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
	if _task_root.find("g4_09uatbc01") < 0:
		_fail("task-owned --root must contain g4_09uatbc01")
		return _finish()
	_fixture.reset_directory(_task_root)
	_test_incremental_framing()
	if not _create_expansion_game():
		return _finish()
	var runtime := GameRuntime.new()
	_check(runtime.open_existing_game(_database_path).success, "setup opens schema-v4 Expansion Game")
	if runtime.is_ready():
		await _test_no_check_progressive(runtime)
		await _test_no_check_failure_cancel_retry(runtime)
		await _test_check_progressive_retry(runtime)
		runtime.close()
	_finish()


func _test_incremental_framing() -> void:
	var parser := Parser.new()
	parser.reset("split-no-check")
	var first := parser.push_delta('{"deci')
	var second := parser.push_delta('sion":"NO_CHECK","reason":"无风险"}\n第一段')
	var third := parser.push_delta("，第二段。")
	var completed := parser.finish()
	_check(first.success and String(first.status) == "awaiting_header", "A arbitrary split buffers incomplete control header")
	_check(second.success and String(second.narrative_delta) == "第一段", "A valid NO_CHECK header releases same-chunk body only")
	_check(third.success and String(third.narrative_delta) == "，第二段。", "A later raw body remains exact delta")
	_check(completed.success and String(completed.narrative) == "第一段，第二段。", "A finish returns exact accumulated NO_CHECK body")

	var check_parser := Parser.new()
	check_parser.reset("split-check")
	var wire := JSON.stringify(_proposal(15, 2, "normal"))
	check_parser.push_delta(wire.substr(0, 11))
	check_parser.push_delta(wire.substr(11))
	var check_completed := check_parser.finish()
	_check(check_completed.success and String(check_completed.decision) == "CHECK_REQUIRED", "A CHECK_REQUIRED accepts one compact control line without fallback")

	var trailing := Parser.new()
	trailing.reset("trailing-check")
	var rejected := trailing.push_delta(JSON.stringify(_proposal(15, 2, "normal")) + "\n不得出现正文")
	_check(not rejected.success and String(rejected.code) == "unexpected_check_body", "A CHECK_REQUIRED rejects non-whitespace body")
	var fenced := Parser.new()
	fenced.reset("fenced")
	var fenced_result := fenced.push_delta("```json\n")
	_check(not fenced_result.success, "A fenced/preamble control fails loud without guessing")


func _test_no_check_progressive(runtime: RefCounted) -> void:
	var case := _new_process(runtime, [20])
	var accepted_before: int = runtime.conversation.get_durable_accepted_entries().size()
	var world_before := JSON.stringify(runtime.world_state)
	case.process.start_action("c01-no-check-stream", "我询问军报上的日期。")
	case.stub.simulate_delta('{"decision":"NO_')
	await _delay()
	_check(not runtime.conversation.is_generating(), "B NO_CHECK exposes nothing before complete validated header")
	case.stub.simulate_delta('CHECK","reason":"军报明确"}\n第一段')
	await _delay()
	var turn: RefCounted = runtime.conversation.latest_turn()
	var timing: Dictionary = case.process.timing_snapshot()
	_check(case.stub.requests.size() == 1 and case.stub.busy, "B NO_CHECK stays one active Provider call while body streams")
	_check(runtime.conversation.is_generating() and String(turn.draft_text) == "第一段", "B first body delta reaches provisional Conversation before completion")
	_check(runtime.conversation.get_durable_accepted_entries().size() == accepted_before and JSON.stringify(runtime.world_state) == world_before, "B body delta performs no durable Conversation/world write")
	_check(timing.has("first_visible_narrative_delta") and not timing.has("provider_completed"), "B timing proves first visible narrative precedes Provider completion")
	case.stub.simulate_delta("，第二段。")
	await _delay()
	case.stub.simulate_completed()
	var final_timing: Dictionary = case.process.timing_snapshot()
	var resolution := _find_no_check(runtime.world_state, "c01-no-check-stream")
	_check(resolution.success and String(resolution.resolution.narrative) == "第一段，第二段。", "B exact streamed body freezes once at completion")
	_check(runtime.conversation.get_durable_accepted_entries().size() == accepted_before + 1, "B finalize durably accepts exactly one Conversation turn")
	_check(_ordered(final_timing, ["first_provider_content_delta", "first_visible_narrative_delta", "provider_completed", "finalize_completed", "turn_ready"]), "B non-secret monotonic timing orders delta -> visible -> complete -> finalize")


func _test_no_check_failure_cancel_retry(runtime: RefCounted) -> void:
	var failed := _new_process(runtime, [20])
	var accepted_before: int = runtime.conversation.get_durable_accepted_entries().size()
	failed.process.start_action("c01-no-check-fail", "我询问营门方向。")
	failed.stub.simulate_delta(_no_check_wire("方向明确", "屏幕可见但不会接受"))
	var turns_after_first: int = runtime.conversation.turns.size()
	failed.stub.simulate_failed("transport")
	_check(runtime.conversation.get_durable_accepted_entries().size() == accepted_before and not _find_no_check(runtime.world_state, "c01-no-check-fail").success, "C mid-stream failure leaves zero durable result/Conversation")
	_check(not JSON.stringify(runtime.conversation.get_context_projection()).contains("屏幕可见但不会接受"), "C failed partial draft is excluded from future Context")
	failed.process.start_action("c01-no-check-fail", "我询问营门方向。")
	failed.stub.simulate_delta(_no_check_wire("方向明确", "军吏重新指出营门。"))
	failed.stub.simulate_completed()
	_check(runtime.conversation.turns.size() == turns_after_first and failed.stub.requests.size() == 2, "C same-process retry reuses provisional Turn without duplicate Player turn")

	var cancelled := _new_process(runtime, [20])
	accepted_before = runtime.conversation.get_durable_accepted_entries().size()
	cancelled.process.start_action("c01-no-check-cancel", "我查看眼前的旗号。")
	cancelled.stub.simulate_delta(_no_check_wire("旗号可见", "这段在取消前可见"))
	var cancel_turns: int = runtime.conversation.turns.size()
	cancelled.process.cancel()
	_check(runtime.conversation.get_durable_accepted_entries().size() == accepted_before and not _find_no_check(runtime.world_state, "c01-no-check-cancel").success, "C cancel leaves no accepted/durable NO_CHECK result")
	cancelled.process.start_action("c01-no-check-cancel", "我查看眼前的旗号。")
	cancelled.stub.simulate_delta(_no_check_wire("旗号可见", "旗号属于本营。"))
	cancelled.stub.simulate_completed()
	_check(runtime.conversation.turns.size() == cancel_turns and cancelled.stub.requests.size() == 2, "C cancelled action retry reuses one Turn and one stable action")


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
	_check(_ordered(timing, ["adjudication_control_completed", "durable_check_completed", "resolution_narrative_request_started"]), "D timing proves durable check before narrative request")
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


func _no_check_wire(reason: String, narrative: String) -> String:
	return JSON.stringify({"decision": "NO_CHECK", "reason": reason}) + "\n" + narrative


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
		print("G4-09UATBC01 PASS | " + label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-09UATBC01 FAIL | " + label)


func _finish() -> void:
	print("G4-09UATBC01 | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
