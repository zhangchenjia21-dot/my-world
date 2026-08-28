extends SceneTree

## G4-01 真实窗口布局证据：Main Menu / New Game / Game Surface 在三档窗口均可用。

var _failures := 0
var _shot_dir := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var database_path := _argument("--db=")
	if database_path.find("g4_01") < 0:
		_fail("task-owned --db path containing g4_01 is required")
		_finish()
		return
	_shot_dir = _argument("--shot-dir=")
	if _shot_dir.find("g4_01") < 0:
		_fail("task-owned --shot-dir path containing g4_01 is required")
		_finish()
		return
	DirAccess.make_dir_recursive_absolute(_shot_dir)
	OS.set_environment("MY_WORLD_TEST_CURRENT_GAME_DB", database_path)
	root.mode = Window.MODE_WINDOWED
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)

	root.size = Vector2i(1280, 720)
	await _settle()
	_check_menu_layout(shell, "1280x720")
	await _shot("main_menu_1280")

	root.mode = Window.MODE_MAXIMIZED
	await _settle(15)
	_check(root.size.x > 1280, "Maximized window is wider than 1280")
	_check_menu_layout(shell, "Maximized")
	await _shot("main_menu_maximized")

	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(960, 540)
	await _settle()
	_check_menu_layout(shell, "960x540")
	await _shot("main_menu_960")

	shell.new_game_button.pressed.emit()
	await _settle(4)
	var new_panel: Control = shell.get_node("NewGameSurface/NewGamePanel")
	_check(shell.new_game_surface.visible and _inside_window(new_panel.get_global_rect()), "960x540 New Game host is visible and contained")
	_check(shell.new_game_back_button.visible and not shell.new_game_back_button.disabled, "New Game Back is usable")
	await _shot("new_game_960")
	shell.new_game_back_button.pressed.emit()
	await _settle(3)

	# Continue 使用 task-owned Game；960 窄布局仍保留 Narrative 与清晰应用导航。
	shell.continue_button.pressed.emit()
	await _settle(8)
	_check(shell.game_surface.visible and shell.session_state == shell.SessionState.READY, "Continue reaches Game Surface at 960x540")
	_check(shell.narrative_view.visible and shell.return_menu_button.visible, "Narrative and Return to Main Menu remain visible")
	_check(shell.player_toggle.visible and shell.world_toggle.visible, "960x540 keeps side hosts behind explicit toggles")
	await _shot("game_surface_960")
	shell.return_menu_button.pressed.emit()
	await _settle(4)
	_check(shell.main_menu_surface.visible and shell.session_state == shell.SessionState.ABSENT, "Return restores Main Menu without exiting Application")

	shell.queue_free()
	OS.set_environment("MY_WORLD_TEST_CURRENT_GAME_DB", "")
	await process_frame
	_finish()


func _check_menu_layout(shell: Variant, label: String) -> void:
	var panel: Control = shell.get_node("MainMenuSurface/MainMenuPanel")
	_check(shell.main_menu_surface.visible, "%s Main Menu visible" % label)
	_check(_inside_window(panel.get_global_rect()), "%s menu panel fully inside window" % label)
	for button: Button in [shell.continue_button, shell.new_game_button, shell.quit_button]:
		_check(button.visible and button.size.y >= 48.0, "%s %s is visible with usable height" % [label, button.text])


func _inside_window(rect: Rect2) -> bool:
	return rect.position.x >= 0.0 and rect.position.y >= 0.0 and rect.end.x <= root.size.x and rect.end.y <= root.size.y


func _settle(frames: int = 10) -> void:
	for _index: int in range(frames):
		await process_frame


func _shot(name: String) -> void:
	await process_frame
	var path := "%s/%s.png" % [_shot_dir, name]
	root.get_texture().get_image().save_png(path)
	print("G4-01 UI SHOT | %s" % path)


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix)
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-01 UI PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-01 UI FAIL | %s" % label)


func _finish() -> void:
	print("G4-01 UI | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
