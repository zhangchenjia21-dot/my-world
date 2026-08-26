extends PanelContainer

## G2-03 Narrative Conversation View —— 中央 NarrativeHost 的正式玩家界面。
##
## 直接消费 src/provider/deepseek流式适配器.gd（G2-02 seam），不重写 HTTP/SSE transport。
##
## Provisional 边界（DEC-06，明确不是 G2-04/G2-05 contract）：
## - _history 只保存 completed player/GM 消息对，仅存在于内存，不落盘；
## - cancelled / failed 的不完整 GM 输出不进入后续 Provider context；
## - regenerate 替换最近一次 GM generation，不制造第二个 player turn；
## - regenerate 成功前旧 GM 输出仍是稳定 provisional context，成功后才原子替换（IR-02）；
## - 这不是 authoritative Conversation / Timeline / Save。
##
## Provisional GM system message（DEC-07）：最小化，不含 Narrative 白名单 / Regex / Confirmation。
const PROVISIONAL_SYSTEM_PROMPT := "你是 my world 的 AI GM。把玩家输入视为游戏中的自由行动或意图，以自然、沉浸的中文 RPG 叙事回应，自由推进场景、人物与世界。不要输出工程说明，不要解释自己是 AI 或测试程序。"

const ADAPTER := preload("res://src/provider/deepseek流式适配器.gd")

## 长正文 readable-width 上限（px）：宽屏/最大化下避免单行无限拉长；居中由 EntriesCenter 负责。
const READABLE_MAX_WIDTH := 920.0

enum GenState {
	IDLE,
	STREAMING,
	COMPLETED,
	CANCELLED,
	FAILED,
}

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

var _history: Array = []
var _gen_state: GenState = GenState.IDLE
var _last_player_text := ""
var _current_gm_text := ""
var _current_gm_content: RichTextLabel = null
var _current_gm_marker: Label = null
var _follow_scroll := true
## 当前 player turn 是否已写入 _history。Regenerate 同一个 completed turn 时 player entry
## 已存在，completed 时不得再 append 一次（IR-01）；新发送或 cancelled/failed retry 的
## turn 尚未入 history，completed 时才补写。
var _current_turn_in_history := false
## 是否正在替换一个已入 history 的 completed GM generation（IR-02）。
## 替换成功前旧 assistant 保持为稳定 provisional context；completed 时原子替换；
## cancel / fail / 直接新发送都中止本次替换，history 不留半对。
var _replacing_recorded_turn := false
## 最近一次请求实际发给 Provider 的 messages，只读测试 seam（验证 player input 只出现一次）。
var _last_messages: Array = []


func _ready() -> void:
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
	_update_controls()
	_update_readable_width.call_deferred()


## G2-03 provisional 只读 seam，供 focused tests 断言；不是公开 Domain contract。
func get_provisional_history() -> Array:
	return _history.duplicate(true)


func get_gen_state() -> GenState:
	return _gen_state


## 最近一次发给 Provider 的 messages（provisional 只读 seam）。
func get_last_request_messages() -> Array:
	return _last_messages.duplicate(true)


func _on_send_pressed() -> void:
	var text := player_input.text.strip_edges()
	if text.is_empty() or _gen_state == GenState.STREAMING:
		return

	_last_player_text = text
	# 新 player turn 必然尚未入 history；之前的 completed 对保持不变，任何未完成替换中止。
	_current_turn_in_history = false
	_replacing_recorded_turn = false
	_append_player_entry(text)
	_begin_gm_entry()
	player_input.clear()
	_hide_error()
	_start_request()


func _on_cancel_pressed() -> void:
	if _gen_state == GenState.STREAMING:
		adapter.cancel()


## Regenerate / Retry（DEC-10）：复用同一玩家输入，替换同一逻辑 GM block。
func _on_regenerate_pressed() -> void:
	if _gen_state == GenState.STREAMING or _last_player_text.is_empty():
		return

	# 替换已入 history 的 completed turn：旧 assistant 保持为稳定 provisional context，
	# 直到新 generation 成功 completed 才原子替换（IR-02）；
	# cancelled / failed 的 retry 该 turn 从未入 history，不进入替换模式。
	_replacing_recorded_turn = (
		_current_turn_in_history
		and not _history.is_empty()
		and String((_history[-1] as Dictionary).get("role", "")) == "assistant"
	)

	if _current_gm_content != null:
		_current_gm_content.clear()
	if _current_gm_marker != null:
		_current_gm_marker.text = ""
	_hide_error()
	_start_request()


func _start_request() -> void:
	_current_gm_text = ""
	_set_gen_state(GenState.STREAMING)
	_last_messages = _build_messages(_last_player_text)
	var start_error: Error = adapter.start_stream(_last_messages)
	if start_error == ERR_BUSY:
		# UI 已防止 double-submit；此处只是防御，不制造额外 UI 状态。
		push_warning("G2-03: adapter busy on start_stream")


## provisional in-memory messages：system + completed pairs + 当前 player（若尚未入 history）。
func _build_messages(player_text: String) -> Array:
	var messages: Array = [{"role": "system", "content": PROVISIONAL_SYSTEM_PROMPT}]
	messages.append_array(_history)
	if not _current_turn_in_history:
		messages.append({"role": "user", "content": player_text})
	return messages


func _append_player_entry(text: String) -> void:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)

	var header := Label.new()
	header.text = "你的行动"
	header.add_theme_font_size_override("font_size", 13)
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
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", Color(0.78, 0.72, 0.55))
	header_row.add_child(title)

	_current_gm_marker = Label.new()
	_current_gm_marker.add_theme_font_size_override("font_size", 13)
	_current_gm_marker.add_theme_color_override("font_color", Color(0.85, 0.55, 0.45))
	header_row.add_child(_current_gm_marker)
	box.add_child(header_row)

	_current_gm_content = RichTextLabel.new()
	_current_gm_content.fit_content = true
	_current_gm_content.selection_enabled = true
	_current_gm_content.add_theme_font_size_override("normal_font_size", 17)
	box.add_child(_current_gm_content)

	entries.add_child(box)


func _on_text_delta(text: String) -> void:
	_current_gm_text += text
	if _current_gm_content != null:
		_current_gm_content.add_text(text)
		_follow_scroll_if_needed()


func _on_completed() -> void:
	# 只有 completed 的 player/GM 对进入 provisional history。
	# IR-02：替换模式下新 generation 成功后才原子移除旧 assistant；
	# IR-01：regenerate 同一 completed turn 时 player entry 已在 history 中，不重复 append。
	if _replacing_recorded_turn:
		if not _history.is_empty() and String((_history[-1] as Dictionary).get("role", "")) == "assistant":
			_history.pop_back()
		_replacing_recorded_turn = false
	elif not _current_turn_in_history:
		_history.append({"role": "user", "content": _last_player_text})
		_current_turn_in_history = true
	_history.append({"role": "assistant", "content": _current_gm_text})
	_set_gen_state(GenState.COMPLETED)


func _on_cancelled() -> void:
	# 替换中止：旧 completed 对仍是稳定 provisional context，不留半对（IR-02）。
	_replacing_recorded_turn = false
	# partial Narrative 保留在屏幕上，但明确标记，且不进入后续 context。
	if _current_gm_marker != null:
		_current_gm_marker.text = "已取消 —— 本次内容不会带入后续叙事"
	_set_gen_state(GenState.CANCELLED)


func _on_failed(code: String, _message: String) -> void:
	# 同 cancel：替换中止，旧 completed 对不被破坏（IR-02）。
	_replacing_recorded_turn = false
	if _current_gm_marker != null:
		_current_gm_marker.text = "生成失败 —— 可点击「重新生成」重试"
	_show_error(_friendly_error(code))
	_set_gen_state(GenState.FAILED)


## 玩家可读错误（DEC-11）：不泄露 key / Authorization，不向玩家倾倒原始 payload。
func _friendly_error(code: String) -> String:
	match code:
		"missing_key":
			return "未检测到 DeepSeek API Key。请在本机 .env.local 中配置 DEEPSEEK_API_KEY 后重新启动游戏。"
		"transport":
			return "暂时无法连接 DeepSeek 服务。请检查网络后点击「重新生成」重试。"
		"malformed_stream":
			return "收到了无法识别的响应数据。可点击「重新生成」重试。"
		_:
			if code.begins_with("http_"):
				return "DeepSeek 服务返回错误（%s）。可稍后点击「重新生成」重试。" % code
			return "出现未知错误。可点击「重新生成」重试。"


func _set_gen_state(state: GenState) -> void:
	_gen_state = state
	_update_controls()


func _update_controls() -> void:
	var streaming := _gen_state == GenState.STREAMING
	send_button.disabled = streaming or player_input.text.strip_edges().is_empty()
	cancel_button.disabled = not streaming
	regenerate_button.visible = not streaming and not _last_player_text.is_empty()


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
