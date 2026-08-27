extends SceneTree

const Persistence := preload("res://src/persistence/L3_外交层/世界持久化公开接口.gd")
const GAME_ID := "query-failure-game"
const H0 := "query-head-0"
const W0 := {"clock": 0, "weather": "clear"}

var _root_path := ""


func _initialize() -> void:
	_root_path = _argument_value("--root=")
	if _root_path.is_empty():
		_fail("missing --root")
		return
	DirAccess.make_dir_recursive_absolute(_root_path)
	if not _test_current_game_query_failure(): return
	if not _test_timeline_node_query_failure(): return
	if not _test_timeline_count_query_failure(): return
	if not _test_mutation_preflight_query_failure(): return
	if not _test_successful_zero_row_is_not_found(): return
	print("G3-02 IR-01 PASS | query failure propagation suite")
	quit(0)


func _test_current_game_query_failure() -> bool:
	var path := _database_path("current-query-failure.sqlite")
	if not _seed_database(path): return false
	if not _damage_schema(path, ["ALTER TABLE world_materializations RENAME COLUMN materialization_json TO damaged_materialization_json;"]): return false
	var api := Persistence.new()
	if not _expect(api.open_database(path), "ready", "current failure reopen"): return false
	var result: Dictionary = api.get_current_game(GAME_ID)
	api.close_database()
	if not _expect_storage_failure(result, "get_current_game SELECT failure"): return false
	print("G3-02 IR-01 PASS | get_current_game query failure -> storage_failure")
	return true


func _test_timeline_node_query_failure() -> bool:
	var path := _database_path("node-query-failure.sqlite")
	if not _seed_database(path): return false
	if not _damage_schema(path, ["ALTER TABLE timeline_nodes RENAME COLUMN world_snapshot_json TO damaged_snapshot_json;"]): return false
	var api := Persistence.new()
	if not _expect(api.open_database(path), "ready", "node failure reopen"): return false
	var result: Dictionary = api.get_timeline_node(GAME_ID, H0)
	api.close_database()
	if not _expect_storage_failure(result, "get_timeline_node SELECT failure"): return false
	print("G3-02 IR-01 PASS | get_timeline_node query failure -> storage_failure")
	return true


func _test_timeline_count_query_failure() -> bool:
	var path := _database_path("count-query-failure.sqlite")
	if not _seed_database(path): return false
	if not _damage_schema(path, [
		"DROP TABLE world_materializations;",
		"DROP TABLE timeline_nodes;",
		"CREATE VIEW timeline_nodes AS SELECT * FROM deliberately_missing_timeline_source;",
	]): return false
	var api := Persistence.new()
	if not _expect(api.open_database(path), "ready", "count failure reopen"): return false
	var result: Dictionary = api.timeline_node_count(GAME_ID)
	api.close_database()
	if not _expect_storage_failure(result, "timeline_node_count SELECT failure"): return false
	print("G3-02 IR-01 PASS | timeline_node_count query failure -> storage_failure without runtime error")
	return true


func _test_mutation_preflight_query_failure() -> bool:
	var path := _database_path("mutation-query-failure.sqlite")
	if not _seed_database(path): return false
	if not _damage_schema(path, ["ALTER TABLE timeline_nodes RENAME COLUMN intent_fingerprint TO damaged_intent_fingerprint;"]): return false
	var api := Persistence.new()
	if not _expect(api.open_database(path), "ready", "mutation failure reopen"): return false
	var result: Dictionary = api.commit_world_mutation(GAME_ID, "query-mutation-1", H0, "query-head-1", {"clock": 1}, "2026-08-27T01:00:01Z")
	if not _expect_storage_failure(result, "mutation replay preflight SELECT failure"): return false
	var current: Dictionary = api.get_current_game(GAME_ID)
	var count: Dictionary = api.timeline_node_count(GAME_ID)
	var absent: Dictionary = api.get_timeline_node(GAME_ID, "query-head-1")
	api.close_database()
	if current.status != "found" or current.head_id != H0 or current.world_state != _json_round_trip(W0):
		return _fail("mutation query failure changed current truth: %s" % current)
	if count.status != "found" or count.node_count != 1 or absent.status != "not_found":
		return _fail("mutation query failure left partial node: count=%s absent=%s" % [count, absent])
	print("G3-02 IR-01 PASS | mutation preflight query failure rolls back with no partial truth")
	return true


func _test_successful_zero_row_is_not_found() -> bool:
	var path := _database_path("successful-zero-row.sqlite")
	if not _seed_database(path): return false
	var api := Persistence.new()
	if not _expect(api.open_database(path), "ready", "zero-row reopen"): return false
	var missing_game: Dictionary = api.get_current_game("missing-game")
	var missing_node: Dictionary = api.get_timeline_node(GAME_ID, "missing-node")
	api.close_database()
	if not _expect(missing_game, "not_found", "successful zero-row Game query"): return false
	if not _expect(missing_node, "not_found", "successful zero-row Node query"): return false
	print("G3-02 IR-01 PASS | successful zero-row queries remain not_found")
	return true


func _seed_database(path: String) -> bool:
	var api := Persistence.new()
	if not _expect(api.open_database(path), "ready", "seed open"): return false
	if not _expect(api.create_initial_game(GAME_ID, H0, W0, "2026-08-27T01:00:00Z"), "committed", "seed Game"): return false
	if not _expect(api.close_database(), "ready", "seed close"): return false
	return true


func _damage_schema(path: String, statements: Array) -> bool:
	var database := SQLite.new()
	database.path = path
	database.default_extension = ""
	database.foreign_keys = false
	if not database.open_db():
		return _fail("open isolated damage database: %s" % database.error_message)
	for sql: String in statements:
		if not database.query(sql):
			var error: String = database.error_message
			database.close_db()
			return _fail("apply isolated schema damage: %s" % error)
	database.close_db()
	return true


func _database_path(file_name: String) -> String:
	return _root_path.path_join(file_name)


func _expect(result: Dictionary, expected_status: String, label: String) -> bool:
	if result.get("status") != expected_status:
		return _fail("%s expected %s, got %s" % [label, expected_status, result])
	return true


func _expect_storage_failure(result: Dictionary, label: String) -> bool:
	if result.get("status") != "storage_failure" or String(result.get("message", "")).strip_edges().is_empty():
		return _fail("%s expected visible storage_failure cause, got %s" % [label, result])
	return true


func _json_round_trip(value: Variant) -> Variant:
	return JSON.parse_string(JSON.stringify(value))


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix): return argument.trim_prefix(prefix)
	return ""


func _fail(message: String) -> bool:
	push_error("G3-02 IR-01 FAIL | %s" % message)
	quit(1)
	return false
