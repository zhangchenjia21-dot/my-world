extends RefCounted

## godot-sqlite v4.9 的最小 production connection mechanism。
##
## 统一 foreign keys、WAL、FULL synchronous、parameter binding 与 error visibility；不包含
## Game/World/Timeline 流程语义，不扫描 user://，也不选择“最近数据库”。

var _database: Object = null
var _last_error := ""


func open_database(database_path: String) -> bool:
	if _database != null:
		_last_error = "database connection is already open"
		return false
	var database := SQLite.new()
	database.path = database_path
	database.default_extension = ""
	database.verbosity_level = SQLite.QUIET
	database.foreign_keys = true
	if not database.open_db():
		_last_error = database.error_message
		return false
	_database = database
	if not execute("PRAGMA journal_mode=WAL;") or not execute("PRAGMA synchronous=FULL;"):
		close_database()
		return false
	_last_error = ""
	return true


func close_database() -> bool:
	if _database == null:
		return true
	var succeeded: bool = _database.close_db()
	if not succeeded:
		_last_error = _database.error_message
	_database = null
	return succeeded


func is_open() -> bool:
	return _database != null


func execute(sql: String, bindings: Array = []) -> bool:
	if _database == null:
		_last_error = "database connection is not open"
		return false
	var succeeded: bool
	if bindings.is_empty():
		succeeded = _database.query(sql)
	else:
		succeeded = _database.query_with_bindings(sql, bindings)
	_last_error = "" if succeeded else String(_database.error_message)
	return succeeded


func query_rows(sql: String, bindings: Array = []) -> Array:
	if not execute(sql, bindings):
		return []
	return (_database.query_result as Array).duplicate(true)


func begin_immediate() -> bool:
	return execute("BEGIN IMMEDIATE;")


func commit() -> bool:
	return execute("COMMIT;")


func rollback() -> bool:
	return execute("ROLLBACK;")


func changed_rows() -> int:
	var rows := query_rows("SELECT changes() AS changed_rows;")
	if rows.is_empty():
		return -1
	return int((rows[0] as Dictionary).get("changed_rows", -1))


func last_error() -> String:
	return _last_error
