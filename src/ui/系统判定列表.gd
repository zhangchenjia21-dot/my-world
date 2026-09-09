extends VBoxContainer

## 只消费机制 L3 的公开结构，不接收 Runtime、控制载荷或可变事实 owner。
func render(checks: Array) -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	add_theme_constant_override("separation", 16)
	_line(self, "近期公开判定", 22)
	if checks.is_empty(): _line(self, "暂无公开判定记录。")
	for record: Dictionary in checks:
		var card := VBoxContainer.new()
		card.add_theme_constant_override("separation", 6)
		add_child(card)
		_line(card, "第 %d 回合 · %s" % [record.accepted_turn, record.intent], 22)
		_line(card, "结果：" + {"success":"成功", "failure":"失败"}.get(record.outcome, record.outcome))
		_line(card, "d20：%s → %d + %d = %d vs DC %d" % [str(record.get("raw_rolls", [])), record.selected_roll, record.modifier, record.total, record.dc])
		_line(card, "形势：%s · %s" % [{"normal":"正常", "advantage":"优势", "disadvantage":"劣势"}.get(record.stance, record.stance), record.get("situation_reason", "")])
		_line(card, "修正：" + String(record.get("modifier_reason", "")))
		_line(card, "成功意味着：" + record.success_intent)
		_line(card, "失败风险：" + record.failure_stakes)

func _line(parent: Control, text: String, font_size: int = 20) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
