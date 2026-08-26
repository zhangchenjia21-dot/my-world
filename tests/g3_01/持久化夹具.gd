extends RefCounted

## G3-01 隔离 Persistence fixture。
##
## 这里的 key/value state、表名和字段只证明 identity、transaction、timeline reference、
## migration 与 recovery 边界，不是 G3-02 production World schema，更不冻结 G5 领域对象。

const GAME_ID := "g3-fixture-game-001"
const INITIAL_HEAD_ID := "g3-head-001"


static func open_database(database_path: String) -> Object:
	var database := SQLite.new()
	database.path = database_path
	database.default_extension = ""
	database.verbosity_level = SQLite.QUIET
	database.foreign_keys = true
	if not database.open_db():
		push_error("G3-01 SQLite open failed: %s" % database.error_message)
		return null
	# FULL + WAL 让 COMMIT 成为明确 durable boundary；本任务仍以真实 crash/reopen 证明，
	# 不把 pragma 或 SQLite 理论性质本身当作验收证据。
	if not execute(database, "PRAGMA journal_mode=WAL;"):
		database.close_db()
		return null
	if not execute(database, "PRAGMA synchronous=FULL;"):
		database.close_db()
		return null
	return database


static func execute(database: Object, sql: String, bindings: Array = []) -> bool:
	var succeeded: bool
	if bindings.is_empty():
		succeeded = database.query(sql)
	else:
		succeeded = database.query_with_bindings(sql, bindings)
	if not succeeded:
		push_error("G3-01 SQLite query failed: %s" % database.error_message)
	return succeeded


static func scalar(database: Object, sql: String, bindings: Array, column: String) -> Variant:
	if not execute(database, sql, bindings):
		return null
	if database.query_result.is_empty():
		return null
	return (database.query_result[0] as Dictionary).get(column)


static func create_schema_v1(database: Object) -> bool:
	var statements := [
		"CREATE TABLE g3_fixture_meta (singleton INTEGER PRIMARY KEY CHECK (singleton = 1), schema_version INTEGER NOT NULL);",
		"CREATE TABLE g3_fixture_games (game_id TEXT PRIMARY KEY, active_head_id TEXT NOT NULL, created_at TEXT NOT NULL, FOREIGN KEY (active_head_id) REFERENCES g3_fixture_timeline_nodes(node_id) DEFERRABLE INITIALLY DEFERRED);",
		"CREATE TABLE g3_fixture_timeline_nodes (node_id TEXT PRIMARY KEY, game_id TEXT NOT NULL, parent_node_id TEXT, sequence INTEGER NOT NULL, kind TEXT NOT NULL, created_at TEXT NOT NULL, UNIQUE (game_id, node_id), FOREIGN KEY (game_id) REFERENCES g3_fixture_games(game_id), FOREIGN KEY (parent_node_id) REFERENCES g3_fixture_timeline_nodes(node_id));",
		"CREATE TABLE g3_fixture_state (game_id TEXT NOT NULL, key TEXT NOT NULL, value TEXT NOT NULL, PRIMARY KEY (game_id, key), FOREIGN KEY (game_id) REFERENCES g3_fixture_games(game_id));",
		"CREATE TABLE g3_fixture_snapshots (node_id TEXT PRIMARY KEY, game_id TEXT NOT NULL, state_json TEXT NOT NULL, FOREIGN KEY (game_id, node_id) REFERENCES g3_fixture_timeline_nodes(game_id, node_id));",
		"CREATE TABLE g3_fixture_save_points (save_id TEXT PRIMARY KEY, game_id TEXT NOT NULL, timeline_node_id TEXT NOT NULL, display_name TEXT NOT NULL, FOREIGN KEY (game_id, timeline_node_id) REFERENCES g3_fixture_timeline_nodes(game_id, node_id));",
		"CREATE TABLE g3_fixture_recovery_refs (recovery_id TEXT PRIMARY KEY, game_id TEXT NOT NULL, timeline_node_id TEXT NOT NULL, kind TEXT NOT NULL, FOREIGN KEY (game_id, timeline_node_id) REFERENCES g3_fixture_timeline_nodes(game_id, node_id));",
	]
	if not execute(database, "BEGIN IMMEDIATE;"):
		return false
	for statement: String in statements:
		if not execute(database, statement):
			database.query("ROLLBACK;")
			return false
	if not execute(database, "INSERT INTO g3_fixture_meta(singleton, schema_version) VALUES (1, 1);"):
		database.query("ROLLBACK;")
		return false
	return execute(database, "COMMIT;")


static func seed_initial_game(database: Object) -> bool:
	if not execute(database, "BEGIN IMMEDIATE;"):
		return false
	var writes := [
		["INSERT INTO g3_fixture_games(game_id, active_head_id, created_at) VALUES (?, ?, ?);", [GAME_ID, INITIAL_HEAD_ID, "2026-08-26T00:00:00Z"]],
		["INSERT INTO g3_fixture_timeline_nodes(node_id, game_id, parent_node_id, sequence, kind, created_at) VALUES (?, ?, NULL, 1, ?, ?);", [INITIAL_HEAD_ID, GAME_ID, "checkpoint", "2026-08-26T00:00:00Z"]],
		["INSERT INTO g3_fixture_state(game_id, key, value) VALUES (?, 'fixture_status', 'stable-1');", [GAME_ID]],
		["INSERT INTO g3_fixture_state(game_id, key, value) VALUES (?, 'fixture_counter', '1');", [GAME_ID]],
		["INSERT INTO g3_fixture_snapshots(node_id, game_id, state_json) VALUES (?, ?, ?);", [INITIAL_HEAD_ID, GAME_ID, '{"fixture_status":"stable-1","fixture_counter":"1"}']],
		["INSERT INTO g3_fixture_save_points(save_id, game_id, timeline_node_id, display_name) VALUES ('g3-save-001', ?, ?, '起始检查点');", [GAME_ID, INITIAL_HEAD_ID]],
	]
	for write: Array in writes:
		if not execute(database, write[0], write[1]):
			database.query("ROLLBACK;")
			return false
	return execute(database, "COMMIT;")


static func commit_mutation(database: Object, node_id: String, parent_id: String, state_value: String, sequence: int) -> bool:
	if not execute(database, "BEGIN IMMEDIATE;"):
		return false
	var writes := [
		["UPDATE g3_fixture_state SET value = ? WHERE game_id = ? AND key = 'fixture_status';", [state_value, GAME_ID]],
		["INSERT INTO g3_fixture_timeline_nodes(node_id, game_id, parent_node_id, sequence, kind, created_at) VALUES (?, ?, ?, ?, 'mutation', ?);", [node_id, GAME_ID, parent_id, sequence, "2026-08-26T00:00:0%dZ" % sequence]],
		["INSERT INTO g3_fixture_snapshots(node_id, game_id, state_json) VALUES (?, ?, ?);", [node_id, GAME_ID, JSON.stringify({"fixture_status": state_value, "fixture_counter": "1"})]],
		["UPDATE g3_fixture_games SET active_head_id = ? WHERE game_id = ?;", [node_id, GAME_ID]],
	]
	for write: Array in writes:
		if not execute(database, write[0], write[1]):
			database.query("ROLLBACK;")
			return false
	return execute(database, "COMMIT;")
