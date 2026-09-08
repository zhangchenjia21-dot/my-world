extends PanelContainer

## 叶 UI 只接收观测 L3 的安全展示行；无 Runtime/Provider/World 引用。
var _scroll: ScrollContainer
var _rows: VBoxContainer

func _ready() -> void:
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.custom_minimum_size.y = 140
	add_child(_scroll)
	# 轨道固有宽度参与布局，防止放大后的文字被滚动条覆盖。
	var track := _scroll.get_v_scroll_bar().get_theme_stylebox("scroll").duplicate() as StyleBox
	track.content_margin_left = 7
	track.content_margin_right = 7
	_scroll.get_v_scroll_bar().add_theme_stylebox_override("scroll", track)
	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows.add_theme_constant_override("separation", 6)
	_scroll.add_child(_rows)

func render(rows: Array) -> void:
	for child: Node in _rows.get_children():
		_rows.remove_child(child)
		child.queue_free()
	if rows.is_empty():
		_add_label("调试 · 本次会话暂无终态记录", false)
		return
	# 最新证据在前，每行包含回合位置，避免异步完成顺序被误读成提交顺序。
	for i: int in range(rows.size() - 1, -1, -1):
		var row: Dictionary = rows[i]
		var location := "回合 %d" % (int(row.turn) + 1) if int(row.turn) >= 0 else "本次会话"
		var text := "%s · %s：%s" % [location, row.lane_label, row.terminal_label]
		if row.change != "unknown": text += " · " + String(row.change_label)
		var labels := {"changes": "世界变化", "knowledge": "认知事件", "actors": "新人物", "bindings": "身份绑定", "added": "新增", "removed": "减少", "updated": "更新", "total": "当前条目"}
		for key: String in row.counts: text += " · %s %d" % [labels[key], row.counts[key]]
		if row.elapsed_ms >= 0: text += " · %.1fs" % (float(row.elapsed_ms) / 1000.0)
		if not String(row.reason).is_empty(): text += " · " + String(row.reason)
		_add_label(text, row.terminal in ["failed", "unavailable", "stale", "cancelled"])

func _add_label(text: String, abnormal: bool) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 20)
	if abnormal: label.theme_type_variation = &"LabelDanger"
	_rows.add_child(label)
