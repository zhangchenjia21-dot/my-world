extends SceneTree

const SourceLibrary := preload("res://src/source/L3_外交层/Source库公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const GameRuntime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Adjudication := preload("res://src/行动判定/L3_外交层/行动判定公开接口.gd")
const StubAdapter := preload("res://tests/g4_07a/首次开场桩适配器.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

class DeterministicRng:
	extends RefCounted
	var values: Array
	var invocation_count := 0
	func _init(faces: Array) -> void:
		values = faces.duplicate()
	func roll_d20() -> int:
		var value := int(values[invocation_count])
		invocation_count += 1
		return value

var _failures := 0
var _fixture := Fixture.new()


func _initialize() -> void:
	call_deferred("_run")


## 每次 invocation 只执行一个 phase；controller 用独立 Godot PID 证明没有对象或静态内存跨越重启边界。
func _run() -> void:
	var phase := _argument("--phase=")
	var case_root := _argument("--case-root=")
	var proof_path := _argument("--proof=")
	var prior_proof_path := _argument("--prior-proof=")
	if not phase in ["interrupt", "resume", "replay"] or case_root.find("g4_08m1") < 0 or proof_path.is_empty():
		_fail("phase/task-owned case-root/proof 参数无效")
		return _finish(proof_path, {})
	if phase == "interrupt":
		await _run_interrupt(case_root, proof_path)
	else:
		await _run_resume_or_replay(phase, prior_proof_path, proof_path)


func _run_interrupt(case_root: String, proof_path: String) -> void:
	_fixture.reset_directory(case_root)
	var installed := _fixture.install_real_assets(case_root.path_join("source-library"))
	_check(installed.success, "Process A installs exact real Source generations")
	if not installed.success:
		return _finish(proof_path, {})
	var library: RefCounted = installed.library
	var expansion: Dictionary = library.install_expansion_pack("res://tests/fixtures/g4_08m1/判定与检定_公开d20")
	_check(expansion.success, "Process A installs exact Public d20 Expansion")
	if not expansion.success:
		return _finish(proof_path, {})
	var creation := Creation.new(library)
	creation.select_world(_fixture.find_generation(installed.installed, "world.han_end.unsettled_realm"))
	creation.select_entry("t0-208-red-cliffs-eve")
	creation.set_expansion(expansion.generation, true)
	creation.select_player(_fixture.find_generation(installed.installed, "character.han_end.liu_bei"))
	creation.set_settings("G4-08M1 process restart", "Light", "")
	var create_root := case_root.path_join("create")
	var created: Dictionary = FinalCreate.new(
		library, create_root.path_join("creation"), create_root.path_join("library"), create_root.path_join("games")
	).create_or_resume("g4-08m1-process-restart", creation.composition_snapshot())
	_check(created.success, "Process A creates one Expansion Game")
	if not created.success:
		return _finish(proof_path, {})
	var runtime := GameRuntime.new()
	_check(runtime.open_existing_game(String(created.database_path)).success, "Process A existing-only opens Game")
	var stub := StubAdapter.new()
	var rng := DeterministicRng.new([2])
	var process := Adjudication.new(runtime, stub, rng)
	root.add_child(process)
	process.start_action("process-risk-1", "我独自潜入敌营偷取军令。")
	stub.simulate_delta(JSON.stringify(_proposal()))
	stub.simulate_completed()
	var check := _find_check(runtime.world_state)
	_check(check.success and rng.invocation_count == 1 and stub.requests.size() == 2, "Process A persists resolution before second Provider acceptance")
	stub.simulate_failed("transport")
	_check(runtime.conversation.get_durable_accepted_entries().is_empty(), "Process A exits with zero accepted turns")
	runtime.close()
	_finish(proof_path, {
		"phase": "interrupt", "pid": OS.get_process_id(), "database_path": created.database_path,
		"game_id": created.game_id, "check": check.get("check", {}), "accepted_count": 0,
	})


func _run_resume_or_replay(phase: String, prior_proof_path: String, proof_path: String) -> void:
	var prior := _read_json(prior_proof_path)
	_check(not prior.is_empty(), "%s reads prior durable proof" % phase)
	if prior.is_empty():
		return _finish(proof_path, {})
	var runtime := GameRuntime.new()
	var opened: Dictionary = runtime.open_existing_game(String(prior.database_path))
	_check(opened.success and String(runtime.game_id) == String(prior.game_id), "%s existing-only opens same Game" % phase)
	var stub := StubAdapter.new()
	var rng := DeterministicRng.new([20])
	var process := Adjudication.new(runtime, stub, rng)
	root.add_child(process)
	var started: Dictionary = process.start_action("process-risk-1", "我独自潜入敌营偷取军令。")
	if phase == "resume":
		_check(started.success and String(started.status) == "streaming" and stub.requests.size() == 1, "Process B resumes at second Provider stage")
		_check(rng.invocation_count == 0, "Process B does not reroll")
		stub.simulate_delta("夜色没有掩护你的脚步，守卫截断退路；既定失败结果生效。")
		stub.simulate_completed()
	else:
		_check(started.success and String(started.status) == "already_accepted", "Process C replay returns accepted result")
		_check(stub.requests.is_empty() and rng.invocation_count == 0, "Process C performs no Provider call or reroll")
	var check := _find_check(runtime.world_state)
	var accepted_count: int = runtime.conversation.get_durable_accepted_entries().size()
	_check(check.success and _same_resolution(check.check, prior.check), "%s preserves exact Proposal/roll/outcome" % phase)
	_check(accepted_count == 1, "%s has exactly one accepted Player action" % phase)
	runtime.close()
	_finish(proof_path, {
		"phase": phase, "pid": OS.get_process_id(), "database_path": prior.database_path,
		"game_id": prior.game_id, "check": check.get("check", {}), "accepted_count": accepted_count,
	})


func _proposal() -> Dictionary:
	return {"decision": "CHECK_REQUIRED", "proposal": {
		"intent": "完成高风险行动", "dc": 20, "modifier": 0, "stance": "normal",
		"modifier_reason": "来自 Game-local 角色事实", "situation_reason": "存在不确定性与代价",
		"success_intent": "行动达成", "failure_stakes": "暴露并承受后果",
	}}


func _find_check(world_state: Dictionary) -> Dictionary:
	for value: Variant in world_state.get("expansion_runtime", {}).get("public_d20_checks", []):
		if value is Dictionary and String(value.get("action_id", "")) == "process-risk-1":
			return {"success": true, "check": value}
	return {"success": false}


func _same_resolution(left: Dictionary, right: Dictionary) -> bool:
	for field: String in ["check_id", "action_id", "intent", "dc", "modifier", "stance", "raw_rolls", "selected_roll", "total", "outcome"]:
		if JSON.stringify(left.get(field)) != JSON.stringify(right.get(field)):
			return false
	return true


func _read_json(path: String) -> Dictionary:
	if path.is_empty() or not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-08M1 PROCESS PASS | " + label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-08M1 PROCESS FAIL | " + label)


func _finish(proof_path: String, proof: Dictionary) -> void:
	if not proof_path.is_empty() and not proof.is_empty():
		var parent_error := DirAccess.make_dir_recursive_absolute(proof_path.get_base_dir())
		if parent_error == OK:
			var file := FileAccess.open(proof_path, FileAccess.WRITE)
			file.store_string(JSON.stringify(proof, "  "))
			file.close()
	print("G4-08M1 PROCESS | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
