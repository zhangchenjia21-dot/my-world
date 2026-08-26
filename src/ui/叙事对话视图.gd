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

## Context Assembly 是 derived Provider request 的 owner；UI 只提供输入 material 并转交结果。
var context_assembler: RefCounted

## 未来 Game/World owner 的最小接入 seam。当前 production 没有正式 Game Context，保持空值；
## focused tests 可以注入 fixture，但 UI 不拥有或解释该 material。
var game_context_text := ""

## 以下为纯渲染引用：当前 streaming GM block 的 content / marker，以及滚动跟随状态。
var _current_gm_content: RichTextLabel = null
var _current_gm_marker: Label = null
var _follow_scroll := true


func _ready() -> void:
	conversation = Conversation.new()
	context_assembler = ContextAssembler.new()
	conversation.turn_started.connect(_on_turn_started)
	conversation.attempt_started.connect(_on_attempt_started)
	conversation.draft_appended.connect(_on_draft_appended)
	conversation.generation_completed.connect(_on_generation_completed)
	conversation.generation_cancelled.connect(_on_generation_cancelled)
	conversation.generation_failed.connect(_on_generation_failed)

	adapter = ADAPTER.new()
	adapter.name = "DeepSeekProviderAdapter"
	add_child(adapter)
	adapter.text_delta.connect(_on_text_delta)
	adapter.completed.connect(_on_completed)
	adapter.cancelled.connect(_on_cancelled)
	adapter.failed.connect(_on_failed)

	send_button.pressed.connect(_on_send_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	regenerate_button.pressed.connect(_on_regenerate_pressed)
	player_input.text_changed.connect(_update_controls)
	player_input.gui_input.connect(_on_player_input_gui)

	narrative_scroll.get_v_scroll_bar().value_changed.connect(_on_narrative_scroll_changed)
	narrative_scroll.resized.connect(_update_readable_width)
	get_tree().root.size_changed.connect(_update_composer_height)
	_update_controls()
	_update_readable_width.call_deferred()
	_update_composer_height()


func _on_send_pressed() -> void:
	var text := player_input.text.strip_edges()
	if text.is_empty() or conversation.is_generating():
		return

	if conversation.begin_turn(text) == null:
		return
	player_input.clear()
	_hide_error()
	_start_request()


func _on_cancel_pressed() -> void:
	if conversation.is_generating():
		adapter.cancel()


## Regenerate / Retry：Domain 决定语义（completed latest = regenerate，否则 retry），
## UI 只触发并发起新请求。
func _on_regenerate_pressed() -> void:
	if conversation.is_generating() or conversation.latest_turn() == null:
		return

	if conversation.retry_or_regenerate_latest() == null:
		return
	_hide_error()
	_start_request()


func _start_request() -> void:
	var start_error: Error = adapter.start_stream(
		context_assembler.assemble_messages(
			conversation.get_context_projection(),
			game_context_text
		)
	)
	if start_error == ERR_BUSY:
		# UI 已防止 double-submit；此处只是防御，不制造额外 UI 状态。
		push_warning("G2-04: adapter busy on start_stream")


## ---- adapter 事件 -> Domain 调用 ----

func _on_text_delta(text: String) -> void:
	conversation.append_delta(text)


func _on_completed() -> void:
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
func _on_attempt_started(_turn: RefCounted) -> void:
	if _current_gm_content != null:
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


func _on_generation_failed(_turn: RefCounted, code: String) -> void:
	if _current_gm_marker != null:
		_current_gm_marker.text = "生成失败 —— 可点击「重新生成」重试"
	_show_error(_friendly_error(code))
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


func _begin_gm_entry() -> void:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)

	var header_row := HBoxContainer.new()
	var title := Label.new()
	title.text = "GM"
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
		_:
			if code.begins_with("http_"):
				return "DeepSeek 服务返回错误（%s）。可稍后点击「重新生成」重试。" % code
			return "出现未知错误。可点击「重新生成」重试。"


func _update_controls() -> void:
	var streaming: bool = conversation.is_generating()
	send_button.disabled = streaming or player_input.text.strip_edges().is_empty()
	cancel_button.disabled = not streaming
	regenerate_button.visible = not streaming and conversation.latest_turn() != null


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
