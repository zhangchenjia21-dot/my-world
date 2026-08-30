class_name GameCreationPublicInterface
extends RefCounted

const Rules := preload("res://src/建局/L0_公理层/建局Composition规则.gd")
const State := preload("res://src/建局/L1_器件层/建局Composition状态器.gd")
const ReviewProcess := preload("res://src/建局/L2_流程层/建局兼容性审查流程.gd")
const SourceContract := preload("res://src/source/L3_外交层/Source合同公开接口.gd")

var _source_library: RefCounted
var _state := State.new()
var _review := ReviewProcess.new()
var _source_contract := SourceContract.new()


## Source Library 由 Application composition root 显式注入；构造与 reset 均不扫描 Library。
func _init(source_library: RefCounted) -> void:
	_source_library = source_library


func reset() -> void:
	_state.reset()


## 只有显式进入 Wizard 才读取 current inventory；返回值不会隐式选择任何第一项。
func load_current_inventory() -> Dictionary:
	var result: Dictionary = _source_library.list_current_sources()
	if not result.success:
		return result
	var worlds: Array[RefCounted] = []
	var characters: Array[RefCounted] = []
	for generation: RefCounted in result.sources:
		if String(generation.identity.asset_type) == "world_pack":
			worlds.append(generation)
		else:
			characters.append(generation)
	return Rules.success({"worlds": worlds, "characters": characters})


func select_world(generation: RefCounted) -> Dictionary:
	return _state.select_world(generation)


func select_entry(entry_id: String) -> Dictionary:
	return _state.select_entry(entry_id)


func confirm_expansion_none() -> Dictionary:
	return _state.confirm_expansion_none()


func select_player(generation: RefCounted) -> Dictionary:
	return _state.select_player(generation)


func set_guaranteed_npc(generation: RefCounted, selected: bool) -> Dictionary:
	return _state.set_npc(generation, selected)


func set_settings(display_name: String, control_mode: String, opening_supplement: String) -> Dictionary:
	return _state.set_settings(display_name, control_mode, opening_supplement)


func composition_snapshot() -> Dictionary:
	return _state.snapshot()


## 审查时逐项 exact lookup；current 已切到新 generation 时仍验证 Composition 原先点击的 fingerprint。
func build_compatibility_review() -> Dictionary:
	return review_frozen_composition(_state.snapshot())


## Final Create 对 Wizard 已冻结 snapshot 做同一套 deterministic exact re-review；
## 调用不改变当前 Wizard state，也不产生任何 durable side effect。
func review_frozen_composition(composition: Dictionary) -> Dictionary:
	if composition.world.is_empty() or composition.player_character.is_empty():
		return _review.review(composition, {})
	var world_result := _exact_lookup(composition.world.identity)
	if not world_result.success:
		return _review_failure(world_result, "World")
	var player_result := _exact_lookup(composition.player_character.identity)
	if not player_result.success:
		return _review_failure(player_result, "Player Character")
	var npcs: Array[RefCounted] = []
	for npc: Dictionary in composition.guaranteed_npcs:
		var npc_result := _exact_lookup(npc.identity)
		if not npc_result.success:
			return _review_failure(npc_result, "Guaranteed NPC")
		npcs.append(npc_result.generation)
	if not composition.entry.is_empty():
		var world_asset_id := String(world_result.generation.identity.asset_id)
		var entry_id := String(composition.entry.entry_id)
		var player_compatibility := _temporal_compatibility(player_result.generation, world_asset_id, entry_id)
		if not player_compatibility.success:
			return player_compatibility
		for npc_generation: RefCounted in npcs:
			var npc_compatibility := _temporal_compatibility(npc_generation, world_asset_id, entry_id)
			if not npc_compatibility.success:
				return npc_compatibility
	return _review.review(composition, {
		"world": world_result.generation,
		"player_character": player_result.generation,
		"guaranteed_npcs": npcs,
	})


func _temporal_compatibility(generation: RefCounted, world_asset_id: String, entry_id: String) -> Dictionary:
	# v0.1 没有 T0 profile contract；保留已接受的 Wizard 历史回归，不从 display/family 猜测。
	if String(generation.source.identity.get("schema_version", "")) != "character_card.v0.2":
		return Rules.success()
	var result := _source_contract.project_character_t0(generation.source, world_asset_id, entry_id)
	if not result.success:
		return Rules.failure("source_projection_failed", String(result.get("message", result.get("code", "unknown"))))
	if bool(result.hard_incompatible):
		return Rules.failure("character_temporal_incompatible", "Character 对所选 World 已声明封闭 T0 coverage，但未绑定所选 Entry。")
	return Rules.success({"compatibility_state": result.compatibility_state})


func _exact_lookup(identity: Dictionary) -> Dictionary:
	if String(identity.asset_type) == "world_pack":
		return _source_library.get_exact_world(String(identity.asset_id), String(identity.generation_fingerprint))
	return _source_library.get_exact_character(String(identity.asset_id), String(identity.generation_fingerprint))


func _review_failure(failure: Dictionary, label: String) -> Dictionary:
	return Rules.failure("exact_generation_unavailable", "%s exact generation 无法复核：%s" % [label, String(failure.get("message", failure.get("code", "unknown")))])
