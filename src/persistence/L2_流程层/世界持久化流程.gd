extends RefCounted

const Result := preload("res://src/persistence/L0_公理层/持久化操作结果.gd")
const Encoder := preload("res://src/persistence/L1_器件层/规范化文档编码器.gd")
const Connector := preload("res://src/persistence/L1_器件层/SQLite数据库连接器.gd")

const SCHEMA_VERSION := 2

var _connection: Variant = null


func open(database_path: String) -> Dictionary:
	if database_path.strip_edges().is_empty():
		return Result.make(Result.INVALID_INPUT, "database_path must be explicit and non-empty")
	if _require_open():
		return Result.make(Result.INVALID_INPUT, "database connection is already open")
	_connection = Connector.new()
	if not _connection.open_database(database_path):
		var message: String = _connection.last_error()
		_connection = null
		return Result.make(Result.STORAGE_FAILURE, message)
	var schema_result: Dictionary = _ensure_schema()
	if not schema_result.success:
		_connection.close_database()
		_connection = null
	return schema_result


func close() -> Dictionary:
	if _connection == null:
		return Result.make(Result.READY)
	var succeeded: bool = _connection.close_database()
	var message: String = _connection.last_error()
	_connection = null
	return Result.make(Result.READY) if succeeded else Result.make(Result.STORAGE_FAILURE, message)


func create_initial_game(game_id: String, root_node_id: String, world_state: Variant, created_at: String) -> Dictionary:
	var identity_error := _identity_error({"game_id": game_id, "root_node_id": root_node_id, "created_at": created_at})
	if not identity_error.is_empty():
		return Result.make(Result.INVALID_INPUT, identity_error)
	var encoded := Encoder.encode_document(world_state)
	if not encoded.ok:
		return Result.make(Result.INVALID_INPUT, encoded.error)
	if not _require_open():
		return Result.make(Result.NOT_OPEN, "database connection is not open")
	if not _connection.begin_immediate():
		return _storage_failure("begin initial Game")
	var existing_query: Dictionary = _connection.query_rows("SELECT game_id FROM games WHERE game_id = ?;", [game_id])
	if not existing_query.ok:
		return _rollback_storage_failure("query existing Game")
	var existing: Array = existing_query.rows
	if not existing.is_empty():
		_connection.rollback()
		return Result.make(Result.ALREADY_EXISTS, "game_id already exists", {"game_id": game_id})
	var root_mutation_id := "__root__:%s" % root_node_id
	var root_fingerprint := Encoder.fingerprint_intent(game_id, root_mutation_id, "", root_node_id, encoded.json)
	var statements := [
		["INSERT INTO games(game_id, active_head_id, created_at, updated_at) VALUES (?, ?, ?, ?);", [game_id, root_node_id, created_at, created_at]],
		["INSERT INTO timeline_nodes(game_id, node_id, parent_node_id, sequence_number, mutation_id, intent_fingerprint, world_snapshot_json, created_at) VALUES (?, ?, NULL, 0, ?, ?, ?, ?);", [game_id, root_node_id, root_mutation_id, root_fingerprint, encoded.json, created_at]],
		["INSERT INTO world_materializations(game_id, head_id, materialization_json, updated_at) VALUES (?, ?, ?, ?);", [game_id, root_node_id, encoded.json, created_at]],
		["INSERT INTO conversation_materializations(game_id, accepted_turns_json, revision, updated_at) VALUES (?, '[]', 0, ?);", [game_id, created_at]],
	]
	for statement: Array in statements:
		if not _connection.execute(statement[0], statement[1]):
			return _rollback_storage_failure("create initial Game")
	if not _connection.commit():
		return _rollback_storage_failure("commit initial Game")
	return Result.make(Result.COMMITTED, "initial Game committed", {"game_id": game_id, "head_id": root_node_id, "node_id": root_node_id, "world_state": encoded.document})


func list_game_identities() -> Dictionary:
	if not _require_open():
		return Result.make(Result.NOT_OPEN, "database connection is not open")
	var query: Dictionary = _connection.query_rows("SELECT game_id FROM games ORDER BY game_id;")
	if not query.ok:
		return _storage_failure("query Game identities")
	var game_ids: Array = []
	for row_value: Variant in query.rows:
		game_ids.append(String((row_value as Dictionary).game_id))
	return Result.make(Result.FOUND, "", {"game_ids": game_ids})


func get_current_conversation(game_id: String) -> Dictionary:
	if game_id.strip_edges().is_empty():
		return Result.make(Result.INVALID_INPUT, "game_id must be non-empty")
	if not _require_open():
		return Result.make(Result.NOT_OPEN, "database connection is not open")
	var query: Dictionary = _connection.query_rows("SELECT accepted_turns_json, revision FROM conversation_materializations WHERE game_id = ?;", [game_id])
	if not query.ok:
		return _storage_failure("query current Conversation")
	if query.rows.is_empty():
		return Result.make(Result.NOT_FOUND, "current Conversation materialization was not found", {"game_id": game_id})
	if query.rows.size() != 1:
		return Result.make(Result.STORAGE_FAILURE, "current Conversation query returned multiple rows")
	var row := query.rows[0] as Dictionary
	var accepted_entries: Variant = JSON.parse_string(String(row.accepted_turns_json))
	if typeof(accepted_entries) != TYPE_ARRAY:
		return Result.make(Result.STORAGE_FAILURE, "persisted accepted Conversation is not a valid JSON Array")
	return Result.make(Result.FOUND, "", {
		"game_id": game_id,
		"accepted_entries": accepted_entries,
		"revision": int(row.revision),
	})


func write_current_conversation(game_id: String, accepted_entries: Variant, updated_at: String) -> Dictionary:
	if game_id.strip_edges().is_empty() or updated_at.strip_edges().is_empty():
		return Result.make(Result.INVALID_INPUT, "game_id and updated_at must be non-empty")
	var encoded := Encoder.encode_json_value(accepted_entries)
	if not encoded.ok or typeof(encoded.value) != TYPE_ARRAY:
		return Result.make(Result.INVALID_INPUT, encoded.get("error", "accepted_entries must be a JSON Array"))
	if not _require_open():
		return Result.make(Result.NOT_OPEN, "database connection is not open")
	if not _connection.begin_immediate():
		return _storage_failure("begin current Conversation write")
	var current_query: Dictionary = _connection.query_rows("SELECT revision FROM conversation_materializations WHERE game_id = ?;", [game_id])
	if not current_query.ok:
		return _rollback_storage_failure("query current Conversation revision")
	if current_query.rows.is_empty():
		_connection.rollback()
		return Result.make(Result.NOT_FOUND, "current Conversation materialization was not found", {"game_id": game_id})
	var next_revision := int((current_query.rows[0] as Dictionary).revision) + 1
	if not _connection.execute("UPDATE conversation_materializations SET accepted_turns_json = ?, revision = revision + 1, updated_at = ? WHERE game_id = ?;", [encoded.json, updated_at, game_id]):
		return _rollback_storage_failure("write current Conversation")
	if _connection.changed_rows() != 1:
		return _rollback_storage_failure("write current Conversation materialization")
	if not _connection.commit():
		return _rollback_storage_failure("commit current Conversation")
	return Result.make(Result.COMMITTED, "current accepted Conversation committed", {
		"game_id": game_id,
		"accepted_entries": encoded.value,
		"revision": next_revision,
	})


func commit_world_mutation(game_id: String, mutation_id: String, expected_head_id: String, node_id: String, next_world_state: Variant, created_at: String) -> Dictionary:
	var identity_error := _identity_error({"game_id": game_id, "mutation_id": mutation_id, "expected_head_id": expected_head_id, "node_id": node_id, "created_at": created_at})
	if not identity_error.is_empty():
		return Result.make(Result.INVALID_INPUT, identity_error)
	var encoded := Encoder.encode_document(next_world_state)
	if not encoded.ok:
		return Result.make(Result.INVALID_INPUT, encoded.error)
	if not _require_open():
		return Result.make(Result.NOT_OPEN, "database connection is not open")
	var fingerprint := Encoder.fingerprint_intent(game_id, mutation_id, expected_head_id, node_id, encoded.json)
	if not _connection.begin_immediate():
		return _storage_failure("begin durable mutation")

	# Replay 必须先于 current-head CAS：lost ACK 后 current head 已前移，但同一 intent 仍应成功恢复。
	var prior_query: Dictionary = _connection.query_rows("SELECT node_id, parent_node_id, intent_fingerprint, world_snapshot_json FROM timeline_nodes WHERE game_id = ? AND mutation_id = ?;", [game_id, mutation_id])
	if not prior_query.ok:
		return _rollback_storage_failure("query prior mutation")
	var prior: Array = prior_query.rows
	if not prior.is_empty():
		var row := prior[0] as Dictionary
		_connection.rollback()
		if String(row.intent_fingerprint) == fingerprint:
			return Result.make(Result.REPLAY_SUCCESS, "previously committed mutation recovered", {"game_id": game_id, "head_id": String(row.node_id), "node_id": String(row.node_id), "world_state": JSON.parse_string(String(row.world_snapshot_json))})
		return Result.make(Result.MUTATION_CONFLICT, "mutation_id was already used for a different intent", {"game_id": game_id, "mutation_id": mutation_id})

	var games_query: Dictionary = _connection.query_rows("SELECT active_head_id FROM games WHERE game_id = ?;", [game_id])
	if not games_query.ok:
		return _rollback_storage_failure("query Game active head")
	var games: Array = games_query.rows
	if games.is_empty():
		_connection.rollback()
		return Result.make(Result.NOT_FOUND, "game_id was not found", {"game_id": game_id})
	var current_head := String((games[0] as Dictionary).active_head_id)
	if current_head != expected_head_id:
		_connection.rollback()
		return Result.make(Result.STALE_HEAD, "expected head does not match active head", {"expected_head_id": expected_head_id, "active_head_id": current_head})
	var parents_query: Dictionary = _connection.query_rows("SELECT sequence_number FROM timeline_nodes WHERE game_id = ? AND node_id = ?;", [game_id, expected_head_id])
	if not parents_query.ok:
		return _rollback_storage_failure("query active Timeline Node")
	var parents: Array = parents_query.rows
	if parents.size() != 1:
		return _rollback_storage_failure("active head has no unique Timeline Node")
	var next_sequence := int((parents[0] as Dictionary).sequence_number) + 1
	if not _connection.execute("INSERT INTO timeline_nodes(game_id, node_id, parent_node_id, sequence_number, mutation_id, intent_fingerprint, world_snapshot_json, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?);", [game_id, node_id, expected_head_id, next_sequence, mutation_id, fingerprint, encoded.json, created_at]):
		return _rollback_storage_failure("insert Timeline Node")
	if not _connection.execute("UPDATE world_materializations SET head_id = ?, materialization_json = ?, updated_at = ? WHERE game_id = ? AND head_id = ?;", [node_id, encoded.json, created_at, game_id, expected_head_id]) or _connection.changed_rows() != 1:
		return _rollback_storage_failure("compare-and-swap current World")
	# Game head 是最后一个 durable step；测试 trigger 会在此 abort，验证前两步整体回滚。
	if not _connection.execute("UPDATE games SET active_head_id = ?, updated_at = ? WHERE game_id = ? AND active_head_id = ?;", [node_id, created_at, game_id, expected_head_id]) or _connection.changed_rows() != 1:
		return _rollback_storage_failure("compare-and-swap Game active head")
	if not _connection.commit():
		return _rollback_storage_failure("commit durable mutation")
	return Result.make(Result.COMMITTED, "durable mutation committed", {"game_id": game_id, "head_id": node_id, "node_id": node_id, "parent_node_id": expected_head_id, "sequence": next_sequence, "world_state": encoded.document})


func get_current_game(game_id: String) -> Dictionary:
	if game_id.strip_edges().is_empty():
		return Result.make(Result.INVALID_INPUT, "game_id must be non-empty")
	if not _require_open():
		return Result.make(Result.NOT_OPEN, "database connection is not open")
	var query: Dictionary = _connection.query_rows("SELECT g.active_head_id, w.head_id, w.materialization_json FROM games g JOIN world_materializations w ON w.game_id = g.game_id WHERE g.game_id = ?;", [game_id])
	if not query.ok:
		return _storage_failure("query current Game")
	var rows: Array = query.rows
	if rows.is_empty():
		return Result.make(Result.NOT_FOUND, "game_id was not found", {"game_id": game_id})
	var row := rows[0] as Dictionary
	if String(row.active_head_id) != String(row.head_id):
		return Result.make(Result.STORAGE_FAILURE, "Game head and current World head diverged")
	return _decoded_found(String(row.active_head_id), String(row.materialization_json), {"game_id": game_id})


func get_timeline_node(game_id: String, node_id: String) -> Dictionary:
	if game_id.strip_edges().is_empty() or node_id.strip_edges().is_empty():
		return Result.make(Result.INVALID_INPUT, "game_id and node_id must be non-empty")
	if not _require_open():
		return Result.make(Result.NOT_OPEN, "database connection is not open")
	var query: Dictionary = _connection.query_rows("SELECT node_id, parent_node_id, sequence_number, mutation_id, world_snapshot_json FROM timeline_nodes WHERE game_id = ? AND node_id = ?;", [game_id, node_id])
	if not query.ok:
		return _storage_failure("query Timeline Node")
	var rows: Array = query.rows
	if rows.is_empty():
		return Result.make(Result.NOT_FOUND, "Timeline Node was not found", {"game_id": game_id, "node_id": node_id})
	var row := rows[0] as Dictionary
	return _decoded_found(String(row.node_id), String(row.world_snapshot_json), {"game_id": game_id, "node_id": String(row.node_id), "parent_node_id": row.parent_node_id, "sequence": int(row.sequence_number), "mutation_id": String(row.mutation_id)})


func timeline_node_count(game_id: String) -> Dictionary:
	if not _require_open():
		return Result.make(Result.NOT_OPEN, "database connection is not open")
	var query: Dictionary = _connection.query_rows("SELECT COUNT(*) AS node_count FROM timeline_nodes WHERE game_id = ?;", [game_id])
	if not query.ok:
		return _storage_failure("count Timeline Nodes")
	var rows: Array = query.rows
	if rows.size() != 1:
		return Result.make(Result.STORAGE_FAILURE, "count Timeline Nodes returned an invalid row shape")
	return Result.make(Result.FOUND, "", {"game_id": game_id, "node_count": int((rows[0] as Dictionary).node_count)})


func _ensure_schema() -> Dictionary:
	if not _connection.begin_immediate():
		return _storage_failure("begin schema initialization")
	var statements := [
		"CREATE TABLE IF NOT EXISTS persistence_schema(singleton INTEGER PRIMARY KEY CHECK(singleton = 1), schema_version INTEGER NOT NULL);",
		"CREATE TABLE IF NOT EXISTS games(game_id TEXT PRIMARY KEY, active_head_id TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL);",
		"CREATE TABLE IF NOT EXISTS timeline_nodes(game_id TEXT NOT NULL, node_id TEXT NOT NULL, parent_node_id TEXT, sequence_number INTEGER NOT NULL CHECK(sequence_number >= 0), mutation_id TEXT NOT NULL, intent_fingerprint TEXT NOT NULL, world_snapshot_json TEXT NOT NULL, created_at TEXT NOT NULL, PRIMARY KEY(game_id, node_id), UNIQUE(game_id, mutation_id), FOREIGN KEY(game_id) REFERENCES games(game_id) ON DELETE RESTRICT, FOREIGN KEY(game_id, parent_node_id) REFERENCES timeline_nodes(game_id, node_id) DEFERRABLE INITIALLY DEFERRED);",
		"CREATE TABLE IF NOT EXISTS world_materializations(game_id TEXT PRIMARY KEY, head_id TEXT NOT NULL, materialization_json TEXT NOT NULL, updated_at TEXT NOT NULL, FOREIGN KEY(game_id) REFERENCES games(game_id) ON DELETE RESTRICT, FOREIGN KEY(game_id, head_id) REFERENCES timeline_nodes(game_id, node_id) DEFERRABLE INITIALLY DEFERRED);",
		"INSERT OR IGNORE INTO persistence_schema(singleton, schema_version) VALUES (1, 2);",
	]
	for sql: String in statements:
		if not _connection.execute(sql):
			return _rollback_storage_failure("initialize production schema v1")
	var meta_inserted: int = _connection.changed_rows()
	var version_query: Dictionary = _connection.query_rows("SELECT schema_version FROM persistence_schema WHERE singleton = 1;")
	if not version_query.ok:
		return _rollback_storage_failure("query production schema version")
	var versions: Array = version_query.rows
	if versions.size() != 1:
		_connection.rollback()
		return Result.make(Result.SCHEMA_MISMATCH, "production schema version source is invalid")
	var version := int((versions[0] as Dictionary).schema_version)
	if version == 1:
		# v1→v2 是单笔 additive migration；test-only trigger 可在 version UPDATE 中止，
		# 从而证明 table/seed/version 全部 rollback，既有 Game/World/Timeline 不受影响。
		var migration_statements := [
			"CREATE TABLE conversation_materializations(game_id TEXT PRIMARY KEY, accepted_turns_json TEXT NOT NULL, revision INTEGER NOT NULL DEFAULT 0 CHECK(revision >= 0), updated_at TEXT NOT NULL, FOREIGN KEY(game_id) REFERENCES games(game_id) ON DELETE RESTRICT);",
			"INSERT INTO conversation_materializations(game_id, accepted_turns_json, revision, updated_at) SELECT game_id, '[]', 0, updated_at FROM games;",
			"UPDATE persistence_schema SET schema_version = 2 WHERE singleton = 1 AND schema_version = 1;",
		]
		for sql: String in migration_statements:
			if not _connection.execute(sql):
				return _rollback_storage_failure("migrate production schema v1 to v2")
		version = SCHEMA_VERSION
	elif version == SCHEMA_VERSION and meta_inserted == 1:
		if not _connection.execute("CREATE TABLE conversation_materializations(game_id TEXT PRIMARY KEY, accepted_turns_json TEXT NOT NULL, revision INTEGER NOT NULL DEFAULT 0 CHECK(revision >= 0), updated_at TEXT NOT NULL, FOREIGN KEY(game_id) REFERENCES games(game_id) ON DELETE RESTRICT);"):
			return _rollback_storage_failure("create production schema v2 Conversation table")
	elif version == SCHEMA_VERSION:
		var table_query: Dictionary = _connection.query_rows("SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'conversation_materializations';")
		if not table_query.ok:
			return _rollback_storage_failure("verify production schema v2")
		if table_query.rows.size() != 1:
			_connection.rollback()
			return Result.make(Result.SCHEMA_MISMATCH, "production schema v2 Conversation table is missing")
	else:
		_connection.rollback()
		return Result.make(Result.SCHEMA_MISMATCH, "unsupported production schema version %d" % version)
	if not _connection.commit():
		return _rollback_storage_failure("commit production schema v2")
	return Result.make(Result.READY, "production schema v2 ready", {"schema_version": SCHEMA_VERSION})


func _decoded_found(head_id: String, json_text: String, details: Dictionary) -> Dictionary:
	var decoded: Variant = JSON.parse_string(json_text)
	if typeof(decoded) != TYPE_DICTIONARY:
		return Result.make(Result.STORAGE_FAILURE, "persisted World materialization is not valid JSON object")
	details["head_id"] = head_id
	details["world_state"] = decoded
	return Result.make(Result.FOUND, "", details)


func _identity_error(fields: Dictionary) -> String:
	for key: Variant in fields:
		if String(fields[key]).strip_edges().is_empty():
			return "%s must be non-empty" % String(key)
	return ""


func _require_open() -> bool:
	return _connection != null and _connection.is_open()


func _storage_failure(step: String) -> Dictionary:
	return Result.make(Result.STORAGE_FAILURE, "%s: %s" % [step, _connection.last_error()])


func _rollback_storage_failure(step: String) -> Dictionary:
	var cause: String = _connection.last_error()
	_connection.rollback()
	return Result.make(Result.STORAGE_FAILURE, "%s: %s" % [step, cause])
