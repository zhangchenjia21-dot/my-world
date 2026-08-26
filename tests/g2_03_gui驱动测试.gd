extends SceneTree

## G2-03 GUI 驱动测试（真实窗口运行，非 headless）。
##
## 证据覆盖：
## - 1280x720 宽窗口三 Host 布局 + 截图；
## - 960x540 窄窗口 Narrative 优先、侧 Host 折叠为 toggle、输入文本保留 + 截图；
## - 真实 DeepSeek stream（TTFT / delta / 完成耗时）+ streaming 截图；
## - 生成中 Cancel 延迟、partial 标记、无双终止、不污染 history；
## - Regenerate 完整完成、provisional history 恰好一对 player/GM；
## - 第二条行动完成后 history == 两对；
## - active streaming 中走正式退出按钮路径（AC-13，进程应立即退出码 0，由外部计时）。
##
## 截图由 viewport 自取，保存到 user://g2_03_shots/ 并打印绝对路径。
## 结果在退出测试前写入 user://g2_03_gui_result.txt（退出路径固定 exit 0，不能承载测试结论）。

const VIEW := preload("res://src/ui/叙事对话视图.gd")

var _failures := 0
var _terminal_count := 0
var _shot_dir := "user://g2_03_shots"


func _init() -> void:
	_run.call_deferred()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("[g2-03-gui] PASS: %s" % label)
	else:
		_failures += 1
		printerr("[g2-03-gui] FAIL: %s" % label)


func _shot(shot_name: String) -> void:
	await process_frame
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, shot_name]
	image.save_png(path)
	print("[g2-03-gui] shot: %s" % ProjectSettings.globalize_path(path))


func _wait_until(callable: Callable, budget_msec: int, label: String) -> bool:
	var deadline := Time.get_ticks_msec() + budget_msec
	while not callable.call() and Time.get_ticks_msec() < deadline:
		await process_frame
	var ok: bool = callable.call()
	if not ok:
		print("[g2-03-gui] TIMEOUT waiting: %s" % label)
	return ok


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_shot_dir))

	var packed: PackedScene = load("res://src/main.tscn")
	var inst: Node = packed.instantiate()
	root.add_child(inst)

	root.size = Vector2i(1280, 720)
	for i in range(10):
		await process_frame

	var view: Node = inst.get_node("%NarrativeHost")
	var player_input: TextEdit = inst.get_node("%PlayerInput")
	var send_button: Button = inst.get_node("%SendButton")
	var cancel_button: Button = inst.get_node("%CancelButton")
	var regenerate_button: Button = inst.get_node("%RegenerateButton")
	var player_panel_host: PanelContainer = inst.get_node("%PlayerPanelHost")
	var world_surface_host: PanelContainer = inst.get_node("%WorldSurfaceHost")
	var player_toggle: Button = inst.get_node("%PlayerToggle")
	var world_toggle: Button = inst.get_node("%WorldToggle")
	var exit_button: Button = inst.get_node("%ExitButton")
	var adapter: Node = view.adapter

	adapter.completed.connect(func() -> void: _terminal_count += 1)
	adapter.cancelled.connect(func() -> void: _terminal_count += 1)
	adapter.failed.connect(func(_c: String, _m: String) -> void: _terminal_count += 1)

	# ---- 宽窗口布局（AC：三 Host，Narrative 主角）----
	_check(player_panel_host.visible and world_surface_host.visible, "宽窗口左右 Host 可见")
	_check(not player_toggle.visible and not world_toggle.visible, "宽窗口 toggle 隐藏")
	_check(view.size.x > player_panel_host.size.x and view.size.x > world_surface_host.size.x, "宽窗口 Narrative 为中央主角")
	await _shot("01_wide_1280")

	# ---- 窄窗口布局（Narrative 优先，侧 Host 折叠，输入保留）----
	player_input.text = "这条文本在窗口缩放后必须保留。"
	root.size = Vector2i(960, 540)
	for i in range(10):
		await process_frame
	_check(not player_panel_host.visible and not world_surface_host.visible, "窄窗口侧 Host 折叠")
	_check(player_toggle.visible and world_toggle.visible, "窄窗口 toggle 可见")
	_check(view.visible, "窄窗口 Narrative 仍可见（主角）")
	_check(player_input.text.contains("必须保留"), "窄窗口输入文本保留")
	player_toggle.button_pressed = true
	await process_frame
	_check(player_panel_host.visible, "窄窗口主角 toggle 可展开侧栏")
	player_toggle.button_pressed = false
	await process_frame
	await _shot("02_narrow_960")

	# ---- 回宽窗口，真实 DeepSeek stream ----
	root.size = Vector2i(1280, 720)
	for i in range(6):
		await process_frame

	var api_key := OS.get_environment("DEEPSEEK_API_KEY").strip_edges()
	if api_key.is_empty():
		_failures += 1
		printerr("[g2-03-gui] FAIL: 缺少 DEEPSEEK_API_KEY，无法做真实 stream 证据")
		_write_result_and_exit({})
		return

	player_input.text = "我推开茶馆后门，冒雨走进漆黑的巷子，握紧短刀，仔细听四周的动静。"
	send_button.pressed.emit()
	var stream_ok := await _wait_until(func() -> bool: return adapter.delta_count >= 5 or _terminal_count > 0, 90000, "首批 stream delta")
	_check(stream_ok and adapter.delta_count >= 5, "真实 stream 收到 >=5 个增量 delta")
	var ttft_ms: int = adapter.first_delta_msec - adapter.started_msec
	_check(ttft_ms > 0, "TTFT 已记录")
	_check(view.get_gen_state() == VIEW.GenState.STREAMING, "streaming 中 GenState == STREAMING")
	_check(not cancel_button.disabled, "streaming 中 Cancel 可用")
	_check(send_button.disabled, "streaming 中 Send 禁用（防 double-submit）")
	await _shot("03_streaming")

	# ---- 生成中 Cancel ----
	var cancel_begin := Time.get_ticks_msec()
	cancel_button.pressed.emit()
	var cancel_ok := await _wait_until(func() -> bool: return _terminal_count == 1, 10000, "cancelled 终态")
	var cancel_ms := Time.get_ticks_msec() - cancel_begin
	_check(cancel_ok, "Cancel 后收到 cancelled 终态")
	_check(view.get_gen_state() == VIEW.GenState.CANCELLED, "Cancel 后 GenState == CANCELLED")
	_check(view.get_provisional_history().is_empty(), "cancelled partial 不进入 history")
	_check(regenerate_button.visible, "Cancel 后 Regenerate 可见")
	# 双终止保护：cancel 后再等 2 秒，终态计数不得再涨。
	var settle_deadline := Time.get_ticks_msec() + 2000
	while Time.get_ticks_msec() < settle_deadline:
		await process_frame
	_check(_terminal_count == 1, "无双终止（cancelled 只发一次）")
	await _shot("04_cancelled")

	# ---- Regenerate：完整完成，history 恰好一对 ----
	regenerate_button.pressed.emit()
	var regen_ok := await _wait_until(func() -> bool: return _terminal_count >= 2, 180000, "regenerate completed")
	_check(regen_ok and view.get_gen_state() == VIEW.GenState.COMPLETED, "Regenerate 完整完成")
	var history: Array = view.get_provisional_history()
	_check(history.size() == 2, "Regenerate 后 history 恰好一对 player/GM")
	if history.size() == 2:
		_check(String(history[0].get("role", "")) == "user", "history[0] 是 player turn")
		_check(String(history[1].get("role", "")) == "assistant", "history[1] 是 GM turn")
		_check(not String(history[1].get("content", "")).is_empty(), "GM 完整输出非空")
	var gen1_ms: int = adapter.finished_msec - adapter.started_msec
	await _shot("05_regenerated")

	# ---- 第二条行动：provisional history 累计两对 ----
	player_input.text = "我蹲下身，检查地上刚才那个黑影留下的痕迹。"
	send_button.pressed.emit()
	var second_ok := await _wait_until(func() -> bool: return _terminal_count >= 3, 180000, "第二条行动 completed")
	_check(second_ok and view.get_gen_state() == VIEW.GenState.COMPLETED, "第二条行动完整完成")
	history = view.get_provisional_history()
	_check(history.size() == 4, "两条行动后 history == 两对 player/GM")
	await _shot("06_second_turn")

	var metrics := {
		"ttft_ms": ttft_ms,
		"cancel_ms": cancel_ms,
		"gen1_ms": gen1_ms,
		"gen1_deltas": adapter.delta_count,
		"gen1_chars": adapter.output_chars,
	}
	print("[g2-03-gui] metrics: %s" % JSON.stringify(metrics))
	_write_result(metrics)

	# ---- AC-13：active streaming 中走正式退出路径，进程应立即退出（外部计时与 exit code）----
	if _failures > 0:
		printerr("[g2-03-gui] 已有失败，跳过退出测试并直接退出")
		quit(1)
		return
	player_input.text = "我沿着巷子继续往前走。"
	send_button.pressed.emit()
	var exit_stream_ok := await _wait_until(func() -> bool: return adapter.delta_count >= 2 or _terminal_count >= 4, 90000, "退出测试流启动")
	if not exit_stream_ok:
		_failures += 1
		printerr("[g2-03-gui] FAIL: 退出测试流未能启动")
		quit(1)
		return
	print("[g2-03-gui] active streaming 中触发退出按钮: msec=%d" % Time.get_ticks_msec())
	exit_button.pressed.emit()
	# 正常路径下进程会在本帧末退出；若 5 秒后仍在运行则判失败。
	var exit_deadline := Time.get_ticks_msec() + 5000
	while Time.get_ticks_msec() < exit_deadline:
		await process_frame
	_failures += 1
	printerr("[g2-03-gui] FAIL: 退出按钮触发后进程未在 5 秒内退出")
	quit(1)


func _write_result(metrics: Dictionary) -> void:
	var file := FileAccess.open("user://g2_03_gui_result.txt", FileAccess.WRITE)
	file.store_line("failures=%d" % _failures)
	for key in metrics.keys():
		file.store_line("%s=%s" % [key, metrics[key]])
	file.close()
	print("[g2-03-gui] result: %s" % ProjectSettings.globalize_path("user://g2_03_gui_result.txt"))


func _write_result_and_exit(metrics: Dictionary) -> void:
	_write_result(metrics)
	quit(1)
