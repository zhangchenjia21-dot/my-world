class_name GameLibraryRules
extends RefCounted

## Game Library 只定义 Application 级 index/current facts；Game gameplay truth 始终留在各自 SQLite。

const RECORD_SCHEMA := "game_library_record.v0.1"
const CURRENT_SCHEMA := "game_library_current.v0.1"
const MANAGED := "managed"
const LEGACY_G3 := "legacy_g3"
const STORAGE_KINDS := [MANAGED, LEGACY_G3]
const PRODUCTION_LIBRARY_ROOT := "user://my-world/game-library"
const PRODUCTION_GAMES_ROOT := "user://my-world/games"
const RECORD_FIELDS := ["schema_version", "game_id", "display_name", "storage_kind"]
const CURRENT_FIELDS := ["schema_version", "game_id"]


static func success(values: Dictionary = {}) -> Dictionary:
	var result := {"success": true}
	result.merge(values, true)
	return result


static func failure(code: String, message: String) -> Dictionary:
	return {"success": false, "code": code, "message": message}


static func make_record(game_id: String, display_name: String, storage_kind: String) -> Dictionary:
	return {
		"schema_version": RECORD_SCHEMA,
		"game_id": game_id,
		"display_name": display_name,
		"storage_kind": storage_kind,
	}


static func make_current(game_id: String) -> Dictionary:
	return {"schema_version": CURRENT_SCHEMA, "game_id": game_id}


static func validate_record(record: Dictionary) -> Dictionary:
	if record.size() != RECORD_FIELDS.size():
		return failure("invalid_game_record", "Game record 字段集合无效。")
	for field: String in RECORD_FIELDS:
		if not record.has(field) or not record[field] is String or String(record[field]).is_empty():
			return failure("invalid_game_record", "Game record 字段无效：%s" % field)
	if String(record.schema_version) != RECORD_SCHEMA:
		return failure("invalid_game_record", "不支持的 Game record schema。")
	var identity := validate_game_id(String(record.game_id))
	if not identity.success:
		return failure("invalid_game_record", String(identity.message))
	if String(record.display_name).strip_edges().is_empty() or String(record.display_name).length() > 120:
		return failure("invalid_game_record", "Game display_name 必须是 1..120 字符。")
	if not STORAGE_KINDS.has(String(record.storage_kind)):
		return failure("invalid_game_record", "Game storage_kind 无效。")
	return success()


static func validate_current(current: Dictionary) -> Dictionary:
	if current.size() != CURRENT_FIELDS.size() or String(current.get("schema_version", "")) != CURRENT_SCHEMA:
		return failure("invalid_current_selection", "Game current metadata 字段或 schema 无效。")
	var identity := validate_game_id(String(current.get("game_id", "")))
	if not identity.success:
		return failure("invalid_current_selection", String(identity.message))
	return success()


static func validate_game_id(game_id: String) -> Dictionary:
	if game_id.is_empty() or game_id.length() > 128 or game_id in [".", ".."]:
		return failure("invalid_game_id", "game_id 长度或路径语义无效。")
	for index: int in game_id.length():
		var code := game_id.unicode_at(index)
		var allowed := (code >= 97 and code <= 122) or (code >= 65 and code <= 90) \
			or (code >= 48 and code <= 57) or code in [45, 46, 95]
		if not allowed:
			return failure("invalid_game_id", "game_id 只允许 ASCII 字母、数字、点、下划线和连字符。")
	return success()


static func database_path(record: Dictionary, managed_games_root: String, legacy_database_path: String) -> String:
	if String(record.storage_kind) == LEGACY_G3:
		return legacy_database_path
	return managed_games_root.path_join(String(record.game_id)).path_join("game.sqlite")
