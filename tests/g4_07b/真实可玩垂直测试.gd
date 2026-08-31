extends SceneTree

## G4-07B 真实可玩垂直 —— 真实 main.tscn Shell + 真实 DeepSeek Provider（非 headless，1280x720）。
## Han（208 赤壁前夕 + 刘备 + 孙权）与 Afterglow（t0-1287 + 莉维娅 + 阿德里安/杜恩）两条
## family-agnostic 垂直：Wizard → Final Create → existing-only open → 真实 GM Opening streaming
## → 玩家行动 → durable continuation → Continue 无二次开场。
## Key 只经 DEEPSEEK_API_KEY 环境变量进入 adapter；本脚本与证据文件绝不记录 key。

const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

var _failures := 0
var _fixture := Fixture.new()
var _root := ""
var _shot_dir := ""
var _evidence_path := ""
var _evidence: Dictionary = {"cases": []}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	_shot_dir = _argument("--shot-dir=")
	_evidence_path = _argument("--evidence=")
	if _root.find("g4_07b") < 0 or _shot_dir.is_empty() or _evidence_path.is_empty():
		_fail("task-owned --root / --shot-dir / --evidence required")
		return _finish()
	_fixture.reset_directory(_root)
	DirAccess.make_dir_recursive_absolute(_shot_dir)
	var source_root := _root.path_join("source-library")
	var installed: Dictionary = _fixture.install_real_assets(source_root)
	_check(installed.success, "frozen v0.2 full-fidelity packages installed for real vertical")
	if not installed.success:
		return _finish()
	if OS.get_environment("DEEPSEEK_API_KEY").strip_edges().is_empty():
		_fail("DEEPSEEK_API_KEY env required（由运行器从 .env.local 注入）")
		return _finish()
	root.size = Vector2i(1280, 720)
	await _settle(6)
	await _test_han_real_vertical(source_root)
	await _test_afterglow_real_vertical(source_root)
	_write_evidence()
	_clear_environment()
	_finish()


func _test_han_real_vertical(source_root: String) -> void:
	var case_root := _case_root("han-real")
	var shell: Variant = await _boot_shell(case_root, source_root)
	await _drive_wizard_to_review(shell, "entry_t0-208-red-cliffs-eve", "character_han_end_liu_bei", ["npc_character_han_end_sun_quan"], "赤壁真实垂直", "从江夏的雨夜开始。")
	_check(shell.new_game_wizard.step == 6 and not shell.new_game_wizard.final_create_button.disabled, "Han real Review ready for Final Create")
	await _shot("han-review")
	shell.new_game_wizard.final_create_button.pressed.emit()
	await _settle(6)
	_check(shell.application_state == shell.ApplicationState.GAME_ACTIVE and shell.opening_runtime != null, "Han real create opens Game and starts first Opening")
	_check(shell.opening_banner.visible and not shell.narrative_view.player_input.editable, "Han real Opening streams with locked Player input")
	await _wait_for(func() -> bool: return shell.narrative_view._current_gm_content != null and String(shell.narrative_view._current_gm_content.text).length() > 0, 120.0)
	await _shot("han-opening-streaming")
	var opened: bool = await _wait_for(func() -> bool: return shell.session_runtime == null or shell.session_runtime.conversation.get_durable_accepted_entries().size() >= 1 or shell.opening_retry_button.visible, 420.0)
	_check(opened and shell.session_runtime != null and shell.session_runtime.conversation.get_durable_accepted_entries().size() == 1, "Han real Opening accepted durable exactly once")
	if shell.session_runtime == null or shell.session_runtime.conversation.get_durable_accepted_entries().is_empty():
		_fail("Han real Opening did not complete; banner: %s" % shell.opening_banner_label.text)
		await _shutdown_shell(shell)
		return
	var opening_text := String(shell.session_runtime.conversation.get_durable_accepted_entries()[0].gm_text)
	_check(opening_text.length() >= 60, "Han real Opening is narrative-rich (>= 60 chars)")
	_check(not shell.opening_banner.visible and shell.narrative_view.player_input.editable, "Han accepted Opening unlocks Player input")
	var first_messages: Array = shell.opening_runtime.last_request_messages.duplicate(true)
	_check(first_messages.size() == 1 and String(first_messages[0].role) == "system", "Han real first Opening request is single system message")
	var game_id := String(shell.session_runtime.game_id)
	await _shot("han-opening-accepted")

	# 真实玩家行动 → durable continuation（roles system/assistant/user）。
	var captured: Array = []
	shell.narrative_view.request_messages_assembled.connect(func(messages: Array) -> void: captured.append(messages))
	shell.narrative_view.player_input.text = "我走出军帐，查看江面水情。"
	shell.narrative_view._on_send_pressed()
	var continued: bool = await _wait_for(func() -> bool: return shell.session_runtime == null or shell.session_runtime.conversation.get_durable_accepted_entries().size() >= 2, 420.0)
	_check(continued and shell.session_runtime.conversation.get_durable_accepted_entries().size() == 2, "Han real Player action accepted durable")
	var roles: Array = []
	if not captured.is_empty():
		for message: Dictionary in captured[0]:
			roles.append(String(message.role))
	_check(roles == ["system", "assistant", "user"], "Han continuation roles system/assistant/user")
	var continuation := JSON.stringify(captured[0]) if not captured.is_empty() else ""
	_check(continuation.contains("e208-snapshot") and continuation.contains("我走出军帐"), "Han continuation carries durable World truth and Player action")
	await _shot("han-playing")

	# Continue：同一 Game、无二次开场。
	shell.return_menu_button.pressed.emit()
	await _settle(4)
	shell.continue_button.pressed.emit()
	await _settle(8)
	_check(shell.session_runtime != null and String(shell.session_runtime.game_id) == game_id, "Han Continue reopens the exact same Game")
	_check(shell.session_runtime.conversation.get_durable_accepted_entries().size() == 2, "Han Continue restores durable history")
	_check(shell.opening_runtime != null and shell.opening_runtime.last_request_messages.is_empty() and not shell.opening_banner.visible, "Han Continue never triggers a second first Opening")
	await _shot("han-continue-restored")
	_evidence.cases.append({
		"case": "han",
		"game_id": game_id,
		"opening_chars": opening_text.length(),
		"accepted_after_vertical": 2,
		"first_request_roles": ["system"],
		"continuation_roles": roles,
		"no_second_opening_after_continue": true,
	})
	await _shutdown_shell(shell)


func _test_afterglow_real_vertical(source_root: String) -> void:
	var case_root := _case_root("afterglow-real")
	var shell: Variant = await _boot_shell(case_root, source_root)
	await _drive_wizard_to_review(shell, "entry_t0-1287-public-works", "character_ashtervia_livia_selan", ["npc_character_ashtervia_adrian_wilk", "npc_character_ashtervia_duen_stonescar"], "余辉真实垂直", "保留角色各自的信息边界。", "world_ashtervia_afterglow")
	_check(shell.new_game_wizard.step == 6 and not shell.new_game_wizard.final_create_button.disabled, "Afterglow real Review ready for Final Create")
	await _shot("afterglow-review")
	shell.new_game_wizard.final_create_button.pressed.emit()
	await _settle(6)
	_check(shell.application_state == shell.ApplicationState.GAME_ACTIVE and shell.opening_banner.visible, "Afterglow real create starts first Opening via same family-agnostic path")
	await _wait_for(func() -> bool: return shell.narrative_view._current_gm_content != null and String(shell.narrative_view._current_gm_content.text).length() > 0, 120.0)
	await _shot("afterglow-opening-streaming")
	var opened: bool = await _wait_for(func() -> bool: return shell.session_runtime == null or shell.session_runtime.conversation.get_durable_accepted_entries().size() >= 1 or shell.opening_retry_button.visible, 420.0)
	_check(opened and shell.session_runtime != null and shell.session_runtime.conversation.get_durable_accepted_entries().size() == 1, "Afterglow real Opening accepted durable exactly once")
	if shell.session_runtime == null or shell.session_runtime.conversation.get_durable_accepted_entries().is_empty():
		_fail("Afterglow real Opening did not complete; banner: %s" % shell.opening_banner_label.text)
		await _shutdown_shell(shell)
		return
	var opening_text := String(shell.session_runtime.conversation.get_durable_accepted_entries()[0].gm_text)
	_check(opening_text.length() >= 60, "Afterglow real Opening is narrative-rich (>= 60 chars)")
	var serialized := JSON.stringify(shell.opening_runtime.last_request_messages)
	_check(serialized.contains("t0-1287-public-works") and serialized.contains("莉维娅") and serialized.contains("阿德里安") and serialized.contains("杜恩"), "Afterglow transports distinct exact World/Player/cast semantics")
	_check(not serialized.contains("赤壁") and not serialized.contains("刘备"), "Afterglow context carries no Han semantics")
	await _shot("afterglow-opening-accepted")
	_evidence.cases.append({
		"case": "afterglow",
		"game_id": String(shell.session_runtime.game_id),
		"opening_chars": opening_text.length(),
		"accepted_after_vertical": 1,
		"first_request_roles": ["system"],
	})
	await _shutdown_shell(shell)


## ---- 驱动辅助 ----

func _case_root(name: String) -> String:
	var path := _root.path_join(name)
	DirAccess.make_dir_recursive_absolute(path)
	return path


func _boot_shell(case_root: String, source_root: String) -> Variant:
	OS.set_environment("MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", source_root)
	OS.set_environment("MY_WORLD_TEST_CURRENT_GAME_DB", case_root.path_join("current-game.sqlite"))
	OS.set_environment("MY_WORLD_TEST_GAME_LIBRARY_ROOT", case_root.path_join("game-library"))
	OS.set_environment("MY_WORLD_TEST_GAMES_ROOT", case_root.path_join("games"))
	OS.set_environment("MY_WORLD_TEST_CREATION_ROOT", case_root.path_join("creation"))
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await _settle(4)
	_check(shell.application_state == shell.ApplicationState.MENU_READY, "shell boots to Main Menu")
	return shell


func _drive_wizard_to_review(shell: Variant, entry_fragment: String, player_fragment: String, npc_fragments: Array, display_name: String, supplement: String, world_fragment: String = "world_han_end_unsettled_realm") -> void:
	shell.new_game_button.pressed.emit()
	await _settle(4)
	var wizard: Variant = shell.new_game_wizard
	_press_choice(wizard, world_fragment)
	wizard.next_button.pressed.emit()
	await _settle(2)
	_press_choice(wizard, entry_fragment)
	wizard.next_button.pressed.emit()
	await _settle(2)
	_press_choice(wizard, "expansion_none")
	wizard.next_button.pressed.emit()
	await _settle(2)
	_press_choice(wizard, player_fragment)
	wizard.next_button.pressed.emit()
	await _settle(2)
	for npc_fragment: String in npc_fragments:
		_toggle_choice(wizard, npc_fragment, true)
	wizard.next_button.pressed.emit()
	await _settle(2)
	wizard.display_name_input.text = display_name
	wizard.display_name_input.text_changed.emit(display_name)
	wizard.supplement_input.text = supplement
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


func _wait_for(condition: Callable, timeout_sec: float) -> bool:
	var deadline := Time.get_ticks_msec() + int(timeout_sec * 1000.0)
	while Time.get_ticks_msec() < deadline:
		if condition.call():
			return true
		await process_frame
	return condition.call()


func _shot(name: String) -> void:
	await process_frame
	await process_frame
	var path := _shot_dir.path_join("%s.png" % name)
	root.get_texture().get_image().save_png(path)
	print("G4-07B REAL SHOT | %s" % path)


func _shutdown_shell(shell: Variant) -> void:
	shell._close_game_session()
	await _settle(2)
	shell.queue_free()
	await process_frame


func _settle(frames: int) -> void:
	for _index: int in range(frames):
		await process_frame


func _write_evidence() -> void:
	_evidence["task"] = "G4-07B"
	_evidence["generated_at"] = Time.get_datetime_string_from_system(true)
	_evidence["failures"] = _failures
	var file := FileAccess.open(_evidence_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(_evidence, "  "))
		file.close()


func _clear_environment() -> void:
	for key: String in ["MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", "MY_WORLD_TEST_CURRENT_GAME_DB", "MY_WORLD_TEST_GAME_LIBRARY_ROOT", "MY_WORLD_TEST_GAMES_ROOT", "MY_WORLD_TEST_CREATION_ROOT"]:
		OS.set_environment(key, "")


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-07B REAL PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-07B REAL FAIL | %s" % label)


func _finish() -> void:
	_write_evidence()
	print("G4-07B REAL | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
