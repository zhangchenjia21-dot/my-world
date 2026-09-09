extends VBoxContainer

## 叶视图仅消费事务 L3 的安全快照，不接收 Runtime/World 或模型原文。
func render(threads: Array) -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	add_theme_constant_override("separation", 12)
	if threads.is_empty():
		_line(self, "目前没有需要持续跟进的事务。", 20)
	for thread: Dictionary in threads:
		var card := VBoxContainer.new()
		card.add_theme_constant_override("separation", 6)
		add_child(card)
		_line(card, thread.title, 22)
		_line(card, thread.summary, 20)
		for detail: String in thread.details:
			_line(card, "• " + detail, 20)

func _line(parent: Control, text: String, font_size: int) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
