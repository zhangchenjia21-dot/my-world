class_name GameCreationPublicInterface
extends RefCounted

const Rules := preload("res://src/建局/L0_公理层/建局Composition规则.gd")
const State := preload("res://src/建局/L1_器件层/建局Composition状态器.gd")
const ReviewProcess := preload("res://src/建局/L2_流程层/建局兼容性审查流程.gd")

var _source_library: RefCounted
var _state := State.new()
var _review := ReviewProcess.new()


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
	var composition := _state.snapshot()
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
	return _review.review(composition, {
		"world": world_result.generation,
		"player_character": player_result.generation,
		"guaranteed_npcs": npcs,
	})


func _exact_lookup(identity: Dictionary) -> Dictionary:
	if String(identity.asset_type) == "world_pack":
		return _source_library.get_exact_world(String(identity.asset_id), String(identity.generation_fingerprint))
	return _source_library.get_exact_character(String(identity.asset_id), String(identity.generation_fingerprint))


func _review_failure(failure: Dictionary, label: String) -> Dictionary:
	return Rules.failure("exact_generation_unavailable", "%s exact generation 无法复核：%s" % [label, String(failure.get("message", failure.get("code", "unknown")))])
