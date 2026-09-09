extends RefCounted

const SURFACES := ["character","important_experiences","people","threads","inventory","system"]
const HIDEABLE := ["people","important_experiences"]
const MAX_DEPTH := 8
const MAX_COMPONENTS := 4096
const MAX_LIST := 1024
const MAX_TEXT := 8192
const MAX_TOTAL_TEXT := 1048576

static func exact(value: Variant, fields: Array) -> bool:
	if not value is Dictionary or value.size() != fields.size(): return false
	for field: String in fields:
		if not value.has(field): return false
	return true

static func token(value: Variant, limit: int = 128) -> bool:
	if not value is String or value.is_empty() or value.length() > limit: return false
	for c: String in value:
		if not c in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-": return false
	return true

static func opaque(value: Variant) -> bool:
	if not value is String or value.length() != 64: return false
	for c: String in value:
		if not c in "0123456789abcdef": return false
	return true

## 第一方封闭树；任何未知字段/重复身份/超界使整个贡献局部拒绝，不执行数据中的指令。
static func valid(definition: Variant) -> bool:
	if not exact(definition,["surface","children"]) or definition.surface not in SURFACES: return false
	return _children(definition.children,0,{"ids":{},"keys":{},"count":0,"chars":0},definition.surface)

static func _text(value: Variant, state: Dictionary) -> bool:
	if not value is String or value.length() > MAX_TEXT: return false
	state.chars += value.length()
	return state.chars <= MAX_TOTAL_TEXT

static func _children(value: Variant, depth: int, state: Dictionary, surface: String) -> bool:
	if not value is Array or value.size() > MAX_LIST or depth > MAX_DEPTH: return false
	for node: Variant in value:
		if not _node(node,depth,state,surface): return false
	return true

static func _node(node: Variant, depth: int, state: Dictionary, surface: String) -> bool:
	if not node is Dictionary: return false
	var fields: Array
	match node.get("kind"):
		"section": fields=["kind","component_id","title","children"]
		"text": fields=["kind","component_id","text","role"]
		"fact_list": fields=["kind","component_id","title","items"]
		"field_list": fields=["kind","component_id","title","fields"]
		"card": fields=["kind","component_id","title","subtitle","children","collapsible","visibility_key"]
		_: return false
	if not exact(node,fields) or not token(node.component_id) or state.ids.has(node.component_id): return false
	state.ids[node.component_id]=true; state.count+=1
	if state.count > MAX_COMPONENTS: return false
	if node.kind == "text": return node.role in ["body","heading","muted"] and _text(node.text,state)
	if not _text(node.title,state): return false
	if node.kind == "card":
		if not node.collapsible is bool or not _text(node.subtitle,state): return false
		if not node.visibility_key is String: return false
		if not node.visibility_key.is_empty():
			if surface not in HIDEABLE or depth != 0 or not opaque(node.visibility_key) or state.keys.has(node.visibility_key): return false
			state.keys[node.visibility_key]=true
	if node.kind in ["section","card"]: return _children(node.children,depth+1,state,surface)
	var values: Variant=node.items if node.kind=="fact_list" else node.fields
	if not values is Array or values.size()>MAX_LIST: return false
	for value: Variant in values:
		if node.kind=="fact_list":
			if not _text(value,state): return false
		elif not exact(value,["label","value"]) or not _text(value.label,state) or not _text(value.value,state): return false
	return true
