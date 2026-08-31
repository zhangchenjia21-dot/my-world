extends SceneTree

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Opening := preload("res://src/首次开场/L3_外交层/首次开场公开接口.gd")

var _failures := 0


func _initialize() -> void:
	var evidence_path := _argument("--evidence=")
	var output_path := _argument("--output=")
	if evidence_path.is_empty() or output_path.is_empty():
		return _finish(1)
	var evidence_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(evidence_path))
	if typeof(evidence_value) != TYPE_DICTIONARY:
		return _finish(1)
	var proof := {"schema_version": "g4_07a.process_reopen_evidence.v0.1", "process_id": OS.get_process_id(), "routes": []}
	for route_value: Variant in (evidence_value as Dictionary).get("routes", []):
		var route := route_value as Dictionary
		var runtime := Runtime.new()
		var opened: Dictionary = runtime.open_existing_game(String(route.database_path))
		_check(opened.success and runtime.game_id == String(route.game_id), "%s fresh process opens exact Game identity" % String(route.route))
		var accepted: Array = runtime.conversation.get_durable_accepted_entries()
		_check(accepted.size() == 1 and String(accepted[0].player_text).is_empty() and String(accepted[0].gm_text).sha256_text() == String(route.response_sha256), "%s fresh process restores exact one real GM Opening" % String(route.route))
		var opening := Opening.new(runtime)
		root.add_child(opening)
		var rejected: Dictionary = opening.start_first_opening()
		_check(String(rejected.status) == "already_opened", "%s fresh process cannot generate second first Opening" % String(route.route))
		runtime.conversation.begin_turn("跨进程重开后的下一步行动")
		var continuation_result: Dictionary = opening.assemble_continuation_messages()
		var continuation := continuation_result.get("messages", []) as Array
		_check(continuation_result.success and _roles(continuation) == ["system", "assistant", "user"], "%s continuation contains durable Opening and real next Player turn" % String(route.route))
		var expected_world_marker := "e208-snapshot" if String(route.route) == "han" else "t0-1287-public-works"
		_check(JSON.stringify(continuation).contains(expected_world_marker), "%s continuation rebuilds durable Game-local World truth" % String(route.route))
		runtime.conversation.cancel_generation()
		proof.routes.append({
			"route": route.route,
			"game_id": runtime.game_id,
			"active_head_id": runtime.active_head_id,
			"accepted_count": accepted.size(),
			"response_sha256": String(accepted[0].gm_text).sha256_text() if accepted.size() == 1 else "",
			"second_opening_status": String(rejected.status),
		})
		opening.free()
		runtime.close()
	DirAccess.make_dir_recursive_absolute(output_path.get_base_dir())
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		return _finish(1)
	file.store_string(JSON.stringify(proof, "  ", false, true))
	file.close()
	_finish(_failures)


func _roles(messages: Array) -> Array:
	var roles: Array = []
	for message: Dictionary in messages:
		roles.append(String(message.get("role", "")))
	return roles


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-07A PROCESS REOPEN PASS | %s" % label)
	else:
		_failures += 1
		push_error("G4-07A PROCESS REOPEN FAIL | %s" % label)


func _finish(failures: int) -> void:
	print("G4-07A PROCESS REOPEN | pid=%d failures=%d" % [OS.get_process_id(), failures])
	quit(0 if failures == 0 else 1)
