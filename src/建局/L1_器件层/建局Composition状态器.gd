class_name GameCreationCompositionState
extends RefCounted

const Rules := preload("res://src/建局/L0_公理层/建局Composition规则.gd")

var world: Dictionary = {}
var entry: Dictionary = {}
var expansion_none_confirmed := false
var expansions: Array[Dictionary] = []
var player_character: Dictionary = {}
var guaranteed_npcs: Array[Dictionary] = []
var display_name := ""
var control_mode := Rules.DEFAULT_CONTROL_MODE
var opening_supplement := ""


func reset() -> void:
	world = {}
	entry = {}
	expansion_none_confirmed = false
	expansions.clear()
	player_character = {}
	guaranteed_npcs.clear()
	display_name = ""
	control_mode = Rules.DEFAULT_CONTROL_MODE
	opening_supplement = ""


func select_world(generation: RefCounted) -> Dictionary:
	var selected := _selection(generation)
	var validation := Rules.validate_identity(selected.identity, "world_pack")
	if not validation.success:
		return validation
	var changed := world.is_empty() or not Rules.same_generation(world.identity, selected.identity)
	world = selected
	if changed:
		entry = {}
	return Rules.success({"world": world.duplicate(true), "entry_cleared": changed})


func select_entry(entry_id: String) -> Dictionary:
	if world.is_empty():
		return Rules.failure("world_required", "请先明确选择 World。")
	if entry_id.is_empty():
		entry = {}
		return Rules.success({"entry": {}})
	for candidate: Dictionary in world.source_entries:
		if String(candidate.entry_id) == entry_id:
			entry = candidate.duplicate(true)
			return Rules.success({"entry": entry.duplicate(true)})
	return Rules.failure("entry_not_in_world", "Entry 不属于所选 exact World generation。")


func confirm_expansion_none() -> Dictionary:
	expansions.clear()
	expansion_none_confirmed = true
	return Rules.success()


## M1 的 headless/programmatic 选择入口；UI selector 由后续任务拥有。
func set_expansion(generation: RefCounted, selected: bool) -> Dictionary:
	var candidate := _selection(generation)
	var validation := Rules.validate_identity(candidate.identity, "expansion_pack")
	if not validation.success:
		return validation
	candidate["capability_binding"] = generation.source.capability_binding.duplicate(true)
	var index := _expansion_index(candidate.identity)
	if selected and index >= 0:
		return Rules.failure("duplicate_expansion", "同一 exact Expansion generation 不能重复选择。")
	if selected:
		for existing: Dictionary in expansions:
			if String(existing.capability_binding.capability_slot) == String(candidate.capability_binding.capability_slot):
				return Rules.failure("capability_slot_conflict", "所选 Expansion 占用同一 exclusive capability_slot。")
		expansions.append(candidate)
		expansions.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
			return Rules.identity_sort_key(left.identity) < Rules.identity_sort_key(right.identity)
		)
	elif index >= 0:
		expansions.remove_at(index)
	expansion_none_confirmed = expansions.is_empty()
	return Rules.success({"expansions": expansions.duplicate(true)})


func select_player(generation: RefCounted) -> Dictionary:
	var selected := _selection(generation)
	var validation := Rules.validate_identity(selected.identity, "character_card")
	if not validation.success:
		return validation
	if not bool(generation.source.player_character_supported):
		return Rules.failure("player_character_not_supported", "该 Character Card 不支持 Player Character。")
	player_character = selected
	guaranteed_npcs = guaranteed_npcs.filter(func(candidate: Dictionary) -> bool:
		return not Rules.same_generation(candidate.identity, player_character.identity)
	)
	return Rules.success({"player": player_character.duplicate(true)})


func set_npc(generation: RefCounted, selected: bool) -> Dictionary:
	var candidate := _selection(generation)
	var validation := Rules.validate_identity(candidate.identity, "character_card")
	if not validation.success:
		return validation
	if not player_character.is_empty() and Rules.same_generation(candidate.identity, player_character.identity):
		return Rules.failure("character_role_overlap", "同一 exact Character generation 不能同时是 Player 与 Guaranteed NPC。")
	var index := _npc_index(candidate.identity)
	if selected and index < 0:
		guaranteed_npcs.append(candidate)
	elif not selected and index >= 0:
		guaranteed_npcs.remove_at(index)
	return Rules.success({"npcs": guaranteed_npcs.duplicate(true)})


func set_settings(name: String, mode: String, supplement: String) -> Dictionary:
	var normalized_name := name.strip_edges()
	if normalized_name.is_empty():
		return Rules.failure("display_name_required", "游戏名称不能为空。")
	if not mode in Rules.CONTROL_MODES:
		return Rules.failure("invalid_control_mode", "主角控制模式无效。")
	display_name = normalized_name
	control_mode = mode
	opening_supplement = supplement.strip_edges()
	return Rules.success()


func snapshot() -> Dictionary:
	return {
		"world": world.duplicate(true),
		"entry": entry.duplicate(true),
		"expansions": expansions.duplicate(true),
		"expansion_none_confirmed": expansion_none_confirmed,
		"player_character": player_character.duplicate(true),
		"guaranteed_npcs": guaranteed_npcs.duplicate(true),
		"display_name": display_name,
		"control_mode": control_mode,
		"opening_supplement": opening_supplement,
	}


func _selection(generation: RefCounted) -> Dictionary:
	var selection := {
		"identity": Rules.exact_identity(generation),
		"display_name": String(generation.display_name),
	}
	if String(generation.identity.asset_type) == "world_pack":
		selection["source_entries"] = generation.source.entries.duplicate(true)
	return selection


func _npc_index(identity: Dictionary) -> int:
	for index: int in guaranteed_npcs.size():
		if Rules.same_generation(guaranteed_npcs[index].identity, identity):
			return index
	return -1


func _expansion_index(identity: Dictionary) -> int:
	for index: int in expansions.size():
		if Rules.same_generation(expansions[index].identity, identity):
			return index
	return -1
