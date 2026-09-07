extends RefCounted

const WorldRules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")
const SCHEMA := "accepted_people_identity.v0.1"
const PAIR_SCHEMA := "accepted_people_identity.v0.2"
const COLLECTION := "people_identity_turns_by_index"
const MAX_BINDINGS := 8
const MAX_SPAN := 600

# 与 accepted Player+GM 原文链绑定；不改写历史 G5 GM-only record/actor 身份。
static func prefix_at(entries: Array, index: int) -> String:
	if index < 0 or index >= entries.size():
		return ""
	var prefix := ""
	for i: int in range(index + 1):
		prefix = JSON.stringify([prefix, entries[i].get("player_text", ""), entries[i].get("gm_text", "")]).sha256_text()
	return prefix

static func accepted_hashes(entries: Array, index: int) -> Dictionary:
	var hashes := {}
	for i: int in range(mini(index + 1, entries.size())):
		hashes[i] = WorldRules.gm_sha256(String(entries[i].get("gm_text", "")))
	return hashes

static func npc_ids(world: Dictionary, entries: Array, index: int) -> Dictionary:
	var ids := {}
	var player_id := String(world.get("player_character", {}).get("local_character_id", ""))
	for actor: Dictionary in WorldRules.stable_npc_records(world, accepted_hashes(entries, index)):
		var local_id := String(actor.local_character_id)
		if local_id != player_id:
			ids[local_id] = true
	return ids

static func keys_exact(value: Variant, keys: Array) -> bool:
	if not value is Dictionary or value.size() != keys.size():
		return false
	for key: String in keys:
		if not value.has(key):
			return false
	return true

static func integer(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value))

static func ref_valid(value: Variant) -> bool:
	return value is String and not value.is_empty() and value.length() <= 64 and value == value.strip_edges()

static func span_valid(value: Variant, gm: String) -> bool:
	if not keys_exact(value, ["start", "length"]) or not integer(value.start) or not integer(value.length):
		return false
	return value.start >= 0 and value.length > 0 and value.length <= MAX_SPAN and value.start <= gm.length() - value.length

# 模型解释人物所指；Program 只验证请求引用、来源角色与原文坐标，不从姓名推导身份。
# Player 来源只能解析请求前的演员引用，不能借同响应 candidate_ref 建立人物存在。
static func resolve_bindings(value: Variant, actors: Dictionary, candidates: Dictionary, allowed_ids: Dictionary, gm: String, player: String = "") -> Array:
	var bindings: Array = []
	if not value is Array:
		return bindings
	for item: Variant in value:
		if not item is Dictionary:
			continue
		var legacy: bool = item.has("gm_span")
		var fields := ["gm_span"] if legacy else ["source_role", "source_span"]
		var role: Variant = "gm" if legacy else item.get("source_role")
		if role != "player" and role != "gm":
			continue
		var span: Variant = item.get("gm_span") if legacy else item.get("source_span")
		var local_id := ""
		if keys_exact(item, ["actor_ref"] + fields) and ref_valid(item.actor_ref):
			local_id = String(actors.get(item.actor_ref, ""))
		elif role == "gm" and keys_exact(item, ["candidate_ref"] + fields) and ref_valid(item.candidate_ref):
			local_id = String(candidates.get(item.candidate_ref, ""))
		if not allowed_ids.has(local_id) or not span_valid(span, player if role == "player" else gm):
			continue
		var normalized_span := {"start": int(span.start), "length": int(span.length)}
		var binding := {"local_character_id": local_id, "gm_span": normalized_span} if legacy else {
			"local_character_id": local_id, "source_role": role, "source_span": normalized_span}
		if not bindings.has(binding):
			bindings.append(binding)
		if bindings.size() == MAX_BINDINGS:
			break
	return bindings

# 旧 GM-only 回执沿用原 schema / ID 算法；含来源角色的新响应统一为 v0.2，避免迁移旧历史。
static func build(game: String, index: int, prefix: String, bindings: Array) -> Dictionary:
	var pair := bindings.any(func(b: Dictionary) -> bool: return b.has("source_role"))
	var normalized: Array = []
	for binding: Dictionary in bindings:
		var item := binding.duplicate(true)
		if pair and item.has("gm_span"):
			item = {"local_character_id": item.local_character_id, "source_role": "gm", "source_span": item.gm_span}
		if not normalized.has(item):
			normalized.append(item)
	var record := {"schema": PAIR_SCHEMA if pair else SCHEMA, "game_id": game, "turn_index": index, "prefix": prefix,
		"status": "empty" if normalized.is_empty() else "resolved", "bindings": normalized}
	record["id"] = JSON.stringify(record, "", true).sha256_text()
	return record

# 验证完整回执而非部分修补损坏存储；返回独立白名单副本。旧 owner 缺字段自然为空。
static func current(world: Dictionary, game: String, entries: Array, index: int) -> Dictionary:
	var prefix := prefix_at(entries, index)
	if prefix.is_empty() or String(entries[index].get("player_text", "")).is_empty():
		return {}
	var living: Variant = world.get("living_world", {})
	if not living is Dictionary or living.get("schema_version") != WorldRules.LIVING_WORLD_SCHEMA:
		return {}
	var turns: Variant = living.get(COLLECTION, {})
	if not turns is Dictionary:
		return {}
	var record: Variant = turns.get(str(index))
	if not keys_exact(record, ["schema", "game_id", "turn_index", "prefix", "status", "bindings", "id"]):
		return {}
	if record.schema not in [SCHEMA, PAIR_SCHEMA] or record.game_id != game or not integer(record.turn_index) or record.turn_index != index or record.prefix != prefix:
		return {}
	if not record.bindings is Array or record.bindings.size() > MAX_BINDINGS:
		return {}
	var allowed := npc_ids(world, entries, index)
	var bindings: Array = []
	for binding: Variant in record.bindings:
		var legacy: bool = record.schema == SCHEMA
		var fields := ["local_character_id", "gm_span"] if legacy else ["local_character_id", "source_role", "source_span"]
		if not keys_exact(binding, fields) or not binding.local_character_id is String:
			return {}
		var role: Variant = "gm" if legacy else binding.source_role
		if role != "player" and role != "gm":
			return {}
		var span: Variant = binding.gm_span if legacy else binding.source_span
		var source := String(entries[index].get("player_text" if role == "player" else "gm_text", ""))
		if not allowed.has(binding.local_character_id) or not span_valid(span, source):
			return {}
		var normalized_span := {"start": int(span.start), "length": int(span.length)}
		var normalized := {"local_character_id": binding.local_character_id, "gm_span": normalized_span} if legacy else {
			"local_character_id": binding.local_character_id, "source_role": role, "source_span": normalized_span}
		if bindings.has(normalized):
			return {}
		bindings.append(normalized)
	var expected := build(game, index, prefix, bindings)
	if record.schema != expected.schema or record.status != expected.status or record.id != expected.id:
		return {}
	return expected

static func with_receipt(world: Dictionary, receipt: Dictionary) -> Dictionary:
	var next := world.duplicate(true)
	var living: Dictionary = next.get("living_world", {}).duplicate(true)
	var turns: Dictionary = living.get(COLLECTION, {}).duplicate(true)
	turns[str(int(receipt.turn_index))] = receipt.duplicate(true)
	living["schema_version"] = WorldRules.LIVING_WORLD_SCHEMA
	living[COLLECTION] = turns
	next["living_world"] = living
	return next
