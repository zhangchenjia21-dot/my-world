extends SceneTree

## MW-005 R2 —— Public d20 control lane 文风排除 focused 测试。
## 捕获真实 request_assembled(stage, messages)，证明 consumer matrix：
##   control / control_recovery        → 完全排除 literary_style_reference
##   no_check / resolution / degraded narrative → Primer 恰好一次、位于非事实边界下
## 同时证明 d20 decision / RNG / no-reroll / accepted 语义不变。
## Provider 全部走桩；real Provider calls = 0。

const SourceLibrary := preload("res://src/source/L3_外交层/Source库公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const GameRuntime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Adjudication := preload("res://src/行动判定/L3_外交层/行动判定公开接口.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")
const StubAdapter := preload("res://tests/g4_07a/首次开场桩适配器.gd")

const WORLD_PKG := "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定"
const PLAYER_PKG := "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/刘备"
const EXPANSION_PKG := "res://tests/fixtures/g4_08m1/判定与检定_公开d20"
const PRIMER_MARKER := "听弦歌也略知雅意"
const STYLE_TYPE := "literary_style_reference"
const BOUNDARY := "## Literary Style Reference"
const NEW_FINGERPRINT := "58966f73dfade50b0aa7536aad38a8840e614016975e8beba0735f7dd14ab443"


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


func _initialize() -> void:
	call_deferred("_run")


func _on_request_assembled(stage: Variant, messages: Variant) -> void:
	_assembled.append({"stage": String(stage), "text": JSON.stringify(messages)})


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("mw005") < 0:
		_fail("必须提供 task-owned --root，且路径包含 mw005")
		return _finish()
	_fixture.reset_directory(_root)

	var case_root := _root.path_join("d20-control")
	var library := SourceLibrary.new(case_root.path_join("source-library"))
	var installed := _fixture.install_packages(case_root.path_join("source-library"), [
		{"type": "world", "path": WORLD_PKG},
		{"type": "character", "path": PLAYER_PKG},
	])
	_check(installed.success, "task-owned library installs Primer World + Player")
	if not installed.success:
		return _finish()
	library = installed.library
	var expansion: Dictionary = library.install_expansion_pack(EXPANSION_PKG)
	_check(expansion.success, "Public d20 Expansion installed")
	if not expansion.success:
		return _finish()
	var world_generation := _fixture.find_generation(installed.installed, "world.han_end.unsettled_realm")
	_check(String(world_generation.identity.generation_fingerprint) == NEW_FINGERPRINT,
		"Source generation unchanged: still the Revision-1 Primer generation (no republish)")

	var creation := Creation.new(library)
	creation.select_world(world_generation)
	creation.select_entry("t0-208-red-cliffs-eve")
	creation.set_expansion(expansion.generation, true)
	creation.select_player(_fixture.find_generation(installed.installed, "character.han_end.liu_bei"))
	creation.set_settings("MW005R2控制排除", "Light", "")
	var created: Dictionary = FinalCreate.new(library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games")).create_or_resume("mw005r2-d20", creation.composition_snapshot())
	_check(created.success, "frozen Primer Game with Public d20 created")
	if not created.success:
		return _finish()

	var runtime := GameRuntime.new()
	var opened: Dictionary = runtime.open_existing_game(String(created.database_path))
	_check(opened.success, "Game existing-only opens")
	if not opened.success:
		return _finish()

	_test_control_recovery_lane(runtime)
	_test_resolution_lane(runtime)
	_test_degraded_lane(runtime)
	_check(runtime.conversation.get_durable_accepted_entries().size() == 3, "three actions accepted exactly once each (no reroll / no duplicate)")
	runtime.close()
	_finish()


## control(垃圾输出) → control_recovery(NO_CHECK) → no_check_narrative。
func _test_control_recovery_lane(runtime: RefCounted) -> void:
	_assembled.clear()
	var stub := StubAdapter.new()
	var process: Node = Adjudication.new(runtime, stub, DeterministicRng.new([20]))
	process.request_assembled.connect(_on_request_assembled)
	root.add_child(process)
	var started: Dictionary = process.start_action("mw005r2-recovery", "我独自潜入敌营偷取军令。")
	_check(started.success and _stages() == ["control"], "control request assembled first")

	stub.simulate_delta("无法解析的闲谈，不是 JSON。")
	stub.simulate_completed()
	_check(_stages() == ["control", "control_recovery"], "unparseable control triggers exactly one control_recovery")

	stub.simulate_delta(JSON.stringify({"decision": "NO_CHECK", "reason": "已探明且无风险"}))
	stub.simulate_completed()
	_check(_stages() == ["control", "control_recovery", "no_check_narrative"], "successful recovery leads to no_check_narrative")
	stub.simulate_delta("营中巡夜松散，你径直而入。")
	stub.simulate_completed()

	_assert_control_excludes("control")
	_assert_control_excludes("control_recovery")
	_assert_narrative_includes("no_check_narrative")
	process.queue_free()


## control(CHECK_REQUIRED) → Program RNG 一次 → resolution_narrative。
func _test_resolution_lane(runtime: RefCounted) -> void:
	_assembled.clear()
	var stub := StubAdapter.new()
	var rng := DeterministicRng.new([17])
	var process: Node = Adjudication.new(runtime, stub, rng)
	process.request_assembled.connect(_on_request_assembled)
	root.add_child(process)
	process.start_action("mw005r2-check", "我当众弹劾督邮。")
	stub.simulate_delta(JSON.stringify({"decision": "CHECK_REQUIRED", "proposal": {
		"intent": "当众弹劾", "dc": 15, "modifier": 0, "stance": "normal",
		"modifier_reason": "无加成", "situation_reason": "有证人风险",
		"success_intent": "弹劾生效", "failure_stakes": "招致报复",
	}}))
	stub.simulate_completed()
	_check(rng.invocation_count == 1 and _stages() == ["control", "resolution_narrative"],
		"CHECK_REQUIRED rolls Program RNG exactly once before resolution_narrative")
	stub.simulate_delta("督邮面色铁青，堂上一时无声。")
	stub.simulate_completed()

	_assert_control_excludes("control")
	_assert_narrative_includes("resolution_narrative")
	process.queue_free()


## control(垃圾) → control_recovery(垃圾) → degraded_narrative（唯一修复机会耗尽后降级）。
func _test_degraded_lane(runtime: RefCounted) -> void:
	_assembled.clear()
	var stub := StubAdapter.new()
	var rng := DeterministicRng.new([20])
	var process: Node = Adjudication.new(runtime, stub, rng)
	process.request_assembled.connect(_on_request_assembled)
	root.add_child(process)
	process.start_action("mw005r2-degraded", "我查看渡口告示。")
	stub.simulate_delta("第一段无法解析。")
	stub.simulate_completed()
	stub.simulate_delta("第二段仍然无法解析。")
	stub.simulate_completed()
	_check(_stages() == ["control", "control_recovery", "degraded_narrative"] and rng.invocation_count == 0,
		"recovery exhausted degrades without any RNG roll")
	stub.simulate_delta("告示字迹斑驳，内容如常。")
	stub.simulate_completed()

	_assert_control_excludes("control")
	_assert_control_excludes("control_recovery")
	_assert_narrative_includes("degraded_narrative")
	process.queue_free()


func _assert_control_excludes(stage: String) -> void:
	var text := _stage_text(stage)
	_check(not text.is_empty(), "%s request captured via request_assembled" % stage)
	_check(not text.contains(PRIMER_MARKER), "%s contains no Primer content" % stage)
	_check(not text.contains(STYLE_TYPE), "%s contains no literary_style_reference token" % stage)
	_check(not text.contains(BOUNDARY), "%s contains no literary boundary header" % stage)
	_check(text.contains("world-identity-ownership"), "%s still carries factual World context" % stage)
	_check(text.contains("刘备"), "%s still carries Player Character factual context" % stage)


func _assert_narrative_includes(stage: String) -> void:
	var text := _stage_text(stage)
	_check(not text.is_empty(), "%s request captured via request_assembled" % stage)
	_check(text.count(PRIMER_MARKER) == 1, "%s includes the Primer exactly once" % stage)
	var boundary := text.find(BOUNDARY)
	_check(boundary >= 0 and text.find(PRIMER_MARKER) > boundary, "%s Primer sits under the non-factual literary boundary" % stage)


func _stages() -> Array:
	var stages: Array = []
	for item: Dictionary in _assembled:
		stages.append(item.stage)
	return stages


func _stage_text(stage: String) -> String:
	for item: Dictionary in _assembled:
		if item.stage == stage:
			return item.text
	return ""


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("MW-005 R2 CONTROL PASS | %s" % label)
	else:
		_failures += 1
		push_error("MW-005 R2 CONTROL FAIL | %s" % label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("MW-005 R2 CONTROL FAIL | %s" % label)


func _finish() -> void:
	print("MW-005 R2 CONTROL | done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)
