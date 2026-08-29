class_name GameLibraryTestFixture
extends RefCounted

const Persistence := preload("res://src/persistence/L3_外交层/世界持久化公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")


func reset_directory(path: String) -> void:
	if DirAccess.dir_exists_absolute(path):
		_remove_tree(path)
	DirAccess.make_dir_recursive_absolute(path)


## 测试专用 fixture：直接用既有 G3 contract 创建一个指定 identity 的独立 SQLite，
## 随后走真实 Runtime acceptance/backup；此能力不暴露给产品 New Game。
func seed_game(database_path: String, game_id: String, world: Dictionary, player_text: String, gm_text: String, create_save: bool = false) -> Dictionary:
	DirAccess.make_dir_recursive_absolute(database_path.get_base_dir())
	var persistence := Persistence.new()
	var opened: Dictionary = persistence.open_database(database_path)
	if not opened.success:
		return opened
	var created: Dictionary = persistence.create_initial_game(game_id, "root-%s" % game_id, world, "2026-08-29T00:00:00Z")
	persistence.close_database()
	if not created.success:
		return created
	var runtime := Runtime.new()
	var resumed: Dictionary = runtime.open_existing_game(database_path)
	if not resumed.success:
		return resumed
	runtime.conversation.begin_turn(player_text)
	runtime.conversation.append_delta(gm_text)
	var accepted: Dictionary = runtime.complete_active_generation_durably()
	if not accepted.success:
		runtime.close()
		return accepted
	var saved: Dictionary = {"success": true}
	if create_save:
		saved = runtime.create_save_point("fixture-save-%s" % game_id)
	var result := {
		"success": bool(saved.success),
		"game_id": String(runtime.game_id),
		"head_id": String(runtime.active_head_id),
		"world": runtime.world_state.duplicate(true),
		"accepted": runtime.conversation.get_durable_accepted_entries(),
		"save_count": runtime.list_save_points().save_points.size(),
	}
	runtime.close()
	return result


func corrupt(database_path: String) -> void:
	var file := FileAccess.open(database_path, FileAccess.WRITE)
	file.store_string("intentional G4-04 physical corruption")
	file.close()


func overwrite_file(source: String, target: String) -> void:
	var input := FileAccess.open(source, FileAccess.READ)
	var output := FileAccess.open(target, FileAccess.WRITE)
	output.store_buffer(input.get_buffer(input.get_length()))
	output.close()


func write_json(path: String, value: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(value, "  ") + "\n")
	file.close()


func file_hash(path: String) -> String:
	return FileAccess.get_sha256(path)


func _remove_tree(path: String) -> void:
	for file_name: String in DirAccess.get_files_at(path):
		DirAccess.remove_absolute(path.path_join(file_name))
	for directory_name: String in DirAccess.get_directories_at(path):
		_remove_tree(path.path_join(directory_name))
	DirAccess.remove_absolute(path)
