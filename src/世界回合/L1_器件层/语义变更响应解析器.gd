class_name SemanticChangeResponseParser
extends RefCounted

const Rules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")


## 这里只解析独立分析 lane 的 machine data，不接触或评判玩家可见 Narrative。
## 任一 shape/size 错误均返回 fail-soft 结果，上层不会把部分数据提交为世界事实。
func parse(response_text: String) -> Dictionary:
	var body := _strip_code_fence(response_text.strip_edges())
	if body.is_empty():
		return _failure("empty_analysis")
	var json := JSON.new()
	if json.parse(body) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return _failure("malformed_analysis")
	var changes_value: Variant = (json.data as Dictionary).get("changes", null)
	if typeof(changes_value) != TYPE_ARRAY:
		return _failure("invalid_changes")
	if (changes_value as Array).size() > Rules.MAX_CHANGES_PER_TURN:
		return _failure("too_many_changes")
	var changes: Array = []
	for value: Variant in changes_value as Array:
		if typeof(value) != TYPE_STRING:
			return _failure("invalid_change")
		var change := String(value).strip_edges()
		if change.is_empty() or change.length() > Rules.MAX_CHANGE_CHARS:
			return _failure("invalid_change")
		if not changes.has(change):
			changes.append(change)
	return {
		"success": true,
		"status": "no_changes" if changes.is_empty() else "changes_ready",
		"changes": changes,
	}


func _strip_code_fence(text: String) -> String:
	if not text.begins_with("```"):
		return text
	var first_newline := text.find("\n")
	if first_newline < 0 or not text.ends_with("```"):
		return text
	return text.substr(first_newline + 1, text.length() - first_newline - 4).strip_edges()


func _failure(status: String) -> Dictionary:
	return {"success": false, "status": status, "changes": []}
