class_name GameLibraryProcess
extends RefCounted

const Rules := preload("res://src/游戏库/L0_公理层/游戏库规则.gd")
const Store := preload("res://src/游戏库/L1_器件层/游戏库元数据存储.gd")

const FAULT_BEFORE_RECORD_PUBLISH := "before_record_publish"
const FAULT_BEFORE_CURRENT_PUBLISH := "before_current_publish"

var _store: RefCounted
var _managed_games_root: String
var _legacy_database_path: String


func _init(library_root: String, managed_games_root: String, legacy_database_path: String) -> void:
	_store = Store.new(library_root)
	_managed_games_root = ProjectSettings.globalize_path(managed_games_root).simplify_path()
	_legacy_database_path = ProjectSettings.globalize_path(legacy_database_path).simplify_path()


## verified_database_game_id 必须来自 Application 刚完成的 Runtime identity check；
## 本流程仍会检查 exact path 已存在，但绝不打开或创建 gameplay SQLite。
func register_verified_game(game_id: String, display_name: String, storage_kind: String, verified_database_game_id: String, fault: String = "") -> Dictionary:
	var initialized: Dictionary = _store.initialize()
	if not initialized.success:
		return initialized
	if game_id != verified_database_game_id:
		return Rules.failure("game_identity_mismatch", "登记 intent 与已验证的数据库 Game identity 不一致。")
	var record := Rules.make_record(game_id, display_name, storage_kind)
	var validation := Rules.validate_record(record)
	if not validation.success:
		return validation
	var database_path := Rules.database_path(record, _managed_games_root, _legacy_database_path)
	if not FileAccess.file_exists(database_path):
		return Rules.failure("game_database_missing", "只能登记已经存在的 Game database。")
	var path: String = _store.record_path(game_id)
	if FileAccess.file_exists(path):
		var existing := _read_record_path(path)
		if not existing.success:
			return existing
		if String(existing.record.storage_kind) != storage_kind:
			return Rules.failure("game_record_conflict", "同一 game_id 已登记为另一 storage kind。")
		if existing.record == record:
			return Rules.success({"record": _resolved(existing.record), "already_registered": true})
		return Rules.failure("game_record_conflict", "同一 game_id 已有不同的 verified Game record；不会覆盖。")
	if fault == FAULT_BEFORE_RECORD_PUBLISH:
		return Rules.failure("injected_record_publish_failure", "task-only fault：record publish 前中断。")
	if not fault.is_empty():
		return Rules.failure("invalid_fault", "未知的 Game Library task-only fault。")
	var published: Dictionary = _store.publish_json(path, record)
	if not published.success:
		return published
	var committed := _read_record_path(path)
	if not committed.success:
		return committed
	return Rules.success({"record": _resolved(committed.record), "already_registered": false})


func list_records() -> Dictionary:
	var initialized: Dictionary = _store.initialize()
	if not initialized.success:
		return initialized
	var listed: Dictionary = _store.list_record_paths()
	if not listed.success:
		return listed
	var records: Array[Dictionary] = []
	for path: String in listed.paths:
		var loaded := _read_record_path(path)
		if not loaded.success:
			return loaded
		records.append(_resolved(loaded.record))
	return Rules.success({"records": records})


## Metadata-only query；不检查或打开 Game DB，供 Main Menu/restart 恢复 selection projection。
func get_current_selection() -> Dictionary:
	var initialized: Dictionary = _store.initialize()
	if not initialized.success:
		return initialized
	var read: Dictionary = _store.read_json(_store.current_path())
	if not read.success:
		return Rules.failure("no_current_selection" if String(read.code) == "metadata_missing" else "current_selection_invalid", String(read.message))
	var current: Dictionary = read.value
	var validation := Rules.validate_current(current)
	if not validation.success:
		return Rules.failure("current_selection_invalid", String(validation.message))
	var record := get_record(String(current.game_id))
	if not record.success:
		return Rules.failure("current_selection_invalid", "current pointer 指向 missing/invalid Game record。")
	return record


func get_record(game_id: String) -> Dictionary:
	var identity := Rules.validate_game_id(game_id)
	if not identity.success:
		return identity
	var initialized: Dictionary = _store.initialize()
	if not initialized.success:
		return initialized
	var loaded := _read_record_path(_store.record_path(game_id))
	if not loaded.success:
		return loaded
	return Rules.success({"record": _resolved(loaded.record)})


func resolve_existing_game(game_id: String) -> Dictionary:
	var found := get_record(game_id)
	if not found.success:
		return found
	if not FileAccess.file_exists(String(found.record.database_path)):
		return Rules.failure("game_database_missing", "Game record 指向的数据库不存在；不会创建替代 Game。")
	return found


func resolve_current_existing_game() -> Dictionary:
	var selected := get_current_selection()
	if not selected.success:
		return selected
	if not FileAccess.file_exists(String(selected.record.database_path)):
		return Rules.failure("game_database_missing", "current Game database 不存在；不会创建替代 Game。")
	return selected


## current 只接受 Application 已从 opened Runtime 验证的同一 identity。
func commit_current(game_id: String, verified_database_game_id: String, fault: String = "") -> Dictionary:
	if game_id != verified_database_game_id:
		return Rules.failure("game_identity_mismatch", "current intent 与已打开数据库 identity 不一致。")
	var found := resolve_existing_game(game_id)
	if not found.success:
		return found
	var current_path: String = _store.current_path()
	if FileAccess.file_exists(current_path):
		var existing := get_current_selection()
		if not existing.success:
			return existing
		if String(existing.record.game_id) == game_id:
			return Rules.success({"record": found.record, "already_current": true})
	if fault == FAULT_BEFORE_CURRENT_PUBLISH:
		return Rules.failure("injected_current_publish_failure", "task-only fault：current publish 前中断。")
	if not fault.is_empty():
		return Rules.failure("invalid_fault", "未知的 Game Library task-only fault。")
	var published: Dictionary = _store.publish_json(current_path, Rules.make_current(game_id))
	if not published.success:
		return published
	var selected := get_current_selection()
	if not selected.success:
		return selected
	return Rules.success({"record": selected.record, "already_current": false})


func managed_database_path(game_id: String) -> Dictionary:
	var identity := Rules.validate_game_id(game_id)
	if not identity.success:
		return identity
	return Rules.success({"path": _managed_games_root.path_join(game_id).path_join("game.sqlite")})


func legacy_database_path() -> String:
	return _legacy_database_path


func _read_record_path(path: String) -> Dictionary:
	var read: Dictionary = _store.read_json(path)
	if not read.success:
		return Rules.failure("game_record_missing" if String(read.code) == "metadata_missing" else "invalid_game_record", String(read.message))
	var record: Dictionary = read.value
	var validation := Rules.validate_record(record)
	if not validation.success:
		return validation
	if path.get_file() != "%s.json" % String(record.game_id):
		return Rules.failure("invalid_game_record", "Game record filename 与 game_id 不一致。")
	return Rules.success({"record": record})


func _resolved(record: Dictionary) -> Dictionary:
	var result := record.duplicate(true)
	result["database_path"] = Rules.database_path(record, _managed_games_root, _legacy_database_path)
	return result
