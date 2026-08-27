extends SceneTree

const Persistence := preload("res://src/persistence/L3_外交层/世界持久化公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const ContextAssembler := preload("res://src/context/上下文组装器.gd")

const FUTURE_MARKER := "FUTURE_ONLY_SECRET_G304"
var _root_path := ""


func _initialize() -> void:
	_root_path = _argument_value("--root=")
	if _root_path.is_empty(): return _fail("missing --root")
	DirAccess.make_dir_recursive_absolute(_root_path)
	if not _test_v2_migration(false): return
	if not _test_v2_migration(true): return
	if not _test_save_and_restore(): return
	if not _test_save_failure(): return
	if not _test_restore_failures(): return
	print("G3-04 PASS | schema v3 + Save + atomic Restore persistence suite")
	quit(0)


func _test_v2_migration(failing: bool) -> bool:
	var path := _path("migration-failure.sqlite" if failing else "migration-success.sqlite")
	var seed := Runtime.new()
	if not seed.open_current_game(path).success or not _accept(seed, "迁移前行动", "迁移前回应"):
		return _fail("v2 fixture seed")
	var expected_game: String = seed.game_id
	var expected_head: String = seed.active_head_id
	seed.close()
	var db := SQLite.new()
	db.path = path
	db.default_extension = ""
	if not db.open_db(): return _fail("open v2 downgrade fixture")
	if not db.query("DROP TABLE save_points;") or not db.query("UPDATE persistence_schema SET schema_version = 2;"):
		return _fail("downgrade fixture to v2: %s" % db.error_message)
	if failing and not db.query("CREATE TRIGGER abort_v3_version BEFORE UPDATE OF schema_version ON persistence_schema BEGIN SELECT RAISE(ABORT, 'intentional v3 migration failure'); END;"):
		return _fail("install v3 migration trigger")
	db.close_db()
	var api := Persistence.new()
	var opened: Dictionary = api.open_database(path)
	if failing:
		if opened.status != "storage_failure": return _fail("v3 migration failure not fail-loud: %s" % opened)
		var proof := _schema_proof(path)
		if proof.version != 2 or proof.save_tables != 0:
			return _fail("failed v3 migration did not rollback: %s" % proof)
		print("G3-04 PASS | intentional v2->v3 failure leaves usable v2")
		return true
	if not opened.success: return _fail("v2->v3 open: %s" % opened)
	var current: Dictionary = api.get_current_game(expected_game)
	var conversation: Dictionary = api.get_current_conversation(expected_game)
	var saves: Dictionary = api.list_save_points(expected_game)
	api.close_database()
	var proof := _schema_proof(path)
	if proof.version != 3 or proof.save_tables != 1 or current.head_id != expected_head or conversation.accepted_entries.size() != 1 or not saves.save_points.is_empty():
		return _fail("v2->v3 did not preserve current truth: %s %s %s %s" % [proof, current, conversation, saves])
	print("G3-04 PASS | v2->v3 additive migration preserves Game/World/Conversation")
	return true


func _test_save_and_restore() -> bool:
	var path := _path("save-restore.sqlite")
	var runtime := Runtime.new()
	if not runtime.open_current_game(path).success: return _fail("save/restore open")
	for index: int in range(14):
		if not _accept(runtime, "保存前行动%02d" % index, "保存前回应%02d" % index): return false
	var saved_head: String = runtime.active_head_id
	var saved_world: Dictionary = runtime.world_state.duplicate(true)
	var saved_entries: Array = runtime.conversation.get_durable_accepted_entries()
	var save_a: Dictionary = runtime.create_save_point("测试存档甲")
	var save_duplicate: Dictionary = runtime.create_save_point("测试存档甲")
	if not save_a.success or not save_duplicate.success or save_a.save_id == save_duplicate.save_id:
		return _fail("Unicode/duplicate display-name Save failed")
	if runtime.create_save_point("   ").status != "invalid_input": return _fail("empty Save name allowed")
	var mutation: Dictionary = runtime.persistence.commit_world_mutation(runtime.game_id, "g304-mutation", runtime.active_head_id, "g304-head-2", {"place": "future", "secret": FUTURE_MARKER}, "2026-08-27T08:00:00Z")
	if not mutation.success: return _fail("future World mutation: %s" % mutation)
	runtime.active_head_id = String(mutation.head_id)
	runtime.world_state = (mutation.world_state as Dictionary).duplicate(true)
	if not _accept(runtime, "未来行动 %s" % FUTURE_MARKER, "未来回应 %s" % FUTURE_MARKER): return false
	var future_head: String = runtime.active_head_id
	var node_count_before: Dictionary = runtime.persistence.timeline_node_count(runtime.game_id)
	var restored: Dictionary = runtime.restore_save_point(save_a.save_id)
	if not restored.success: return _fail("restore old Save: %s" % restored)
	if runtime.active_head_id != saved_head or runtime.world_state != saved_world or runtime.conversation.get_durable_accepted_entries() != saved_entries:
		return _fail("Runtime current triple did not restore exactly")
	var future_node: Dictionary = runtime.persistence.get_timeline_node(runtime.game_id, future_head)
	var node_count_after: Dictionary = runtime.persistence.timeline_node_count(runtime.game_id)
	var listed: Dictionary = runtime.list_save_points()
	if not future_node.success or node_count_after.node_count != node_count_before.node_count or listed.save_points.size() != 2:
		return _fail("Restore deleted Timeline/Save history")
	runtime.conversation.begin_turn("恢复后的当前行动")
	var messages: Array = ContextAssembler.new().assemble_messages(runtime.conversation.get_context_projection(), "")
	var serialized := JSON.stringify(messages)
	if serialized.contains(FUTURE_MARKER) or messages.size() != 26 or String(messages[-1].content) != "恢复后的当前行动" or _count_message(messages, "恢复后的当前行动") != 1:
		return _fail("future-memory isolation/recent-12 failed: %s" % messages)
	if serialized.contains("materialization_json") or String(messages[0].content).contains("Current Game Context"):
		return _fail("raw World/persisted Context entered Provider messages")
	runtime.conversation.cancel_generation()
	runtime.close()
	var reopened := Runtime.new()
	if not reopened.open_current_game(path).success or reopened.active_head_id != saved_head or reopened.conversation.get_durable_accepted_entries() != saved_entries:
		return _fail("normal reopen after Restore mismatch")
	if not _accept(reopened, "恢复后新未来", "恢复后新回应"): return false
	reopened.close()
	var final := Runtime.new()
	if not final.open_current_game(path).success or final.conversation.get_durable_accepted_entries().size() != 15:
		return _fail("post-Restore new future did not survive reopen")
	final.close()
	print("G3-04 PASS | Save exact history, World+Conversation Restore, retained future nodes, future isolation, reopen+continue")
	return true


func _test_save_failure() -> bool:
	var path := _path("save-failure.sqlite")
	var runtime := Runtime.new()
	if not runtime.open_current_game(path).success or not _accept(runtime, "旧行动", "旧回应"): return _fail("Save failure seed")
	var before := _current_proof(runtime)
	if not _execute_raw(path, "CREATE TRIGGER abort_save_insert BEFORE INSERT ON save_points BEGIN SELECT RAISE(ABORT, 'intentional Save failure'); END;"):
		return false
	var saved: Dictionary = runtime.create_save_point("不会成功")
	var after := _current_proof(runtime)
	var listed: Dictionary = runtime.list_save_points()
	runtime.close()
	if saved.status != "storage_failure" or before != after or not listed.save_points.is_empty():
		return _fail("Save failure mutated current/created row: %s" % saved)
	print("G3-04 PASS | Save write failure is non-mutating and fail-loud")
	return true


func _test_restore_failures() -> bool:
	for mode: String in ["late_head", "late_conversation", "missing_anchor", "invalid_conversation"]:
		var path := _path("restore-%s.sqlite" % mode)
		var runtime := Runtime.new()
		if not runtime.open_current_game(path).success or not _accept(runtime, "旧行动", "旧回应"): return _fail("Restore failure seed %s" % mode)
		var saved: Dictionary = runtime.create_save_point("恢复目标")
		if not saved.success or not _accept(runtime, "当前未来", "当前未来回应"): return _fail("Restore failure future %s" % mode)
		var before := _current_proof(runtime)
		if mode == "late_head":
			if not _execute_raw(path, "CREATE TRIGGER abort_restore_head BEFORE UPDATE OF active_head_id ON games BEGIN SELECT RAISE(ABORT, 'intentional head Restore failure'); END;"): return false
		elif mode == "late_conversation":
			if not _execute_raw(path, "CREATE TRIGGER abort_restore_conversation BEFORE UPDATE ON conversation_materializations BEGIN SELECT RAISE(ABORT, 'intentional late Restore failure'); END;"): return false
		elif mode == "missing_anchor":
			if not _execute_raw(path, "PRAGMA foreign_keys=OFF; UPDATE save_points SET timeline_node_id='missing-anchor' WHERE save_id='%s';" % saved.save_id): return false
		else:
			if not _execute_raw(path, "UPDATE save_points SET accepted_turns_json='[{\"player_text\":\"x\",\"gm_text\":\"   \"}]' WHERE save_id='%s';" % saved.save_id): return false
		var result: Dictionary = runtime.restore_save_point(saved.save_id)
		var after := _current_proof(runtime)
		runtime.close()
		if result.success or before != after:
			return _fail("%s Restore failure mutated current triple: %s" % [mode, result])
	var missing := Runtime.new()
	if not missing.open_current_game(_path("missing-save.sqlite")).success: return _fail("missing Save open")
	var missing_before := _current_proof(missing)
	var missing_result: Dictionary = missing.restore_save_point("unknown-save")
	var missing_after := _current_proof(missing)
	missing.close()
	if missing_result.status != "not_found" or missing_before != missing_after:
		return _fail("missing Save did not preserve current")
	print("G3-04 PASS | missing/invalid/late-step Restore failures preserve old current triple")
	return true


func _current_proof(runtime: RefCounted) -> Dictionary:
	var current: Dictionary = runtime.persistence.get_current_game(runtime.game_id)
	var conversation: Dictionary = runtime.persistence.get_current_conversation(runtime.game_id)
	return {"head": current.get("head_id", ""), "world": current.get("world_state", {}), "conversation": conversation.get("accepted_entries", [])}


func _accept(runtime: RefCounted, player: String, gm: String) -> bool:
	if runtime.conversation.begin_turn(player) == null: return _fail("begin Turn")
	runtime.conversation.append_delta(gm)
	var result: Dictionary = runtime.complete_active_generation_durably()
	return true if result.success else _fail("durable accept: %s" % result)


func _schema_proof(path: String) -> Dictionary:
	var db := SQLite.new(); db.path = path; db.default_extension = ""
	if not db.open_db(): return {}
	db.query("SELECT schema_version FROM persistence_schema WHERE singleton=1;")
	var version := int(db.query_result[0].schema_version)
	db.query("SELECT COUNT(*) AS count FROM sqlite_master WHERE type='table' AND name='save_points';")
	var save_tables := int(db.query_result[0].count)
	db.close_db()
	return {"version": version, "save_tables": save_tables}


func _execute_raw(path: String, sql: String) -> bool:
	var db := SQLite.new(); db.path = path; db.default_extension = ""
	if not db.open_db(): return _fail("raw DB open")
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
	push_error("G3-04 PERSISTENCE FAIL | %s" % message)
	quit(1)
	return false
