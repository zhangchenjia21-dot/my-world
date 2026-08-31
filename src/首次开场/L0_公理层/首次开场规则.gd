class_name FirstOpeningRules
extends RefCounted

const SETUP_SCHEMA := "game_local_setup.v0.1"


static func inspect_eligibility(runtime: Variant) -> Dictionary:
	if runtime == null or not runtime.has_method("is_ready") or not runtime.is_ready():
		return failure("runtime_not_ready", "既有 Game session 尚未安全打开。")
	if runtime.conversation == null:
		return failure("conversation_unavailable", "既有 Conversation owner 不可用。")
	if runtime.conversation.is_generating():
		return failure("generation_active", "已有 generation 正在进行。")
	var accepted: Array = runtime.conversation.get_durable_accepted_entries()
	if not accepted.is_empty():
		return failure("already_opened", "本局已经存在 accepted Opening/Conversation，不会自动生成第二条 Opening。")
	var setup_validation := validate_setup(runtime.world_state)
	if not setup_validation.success:
		return setup_validation
	return success({"setup": (runtime.world_state as Dictionary).duplicate(true)})


static func validate_setup(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return failure("invalid_game_setup", "Current World 不是 Game-local setup document。")
	var setup := value as Dictionary
	if String(setup.get("schema_version", "")) != SETUP_SCHEMA:
		return failure("invalid_game_setup", "Current World 的 Game-local setup schema 无效。")
	for field: String in ["creation_origin", "game", "setup_ancestry", "world", "player_character"]:
		if typeof(setup.get(field)) != TYPE_DICTIONARY:
			return failure("invalid_game_setup", "Game-local setup 缺少结构：%s。" % field)
	if typeof(setup.get("guaranteed_npcs")) != TYPE_ARRAY:
		return failure("invalid_game_setup", "Game-local setup 的 guaranteed_npcs 无效。")
	var world := setup.world as Dictionary
	var player := setup.player_character as Dictionary
	if typeof(world.get("source_projection")) != TYPE_DICTIONARY or typeof(player.get("source_projection")) != TYPE_DICTIONARY:
		return failure("invalid_game_setup", "Game-local World/Player selected projection 缺失。")
	return success()


static func success(details: Dictionary = {}) -> Dictionary:
	var result := {"success": true, "status": "ready", "message": ""}
	result.merge(details, true)
	return result


static func failure(status: String, message: String, details: Dictionary = {}) -> Dictionary:
	var result := {"success": false, "status": status, "message": message}
	result.merge(details, true)
	return result
