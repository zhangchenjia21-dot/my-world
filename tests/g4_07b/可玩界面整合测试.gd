extends SceneTree

## G4-07B Playable UI Integration —— headless 真实 main.tscn Shell + stub Provider 的可玩垂直整合测试。
## 覆盖 UI_STATE_FAILURE_MATRIX 的自动化案例：
##   创建幂等（双击/失败重试/payload 变更）→ existing-only open → 第一幕 streaming/失败/取消/重试
##   → accepted 后不二次开场 → 玩家行动走 durable continuation → save/exit/reopen/Continue。
## Provider 全部走桩；真实 DeepSeek 垂直由 tests/g4_07b/真实可玩垂直测试.gd 证明。

const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")
const OpeningStub := preload("res://tests/g4_07a/首次开场桩适配器.gd")
const ViewStub := preload("res://tests/g2_03_桩适配器.gd")

var _failures := 0
var _fixture := Fixture.new()
var _root := ""
var _source_root := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("g4_07b") < 0:
		_fail("必须提供 task-owned g4_07b root")
		return _finish()
	_fixture.reset_directory(_root)
	_source_root = _root.path_join("source-library")
	var installed: Dictionary = _fixture.install_real_assets(_source_root)
	_check(installed.success, "frozen v0.2 full-fidelity packages installed for playable UI")
	if not installed.success:
		return _finish()
	await _test_han_playable_vertical()
	await _test_create_retry_identity()
	await _test_opening_failure_and_retry()
	await _test_opening_cancel_and_retry()
	await _test_exit_before_opening_continue_resumes()
	await _test_no_entry_opening()
	_clear_environment()
	_finish()


## A/B/E/G/I/K：完整可玩垂直 —— 创建（含双击幂等）→ 自动 existing-only open → 第一幕 → 玩家行动
## → durable continuation → save → 返回主菜单 → Continue → 无二次开场 → 无空玩家气泡。
func _test_han_playable_vertical() -> void:
	var case_root := _case_root("han-vertical")
	var shell: Variant = await _boot_shell(case_root)
	var captured_ids: Array = []
	shell.new_game_wizard.final_create_requested.connect(func(creation_id: String, _payload: Dictionary) -> void: captured_ids.append(creation_id))
	await _drive_wizard_to_review(shell, "entry_t0-208-red-cliffs-eve", "character_han_end_liu_bei", ["npc_character_han_end_sun_quan"], "赤壁可玩垂直", "从江夏的雨夜开始。")
	var wizard: Variant = shell.new_game_wizard
	_check(wizard.step == 6 and not wizard.final_create_button.disabled, "valid Review enables Final Create")

	shell.test_opening_adapter_override = OpeningStub.new()
	var opening_stub: Node = shell.test_opening_adapter_override
	# 双击/重复点击同一 frozen Review：必须收敛到同一 creation_id 与同一 Game。
	wizard.final_create_button.pressed.emit()
	wizard.final_create_button.pressed.emit()
	await _settle(6)
	_check(captured_ids.size() == 1, "double submit reuses one stable creation_id")
	_check(shell.application_state == shell.ApplicationState.GAME_ACTIVE and shell.session_runtime != null and shell.session_runtime.is_ready(), "create success ends Wizard path and opens the exact Game")
	var listed: Dictionary = shell.game_library.list_games()
	_check(listed.success and listed.games.size() == 1, "double submit creates exactly one Game in Library")
	var game_id := String(shell.session_runtime.game_id)
	_check(String(shell.active_game_record.game_id) == game_id, "opened Game is the created Game identity")

	_check(shell.opening_runtime != null and shell.opening_banner.visible and shell.opening_cancel_button.visible, "created Game auto-starts first Opening with visible streaming banner")
	_check(not shell.narrative_view.player_input.editable and shell.narrative_view.send_button.disabled, "opening-pending locks Player input until accepted")
	_check(opening_stub.requests.size() == 1 and opening_stub.requests[0].size() == 1 and String(opening_stub.requests[0][0].role) == "system", "first Opening request is a single GM-only system message")
	var serialized := JSON.stringify(opening_stub.requests[0])
	_check(serialized.contains("e208-snapshot") and serialized.contains("t0-208-red-cliffs-eve") and serialized.contains("孙权"), "Opening context carries exact durable Entry/profile/canonical cast")
	_check(not serialized.contains("fingerprint") and shell.opening_banner_label.text.find("fingerprint") < 0, "player-facing Opening UI carries no fingerprint/internal ids")

	opening_stub.simulate_delta("江夏的雨落在檐瓦上。")
	opening_stub.simulate_delta("军帐之外，江风带来尚未定局的消息。")
	opening_stub.simulate_completed()
	await _settle(4)
	_check(shell.session_runtime.conversation.get_durable_accepted_entries().size() == 1, "Opening accepted durable exactly once")
	_check(not shell.opening_banner.visible and shell.narrative_view.player_input.editable, "accepted Opening hides banner and unlocks Player input")
	_check(opening_stub.requests.size() == 1, "accepted Game does not auto-generate a second first Opening")
	_check(not shell.narrative_view.regenerate_button.visible, "GM-only Opening turn never shows player-side Regenerate")

	# 玩家第一条行动：必须经由 G4-07A durable continuation（Game-local World + durable Conversation）。
	var view_stub := _swap_view_stub(shell.narrative_view)
	shell.narrative_view.player_input.text = "我走出军帐查看江面。"
	shell.narrative_view._on_send_pressed()
	await _settle(3)
	_check(view_stub.start_calls.size() == 1, "first Player action issues exactly one Provider request")
	var roles: Array = []
	for message: Dictionary in view_stub.start_calls[0]:
		roles.append(String(message.role))
	_check(roles == ["system", "assistant", "user"], "continuation roles are system/assistant/user with durable Opening")
	var continuation := JSON.stringify(view_stub.start_calls[0])
	_check(continuation.contains("e208-snapshot") and continuation.contains("江夏的雨落在檐瓦上") and continuation.contains("我走出军帐查看江面"), "continuation rebuilds from durable World truth plus durable Conversation")
	view_stub.text_delta.emit("你掀开帐帘，江面雾气沉沉。")
	view_stub.simulate_completed()
	await _settle(4)
	_check(shell.session_runtime.conversation.get_durable_accepted_entries().size() == 2, "Player turn accepted durable after Opening")
	_check(shell.narrative_view.regenerate_button.visible, "normal Player turn keeps Regenerate available")

	# Save / 返回主菜单 / Continue：同一 Game、durable history 恢复、绝不二次开场。
	shell.save_name_input.text = "雨夜之后"
	shell._on_create_save_pressed()
	await _settle(3)
	_check(shell.save_selector.item_count == 1, "Save point created on the same Game")
	shell.return_menu_button.pressed.emit()
	await _settle(4)
	_check(shell.session_runtime == null and shell.main_menu_surface.visible, "Return to Main Menu closes the Game Session")
	shell.test_opening_adapter_override = OpeningStub.new()
	shell.continue_button.pressed.emit()
	await _settle(6)
	_check(shell.session_runtime != null and String(shell.session_runtime.game_id) == game_id, "Continue reopens the exact same Game")
	_check(shell.session_runtime.conversation.get_durable_accepted_entries().size() == 2, "Continue restores durable Conversation history")
	_check(shell.test_opening_adapter_override.requests.is_empty() and not shell.opening_banner.visible, "accepted Game never auto-generates a second first Opening after Continue")
	_check(shell.narrative_view.player_input.editable, "Continue with accepted history leaves Player input unlocked")
	_check(_count_headers(shell.narrative_view, "你的行动") == 1 and _count_headers(shell.narrative_view, "GM · 开场") == 1, "restored view renders one real Player action and one Opening header without empty bubble")
	await _shutdown_shell(shell)


## C/D/F：创建失败重试保持 creation_id；payload 变更后才换 attempt；成功后 Wizard 锁定。
func _test_create_retry_identity() -> void:
	var case_root := _case_root("create-retry")
	var shell: Variant = await _boot_shell(case_root)
	var captured_ids: Array = []
	shell.new_game_wizard.final_create_requested.connect(func(creation_id: String, _payload: Dictionary) -> void: captured_ids.append(creation_id))
	await _drive_wizard_to_review(shell, "entry_t0-208-red-cliffs-eve", "character_han_end_liu_bei", [], "创建重试身份", "先制造一次失败。")
	var wizard: Variant = shell.new_game_wizard

	# 把 Shell 侧 Source Library root 暂时指向不存在的 path，使 Final Create 的
	# exact pin 复核失败；Game 不得创建。Wizard 内存 inventory 不受影响。
	OS.set_environment("MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", case_root.path_join("missing-source-library"))
	wizard.final_create_button.pressed.emit()
	await _settle(4)
	_check(wizard.final_create_button.text == "重试创建" and not wizard.final_create_button.disabled, "create failure returns Review with plain retry state")
	_check(wizard.result_label.text.find("fingerprint") < 0 and wizard.result_label.text.find("creation") < 0, "create failure message is player-facing without internal ids")
	_check(shell.session_runtime == null and shell.game_library.list_games().games.is_empty(), "failed create leaves zero Games")
	OS.set_environment("MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", _source_root)

	wizard.final_create_button.pressed.emit()
	await _settle(4)
	_check(captured_ids.size() == 2 and captured_ids[0] == captured_ids[1], "retry after failure reuses the same creation_id")
	_check(shell.application_state == shell.ApplicationState.GAME_ACTIVE, "retry after restore creates and opens the Game")
	_check(shell.game_library.list_games().games.size() == 1, "retry converges to exactly one Game")
	var first_game_id := String(shell.session_runtime.game_id)

	# 已创建后再次点击（锁定）与 payload 变更后的新 attempt 身份。
	wizard.final_create_button.pressed.emit()
	await _settle(2)
	_check(captured_ids.size() == 2, "completed Wizard locks the create path")
	shell.test_opening_adapter_override = OpeningStub.new()
	shell._close_game_session()
	shell._show_main_menu()
	await _settle(3)
	await _drive_wizard_to_review(shell, "entry_t0-208-red-cliffs-eve", "character_han_end_liu_bei", [], "创建重试身份-改", "换一个开场补充。")
	shell.test_opening_adapter_override = OpeningStub.new()
	shell.new_game_wizard.final_create_button.pressed.emit()
	await _settle(6)
	_check(captured_ids.size() == 3 and captured_ids[2] != captured_ids[0], "changed payload after edit starts a new create attempt identity")
	_check(shell.game_library.list_games().games.size() == 2 and String(shell.session_runtime.game_id) != first_game_id, "new attempt identity converges to its own Game")
	await _shutdown_shell(shell)


## H/L：Opening 失败 —— banner 可重试、零 accepted、Game 保留、重试成功。
func _test_opening_failure_and_retry() -> void:
	var case_root := _case_root("opening-failure")
	var shell: Variant = await _boot_shell_with_created_game(case_root, "第一幕失败重试", "entry_t0-208-red-cliffs-eve")
	if shell == null:
		return
	var opening_stub: Node = shell.test_opening_adapter_override
	opening_stub.simulate_delta("不得接受的 partial")
	opening_stub.simulate_failed("transport")
	await _settle(4)
	_check(shell.session_runtime != null and shell.session_runtime.conversation.get_durable_accepted_entries().is_empty(), "Opening failure leaves zero accepted Opening")
	_check(shell.opening_banner.visible and shell.opening_retry_button.visible and not shell.opening_cancel_button.visible, "Opening failure shows retry banner without cancel")
	_check(shell.opening_banner_label.text.find("transport") < 0 and shell.opening_banner_label.text.find("未完成") >= 0, "Opening failure banner is player-facing without raw codes")
	_check(not shell.narrative_view.player_input.editable, "failed Opening keeps Player input locked until accepted")
	var game_id := String(shell.session_runtime.game_id)

	shell.opening_retry_button.pressed.emit()
	await _settle(3)
	_check(opening_stub.requests.size() == 2, "retry issues a new first-Opening request for the same Game")
	opening_stub.simulate_delta("重试后唯一接受的第一幕。")
	opening_stub.simulate_completed()
	await _settle(4)
	_check(String(shell.session_runtime.game_id) == game_id and shell.session_runtime.conversation.get_durable_accepted_entries().size() == 1, "retry accepts exactly one Opening on the same Game")
	_check(not shell.opening_banner.visible and shell.narrative_view.player_input.editable, "accepted retry clears banner and unlocks input")
	await _shutdown_shell(shell)


## H/N：Opening 取消 —— 玩家主动取消保留 Game，可干净重试。
func _test_opening_cancel_and_retry() -> void:
	var case_root := _case_root("opening-cancel")
	var shell: Variant = await _boot_shell_with_created_game(case_root, "第一幕取消重试", "entry_t0-208-red-cliffs-eve")
	if shell == null:
		return
	var opening_stub: Node = shell.test_opening_adapter_override
	opening_stub.simulate_delta("取消前的 partial")
	shell.opening_cancel_button.pressed.emit()
	await _settle(4)
	_check(shell.session_runtime != null and shell.session_runtime.conversation.get_durable_accepted_entries().is_empty(), "Opening cancel leaves zero accepted Opening and keeps the Game")
	_check(shell.opening_banner.visible and shell.opening_retry_button.visible and shell.opening_banner_label.text.find("取消") >= 0, "cancel banner offers retry in player language")
	shell.opening_retry_button.pressed.emit()
	await _settle(3)
	opening_stub.simulate_delta("取消后重试接受的第一幕。")
	opening_stub.simulate_completed()
	await _settle(4)
	_check(shell.session_runtime.conversation.get_durable_accepted_entries().size() == 1, "cancel retry accepts exactly once")
	await _shutdown_shell(shell)


## J：创建成功但第一幕未 accepted 就退出 → Continue 回到同一 Game 并重新尝试第一幕。
func _test_exit_before_opening_continue_resumes() -> void:
	var case_root := _case_root("exit-before-opening")
	var shell: Variant = await _boot_shell_with_created_game(case_root, "退出后续玩", "entry_t0-208-red-cliffs-eve")
	if shell == null:
		return
	var first_stub: Node = shell.test_opening_adapter_override
	first_stub.simulate_delta("退出前的 partial")
	var game_id := String(shell.session_runtime.game_id)
	# 模拟 App 退出：正式 close session（未 accepted partial 随之取消），随后整个 Shell 重建。
	shell._close_game_session()
	await _settle(3)
	shell.queue_free()
	await process_frame

	var shell2: Variant = await _boot_shell(case_root)
	shell2.test_opening_adapter_override = OpeningStub.new()
	shell2.continue_button.pressed.emit()
	await _settle(6)
	_check(shell2.session_runtime != null and String(shell2.session_runtime.game_id) == game_id, "Continue after exit reopens the exact same created Game")
	_check(shell2.session_runtime.conversation.get_durable_accepted_entries().is_empty(), "exit before acceptance preserves legal opening-pending state")
	var second_stub: Node = shell2.test_opening_adapter_override
	_check(second_stub.requests.size() == 1 and shell2.opening_banner.visible, "Continue retries the first Opening on the same Game")
	second_stub.simulate_delta("重开进程后唯一接受的第一幕。")
	second_stub.simulate_completed()
	await _settle(4)
	_check(shell2.session_runtime.conversation.get_durable_accepted_entries().size() == 1, "resumed Opening accepts exactly once")
	await _shutdown_shell(shell2)


## M/O：无 Entry 路由 —— 不得注入隐藏默认 Entry/profile/year。
func _test_no_entry_opening() -> void:
	var case_root := _case_root("no-entry")
	var shell: Variant = await _boot_shell_with_created_game(case_root, "无开局垂直", "")
	if shell == null:
		return
	_check(shell.session_runtime.world_state.selected_entry_id == null, "durable no-Entry stays explicit null in UI-opened Game")
	var opening_stub: Node = shell.test_opening_adapter_override
	var serialized := JSON.stringify(opening_stub.requests[0])
	_check(serialized.contains("Selected Entry: none") and serialized.contains("Exact selected profile: none"), "no-Entry Opening keeps explicit none semantics")
	_check(not serialized.contains("t0-208-red-cliffs-eve") and not serialized.contains("han-208"), "UI path never infers a hidden default Entry/profile")
	opening_stub.simulate_delta("没有预设年代替玩家作出选择。")
	opening_stub.simulate_completed()
	await _settle(4)
	_check(shell.session_runtime.conversation.get_durable_accepted_entries().size() == 1, "no-Entry Opening accepts normally")
	await _shutdown_shell(shell)


## ---- 驱动辅助 ----

func _case_root(name: String) -> String:
	var path := _root.path_join(name)
	DirAccess.make_dir_recursive_absolute(path)
	return path


func _set_environment(case_root: String) -> void:
	OS.set_environment("MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", _source_root)
	OS.set_environment("MY_WORLD_TEST_CURRENT_GAME_DB", case_root.path_join("current-game.sqlite"))
	OS.set_environment("MY_WORLD_TEST_GAME_LIBRARY_ROOT", case_root.path_join("game-library"))
	OS.set_environment("MY_WORLD_TEST_GAMES_ROOT", case_root.path_join("games"))
	OS.set_environment("MY_WORLD_TEST_CREATION_ROOT", case_root.path_join("creation"))


func _clear_environment() -> void:
	for key: String in ["MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", "MY_WORLD_TEST_CURRENT_GAME_DB", "MY_WORLD_TEST_GAME_LIBRARY_ROOT", "MY_WORLD_TEST_GAMES_ROOT", "MY_WORLD_TEST_CREATION_ROOT"]:
		OS.set_environment(key, "")


func _boot_shell(case_root: String) -> Variant:
	_set_environment(case_root)
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await _settle(3)
	_check(shell.application_state == shell.ApplicationState.MENU_READY, "shell boots to Main Menu")
	return shell


## 走完真实 Wizard 到 Review；entry_fragment 为空表示不指定开局。
func _drive_wizard_to_review(shell: Variant, entry_fragment: String, player_fragment: String, npc_fragments: Array, display_name: String, supplement: String) -> void:
	shell.new_game_button.pressed.emit()
	await _settle(4)
	var wizard: Variant = shell.new_game_wizard
	_press_choice(wizard, "world_han_end_unsettled_realm")
	wizard.next_button.pressed.emit()
	await _settle(2)
	if not entry_fragment.is_empty():
		_press_choice(wizard, entry_fragment)
	else:
		_press_choice(wizard, "entry_none")
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


## 创建一局并停在第一幕 streaming；返回 shell，失败返回 null。
func _boot_shell_with_created_game(case_root: String, display_name: String, entry_fragment: String) -> Variant:
	var shell: Variant = await _boot_shell(case_root)
	await _drive_wizard_to_review(shell, entry_fragment, "character_han_end_liu_bei", [], display_name, "")
	shell.test_opening_adapter_override = OpeningStub.new()
	shell.new_game_wizard.final_create_button.pressed.emit()
	await _settle(6)
	if shell.session_runtime == null or not shell.session_runtime.is_ready():
		_fail("created Game did not open: %s" % display_name)
		return null
	if shell.opening_banner == null or not shell.opening_banner.visible:
		_fail("first Opening did not start streaming: %s" % display_name)
		return null
	return shell


## 玩家 turn 使用 View 自有 adapter；focused 测试换成 g2 桩，接线与 production 完全一致。
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


func _count_headers(view: Variant, header_text: String) -> int:
	var count := 0
	for box: Node in view.entries.get_children():
		for child: Node in box.get_children():
			var labels: Array = [child]
			for nested: Node in child.get_children():
				labels.append(nested)
			for label_value: Node in labels:
				if label_value is Label and String((label_value as Label).text) == header_text:
					count += 1
	return count


func _press_choice(wizard: Variant, name_fragment: String) -> void:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(name_fragment) >= 0:
			button.pressed.emit()
			return
	_fail("choice not found: %s among %s" % [name_fragment, wizard.choice_buttons.map(func(button: Button) -> String: return String(button.name))])


func _toggle_choice(wizard: Variant, name_fragment: String, selected: bool) -> void:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(name_fragment) >= 0:
			button.button_pressed = selected
			button.toggled.emit(selected)
			return
	_fail("toggle not found: %s" % name_fragment)


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
		print("G4-07B UI PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-07B UI FAIL | %s" % label)


func _finish() -> void:
	print("G4-07B UI | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
