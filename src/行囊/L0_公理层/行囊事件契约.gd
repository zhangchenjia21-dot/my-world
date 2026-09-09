extends RefCounted

const SCHEMA := "player_inventory.v0.1"
const MAX_ITEMS := 64
const MAX_OPS := 8

static func exact(value: Variant, fields: Array) -> bool:
	if not value is Dictionary or value.size() != fields.size(): return false
	for field: String in fields:
		if not value.has(field): return false
	return true

static func text(value: Variant, limit: int) -> bool:
	return value is String and not value.strip_edges().is_empty() and value.length() <= limit

## 只检查机器结构；不按名称、动词或类型推断持有/消耗语义。非法子字段整体隔离。
static func parse(value: Variant) -> Dictionary:
	var empty := {"add":[],"update":[],"remove":[]}
	if value == null: return {"valid":true,"updates":empty}
	if not exact(value,["add","update","remove"]): return {"valid":false,"updates":empty}
	var count := 0
	for kind: String in empty:
		if not value[kind] is Array: return {"valid":false,"updates":empty}
		count += value[kind].size()
		for op: Variant in value[kind]:
			var fields := ["item_ref"] if kind == "remove" else (["name","summary"] if kind == "add" else ["item_ref","name","summary"])
			if not exact(op,fields): return {"valid":false,"updates":empty}
			if kind != "add" and not text(op.item_ref,128): return {"valid":false,"updates":empty}
			if kind != "remove" and (not text(op.name,120) or not text(op.summary,600)): return {"valid":false,"updates":empty}
	if count > MAX_OPS: return {"valid":false,"updates":empty}
	return {"valid":true,"updates":value.duplicate(true)}

static func event_id(index: int, prefix: String, gm_hash: String, ops: Array) -> String:
	return JSON.stringify([SCHEMA,index,prefix,gm_hash,ops],"",true).sha256_text()

static func item_id(index: int, prefix: String, ordinal: int, material: Dictionary) -> String:
	return JSON.stringify([SCHEMA,index,prefix,ordinal,material],"",true).sha256_text()

## 内部事件也必须逐项验证与内容校验；损坏事件整体不参与 fold，不进行语义修复。
static func valid_event(value: Variant, index: int, version: Dictionary) -> bool:
	if not exact(value,["source_turn_index","prefix","source_gm_sha256","ops","id"]): return false
	if not value.source_turn_index is float and not value.source_turn_index is int: return false
	if value.source_turn_index != index or value.prefix != version.prefix or value.source_gm_sha256 != version.gm_hash: return false
	if not value.ops is Array or value.ops.size() > MAX_OPS: return false
	var seen := {}
	for op: Variant in value.ops:
		if not op is Dictionary or op.get("kind") not in ["add","update","remove"]: return false
		if not exact(op,["kind","item_id"] if op.kind == "remove" else ["kind","item_id","name","summary"]): return false
		if not text(op.item_id,64) or op.item_id.length() != 64 or seen.has(op.item_id): return false
		seen[op.item_id] = true
		if op.kind != "remove" and (not text(op.name,120) or not text(op.summary,600)): return false
	return value.id == event_id(index,value.prefix,value.source_gm_sha256,value.ops)
