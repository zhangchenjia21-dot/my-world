extends SceneTree

const Contract := preload("res://src/source/L3_外交层/Source合同公开接口.gd")
const Library := preload("res://src/source/L3_外交层/Source库公开接口.gd")
const Composition := preload("res://src/建局/L3_外交层/建局公开接口.gd")

const HAN_ROOT := "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国"
const AFTERGLOW_ROOT := "res://tests/fixtures/g4_02r1/full_fidelity/诸界余辉"
const PACKAGES := [
	{"type": "world", "path": HAN_ROOT + "/天下未定", "asset_id": "world.han_end.unsettled_realm"},
	{"type": "world", "path": AFTERGLOW_ROOT + "/埃瑟维亚", "asset_id": "world.ashtervia.afterglow"},
	{"type": "character", "path": HAN_ROOT + "/刘备", "asset_id": "character.han_end.liu_bei"},
	{"type": "character", "path": HAN_ROOT + "/曹操", "asset_id": "character.han_end.cao_cao"},
	{"type": "character", "path": HAN_ROOT + "/孙权", "asset_id": "character.han_end.sun_quan"},
	{"type": "character", "path": AFTERGLOW_ROOT + "/莉维娅", "asset_id": "character.ashtervia.livia_selan"},
	{"type": "character", "path": AFTERGLOW_ROOT + "/阿德里安", "asset_id": "character.ashtervia.adrian_wilk"},
	{"type": "character", "path": AFTERGLOW_ROOT + "/杜恩", "asset_id": "character.ashtervia.duen_stonescar"},
]

var _contract := Contract.new()
var _failures := 0
var _work_root := ""
var _loaded := {}


func _initialize() -> void:
	_work_root = _argument("--work-root=")
	if _work_root.find("g4_02r1") < 0:
		_fail("必须提供 task-owned g4_02r1 work root")
		return _finish()
	_reset_directory(_work_root)
	_test_real_packages()
	_test_world_projection()
	_test_character_projection_and_compatibility()
	_test_fingerprint_visibility()
	_test_library_and_wizard()
	_finish()


func _test_real_packages() -> void:
	for package: Dictionary in PACKAGES:
		var result: Dictionary = _contract.load_world_pack(package.path) if package.type == "world" else _contract.load_character_card(package.path)
		_check(result.success, "full-fidelity package loads unchanged: %s" % package.asset_id)
		if result.success:
			_loaded[package.asset_id] = result.source
	_check(_loaded.size() == 8, "real 2 World + 6 Character all use production loader")
	for asset_id: String in ["character.han_end.liu_bei", "character.han_end.cao_cao", "character.han_end.sun_quan", "character.ashtervia.livia_selan", "character.ashtervia.adrian_wilk", "character.ashtervia.duen_stonescar"]:
		if _loaded.has(asset_id):
			_check(_loaded[asset_id].portrait.is_empty(), "optional portrait remains absent without fabricated bytes: %s" % asset_id)


func _test_world_projection() -> void:
	if not _loaded.has("world.han_end.unsettled_realm") or not _loaded.has("world.ashtervia.afterglow"):
		return
	var han_184 := _contract.project_world_entry(_loaded["world.han_end.unsettled_realm"], "t0-184-yellow-turban")
	_check(han_184.success, "Han 184 exact World projection succeeds")
	if han_184.success:
		var paths := _section_paths(han_184.projection.semantic_sections)
		var content := _section_content(han_184.projection.semantic_sections)
		_check(paths.has("history/through-184.md") and paths.has("entries/184/snapshot.md"), "Han 184 includes exact past and snapshot inventory")
		_check(not paths.has("history/200-to-208.md") and not paths.has("entries/280/snapshot.md"), "Han 184 excludes later Entry inventory")
		_check(content.contains("豪族") and content.contains("军队不是名将卡牌集合"), "Han 184 projection carries real rich section content")
		_check(not content.contains("蜀汉已经灭亡") and not content.contains("晋控制北方与巴蜀"), "Han 184 content excludes later canon markers")
	var afterglow: RefCounted = _loaded["world.ashtervia.afterglow"]
	var cases := {
		"t0-1287-ovista": "entries/ovista/snapshot.md",
		"t0-1287-border-route": "entries/border-route/snapshot.md",
		"t0-1287-public-works": "entries/public-works/snapshot.md",
	}
	for entry_id: String in cases:
		var projection := _contract.project_world_entry(afterglow, entry_id)
		_check(projection.success, "Afterglow exact Entry projection: %s" % entry_id)
		if projection.success:
			var paths := _section_paths(projection.projection.semantic_sections)
			_check(paths.has(cases[entry_id]), "Afterglow projection includes selected snapshot content: %s" % entry_id)
			for other_path: String in cases.values():
				if other_path != cases[entry_id]:
					_check(not paths.has(other_path), "Afterglow projection excludes unselected snapshot: %s" % other_path)


func _test_character_projection_and_compatibility() -> void:
	var han_world := "world.han_end.unsettled_realm"
	# 每个断言都走真实 Entry ID 与 production exact-binding seam，不能用年份运算代替 authored coverage。
	var han_cases := [
		{"name": "刘备", "asset_id": "character.han_end.liu_bei", "entry_id": "t0-220-han-wei-transition", "state": "exact_profile_match", "profile_id": "han-220"},
		{"name": "刘备", "asset_id": "character.han_end.liu_bei", "entry_id": "t0-229-three-states", "state": "temporal_incompatible"},
		{"name": "刘备", "asset_id": "character.han_end.liu_bei", "entry_id": "t0-263-shu-survival-eve", "state": "temporal_incompatible"},
		{"name": "刘备", "asset_id": "character.han_end.liu_bei", "entry_id": "t0-280-wu-survival-eve", "state": "temporal_incompatible"},
		{"name": "曹操", "asset_id": "character.han_end.cao_cao", "entry_id": "t0-214-yizhou-transition", "state": "exact_profile_match", "profile_id": "han-214"},
		{"name": "曹操", "asset_id": "character.han_end.cao_cao", "entry_id": "t0-220-han-wei-transition", "state": "temporal_incompatible"},
		{"name": "曹操", "asset_id": "character.han_end.cao_cao", "entry_id": "t0-229-three-states", "state": "temporal_incompatible"},
		{"name": "曹操", "asset_id": "character.han_end.cao_cao", "entry_id": "t0-263-shu-survival-eve", "state": "temporal_incompatible"},
		{"name": "曹操", "asset_id": "character.han_end.cao_cao", "entry_id": "t0-280-wu-survival-eve", "state": "temporal_incompatible"},
		{"name": "孙权", "asset_id": "character.han_end.sun_quan", "entry_id": "t0-249-gaopingling-aftermath", "state": "exact_profile_match", "profile_id": "han-249"},
		{"name": "孙权", "asset_id": "character.han_end.sun_quan", "entry_id": "t0-263-shu-survival-eve", "state": "temporal_incompatible"},
		{"name": "孙权", "asset_id": "character.han_end.sun_quan", "entry_id": "t0-280-wu-survival-eve", "state": "temporal_incompatible"},
	]
	for case: Dictionary in han_cases:
		if not _loaded.has(case.asset_id):
			continue
		var result := _contract.project_character_t0(_loaded[case.asset_id], han_world, case.entry_id)
		var accepted: bool = bool(result.success) and String(result.compatibility_state) == String(case.state)
		if case.state == "exact_profile_match":
			accepted = accepted and not result.hard_incompatible and String(result.projection.selected_profile.get("profile_id", "")) == case.profile_id
		else:
			accepted = accepted and result.hard_incompatible and result.projection.selected_profile.is_empty()
		_check(accepted, "%s %s -> %s" % [case.name, case.entry_id, case.state])
	var liu_184 := _contract.project_character_t0(_loaded["character.han_end.liu_bei"], han_world, "t0-184-yellow-turban")
	if liu_184.success:
		var paths := _section_paths(liu_184.projection.semantic_sections)
		var content := _section_content(liu_184.projection.semantic_sections)
		_check(paths.has("t0/184/profile.md") and not paths.has("t0/220/profile.md"), "Liu Bei 184 projection includes only exact profile inventory")
		_check(content.contains("约二十三岁") and not content.contains("曹魏建立"), "Liu Bei 184 content excludes later-profile truth")
	for asset_id: String in ["character.ashtervia.livia_selan", "character.ashtervia.adrian_wilk", "character.ashtervia.duen_stonescar"]:
		for entry_id: String in ["t0-1287-ovista", "t0-1287-border-route", "t0-1287-public-works"]:
			var exact := _contract.project_character_t0(_loaded[asset_id], "world.ashtervia.afterglow", entry_id)
			_check(exact.success and exact.compatibility_state == "exact_profile_match", "%s exact 1287 binding accepts %s" % [asset_id, entry_id])
	var cross_world := _contract.project_character_t0(_loaded["character.han_end.liu_bei"], "world.ashtervia.afterglow", "t0-1287-ovista")
	_check(cross_world.success and cross_world.compatibility_state == "no_world_coverage" and not cross_world.hard_incompatible, "cross-world zero coverage remains distinguishable and not hard-blocked")


func _test_fingerprint_visibility() -> void:
	var world_copy := _work_root.path_join("fingerprint-world")
	_copy_tree(HAN_ROOT + "/天下未定", world_copy)
	_append_text(world_copy.path_join("entries/280/snapshot.md"), "\nR2_UNSELECTED_WORLD_MUTATION\n")
	var mutated_world := _contract.load_world_pack(world_copy)
	_check(mutated_world.success and String(mutated_world.source.identity.generation_fingerprint) != String(_loaded["world.han_end.unsettled_realm"].identity.generation_fingerprint), "unselected Entry bytes change generation fingerprint")
	if mutated_world.success:
		var selected := _contract.project_world_entry(mutated_world.source, "t0-184-yellow-turban")
		_check(selected.success and not _section_content(selected.projection.semantic_sections).contains("R2_UNSELECTED_WORLD_MUTATION"), "unselected mutated Entry stays outside selected projection")
	var private_copy := _work_root.path_join("fingerprint-private")
	_copy_tree(AFTERGLOW_ROOT + "/莉维娅", private_copy)
	_append_text(private_copy.path_join("t0/1287/private.md"), "\nR2_PRIVATE_MUTATION\n")
	var mutated_private := _contract.load_character_card(private_copy)
	_check(mutated_private.success and String(mutated_private.source.identity.generation_fingerprint) != String(_loaded["character.ashtervia.livia_selan"].identity.generation_fingerprint), "gm_private bytes change generation fingerprint")
	if mutated_private.success:
		var excluded := _contract.project_character_t0(mutated_private.source, "world.han_end.unsettled_realm", "t0-184-yellow-turban")
		var included := _contract.project_character_t0(mutated_private.source, "world.ashtervia.afterglow", "t0-1287-ovista")
		_check(excluded.success and not _section_content(excluded.projection.semantic_sections).contains("R2_PRIVATE_MUTATION"), "unmatched private profile remains excluded from always-safe-only projection")
		_check(included.success and _has_disclosure(included.projection.semantic_sections, "gm_private"), "included exact profile preserves gm_private disclosure metadata")


func _test_library_and_wizard() -> void:
	var library := Library.new(_work_root.path_join("library"))
	var generations := {}
	for package: Dictionary in PACKAGES:
		var installed: Dictionary = library.install_world_pack(package.path) if package.type == "world" else library.install_character_card(package.path)
		_check(installed.success, "v0.2 managed staged publish: %s" % package.asset_id)
		if installed.success:
			generations[package.asset_id] = installed.generation
	var inventory := library.list_current_sources()
	_check(inventory.success and inventory.sources.size() == 8, "G4-03 current inventory revalidates 2 World + 6 Character")
	if generations.size() != 8:
		return
	var intent := Composition.new(library)
	intent.select_world(generations["world.han_end.unsettled_realm"])
	intent.select_entry("t0-229-three-states")
	intent.confirm_expansion_none()
	intent.select_player(generations["character.han_end.liu_bei"])
	intent.set_settings("闭包覆盖证据", "Light", "")
	var incompatible := intent.build_compatibility_review()
	_check(not incompatible.success and incompatible.code == "character_temporal_incompatible", "G4-05 Review blocks declared-World missing Entry binding")
	intent.reset()
	intent.select_world(generations["world.ashtervia.afterglow"])
	intent.select_entry("t0-1287-ovista")
	intent.confirm_expansion_none()
	intent.select_player(generations["character.han_end.liu_bei"])
	intent.set_settings("跨世界零覆盖证据", "Light", "")
	var zero_coverage := intent.build_compatibility_review()
	_check(zero_coverage.success, "G4-05 Review does not invent same-family restriction for zero coverage")
	var managed_world_path := String(generations["world.han_end.unsettled_realm"].managed_path)
	_append_text(managed_world_path.path_join("entries/280/snapshot.md"), "\nMANAGED_TAMPER\n")
	var tampered := library.get_exact_world("world.han_end.unsettled_realm", String(generations["world.han_end.unsettled_realm"].identity.generation_fingerprint))
	_check(not tampered.success and tampered.code == "managed_generation_invalid", "G4-03 exact revalidation fails loud on rich unselected-file tamper")


func _section_paths(sections: Array) -> Array[String]:
	var paths: Array[String] = []
	for section: Dictionary in sections:
		paths.append(String(section.content_path))
	return paths


func _section_content(sections: Array) -> String:
	var content := ""
	for section: Dictionary in sections:
		content += String(section.content) + "\n"
	return content


func _has_disclosure(sections: Array, disclosure: String) -> bool:
	for section: Dictionary in sections:
		if String(section.disclosure) == disclosure:
			return true
	return false


func _copy_tree(source: String, target: String) -> void:
	DirAccess.make_dir_recursive_absolute(target)
	for file_name: String in DirAccess.get_files_at(source):
		DirAccess.copy_absolute(source.path_join(file_name), target.path_join(file_name))
	for directory_name: String in DirAccess.get_directories_at(source):
		_copy_tree(source.path_join(directory_name), target.path_join(directory_name))


func _append_text(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ_WRITE)
	file.seek_end()
	file.store_string(text)


func _reset_directory(path: String) -> void:
	if DirAccess.dir_exists_absolute(path):
		_remove_tree(path)
	DirAccess.make_dir_recursive_absolute(path)


func _remove_tree(path: String) -> void:
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
		print("G4-02R1M1 REALITY PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-02R1M1 REALITY FAIL | %s" % label)


func _finish() -> void:
	print("G4-02R1M1 REALITY | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
