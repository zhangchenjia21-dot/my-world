extends SceneTree

const Parser := preload("res://src/行动判定/L1_器件层/结构化判定响应解析器.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const GameRuntime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Adjudication := preload("res://src/行动判定/L3_外交层/行动判定公开接口.gd")
const StubAdapter := preload("res://tests/g4_07a/首次开场桩适配器.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")


class DeterministicRng:
	extends RefCounted
	var values: Array
	var invocation_count := 0
	func _init(faces: Array) -> void:
		values = faces.duplicate()
	func roll_d20() -> int:
		var value := int(values[invocation_count])
		invocation_count += 1
		return value


var _failures := 0
var _task_root := ""
var _fixture := Fixture.new()
var _database_path := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_task_root = _argument("--root=")
	if _task_root.find("g4_09uatbc01") < 0 and _task_root.find("g4_09uatbc02a") < 0:
		_fail("task-owned --root must contain g4_09uatbc01 or g4_09uatbc02a")
		return _finish()
	_fixture.reset_directory(_task_root)
	_test_incremental_framing()
	if not _create_expansion_game():
		return _finish()
	var runtime := GameRuntime.new()
	_check(runtime.open_existing_game(_database_path).success, "setup opens schema-v4 Expansion Game")
	if runtime.is_ready():
		await _test_no_check_progressive(runtime)
		await _test_bounded_recovery_fail_soft(runtime)
		await _test_no_check_failure_cancel_retry(runtime)
		await _test_check_progressive_retry(runtime)
		runtime.close()
	_finish()


func _test_incremental_framing() -> void:
	var parser := Parser.new()
	var no_check := parser.parse(" \n\t{\n  \"decision\": \"NO_CHECK\",\n  \"reason\": \"无风险\"\n}\r\n ", "pretty-no-check")
	_check(no_check.success and String(no_check.decision) == "NO_CHECK", "A isolated control accepts harmless whitespace and pretty-print JSON")
	var check_completed := parser.parse(JSON.stringify(_proposal(15, 2, "normal")), "pretty-check")
	_check(check_completed.success and String(check_completed.decision) == "CHECK_REQUIRED", "A CHECK_REQUIRED remains exact structured mechanics control")
	var mixed := parser.parse(JSON.stringify({"decision": "NO_CHECK", "reason": "无风险"}) + "\n玩家可见正文", "mixed")
	_check(not mixed.success, "A mixed control plus narrative protocol is retired")
	var fenced := parser.parse("```json\n{}\n```", "fenced")
	var preamble := parser.parse("判定如下：" + JSON.stringify({"decision": "NO_CHECK", "reason": "无风险"}), "preamble")
	_check(not fenced.success and not preamble.success, "A fenced/preamble control fails without object guessing")


func _test_no_check_progressive(runtime: RefCounted) -> void:
	var case := _new_process(runtime, [20])
	var accepted_before: int = runtime.conversation.get_durable_accepted_entries().size()
	var world_before := JSON.stringify(runtime.world_state)
	case.process.start_action("c01-no-check-stream", "我询问军报上的日期。")
	case.stub.simulate_delta("  {\n  \"decision\": \"NO_CHECK\",")
	await _delay()
	_check(not runtime.conversation.is_generating(), "B control lane never exposes structured content as narrative")
	case.stub.simulate_delta('\n  "reason": "军报明确"\n}\n ')
	case.stub.simulate_completed()
	await _delay()
	_check(case.stub.requests.size() == 2 and String(case.process._stage) == "no_check_narrative", "B valid NO_CHECK starts a separate free-form narrative request")
	var narrative_request := JSON.stringify(case.stub.requests[1])
	_check(not narrative_request.contains("必须输出首个物理行") and not narrative_request.contains("raw GM narrative body"), "B narrative request has no mixed framing contract")
	case.stub.simulate_delta("第一段")
	await _delay()
	var turn: RefCounted = runtime.conversation.latest_turn()
	var timing: Dictionary = case.process.timing_snapshot()
	_check(case.stub.requests.size() == 2 and case.stub.busy, "B NO_CHECK narrative streams in the second selected-provider call")
	_check(runtime.conversation.is_generating() and String(turn.draft_text) == "第一段", "B first body delta reaches provisional Conversation before completion")
	_check(runtime.conversation.get_durable_accepted_entries().size() == accepted_before and JSON.stringify(runtime.world_state) == world_before, "B body delta performs no durable Conversation/world write")
	_check(timing.has("first_visible_narrative_delta") and not timing.has("provider_completed"), "B timing proves first visible narrative precedes Provider completion")
	case.stub.simulate_delta("，第二段。")
	await _delay()
	case.stub.simulate_completed()
	var final_timing: Dictionary = case.process.timing_snapshot()
	var resolution := _find_no_check(runtime.world_state, "c01-no-check-stream")
	_check(resolution.success and String(resolution.resolution.narrative) == "第一段，第二段。", "B exact streamed body freezes once at completion")
	_check(int(case.process.last_result.provider_calls) == 2 and not bool(case.process.last_result.degraded), "B normal NO_CHECK uses isolated control plus narrative with no degradation")
	_check(runtime.conversation.get_durable_accepted_entries().size() == accepted_before + 1, "B finalize durably accepts exactly one Conversation turn")
	_check(_ordered(final_timing, ["control_request_started", "control_completed", "narrative_request_started", "first_provider_content_delta", "first_visible_narrative_delta", "provider_completed", "finalize_completed", "turn_ready"]), "B timing separates control from free-form narrative and finalize")


func _test_bounded_recovery_fail_soft(runtime: RefCounted) -> void:
	var recovered := _new_process(runtime, [20])
	recovered.process.start_action("c02a-recovered-control", "我询问今日日期。")
	recovered.stub.simulate_delta("无法解析的首次 control")
	recovered.stub.simulate_completed()
	_check(recovered.stub.requests.size() == 2 and String(recovered.process._stage) == "control_recovery", "C malformed control triggers exactly one internal recovery request")
	recovered.stub.simulate_delta(" \n" + JSON.stringify({"decision": "NO_CHECK", "reason": "日期明确"}) + " \n")
	recovered.stub.simulate_completed()
	_check(recovered.stub.requests.size() == 3 and String(recovered.process._stage) == "no_check_narrative", "C recovered control continues through separate narrative lane")
	recovered.stub.simulate_delta("军吏答出今日日期。")
	recovered.stub.simulate_completed()
	_check(recovered.process.last_result.success and not bool(recovered.process.last_result.degraded) and int(recovered.process.last_result.provider_calls) == 3, "C one recovery can resolve normally without fake degradation")

	var degraded := _new_process(runtime, [20])
	var checks_before := _check_count(runtime.world_state)
	var no_checks_before := _no_check_count(runtime.world_state)
	degraded.process.start_action("c02a-degraded-control", "我查看江面风向。")
	degraded.stub.simulate_delta("RAW_CONTROL_MARKER_A")
	degraded.stub.simulate_completed()
	degraded.stub.simulate_delta("RAW_CONTROL_MARKER_B")
	degraded.stub.simulate_completed()
	_check(degraded.stub.requests.size() == 3 and String(degraded.process._stage) == "degraded_narrative", "C second malformed control fail-softs without a third control attempt")
	_check(not JSON.stringify(degraded.stub.requests[2]).contains("RAW_CONTROL_MARKER"), "C degraded narrative request does not echo raw control payload")
	degraded.stub.simulate_delta("江面东南风渐起，战船随浪轻摆。")
	_check(runtime.conversation.is_generating(), "C fail-soft narrative is progressively visible instead of dead-end unfinished")
	degraded.stub.simulate_completed()
	_check(degraded.process.last_result.success and String(degraded.process.last_result.status) == "accepted" and bool(degraded.process.last_result.degraded), "C degraded action returns accepted plus stable non-secret flag")
	_check(String(degraded.process.last_result.degradation_code) == "control_unresolved" and int(degraded.process.last_result.provider_calls) == 3, "C degradation status is bounded and non-secret")
	_check(_check_count(runtime.world_state) == checks_before and _no_check_count(runtime.world_state) == no_checks_before, "C degraded action creates no check and no fake NO_CHECK marker")


func _test_no_check_failure_cancel_retry(runtime: RefCounted) -> void:
	var failed := _new_process(runtime, [20])
	var accepted_before: int = runtime.conversation.get_durable_accepted_entries().size()
	failed.process.start_action("c01-no-check-fail", "我询问营门方向。")
	failed.stub.simulate_delta(_no_check_control("方向明确"))
	failed.stub.simulate_completed()
	failed.stub.simulate_delta("屏幕可见但不会接受")
	var turns_after_first: int = runtime.conversation.turns.size()
	failed.stub.simulate_failed("transport")
	_check(runtime.conversation.get_durable_accepted_entries().size() == accepted_before and not _find_no_check(runtime.world_state, "c01-no-check-fail").success, "C mid-stream failure leaves zero durable result/Conversation")
	_check(not JSON.stringify(runtime.conversation.get_context_projection()).contains("屏幕可见但不会接受"), "C failed partial draft is excluded from future Context")
	failed.process.start_action("c01-no-check-fail", "我询问营门方向。")
	failed.stub.simulate_delta(_no_check_control("方向明确"))
	failed.stub.simulate_completed()
	failed.stub.simulate_delta("军吏重新指出营门。")
	failed.stub.simulate_completed()
	_check(runtime.conversation.turns.size() == turns_after_first and failed.stub.requests.size() == 4, "D same-process retry reuses provisional Turn across decoupled calls")

	var cancelled := _new_process(runtime, [20])
	accepted_before = runtime.conversation.get_durable_accepted_entries().size()
	cancelled.process.start_action("c01-no-check-cancel", "我查看眼前的旗号。")
	cancelled.stub.simulate_delta(_no_check_control("旗号可见"))
	cancelled.stub.simulate_completed()
	cancelled.stub.simulate_delta("这段在取消前可见")
	var cancel_turns: int = runtime.conversation.turns.size()
	cancelled.process.cancel()
	_check(runtime.conversation.get_durable_accepted_entries().size() == accepted_before and not _find_no_check(runtime.world_state, "c01-no-check-cancel").success, "C cancel leaves no accepted/durable NO_CHECK result")
	cancelled.process.start_action("c01-no-check-cancel", "我查看眼前的旗号。")
	cancelled.stub.simulate_delta(_no_check_control("旗号可见"))
	cancelled.stub.simulate_completed()
	cancelled.stub.simulate_delta("旗号属于本营。")
	cancelled.stub.simulate_completed()
	_check(runtime.conversation.turns.size() == cancel_turns and cancelled.stub.requests.size() == 4, "D cancelled action retry reuses one Turn and one stable action")


func _test_check_progressive_retry(runtime: RefCounted) -> void:
	var case := _new_process(runtime, [3])
	var accepted_before: int = runtime.conversation.get_durable_accepted_entries().size()
	case.process.start_action("c01-check-stream", "我冒险潜入敌营。")
	var control := JSON.stringify(_proposal(18, 1, "normal"))
	case.stub.simulate_delta(control.substr(0, 17))
	await _delay()
	case.stub.simulate_delta(control.substr(17))
	case.stub.simulate_completed()
	var durable := _find_check(runtime.world_state, "c01-check-stream")
	var timing: Dictionary = case.process.timing_snapshot()
	_check(durable.success and int(durable.check.raw_rolls[0]) == 3 and String(durable.check.outcome) == "failure", "D exact Program check is durable before result narrative")
	_check(case.rng.invocation_count == 1 and case.stub.requests.size() == 2, "D validated control performs one RNG then starts second Provider call")
	_check(runtime.conversation.is_generating() and runtime.conversation.get_durable_accepted_entries().size() == accepted_before, "D provisional Turn is active behind finalize barrier")
	_check(_ordered(timing, ["control_completed", "durable_check_completed", "resolution_narrative_request_started"]), "E timing proves durable check before narrative request")
	await _delay()
	case.stub.simulate_delta("守卫发现了你的踪迹；")
	await _delay()
	timing = case.process.timing_snapshot()
	_check(String(runtime.conversation.latest_turn().draft_text) == "守卫发现了你的踪迹；" and not timing.has("provider_completed"), "D result narrative is visible while second Provider remains active")
	_check(int(timing.durable_check_completed) <= int(timing.first_visible_narrative_delta), "D first visible result delta occurs only after durable check")
	var turns_before_retry: int = runtime.conversation.turns.size()
	case.stub.simulate_failed("transport")
	case.process.start_action("c01-check-stream", "我冒险潜入敌营。")
	_check(case.rng.invocation_count == 1 and case.stub.requests.size() == 3 and runtime.conversation.turns.size() == turns_before_retry, "D retry reuses exact check/provisional Turn with no reroll or duplicate")
	case.stub.simulate_delta("守卫截断退路，既定失败生效。")
	await _delay()
	case.stub.simulate_completed()
	durable = _find_check(runtime.world_state, "c01-check-stream")
	_check(runtime.conversation.get_durable_accepted_entries().size() == accepted_before + 1 and int(durable.check.raw_rolls[0]) == 3, "D retry finalizes exactly once and preserves raw roll")


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
	creation.set_settings("G4-09UATBC01", "Light", "")
	var create_root := _task_root.path_join("create")
	var created: Dictionary = FinalCreate.new(
		library, create_root.path_join("creation"), create_root.path_join("library"), create_root.path_join("games")
	).create_or_resume("g4-09uatbc01", creation.composition_snapshot())
	_check(created.success, "setup creates one task-owned Expansion Game")
	if created.success:
		_database_path = String(created.database_path)
	return created.success


func _new_process(runtime: Variant, faces: Array) -> Dictionary:
	var stub := StubAdapter.new()
	var rng := DeterministicRng.new(faces)
	var process := Adjudication.new(runtime, stub, rng)
	root.add_child(process)
	return {"process": process, "stub": stub, "rng": rng}


func _proposal(dc: int, modifier: int, stance: String) -> Dictionary:
	return {"decision": "CHECK_REQUIRED", "proposal": {
		"intent": "完成高风险行动", "dc": dc, "modifier": modifier, "stance": stance,
		"modifier_reason": "来自 Game-local 事实", "situation_reason": "存在不确定性与代价",
		"success_intent": "行动达成", "failure_stakes": "暴露并承受后果",
	}}


func _no_check_control(reason: String) -> String:
	return JSON.stringify({"decision": "NO_CHECK", "reason": reason})


func _check_count(world_state: Dictionary) -> int:
	return world_state.get("expansion_runtime", {}).get("public_d20_checks", []).size()


func _no_check_count(world_state: Dictionary) -> int:
	return world_state.get("expansion_runtime", {}).get("public_d20_no_check_actions", []).size()


func _find_no_check(world_state: Dictionary, action_id: String) -> Dictionary:
	for value: Variant in world_state.get("expansion_runtime", {}).get("public_d20_no_check_actions", []):
		if value is Dictionary and String(value.get("action_id", "")) == action_id:
			return {"success": true, "resolution": value}
	return {"success": false, "resolution": {}}


func _find_check(world_state: Dictionary, action_id: String) -> Dictionary:
	for value: Variant in world_state.get("expansion_runtime", {}).get("public_d20_checks", []):
		if value is Dictionary and String(value.get("action_id", "")) == action_id:
			return {"success": true, "check": value}
	return {"success": false, "check": {}}


func _ordered(timing: Dictionary, names: Array[String]) -> bool:
	var previous := -1
	for name: String in names:
		if not timing.has(name) or int(timing[name]) < previous:
			return false
		previous = int(timing[name])
	return true


func _delay() -> void:
	await create_timer(0.01).timeout


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-09UATBC02A PASS | " + label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-09UATBC02A FAIL | " + label)


func _finish() -> void:
	print("G4-09UATBC02A | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
