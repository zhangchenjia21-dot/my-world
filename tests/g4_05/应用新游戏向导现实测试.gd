extends SceneTree

const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

var _failures := 0
var _fixture := Fixture.new()


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var root_path := _argument("--root=")
	if root_path.find("g4_05") < 0:
		_fail("必须提供 task-owned --root")
		return _finish()
	_fixture.reset_directory(root_path)
	await _prove_boot_does_not_scan_source(root_path.path_join("boot-isolation"))
	await _prove_real_wizard(root_path.path_join("real-wizard"))
	_clear_environment()
	_finish()


func _prove_boot_does_not_scan_source(case_root: String) -> void:
	var source_root := case_root.path_join("source-library")
	DirAccess.make_dir_recursive_absolute(source_root.path_join("current/world_pack"))
	var invalid := FileAccess.open(source_root.path_join("current/world_pack/broken.json"), FileAccess.WRITE)
	invalid.store_string("{broken")
	invalid.close()
	_set_environment(case_root, source_root)
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await _settle(3)
	_check(shell.application_state == shell.ApplicationState.MENU_READY and shell.session_runtime == null, "Main Menu boot ignores invalid Source Library until explicit New Game")
	_check(shell.main_menu_surface.visible and not shell.new_game_surface.visible, "Launch remains Main Menu READY")
	shell.new_game_button.pressed.emit()
	await _settle(3)
	_check(shell.new_game_surface.visible and shell.new_game_wizard.step_label.text == "无法开始", "explicit New Game surfaces Source inventory failure")
	_check(shell.session_runtime == null and not FileAccess.file_exists(case_root.path_join("current-game.sqlite")), "Source failure creates no Game Session/SQLite")
	shell.new_game_back_button.pressed.emit()
	await _settle(2)
	shell.queue_free()
	await process_frame


func _prove_real_wizard(case_root: String) -> void:
	var source_root := case_root.path_join("source-library")
	var installed: Dictionary = _fixture.install_real_assets(source_root)
	_check(installed.success, "frozen v0.2 full-fidelity packages installed for product Wizard")
	_set_environment(case_root, source_root)
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await _settle(3)
	shell.new_game_button.pressed.emit()
	await _settle(4)
	var wizard: Variant = shell.new_game_wizard
	_check(wizard.visible and wizard.step == 0 and wizard.worlds.size() == 2 and wizard.characters.size() == 6, "New Game enters real Wizard with 2 World / 6 Character inventory")
	var all_v02 := true
	for generation: RefCounted in wizard.worlds + wizard.characters:
		if not String(generation.source.identity.get("schema_version", "")).ends_with(".v0.2"):
			all_v02 = false
	_check(all_v02, "all eight loaded generations are schema v0.2 through generation.source")
	_check(wizard.composition.composition_snapshot().world.is_empty() and wizard.next_button.disabled, "first visible World is not an implicit selection")
	_check(_choice_text(wizard, "world_han_end_unsettled_realm").find(_summary_of(wizard.worlds, "world.han_end.unsettled_realm")) >= 0, "World chooser visibly shows current Source catalog_summary")

	_press_choice(wizard, "world_han_end_unsettled_realm")
	_check(not wizard.next_button.disabled, "explicit World item click enables progression")
	wizard.next_button.pressed.emit()
	await _settle(2)
	_check(wizard.title_label.text.find("T0") < 0 and wizard.hint_label.text.find("T0") < 0 and wizard.step_label.text.find("T0") < 0, "generic opening-step UI does not impose T0 wording")
	_check(_choice_text(wizard, "entry_t0-208-red-cliffs-eve").find("208｜赤壁前夕") >= 0, "historical Entry keeps its authored year display name")
	_press_choice(wizard, "entry_t0-208-red-cliffs-eve")
	wizard.next_button.pressed.emit()
	await _settle(2)
	_check(wizard.step == 2 and wizard.next_button.disabled, "Expansion step requires honest explicit none confirmation")
	_press_choice(wizard, "expansion_none")
	wizard.next_button.pressed.emit()
	await _settle(2)
	_check(wizard.step == 3 and wizard.next_button.disabled, "Player step requires explicit eligible Character click")
	_check(_choice_text(wizard, "character_han_end_liu_bei").find(_summary_of(wizard.characters, "character.han_end.liu_bei")) >= 0, "Player Character chooser visibly shows current Source catalog_summary")
	_press_choice(wizard, "character_han_end_liu_bei")
	wizard.next_button.pressed.emit()
	await _settle(2)
	_check(wizard.title_label.text.find("登场") < 0 and wizard.hint_label.text.find("登场") < 0, "Guaranteed NPC wording does not imply opening appearance")
	_check(_choice_text(wizard, "character_han_end_cao_cao").find(_summary_of(wizard.characters, "character.han_end.cao_cao")) >= 0, "Guaranteed NPC chooser visibly shows current Source catalog_summary")
	_toggle_choice(wizard, "character_han_end_cao_cao", true)
	_toggle_choice(wizard, "character_ashtervia_duen_stonescar", true)
	wizard.next_button.pressed.emit()
	await _settle(2)
	_check(wizard.step == 5 and wizard.control_mode.get_item_text(wizard.control_mode.selected) == "Light", "Settings defaults to Light")
	wizard.display_name_input.text = "赤壁之前的另一条路"
	wizard.display_name_input.text_changed.emit(wizard.display_name_input.text)
	wizard.supplement_input.text = "从荆州水路上的一场误会开始。"
	wizard.next_button.pressed.emit()
	await _settle(4)
	_check(wizard.step == 6 and wizard.review_text.text.find("汉末三国：天下未定") >= 0, "Review displays exact selected World")
	_check(wizard.review_text.text.find("208｜赤壁前夕") >= 0 and wizard.review_text.text.find("T0") < 0, "Review shows authored opening name without generic T0 wording")
	_check(wizard.review_text.text.find("刘备") >= 0 and wizard.review_text.text.find("曹操") >= 0 and wizard.review_text.text.find("杜恩·石痕") >= 0, "Review displays exact Player and Guaranteed NPC set")
	_check(wizard.review_text.text.find("赤壁之前的另一条路") >= 0 and wizard.review_text.text.find("Light") >= 0, "Review displays minimal settings")
	_check(wizard.create_placeholder_button.visible and wizard.create_placeholder_button.disabled, "Final Create remains honest disabled G4-06 placeholder")
	_check(shell.session_runtime == null and not FileAccess.file_exists(case_root.path_join("current-game.sqlite")), "full Wizard→Review creates no Game Session/SQLite")
	_check(not DirAccess.dir_exists_absolute(case_root.path_join("game-library")), "full Wizard→Review does not mutate Game Library")

	shell.new_game_back_button.pressed.emit()
	await _settle(3)
	_check(shell.application_state == shell.ApplicationState.MENU_READY and shell.session_state == shell.SessionState.ABSENT, "Cancel returns MENU_READY / Session ABSENT")
	_check(wizard.composition == null, "Cancel discards in-memory Composition")
	shell.queue_free()
	await process_frame


func _press_choice(wizard: Variant, name_fragment: String) -> void:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(name_fragment) >= 0:
			button.pressed.emit()
			return
	_fail("choice not found: %s among %s" % [name_fragment, wizard.choice_buttons.map(func(button: Button) -> String: return String(button.name))])


func _choice_text(wizard: Variant, name_fragment: String) -> String:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(name_fragment) >= 0:
			return button.text
	_fail("choice not found: %s" % name_fragment)
	return ""


func _summary_of(generations: Array, asset_id: String) -> String:
	var generation: RefCounted = _fixture.find_generation(generations, asset_id)
	if generation == null:
		_fail("generation not found: %s" % asset_id)
		return ""
	return String(generation.source.catalog_summary)


func _toggle_choice(wizard: Variant, name_fragment: String, selected: bool) -> void:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(name_fragment) >= 0:
			button.button_pressed = selected
			button.toggled.emit(selected)
			return
	_fail("toggle not found: %s among %s" % [name_fragment, wizard.choice_buttons.map(func(button: Button) -> String: return String(button.name))])


func _set_environment(case_root: String, source_root: String) -> void:
	OS.set_environment("MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", source_root)
	OS.set_environment("MY_WORLD_TEST_CURRENT_GAME_DB", case_root.path_join("current-game.sqlite"))
	OS.set_environment("MY_WORLD_TEST_GAME_LIBRARY_ROOT", case_root.path_join("game-library"))
	OS.set_environment("MY_WORLD_TEST_GAMES_ROOT", case_root.path_join("games"))


func _clear_environment() -> void:
	for key: String in ["MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", "MY_WORLD_TEST_CURRENT_GAME_DB", "MY_WORLD_TEST_GAME_LIBRARY_ROOT", "MY_WORLD_TEST_GAMES_ROOT"]:
		OS.set_environment(key, "")


func _settle(frames: int) -> void:
	for _index: int in range(frames): await process_frame


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix): return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition: print("G4-05 APP WIZARD PASS | %s" % label)
	else: _fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-05 APP WIZARD FAIL | %s" % label)


func _finish() -> void:
	print("G4-05 APP WIZARD | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
