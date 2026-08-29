extends SceneTree

const Library := preload("res://src/source/L3_外交层/Source库公开接口.gd")
const PublicationProcess := preload("res://src/source/L2_流程层/Source库发布流程.gd")
const Contract := preload("res://src/source/L3_外交层/Source合同公开接口.gd")
const Fixture := preload("res://tests/g4_02/Source合同测试夹具.gd")

const WORLD := "res://tests/fixtures/g4_02/世界包_边境诸侯"

var _failures := 0
var _fixture := Fixture.new()
var _contract := Contract.new()
var _mutating_external := ""
var _mutation_mode := ""


func _initialize() -> void:
	var work_root := _argument("--work-root=")
	if work_root.find("g4_03") < 0:
		_fail("必须提供 task-owned --work-root，且路径包含 g4_03")
		_finish()
		return
	_fixture.reset_directory(work_root)
	_test_copy_and_stage_race(work_root.path_join("staging-race"))
	_test_invalid_and_current_failure(work_root.path_join("failure"))
	_test_missing(work_root.path_join("missing"))
	_test_tamper(work_root.path_join("tamper"))
	_finish()


func _test_copy_and_stage_race(root: String) -> void:
	var copy_failure_external := root.path_join("copy-failure-external")
	_fixture.copy_package(WORLD, copy_failure_external)
	_mutating_external = copy_failure_external
	_mutation_mode = "delete_declared"
	var copy_process := PublicationProcess.new(root.path_join("copy-failure-library"))
	var copy_failure := copy_process.install(copy_failure_external, _load_then_mutate_external)
	_check(not copy_failure.success and String(copy_failure.code) == "staging_copy_failed", "external 在初验后缺文件时 copy fail-loud")
	_check(_current_count(root.path_join("copy-failure-library")) == 0, "copy 中断不进入 current inventory")

	var mismatch_external := root.path_join("mismatch-external")
	_fixture.copy_package(WORLD, mismatch_external)
	_mutating_external = mismatch_external
	_mutation_mode = "change_manifest"
	var mismatch_process := PublicationProcess.new(root.path_join("mismatch-library"))
	var mismatch := mismatch_process.install(mismatch_external, _load_then_mutate_external)
	_check(not mismatch.success and String(mismatch.code) == "staged_fingerprint_mismatch", "初验后 external 内容变化导致 staged fingerprint mismatch")
	_check(_generation_count(root.path_join("mismatch-library"), "world_pack", "world.border_lords") == 0, "fingerprint mismatch 不发布 final generation")
	_mutating_external = ""
	_mutation_mode = ""


func _load_then_mutate_external(path: String) -> Dictionary:
	var result := _contract.load_world_pack(path)
	if result.success and path == _mutating_external:
		if _mutation_mode == "delete_declared":
			DirAccess.remove_absolute(path.path_join("assets/river_gate.svg"))
		elif _mutation_mode == "change_manifest":
			var manifest := _fixture.read_manifest(path)
			manifest.gm_instructions = String(manifest.gm_instructions) + " validation 后发生变化。"
			_fixture.write_manifest(path, manifest)
		_mutating_external = ""
	return result


func _test_invalid_and_current_failure(root: String) -> void:
	var external := root.path_join("external")
	var first := external.path_join("first")
	var second := external.path_join("second")
	var invalid := external.path_join("invalid")
	_fixture.copy_package(WORLD, first)
	_fixture.copy_package(WORLD, invalid)
	_fixture.write_text(invalid.path_join("source.json"), "{not-json")
	var library_root := root.path_join("library")
	var library := Library.new(library_root)
	var rejected := library.install_world_pack(invalid)
	var empty := library.list_current_sources()
	_check(not rejected.success and String(rejected.code) == "malformed_json", "invalid package 在 staging 前由 G4-02 fail-loud")
	_check(empty.success and empty.sources.is_empty(), "invalid package 没有 durable inventory 副作用")

	var initial := library.install_world_pack(first)
	if not initial.success:
		_fail("failure fixture 初代安装失败")
		return
	var old_fingerprint := String(initial.generation.identity.generation_fingerprint)
	_fixture.copy_package(WORLD, second)
	var manifest := _fixture.read_manifest(second)
	manifest.world_instructions = String(manifest.world_instructions) + " failure fixture second generation。"
	_fixture.write_manifest(second, manifest)
	var interrupted := library.install_world_pack(second, PublicationProcess.FAULT_BEFORE_CURRENT_PUBLISH)
	_check(not interrupted.success and String(interrupted.code) == "injected_current_publish_failure", "deterministic fault 在 current commit 前中断")
	var preserved := library.get_current_world("world.border_lords")
	_check(preserved.success and String(preserved.generation.identity.generation_fingerprint) == old_fingerprint, "current publish 失败保留旧 current")
	_check(_generation_count(library_root, "world_pack", "world.border_lords") == 2, "失败后新 generation 仅作为 retained generation 留存")
	var retried := library.install_world_pack(second)
	_check(retried.success, "相同 intent retry 安全收敛")
	if retried.success:
		_check(String(retried.generation.identity.generation_fingerprint) != old_fingerprint, "retry 成功后才切换 current")

	DirAccess.make_dir_recursive_absolute(library_root.path_join("staging/stale"))
	_fixture.write_text(library_root.path_join("staging/stale/source.json"), "{partial")
	var reloaded := Library.new(library_root).list_current_sources()
	_check(reloaded.success and reloaded.sources.size() == 1, "stale staging residue 不进入 inventory")


func _test_missing(root: String) -> void:
	var external := root.path_join("external")
	_fixture.copy_package(WORLD, external)
	var library := Library.new(root.path_join("library"))
	var installed := library.install_world_pack(external)
	if not installed.success:
		_fail("missing fixture 安装失败")
		return
	DirAccess.remove_absolute(String(installed.generation.managed_path).path_join("assets/river_gate.svg"))
	var current := library.get_current_world("world.border_lords")
	var inventory := library.list_current_sources()
	_check(not current.success and String(current.code) == "managed_generation_invalid", "managed declared file missing 时 current fail-loud")
	_check(not inventory.success, "missing current generation 不 fallback 到历史或空 inventory")


func _test_tamper(root: String) -> void:
	var external := root.path_join("external")
	_fixture.copy_package(WORLD, external)
	var library := Library.new(root.path_join("library"))
	var installed := library.install_world_pack(external)
	if not installed.success:
		_fail("tamper fixture 安装失败")
		return
	var managed_asset := String(installed.generation.managed_path).path_join("assets/river_gate.svg")
	_fixture.append_text(managed_asset, "\n<!-- managed tamper -->\n")
	var current := library.get_current_world("world.border_lords")
	var replay := library.install_world_pack(external)
	_check(not current.success and String(current.code) == "managed_generation_invalid", "managed bytes 篡改不信任 fingerprint 目录名")
	_check(not replay.success and String(replay.code) == "managed_generation_invalid", "final 已存在但损坏时拒绝用 external 静默覆盖")


func _generation_count(root: String, asset_type: String, asset_id: String) -> int:
	var path := root.path_join("generations").path_join(asset_type).path_join(asset_id)
	return DirAccess.get_directories_at(path).size() if DirAccess.dir_exists_absolute(path) else 0


func _current_count(root: String) -> int:
	var count := 0
	for asset_type: String in ["world_pack", "character_card"]:
		var path := root.path_join("current").path_join(asset_type)
		if DirAccess.dir_exists_absolute(path):
			count += DirAccess.get_files_at(path).size()
	return count


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-03 FAILURE PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-03 FAILURE FAIL | %s" % label)


func _finish() -> void:
	print("G4-03 FAILURE | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
