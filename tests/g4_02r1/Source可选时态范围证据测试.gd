extends SceneTree

const Contract := preload("res://src/source/L3_外交层/Source合同公开接口.gd")
const CHARACTER_ROOT := "res://tests/fixtures/g4_02r1/ir01_optional_temporal/非时态角色"
const WORLD_ROOT := "res://tests/fixtures/g4_02r1/ir01_optional_temporal/非时态世界"

var _contract := Contract.new()
var _failures := 0


func _initialize() -> void:
	_test_non_temporal_character()
	_test_non_temporal_world()
	_finish()


func _test_non_temporal_character() -> void:
	var manifest := _read_manifest(CHARACTER_ROOT)
	_check(not manifest.has("t0_profiles"), "non-temporal Character manifest omits t0_profiles instead of creating a fake profile")
	_check(not _has_global_mode(manifest), "non-temporal Character introduces no historical/temporal global mode")
	var loaded := _contract.load_character_card(CHARACTER_ROOT)
	_check(loaded.success, "non-temporal character_card.v0.2 loads through production contract")
	if not loaded.success:
		return
	_check(loaded.source.t0_profiles.is_empty(), "production loader preserves absence as zero profiles")
	_check(loaded.source.semantic_sections.size() == 2, "complete rich Character semantics remain top-level")
	var projected := _contract.project_character_t0(loaded.source, "world.ir01.tidal_archipelago", "opening-harbor-market")
	_check(projected.success and projected.compatibility_state == "no_world_coverage" and not projected.hard_incompatible, "profile-free Character projects as no_world_coverage / always-safe-only")
	if projected.success:
		_check(projected.projection.selected_profile.is_empty(), "profile-free Character projection creates no fake selected profile")
		var content := _section_content(projected.projection.semantic_sections)
		_check(content.contains("IR01_NON_TEMPORAL_CHARACTER_TOP_LEVEL") and content.contains("IR01_NON_TEMPORAL_CHARACTER_COMPLETE_RICH_SEMANTICS"), "profile-free Character projection preserves all rich top-level semantics")


func _test_non_temporal_world() -> void:
	var manifest := _read_manifest(WORLD_ROOT)
	_check(not _has_global_mode(manifest), "non-temporal World introduces no historical/temporal global mode")
	var entries: Array = manifest.get("entries", [])
	_check(entries.size() == 2 and entries[0].semantic_sections.is_empty() and entries[1].semantic_sections.is_empty(), "scenario Entries require no artificial temporal section matrix")
	var loaded := _contract.load_world_pack(WORLD_ROOT)
	_check(loaded.success, "non-temporal world_pack.v0.2 loads through production contract")
	if not loaded.success:
		return
	for entry_id: String in ["opening-harbor-market", "opening-outer-lighthouse"]:
		var projected := _contract.project_world_entry(loaded.source, entry_id)
		_check(projected.success and String(projected.projection.selected_entry.entry_id) == entry_id, "scenario Entry exact selection works: %s" % entry_id)
		if projected.success:
			_check(projected.projection.semantic_sections.size() == 1 and _section_content(projected.projection.semantic_sections).contains("IR01_NON_TEMPORAL_WORLD_TOP_LEVEL"), "scenario Entry keeps complete top-level World semantics without temporal partition: %s" % entry_id)


func _read_manifest(root_path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(root_path.path_join("source.json")))
	return parsed if parsed is Dictionary else {}


func _has_global_mode(manifest: Dictionary) -> bool:
	for field: String in ["historical", "temporal_mode", "requires_quarantine", "family_mode"]:
		if manifest.has(field):
			return true
	return false


func _section_content(sections: Array) -> String:
	var content := ""
	for section: Dictionary in sections:
		content += String(section.content) + "\n"
	return content


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-02R1M1-IR01 PASS | %s" % label)
	else:
		_failures += 1
		push_error("G4-02R1M1-IR01 FAIL | %s" % label)


func _finish() -> void:
	print("G4-02R1M1-IR01 | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
