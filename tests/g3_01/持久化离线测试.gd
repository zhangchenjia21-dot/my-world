extends SceneTree

const Fixture := preload("res://tests/g3_01/持久化夹具.gd")

var _root_path := ""


func _initialize() -> void:
	_root_path = _argument_value("--root=")
	if _root_path.is_empty():
		_fail("missing --root argument")
		return
	DirAccess.make_dir_recursive_absolute(_root_path)

	if not _test_basic_reopen_and_atomicity():
		return
	if not _test_transaction_rollback():
		return
	if not _test_timeline_save_and_future_recovery_references():
		return
	if not _test_migration_success_and_failure():
		return
	if not _test_missing_and_corrupt_paths():
		return
	if not _prepare_crash_fixture():
		return

	print("G3-01 PASS | offline persistence fixture suite")
	quit(0)


func _test_basic_reopen_and_atomicity() -> bool:
	var path := _db_path("basic.sqlite")
	var database := Fixture.open_database(path)
	if database == null or not Fixture.create_schema_v1(database) or not Fixture.seed_initial_game(database):
		return _fail("basic schema/seed")
	if not Fixture.commit_mutation(database, "g3-head-002", Fixture.INITIAL_HEAD_ID, "stable-2", 2):
		return _fail("atomic commit")
	database.close_db()

	var reopened := Fixture.open_database(path)
	if reopened == null:
		return _fail("basic reopen")
	var game_id: Variant = Fixture.scalar(reopened, "SELECT game_id FROM g3_fixture_games LIMIT 1;", [], "game_id")
	var head: Variant = Fixture.scalar(reopened, "SELECT active_head_id FROM g3_fixture_games WHERE game_id = ?;", [Fixture.GAME_ID], "active_head_id")
	var state: Variant = Fixture.scalar(reopened, "SELECT value FROM g3_fixture_state WHERE game_id = ? AND key = 'fixture_status';", [Fixture.GAME_ID], "value")
	var node_count: Variant = Fixture.scalar(reopened, "SELECT COUNT(*) AS count FROM g3_fixture_timeline_nodes WHERE game_id = ?;", [Fixture.GAME_ID], "count")
	reopened.close_db()
	if game_id != Fixture.GAME_ID or head != "g3-head-002" or state != "stable-2" or int(node_count) != 2:
		return _fail("reopen exact values / stable identity")
	print("G3-01 PASS | basic open/schema/commit/close/reopen + stable identity")
	return true


func _test_transaction_rollback() -> bool:
	var path := _db_path("rollback.sqlite")
	var database := Fixture.open_database(path)
	if database == null or not Fixture.create_schema_v1(database) or not Fixture.seed_initial_game(database):
		return _fail("rollback setup")
	if not Fixture.execute(database, "BEGIN IMMEDIATE;"):
		return _fail("rollback begin")
	if not Fixture.execute(database, "UPDATE g3_fixture_state SET value = 'must-not-survive' WHERE game_id = ? AND key = 'fixture_status';", [Fixture.GAME_ID]):
		return _fail("rollback state write")
	if not Fixture.execute(database, "INSERT INTO g3_fixture_timeline_nodes(node_id, game_id, parent_node_id, sequence, kind, created_at) VALUES ('g3-head-rollback', ?, ?, 2, 'mutation', '2026-08-26T00:00:02Z');", [Fixture.GAME_ID, Fixture.INITIAL_HEAD_ID]):
		return _fail("rollback node write")
	if not Fixture.execute(database, "UPDATE g3_fixture_games SET active_head_id = 'g3-head-rollback' WHERE game_id = ?;", [Fixture.GAME_ID]):
		return _fail("rollback head write")
	if not Fixture.execute(database, "ROLLBACK;"):
		return _fail("explicit rollback")
	database.close_db()

	var reopened := Fixture.open_database(path)
	if reopened == null:
		return _fail("rollback reopen")
	var state: Variant = Fixture.scalar(reopened, "SELECT value FROM g3_fixture_state WHERE game_id = ? AND key = 'fixture_status';", [Fixture.GAME_ID], "value")
	var head: Variant = Fixture.scalar(reopened, "SELECT active_head_id FROM g3_fixture_games WHERE game_id = ?;", [Fixture.GAME_ID], "active_head_id")
	var rolled_back_nodes: Variant = Fixture.scalar(reopened, "SELECT COUNT(*) AS count FROM g3_fixture_timeline_nodes WHERE node_id = 'g3-head-rollback';", [], "count")
	reopened.close_db()
	if state != "stable-1" or head != Fixture.INITIAL_HEAD_ID or int(rolled_back_nodes) != 0:
		return _fail("rollback left half-new state")
	print("G3-01 PASS | explicit rollback leaves no world/head/node partial write")
	return true


func _test_timeline_save_and_future_recovery_references() -> bool:
	var path := _db_path("timeline.sqlite")
	var database := Fixture.open_database(path)
	if database == null or not Fixture.create_schema_v1(database) or not Fixture.seed_initial_game(database):
		return _fail("timeline setup")
	if not Fixture.commit_mutation(database, "g3-head-old-future", Fixture.INITIAL_HEAD_ID, "old-future", 2):
		return _fail("old future commit")
	# 这是 relationship fixture，不是 G3-04 product Restore：切回旧 Save 前先给当前 future
	# 建立 durable recovery reference，再从旧 head 产生新的 child。
	if not Fixture.execute(database, "BEGIN IMMEDIATE;"):
		return _fail("restore relationship begin")
	var relationship_writes := [
		["INSERT INTO g3_fixture_recovery_refs(recovery_id, game_id, timeline_node_id, kind) VALUES ('g3-pre-restore-future', ?, 'g3-head-old-future', 'pre_restore_head');", [Fixture.GAME_ID]],
		["UPDATE g3_fixture_state SET value = 'stable-1' WHERE game_id = ? AND key = 'fixture_status';", [Fixture.GAME_ID]],
		["UPDATE g3_fixture_games SET active_head_id = ? WHERE game_id = ?;", [Fixture.INITIAL_HEAD_ID, Fixture.GAME_ID]],
	]
	for write: Array in relationship_writes:
		if not Fixture.execute(database, write[0], write[1]):
			database.query("ROLLBACK;")
			return _fail("restore relationship write")
	if not Fixture.execute(database, "COMMIT;"):
		return _fail("restore relationship commit")
	if not Fixture.commit_mutation(database, "g3-head-new-future", Fixture.INITIAL_HEAD_ID, "new-future", 3):
		return _fail("new future commit")
	var save_target: Variant = Fixture.scalar(database, "SELECT timeline_node_id FROM g3_fixture_save_points WHERE save_id = 'g3-save-001';", [], "timeline_node_id")
	var recovery_target: Variant = Fixture.scalar(database, "SELECT timeline_node_id FROM g3_fixture_recovery_refs WHERE recovery_id = 'g3-pre-restore-future';", [], "timeline_node_id")
	var old_future_count: Variant = Fixture.scalar(database, "SELECT COUNT(*) AS count FROM g3_fixture_timeline_nodes WHERE node_id = 'g3-head-old-future';", [], "count")
	var new_parent: Variant = Fixture.scalar(database, "SELECT parent_node_id FROM g3_fixture_timeline_nodes WHERE node_id = 'g3-head-new-future';", [], "parent_node_id")
	database.close_db()
	if save_target != Fixture.INITIAL_HEAD_ID or recovery_target != "g3-head-old-future" or int(old_future_count) != 1 or new_parent != Fixture.INITIAL_HEAD_ID:
		return _fail("timeline/save/recovery reference semantics")
	print("G3-01 PASS | Save references Node; old future retained; new future branches from restored head")
	return true


func _test_migration_success_and_failure() -> bool:
	var success_path := _db_path("migration-success.sqlite")
	var success_db := Fixture.open_database(success_path)
	if success_db == null or not Fixture.create_schema_v1(success_db) or not Fixture.seed_initial_game(success_db):
		return _fail("migration success setup")
	if not Fixture.execute(success_db, "BEGIN IMMEDIATE;"):
		return _fail("migration success begin")
	if not Fixture.execute(success_db, "ALTER TABLE g3_fixture_timeline_nodes ADD COLUMN reason TEXT NOT NULL DEFAULT '';"):
		return _fail("migration success alter")
	if not Fixture.execute(success_db, "UPDATE g3_fixture_meta SET schema_version = 2 WHERE singleton = 1;"):
		return _fail("migration success version")
	if not Fixture.execute(success_db, "COMMIT;"):
		return _fail("migration success commit")
	success_db.close_db()
	var success_reopen := Fixture.open_database(success_path)
	var migrated_version: Variant = Fixture.scalar(success_reopen, "SELECT schema_version FROM g3_fixture_meta WHERE singleton = 1;", [], "schema_version")
	var reason_columns := _column_count(success_reopen, "reason")
	success_reopen.close_db()
	if int(migrated_version) != 2 or reason_columns != 1:
		return _fail("migration success reopen")

	var failure_path := _db_path("migration-failure.sqlite")
	var failure_db := Fixture.open_database(failure_path)
	if failure_db == null or not Fixture.create_schema_v1(failure_db) or not Fixture.seed_initial_game(failure_db):
		return _fail("migration failure setup")
	if not Fixture.execute(failure_db, "BEGIN IMMEDIATE;"):
		return _fail("migration failure begin")
	if not Fixture.execute(failure_db, "ALTER TABLE g3_fixture_timeline_nodes ADD COLUMN failed_probe TEXT;"):
		return _fail("migration failure first step")
	var intentional_failure: bool = failure_db.query("INSERT INTO g3_fixture_table_that_does_not_exist(value) VALUES ('fail');")
	if intentional_failure:
		return _fail("intentional migration error unexpectedly succeeded")
	var captured_error: String = failure_db.error_message
	if not failure_db.query("ROLLBACK;"):
		return _fail("migration failure rollback")
	failure_db.close_db()
	var failure_reopen := Fixture.open_database(failure_path)
	var original_version: Variant = Fixture.scalar(failure_reopen, "SELECT schema_version FROM g3_fixture_meta WHERE singleton = 1;", [], "schema_version")
	var failed_columns := _column_count(failure_reopen, "failed_probe")
	var old_state: Variant = Fixture.scalar(failure_reopen, "SELECT value FROM g3_fixture_state WHERE game_id = ? AND key = 'fixture_status';", [Fixture.GAME_ID], "value")
	failure_reopen.close_db()
	if captured_error.is_empty() or int(original_version) != 1 or failed_columns != 0 or old_state != "stable-1":
		return _fail("failed migration did not preserve old usable schema/state")
	print("G3-01 PASS | migration N->N+1 commit + intentional failure transactional rollback")
	return true


func _test_missing_and_corrupt_paths() -> bool:
	var missing_path := _db_path("missing-created.sqlite")
	if FileAccess.file_exists(missing_path):
		return _fail("test-owned missing path unexpectedly exists")
	var created := Fixture.open_database(missing_path)
	if created == null or not Fixture.create_schema_v1(created):
		return _fail("explicit missing-path create")
	created.close_db()
	if not FileAccess.file_exists(missing_path):
		return _fail("explicit create did not create database")

	var corrupt_path := _db_path("corrupt.sqlite")
	var corrupt_file := FileAccess.open(corrupt_path, FileAccess.WRITE)
	if corrupt_file == null:
		return _fail("create isolated corrupt fixture")
	corrupt_file.store_string("G3-01 intentional corrupt fixture; not a SQLite database")
	corrupt_file.close()
	var corrupt_db := Fixture.open_database(corrupt_path)
	if corrupt_db != null:
		corrupt_db.close_db()
		return _fail("corrupt database silently opened as usable")
	print("G3-01 PASS | explicit missing create + corrupt fail-loud (no empty fallback)")
	return true


func _prepare_crash_fixture() -> bool:
	var path := _db_path("crash.sqlite")
	var database := Fixture.open_database(path)
	if database == null or not Fixture.create_schema_v1(database) or not Fixture.seed_initial_game(database):
		return _fail("crash fixture setup")
	database.close_db()
	print("G3-01 PASS | crash fixture prepared at last committed head")
	return true


func _column_count(database: Object, column_name: String) -> int:
	if not Fixture.execute(database, "PRAGMA table_info(g3_fixture_timeline_nodes);"):
		return -1
	var count := 0
	for row_value: Variant in database.query_result:
		var row := row_value as Dictionary
		if String(row.get("name", "")) == column_name:
			count += 1
	return count


func _db_path(file_name: String) -> String:
	return _root_path.path_join(file_name)


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


func _fail(message: String) -> bool:
	push_error("G3-01 FAIL | %s" % message)
	quit(1)
	return false
