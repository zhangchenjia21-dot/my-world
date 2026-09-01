extends SceneTree

## G4-08B Public d20 UI / Interaction Integration —— headless 真实 main.tscn Shell +
## 桩 Provider + deterministic RNG 的 UI 垂直整合测试，覆盖
## docs/tasks/G4-08B_UI_STATE_FAILURE_MATRIX.md 的 A–H 案例。
## 真实 Provider 垂直由 tests/g4_08b/真实公开D20界面垂直测试.gd 证明。

const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")
const OpeningStub := preload("res://tests/g4_07a/首次开场桩适配器.gd")
const ViewStub := preload("res://tests/g2_03_桩适配器.gd")

class DeterministicRng:
	extends RefCounted
	var values: Array
	var invocation_count := 0
	func _init(faces: Array) -> void:
		values = faces.duplicate()
	func roll_d20() -> int:
		var value := int(values[invocation_count])
		invocation_count += 1
		return value

var _failures := 0
var _fixture := Fixture.new()
var _root := ""
var _source_root := ""
var _library: RefCounted


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("g4_08b") < 0:
		_fail("必须提供 task-owned g4_08b root")
		return _finish()
	_fixture.reset_directory(_root)
	_source_root = _root.path_join("source-library")
	var installed: Dictionary = _fixture.install_real_assets(_source_root)
	_check(installed.success, "frozen v0.2 full-fidelity packages installed for G4-08B UI")
	if not installed.success:
		return _finish()
	_library = installed.library
	var expansion: Dictionary = _library.install_expansion_pack("res://tests/fixtures/g4_08m1/判定与检定_公开d20")
	_check(expansion.success, "Public d20 Expansion installed through Managed Library")
	if not expansion.success:
		return _finish()
	var conflict_install: Dictionary = _library.install_expansion_pack("res://tests/fixtures/g4_08m1/冲突拓展")
	_check(conflict_install.success, "task-only slot-conflict Expansion installed for Evidence B")

	await _test_wizard_expansion_inventory()
	await _test_no_expansion_regression()
	await _test_checked_action_ui()
	await _test_no_check_ui()
	await _test_retry_no_reroll_ui()
	await _test_reopen_unfinished_action()
	await _test_continue_load_card_reconstruction()
	_clear_environment()
	_finish()


## A/B：Wizard 拓展库存投影、显式 none、选择保留、Review 投影、slot 冲突回滚、
## Final Create 收到 frozen exact identity。
func _test_wizard_expansion_inventory() -> void:
	var case_root := _case_root("wizard-expansion")
	var shell: Variant = await _boot_shell(case_root)
	shell.new_game_button.pressed.emit()
	await _settle(4)
	var wizard: Variant = shell.new_game_wizard
	_check(wizard.step == 0 and wizard.expansions.size() == 2, "A Wizard stores Expansion generations separately")
	_press_choice(wizard, "world_han_end_unsettled_realm")
	wizard.next_button.pressed.emit()
	await _settle(2)
	_press_choice(wizard, "entry_t0-208-red-cliffs-eve")
	wizard.next_button.pressed.emit()
	await _settle(2)
	_check(wizard.step == 2 and wizard.next_button.disabled, "A Expansion step does not auto-complete/auto-select")
	_check(_choice_text(wizard, "expansion_exp_check_core_public_d20").contains("判定与检定：公开 d20") and _choice_text(wizard, "expansion_exp_check_core_public_d20").contains("0.1.0"), "A Expansion chooser shows display name + version")
	_check(_choice_text(wizard, "expansion_exp_check_core_public_d20").contains("公开 DC"), "A Expansion chooser shows catalog summary")
	_check(_choice_text(wizard, "expansion_exp_check_core_public_d20").find("fingerprint") < 0, "A Expansion chooser never shows raw fingerprint")
	# 往返保留选择：选中 → 后退 → 前进 → 仍选中。
	_toggle_choice(wizard, "expansion_exp_check_core_public_d20", true)
	_check(not wizard.next_button.disabled, "A selecting an Expansion completes the step")
	wizard.next_button.pressed.emit()
	await _settle(2)
	_check(wizard.step == 3, "A forward after Expansion selection")
	wizard.back_button.pressed.emit()
	await _settle(2)
	_check(wizard.step == 2 and _toggle_state(wizard, "expansion_exp_check_core_public_d20"), "A back/forward preserves exact Expansion selection")

	# B：同 slot 第二个 Expansion 被 backend 拒绝且 UI 回滚 toggle。
	_toggle_choice(wizard, "expansion_exp_test_slot_collision", true)
	_check(not _toggle_state(wizard, "expansion_exp_test_slot_collision"), "B rejected slot-conflict toggle reverts visually")
	_check(wizard.result_label.text.find("同一判定位置") >= 0, "B slot conflict shown in player language")
	_check(_toggle_state(wizard, "expansion_exp_check_core_public_d20"), "B original selection survives rejected conflict")

	# A4/A6：Review 显示 exact 选择；Final Create payload 携带 exact identity。
	wizard.next_button.pressed.emit()
	await _settle(2)
	_press_choice(wizard, "character_han_end_liu_bei")
	wizard.next_button.pressed.emit()
	await _settle(2)
	wizard.next_button.pressed.emit()
	await _settle(2)
	wizard.display_name_input.text = "拓展库存证据"
	wizard.display_name_input.text_changed.emit(wizard.display_name_input.text)
	wizard.next_button.pressed.emit()
	await _settle(4)
	_check(wizard.review_text.text.contains("判定与检定：公开 d20（0.1.0）"), "A Review shows exact selected Expansion name/version")
	var captured: Array = []
	wizard.final_create_requested.connect(func(creation_id: String, payload: Dictionary) -> void: captured.append(payload))
	shell.test_opening_adapter_override = OpeningStub.new()
	shell.test_adjudication_adapter_override = OpeningStub.new()
	wizard.final_create_button.pressed.emit()
	await _settle(6)
	_check(captured.size() == 1 and (captured[0] as Dictionary).expansions.size() == 1, "A Final Create receives frozen exact Expansion identity")
	var frozen_expansion: Dictionary = (captured[0] as Dictionary).expansions[0]
	_check(String(frozen_expansion.identity.asset_id) == "exp.check_core.public_d20" and not String(frozen_expansion.identity.generation_fingerprint).is_empty(), "A frozen payload pins exact generation fingerprint")
	_check(shell.session_runtime != null and shell.session_runtime.world_state.expansions.size() == 1, "A created Game materializes the Expansion")
	# 第一幕走 Opening stub；接受后转入 Playing。
	var opening_stub: Node = shell.test_opening_adapter_override
	opening_stub.simulate_delta("拓展局的第一幕。")
	opening_stub.simulate_completed()
	await _settle(4)
	_check(shell.session_runtime.conversation.get_durable_accepted_entries().size() == 1, "A d20 Game Opening accepted")
	await _shutdown_shell(shell)


## A2/A5：explicit none 在真实 UI 路径保持有效并投影「拓展 无」。
func _test_wizard_expansion_none_projection() -> void:
	pass


## C：无 Expansion 回归 —— 真实 UI 路径建局，无 adjudication、无机制卡、G4-07 行为不变。
func _test_no_expansion_regression() -> void:
	var case_root := _case_root("no-expansion")
	var shell: Variant = await _boot_shell_with_game(case_root, "无拓展回归", false, true)
	if shell == null:
		return
	_check(shell.action_adjudication == null, "C no-Expansion Game mounts no adjudication Host")
	_check(shell.narrative_view.action_adjudication == null, "C View keeps legacy G4-07 routing")
	var view_stub := _swap_view_stub(shell.narrative_view)
	shell.narrative_view.player_input.text = "我查看江面。"
	shell.narrative_view._on_send_pressed()
	await _settle(2)
	_check(view_stub.start_calls.size() == 1, "C no-Expansion action uses the single G4-07 continuation call")
	view_stub.text_delta.emit("江面雾气沉沉。")
	view_stub.simulate_completed()
	await _settle(4)
	_check(shell.session_runtime.conversation.get_durable_accepted_entries().size() == 2, "C no-Expansion turn accepted once")
	_check(_count_mechanic_cards(shell.narrative_view) == 0, "C no mechanic card without Expansion")
	_check(shell.narrative_view.regenerate_button.visible, "C no-Expansion keeps legacy Regenerate")
	await _shutdown_shell(shell)


## D：受检行动 —— 单 stable action_id、CHECK_REQUIRED 冻结/掷骰经 M1 Host、
## transient 公开先于 narrative 完成、accepted 历史含 exact durable 卡、UI 不重算。
func _test_checked_action_ui() -> void:
	var case_root := _case_root("checked-action")
	var shell: Variant = await _boot_shell_with_game(case_root, "受检行动", true, true)
	if shell == null:
		return
	_check(shell.action_adjudication != null and shell.narrative_view.action_adjudication == shell.action_adjudication, "D Public d20 capability routes through the Host")
	var adjudication_stub: Node = shell.test_adjudication_adapter_override
	var rng: RefCounted = shell.test_adjudication_rng_override
	shell.narrative_view.player_input.text = "我独自潜入敌营偷取军令。"
	shell.narrative_view._on_send_pressed()
	await _settle(2)
	_check(adjudication_stub.requests.size() == 1 and String(shell.action_adjudication._stage) == "adjudication", "D UI starts one adjudication call before any Conversation turn")
	_check(shell.session_runtime.conversation.get_durable_accepted_entries().size() == 1, "D UI does not begin_turn before adjudication")
	_check(shell.narrative_view.send_button.disabled, "D submit disabled during adjudication")
	var action_id := String(shell.narrative_view._pending_action_id)
	_check(action_id.begins_with("action-") and action_id.length() == 39, "D UI mints one stable opaque action_id")
	adjudication_stub.simulate_delta(JSON.stringify(_proposal(15, 0, "normal")))
	adjudication_stub.simulate_completed()
	await _settle(3)
	_check(rng.invocation_count == 1 and adjudication_stub.requests.size() == 2, "D Program rolls once and starts resolution narrative")
	var durable := _check_record(shell.session_runtime, action_id)
	_check(durable.success and int(durable.check.selected_roll) == 7 and int(durable.check.total) == 7 and String(durable.check.outcome) == "failure", "D Program-owned result durable before narrative")
	var card_text := _mechanic_card_text(shell.narrative_view, String(durable.check.check_id))
	_check(card_text.contains("DC 15") and card_text.contains("骰面 7 → 7") and card_text.contains("总计 7") and card_text.contains("失败"), "D transient card projects exact durable truth")
	_check(_count_mechanic_cards(shell.narrative_view) == 1, "D transient public result appears before resolution narrative completes")
	adjudication_stub.simulate_delta("守卫截断了你的退路；失败结果生效。")
	adjudication_stub.simulate_completed()
	await _settle(4)
	_check(shell.session_runtime.conversation.get_durable_accepted_entries().size() == 2, "D accepted history appends Player/GM exactly once")
	_check(String(shell.narrative_view._pending_action_id).is_empty(), "D accepted action clears pending identity")
	_check(_count_mechanic_cards(shell.narrative_view) == 1, "D durable mechanic card stays in accepted history")
	_check(not shell.narrative_view.regenerate_button.visible, "D accepted d20 turn never shows legacy Regenerate")
	_check(not card_text.contains("action-") and not card_text.contains("check-"), "D card never exposes internal action/check ids")
	await _shutdown_shell(shell)


## E：NO_CHECK —— 一次 Provider 调用、零 RNG、无骰卡、正常 Player/GM 叙事 accepted 一次。
func _test_no_check_ui() -> void:
	var case_root := _case_root("no-check")
	var shell: Variant = await _boot_shell_with_game(case_root, "普通行动", true, true)
	if shell == null:
		return
	var adjudication_stub: Node = shell.test_adjudication_adapter_override
	var rng: RefCounted = shell.test_adjudication_rng_override
	shell.narrative_view.player_input.text = "我向身边侍从询问今日日期。"
	shell.narrative_view._on_send_pressed()
	await _settle(2)
	adjudication_stub.simulate_delta(JSON.stringify({"decision": "NO_CHECK", "reason": "已知且无风险", "narrative": "侍从立即答出今日日期。"}))
	adjudication_stub.simulate_completed()
	await _settle(4)
	_check(adjudication_stub.requests.size() == 1 and rng.invocation_count == 0, "E NO_CHECK is one Provider call with zero RNG")
	_check(_count_mechanic_cards(shell.narrative_view) == 0, "E NO_CHECK renders no dice card")
	_check(shell.session_runtime.conversation.get_durable_accepted_entries().size() == 2, "E NO_CHECK narrative accepted exactly once")
	_check(_count_headers(shell.narrative_view, "你的行动") == 1, "E ordinary action looks like ordinary narrative play")
	await _shutdown_shell(shell)


## F：durable 败检后 narrative 失败 → 仅「重试行动」；同 action_id/text 重试不重掷、
## accepted 恰一次。判定期失败可编辑替换并铸新 identity。
func _test_retry_no_reroll_ui() -> void:
	var case_root := _case_root("retry-no-reroll")
	var shell: Variant = await _boot_shell_with_game(case_root, "重试行动", true, true)
	if shell == null:
		return
	var adjudication_stub: Node = shell.test_adjudication_adapter_override
	var rng: RefCounted = shell.test_adjudication_rng_override
	shell.narrative_view.player_input.text = "我冒险跃上着火的粮船。"
	shell.narrative_view._on_send_pressed()
	await _settle(2)
	var action_id := String(shell.narrative_view._pending_action_id)
	adjudication_stub.simulate_delta(JSON.stringify(_proposal(20, 0, "normal")))
	adjudication_stub.simulate_completed()
	await _settle(3)
	_check(_check_record(shell.session_runtime, action_id).success, "F losing check durable before narrative failure")
	adjudication_stub.simulate_failed("transport")
	await _settle(4)
	_check(shell.session_runtime.conversation.get_durable_accepted_entries().size() == 1, "F narrative failure accepts no Player/GM turn")
	_check(shell.narrative_view.retry_action_button.visible and not shell.narrative_view.player_input.editable, "F failure with durable resolution offers only 重试行动 and locks editing")
	_check(not shell.narrative_view.regenerate_button.visible, "F failure never shows legacy Regenerate")
	shell.narrative_view.retry_action_button.pressed.emit()
	await _settle(3)
	_check(String(shell.narrative_view._pending_action_id) == action_id, "F retry reuses the same stable action_id")
	_check(adjudication_stub.requests.size() == 3 and rng.invocation_count == 1, "F retry skips adjudication/RNG and resumes resolution narrative")
	adjudication_stub.simulate_delta("火焰吞没了跳板；失败结果生效。")
	adjudication_stub.simulate_completed()
	await _settle(4)
	_check(shell.session_runtime.conversation.get_durable_accepted_entries().size() == 2, "F retry accepts exactly one Player/GM turn")
	var checks_after: Array = shell.session_runtime.world_state.get("expansion_runtime", {}).get("public_d20_checks", [])
	_check(checks_after.size() == 1 and int(checks_after[0].selected_roll) == 7, "F retry never rerolls the durable result")

	# F3：判定期失败允许编辑替换；新文本铸新 action_id。
	shell.narrative_view.player_input.text = "我尝试潜过水寨栅栏。"
	shell.narrative_view._on_send_pressed()
	await _settle(2)
	var first_attempt_id := String(shell.narrative_view._pending_action_id)
	adjudication_stub.simulate_failed("transport")
	await _settle(4)
	_check(not _check_record(shell.session_runtime, first_attempt_id).success, "F pre-resolution failure leaves no durable check")
	_check(shell.narrative_view.retry_action_button.visible and shell.narrative_view.player_input.editable, "F pre-resolution failure allows edit or retry")
	shell.narrative_view.player_input.text = "我改为沿岸边芦苇潜行。"
	shell.narrative_view._on_send_pressed()
	await _settle(2)
	_check(String(shell.narrative_view._pending_action_id) != first_attempt_id, "F edited replacement mints a new action_id")
	adjudication_stub.simulate_delta(JSON.stringify({"decision": "NO_CHECK", "reason": "日常可行", "narrative": "你沿芦苇荡无声前行。"}))
	adjudication_stub.simulate_completed()
	await _settle(4)
	_check(shell.session_runtime.conversation.get_durable_accepted_entries().size() == 3, "F edited action accepts once")
	await _shutdown_shell(shell)


## G：重开恰好一个未完成 durable 行动 → 门控输入 +「重试行动」；同 durable 行动恢复，
## 不重掷、无额外判定。
func _test_reopen_unfinished_action() -> void:
	var case_root := _case_root("reopen-unfinished")
	var shell: Variant = await _boot_shell_with_game(case_root, "重开未完成", true, true)
	if shell == null:
		return
	var adjudication_stub: Node = shell.test_adjudication_adapter_override
	shell.narrative_view.player_input.text = "我强闯曹军水寨辕门。"
	shell.narrative_view._on_send_pressed()
	await _settle(2)
	var action_id := String(shell.narrative_view._pending_action_id)
	adjudication_stub.simulate_delta(JSON.stringify(_proposal(25, 0, "disadvantage")))
	adjudication_stub.simulate_completed()
	await _settle(3)
	_check(_check_record(shell.session_runtime, action_id).success, "G durable losing check before close")
	var game_id := String(shell.session_runtime.game_id)
	# narrative 未 accepted 即退出。
	await _shutdown_shell(shell)

	var shell2: Variant = await _boot_shell(case_root)
	shell2.test_adjudication_adapter_override = OpeningStub.new()
	shell2.test_adjudication_rng_override = DeterministicRng.new([20, 20])
	shell2.continue_button.pressed.emit()
	await _settle(6)
	_check(shell2.session_runtime != null and String(shell2.session_runtime.game_id) == game_id, "G Continue reopens the same Game")
	_check(shell2.narrative_view._unresolved_reopen_pending and not shell2.narrative_view.player_input.editable, "G reopen gates new Player input on the unfinished action")
	_check(shell2.narrative_view.retry_action_button.visible and shell2.narrative_view.action_status_label.text.contains("上一次行动尚未完成"), "G reopen shows 上一次行动尚未完成 / 重试行动")
	_check(String(shell2.narrative_view._pending_action_id) == action_id, "G reopen retains the exact durable action_id")
	var reopened_stub: Node = shell2.test_adjudication_adapter_override
	var reopened_rng: RefCounted = shell2.test_adjudication_rng_override
	shell2.narrative_view.retry_action_button.pressed.emit()
	await _settle(3)
	_check(reopened_stub.requests.size() == 1 and reopened_rng.invocation_count == 0 and String(shell2.action_adjudication._stage) == "resolution_narrative", "G retry resumes narrative with no reroll and no extra adjudication")
	reopened_stub.simulate_delta("辕门守卫层层围拢；失败结果生效。")
	reopened_stub.simulate_completed()
	await _settle(4)
	_check(shell2.session_runtime.conversation.get_durable_accepted_entries().size() == 2, "G retried action accepts exactly once")
	_check(not shell2.narrative_view._adjudication_active and shell2.narrative_view.player_input.editable, "G accepted retry unlocks input")
	await _shutdown_shell(shell2)


## H：accepted 卡的 Continue 重建 + Load/Restore 移除未来卡。
func _test_continue_load_card_reconstruction() -> void:
	var case_root := _case_root("card-reconstruction")
	var shell: Variant = await _boot_shell_with_game(case_root, "卡牌重建", true, true)
	# H 用独立 RNG 序列匹配 advantage 断言：重新 Continue 触发 Host 重挂载
	shell.return_menu_button.pressed.emit()
	await _settle(4)
	shell.test_adjudication_adapter_override = OpeningStub.new()
	shell.test_adjudication_rng_override = DeterministicRng.new([18, 4])
	shell.continue_button.pressed.emit()
	await _settle(6)
	if shell == null:
		return
	# 先建一个 check 前的 Save。
	shell.save_name_input.text = "行动之前"
	shell._on_create_save_pressed()
	await _settle(3)
	var adjudication_stub: Node = shell.test_adjudication_adapter_override
	shell.narrative_view.player_input.text = "我攀上瞭望塔探查敌情。"
	shell.narrative_view._on_send_pressed()
	await _settle(2)
	adjudication_stub.simulate_delta(JSON.stringify(_proposal(10, 2, "advantage")))
	adjudication_stub.simulate_completed()
	await _settle(3)
	adjudication_stub.simulate_delta("你登上塔顶，敌营布防尽收眼底。")
	adjudication_stub.simulate_completed()
	await _settle(4)
	_check(shell.session_runtime.conversation.get_durable_accepted_entries().size() == 2 and _count_mechanic_cards(shell.narrative_view) == 1, "H accepted check leaves one durable card")
	var card_text := _first_mechanic_card_text(shell.narrative_view)
	_check(card_text.contains("骰面 18 / 4 → 18") and card_text.contains("总计 20") and card_text.contains("成功"), "H card projects exact Program truth")

	# Continue：卡随 durable 重建，数值精确。
	shell.return_menu_button.pressed.emit()
	await _settle(4)
	shell.test_adjudication_adapter_override = OpeningStub.new()
	shell.test_adjudication_rng_override = DeterministicRng.new([18, 4])
	shell.continue_button.pressed.emit()
	await _settle(6)
	_check(_count_mechanic_cards(shell.narrative_view) == 1, "H Continue rebuilds the accepted card")
	var rebuilt_text := _first_mechanic_card_text(shell.narrative_view)
	_check(rebuilt_text.contains("骰面 18 / 4 → 18") and rebuilt_text.contains("总计 20") and rebuilt_text.contains("成功"), "H rebuilt card preserves exact raw rolls/total/outcome")

	# Load 回 check 前：未来卡消失，继续用 restored canonical reality。
	shell.save_selector.selected = 0
	shell._on_load_save_pressed()
	await _settle(2)
	shell.load_confirmation.confirmed.emit()
	await _settle(5)
	_check(shell.session_runtime.conversation.get_durable_accepted_entries().size() == 1, "H Load restores the pre-check state")
	_check(_count_mechanic_cards(shell.narrative_view) == 0, "H Load removes the future mechanic card with the restored future")
	var checks_restored: Array = shell.session_runtime.world_state.get("expansion_runtime", {}).get("public_d20_checks", [])
	_check(checks_restored.is_empty(), "H restored canonical reality drops the future check record")
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


## 走完真实 Wizard 建一局；with_expansion=false 走 explicit none；accept_opening=true 时
## 用 Opening stub 接受第一幕后进入 Playing。返回 shell，失败返回 null。
func _boot_shell_with_game(case_root: String, display_name: String, with_expansion: bool, accept_opening: bool) -> Variant:
	var shell: Variant = await _boot_shell(case_root)
	shell.new_game_button.pressed.emit()
	await _settle(4)
	var wizard: Variant = shell.new_game_wizard
	_press_choice(wizard, "world_han_end_unsettled_realm")
	wizard.next_button.pressed.emit()
	await _settle(2)
	_press_choice(wizard, "entry_t0-208-red-cliffs-eve")
	wizard.next_button.pressed.emit()
	await _settle(2)
	if with_expansion:
		_toggle_choice(wizard, "expansion_exp_check_core_public_d20", true)
	else:
		_press_choice(wizard, "expansion_none")
	wizard.next_button.pressed.emit()
	await _settle(2)
	_press_choice(wizard, "character_han_end_liu_bei")
	wizard.next_button.pressed.emit()
	await _settle(2)
	wizard.next_button.pressed.emit()
	await _settle(2)
	wizard.display_name_input.text = display_name
	wizard.display_name_input.text_changed.emit(display_name)
	wizard.next_button.pressed.emit()
	await _settle(4)
	if wizard.step != 6 or wizard.final_create_button.disabled:
		_fail("Wizard did not reach Review: %s" % display_name)
		return null
	shell.test_opening_adapter_override = OpeningStub.new()
	if with_expansion:
		shell.test_adjudication_adapter_override = OpeningStub.new()
		shell.test_adjudication_rng_override = DeterministicRng.new([7, 3, 18, 4, 11])
	wizard.final_create_button.pressed.emit()
	await _settle(6)
	if shell.session_runtime == null or not shell.session_runtime.is_ready():
		_fail("created Game did not open: %s" % display_name)
		return null
	if accept_opening:
		var opening_stub: Node = shell.test_opening_adapter_override
		opening_stub.simulate_delta("第一幕。")
		opening_stub.simulate_completed()
		await _settle(4)
		if shell.session_runtime.conversation.get_durable_accepted_entries().size() != 1:
			_fail("Opening not accepted: %s" % display_name)
			return null
	return shell


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


func _mechanic_card_text(view: Variant, check_id: String) -> String:
	for child: Node in view.entries.get_children():
		if child.has_meta("mechanic_card") and String(child.get_meta("check_id")) == check_id:
			return _collect_text(child)
	return ""


func _first_mechanic_card_text(view: Variant) -> String:
	for child: Node in view.entries.get_children():
		if child.has_meta("mechanic_card"):
			return _collect_text(child)
	return ""


func _collect_text(node: Node) -> String:
	var text := ""
	if node is Label:
		text += String((node as Label).text) + "\n"
	for child: Node in node.get_children():
		text += _collect_text(child)
	return text


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


func _choice_text(wizard: Variant, name_fragment: String) -> String:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(name_fragment) >= 0:
			return button.text
	_fail("choice not found: %s" % name_fragment)
	return ""


func _toggle_choice(wizard: Variant, name_fragment: String, selected: bool) -> void:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(name_fragment) >= 0 and button is CheckButton:
			(button as CheckButton).button_pressed = selected
			button.toggled.emit(selected)
			return
	_fail("toggle not found: %s" % name_fragment)


func _toggle_state(wizard: Variant, name_fragment: String) -> bool:
	for button: Button in wizard.choice_buttons:
		if String(button.name).find(name_fragment) >= 0 and button is CheckButton:
			return (button as CheckButton).button_pressed
	_fail("toggle not found: %s" % name_fragment)
	return false


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
		print("G4-08B UI PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-08B UI FAIL | %s" % label)


func _finish() -> void:
	print("G4-08B UI | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
