class_name GameLibraryMetadataStore
extends RefCounted

const Rules := preload("res://src/游戏库/L0_公理层/游戏库规则.gd")

var root: String


func _init(library_root: String) -> void:
	root = ProjectSettings.globalize_path(library_root).simplify_path()


func initialize() -> Dictionary:
	if root.strip_edges().is_empty():
		return Rules.failure("invalid_library_root", "Game Library root 不能为空。")
	var error := DirAccess.make_dir_recursive_absolute(root.path_join("records"))
	if error != OK:
		return Rules.failure("library_initialize_failed", "无法创建 Game Library records 目录。")
	return Rules.success()


func record_path(game_id: String) -> String:
	return root.path_join("records").path_join("%s.json" % game_id)


func current_path() -> String:
	return root.path_join("current.json")


## 完整 JSON 先写同目录 sibling，再用同卷 rename 原子替换；失败不删除既有 authority 文件。
func publish_json(path: String, value: Dictionary) -> Dictionary:
	var temporary := "%s.pending-%d-%d" % [path, OS.get_process_id(), Time.get_ticks_usec()]
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return Rules.failure("metadata_publish_failed", "无法创建 Game Library metadata 临时文件。")
	file.store_string(JSON.stringify(value, "  ") + "\n")
	file.flush()
	if file.get_error() != OK:
		file = null
		DirAccess.remove_absolute(temporary)
		return Rules.failure("metadata_publish_failed", "Game Library metadata 临时文件写入失败。")
	file = null
	var error := DirAccess.rename_absolute(temporary, path)
	if error != OK:
		DirAccess.remove_absolute(temporary)
		return Rules.failure("metadata_publish_failed", "Game Library metadata 原子提交失败：%s" % error_string(error))
	return Rules.success()


func read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return Rules.failure("metadata_missing", "Game Library metadata 不存在。")
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return Rules.failure("metadata_read_failed", "Game Library metadata 无法读取。")
	var bytes := file.get_buffer(file.get_length())
	var text := bytes.get_string_from_utf8()
	if text.to_utf8_buffer() != bytes:
		return Rules.failure("invalid_metadata", "Game Library metadata 不是有效 UTF-8。")
	var parser := JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		return Rules.failure("invalid_metadata", "Game Library metadata 不是有效 JSON object。")
	return Rules.success({"value": parser.data})


func list_record_paths() -> Dictionary:
	var directory := DirAccess.open(root.path_join("records"))
	if directory == null:
		return Rules.failure("inventory_read_failed", "无法读取 Game Library records。")
	var paths: Array[String] = []
	for file_name: String in directory.get_files():
		if file_name.ends_with(".json"):
			paths.append(root.path_join("records").path_join(file_name))
	paths.sort()
	return Rules.success({"paths": paths})
