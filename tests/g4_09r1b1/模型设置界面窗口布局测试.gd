extends SceneTree

## G4-09R1B1 模型设置界面布局证据 —— 真实 main.tscn + task-owned settings path，
## 三种窗口尺寸（1280x720 / 960x540 / 最大化）下截取：Main Menu 入口、设置面板、
## K2.7 固定思考态、保存后回 Main Menu。

const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

var _failures := 0
var _fixture := Fixture.new()
var _root := ""
var _shot_dir := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	_shot_dir = _argument("--shot-dir=")
	if _root.find("g4_09r1b1") < 0 or _shot_dir.is_empty():
		_fail("task-owned --root / --shot-dir required")
		return _finish()
	_fixture.reset_directory(_root)
	DirAccess.make_dir_recursive_absolute(_shot_dir)
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
	OS.set_environment("MY_WORLD_TEST_SETTINGS_PATH", case_root.path_join("settings/provider-runtime.json"))
	var source_root := case_root.path_join("source-library")
	_fixture.install_real_assets(source_root)
	_set_environment(case_root, source_root)
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await _settle(4)
	_check(shell.model_settings_button.visible and _inside_window(shell.model_settings_button.get_global_rect()), "%s Main Menu 模型设置 inside viewport" % size_label)
	await _shot("%s-menu" % size_label)

	shell.model_settings_button.pressed.emit()
	await _settle(3)
	_check(shell.model_settings_overlay.visible and _inside_window(shell.model_option.get_global_rect()) and _inside_window(shell.settings_save_button.get_global_rect()), "%s settings panel inside viewport" % size_label)
	await _shot("%s-settings" % size_label)

	# K2.7 固定思考态
	_select_option(shell.model_option, "Kimi K2.7")
	await _settle(2)
	_check(shell.reasoning_option.disabled and shell.model_settings_note.visible, "%s K2.7 fixed-thinking state visible" % size_label)
	await _shot("%s-settings-k27" % size_label)

	# 保存回 Main Menu
	_select_option(shell.model_option, "DeepSeek V4 Pro")
	shell.settings_save_button.pressed.emit()
	await _settle(3)
	_check(shell.main_menu_surface.visible and not shell.model_settings_overlay.visible, "%s save returns to Main Menu" % size_label)
	await _shot("%s-saved" % size_label)

	shell._close_game_session()
	await _settle(2)
	shell.queue_free()
	await process_frame


func _set_environment(case_root: String, source_root: String) -> void:
	OS.set_environment("MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", source_root)
	OS.set_environment("MY_WORLD_TEST_CURRENT_GAME_DB", case_root.path_join("current-game.sqlite"))
	OS.set_environment("MY_WORLD_TEST_GAME_LIBRARY_ROOT", case_root.path_join("game-library"))
	OS.set_environment("MY_WORLD_TEST_GAMES_ROOT", case_root.path_join("games"))
	OS.set_environment("MY_WORLD_TEST_CREATION_ROOT", case_root.path_join("creation"))


func _clear_environment() -> void:
	for key: String in ["MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", "MY_WORLD_TEST_CURRENT_GAME_DB", "MY_WORLD_TEST_GAME_LIBRARY_ROOT", "MY_WORLD_TEST_GAMES_ROOT", "MY_WORLD_TEST_CREATION_ROOT", "MY_WORLD_TEST_SETTINGS_PATH"]:
		OS.set_environment(key, "")


func _select_option(option: OptionButton, text: String) -> void:
	for index: int in option.item_count:
		if option.get_item_text(index) == text:
			option.selected = index
			option.item_selected.emit(index)
			return
	_fail("option not found: %s" % text)


func _inside_window(rect: Rect2) -> bool:
	return rect.position.x >= 0 and rect.position.y >= 0 and rect.end.x <= root.size.x + 1 and rect.end.y <= root.size.y + 1


func _shot(name: String) -> void:
	await process_frame
	await process_frame
	var path := _shot_dir.path_join("%s.png" % name)
	root.get_texture().get_image().save_png(path)
	print("G4-09R1B1 GUI SHOT | %s" % path)


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
		print("G4-09R1B1 GUI PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-09R1B1 GUI FAIL | %s" % label)


func _finish() -> void:
	print("G4-09R1B1 GUI | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
