extends PanelContainer

const Palette := preload("res://src/ui/视觉舒适调色板.gd")

var toggle: Button
var expanded_body: VBoxContainer

## 叶卡只消费五个已验证展示字段。重建默认折叠，无身份查找、存储或 Provider 权限。
func render(snapshot: Dictionary) -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	var margin := MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)
	toggle = Button.new()
	toggle.toggle_mode = true
	toggle.alignment = HORIZONTAL_ALIGNMENT_LEFT
	toggle.clip_text = true
	toggle.text = "▸ " + String(snapshot.display_name)
	toggle.tooltip_text = String(snapshot.display_name)
	column.add_child(toggle)
	if not String(snapshot.headline).is_empty():
		_label(column, snapshot.headline, Palette.TEXT_SECONDARY)
	expanded_body = VBoxContainer.new()
	expanded_body.add_theme_constant_override("separation", 8)
	expanded_body.visible = false
	column.add_child(expanded_body)
	for field: String in ["summary", "relationship"]:
		if not String(snapshot[field]).is_empty():
			_label(expanded_body, snapshot[field], Palette.TEXT_PRIMARY)
	for detail: String in snapshot.details:
		_label(expanded_body, "• " + detail, Palette.TEXT_PRIMARY)
	toggle.toggled.connect(func(pressed: bool) -> void:
		expanded_body.visible = pressed
		toggle.text = ("▾ " if pressed else "▸ ") + String(snapshot.display_name))

func _label(parent: Control, content: String, color: Color) -> void:
	var label := Label.new()
	label.text = content
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
