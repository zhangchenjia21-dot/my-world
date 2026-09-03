class_name WorldTurnContextProjector
extends RefCounted

const Rules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")

const RECENT_MATCHING_TURN_LIMIT := 8
const MAX_PROJECTED_CHARS := 16000
const MAX_KNOWLEDGE_EVENTS_PROJECTED := 8
const MAX_KNOWLEDGE_ACTORS_PROJECTED := 8


## 只投影已在 current world snapshot 中提交、且仍与 current accepted Conversation hash
## 匹配的 consequence record。结构无效、未提交或 replacement 后 stale 的记录一律跳过。
func project(world_state: Dictionary, accepted_entries: Array) -> Dictionary:
	var living_world_value: Variant = world_state.get("living_world", null)
	if living_world_value == null:
		return _empty_result()
	if typeof(living_world_value) != TYPE_DICTIONARY:
		return _empty_result(1)
	var living_world := living_world_value as Dictionary
	if String(living_world.get("schema_version", "")) != Rules.LIVING_WORLD_SCHEMA:
		return _empty_result(1)
	var records_value: Variant = living_world.get("semantic_turns_by_index", {})
	if typeof(records_value) != TYPE_DICTIONARY:
		return _empty_result(1)

	var accepted_hashes := _accepted_hashes(accepted_entries)
	var matching: Array = []
	var rejected := 0
	for record_value: Variant in (records_value as Dictionary).values():
		if typeof(record_value) != TYPE_DICTIONARY:
			rejected += 1
			continue
		var record := record_value as Dictionary
		if not Rules.record_is_valid(record):
			rejected += 1
			continue
		var turn_index := int(record.source_turn_index)
		if not accepted_hashes.has(turn_index) or String(record.get("source_gm_sha256", "")) != String(accepted_hashes[turn_index]):
			rejected += 1
			continue
		var changes: Array = []
		for change_value: Variant in record.changes as Array:
			changes.append(String(change_value).strip_edges())
		matching.append({"turn_index": turn_index, "changes": changes})

	matching.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.turn_index) < int(b.turn_index))
	if matching.size() > RECENT_MATCHING_TURN_LIMIT:
		matching = matching.slice(matching.size() - RECENT_MATCHING_TURN_LIMIT)
	var selected: Array = []
	var projected_chars := 0
	for offset: int in range(matching.size() - 1, -1, -1):
		var block := _record_block(matching[offset] as Dictionary)
		if projected_chars + block.length() > MAX_PROJECTED_CHARS:
			break
		selected.push_front(block)
		projected_chars += block.length()
	var text := ""
	if not selected.is_empty():
		text = "## Materialized World Changes\nOnly durable consequences matching the current accepted Conversation are listed.\n" + "\n".join(selected)
	var knowledge := _project_knowledge(world_state, accepted_hashes, projected_chars)
	if not String(knowledge.context_text).is_empty():
		text += "\n\n" + String(knowledge.context_text)
	return {
		"success": true,
		"status": "projected" if not text.is_empty() else "empty",
		"context_text": text,
		"record_count": selected.size(),
		"knowledge_record_count": int(knowledge.knowledge_record_count),
		"knowledge_event_count": int(knowledge.knowledge_event_count),
		"rejected_count": rejected + matching.size() - selected.size() + int(knowledge.rejected_count),
	}


## Actor Knowledge Provenance 是软模型引导，不是 Narrative 输出门：
## 只投影 committed + hash-matching 的 durable provenance；不做关键词/分类器检查。
func _project_knowledge(world_state: Dictionary, accepted_hashes: Dictionary, projected_chars: int) -> Dictionary:
	var living_world_value: Variant = world_state.get("living_world", {})
	if typeof(living_world_value) != TYPE_DICTIONARY:
		return _empty_knowledge()
	var records_value: Variant = (living_world_value as Dictionary).get("knowledge_turns_by_index", {})
	if typeof(records_value) != TYPE_DICTIONARY:
		return _empty_knowledge()
	var roster := Rules.actor_roster(world_state)
	var matching: Array = []
	var rejected := 0
	for record_value: Variant in (records_value as Dictionary).values():
		if typeof(record_value) != TYPE_DICTIONARY:
			rejected += 1
			continue
		var record := record_value as Dictionary
		if not Rules.knowledge_record_is_valid(record):
			rejected += 1
			continue
		var turn_index := int(record.source_turn_index)
		if not accepted_hashes.has(turn_index) or String(record.get("source_gm_sha256", "")) != String(accepted_hashes[turn_index]):
			rejected += 1
			continue
		matching.append(record)
	matching.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.source_turn_index) < int(b.source_turn_index))
	# 按 actor 聚合最近 provenance； bounded actor/event 上限。
	var by_actor: Dictionary = {}
	var event_count := 0
	for record: Dictionary in matching:
		for event: Dictionary in record.events as Array:
			if event_count >= MAX_KNOWLEDGE_EVENTS_PROJECTED:
				break
			var knower_id := String(event.knower_id)
			if not by_actor.has(knower_id):
				if by_actor.size() >= MAX_KNOWLEDGE_ACTORS_PROJECTED:
					continue
				by_actor[knower_id] = []
			(by_actor[knower_id] as Array).append({"fact": String(event.fact), "basis": String(event.basis)})
			event_count += 1
	if by_actor.is_empty():
		return _empty_knowledge(rejected)
	var lines := PackedStringArray([
		"## Actor Knowledge Provenance",
		"GM has broader world reference; actors do not automatically share GM knowledge.",
		"A post-T0 fact present in World/GM context is not automatically actor knowledge. Let an actor speak, plan, react or decide from it only when durable provenance below or the current scene supports awareness.",
	])
	for knower_id: String in by_actor.keys():
		var display := String(roster.get(knower_id, knower_id))
		lines.append("%s [%s]" % [display, knower_id])
		for event: Dictionary in by_actor[knower_id] as Array:
			lines.append("- [%s] %s" % [String(event.basis), String(event.fact)])
	var text := "\n".join(lines)
	if projected_chars + text.length() > MAX_PROJECTED_CHARS:
		return _empty_knowledge(rejected)
	return {
		"context_text": text,
		"knowledge_record_count": matching.size(),
		"knowledge_event_count": event_count,
		"rejected_count": rejected,
	}


func _accepted_hashes(accepted_entries: Array) -> Dictionary:
	var accepted_hashes: Dictionary = {}
	for entry_value: Variant in accepted_entries:
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue
		var entry := entry_value as Dictionary
		var turn_index := int(entry.get("turn_index", -1))
		var gm_text_value: Variant = entry.get("gm_text", null)
		if turn_index >= 0 and typeof(gm_text_value) == TYPE_STRING:
			accepted_hashes[turn_index] = Rules.gm_sha256(String(gm_text_value))
	return accepted_hashes


func _empty_knowledge(rejected_count: int = 0) -> Dictionary:
	return {"context_text": "", "knowledge_record_count": 0, "knowledge_event_count": 0, "rejected_count": rejected_count}


func _record_block(record: Dictionary) -> String:
	var lines := PackedStringArray(["Conversation Turn %d" % int(record.turn_index)])
	for change: String in record.changes as Array:
		lines.append("- %s" % change)
	return "\n".join(lines)


func _empty_result(rejected_count: int = 0) -> Dictionary:
	return {"success": true, "status": "empty", "context_text": "", "record_count": 0, "rejected_count": rejected_count}
