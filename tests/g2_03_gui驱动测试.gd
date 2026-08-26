extends SceneTree

## G2-03 GUI 驱动测试（真实窗口运行，非 headless）。
## G2-04 起 provisional truth 由 Domain Conversation（src/domain/会话.gd）拥有，
## 本测试断言 view.conversation；发送给 Provider 的 context 通过 attempt_started 信号快照记录。
##
## 证据覆盖：
## - Maximized 三 Host 布局比例 + 截图；
## - 1280x720 宽窗口三 Host 布局 + 截图；
## - 960x540 窄窗口 Narrative 优先、侧 Host 折叠为 toggle、输入文本保留 + 截图；
## - DEC-10 中号字体基线证据（Theme default / GM 正文字号）；
## - 真实 DeepSeek stream（TTFT / delta / 完成耗时）+ streaming 截图；
## - 生成中 Cancel 延迟、partial 标记、无双终止、不污染 accepted；
## - Regenerate 完整完成、accepted 恰好一对 player/GM；
## - 第二条行动完成后 accepted == 两对；
## - IR-01 completed→regenerate / IR-02 regenerate→cancel→直接新发送真实回归；
## - active streaming 中走正式退出按钮路径（AC-13，进程应立即退出码 0，由外部计时）。
##
## 截图由 viewport 自取，保存到 user://g2_03_shots/ 并打印绝对路径。
## 结果在退出测试前写入 user://g2_03_gui_result.txt（退出路径固定 exit 0，不能承载测试结论）。

const VIEW := preload("res://src/ui/叙事对话视图.gd")
const CONVERSATION := preload("res://src/domain/会话.gd")

var _failures := 0
var _terminal_count := 0
var _shot_dir := "user://g2_03_shots"
## 每次 attempt 实际发给 Provider 的 messages 快照（attempt_started 时 Domain 状态已是 STREAMING，
## 与 view._start_request 随后使用的 Context Assembly 输入一致）。
var _sent_contexts: Array = []


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


## messages 中指定 role + content 的出现次数。
func _count_msg(messages: Array, role: String, content: String) -> int:
	var n := 0
	for m: Variant in messages:
		var d := m as Dictionary
		if d != null and String(d.get("role", "")) == role and String(d.get("content", "")) == content:
			n += 1
	return n


func _count_role(messages: Array, role: String) -> int:
	var n := 0
	for m: Variant in messages:
		if String((m as Dictionary).get("role", "")) == role:
			n += 1
	return n


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_shot_dir))

	var packed: PackedScene = load("res://src/main.tscn")
	var inst: Node = packed.instantiate()
	root.add_child(inst)

	# 工程测试显式控制窗口模式；产品默认（project.godot window/size/mode=2）为 Maximized。
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1280, 720)
	for i in range(10):
		await process_frame

	var view: Node = inst.get_node("%NarrativeHost")
	var conversation: RefCounted = view.conversation
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

	conversation.attempt_started.connect(
		func(_t: RefCounted) -> void: _sent_contexts.append(
			view.context_assembler.assemble_messages(
				conversation.get_context_projection(),
				view.game_context_text
			)
		)
	)
	adapter.completed.connect(func() -> void: _terminal_count += 1)
	adapter.cancelled.connect(func() -> void: _terminal_count += 1)
	adapter.failed.connect(func(_c: String, _m: String) -> void: _terminal_count += 1)

	var host_layout: Control = inst.get_node("Margin/Layout/HostLayout")
	var player_empty: Label = player_panel_host.get_node("PlayerPanelMargin/PlayerPanelColumn/PlayerEmpty")
	var world_empty: Label = world_surface_host.get_node("WorldPanelMargin/WorldPanelColumn/WorldEmpty")
	var entries_node: Control = inst.get_node("%Entries")

	# ---- DEC-10 中号字体基线证据 ----
	_check(inst.theme.default_font_size == 18, "Theme default_font_size == 18（中号基线）")

	# ---- Maximized 三栏比例（三 Host 全部横向 expand）----
	root.mode = Window.MODE_MAXIMIZED
	for i in range(15):
		await process_frame
	var total_w := host_layout.size.x
	var player_w := player_panel_host.size.x
	var narrative_w: float = view.size.x
	var world_w := world_surface_host.size.x
	print("[g2-03-gui] maximized widths: window=%d total=%d player=%d narrative=%d world=%d" % [root.size.x, int(total_w), int(player_w), int(narrative_w), int(world_w)])
	_check(root.size.x > 1280, "Maximized 窗口实际宽于 1280 基准")
	_check(player_w >= 250.0, "Maximized Player Host >= 250px 最小可用宽度")
	_check(world_w >= 310.0, "Maximized World Host >= 310px 最小可用宽度")
	var player_ratio := player_w / total_w
	var narrative_ratio: float = narrative_w / total_w
	var world_ratio := world_w / total_w
	print("[g2-03-gui] maximized ratios: player=%.3f narrative=%.3f world=%.3f" % [player_ratio, narrative_ratio, world_ratio])
	_check(player_ratio >= 0.12 and player_ratio <= 0.24, "Maximized Player 比例 ~18% 量级")
	_check(narrative_ratio >= 0.50 and narrative_ratio <= 0.70, "Maximized Narrative 比例 ~60% 量级")
	_check(world_ratio >= 0.16 and world_ratio <= 0.28, "Maximized World 比例 ~22% 量级")
	_check(player_empty.size.x <= player_panel_host.size.x and world_empty.size.x <= world_surface_host.size.x, "Maximized 侧栏文字无跨 Host 溢出")
	_check(entries_node.size.x <= 921.0, "Maximized 正文列 readable-width 约束生效")
	var composer_h_max := player_input.size.y
	print("[g2-03-gui] maximized composer height=%d" % int(composer_h_max))
	_check(composer_h_max >= 130.0 and composer_h_max <= 165.0, "Maximized Composer 高度 130-160px 量级")
	await _shot("00_maximized")

	# ---- 回到 1280x720 windowed 回归 ----
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1280, 720)
	for i in range(12):
		await process_frame
	print("[g2-03-gui] 1280 widths: player=%d narrative=%d world=%d" % [int(player_panel_host.size.x), int(view.size.x), int(world_surface_host.size.x)])
	_check(player_panel_host.size.x >= 250.0 and world_surface_host.size.x >= 310.0, "1280 windowed 侧栏保持最小可用宽度")
	var composer_h_1280 := player_input.size.y
	print("[g2-03-gui] 1280 composer height=%d" % int(composer_h_1280))
	_check(composer_h_1280 >= 104.0 and composer_h_1280 <= 128.0, "1280 Composer 高度约 112px（约 3-4 行）")

	# ---- 宽窗口布局（三 Host，Narrative 主角）----
	_check(player_panel_host.visible and world_surface_host.visible, "宽窗口左右 Host 可见")
	_check(not player_toggle.visible and not world_toggle.visible, "宽窗口 toggle 隐藏")
	_check(view.size.x > player_panel_host.size.x and view.size.x > world_surface_host.size.x, "宽窗口 Narrative 为中央主角")
	await _shot("01_wide_1280")

	# ---- 窄窗口布局（Narrative 优先，侧 Host 折叠，输入保留）----
	player_input.text = "这条文本在窗口缩放后必须保留。\n第二行：中文多行输入。\n第三行：计划与态度。"
	root.size = Vector2i(960, 540)
	for i in range(10):
		await process_frame
	_check(not player_panel_host.visible and not world_surface_host.visible, "窄窗口侧 Host 折叠")
	_check(player_toggle.visible and world_toggle.visible, "窄窗口 toggle 可见")
	_check(view.visible, "窄窗口 Narrative 仍可见（主角）")
	_check(player_input.text.contains("必须保留") and player_input.text.contains("第三行"), "窄窗口多行输入文本保留")
	_check(player_input.size.y >= 100.0, "960 窄窗口 Composer 保持可用高度")
	var narrative_scroll_node: ScrollContainer = inst.get_node("%NarrativeScroll")
	_check(narrative_scroll_node.size.y > 120.0, "960 窄窗口 Narrative 阅读区仍可用")
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
	# 真实发送走 Ctrl+Enter 路径（UX-01：玩家多行输入后的主要发送方式）。
	var ctrl_enter := InputEventKey.new()
	ctrl_enter.pressed = true
	ctrl_enter.ctrl_pressed = true
	ctrl_enter.keycode = KEY_ENTER
	player_input.gui_input.emit(ctrl_enter)
	_check(conversation.generation_state == CONVERSATION.GenerationState.STREAMING, "Ctrl+Enter 真实触发发送")
	var stream_ok := await _wait_until(func() -> bool: return adapter.delta_count >= 5 or _terminal_count > 0, 90000, "首批 stream delta")
	_check(stream_ok and adapter.delta_count >= 5, "真实 stream 收到 >=5 个增量 delta")
	var ttft_ms: int = adapter.first_delta_msec - adapter.started_msec
	_check(ttft_ms > 0, "TTFT 已记录")
	_check(conversation.generation_state == CONVERSATION.GenerationState.STREAMING, "streaming 中 GenerationState == STREAMING")
	_check(not cancel_button.disabled, "streaming 中 Cancel 可用")
	_check(send_button.disabled, "streaming 中 Send 禁用（防 double-submit）")
	await _shot("03_streaming")

	# ---- 生成中 Cancel ----
	var cancel_begin := Time.get_ticks_msec()
	cancel_button.pressed.emit()
	var cancel_ok := await _wait_until(func() -> bool: return _terminal_count == 1, 10000, "cancelled 终态")
	var cancel_ms := Time.get_ticks_msec() - cancel_begin
	_check(cancel_ok, "Cancel 后收到 cancelled 终态")
	_check(conversation.generation_state == CONVERSATION.GenerationState.CANCELLED, "Cancel 后 GenerationState == CANCELLED")
	_check(conversation.get_accepted_entries().is_empty(), "cancelled partial 不进入 accepted entries")
	_check(regenerate_button.visible, "Cancel 后 Regenerate 可见")
	# 双终止保护：cancel 后再等 2 秒，终态计数不得再涨。
	var settle_deadline := Time.get_ticks_msec() + 2000
	while Time.get_ticks_msec() < settle_deadline:
		await process_frame
	_check(_terminal_count == 1, "无双终止（cancelled 只发一次）")
	await _shot("04_cancelled")

	# ---- Regenerate：完整完成，accepted 恰好一对 ----
	regenerate_button.pressed.emit()
	var regen_ok := await _wait_until(func() -> bool: return _terminal_count >= 2, 180000, "regenerate completed")
	_check(regen_ok and conversation.generation_state == CONVERSATION.GenerationState.COMPLETED, "Regenerate 完整完成")
	var accepted: Array = conversation.get_accepted_entries()
	_check(accepted.size() == 1, "Regenerate 后 accepted 恰好一对 player/GM")
	if accepted.size() == 1:
		_check(not String(accepted[0].get("player_text", "")).is_empty(), "accepted player 非空")
		_check(not String(accepted[0].get("gm_text", "")).is_empty(), "GM 完整输出非空")
	# DEC-10：GM 正文中号字号证据。
	_check(view._current_gm_content.get_theme_font_size("normal_font_size") == 20, "GM 正文 normal_font_size == 20（中号基线）")
	var gen1_ms: int = adapter.finished_msec - adapter.started_msec
	await _shot("05_regenerated")

	# ---- 第二条行动：accepted 累计两对 ----
	player_input.text = "我蹲下身，检查地上刚才那个黑影留下的痕迹。"
	send_button.pressed.emit()
	var second_ok := await _wait_until(func() -> bool: return _terminal_count >= 3, 180000, "第二条行动 completed")
	_check(second_ok and conversation.generation_state == CONVERSATION.GenerationState.COMPLETED, "第二条行动完整完成")
	accepted = conversation.get_accepted_entries()
	_check(accepted.size() == 2, "两条行动后 accepted == 两对 player/GM")
	await _shot("06_second_turn")

	# ---- IR-01 回归：completed turn → 真实 Regenerate → 不得重复 player entry ----
	var second_player_text := "我蹲下身，检查地上刚才那个黑影留下的痕迹。"
	var old_second_gm := String(accepted[1].get("gm_text", "")) if accepted.size() >= 2 else ""
	regenerate_button.pressed.emit()
	var regen2_ok := await _wait_until(func() -> bool: return _terminal_count >= 4, 180000, "completed turn regenerate completed")
	_check(regen2_ok and conversation.generation_state == CONVERSATION.GenerationState.COMPLETED, "IR-01 completed turn Regenerate 真实完成")
	accepted = conversation.get_accepted_entries()
	_check(accepted.size() == 2, "IR-01 completed→regenerate 后 accepted 仍 == 两对")
	if accepted.size() == 2:
		_check(String(accepted[1].get("player_text", "")) == second_player_text, "IR-01 被重新生成的 player turn 原样保留")
		_check(not String(accepted[1].get("gm_text", "")).is_empty(), "IR-01 新 GM 输出非空")
		_check(int(accepted[0].get("turn_index", -1)) == 0 and int(accepted[1].get("turn_index", -1)) == 1, "IR-01 turn identity 稳定")
	_check(accepted.filter(func(e: Variant) -> bool: return String((e as Dictionary).get("player_text", "")) == second_player_text).size() == 1, "IR-01 该 player input 在 accepted 中严格一次")
	var last_messages: Array = _sent_contexts[-1]
	_check(_count_msg(last_messages, "user", second_player_text) == 1, "IR-01 该 player input 在 Provider context 中严格一次")
	_check(_count_role(last_messages, "user") == 2, "IR-01 regenerate context 恰好含两条 user 消息")
	# IR-03：replacement request 以 user 结束，当前 Turn 旧 accepted assistant 不条件化新 generation；
	# previous accepted pair 正常保留。
	_check(String((last_messages[-1] as Dictionary).get("role", "")) == "user", "IR-03 regenerate request 以 user 结束")
	_check(not old_second_gm.is_empty() and _count_msg(last_messages, "assistant", old_second_gm) == 0, "IR-03 当前 Turn 旧 accepted assistant 不在 request")
	_check(_count_role(last_messages, "assistant") == 1, "IR-03 仅前一对 accepted assistant 保留在 request")
	_check(adapter.output_chars >= 100, "Narrative richness：真实 GM 输出充分展开、无 UI/适配器截断（chars=%d）" % adapter.output_chars)
	print("[g2-03-gui] IR-01 old_gm_chars=%d new_gm_chars=%d" % [old_second_gm.length(), String(accepted[1].get("gm_text", "")).length() if accepted.size() == 2 else -1])
	await _shot("07_regenerate_completed")

	# ---- IR-02 真实路径：completed → regenerate → cancel → 不 Retry 直接发送新行动 ----
	regenerate_button.pressed.emit()
	var regen3_stream := await _wait_until(func() -> bool: return adapter.delta_count >= 2 or _terminal_count >= 5, 90000, "IR-02 regenerate 流启动")
	_check(regen3_stream and adapter.delta_count >= 2, "IR-02 regenerate 真实流式中")
	cancel_button.pressed.emit()
	var ir02_cancel_ok := await _wait_until(func() -> bool: return _terminal_count >= 5, 10000, "IR-02 cancelled 终态")
	_check(ir02_cancel_ok and conversation.generation_state == CONVERSATION.GenerationState.CANCELLED, "IR-02 regenerate 生成中 Cancel")
	accepted = conversation.get_accepted_entries()
	_check(accepted.size() == 2, "IR-02 cancel 后旧 completed 对保持完整（无半对）")
	if accepted.size() == 2:
		_check(String(accepted[1].get("gm_text", "")).length() > 0, "IR-02 cancel 后旧 GM 输出未被半路内容污染")
	var third_player_text := "我推开那扇窄木门，侧身闪了进去。"
	player_input.text = third_player_text
	send_button.pressed.emit()
	var ir02_ctx: Array = _sent_contexts[-1]
	_check(_count_msg(ir02_ctx, "user", second_player_text) == 1, "IR-02 新请求 context 中 turn2 恰好一次")
	_check(_count_msg(ir02_ctx, "user", third_player_text) == 1, "IR-02 新行动已进入 Provider context 恰好一次")
	_check(_count_role(ir02_ctx, "user") == 3, "IR-02 context 恰好三条 user 消息")
	var ir02_done := await _wait_until(func() -> bool: return _terminal_count >= 6, 180000, "IR-02 新行动 completed")
	_check(ir02_done and conversation.generation_state == CONVERSATION.GenerationState.COMPLETED, "IR-02 直接新行动真实完成")
	accepted = conversation.get_accepted_entries()
	_check(accepted.size() == 3, "IR-02 完成后 accepted == 三对 player/GM")
	if accepted.size() == 3:
		_check(String(accepted[2].get("player_text", "")) == third_player_text and not String(accepted[2].get("gm_text", "")).is_empty(), "IR-02 第三对内容正确")
	await _shot("08_ir02_direct_send")

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
	var exit_stream_ok := await _wait_until(func() -> bool: return adapter.delta_count >= 2 or _terminal_count >= 7, 90000, "退出测试流启动")
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
