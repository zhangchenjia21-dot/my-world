extends SceneTree

const Library := preload("res://src/source/L3_外交层/Source库公开接口.gd")
const Generation := preload("res://src/source/L3_外交层/Source库代次公开类型.gd")
const Fixture := preload("res://tests/g4_02/Source合同测试夹具.gd")

const WORLD := "res://tests/fixtures/g4_02/世界包_边境诸侯"
const CHARACTER := "res://tests/fixtures/g4_02/角色卡_沈砚"

var _failures := 0
var _fixture := Fixture.new()


func _initialize() -> void:
	_run()


func _run() -> void:
	var work_root := _argument("--work-root=")
	if work_root.find("g4_03") < 0:
		_fail("必须提供 task-owned --work-root，且路径包含 g4_03")
		_finish()
		return
	_fixture.reset_directory(work_root)
	var external := work_root.path_join("external")
	var world_external := external.path_join("world")
	var character_external := external.path_join("character")
	_fixture.copy_package(WORLD, world_external)
	_fixture.copy_package(CHARACTER, character_external)
	var library_root := work_root.path_join("library")
	var library := Library.new(library_root)

	var world := library.install_world_pack(world_external)
	var character := library.install_character_card(character_external)
	_check(world.success and world.generation is Generation, "World 通过 G4-02 L3 contract 发布为 managed generation")
	_check(character.success and character.generation is Generation, "Character 通过 G4-02 L3 contract 发布为 managed generation")
	if not world.success or not character.success:
		_finish()
		return
	var old_world_fingerprint := String(world.generation.identity.generation_fingerprint)
	var character_fingerprint := String(character.generation.identity.generation_fingerprint)
	_check(String(world.generation.managed_path).begins_with(library_root), "公开 generation path 属于 injected managed root")

	var duplicate := library.install_world_pack(world_external)
	_check(duplicate.success and duplicate.already_installed, "duplicate exact install replay-safe")
	_check(_generation_count(library_root, "world_pack", "world.border_lords") == 1, "duplicate 不创建第二份 generation")

	# 成功发布后，外部输入可变或消失都不能改变 managed authority。
	_fixture.append_text(world_external.path_join("assets/river_gate.svg"), "\n<!-- external-only mutation -->\n")
	_remove_tree(character_external)
	var detached_world := library.get_exact_world("world.border_lords", old_world_fingerprint)
	var detached_character := library.get_exact_character("character.shen_yan", character_fingerprint)
	_check(detached_world.success and String(detached_world.generation.identity.generation_fingerprint) == old_world_fingerprint, "external World 修改不改变 managed exact generation")
	_check(detached_character.success, "external Character 删除后 managed generation 仍可读取")

	var second_external := external.path_join("world-second")
	_fixture.copy_package(WORLD, second_external)
	var second_manifest := _fixture.read_manifest(second_external)
	second_manifest.gm_instructions = String(second_manifest.gm_instructions) + " 同 version 的第二代规则。"
	_fixture.write_manifest(second_external, second_manifest)
	_fixture.write_text(second_external.path_join("undeclared-draft.txt"), "不得发布的草稿")
	var second := library.install_world_pack(second_external)
	_check(second.success, "同 stable identity / authored version 的不同 fingerprint 可安装")
	if second.success:
		var second_fingerprint := String(second.generation.identity.generation_fingerprint)
		_check(second_fingerprint != old_world_fingerprint, "content change 形成不同 exact generation")
		_check(_generation_count(library_root, "world_pack", "world.border_lords") == 2, "新旧 generation append-only retained")
		_check(not FileAccess.file_exists(String(second.generation.managed_path).path_join("undeclared-draft.txt")), "只复制 contract-owned content")
		var current := library.get_current_world("world.border_lords")
		var retained := library.get_exact_world("world.border_lords", old_world_fingerprint)
		_check(current.success and String(current.generation.identity.generation_fingerprint) == second_fingerprint, "最近成功提交的 generation 是显式 current")
		_check(retained.success, "旧 generation 仍可 exact lookup")
		_write_expectation(work_root, old_world_fingerprint, second_fingerprint, character_fingerprint)

	DirAccess.make_dir_recursive_absolute(library_root.path_join("staging/stale-interrupted"))
	_fixture.write_text(library_root.path_join("staging/stale-interrupted/source.json"), "{incomplete")
	var fresh_instance := Library.new(library_root)
	var inventory := fresh_instance.list_current_sources()
	_check(inventory.success and inventory.sources.size() == 2, "fresh Library instance 从 current metadata 恢复 World/Character inventory")
	_finish()


func _write_expectation(work_root: String, old_fingerprint: String, current_fingerprint: String, character_fingerprint: String) -> void:
	_fixture.write_text(work_root.path_join("restart-expectation.json"), JSON.stringify({
		"old_world": old_fingerprint,
		"current_world": current_fingerprint,
		"character": character_fingerprint,
	}, "  ") + "\n")


func _generation_count(root: String, asset_type: String, asset_id: String) -> int:
	return DirAccess.get_directories_at(root.path_join("generations").path_join(asset_type).path_join(asset_id)).size()


func _remove_tree(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		return
	for file_name: String in DirAccess.get_files_at(path):
		DirAccess.remove_absolute(path.path_join(file_name))
	for directory_name: String in DirAccess.get_directories_at(path):
		_remove_tree(path.path_join(directory_name))
	DirAccess.remove_absolute(path)


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-03 REALITY PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-03 REALITY FAIL | %s" % label)


func _finish() -> void:
	print("G4-03 REALITY | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
