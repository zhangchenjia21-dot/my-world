class_name AtomicFinalCreationProcess
extends RefCounted

const Rules := preload("res://src/最终建局/L0_公理层/最终建局规则.gd")
const IntentStore := preload("res://src/最终建局/L1_器件层/创建Intent存储.gd")
const CreationReview := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const SourceContract := preload("res://src/source/L3_外交层/Source合同公开接口.gd")
const SourceRules := preload("res://src/source/L0_公理层/Source合同规则.gd")
const GameLibrary := preload("res://src/游戏库/L3_外交层/游戏库公开接口.gd")
const Persistence := preload("res://src/persistence/L3_外交层/世界持久化公开接口.gd")
const DatabaseSafety := preload("res://src/persistence/L3_外交层/数据库安全公开接口.gd")

const FAULT_AFTER_INTENT := "after_intent_publish"
const FAULT_AFTER_DATABASE := "after_database_commit"
const FAULT_AFTER_LIBRARY_RECORD := "after_library_record_publish"
const FAULT_AFTER_CURRENT := "after_current_publish"
const FAULT_BEFORE_LIBRARY_RECORD := "before_library_record_publish"
const FAULT_BEFORE_CURRENT := "before_current_publish"

var _source_library: RefCounted
var _source_contract := SourceContract.new()
var _review: RefCounted
var _store: RefCounted
var _game_library: RefCounted


func _init(source_library: RefCounted, creation_root: String, library_root: String, games_root: String) -> void:
	_source_library = source_library
	_review = CreationReview.new(source_library)
	_store = IntentStore.new(creation_root)
	_game_library = GameLibrary.new(library_root, games_root)


func create_or_resume(creation_id: String, composition: Dictionary, task_fault: String = "") -> Dictionary:
	var identity_validation := Rules.validate_creation_id(creation_id)
	if not identity_validation.success:
		return identity_validation
	if not task_fault in ["", FAULT_AFTER_INTENT, FAULT_AFTER_DATABASE, FAULT_AFTER_LIBRARY_RECORD, FAULT_AFTER_CURRENT, FAULT_BEFORE_LIBRARY_RECORD, FAULT_BEFORE_CURRENT]:
		return Rules.failure("invalid_fault", "未知的 Final Create task-only fault。")
	var canonical := Rules.canonicalize_composition(composition)
	if not canonical.success:
		return canonical
	var existing: Dictionary = _store.read_intent(creation_id)
	if existing.success:
		return _resume_existing(existing.value, canonical, task_fault)
	if String(existing.code) != "creation_metadata_missing":
		return existing

	# 所有 Source lookup/projection 必须在第一个 durable Game side effect（intent）之前完成。
	var reviewed: Dictionary = _review.review_frozen_composition(composition)
	if not reviewed.success:
		return reviewed
	var intent_result := _build_intent(creation_id, canonical)
	if not intent_result.success:
		return intent_result
	var target: Dictionary = _game_library.managed_database_path(String(intent_result.intent.game_id))
	if not target.success:
		return target
	if FileAccess.file_exists(String(target.path)):
		return Rules.failure("database_path_conflict", "新 creating intent 的目标 Game DB path 已存在；不会覆盖或采用。")
	var published: Dictionary = _store.publish_intent(intent_result.intent)
	if not published.success:
		return published
	if String(published.value.composition_fingerprint) != String(canonical.fingerprint):
		return Rules.failure("creation_payload_conflict", "同一 creation_id 已绑定不同 Composition payload。")
	if task_fault == FAULT_AFTER_INTENT:
		return _injected(FAULT_AFTER_INTENT, published.value)
	return _converge(published.value, task_fault)


func _resume_existing(intent: Dictionary, canonical: Dictionary, task_fault: String) -> Dictionary:
	if String(intent.composition_fingerprint) != String(canonical.fingerprint) or intent.canonical_payload != canonical.payload:
		return Rules.failure("creation_payload_conflict", "同一 creation_id 已绑定不同 Composition payload。")
	return _converge(intent, task_fault)


func _build_intent(creation_id: String, canonical: Dictionary) -> Dictionary:
	var world_result := _exact_generation(canonical.payload.world_pin)
	if not world_result.success:
		return world_result
	var player_result := _exact_generation(canonical.payload.player_character_pin)
	if not player_result.success:
		return player_result
	var npc_generations: Array = []
	for pin: Dictionary in canonical.payload.guaranteed_npc_pins:
		var npc_result := _exact_generation(pin)
		if not npc_result.success:
			return npc_result
		npc_generations.append(npc_result.generation)
	var expansion_generations: Array = []
	for pin: Dictionary in canonical.payload.expansions:
		var expansion_result := _exact_generation(pin)
		if not expansion_result.success:
			return expansion_result
		expansion_generations.append(expansion_result.generation)
	var expansion_materialization := _materialize_expansions(expansion_generations)
	if not expansion_materialization.success:
		return expansion_materialization

	var entry_id := "" if canonical.payload.entry_id == null else String(canonical.payload.entry_id)
	var world_projection := _world_projection(world_result.generation, entry_id)
	if not world_projection.success:
		return world_projection
	var player_projection := _character_projection(player_result.generation, String(canonical.payload.world_pin.asset_id), entry_id)
	if not player_projection.success:
		return player_projection
	var npc_projections: Array = []
	for generation: RefCounted in npc_generations:
		var projected := _character_projection(generation, String(canonical.payload.world_pin.asset_id), entry_id)
		if not projected.success:
			return projected
		npc_projections.append(projected.projection)

	# G5-03M2A：只在首次 intent 构建时检查一次 validated current Character inventory。
	# 同 creation_id retry/resume 走 _resume_existing 复用冻结 intent，绝不重扫 later Source current。
	var stable_snapshot := _source_backed_stable_npcs(canonical.payload, String(canonical.payload.world_pin.asset_id), entry_id)
	if not stable_snapshot.success:
		return stable_snapshot
	var stable_npcs: Array = stable_snapshot.records
	stable_npcs.append_array(_creation_authored_stable_npcs(canonical.payload))

	var game_id := _identity("game")
	var root_node_id := _identity("root")
	var local_world_id := _identity("world")
	var local_player_id := _identity("character")
	var local_npc_ids: Array = []
	for _index: int in npc_projections.size():
		local_npc_ids.append(_identity("character"))
	var created_at := Time.get_datetime_string_from_system(true, true)
	var setup := _setup_envelope(
		creation_id, String(canonical.fingerprint), game_id, root_node_id, local_world_id,
		local_player_id, local_npc_ids, created_at, canonical.payload,
		world_projection.projection, player_projection.projection, npc_projections,
		expansion_materialization.expansions, stable_npcs
	)
	return Rules.success({"intent": {
		"schema_version": Rules.INTENT_SCHEMA,
		"creation_id": creation_id,
		"composition_fingerprint": String(canonical.fingerprint),
		"canonical_payload": canonical.payload.duplicate(true),
		"game_id": game_id,
		"root_node_id": root_node_id,
		"local_world_id": local_world_id,
		"local_player_id": local_player_id,
		"local_npc_ids": local_npc_ids.duplicate(),
		"created_at": created_at,
		"initial_setup": setup,
	}})


func _converge(intent: Dictionary, task_fault: String) -> Dictionary:
	var target: Dictionary = _game_library.managed_database_path(String(intent.game_id))
	if not target.success:
		return target
	var database_path := String(target.path)
	var database_result := _create_or_verify_database(intent, database_path)
	if not database_result.success:
		return database_result
	if task_fault == FAULT_AFTER_DATABASE:
		return _injected(FAULT_AFTER_DATABASE, intent)

	var record_fault := GameLibrary.FAULT_BEFORE_RECORD_PUBLISH if task_fault == FAULT_BEFORE_LIBRARY_RECORD else ""
	var registered: Dictionary = _game_library.register_verified_managed_game(
		String(intent.game_id), String(intent.canonical_payload.display_name), String(database_result.game_id), record_fault
	)
	if not registered.success:
		return registered
	if task_fault == FAULT_AFTER_LIBRARY_RECORD:
		return _injected(FAULT_AFTER_LIBRARY_RECORD, intent)
	var current_fault := GameLibrary.FAULT_BEFORE_CURRENT_PUBLISH if task_fault == FAULT_BEFORE_CURRENT else ""
	var current: Dictionary = _game_library.commit_current(String(intent.game_id), String(database_result.game_id), current_fault)
	if not current.success:
		return current
	if task_fault == FAULT_AFTER_CURRENT:
		return _injected(FAULT_AFTER_CURRENT, intent)

	var marker := {
		"schema_version": Rules.CREATED_SCHEMA,
		"creation_id": String(intent.creation_id),
		"composition_fingerprint": String(intent.composition_fingerprint),
		"game_id": String(intent.game_id),
	}
	var marked: Dictionary = _store.publish_created(marker)
	if not marked.success:
		return marked
	return Rules.success({
		"status": "created",
		"creation_id": String(intent.creation_id),
		"composition_fingerprint": String(intent.composition_fingerprint),
		"game_id": String(intent.game_id),
		"database_path": database_path,
		"root_node_id": String(intent.root_node_id),
		"local_world_id": String(intent.local_world_id),
		"local_player_id": String(intent.local_player_id),
		"local_npc_ids": intent.local_npc_ids.duplicate(),
		"already_created": bool(marked.get("already_created", false)),
	})


func _create_or_verify_database(intent: Dictionary, database_path: String) -> Dictionary:
	var safety := DatabaseSafety.new()
	var ownership := safety.acquire_writer(database_path)
	if not ownership.success:
		return Rules.failure(String(ownership.get("status", "writer_conflict")), String(ownership.get("message", "无法取得 Game DB single-writer ownership。")))
	var inspection := safety.inspect_startup()
	var existed := FileAccess.file_exists(database_path)
	if not inspection.success and String(inspection.get("status", "")) != "normal_missing":
		safety.release_writer()
		return Rules.failure("database_inspection_failed", "目标 Game DB 无法通过启动检查：%s" % String(inspection.get("status", "unknown")))
	if existed and int(inspection.get("schema_version", 4)) != 4:
		safety.release_writer()
		return Rules.failure("database_schema_conflict", "G4-06 不迁移既有目标 Game DB schema。")
	if not existed:
		var directory_error := DirAccess.make_dir_recursive_absolute(database_path.get_base_dir())
		if directory_error != OK:
			safety.release_writer()
			return Rules.failure("database_directory_failed", "无法创建 managed Game 目录。")
	var persistence := Persistence.new()
	var opened := persistence.open_database(database_path)
	if not opened.success:
		safety.release_writer()
		return Rules.failure("database_open_failed", String(opened.message))
	var identities := persistence.list_game_identities()
	if not identities.success:
		return _close_database_failure(persistence, safety, "database_identity_read_failed", String(identities.message))
	var ids := identities.game_ids as Array
	if ids.is_empty():
		var created := persistence.create_initial_game(String(intent.game_id), String(intent.root_node_id), intent.initial_setup, String(intent.created_at))
		if not created.success:
			return _close_database_failure(persistence, safety, "database_create_failed", String(created.message))
	elif ids.size() != 1 or String(ids[0]) != String(intent.game_id):
		return _close_database_failure(persistence, safety, "database_identity_conflict", "目标 path 的 internal Game identity 与 creating intent 不一致。")
	var root := persistence.get_timeline_node(String(intent.game_id), String(intent.root_node_id))
	if not root.success:
		return _close_database_failure(persistence, safety, "database_root_verification_failed", String(root.message))
	if root.world_state != intent.initial_setup or root.parent_node_id != null or int(root.sequence) != 0:
		return _close_database_failure(persistence, safety, "database_root_conflict", "root Timeline snapshot/ancestry 与 immutable creating intent 不一致。")
	var closed := persistence.close_database()
	var released := safety.release_writer()
	if not closed.success:
		return Rules.failure("database_close_failed", String(closed.message))
	if not released.success:
		return Rules.failure("writer_release_failed", String(released.get("message", "无法释放 Game DB writer。")))
	return Rules.success({"game_id": String(intent.game_id)})


func _close_database_failure(persistence: RefCounted, safety: RefCounted, code: String, message: String) -> Dictionary:
	persistence.close_database()
	safety.release_writer()
	return Rules.failure(code, message)


func _world_projection(generation: RefCounted, entry_id: String) -> Dictionary:
	if not entry_id.is_empty():
		return _source_contract.project_world_entry(generation.source, entry_id)
	var source: RefCounted = generation.source
	return Rules.success({"projection": {
		"identity": source.identity.duplicate(true),
		"display_name": source.display_name,
		"catalog_summary": source.catalog_summary,
		"world_instructions": source.world_instructions,
		"gm_instructions": source.gm_instructions,
		"selected_entry": {},
		"semantic_sections": source.semantic_sections.duplicate(true),
	}})


func _character_projection(generation: RefCounted, world_asset_id: String, entry_id: String) -> Dictionary:
	if not entry_id.is_empty():
		var projected := _source_contract.project_character_t0(generation.source, world_asset_id, entry_id)
		if not projected.success:
			return projected
		if bool(projected.hard_incompatible):
			return Rules.failure("character_temporal_incompatible", "Character 与 exact Entry temporal coverage 不兼容。")
		return Rules.success({"projection": projected.projection})
	var source: RefCounted = generation.source
	return Rules.success({"projection": {
		"identity": source.identity.duplicate(true),
		"display_name": source.display_name,
		"catalog_summary": source.catalog_summary,
		"selected_profile": {},
		"semantic_sections": source.semantic_sections.duplicate(true),
		"portrait": source.portrait.duplicate(true),
		"player_character_supported": source.player_character_supported,
	}})


func _exact_generation(pin: Dictionary) -> Dictionary:
	var result: Dictionary
	if String(pin.asset_type) == "world_pack":
		result = _source_library.get_exact_world(String(pin.asset_id), String(pin.generation_fingerprint))
	elif String(pin.asset_type) == "character_card":
		result = _source_library.get_exact_character(String(pin.asset_id), String(pin.generation_fingerprint))
	else:
		result = _source_library.get_exact_expansion(String(pin.asset_id), String(pin.generation_fingerprint))
	if not result.success:
		return Rules.failure("exact_generation_unavailable", String(result.get("message", result.get("code", "unknown"))))
	if result.generation.identity != pin:
		return Rules.failure("exact_generation_mismatch", "Source exact generation pin 复核不一致。")
	return result


func _setup_envelope(
	creation_id: String, fingerprint: String, game_id: String, root_node_id: String,
	local_world_id: String, local_player_id: String, local_npc_ids: Array, created_at: String,
	payload: Dictionary, world_projection: Dictionary, player_projection: Dictionary, npc_projections: Array,
	expansions: Array, stable_npcs: Array
) -> Dictionary:
	var npcs: Array = []
	for index: int in npc_projections.size():
		npcs.append({
			"local_character_id": String(local_npc_ids[index]),
			"role": "guaranteed_npc",
			"provenance": payload.guaranteed_npc_pins[index].duplicate(true),
			"source_projection": npc_projections[index].duplicate(true),
		})
	return {
		"schema_version": Rules.SETUP_SCHEMA,
		"creation_origin": {"creation_id": creation_id, "composition_fingerprint": fingerprint, "created_at": created_at},
		"game": {
			"game_id": game_id,
			"display_name": String(payload.display_name),
			"control_mode": String(payload.control_mode),
			"opening_supplement": String(payload.opening_supplement),
		},
		"setup_ancestry": {"root_timeline_node_id": root_node_id, "kind": "initial_setup"},
		"selected_entry_id": payload.entry_id,
		"expansions": expansions.duplicate(true),
		"world": {
			"local_world_id": local_world_id,
			"provenance": payload.world_pin.duplicate(true),
			"source_projection": world_projection.duplicate(true),
		},
		"player_character": {
			"local_character_id": local_player_id,
			"role": "player",
			"provenance": payload.player_character_pin.duplicate(true),
			"source_projection": player_projection.duplicate(true),
		},
		"guaranteed_npcs": npcs,
		# G5-03M2A：optional additive Game-local stable registry；Guaranteed 保持 distinct product role。
		"stable_npcs": stable_npcs.duplicate(true),
	}


## G5-03M2A：automatic Source-backed stable NPC snapshot。
## 只包含对 selected exact World+Entry compatibility_state == exact_profile 的 Character；
## 排除 Player 与显式 Guaranteed 的 asset_id；按 exact Source identity deterministic 排序；
## 冻结 exact provenance + T0 source_projection；Program 分配 Game-local ID。
func _source_backed_stable_npcs(payload: Dictionary, world_asset_id: String, entry_id: String) -> Dictionary:
	# 无 exact Entry 时没有 T0 projection contract，automatic snapshot 为空。
	if entry_id.is_empty():
		return Rules.success({"records": []})
	var excluded_asset_ids: Dictionary = {String(payload.player_character_pin.asset_id): true}
	for pin: Dictionary in payload.guaranteed_npc_pins:
		excluded_asset_ids[String(pin.asset_id)] = true
	var inventory: Dictionary = _source_library.list_current_sources()
	if not inventory.success:
		return Rules.failure("source_inventory_unavailable", "automatic stable NPC snapshot 无法检查 validated current Character inventory。")
	var candidates: Array = []
	for generation: RefCounted in inventory.sources:
		var identity: Dictionary = generation.identity
		if String(identity.get("asset_type", "")) != "character_card":
			continue
		if excluded_asset_ids.has(String(identity.get("asset_id", ""))):
			continue
		var projected: Dictionary = _source_contract.project_character_t0(generation.source, world_asset_id, entry_id)
		# 无 v0.2 T0 contract 的 Character 不参与 automatic snapshot；不是创建失败。
		if not projected.success:
			continue
		if String(projected.compatibility_state) != SourceRules.COMPATIBILITY_EXACT_PROFILE:
			continue
		var provenance := {}
		for field: String in Rules.PIN_FIELDS:
			provenance[field] = String(identity.get(field, ""))
		candidates.append({"provenance": provenance, "projection": (projected.projection as Dictionary).duplicate(true)})
	candidates.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return Rules._pin_sort_key(left.provenance) < Rules._pin_sort_key(right.provenance)
	)
	var records: Array = []
	for candidate: Dictionary in candidates:
		records.append({
			"local_character_id": _identity("character"),
			"role": "stable_npc",
			"origin": {"kind": "source_character"},
			"provenance": candidate.provenance.duplicate(true),
			"source_projection": candidate.projection.duplicate(true),
		})
	return Rules.success({"records": records})


## G5-03M2A：creation-authored no-Card NPC；诚实的 game_local_material，绝不伪造 Source provenance。
func _creation_authored_stable_npcs(payload: Dictionary) -> Array:
	var records: Array = []
	for item: Dictionary in payload.get("game_local_npcs", []):
		records.append({
			"local_character_id": _identity("character"),
			"role": "stable_npc",
			"origin": {"kind": "creation_authored"},
			"game_local_material": {
				"display_name": String(item.display_name),
				"profile_text": String(item.profile_text),
			},
		})
	return records


## Final Create 只接受 Host 已知 capability；Source rules 作为 immutable data materialize，不执行 Source 代码。
func _materialize_expansions(generations: Array) -> Dictionary:
	var materialized: Array = []
	var slots := {}
	for generation: RefCounted in generations:
		var source: RefCounted = generation.source
		var binding: Dictionary = source.capability_binding
		if String(binding.capability_id) != "action_check.public_d20.v1":
			return Rules.failure("unknown_capability", "Host 不支持 materialized capability_id：%s" % String(binding.capability_id))
		var slot := String(binding.capability_slot)
		if slots.has(slot):
			return Rules.failure("capability_slot_conflict", "多个 Expansion 占用同一 capability_slot。")
		slots[slot] = true
		materialized.append({
			"provenance": generation.identity.duplicate(true),
			"display_name": source.display_name,
			"catalog_summary": source.catalog_summary,
			"capability_id": String(binding.capability_id),
			"capability_slot": slot,
			"semantic_sections": source.semantic_sections.duplicate(true),
		})
	return Rules.success({"expansions": materialized})


func _identity(prefix: String) -> String:
	return "%s-%s" % [prefix, Crypto.new().generate_random_bytes(16).hex_encode()]


func _injected(point: String, intent: Dictionary) -> Dictionary:
	var result := Rules.failure("injected_creation_interruption", "task-only fault：%s 后中断。" % point)
	result["fault_point"] = point
	result["creation_id"] = String(intent.creation_id)
	result["game_id"] = String(intent.game_id)
	return result
