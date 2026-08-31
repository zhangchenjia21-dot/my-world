extends SceneTree

## G4-07B 可玩界面窗口布局证据 —— 真实 main.tscn + stub Provider，三种窗口尺寸
## （1280x720 / 960x540 / 最大化）下截取：Review（Final Create 可用）、第一幕 streaming
## banner、第一幕失败 banner（可重试）、Playing（Opening accepted + 玩家回合）。
## headless 下布局断言照常运行；截图仅在真实窗口运行时有意义。

const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")
const OpeningStub := preload("res://tests/g4_07a/首次开场桩适配器.gd")
const ViewStub := preload("res://tests/g2_03_桩适配器.gd")

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
	if _root.find("g4_07b") < 0 or _shot_dir.is_empty():
		_fail("task-owned --root / --shot-dir required")
		return _finish()
	_fixture.reset_directory(_root)
	DirAccess.make_dir_recursive_absolute(_shot_dir)
	_source_root = _root.path_join("source-library")
	var installed: Dictionary = _fixture.install_real_assets(_source_root)
	_check(installed.success, "frozen v0.2 full-fidelity packages installed for layout evidence")
	if not installed.success:
		return _finish()
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
	_check(size_label == "maximized" or Vector2i(root.size) == (Vector2i(960, 540) if size_label == "960x540" else Vector2i(1280, 720)), "%s window size applied" % size_label)
	if size_label == "maximized" and DisplayServer.get_name() != "headless":
		_check(root.size.x > 1280, "maximized window is wider than 1280")

	var shell: Variant = _boot_shell(case_root)
	await _settle(3)
	await _drive_wizard_to_review(shell)
	var wizard: Variant = shell.new_game_wizard
	_check(_inside_window(wizard.final_create_button.get_global_rect()) and not wizard.final_create_button.disabled, "%s Review keeps Final Create reachable inside viewport" % size_label)
	await _shot("%s-review" % size_label)

	shell.test_opening_adapter_override = OpeningStub.new()
	var opening_stub: Node = shell.test_opening_adapter_override
	wizard.final_create_button.pressed.emit()
	await _settle(6)
	_check(shell.opening_banner.visible and _inside_window(shell.opening_banner.get_global_rect()), "%s streaming Opening banner visible inside viewport" % size_label)
	_check(not shell.narrative_view.player_input.editable, "%s opening-pending locks Player input" % size_label)
	await _shot("%s-opening-streaming" % size_label)

	opening_stub.simulate_failed("transport")
	await _settle(4)
	_check(shell.opening_banner.visible and shell.opening_retry_button.visible and _inside_window(shell.opening_retry_button.get_global_rect()), "%s failed Opening shows reachable retry banner" % size_label)
	await _shot("%s-opening-failed" % size_label)

	shell.opening_retry_button.pressed.emit()
	await _settle(3)
	opening_stub.simulate_delta("雨夜的第一幕已经展开。")
	opening_stub.simulate_completed()
	await _settle(4)
	_check(not shell.opening_banner.visible and shell.narrative_view.player_input.editable, "%s accepted Opening returns to Playing state" % size_label)
	var view_stub := _swap_view_stub(shell.narrative_view)
	shell.narrative_view.player_input.text = "我望向帐外。"
	shell.narrative_view._on_send_pressed()
	await _settle(2)
	view_stub.text_delta.emit("江风掠过营门。")
	view_stub.simulate_completed()
	await _settle(4)
	_check(shell.session_runtime.conversation.get_durable_accepted_entries().size() == 2, "%s Playing vertical completes Player turn" % size_label)
	await _shot("%s-playing" % size_label)

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


func _drive_wizard_to_review(shell: Variant) -> void:
	shell.new_game_button.pressed.emit()
	await _settle(4)
	var wizard: Variant = shell.new_game_wizard
	_press_choice(wizard, "world_han_end_unsettled_realm")
	wizard.next_button.pressed.emit()
	await _settle(2)
	_press_choice(wizard, "entry_t0-208-red-cliffs-eve")
	wizard.next_button.pressed.emit()
	await _settle(2)
	_press_choice(wizard, "expansion_none")
	wizard.next_button.pressed.emit()
	await _settle(2)
	_press_choice(wizard, "character_han_end_liu_bei")
	wizard.next_button.pressed.emit()
	await _settle(2)
	_toggle_choice(wizard, "npc_character_han_end_sun_quan", true)
	wizard.next_button.pressed.emit()
	await _settle(2)
	wizard.display_name_input.text = "布局证据局"
	wizard.display_name_input.text_changed.emit(wizard.display_name_input.text)
	wizard.next_button.pressed.emit()
	await _settle(4)


func _press_choice(wizard: Variant, name_fragment: String) -> void:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(name_fragment) >= 0:
			button.pressed.emit()
			return
	_fail("choice not found: %s" % name_fragment)


func _toggle_choice(wizard: Variant, name_fragment: String, selected: bool) -> void:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(name_fragment) >= 0:
			button.button_pressed = selected
			button.toggled.emit(selected)
			return
	_fail("toggle not found: %s" % name_fragment)


func _swap_view_stub(view: Variant) -> Node:
	var stub: Node = ViewStub.new()
	view._disconnect_adapter_signals(view.adapter)
	view.remove_child(view.adapter)
	view.adapter.queue_free()
	view.adapter = stub
	view.add_child(stub)
	stub.text_delta.connect(view._on_text_delta)
	stub.completed.connect(view._on_completed)
	stub.cancelled.connect(view._on_cancelled)
	stub.failed.connect(view._on_failed)
	return stub


func _inside_window(rect: Rect2) -> bool:
	return rect.position.x >= 0 and rect.position.y >= 0 and rect.end.x <= root.size.x + 1 and rect.end.y <= root.size.y + 1


func _shot(name: String) -> void:
	await process_frame
	await process_frame
	var path := _shot_dir.path_join("%s.png" % name)
	root.get_texture().get_image().save_png(path)
	print("G4-07B GUI SHOT | %s" % path)


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
		print("G4-07B GUI PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-07B GUI FAIL | %s" % label)


func _finish() -> void:
	print("G4-07B GUI | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
