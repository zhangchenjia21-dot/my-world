extends RefCounted

## G3-06 physical database safety public boundary。返回稳定状态 DTO，不暴露 SQLite
## connection/row，也不把 physical backup 伪装成 Save Point 或 Timeline truth。

const Flow := preload("res://src/persistence/L2_流程层/数据库灾难恢复流程.gd")

var _flow: RefCounted = Flow.new()


func acquire_writer(database_path: String) -> Dictionary:
	return _flow.acquire_writer(database_path)


func inspect_startup() -> Dictionary:
	return _flow.inspect_startup()


func refresh_backup() -> Dictionary:
	return _flow.refresh_backup()


func backup_availability() -> Dictionary:
	return _flow.backup_availability()


func recover_current_from_backup() -> Dictionary:
	return _flow.recover_current_from_backup()


func release_writer() -> Dictionary:
	return _flow.release_writer()
