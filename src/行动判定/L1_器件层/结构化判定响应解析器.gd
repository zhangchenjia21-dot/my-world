class_name StructuredAdjudicationResponseParser
extends RefCounted

const Rules := preload("res://src/行动判定/L0_公理层/公开D20判定规则.gd")

## Isolated control lane 在 Provider completion 后整体解析；允许无害空白与 pretty-print，
## 但整个非空响应必须且只能是一个 JSON object，不能从 prose/fence 中猜测结构。
func parse(text: String, action_id: String) -> Dictionary:
	var control := text.strip_edges()
	if control.is_empty():
		return Rules.failure("invalid_adjudication_json", "Provider adjudication control 为空。")
	var parser := JSON.new()
	if parser.parse(control) != OK:
		return Rules.failure("invalid_adjudication_json", "Provider adjudication control 不是唯一有效 JSON object。")
	return Rules.validate_envelope(parser.data, action_id)
