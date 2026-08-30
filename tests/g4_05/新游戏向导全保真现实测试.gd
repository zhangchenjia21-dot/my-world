extends SceneTree

## G4-05R2 聚焦现实测试：真实 Application/Wizard 路径直接消费冻结 v0.2 full-fidelity Source。
## 覆盖：真实不兼容三国路线清晰失败且无破坏、埃瑟维亚路线到达 Review、
## IR01 非时态世界/角色以场景开局呈现且不被强加 T0 概念。

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
	var installed: Dictionary = _fixture.install_real_assets(root_path.path_join("source-library"))
	_check(installed.success, "frozen v0.2 full-fidelity packages installed through production Managed Source Library")
	if not installed.success:
		return _finish()
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await _settle(3)
	await _prove_incompatible_han_route(shell, root_path)
	await _prove_afterglow_route(shell, root_path)
	await _prove_non_temporal_scenario_route(shell, root_path)
	shell.queue_free()
	await process_frame
	_clear_environment()
	_finish()


## AC-05R2-05：真实 229 + 刘备 路线必须因后端 temporal incompatibility 清晰失败，
## 用玩家可理解的语言说明，不替换 profile，不产生任何 Game，并允许返回修改。
func _prove_incompatible_han_route(shell: Variant, case_root: String) -> void:
	_set_environment(case_root, case_root.path_join("source-library"))
	shell.new_game_button.pressed.emit()
	await _settle(4)
	var wizard: Variant = shell.new_game_wizard
	_check(wizard.visible and wizard.worlds.size() == 2 and wizard.characters.size() == 6, "incompatible route starts from real v0.2 inventory")
	_press(wizard, "world_han_end_unsettled_realm")
	await _next(wizard)
	_press(wizard, "entry_t0-229-three-states")
	await _next(wizard)
	_press(wizard, "expansion_none")
	await _next(wizard)
	_press(wizard, "character_han_end_liu_bei")
	await _next(wizard)
	await _next(wizard)
	wizard.display_name_input.text = "鼎立之后的假设"
	wizard.display_name_input.text_changed.emit(wizard.display_name_input.text)
	await _next(wizard)
	_check(wizard.step == 6, "incompatible route reaches Review step")
	var backend: Dictionary = wizard.composition.build_compatibility_review()
	_check(not backend.success and String(backend.code) == "character_temporal_incompatible", "backend remains authoritative: character_temporal_incompatible, no profile substitution")
	_check(wizard.review_text.text.find("无法继续创建") >= 0 and wizard.review_text.text.find("229｜三国鼎立") >= 0, "Review failure names the selected opening in plain player language")
	_check(wizard.review_text.text.find("更换开局") >= 0 or wizard.review_text.text.find("调整") >= 0, "Review failure tells the player how to recover")
	_check(wizard.review_text.text.find("T0") < 0 and wizard.review_text.text.find("coverage") < 0 and wizard.review_text.text.find("封闭") < 0, "Review failure hides backend temporal jargon")
	_check(wizard.create_placeholder_button.visible and wizard.create_placeholder_button.disabled, "Final Create stays disabled on failed Review")
	_check(shell.session_runtime == null and not FileAccess.file_exists(case_root.path_join("current-game.sqlite")) and not DirAccess.dir_exists_absolute(case_root.path_join("game-library")), "failed Review creates no Game/Session/SQLite/Game Library")

	for _index: int in range(5):
		wizard.back_button.pressed.emit()
		await _settle(2)
	_check(wizard.step == 1, "player can navigate back from failed Review to the opening step")
	_press(wizard, "entry_t0-208-red-cliffs-eve")
	await _next(wizard)
	await _next(wizard)
	await _next(wizard)
	await _next(wizard)
	await _next(wizard)
	_check(wizard.step == 6 and wizard.review_text.text.find("208｜赤壁前夕") >= 0 and wizard.review_text.text.find("无法继续创建") < 0, "after changing the opening the same Composition reaches a valid Review")
	wizard.cancel_button.pressed.emit()
	await _settle(3)
	_check(shell.main_menu_surface.visible and shell.session_runtime == null, "incompatible route cancel returns clean Main Menu")


## AC-05R2-06：埃瑟维亚路线正常到达 Review，不被发明出历史/家族时间限制。
func _prove_afterglow_route(shell: Variant, case_root: String) -> void:
	shell.new_game_button.pressed.emit()
	await _settle(4)
	var wizard: Variant = shell.new_game_wizard
	_press(wizard, "world_ashtervia_afterglow")
	await _next(wizard)
	_check(_text_of(wizard, "entry_t0-1287-public-works").find("1287｜断裂遗迹公共工程") >= 0, "Afterglow Entries show their authored scenario names")
	_press(wizard, "entry_t0-1287-public-works")
	await _next(wizard)
	_press(wizard, "expansion_none")
	await _next(wizard)
	_press(wizard, "character_ashtervia_livia_selan")
	await _next(wizard)
	_toggle(wizard, "character_ashtervia_duen_stonescar", true)
	_toggle(wizard, "character_ashtervia_adrian_wilk", true)
	await _next(wizard)
	wizard.display_name_input.text = "公共工程的余波"
	wizard.display_name_input.text_changed.emit(wizard.display_name_input.text)
	await _next(wizard)
	_check(wizard.step == 6 and wizard.review_text.text.find("无法继续创建") < 0, "Afterglow route reaches a valid Review")
	_check(wizard.review_text.text.find("埃瑟维亚：诸界余辉") >= 0 and wizard.review_text.text.find("1287｜断裂遗迹公共工程") >= 0, "Review shows the chosen Afterglow World and opening")
	_check(wizard.review_text.text.find("莉维娅·塞兰") >= 0 and wizard.review_text.text.find("杜恩·石痕") >= 0 and wizard.review_text.text.find("阿德里安·维尔克") >= 0, "Review shows exact Afterglow Player and Guaranteed NPC set")
	_check(shell.session_runtime == null and not FileAccess.file_exists(case_root.path_join("current-game.sqlite")), "Afterglow Review creates no Game/Session/SQLite")
	wizard.cancel_button.pressed.emit()
	await _settle(3)
	_check(shell.main_menu_surface.visible, "Afterglow route cancel returns Main Menu")


## AC-05R2-03：非时态世界可以把 Entry 用作纯场景/开局选择，通用 UI 不引入 T0 概念。
func _prove_non_temporal_scenario_route(shell: Variant, case_root: String) -> void:
	var ir01_root := case_root.path_join("ir01-library")
	var installed: Dictionary = _fixture.install_packages(ir01_root, Fixture.IR01_NON_TEMPORAL_PACKAGES)
	_check(installed.success, "IR01 non-temporal World/Character packages installed")
	if not installed.success:
		return
	_set_environment(case_root, ir01_root)
	shell.new_game_button.pressed.emit()
	await _settle(4)
	var wizard: Variant = shell.new_game_wizard
	_check(wizard.worlds.size() == 1 and wizard.characters.size() == 1, "non-temporal library exposes exactly its authored inventory")
	_check(_text_of(wizard, "world_ir01_tidal_archipelago").find("开局场景") >= 0, "non-temporal World chooser shows its catalog_summary")
	_press(wizard, "world_ir01_tidal_archipelago")
	await _next(wizard)
	var generic_text := "%s\n%s\n%s" % [wizard.title_label.text, wizard.hint_label.text, wizard.step_label.text]
	_check(generic_text.find("T0") < 0, "scenario opening step never mentions T0")
	_check(_text_of(wizard, "entry_opening-harbor-market").find("港市晨潮") >= 0 and _text_of(wizard, "entry_opening-outer-lighthouse").find("外海灯塔") >= 0, "scenario Entries show authored names without any historical framing")
	_press(wizard, "entry_opening-harbor-market")
	await _next(wizard)
	_press(wizard, "expansion_none")
	await _next(wizard)
	_press(wizard, "character_ir01_river_cartographer")
	await _next(wizard)
	await _next(wizard)
	wizard.display_name_input.text = "潮汐之间"
	wizard.display_name_input.text_changed.emit(wizard.display_name_input.text)
	await _next(wizard)
	_check(wizard.step == 6 and wizard.review_text.text.find("潮汐群岛") >= 0 and wizard.review_text.text.find("港市晨潮") >= 0 and wizard.review_text.text.find("无法继续创建") < 0, "non-temporal Character with zero World coverage passes Review without invented restriction")
	_check(shell.session_runtime == null and not FileAccess.file_exists(case_root.path_join("current-game.sqlite")) and not DirAccess.dir_exists_absolute(case_root.path_join("game-library")), "non-temporal route also creates no Game side effects")
	wizard.cancel_button.pressed.emit()
	await _settle(3)


func _next(wizard: Variant) -> void:
	wizard.next_button.pressed.emit()
	await _settle(3)


func _press(wizard: Variant, fragment: String) -> void:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(fragment) >= 0:
			button.pressed.emit()
			return
	_fail("button not found: %s among %s" % [fragment, wizard.choice_buttons.map(func(button: Button) -> String: return String(button.name))])


func _toggle(wizard: Variant, fragment: String, selected: bool) -> void:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(fragment) >= 0:
			button.button_pressed = selected
			button.toggled.emit(selected)
			return
	_fail("toggle not found: %s" % fragment)


func _text_of(wizard: Variant, fragment: String) -> String:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(fragment) >= 0:
			return button.text
	_fail("choice not found: %s" % fragment)
	return ""


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
	if condition: print("G4-05R2 WIZARD PASS | %s" % label)
	else: _fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-05R2 WIZARD FAIL | %s" % label)


func _finish() -> void:
	print("G4-05R2 WIZARD | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
