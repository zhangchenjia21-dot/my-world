class_name StructuredAdjudicationResponseParser
extends RefCounted

const Rules := preload("res://src/行动判定/L0_公理层/公开D20判定规则.gd")


func parse(text: String, action_id: String) -> Dictionary:
	var parser := JSON.new()
	if parser.parse(text.strip_edges()) != OK:
		return Rules.failure("invalid_adjudication_json", "Provider adjudication 不是有效 JSON。")
	return Rules.validate_envelope(parser.data, action_id)
