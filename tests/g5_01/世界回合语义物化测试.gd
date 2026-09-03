extends SceneTree

const Conversation := preload("res://src/domain/会话.gd")
const WorldTurn := preload("res://src/世界回合/L3_外交层/世界回合公开接口.gd")
const WorldTurnContext := preload("res://src/世界回合/L3_外交层/世界回合上下文公开接口.gd")
const StubAdapter := preload("res://tests/g5_01/世界回合语义桩适配器.gd")

class ControlledRuntime:
	extends RefCounted

	var conversation: RefCounted = Conversation.new()
	var game_id := "game-g5-01-controlled"
	var active_head_id := "root"
	var world_state: Dictionary = {"setup": "legacy-g4"}
	var commit_count := 0
	var fail_commit := false

	func is_ready() -> bool:
		return true

	func commit_world_mutation_durably(_mutation_id: String, node_id: String, candidate: Dictionary) -> Dictionary:
		commit_count += 1
		if fail_commit:
			return {"success": false, "status": "storage_failure", "message": "controlled persistence failure"}
		active_head_id = node_id
		world_state = candidate.duplicate(true)
		return {"success": true, "status": "committed", "head_id": node_id, "world_state": world_state.duplicate(true)}

var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await _test_trigger_and_success()
	await _test_fail_soft_results()
	await _test_persistence_failure()
	await _test_opening_skip()
	_test_projection_filtering_and_bounds()
	print("G5-01 FOCUSED | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)


func _test_trigger_and_success() -> void:
	var runtime := ControlledRuntime.new()
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	runtime.conversation.begin_turn("我修好了村口被冲毁的木桥。")
	runtime.conversation.append_delta("村民确认木桥已经恢复通行。")
	await process_frame
	_check(stub.requests.is_empty() and runtime.commit_count == 0, "provisional streaming text never starts materialization")
	runtime.conversation.cancel_generation()
	await process_frame
	_check(stub.requests.is_empty(), "cancelled narrative never starts materialization")
	runtime.conversation.retry_or_regenerate_latest()
	runtime.conversation.append_delta("未接受的失败草稿")
	runtime.conversation.fail_generation("transport")
	await process_frame
	_check(stub.requests.is_empty(), "failed narrative never starts materialization")
	runtime.conversation.retry_or_regenerate_latest()
	runtime.conversation.append_delta("村民确认木桥已经恢复通行。")
	runtime.conversation.complete_generation()
	await process_frame
	_check(stub.requests.size() == 1 and worker.analysis_attempt_count == 1, "durable accepted ordinary turn starts exactly one separate analysis")
	_check(JSON.stringify(stub.requests[0]).contains("我修好了村口") and JSON.stringify(stub.requests[0]).contains("恢复通行"), "analysis request contains accepted player and GM pair")
	stub.simulate_delta('{"changes":["村口木桥已修复并恢复通行。"]}')
	stub.simulate_completed()
	await process_frame
	var records := runtime.world_state.living_world.semantic_turns_by_index as Dictionary
	_check(worker.last_result.status == "committed" and runtime.commit_count == 1 and records.size() == 1, "valid analysis commits exactly one World Turn")
	_check(String(runtime.world_state.living_world.schema_version) == "living_world.v0.1" and String(runtime.world_state.setup) == "legacy-g4", "legacy G4 World gains optional living_world without losing prior state")
	worker.consider_latest_accepted_turn()
	await process_frame
	_check(stub.requests.size() == 1 and runtime.commit_count == 1 and worker.last_result.status == "already_materialized", "same accepted version replay is idempotent")
	worker.shutdown()
	worker.queue_free()


func _test_fail_soft_results() -> void:
	for mode: String in ["empty", "malformed", "transport", "synchronous"]:
		var runtime := ControlledRuntime.new()
		var stub := StubAdapter.new()
		stub.synchronous_failure = mode == "synchronous"
		var worker := WorldTurn.new(runtime, stub)
		root.add_child(worker)
		await process_frame
		_accept(runtime, "我观察四周。", "四周暂时没有形成新的持久变化。")
		await process_frame
		if mode == "empty":
			stub.simulate_delta('{"changes":[]}')
			stub.simulate_completed()
		elif mode == "malformed":
			stub.simulate_delta("不是 JSON")
			stub.simulate_completed()
		elif mode == "transport":
			stub.simulate_failed()
		await process_frame
		var accepted: Array = runtime.conversation.get_durable_accepted_entries()
		_check(accepted.size() == 1 and runtime.commit_count == 0 and not runtime.world_state.has("living_world"), "%s analysis failure/empty preserves accepted Conversation and creates no mutation" % mode)
		_check(worker.analysis_attempt_count == 1 and stub.requests.size() == 1, "%s performs no automatic retry" % mode)
		worker.shutdown()
		worker.queue_free()


func _test_persistence_failure() -> void:
	var runtime := ControlledRuntime.new()
	runtime.fail_commit = true
	var before := runtime.world_state.duplicate(true)
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	_accept(runtime, "我点燃了废弃烽火台。", "烽火已经升起，附近哨所都能看见。")
	await process_frame
	stub.simulate_delta('{"changes":["废弃烽火台重新燃起烽火。"]}')
	stub.simulate_completed()
	await process_frame
	_check(worker.last_result.status == "persistence_failure" and runtime.world_state == before, "persistence failure does not publish candidate World memory")
	_check(runtime.conversation.get_durable_accepted_entries().size() == 1, "persistence failure does not roll back accepted Conversation")
	worker.shutdown()
	worker.queue_free()


func _test_opening_skip() -> void:
	var runtime := ControlledRuntime.new()
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	runtime.conversation.begin_gm_opening()
	runtime.conversation.append_delta("这是只由 GM 叙述的首次开场。")
	runtime.conversation.complete_generation()
	await process_frame
	_check(worker.last_result.status == "opening_skipped" and stub.requests.is_empty(), "GM-only Opening is excluded")
	worker.shutdown()
	worker.queue_free()


func _test_projection_filtering_and_bounds() -> void:
	var accepted: Array = []
	var records: Dictionary = {}
	for index: int in range(10):
		var gm := "已接受叙事 %d" % index
		accepted.append({"turn_index": index, "player_text": "行动", "gm_text": gm})
		var hash := gm.sha256_text()
		records[str(index)] = {
			"world_turn_id": "record-%d" % index,
			"source_turn_index": index,
			"source_gm_sha256": hash,
			"materialized_at": "2026-09-03T00:00:00Z",
			"changes": ["MATCHING_CHANGE_%d" % index],
		}
	records["1"].source_gm_sha256 = "stale"
	records["broken"] = {"world_turn_id": "broken", "source_turn_index": 77, "changes": []}
	var projected := WorldTurnContext.new().project({"living_world": {"schema_version": "living_world.v0.1", "semantic_turns_by_index": records}}, accepted)
	_check(projected.record_count == 8 and projected.rejected_count == 2, "Context projection is bounded to eight matching committed records and counts stale/malformed records")
	var text := String(projected.context_text)
	_check(text.contains("MATCHING_CHANGE_9") and not text.contains("MATCHING_CHANGE_0") and not text.contains("MATCHING_CHANGE_1"), "Context keeps recent matching consequences and excludes bounded-old/stale material")
	var empty := WorldTurnContext.new().project({}, accepted)
	_check(empty.record_count == 0 and String(empty.context_text).is_empty(), "uncommitted candidate outside current World does not project")


func _accept(runtime: ControlledRuntime, player: String, gm: String) -> void:
	runtime.conversation.begin_turn(player)
	runtime.conversation.append_delta(gm)
	runtime.conversation.complete_generation()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G5-01 FOCUSED PASS | %s" % label)
	else:
		_failures += 1
		push_error("G5-01 FOCUSED FAIL | %s" % label)
