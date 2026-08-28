extends SceneTree

const Persistence := preload("res://src/persistence/L3_外交层/世界持久化公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const ContextAssembler := preload("res://src/context/上下文组装器.gd")

const MARKER_A := "RECOVERED_FUTURE_MARKER_A"
const MARKER_B := "DISPLACED_BRANCH_MARKER_B"
var _root_path := ""


func _initialize() -> void:
	_root_path = _argument_value("--root=")
	if _root_path.is_empty(): return _fail("missing --root")
	DirAccess.make_dir_recursive_absolute(_root_path)
	if not _test_v3_migration(false): return
	if not _test_v3_migration(true): return
	if not _test_no_op_and_generation_gate(): return
	if not _test_recovery_target_failures(): return
	if not _test_load_failure_rollback(): return
	if not _test_recover_failure_rollback(): return
	if not _test_reciprocal_branch_context_and_order(): return
	if not _test_regenerate_and_correction(): return
	print("G3-05 PASS | schema v4 + protected Load/Recover + Timeline/Context suite")
	quit(0)


func _test_v3_migration(failing: bool) -> bool:
	var path := _path("migration-failure.sqlite" if failing else "migration-success.sqlite")
	var seed := Runtime.new()
	if not seed.open_current_game(path).success or not _accept(seed, "迁移前行动", "迁移前回应"):
		return _fail("v3 fixture seed")
	var expected := _current_proof(seed)
	var saved: Dictionary = seed.create_save_point("迁移前存档")
	seed.close()
	if not saved.success: return _fail("v3 fixture Save")
	var db := _open_raw(path)
	if db == null: return false
	if not db.query("DROP TABLE recovery_checkpoints;") or not db.query("UPDATE persistence_schema SET schema_version=3;"):
		return _fail("downgrade fixture to v3: %s" % db.error_message)
	if failing and not db.query("CREATE TRIGGER abort_v4_version BEFORE UPDATE OF schema_version ON persistence_schema BEGIN SELECT RAISE(ABORT, 'intentional v4 migration failure'); END;"):
		return _fail("install v4 migration trigger")
	db.close_db()
	var api := Persistence.new()
	var opened: Dictionary = api.open_database(path)
	if failing:
		if opened.status != "storage_failure": return _fail("v4 migration failure not fail-loud: %s" % opened)
		var proof := _schema_proof(path)
		if proof.version != 3 or proof.recovery_tables != 0 or proof.recovery_indexes != 0:
			return _fail("failed v4 migration did not rollback: %s" % proof)
		print("G3-05 PASS | intentional v3->v4 failure leaves usable v3")
		return true
	if not opened.success or opened.schema_version != 4: return _fail("v3->v4 open: %s" % opened)
	var current: Dictionary = api.get_current_game(String(expected.game_id))
	var conversation: Dictionary = api.get_current_conversation(String(expected.game_id))
	var saves: Dictionary = api.list_save_points(String(expected.game_id))
	var recovery_count: Dictionary = api.recovery_checkpoint_count(String(expected.game_id))
	api.close_database()
	var proof := _schema_proof(path)
	if proof.version != 4 or proof.recovery_tables != 1 or proof.recovery_indexes != 1:
		return _fail("v3->v4 schema shape mismatch: %s" % proof)
	if current.head_id != expected.head or conversation.accepted_entries != expected.conversation or saves.save_points.size() != 1 or recovery_count.recovery_count != 0:
		return _fail("v3->v4 changed existing truth")
	print("G3-05 PASS | v3->v4 additive migration preserves current/Save/Timeline truth")
	return true


func _test_no_op_and_generation_gate() -> bool:
	var path := _path("no-op.sqlite")
	var runtime := Runtime.new()
	if not runtime.open_current_game(path).success or not _accept(runtime, "当前行动", "当前回应"): return _fail("no-op seed")
	var saved: Dictionary = runtime.create_save_point("当前存档")
	var before := _current_proof(runtime)
	var count_before: Dictionary = runtime.persistence.recovery_checkpoint_count(runtime.game_id)
	var loaded: Dictionary = runtime.restore_save_point(saved.save_id)
	var count_after: Dictionary = runtime.persistence.recovery_checkpoint_count(runtime.game_id)
	if loaded.status != "already_current" or bool(loaded.committed) or before != _current_proof(runtime) or count_before.recovery_count != count_after.recovery_count:
		return _fail("Load exact no-op mutated current/Recovery: %s" % loaded)
	if not _insert_current_recovery(path, runtime, "recovery-no-op", "2026-08-28T01:02:03Z"):
		return false
	var latest_before: Dictionary = runtime.persistence.get_latest_recovery(runtime.game_id)
	var recover_count_before: Dictionary = runtime.persistence.recovery_checkpoint_count(runtime.game_id)
	var recovered: Dictionary = runtime.recover_previous_progress()
	var latest_after: Dictionary = runtime.persistence.get_latest_recovery(runtime.game_id)
	var recover_count_after: Dictionary = runtime.persistence.recovery_checkpoint_count(runtime.game_id)
	if recovered.status != "already_current" or bool(recovered.committed) or latest_before.recovery_id != latest_after.recovery_id or recover_count_before.recovery_count != recover_count_after.recovery_count:
		return _fail("Recover exact no-op changed latest/count")
	runtime.conversation.begin_turn("生成中")
	if runtime.restore_save_point(saved.save_id).status != "generation_active" or runtime.recover_previous_progress().status != "generation_active":
		return _fail("active generation did not gate Load/Recover")
	runtime.conversation.append_delta("PARTIAL_MUST_NOT_PERSIST")
	runtime.conversation.cancel_generation()
	runtime.close()
	print("G3-05 PASS | Load/Recover exact no-op and active-generation gate")
	return true


func _test_recovery_target_failures() -> bool:
	var empty_path := _path("recovery-missing.sqlite")
	var empty_runtime := Runtime.new()
	if not empty_runtime.open_current_game(empty_path).success: return _fail("missing Recovery open")
	var availability: Dictionary = empty_runtime.get_recovery_availability()
	var missing: Dictionary = empty_runtime.recover_previous_progress()
	if not availability.success or availability.available or missing.status != "not_found": return _fail("missing Recovery semantics")
	empty_runtime.close()
	for mode: String in ["anchor", "conversation"]:
		var path := _path("invalid-recovery-%s.sqlite" % mode)
		var runtime := Runtime.new()
		if not runtime.open_current_game(path).success or not _accept(runtime, "Save truth", "Save response"): return _fail("invalid Recovery seed")
		var saved: Dictionary = runtime.create_save_point("目标")
		if not _accept(runtime, "Future truth", "Future response") or not runtime.restore_save_point(saved.save_id).success: return _fail("create Recovery target")
		var before := _current_proof(runtime)
		var count_before: Dictionary = runtime.persistence.recovery_checkpoint_count(runtime.game_id)
		var sql := "UPDATE recovery_checkpoints SET timeline_node_id='missing-recovery-anchor' WHERE recovery_sequence=(SELECT MAX(recovery_sequence) FROM recovery_checkpoints);" if mode == "anchor" else "UPDATE recovery_checkpoints SET accepted_turns_json='[{\"player_text\":\"x\",\"gm_text\":\"   \"}]' WHERE recovery_sequence=(SELECT MAX(recovery_sequence) FROM recovery_checkpoints);"
		if mode == "anchor": sql = "PRAGMA foreign_keys=OFF; %s" % sql
		if not _execute_raw(path, sql): return false
		var result: Dictionary = runtime.recover_previous_progress()
		var count_after: Dictionary = runtime.persistence.recovery_checkpoint_count(runtime.game_id)
		if result.success or before != _current_proof(runtime) or count_before.recovery_count != count_after.recovery_count:
			return _fail("invalid Recovery %s mutated current/history: %s" % [mode, result])
		runtime.close()
	print("G3-05 PASS | missing/invalid Recovery target fails loud without fallback or mutation")
	return true


func _test_load_failure_rollback() -> bool:
	for mode: String in ["recovery_insert", "world", "head", "conversation", "commit"]:
		var path := _path("load-failure-%s.sqlite" % mode)
		var runtime := Runtime.new()
		if not runtime.open_current_game(path).success or not _accept(runtime, "存档行动", "存档回应"): return _fail("failure seed %s" % mode)
		var saved: Dictionary = runtime.create_save_point("故障目标")
		if not saved.success or not _accept(runtime, "被替换未来", "被替换回应"): return _fail("failure future %s" % mode)
		var before := _current_proof(runtime)
		var count_before: Dictionary = runtime.persistence.recovery_checkpoint_count(runtime.game_id)
		if not _install_switch_failure(path, mode): return false
		var result: Dictionary = runtime.restore_save_point(saved.save_id)
		var count_after: Dictionary = runtime.persistence.recovery_checkpoint_count(runtime.game_id)
		if result.success or before != _current_proof(runtime) or count_before.recovery_count != count_after.recovery_count:
			return _fail("%s failure left half-switch/orphan: %s" % [mode, result])
		runtime.close()
	print("G3-05 PASS | INSERT/World/head/Conversation/COMMIT failures rollback switch + Recovery")
	return true


func _test_recover_failure_rollback() -> bool:
	for mode: String in ["recovery_insert", "world", "head", "conversation", "commit"]:
		var path := _path("recover-failure-%s.sqlite" % mode)
		var runtime := Runtime.new()
		if not runtime.open_current_game(path).success or not _accept(runtime, "恢复目标行动", "恢复目标回应"): return _fail("Recover failure seed %s" % mode)
		var saved: Dictionary = runtime.create_save_point("旧进度")
		if not saved.success or not _accept(runtime, "Future A", "Future A response"): return _fail("Recover failure Future A %s" % mode)
		if not runtime.restore_save_point(saved.save_id).success or not _accept(runtime, "Branch B", "Branch B response"):
			return _fail("Recover failure branch seed %s" % mode)
		var before := _current_proof(runtime)
		var latest_before: Dictionary = runtime.persistence.get_latest_recovery(runtime.game_id)
		var count_before: Dictionary = runtime.persistence.recovery_checkpoint_count(runtime.game_id)
		if not _install_switch_failure(path, mode): return false
		var result: Dictionary = runtime.recover_previous_progress()
		var latest_after: Dictionary = runtime.persistence.get_latest_recovery(runtime.game_id)
		var count_after: Dictionary = runtime.persistence.recovery_checkpoint_count(runtime.game_id)
		if result.success or before != _current_proof(runtime) or count_before.recovery_count != count_after.recovery_count or latest_before.recovery_id != latest_after.recovery_id:
			return _fail("Recover %s failure left half-switch/orphan/latest drift: %s" % [mode, result])
		runtime.close()
	print("G3-05 PASS | reciprocal INSERT/World/head/Conversation/COMMIT failures rollback switch + latest")
	return true


func _test_reciprocal_branch_context_and_order() -> bool:
	var path := _path("reciprocal-branch.sqlite")
	var runtime := Runtime.new()
	if not runtime.open_current_game(path).success or not _accept(runtime, "H1 行动", "H1 回应"): return _fail("branch seed")
	var h1 := runtime.active_head_id
	var saved: Dictionary = runtime.create_save_point("H1 存档")
	var mutation_h2: Dictionary = runtime.persistence.commit_world_mutation(runtime.game_id, "mutation-h2", h1, "head-h2", {"future": "A"}, "2026-08-28T02:00:00Z")
	if not mutation_h2.success: return _fail("H2 mutation")
	_apply_mutation(runtime, mutation_h2)
	for index: int in range(13):
		if not _accept(runtime, "A 行动 %02d" % index, "A 回应 %02d" % index): return false
	if not _accept(runtime, "A marker", MARKER_A): return false
	var future_a_entries: Array = runtime.conversation.get_durable_accepted_entries()
	var loaded: Dictionary = runtime.restore_save_point(saved.save_id)
	if not loaded.success or runtime.active_head_id != h1: return _fail("protected Load H1")
	var recovery_a: Dictionary = runtime.persistence.get_latest_recovery(runtime.game_id)
	var normalized_a: Dictionary = runtime.conversation.validate_accepted_entries(recovery_a.get("accepted_entries", []))
	if not recovery_a.success or recovery_a.timeline_node_id != "head-h2" or not normalized_a.ok or normalized_a.accepted_entries != future_a_entries:
		return _fail("Load did not capture exact Future A: latest=%s expected=%s" % [recovery_a, future_a_entries])
	if not _accept(runtime, "B 行动", MARKER_B): return false
	var branch_b_entries: Array = runtime.conversation.get_durable_accepted_entries()
	var mutation_h3: Dictionary = runtime.persistence.commit_world_mutation(runtime.game_id, "mutation-h3", h1, "head-h3", {"future": "B"}, "2026-08-28T02:00:01Z")
	if not mutation_h3.success: return _fail("H3 mutation")
	_apply_mutation(runtime, mutation_h3)
	var recovered_a: Dictionary = runtime.recover_previous_progress()
	if not recovered_a.success or runtime.active_head_id != "head-h2" or runtime.conversation.get_durable_accepted_entries() != future_a_entries:
		return _fail("Recover did not restore exact Future A")
	var h2_node: Dictionary = runtime.persistence.get_timeline_node(runtime.game_id, "head-h2")
	var h3_node: Dictionary = runtime.persistence.get_timeline_node(runtime.game_id, "head-h3")
	if h2_node.parent_node_id != h1 or h3_node.parent_node_id != h1 or h2_node.world_state != {"future": "A"} or h3_node.world_state != {"future": "B"}:
		return _fail("immutable H1 children branch proof failed")
	var latest_b: Dictionary = runtime.persistence.get_latest_recovery(runtime.game_id)
	var normalized_b: Dictionary = runtime.conversation.validate_accepted_entries(latest_b.accepted_entries)
	if not normalized_b.ok or normalized_b.accepted_entries != branch_b_entries or latest_b.timeline_node_id != "head-h3": return _fail("reciprocal Recovery did not preserve B")
	runtime.conversation.begin_turn("恢复后当前行动")
	var messages: Array = ContextAssembler.new().assemble_messages(runtime.conversation.get_context_projection(), "")
	var serialized := JSON.stringify(messages)
	if not serialized.contains(MARKER_A) or serialized.contains(MARKER_B) or messages.size() != 26 or _count_message(messages, "恢复后当前行动") != 1 or String(messages[-1].content) != "恢复后当前行动":
		return _fail("symmetric Context isolation/recent-12 failed")
	if serialized.contains("materialization_json") or String(messages[0].content).contains("Current Game Context"):
		return _fail("raw World/Prompt truth leaked into Context")
	runtime.conversation.cancel_generation()
	var recovered_b: Dictionary = runtime.recover_previous_progress()
	if not recovered_b.success or runtime.active_head_id != "head-h3" or runtime.conversation.get_durable_accepted_entries() != branch_b_entries:
		return _fail("second Recover did not return to B")
	if runtime.list_save_points().save_points.size() != 1 or runtime.persistence.timeline_node_count(runtime.game_id).node_count != 3:
		return _fail("Load/Recover changed named Save or historical Timeline count")
	var order_proof := _recovery_order_proof(path)
	if order_proof.count < 3 or not order_proof.monotonic or not order_proof.has_same_second:
		return _fail("durable same-second latest ordering proof failed: %s" % order_proof)
	runtime.close()
	var reopened := Runtime.new()
	if not reopened.open_current_game(path).success or reopened.active_head_id != "head-h3" or not reopened.get_recovery_availability().available:
		return _fail("normal reopen lost current/latest Recovery")
	reopened.close()
	print("G3-05 PASS | reciprocal back-and-forth, H1->{H2,H3}, same-second order, Context isolation, reopen")
	return true


func _test_regenerate_and_correction() -> bool:
	for mode: String in ["regenerate", "correction"]:
		var path := _path("%s.sqlite" % mode)
		var runtime := Runtime.new()
		if not runtime.open_current_game(path).success or not _accept(runtime, "旧行动", "旧回应"): return _fail("%s seed" % mode)
		var saved: Dictionary = runtime.create_save_point("替换前")
		if not _accept(runtime, "待替换行动", "待替换回应"): return false
		if mode == "regenerate":
			if runtime.conversation.retry_or_regenerate_latest() == null: return _fail("begin regenerate")
			runtime.conversation.append_delta("REGENERATED_ACCEPTED_GM")
		else:
			if runtime.conversation.correct_latest("CORRECTED_PLAYER") == null: return _fail("begin correction")
			runtime.conversation.append_delta("CORRECTED_ACCEPTED_GM")
		if not runtime.complete_active_generation_durably().success: return _fail("durable %s" % mode)
		var expected: Array = runtime.conversation.get_durable_accepted_entries()
		# failed partial after the accepted replacement must remain outside Recovery.
		runtime.conversation.retry_or_regenerate_latest()
		runtime.conversation.append_delta("FAILED_PARTIAL_NOT_RECOVERY_TRUTH")
		runtime.conversation.fail_generation("injected")
		if not runtime.restore_save_point(saved.save_id).success or not runtime.recover_previous_progress().success:
			return _fail("Load/Recover %s" % mode)
		var actual: Array = runtime.conversation.get_durable_accepted_entries()
		if actual != expected or JSON.stringify(actual).contains("FAILED_PARTIAL_NOT_RECOVERY_TRUTH"):
			return _fail("%s accepted result/partial alignment mismatch" % mode)
		if runtime.conversation.retry_or_regenerate_latest() == null:
			return _fail("post-Recover latest Regenerate unavailable")
		runtime.conversation.append_delta("POST_RECOVER_REGENERATED")
		if not runtime.complete_active_generation_durably().success: return _fail("post-Recover persist-before-accept")
		runtime.close()
	print("G3-05 PASS | Regenerate/Correction exact recovery and partial exclusion")
	return true


func _install_switch_failure(path: String, mode: String) -> bool:
	var sql := ""
	match mode:
		"recovery_insert": sql = "CREATE TRIGGER abort_recovery_insert BEFORE INSERT ON recovery_checkpoints BEGIN SELECT RAISE(ABORT, 'intentional recovery insert failure'); END;"
		"world": sql = "CREATE TRIGGER abort_recovery_world BEFORE UPDATE ON world_materializations BEGIN SELECT RAISE(ABORT, 'intentional world failure'); END;"
		"head": sql = "CREATE TRIGGER abort_recovery_head BEFORE UPDATE OF active_head_id ON games BEGIN SELECT RAISE(ABORT, 'intentional head failure'); END;"
		"conversation": sql = "CREATE TRIGGER abort_recovery_conversation BEFORE UPDATE ON conversation_materializations BEGIN SELECT RAISE(ABORT, 'intentional conversation failure'); END;"
		"commit": sql = "CREATE TABLE commit_parent(id INTEGER PRIMARY KEY); CREATE TABLE commit_child(parent_id INTEGER, FOREIGN KEY(parent_id) REFERENCES commit_parent(id) DEFERRABLE INITIALLY DEFERRED); CREATE TRIGGER abort_recovery_commit AFTER UPDATE ON conversation_materializations BEGIN INSERT INTO commit_child(parent_id) VALUES (999); END;"
	return _execute_raw(path, sql)


func _insert_current_recovery(path: String, runtime: RefCounted, recovery_id: String, created_at: String) -> bool:
	var entries_json := JSON.stringify(runtime.conversation.get_durable_accepted_entries()).replace("'", "''")
	var sql := "INSERT INTO recovery_checkpoints(game_id,recovery_id,timeline_node_id,accepted_turns_json,reason,created_at) VALUES ('%s','%s','%s','%s','test','%s');" % [runtime.game_id, recovery_id, runtime.active_head_id, entries_json, created_at]
	return _execute_raw(path, sql)


func _recovery_order_proof(path: String) -> Dictionary:
	var db := _open_raw(path)
	if db == null: return {}
	if not db.query("SELECT recovery_sequence, created_at FROM recovery_checkpoints ORDER BY recovery_sequence;"):
		return {}
	var rows: Array = db.query_result.duplicate(true)
	db.close_db()
	var monotonic := true
	var same_second := false
	for index: int in range(rows.size()):
		if index > 0:
			monotonic = monotonic and int(rows[index].recovery_sequence) > int(rows[index - 1].recovery_sequence)
			same_second = same_second or String(rows[index].created_at) == String(rows[index - 1].created_at)
	return {"count": rows.size(), "monotonic": monotonic, "has_same_second": same_second}


func _schema_proof(path: String) -> Dictionary:
	var db := _open_raw(path)
	if db == null: return {}
	db.query("SELECT schema_version FROM persistence_schema WHERE singleton=1;")
	var version := int(db.query_result[0].schema_version)
	db.query("SELECT COUNT(*) AS count FROM sqlite_master WHERE type='table' AND name='recovery_checkpoints';")
	var recovery_tables := int(db.query_result[0].count)
	db.query("SELECT COUNT(*) AS count FROM sqlite_master WHERE type='index' AND name='recovery_checkpoints_latest_idx';")
	var recovery_indexes := int(db.query_result[0].count)
	db.close_db()
	return {"version": version, "recovery_tables": recovery_tables, "recovery_indexes": recovery_indexes}


func _current_proof(runtime: RefCounted) -> Dictionary:
	var current: Dictionary = runtime.persistence.get_current_game(runtime.game_id)
	var conversation: Dictionary = runtime.persistence.get_current_conversation(runtime.game_id)
	return {"game_id": runtime.game_id, "head": current.get("head_id", ""), "world": current.get("world_state", {}), "conversation": conversation.get("accepted_entries", [])}


func _apply_mutation(runtime: RefCounted, mutation: Dictionary) -> void:
	runtime.active_head_id = String(mutation.head_id)
	runtime.world_state = (mutation.world_state as Dictionary).duplicate(true)


func _accept(runtime: RefCounted, player: String, gm: String) -> bool:
	if runtime.conversation.begin_turn(player) == null: return _fail("begin Turn")
	runtime.conversation.append_delta(gm)
	var result: Dictionary = runtime.complete_active_generation_durably()
	return true if result.success else _fail("durable accept: %s" % result)


func _open_raw(path: String) -> SQLite:
	var db := SQLite.new(); db.path = path; db.default_extension = ""
	if not db.open_db():
		_fail("raw DB open: %s" % db.error_message)
		return null
	return db


func _execute_raw(path: String, sql: String) -> bool:
	var db := _open_raw(path)
	if db == null: return false
	var ok: bool = db.query(sql)
	var error: String = db.error_message
	db.close_db()
	return true if ok else _fail("raw SQL failed: %s" % error)


func _count_message(messages: Array, content: String) -> int:
	var count := 0
	for value: Variant in messages:
		if String((value as Dictionary).get("content", "")) == content: count += 1
	return count


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix): return argument.trim_prefix(prefix)
	return ""


func _path(file_name: String) -> String:
	return _root_path.path_join(file_name)


func _fail(message: String) -> bool:
	push_error("G3-05 PERSISTENCE FAIL | %s" % message)
	quit(1)
	return false
