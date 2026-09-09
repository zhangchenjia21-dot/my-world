extends VBoxContainer

## 只呈现 L3 name/summary；物品操作始终通过普通自然语言行动，不提供第二 mutation 入口。
func render(items: Array) -> void:
	for child: Node in get_children():
		remove_child(child); child.queue_free()
	add_theme_constant_override("separation",12)
	_line("当前行囊",22)
	if items.is_empty(): _line("当前没有已记录的随身物品。",20)
	for item: Dictionary in items:
		_line(item.name,22); _line(item.summary,20)

func _line(text: String, font_size: int) -> void:
	var label := Label.new()
	label.text = text; label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",font_size)
	add_child(label)
