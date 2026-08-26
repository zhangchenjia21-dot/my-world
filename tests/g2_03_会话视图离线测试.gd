extends SceneTree

## G2-03 离线 focused 测试（headless，不触网、不需要真实 Provider key）。
##
## 覆盖：
## - T1 空输入不发送；
## - T2 缺 DEEPSEEK_API_KEY → 明确 failed("missing_key")，玩家可读错误，失败不进 history，可重试；
## - T3 dummy key + DNS .invalid 确定性 transport 失败 → regenerate 路径可恢复、仍不污染 history。
##
## 真实 stream / cancel / 响应式布局证据在 tests/g2_03_gui驱动测试.gd。

const VIEW := preload("res://src/ui/叙事对话视图.gd")

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

	print("[g2-03-offline] done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)
