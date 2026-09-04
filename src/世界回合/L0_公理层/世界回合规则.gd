class_name WorldTurnRules
extends RefCounted

const LIVING_WORLD_SCHEMA := "living_world.v0.1"
const MAX_CHANGES_PER_TURN := 8
const MAX_CHANGE_CHARS := 512
## G5-02M1：post-T0 知识 provenance 的有界 v0.1 形状；不是通用 Knowledge Graph。
const MAX_KNOWLEDGE_EVENTS_PER_TURN := 4
const MAX_KNOWLEDGE_FACT_CHARS := 256
const KNOWLEDGE_BASES := ["witnessed", "told", "discovered", "participated"]


static func gm_sha256(gm_text: String) -> String:
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(gm_text.to_utf8_buffer())
	return hashing.finish().hex_encode()


## World Turn 与底层 mutation/node 共用同一内容身份；重放相同 accepted 版本时，
## Runtime 只能回到同一 durable intent，不能因调用时刻不同制造第二个世界节点。
static func identities(game_id: String, source_turn_index: int, source_gm_sha256: String) -> Dictionary:
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(("%s|%d|%s" % [game_id, source_turn_index, source_gm_sha256]).to_utf8_buffer())
	var digest := hashing.finish().hex_encode()
	return {
		"world_turn_id": "world-turn-%s" % digest,
		"mutation_id": "semantic-turn-%s" % digest,
		"node_id": "semantic-node-%s" % digest,
	}


static func build_record(game_id: String, source_turn_index: int, gm_text: String, changes: Array, materialized_at: String) -> Dictionary:
	var source_hash := gm_sha256(gm_text)
	var stable := identities(game_id, source_turn_index, source_hash)
	return {
		"world_turn_id": String(stable.world_turn_id),
		"source_turn_index": source_turn_index,
		"source_gm_sha256": source_hash,
		"materialized_at": materialized_at,
		"changes": changes.duplicate(true),
	}


static func build_world_candidate(current_world_state: Dictionary, record: Dictionary) -> Dictionary:
	var candidate := current_world_state.duplicate(true)
	var living_world_value: Variant = candidate.get("living_world", {})
	var living_world := (living_world_value as Dictionary).duplicate(true) if typeof(living_world_value) == TYPE_DICTIONARY else {}
	var records_value: Variant = living_world.get("semantic_turns_by_index", {})
	var records := (records_value as Dictionary).duplicate(true) if typeof(records_value) == TYPE_DICTIONARY else {}
	records[str(int(record.source_turn_index))] = record.duplicate(true)
	living_world["schema_version"] = LIVING_WORLD_SCHEMA
	living_world["semantic_turns_by_index"] = records
	candidate["living_world"] = living_world
	return candidate


## durable consequence record 只有完整满足 v0.1 shape/size 不变量才可用于幂等判断或
## 后续 Context；损坏/外部篡改数据不能借宽松类型转换进入模型可见事实。
static func record_is_valid(record: Dictionary) -> bool:
	if typeof(record.get("world_turn_id")) != TYPE_STRING or String(record.world_turn_id).is_empty():
		return false
	var source_index_value: Variant = record.get("source_turn_index")
	if typeof(source_index_value) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	var source_index := int(source_index_value)
	# SQLite JSON round-trip 会把整数恢复为 integral float；接受该等价表示，但拒绝
	# 字符串强转与非整数，避免损坏数据被悄悄归到另一个 Conversation turn。
	if source_index < 0 or float(source_index_value) != float(source_index):
		return false
	if typeof(record.get("source_gm_sha256")) != TYPE_STRING or String(record.source_gm_sha256).length() != 64:
		return false
	if typeof(record.get("materialized_at")) != TYPE_STRING or String(record.materialized_at).is_empty():
		return false
	var changes_value: Variant = record.get("changes")
	if typeof(changes_value) != TYPE_ARRAY or (changes_value as Array).is_empty() or (changes_value as Array).size() > MAX_CHANGES_PER_TURN:
		return false
	for value: Variant in changes_value as Array:
		if typeof(value) != TYPE_STRING:
			return false
		var change := String(value).strip_edges()
		if change.is_empty() or change.length() > MAX_CHANGE_CHARS:
			return false
	return true


static func matching_record(world_state: Dictionary, source_turn_index: int, source_gm_sha256: String) -> Dictionary:
	var living_world_value: Variant = world_state.get("living_world", {})
	if typeof(living_world_value) != TYPE_DICTIONARY:
		return {}
	var records_value: Variant = (living_world_value as Dictionary).get("semantic_turns_by_index", {})
	if typeof(records_value) != TYPE_DICTIONARY:
		return {}
	var record_value: Variant = (records_value as Dictionary).get(str(source_turn_index), {})
	if typeof(record_value) != TYPE_DICTIONARY:
		return {}
	var record := record_value as Dictionary
	if not record_is_valid(record) or int(record.source_turn_index) != source_turn_index or String(record.source_gm_sha256) != source_gm_sha256:
		return {}
	return record.duplicate(true)


## ---- G5-02M1 actor knowledge provenance ----
## 知识事件不是普遍事实对象：只表示「该 stable actor 在此 accepted turn 后有 durable 根据
## 知道该事实」。不携带 confidence/truth-maintenance/inference。

## ---- G5-03M2A Stable Actor Registry ----
## 统一 stable actor 视图：Guaranteed + creation-time stable_npcs（+ 未来 runtime_narrative）。
## Display name 永不作为 authoritative identity；空/重复 local ID deterministic fail-soft 丢弃。

## 当前 stable NPC 记录：Guaranteed（product role 保持 distinct）+ world_state.stable_npcs。
## creation-time origin 永远 current；origin.kind == runtime_narrative 的记录只在
## accepted_hashes[source_turn_index] == source_gm_sha256 时 current（M2B 契约预留）。
static func stable_npc_records(world_state: Dictionary, accepted_hashes: Dictionary = {}) -> Array:
	var records: Array = []
	var seen: Dictionary = {}
	for collection: String in ["guaranteed_npcs", "stable_npcs"]:
		var list_value: Variant = world_state.get(collection, [])
		if typeof(list_value) != TYPE_ARRAY:
			continue
		for record_value: Variant in list_value as Array:
			if typeof(record_value) != TYPE_DICTIONARY:
				continue
			var record := record_value as Dictionary
			var local_id := String(record.get("local_character_id", "")).strip_edges()
			if local_id.is_empty() or seen.has(local_id):
				continue
			var origin_value: Variant = record.get("origin", {})
			var origin := origin_value as Dictionary if typeof(origin_value) == TYPE_DICTIONARY else {}
			if String(origin.get("kind", "")) == "runtime_narrative":
				var origin_turn := int(origin.get("source_turn_index", -1))
				var origin_hash := String(origin.get("source_gm_sha256", ""))
				if not accepted_hashes.has(origin_turn) or String(accepted_hashes[origin_turn]) != origin_hash:
					continue
			seen[local_id] = true
			records.append(record)
	return records


## 两种 material family 不做假等价：Source-backed/Guaranteed 返回 source_projection；
## no-Card Game-local actor 返回 game_local_material；都没有时返回空。
static func stable_actor_material(record: Dictionary) -> Dictionary:
	var source_value: Variant = record.get("source_projection", {})
	if typeof(source_value) == TYPE_DICTIONARY and not (source_value as Dictionary).is_empty():
		return source_value as Dictionary
	var local_value: Variant = record.get("game_local_material", {})
	if typeof(local_value) == TYPE_DICTIONARY:
		return local_value as Dictionary
	return {}


## 从当前 Game-local durable setup 构造只读 actor allowlist；incidental/emergent NPC 不在此列。
## roster = Player + stable_npc_records；Player 永不进入 Agency eligibility（由消费方保证）。
static func actor_roster(world_state: Dictionary, accepted_hashes: Dictionary = {}) -> Dictionary:
	var roster: Dictionary = {}
	var player_value: Variant = world_state.get("player_character", {})
	if typeof(player_value) == TYPE_DICTIONARY:
		var player := player_value as Dictionary
		var local_id := String(player.get("local_character_id", ""))
		if not local_id.is_empty():
			roster[local_id] = String(stable_actor_material(player).get("display_name", local_id))
	for record: Dictionary in stable_npc_records(world_state, accepted_hashes):
		var record_id := String(record.get("local_character_id", ""))
		roster[record_id] = String(stable_actor_material(record).get("display_name", record_id))
	return roster


## ---- MW-001 Runtime Narrative Actor Materialization ----
## runtime_narrative actor 是 Game-local stable NPC 的 runtime ingress：Program 拥有 identity，
## 模型只提供 bounded material，永不提供 authoritative ID 或 Source provenance。

## 单回合 semantic lane 的 extraction 安全上限；不是世界 actor 上限。
const MAX_NEW_ACTOR_CANDIDATES_PER_TURN := 8
## 与 M2A creation-authored bounds（64/1024）对齐，不为 runtime actor 发明更宽的 material contract。
const MAX_RUNTIME_ACTOR_NAME_CHARS := 64
const MAX_RUNTIME_ACTOR_PROFILE_CHARS := 1024


## deterministic Program-owned identity：同一 accepted 版本 + canonical material + candidate
## ordinal 永远推出同一 local ID；不含 wall-clock 或随机数，replay/reopen 同一版本不会
## mint 第二个身份。
static func runtime_actor_identities(game_id: String, source_turn_index: int, source_gm_sha256: String, ordinal: int, display_name: String, profile_text: String) -> Dictionary:
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(("runtime-actor|%s|%d|%s|%d|%s|%s" % [game_id, source_turn_index, source_gm_sha256, ordinal, display_name, profile_text]).to_utf8_buffer())
	var digest := hashing.finish().hex_encode()
	return {"local_character_id": "character-runtime-%s" % digest}


## runtime_narrative 记录形状（canonical v0.2 INV-06）：无 provenance/source_projection，
## 只有 honest game_local_material；origin 绑定 exact accepted turn/hash 供 currentness 过滤。
static func build_runtime_actor_record(local_character_id: String, source_turn_index: int, source_gm_sha256: String, display_name: String, profile_text: String) -> Dictionary:
	return {
		"local_character_id": local_character_id,
		"role": "stable_npc",
		"origin": {"kind": "runtime_narrative", "source_turn_index": source_turn_index, "source_gm_sha256": source_gm_sha256},
		"game_local_material": {"display_name": display_name, "profile_text": profile_text},
	}


## 同一 accepted 版本已物化的 runtime actor local IDs。这是 actor-only commit 的 durable
## replay 信号：reopen 后同版本再进入 semantic lane 时可识别，不依赖内存 _attempted_versions。
static func runtime_actor_ids_for_version(world_state: Dictionary, source_turn_index: int, source_gm_sha256: String) -> Array:
	var ids: Array = []
	var list_value: Variant = world_state.get("stable_npcs", [])
	if typeof(list_value) != TYPE_ARRAY:
		return ids
	for record_value: Variant in list_value as Array:
		if typeof(record_value) != TYPE_DICTIONARY:
			continue
		var record := record_value as Dictionary
		var origin_value: Variant = record.get("origin", {})
		if typeof(origin_value) != TYPE_DICTIONARY:
			continue
		var origin := origin_value as Dictionary
		if String(origin.get("kind", "")) != "runtime_narrative":
			continue
		if int(origin.get("source_turn_index", -1)) != source_turn_index or String(origin.get("source_gm_sha256", "")) != source_gm_sha256:
			continue
		var local_id := String(record.get("local_character_id", "")).strip_edges()
		if not local_id.is_empty():
			ids.append(local_id)
	return ids


## actor 与 changes/knowledge 共用同一 semantic mutation seam；actor-only 合法，不伪造
## changes。不创建第二个 actor-registration mutation。
static func build_world_candidate_with_actors(current_world_state: Dictionary, record: Dictionary, knowledge_record: Dictionary, actor_records: Array) -> Dictionary:
	var candidate := build_world_candidate_with_knowledge(current_world_state, record, knowledge_record)
	if actor_records.is_empty():
		return candidate
	var stable_value: Variant = candidate.get("stable_npcs", [])
	var stable := (stable_value as Array).duplicate(true) if typeof(stable_value) == TYPE_ARRAY else []
	for actor_record: Dictionary in actor_records:
		stable.append(actor_record.duplicate(true))
	candidate["stable_npcs"] = stable
	return candidate


## 单条知识事件的 v0.1 不变量；unknown/non-roster knower_id 在上层被丢弃，这里不猜 roster。
static func knowledge_event_is_valid(event: Dictionary) -> bool:
	if typeof(event.get("knower_id")) != TYPE_STRING or String(event.knower_id).strip_edges().is_empty():
		return false
	if typeof(event.get("fact")) != TYPE_STRING:
		return false
	var fact := String(event.fact).strip_edges()
	if fact.is_empty() or fact.length() > MAX_KNOWLEDGE_FACT_CHARS:
		return false
	if typeof(event.get("basis")) != TYPE_STRING or not KNOWLEDGE_BASES.has(String(event.basis)):
		return false
	return true


static func knowledge_record_is_valid(record: Dictionary) -> bool:
	if typeof(record.get("knowledge_turn_id")) != TYPE_STRING or String(record.knowledge_turn_id).is_empty():
		return false
	var source_index_value: Variant = record.get("source_turn_index")
	if typeof(source_index_value) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	var source_index := int(source_index_value)
	if source_index < 0 or float(source_index_value) != float(source_index):
		return false
	if typeof(record.get("source_gm_sha256")) != TYPE_STRING or String(record.source_gm_sha256).length() != 64:
		return false
	if typeof(record.get("materialized_at")) != TYPE_STRING or String(record.materialized_at).is_empty():
		return false
	var events_value: Variant = record.get("events")
	if typeof(events_value) != TYPE_ARRAY or (events_value as Array).is_empty() or (events_value as Array).size() > MAX_KNOWLEDGE_EVENTS_PER_TURN:
		return false
	for event_value: Variant in events_value as Array:
		if typeof(event_value) != TYPE_DICTIONARY or not knowledge_event_is_valid(event_value as Dictionary):
			return false
	return true


static func knowledge_identities(game_id: String, source_turn_index: int, source_gm_sha256: String) -> Dictionary:
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(("knowledge|%s|%d|%s" % [game_id, source_turn_index, source_gm_sha256]).to_utf8_buffer())
	var digest := hashing.finish().hex_encode()
	return {"knowledge_turn_id": "knowledge-turn-%s" % digest}


static func build_knowledge_record(game_id: String, source_turn_index: int, gm_text: String, events: Array, materialized_at: String) -> Dictionary:
	var source_hash := gm_sha256(gm_text)
	var stable := knowledge_identities(game_id, source_turn_index, source_hash)
	return {
		"knowledge_turn_id": String(stable.knowledge_turn_id),
		"source_turn_index": source_turn_index,
		"source_gm_sha256": source_hash,
		"materialized_at": materialized_at,
		"events": events.duplicate(true),
	}


## 同一 candidate world snapshot 可同时承载 changes 与 knowledge；两者共用同一 mutation seam。
static func build_world_candidate_with_knowledge(current_world_state: Dictionary, record: Dictionary, knowledge_record: Dictionary) -> Dictionary:
	var candidate := build_world_candidate(current_world_state, record) if not record.is_empty() else current_world_state.duplicate(true)
	if knowledge_record.is_empty():
		return candidate
	var living_world_value: Variant = candidate.get("living_world", {})
	var living_world := (living_world_value as Dictionary).duplicate(true) if typeof(living_world_value) == TYPE_DICTIONARY else {}
	var knowledge_value: Variant = living_world.get("knowledge_turns_by_index", {})
	var knowledge_records := (knowledge_value as Dictionary).duplicate(true) if typeof(knowledge_value) == TYPE_DICTIONARY else {}
	knowledge_records[str(int(knowledge_record.source_turn_index))] = knowledge_record.duplicate(true)
	living_world["schema_version"] = LIVING_WORLD_SCHEMA
	living_world["knowledge_turns_by_index"] = knowledge_records
	candidate["living_world"] = living_world
	return candidate


static func matching_knowledge_record(world_state: Dictionary, source_turn_index: int, source_gm_sha256: String) -> Dictionary:
	var living_world_value: Variant = world_state.get("living_world", {})
	if typeof(living_world_value) != TYPE_DICTIONARY:
		return {}
	var records_value: Variant = (living_world_value as Dictionary).get("knowledge_turns_by_index", {})
	if typeof(records_value) != TYPE_DICTIONARY:
		return {}
	var record_value: Variant = (records_value as Dictionary).get(str(source_turn_index), {})
	if typeof(record_value) != TYPE_DICTIONARY:
		return {}
	var record := record_value as Dictionary
	if not knowledge_record_is_valid(record) or int(record.source_turn_index) != source_turn_index or String(record.source_gm_sha256) != source_gm_sha256:
		return {}
	return record.duplicate(true)


## ---- G5-03M1 Multi-Actor Agency Cycle ----
## Agency Cycle 是 accepted ordinary turn 的可选后续：0..4 个 stable NPC 独立行动。
## 不引入 round-robin、Faction agency 或通用 actor 模拟平台。

const AGENCY_CYCLE_MAX_ACTORS := 4
const MAX_AGENCY_INTENT_CHARS := 256
const MAX_AGENCY_ACTION_CHARS := 512
const MAX_AGENCY_EFFECTS := 4
const MAX_AGENCY_EFFECT_CHARS := 512


## 一个 eligible source turn 至多一个 Agency Cycle；identity 绑定 game/turn/hash/base head。
static func agency_cycle_identities(game_id: String, source_turn_index: int, source_gm_sha256: String, cycle_base_head_id: String) -> Dictionary:
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(("%s|%d|%s|%s" % [game_id, source_turn_index, source_gm_sha256, cycle_base_head_id]).to_utf8_buffer())
	var digest := hashing.finish().hex_encode()
	return {
		"agency_cycle_id": "agency-cycle-%s" % digest,
	}


## 同一 cycle 内 sibling commit 是 cycle-owned head progression，不是 external staleness。
## 任何 unrelated head change 使剩余 uncommitted 结果失效。
static func agency_action_identities(game_id: String, agency_cycle_id: String, actor_id: String) -> Dictionary:
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(("%s|%s|%s" % [game_id, agency_cycle_id, actor_id]).to_utf8_buffer())
	var digest := hashing.finish().hex_encode()
	return {
		"agency_action_id": "agency-action-%s" % digest,
		"mutation_id": "agency-mutation-%s" % digest,
		"node_id": "agency-node-%s" % digest,
	}


## 单条 agency 行动的 v0.2 不变量。
static func agency_action_is_valid(action: Dictionary) -> bool:
	if typeof(action.get("agency_action_id")) != TYPE_STRING or String(action.agency_action_id).is_empty():
		return false
	if typeof(action.get("actor_id")) != TYPE_STRING or String(action.actor_id).strip_edges().is_empty():
		return false
	if typeof(action.get("intent")) != TYPE_STRING:
		return false
	var intent := String(action.intent).strip_edges()
	if intent.is_empty() or intent.length() > MAX_AGENCY_INTENT_CHARS:
		return false
	if typeof(action.get("action")) != TYPE_STRING:
		return false
	var action_text := String(action.action).strip_edges()
	if action_text.is_empty() or action_text.length() > MAX_AGENCY_ACTION_CHARS:
		return false
	var effects_value: Variant = action.get("effects")
	if typeof(effects_value) != TYPE_ARRAY or (effects_value as Array).size() > MAX_AGENCY_EFFECTS:
		return false
	for effect_value: Variant in effects_value as Array:
		if typeof(effect_value) != TYPE_STRING:
			return false
		var effect := String(effect_value).strip_edges()
		if effect.is_empty() or effect.length() > MAX_AGENCY_EFFECT_CHARS:
			return false
	return true


static func agency_cycle_is_valid(cycle: Dictionary) -> bool:
	if typeof(cycle.get("agency_cycle_id")) != TYPE_STRING or String(cycle.agency_cycle_id).is_empty():
		return false
	var source_index_value: Variant = cycle.get("source_turn_index")
	if typeof(source_index_value) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	var source_index := int(source_index_value)
	if source_index < 0 or float(source_index_value) != float(source_index):
		return false
	if typeof(cycle.get("source_gm_sha256")) != TYPE_STRING or String(cycle.source_gm_sha256).length() != 64:
		return false
	if typeof(cycle.get("cycle_base_head_id")) != TYPE_STRING or String(cycle.cycle_base_head_id).is_empty():
		return false
	var actions_value: Variant = cycle.get("actions_by_actor")
	if typeof(actions_value) != TYPE_DICTIONARY:
		return false
	for action_value: Variant in (actions_value as Dictionary).values():
		if typeof(action_value) != TYPE_DICTIONARY or not agency_action_is_valid(action_value as Dictionary):
			return false
	return true


static func build_agency_cycle(game_id: String, source_turn_index: int, gm_text: String, cycle_base_head_id: String, materialized_at: String) -> Dictionary:
	var source_hash := gm_sha256(gm_text)
	var stable := agency_cycle_identities(game_id, source_turn_index, source_hash, cycle_base_head_id)
	return {
		"agency_cycle_id": String(stable.agency_cycle_id),
		"source_turn_index": source_turn_index,
		"source_gm_sha256": source_hash,
		"cycle_base_head_id": cycle_base_head_id,
		"materialized_at": materialized_at,
		"actions_by_actor": {},
	}


static func build_agency_action(game_id: String, agency_cycle_id: String, actor_id: String, intent: String, action_text: String, effects: Array, materialized_at: String) -> Dictionary:
	var stable := agency_action_identities(game_id, agency_cycle_id, actor_id)
	return {
		"agency_action_id": String(stable.agency_action_id),
		"actor_id": actor_id,
		"intent": intent.strip_edges(),
		"action": action_text.strip_edges(),
		"effects": effects.duplicate(true),
		"materialized_at": materialized_at,
	}


## 把一条 agency 行动并入既有 cycle 的 candidate snapshot；不覆盖其它 actor 的既有行动。
## C01 修正 E：只有同一 current cycle identity 才合并 sibling；stale 同 turn-index cycle 被替换。
static func build_agency_candidate(current_world_state: Dictionary, cycle: Dictionary, action: Dictionary) -> Dictionary:
	var candidate := current_world_state.duplicate(true)
	var living_world_value: Variant = candidate.get("living_world", {})
	var living_world := (living_world_value as Dictionary).duplicate(true) if typeof(living_world_value) == TYPE_DICTIONARY else {}
	var cycles_value: Variant = living_world.get("agency_cycles_by_source_turn", {})
	var cycles := (cycles_value as Dictionary).duplicate(true) if typeof(cycles_value) == TYPE_DICTIONARY else {}
	var cycle_key := str(int(cycle.source_turn_index))
	var existing_cycle_value: Variant = cycles.get(cycle_key, {})
	var existing_cycle := (existing_cycle_value as Dictionary).duplicate(true) if typeof(existing_cycle_value) == TYPE_DICTIONARY and not (existing_cycle_value as Dictionary).is_empty() else cycle.duplicate(true)
	# C01 修正 E：stale 同 turn-index cycle（不同 current source hash / cycle identity）被替换而非合并。
	if String(existing_cycle.get("source_gm_sha256", "")) != String(cycle.get("source_gm_sha256", "")) \
		or String(existing_cycle.get("agency_cycle_id", "")) != String(cycle.get("agency_cycle_id", "")):
		existing_cycle = cycle.duplicate(true)
	var actions_value: Variant = existing_cycle.get("actions_by_actor", {})
	var actions := (actions_value as Dictionary).duplicate(true) if typeof(actions_value) == TYPE_DICTIONARY else {}
	actions[String(action.actor_id)] = action.duplicate(true)
	existing_cycle["actions_by_actor"] = actions
	cycles[cycle_key] = existing_cycle
	living_world["schema_version"] = LIVING_WORLD_SCHEMA
	living_world["agency_cycles_by_source_turn"] = cycles
	candidate["living_world"] = living_world
	return candidate


static func matching_agency_cycle(world_state: Dictionary, source_turn_index: int, source_gm_sha256: String) -> Dictionary:
	var living_world_value: Variant = world_state.get("living_world", {})
	if typeof(living_world_value) != TYPE_DICTIONARY:
		return {}
	var cycles_value: Variant = (living_world_value as Dictionary).get("agency_cycles_by_source_turn", {})
	if typeof(cycles_value) != TYPE_DICTIONARY:
		return {}
	var cycle_value: Variant = (cycles_value as Dictionary).get(str(source_turn_index), {})
	if typeof(cycle_value) != TYPE_DICTIONARY:
		return {}
	var cycle := cycle_value as Dictionary
	if not agency_cycle_is_valid(cycle) or int(cycle.source_turn_index) != source_turn_index or String(cycle.source_gm_sha256) != source_gm_sha256:
		return {}
	return cycle.duplicate(true)


## ---- MW-002 Selective World Evolution ----
## World Evolution 只推进不归属于单一 stable NPC intentional 决策的世界过程；
## hold 是一等正确结果；一次 evaluation 至多推进一个事件（v0.1 安全上限，不是世界语义限制）。
## 不引入 numeric priority / pressure queue / every-N-turn cadence / random-event engine。

const MAX_EVOLUTION_EVENT_CHARS := 512
const MAX_EVOLUTION_EFFECTS := 4
const MAX_EVOLUTION_EFFECT_CHARS := 512
## GM Context 只投影最近若干个 current 事件。
const RECENT_EVOLUTION_EVENTS_LIMIT := 4


## Program-owned deterministic identity：game + exact opportunity turn/hash + base head。
## opportunity_* 是 scheduling/currentness 元数据，不是 Player-causation 元数据；
## identity 不含 wall-clock/随机，replay 同一机会只能回到同一 durable intent。
static func world_evolution_identities(game_id: String, opportunity_turn_index: int, opportunity_gm_sha256: String, evolution_base_head_id: String) -> Dictionary:
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(("evolution|%s|%d|%s|%s" % [game_id, opportunity_turn_index, opportunity_gm_sha256, evolution_base_head_id]).to_utf8_buffer())
	var digest := hashing.finish().hex_encode()
	return {
		"world_evolution_id": "world-evolution-%s" % digest,
		"mutation_id": "evolution-mutation-%s" % digest,
		"node_id": "evolution-node-%s" % digest,
	}


static func build_world_evolution_event(game_id: String, opportunity_turn_index: int, opportunity_gm_sha256: String, evolution_base_head_id: String, event: String, effects: Array, materialized_at: String) -> Dictionary:
	var stable := world_evolution_identities(game_id, opportunity_turn_index, opportunity_gm_sha256, evolution_base_head_id)
	return {
		"world_evolution_id": String(stable.world_evolution_id),
		"opportunity_turn_index": opportunity_turn_index,
		"opportunity_gm_sha256": opportunity_gm_sha256,
		"evolution_base_head_id": evolution_base_head_id,
		"materialized_at": materialized_at,
		"event": event,
		"effects": effects.duplicate(true),
	}


## 单条 world evolution event 的 v0.1 不变量；损坏/篡改数据不能借宽松类型转换进入
## 模型可见事实或幂等判断。
static func world_evolution_event_is_valid(record: Dictionary) -> bool:
	if typeof(record.get("world_evolution_id")) != TYPE_STRING or String(record.world_evolution_id).is_empty():
		return false
	var turn_value: Variant = record.get("opportunity_turn_index")
	if typeof(turn_value) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	var turn_index := int(turn_value)
	# SQLite JSON round-trip 会把整数恢复为 integral float；接受该等价表示。
	if turn_index < 0 or float(turn_value) != float(turn_index):
		return false
	if typeof(record.get("opportunity_gm_sha256")) != TYPE_STRING or String(record.opportunity_gm_sha256).length() != 64:
		return false
	if typeof(record.get("evolution_base_head_id")) != TYPE_STRING or String(record.evolution_base_head_id).is_empty():
		return false
	if typeof(record.get("materialized_at")) != TYPE_STRING or String(record.materialized_at).is_empty():
		return false
	if typeof(record.get("event")) != TYPE_STRING:
		return false
	var event := String(record.event).strip_edges()
	if event.is_empty() or event.length() > MAX_EVOLUTION_EVENT_CHARS:
		return false
	var effects_value: Variant = record.get("effects")
	if typeof(effects_value) != TYPE_ARRAY or (effects_value as Array).is_empty() or (effects_value as Array).size() > MAX_EVOLUTION_EFFECTS:
		return false
	for effect_value: Variant in effects_value as Array:
		if typeof(effect_value) != TYPE_STRING:
			return false
		var effect := String(effect_value).strip_edges()
		if effect.is_empty() or effect.length() > MAX_EVOLUTION_EFFECT_CHARS:
			return false
	return true


## 同一 accepted 机会已提交的 current event；是 evaluator 的 durable replay 信号——
## reopen/fresh worker 再进入同一机会时不得重发评估请求或追加重复事件。
static func matching_world_evolution_event(world_state: Dictionary, opportunity_turn_index: int, opportunity_gm_sha256: String) -> Dictionary:
	var living_world_value: Variant = world_state.get("living_world", {})
	if typeof(living_world_value) != TYPE_DICTIONARY:
		return {}
	var events_value: Variant = (living_world_value as Dictionary).get("world_evolution_events_by_turn", {})
	if typeof(events_value) != TYPE_DICTIONARY:
		return {}
	var record_value: Variant = (events_value as Dictionary).get(str(opportunity_turn_index), {})
	if typeof(record_value) != TYPE_DICTIONARY:
		return {}
	var record := record_value as Dictionary
	if not world_evolution_event_is_valid(record) or int(record.opportunity_turn_index) != opportunity_turn_index or String(record.opportunity_gm_sha256) != opportunity_gm_sha256:
		return {}
	return record.duplicate(true)


## event 进入同一 living_world.v0.1 World document 的 additive collection；
## 无 SQLite schema/table/migration；一个机会至多一条 current 记录（按 turn 覆盖 stale）。
static func build_world_candidate_with_evolution(current_world_state: Dictionary, event_record: Dictionary) -> Dictionary:
	var candidate := current_world_state.duplicate(true)
	var living_world_value: Variant = candidate.get("living_world", {})
	var living_world := (living_world_value as Dictionary).duplicate(true) if typeof(living_world_value) == TYPE_DICTIONARY else {}
	var events_value: Variant = living_world.get("world_evolution_events_by_turn", {})
	var events := (events_value as Dictionary).duplicate(true) if typeof(events_value) == TYPE_DICTIONARY else {}
	events[str(int(event_record.opportunity_turn_index))] = event_record.duplicate(true)
	living_world["schema_version"] = LIVING_WORLD_SCHEMA
	living_world["world_evolution_events_by_turn"] = events
	candidate["living_world"] = living_world
	return candidate
