extends SceneTree

## G4-08B 真实公开 D20 界面垂直 —— 真实 main.tscn Shell + 真实 DeepSeek Provider。
## Han 208｜赤壁前夕 + 刘备 + 孙权 + Public d20：风险行动自然触发 CHECK_REQUIRED，
## Program 结果公开展示，GM continuation 尊重 outcome；后续普通行动 NO_CHECK 无骰卡。
## Key 只经 DEEPSEEK_API_KEY 环境变量进入 adapter；本脚本与证据文件绝不记录 key。

const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")
const ModelSettings := preload("res://src/运行时设置/L3_外交层/模型运行时设置公开接口.gd")
const RuntimeAdapter := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")

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
	if _root.find("g4_08b") < 0 or _shot_dir.is_empty() or _evidence_path.is_empty():
		_fail("task-owned --root / --shot-dir / --evidence required")
		return _finish()
	_fixture.reset_directory(_root)
	DirAccess.make_dir_recursive_absolute(_shot_dir)
	var source_root := _root.path_join("source-library")
	var installed: Dictionary = _fixture.install_real_assets(source_root)
	_check(installed.success, "frozen v0.2 full-fidelity packages installed for real vertical")
	if not installed.success:
		return _finish()
	_library = installed.library
	var expansion: Dictionary = _library.install_expansion_pack("res://tests/fixtures/g4_08m1/判定与检定_公开d20")
	_check(expansion.success, "Public d20 Expansion installed")
	if not expansion.success:
		return _finish()
	if OS.get_environment("DEEPSEEK_API_KEY").strip_edges().is_empty():
		_fail("DEEPSEEK_API_KEY env required")
		return _finish()
	root.size = Vector2i(1280, 720)
	await _settle(6)
	await _test_han_real_d20_vertical(source_root)
	_write_evidence()
	_clear_environment()
	_finish()


var _library: RefCounted


func _test_han_real_d20_vertical(source_root: String) -> void:
	var case_root := _case_root("han-d20")
	var shell: Variant = await _boot_shell(case_root, source_root)
	await _drive_wizard_to_review(shell, "entry_t0-208-red-cliffs-eve", "character_han_end_liu_bei", ["npc_character_han_end_sun_quan"], "赤壁真实判定", "从江夏的雨夜开始。", "world_han_end_unsettled_realm", true)
	_check(shell.new_game_wizard.step == 6 and not shell.new_game_wizard.final_create_button.disabled, "I Han d20 Review ready")
	await _shot("han-d20-review")
	shell.new_game_wizard.final_create_button.pressed.emit()
	await _settle(6)
	_check(shell.application_state == shell.ApplicationState.GAME_ACTIVE and shell.action_adjudication != null, "I create opens Game with adjudication Host")
	# 第一幕走真实 DeepSeek Opening
	var opened: bool = await _wait_for(func() -> bool: return shell.session_runtime == null or shell.session_runtime.conversation.get_durable_accepted_entries().size() >= 1 or shell.opening_retry_button.visible, 420.0)
	_check(opened and shell.session_runtime.conversation.get_durable_accepted_entries().size() == 1, "I real Opening accepted")
	if shell.session_runtime == null or shell.session_runtime.conversation.get_durable_accepted_entries().is_empty():
		_fail("Opening did not complete; banner: %s" % shell.opening_banner_label.text)
		await _shutdown_shell(shell)
		return
	await _shot("han-d20-opening")

	# I：风险行动自然触发 CHECK_REQUIRED；Program 结果公开展示。
	shell.narrative_view.player_input.text = "我独自潜入曹军水寨，试图盗取军令。"
	shell.narrative_view._on_send_pressed()
	var adjudicating: bool = await _wait_for(func() -> bool: return shell.action_adjudication != null and String(shell.action_adjudication._stage) == "adjudication", 30.0)
	_check(adjudicating, "I risky action starts adjudication stage")
	var adjudicated: bool = await _wait_for(func() -> bool: return shell.action_adjudication != null and String(shell.action_adjudication._stage) == "resolution_narrative", 180.0)
	_check(adjudicated, "I adjudication completes and starts resolution narrative")
	var action_id := String(shell.narrative_view._pending_action_id)
	_check(not action_id.is_empty(), "I stable action_id minted")
	var durable := _check_record(shell.session_runtime, action_id)
	_check(durable.success, "I Program result durable before narrative completes")
	_check(_count_mechanic_cards(shell.narrative_view) >= 1, "I transient public result visible during narrative")
	await _shot("han-d20-check-transient")
	var continued: bool = await _wait_for(func() -> bool: return shell.session_runtime == null or shell.session_runtime.conversation.get_durable_accepted_entries().size() >= 2, 420.0)
	_check(continued and shell.session_runtime.conversation.get_durable_accepted_entries().size() == 2, "I GM continuation accepted respecting outcome")
	var check_timing: Dictionary = shell.action_adjudication.timing_snapshot()
	_check(_timing_ordered(check_timing, ["durable_check_completed", "first_visible_narrative_delta", "provider_completed", "finalize_completed"]) and int(check_timing.first_visible_narrative_delta) < int(check_timing.provider_completed), "I real CHECK_REQUIRED timing proves durable -> visible-before-completed -> finalize")
	var card_text := _first_mechanic_card_text(shell.narrative_view)
	_check(card_text.contains("判定") and (card_text.contains("成功") or card_text.contains("失败")), "I durable mechanic card shows public outcome")
	await _shot("han-d20-check-accepted")

	# I：普通行动 NO_CHECK 无骰卡。
	var card_count_before := _count_mechanic_cards(shell.narrative_view)
	shell.narrative_view.player_input.text = "我向身边侍从询问今日日期。"
	shell.narrative_view._on_send_pressed()
	var no_check_done: bool = await _wait_for(func() -> bool: return shell.session_runtime == null or shell.session_runtime.conversation.get_durable_accepted_entries().size() >= 3, 600.0)
	_check(no_check_done and shell.session_runtime.conversation.get_durable_accepted_entries().size() == 3, "I ordinary action accepted")
	_check(_count_mechanic_cards(shell.narrative_view) == card_count_before, "I NO_CHECK renders no dice card")
	var no_check_timing: Dictionary = shell.action_adjudication.timing_snapshot()
	_check(int(shell.action_adjudication.last_result.get("provider_calls", -1)) == 1, "I real NO_CHECK remains one selected-provider call")
	_check(_timing_ordered(no_check_timing, ["first_provider_content_delta", "first_visible_narrative_delta", "provider_completed", "finalize_completed"]) and int(no_check_timing.first_visible_narrative_delta) < int(no_check_timing.provider_completed), "I real NO_CHECK timing proves provider delta -> visible-before-completed -> finalize")
	await _shot("han-d20-no-check")
	_evidence.cases.append({
		"case": "han-d20",
		"game_id": String(shell.session_runtime.game_id),
		"check_action_id": action_id,
		"check_outcome": String(durable.check.get("outcome", "")),
		"check_dc": int(durable.check.get("dc", 0)),
		"check_total": int(durable.check.get("total", 0)),
		"accepted_after_vertical": 3,
		"no_check_no_card": true,
		"selected_profile": "deepseek_v4_pro",
		"check_timing_us": check_timing,
		"no_check_timing_us": no_check_timing,
	})
	await _shutdown_shell(shell)


## ---- 驱动辅助 ----

func _proposal(dc: int, modifier: int, stance: String) -> Dictionary:
	return {"decision": "CHECK_REQUIRED", "proposal": {
		"intent": "完成高风险行动", "dc": dc, "modifier": modifier,
		"stance": stance, "modifier_reason": "来自 Game-local 角色事实", "situation_reason": "存在不确定性与代价",
		"success_intent": "行动达成", "failure_stakes": "暴露并承受后果",
	}}


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
	var settings_path := case_root.path_join("settings/provider-runtime.json")
	OS.set_environment("MY_WORLD_TEST_SETTINGS_PATH", settings_path)
	var saved: Dictionary = ModelSettings.new(settings_path).save_settings({
		"profile_id": "deepseek_v4_pro", "context_limit": "256k", "reasoning_request": "high",
	})
	_check(saved.success, "task-owned selected-provider settings saved for real vertical")
	var shell: Variant = load("res://src/main.tscn").instantiate()
	# Opening 与 Public d20 各自持有独立 adapter；二者都从同一 task-owned 设置快照读取，
	# 避免真实验证读取或覆盖 Owner 默认 user:// 设置。
	shell.test_opening_adapter_override = RuntimeAdapter.new(ModelSettings.new(settings_path))
	shell.test_adjudication_adapter_override = RuntimeAdapter.new(ModelSettings.new(settings_path))
	root.add_child(shell)
	await _settle(4)
	_check(shell.application_state == shell.ApplicationState.MENU_READY, "shell boots to Main Menu")
	return shell


func _drive_wizard_to_review(shell: Variant, entry_fragment: String, player_fragment: String, npc_fragments: Array, display_name: String, supplement: String, world_fragment: String = "world_han_end_unsettled_realm", with_expansion: bool = true) -> void:
	shell.new_game_button.pressed.emit()
	await _settle(4)
	var wizard: Variant = shell.new_game_wizard
	_press_choice(wizard, world_fragment)
	wizard.next_button.pressed.emit()
	await _settle(2)
	_press_choice(wizard, entry_fragment)
	wizard.next_button.pressed.emit()
	await _settle(2)
	if with_expansion:
		_toggle_choice(wizard, "expansion_exp_check_core_public_d20", true)
	else:
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
		if String(button.name).find(name_fragment) >= 0 and button is CheckButton:
			(button as CheckButton).button_pressed = selected
			button.toggled.emit(selected)
			return
	_fail("toggle not found: %s" % name_fragment)


func _check_record(runtime: Variant, action_id: String) -> Dictionary:
	for value: Variant in runtime.world_state.get("expansion_runtime", {}).get("public_d20_checks", []):
		if value is Dictionary and String(value.get("action_id", "")) == action_id:
			return {"success": true, "check": value}
	return {"success": false}


func _count_mechanic_cards(view: Variant) -> int:
	var count := 0
	for child: Node in view.entries.get_children():
		if child.has_meta("mechanic_card"):
			count += 1
	return count


func _first_mechanic_card_text(view: Variant) -> String:
	for child: Node in view.entries.get_children():
		if child.has_meta("mechanic_card"):
			return _collect_text(child)
	return ""


func _collect_text(node: Node) -> String:
	var text := ""
	if node is Label:
		text += String((node as Label).text) + "\n"
	elif node is RichTextLabel:
		text += String((node as RichTextLabel).text) + "\n"
	for child: Node in node.get_children():
		text += _collect_text(child)
	return text


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
	print("G4-08B REAL SHOT | %s" % path)


func _shutdown_shell(shell: Variant) -> void:
	shell._close_game_session()
	await _settle(2)
	shell.queue_free()
	await process_frame


func _settle(frames: int) -> void:
	for _index: int in range(frames):
		await process_frame


func _write_evidence() -> void:
	_evidence["task"] = "G4-08B"
	_evidence["generated_at"] = Time.get_datetime_string_from_system(true)
	_evidence["failures"] = _failures
	var file := FileAccess.open(_evidence_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(_evidence, "  "))
		file.close()


func _clear_environment() -> void:
	for key: String in ["MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", "MY_WORLD_TEST_CURRENT_GAME_DB", "MY_WORLD_TEST_GAME_LIBRARY_ROOT", "MY_WORLD_TEST_GAMES_ROOT", "MY_WORLD_TEST_CREATION_ROOT", "MY_WORLD_TEST_SETTINGS_PATH"]:
		OS.set_environment(key, "")


func _timing_ordered(timing: Dictionary, names: Array[String]) -> bool:
	var previous := -1
	for name: String in names:
		if not timing.has(name) or int(timing[name]) < previous:
			return false
		previous = int(timing[name])
	return true


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-08B REAL PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-08B REAL FAIL | %s" % label)


func _finish() -> void:
	_write_evidence()
	print("G4-08B REAL | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
