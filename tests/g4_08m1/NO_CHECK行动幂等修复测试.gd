extends SceneTree

const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const GameRuntime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Adjudication := preload("res://src/行动判定/L3_外交层/行动判定公开接口.gd")
const StubAdapter := preload("res://tests/g4_07a/首次开场桩适配器.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")


class CountingRng:
	extends RefCounted
	var invocation_count := 0
	func roll_d20() -> int:
		invocation_count += 1
		return 20


## task-only fault proxy：真实执行 Window A 的 marker COMMIT 后丢 ACK，或在 Window B
## final marker COMMIT 前返回失败。production runtime 不增加测试 fault flag。
class LostAckRuntimeProxy:
	extends RefCounted
	var base: RefCounted
	var fail_commit_number: int
	var commit_count := 0
	var game_id := ""
	var world_state: Dictionary = {}
	var conversation: RefCounted

	func _init(runtime: RefCounted, target_commit: int) -> void:
		base = runtime
		fail_commit_number = target_commit
		_sync()

	func is_ready() -> bool:
		return base.is_ready()

	func complete_active_generation_durably() -> Dictionary:
		return base.complete_active_generation_durably()

	func commit_world_mutation_durably(mutation_id: String, node_id: String, next: Dictionary) -> Dictionary:
		commit_count += 1
		if commit_count == fail_commit_number and fail_commit_number == 2:
			return {"success": false, "status": "injected_lost_ack", "message": "Window B marker ACK lost before publish"}
		var committed: Dictionary = base.commit_world_mutation_durably(mutation_id, node_id, next)
		_sync()
		if commit_count == fail_commit_number:
			return {"success": false, "status": "injected_lost_ack", "message": "Window A durable COMMIT ACK lost"}
		return committed

	func _sync() -> void:
		game_id = String(base.game_id)
		world_state = base.world_state
		conversation = base.conversation


var _failures := 0
var _task_root := ""
var _fixture := Fixture.new()
var _database_path := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_task_root = _argument("--root=")
	if _task_root.find("g4_08m1") < 0:
		_fail("task-owned --root must contain g4_08m1")
		return _finish()
	_fixture.reset_directory(_task_root)
	if not _create_expansion_game():
		return _finish()
	await _test_first_replay_conflict_and_pre_result_failure()
	await _test_lost_ack_window_a()
	await _test_lost_ack_window_b()
	_finish()


func _create_expansion_game() -> bool:
	var installed: Dictionary = _fixture.install_real_assets(_task_root.path_join("source-library"))
	_check(installed.success, "setup installs frozen real Source generations")
	if not installed.success:
		return false
	var library: RefCounted = installed.library
	var expansion: Dictionary = library.install_expansion_pack("res://tests/fixtures/g4_08m1/判定与检定_公开d20")
	_check(expansion.success, "setup installs Public d20 exact generation")
	if not expansion.success:
		return false
	var creation := Creation.new(library)
	creation.select_world(_fixture.find_generation(installed.installed, "world.han_end.unsettled_realm"))
	creation.select_entry("t0-208-red-cliffs-eve")
	creation.set_expansion(expansion.generation, true)
	creation.select_player(_fixture.find_generation(installed.installed, "character.han_end.liu_bei"))
	creation.set_settings("G4-08M1C01", "Light", "")
	var create_root := _task_root.path_join("create")
	var created: Dictionary = FinalCreate.new(
		library, create_root.path_join("creation"), create_root.path_join("library"), create_root.path_join("games")
	).create_or_resume("g4-08m1c01", creation.composition_snapshot())
	_check(created.success, "setup creates one schema-v4 Expansion Game")
	if created.success:
		_database_path = String(created.database_path)
	return created.success


func _test_first_replay_conflict_and_pre_result_failure() -> void:
	var runtime := GameRuntime.new()
	_check(runtime.open_existing_game(_database_path).success, "A opens existing Game")
	var first := _new_process(runtime)
	first.process.start_action("no-check-a", "我向侍从询问今日日期。")
	first.stub.simulate_delta(_no_check("已知且无风险", "侍从立即答出今日日期。"))
	first.stub.simulate_completed()
	var marker := _find_no_check(runtime.world_state, "no-check-a")
	_check(first.stub.requests.size() == 1 and first.rng.invocation_count == 0, "A first execution uses one Provider call and zero RNG")
	_check(runtime.conversation.get_durable_accepted_entries().size() == 1, "A accepts exactly one durable Conversation turn")
	_check(marker.success and marker.resolution.narrative_accepted and _check_count(runtime.world_state) == 0, "A durable NO_CHECK replay identity exists without fake check")

	var replay := _new_process(runtime)
	var replayed: Dictionary = replay.process.start_action("no-check-a", "我向侍从询问今日日期。")
	_check(replayed.success and String(replayed.status) == "already_accepted", "B same-process replay returns already_accepted")
	_check(replay.stub.requests.is_empty() and replay.rng.invocation_count == 0 and runtime.conversation.get_durable_accepted_entries().size() == 1, "B replay has zero Provider/RNG/new Conversation")

	var conflict := _new_process(runtime)
	var conflicted: Dictionary = conflict.process.start_action("no-check-a", "我改为询问明日日期。")
	_check(not conflicted.success and String(conflicted.code) == "action_payload_conflict", "D changed payload fails loud")
	_check(conflict.stub.requests.is_empty() and conflict.rng.invocation_count == 0 and runtime.conversation.get_durable_accepted_entries().size() == 1, "D conflict has no side effect")
	runtime.close()

	var reopened := GameRuntime.new()
	_check(reopened.open_existing_game(_database_path).success, "C fresh runtime reopens same Game")
	var fresh := _new_process(reopened)
	var fresh_result: Dictionary = fresh.process.start_action("no-check-a", "我向侍从询问今日日期。")
	_check(fresh_result.success and String(fresh_result.status) == "already_accepted", "C reopen replay identifies exact accepted action")
	_check(fresh.stub.requests.is_empty() and fresh.rng.invocation_count == 0 and reopened.conversation.get_durable_accepted_entries().size() == 1, "C reopen replay has zero Provider/RNG/duplicate turn")

	var failed := _new_process(reopened)
	failed.process.start_action("no-check-retry", "我向军吏询问营门位置。")
	failed.stub.simulate_failed("transport")
	_check(not _find_no_check(reopened.world_state, "no-check-retry").success, "E Provider failure creates no false marker")
	var invalid := _new_process(reopened)
	invalid.process.start_action("no-check-invalid", "我询问当前时辰。")
	invalid.stub.simulate_delta("{invalid")
	invalid.stub.simulate_completed()
	_check(not _find_no_check(reopened.world_state, "no-check-invalid").success, "E invalid envelope creates no false marker")
	var retry := _new_process(reopened)
	retry.process.start_action("no-check-retry", "我向军吏询问营门位置。")
	retry.stub.simulate_delta(_no_check("营门位置明确", "军吏抬手指出营门方向。"))
	retry.stub.simulate_completed()
	_check(_find_no_check(reopened.world_state, "no-check-retry").success and reopened.conversation.get_durable_accepted_entries().size() == 2, "E pre-result failure remains safely retryable")
	reopened.close()


func _test_lost_ack_window_a() -> void:
	var runtime := GameRuntime.new()
	runtime.open_existing_game(_database_path)
	var proxy := LostAckRuntimeProxy.new(runtime, 1)
	var interrupted := _new_process(proxy)
	var before_count: int = runtime.conversation.get_durable_accepted_entries().size()
	interrupted.process.start_action("window-a", "我询问已经写在军报上的日期。")
	interrupted.stub.simulate_delta(_no_check("军报可直接读取", "你展开军报，日期清楚地写在页首。"))
	interrupted.stub.simulate_completed()
	_check(_find_no_check(runtime.world_state, "window-a").success and runtime.conversation.get_durable_accepted_entries().size() == before_count, "F1 Window A leaves frozen result before Conversation")
	runtime.close()

	var reopened := GameRuntime.new()
	reopened.open_existing_game(_database_path)
	var resumed := _new_process(reopened)
	var result: Dictionary = resumed.process.start_action("window-a", "我询问已经写在军报上的日期。")
	_check(result.success and String(result.status) == "accepted" and int(result.provider_calls) == 0, "F1 retry resumes frozen narrative with zero Provider")
	_check(resumed.stub.requests.is_empty() and resumed.rng.invocation_count == 0 and reopened.conversation.get_durable_accepted_entries().size() == before_count + 1, "F1 retry accepts exactly one stored turn without RNG")
	reopened.close()


func _test_lost_ack_window_b() -> void:
	var runtime := GameRuntime.new()
	runtime.open_existing_game(_database_path)
	var proxy := LostAckRuntimeProxy.new(runtime, 2)
	var interrupted := _new_process(proxy)
	var before_count: int = runtime.conversation.get_durable_accepted_entries().size()
	interrupted.process.start_action("window-b", "我查看桌上已经摊开的地图。")
	interrupted.stub.simulate_delta(_no_check("地图已在眼前", "你俯身看清地图上标出的渡口。"))
	interrupted.stub.simulate_completed()
	var marker := _find_no_check(runtime.world_state, "window-b")
	_check(marker.success and not marker.resolution.narrative_accepted and runtime.conversation.get_durable_accepted_entries().size() == before_count + 1, "F2 Window B leaves accepted Conversation before final marker")
	runtime.close()

	var reopened := GameRuntime.new()
	reopened.open_existing_game(_database_path)
	var recovered := _new_process(reopened)
	var result: Dictionary = recovered.process.start_action("window-b", "我查看桌上已经摊开的地图。")
	var final_marker := _find_no_check(reopened.world_state, "window-b")
	_check(result.success and String(result.status) == "already_accepted" and final_marker.resolution.narrative_accepted, "F2 retry matches exact Conversation slot and finalizes marker")
	_check(recovered.stub.requests.is_empty() and recovered.rng.invocation_count == 0 and reopened.conversation.get_durable_accepted_entries().size() == before_count + 1, "F2 recovery has zero Provider/RNG/duplicate turn")
	reopened.close()


func _new_process(runtime: Variant) -> Dictionary:
	var stub := StubAdapter.new()
	var rng := CountingRng.new()
	var process := Adjudication.new(runtime, stub, rng)
	root.add_child(process)
	return {"process": process, "stub": stub, "rng": rng}


func _no_check(reason: String, narrative: String) -> String:
	return JSON.stringify({"decision": "NO_CHECK", "reason": reason}) + "\n" + narrative


func _find_no_check(world_state: Dictionary, action_id: String) -> Dictionary:
	for value: Variant in world_state.get("expansion_runtime", {}).get("public_d20_no_check_actions", []):
		if value is Dictionary and String(value.get("action_id", "")) == action_id:
			return {"success": true, "resolution": value}
	return {"success": false, "resolution": {}}


func _check_count(world_state: Dictionary) -> int:
	return world_state.get("expansion_runtime", {}).get("public_d20_checks", []).size()


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-08M1C01 PASS | " + label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-08M1C01 FAIL | " + label)


func _finish() -> void:
	print("G4-08M1C01 | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
