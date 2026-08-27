extends RefCounted

## Opaque World materialization 的 JSON 完整性边界。
##
## 本器件只验证结构可持久化并生成 deterministic representation；它不解释 document 内
## 的 NPC/Faction/Item/lore 含义。递归排序 String keys，避免 Dictionary insertion order
## 改变同一 durable intent 的 fingerprint。

const MAX_DEPTH := 64


static func encode_document(document: Variant) -> Dictionary:
	var encoded := encode_json_value(document)
	if not encoded.ok:
		return encoded
	if typeof(encoded.value) != TYPE_DICTIONARY:
		return {"ok": false, "error": "World materialization root must be a Dictionary"}
	return {
		"ok": true,
		"json": encoded.json,
		"document": encoded.value,
	}


## 为非 World 的 current materialization 提供同一 deterministic JSON seam。
## 只验证 JSON representation；Conversation accepted 语义仍由 Conversation Domain 校验。
static func encode_json_value(value: Variant) -> Dictionary:
	var error := _validation_error(value, "$", 0)
	if not error.is_empty():
		return {"ok": false, "error": error}
	var canonical: Variant = _canonicalize(value)
	var json_text := JSON.stringify(canonical, "", true, true)
	var round_trip: Variant = JSON.parse_string(json_text)
	return {
		"ok": true,
		"json": json_text,
		"value": round_trip,
	}


static func fingerprint_intent(
	game_id: String,
	mutation_id: String,
	expected_head_id: String,
	node_id: String,
	canonical_world_json: String
) -> String:
	# 长度前缀避免简单分隔符拼接产生歧义；SHA-256 只标识 durable intent，不评判内容。
	var fields := [game_id, mutation_id, expected_head_id, node_id, canonical_world_json]
	var framed := ""
	for field: String in fields:
		framed += "%d:%s" % [field.length(), field]
	return framed.sha256_text()


static func _validation_error(value: Variant, path: String, depth: int) -> String:
	if depth > MAX_DEPTH:
		return "%s exceeds maximum JSON nesting depth" % path
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return ""
		TYPE_FLOAT:
			if is_nan(value) or is_inf(value):
				return "%s contains a non-finite number" % path
			return ""
		TYPE_ARRAY:
			var array := value as Array
			for index: int in range(array.size()):
				var child_error := _validation_error(array[index], "%s[%d]" % [path, index], depth + 1)
				if not child_error.is_empty():
					return child_error
			return ""
		TYPE_DICTIONARY:
			var dictionary := value as Dictionary
			for key: Variant in dictionary:
				if typeof(key) != TYPE_STRING:
					return "%s contains a non-String Dictionary key" % path
				var child_error := _validation_error(dictionary[key], "%s.%s" % [path, key], depth + 1)
				if not child_error.is_empty():
					return child_error
			return ""
		_:
			return "%s contains non-JSON type %s" % [path, type_string(typeof(value))]


static func _canonicalize(value: Variant) -> Variant:
	if typeof(value) == TYPE_ARRAY:
		var output: Array = []
		for item: Variant in value as Array:
			output.append(_canonicalize(item))
		return output
	if typeof(value) == TYPE_DICTIONARY:
		var dictionary := value as Dictionary
		var keys: Array = dictionary.keys()
		keys.sort()
		var output: Dictionary = {}
		for key: String in keys:
			output[key] = _canonicalize(dictionary[key])
		return output
	return value
