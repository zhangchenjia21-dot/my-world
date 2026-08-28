extends SceneTree

const Persistence := preload("res://src/persistence/L3_外交层/世界持久化公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Conversation := preload("res://src/domain/会话.gd")

const V1_GAME := "v1-game"
const V1_H0 := "v1-head-0"
const V1_H1 := "v1-head-1"
const V1_W1 := {"clock": 1, "weather": "rain"}

var _root_path := ""


func _initialize() -> void:
	_root_path = _argument_value("--root=")
	if _root_path.is_empty(): return _fail("missing --root")
	DirAccess.make_dir_recursive_absolute(_root_path)
	if not _test_migration_success(): return
	if not _test_migration_failure_rollback(): return
	if not _test_first_run_and_reopen(): return
	if not _test_invalid_existing_states(): return
	if not _test_durable_acceptance_success(): return
	if not _test_durable_acceptance_failures(): return
	if not _test_only_accepted_truth_resumes(): return
	print("G3-03 PASS | migration + lifecycle + durable ordering suite")
	quit(0)


func _test_migration_success() -> bool:
	var path := _path("migration-success.sqlite")
	if not _create_v1_database(path, false): return false
	var api := Persistence.new()
	if not _expect(api.open_database(path), "ready", "v1 migrate open"): return false
	var current: Dictionary = api.get_current_game(V1_GAME)
	var count: Dictionary = api.timeline_node_count(V1_GAME)
	var conversation: Dictionary = api.get_current_conversation(V1_GAME)
	api.close_database()
	if current.status != "found" or current.head_id != V1_H1 or current.world_state != _json_round_trip(V1_W1):
		return _fail("migration did not preserve Game/World/head: %s" % current)
	if count.node_count != 2 or conversation.status != "found" or not conversation.accepted_entries.is_empty():
		return _fail("migration nodes/Conversation mismatch: count=%s conversation=%s" % [count, conversation])
	var proof := _raw_schema_proof(path)
	if proof.version != 4 or proof.conversation_tables != 1 or proof.save_tables != 1:
		return _fail("migration schema proof: %s" % proof)
	print("G3-03 PASS | production v1->current preserves H1/W1/2 nodes and seeds empty Conversation")
	return true


func _test_migration_failure_rollback() -> bool:
	var path := _path("migration-failure.sqlite")
	if not _create_v1_database(path, true): return false
	var api := Persistence.new()
	var opened: Dictionary = api.open_database(path)
	if opened.status != "storage_failure": return _fail("intentional migration failure not fail-loud: %s" % opened)
	var proof := _raw_schema_proof(path)
	if proof.version != 1 or proof.conversation_tables != 0 or proof.head != V1_H1 or proof.world_json != JSON.stringify(V1_W1, "", true, true):
		return _fail("failed migration did not preserve usable v1: %s" % proof)
	print("G3-03 PASS | intentional mid-migration failure rolls back table/seed/version")
	return true


func _test_first_run_and_reopen() -> bool:
	var path := _path("first-run.sqlite")
	if FileAccess.file_exists(path): return _fail("first-run fixture unexpectedly exists")
	var first := Runtime.new()
	var created: Dictionary = first.open_current_game(path)
	if created.status != "created" or created.accepted_count != 0 or created.world_state != {}:
		return _fail("first-run create: %s" % created)
	var game_id: String = created.game_id
	var head_id: String = created.head_id
	first.close()
	var second := Runtime.new()
	var resumed: Dictionary = second.open_current_game(path)
	second.close()
	if resumed.status != "resumed" or resumed.game_id != game_id or resumed.head_id != head_id or resumed.accepted_count != 0:
		return _fail("first-run identity did not survive reopen: %s" % resumed)
	print("G3-03 PASS | first run creates one stable Game/root/{} and exact reopen")
	return true


func _test_invalid_existing_states() -> bool:
	var zero_path := _path("zero-game.sqlite")
	var zero_api := Persistence.new()
	if not _expect(zero_api.open_database(zero_path), "ready", "zero schema"): return false
	zero_api.close_database()
	var zero_runtime := Runtime.new()
	if zero_runtime.open_current_game(zero_path).status != "missing_game": return _fail("existing zero Game minted fallback")

	var multi_path := _path("multi-game.sqlite")
	var multi_api := Persistence.new()
	if not _expect(multi_api.open_database(multi_path), "ready", "multi schema"): return false
	if not _expect(multi_api.create_initial_game("game-a", "root-a", {}, "2026-08-27T02:00:00Z"), "committed", "multi Game A"): return false
	if not _expect(multi_api.create_initial_game("game-b", "root-b", {}, "2026-08-27T02:00:01Z"), "committed", "multi Game B"): return false
	multi_api.close_database()
	var multi_runtime := Runtime.new()
	if multi_runtime.open_current_game(multi_path).status != "ambiguous_game": return _fail("multi Game was guessed")

	var corrupt_path := _path("corrupt.sqlite")
	var corrupt := FileAccess.open(corrupt_path, FileAccess.WRITE)
	corrupt.store_string("intentional G3-03 corrupt fixture")
	corrupt.close()
	var corrupt_runtime := Runtime.new()
	if corrupt_runtime.open_current_game(corrupt_path).status != "storage_failure": return _fail("corrupt DB became fresh Game")

	var unsupported_path := _path("unsupported.sqlite")
	var db := SQLite.new()
	db.path = unsupported_path
	db.default_extension = ""
	if not db.open_db() or not db.query("CREATE TABLE persistence_schema(singleton INTEGER PRIMARY KEY, schema_version INTEGER NOT NULL);") or not db.query("INSERT INTO persistence_schema VALUES (1, 99);"):
		return _fail("unsupported schema fixture")
	db.close_db()
	var unsupported_runtime := Runtime.new()
	if unsupported_runtime.open_current_game(unsupported_path).status != "schema_mismatch": return _fail("unsupported schema fallback")
	print("G3-03 PASS | zero/multi/corrupt/unsupported existing DB fail-loud without fresh fallback")
	return true


func _test_durable_acceptance_success() -> bool:
	var path := _path("durable-success.sqlite")
	var runtime := Runtime.new()
	if not runtime.open_current_game(path).success: return _fail("durable success open")
	if not _accept(runtime, "行动一", "回应一"): return false
	var old_gm := String(runtime.conversation.get_accepted_entries()[0].gm_text)
	runtime.conversation.retry_or_regenerate_latest()
	runtime.conversation.append_delta("回应一新版")
	var regen: Dictionary = runtime.complete_active_generation_durably()
	if not regen.success or runtime.conversation.get_accepted_entries().size() != 1 or String(runtime.conversation.get_accepted_entries()[0].gm_text) == old_gm:
		return _fail("durable regenerate success")
	runtime.conversation.correct_latest("行动一修正")
	runtime.conversation.append_delta("回应一修正")
	var correction: Dictionary = runtime.complete_active_generation_durably()
	if not correction.success or runtime.conversation.get_accepted_entries().size() != 1:
		return _fail("durable correction success")
	runtime.close()
	var reopened := Runtime.new()
	if not reopened.open_current_game(path).success: return _fail("durable success reopen")
	var entries: Array = reopened.conversation.get_accepted_entries()
	reopened.close()
	if entries.size() != 1 or String(entries[0].player_text) != "行动一修正" or String(entries[0].gm_text) != "回应一修正":
		return _fail("durable success exact rehydrate: %s" % entries)
	print("G3-03 PASS | new/regenerate/correction persist before Domain acceptance")
	return true


func _test_durable_acceptance_failures() -> bool:
	if not _test_one_write_failure("new-write-failure.sqlite", "new"): return false
	if not _test_one_write_failure("regenerate-write-failure.sqlite", "regenerate"): return false
	if not _test_one_write_failure("correction-write-failure.sqlite", "correction"): return false
	print("G3-03 PASS | new/regenerate/correction write failure preserves old Domain+DB truth")
	return true


func _test_one_write_failure(file_name: String, mode: String) -> bool:
	var path := _path(file_name)
	var seed := Runtime.new()
	if not seed.open_current_game(path).success: return _fail("failure seed open %s" % mode)
	if mode != "new" and not _accept(seed, "旧行动", "旧回应"): return false
	seed.close()
	if not _install_conversation_abort_trigger(path): return false
	var runtime := Runtime.new()
	if not runtime.open_current_game(path).success: return _fail("failure reopen %s" % mode)
	if mode == "new":
		runtime.conversation.begin_turn("新行动")
	elif mode == "regenerate":
		runtime.conversation.retry_or_regenerate_latest()
	else:
		runtime.conversation.correct_latest("修正行动")
	runtime.conversation.append_delta("不会保存的回应")
	var result: Dictionary = runtime.complete_active_generation_durably()
	var memory_entries: Array = runtime.conversation.get_accepted_entries()
	var state: int = runtime.conversation.generation_state
	runtime.close()
	var reopened := Runtime.new()
	if not reopened.open_current_game(path).success: return _fail("failure proof reopen %s" % mode)
	var durable_entries: Array = reopened.conversation.get_accepted_entries()
	reopened.close()
	if result.status != "persistence_failure" or state != Conversation.GenerationState.FAILED:
		return _fail("failure result/state %s: %s" % [mode, result])
	var expected_count := 0 if mode == "new" else 1
	if memory_entries.size() != expected_count or durable_entries.size() != expected_count:
		return _fail("partial accepted truth after %s failure" % mode)
	if expected_count == 1 and (String(memory_entries[0].player_text) != "旧行动" or String(durable_entries[0].gm_text) != "旧回应"):
		return _fail("old pair changed after %s failure" % mode)
	return true


func _test_only_accepted_truth_resumes() -> bool:
	for terminal: String in ["cancelled", "failed", "streaming"]:
		var path := _path("partial-%s.sqlite" % terminal)
		var runtime := Runtime.new()
		if not runtime.open_current_game(path).success or not _accept(runtime, "已接受行动", "已接受回应"): return _fail("partial seed %s" % terminal)
		runtime.conversation.begin_turn("不应恢复的行动")
		runtime.conversation.append_delta("不应恢复的 partial GM")
		if terminal == "cancelled": runtime.conversation.cancel_generation()
		elif terminal == "failed": runtime.conversation.fail_generation("transport")
		runtime.close()
		var reopened := Runtime.new()
		if not reopened.open_current_game(path).success: return _fail("partial reopen %s" % terminal)
		var entries: Array = reopened.conversation.get_accepted_entries()
		reopened.close()
		if entries.size() != 1 or String(entries[0].player_text) != "已接受行动" or String(entries[0].gm_text) != "已接受回应":
			return _fail("partial attempt resumed as truth: %s %s" % [terminal, entries])
	print("G3-03 PASS | cancelled/failed/streaming-only attempts never resume as accepted")
	return true


func _accept(runtime: RefCounted, player: String, gm: String) -> bool:
	if runtime.conversation.begin_turn(player) == null: return _fail("begin accepted Turn")
	runtime.conversation.append_delta(gm)
	var result: Dictionary = runtime.complete_active_generation_durably()
	return result.success if result.success else _fail("durable accept: %s" % result)


func _create_v1_database(path: String, fail_migration: bool) -> bool:
	var db := SQLite.new()
	db.path = path
	db.default_extension = ""
	db.foreign_keys = true
	if not db.open_db(): return _fail("open v1 fixture")
	var statements := [
		"CREATE TABLE persistence_schema(singleton INTEGER PRIMARY KEY CHECK(singleton = 1), schema_version INTEGER NOT NULL);",
		"CREATE TABLE games(game_id TEXT PRIMARY KEY, active_head_id TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL);",
		"CREATE TABLE timeline_nodes(game_id TEXT NOT NULL, node_id TEXT NOT NULL, parent_node_id TEXT, sequence_number INTEGER NOT NULL, mutation_id TEXT NOT NULL, intent_fingerprint TEXT NOT NULL, world_snapshot_json TEXT NOT NULL, created_at TEXT NOT NULL, PRIMARY KEY(game_id, node_id), UNIQUE(game_id, mutation_id), FOREIGN KEY(game_id) REFERENCES games(game_id));",
		"CREATE TABLE world_materializations(game_id TEXT PRIMARY KEY, head_id TEXT NOT NULL, materialization_json TEXT NOT NULL, updated_at TEXT NOT NULL, FOREIGN KEY(game_id) REFERENCES games(game_id));",
		"INSERT INTO persistence_schema VALUES (1, 1);",
		"INSERT INTO games VALUES ('%s', '%s', '2026-08-27T00:00:00Z', '2026-08-27T00:00:01Z');" % [V1_GAME, V1_H1],
		"INSERT INTO timeline_nodes VALUES ('%s', '%s', NULL, 0, '__root__', 'root-fingerprint', '%s', '2026-08-27T00:00:00Z');" % [V1_GAME, V1_H0, JSON.stringify({"clock": 0}, "", true, true)],
		"INSERT INTO timeline_nodes VALUES ('%s', '%s', '%s', 1, 'mutation-1', 'mutation-fingerprint', '%s', '2026-08-27T00:00:01Z');" % [V1_GAME, V1_H1, V1_H0, JSON.stringify(V1_W1, "", true, true)],
		"INSERT INTO world_materializations VALUES ('%s', '%s', '%s', '2026-08-27T00:00:01Z');" % [V1_GAME, V1_H1, JSON.stringify(V1_W1, "", true, true)],
	]
	if fail_migration:
		statements.append("CREATE TRIGGER abort_v2_version BEFORE UPDATE OF schema_version ON persistence_schema BEGIN SELECT RAISE(ABORT, 'intentional migration failure'); END;")
	for sql: String in statements:
		if not db.query(sql):
			var error: String = db.error_message
			db.close_db()
			return _fail("v1 fixture SQL: %s" % error)
	db.close_db()
	return true


func _raw_schema_proof(path: String) -> Dictionary:
	var db := SQLite.new()
	db.path = path
	db.default_extension = ""
	if not db.open_db(): return {}
	db.query("SELECT schema_version FROM persistence_schema WHERE singleton = 1;")
	var version := int(db.query_result[0].schema_version)
	db.query("SELECT COUNT(*) AS count FROM sqlite_master WHERE type = 'table' AND name = 'conversation_materializations';")
	var table_count := int(db.query_result[0].count)
	db.query("SELECT COUNT(*) AS count FROM sqlite_master WHERE type = 'table' AND name = 'save_points';")
	var save_table_count := int(db.query_result[0].count)
	db.query("SELECT active_head_id FROM games WHERE game_id = '%s';" % V1_GAME)
	var head := String(db.query_result[0].active_head_id)
	db.query("SELECT materialization_json FROM world_materializations WHERE game_id = '%s';" % V1_GAME)
	var world_json := String(db.query_result[0].materialization_json)
	db.close_db()
	return {"version": version, "conversation_tables": table_count, "save_tables": save_table_count, "head": head, "world_json": world_json}


func _install_conversation_abort_trigger(path: String) -> bool:
	var db := SQLite.new()
	db.path = path
	db.default_extension = ""
	if not db.open_db(): return _fail("open write-failure fixture")
	var ok: bool = db.query("CREATE TRIGGER abort_conversation_write BEFORE UPDATE ON conversation_materializations BEGIN SELECT RAISE(ABORT, 'intentional Conversation write failure'); END;")
	var error: String = db.error_message
	db.close_db()
	return true if ok else _fail("install Conversation failure trigger: %s" % error)


func _expect(result: Dictionary, status: String, label: String) -> bool:
	return true if result.get("status") == status else _fail("%s expected %s got %s" % [label, status, result])


func _json_round_trip(value: Variant) -> Variant:
	return JSON.parse_string(JSON.stringify(value))


func _path(file_name: String) -> String:
	return _root_path.path_join(file_name)


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix): return argument.trim_prefix(prefix)
	return ""


func _fail(message: String) -> bool:
	push_error("G3-03 FAIL | %s" % message)
	quit(1)
	return false
