extends SceneTree

const Contract := preload("res://src/source/L3_外交层/Source合同公开接口.gd")
const WORLD := "res://tests/fixtures/g4_02r1/full_fidelity/诸界余辉/埃瑟维亚"
const CHARACTER := "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/刘备"

var _contract := Contract.new()
var _failures := 0
var _work_root := ""


func _initialize() -> void:
	_work_root = _argument("--work-root=")
	if _work_root.find("g4_02r1") < 0:
		_fail("必须提供 task-owned g4_02r1 work root")
		return _finish()
	_reset_directory(_work_root)
	_test_section_failures()
	_test_profile_and_binding_failures()
	_test_declared_file_failures()
	_finish()


func _test_section_failures() -> void:
	var duplicate := _copy("duplicate-section", WORLD)
	var duplicate_manifest := _read_manifest(duplicate)
	duplicate_manifest.entries[0].semantic_sections[0].section_id = duplicate_manifest.semantic_sections[0].section_id
	_write_manifest(duplicate, duplicate_manifest)
	_expect(_contract.load_world_pack(duplicate), "duplicate_id", "package-wide nested section_id duplicate rejected")

	var disclosure := _copy("invalid-disclosure", WORLD)
	var disclosure_manifest := _read_manifest(disclosure)
	disclosure_manifest.semantic_sections[0].disclosure = "player_public"
	_write_manifest(disclosure, disclosure_manifest)
	_expect(_contract.load_world_pack(disclosure), "invalid_disclosure", "invalid disclosure rejected")

	var unsafe := _copy("unsafe-section", WORLD)
	var unsafe_manifest := _read_manifest(unsafe)
	unsafe_manifest.semantic_sections[0].content_path = "../outside.md"
	_write_manifest(unsafe, unsafe_manifest)
	_expect(_contract.load_world_pack(unsafe), "unsafe_reference", "escaping semantic content_path rejected")

	var closed_type := _copy("open-section-type", WORLD)
	var closed_manifest := _read_manifest(closed_type)
	closed_manifest.semantic_sections[0].section_type = "new_semantic_hint"
	_write_manifest(closed_type, closed_manifest)
	var open_result := _contract.load_world_pack(closed_type)
	_check(open_result.success, "new safe section_type accepted without closed ontology")


func _test_profile_and_binding_failures() -> void:
	var duplicate_profile := _copy("duplicate-profile", CHARACTER)
	var duplicate_profile_manifest := _read_manifest(duplicate_profile)
	duplicate_profile_manifest.t0_profiles[1].profile_id = duplicate_profile_manifest.t0_profiles[0].profile_id
	_write_manifest(duplicate_profile, duplicate_profile_manifest)
	_expect(_contract.load_character_card(duplicate_profile), "duplicate_id", "duplicate profile_id rejected")

	var empty_binding := _copy("empty-binding", CHARACTER)
	var empty_binding_manifest := _read_manifest(empty_binding)
	empty_binding_manifest.t0_profiles[0].bindings[0].entry_id = ""
	_write_manifest(empty_binding, empty_binding_manifest)
	_expect(_contract.load_character_card(empty_binding), "missing_or_invalid_field", "empty binding entry_id rejected")

	var duplicate_binding := _copy("duplicate-binding", CHARACTER)
	var duplicate_binding_manifest := _read_manifest(duplicate_binding)
	duplicate_binding_manifest.t0_profiles[0].bindings.append(duplicate_binding_manifest.t0_profiles[0].bindings[0].duplicate(true))
	_write_manifest(duplicate_binding, duplicate_binding_manifest)
	_expect(_contract.load_character_card(duplicate_binding), "duplicate_binding", "duplicate exact Character binding rejected")

	var live_state := _copy("nested-live-state", CHARACTER)
	var live_state_manifest := _read_manifest(live_state)
	live_state_manifest.t0_profiles[0].current_location = "forbidden"
	_write_manifest(live_state, live_state_manifest)
	_expect(_contract.load_character_card(live_state), "forbidden_source_field", "v0.1 live-state boundary remains recursive for rich profile")


func _test_declared_file_failures() -> void:
	var missing := _copy("missing-section", CHARACTER)
	DirAccess.remove_absolute(missing.path_join("t0/184/profile.md"))
	_expect(_contract.load_character_card(missing), "missing_reference", "declared rich section missing fails loud")

	var invalid_encoding := _copy("invalid-section-encoding", CHARACTER)
	var invalid_file := FileAccess.open(invalid_encoding.path_join("t0/184/profile.md"), FileAccess.WRITE)
	invalid_file.store_buffer(PackedByteArray([0xff, 0xfe, 0xfd]))
	invalid_file = null
	_expect(_contract.load_character_card(invalid_encoding), "invalid_encoding", "declared semantic file invalid UTF-8 fails loud")

	var null_portrait := _copy("null-portrait", CHARACTER)
	var null_portrait_manifest := _read_manifest(null_portrait)
	null_portrait_manifest.portrait = null
	_write_manifest(null_portrait, null_portrait_manifest)
	_expect(_contract.load_character_card(null_portrait), "missing_or_invalid_field", "portrait null rejected; canonical absence is omitted")

	var unsafe_portrait := _copy("unsafe-portrait", CHARACTER)
	var unsafe_portrait_manifest := _read_manifest(unsafe_portrait)
	unsafe_portrait_manifest.portrait = {"path": "../invented.webp", "alt_text": "negative path fixture only"}
	_write_manifest(unsafe_portrait, unsafe_portrait_manifest)
	_expect(_contract.load_character_card(unsafe_portrait), "unsafe_reference", "declared optional portrait path escape rejected without placeholder bytes")


func _copy(name: String, source: String) -> String:
	var target := _work_root.path_join(name)
	_copy_tree(source, target)
	return target


func _copy_tree(source: String, target: String) -> void:
	DirAccess.make_dir_recursive_absolute(target)
	for file_name: String in DirAccess.get_files_at(source):
		DirAccess.copy_absolute(source.path_join(file_name), target.path_join(file_name))
	for directory_name: String in DirAccess.get_directories_at(source):
		_copy_tree(source.path_join(directory_name), target.path_join(directory_name))


func _read_manifest(root: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(root.path_join("source.json"))) as Dictionary


func _write_manifest(root: String, manifest: Dictionary) -> void:
	var file := FileAccess.open(root.path_join("source.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "  ") + "\n")


func _expect(result: Dictionary, code: String, label: String) -> void:
	_check(not result.success and String(result.get("code", "")) == code, "%s (%s)" % [label, code])


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
		print("G4-02R1M1 NEGATIVE PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-02R1M1 NEGATIVE FAIL | %s" % label)


func _finish() -> void:
	print("G4-02R1M1 NEGATIVE | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
