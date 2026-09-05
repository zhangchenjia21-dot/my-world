extends SceneTree

## MW-006 机制锚定世界后果 Vertical focused proof。
## 只证明：既有 authoritative CHECK_REQUIRED durable resolution 经只读取回进入
## G5-01 语义 request 恰好一次；模型（stub）仍自主 author 0..N durable consequences；
## NO_CHECK / 普通路径无伪造 mechanics block；malformed 语义 fail-soft；
## replay/reopen 无 duplicate mutation；durable mechanics 与既有 schema 不变。

const Conversation := preload("res://src/domain/会话.gd")
const WorldTurn := preload("res://src/世界回合/L3_外交层/世界回合公开接口.gd")
const D20Rules := preload("res://src/行动判定/L0_公理层/公开D20判定规则.gd")
const StubAdapter := preload("res://tests/g5_01/世界回合语义桩适配器.gd")

const GROUNDING_MARKER := "Durable Mechanical Resolution"

class ControlledRuntime:
	extends RefCounted

	var conversation: RefCounted = Conversation.new()
	var game_id := "game-mw-006-controlled"
	var active_head_id := "root"
	var world_state: Dictionary = {"setup": "legacy-g4"}
	var commit_count := 0

	func is_ready() -> bool:
		return true

	func commit_world_mutation_durably(_mutation_id: String, node_id: String, candidate: Dictionary) -> Dictionary:
		commit_count += 1
		active_head_id = node_id
		world_state = candidate.duplicate(true)
		return {"success": true, "status": "committed", "head_id": node_id, "world_state": world_state.duplicate(true)}

var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await _test_check_required_grounding_and_materialization()
	await _test_no_check_and_ordinary_paths_unchanged()
	await _test_fail_soft_and_ambiguity()
	print("MW-006 FOCUSED | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)


func _test_check_required_grounding_and_materialization() -> void:
	var runtime := ControlledRuntime.new()
	var check := _durable_check("action-climb-wall", "我趁夜攀爬东侧城墙，想看清城中守军布防。", 0)
	runtime.world_state = {"setup": "legacy-g4", "expansion_runtime": {"public_d20_checks": [check.duplicate(true)], "public_d20_no_check_actions": []}}
	var before_world := runtime.world_state.duplicate(true)
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	_accept(runtime, String(check.player_text), "灯笼的光晃过墙头，你被巡夜守卫喝止并驱离；守军随即加派了东墙人手。")
	await process_frame
	await process_frame
	_check(stub.requests.size() == 1, "accepted CHECK_REQUIRED turn starts exactly one semantic analysis")
	var user_content := String((stub.requests[0][1] as Dictionary).get("content", ""))
	var system_content := String((stub.requests[0][0] as Dictionary).get("content", ""))
	_check(user_content.count(GROUNDING_MARKER) == 1, "durable mechanical resolution appears in semantic request exactly once")
	_check(user_content.contains(String(check.check_id)) and user_content.contains('outcome: "failure"') and user_content.contains("- total: 13") and user_content.contains("- selected_roll: 11"), "grounding carries the exact Program-owned d20 facts")
	_check(system_content.contains(GROUNDING_MARKER) and system_content.contains("不得改写、重掷或虚构判定结果") and system_content.contains("不对应任何固定世界后果"), "analysis instructions bound the mechanics to respect-without-fixed-mapping")
	# deterministic fake semantic output grounded in the mechanics fact materializes durable consequence
	stub.simulate_delta('{"changes":["东墙巡夜守卫加倍，守军已察觉有人窥探布防。"]}')
	stub.simulate_completed()
	await process_frame
	_check(worker.last_result.status == "committed" and runtime.commit_count == 1, "model-authored consequence commits through the existing single semantic mutation")
	var records: Dictionary = (runtime.world_state.get("living_world", {}) as Dictionary).get("semantic_turns_by_index", {})
	_check((records.get("0", {}) as Dictionary).get("changes", []) == ["东墙巡夜守卫加倍，守军已察觉有人窥探布防。"], "committed record keeps the accepted-version identity contract")
	var after_keys := runtime.world_state.keys()
	_check(after_keys.size() == before_world.keys().size() + 1 and after_keys.has("living_world") and not after_keys.has("mechanical_resolution"), "no new world schema family beyond living_world")
	_check((runtime.world_state.get("expansion_runtime", {}) as Dictionary) == (before_world.get("expansion_runtime", {}) as Dictionary), "durable mechanical resolution is unchanged by semantic materialization")
	# replay / reopen：不 reroll、不 duplicate mutation、不重发请求
	worker.consider_latest_accepted_turn()
	await process_frame
	_check(stub.requests.size() == 1 and runtime.commit_count == 1 and worker.last_result.status == "already_materialized", "same accepted version replay is idempotent")
	worker.shutdown()
	worker.queue_free()
	var reopen_stub := StubAdapter.new()
	var reopened := WorldTurn.new(runtime, reopen_stub)
	root.add_child(reopened)
	await process_frame
	reopened.consider_latest_accepted_turn()
	await process_frame
	_check(reopen_stub.requests.is_empty() and runtime.commit_count == 1 and reopened.last_result.status == "already_materialized", "reopen replay relies on durable record, no duplicate mutation")
	reopened.shutdown()
	reopened.queue_free()


func _test_no_check_and_ordinary_paths_unchanged() -> void:
	# NO_CHECK：durable resolution 存在但不携带任何 mechanics grounding。
	var no_check_runtime := ControlledRuntime.new()
	no_check_runtime.world_state = {
		"setup": "legacy-g4",
		"expansion_runtime": {
			"public_d20_checks": [],
			"public_d20_no_check_actions": [{
				"resolution_id": D20Rules.no_check_resolution_id("game-mw-006-controlled", "action-rest"),
				"action_id": "action-rest", "player_text": "我在客栈歇息一夜。", "branch": "NO_CHECK",
				"reason": "日常休整，无需检定", "narrative": "你在客栈安睡到天明。",
				"conversation_base_count": 0, "narrative_accepted": true, "accepted_turn_index": 0,
			}],
		},
	}
	var no_check_stub := StubAdapter.new()
	var no_check_worker := WorldTurn.new(no_check_runtime, no_check_stub)
	root.add_child(no_check_worker)
	await process_frame
	_accept(no_check_runtime, "我在客栈歇息一夜。", "你在客栈安睡到天明，次日精神饱满。")
	await process_frame
	await process_frame
	var no_check_content := String((no_check_stub.requests[0][1] as Dictionary).get("content", ""))
	_check(no_check_stub.requests.size() == 1 and not no_check_content.contains(GROUNDING_MARKER), "NO_CHECK accepted turn gets no fake mechanics block")
	no_check_stub.simulate_delta('{"changes":["你在客栈得到充分休息。"]}')
	no_check_stub.simulate_completed()
	await process_frame
	_check(no_check_worker.last_result.status == "committed" and no_check_runtime.commit_count == 1, "NO_CHECK semantic path itself stays unchanged")
	no_check_worker.shutdown()
	no_check_worker.queue_free()
	# 普通（无 Expansion）路径：无 expansion_runtime，语义 request 不含 mechanics block。
	var ordinary_runtime := ControlledRuntime.new()
	var ordinary_stub := StubAdapter.new()
	var ordinary_worker := WorldTurn.new(ordinary_runtime, ordinary_stub)
	root.add_child(ordinary_worker)
	await process_frame
	_accept(ordinary_runtime, "我观察四周。", "四周暂时没有形成新的持久变化。")
	await process_frame
	await process_frame
	var ordinary_content := String((ordinary_stub.requests[0][1] as Dictionary).get("content", ""))
	_check(ordinary_stub.requests.size() == 1 and not ordinary_content.contains(GROUNDING_MARKER), "ordinary non-expansion turn gets no mechanics block")
	ordinary_worker.shutdown()
	ordinary_worker.queue_free()


func _test_fail_soft_and_ambiguity() -> void:
	# malformed 语义结果：accepted Narrative 与 durable mechanics 都不受影响。
	var runtime := ControlledRuntime.new()
	var check := _durable_check("action-climb-wall", "我趁夜攀爬东侧城墙，想看清城中守军布防。", 0)
	runtime.world_state = {"setup": "legacy-g4", "expansion_runtime": {"public_d20_checks": [check.duplicate(true)], "public_d20_no_check_actions": []}}
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	_accept(runtime, String(check.player_text), "你被巡夜守卫喝止并驱离。")
	await process_frame
	await process_frame
	_check(stub.requests.size() == 1, "grounded request dispatched before malformed response")
	stub.simulate_delta("不是 JSON 的输出")
	stub.simulate_completed()
	await process_frame
	_check(not worker.last_result.success and runtime.commit_count == 0 and not runtime.world_state.has("living_world"), "malformed analysis creates no fake world mutation")
	_check(runtime.conversation.get_durable_accepted_entries().size() == 1, "accepted Narrative remains accepted")
	_check((runtime.world_state.get("expansion_runtime", {}) as Dictionary).get("public_d20_checks", []) == [check], "durable mechanical resolution remains authoritative and untouched")
	worker.shutdown()
	worker.queue_free()
	# marker 缺失 / player_text 不一致 / 多重命中：一律 fail-soft 无 block。
	var absent_marker_runtime := ControlledRuntime.new()
	var absent_check := _durable_check("action-a", "行动甲", 0, false)
	absent_marker_runtime.world_state = {"setup": "legacy-g4", "expansion_runtime": {"public_d20_checks": [absent_check], "public_d20_no_check_actions": []}}
	var absent_grounding := _grounding_for(absent_marker_runtime, "行动甲", 0)
	_check(absent_grounding.is_empty(), "unaccepted marker yields no grounding")
	var mismatch_runtime := ControlledRuntime.new()
	mismatch_runtime.world_state = {"setup": "legacy-g4", "expansion_runtime": {"public_d20_checks": [_durable_check("action-b", "行动乙", 0)], "public_d20_no_check_actions": []}}
	_check(_grounding_for(mismatch_runtime, "行动丙", 0).is_empty(), "player_text mismatch (e.g. after Restore) yields no grounding")
	var ambiguous_runtime := ControlledRuntime.new()
	ambiguous_runtime.world_state = {"setup": "legacy-g4", "expansion_runtime": {"public_d20_checks": [_durable_check("action-c", "行动丁", 0), _durable_check("action-d", "行动丁", 0)], "public_d20_no_check_actions": []}}
	_check(_grounding_for(ambiguous_runtime, "行动丁", 0).is_empty(), "ambiguous duplicate durable checks yield no grounding")


func _grounding_for(runtime: ControlledRuntime, player_text: String, turn_index: int) -> String:
	var check := D20Rules.matching_accepted_check_for_turn(runtime.world_state, turn_index, player_text)
	return "" if check.is_empty() else GROUNDING_MARKER


func _durable_check(action_id: String, player_text: String, accepted_index: int, accepted: bool = true) -> Dictionary:
	var check := {
		"action_id": action_id,
		"intent": "趁夜攀爬东侧城墙侦察布防",
		"dc": 14, "modifier": 2, "stance": "normal",
		"modifier_reason": "轻装夜行", "situation_reason": "守卫换岗间隙",
		"success_intent": "看清守军布防而不被发现",
		"failure_stakes": "被巡夜守卫发现并驱离",
		"raw_rolls": [11], "selected_roll": 11, "total": 13, "outcome": "failure",
		"check_id": D20Rules.check_id("game-mw-006-controlled", action_id),
		"player_text": player_text,
		"conversation_base_count": accepted_index,
		"narrative_accepted": accepted,
	}
	if accepted:
		check["accepted_turn_index"] = accepted_index
	return check


func _accept(runtime: ControlledRuntime, player: String, gm: String) -> void:
	runtime.conversation.begin_turn(player)
	runtime.conversation.append_delta(gm)
	runtime.conversation.complete_generation()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("MW-006 FOCUSED PASS | %s" % label)
	else:
		_failures += 1
		push_error("MW-006 FOCUSED FAIL | %s" % label)
