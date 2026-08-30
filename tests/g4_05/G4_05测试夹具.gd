class_name G405TestFixture
extends RefCounted

const Library := preload("res://src/source/L3_外交层/Source库公开接口.gd")
## 主现实路径使用冻结的 v0.2 full-fidelity Source；旧的 v0.1 转换包仅由历史回归测试显式引用。
const PACKAGES := [
	{"type": "world", "path": "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定"},
	{"type": "world", "path": "res://tests/fixtures/g4_02r1/full_fidelity/诸界余辉/埃瑟维亚"},
	{"type": "character", "path": "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/刘备"},
	{"type": "character", "path": "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/曹操"},
	{"type": "character", "path": "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/孙权"},
	{"type": "character", "path": "res://tests/fixtures/g4_02r1/full_fidelity/诸界余辉/莉维娅"},
	{"type": "character", "path": "res://tests/fixtures/g4_02r1/full_fidelity/诸界余辉/阿德里安"},
	{"type": "character", "path": "res://tests/fixtures/g4_02r1/full_fidelity/诸界余辉/杜恩"},
]

## IR01 任务拥有的非时态证据包：用于证明场景型 Entry 不被套上历史时间限制。
const IR01_NON_TEMPORAL_PACKAGES := [
	{"type": "world", "path": "res://tests/fixtures/g4_02r1/ir01_optional_temporal/非时态世界"},
	{"type": "character", "path": "res://tests/fixtures/g4_02r1/ir01_optional_temporal/非时态角色"},
]


func reset_directory(path: String) -> void:
	if DirAccess.dir_exists_absolute(path):
		_remove_tree(path)
	DirAccess.make_dir_recursive_absolute(path)


func install_real_assets(library_root: String) -> Dictionary:
	return install_packages(library_root, PACKAGES)


func install_packages(library_root: String, packages: Array) -> Dictionary:
	var library := Library.new(library_root)
	var installed: Array = []
	for package: Dictionary in packages:
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
