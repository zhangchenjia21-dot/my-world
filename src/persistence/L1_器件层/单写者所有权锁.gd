extends RefCounted

## dedicated SQLite coordination connection 上的进程生命周期写锁。
## correctness 来自 SQLite/Windows 文件锁：normal close rollback，process crash 由 OS
## 自动释放。数据库文件可以残留，但 PID、时间戳和 stale artifact 均不参与 authority。

var _database: Object = null
var _last_error := ""


func acquire(coordination_path: String) -> Dictionary:
	if _database != null:
		return {"success": false, "status": "lock_internal_error", "message": "writer ownership is already acquired by this guard"}
	var parent_error := DirAccess.make_dir_recursive_absolute(coordination_path.get_base_dir())
	if parent_error != OK:
		return {"success": false, "status": "storage_failure", "message": "cannot create writer coordination directory"}
	var database := SQLite.new()
	database.path = coordination_path
	database.default_extension = ""
	database.verbosity_level = SQLite.QUIET
	if not database.open_db():
		return {"success": false, "status": "storage_failure", "message": String(database.error_message)}
	if not database.query("PRAGMA busy_timeout=0;") or not database.query("CREATE TABLE IF NOT EXISTS writer_ownership(singleton INTEGER PRIMARY KEY CHECK(singleton=1));"):
		_last_error = String(database.error_message)
		database.close_db()
		return {"success": false, "status": "lock_internal_error", "message": _last_error}
	if not database.query("BEGIN IMMEDIATE;"):
		_last_error = String(database.error_message)
		database.close_db()
		var normalized := _last_error.to_lower()
		if normalized.contains("locked") or normalized.contains("busy"):
			return {"success": false, "status": "already_running", "message": _last_error}
		return {"success": false, "status": "lock_internal_error", "message": _last_error}
	_database = database
	_last_error = ""
	return {"success": true, "status": "owned", "message": ""}


func release() -> Dictionary:
	if _database == null:
		return {"success": true, "status": "released", "message": ""}
	var rolled_back: bool = _database.query("ROLLBACK;")
	var rollback_error := "" if rolled_back else String(_database.error_message)
	var closed: bool = _database.close_db()
	var close_error := "" if closed else String(_database.error_message)
	_database = null
	if not rolled_back or not closed:
		_last_error = rollback_error if not rollback_error.is_empty() else close_error
		return {"success": false, "status": "storage_failure", "message": _last_error}
	return {"success": true, "status": "released", "message": ""}


func is_owned() -> bool:
	return _database != null
