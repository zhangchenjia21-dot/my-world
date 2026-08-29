class_name SourceLibraryFileStore
extends RefCounted

const Rules := preload("res://src/source/L0_公理层/Source库规则.gd")

var root: String


func _init(library_root: String) -> void:
	root = ProjectSettings.globalize_path(library_root).simplify_path()


func initialize() -> Dictionary:
	if root.strip_edges().is_empty():
		return Rules.failure("invalid_library_root", "Managed Source Library root 不能为空。")
	for relative: String in ["generations/world_pack", "generations/character_card", "current/world_pack", "current/character_card", "staging"]:
		var error := DirAccess.make_dir_recursive_absolute(root.path_join(relative))
		if error != OK:
			return Rules.failure("library_initialize_failed", "无法创建 Managed Source Library 目录：%s" % relative)
	return Rules.success()


func create_stage() -> Dictionary:
	var stage := root.path_join("staging").path_join("%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	var error := DirAccess.make_dir_recursive_absolute(stage)
	if error != OK:
		return Rules.failure("staging_create_failed", "无法创建 Source publication staging。")
	return Rules.success({"path": stage})


## 复制清单明确拥有的文件；不会递归复制外部目录、草稿、缓存或未声明文件。
func copy_contract_files(external_root: String, stage: String, relative_paths: Array[String]) -> Dictionary:
	var source_root := ProjectSettings.globalize_path(external_root).simplify_path()
	for relative_path: String in relative_paths:
		var source := source_root.path_join(relative_path)
		var target := stage.path_join(relative_path)
		var parent_error := DirAccess.make_dir_recursive_absolute(target.get_base_dir())
		if parent_error != OK:
			return Rules.failure("staging_copy_failed", "无法创建 staging 子目录：%s" % relative_path)
		var input := FileAccess.open(source, FileAccess.READ)
		if input == null:
			return Rules.failure("staging_copy_failed", "无法读取 contract-owned Source 文件：%s" % relative_path)
		var output := FileAccess.open(target, FileAccess.WRITE)
		if output == null:
			return Rules.failure("staging_copy_failed", "无法写入 staging Source 文件：%s" % relative_path)
		output.store_buffer(input.get_buffer(input.get_length()))
		output.flush()
		if output.get_error() != OK:
			return Rules.failure("staging_copy_failed", "staging Source 文件写入失败：%s" % relative_path)
	return Rules.success()


func generation_path(asset_type: String, asset_id: String, fingerprint: String) -> String:
	return root.path_join("generations").path_join(asset_type).path_join(asset_id).path_join(fingerprint)


func current_path(asset_type: String, asset_id: String) -> String:
	return root.path_join("current").path_join(asset_type).path_join("%s.json" % asset_id)


func publish_stage(stage: String, final_path: String) -> Dictionary:
	var parent_error := DirAccess.make_dir_recursive_absolute(final_path.get_base_dir())
	if parent_error != OK:
		return Rules.failure("generation_publish_failed", "无法创建 generation identity 目录。")
	var error := DirAccess.rename_absolute(stage, final_path)
	if error != OK:
		return Rules.failure("generation_publish_failed", "无法原子发布 staged generation：%s" % error_string(error))
	return Rules.success()


## 完整 JSON 先落到同目录 sibling，再以同卷 rename 提交；失败时既有 current 保持不变。
func publish_current(metadata: Dictionary) -> Dictionary:
	var path := current_path(String(metadata.asset_type), String(metadata.asset_id))
	var temporary := "%s.pending-%d-%d" % [path, OS.get_process_id(), Time.get_ticks_usec()]
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return Rules.failure("current_publish_failed", "无法写入 current metadata 临时文件。")
	file.store_string(JSON.stringify(metadata, "  ") + "\n")
	file.flush()
	if file.get_error() != OK:
		DirAccess.remove_absolute(temporary)
		return Rules.failure("current_publish_failed", "current metadata 临时文件写入失败。")
	file = null
	var error := DirAccess.rename_absolute(temporary, path)
	if error != OK:
		DirAccess.remove_absolute(temporary)
		return Rules.failure("current_publish_failed", "无法原子提交 current metadata：%s" % error_string(error))
	return Rules.success()


func read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return Rules.failure("metadata_missing", "Managed Source metadata 不存在。")
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return Rules.failure("metadata_read_failed", "Managed Source metadata 无法读取。")
	var bytes := file.get_buffer(file.get_length())
	var text := bytes.get_string_from_utf8()
	if text.to_utf8_buffer() != bytes:
		return Rules.failure("invalid_metadata", "Managed Source metadata 不是有效 UTF-8。")
	var parser := JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		return Rules.failure("invalid_metadata", "Managed Source metadata 不是有效 JSON object。")
	return Rules.success({"metadata": parser.data})


func list_current_metadata_paths(asset_type: String) -> Dictionary:
	var directory_path := root.path_join("current").path_join(asset_type)
	var directory := DirAccess.open(directory_path)
	if directory == null:
		return Rules.failure("inventory_read_failed", "无法读取 current inventory 目录：%s" % asset_type)
	var paths: Array[String] = []
	for file_name: String in directory.get_files():
		if file_name.ends_with(".json"):
			paths.append(directory_path.path_join(file_name))
	paths.sort()
	return Rules.success({"paths": paths})


func remove_tree(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		return
	for file_name: String in DirAccess.get_files_at(path):
		DirAccess.remove_absolute(path.path_join(file_name))
	for directory_name: String in DirAccess.get_directories_at(path):
		remove_tree(path.path_join(directory_name))
	DirAccess.remove_absolute(path)
