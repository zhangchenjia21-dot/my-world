extends SceneTree

## G4-11P1 双族现实准备验证：真实 main.tscn、真实当前所选 Provider、同一任务拥有的
## Source/Game Library。验证 A→B→A 切换、Save/reopen/Continue、精确 Source 祖先与上下文隔离。
## 仅记录安全 profile 元数据、hash、计数和短叙事摘录；不记录 credential 或完整 Provider payload。

const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")
const SourceLibrary := preload("res://src/source/L3_外交层/Source库公开接口.gd")
const ModelSettings := preload("res://src/运行时设置/L3_外交层/模型运行时设置公开接口.gd")
const ProviderStub := preload("res://tests/g4_07a/首次开场桩适配器.gd")

const HAN_WORLD_PATH := "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定"
const HAN_PLAYER_PATH := "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/刘备"
const FANTASY_WORLD_PATH := "res://tests/fixtures/g4_02r1/full_fidelity/诸界余辉/埃瑟维亚"
const FANTASY_PLAYER_PATH := "res://tests/fixtures/g4_02r1/full_fidelity/诸界余辉/莉维娅"

const HAN_MARKER := "G411_NEW_HAN_CURRENT_MUST_NOT_ENTER_GAME"
const FANTASY_MARKER := "G411_NEW_FANTASY_CURRENT_MUST_NOT_ENTER_GAME"

var _failures := 0
var _fixture := Fixture.new()
var _task_root := ""
var _evidence_path := ""
var _source_root := ""
var _shell: Variant = null
var _profile: Dictionary = {}
var _families: Dictionary = {}
var _switch_sequence: Array = []
var _source_updates: Dictionary = {}
var _started_at := 0
var _offline_stub := false
var _view_stub: Node = null


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_started_at = Time.get_ticks_msec()
	_task_root = _argument("--root=")
	_evidence_path = _argument("--evidence=")
	_offline_stub = OS.get_cmdline_user_args().has("--offline-stub")
	if _task_root.find("g411") < 0 or _evidence_path.is_empty():
		_fail("必须提供 task-owned g411 --root 与 --evidence")
		return _finish()
	_fixture.reset_directory(_task_root)
	_source_root = _task_root.path_join("source-library")
	var installed: Dictionary = _fixture.install_real_assets(_source_root)
	_check(installed.success, "两族 full-fidelity Source 通过 production Source Library 安装")
	if not installed.success:
		return _finish()
	var profile_result: Dictionary = ModelSettings.new().request_snapshot()
	_check(profile_result.success, "当前 Owner runtime model settings 可只读解析")
	if not profile_result.success:
		return _finish()
	_profile = _safe_profile(profile_result.request_profile)
	var credential_env := String((profile_result.request_profile as Dictionary).credential_env)
	_check(_offline_stub or not OS.get_environment(credential_env).strip_edges().is_empty(), "当前所选 Provider credential 可用，或显式离线桩模式")
	if not _offline_stub and OS.get_environment(credential_env).strip_edges().is_empty():
		return _finish()

	_set_task_roots()
	_shell = load("res://src/main.tscn").instantiate()
	root.add_child(_shell)
	await _settle(5)
	_check(_shell.application_state == _shell.ApplicationState.MENU_READY, "同一 Host 启动到 Main Menu")

	var han_created := await _create_and_play_family({
		"key": "A",
		"world_choice": "world_han_end_unsettled_realm",
		"entry_choice": "entry_t0-208-red-cliffs-eve",
		"player_choice": "character_han_end_liu_bei",
		"display_name": "G4-11P1 汉末三国现实",
		"supplement": "从赤壁前夕的军政压力与刘备当前处境自然开始。",
		"prompts": ["我先请近臣简报江面与营中刚收到的消息。", "我追问此刻最急迫、又不能贸然决定的一件事。"],
		"expected": ["world.han_end.unsettled_realm", "character.han_end.liu_bei", "t0-208-red-cliffs-eve", "e208-snapshot", "han-208", "刘备"],
		"forbidden": ["world.ashtervia.afterglow", "character.ashtervia.livia_selan", "t0-1287-ovista", "莉维娅", "奥维斯塔", FANTASY_MARKER],
	})
	if not han_created:
		return _finish()

	var fantasy_created := await _create_and_play_family({
		"key": "B",
		"world_choice": "world_ashtervia_afterglow",
		"entry_choice": "entry_t0-1287-ovista",
		"player_choice": "character_ashtervia_livia_selan",
		"display_name": "G4-11P1 诸界余辉现实",
		"supplement": "从奥维斯塔当下的日常压力与莉维娅的职业处境自然开始。",
		"prompts": ["我整理随身记录，确认今天最需要亲自处理的事务。", "我去观察现场，并先向最熟悉情况的人询问细节。"],
		"expected": ["world.ashtervia.afterglow", "character.ashtervia.livia_selan", "t0-1287-ovista", "livia-1287", "莉维娅", "奥维斯塔"],
		"forbidden": ["world.han_end.unsettled_realm", "character.han_end.liu_bei", "t0-208-red-cliffs-eve", "刘备", "赤壁", HAN_MARKER],
	})
	if not fantasy_created:
		return _finish()

	_check(String((_families.A as Dictionary).game_id) != String((_families.B as Dictionary).game_id), "A/B Game IDs 独立")
	_check(String((_families.A as Dictionary).database_path) != String((_families.B as Dictionary).database_path), "A/B SQLite paths 独立")
	_check(FileAccess.file_exists(String((_families.A as Dictionary).database_path)) and FileAccess.file_exists(String((_families.B as Dictionary).database_path)), "A/B 独立 SQLite 均存在")

	_publish_new_source_currents()
	await _reopen_continue_and_switch("A", "我重新查看先前记录，再决定下一步如何稳住局面。")
	await _reopen_continue_and_switch("B", "我对照存档中的线索，继续处理尚未收束的问题。")
	await _open_and_verify("A", false)
	_check(_switch_sequence == ["A", "B", "A", "B", "A"], "同一 Host 完成 A→B→A→B→A switch sequence")

	var final_profile_result: Dictionary = ModelSettings.new().request_snapshot()
	_check(final_profile_result.success and _safe_profile(final_profile_result.request_profile) == _profile, "全部真实请求前后保持同一 effective selected model profile")
	_finish()


func _create_and_play_family(spec: Dictionary) -> bool:
	var profile_check: Dictionary = ModelSettings.new().request_snapshot()
	_check(profile_check.success and _safe_profile(profile_check.request_profile) == _profile, "%s 建局前仍使用同一 selected profile" % String(spec.key))
	await _drive_wizard_to_review(spec)
	if _shell.new_game_wizard.step != 6 or _shell.new_game_wizard.final_create_button.disabled:
		_fail("%s exact Composition 未到达可创建 Review" % String(spec.key))
		return false
	var composition: Dictionary = _shell.new_game_wizard.composition.composition_snapshot()
	_check((composition.expansions as Array).is_empty(), "%s Expansion = none" % String(spec.key))
	var source_identity := {
		"world_asset_id": String(composition.world.identity.asset_id),
		"world_generation_fingerprint": String(composition.world.identity.generation_fingerprint),
		"character_asset_id": String(composition.player_character.identity.asset_id),
		"character_generation_fingerprint": String(composition.player_character.identity.generation_fingerprint),
		"entry_id": String(composition.entry.entry_id),
	}
	if _offline_stub:
		_shell.test_opening_adapter_override = ProviderStub.new()
	_shell.new_game_wizard.final_create_button.pressed.emit()
	await _settle(5)
	if _shell.session_runtime == null:
		_fail("%s Final Create 未打开 Game" % String(spec.key))
		return false
	var opening_started := Time.get_ticks_msec()
	if _offline_stub and _shell.opening_runtime != null:
		var opening_stub: Node = _shell.opening_runtime.provider_adapter
		opening_stub.simulate_delta("%s 离线第一幕：精确 Source 上下文已接入。" % String(spec.key))
		opening_stub.simulate_completed()
		await process_frame
	var opening_ready: bool = await _wait_for(func() -> bool:
		return _shell.session_runtime == null \
			or _shell.session_runtime.conversation.get_durable_accepted_entries().size() >= 1 \
			or _shell.opening_retry_button.visible,
		420.0)
	var accepted: Array = _accepted_entries()
	_check(opening_ready and accepted.size() == 1, "%s real Provider Opening accepted durable" % String(spec.key))
	if accepted.size() != 1:
		_fail("%s Opening 未接受；banner=%s" % [String(spec.key), String(_shell.opening_banner_label.text)])
		return false
	var opening_messages: Array = _shell.opening_runtime.last_request_messages.duplicate(true)
	var opening_serialized := JSON.stringify(opening_messages)
	_assert_context_isolation(String(spec.key), opening_serialized, spec.expected, spec.forbidden, "opening")
	var game_id := String(_shell.session_runtime.game_id)
	var database_path := String(_shell.session_runtime.database_path)
	_switch_sequence.append(String(spec.key))
	var family := {
		"game_id": game_id,
		"database_path": database_path,
		"source_identity": source_identity,
		"opening": _turn_summary(accepted[0], Time.get_ticks_msec() - opening_started, opening_serialized),
		"continuations": [],
		"save": {},
	}
	_families[String(spec.key)] = family

	for prompt: String in spec.prompts:
		var result := await _play_turn(String(spec.key), prompt, spec.expected, spec.forbidden)
		if not result.success:
			return false
		(family.continuations as Array).append(result.summary)
	var after_two: Array = _accepted_entries()
	_check(after_two.size() == 3, "%s Opening + 2 continuation 均 durable accepted" % String(spec.key))
	var save_result: Dictionary = _shell.session_runtime.create_save_point("G4-11P1 %s 双族现实存档" % String(spec.key))
	_check(save_result.success, "%s named Save 创建成功" % String(spec.key))
	var saves: Dictionary = _shell.session_runtime.list_save_points()
	_check(saves.success and (saves.save_points as Array).size() == 1, "%s Save 可由当前 Game 精确列出" % String(spec.key))
	family.save = {
		"save_id": String(save_result.get("save_id", "")),
		"display_name": String(save_result.get("display_name", "")),
		"accepted_at_save": after_two.size(),
	}
	_check(_durable_ancestry_matches(family), "%s durable Game 保留精确 World/Character generation ancestry" % String(spec.key))
	_shell.return_menu_button.pressed.emit()
	await _settle(4)
	_check(_shell.session_runtime == null and _shell.application_state == _shell.ApplicationState.MENU_READY, "%s Save 后 close/release 回到 Main Menu" % String(spec.key))
	return true


func _reopen_continue_and_switch(key: String, prompt: String) -> void:
	var family := _families[key] as Dictionary
	var opened: Dictionary = _shell.open_registered_game(String(family.game_id))
	await _settle(5)
	_check(opened.success, "%s 通过 Game Library exact reopen" % key)
	if not opened.success:
		return
	_switch_sequence.append(key)
	_check(String(_shell.session_runtime.game_id) == String(family.game_id), "%s reopen 恢复自身 Game identity" % key)
	_check(String(_shell.session_runtime.database_path) == String(family.database_path), "%s reopen 恢复自身 SQLite" % key)
	_check(_accepted_entries().size() == 3, "%s reopen 恢复 Opening + 2 continuation" % key)
	_check((_shell.session_runtime.list_save_points().save_points as Array).size() == 1, "%s reopen 恢复自身 named Save" % key)
	_check(_durable_ancestry_matches(family), "%s Source current 更新后 exact ancestry/materialized truth 不变" % key)
	var expected: Array = ["world.han_end.unsettled_realm", "character.han_end.liu_bei", "t0-208-red-cliffs-eve", "e208-snapshot", "han-208", "刘备"] if key == "A" else ["world.ashtervia.afterglow", "character.ashtervia.livia_selan", "t0-1287-ovista", "livia-1287", "莉维娅", "奥维斯塔"]
	var forbidden: Array = ["world.ashtervia.afterglow", "character.ashtervia.livia_selan", "t0-1287-ovista", "莉维娅", "奥维斯塔", FANTASY_MARKER, HAN_MARKER] if key == "A" else ["world.han_end.unsettled_realm", "character.han_end.liu_bei", "t0-208-red-cliffs-eve", "刘备", "赤壁", HAN_MARKER, FANTASY_MARKER]
	var result := await _play_turn(key, prompt, expected, forbidden)
	if result.success:
		(family.continuations as Array).append(result.summary)
	_check(_accepted_entries().size() == 4, "%s reopen 后新增 1 个 durable continuation" % key)
	_shell.return_menu_button.pressed.emit()
	await _settle(4)


func _open_and_verify(key: String, keep_open: bool) -> void:
	var family := _families[key] as Dictionary
	var opened: Dictionary = _shell.open_registered_game(String(family.game_id))
	await _settle(5)
	_check(opened.success and String(_shell.session_runtime.game_id) == String(family.game_id), "%s 最终切回仍恢复精确 Game" % key)
	if opened.success:
		_switch_sequence.append(key)
		_check(_accepted_entries().size() == 4 and _durable_ancestry_matches(family), "%s 最终切回无 Conversation/Source identity 泄漏" % key)
	if not keep_open and _shell.session_runtime != null:
		_shell.return_menu_button.pressed.emit()
		await _settle(4)


func _play_turn(key: String, prompt: String, expected: Array, forbidden: Array) -> Dictionary:
	if _offline_stub:
		_view_stub = _swap_view_stub(_shell.narrative_view)
	var target := _accepted_entries().size() + 1
	var captured: Array = []
	var capture := func(messages: Array) -> void: captured.append(messages.duplicate(true))
	_shell.narrative_view.request_messages_assembled.connect(capture, CONNECT_ONE_SHOT)
	var started := Time.get_ticks_msec()
	_shell.narrative_view.player_input.text = prompt
	_shell.narrative_view._on_send_pressed()
	if _offline_stub and _view_stub != null:
		_view_stub.simulate_delta("%s 离线续写：本次行动已沿 durable Conversation 接受。" % key)
		_view_stub.simulate_completed()
		await process_frame
	var terminal: bool = await _wait_for(func() -> bool:
		return _shell.session_runtime == null \
			or _accepted_entries().size() >= target \
			or not _shell.session_runtime.conversation.is_generating(),
		420.0)
	var accepted := _accepted_entries()
	var success := terminal and accepted.size() == target
	_check(success, "%s continuation %d real Provider accepted durable" % [key, target - 1])
	if not success:
		return {"success": false, "summary": {}}
	var messages: Array = captured[0] if not captured.is_empty() else []
	var serialized := JSON.stringify(messages)
	_assert_context_isolation(key, serialized, expected, forbidden, "continuation-%d" % (target - 1))
	return {"success": true, "summary": _turn_summary(accepted[-1], Time.get_ticks_msec() - started, serialized)}


func _publish_new_source_currents() -> void:
	var library := SourceLibrary.new(_source_root)
	_source_updates.A = _publish_family_updates(library, "han", HAN_WORLD_PATH, HAN_PLAYER_PATH, HAN_MARKER)
	_source_updates.B = _publish_family_updates(library, "fantasy", FANTASY_WORLD_PATH, FANTASY_PLAYER_PATH, FANTASY_MARKER)
	_check(bool((_source_updates.A as Dictionary).success) and bool((_source_updates.B as Dictionary).success), "task-owned 两族 Source current 均发布 bounded second generation")


func _publish_family_updates(library: RefCounted, name: String, world_path: String, player_path: String, marker: String) -> Dictionary:
	var base := _task_root.path_join("updates").path_join(name)
	var world_clone := base.path_join("world")
	var player_clone := base.path_join("player")
	_fixture.copy_package(world_path, world_clone)
	_fixture.copy_package(player_path, player_clone)
	var world_json := _fixture.read_json(world_clone.path_join("source.json"))
	world_json.version = "%s-g411-newer" % String(world_json.version)
	world_json.catalog_summary = marker
	_fixture.write_json(world_clone.path_join("source.json"), world_json)
	var player_json := _fixture.read_json(player_clone.path_join("source.json"))
	player_json.version = "%s-g411-newer" % String(player_json.version)
	player_json.catalog_summary = marker
	_fixture.write_json(player_clone.path_join("source.json"), player_json)
	var world_result: Dictionary = library.install_world_pack(world_clone)
	var player_result: Dictionary = library.install_character_card(player_clone)
	return {
		"success": world_result.success and player_result.success,
		"world_new_fingerprint": String(world_result.generation.identity.generation_fingerprint) if world_result.success else "",
		"character_new_fingerprint": String(player_result.generation.identity.generation_fingerprint) if player_result.success else "",
	}


func _durable_ancestry_matches(family: Dictionary) -> bool:
	if _shell.session_runtime == null:
		return false
	var identity := family.source_identity as Dictionary
	var state := _shell.session_runtime.world_state as Dictionary
	return String(state.world.provenance.asset_id) == String(identity.world_asset_id) \
		and String(state.world.provenance.generation_fingerprint) == String(identity.world_generation_fingerprint) \
		and String(state.player_character.provenance.asset_id) == String(identity.character_asset_id) \
		and String(state.player_character.provenance.generation_fingerprint) == String(identity.character_generation_fingerprint) \
		and String(state.selected_entry_id) == String(identity.entry_id)


func _assert_context_isolation(key: String, serialized: String, expected: Array, forbidden: Array, stage: String) -> void:
	var expected_ok := true
	for marker: String in expected:
		expected_ok = expected_ok and serialized.contains(marker)
	var forbidden_ok := true
	for marker: String in forbidden:
		forbidden_ok = forbidden_ok and not serialized.contains(marker)
	_check(expected_ok, "%s %s context 包含 exact selected family identity/T0" % [key, stage])
	_check(forbidden_ok, "%s %s context 无对族/新 current 泄漏" % [key, stage])


func _drive_wizard_to_review(spec: Dictionary) -> void:
	_shell.new_game_button.pressed.emit()
	await _settle(4)
	var wizard: Variant = _shell.new_game_wizard
	_press_choice(wizard, String(spec.world_choice))
	wizard.next_button.pressed.emit()
	await _settle(2)
	_press_choice(wizard, String(spec.entry_choice))
	wizard.next_button.pressed.emit()
	await _settle(2)
	_press_choice(wizard, "expansion_none")
	wizard.next_button.pressed.emit()
	await _settle(2)
	_press_choice(wizard, String(spec.player_choice))
	wizard.next_button.pressed.emit()
	await _settle(2)
	# G4-11 固定不添加 Guaranteed NPC，避免引入 G5 或额外比较变量。
	wizard.next_button.pressed.emit()
	await _settle(2)
	wizard.display_name_input.text = String(spec.display_name)
	wizard.display_name_input.text_changed.emit(String(spec.display_name))
	wizard.supplement_input.text = String(spec.supplement)
	wizard.next_button.pressed.emit()
	await _settle(4)


func _press_choice(wizard: Variant, name_fragment: String) -> void:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(name_fragment) >= 0:
			button.pressed.emit()
			return
	_fail("choice not found: %s" % name_fragment)


func _set_task_roots() -> void:
	OS.set_environment("MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", _source_root)
	OS.set_environment("MY_WORLD_TEST_CURRENT_GAME_DB", _task_root.path_join("legacy-current.sqlite"))
	OS.set_environment("MY_WORLD_TEST_GAME_LIBRARY_ROOT", _task_root.path_join("game-library"))
	OS.set_environment("MY_WORLD_TEST_GAMES_ROOT", _task_root.path_join("games"))
	OS.set_environment("MY_WORLD_TEST_CREATION_ROOT", _task_root.path_join("creation"))


func _swap_view_stub(view: Variant) -> Node:
	var stub: Node = ProviderStub.new()
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


func _safe_profile(profile: Dictionary) -> Dictionary:
	return {
		"profile_id": String(profile.profile_id),
		"provider_id": String(profile.provider_id),
		"model_id": String(profile.model_id),
		"context_limit": String(profile.context_limit),
		"reasoning_requested": String(profile.reasoning_requested),
		"reasoning_effective": profile.reasoning_effective,
	}


func _turn_summary(turn: Dictionary, duration_ms: int, request_serialized: String) -> Dictionary:
	var gm_text := String(turn.gm_text)
	return {
		"duration_ms": duration_ms,
		"request_sha256": request_serialized.sha256_text(),
		"response_chars": gm_text.length(),
		"response_sha256": gm_text.sha256_text(),
		"excerpt": gm_text.left(240),
	}


func _accepted_entries() -> Array:
	if _shell == null or _shell.session_runtime == null:
		return []
	return _shell.session_runtime.conversation.get_durable_accepted_entries()


func _wait_for(condition: Callable, timeout_sec: float) -> bool:
	var deadline := Time.get_ticks_msec() + int(timeout_sec * 1000.0)
	while Time.get_ticks_msec() < deadline:
		if condition.call():
			return true
		await process_frame
	return condition.call()


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
		print("G4-11P1 PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-11P1 FAIL | %s" % label)


func _write_evidence() -> void:
	var evidence := {
		"task": "G4-11P1",
		"generated_at": Time.get_datetime_string_from_system(true),
		"duration_ms": Time.get_ticks_msec() - _started_at,
		"failures": _failures,
		"provider_mode": "offline_stub" if _offline_stub else "real_selected_provider",
		"effective_profile": _profile,
		"families": _families,
		"switch_sequence": _switch_sequence,
		"source_updates": _source_updates,
	}
	var file := FileAccess.open(_evidence_path, FileAccess.WRITE)
	if file == null:
		_fail("无法写入 task-owned evidence JSON")
		return
	file.store_string(JSON.stringify(evidence, "  ") + "\n")
	file.close()


func _clear_environment() -> void:
	for key: String in ["MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", "MY_WORLD_TEST_CURRENT_GAME_DB", "MY_WORLD_TEST_GAME_LIBRARY_ROOT", "MY_WORLD_TEST_GAMES_ROOT", "MY_WORLD_TEST_CREATION_ROOT"]:
		OS.set_environment(key, "")


func _finish() -> void:
	if _shell != null:
		_shell._close_game_session()
		_shell.queue_free()
	_write_evidence()
	_clear_environment()
	print("G4-11P1 | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
