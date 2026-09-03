class_name WorldTurnContextProjector
extends RefCounted

const Rules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")

const RECENT_MATCHING_TURN_LIMIT := 8
const MAX_PROJECTED_CHARS := 16000


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

	var accepted_hashes: Dictionary = {}
	for entry_value: Variant in accepted_entries:
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue
		var entry := entry_value as Dictionary
		var turn_index := int(entry.get("turn_index", -1))
		var gm_text_value: Variant = entry.get("gm_text", null)
		if turn_index >= 0 and typeof(gm_text_value) == TYPE_STRING:
			accepted_hashes[turn_index] = Rules.gm_sha256(String(gm_text_value))

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
	return {
		"success": true,
		"status": "projected" if not selected.is_empty() else "empty",
		"context_text": text,
		"record_count": selected.size(),
		"rejected_count": rejected + matching.size() - selected.size(),
	}


func _record_block(record: Dictionary) -> String:
	var lines := PackedStringArray(["Conversation Turn %d" % int(record.turn_index)])
	for change: String in record.changes as Array:
		lines.append("- %s" % change)
	return "\n".join(lines)


func _empty_result(rejected_count: int = 0) -> Dictionary:
	return {"success": true, "status": "empty", "context_text": "", "record_count": 0, "rejected_count": rejected_count}
