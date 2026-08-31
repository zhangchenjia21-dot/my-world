extends SceneTree

const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

var _failures := 0
var _fixture := Fixture.new()
var _shot_dir := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var root_path := _argument("--root=")
	_shot_dir = _argument("--shot-dir=")
	if root_path.find("g4_05") < 0 or _shot_dir.find("g4_05") < 0:
		_fail("task-owned root/shot-dir required")
		return _finish()
	_fixture.reset_directory(root_path)
	DirAccess.make_dir_recursive_absolute(_shot_dir)
	var installed: Dictionary = _fixture.install_real_assets(root_path.path_join("source-library"))
	_check(installed.success, "real assets installed for GUI")
	OS.set_environment("MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", root_path.path_join("source-library"))
	OS.set_environment("MY_WORLD_TEST_CURRENT_GAME_DB", root_path.path_join("current-game.sqlite"))
	OS.set_environment("MY_WORLD_TEST_GAME_LIBRARY_ROOT", root_path.path_join("game-library"))
	OS.set_environment("MY_WORLD_TEST_GAMES_ROOT", root_path.path_join("games"))
	root.mode = Window.MODE_WINDOWED
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await _settle(8)

	root.size = Vector2i(1280, 720)
	await _settle(10)
	await _run_wizard_at_size(shell, "1280x720")

	root.mode = Window.MODE_MAXIMIZED
	await _settle(15)
	_check(root.size.x >= 1280 and root.size.y >= 720, "maximized Windows viewport available")
	await _run_wizard_at_size(shell, "maximized")

	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(960, 540)
	await _settle(10)
	await _run_wizard_at_size(shell, "960x540")

	root.size = Vector2i(1280, 720)
	await _settle(10)
	await _run_incompatible_review_at_size(shell, "1280x720")

	_check(not FileAccess.file_exists(root_path.path_join("current-game.sqlite")) and not DirAccess.dir_exists_absolute(root_path.path_join("game-library")), "GUI runs create no Game DB/Game Library")
	shell.queue_free()
	for key: String in ["MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", "MY_WORLD_TEST_CURRENT_GAME_DB", "MY_WORLD_TEST_GAME_LIBRARY_ROOT", "MY_WORLD_TEST_GAMES_ROOT"]:
		OS.set_environment(key, "")
	await process_frame
	_finish()


func _run_wizard_at_size(shell: Variant, label: String) -> void:
	shell.new_game_button.pressed.emit()
	await _settle(5)
	var wizard: Variant = shell.new_game_wizard
	_check(_inside_window(wizard.get_node("Panel").get_global_rect()), "%s Wizard panel is contained" % label)
	_check(wizard.cancel_button.size.y >= 44 and wizard.next_button.size.y >= 44, "%s navigation controls meet usable height" % label)
	_check(wizard.step == 0 and wizard.next_button.disabled, "%s World requires explicit click" % label)
	await _shot("world_%s" % _safe_label(label))
	_press(wizard, "world_han_end_unsettled_realm")
	await _next(wizard)
	_check(wizard.step == 1 and wizard.choice_buttons.size() >= 2, "%s Entry choices reachable" % label)
	_press(wizard, "entry_none")
	await _next(wizard)
	_check(wizard.step == 2 and wizard.next_button.disabled, "%s Expansion none step reachable" % label)
	_press(wizard, "expansion_none")
	await _next(wizard)
	_check(wizard.step == 3 and wizard.choice_buttons.size() == 6, "%s Player Character list reachable" % label)
	_check(_choice_text(wizard, "character_han_end_liu_bei").length() > 40, "%s Player choice shows readable summary text" % label)
	await _shot("player_%s" % _safe_label(label))
	_press(wizard, "character_han_end_liu_bei")
	await _next(wizard)
	_check(wizard.step == 4 and wizard.choice_buttons.size() == 6, "%s multi-select NPC list reachable" % label)
	_toggle(wizard, "character_han_end_cao_cao")
	await _next(wizard)
	_check(wizard.step == 5 and wizard.display_name_input.visible and wizard.supplement_input.visible, "%s settings fields reachable" % label)
	wizard.display_name_input.text = "窗口现实 · %s" % label
	wizard.display_name_input.text_changed.emit(wizard.display_name_input.text)
	wizard.supplement_input.text = "验证长文本输入与可滚动布局。"
	await _next(wizard)
	_check(wizard.step == 6 and wizard.review_text.visible and not wizard.final_create_button.disabled, "%s Review reachable and Final Create enabled" % label)
	_check(_inside_window(wizard.cancel_button.get_global_rect()) and _inside_window(wizard.final_create_button.get_global_rect()), "%s Review navigation remains inside viewport" % label)
	await _shot("review_%s" % _safe_label(label))
	wizard.cancel_button.pressed.emit()
	await _settle(4)
	_check(shell.main_menu_surface.visible and shell.session_runtime == null, "%s Cancel returns clean Main Menu" % label)


## 真实不兼容路线（229 + 刘备）的 Review 失败可读性证据：失败文本须在视口内完整可读，
## 且返回/主导航仍然可达。
func _run_incompatible_review_at_size(shell: Variant, label: String) -> void:
	shell.new_game_button.pressed.emit()
	await _settle(5)
	var wizard: Variant = shell.new_game_wizard
	_press(wizard, "world_han_end_unsettled_realm")
	await _next(wizard)
	_press(wizard, "entry_t0-229-three-states")
	await _next(wizard)
	_press(wizard, "expansion_none")
	await _next(wizard)
	_press(wizard, "character_han_end_liu_bei")
	await _next(wizard)
	await _next(wizard)
	wizard.display_name_input.text = "布局验证 · 不兼容 %s" % label
	wizard.display_name_input.text_changed.emit(wizard.display_name_input.text)
	await _next(wizard)
	_check(wizard.step == 6 and wizard.review_text.text.find("无法继续创建") >= 0, "%s incompatible Review shows plain failure message" % label)
	_check(wizard.review_text.text.find("T0") < 0 and wizard.review_text.text.find("coverage") < 0, "%s incompatible Review hides backend jargon" % label)
	_check(_inside_window(wizard.back_button.get_global_rect()) and _inside_window(wizard.cancel_button.get_global_rect()), "%s failed Review keeps back/cancel navigation inside viewport" % label)
	_check(wizard.final_create_button.disabled, "%s Final Create disabled on failed Review" % label)
	await _shot("review_error_%s" % _safe_label(label))
	wizard.cancel_button.pressed.emit()
	await _settle(4)
	_check(shell.main_menu_surface.visible and shell.session_runtime == null, "%s incompatible route cancel returns clean Main Menu" % label)


func _choice_text(wizard: Variant, fragment: String) -> String:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(fragment) >= 0:
			return button.text
	_fail("choice not found: %s" % fragment)
	return ""


func _next(wizard: Variant) -> void:
	wizard.next_button.pressed.emit()
	await _settle(3)


func _press(wizard: Variant, fragment: String) -> void:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(fragment) >= 0:
			button.pressed.emit()
			return
	_fail("button not found: %s" % fragment)


func _toggle(wizard: Variant, fragment: String) -> void:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(fragment) >= 0:
			button.button_pressed = true
			button.toggled.emit(true)
			return
	_fail("toggle not found: %s" % fragment)


func _inside_window(rect: Rect2) -> bool:
	return rect.position.x >= 0 and rect.position.y >= 0 and rect.end.x <= root.size.x and rect.end.y <= root.size.y


func _shot(name: String) -> void:
	await process_frame
	var path := _shot_dir.path_join("%s.png" % name)
	root.get_texture().get_image().save_png(path)
	print("G4-05 GUI SHOT | %s" % path)


func _safe_label(value: String) -> String:
	return value.replace("×", "x").replace(":", "_")


func _settle(frames: int) -> void:
	for _index: int in range(frames): await process_frame


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix): return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition: print("G4-05 GUI PASS | %s" % label)
	else: _fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-05 GUI FAIL | %s" % label)


func _finish() -> void:
	print("G4-05 GUI | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
