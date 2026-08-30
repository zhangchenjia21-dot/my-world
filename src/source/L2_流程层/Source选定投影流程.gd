class_name SelectedSourceProjectionProcess
extends RefCounted

const Rules := preload("res://src/source/L0_公理层/Source合同规则.gd")


## 选定投影只使用已验证、已加载的 L3 Source projection；不再读 manifest 或文件系统。
func project_world_entry(source: RefCounted, entry_id: String) -> Dictionary:
	if source == null or String(source.identity.get("schema_version", "")) != Rules.WORLD_SCHEMA_V2:
		return Rules.failure("unsupported_projection_schema", "World selected projection 需要 world_pack.v0.2。")
	if entry_id.is_empty():
		return Rules.failure("entry_required", "World selected projection 需要明确 entry_id。")
	var selected_entry: Dictionary = {}
	for entry: Dictionary in source.entries:
		if String(entry.entry_id) == entry_id:
			selected_entry = entry
			break
	if selected_entry.is_empty():
		return Rules.failure("entry_not_in_world", "Entry 不属于该 exact World generation。")
	var sections: Array = source.semantic_sections.duplicate(true)
	sections.append_array(selected_entry.semantic_sections.duplicate(true))
	return Rules.success({"projection": {
		"identity": source.identity.duplicate(true),
		"display_name": source.display_name,
		"catalog_summary": source.catalog_summary,
		"world_instructions": source.world_instructions,
		"gm_instructions": source.gm_instructions,
		"selected_entry": {
			"entry_id": selected_entry.entry_id,
			"display_name": selected_entry.display_name,
			"opening_seed": selected_entry.opening_seed,
		},
		"semantic_sections": sections,
	}})


## 三态结果是 authored coverage 的机械分类，不推断 family、地点或叙事推荐。
func project_character_t0(source: RefCounted, world_asset_id: String, entry_id: String) -> Dictionary:
	if source == null or String(source.identity.get("schema_version", "")) != Rules.CHARACTER_SCHEMA_V2:
		return Rules.failure("unsupported_projection_schema", "Character selected projection 需要 character_card.v0.2。")
	if world_asset_id.is_empty() or entry_id.is_empty():
		return Rules.failure("selection_required", "Character T0 projection 需要明确 world_asset_id 与 entry_id。")
	var world_covered := false
	var selected_profile: Dictionary = {}
	for profile: Dictionary in source.t0_profiles:
		for binding: Dictionary in profile.bindings:
			if String(binding.world_asset_id) != world_asset_id:
				continue
			world_covered = true
			if String(binding.entry_id) == entry_id:
				selected_profile = profile
	var state := Rules.COMPATIBILITY_EXACT_PROFILE if not selected_profile.is_empty() \
		else Rules.COMPATIBILITY_TEMPORAL_INCOMPATIBLE if world_covered \
		else Rules.COMPATIBILITY_NO_WORLD_COVERAGE
	var sections: Array = source.semantic_sections.duplicate(true)
	if not selected_profile.is_empty():
		sections.append_array(selected_profile.semantic_sections.duplicate(true))
	var profile_metadata := {}
	if not selected_profile.is_empty():
		profile_metadata = {
			"profile_id": selected_profile.profile_id,
			"display_name": selected_profile.display_name,
		}
	return Rules.success({
		"compatibility_state": state,
		"hard_incompatible": state == Rules.COMPATIBILITY_TEMPORAL_INCOMPATIBLE,
		"projection": {
			"identity": source.identity.duplicate(true),
			"display_name": source.display_name,
			"catalog_summary": source.catalog_summary,
			"selected_profile": profile_metadata,
			"semantic_sections": sections,
			"portrait": source.portrait.duplicate(true),
			"player_character_supported": source.player_character_supported,
		},
	})
