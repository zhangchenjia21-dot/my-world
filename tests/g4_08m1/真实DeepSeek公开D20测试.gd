extends SceneTree

const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Adjudication := preload("res://src/行动判定/L3_外交层/行动判定公开接口.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

const TIMEOUT_MSEC := 600000

var _failures := 0
var _fixture := Fixture.new()
var _root := ""
var _evidence_path := ""
var _library: RefCounted
var _generations: Array = []
var _expansion: RefCounted
var _evidence := {"schema_version": "g4_08m1.real_provider_evidence.v0.1", "routes": []}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	_evidence_path = _argument("--evidence=")
	if _root.find("g4_08m1") < 0 or _evidence_path.is_empty() or OS.get_environment("DEEPSEEK_API_KEY").strip_edges().is_empty():
		return _finish_with_failure("task-owned root/evidence/DEEPSEEK_API_KEY required")
	_fixture.reset_directory(_root)
	var installed := _fixture.install_real_assets(_root.path_join("source-library"))
	_check(installed.success, "real frozen 2 World + 6 Character installed")
	if not installed.success:
		return _finish()
	_library = installed.library
	_generations = installed.installed
	var expansion_install: Dictionary = _library.install_expansion_pack("res://tests/fixtures/g4_08m1/判定与检定_公开d20")
	_check(expansion_install.success, "real Public d20 exact generation installed")
	if not expansion_install.success:
		return _finish()
	_expansion = expansion_install.generation
	await _run_han()
	await _run_afterglow()
	_finish()


func _run_han() -> void:
	var route := await _create_open("han", "world.han_end.unsettled_realm", "t0-208-red-cliffs-eve", "character.han_end.liu_bei")
	if not route.success:
		return
	var runtime: RefCounted = route.runtime
	var risk := await _perform(runtime, "han-risk-real", "我趁夜独自潜入曹军水寨，越过巡哨并偷取中军调令；一旦被发现就会被围捕。我立即执行。")
	var risk_check := _find_check(runtime.world_state, "han-risk-real")
	_check(risk.success and risk_check.success, "H Han high-risk action produces CHECK_REQUIRED and accepted continuation")
	if risk_check.success:
		_check((risk.stages as Array) == ["control", "resolution_narrative"], "H Han CHECK_REQUIRED uses isolated control plus result narrative")
		_check(int(risk_check.check.selected_roll) >= 1 and int(risk_check.check.selected_roll) <= 20, "H Han die face is Program-owned legal d20")
	var before_count := _check_count(runtime.world_state)
	var ordinary := await _perform(runtime, "han-ordinary-real", "我留在安全的军帐内，向身边书记询问案牍上已经写明的今日日期。")
	_check(ordinary.success and (ordinary.stages as Array) == ["control", "no_check_narrative"] and _check_count(runtime.world_state) == before_count, "H Han ordinary action uses decoupled NO_CHECK narrative path")
	var game_id := String(runtime.game_id)
	var exact_check: Dictionary = _find_check(runtime.world_state, "han-risk-real").check.duplicate(true) if risk_check.success else {}
	var accepted_before: Array = runtime.conversation.get_durable_accepted_entries().duplicate(true)
	runtime.close()
	var reopened := Runtime.new()
	var reopen: Dictionary = reopened.open_existing_game(String(route.database_path))
	var reopened_check := _find_check(reopened.world_state, "han-risk-real") if reopen.success else {"success": false}
	_check(reopen.success and String(reopened.game_id) == game_id and reopened_check.success and int(reopened_check.check.selected_roll) == int(exact_check.get("selected_roll", 0)), "H Han close/reopen keeps exact check result")
	_check(reopen.success and reopened.conversation.get_durable_accepted_entries().size() == accepted_before.size(), "H Han resulting Conversation reality survives reopen")
	_evidence.routes.append(_route_evidence("han", route, risk, ordinary, reopened_check.get("check", {}), reopened.conversation.get_durable_accepted_entries()))
	reopened.close()


func _run_afterglow() -> void:
	var route := await _create_open("afterglow", "world.ashtervia.afterglow", "t0-1287-public-works", "character.ashtervia.livia_selan")
	if not route.success:
		return
	var runtime: RefCounted = route.runtime
	var risk := await _perform(runtime, "afterglow-risk-real", "莉维娅独自进入正在失稳的主魔力管线，试图在防护崩溃前手动闭合核心阀门；失败会让她受伤并扩大泄漏。")
	var check := _find_check(runtime.world_state, "afterglow-risk-real")
	_check(risk.success and check.success and (risk.stages as Array) == ["control", "resolution_narrative"], "I Afterglow/Livia uses same real Public d20 vertical")
	_check(not JSON.stringify(runtime.world_state.expansions).contains("汉末"), "I materialized Host capability has no Han-specific rule")
	_evidence.routes.append(_route_evidence("afterglow", route, risk, {}, check.get("check", {}), runtime.conversation.get_durable_accepted_entries()))
	runtime.close()


func _create_open(route: String, world_id: String, entry_id: String, player_id: String) -> Dictionary:
	var case_root := _root.path_join(route)
	var creation := Creation.new(_library)
	creation.select_world(_generation(world_id))
	creation.select_entry(entry_id)
	creation.set_expansion(_expansion, true)
	creation.select_player(_generation(player_id))
	creation.set_settings("G4-08M1 real %s" % route, "Narrative", "")
	var created: Dictionary = FinalCreate.new(_library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games")).create_or_resume("g4-08m1-real-%s" % route, creation.composition_snapshot())
	_check(created.success, "%s production G4-06 create with exact Expansion" % route)
	if not created.success:
		return {"success": false}
	var runtime := Runtime.new()
	var opened: Dictionary = runtime.open_existing_game(String(created.database_path))
	_check(opened.success, "%s existing-only open" % route)
	return {"success": opened.success, "runtime": runtime, "database_path": created.database_path, "game_id": created.game_id, "root_node_id": created.root_node_id}


func _perform(runtime: RefCounted, action_id: String, player_text: String) -> Dictionary:
	var process := Adjudication.new(runtime)
	var stages: Array = []
	process.request_assembled.connect(func(stage: String, _messages: Array) -> void: stages.append(stage))
	root.add_child(process)
	await process_frame
	var started: Dictionary = process.start_action(action_id, player_text)
	if not started.success:
		process.queue_free()
		return {"success": false, "status": started.get("code", "start_failed"), "stages": stages}
	var deadline := Time.get_ticks_msec() + TIMEOUT_MSEC
	while String(process.last_result.get("status", "")) == "streaming" and Time.get_ticks_msec() < deadline:
		await process_frame
	if String(process.last_result.get("status", "")) == "streaming":
		process.cancel()
		_check(false, "%s real Provider timeout" % action_id)
	var result := process.last_result.duplicate(true)
	var adapter: Node = process.provider_adapter
	var metrics := {
		"started_msec": adapter.started_msec, "first_delta_msec": adapter.first_delta_msec,
		"finished_msec": adapter.finished_msec, "delta_count": adapter.delta_count,
		"output_chars": adapter.output_chars,
	}
	print("G4-08M1 REAL TERMINAL | action=%s status=%s stages=%s" % [action_id, String(result.get("status", result.get("code", ""))), JSON.stringify(stages)])
	process.queue_free()
	await process.tree_exited
	return {"success": bool(result.get("success", false)) and String(result.get("status", "")) in ["accepted", "already_accepted"], "status": result.get("status", result.get("code", "")), "stages": stages, "metrics": metrics}


func _route_evidence(route: String, created: Dictionary, risk: Dictionary, ordinary: Dictionary, check: Dictionary, accepted: Array) -> Dictionary:
	return {
		"route": route, "game_id": created.game_id, "root_node_id": created.root_node_id,
		"model": OS.get_environment("MY_WORLD_DEEPSEEK_MODEL") if not OS.get_environment("MY_WORLD_DEEPSEEK_MODEL").is_empty() else "deepseek-v4-pro",
		"risk_stages": risk.get("stages", []), "risk_provider_metrics": risk.get("metrics", {}),
		"ordinary_stages": ordinary.get("stages", []), "ordinary_provider_metrics": ordinary.get("metrics", {}),
		"check_id": check.get("check_id", ""), "dc": check.get("dc", null), "modifier": check.get("modifier", null),
		"stance": check.get("stance", ""), "raw_rolls": check.get("raw_rolls", []), "selected_roll": check.get("selected_roll", null),
		"total": check.get("total", null), "outcome": check.get("outcome", ""), "narrative_accepted": check.get("narrative_accepted", false),
		"accepted_count": accepted.size(),
	}


func _find_check(world_state: Dictionary, action_id: String) -> Dictionary:
	for value: Variant in world_state.get("expansion_runtime", {}).get("public_d20_checks", []):
		if value is Dictionary and String(value.get("action_id", "")) == action_id:
			return {"success": true, "check": value}
	return {"success": false}


func _check_count(world_state: Dictionary) -> int:
	return world_state.get("expansion_runtime", {}).get("public_d20_checks", []).size()


func _generation(asset_id: String) -> RefCounted:
	return _fixture.find_generation(_generations, asset_id)


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-08M1 REAL PASS | " + label)
	else:
		_failures += 1
		push_error("G4-08M1 REAL FAIL | " + label)


func _finish_with_failure(message: String) -> void:
	_check(false, message)
	_finish()


func _finish() -> void:
	_evidence["completed_at_utc"] = Time.get_datetime_string_from_system(true, true)
	_evidence["failure_count"] = _failures
	DirAccess.make_dir_recursive_absolute(_evidence_path.get_base_dir())
	var file := FileAccess.open(_evidence_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(_evidence, "  ", false, true))
		file.close()
	else:
		_failures += 1
	print("G4-08M1 REAL | done failures=%d evidence=%s" % [_failures, _evidence_path])
	quit(0 if _failures == 0 else 1)
