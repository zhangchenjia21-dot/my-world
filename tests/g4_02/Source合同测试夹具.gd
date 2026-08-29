class_name SourceContractTestFixture
extends RefCounted


func reset_directory(path: String) -> void:
	if DirAccess.dir_exists_absolute(path):
		_remove_tree(path)
	DirAccess.make_dir_recursive_absolute(path)


func copy_package(source_path: String, target_path: String, reverse_order: bool = false) -> void:
	var source := ProjectSettings.globalize_path(source_path).simplify_path()
	DirAccess.make_dir_recursive_absolute(target_path)
	_copy_tree(source, target_path, reverse_order)


func read_manifest(package_path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(package_path.path_join("source.json"))
	var parsed: Variant = JSON.parse_string(text)
	return parsed as Dictionary


func write_manifest(package_path: String, manifest: Dictionary) -> void:
	write_text(package_path.path_join("source.json"), JSON.stringify(manifest, "  ") + "\n")


func write_text(path: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)


func write_bytes(path: String, bytes: PackedByteArray) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(bytes)


func append_text(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ_WRITE)
	file.seek_end()
	file.store_string(text)


func _copy_tree(source: String, target: String, reverse_order: bool) -> void:
	var files := Array(DirAccess.get_files_at(source))
	var directories := Array(DirAccess.get_directories_at(source))
	files.sort()
	directories.sort()
	if reverse_order:
		files.reverse()
		directories.reverse()
	for file_name: String in files:
		_copy_file(source.path_join(file_name), target.path_join(file_name))
	for directory_name: String in directories:
		var child_target := target.path_join(directory_name)
		DirAccess.make_dir_recursive_absolute(child_target)
		_copy_tree(source.path_join(directory_name), child_target, reverse_order)


func _copy_file(source: String, target: String) -> void:
	var input := FileAccess.open(source, FileAccess.READ)
	var output := FileAccess.open(target, FileAccess.WRITE)
	output.store_buffer(input.get_buffer(input.get_length()))


func _remove_tree(path: String) -> void:
	for file_name: String in DirAccess.get_files_at(path):
		DirAccess.remove_absolute(path.path_join(file_name))
	for directory_name: String in DirAccess.get_directories_at(path):
		_remove_tree(path.path_join(directory_name))
	DirAccess.remove_absolute(path)
