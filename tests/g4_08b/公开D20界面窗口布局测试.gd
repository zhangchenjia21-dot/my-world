extends SceneTree

## G4-08B 可玩界面窗口布局证据 —— 真实 main.tscn + 桩 Provider + deterministic RNG，
## 三种窗口尺寸（1280x720 / 960x540 / 最大化）下截取：拓展步选择、受检行动 transient 卡、
## 失败重试 banner、Playing（accepted 卡 + 无 Expansion 回归）。

const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")
const OpeningStub := preload("res://tests/g4_07a/首次开场桩适配器.gd")
const ViewStub := preload("res://tests/g2_03_桩适配器.gd")

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
var _shot_dir := ""
var _source_root := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	_shot_dir = _argument("--shot-dir=")
	if _root.find("g4_08b") < 0 or _shot_dir.is_empty():
		_fail("task-owned --root / --shot-dir required")
		return _finish()
	_fixture.reset_directory(_root)
	DirAccess.make_dir_recursive_absolute(_shot_dir)
	_source_root = _root.path_join("source-library")
	var installed: Dictionary = _fixture.install_real_assets(_source_root)
	_check(installed.success, "frozen v0.2 full-fidelity packages installed for layout evidence")
	if not installed.success:
		return _finish()
	var library: RefCounted = installed.library
	var expansion: Dictionary = library.install_expansion_pack("res://tests/fixtures/g4_08m1/判定与检定_公开d20")
	_check(expansion.success, "Public d20 Expansion installed for layout evidence")
	for size_label: String in ["1280x720", "960x540", "maximized"]:
		await _run_size(size_label)
	_clear_environment()
	_finish()


func _run_size(size_label: String) -> void:
	var case_root := _root.path_join("layout-%s" % size_label)
	DirAccess.make_dir_recursive_absolute(case_root)
	root.mode = Window.MODE_WINDOWED
	match size_label:
		"1280x720": root.size = Vector2i(1280, 720)
		"960x540": root.size = Vector2i(960, 540)
		"maximized": root.mode = Window.MODE_MAXIMIZED
	await _settle(6)
	if size_label == "maximized" and DisplayServer.get_name() != "headless":
		_check(root.size.x > 1280, "maximized window is wider than 1280")

	var shell: Variant = _boot_shell(case_root)
	await _settle(3)
	# 拓展步选择截图
	shell.new_game_button.pressed.emit()
	await _settle(4)
	var wizard: Variant = shell.new_game_wizard
	_press_choice(wizard, "world_han_end_unsettled_realm")
	wizard.next_button.pressed.emit()
	await _settle(2)
	_press_choice(wizard, "entry_t0-208-red-cliffs-eve")
	wizard.next_button.pressed.emit()
	await _settle(2)
	_check(_inside_window(wizard.final_create_button.get_global_rect()) or wizard.step == 2, "%s Wizard reachable" % size_label)
	await _shot("%s-expansion-step" % size_label)
	_toggle_choice(wizard, "expansion_exp_check_core_public_d20", true)
	wizard.next_button.pressed.emit()
	await _settle(2)
	_press_choice(wizard, "character_han_end_liu_bei")
	wizard.next_button.pressed.emit()
	await _settle(2)
	wizard.next_button.pressed.emit()
	await _settle(2)
	wizard.display_name_input.text = "布局证据局"
	wizard.display_name_input.text_changed.emit(wizard.display_name_input.text)
	wizard.next_button.pressed.emit()
	await _settle(4)
	_check(wizard.review_text.text.contains("判定与检定：公开 d20"), "%s Review shows selected Expansion" % size_label)
	await _shot("%s-review-with-expansion" % size_label)

	# 建局 + 第一幕
	shell.test_opening_adapter_override = OpeningStub.new()
	shell.test_adjudication_adapter_override = OpeningStub.new()
	shell.test_adjudication_rng_override = DeterministicRng.new([7, 3])
	wizard.final_create_button.pressed.emit()
	await _settle(6)
	var opening_stub: Node = shell.test_opening_adapter_override
	opening_stub.simulate_delta("雨夜的第一幕。")
	opening_stub.simulate_completed()
	await _settle(4)

	# 受检行动 transient 卡
	var adjudication_stub: Node = shell.test_adjudication_adapter_override
	shell.narrative_view.player_input.text = "我独自潜入敌营偷取军令。"
	shell.narrative_view._on_send_pressed()
	await _settle(2)
	adjudication_stub.simulate_delta(JSON.stringify({"decision": "CHECK_REQUIRED", "proposal": {
		"intent": "潜入敌营", "dc": 15, "modifier": 0, "stance": "normal",
		"modifier_reason": "无修正", "situation_reason": "高风险",
		"success_intent": "盗取军令", "failure_stakes": "暴露被捕",
	}}))
	adjudication_stub.simulate_completed()
	await _settle(3)
	_check(_inside_window(shell.narrative_view.action_status_panel.get_global_rect()) or not shell.narrative_view.action_status_panel.visible, "%s action status panel inside viewport" % size_label)
	await _shot("%s-check-transient" % size_label)
	adjudication_stub.simulate_delta("守卫截断了你的退路；失败结果生效。")
	adjudication_stub.simulate_completed()
	await _settle(4)
	_check(_count_mechanic_cards(shell.narrative_view) == 1, "%s accepted card in history" % size_label)
	await _shot("%s-playing-with-card" % size_label)

	# 失败重试 banner
	shell.narrative_view.player_input.text = "我再次尝试潜入。"
	shell.narrative_view._on_send_pressed()
	await _settle(2)
	adjudication_stub.simulate_delta(JSON.stringify({"decision": "CHECK_REQUIRED", "proposal": {
		"intent": "再次潜入", "dc": 20, "modifier": 0, "stance": "disadvantage",
		"modifier_reason": "无修正", "situation_reason": "更高风险",
		"success_intent": "盗取军令", "failure_stakes": "暴露被捕",
	}}))
	adjudication_stub.simulate_completed()
	await _settle(3)
	adjudication_stub.simulate_failed("transport")
	await _settle(4)
	_check(shell.narrative_view.retry_action_button.visible and _inside_window(shell.narrative_view.retry_action_button.get_global_rect()), "%s retry action button reachable" % size_label)
	await _shot("%s-action-failed-retry" % size_label)

	shell._close_game_session()
	await _settle(2)
	shell.queue_free()
	await process_frame


func _boot_shell(case_root: String) -> Variant:
	OS.set_environment("MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", _source_root)
	OS.set_environment("MY_WORLD_TEST_CURRENT_GAME_DB", case_root.path_join("current-game.sqlite"))
	OS.set_environment("MY_WORLD_TEST_GAME_LIBRARY_ROOT", case_root.path_join("game-library"))
	OS.set_environment("MY_WORLD_TEST_GAMES_ROOT", case_root.path_join("games"))
	OS.set_environment("MY_WORLD_TEST_CREATION_ROOT", case_root.path_join("creation"))
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	return shell


func _press_choice(wizard: Variant, name_fragment: String) -> void:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(name_fragment) >= 0:
			button.pressed.emit()
			return
	_fail("choice not found: %s" % name_fragment)


func _toggle_choice(wizard: Variant, name_fragment: String, selected: bool) -> void:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(name_fragment) >= 0 and button is CheckButton:
			(button as CheckButton).button_pressed = selected
			button.toggled.emit(selected)
			return
	_fail("toggle not found: %s" % name_fragment)


func _count_mechanic_cards(view: Variant) -> int:
	var count := 0
	for child: Node in view.entries.get_children():
		if child.has_meta("mechanic_card"):
			count += 1
	return count


func _inside_window(rect: Rect2) -> bool:
	return rect.position.x >= 0 and rect.position.y >= 0 and rect.end.x <= root.size.x + 1 and rect.end.y <= root.size.y + 1


func _shot(name: String) -> void:
	await process_frame
	await process_frame
	var path := _shot_dir.path_join("%s.png" % name)
	root.get_texture().get_image().save_png(path)
	print("G4-08B GUI SHOT | %s" % path)


func _clear_environment() -> void:
	for key: String in ["MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", "MY_WORLD_TEST_CURRENT_GAME_DB", "MY_WORLD_TEST_GAME_LIBRARY_ROOT", "MY_WORLD_TEST_GAMES_ROOT", "MY_WORLD_TEST_CREATION_ROOT"]:
		OS.set_environment(key, "")


func _settle(frames: int) -> void:
	for _index: int in range(frames):
		await process_frame


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-08B GUI PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-08B GUI FAIL | %s" % label)


func _finish() -> void:
	print("G4-08B GUI | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
