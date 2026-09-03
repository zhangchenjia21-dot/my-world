class_name WorldTurnRules
extends RefCounted

const LIVING_WORLD_SCHEMA := "living_world.v0.1"
const MAX_CHANGES_PER_TURN := 8
const MAX_CHANGE_CHARS := 512
## G5-02M1：post-T0 知识 provenance 的有界 v0.1 形状；不是通用 Knowledge Graph。
const MAX_KNOWLEDGE_EVENTS_PER_TURN := 4
const MAX_KNOWLEDGE_FACT_CHARS := 256
const KNOWLEDGE_BASES := ["witnessed", "told", "discovered", "participated"]


static func gm_sha256(gm_text: String) -> String:
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(gm_text.to_utf8_buffer())
	return hashing.finish().hex_encode()


## World Turn 与底层 mutation/node 共用同一内容身份；重放相同 accepted 版本时，
## Runtime 只能回到同一 durable intent，不能因调用时刻不同制造第二个世界节点。
static func identities(game_id: String, source_turn_index: int, source_gm_sha256: String) -> Dictionary:
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(("%s|%d|%s" % [game_id, source_turn_index, source_gm_sha256]).to_utf8_buffer())
	var digest := hashing.finish().hex_encode()
	return {
		"world_turn_id": "world-turn-%s" % digest,
		"mutation_id": "semantic-turn-%s" % digest,
		"node_id": "semantic-node-%s" % digest,
	}


static func build_record(game_id: String, source_turn_index: int, gm_text: String, changes: Array, materialized_at: String) -> Dictionary:
	var source_hash := gm_sha256(gm_text)
	var stable := identities(game_id, source_turn_index, source_hash)
	return {
		"world_turn_id": String(stable.world_turn_id),
		"source_turn_index": source_turn_index,
		"source_gm_sha256": source_hash,
		"materialized_at": materialized_at,
		"changes": changes.duplicate(true),
	}


static func build_world_candidate(current_world_state: Dictionary, record: Dictionary) -> Dictionary:
	var candidate := current_world_state.duplicate(true)
	var living_world_value: Variant = candidate.get("living_world", {})
	var living_world := (living_world_value as Dictionary).duplicate(true) if typeof(living_world_value) == TYPE_DICTIONARY else {}
	var records_value: Variant = living_world.get("semantic_turns_by_index", {})
	var records := (records_value as Dictionary).duplicate(true) if typeof(records_value) == TYPE_DICTIONARY else {}
	records[str(int(record.source_turn_index))] = record.duplicate(true)
	living_world["schema_version"] = LIVING_WORLD_SCHEMA
	living_world["semantic_turns_by_index"] = records
	candidate["living_world"] = living_world
	return candidate


## durable consequence record 只有完整满足 v0.1 shape/size 不变量才可用于幂等判断或
## 后续 Context；损坏/外部篡改数据不能借宽松类型转换进入模型可见事实。
static func record_is_valid(record: Dictionary) -> bool:
	if typeof(record.get("world_turn_id")) != TYPE_STRING or String(record.world_turn_id).is_empty():
		return false
	var source_index_value: Variant = record.get("source_turn_index")
	if typeof(source_index_value) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	var source_index := int(source_index_value)
	# SQLite JSON round-trip 会把整数恢复为 integral float；接受该等价表示，但拒绝
	# 字符串强转与非整数，避免损坏数据被悄悄归到另一个 Conversation turn。
	if source_index < 0 or float(source_index_value) != float(source_index):
		return false
	if typeof(record.get("source_gm_sha256")) != TYPE_STRING or String(record.source_gm_sha256).length() != 64:
		return false
	if typeof(record.get("materialized_at")) != TYPE_STRING or String(record.materialized_at).is_empty():
		return false
	var changes_value: Variant = record.get("changes")
	if typeof(changes_value) != TYPE_ARRAY or (changes_value as Array).is_empty() or (changes_value as Array).size() > MAX_CHANGES_PER_TURN:
		return false
	for value: Variant in changes_value as Array:
		if typeof(value) != TYPE_STRING:
			return false
		var change := String(value).strip_edges()
		if change.is_empty() or change.length() > MAX_CHANGE_CHARS:
			return false
	return true


static func matching_record(world_state: Dictionary, source_turn_index: int, source_gm_sha256: String) -> Dictionary:
	var living_world_value: Variant = world_state.get("living_world", {})
	if typeof(living_world_value) != TYPE_DICTIONARY:
		return {}
	var records_value: Variant = (living_world_value as Dictionary).get("semantic_turns_by_index", {})
	if typeof(records_value) != TYPE_DICTIONARY:
		return {}
	var record_value: Variant = (records_value as Dictionary).get(str(source_turn_index), {})
	if typeof(record_value) != TYPE_DICTIONARY:
		return {}
	var record := record_value as Dictionary
	if not record_is_valid(record) or int(record.source_turn_index) != source_turn_index or String(record.source_gm_sha256) != source_gm_sha256:
		return {}
	return record.duplicate(true)


## ---- G5-02M1 actor knowledge provenance ----
## 知识事件不是普遍事实对象：只表示「该 stable actor 在此 accepted turn 后有 durable 根据
## 知道该事实」。不携带 confidence/truth-maintenance/inference。

## 从当前 Game-local durable setup 构造只读 actor allowlist；incidental/emergent NPC 不在此列。
static func actor_roster(world_state: Dictionary) -> Dictionary:
	var roster: Dictionary = {}
	var player_value: Variant = world_state.get("player_character", {})
	if typeof(player_value) == TYPE_DICTIONARY:
		var player := player_value as Dictionary
		var local_id := String(player.get("local_character_id", ""))
		if not local_id.is_empty():
			roster[local_id] = String(player.get("source_projection", {}).get("display_name", local_id))
	var npcs_value: Variant = world_state.get("guaranteed_npcs", [])
	if typeof(npcs_value) == TYPE_ARRAY:
		for npc_value: Variant in npcs_value as Array:
			if typeof(npc_value) != TYPE_DICTIONARY:
				continue
			var npc := npc_value as Dictionary
			var npc_id := String(npc.get("local_character_id", ""))
			if not npc_id.is_empty():
				roster[npc_id] = String(npc.get("source_projection", {}).get("display_name", npc_id))
	return roster


## 单条知识事件的 v0.1 不变量；unknown/non-roster knower_id 在上层被丢弃，这里不猜 roster。
static func knowledge_event_is_valid(event: Dictionary) -> bool:
	if typeof(event.get("knower_id")) != TYPE_STRING or String(event.knower_id).strip_edges().is_empty():
		return false
	if typeof(event.get("fact")) != TYPE_STRING:
		return false
	var fact := String(event.fact).strip_edges()
	if fact.is_empty() or fact.length() > MAX_KNOWLEDGE_FACT_CHARS:
		return false
	if typeof(event.get("basis")) != TYPE_STRING or not KNOWLEDGE_BASES.has(String(event.basis)):
		return false
	return true


static func knowledge_record_is_valid(record: Dictionary) -> bool:
	if typeof(record.get("knowledge_turn_id")) != TYPE_STRING or String(record.knowledge_turn_id).is_empty():
		return false
	var source_index_value: Variant = record.get("source_turn_index")
	if typeof(source_index_value) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	var source_index := int(source_index_value)
	if source_index < 0 or float(source_index_value) != float(source_index):
		return false
	if typeof(record.get("source_gm_sha256")) != TYPE_STRING or String(record.source_gm_sha256).length() != 64:
		return false
	if typeof(record.get("materialized_at")) != TYPE_STRING or String(record.materialized_at).is_empty():
		return false
	var events_value: Variant = record.get("events")
	if typeof(events_value) != TYPE_ARRAY or (events_value as Array).is_empty() or (events_value as Array).size() > MAX_KNOWLEDGE_EVENTS_PER_TURN:
		return false
	for event_value: Variant in events_value as Array:
		if typeof(event_value) != TYPE_DICTIONARY or not knowledge_event_is_valid(event_value as Dictionary):
			return false
	return true


static func knowledge_identities(game_id: String, source_turn_index: int, source_gm_sha256: String) -> Dictionary:
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(("knowledge|%s|%d|%s" % [game_id, source_turn_index, source_gm_sha256]).to_utf8_buffer())
	var digest := hashing.finish().hex_encode()
	return {"knowledge_turn_id": "knowledge-turn-%s" % digest}


static func build_knowledge_record(game_id: String, source_turn_index: int, gm_text: String, events: Array, materialized_at: String) -> Dictionary:
	var source_hash := gm_sha256(gm_text)
	var stable := knowledge_identities(game_id, source_turn_index, source_hash)
	return {
		"knowledge_turn_id": String(stable.knowledge_turn_id),
		"source_turn_index": source_turn_index,
		"source_gm_sha256": source_hash,
		"materialized_at": materialized_at,
		"events": events.duplicate(true),
	}


## 同一 candidate world snapshot 可同时承载 changes 与 knowledge；两者共用同一 mutation seam。
static func build_world_candidate_with_knowledge(current_world_state: Dictionary, record: Dictionary, knowledge_record: Dictionary) -> Dictionary:
	var candidate := build_world_candidate(current_world_state, record) if not record.is_empty() else current_world_state.duplicate(true)
	if knowledge_record.is_empty():
		return candidate
	var living_world_value: Variant = candidate.get("living_world", {})
	var living_world := (living_world_value as Dictionary).duplicate(true) if typeof(living_world_value) == TYPE_DICTIONARY else {}
	var knowledge_value: Variant = living_world.get("knowledge_turns_by_index", {})
	var knowledge_records := (knowledge_value as Dictionary).duplicate(true) if typeof(knowledge_value) == TYPE_DICTIONARY else {}
	knowledge_records[str(int(knowledge_record.source_turn_index))] = knowledge_record.duplicate(true)
	living_world["schema_version"] = LIVING_WORLD_SCHEMA
	living_world["knowledge_turns_by_index"] = knowledge_records
	candidate["living_world"] = living_world
	return candidate


static func matching_knowledge_record(world_state: Dictionary, source_turn_index: int, source_gm_sha256: String) -> Dictionary:
	var living_world_value: Variant = world_state.get("living_world", {})
	if typeof(living_world_value) != TYPE_DICTIONARY:
		return {}
	var records_value: Variant = (living_world_value as Dictionary).get("knowledge_turns_by_index", {})
	if typeof(records_value) != TYPE_DICTIONARY:
		return {}
	var record_value: Variant = (records_value as Dictionary).get(str(source_turn_index), {})
	if typeof(record_value) != TYPE_DICTIONARY:
		return {}
	var record := record_value as Dictionary
	if not knowledge_record_is_valid(record) or int(record.source_turn_index) != source_turn_index or String(record.source_gm_sha256) != source_gm_sha256:
		return {}
	return record.duplicate(true)
