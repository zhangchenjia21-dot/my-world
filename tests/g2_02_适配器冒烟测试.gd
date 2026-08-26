extends SceneTree

## G2-02 Provider Adapter 冒烟测试（focused harness，headless 运行）。
## 覆盖：missing key 不发网 → deterministic credential-free transport failure → 真实 DeepSeek stream
## → active 时重复 start 拒绝 → 真实 cancel（无双终止）→ cancel 后新请求成功。
## 安全边界：失败测试只用 dummy key 指向 127.0.0.1:1；任何输出不得包含真实 key 或完整模型正文。

const ADAPTER := preload("res://src/provider/deepseek流式适配器.gd")

var _failures := 0


func _init() -> void:
	_run.call_deferred()


func _check(ok: bool, label: String, detail: String = "") -> void:
	if ok:
		print("[PASS] ", label, " ", detail)
	else:
		_failures += 1
		print("[FAIL] ", label, " ", detail)


## 等待 adapter 终态信号；返回 {kind, code, completed_count, cancelled_count, failed_count}。
func _await_terminal(adapter: Node, budget_msec: int) -> Dictionary:
	var result := {"kind": "", "code": "", "completed_count": 0, "cancelled_count": 0, "failed_count": 0}
	adapter.completed.connect(func() -> void:
		result["kind"] = "completed"
		result["completed_count"] += 1
	)
	adapter.cancelled.connect(func() -> void:
		result["kind"] = "cancelled"
		result["cancelled_count"] += 1
	)
	adapter.failed.connect(func(code: String, _message: String) -> void:
		result["kind"] = "failed"
		result["code"] = code
		result["failed_count"] += 1
	)

	var deadline := Time.get_ticks_msec() + budget_msec
	while result["kind"] == "" and Time.get_ticks_msec() < deadline:
		await process_frame
	if result["kind"] == "":
		result["kind"] = "timeout"
	return result


func _run() -> void:
	print("[g2-02] provider adapter smoke start")
	var real_key := OS.get_environment("DEEPSEEK_API_KEY").strip_edges()

	# T1：missing key —— 禁止发网、明确失败、不进入 busy。
	OS.set_environment("DEEPSEEK_API_KEY", "")
	var t1: Node = ADAPTER.new()
	root.add_child(t1)
	var t1_failed_codes: Array = []
	var t1_completed := false
	t1.failed.connect(func(code: String, _message: String) -> void: t1_failed_codes.append(code))
	t1.completed.connect(func() -> void: t1_completed = true)
	var t1_err: Error = t1.start_stream([{"role": "user", "content": "你好"}])
	_check(t1_err != OK and t1_failed_codes.has("missing_key") and not t1_completed and not t1.is_busy(),
		"T1 missing-key", "err=%d codes=%s busy=%s" % [t1_err, str(t1_failed_codes), str(t1.is_busy())])
	t1.queue_free()

	# T2：deterministic credential-free failure —— dummy key + 保留 TLD `.invalid` 确定性 DNS 失败。
	# （本机 127.0.0.1:1 实测连接挂起 >30s 不报 CANT_CONNECT，故改用 DNS 失败路径。）
	OS.set_environment("DEEPSEEK_API_KEY", "g2-02-deterministic-failure-dummy")
	var t2: Node = ADAPTER.new()
	root.add_child(t2)
	t2.test_host_override = "g2-02-deterministic-failure.invalid"
	t2.test_port_override = 443
	var t2_start_err: Error = t2.start_stream([{"role": "user", "content": "不会发出"}])
	var t2_result: Dictionary = await _await_terminal(t2, 15000)
	_check(t2_result["kind"] == "failed" and String(t2_result["code"]) == "transport" and not t2.is_busy(),
		"T2 deterministic-failure", "kind=%s code=%s" % [t2_result["kind"], t2_result["code"]])

	# 离线前置未通过时不消耗真实 Provider 调用。
	if _failures > 0:
		print("[g2-02] offline checks failed; skip real provider calls")
		quit(1)
		return
	if real_key.is_empty():
		print("[g2-02] no real DEEPSEEK_API_KEY in environment; skip real provider calls")
		quit(1)
		return

	# T3：真实 DeepSeek stream —— 同一 adapter 实例，证明 failure 后可恢复。
	OS.set_environment("DEEPSEEK_API_KEY", real_key)
	t2.test_host_override = ""
	t2.test_port_override = 0
	var short_messages: Array = [
		{"role": "system", "content": "你是测试助手，只输出一句简短中文问候。"},
		{"role": "user", "content": "开始"},
	]
	var t3_start_err: Error = t2.start_stream(short_messages)
	var t3_result: Dictionary = await _await_terminal(t2, 90000)
	var t3_ttft := -1
	if t2.first_delta_msec >= 0:
		t3_ttft = t2.first_delta_msec - t2.started_msec
	var t3_total := -1
	if t2.finished_msec >= 0:
		t3_total = t2.finished_msec - t2.started_msec
	_check(t3_start_err == OK and t3_result["kind"] == "completed" and t2.delta_count > 0 and t2.output_chars > 0,
		"T3 real-stream (post-failure recovery)",
		"start_err=%d kind=%s deltas=%d chars=%d" % [t3_start_err, t3_result["kind"], t2.delta_count, t2.output_chars])
	print("[metric] real-stream ttft_ms=%d total_ms=%d deltas=%d chars=%d" % [t3_ttft, t3_total, t2.delta_count, t2.output_chars])
	t2.queue_free()

	# T4：active 时重复 start 被拒绝，随后真实 cancel，无双终止。
	var t4: Node = ADAPTER.new()
	root.add_child(t4)
	var long_messages: Array = [
		{"role": "system", "content": "你是测试 GM。请连续输出 8 段中文叙事，每段 3 句。"},
		{"role": "user", "content": "开始讲述"},
	]
	var t4_start_err: Error = t4.start_stream(long_messages)
	# 等首个 delta（允许较慢 TTFT），再尝试并发 start。
	var guard_deadline := Time.get_ticks_msec() + 45000
	while t4.delta_count == 0 and t4.is_busy() and Time.get_ticks_msec() < guard_deadline:
		await process_frame
	var t4_second_err: Error = t4.start_stream(long_messages)
	_check(t4_second_err == ERR_BUSY and t4.is_busy(), "T4 concurrent-guard", "second_err=%d busy=%s deltas_so_far=%d" % [t4_second_err, str(t4.is_busy()), t4.delta_count])

	# 先连接终态信号再 cancel，避免同步发射的 cancelled 被错过。
	var t4_result := {"kind": "", "code": "", "completed_count": 0, "cancelled_count": 0, "failed_count": 0}
	t4.completed.connect(func() -> void:
		t4_result["kind"] = "completed"
		t4_result["completed_count"] += 1
	)
	t4.cancelled.connect(func() -> void:
		t4_result["kind"] = "cancelled"
		t4_result["cancelled_count"] += 1
	)
	t4.failed.connect(func(code: String, _message: String) -> void:
		t4_result["kind"] = "failed"
		t4_result["code"] = code
		t4_result["failed_count"] += 1
	)
	t4.cancel()
	var cancel_deadline := Time.get_ticks_msec() + 5000
	while t4_result["kind"] == "" and Time.get_ticks_msec() < cancel_deadline:
		await process_frame
	# cancel 后多等若干帧，确认不会迟发 completed（双终止）。
	for _i in range(30):
		await process_frame
	_check(t4_result["kind"] == "cancelled" and t4_result["completed_count"] == 0 and not t4.is_busy(),
		"T4 cancel", "kind=%s completed_count=%d busy=%s" % [t4_result["kind"], t4_result["completed_count"], str(t4.is_busy())])
	print("[metric] cancel deltas_before_cancel=%d chars_before_cancel=%d" % [t4.delta_count, t4.output_chars])

	# T5：cancel 后新真实请求成功完成。
	var t5_start_err: Error = t4.start_stream(short_messages)
	var t5_result: Dictionary = await _await_terminal(t4, 90000)
	var t5_total := -1
	if t4.finished_msec >= 0:
		t5_total = t4.finished_msec - t4.started_msec
	_check(t5_start_err == OK and t5_result["kind"] == "completed" and t4.delta_count > 0,
		"T5 post-cancel request", "start_err=%d kind=%s deltas=%d chars=%d total_ms=%d" % [t5_start_err, t5_result["kind"], t4.delta_count, t4.output_chars, t5_total])
	t4.queue_free()

	print("[g2-02] smoke done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)
