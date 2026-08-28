extends SceneTree

## 只在调用者显式提供的 task-owned 目录验证 vendored godot-sqlite v4.9 合同。
## 该 spike 故意保持 WAL source connection 打开，以排除普通文件复制形成的假阳性。


func _initialize() -> void:
	var root := _argument("--root=")
	if root.is_empty() or root.find("g3_06") < 0:
		_fail("task-owned --root containing g3_06 is required")
		return
	DirAccess.make_dir_recursive_absolute(root)
	var source_path := root.path_join("online-source.sqlite")
	var backup_path := root.path_join("online-backup.sqlite")
	var restored_path := root.path_join("restored.sqlite")
	for path: String in [source_path, backup_path, restored_path]:
		_remove_sqlite_family(path)

	var source := _open(source_path)
	if source == null:
		return
	if not source.query("PRAGMA journal_mode=WAL;") or not source.query("PRAGMA synchronous=FULL;"):
		_fail("failed to configure WAL source: %s" % source.error_message)
		return
	if not source.query("CREATE TABLE proof(id INTEGER PRIMARY KEY, marker TEXT NOT NULL);"):
		_fail("failed to create source: %s" % source.error_message)
		return
	if not source.query_with_bindings("INSERT INTO proof(id, marker) VALUES (?, ?);", [1, "g3-06-online-backup"]):
		_fail("failed to seed source: %s" % source.error_message)
		return

	var backup_result: Variant = source.backup_to(backup_path)
	print("G3-06 SPIKE | backup_to result=%s type=%d" % [str(backup_result), typeof(backup_result)])
	if not _operation_succeeded(backup_result):
		_fail("backup_to failed: %s" % source.error_message)
		return

	var backup := _open(backup_path)
	if backup == null or not _verify_truth(backup, "g3-06-online-backup"):
		return
	backup.close_db()

	var restored := _open(restored_path)
	if restored == null:
		return
	var restore_result: Variant = restored.restore_from(backup_path)
	print("G3-06 SPIKE | restore_from result=%s type=%d" % [str(restore_result), typeof(restore_result)])
	if not _operation_succeeded(restore_result):
		_fail("restore_from failed: %s" % restored.error_message)
		return
	if not _verify_truth(restored, "g3-06-online-backup"):
		return
	restored.close_db()
	source.close_db()
	print("G3-06 SPIKE PASS | online WAL backup and staged restore preserved exact committed truth")
	quit(0)


func _open(path: String) -> Object:
	var database := SQLite.new()
	database.path = path
	database.default_extension = ""
	database.verbosity_level = SQLite.QUIET
	if not database.open_db():
		_fail("open failed for %s: %s" % [path, database.error_message])
		return null
	return database


func _verify_truth(database: Object, expected: String) -> bool:
	if not database.query("PRAGMA quick_check;"):
		_fail("quick_check query failed: %s" % database.error_message)
		return false
	var checks: Array = database.query_result
	if checks.size() != 1 or String((checks[0] as Dictionary).values()[0]) != "ok":
		_fail("quick_check was not ok: %s" % str(checks))
		return false
	if not database.query("SELECT marker FROM proof WHERE id = 1;"):
		_fail("truth query failed: %s" % database.error_message)
		return false
	var rows: Array = database.query_result
	if rows.size() != 1 or String((rows[0] as Dictionary).marker) != expected:
		_fail("restored truth mismatch: %s" % str(rows))
		return false
	return true


func _operation_succeeded(result: Variant) -> bool:
	# v4.9 当前二进制可能把 C++ bool 暴露为 bool；保留 int==OK 仅用于记录实际 ABI。
	return (typeof(result) == TYPE_BOOL and bool(result)) or (typeof(result) == TYPE_INT and int(result) == OK)


func _remove_sqlite_family(path: String) -> void:
	for candidate: String in [path, path + "-wal", path + "-shm"]:
		if FileAccess.file_exists(candidate):
			DirAccess.remove_absolute(candidate)


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


func _fail(message: String) -> void:
	push_error("G3-06 SPIKE FAIL | %s" % message)
	quit(1)
