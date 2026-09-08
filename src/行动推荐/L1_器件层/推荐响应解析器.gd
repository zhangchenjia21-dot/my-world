extends RefCounted

const Contract := preload("res://src/行动推荐/L0_公理层/行动推荐契约.gd")

static func parse(text: String) -> Array:
	if text.to_utf8_buffer().size() > Contract.RESPONSE_BYTES:
		return []
	# 在 JSON parser 之前限制嵌套；字符串内括号和转义只按语法扫描，不作语义修复。
	var depth := 0
	var quoted := false
	var escaped := false
	for character: String in text:
		if quoted:
			if escaped:
				escaped = false
			elif character == "\\":
				escaped = true
			elif character == '"':
				quoted = false
		elif character == '"':
			quoted = true
		elif character == "{" or character == "[":
			depth += 1
			if depth > 3:
				return []
		elif character == "}" or character == "]":
			depth -= 1
			if depth < 0:
				return []
	var json := JSON.new()
	if json.parse(text) != OK:
		return []
	return Contract.normalize(json.data)
