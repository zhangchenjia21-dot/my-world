extends RefCounted

const Contract := preload("res://src/信息整理/L0_公理层/信息整理契约.gd")

# 拒绝超深 JSON 后才交给 JSON parser；仅扫描括号/字符串语法，不解释任何文案。
static func parse(text: String, lived: bool = false, bindings: Dictionary = {}) -> Dictionary:
	if text.to_utf8_buffer().size() > Contract.MAX_RESPONSE_BYTES:
		return {}
	var depth := 0
	var quoted := false
	var escaped := false
	for character: String in text:
		if quoted:
			if escaped:
				escaped = false
			elif character == "\\":
				escaped = true
			elif character == "\"":
				quoted = false
		elif character == "\"":
			quoted = true
		elif character == "{" or character == "[":
			depth += 1
			if depth > 8:
				return {}
		elif character == "}" or character == "]":
			depth -= 1
	var parser := JSON.new()
	if parser.parse(text) != OK:
		return {}
	if not lived:
		return Contract.normalize(parser.data)
	var value: Variant = parser.data
	if not value is Dictionary or not value.has("character") or not value.has("experiences"):
		return {}
	for key: Variant in value:
		if key not in ["character", "experiences", "people_updates", "open_threads"]:
			return {}
	if not Contract.threads_valid(value.get("open_threads")):
		return {}
	var base := Contract.normalize({"character": value.character, "experiences": value.experiences})
	if base.is_empty():
		return {}
	base["people_updates"] = Contract.resolve_people(value.get("people_updates", []), bindings)
	base["open_threads"] = value.get("open_threads")
	return base
