extends PanelContainer

## G2-04 Narrative Conversation View —— 中央 NarrativeHost 的玩家界面，
## Domain Conversation（src/domain/会话.gd）的 projection。
##
## UI 不再持有第二套 history / generation flags（AC-09）：Turn ordering、accepted truth、
## Generation State、retry / regenerate / correction 全部由 conversation 拥有；
## 本视图只消费 conversation 信号做渲染，并把 adapter 事件翻译成 conversation 调用。
##
## 直接消费 src/provider/deepseek流式适配器.gd（G-02 seam），不重写 HTTP/SSE transport。

const ADAPTER := preload("res://src/provider/deepseek流式适配器.gd")
const Conversation := preload("res://src/domain/会话.gd")
const ContextAssembler := preload("res://src/context/上下文组装器.gd")

## 一次性 derived request 的观测 seam；测试可捕获，UI 不保存或持久化 messages。
signal request_messages_assembled(messages)

## 长正文 readable-width 上限（px）：宽屏/最大化下避免单行无限拉长；居中由 EntriesCenter 负责。
const READABLE_MAX_WIDTH := 920.0

## Composer 高度响应式规则（UX-01）：随窗口高度适度增高并 clamp，约 3-4 行自然语言行动起步。
## 简单 clamp 规则，不做 auto-growing editor / Splitter / UI preference framework。
const COMPOSER_HEIGHT_FACTOR := 0.15
const COMPOSER_MIN_HEIGHT := 112.0
const COMPOSER_MAX_HEIGHT := 160.0

@onready var narrative_scroll: ScrollContainer = %NarrativeScroll
@onready var entries: VBoxContainer = %Entries
@onready var error_label: Label = %ErrorLabel
@onready var player_input: TextEdit = %PlayerInput
@onready var send_button: Button = %SendButton
@onready var cancel_button: Button = %CancelButton
@onready var regenerate_button: Button = %RegenerateButton

## provisional integration point：adapter 由本视图创建为子节点；
## focused tests 可在首次请求前注入 adapter.test_host_override。
var adapter: Node

## authoritative Conversation（G2-04 Domain）。UI 只是它的 projection。
var conversation: RefCounted

## Application Shell 注入的 current Game runtime。production 必须提供；仅 `--script`
## focused tests 保留无 Persistence 的 Conversation fallback，避免测试触碰真实 user:// DB。
var session_runtime: Variant = null
var _startup_ready := false
var _isolated_test_mode := false

## Context Assembly 是 derived Provider request 的 owner；UI 只提供输入 material 并转交结果。
var context_assembler: RefCounted

## 未来 Game/World owner 的最小接入 seam。当前 production 没有正式 Game Context，保持空值；
## focused tests 可以注入 fixture，但 UI 不拥有或解释该 material。
var game_context_text := ""

## G4-07A reviewed durable Opening/continuation seam；Application Shell 在 created Game
## 激活后注入。注入后第一条玩家行动也经由 durable Game-local World + durable Conversation
## 组装 Provider request，绝不回读 Wizard 内存或 mutable Source current。
var opening_runtime: Node = null

## opening-pending（durable accepted Conversation = 0）时锁住玩家输入；由 Shell 驱动。
var _opening_gate := false

## 以下为纯渲染引用：当前 streaming GM block 的 content / marker，以及滚动跟随状态。
var _current_gm_content: RichTextLabel = null
var _current_gm_marker: Label = null
var _follow_scroll := true


func _ready() -> void:
	if session_runtime == null:
		session_runtime = _find_session_runtime()
	send_button.pressed.connect(_on_send_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	regenerate_button.pressed.connect(_on_regenerate_pressed)
	player_input.text_changed.connect(_update_controls)
	player_input.gui_input.connect(_on_player_input_gui)

	narrative_scroll.get_v_scroll_bar().value_changed.connect(_on_narrative_scroll_changed)
	narrative_scroll.resized.connect(_update_readable_width)
	get_tree().root.size_changed.connect(_update_composer_height)
	if session_runtime != null:
		_initialize_session(session_runtime.conversation, session_runtime.is_ready())
	elif _isolated_test_mode:
		_initialize_session(Conversation.new(), true)
	_update_controls()
	_update_readable_width.call_deferred()
	_update_composer_height()


func _on_send_pressed() -> void:
	var text := player_input.text.strip_edges()
	if not _startup_ready or _opening_gate or conversation == null or text.is_empty() or conversation.is_generating():
		return

	if conversation.begin_turn(text) == null:
		return
	player_input.clear()
	_hide_error()
	_start_request()


func _on_cancel_pressed() -> void:
	if conversation == null or not conversation.is_generating():
		return
	# Opening streaming 期间取消必须路由到 opening runtime 的 adapter；
	# 只有普通玩家 turn 才走本视图自己的 adapter。
	if opening_runtime != null and opening_runtime.provider_adapter != null and opening_runtime.provider_adapter.is_busy():
		opening_runtime.cancel()
	elif adapter != null:
		adapter.cancel()


## Regenerate / Retry：Domain 决定语义（completed latest = regenerate，否则 retry），
## UI 只触发并发起新请求。
func _on_regenerate_pressed() -> void:
	if not _startup_ready or conversation == null or conversation.is_generating() or conversation.latest_turn() == null:
		return

	if conversation.retry_or_regenerate_latest() == null:
		return
	_hide_error()
	_start_request()


func _start_request() -> void:
	var messages: Array = []
	if opening_runtime != null:
		# G4-07A reviewed durable continuation：durable Game-local World + durable Conversation。
		# 组装失败必须 fail-loud：宁可不发送，也不退回 Wizard 状态或 Source current。
		var assembled: Dictionary = opening_runtime.assemble_continuation_messages()
		if not assembled.success:
			conversation.fail_generation("context_assembly_failed")
			return
		messages = assembled.messages
	else:
		messages = context_assembler.assemble_messages(
			conversation.get_context_projection(),
			game_context_text
		)
	request_messages_assembled.emit(messages.duplicate(true))
	var start_error: Error = adapter.start_stream(messages)
	if start_error == ERR_BUSY:
		# UI 已防止 double-submit；此处只是防御，不制造额外 UI 状态。
		push_warning("G2-04: adapter busy on start_stream")


## ---- adapter 事件 -> Domain 调用 ----

func _on_text_delta(text: String) -> void:
	conversation.append_delta(text)


func _on_completed() -> void:
	if session_runtime != null:
		session_runtime.complete_active_generation_durably()
	else:
		conversation.complete_generation()


func _on_cancelled() -> void:
	conversation.cancel_generation()


func _on_failed(code: String, _message: String) -> void:
	conversation.fail_generation(code)


## ---- Domain 信号 -> 渲染 ----

func _on_turn_started(turn: RefCounted) -> void:
	_append_player_entry(String(turn.pending_player_text))
	_begin_gm_entry()


## retry / regenerate / correction：复用同一 GM block，清空上一轮展示内容。
## GM-only 首次 Opening 不发 turn_started：pending_player_text 为空（v4 兼容槽，
## 不代表玩家说过话），此处为它新建 GM block，且绝不渲染玩家气泡。
func _on_attempt_started(turn: RefCounted) -> void:
	if _current_gm_content == null:
		_begin_gm_entry(String(turn.pending_player_text).is_empty())
	else:
		_current_gm_content.clear()
	if _current_gm_marker != null:
		_current_gm_marker.text = ""
	_update_controls()


func _on_draft_appended(text: String) -> void:
	if _current_gm_content != null:
		_current_gm_content.add_text(text)
		_follow_scroll_if_needed()


func _on_generation_completed(_turn: RefCounted) -> void:
	_update_controls()


func _on_generation_cancelled(_turn: RefCounted) -> void:
	# partial Narrative 保留在屏幕上，但明确标记，且不进入后续 context。
	if _current_gm_marker != null:
		_current_gm_marker.text = "已取消 —— 本次内容不会带入后续叙事"
	_update_controls()


func _on_generation_failed(turn: RefCounted, code: String) -> void:
	# GM-only Opening 的失败重试归 Shell banner；这里不得指向隐藏的「重新生成」。
	var opening_turn := String(turn.pending_player_text).is_empty()
	if _current_gm_marker != null:
		_current_gm_marker.text = "第一幕未完成 —— 可使用上方「重试第一幕」" if opening_turn else "生成失败 —— 可点击「重新生成」重试"
	_show_error("第一幕未完成；本局已保存，可使用上方「重试第一幕」。" if opening_turn else _friendly_error(code))
	_update_controls()


func _on_runtime_restore_completed(_result: Dictionary) -> void:
	# Restore 后 UI 必须从新的 Domain projection 全量重建，不能逐条 patch 旧 future blocks。
	redraw_from_conversation()
	_hide_error()
	_update_controls()


func _append_player_entry(text: String) -> void:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)

	var header := Label.new()
	header.text = "你的行动"
	header.add_theme_font_size_override("font_size", 14)
	header.add_theme_color_override("font_color", Color(0.63, 0.68, 0.78))
	box.add_child(header)

	var content := RichTextLabel.new()
	content.fit_content = true
	content.selection_enabled = true
	content.add_text(text)
	box.add_child(content)

	entries.add_child(box)


func _begin_gm_entry(opening: bool = false) -> void:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)

	var header_row := HBoxContainer.new()
	var title := Label.new()
	title.text = "GM · 开场" if opening else "GM"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.78, 0.72, 0.55))
	header_row.add_child(title)

	_current_gm_marker = Label.new()
	_current_gm_marker.add_theme_font_size_override("font_size", 14)
	_current_gm_marker.add_theme_color_override("font_color", Color(0.85, 0.55, 0.45))
	header_row.add_child(_current_gm_marker)
	box.add_child(header_row)

	_current_gm_content = RichTextLabel.new()
	_current_gm_content.fit_content = true
	_current_gm_content.selection_enabled = true
	_current_gm_content.add_theme_font_size_override("normal_font_size", 20)
	box.add_child(_current_gm_content)

	entries.add_child(box)


## 玩家可读错误（DEC-11）：不泄露 key / Authorization，不向玩家倾倒原始 payload。
func _friendly_error(code: String) -> String:
	match code:
		"missing_key":
			return "未检测到 DeepSeek API Key。请在本机 .env.local 中配置 DEEPSEEK_API_KEY 后重新启动游戏。"
		"transport":
			return "暂时无法连接 DeepSeek 服务。请检查网络后点击「重新生成」重试。"
		"malformed_stream":
			return "收到了无法识别的响应数据。可点击「重新生成」重试。"
		"empty_generation":
			return "本次没有生成有效叙事，可点击「重新生成」重试。"
		"context_assembly_failed":
			return "无法组装本局上下文；为保护既有进度，本次没有发送请求。可点击「重新生成」重试。"
		"persistence_failure":
			return "叙事未能安全保存，因此没有正式接受本次结果。请检查磁盘后点击「重新生成」重试。"
		_:
			if code.begins_with("http_"):
				return "DeepSeek 服务返回错误（%s）。可稍后点击「重新生成」重试。" % code
			return "出现未知错误。可点击「重新生成」重试。"


func _update_controls() -> void:
	var streaming: bool = conversation != null and conversation.is_generating()
	send_button.disabled = not _startup_ready or _opening_gate or streaming or player_input.text.strip_edges().is_empty()
	cancel_button.disabled = not _startup_ready or not streaming
	# opening Turn（pending_player_text 为空）不显示「重新生成」：第一幕的重试由
	# Shell 的 Opening banner 拥有，避免把 GM-only Opening 当成可 regenerate 的玩家回合。
	var latest: RefCounted = conversation.latest_turn() if conversation != null else null
	var opening_turn := latest != null and String(latest.pending_player_text).is_empty()
	regenerate_button.visible = _startup_ready and not streaming and latest != null and not opening_turn


func _show_error(text: String) -> void:
	error_label.text = text
	error_label.visible = true


func _hide_error() -> void:
	error_label.visible = false


## Ctrl+Enter 发送；只响应明确的 Ctrl 组合，不干扰中文输入法。
func _on_player_input_gui(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.ctrl_pressed and key_event.keycode == KEY_ENTER:
			_on_send_pressed()
			player_input.accept_event()


## 正文列宽随窗口收窄铺满，超过 READABLE_MAX_WIDTH 后由 CenterContainer 居中限宽。
func _update_readable_width() -> void:
	entries.custom_minimum_size.x = minf(narrative_scroll.size.x, READABLE_MAX_WIDTH)


## UX-01：Composer 高度 = clamp(窗口高度 * 0.15, 112, 160)。
## 720p ≈ 112px（3-4 行），1080p+/Maximized ≈ 160px 封顶，960x540 窄窗口保持可用。
func _update_composer_height() -> void:
	player_input.custom_minimum_size.y = clampf(
		float(get_tree().root.size.y) * COMPOSER_HEIGHT_FACTOR,
		COMPOSER_MIN_HEIGHT,
		COMPOSER_MAX_HEIGHT
	)


## 用户仍在底部附近时跟随最新文本；用户主动向上阅读时不强行拉回。
func _on_narrative_scroll_changed(value: float) -> void:
	var bar := narrative_scroll.get_v_scroll_bar()
	_follow_scroll = value >= bar.max_value - bar.page - 24.0


func _follow_scroll_if_needed() -> void:
	if not _follow_scroll:
		return
	await get_tree().process_frame
	var bar := narrative_scroll.get_v_scroll_bar()
	bar.value = bar.max_value


## Application Continue 后绑定本次 Session；重新绑定前完整拆除旧 transport/callback/projection。
func bind_session_runtime(runtime: Variant) -> void:
	if not is_node_ready():
		session_runtime = runtime
		return
	shutdown_session()
	session_runtime = runtime
	_initialize_session(runtime.conversation, runtime.is_ready())


## Application Shell 在 created Game 激活后注入 G4-07A opening runtime。
func bind_opening_runtime(opening: Node) -> void:
	opening_runtime = opening
	_update_controls()


## created Game 且 durable accepted Conversation = 0：第一幕 accepted 前锁住玩家输入。
func set_opening_gate(active: bool) -> void:
	_opening_gate = active
	player_input.editable = not active
	_update_controls()


## Game -> Main Menu / App exit 的正式 View cleanup seam。Adapter cancel 同步发布 cancelled，
## 因而先终止 transport，再断开信号与释放 projection，未 accepted partial 不会 durable。
func shutdown_session() -> void:
	if adapter != null:
		if adapter.is_busy():
			adapter.cancel()
		_disconnect_adapter_signals(adapter)
		if adapter.get_parent() == self:
			remove_child(adapter)
		adapter.queue_free()
		adapter = null
	if conversation != null:
		_disconnect_conversation_signals(conversation)
	if session_runtime != null and session_runtime.has_signal("restore_completed"):
		var restore_callback := Callable(self, "_on_runtime_restore_completed")
		if session_runtime.restore_completed.is_connected(restore_callback):
			session_runtime.restore_completed.disconnect(restore_callback)
	session_runtime = null
	conversation = null
	context_assembler = null
	opening_runtime = null
	_opening_gate = false
	player_input.editable = true
	_startup_ready = false
	_clear_rendered_entries(true)
	_hide_error()
	_update_controls()


## 旧 G2 UI 测试显式启用无 Persistence fixture；production/Main Menu 永不自动创建它。
func enable_isolated_test_mode() -> void:
	_isolated_test_mode = true
	if is_node_ready() and conversation == null:
		_initialize_session(Conversation.new(), true)


func _initialize_session(bound_conversation: RefCounted, ready: bool) -> void:
	conversation = bound_conversation
	_startup_ready = ready
	context_assembler = ContextAssembler.new()
	conversation.turn_started.connect(_on_turn_started)
	conversation.attempt_started.connect(_on_attempt_started)
	conversation.draft_appended.connect(_on_draft_appended)
	conversation.generation_completed.connect(_on_generation_completed)
	conversation.generation_cancelled.connect(_on_generation_cancelled)
	conversation.generation_failed.connect(_on_generation_failed)
	if session_runtime != null and session_runtime.has_signal("restore_completed"):
		session_runtime.restore_completed.connect(_on_runtime_restore_completed)
	adapter = ADAPTER.new()
	adapter.name = "DeepSeekProviderAdapter"
	add_child(adapter)
	adapter.text_delta.connect(_on_text_delta)
	adapter.completed.connect(_on_completed)
	adapter.cancelled.connect(_on_cancelled)
	adapter.failed.connect(_on_failed)
	_render_restored_entries()
	if not _startup_ready:
		_show_error("无法恢复当前游戏。为保护已有数据，本次不会创建空白新局；请稍后重试。")
	_update_controls()


func _disconnect_adapter_signals(source: Node) -> void:
	var callbacks := {
		"text_delta": Callable(self, "_on_text_delta"),
		"completed": Callable(self, "_on_completed"),
		"cancelled": Callable(self, "_on_cancelled"),
		"failed": Callable(self, "_on_failed"),
	}
	for signal_name: String in callbacks:
		var source_signal: Signal = source.get(signal_name)
		var callback: Callable = callbacks[signal_name]
		if source_signal.is_connected(callback):
			source_signal.disconnect(callback)


func _disconnect_conversation_signals(source: RefCounted) -> void:
	var callbacks := {
		"turn_started": Callable(self, "_on_turn_started"),
		"attempt_started": Callable(self, "_on_attempt_started"),
		"draft_appended": Callable(self, "_on_draft_appended"),
		"generation_completed": Callable(self, "_on_generation_completed"),
		"generation_cancelled": Callable(self, "_on_generation_cancelled"),
		"generation_failed": Callable(self, "_on_generation_failed"),
	}
	for signal_name: String in callbacks:
		var source_signal: Signal = source.get(signal_name)
		var callback: Callable = callbacks[signal_name]
		if source_signal.is_connected(callback):
			source_signal.disconnect(callback)


func _clear_rendered_entries(clear_player_input: bool = false) -> void:
	for child: Node in entries.get_children():
		entries.remove_child(child)
		child.queue_free()
	_current_gm_content = null
	_current_gm_marker = null
	if clear_player_input:
		player_input.clear()


func _find_session_runtime() -> Variant:
	var ancestor: Node = get_parent()
	while ancestor != null:
		if ancestor.has_method("get_session_runtime"):
			return ancestor.get_session_runtime()
		ancestor = ancestor.get_parent()
	return null


## UI 从 Domain projection 重建 visual blocks；不保存 `_history` 或 Transcript 副本。
## 最后一个 restored GM block 留作 regenerate/retry 的复用目标。
## GM-only Opening 的 empty player_text 是 v4 兼容槽：跳过玩家气泡，只渲染开场 GM block。
func _render_restored_entries() -> void:
	for entry_value: Variant in conversation.get_accepted_entries():
		var entry := entry_value as Dictionary
		var player_text := String(entry.player_text)
		if not player_text.is_empty():
			_append_player_entry(player_text)
		_begin_gm_entry(player_text.is_empty())
		_current_gm_content.add_text(String(entry.gm_text))


func redraw_from_conversation() -> void:
	_clear_rendered_entries()
	_render_restored_entries()
	_follow_scroll = true
	_follow_scroll_if_needed()
