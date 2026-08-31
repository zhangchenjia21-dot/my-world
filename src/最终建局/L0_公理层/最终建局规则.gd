class_name AtomicFinalCreationRules
extends RefCounted

const INTENT_SCHEMA := "atomic_game_creation_intent.v0.1"
const CREATED_SCHEMA := "atomic_game_creation_created.v0.1"
const SETUP_SCHEMA := "game_local_setup.v0.1"
const PRODUCTION_ROOT := "user://my-world/creation-protocol"
const PIN_FIELDS := ["asset_type", "asset_id", "version", "generation_fingerprint"]


static func success(values: Dictionary = {}) -> Dictionary:
	var result := {"success": true}
	result.merge(values, true)
	return result


static func failure(code: String, message: String) -> Dictionary:
	return {"success": false, "code": code, "message": message}


static func validate_creation_id(creation_id: String) -> Dictionary:
	if creation_id.is_empty() or creation_id.length() > 128 or creation_id in [".", ".."]:
		return failure("invalid_creation_id", "creation_id 长度或路径语义无效。")
	for index: int in creation_id.length():
		var code := creation_id.unicode_at(index)
		var allowed := (code >= 97 and code <= 122) or (code >= 65 and code <= 90) \
			or (code >= 48 and code <= 57) or code in [45, 46, 95]
		if not allowed:
			return failure("invalid_creation_id", "creation_id 只允许 ASCII 字母、数字、点、下划线和连字符。")
	return success()


## canonical payload 只包含冻结的玩家语义选择；NPC 是集合，按 exact pin 排序。
static func canonicalize_composition(composition: Dictionary) -> Dictionary:
	for field: String in ["world", "entry", "expansions", "expansion_none_confirmed", "player_character", "guaranteed_npcs", "display_name", "control_mode", "opening_supplement"]:
		if not composition.has(field):
			return failure("invalid_composition", "Composition 缺少字段：%s" % field)
	if not composition.world is Dictionary or not composition.player_character is Dictionary \
		or not composition.entry is Dictionary or not composition.guaranteed_npcs is Array \
		or not composition.expansions is Array:
		return failure("invalid_composition", "Composition 字段类型无效。")
	if composition.expansions.is_empty() and not bool(composition.expansion_none_confirmed):
		return failure("invalid_composition", "空 Expansion 集合必须由玩家明确确认。")
	var world_pin := _pin_from_selection(composition.world, "world_pack")
	if not world_pin.success:
		return world_pin
	var player_pin := _pin_from_selection(composition.player_character, "character_card")
	if not player_pin.success:
		return player_pin
	var npc_pins: Array = []
	for value: Variant in composition.guaranteed_npcs:
		if not value is Dictionary:
			return failure("invalid_composition", "Guaranteed NPC selection 类型无效。")
		var npc_pin := _pin_from_selection(value, "character_card")
		if not npc_pin.success:
			return npc_pin
		npc_pins.append(npc_pin.pin)
	npc_pins.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return _pin_sort_key(left) < _pin_sort_key(right)
	)
	var expansion_pins: Array = []
	var expansion_seen := {}
	for value: Variant in composition.expansions:
		if not value is Dictionary:
			return failure("invalid_composition", "Expansion selection 类型无效。")
		var expansion_pin := _pin_from_selection(value, "expansion_pack")
		if not expansion_pin.success:
			return expansion_pin
		var key := _pin_sort_key(expansion_pin.pin)
		if expansion_seen.has(key):
			return failure("duplicate_expansion", "同一 exact Expansion generation 不能重复选择。")
		expansion_seen[key] = true
		expansion_pins.append(expansion_pin.pin)
	expansion_pins.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return _pin_sort_key(left) < _pin_sort_key(right)
	)
	var entry_id: Variant = null
	if not composition.entry.is_empty():
		entry_id = String(composition.entry.get("entry_id", ""))
		if String(entry_id).is_empty():
			return failure("invalid_composition", "selected Entry 缺少 entry_id。")
	var payload := {
		"world_pin": world_pin.pin,
		"entry_id": entry_id,
		# 保留 G4-06 canonical key；空集合 JSON/fingerprint 不漂移，非空时该字段承载 exact pins。
		"expansions": expansion_pins,
		"player_character_pin": player_pin.pin,
		"guaranteed_npc_pins": npc_pins,
		"display_name": String(composition.display_name),
		"control_mode": String(composition.control_mode),
		"opening_supplement": String(composition.opening_supplement),
	}
	var canonical_json := JSON.stringify(_canonical_value(payload))
	return success({
		"payload": payload,
		"canonical_json": canonical_json,
		"fingerprint": _fingerprint_json(canonical_json),
	})


static func validate_intent(intent: Dictionary) -> Dictionary:
	for field: String in ["schema_version", "creation_id", "composition_fingerprint", "canonical_payload", "game_id", "root_node_id", "local_world_id", "local_player_id", "local_npc_ids", "created_at", "initial_setup"]:
		if not intent.has(field):
			return failure("invalid_creation_intent", "creating intent 缺少字段：%s" % field)
	if String(intent.schema_version) != INTENT_SCHEMA:
		return failure("invalid_creation_intent", "不支持的 creating intent schema。")
	var creation_validation := validate_creation_id(String(intent.creation_id))
	if not creation_validation.success:
		return failure("invalid_creation_intent", String(creation_validation.message))
	for identity_field: String in ["composition_fingerprint", "game_id", "root_node_id", "local_world_id", "local_player_id", "created_at"]:
		if not intent[identity_field] is String or String(intent[identity_field]).is_empty():
			return failure("invalid_creation_intent", "creating intent identity 字段无效：%s" % identity_field)
	if not intent.canonical_payload is Dictionary or not intent.local_npc_ids is Array or not intent.initial_setup is Dictionary:
		return failure("invalid_creation_intent", "creating intent payload 类型无效。")
	if not intent.canonical_payload.get("expansions", null) is Array:
		return failure("invalid_creation_intent", "creating intent Expansion pins 类型无效。")
	var canonical_json := JSON.stringify(_canonical_value(intent.canonical_payload))
	if _fingerprint_json(canonical_json) != String(intent.composition_fingerprint):
		return failure("invalid_creation_intent", "creating intent payload fingerprint 不一致。")
	var setup := intent.initial_setup as Dictionary
	if String(setup.get("schema_version", "")) != SETUP_SCHEMA:
		return failure("invalid_creation_intent", "creating intent initial setup schema 无效。")
	for field: String in ["creation_origin", "game", "setup_ancestry", "world", "player_character"]:
		if not setup.get(field, null) is Dictionary:
			return failure("invalid_creation_intent", "creating intent initial setup 字段类型无效：%s" % field)
	if not setup.get("guaranteed_npcs", null) is Array or not setup.get("expansions", null) is Array:
		return failure("invalid_creation_intent", "creating intent NPC/Expansion 集合类型无效。")
	var origin := setup.get("creation_origin", {}) as Dictionary
	var game := setup.get("game", {}) as Dictionary
	var ancestry := setup.get("setup_ancestry", {}) as Dictionary
	var world := setup.get("world", {}) as Dictionary
	var player := setup.get("player_character", {}) as Dictionary
	var npcs := setup.get("guaranteed_npcs", []) as Array
	var expansions := setup.get("expansions", []) as Array
	if String(origin.get("creation_id", "")) != String(intent.creation_id) \
		or String(origin.get("composition_fingerprint", "")) != String(intent.composition_fingerprint) \
		or String(game.get("game_id", "")) != String(intent.game_id) \
		or String(ancestry.get("root_timeline_node_id", "")) != String(intent.root_node_id) \
		or String(world.get("local_world_id", "")) != String(intent.local_world_id) \
		or String(player.get("local_character_id", "")) != String(intent.local_player_id) \
		or npcs.size() != intent.local_npc_ids.size() \
		or expansions.size() != (intent.canonical_payload.expansions as Array).size():
		return failure("invalid_creation_intent", "creating intent fixed identities 与 initial setup 不一致。")
	for index: int in npcs.size():
		if not npcs[index] is Dictionary:
			return failure("invalid_creation_intent", "creating intent NPC setup 类型无效。")
		if String((npcs[index] as Dictionary).get("local_character_id", "")) != String(intent.local_npc_ids[index]):
			return failure("invalid_creation_intent", "creating intent NPC local identity 不一致。")
	for index: int in expansions.size():
		if not expansions[index] is Dictionary or not (expansions[index] as Dictionary).get("provenance", null) is Dictionary:
			return failure("invalid_creation_intent", "creating intent Expansion materialization 类型无效。")
		if (expansions[index] as Dictionary).provenance != intent.canonical_payload.expansions[index]:
			return failure("invalid_creation_intent", "creating intent Expansion exact provenance 不一致。")
	return success()


static func _pin_from_selection(selection: Dictionary, expected_type: String) -> Dictionary:
	if not selection.get("identity", null) is Dictionary:
		return failure("invalid_composition", "Source selection 缺少 exact identity。")
	var identity := selection.identity as Dictionary
	var pin := {}
	for field: String in PIN_FIELDS:
		if not identity.get(field, null) is String or String(identity.get(field, "")).is_empty():
			return failure("invalid_composition", "Source exact identity 字段无效：%s" % field)
		pin[field] = String(identity[field])
	if String(pin.asset_type) != expected_type:
		return failure("invalid_composition", "Source asset_type 与角色不匹配。")
	return success({"pin": pin})


static func _pin_sort_key(pin: Dictionary) -> String:
	return "%s\u001f%s\u001f%s\u001f%s" % [pin.asset_type, pin.asset_id, pin.version, pin.generation_fingerprint]


static func _canonical_value(value: Variant) -> Variant:
	if value is Dictionary:
		var result := {}
		var keys: Array = value.keys()
		keys.sort()
		for key: Variant in keys:
			result[String(key)] = _canonical_value(value[key])
		return result
	if value is Array:
		var result: Array = []
		for item: Variant in value:
			result.append(_canonical_value(item))
		return result
	return value


static func _fingerprint_json(canonical_json: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(canonical_json.to_utf8_buffer())
	return context.finish().hex_encode()
