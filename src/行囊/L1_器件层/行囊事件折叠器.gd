extends RefCounted
const Contract := preload("res://src/行囊/L0_公理层/行囊事件契约.gd")

## 仅折叠仍匹配 accepted version 的事件；不存在的目标不复活，64是防御上限而非负重规则。
static func fold(world: Dictionary, versions: Array) -> Dictionary:
	var items := {}
	var owner: Variant = world.get("player_inventory",{})
	if not owner is Dictionary or owner.get("schema_version") != Contract.SCHEMA or not owner.get("turns_by_index") is Dictionary: return items
	for index: int in versions.size():
		if not versions[index].valid: continue
		var event: Variant = owner.turns_by_index.get(str(index))
		if not Contract.valid_event(event,index,versions[index]): continue
		for op: Dictionary in event.ops:
			if op.kind == "add" and not items.has(op.item_id) and items.size() < Contract.MAX_ITEMS:
				items[op.item_id] = {"name":op.name,"summary":op.summary}
			elif op.kind == "update" and items.has(op.item_id): items[op.item_id] = {"name":op.name,"summary":op.summary}
			elif op.kind == "remove": items.erase(op.item_id)
	return items

## 请求 refs 仅映射本次安全快照，nonce 每请求独立；stable ID 不进入 model rows。
static func request(items: Dictionary) -> Dictionary:
	var rows: Array = []
	var refs := {}
	var nonce := Crypto.new().generate_random_bytes(12).hex_encode()
	for id: String in items:
		var ref := "item-" + nonce + "-" + str(rows.size())
		refs[ref] = {"id":id,"snapshot":items[id].duplicate(true)}
		rows.append({"item_ref":ref,"name":items[id].name,"summary":items[id].summary})
	return {"rows":rows,"refs":refs}

## 返回同一 World candidate 的增量；refs 不持久化，重复/未知/快照已变目标一律丢弃。
static func candidate(world: Dictionary, versions: Array, index: int, parsed: Dictionary, refs: Dictionary) -> Dictionary:
	var items := fold(world,versions.slice(0,index))
	var counts := {"added":0,"updated":0,"removed":0,"total":items.size()}
	var result := {"world":world.duplicate(true),"counts":counts,"status":"committed"}
	if not parsed.valid:
		result.status = "invalid_inventory"
		return result
	var ops: Array = []
	var targets := {}
	for kind: String in ["update","remove"]:
		for op: Dictionary in parsed.updates[kind]: targets[op.item_ref] = int(targets.get(op.item_ref,0)) + 1
	var dropped := false
	for kind: String in ["update","remove"]:
		for op: Dictionary in parsed.updates[kind]:
			var binding: Dictionary = refs.get(op.item_ref,{})
			if targets[op.item_ref] != 1 or binding.is_empty() or not items.has(binding.id) or items[binding.id] != binding.snapshot:
				dropped = true
				continue
			var event_op := {"kind":kind,"item_id":binding.id}
			if kind == "remove":
				items.erase(binding.id); counts.removed += 1
			else:
				var material := {"name":op.name,"summary":op.summary}
				if items[binding.id] == material: continue
				items[binding.id] = material; event_op.merge(material); counts.updated += 1
			ops.append(event_op)
	for ordinal: int in parsed.updates.add.size():
		if items.size() >= Contract.MAX_ITEMS: dropped = true; continue
		var material: Dictionary = parsed.updates.add[ordinal]
		var id := Contract.item_id(index,versions[index].prefix,ordinal,material)
		if items.has(id): continue
		items[id] = material.duplicate(true)
		ops.append({"kind":"add","item_id":id,"name":material.name,"summary":material.summary}); counts.added += 1
	counts.total = items.size()
	if dropped and ops.is_empty(): result.status = "invalid_inventory"
	if ops.is_empty(): return result
	var owner: Variant = result.world.get("player_inventory",{})
	if not owner is Dictionary or (not owner.is_empty() and (owner.get("schema_version") != Contract.SCHEMA or not owner.get("turns_by_index") is Dictionary)):
		return {"world":world.duplicate(true),"counts":{},"status":"invalid_inventory"}
	var events: Dictionary = owner.get("turns_by_index",{}).duplicate(true)
	var version: Dictionary = versions[index]
	events[str(index)] = {"source_turn_index":index,"prefix":version.prefix,"source_gm_sha256":version.gm_hash,"ops":ops,"id":Contract.event_id(index,version.prefix,version.gm_hash,ops)}
	result.world["player_inventory"] = {"schema_version":Contract.SCHEMA,"turns_by_index":events}
	return result
