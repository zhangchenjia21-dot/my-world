extends SceneTree

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Persistence := preload("res://src/persistence/L3_外交层/世界持久化公开接口.gd")

var _root := ""


func _initialize() -> void:
	_root = _argument("--root=")
	if _root.is_empty() or _root.find("g3_06") < 0:
		_fail("task-owned --root containing g3_06 is required")
		return
	DirAccess.make_dir_recursive_absolute(_root)
	if not _test_initial_and_save_backup(): return
	if not _test_corrupt_latest_recovery(): return
	if not _test_previous_fallback(): return
	if not _test_no_backup_and_classification(): return
	if not _test_migration_backup_gate(): return
	print("G3-06 PASS | backup lifecycle, classification, staged recovery, previous fallback, migration gate")
	quit(0)


func _test_initial_and_save_backup() -> bool:
	var path := _path("initial-save.sqlite")
	var runtime := Runtime.new()
	var opened: Dictionary = runtime.open_current_game(path)
	if not opened.success: return _fail("first run failed: %s" % opened)
	var latest := _latest(path)
	if _schema(latest) != 4: return _fail("initial verified backup missing")
	var saved: Dictionary = runtime.create_save_point("重要进度")
	if not saved.success or bool(saved.get("backup_warning", true)): return _fail("Save backup refresh failed: %s" % saved)
	if _count(latest, "save_points") != 1: return _fail("latest backup does not contain committed Save")
	runtime.close()
	print("G3-06 PASS | first READY backup + Save-triggered online refresh")
	return true


func _test_corrupt_latest_recovery() -> bool:
	var path := _path("corrupt-latest.sqlite")
	var runtime := Runtime.new()
	if not runtime.open_current_game(path).success: return _fail("corruption seed open")
	var game_id: String = runtime.game_id
	var head_id: String = runtime.active_head_id
	if not runtime.create_save_point("可恢复存档").success: return _fail("corruption seed Save")
	runtime.close()
	_corrupt(path)
	var damaged := Runtime.new()
	var classified: Dictionary = damaged.open_current_game(path)
	if classified.status != "physical_corruption" or not bool(classified.recovery_available):
		return _fail("corrupt current classification/backup availability: %s" % classified)
	var recovered: Dictionary = damaged.recover_damaged_database()
	if recovered.status != "reopen_required" or not DirAccess.dir_exists_absolute(String(recovered.quarantine_path)):
		return _fail("staged recovery/quarantine failed: %s" % recovered)
	var reopened := Runtime.new()
	var resumed: Dictionary = reopened.open_current_game(path)
	if not resumed.success or reopened.game_id != game_id or reopened.active_head_id != head_id or reopened.list_save_points().save_points.size() != 1:
		return _fail("recovered whole generation mismatch")
	reopened.close()
	print("G3-06 PASS | corrupt current -> latest -> quarantine + staged publish + exact reopen")
	return true


func _test_previous_fallback() -> bool:
	var path := _path("previous-fallback.sqlite")
	var runtime := Runtime.new()
	if not runtime.open_current_game(path).success: return _fail("fallback seed open")
	if not runtime.create_save_point("第一代").success: return _fail("fallback Save 1")
	if not runtime.create_save_point("第二代").success: return _fail("fallback Save 2")
	# 保持 Save 2 在 latest、Save 1 在 previous；只关闭 gameplay connection 并释放 test-owned lock，
	# 避免 graceful-close refresh 再生成同内容 backup 干扰 generation 证明。
	runtime.persistence.close_database()
	runtime.database_safety.release_writer()
	runtime.persistence = null
	_corrupt(path)
	_corrupt(_latest(path))
	var damaged := Runtime.new()
	var classified: Dictionary = damaged.open_current_game(path)
	if classified.status != "physical_corruption" or not bool(classified.recovery_available): return _fail("previous was not selected")
	if damaged.recover_damaged_database().status != "reopen_required": return _fail("previous recovery failed")
	var reopened := Runtime.new()
	if not reopened.open_current_game(path).success or reopened.list_save_points().save_points.size() != 1:
		return _fail("fallback mixed generations or did not select previous")
	reopened.close()
	print("G3-06 PASS | invalid latest falls back to exact verified previous generation")
	return true


func _test_no_backup_and_classification() -> bool:
	var no_backup := _path("no-backup.sqlite")
	if not _seed_v4_without_safety(no_backup): return false
	_corrupt(no_backup)
	var damaged := Runtime.new()
	var result: Dictionary = damaged.open_current_game(no_backup)
	if result.status != "physical_corruption" or bool(result.recovery_available) or damaged.recover_damaged_database().status != "no_verified_backup":
		return _fail("corrupt current without backup did not block")
	damaged.close()
	if _count(no_backup, "games") != -1: return _fail("corrupt current was replaced with blank Game")

	var unsupported := _path("unsupported.sqlite")
	var db := _open(unsupported)
	if db == null or not db.query("CREATE TABLE persistence_schema(singleton INTEGER PRIMARY KEY, schema_version INTEGER NOT NULL); INSERT INTO persistence_schema VALUES(1,99);"):
		return _fail("unsupported fixture")
	db.close_db()
	var newer := Runtime.new()
	if newer.open_current_game(unsupported).status != "unsupported_newer_schema": return _fail("newer schema was treated as corruption")

	var logical := _path("logical-invalid.sqlite")
	if not _seed_v4_without_safety(logical): return false
	db = _open(logical)
	if db == null or not db.query("UPDATE world_materializations SET materialization_json='[]';"):
		return _fail("logical invalid fixture")
	db.close_db()
	var invalid := Runtime.new()
	if invalid.open_current_game(logical).status != "logical_invalid": return _fail("logical failure was treated as physical recovery")
	print("G3-06 PASS | no-backup blocks blank Game; newer/logical failures stay separate")
	return true


func _test_migration_backup_gate() -> bool:
	var success_path := _path("migration-success.sqlite")
	if not _seed_v3(success_path, false): return false
	var success_runtime := Runtime.new()
	if not success_runtime.open_current_game(success_path).success: return _fail("v3 migration success open")
	if _schema(success_path) != 4 or _schema(_latest(success_path)) != 3:
		return _fail("pre-migration backup did not preserve v3 before v4")
	success_runtime.close()

	var backup_failure_path := _path("migration-backup-failure.sqlite")
	if not _seed_v3(backup_failure_path, true): return false
	var blocked_root := "%s.recovery" % backup_failure_path.get_basename()
	var blocker := FileAccess.open(blocked_root, FileAccess.WRITE)
	blocker.store_string("blocks recovery directory creation")
	blocker.close()
	var blocked := Runtime.new()
	if blocked.open_current_game(backup_failure_path).status != "migration_backup_failed" or _schema(backup_failure_path) != 3:
		return _fail("backup failure allowed migration")

	var migration_failure_path := _path("migration-intentional-failure.sqlite")
	if not _seed_v3(migration_failure_path, true): return false
	var failed := Runtime.new()
	var failed_result: Dictionary = failed.open_current_game(migration_failure_path)
	if failed_result.success or _schema(migration_failure_path) != 3 or _schema(_latest(migration_failure_path)) != 3:
		return _fail("migration failure did not preserve v3 + verified prebackup: %s" % failed_result)
	print("G3-06 PASS | v3->v4 prebackup gate success/failure and rollback preservation")
	return true


func _seed_v4_without_safety(path: String) -> bool:
	var api := Persistence.new()
	var opened: Dictionary = api.open_database(path)
	if not opened.success: return _fail("seed v4 open: %s" % opened)
	var created: Dictionary = api.create_initial_game("game-%s" % path.get_file(), "root", {}, "2026-08-28T00:00:00Z")
	api.close_database()
	return true if created.success else _fail("seed v4 create: %s" % created)


func _seed_v3(path: String, fail_migration: bool) -> bool:
	if not _seed_v4_without_safety(path): return false
	var db := _open(path)
	if db == null: return false
	var sql := "DROP INDEX recovery_checkpoints_latest_idx; DROP TABLE recovery_checkpoints; UPDATE persistence_schema SET schema_version=3;"
	if fail_migration:
		sql += " CREATE TRIGGER abort_v4 BEFORE UPDATE OF schema_version ON persistence_schema WHEN NEW.schema_version=4 BEGIN SELECT RAISE(ABORT,'intentional G3-06 migration failure'); END;"
	var ok: bool = db.query(sql)
	var error: String = db.error_message
	db.close_db()
	return true if ok else _fail("seed v3: %s" % error)


func _schema(path: String) -> int:
	var db := _open(path)
	if db == null: return -1
	if not db.query("SELECT schema_version FROM persistence_schema WHERE singleton=1;"):
		db.close_db(); return -1
	var version := int(db.query_result[0].schema_version)
	db.close_db()
	return version


func _count(path: String, table: String) -> int:
	var db := _open(path)
	if db == null: return -1
	if not db.query("SELECT COUNT(*) AS count FROM %s;" % table):
		db.close_db(); return -1
	var count := int(db.query_result[0].count)
	db.close_db()
	return count


func _open(path: String) -> Object:
	var db := SQLite.new(); db.path = path; db.default_extension = ""; db.verbosity_level = SQLite.QUIET
	if not db.open_db(): return null
	return db


func _corrupt(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("intentional G3-06 physical corruption")
	file.close()


func _latest(path: String) -> String:
	return "%s.recovery/latest.sqlite" % path.get_basename()


func _path(file_name: String) -> String:
	return _root.path_join(file_name)


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix): return value.trim_prefix(prefix)
	return ""


func _fail(message: String) -> bool:
	push_error("G3-06 FAIL | %s" % message)
	quit(1)
	return false
