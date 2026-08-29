extends SceneTree

const Contract := preload("res://src/source/L3_外交层/Source合同公开接口.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

var _failures := 0
var _fixture := Fixture.new()


func _initialize() -> void:
	var root_path := _argument("--root=")
	if root_path.find("g4_05") < 0:
		_fail("必须提供 task-owned --root")
		return _finish()
	_fixture.reset_directory(root_path)
	var contract := Contract.new()
	var world_count := 0
	var character_count := 0
	for package: Dictionary in Fixture.PACKAGES:
		var loaded: Dictionary = contract.load_world_pack(package.path) if package.type == "world" else contract.load_character_card(package.path)
		_check(loaded.success, "G4-02 validation：%s" % package.path)
		if loaded.success:
			if package.type == "world": world_count += 1
			else: character_count += 1
	_check(world_count == 2 and character_count == 6, "两套真实资产族形成 2 World + 6 Character")
	var installed: Dictionary = _fixture.install_real_assets(root_path.path_join("source-library"))
	_check(installed.success, "八个 package 通过 G4-03 production install")
	if installed.success:
		var inventory: Dictionary = installed.library.list_current_sources()
		_check(inventory.success and inventory.sources.size() == 8, "Managed inventory 返回八个 current exact generations")
		for generation: RefCounted in inventory.sources:
			var exact: Dictionary = installed.library.get_exact_world(generation.identity.asset_id, generation.identity.generation_fingerprint) \
				if String(generation.identity.asset_type) == "world_pack" \
				else installed.library.get_exact_character(generation.identity.asset_id, generation.identity.generation_fingerprint)
			_check(exact.success, "exact lookup：%s fingerprint=%s" % [generation.display_name, generation.identity.generation_fingerprint])
	_finish()


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix): return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition: print("G4-05 REAL ASSET PASS | %s" % label)
	else: _fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-05 REAL ASSET FAIL | %s" % label)


func _finish() -> void:
	print("G4-05 REAL ASSET | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
