extends SceneTree

## G4-09R1B1 模型设置 UI 整合测试 —— headless 真实 main.tscn Shell + task-owned settings path。
## 覆盖 packet §10 的 14 项必需断言；Provider 只验证设置面，不触网。

const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")
const OpeningStub := preload("res://tests/g4_07a/首次开场桩适配器.gd")
const ModelSettings := preload("res://src/运行时设置/L3_外交层/模型运行时设置公开接口.gd")

var _failures := 0
var _fixture := Fixture.new()
var _root := ""
var _settings_path := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("g4_09r1b1") < 0:
		_fail("必须提供 task-owned g4_09r1b1 root")
		return _finish()
	_fixture.reset_directory(_root)
	_settings_path = _root.path_join("settings/provider-runtime.json")
	OS.set_environment("MY_WORLD_TEST_SETTINGS_PATH", _settings_path)
	await _test_menu_entry_and_controls()
	await _test_k27_projection()
	await _test_medium_effective_high()
	await _test_save_cancel_restart()
	await _test_invalid_combination_cannot_save()
	await _test_persisted_invalid_recovery()
	await _test_settings_no_game_source_mutation()
	await _test_continue_new_game_after_settings()
	_clear_environment()
	_finish()


## S1/S2/S8：Main Menu 有「模型设置」；打开显示四个精确模型名与凭证状态（无秘密）。
func _test_menu_entry_and_controls() -> void:
	var shell: Variant = await _boot_shell("menu-entry")
	_check(shell.model_settings_button.visible and shell.model_settings_button.text == "模型设置", "S1 Main Menu shows 模型设置")
	shell.model_settings_button.pressed.emit()
	await _settle(3)
	_check(shell.model_settings_overlay.visible and not shell.main_menu_surface.visible, "S1 settings overlay opens over Main Menu")
	var model_names: Array = []
	for index: int in shell.model_option.item_count:
		model_names.append(shell.model_option.get_item_text(index))
	_check(model_names == ["DeepSeek V4 Pro", "DeepSeek V4 Flash", "Kimi K3", "Kimi K2.7"], "S2 four exact model names visible")
	_check(shell.credential_label.text.contains("DeepSeek：") and shell.credential_label.text.contains("Kimi："), "S8 credential status lines visible")
	_check(not shell.credential_label.text.contains("sk-") and shell.credential_label.text.find("KEY") < 0, "S8 credential status never exposes secret values")
	shell.settings_cancel_button.pressed.emit()
	await _settle(3)
	_check(not shell.model_settings_overlay.visible and shell.main_menu_surface.visible, "S1 cancel closes settings back to Main Menu")
	_check(not FileAccess.file_exists(_settings_path), "S3 cancel writes no settings file")
	await _shutdown_shell(shell)


## S5/S6：K2.7 从 backend 投影禁 1M + 固定思考 UX。
func _test_k27_projection() -> void:
	var shell: Variant = await _boot_shell("k27")
	shell.model_settings_button.pressed.emit()
	await _settle(3)
	_select_option(shell.model_option, "Kimi K2.7")
	await _settle(2)
	_check(shell.context_option.is_item_disabled(1), "S5 K2.7 disables 1M from backend projection")
	_check(shell.reasoning_option.disabled, "S6 K2.7 disables graded effort control")
	_check(shell.model_settings_note.visible and shell.model_settings_note.text.contains("固定 Thinking ON"), "S6 K2.7 shows fixed-thinking explanation")
	_check(shell.summary_label.text.contains("固定思考"), "S6 K2.7 summary shows 固定思考")
	_check(not shell.summary_label.text.contains("Low") and not shell.summary_label.text.contains("High"), "S6 K2.7 summary never fabricates graded effort")
	shell.settings_cancel_button.pressed.emit()
	await _settle(2)
	await _shutdown_shell(shell)


## S7：DeepSeek/K3 选 Medium 时摘要披露「实际 High」。
func _test_medium_effective_high() -> void:
	var shell: Variant = await _boot_shell("medium")
	shell.model_settings_button.pressed.emit()
	await _settle(3)
	_select_option(shell.reasoning_option, "Medium")
	await _settle(2)
	_check(shell.summary_label.text.contains("Medium（实际 High）"), "S7 DeepSeek Medium discloses actual High")
	_select_option(shell.model_option, "Kimi K3")
	await _settle(2)
	_check(shell.summary_label.text.contains("Kimi K3") and shell.summary_label.text.contains("Medium（实际 High）"), "S7 Kimi K3 Medium discloses actual High")
	_select_option(shell.reasoning_option, "Max")
	await _settle(2)
	_check(shell.summary_label.text.contains("Max") and not shell.summary_label.text.contains("（实际"), "S7 Max stays Max without disclosure")
	shell.settings_cancel_button.pressed.emit()
	await _settle(2)
	await _shutdown_shell(shell)


## S3/S4：save 持久化；重开面板与新实例都反映 saved values。
func _test_save_cancel_restart() -> void:
	var shell: Variant = await _boot_shell("save-restart")
	shell.model_settings_button.pressed.emit()
	await _settle(3)
	_select_option(shell.model_option, "Kimi K3")
	_select_option(shell.context_option, "1M")
	_select_option(shell.reasoning_option, "Low")
	await _settle(2)
	shell.settings_save_button.pressed.emit()
	await _settle(3)
	_check(FileAccess.file_exists(_settings_path), "S3 save persists settings file")
	_check(not shell.model_settings_overlay.visible and shell.main_menu_surface.visible, "S3 save returns to Main Menu")
	shell.model_settings_button.pressed.emit()
	await _settle(3)
	_check(shell.model_option.get_item_text(shell.model_option.selected) == "Kimi K3" and shell.context_option.get_item_text(shell.context_option.selected) == "1M" and shell.reasoning_option.get_item_text(shell.reasoning_option.selected) == "Low", "S4 reopen shows saved values")
	shell.settings_cancel_button.pressed.emit()
	await _settle(2)
	await _shutdown_shell(shell)

	# 新实例（模拟重启）：backend 持久化恢复。
	var backend := ModelSettings.new(_settings_path)
	var loaded: Dictionary = backend.load_settings()
	_check(loaded.success and String(loaded.settings.profile_id) == "kimi_k3" and String(loaded.settings.context_limit) == "1m" and String(loaded.settings.reasoning_request) == "low", "S4 restart reloads persisted selection")
	var shell2: Variant = await _boot_shell("save-restart")
	shell2.model_settings_button.pressed.emit()
	await _settle(3)
	_check(shell2.model_option.get_item_text(shell2.model_option.selected) == "Kimi K3", "S4 fresh instance shows persisted selection")
	shell2.settings_cancel_button.pressed.emit()
	await _settle(2)
	await _shutdown_shell(shell2)


## S9：非法组合（K2.7 + 1M 候选）不可保存。
func _test_invalid_combination_cannot_save() -> void:
	# 先用 backend 直接写一个 K2.7 候选再尝试切 1M：inspect 必拒。
	var shell: Variant = await _boot_shell("invalid-combo")
	shell.model_settings_button.pressed.emit()
	await _settle(3)
	_select_option(shell.model_option, "Kimi K2.7")
	await _settle(2)
	var direct_inspect: Dictionary = shell.model_settings.inspect_candidate({"profile_id": "kimi_k27", "context_limit": "1m", "reasoning_request": "high"})
	_check(not direct_inspect.success, "S9 K2.7 1M inspect fails")
	_check(shell.context_option.is_item_disabled(1), "S9 K2.7 1M option disabled prevents invalid selection")
	# 直接注入非法候选验证 inspect 失败路径（UI 防御，不依赖控件状态）。
	var inspected: Dictionary = shell.model_settings.inspect_candidate({"profile_id": "kimi_k27", "context_limit": "1m", "reasoning_request": "high"})
	_check(not inspected.success and String(inspected.status) == "incompatible_context_limit", "S9 backend rejects K2.7 + 1M before save")
	# K2.7+1M 非法候选时 save 必禁用
	_check(shell.settings_save_button.disabled, "S9 invalid combination disables save")
	shell.settings_cancel_button.pressed.emit()
	await _settle(2)
	# 文件仍是 S4 保存的 K3 1M Low，未被非法候选覆盖
	var backend_after: Dictionary = ModelSettings.new(_settings_path).load_settings()
	_check(backend_after.success and String(backend_after.settings.profile_id) == "kimi_k3", "S9 invalid combination never persists over saved state")
	await _shutdown_shell(shell)


## S4-invalid：persisted 设置损坏时显示可恢复状态，引导重存。
func _test_persisted_invalid_recovery() -> void:
	DirAccess.make_dir_recursive_absolute(_settings_path.get_base_dir())
	var file := FileAccess.open(_settings_path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema": "my-world.provider-runtime.v1", "settings": {"profile_id": "unknown_model", "context_limit": "256k", "reasoning_request": "high"}}))
	file.close()
	var shell: Variant = await _boot_shell("persisted-invalid")
	shell.model_settings_button.pressed.emit()
	await _settle(3)
	_check(shell._settings_persisted_invalid and shell.settings_result_label.visible, "S4-invalid persisted invalid shows recoverable state")
	_check(shell.settings_result_label.text.contains("无效"), "S4-invalid message is player-readable")
	_check(shell.model_option.get_item_text(shell.model_option.selected) == "DeepSeek V4 Pro", "S4-invalid editing starts from frozen default without silently saving")
	# 玩家显式保存合法组合后恢复。
	_select_option(shell.model_option, "DeepSeek V4 Flash")
	shell.settings_save_button.pressed.emit()
	await _settle(3)
	var backend := ModelSettings.new(_settings_path)
	var loaded: Dictionary = backend.load_settings()
	_check(loaded.success and String(loaded.settings.profile_id) == "deepseek_v4_flash", "S4-invalid explicit save recovers valid persisted state")
	await _shutdown_shell(shell)


## S10：设置保存不改 Game/Source。
func _test_settings_no_game_source_mutation() -> void:
	var case_root := _case_root("no-mutation")
	var source_root := case_root.path_join("source-library")
	var installed: Dictionary = _fixture.install_real_assets(source_root)
	_check(installed.success, "S10 source library installed")
	_set_environment(case_root, source_root)
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await _settle(3)
	# 建一局作为 sentinel。
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
	wizard.next_button.pressed.emit()
	await _settle(2)
	wizard.display_name_input.text = "设置哨兵局"
	wizard.display_name_input.text_changed.emit(wizard.display_name_input.text)
	wizard.next_button.pressed.emit()
	await _settle(4)
	shell.test_opening_adapter_override = OpeningStub.new()
	wizard.final_create_button.pressed.emit()
	await _settle(6)
	_check(shell.session_runtime != null and shell.session_runtime.is_ready(), "S10 sentinel Game created")
	var game_db_path := String(shell.active_game_record.database_path)
	var game_state_before := JSON.stringify(shell.session_runtime.world_state)
	shell.return_menu_button.pressed.emit()
	await _settle(4)
	# 保存设置。
	shell.model_settings_button.pressed.emit()
	await _settle(3)
	_select_option(shell.model_option, "Kimi K3")
	shell.settings_save_button.pressed.emit()
	await _settle(3)
	_check(FileAccess.file_exists(_settings_path), "S10 settings file saved")
	var game_file := FileAccess.open(game_db_path, FileAccess.READ)
	var game_bytes_after := game_file.get_as_text() if game_file != null else ""
	_check(not game_bytes_after.contains("kimi_k3") and not game_bytes_after.contains("Kimi K3"), "S10 settings never enter Game DB")
	_check(game_state_before.length() > 0, "S10 sentinel world_state captured")
	shell.continue_button.pressed.emit()
	await _settle(6)
	_check(JSON.stringify(shell.session_runtime.world_state) == game_state_before, "S10 Game world_state unchanged after settings save")
	await _shutdown_shell(shell)


## S11：设置交互后 Continue/New Game 可用。
func _test_continue_new_game_after_settings() -> void:
	var case_root := _case_root("after-settings")
	var source_root := case_root.path_join("source-library")
	_fixture.install_real_assets(source_root)
	_set_environment(case_root, source_root)
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await _settle(3)
	shell.model_settings_button.pressed.emit()
	await _settle(3)
	_select_option(shell.model_option, "DeepSeek V4 Flash")
	shell.settings_save_button.pressed.emit()
	await _settle(3)
	_check(shell.main_menu_surface.visible and not shell.continue_button.disabled and not shell.new_game_button.disabled, "S11 Main Menu actions usable after settings")
	shell.new_game_button.pressed.emit()
	await _settle(4)
	_check(shell.new_game_wizard.step == 0 and shell.new_game_wizard.worlds.size() == 2, "S11 New Game works after settings interaction")
	shell.new_game_back_button.pressed.emit()
	await _settle(2)
	await _shutdown_shell(shell)


## ---- 驱动辅助 ----

func _case_root(name: String) -> String:
	var path := _root.path_join(name)
	DirAccess.make_dir_recursive_absolute(path)
	return path


func _set_environment(case_root: String, source_root: String) -> void:
	OS.set_environment("MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", source_root)
	OS.set_environment("MY_WORLD_TEST_CURRENT_GAME_DB", case_root.path_join("current-game.sqlite"))
	OS.set_environment("MY_WORLD_TEST_GAME_LIBRARY_ROOT", case_root.path_join("game-library"))
	OS.set_environment("MY_WORLD_TEST_GAMES_ROOT", case_root.path_join("games"))
	OS.set_environment("MY_WORLD_TEST_CREATION_ROOT", case_root.path_join("creation"))


func _clear_environment() -> void:
	for key: String in ["MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", "MY_WORLD_TEST_CURRENT_GAME_DB", "MY_WORLD_TEST_GAME_LIBRARY_ROOT", "MY_WORLD_TEST_GAMES_ROOT", "MY_WORLD_TEST_CREATION_ROOT", "MY_WORLD_TEST_SETTINGS_PATH"]:
		OS.set_environment(key, "")


func _boot_shell(case_name: String) -> Variant:
	var case_root := _case_root(case_name)
	var source_root := case_root.path_join("source-library")
	_fixture.install_real_assets(source_root)
	_set_environment(case_root, source_root)
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await _settle(3)
	_check(shell.application_state == shell.ApplicationState.MENU_READY, "shell boots to Main Menu")
	return shell


func _select_option(option: OptionButton, text: String) -> void:
	for index: int in option.item_count:
		if option.get_item_text(index) == text:
			option.selected = index
			option.item_selected.emit(index)
			return
	_fail("option not found: %s" % text)


func _press_choice(wizard: Variant, name_fragment: String) -> void:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(name_fragment) >= 0:
			button.pressed.emit()
			return
	_fail("choice not found: %s" % name_fragment)


func _shutdown_shell(shell: Variant) -> void:
	shell._close_game_session()
	await _settle(2)
	shell.queue_free()
	await process_frame


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
		print("G4-09R1B1 UI PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-09R1B1 UI FAIL | %s" % label)


func _finish() -> void:
	print("G4-09R1B1 UI | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
