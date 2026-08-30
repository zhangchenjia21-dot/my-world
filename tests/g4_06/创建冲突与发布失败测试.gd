extends SceneTree

const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const DatabaseSafety := preload("res://src/persistence/L3_外交层/数据库安全公开接口.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")
const LibraryFixture := preload("res://tests/g4_04/游戏库测试夹具.gd")

var _failures := 0
var _fixture := Fixture.new()
var _library_fixture := LibraryFixture.new()


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var root_path := _argument("--root=")
	if root_path.find("g4_06") < 0:
		_fail("必须提供 task-owned --root")
		return _finish()
	_fixture.reset_directory(root_path)
	var installed := _fixture.install_real_assets(root_path.path_join("source-library"))
	_check(installed.success, "failure suite Source installed")
	if not installed.success:
		return _finish()
	var library: RefCounted = installed.library
	var generations: Array = installed.installed
	var composition := _composition(library, generations)
	_prove_wrong_database_identity(root_path.path_join("wrong-db"), library, composition)
	_prove_library_publish_failures(root_path.path_join("publish"), library, composition)
	_prove_writer_conflict(root_path.path_join("writer"), library, composition)
	_prove_distinct_creation_identities(root_path.path_join("distinct"), library, composition)
	_prove_source_tamper_before_side_effect(root_path.path_join("source-tamper"))
	_finish()


func _prove_wrong_database_identity(case_root: String, library: RefCounted, composition: Dictionary) -> void:
	var creator := _creator(library, case_root)
	var interrupted: Dictionary = creator.create_or_resume("creation-wrong-db", composition, FinalCreate.FAULT_AFTER_INTENT)
	_check(not interrupted.success, "wrong-DB case publishes intent before injected stop")
	var intent := _read_json(case_root.path_join("creation/intents/creation-wrong-db.json"))
	var target := case_root.path_join("games").path_join(String(intent.game_id)).path_join("game.sqlite")
	var seeded := _library_fixture.seed_game(target, "another-game", {"foreign": true}, "行动", "回应")
	_check(seeded.success, "task fixture places valid wrong-identity DB at fixed target")
	var retried: Dictionary = _creator(library, case_root).create_or_resume("creation-wrong-db", composition)
	_check(not retried.success and String(retried.code) == "database_identity_conflict", "existing wrong internal identity fails loud")
	_check(FileAccess.file_exists(target), "wrong-identity DB is preserved, never deleted/overwritten")


func _prove_library_publish_failures(case_root: String, library: RefCounted, composition: Dictionary) -> void:
	var record_failure: Dictionary = _creator(library, case_root).create_or_resume("creation-record-failure", composition, FinalCreate.FAULT_BEFORE_LIBRARY_RECORD)
	_check(not record_failure.success and String(record_failure.code) == "injected_record_publish_failure", "Game Library record publication failure is visible")
	var record_retry: Dictionary = _creator(library, case_root).create_or_resume("creation-record-failure", composition)
	_check(record_retry.success, "record publication failure retries forward without deleting valid DB")

	var current_case := case_root.path_join("current")
	var current_failure: Dictionary = _creator(library, current_case).create_or_resume("creation-current-failure", composition, FinalCreate.FAULT_BEFORE_CURRENT)
	_check(not current_failure.success and String(current_failure.code) == "injected_current_publish_failure", "current publication failure is visible")
	var current_retry: Dictionary = _creator(library, current_case).create_or_resume("creation-current-failure", composition)
	_check(current_retry.success, "current publication failure retries forward from verified record")


func _prove_writer_conflict(case_root: String, library: RefCounted, composition: Dictionary) -> void:
	var creator := _creator(library, case_root)
	var interrupted: Dictionary = creator.create_or_resume("creation-writer", composition, FinalCreate.FAULT_AFTER_INTENT)
	var intent := _read_json(case_root.path_join("creation/intents/creation-writer.json"))
	var target := case_root.path_join("games").path_join(String(intent.game_id)).path_join("game.sqlite")
	var owner := DatabaseSafety.new()
	var acquired := owner.acquire_writer(target)
	_check(not interrupted.success and acquired.success, "task probe owns fixed target writer after intent")
	var blocked: Dictionary = _creator(library, case_root).create_or_resume("creation-writer", composition)
	_check(not blocked.success and String(blocked.code) == "already_running", "writer conflict fails loud without DB/Library mutation")
	owner.release_writer()
	var resumed: Dictionary = _creator(library, case_root).create_or_resume("creation-writer", composition)
	_check(resumed.success, "same immutable intent converges after writer release")


func _prove_distinct_creation_identities(case_root: String, library: RefCounted, composition: Dictionary) -> void:
	var first: Dictionary = _creator(library, case_root).create_or_resume("creation-distinct-a", composition)
	var second: Dictionary = _creator(library, case_root).create_or_resume("creation-distinct-b", composition)
	_check(first.success and second.success and String(first.game_id) != String(second.game_id), "identical Composition under two creation identities creates two distinct Games")
	_check(String(first.local_player_id) != String(second.local_player_id), "same Source generation in two Games receives distinct local Character IDs")


func _prove_source_tamper_before_side_effect(case_root: String) -> void:
	var installed := _fixture.install_real_assets(case_root.path_join("source-library"))
	_check(installed.success, "tamper case exact Source installed")
	if not installed.success:
		return
	var library: RefCounted = installed.library
	var generations: Array = installed.installed
	var composition := _composition(library, generations)
	var world := _fixture.find_generation(generations, "world.ashtervia.afterglow")
	var selected_file := String(world.managed_path).path_join("sections/01_world_identity_ownership_and_1287_authority.md")
	var file := FileAccess.open(selected_file, FileAccess.READ_WRITE)
	file.seek_end()
	file.store_string("\nTAMPER\n")
	file = null
	var result: Dictionary = _creator(library, case_root).create_or_resume("creation-source-tamper", composition)
	_check(not result.success and String(result.code) == "exact_generation_unavailable", "selected exact Source tamper fails loud")
	_check(not DirAccess.dir_exists_absolute(case_root.path_join("creation/intents")) and not DirAccess.dir_exists_absolute(case_root.path_join("games")) and not DirAccess.dir_exists_absolute(case_root.path_join("library")), "Source tamper fails before intent/Game DB/Game Library side effects")


func _composition(library: RefCounted, generations: Array) -> Dictionary:
	var creation := Creation.new(library)
	creation.select_world(_fixture.find_generation(generations, "world.ashtervia.afterglow"))
	creation.select_entry("t0-1287-ovista")
	creation.confirm_expansion_none()
	creation.select_player(_fixture.find_generation(generations, "character.ashtervia.livia_selan"))
	creation.set_settings("边界验证", "Light", "")
	return creation.composition_snapshot()


func _creator(library: RefCounted, case_root: String) -> RefCounted:
	return FinalCreate.new(library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games"))


func _read_json(path: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(path)) as Dictionary


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-06 FAILURE PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-06 FAILURE FAIL | %s" % label)


func _finish() -> void:
	print("G4-06 FAILURE | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
