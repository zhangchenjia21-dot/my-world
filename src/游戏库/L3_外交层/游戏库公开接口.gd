class_name GameLibraryPublicInterface
extends RefCounted

const Rules := preload("res://src/游戏库/L0_公理层/游戏库规则.gd")
const Process := preload("res://src/游戏库/L2_流程层/游戏库流程.gd")
const RecordProjection := preload("res://src/游戏库/L3_外交层/游戏库公开类型.gd")

const FAULT_BEFORE_RECORD_PUBLISH := "before_record_publish"
const FAULT_BEFORE_CURRENT_PUBLISH := "before_current_publish"

var _process: RefCounted


## Production 使用固定 Application metadata/per-Game roots；自动化必须显式注入 task-owned roots。
func _init(
	library_root: String = Rules.PRODUCTION_LIBRARY_ROOT,
	managed_games_root: String = Rules.PRODUCTION_GAMES_ROOT,
	legacy_database_path: String = "user://my-world/current-game.sqlite"
) -> void:
	_process = Process.new(library_root, managed_games_root, legacy_database_path)


## 仅登记 Application 已通过 Runtime 取得并核对 identity 的 existing managed Game；本接口不创建 SQLite。
func register_verified_managed_game(game_id: String, display_name: String, verified_database_game_id: String, task_fault: String = "") -> Dictionary:
	return _project_one(_process.register_verified_game(game_id, display_name, Rules.MANAGED, verified_database_game_id, task_fault))


## Legacy adoption 只记录原位 G3 path；不移动、复制或重写 legacy database/recovery artifacts。
func register_verified_legacy_game(game_id: String, display_name: String, verified_database_game_id: String, task_fault: String = "") -> Dictionary:
	return _project_one(_process.register_verified_game(game_id, display_name, Rules.LEGACY_G3, verified_database_game_id, task_fault))


## Inventory/restart query 只读取 metadata，不打开所有 gameplay DB。
func list_games() -> Dictionary:
	var result: Dictionary = _process.list_records()
	if not result.success:
		return result
	var records: Array[RefCounted] = []
	for record: Dictionary in result.records:
		records.append(RecordProjection.new(record))
	return Rules.success({"games": records})


func get_current_selection() -> Dictionary:
	return _project_one(_process.get_current_selection())


func resolve_current_existing_game() -> Dictionary:
	return _project_one(_process.resolve_current_existing_game())


func resolve_existing_game(game_id: String) -> Dictionary:
	return _project_one(_process.resolve_existing_game(game_id))


func commit_current(game_id: String, verified_database_game_id: String, task_fault: String = "") -> Dictionary:
	return _project_one(_process.commit_current(game_id, verified_database_game_id, task_fault))


func managed_database_path(game_id: String) -> Dictionary:
	return _process.managed_database_path(game_id)


func legacy_database_path() -> String:
	return _process.legacy_database_path()


func _project_one(result: Dictionary) -> Dictionary:
	if not result.success:
		return result
	var projected := Rules.success({"record": RecordProjection.new(result.record)})
	for flag: String in ["already_registered", "already_current"]:
		if result.has(flag):
			projected[flag] = bool(result[flag])
	return projected
