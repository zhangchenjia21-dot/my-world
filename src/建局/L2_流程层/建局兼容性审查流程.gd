class_name GameCreationCompatibilityReviewProcess
extends RefCounted

const Rules := preload("res://src/建局/L0_公理层/建局Composition规则.gd")


## resolved_exact 必须由 L3 在审查时重新通过 Source Library exact lookup 取得；
## 本流程不接受 current generation 替代，也不产生任何 durable side effect。
func review(composition: Dictionary, resolved_exact: Dictionary) -> Dictionary:
	if composition.world.is_empty():
		return Rules.failure("world_required", "必须选择一个 World。")
	if composition.player_character.is_empty():
		return Rules.failure("player_character_required", "必须选择一个 Player Character。")
	if composition.expansions.is_empty() and not bool(composition.expansion_none_confirmed):
		return Rules.failure("expansion_choice_required", "请明确确认本局不使用拓展。")
	if String(composition.display_name).strip_edges().is_empty():
		return Rules.failure("display_name_required", "游戏名称不能为空。")
	if not String(composition.control_mode) in Rules.CONTROL_MODES:
		return Rules.failure("invalid_control_mode", "主角控制模式无效。")
	if not _matches(composition.world, resolved_exact.world):
		return Rules.failure("exact_generation_mismatch", "World exact generation 复核不一致。")
	if not _matches(composition.player_character, resolved_exact.player_character):
		return Rules.failure("exact_generation_mismatch", "Player Character exact generation 复核不一致。")
	var resolved_npcs: Array = resolved_exact.guaranteed_npcs
	if resolved_npcs.size() != composition.guaranteed_npcs.size():
		return Rules.failure("exact_generation_mismatch", "Guaranteed NPC exact generation 数量不一致。")
	for index: int in composition.guaranteed_npcs.size():
		if not _matches(composition.guaranteed_npcs[index], resolved_npcs[index]):
			return Rules.failure("exact_generation_mismatch", "Guaranteed NPC exact generation 复核不一致。")
		if Rules.same_generation(composition.guaranteed_npcs[index].identity, composition.player_character.identity):
			return Rules.failure("character_role_overlap", "Player 与 Guaranteed NPC 角色重叠。")
	var resolved_expansions: Array = resolved_exact.get("expansions", [])
	if resolved_expansions.size() != composition.expansions.size():
		return Rules.failure("exact_generation_mismatch", "Expansion exact generation 数量不一致。")
	var exact_seen := {}
	var slot_seen := {}
	for index: int in composition.expansions.size():
		var selected := composition.expansions[index] as Dictionary
		if not _matches(selected, resolved_expansions[index]):
			return Rules.failure("exact_generation_mismatch", "Expansion exact generation 复核不一致。")
		var key := Rules.identity_sort_key(selected.identity)
		if exact_seen.has(key):
			return Rules.failure("duplicate_expansion", "同一 exact Expansion generation 不能重复选择。")
		exact_seen[key] = true
		var binding: Dictionary = resolved_expansions[index].source.capability_binding
		var slot := String(binding.capability_slot)
		if slot_seen.has(slot):
			return Rules.failure("capability_slot_conflict", "所选 Expansion 占用同一 exclusive capability_slot：%s" % slot)
		slot_seen[slot] = true
	if not composition.entry.is_empty():
		var found := false
		for candidate: Dictionary in resolved_exact.world.source.entries:
			if String(candidate.entry_id) == String(composition.entry.entry_id):
				found = true
				break
		if not found:
			return Rules.failure("entry_not_in_world", "Entry 不属于复核后的 exact World。")
	return Rules.success({"review": composition.duplicate(true)})


func _matches(selected: Dictionary, generation: RefCounted) -> bool:
	return generation != null and Rules.same_generation(selected.identity, generation.identity)
