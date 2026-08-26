extends SceneTree

## G2-03 离线 focused 测试（headless，不触网、不需要真实 Provider key）。
## G2-04 起 provisional truth 由 Domain Conversation（src/domain/会话.gd）拥有，
## 本测试断言 view.conversation，UI 不再持有第二套 history。
##
## 覆盖：
## - T1 空输入不发送；
## - T2 缺 DEEPSEEK_API_KEY → 明确 failed("missing_key")，玩家可读错误，失败不进 accepted，可重试；
## - T3 dummy key + DNS .invalid 确定性 transport 失败 → regenerate 路径可恢复、仍不污染 accepted；
## - T4 IR-01 回归：completed → regenerate → 成功替换，不重复 player entry；
## - T5 IR-02 cancel 路径：completed → regenerate → cancel → 不 Retry 直接发送；
## - T6 IR-02 fail 路径：completed → regenerate → fail → 不 Retry 直接发送；
## - T7 Ctrl+Enter 发送 + 中文多行输入（裸 Enter 不发送，保护输入法）。
##
## T1–T3 用真实 adapter（验证与 G2-02 seam 的真实集成）；T4–T6 换用 tests/g2_03_桩适配器.gd，
## 专注 Conversation 记账，避免真实 start_stream 副作用干扰模拟。
## 真实 DeepSeek stream / cancel / completed→regenerate / 响应式布局证据在 tests/g2_03_gui驱动测试.gd。

const VIEW := preload("res://src/ui/叙事对话视图.gd")
const STUB := preload("res://tests/g2_03_桩适配器.gd")
const CONVERSATION := preload("res://src/domain/会话.gd")

var _failures := 0


func _init() -> void:
	_run.call_deferred()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("[g2-03-offline] PASS: %s" % label)
	else:
		_failures += 1
		printerr("[g2-03-offline] FAIL: %s" % label)


## messages 中指定 role + content 的出现次数。
func _count_msg(messages: Array, role: String, content: String) -> int:
	var n := 0
	for m: Variant in messages:
		var d := m as Dictionary
		if d != null and String(d.get("role", "")) == role and String(d.get("content", "")) == content:
			n += 1
	return n


## accepted entries 中指定 player_text 的出现次数。
func _count_player(entries: Array, text: String) -> int:
	var n := 0
	for e: Variant in entries:
		if String((e as Dictionary).get("player_text", "")) == text:
			n += 1
	return n


func _run() -> void:
	# T2 要求无 key 环境；防御性清空，避免继承环境污染结果。
	OS.set_environment("DEEPSEEK_API_KEY", "")

	var packed: PackedScene = load("res://src/main.tscn")
	var inst: Node = packed.instantiate()
	root.add_child(inst)
	await process_frame
	await process_frame

	var view: Node = inst.get_node("%NarrativeHost")
	var conversation: RefCounted = view.conversation
	var player_input: TextEdit = inst.get_node("%PlayerInput")
	var send_button: Button = inst.get_node("%SendButton")
	var regenerate_button: Button = inst.get_node("%RegenerateButton")
	var error_label: Label = inst.get_node("%ErrorLabel")
	var entries: VBoxContainer = inst.get_node("%Entries")
	var adapter: Node = view.adapter

	# ---- T1：空输入不发送 ----
	_check(send_button.disabled, "T1 空输入时发送按钮禁用")
	send_button.pressed.emit()
	await process_frame
	_check(not adapter.is_busy(), "T1 空输入未启动请求")
	_check(entries.get_child_count() == 0, "T1 空输入未产生任何 entry")
	_check(conversation.turns.is_empty(), "T1 空输入未产生任何 turn")

	# ---- T2：缺 key → 明确失败（failed 信号在 start_stream 内同步发出，先连信号再触发）----
	var failed_results: Array = []
	adapter.failed.connect(func(code: String, message: String) -> void: failed_results.append([code, message]))
	player_input.text = "环顾四周。"
	send_button.pressed.emit()
	await process_frame
	_check(failed_results.size() == 1, "T2 恰好一次 failed 信号")
	if failed_results.size() == 1:
		_check(String(failed_results[0][0]) == "missing_key", "T2 failed code == missing_key")
		_check(not String(failed_results[0][1]).is_empty(), "T2 failed 带可读 message")
	_check(conversation.generation_state == CONVERSATION.GenerationState.FAILED, "T2 GenerationState == FAILED")
	_check(error_label.visible and error_label.text.contains("API Key"), "T2 玩家可读错误提示可见")
	_check(conversation.get_accepted_entries().is_empty(), "T2 失败不进入 accepted entries")
	_check(not adapter.is_busy(), "T2 失败后 adapter 不 busy")
	_check(regenerate_button.visible, "T2 失败后 Regenerate 可见")
	_check(entries.get_child_count() == 2, "T2 player + GM 占位 entry 各一")

	# ---- T3：确定性 transport 失败 + Regenerate 可重试 ----
	OS.set_environment("DEEPSEEK_API_KEY", "g2-03-offline-dummy-key")
	adapter.test_host_override = "g2-03-failure.invalid"
	regenerate_button.pressed.emit()
	var deadline := Time.get_ticks_msec() + 30000
	while failed_results.size() < 2 and Time.get_ticks_msec() < deadline:
		await process_frame
	_check(failed_results.size() == 2, "T3 regenerate 后收到第二次 failed")
	if failed_results.size() == 2:
		_check(String(failed_results[1][0]) == "transport", "T3 failed code == transport（DNS 确定性失败）")
	_check(conversation.generation_state == CONVERSATION.GenerationState.FAILED, "T3 GenerationState == FAILED")
	_check(
		error_label.visible and (error_label.text.contains("连接") or error_label.text.contains("网络")),
		"T3 玩家可读网络错误提示可见"
	)
	_check(not adapter.is_busy(), "T3 失败后 adapter 不 busy，可再次重试")
	_check(regenerate_button.visible, "T3 失败后 Regenerate 仍可见")
	_check(conversation.get_accepted_entries().is_empty(), "T3 transport 失败仍不污染 accepted entries")

	# ---- T4（IR-01 回归）：completed turn → regenerate → 成功替换，不重复 player entry ----
	# 换用桩适配器：真实 adapter 的同步 missing_key failed 会干扰模拟流；T4–T6 专注 Conversation 记账。
	var stub: Node = STUB.new()
	adapter.text_delta.disconnect(view._on_text_delta)
	adapter.completed.disconnect(view._on_completed)
	adapter.cancelled.disconnect(view._on_cancelled)
	adapter.failed.disconnect(view._on_failed)
	view.adapter = stub
	view.add_child(stub)
	stub.text_delta.connect(view._on_text_delta)
	stub.completed.connect(view._on_completed)
	stub.cancelled.connect(view._on_cancelled)
	stub.failed.connect(view._on_failed)
	var cancel_button: Button = inst.get_node("%CancelButton")

	player_input.text = "第一行动。"
	send_button.pressed.emit()
	_check(conversation.generation_state == CONVERSATION.GenerationState.STREAMING, "T4 发送后进入 STREAMING")
	stub.text_delta.emit("GM 甲")
	stub.simulate_completed()
	var accepted: Array = conversation.get_accepted_entries()
	_check(accepted.size() == 1, "T4 first turn completed 后 accepted entries == 1")
	if accepted.size() == 1:
		_check(String(accepted[0].get("player_text", "")) == "第一行动。" and String(accepted[0].get("gm_text", "")) == "GM 甲", "T4 first turn accepted 内容正确")

	# regenerate completed turn：再次模拟新 generation。
	regenerate_button.pressed.emit()
	_check(_count_msg(stub.start_calls[-1], "user", "第一行动。") == 1, "T4 regenerate 请求 context 中该 player input 恰好一次")
	stub.text_delta.emit("GM 甲改")
	stub.simulate_completed()
	accepted = conversation.get_accepted_entries()
	_check(accepted.size() == 1, "T4 completed→regenerate 后 accepted entries 仍 == 1")
	_check(_count_player(accepted, "第一行动。") == 1, "T4 同一 player input 在 accepted 中恰好一次")
	if accepted.size() == 1:
		_check(String(accepted[0].get("gm_text", "")) == "GM 甲改", "T4 regenerated assistant 为新输出且非空")

	# 第二个 player turn completed → accepted entries == 2。
	player_input.text = "第二行动。"
	send_button.pressed.emit()
	stub.text_delta.emit("GM 乙")
	stub.simulate_completed()
	accepted = conversation.get_accepted_entries()
	_check(accepted.size() == 2, "T4 第二 turn completed 后 accepted entries == 2")
	if accepted.size() == 2:
		_check(
			String(accepted[0].get("player_text", "")) == "第一行动。" and String(accepted[1].get("player_text", "")) == "第二行动。"
			and String(accepted[1].get("gm_text", "")) == "GM 乙",
			"T4 最终两对 accepted 合法有序"
		)
	_check(_count_msg(stub.start_calls[-1], "user", "第一行动。") == 1 and _count_msg(stub.start_calls[-1], "user", "第二行动。") == 1, "T4 第二 turn context 中两条 player input 各一次")

	# ---- T5（IR-02 cancel 路径）：completed → regenerate → cancel → 不 Retry 直接发送 ----
	# T4 结束 accepted = [第一行动/GM甲改, 第二行动/GM乙]（两对）。
	regenerate_button.pressed.emit()
	accepted = conversation.get_accepted_entries()
	_check(accepted.size() == 2, "T5 regenerate 发出后旧 completed 对保持完整（不在替换前移除）")
	_check(_count_msg(stub.start_calls[-1], "user", "第二行动。") == 1, "T5 regenerate context 中被替换 player input 恰好一次")
	stub.text_delta.emit("GM 乙改-半路")
	cancel_button.pressed.emit()  # 玩家真实取消路径：view → stub.cancel() → cancelled
	accepted = conversation.get_accepted_entries()
	_check(accepted.size() == 2, "T5 cancel 后无半对，旧对仍是稳定 context")
	if accepted.size() == 2:
		_check(String(accepted[1].get("gm_text", "")) == "GM 乙", "T5 cancel 后旧 GM 输出未被半路内容污染")
	player_input.text = "第三行动。"
	send_button.pressed.emit()
	var ctx_t5: Array = stub.start_calls[-1]
	_check(_count_msg(ctx_t5, "user", "第二行动。") == 1, "T5 新请求 context 中第二行动恰好一次")
	_check(_count_msg(ctx_t5, "user", "第三行动。") == 1, "T5 新行动已进入 Provider context 恰好一次")
	_check(ctx_t5.filter(func(m: Variant) -> bool: return String((m as Dictionary).get("role", "")) == "user").size() == 3, "T5 context 恰好三条 user 消息")
	stub.text_delta.emit("GM 丙")
	stub.simulate_completed()
	accepted = conversation.get_accepted_entries()
	_check(accepted.size() == 3, "T5 直接新发送完成后 accepted == 三对")
	if accepted.size() == 3:
		_check(String(accepted[2].get("player_text", "")) == "第三行动。" and String(accepted[2].get("gm_text", "")) == "GM 丙", "T5 第三对内容正确")

	# ---- T6（IR-02 fail 路径）：completed → regenerate → deterministic fail → 直接发送 ----
	regenerate_button.pressed.emit()
	stub.simulate_failed("transport", "模拟确定性失败")
	accepted = conversation.get_accepted_entries()
	_check(accepted.size() == 3, "T6 fail 后无半对，旧对完整")
	_check(String(accepted[2].get("gm_text", "")) == "GM 丙", "T6 fail 后旧 GM 输出未被破坏")
	player_input.text = "第四行动。"
	send_button.pressed.emit()
	var ctx_t6: Array = stub.start_calls[-1]
	_check(_count_msg(ctx_t6, "user", "第三行动。") == 1, "T6 新请求 context 中第三行动恰好一次")
	_check(_count_msg(ctx_t6, "user", "第四行动。") == 1, "T6 新行动已进入 Provider context 恰好一次")
	stub.text_delta.emit("GM 丁")
	stub.simulate_completed()
	accepted = conversation.get_accepted_entries()
	_check(accepted.size() == 4, "T6 完成后 accepted == 四对")

	# ---- T7：Ctrl+Enter 发送 + 中文多行输入 ----
	# T6 结束 state == COMPLETED，accepted 四条（四对）。
	var multiline_action := "第一行：观察四周。\n第二行：握紧短刀。\n第三行：计划与态度。"
	player_input.text = multiline_action
	var plain_enter := InputEventKey.new()
	plain_enter.pressed = true
	plain_enter.keycode = KEY_ENTER
	player_input.gui_input.emit(plain_enter)
	_check(conversation.generation_state == CONVERSATION.GenerationState.COMPLETED, "T7 裸 Enter 不触发发送（保护输入法）")
	var ctrl_enter := InputEventKey.new()
	ctrl_enter.pressed = true
	ctrl_enter.ctrl_pressed = true
	ctrl_enter.keycode = KEY_ENTER
	player_input.gui_input.emit(ctrl_enter)
	_check(conversation.generation_state == CONVERSATION.GenerationState.STREAMING, "T7 Ctrl+Enter 触发发送")
	var t7_calls: Array = stub.start_calls
	if not t7_calls.is_empty():
		var t7_last_messages: Array = t7_calls[-1]
		var t7_last_user: Dictionary = t7_last_messages[-1]
		_check(String(t7_last_user.get("content", "")) == multiline_action, "T7 多行中文行动原文进入 Provider context")
	stub.simulate_completed()
	accepted = conversation.get_accepted_entries()
	_check(accepted.size() == 5, "T7 Ctrl+Enter turn 完成后 accepted == 五对")

	print("[g2-03-offline] done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)
