extends RefCounted

## SQLite physical safety flow。只拥有 writer coordination、物理检查、online backup
## publication 与 staged disaster recovery；不解释 Save Point/Timeline/Conversation 业务语义。

const Connector := preload("res://src/persistence/L1_器件层/SQLite数据库连接器.gd")
const WriterLock := preload("res://src/persistence/L1_器件层/单写者所有权锁.gd")

const CURRENT_SCHEMA_VERSION := 4

var _writer_lock: RefCounted = WriterLock.new()
var _database_path := ""
var _recovery_root := ""
var _test_crash_hook: Callable = Callable()


func acquire_writer(database_path: String) -> Dictionary:
	if database_path.strip_edges().is_empty():
		return _result(false, "invalid_path", "database path is empty")
	_database_path = database_path
	_recovery_root = "%s.recovery" % database_path.get_basename()
	return _writer_lock.acquire("%s.writer-lock.sqlite" % database_path.get_basename())


func release_writer() -> Dictionary:
	return _writer_lock.release()


## 在 production migration/open 前分类 existing physical storage。missing 只有在没有任何
## recovery artifact 时才是 first_run；logical invalidity 不会被伪装成 corruption。
func inspect_startup() -> Dictionary:
	if not _writer_lock.is_owned():
		return _result(false, "not_owned", "writer ownership is required")
	if not FileAccess.file_exists(_database_path):
		return _result(true, "interrupted_recovery" if _has_recovery_artifacts() else "normal_missing", "", {
			"backup": _select_verified_backup(),
		})
	# Startup physical classification does not steal one-current-Game ownership from Runtime;
	# zero/multi identities remain readable here and are classified by the existing Game lifecycle seam.
	var inspection := verify_database(_database_path, false)
	if inspection.success:
		return inspection
	if String(inspection.status) == "unsupported_newer_schema":
		return inspection
	if bool(inspection.get("physical_failure", false)):
		return _result(false, "physical_corruption", String(inspection.message), {
			"physical_failure": true,
			"backup": _select_verified_backup(),
		})
	return inspection


## 验证 physical SQLite 与当前产品最小整代结构。schema 1..4 可作为 migration backup；
## >4 单独分类，表/JSON/current identity invalidity 保持 logical failure。
func verify_database(path: String, require_single_current: bool = true) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _result(false, "missing", "database file is missing")
	var size := FileAccess.get_size(path)
	if size <= 0:
		return _result(false, "physical_corruption", "database file is empty", {"physical_failure": true})
	var connection := Connector.new()
	if not connection.open_database(path):
		var open_error: String = connection.last_error()
		return _classified_open_failure(open_error)
	var quick := connection.query_rows("PRAGMA quick_check;")
	if not quick.ok or quick.rows.size() != 1 or String((quick.rows[0] as Dictionary).values()[0]) != "ok":
		var quick_error := connection.last_error() if not quick.ok else str(quick.rows)
		connection.close_database()
		return _result(false, "physical_corruption", "quick_check failed: %s" % quick_error, {"physical_failure": true})
	var foreign := connection.query_rows("PRAGMA foreign_key_check;")
	if not foreign.ok:
		var foreign_error := connection.last_error()
		connection.close_database()
		return _classified_query_failure("foreign_key_check", foreign_error)
	if not foreign.rows.is_empty():
		connection.close_database()
		return _result(false, "logical_invalid", "foreign key violations were found")
	var schema := connection.query_rows("SELECT schema_version FROM persistence_schema WHERE singleton=1;")
	if not schema.ok:
		var schema_error := connection.last_error()
		connection.close_database()
		return _classified_query_failure("schema inspection", schema_error)
	if schema.rows.size() != 1:
		connection.close_database()
		return _result(false, "logical_invalid", "schema version source is invalid")
	var version := int((schema.rows[0] as Dictionary).schema_version)
	if version > CURRENT_SCHEMA_VERSION:
		connection.close_database()
		return _result(false, "unsupported_newer_schema", "database schema %d is newer than supported %d" % [version, CURRENT_SCHEMA_VERSION], {"schema_version": version})
	if version < 1:
		connection.close_database()
		return _result(false, "logical_invalid", "database schema version is unsupported")
	var schema_shape := _verify_schema_shape(connection, version)
	if not schema_shape.success:
		connection.close_database()
		return schema_shape
	var truth := _verify_current_truth(connection, version, require_single_current)
	connection.close_database()
	if not truth.success:
		return truth
	return _result(true, "healthy", "", {"schema_version": version, "file_size": size})


func refresh_backup() -> Dictionary:
	if not _writer_lock.is_owned():
		return _result(false, "not_owned", "writer ownership is required")
	var source_verification := verify_database(_database_path)
	if not source_verification.success:
		return _result(false, "source_not_healthy", String(source_verification.message))
	var directory_error := DirAccess.make_dir_recursive_absolute(_recovery_root)
	if directory_error != OK:
		return _result(false, "backup_staging_failure", "cannot create recovery directory")
	var staging := _backup_path("backup-staging.sqlite")
	_remove_sqlite_family(staging)
	var source := Connector.new()
	if not source.open_database(_database_path):
		return _result(false, "backup_staging_failure", source.last_error())
	var backed_up := source.backup_to(staging)
	var backup_error := source.last_error()
	source.close_database()
	if not backed_up:
		return _result(false, "backup_staging_failure", backup_error)
	var verified := verify_database(staging)
	if not verified.success:
		return _result(false, "backup_verification_failure", String(verified.message))
	_invoke_test_crash_hook("backup_staging_verified")
	return _publish_verified_staging(staging)


## 用选中的 whole-DB backup 构造并验证 replacement staging；随后保留 corrupt original，
## 最后发布 current。任何失败都不删除 verified backup 或 quarantine evidence。
func recover_current_from_backup() -> Dictionary:
	if not _writer_lock.is_owned():
		return _result(false, "not_owned", "writer ownership is required")
	var selected := _select_verified_backup()
	if not selected.success:
		return _result(false, "no_verified_backup", "no verified recovery backup is available")
	var replacement := _backup_path("replacement-staging.sqlite")
	_remove_sqlite_family(replacement)
	DirAccess.make_dir_recursive_absolute(_recovery_root)
	var staging := Connector.new()
	if not staging.open_database(replacement):
		return _result(false, "recovery_staging_failure", staging.last_error())
	var restored := staging.restore_from(String(selected.path))
	var restore_error := staging.last_error()
	staging.close_database()
	if not restored:
		return _result(false, "recovery_staging_failure", restore_error)
	var verified := verify_database(replacement)
	if not verified.success:
		return _result(false, "recovery_verification_failure", String(verified.message))
	var quarantine_root := _recovery_root.path_join("quarantine").path_join("corrupt-%s-%s" % [Time.get_datetime_string_from_system(true, true).replace(":", "-"), Crypto.new().generate_random_bytes(4).hex_encode()])
	var quarantine_error := DirAccess.make_dir_recursive_absolute(quarantine_root)
	if quarantine_error != OK:
		return _result(false, "quarantine_failure", "cannot create quarantine directory")
	for suffix: String in ["", "-wal", "-shm"]:
		var current_artifact := _database_path + suffix
		if FileAccess.file_exists(current_artifact):
			var move_error := DirAccess.rename_absolute(current_artifact, quarantine_root.path_join(_database_path.get_file() + suffix))
			if move_error != OK:
				return _result(false, "quarantine_failure", "cannot preserve corrupt current artifact")
	_invoke_test_crash_hook("current_quarantined")
	var publish_error := DirAccess.rename_absolute(replacement, _database_path)
	if publish_error != OK:
		return _result(false, "recovery_publication_failure", "verified replacement could not be published", {"quarantine_path": quarantine_root})
	_invoke_test_crash_hook("replacement_published")
	return _result(true, "reopen_required", "", {"backup_path": selected.path, "quarantine_path": quarantine_root})


func backup_availability() -> Dictionary:
	return _select_verified_backup()


func _publish_verified_staging(staging: String) -> Dictionary:
	var latest := _backup_path("latest.sqlite")
	var previous := _backup_path("previous.sqlite")
	var latest_verification := verify_database(latest) if FileAccess.file_exists(latest) else _result(false, "missing", "")
	var previous_verification := verify_database(previous) if FileAccess.file_exists(previous) else _result(false, "missing", "")
	if latest_verification.success:
		if FileAccess.file_exists(previous):
			var remove_previous := DirAccess.remove_absolute(previous)
			if remove_previous != OK:
				return _result(false, "backup_publication_failure", "cannot retire previous backup")
		var rotate_error := DirAccess.rename_absolute(latest, previous)
		if rotate_error != OK:
			return _result(false, "backup_publication_failure", "cannot rotate latest backup")
		_invoke_test_crash_hook("latest_rotated")
	elif FileAccess.file_exists(latest):
		# invalid latest is never allowed to displace a verified previous.
		if not previous_verification.success and FileAccess.file_exists(previous):
			var remove_invalid_previous := DirAccess.remove_absolute(previous)
			if remove_invalid_previous != OK:
				return _result(false, "backup_publication_failure", "cannot retire invalid previous backup")
		var remove_latest := DirAccess.remove_absolute(latest)
		if remove_latest != OK:
			return _result(false, "backup_publication_failure", "cannot retire invalid latest backup")
	var publish_error := DirAccess.rename_absolute(staging, latest)
	if publish_error != OK:
		return _result(false, "backup_publication_failure", "cannot publish verified latest backup")
	return _result(true, "backup_refreshed", "", {"path": latest})


func _select_verified_backup() -> Dictionary:
	for slot: String in ["latest.sqlite", "previous.sqlite", "backup-staging.sqlite"]:
		var path := _backup_path(slot)
		if FileAccess.file_exists(path):
			var verified := verify_database(path)
			if verified.success:
				return _result(true, "backup_available", "", {"path": path, "slot": slot, "modified_time": FileAccess.get_modified_time(path)})
	return _result(false, "no_verified_backup", "no verified backup is available")


func _verify_current_truth(connection: RefCounted, schema_version: int, require_single_current: bool) -> Dictionary:
	var games: Dictionary = connection.query_rows("SELECT game_id, active_head_id FROM games ORDER BY game_id;")
	if not games.ok:
		return _classified_query_failure("Game identity inspection", connection.last_error())
	if games.rows.size() > 1:
		return _result(false, "logical_invalid", "multiple current Game identities were found") if require_single_current else _result(true, "truth_readable", "")
	if games.rows.is_empty():
		return _result(true, "healthy_empty", "")
	var game_id := String((games.rows[0] as Dictionary).game_id)
	var head_id := String((games.rows[0] as Dictionary).active_head_id)
	var world: Dictionary = connection.query_rows("SELECT head_id, materialization_json FROM world_materializations WHERE game_id=?;", [game_id])
	if not world.ok:
		return _classified_query_failure("World inspection", connection.last_error())
	if world.rows.size() != 1 or String((world.rows[0] as Dictionary).head_id) != head_id or typeof(JSON.parse_string(String((world.rows[0] as Dictionary).materialization_json))) != TYPE_DICTIONARY:
		return _result(false, "logical_invalid", "current World materialization is invalid")
	if schema_version >= 2:
		var conversation: Dictionary = connection.query_rows("SELECT accepted_turns_json FROM conversation_materializations WHERE game_id=?;", [game_id])
		if not conversation.ok:
			return _classified_query_failure("Conversation inspection", connection.last_error())
		if conversation.rows.size() != 1 or typeof(JSON.parse_string(String((conversation.rows[0] as Dictionary).accepted_turns_json))) != TYPE_ARRAY:
			return _result(false, "logical_invalid", "current Conversation materialization is invalid")
	var json_sources := [["timeline_nodes", "world_snapshot_json", TYPE_DICTIONARY]]
	if schema_version >= 3:
		json_sources.append(["save_points", "accepted_turns_json", TYPE_ARRAY])
	if schema_version >= 4:
		json_sources.append(["recovery_checkpoints", "accepted_turns_json", TYPE_ARRAY])
	for source: Array in json_sources:
		var documents: Dictionary = connection.query_rows("SELECT %s AS document_json FROM %s;" % [String(source[1]), String(source[0])])
		if not documents.ok:
			return _classified_query_failure("%s JSON inspection" % String(source[0]), connection.last_error())
		for row_value: Variant in documents.rows:
			if typeof(JSON.parse_string(String((row_value as Dictionary).document_json))) != int(source[2]):
				return _result(false, "logical_invalid", "%s contains invalid recovery JSON" % String(source[0]))
	return _result(true, "truth_valid", "")


func _verify_schema_shape(connection: RefCounted, schema_version: int) -> Dictionary:
	var required := ["persistence_schema", "games", "timeline_nodes", "world_materializations"]
	if schema_version >= 2: required.append("conversation_materializations")
	if schema_version >= 3: required.append("save_points")
	if schema_version >= 4: required.append("recovery_checkpoints")
	for table: String in required:
		var table_query: Dictionary = connection.query_rows("SELECT 1 AS present FROM sqlite_master WHERE type='table' AND name=?;", [table])
		if not table_query.ok:
			return _classified_query_failure("schema shape inspection", connection.last_error())
		if table_query.rows.size() != 1:
			return _result(false, "logical_invalid", "required table is missing: %s" % table)
	return _result(true, "schema_valid", "")


func _classified_open_failure(error: String) -> Dictionary:
	return _result(false, "physical_corruption" if _is_physical_error(error) else "storage_failure", error, {"physical_failure": _is_physical_error(error)})


func _classified_query_failure(step: String, error: String) -> Dictionary:
	return _result(false, "physical_corruption" if _is_physical_error(error) else "logical_invalid", "%s: %s" % [step, error], {"physical_failure": _is_physical_error(error)})


func _is_physical_error(error: String) -> bool:
	var normalized := error.to_lower()
	return normalized.contains("not a database") or normalized.contains("malformed") or normalized.contains("disk image is malformed") or normalized.contains("database disk image")


func _has_recovery_artifacts() -> bool:
	if DirAccess.dir_exists_absolute(_recovery_root):
		var directory := DirAccess.open(_recovery_root)
		if directory != null:
			directory.list_dir_begin()
			var entry := directory.get_next()
			while not entry.is_empty():
				if entry != "." and entry != "..":
					return true
				entry = directory.get_next()
	for suffix: String in ["-wal", "-shm"]:
		if FileAccess.file_exists(_database_path + suffix):
			return true
	return false


func _backup_path(file_name: String) -> String:
	return _recovery_root.path_join(file_name)


func _remove_sqlite_family(path: String) -> void:
	for suffix: String in ["", "-wal", "-shm"]:
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(path + suffix)


## 仅供 task-owned exact-PID harness 安装同步 crash marker；不经 L3 暴露给产品。
func set_test_crash_hook(hook: Callable) -> void:
	_test_crash_hook = hook


func _invoke_test_crash_hook(point: String) -> void:
	if _test_crash_hook.is_valid():
		_test_crash_hook.call(point)


func _result(success: bool, status: String, message: String, details: Dictionary = {}) -> Dictionary:
	var result := {"success": success, "status": status, "message": message}
	result.merge(details, true)
	return result
