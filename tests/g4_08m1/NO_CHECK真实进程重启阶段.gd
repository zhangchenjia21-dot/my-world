extends SceneTree

const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const GameRuntime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Adjudication := preload("res://src/行动判定/L3_外交层/行动判定公开接口.gd")
const StubAdapter := preload("res://tests/g4_07a/首次开场桩适配器.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")


class CountingRng:
	extends RefCounted
	var invocation_count := 0
	func roll_d20() -> int:
		invocation_count += 1
		return 20


var _failures := 0
var _fixture := Fixture.new()


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var phase := _argument("--phase=")
	var case_root := _argument("--case-root=")
	var proof_path := _argument("--proof=")
	var prior_path := _argument("--prior-proof=")
	if not phase in ["accept", "replay"] or case_root.find("g4_08m1") < 0 or proof_path.is_empty():
		_fail("phase/task-owned paths invalid")
		return _finish(proof_path, {})
	if phase == "accept":
		await _accept(case_root, proof_path)
	else:
		await _replay(prior_path, proof_path)


func _accept(case_root: String, proof_path: String) -> void:
	_fixture.reset_directory(case_root)
	var installed: Dictionary = _fixture.install_real_assets(case_root.path_join("source-library"))
	_check(installed.success, "Process A installs frozen real Source")
	if not installed.success:
		return _finish(proof_path, {})
	var expansion: Dictionary = installed.library.install_expansion_pack("res://tests/fixtures/g4_08m1/判定与检定_公开d20")
	_check(expansion.success, "Process A installs exact Public d20")
	var creation := Creation.new(installed.library)
	creation.select_world(_fixture.find_generation(installed.installed, "world.han_end.unsettled_realm"))
	creation.select_entry("t0-208-red-cliffs-eve")
	creation.set_expansion(expansion.generation, true)
	creation.select_player(_fixture.find_generation(installed.installed, "character.han_end.liu_bei"))
	creation.set_settings("G4-08M1C01 process", "Light", "")
	var create_root := case_root.path_join("create")
	var created: Dictionary = FinalCreate.new(
		installed.library, create_root.path_join("creation"), create_root.path_join("library"), create_root.path_join("games")
	).create_or_resume("g4-08m1c01-process", creation.composition_snapshot())
	_check(created.success, "Process A creates one Expansion Game")
	var runtime := GameRuntime.new()
	_check(runtime.open_existing_game(String(created.database_path)).success, "Process A opens exact Game")
	var stub := StubAdapter.new()
	var rng := CountingRng.new()
	var process := Adjudication.new(runtime, stub, rng)
	root.add_child(process)
	process.start_action("no-check-process", "我读取军报页首已经写明的日期。")
	stub.simulate_delta(JSON.stringify({"decision": "NO_CHECK", "reason": "事实已经写明"}) + "\n你展开军报，页首日期清晰可见。")
	stub.simulate_completed()
	var marker := _find_marker(runtime.world_state)
	_check(marker.success and marker.resolution.narrative_accepted, "Process A publishes accepted NO_CHECK marker")
	_check(stub.requests.size() == 1 and rng.invocation_count == 0 and runtime.conversation.get_durable_accepted_entries().size() == 1, "Process A uses one Provider, zero RNG, one Conversation")
	runtime.close()
	_finish(proof_path, {
		"phase": "accept", "pid": OS.get_process_id(), "database_path": created.database_path,
		"game_id": created.game_id, "resolution_id": marker.get("resolution", {}).get("resolution_id", ""), "accepted_count": 1,
	})


func _replay(prior_path: String, proof_path: String) -> void:
	var prior := _read_json(prior_path)
	_check(not prior.is_empty(), "Process B reads Process A proof")
	var runtime := GameRuntime.new()
	_check(runtime.open_existing_game(String(prior.database_path)).success and String(runtime.game_id) == String(prior.game_id), "Process B opens same existing Game")
	var stub := StubAdapter.new()
	var rng := CountingRng.new()
	var process := Adjudication.new(runtime, stub, rng)
	root.add_child(process)
	var replayed: Dictionary = process.start_action("no-check-process", "我读取军报页首已经写明的日期。")
	var marker := _find_marker(runtime.world_state)
	_check(replayed.success and String(replayed.status) == "already_accepted", "Process B returns already_accepted")
	_check(stub.requests.is_empty() and rng.invocation_count == 0, "Process B uses zero Provider and zero RNG")
	_check(runtime.conversation.get_durable_accepted_entries().size() == 1, "Process B keeps exactly one Conversation turn")
	_check(marker.success and String(marker.resolution.resolution_id) == String(prior.resolution_id), "Process B preserves exact replay identity")
	runtime.close()
	_finish(proof_path, {
		"phase": "replay", "pid": OS.get_process_id(), "database_path": prior.database_path,
		"game_id": prior.game_id, "resolution_id": prior.resolution_id, "accepted_count": 1,
	})


func _find_marker(world_state: Dictionary) -> Dictionary:
	for value: Variant in world_state.get("expansion_runtime", {}).get("public_d20_no_check_actions", []):
		if value is Dictionary and String(value.get("action_id", "")) == "no-check-process":
			return {"success": true, "resolution": value}
	return {"success": false, "resolution": {}}


func _read_json(path: String) -> Dictionary:
	if path.is_empty() or not FileAccess.file_exists(path):
		return {}
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-08M1C01 PROCESS PASS | " + label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-08M1C01 PROCESS FAIL | " + label)


func _finish(proof_path: String, proof: Dictionary) -> void:
	if not proof_path.is_empty() and not proof.is_empty():
		DirAccess.make_dir_recursive_absolute(proof_path.get_base_dir())
		var file := FileAccess.open(proof_path, FileAccess.WRITE)
		file.store_string(JSON.stringify(proof, "  "))
		file.close()
	print("G4-08M1C01 PROCESS | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
