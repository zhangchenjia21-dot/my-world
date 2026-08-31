extends SceneTree

const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Opening := preload("res://src/首次开场/L3_外交层/首次开场公开接口.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

const ROUTE_TIMEOUT_MSEC := 600000

var _failures := 0
var _fixture := Fixture.new()
var _root := ""
var _evidence_path := ""
var _library: RefCounted
var _generations: Array
var _evidence := {"schema_version": "g4_07a.real_provider_evidence.v0.1", "routes": []}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	_evidence_path = _argument("--evidence=")
	if _root.find("g4_07a") < 0 or _evidence_path.is_empty() or OS.get_environment("DEEPSEEK_API_KEY").strip_edges().is_empty():
		return _finish_with_failure("task-owned root/evidence/DEEPSEEK_API_KEY required")
	_fixture.reset_directory(_root)
	var installed := _fixture.install_real_assets(_root.path_join("source-library"))
	_check(installed.success, "real frozen assets installed")
	if not installed.success:
		return _finish()
	_library = installed.library
	_generations = installed.installed
	await _run_route("han", "world.han_end.unsettled_realm", "t0-208-red-cliffs-eve", "character.han_end.liu_bei", ["character.han_end.sun_quan"], "赤壁前夕真实开场", "从江夏雨夜开始；不要强制孙权出现在第一幕。", ["t0-208-red-cliffs-eve", "e208-snapshot", "han-208"], ["e220-snapshot", "liu-bei-220"])
	await _run_route("afterglow", "world.ashtervia.afterglow", "t0-1287-public-works", "character.ashtervia.livia_selan", ["character.ashtervia.adrian_wilk", "character.ashtervia.duen_stonescar"], "诸界余辉真实开场", "从奥维斯塔公共工程余波开始，保留每个人的信息边界。", ["t0-1287-public-works", "莉维娅", "阿德里安", "杜恩"], ["t0-208-red-cliffs-eve"])
	_finish()


func _run_route(route: String, world_id: String, entry_id: String, player_id: String, npc_ids: Array, display_name: String, supplement: String, included: Array, excluded: Array) -> void:
	var case_root := _root.path_join(route)
	DirAccess.make_dir_recursive_absolute(case_root)
	var composition := _composition(world_id, entry_id, player_id, npc_ids, display_name, supplement)
	var created: Dictionary = FinalCreate.new(_library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games")).create_or_resume("g4-07a-real-%s" % route, composition)
	_check(created.success, "%s production G4-06 create" % route)
	if not created.success:
		return
	var runtime := Runtime.new()
	var opened: Dictionary = runtime.open_existing_game(String(created.database_path))
	_check(opened.success, "%s existing-only open" % route)
	if not opened.success:
		return
	var opening := Opening.new(runtime)
	root.add_child(opening)
	await process_frame
	var started: Dictionary = opening.start_first_opening()
	_check(started.success and String(started.status) == "streaming", "%s real DeepSeek stream starts" % route)
	if not started.success:
		runtime.close()
		opening.queue_free()
		return
	var request_text := JSON.stringify(opening.last_request_messages)
	var markers_ok := true
	for marker: String in included:
		markers_ok = markers_ok and request_text.contains(marker)
	for marker: String in excluded:
		markers_ok = markers_ok and not request_text.contains(marker)
	_check(markers_ok, "%s Provider-visible include/exclude markers" % route)

	var deadline := Time.get_ticks_msec() + ROUTE_TIMEOUT_MSEC
	while String(opening.last_result.get("status", "")) == "streaming" and Time.get_ticks_msec() < deadline:
		await process_frame
	if String(opening.last_result.get("status", "")) == "streaming":
		opening.cancel()
		_check(false, "%s real Provider timeout" % route)
		runtime.close()
		opening.queue_free()
		return
	print("G4-07A REAL TERMINAL | %s status=%s message=%s" % [route, String(opening.last_result.get("status", "")), String(opening.last_result.get("message", ""))])
	_check(bool(opening.last_result.get("success", false)) and String(opening.last_result.get("status", "")) == "accepted", "%s real Provider Opening accepted" % route)
	var accepted: Array = runtime.conversation.get_durable_accepted_entries()
	var gm_text := String(accepted[0].gm_text) if accepted.size() == 1 else ""
	_check(accepted.size() == 1 and String(accepted[0].player_text).is_empty() and not gm_text.strip_edges().is_empty(), "%s real GM-only Conversation durable once" % route)
	var adapter: Node = opening.provider_adapter
	var game_id := runtime.game_id
	var root_id := String(created.root_node_id)
	var stats := opening.last_context_stats.duplicate(true)
	var terminal_status := String(opening.last_result.get("status", ""))
	var timing := {
		"started_msec": adapter.started_msec,
		"first_delta_msec": adapter.first_delta_msec,
		"finished_msec": adapter.finished_msec,
		"ttft_msec": adapter.first_delta_msec - adapter.started_msec,
		"duration_msec": adapter.finished_msec - adapter.started_msec,
		"delta_count": adapter.delta_count,
		"output_chars": adapter.output_chars,
	}
	opening.queue_free()
	runtime.close()
	await process_frame
	var reopened := Runtime.new()
	var reopen: Dictionary = reopened.open_existing_game(String(created.database_path))
	var reopened_entries: Array = reopened.conversation.get_durable_accepted_entries() if reopen.success else []
	_check(reopen.success and reopened.game_id == game_id and reopened_entries.size() == 1 and String(reopened_entries[0].gm_text) == gm_text, "%s close/reopen exact durable Opening" % route)
	_evidence.routes.append({
		"route": route,
		"game_id": game_id,
		"root_node_id": root_id,
		"database_path": String(created.database_path),
		"model": OS.get_environment("MY_WORLD_DEEPSEEK_MODEL") if not OS.get_environment("MY_WORLD_DEEPSEEK_MODEL").is_empty() else "deepseek-v4-pro",
		"request_roles": ["system"],
		"context_stats": stats,
		"provider_timing": timing,
		"terminal_status": terminal_status,
		"accepted_count_after_reopen": reopened_entries.size(),
		"player_text_empty": reopened_entries.size() == 1 and String(reopened_entries[0].player_text).is_empty(),
		"response_sha256": gm_text.sha256_text(),
		"response_chars": gm_text.length(),
		"response_excerpt": gm_text.left(240),
	})
	reopened.close()
	print("G4-07A REAL ROUTE | %s context_chars=%d output_chars=%d ttft_msec=%d duration_msec=%d" % [route, int(stats.context_chars), gm_text.length(), int(timing.ttft_msec), int(timing.duration_msec)])


func _composition(world_id: String, entry_id: String, player_id: String, npc_ids: Array, display_name: String, supplement: String) -> Dictionary:
	var creation := Creation.new(_library)
	creation.select_world(_generation(world_id))
	creation.select_entry(entry_id)
	creation.confirm_expansion_none()
	creation.select_player(_generation(player_id))
	for npc_id: String in npc_ids:
		creation.set_guaranteed_npc(_generation(npc_id), true)
	creation.set_settings(display_name, "Narrative", supplement)
	return creation.composition_snapshot()


func _generation(asset_id: String) -> RefCounted:
	return _fixture.find_generation(_generations, asset_id)


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-07A REAL PASS | %s" % label)
	else:
		_failures += 1
		push_error("G4-07A REAL FAIL | %s" % label)


func _finish_with_failure(message: String) -> void:
	_check(false, message)
	_finish()


func _finish() -> void:
	_evidence["completed_at_utc"] = Time.get_datetime_string_from_system(true, true)
	_evidence["failure_count"] = _failures
	DirAccess.make_dir_recursive_absolute(_evidence_path.get_base_dir())
	var file := FileAccess.open(_evidence_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(_evidence, "  ", false, true))
		file.close()
	else:
		_failures += 1
	print("G4-07A REAL | done failures=%d evidence=%s" % [_failures, _evidence_path])
	quit(0 if _failures == 0 else 1)
