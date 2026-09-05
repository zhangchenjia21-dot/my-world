class_name PlayerSafeProjectionDevice
extends RefCounted

## MW-009 / G5-06 Player-Safe Runtime → UI Projection v0.1（canonical decision §5–§8）。
##
## 投影边界拥有 disclosure：本器件只输出 human-player-safe 的展示字段；
## UI widget 不得接收整个 omniscient world_state 后自行过滤。
##
## 明确排除（绝不进入投影对象，即使 UI "大概不会渲染"）：
## semantic_turns_by_index 原始后果、agency_cycles_by_source_turn、
## world_evolution_events_by_turn、其它 actor 的 Knowledge、GM/source instructions、
## literary_style_reference、内部 ID/hash/fingerprint、Public-d20 control/proposal payload。
##
## fail-closed：无效/过期/歧义输入产生更少或空的展示字段，绝不回退到 omniscient truth。

const OpeningRules := preload("res://src/首次开场/L0_公理层/首次开场规则.gd")
const WorldTurnRules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")

## v0.1 主角已知事实的展示上限（canonical decision：6–8 条取其一）。
const MAX_KNOWN_FACTS := 8
const EMPTY_PROJECTION := {
	"success": false,
	"player_display_name": "",
	"player_profile_name": "",
	"world_display_name": "",
	"world_entry_name": "",
	"known_facts": [],
}


## world_state（durable Game-local setup + living_world）+ current accepted Conversation
## → 纯展示字段投影。确定性、无 Provider 调用、无副作用。
static func project(world_state: Variant, accepted_entries: Array) -> Dictionary:
	var validation: Dictionary = OpeningRules.validate_setup(world_state)
	if not validation.success:
		return EMPTY_PROJECTION.duplicate(true)
	var setup := world_state as Dictionary
	var player_projection := (setup.player_character as Dictionary).get("source_projection", {}) as Dictionary
	var world_projection := (setup.world as Dictionary).get("source_projection", {}) as Dictionary
	var player_local_id := String((setup.player_character as Dictionary).get("local_character_id", ""))
	var profile: Variant = player_projection.get("selected_profile", {})
	var selected_entry: Variant = world_projection.get("selected_entry", {})
	return {
		"success": true,
		"player_display_name": _safe_display_text(player_projection.get("display_name")),
		"player_profile_name": _safe_display_text((profile as Dictionary).get("display_name")) if profile is Dictionary else "",
		"world_display_name": _safe_display_text(world_projection.get("display_name")),
		"world_entry_name": _safe_display_text((selected_entry as Dictionary).get("display_name")) if selected_entry is Dictionary else "",
		"known_facts": _current_player_facts(setup, accepted_entries, player_local_id),
	}


## 展示文本白名单化：只接受非空 String，trim 后作为只读展示字段；
## 其它类型一律为空串——不借宽松类型转换泄露内部材料。
static func _safe_display_text(value: Variant) -> String:
	return String(value).strip_edges() if typeof(value) == TYPE_STRING else ""


## 主角 post-T0 已知事实：valid record ∧ current accepted turn/hash 匹配 ∧
## knower_id == 主角 local id → fact 文本。与 G5 上下文投影器同一 currentness 规则。
## 去重保守保留最新一次；取最近 MAX_KNOWN_FACTS 条，按时间序输出。
static func _current_player_facts(setup: Dictionary, accepted_entries: Array, player_local_id: String) -> Array:
	if player_local_id.strip_edges().is_empty():
		return []
	var living_world_value: Variant = setup.get("living_world", {})
	if typeof(living_world_value) != TYPE_DICTIONARY:
		return []
	var living_world := living_world_value as Dictionary
	if String(living_world.get("schema_version", "")) != WorldTurnRules.LIVING_WORLD_SCHEMA:
		return []
	var records_value: Variant = living_world.get("knowledge_turns_by_index", {})
	if typeof(records_value) != TYPE_DICTIONARY:
		return []
	var accepted_hashes := _accepted_hashes(accepted_entries)
	var collected: Array = []
	for record_value: Variant in (records_value as Dictionary).values():
		if typeof(record_value) != TYPE_DICTIONARY:
			continue
		var record := record_value as Dictionary
		if not WorldTurnRules.knowledge_record_is_valid(record):
			continue
		var turn_index := int(record.source_turn_index)
		if not accepted_hashes.has(turn_index) or String(record.source_gm_sha256) != String(accepted_hashes[turn_index]):
			continue
		var order := 0
		for event_value: Variant in record.events:
			var event := event_value as Dictionary
			if String(event.get("knower_id", "")) != player_local_id:
				continue
			var fact := _safe_display_text(event.get("fact"))
			if not fact.is_empty():
				collected.append({"order": turn_index * 1000 + order, "fact": fact})
			order += 1
	# 去重：同文本保守保留最新一次 occurrence（时间序上最后出现的位置）。
	collected.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.order) < int(b.order))
	var newest_position: Dictionary = {}
	for index: int in collected.size():
		newest_position[String(collected[index].fact)] = index
	var deduped: Array = []
	for index: int in collected.size():
		if int(newest_position[String(collected[index].fact)]) == index:
			deduped.append(String(collected[index].fact))
	# 最新信息在序列尾部；展示取最近 8 条并保持时间序（最新在最后，视觉上易找）。
	if deduped.size() > MAX_KNOWN_FACTS:
		deduped = deduped.slice(deduped.size() - MAX_KNOWN_FACTS)
	return deduped


## 当前 accepted Conversation 的 turn_index → GM hash 映射；与 G5 上下文投影器一致。
static func _accepted_hashes(accepted_entries: Array) -> Dictionary:
	var accepted_hashes: Dictionary = {}
	for entry_value: Variant in accepted_entries:
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue
		var entry := entry_value as Dictionary
		var turn_index := int(entry.get("turn_index", -1))
		var gm_text_value: Variant = entry.get("gm_text", null)
		if turn_index >= 0 and typeof(gm_text_value) == TYPE_STRING:
			accepted_hashes[turn_index] = WorldTurnRules.gm_sha256(String(gm_text_value))
	return accepted_hashes
