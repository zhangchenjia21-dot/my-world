extends SceneTree

## G4-09R1B1 真实模型设置 UI 集成 —— 真实 main.tscn Shell + 真实 DeepSeek/Kimi Provider。
## 证明 Main Menu 设置面能选择并持久化设置，并驱动：
##   一次 DeepSeek UI 选择 → 真实生成
##   一次 Kimi UI 选择     → 真实生成
## Key 只经 DEEPSEEK_API_KEY / KIMI_API_KEY 环境变量进入 adapter；本脚本与证据绝不记录 key。

const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")
const ModelSettings := preload("res://src/运行时设置/L3_外交层/模型运行时设置公开接口.gd")

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
	if _root.find("g4_09r1b1") < 0 or _shot_dir.is_empty() or _evidence_path.is_empty():
		_fail("task-owned --root / --shot-dir / --evidence required")
		return _finish()
	_fixture.reset_directory(_root)
	DirAccess.make_dir_recursive_absolute(_shot_dir)
	if OS.get_environment("DEEPSEEK_API_KEY").strip_edges().is_empty():
		_fail("DEEPSEEK_API_KEY env required")
		return _finish()
	if OS.get_environment("KIMI_API_KEY").strip_edges().is_empty():
		_fail("KIMI_API_KEY env required")
		return _finish()
	root.size = Vector2i(1280, 720)
	await _settle(6)
	await _test_real_generation_for_provider("deepseek_v4_pro", "DeepSeek V4 Pro", "deepseek")
	await _test_real_generation_for_provider("kimi_k3", "Kimi K3", "kimi")
	_write_evidence()
	_clear_environment()
	_finish()


## 通过真实 Main Menu 设置面选择并持久化 profile，然后建一局驱动真实生成。
func _test_real_generation_for_provider(profile_id: String, display_name: String, provider_id: String) -> void:
	var case_root := _case_root("real-%s" % provider_id)
	var settings_path := case_root.path_join("settings/provider-runtime.json")
	OS.set_environment("MY_WORLD_TEST_SETTINGS_PATH", settings_path)
	var source_root := case_root.path_join("source-library")
	var installed: Dictionary = _fixture.install_real_assets(source_root)
	_check(installed.success, "R source library installed for %s" % display_name)
	if not installed.success:
		return
	_set_environment(case_root, source_root)
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await _settle(4)

	# 真实 Main Menu 设置面：选择 + 保存。
	shell.model_settings_button.pressed.emit()
	await _settle(3)
	_select_option(shell.model_option, display_name)
	await _settle(2)
	_check(shell.summary_label.text.contains(display_name), "R settings summary projects %s" % display_name)
	_check(shell.credential_label.text.contains("已配置"), "R credential status shows configured for %s" % provider_id)
	await _shot("settings-%s" % provider_id)
	shell.settings_save_button.pressed.emit()
	await _settle(3)
	_check(FileAccess.file_exists(settings_path), "R settings persisted for %s" % display_name)
	var backend := ModelSettings.new(settings_path)
	var loaded: Dictionary = backend.load_settings()
	_check(loaded.success and String(loaded.settings.profile_id) == profile_id, "R persisted profile_id = %s" % profile_id)

	# 建一局并驱动真实生成（Opening 即真实 Provider 调用）。
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
	wizard.display_name_input.text = "%s 真实生成" % display_name
	wizard.display_name_input.text_changed.emit(wizard.display_name_input.text)
	wizard.next_button.pressed.emit()
	await _settle(4)
	wizard.final_create_button.pressed.emit()
	await _settle(6)
	_check(shell.application_state == shell.ApplicationState.GAME_ACTIVE and shell.opening_runtime != null, "R create opens Game for %s" % display_name)
	var opened: bool = await _wait_for(func() -> bool: return shell.session_runtime == null or shell.session_runtime.conversation.get_durable_accepted_entries().size() >= 1 or shell.opening_retry_button.visible, 600.0)
	_check(opened and shell.session_runtime != null and shell.session_runtime.conversation.get_durable_accepted_entries().size() == 1, "R real Opening generation accepted for %s" % display_name)
	if shell.session_runtime == null or shell.session_runtime.conversation.get_durable_accepted_entries().is_empty():
		_fail("R Opening did not complete for %s; banner: %s" % [display_name, shell.opening_banner_label.text])
		await _shutdown_shell(shell)
		return
	var opening_text := String(shell.session_runtime.conversation.get_durable_accepted_entries()[0].gm_text)
	_check(opening_text.length() >= 30, "R real generation is narrative for %s (>= 30 chars)" % display_name)
	await _shot("generation-%s" % provider_id)
	_evidence.cases.append({
		"case": provider_id,
		"profile_id": profile_id,
		"display_name": display_name,
		"opening_chars": opening_text.length(),
		"settings_persisted": true,
		"real_generation_accepted": true,
	})
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
	print("G4-09R1B1 REAL SHOT | %s" % path)


func _shutdown_shell(shell: Variant) -> void:
	shell._close_game_session()
	await _settle(2)
	shell.queue_free()
	await process_frame


func _settle(frames: int) -> void:
	for _index: int in range(frames):
		await process_frame


func _write_evidence() -> void:
	_evidence["task"] = "G4-09R1B1"
	_evidence["generated_at"] = Time.get_datetime_string_from_system(true)
	_evidence["failures"] = _failures
	var file := FileAccess.open(_evidence_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(_evidence, "  "))
		file.close()


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-09R1B1 REAL PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-09R1B1 REAL FAIL | %s" % label)


func _finish() -> void:
	_write_evidence()
	print("G4-09R1B1 REAL | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
