extends SceneTree

const Composition := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

var _failures := 0
var _fixture := Fixture.new()


func _initialize() -> void:
	var root_path := _argument("--root=")
	if root_path.find("g4_05") < 0:
		_fail("必须提供 task-owned --root")
		return _finish()
	_fixture.reset_directory(root_path)
	var installed: Dictionary = _fixture.install_real_assets(root_path.path_join("source-library"))
	_check(installed.success, "real assets installed for Composition")
	if not installed.success: return _finish()
	var intent := Composition.new(installed.library)
	var inventory: Dictionary = intent.load_current_inventory()
	_check(inventory.success and inventory.worlds.size() == 2 and inventory.characters.size() == 6, "Wizard inventory consumes real managed assets")
	_check(intent.composition_snapshot().world.is_empty() and intent.composition_snapshot().player_character.is_empty(), "list visibility does not implicitly select first row")

	var han_world := _fixture.find_generation(inventory.worlds, "world.han_end.unsettled_realm")
	var ash_world := _fixture.find_generation(inventory.worlds, "world.ashtervia.afterglow")
	var liu_bei := _fixture.find_generation(inventory.characters, "character.han_end.liu_bei")
	var cao_cao := _fixture.find_generation(inventory.characters, "character.han_end.cao_cao")
	var duen := _fixture.find_generation(inventory.characters, "character.ashtervia.duen_stonescar")
	_check(intent.select_world(han_world).success, "explicit click equivalent selects exact Han World")
	_check(intent.select_entry("t0-208-red-cliffs-eve").success, "Entry belongs to selected exact World")
	_check(intent.select_world(ash_world).success and intent.composition_snapshot().entry.is_empty(), "World reselection clears dependent Entry only")
	_check(not intent.select_entry("t0-208-red-cliffs-eve").success, "Entry from old World fails loud")
	_check(intent.select_entry("t0-1287-border-route").success, "new World Entry accepted")
	_check(intent.confirm_expansion_none().success, "Expansion explicit none recorded")
	_check(not intent.select_player(duen).success, "player_character_supported=false rejected")
	_check(intent.select_player(liu_bei).success, "eligible exact Character selected as Player")
	_check(not intent.set_guaranteed_npc(liu_bei, true).success, "same exact Character role overlap rejected")
	_check(intent.set_guaranteed_npc(cao_cao, true).success and intent.set_guaranteed_npc(duen, true).success, "0..N Guaranteed NPC exact generations accepted")
	_check(not intent.set_settings("   ", "Light", "").success, "empty display name rejected")
	_check(not intent.set_settings("诸界边路", "Invalid", "").success, "invalid control mode rejected")
	_check(intent.set_settings("诸界边路", "Light", "从商路的异常魔痕开始。 ").success, "minimal settings accepted with Light and supplement")

	var selected_world_fingerprint := String(intent.composition_snapshot().world.identity.generation_fingerprint)
	var second_external := root_path.path_join("second-world")
	_fixture.copy_package("res://tests/fixtures/g4_02r1/full_fidelity/诸界余辉/埃瑟维亚", second_external)
	var manifest := _fixture.read_json(second_external.path_join("source.json"))
	manifest.gm_instructions = String(manifest.gm_instructions) + " 这是同 stable identity 的后续 current generation。"
	_fixture.write_json(second_external.path_join("source.json"), manifest)
	var second: Dictionary = installed.library.install_world_pack(second_external)
	_check(second.success and String(second.generation.identity.generation_fingerprint) != selected_world_fingerprint, "install Y publishes a newer current generation")
	_check(String(intent.composition_snapshot().world.identity.generation_fingerprint) == selected_world_fingerprint, "Composition remains pinned to selected X without reselection")
	var review: Dictionary = intent.build_compatibility_review()
	_check(review.success and String(review.review.world.identity.generation_fingerprint) == selected_world_fingerprint, "Review exact lookup validates X instead of drifting to Y")
	_check(review.success and review.review.guaranteed_npcs.size() == 2 and review.review.expansions.is_empty(), "Review projects exact NPC set and honest empty Expansion")

	var selected_path: String = String(installed.library.get_exact_world("world.ashtervia.afterglow", selected_world_fingerprint).generation.managed_path)
	var selected_manifest := _fixture.read_json(selected_path.path_join("source.json"))
	selected_manifest.gm_instructions = String(selected_manifest.gm_instructions) + " tampered"
	_fixture.write_json(selected_path.path_join("source.json"), selected_manifest)
	var tampered: Dictionary = intent.build_compatibility_review()
	_check(not tampered.success and String(tampered.code) == "exact_generation_unavailable", "tampered selected exact generation fails loud without current fallback")
	_check(not _contains_sqlite(root_path) and not DirAccess.dir_exists_absolute(root_path.path_join("game-library")), "Composition/Review creates no Game DB or Game Library metadata")
	_finish()


func _contains_sqlite(path: String) -> bool:
	for file_name: String in DirAccess.get_files_at(path):
		if file_name.ends_with(".sqlite"): return true
	for directory_name: String in DirAccess.get_directories_at(path):
		if _contains_sqlite(path.path_join(directory_name)): return true
	return false


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix): return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition: print("G4-05 COMPOSITION PASS | %s" % label)
	else: _fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-05 COMPOSITION FAIL | %s" % label)


func _finish() -> void:
	print("G4-05 COMPOSITION | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
