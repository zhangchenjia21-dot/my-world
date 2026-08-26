extends SceneTree

## G2-03 离线 focused 测试（headless，不触网、不需要真实 Provider key）。
##
## 覆盖：
## - T1 空输入不发送；
## - T2 缺 DEEPSEEK_API_KEY → 明确 failed("missing_key")，玩家可读错误，失败不进 history，可重试；
## - T3 dummy key + DNS .invalid 确定性 transport 失败 → regenerate 路径可恢复、仍不污染 history；
## - T4 IR-01 回归：completed → regenerate → 成功替换，不重复 player entry；
## - T5 IR-02 cancel 路径：completed → regenerate → cancel → 不 Retry 直接发送；
## - T6 IR-02 fail 路径：completed → regenerate → fail → 不 Retry 直接发送。
##
## T1–T3 用真实 adapter（验证与 G2-02 seam 的真实集成）；T4–T6 换用 tests/g2_03_桩适配器.gd，
## 专注 view 的 provisional history/context 记账，避免真实 start_stream 副作用干扰模拟。
## 真实 DeepSeek stream / cancel / completed→regenerate / 响应式布局证据在 tests/g2_03_gui驱动测试.gd。

const VIEW := preload("res://src/ui/叙事对话视图.gd")
const STUB := preload("res://tests/g2_03_桩适配器.gd")

var _failures := 0


func _init() -> void:
	_run.call_deferred()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("[g2-03-offline] PASS: %s" % label)
	else:
		_failures += 1
		printerr("[g2-03-offline] FAIL: %s" % label)


func _run() -> void:
	# T2 要求无 key 环境；防御性清空，避免继承环境污染结果。
	OS.set_environment("DEEPSEEK_API_KEY", "")

	var packed: PackedScene = load("res://src/main.tscn")
	var inst: Node = packed.instantiate()
	root.add_child(inst)
	await process_frame
	await process_frame

	var view: Node = inst.get_node("%NarrativeHost")
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
	_check(view.get_provisional_history().is_empty(), "T1 history 为空")

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
	_check(view.get_gen_state() == VIEW.GenState.FAILED, "T2 GenState == FAILED")
	_check(error_label.visible and error_label.text.contains("API Key"), "T2 玩家可读错误提示可见")
	_check(view.get_provisional_history().is_empty(), "T2 失败不进入 provisional history")
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
	_check(view.get_gen_state() == VIEW.GenState.FAILED, "T3 GenState == FAILED")
	_check(
		error_label.visible and (error_label.text.contains("连接") or error_label.text.contains("网络")),
		"T3 玩家可读网络错误提示可见"
	)
	_check(not adapter.is_busy(), "T3 失败后 adapter 不 busy，可再次重试")
	_check(regenerate_button.visible, "T3 失败后 Regenerate 仍可见")
	_check(view.get_provisional_history().is_empty(), "T3 transport 失败仍不污染 history")

	# ---- T4（IR-01 回归）：completed turn → regenerate → 成功替换，不重复 player entry ----
	# 换用桩适配器：真实 adapter 的同步 missing_key failed 会干扰模拟流；T4–T6 专注 view 记账逻辑。
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
	_check(view.get_gen_state() == VIEW.GenState.STREAMING, "T4 发送后进入 STREAMING")
	stub.text_delta.emit("GM 甲")
	stub.simulate_completed()
	var history: Array = view.get_provisional_history()
	_check(history.size() == 2, "T4 first turn completed 后 history == 2")
	if history.size() == 2:
		_check(String(history[0].get("role", "")) == "user" and String(history[1].get("role", "")) == "assistant", "T4 first turn roles == [user, assistant]")

	# regenerate completed turn：再次模拟新 generation。
	regenerate_button.pressed.emit()
	_check(view.get_last_request_messages().filter(func(m: Dictionary) -> bool: return String(m.get("role", "")) == "user" and String(m.get("content", "")) == "第一行动。").size() == 1, "T4 regenerate 请求 context 中该 player input 恰好一次")
	stub.text_delta.emit("GM 甲改")
	stub.simulate_completed()
	history = view.get_provisional_history()
	_check(history.size() == 2, "T4 completed→regenerate 后 history 仍 == 2")
	_check(history.filter(func(m: Dictionary) -> bool: return String(m.get("role", "")) == "user" and String(m.get("content", "")) == "第一行动。").size() == 1, "T4 同一 player input 在 history 中恰好一次")
	if history.size() == 2:
		_check(String(history[0].get("role", "")) == "user" and String(history[1].get("role", "")) == "assistant", "T4 regenerate 后 roles == [user, assistant]")
		_check(String(history[1].get("content", "")) == "GM 甲改", "T4 regenerated assistant 为新输出且非空")

	# 第二个 player turn completed → history == 4。
	player_input.text = "第二行动。"
	send_button.pressed.emit()
	stub.text_delta.emit("GM 乙")
	stub.simulate_completed()
	history = view.get_provisional_history()
	_check(history.size() == 4, "T4 第二 turn completed 后 history == 4")
	if history.size() == 4:
		var roles: Array = history.map(func(m: Dictionary) -> String: return String(m.get("role", "")))
		_check(roles == ["user", "assistant", "user", "assistant"], "T4 最终 roles == [user, assistant, user, assistant]")
	_check(view.get_last_request_messages().filter(func(m: Dictionary) -> bool: return String(m.get("role", "")) == "user").size() == 2, "T4 第二 turn context 中两条 player input 各一次")

	# ---- T5（IR-02 cancel 路径）：completed → regenerate → cancel → 不 Retry 直接发送 ----
	# T4 结束 history = [第一行动, GM甲改, 第二行动, GM乙]（两对）。
	regenerate_button.pressed.emit()
	history = view.get_provisional_history()
	_check(history.size() == 4, "T5 regenerate 发出后旧 completed 对保持完整（不在替换前移除）")
	_check(view.get_last_request_messages().filter(func(m: Dictionary) -> bool: return String(m.get("role", "")) == "user" and String(m.get("content", "")) == "第二行动。").size() == 1, "T5 regenerate context 中被替换 player input 恰好一次")
	stub.text_delta.emit("GM 乙改-半路")
	cancel_button.pressed.emit()  # 玩家真实取消路径：view → stub.cancel() → cancelled
	history = view.get_provisional_history()
	_check(history.size() == 4, "T5 cancel 后无半对 history，旧对仍是稳定 context")
	if history.size() == 4:
		var roles_t5: Array = history.map(func(m: Dictionary) -> String: return String(m.get("role", "")))
		_check(roles_t5 == ["user", "assistant", "user", "assistant"], "T5 cancel 后 history 仍是两对合法对")
	player_input.text = "第三行动。"
	send_button.pressed.emit()
	var ctx_t5: Array = view.get_last_request_messages()
	_check(ctx_t5.filter(func(m: Dictionary) -> bool: return String(m.get("role", "")) == "user" and String(m.get("content", "")) == "第二行动。").size() == 1, "T5 新请求 context 中第二行动恰好一次")
	_check(ctx_t5.filter(func(m: Dictionary) -> bool: return String(m.get("role", "")) == "user" and String(m.get("content", "")) == "第三行动。").size() == 1, "T5 新行动已进入 Provider context 恰好一次")
	_check(ctx_t5.filter(func(m: Dictionary) -> bool: return String(m.get("role", "")) == "user").size() == 3, "T5 context 恰好三条 user 消息")
	stub.text_delta.emit("GM 丙")
	stub.simulate_completed()
	history = view.get_provisional_history()
	_check(history.size() == 6, "T5 直接新发送完成后 history == 三对")
	if history.size() == 6:
		var roles_t5b: Array = history.map(func(m: Dictionary) -> String: return String(m.get("role", "")))
		_check(roles_t5b == ["user", "assistant", "user", "assistant", "user", "assistant"], "T5 最终 roles 合法交错")

	# ---- T6（IR-02 fail 路径）：completed → regenerate → deterministic fail → 直接发送 ----
	regenerate_button.pressed.emit()
	stub.simulate_failed("transport", "模拟确定性失败")
	history = view.get_provisional_history()
	_check(history.size() == 6, "T6 fail 后无半对 history，旧对完整")
	player_input.text = "第四行动。"
	send_button.pressed.emit()
	var ctx_t6: Array = view.get_last_request_messages()
	_check(ctx_t6.filter(func(m: Dictionary) -> bool: return String(m.get("role", "")) == "user" and String(m.get("content", "")) == "第三行动。").size() == 1, "T6 新请求 context 中第三行动恰好一次")
	_check(ctx_t6.filter(func(m: Dictionary) -> bool: return String(m.get("role", "")) == "user" and String(m.get("content", "")) == "第四行动。").size() == 1, "T6 新行动已进入 Provider context 恰好一次")
	stub.text_delta.emit("GM 丁")
	stub.simulate_completed()
	history = view.get_provisional_history()
	_check(history.size() == 8, "T6 完成后 history == 四对")
	if history.size() == 8:
		var roles_t6: Array = history.map(func(m: Dictionary) -> String: return String(m.get("role", "")))
		_check(roles_t6 == ["user", "assistant", "user", "assistant", "user", "assistant", "user", "assistant"], "T6 最终 roles 合法交错")

	print("[g2-03-offline] done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)
