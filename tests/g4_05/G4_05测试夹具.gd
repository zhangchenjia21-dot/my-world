class_name G405TestFixture
extends RefCounted

const Library := preload("res://src/source/L3_外交层/Source库公开接口.gd")
const PACKAGES := [
	{"type": "world", "path": "res://tests/fixtures/g4_05/历史真实资产转换/汉末三国/天下未定"},
	{"type": "world", "path": "res://tests/fixtures/g4_05/历史真实资产转换/诸界余辉/世界"},
	{"type": "character", "path": "res://tests/fixtures/g4_05/历史真实资产转换/汉末三国/刘备"},
	{"type": "character", "path": "res://tests/fixtures/g4_05/历史真实资产转换/汉末三国/曹操"},
	{"type": "character", "path": "res://tests/fixtures/g4_05/历史真实资产转换/汉末三国/孙权"},
	{"type": "character", "path": "res://tests/fixtures/g4_05/历史真实资产转换/诸界余辉/莉维娅"},
	{"type": "character", "path": "res://tests/fixtures/g4_05/历史真实资产转换/诸界余辉/阿德里安"},
	{"type": "character", "path": "res://tests/fixtures/g4_05/历史真实资产转换/诸界余辉/杜恩"},
]


func reset_directory(path: String) -> void:
	if DirAccess.dir_exists_absolute(path):
		_remove_tree(path)
	DirAccess.make_dir_recursive_absolute(path)


func install_real_assets(library_root: String) -> Dictionary:
	var library := Library.new(library_root)
	var installed: Array = []
	for package: Dictionary in PACKAGES:
		var result: Dictionary = library.install_world_pack(package.path) if package.type == "world" \
			else library.install_character_card(package.path)
		if not result.success:
			return {"success": false, "package": package.path, "failure": result}
		installed.append(result.generation)
	return {"success": true, "library": library, "installed": installed}


func find_generation(generations: Array, asset_id: String) -> RefCounted:
	for generation: RefCounted in generations:
		if String(generation.identity.asset_id) == asset_id:
			return generation
	return null

func copy_package(source_path: String, target_path: String) -> void:
	DirAccess.make_dir_recursive_absolute(target_path)
	for file_name: String in DirAccess.get_files_at(source_path):
		DirAccess.copy_absolute(source_path.path_join(file_name), target_path.path_join(file_name))
	for directory_name: String in DirAccess.get_directories_at(source_path):
		copy_package(source_path.path_join(directory_name), target_path.path_join(directory_name))


func read_json(path: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(path)) as Dictionary


func write_json(path: String, value: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(value, "  ") + "\n")


func _remove_tree(path: String) -> void:
	for file_name: String in DirAccess.get_files_at(path):
		DirAccess.remove_absolute(path.path_join(file_name))
	for directory_name: String in DirAccess.get_directories_at(path):
		_remove_tree(path.path_join(directory_name))
	DirAccess.remove_absolute(path)
