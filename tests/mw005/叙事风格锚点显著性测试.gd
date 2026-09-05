extends SceneTree

## MW-005 R3 —— Narrative Style Salience / Late Style Anchor focused 测试。
## 捕获真实最终 request messages（request_assembled / Opening.last_request_messages /
## assemble_continuation_messages），证明 consumer matrix 与 late-anchor 排布：
##   first opening / ordinary continuation / resolution / no_check / degraded narrative
##     → Primer 恰好一次 + 正向 cue，且 anchor 位于事实与 mechanics 材料之后；
##   control / control_recovery → 无 Primer、无 boundary、无 style token、无 cue；
##   G5-04 project_world_only / G5-01 semantic → 无任何 style 材料。
## Provider 全部走桩；real Provider calls = 0。

const SourceLibrary := preload("res://src/source/L3_外交层/Source库公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const GameRuntime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Adjudication := preload("res://src/行动判定/L3_外交层/行动判定公开接口.gd")
const WorldTurn := preload("res://src/世界回合/L3_外交层/世界回合公开接口.gd")
const Opening := preload("res://src/首次开场/L3_外交层/首次开场公开接口.gd")
const Projector := preload("res://src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")
const D20Stub := preload("res://tests/g4_07a/首次开场桩适配器.gd")
const SemanticStub := preload("res://tests/g5_01/世界回合语义桩适配器.gd")

const WORLD_PKG := "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定"
const PLAYER_PKG := "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/刘备"
const EXPANSION_PKG := "res://tests/fixtures/g4_08m1/判定与检定_公开d20"
const PRIMER_MARKER := "听弦歌也略知雅意"
const STYLE_TYPE := "literary_style_reference"
const BOUNDARY := "## Literary Style Reference"
const STYLE_CUE := "表达锚点"
const FINGERPRINT := "58966f73dfade50b0aa7536aad38a8840e614016975e8beba0735f7dd14ab443"

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
var _fixture := Fixture.new()
var _root := ""
var _assembled: Array = []
var _semantic_requests: Array = []


func _initialize() -> void:
	call_deferred("_run")


func _on_request_assembled(stage: Variant, messages: Variant) -> void:
	_assembled.append({"stage": String(stage), "messages": (messages as Array).duplicate(true)})


func _on_semantic_request(_turn_index: Variant, messages: Variant) -> void:
	_semantic_requests.append((messages as Array).duplicate(true))


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("mw005") < 0:
		_fail("必须提供 task-owned --root，且路径包含 mw005")
		return _finish()
	_fixture.reset_directory(_root)

	var case_root := _root.path_join("r3-salience")
	var installed: Dictionary = _fixture.install_packages(case_root.path_join("source-library"), [
		{"type": "world", "path": WORLD_PKG},
		{"type": "character", "path": PLAYER_PKG},
	])
	_check(installed.success, "task-owned library installs Primer World + Player")
	if not installed.success:
		return _finish()
	var library: RefCounted = installed.library
	var expansion: Dictionary = library.install_expansion_pack(EXPANSION_PKG)
	_check(expansion.success, "Public d20 Expansion installed")
	if not expansion.success:
		return _finish()
	var world_generation := _fixture.find_generation(installed.installed, "world.han_end.unsettled_realm")
	_check(String(world_generation.identity.generation_fingerprint) == FINGERPRINT,
		"Source generation unchanged: still the approved Primer generation (no republish)")

	var creation := Creation.new(library)
	creation.select_world(world_generation)
	creation.select_entry("t0-208-red-cliffs-eve")
	creation.set_expansion(expansion.generation, true)
	creation.select_player(_fixture.find_generation(installed.installed, "character.han_end.liu_bei"))
	creation.set_settings("MW005R3锚点", "Light", "")
	var created: Dictionary = FinalCreate.new(library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games")).create_or_resume("mw005r3-salience", creation.composition_snapshot())
	_check(created.success, "frozen Primer Game with Public d20 created")
	if not created.success:
		return _finish()
	var runtime := GameRuntime.new()
	var opened: Dictionary = runtime.open_existing_game(String(created.database_path))
	_check(opened.success, "Game existing-only opens")
	if not opened.success:
		return _finish()

	await _test_opening_and_continuation(runtime)
	_test_d20_lanes(runtime)
	_test_style_free_consumers(runtime)
	_check(runtime.conversation.get_durable_accepted_entries().size() == 4, "ordinary + three d20 turns accepted exactly once each (no reroll / no duplicate)")
	runtime.close()
	_finish()


func _test_opening_and_continuation(runtime: RefCounted) -> void:
	var opening := Opening.new(runtime, D20Stub.new())
	root.add_child(opening)
	await process_frame
	var started: Dictionary = opening.start_first_opening()
	_check(started.success, "first opening starts")
	_assert_narrative_anchor("first_opening", opening.last_request_messages, {"after_markers": ["world-identity-ownership", "## Player Character"]})
	opening.cancel()
	opening.queue_free()

	# 一条普通 accepted 回合 + materialized World Turn record，然后捕获 continuation 请求。
	var semantic_stub := SemanticStub.new()
	var worker := WorldTurn.new(runtime, semantic_stub)
	worker.analysis_requested.connect(_on_semantic_request)
	root.add_child(worker)
	await process_frame
	runtime.conversation.begin_turn("我巡视粮秣仓廪。")
	runtime.conversation.append_delta("仓吏禀报：今岁粮秣尚可支三月，然豪户囤积，市价日涨。")
	runtime.complete_active_generation_durably()
	await process_frame
	await process_frame
	_check(_semantic_requests.size() == 1, "ordinary turn wakes exactly one semantic analysis")
	var semantic_text := JSON.stringify(_semantic_requests[0])
	_check(not semantic_text.contains(BOUNDARY) and not semantic_text.contains(PRIMER_MARKER) and not semantic_text.contains(STYLE_CUE),
		"G5-01 semantic request excludes all style material/cue (not mechanics or causal authority)")
	semantic_stub.simulate_delta(JSON.stringify({"changes": ["豪户囤粮推高市价，县吏已呈报郡府。"]}))
	semantic_stub.simulate_completed()
	await process_frame
	_check(worker.last_result.status == "committed", "materialized World Turn commits")
	worker.shutdown()
	worker.queue_free()

	var continuation: Dictionary = _continuation(runtime)
	_check(continuation.success, "continuation request assembled")
	_assert_narrative_anchor("ordinary_continuation", continuation.get("messages", []), {"after_markers": ["world-identity-ownership", "## Player Character", "## Materialized World Changes"]})


func _test_d20_lanes(runtime: RefCounted) -> void:
	# control(垃圾) → control_recovery(CHECK_REQUIRED) → resolution_narrative
	_assembled.clear()
	var stub := D20Stub.new()
	var process: Node = Adjudication.new(runtime, stub, DeterministicRng.new([17]))
	process.request_assembled.connect(_on_request_assembled)
	root.add_child(process)
	process.start_action("mw005r3-check", "我当众弹劾督邮。")
	stub.simulate_delta("无法解析的闲谈，不是 JSON。")
	stub.simulate_completed()
	stub.simulate_delta(JSON.stringify({"decision": "CHECK_REQUIRED", "proposal": {
		"intent": "当众弹劾", "dc": 15, "modifier": 0, "stance": "normal",
		"modifier_reason": "无加成", "situation_reason": "有证人风险",
		"success_intent": "弹劾生效", "failure_stakes": "招致报复",
	}}))
	stub.simulate_completed()
	stub.simulate_delta("督邮面色铁青，堂上一时无声。")
	stub.simulate_completed()
	_assert_control_excludes("control")
	_assert_control_excludes("control_recovery")
	_assert_narrative_anchor("resolution_narrative", _stage_messages("resolution_narrative"), {"after_markers": ["Materialized Expansion rules", "Program 已决定本次结果"]})
	process.queue_free()

	# control(NO_CHECK) → no_check_narrative
	_assembled.clear()
	var stub2 := D20Stub.new()
	var process2: Node = Adjudication.new(runtime, stub2, DeterministicRng.new([20]))
	process2.request_assembled.connect(_on_request_assembled)
	root.add_child(process2)
	process2.start_action("mw005r3-nocheck", "我向身边侍从询问今日日期。")
	stub2.simulate_delta(JSON.stringify({"decision": "NO_CHECK", "reason": "已知且无风险"}))
	stub2.simulate_completed()
	stub2.simulate_delta("侍从立即答出今日日期。")
	stub2.simulate_completed()
	_assert_control_excludes("control")
	_assert_narrative_anchor("no_check_narrative", _stage_messages("no_check_narrative"), {"after_markers": ["world-identity-ownership"]})
	process2.queue_free()

	# control(垃圾) → control_recovery(垃圾) → degraded_narrative
	_assembled.clear()
	var stub3 := D20Stub.new()
	var process3: Node = Adjudication.new(runtime, stub3, DeterministicRng.new([20]))
	process3.request_assembled.connect(_on_request_assembled)
	root.add_child(process3)
	process3.start_action("mw005r3-degraded", "我查看渡口告示。")
	stub3.simulate_delta("第一段无法解析。")
	stub3.simulate_completed()
	stub3.simulate_delta("第二段仍然无法解析。")
	stub3.simulate_completed()
	stub3.simulate_delta("告示字迹斑驳，内容如常。")
	stub3.simulate_completed()
	_assert_control_excludes("control")
	_assert_control_excludes("control_recovery")
	_assert_narrative_anchor("degraded_narrative", _stage_messages("degraded_narrative"), {"after_markers": ["world-identity-ownership"]})
	process3.queue_free()


func _test_style_free_consumers(runtime: RefCounted) -> void:
	var projector := Projector.new()
	var world_only: Dictionary = projector.project_world_only(runtime.world_state)
	_check(world_only.success and not String(world_only.context_text).contains(BOUNDARY)
		and not String(world_only.context_text).contains(PRIMER_MARKER)
		and not String(world_only.context_text).contains(STYLE_CUE)
		and String(world_only.get("style_reference_text", "")).is_empty(),
		"G5-04 project_world_only() excludes all style material and carries no anchor")


func _continuation(runtime: RefCounted) -> Dictionary:
	var opening := Opening.new(runtime, D20Stub.new())
	root.add_child(opening)
	var result: Dictionary = opening.assemble_continuation_messages()
	opening.queue_free()
	return result


## narrative stage 的最终 system content 断言：Primer 恰好一次、cue 恰好一次、
## anchor 晚于全部 after_markers 材料，且 anchor 之后没有事实/mechanics 材料。
func _assert_narrative_anchor(stage: String, messages: Array, markers: Dictionary) -> void:
	_check(not messages.is_empty(), "%s request captured" % stage)
	if messages.is_empty():
		return
	var system := String((messages[0] as Dictionary).get("content", ""))
	_check(system.count(PRIMER_MARKER) == 1, "%s includes the Primer exactly once" % stage)
	_check(system.count(STYLE_CUE) == 1, "%s includes the positive style cue exactly once" % stage)
	var cue_at := system.find(STYLE_CUE)
	var boundary_at := system.find(BOUNDARY)
	_check(boundary_at >= 0 and boundary_at < cue_at and system.find(PRIMER_MARKER) > boundary_at,
		"%s anchor keeps boundary before Primer before cue" % stage)
	var latest_after := -1
	for marker_value: Variant in markers.after_markers:
		var marker := String(marker_value)
		var at := system.find(marker)
		_check(at >= 0, "%s still carries factual/mechanics material %s" % [stage, marker])
		latest_after = maxi(latest_after, at)
	_check(cue_at > latest_after, "%s style anchor is late: after all factual/mechanics material" % stage)
	var tail := system.substr(cue_at)
	_check(not tail.contains("## Player Character") and not tail.contains("## Materialized World Changes") and not tail.contains("Materialized Expansion rules") and not tail.contains("Program 已决定本次结果"),
		"%s no factual/mechanics material appears after the anchor" % stage)


func _assert_control_excludes(stage: String) -> void:
	var messages := _stage_messages(stage)
	_check(not messages.is_empty(), "%s request captured via request_assembled" % stage)
	if messages.is_empty():
		return
	var system := String((messages[0] as Dictionary).get("content", ""))
	_check(system.count(PRIMER_MARKER) == 0, "%s contains no Primer content" % stage)
	_check(not system.contains(STYLE_TYPE), "%s contains no literary_style_reference token" % stage)
	_check(not system.contains(BOUNDARY), "%s contains no literary boundary header" % stage)
	_check(system.count(STYLE_CUE) == 0, "%s contains no positive style cue" % stage)
	_check(system.contains("world-identity-ownership") and system.contains("刘备"), "%s still carries factual World/Player material" % stage)


func _stage_messages(stage: String) -> Array:
	for item: Dictionary in _assembled:
		if item.stage == stage:
			return item.messages
	return []


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("MW-005 R3 PASS | %s" % label)
	else:
		_failures += 1
		push_error("MW-005 R3 FAIL | %s" % label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("MW-005 R3 FAIL | %s" % label)


func _finish() -> void:
	print("MW-005 R3 | done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)
