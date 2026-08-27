extends RefCounted

## current Game 的最小 application composition owner。
##
## 本对象组合 Persistence L3 与 Conversation Domain，负责 one-current-Game startup、
## rehydration、persist-before-accept 和资源关闭；它不解释 World JSON、不组装 Provider
## messages，也不实现 Save/Load/Restore 或多 Game picker。

const Persistence := preload("res://src/persistence/L3_外交层/世界持久化公开接口.gd")
const Conversation := preload("res://src/domain/会话.gd")

const DEFAULT_DATABASE_PATH := "user://my-world/current-game.sqlite"

var persistence: RefCounted = Persistence.new()
var conversation: RefCounted = Conversation.new()
var database_path := ""
var game_id := ""
var active_head_id := ""
var root_node_id := ""
var world_state: Dictionary = {}
var startup_result: Dictionary = {"status": "not_started", "success": false, "message": ""}


## 打开明确路径的 one-current-Game。只有调用前 DB 文件真实不存在时才允许 mint Game；
## existing zero/multi/corrupt/schema/Conversation failure 均 fail-loud，不创建替代空局。
func open_current_game(explicit_database_path: String) -> Dictionary:
	if explicit_database_path.strip_edges().is_empty():
		return _startup_failure("invalid_path", "Current Game 数据库路径为空。")
	database_path = explicit_database_path
	var existed_before_open := FileAccess.file_exists(database_path)
	if not existed_before_open:
		var parent := database_path.get_base_dir()
		var directory_error := DirAccess.make_dir_recursive_absolute(parent)
		if directory_error != OK:
			return _startup_failure("storage_failure", "无法创建 Current Game 数据目录。")

	var opened: Dictionary = persistence.open_database(database_path)
	if not opened.success:
		return _startup_failure(String(opened.status), "无法打开 Current Game 数据。", opened.message)
	var identities: Dictionary = persistence.list_game_identities()
	if not identities.success:
		return _close_after_startup_failure(String(identities.status), "无法读取 Current Game identity。", identities.message)
	var game_ids := identities.game_ids as Array
	var created := false
	if not existed_before_open:
		if not game_ids.is_empty():
			return _close_after_startup_failure("invalid_state", "新数据库出现了意外 Game identity。")
		game_id = _generate_identity("game")
		root_node_id = _generate_identity("root")
		var created_result: Dictionary = persistence.create_initial_game(game_id, root_node_id, {}, _now_utc())
		if not created_result.success:
			return _close_after_startup_failure(String(created_result.status), "无法创建 Current Game。", created_result.message)
		created = true
	elif game_ids.is_empty():
		return _close_after_startup_failure("missing_game", "Current Game 数据库中没有 Game；不会自动创建替代新局。")
	elif game_ids.size() > 1:
		return _close_after_startup_failure("ambiguous_game", "Current Game 数据库包含多个 Game；当前版本不会猜测选择。")
	else:
		game_id = String(game_ids[0])

	var current: Dictionary = persistence.get_current_game(game_id)
	if not current.success:
		return _close_after_startup_failure(String(current.status), "无法恢复 Current World。", current.message)
	var durable_conversation: Dictionary = persistence.get_current_conversation(game_id)
	if not durable_conversation.success:
		return _close_after_startup_failure(String(durable_conversation.status), "无法恢复 accepted Conversation。", durable_conversation.message)
	var restored: Dictionary = conversation.restore_accepted_entries(durable_conversation.accepted_entries)
	if not restored.ok:
		return _close_after_startup_failure("invalid_conversation", "accepted Conversation 数据无效。", restored.error)
	active_head_id = String(current.head_id)
	if created:
		root_node_id = active_head_id
	world_state = (current.world_state as Dictionary).duplicate(true)
	startup_result = {
		"status": "created" if created else "resumed",
		"success": true,
		"message": "",
		"game_id": game_id,
		"head_id": active_head_id,
		"world_state": world_state.duplicate(true),
		"accepted_count": int(restored.accepted_count),
	}
	return startup_result.duplicate(true)


## Provider completed 后的唯一 durable acceptance seam。
## candidate 不修改 Domain；SQLite COMMIT 成功后才调用 complete_generation() 发布 accepted。
func complete_active_generation_durably() -> Dictionary:
	if not is_ready():
		return {"status": "startup_failure", "success": false, "message": "Current Game 尚未就绪。"}
	var candidate: Dictionary = conversation.get_completion_candidate()
	if not candidate.ok:
		# empty_generation 仍由 Conversation 发出既有 Domain failure signal；不写 durable truth。
		conversation.complete_generation()
		return {"status": String(candidate.code), "success": false, "message": "当前生成没有可持久化的 accepted candidate。"}
	var committed: Dictionary = persistence.write_current_conversation(game_id, candidate.accepted_entries, _now_utc())
	if not committed.success:
		conversation.fail_generation("persistence_failure")
		return {
			"status": "persistence_failure",
			"success": false,
			"message": committed.message,
			"storage_status": committed.status,
		}
	conversation.complete_generation()
	return {
		"status": "accepted",
		"success": true,
		"message": "",
		"revision": committed.revision,
		"accepted_entries": committed.accepted_entries,
	}


func is_ready() -> bool:
	return bool(startup_result.get("success", false)) and persistence != null


## accepted truth 已在每次 completion 前 durable；close 只放弃 non-accepted attempt 并释放连接，
## 不把正确性押在 process shutdown 的最后一次 flush。
func close() -> Dictionary:
	if conversation != null and conversation.is_generating():
		conversation.cancel_generation()
	if persistence == null:
		return {"status": "ready", "success": true, "message": ""}
	var closed: Dictionary = persistence.close_database()
	persistence = null
	return closed


static func default_database_path() -> String:
	return ProjectSettings.globalize_path(DEFAULT_DATABASE_PATH)


func _generate_identity(prefix: String) -> String:
	return "%s-%s" % [prefix, Crypto.new().generate_random_bytes(16).hex_encode()]


func _now_utc() -> String:
	return Time.get_datetime_string_from_system(true, true)


func _close_after_startup_failure(status: String, player_message: String, engineering_cause: String = "") -> Dictionary:
	persistence.close_database()
	persistence = null
	return _startup_failure(status, player_message, engineering_cause)


func _startup_failure(status: String, player_message: String, engineering_cause: String = "") -> Dictionary:
	startup_result = {
		"status": status,
		"success": false,
		"message": player_message,
		"engineering_cause": engineering_cause,
	}
	return startup_result.duplicate(true)
