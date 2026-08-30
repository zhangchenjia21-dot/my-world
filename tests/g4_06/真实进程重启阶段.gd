extends SceneTree

## 本脚本每次只执行一个 phase。PowerShell controller 为 fault/resume/replay
## 分别启动独立 Godot 进程，因此 process_id 与 memory/object state 不会跨 phase 复用。

const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const SourceLibrary := preload("res://src/source/L3_外交层/Source库公开接口.gd")
const GameLibrary := preload("res://src/游戏库/L3_外交层/游戏库公开接口.gd")
const Persistence := preload("res://src/persistence/L3_外交层/世界持久化公开接口.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

var _fixture := Fixture.new()
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var phase := _argument("--phase=")
	var fault := _argument("--fault=")
	var case_root := _argument("--case-root=")
	var proof_path := _argument("--proof=")
	if not phase in ["fault", "resume", "replay"] or fault.is_empty() \
		or case_root.find("g4_06") < 0 or proof_path.find("g4_06") < 0:
		_fail("phase/fault/task-owned case-root/proof 参数无效")
		return _finish()
	var source_root := case_root.path_join("source-library")
	var library: RefCounted
	var generations: Array
	if phase == "fault":
		var installed := _fixture.install_real_assets(source_root)
		_check(installed.success, "Process A installs exact Source Library")
		if not installed.success:
			return _finish()
		library = installed.library
		generations = installed.installed
	else:
		library = SourceLibrary.new(source_root)
		var inventory: Dictionary = library.list_current_sources()
		_check(inventory.success and inventory.sources.size() == 8, "%s reopens same durable Source Library" % phase)
		if not inventory.success:
			return _finish()
		generations = inventory.sources
	var composition := _composition(library, generations)
	var creation_id := "creation-process-%s" % fault
	var creator := FinalCreate.new(
		library,
		case_root.path_join("creation"),
		case_root.path_join("library"),
		case_root.path_join("games")
	)
	var result: Dictionary = creator.create_or_resume(creation_id, composition, fault if phase == "fault" else "")
	if phase == "fault":
		_check(not result.success and String(result.code) == "injected_creation_interruption" and String(result.fault_point) == fault, "Process A reaches exact injected durable interruption")
	else:
		_check(result.success and String(result.status) == "created", "%s converges through production create_or_resume" % phase)
	var intent_path := case_root.path_join("creation/intents").path_join("%s.json" % creation_id)
	var intent := _read_json(intent_path)
	_check(not intent.is_empty(), "%s reads durable immutable intent" % phase)
	var state := _inspect_state(case_root, intent)
	if phase != "fault":
		_check(String(result.game_id) == String(intent.game_id), "%s returns intent-fixed game_id" % phase)
		_check(String(result.root_node_id) == String(intent.root_node_id), "%s returns intent-fixed root ID" % phase)
		_check(String(result.local_player_id) == String(intent.local_player_id) and result.local_npc_ids == intent.local_npc_ids, "%s returns intent-fixed local Player/NPC IDs" % phase)
		_check(state.db_count == 1 and state.record_count == 1 and state.inventory_count == 1, "%s has exactly one SQLite and matching Library record" % phase)
		_check(bool(state.current_matches), "%s current points to the same Game" % phase)
		_check(bool(state.root_matches) and int(state.accepted_count) == 0, "%s preserves root setup and empty Conversation" % phase)
	var proof := {
		"phase": phase,
		"fault": fault,
		"process_id": OS.get_process_id(),
		"creation_id": creation_id,
		"game_id": String(intent.get("game_id", "")),
		"root_node_id": String(intent.get("root_node_id", "")),
		"local_player_id": String(intent.get("local_player_id", "")),
		"local_npc_ids": intent.get("local_npc_ids", []).duplicate(),
		"result_success": bool(result.get("success", false)),
		"result_code": String(result.get("code", "")),
		"db_exists": bool(state.db_exists),
		"db_count": int(state.db_count),
		"database_sha256": String(state.database_sha256),
		"record_count": int(state.record_count),
		"inventory_count": int(state.inventory_count),
		"current_matches": bool(state.current_matches),
		"root_matches": bool(state.root_matches),
		"accepted_count": int(state.accepted_count),
		"ai_opening_turns": int(state.accepted_count),
	}
	_write_json(proof_path, proof)
	_check(FileAccess.file_exists(proof_path), "%s publishes controller proof" % phase)
	_finish()


func _composition(library: RefCounted, generations: Array) -> Dictionary:
	var creation := Creation.new(library)
	creation.select_world(_find_generation(generations, "world.ashtervia.afterglow"))
	creation.select_entry("t0-1287-border-route")
	creation.confirm_expansion_none()
	creation.select_player(_find_generation(generations, "character.ashtervia.adrian_wilk"))
	creation.set_guaranteed_npc(_find_generation(generations, "character.ashtervia.duen_stonescar"), true)
	creation.set_settings("真实进程重启", "Light", "process-boundary proof")
	return creation.composition_snapshot()


func _inspect_state(case_root: String, intent: Dictionary) -> Dictionary:
	var games_root := case_root.path_join("games")
	var database_path := games_root.path_join(String(intent.get("game_id", ""))).path_join("game.sqlite")
	var state := {
		"db_exists": FileAccess.file_exists(database_path),
		"db_count": _count_sqlite(games_root),
		"database_sha256": FileAccess.get_sha256(database_path) if FileAccess.file_exists(database_path) else "",
		"record_count": _record_count(case_root.path_join("library")),
		"inventory_count": 0,
		"current_matches": false,
		"root_matches": false,
		"accepted_count": -1,
	}
	var game_library := GameLibrary.new(case_root.path_join("library"), games_root)
	var inventory := game_library.list_games()
	if inventory.success:
		state.inventory_count = inventory.games.size()
	var current := game_library.get_current_selection()
	state.current_matches = current.success and String(current.record.game_id) == String(intent.get("game_id", ""))
	if not state.db_exists:
		return state
	var persistence := Persistence.new()
	var opened := persistence.open_database(database_path)
	if not opened.success:
		return state
	var identities := persistence.list_game_identities()
	var root := persistence.get_timeline_node(String(intent.game_id), String(intent.root_node_id))
	var conversation := persistence.get_current_conversation(String(intent.game_id))
	persistence.close_database()
	state.root_matches = identities.success and identities.game_ids == [intent.game_id] \
		and root.success and root.world_state == intent.initial_setup
	if conversation.success:
		state.accepted_count = conversation.accepted_entries.size()
	return state


func _find_generation(generations: Array, asset_id: String) -> RefCounted:
	for generation: RefCounted in generations:
		if String(generation.identity.asset_id) == asset_id:
			return generation
	return null


func _count_sqlite(root_path: String) -> int:
	if not DirAccess.dir_exists_absolute(root_path):
		return 0
	var count := 0
	for directory: String in DirAccess.get_directories_at(root_path):
		if FileAccess.file_exists(root_path.path_join(directory).path_join("game.sqlite")):
			count += 1
	return count


func _record_count(library_root: String) -> int:
	var records := library_root.path_join("records")
	if not DirAccess.dir_exists_absolute(records):
		return 0
	var count := 0
	for file_name: String in DirAccess.get_files_at(records):
		if file_name.ends_with(".json"):
			count += 1
	return count


func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _write_json(path: String, value: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(value, "  ") + "\n")


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-06 IR01 PHASE PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-06 IR01 PHASE FAIL | %s" % label)


func _finish() -> void:
	print("G4-06 IR01 PHASE | pid=%d done failures=%d" % [OS.get_process_id(), _failures])
	quit(0 if _failures == 0 else 1)
