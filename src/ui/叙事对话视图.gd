extends PanelContainer

## G2-04 Narrative Conversation View —— 中央 NarrativeHost 的玩家界面，
## Domain Conversation（src/domain/会话.gd）的 projection。
##
## UI 不再持有第二套 history / generation flags（AC-09）：Turn ordering、accepted truth、
## Generation State、retry / regenerate / correction 全部由 conversation 拥有；
## 本视图只消费 conversation 信号做渲染，并把 adapter 事件翻译成 conversation 调用。
##
## 只消费运行时模型 Provider L3 seam，不持有 profile、credential 或 HTTP/SSE transport。

const ADAPTER := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")
const Conversation := preload("res://src/domain/会话.gd")
const ContextAssembler := preload("res://src/context/L3_外交层/上下文组装公开接口.gd")

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
@onready var action_status_panel: PanelContainer = %ActionStatusPanel
@onready var action_status_label: Label = %ActionStatusLabel
@onready var retry_action_button: Button = %RetryActionButton

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

## G4-08B：Game-local materialized Public d20 capability 存在时由 Shell 注入的
## 行动判定 Host（L3 seam）。null = 无 Expansion，保持既有 G4-07 单次续玩路径。
var action_adjudication: Node = null

## opening-pending（durable accepted Conversation = 0）时锁住玩家输入；由 Shell 驱动。
var _opening_gate := false
## 重开已存在 Game 时发现恰好一个未完成的 durable d20 行动：门控新输入直到重试落地。
var _unresolved_reopen_pending := false
## 未知 action_resolution capability：玩家可见的 fail-loud 状态，锁输入且不走 legacy。
var _unsupported_capability := false

## Public d20 的 UI 侧 action identity：一次玩家行动铸造一个 opaque action_id，
## 失败/取消/重开重试必须复用；只有玩家编辑替换文本才铸新 id（INV-D20-02）。
var _pending_action_id := ""
var _pending_action_text := ""
## durable resolution 已存在但 narrative 未 accepted：只允许「重试行动」，不得编辑替换。
var _pending_action_has_resolution := false
## Narrating 期间 transient 展示的 durable check id；accepted 后由历史卡重建接管。
var _transient_check_id := ""
var _adjudication_active := false

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
	retry_action_button.pressed.connect(_on_retry_action_pressed)
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
	if not _startup_ready or _opening_gate or _unsupported_capability or conversation == null or text.is_empty() or conversation.is_generating() or _adjudication_active:
		return
	if action_adjudication != null:
		_start_public_d20_action(text, true)
		return

	if conversation.begin_turn(text) == null:
		return
	player_input.clear()
	_hide_error()
	_start_request()


func _on_cancel_pressed() -> void:
	# Public d20 adjudication 进行中：取消路由到 Host 的 adapter。
	if _adjudication_active and action_adjudication != null:
		action_adjudication.cancel()
		return
	if conversation == null or not conversation.is_generating():
		return
	# Opening streaming 期间取消必须路由到 opening runtime 的 adapter；
	# 只有普通玩家 turn 才走本视图自己的 adapter。
	if opening_runtime != null and opening_runtime.provider_adapter != null and opening_runtime.provider_adapter.is_busy():
		opening_runtime.cancel()
	elif adapter != null:
		adapter.cancel()


## 「重试行动」：durable resolution 已存在或判定中途失败时，用同一 stable action_id/text
## 重走 Host——M1/M1C01 的 no-reroll / replay 语义由 backend 拥有。
func _on_retry_action_pressed() -> void:
	if action_adjudication == null or _adjudication_active or _pending_action_id.is_empty():
		return
	_hide_error()
	_start_public_d20_action(_pending_action_text, false)


## Public d20 路由：UI 不先调 conversation.begin_turn；acceptance ordering 归 Host。
func _start_public_d20_action(text: String, fresh: bool) -> void:
	if fresh:
		_pending_action_id = "action-%s" % Crypto.new().generate_random_bytes(16).hex_encode()
		_pending_action_text = text
		_pending_action_has_resolution = false
		player_input.clear()
	_hide_error()
	_adjudication_active = true
	_update_controls()
	var started: Dictionary = action_adjudication.start_action(_pending_action_id, _pending_action_text)
	_handle_adjudication_result(started, true)


## Host 终态/即时返回统一落点。synchronous=true 表示来自 start_action 的即时返回，
## 此时 streaming 是正常起始而非终态。
func _handle_adjudication_result(result: Dictionary, synchronous: bool = false) -> void:
	if not _adjudication_active:
		return
	var status := String(result.get("status", ""))
	if status == "streaming":
		if String(result.get("stage", "")) == "resolution_narrative":
			# durable check 已存在：立即公开 Program 结果（transient），不等 narrative 完成。
			var check := _durable_check_for(_pending_action_id)
			if not check.is_empty():
				_pending_action_has_resolution = true
				_transient_check_id = String(check.check_id)
				_append_mechanic_card(check, true)
		return
	_adjudication_active = false
	if status == "accepted" or status == "already_accepted":
		# accepted 后 transient 卡转为历史卡（不重绘，只改 meta）；
		# 历史重建时由 _render_restored_entries 按 durable truth 重建。
		if not _transient_check_id.is_empty():
			var card := _find_mechanic_card(_transient_check_id)
			if card != null:
				card.set_meta("transient", false)
		_pending_action_id = ""
		_pending_action_text = ""
		_pending_action_has_resolution = false
		_transient_check_id = ""
		_unresolved_reopen_pending = false
		_hide_error()
		_update_controls()
		return
	# 失败/取消：按是否已有 durable resolution 区分「只能重试」与「可编辑替换」。
	var code := String(result.get("code", status))
	_pending_action_has_resolution = not _durable_check_for(_pending_action_id).is_empty() \
		or not _durable_no_check_for(_pending_action_id).is_empty()
	_hide_error()
	_update_controls()


func _on_adjudication_finished(result: Dictionary) -> void:
	_handle_adjudication_result(result)


func _plain_adjudication_failure(code: String) -> String:
	match code:
		"cancelled":
			return "已取消。"
		"transport":
			return "暂时无法连接当前模型服务。"
		"missing_key":
			return "未检测到当前所选模型的 API Key，请在本机 .env.local 中配置后重试。"
		"malformed_stream", "invalid_adjudication_envelope", "invalid_check_proposal":
			return "判定服务返回了无法识别的内容。"
		"empty_generation":
			return "本次没有生成有效叙事。"
		_:
			if code.begins_with("http_"):
				return "当前模型服务暂时返回异常。"
			return ""


## durable Game-local Public d20 记录的只读投影；UI 永不写入。
func _durable_public_d20_checks() -> Array:
	if session_runtime == null:
		return []
	return session_runtime.world_state.get("expansion_runtime", {}).get("public_d20_checks", [])


func _durable_public_d20_no_checks() -> Array:
	if session_runtime == null:
		return []
	return session_runtime.world_state.get("expansion_runtime", {}).get("public_d20_no_check_actions", [])


func _durable_check_for(action_id: String) -> Dictionary:
	for value: Variant in _durable_public_d20_checks():
		if value is Dictionary and String((value as Dictionary).get("action_id", "")) == action_id:
			return (value as Dictionary).duplicate(true)
	return {}


func _durable_no_check_for(action_id: String) -> Dictionary:
	for value: Variant in _durable_public_d20_no_checks():
		if value is Dictionary and String((value as Dictionary).get("action_id", "")) == action_id:
			return (value as Dictionary).duplicate(true)
	return {}


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
	# Public d20 受检行动：Host 在 begin_turn 时 durable check 已存在；
	# 把 transient 卡移到 Player 之后、GM 之前，冻结 Player → card → GM 顺序。
	if action_adjudication != null and not _transient_check_id.is_empty():
		var card := _find_mechanic_card(_transient_check_id)
		if card != null:
			entries.move_child(card, entries.get_child_count() - 1)
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


## Public d20 行动被 Host accepted 后，玩家回合由 Host 通过 Conversation 落地；
## 历史重建时 mechanic card 由 durable projection 接管。
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
	_recover_pending_d20_action()
	_update_controls()
## Mechanic card 是 durable Program truth 的只读投影：UI 不掷骰、不选面、不算 total、
## 不改 DC/outcome。transient=true 表示 Narrating 期间的即时公开卡。
## 同一 durable check_id 至多一张可见投影：重复通知时复用既有节点，不追加。
func _append_mechanic_card(check: Dictionary, transient: bool = false) -> void:
	var check_id := String(check.get("check_id", ""))
	if not check_id.is_empty():
		var existing := _find_mechanic_card(check_id)
		if existing != null:
			# 已存在同 id 投影：更新内容并复用节点，不追加第二张。
			_update_mechanic_card(existing, check, transient)
			return
	var card := PanelContainer.new()
	card.name = "MechanicCard_%s" % check_id
	card.set_meta("mechanic_card", true)
	card.set_meta("check_id", check_id)
	card.set_meta("transient", transient)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 2)
	card.add_child(column)

	var title := Label.new()
	title.text = "判定｜%s" % String(check.get("intent", ""))
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.82, 0.76, 0.60))
	column.add_child(title)

	var stance_text := String({"normal": "普通", "advantage": "优势", "disadvantage": "劣势"}.get(String(check.get("stance", "normal")), "普通"))
	var raw: Array = check.get("raw_rolls", [])
	var raw_text := ""
	for face: Variant in raw:
		raw_text += (" / " if not raw_text.is_empty() else "") + str(int(face))
	var lines := PackedStringArray([
		"DC %d" % int(check.get("dc", 0)),
		"修正 %+d · %s" % [int(check.get("modifier", 0)), String(check.get("modifier_reason", ""))],
		"%s · %s" % [stance_text, String(check.get("situation_reason", ""))],
		"骰面 %s → %d" % [raw_text, int(check.get("selected_roll", 0))],
		"总计 %d" % int(check.get("total", 0)),
	])
	var detail := Label.new()
	detail.text = "\n".join(lines)
	detail.add_theme_font_size_override("font_size", 13)
	detail.add_theme_color_override("font_color", Color(0.72, 0.74, 0.80))
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(detail)

	var outcome := Label.new()
	var succeeded := String(check.get("outcome", "")) == "success"
	outcome.text = "成功" if succeeded else "失败"
	outcome.add_theme_font_size_override("font_size", 15)
	outcome.add_theme_color_override("font_color", Color(0.58, 0.78, 0.62) if succeeded else Color(0.90, 0.52, 0.46))
	column.add_child(outcome)
	if not succeeded:
		var stakes := Label.new()
		stakes.text = "失败代价：%s" % String(check.get("failure_stakes", ""))
		stakes.add_theme_font_size_override("font_size", 13)
		stakes.add_theme_color_override("font_color", Color(0.85, 0.62, 0.52))
		stakes.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(stakes)

	entries.add_child(card)


## 已存在同 check_id 投影时复用节点并刷新内容；不追加第二张卡。
func _update_mechanic_card(card: PanelContainer, check: Dictionary, transient: bool) -> void:
	card.set_meta("transient", transient)
	var column: VBoxContainer = card.get_child(0)
	var title: Label = column.get_child(0)
	title.text = "判定｜%s" % String(check.get("intent", ""))
	var detail: Label = column.get_child(1)
	var stance_text := String({"normal": "普通", "advantage": "优势", "disadvantage": "劣势"}.get(String(check.get("stance", "normal")), "普通"))
	var raw: Array = check.get("raw_rolls", [])
	var raw_text := ""
	for face: Variant in raw:
		raw_text += (" / " if not raw_text.is_empty() else "") + str(int(face))
	detail.text = "\n".join(PackedStringArray([
		"DC %d" % int(check.get("dc", 0)),
		"修正 %+d · %s" % [int(check.get("modifier", 0)), String(check.get("modifier_reason", ""))],
		"%s · %s" % [stance_text, String(check.get("situation_reason", ""))],
		"骰面 %s → %d" % [raw_text, int(check.get("selected_roll", 0))],
		"总计 %d" % int(check.get("total", 0)),
	]))
	var outcome: Label = column.get_child(2)
	var succeeded := String(check.get("outcome", "")) == "success"
	outcome.text = "成功" if succeeded else "失败"
	outcome.add_theme_color_override("font_color", Color(0.58, 0.78, 0.62) if succeeded else Color(0.90, 0.52, 0.46))
	if column.get_child_count() > 3:
		var stakes: Label = column.get_child(3)
		stakes.text = "失败代价：%s" % String(check.get("failure_stakes", ""))


func _find_mechanic_card(check_id: String) -> PanelContainer:
	for child: Node in entries.get_children():
		if child.has_meta("mechanic_card") and String(child.get_meta("check_id")) == check_id:
			return child as PanelContainer
	return null


## 历史重建：accepted（narrative_accepted=true）的 durable check 按其 accepted_turn_index
## 落在对应 Player/GM 对之间；NO_CHECK replay marker 永不渲染为骰卡。
func _mechanic_cards_by_turn() -> Dictionary:
	var by_turn: Dictionary = {}
	for value: Variant in _durable_public_d20_checks():
		var check := value as Dictionary
		if check == null or not bool(check.get("narrative_accepted", false)):
			continue
		by_turn[int(check.get("accepted_turn_index", -1))] = check
	return by_turn


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
			return "未检测到当前所选模型的 API Key。请在本机 .env.local 中配置对应凭据后重新启动游戏。"
		"transport":
			return "暂时无法连接当前模型服务。请检查网络后点击「重新生成」重试。"
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
				return "当前模型服务返回错误（%s）。可稍后点击「重新生成」重试。" % code
			return "出现未知错误。可点击「重新生成」重试。"


func _update_controls() -> void:
	var streaming: bool = conversation != null and conversation.is_generating()
	var action_blocked := _adjudication_active or _unresolved_reopen_pending
	send_button.disabled = not _startup_ready or _opening_gate or action_blocked or _unsupported_capability or streaming or player_input.text.strip_edges().is_empty()
	cancel_button.disabled = not _startup_ready or not (streaming or _adjudication_active)
	# opening Turn（pending_player_text 为空）不显示「重新生成」：第一幕的重试由
	# Shell 的 Opening banner 拥有，避免把 GM-only Opening 当成可 regenerate 的玩家回合。
	# Public d20 会话在 v0.1 不提供旧式 generic Regenerate（accepted turn 拥有 durable
	# Program resolution / exact NO_CHECK identity；旧路径会绕过 stable action identity）。
	var latest: RefCounted = conversation.latest_turn() if conversation != null else null
	var opening_turn := latest != null and String(latest.pending_player_text).is_empty()
	regenerate_button.visible = _startup_ready and action_adjudication == null and not _unsupported_capability and not streaming and latest != null and not opening_turn
	retry_action_button.visible = action_adjudication != null and not _adjudication_active and not _pending_action_id.is_empty()
	player_input.editable = _startup_ready and not _opening_gate and not action_blocked and not _unsupported_capability and not (_pending_action_has_resolution and not _pending_action_id.is_empty())
	_update_action_status_panel(streaming)


func _update_action_status_panel(_streaming: bool) -> void:
	if action_adjudication == null:
		action_status_panel.visible = false
		return
	if _adjudication_active:
		action_status_label.text = "正在判断行动风险…"
		action_status_panel.visible = true
		return
	if _unresolved_reopen_pending:
		action_status_label.text = "上一次行动尚未完成；点击「重试行动」继续，判定结果保持不变。"
		action_status_panel.visible = true
		return
	if not _pending_action_id.is_empty():
		action_status_label.text = "行动未完成；%s" % ("判定结果已保留，点击「重试行动」继续。" if _pending_action_has_resolution else "可修改后重新提交，或点击「重试行动」。")
		action_status_panel.visible = true
		return
	action_status_panel.visible = false


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


## Application Shell 在检测到 Game-local materialized Public d20 capability 后注入
## 行动判定 Host；同时检查是否有重开前未完成的 durable 行动需要门控恢复。
func bind_action_adjudication(host: Node) -> void:
	action_adjudication = host
	if action_adjudication != null:
		action_adjudication.finished.connect(_on_adjudication_finished)
		action_adjudication.request_assembled.connect(_on_adjudication_stage_started)
	_recover_pending_d20_action()
	_update_controls()


## Host 开始 resolution_narrative 时 durable check 已存在：立即公开 Program 结果，
## 不等 narrative 完成（INV-D20-06）。
func _on_adjudication_stage_started(stage: String, _messages: Array) -> void:
	if not _adjudication_active or String(stage) != "resolution_narrative":
		return
	var check := _durable_check_for(_pending_action_id)
	if not check.is_empty():
		_pending_action_has_resolution = true
		_transient_check_id = String(check.check_id)
		_append_mechanic_card(check, true)


## 重开恢复：只读 durable replay 状态。恰好一个 narrative_accepted=false 的行动
## 门控输入并提供「重试行动」；多于一个不猜顺序，显式失败。
func _recover_pending_d20_action() -> void:
	_unresolved_reopen_pending = false
	if action_adjudication == null or session_runtime == null or _adjudication_active:
		return
	if not _pending_action_id.is_empty():
		return
	var unresolved: Array = []
	for value: Variant in _durable_public_d20_checks():
		var check := value as Dictionary
		if check != null and not bool(check.get("narrative_accepted", false)):
			unresolved.append({"action_id": String(check.get("action_id", "")), "player_text": String(check.get("player_text", "")), "has_resolution": true})
	for value: Variant in _durable_public_d20_no_checks():
		var resolution := value as Dictionary
		if resolution != null and not bool(resolution.get("narrative_accepted", false)):
			unresolved.append({"action_id": String(resolution.get("action_id", "")), "player_text": String(resolution.get("player_text", "")), "has_resolution": true})
	if unresolved.is_empty():
		return
	if unresolved.size() > 1:
		_unresolved_reopen_pending = true
		_pending_action_id = ""
		_show_error("存在多个未完成的判定行动；为保护进度，本局已暂停输入。请返回主菜单后重试。")
		return
	_pending_action_id = String(unresolved[0].action_id)
	_pending_action_text = String(unresolved[0].player_text)
	_pending_action_has_resolution = true
	_unresolved_reopen_pending = true


## 未知 action_resolution capability：玩家可见的 fail-loud 状态。
## 本局 Game 数据保持完整，未来支持该能力的 build 可重新打开；
## 但当前 build 不得把 authored prose 当可执行规则，也不退回 legacy 路径。
func show_unsupported_capability() -> void:
	_unsupported_capability = true
	_show_error("本局包含当前版本不支持的行动判定规则。为保护进度，本局已暂停输入；请使用支持该规则的版本重新打开。")
	_update_controls()


## created Game 且 durable accepted Conversation = 0：第一幕 accepted 前锁住玩家输入。
func set_opening_gate(active: bool) -> void:
	_opening_gate = active
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
	if action_adjudication != null:
		var adjudication_callback := Callable(self, "_on_adjudication_finished")
		if action_adjudication.finished.is_connected(adjudication_callback):
			action_adjudication.finished.disconnect(adjudication_callback)
		var stage_callback := Callable(self, "_on_adjudication_stage_started")
		if action_adjudication.request_assembled.is_connected(stage_callback):
			action_adjudication.request_assembled.disconnect(stage_callback)
		action_adjudication = null
	_pending_action_id = ""
	_pending_action_text = ""
	_pending_action_has_resolution = false
	_transient_check_id = ""
	_adjudication_active = false
	_unresolved_reopen_pending = false
	_unsupported_capability = false
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
	adapter.name = "RuntimeModelProviderAdapter"
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
## accepted Public d20 check 的 mechanic card 冻结为 Player → card → GM 顺序重建。
func _render_restored_entries() -> void:
	var cards := _mechanic_cards_by_turn()
	var index := 0
	for entry_value: Variant in conversation.get_accepted_entries():
		var entry := entry_value as Dictionary
		var player_text := String(entry.player_text)
		if not player_text.is_empty():
			_append_player_entry(player_text)
		if cards.has(index):
			_append_mechanic_card(cards[index] as Dictionary)
		_begin_gm_entry(player_text.is_empty())
		_current_gm_content.add_text(String(entry.gm_text))
		index += 1


func redraw_from_conversation() -> void:
	_clear_rendered_entries()
	_render_restored_entries()
	_follow_scroll = true
	_follow_scroll_if_needed()
