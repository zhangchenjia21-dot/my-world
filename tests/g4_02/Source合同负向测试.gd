extends SceneTree

const Contract := preload("res://src/source/L3_外交层/Source合同公开接口.gd")
const Fixture := preload("res://tests/g4_02/Source合同测试夹具.gd")

const WORLD := "res://tests/fixtures/g4_02/世界包_边境诸侯"
const CHARACTER := "res://tests/fixtures/g4_02/角色卡_沈砚"

var _failures := 0
var _contract := Contract.new()
var _fixture := Fixture.new()
var _work_root := ""


func _initialize() -> void:
	_run()


func _run() -> void:
	_work_root = _argument("--work-root=")
	if _work_root.find("g4_02") < 0:
		_fail("必须提供 task-owned --work-root，且路径包含 g4_02")
		_finish()
		return
	_fixture.reset_directory(_work_root)
	_test_malformed_and_identity()
	_test_cardinality_and_boundary()
	_test_path_safety()
	_test_character_boundary()
	_finish()


func _test_malformed_and_identity() -> void:
	var malformed := _copy("malformed", WORLD)
	_fixture.write_text(malformed.path_join("source.json"), "{not-json")
	_expect(_contract.load_world_pack(malformed), "malformed_json", "malformed JSON fail-loud")

	var invalid_encoding := _copy("invalid-encoding", WORLD)
	_fixture.write_bytes(invalid_encoding.path_join("source.json"), PackedByteArray([0x7b, 0x22, 0xff, 0x22, 0x7d]))
	_expect(_contract.load_world_pack(invalid_encoding), "invalid_encoding", "invalid UTF-8 rejected before JSON interpretation")

	var wrong_type := _copy("wrong-type", WORLD)
	var wrong_type_data := _fixture.read_manifest(wrong_type)
	wrong_type_data.asset_type = "character_card"
	_fixture.write_manifest(wrong_type, wrong_type_data)
	_expect(_contract.load_world_pack(wrong_type), "unsupported_asset_type", "wrong asset_type rejected")

	var wrong_schema := _copy("wrong-schema", WORLD)
	var wrong_schema_data := _fixture.read_manifest(wrong_schema)
	wrong_schema_data.schema_version = "world_pack.v9"
	_fixture.write_manifest(wrong_schema, wrong_schema_data)
	_expect(_contract.load_world_pack(wrong_schema), "unsupported_schema", "unsupported schema rejected")

	var missing_identity := _copy("missing-identity", WORLD)
	var missing_identity_data := _fixture.read_manifest(missing_identity)
	missing_identity_data.erase("asset_id")
	_fixture.write_manifest(missing_identity, missing_identity_data)
	_expect(_contract.load_world_pack(missing_identity), "missing_or_invalid_field", "missing identity rejected without minting ID")

	var author_fingerprint := _copy("author-fingerprint", WORLD)
	var author_fingerprint_data := _fixture.read_manifest(author_fingerprint)
	author_fingerprint_data.generation_fingerprint = "author-controlled"
	_fixture.write_manifest(author_fingerprint, author_fingerprint_data)
	_expect(_contract.load_world_pack(author_fingerprint), "unknown_field", "author fingerprint cannot replace program authority")


func _test_cardinality_and_boundary() -> void:
	var empty_lore := _copy("empty-lore", WORLD)
	var empty_lore_data := _fixture.read_manifest(empty_lore)
	empty_lore_data.source_lore = []
	_fixture.write_manifest(empty_lore, empty_lore_data)
	_expect(_contract.load_world_pack(empty_lore), "invalid_cardinality", "World lore bad cardinality rejected")

	var duplicate_lore := _copy("duplicate-lore", WORLD)
	var duplicate_lore_data := _fixture.read_manifest(duplicate_lore)
	duplicate_lore_data.source_lore.append(duplicate_lore_data.source_lore[0].duplicate(true))
	_fixture.write_manifest(duplicate_lore, duplicate_lore_data)
	_expect(_contract.load_world_pack(duplicate_lore), "duplicate_id", "duplicate World lore ID rejected")

	var live_world := _copy("live-world", WORLD)
	var live_world_data := _fixture.read_manifest(live_world)
	live_world_data.current_conversation = []
	_fixture.write_manifest(live_world, live_world_data)
	_expect(_contract.load_world_pack(live_world), "forbidden_source_field", "World Source cannot own current Conversation")

	var nested_live_world := _copy("nested-live-world", WORLD)
	var nested_live_world_data := _fixture.read_manifest(nested_live_world)
	nested_live_world_data.source_material.current_timeline_head = "forbidden-head"
	_fixture.write_manifest(nested_live_world, nested_live_world_data)
	_expect(_contract.load_world_pack(nested_live_world), "forbidden_source_field", "nested source material cannot hide current Timeline truth")


func _test_path_safety() -> void:
	var traversal := _copy("path-traversal", WORLD)
	var traversal_data := _fixture.read_manifest(traversal)
	traversal_data.authored_assets[0].path = "../outside.svg"
	_fixture.write_manifest(traversal, traversal_data)
	_expect(_contract.load_world_pack(traversal), "unsafe_reference", "path traversal rejected before external read")

	var absolute := _copy("absolute-path", WORLD)
	var absolute_data := _fixture.read_manifest(absolute)
	absolute_data.authored_assets[0].path = "C:/outside.svg"
	_fixture.write_manifest(absolute, absolute_data)
	_expect(_contract.load_world_pack(absolute), "unsafe_reference", "absolute Windows path rejected")

	var missing := _copy("missing-reference", WORLD)
	var missing_data := _fixture.read_manifest(missing)
	missing_data.authored_assets[0].path = "assets/missing.svg"
	_fixture.write_manifest(missing, missing_data)
	_expect(_contract.load_world_pack(missing), "missing_reference", "missing declared file rejected")

	var script := _copy("script-reference", WORLD)
	var script_data := _fixture.read_manifest(script)
	script_data.authored_assets[0].path = "assets/unsafe.gd"
	_fixture.write_text(script.path_join("assets/unsafe.gd"), "extends Node\n")
	_fixture.write_manifest(script, script_data)
	_expect(_contract.load_world_pack(script), "unsupported_reference_type", "executable/script-like Source content rejected")


func _test_character_boundary() -> void:
	var live_character := _copy("live-character", CHARACTER)
	var live_character_data := _fixture.read_manifest(live_character)
	live_character_data.current_location = "河门城"
	_fixture.write_manifest(live_character, live_character_data)
	_expect(_contract.load_character_card(live_character), "forbidden_source_field", "Character current location rejected")

	var invalid_eligibility := _copy("invalid-eligibility", CHARACTER)
	var invalid_eligibility_data := _fixture.read_manifest(invalid_eligibility)
	invalid_eligibility_data.player_character_supported = "yes"
	_fixture.write_manifest(invalid_eligibility, invalid_eligibility_data)
	_expect(_contract.load_character_card(invalid_eligibility), "missing_or_invalid_field", "Character eligibility must be bool")

	var missing_portrait := _copy("missing-portrait", CHARACTER)
	var missing_portrait_data := _fixture.read_manifest(missing_portrait)
	missing_portrait_data.portrait.path = "assets/not-there.svg"
	_fixture.write_manifest(missing_portrait, missing_portrait_data)
	_expect(_contract.load_character_card(missing_portrait), "missing_reference", "Character portrait must exist")


func _copy(name: String, source: String) -> String:
	var target := _work_root.path_join(name)
	_fixture.copy_package(source, target)
	return target


func _expect(result: Dictionary, code: String, label: String) -> void:
	_check(not result.success and String(result.get("code", "")) == code, "%s (%s)" % [label, code])


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-02 NEGATIVE PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-02 NEGATIVE FAIL | %s" % label)


func _finish() -> void:
	print("G4-02 NEGATIVE | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
