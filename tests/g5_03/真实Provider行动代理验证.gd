extends SceneTree

## G5-03M1 真实 selected-Provider 多角色行动代理验证 —— task-owned root 持久化；
## 证据只记录 profile、hash、计数与已提交 action，不保存完整请求/响应/reasoning/credential。
## 上限：1 次组合语义-selection 请求 + 至多 2 次 selected actor execution 请求。

const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Opening := preload("res://src/首次开场/L3_外交层/首次开场公开接口.gd")
const WorldTurn := preload("res://src/世界回合/L3_外交层/世界回合公开接口.gd")
const WorldTurnContext := preload("res://src/世界回合/L3_外交层/世界回合上下文公开接口.gd")
const AgencyCycle := preload("res://src/世界回合/L3_外交层/行动代理循环公开接口.gd")
const ProviderAdapter := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")
const ModelSettings := preload("res://src/运行时设置/L3_外交层/模型运行时设置公开接口.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")
const StubAdapter := preload("res://tests/g4_07a/首次开场桩适配器.gd")

var _failures := 0
var _task_root := ""
var _evidence_path := ""
var _fixture := Fixture.new()
var _runtime: RefCounted
var _opening: Node
var _worker: Node
var _cycle: Node
var _profile: Dictionary = {}
var _result: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_task_root = _argument("--root=")
	_evidence_path = _argument("--evidence=")
	if _task_root.find("g503") < 0 or _evidence_path.is_empty():
		return _finish_with_failure("必须提供 task-owned g503 root/evidence")
	_fixture.reset_directory(_task_root)
	var installed := _fixture.install_real_assets(_task_root.path_join("source-library"))
	_check(installed.success, "frozen real Source assets install into task-owned library")
	if not installed.success:
		return _finish()
	var profile_result := ModelSettings.new().request_snapshot()
	_check(profile_result.success, "current selected runtime profile resolves")
	if not profile_result.success:
		return _finish()
	_profile = _safe_profile(profile_result.request_profile)
	var credential_env := String((profile_result.request_profile as Dictionary).credential_env)
	_check(not OS.get_environment(credential_env).strip_edges().is_empty(), "selected Provider credential is available")
	if OS.get_environment(credential_env).strip_edges().is_empty():
		return _finish()

	var library: RefCounted = installed.library
	var generations: Array = installed.installed
	var creation := Creation.new(library)
	creation.select_world(_fixture.find_generation(generations, "world.han_end.unsettled_realm"))
	creation.select_entry("t0-208-red-cliffs-eve")
	creation.confirm_expansion_none()
	creation.select_player(_fixture.find_generation(generations, "character.han_end.liu_bei"))
	creation.set_guaranteed_npc(_fixture.find_generation(generations, "character.han_end.sun_quan"), true)
	creation.set_guaranteed_npc(_fixture.find_generation(generations, "character.han_end.cao_cao"), true)
	creation.set_settings("G5-03M1 真实行动代理", "Narrative", "从赤壁前夕刘备军营的现实压力自然开始。")
	var created := FinalCreate.new(library, _task_root.path_join("creation"), _task_root.path_join("library"), _task_root.path_join("games")).create_or_resume("g5-03-real-han", creation.composition_snapshot())
	_check(created.success, "production G4-06 creates exact task-owned Game")
	if not created.success:
		return _finish()
	_runtime = Runtime.new()
	_check(_runtime.open_existing_game(String(created.database_path)).success, "created Game opens existing-only")
	if not _runtime.is_ready():
		return _finish()
	_opening = Opening.new(_runtime, StubAdapter.new())
	root.add_child(_opening)
	await process_frame
	_opening.start_first_opening()
	_opening.provider_adapter.simulate_delta("江夏军帐外雨声未歇，案上的军报仍等待刘备裁决。")
	_opening.provider_adapter.simulate_completed()
	await process_frame
	_worker = WorldTurn.new(_runtime)
	root.add_child(_worker)
	await process_frame

	# 一次真实普通行动：可能触发多 actor agency。
	var action := "我当众命孙权使者连夜回江东核实水军调动，并命曹操前军加紧控制江面渡口。"
	var turn_result := await _play_real_turn(action)
	if not turn_result.success:
		_result = turn_result
		return _finish()
	_result = turn_result.duplicate(true)
	var candidates: Array = turn_result.get("agency_candidates", [])
	_check(not candidates.is_empty(), "selector returns at least one valid stable NPC candidate")
	if candidates.is_empty():
		return _finish()
	_result["agency_candidates"] = candidates.duplicate(true)
	_result["candidate_count"] = candidates.size()
	# 启动 Agency Cycle（bounded：至多 2 个 actor execution）。
	var selected: Array = candidates.slice(0, min(2, candidates.size()))
	_cycle = AgencyCycle.new(_runtime)
	root.add_child(_cycle)
	await process_frame
	var started: Dictionary = _cycle.start_cycle(int(turn_result.source_turn_index), String(turn_result.source_gm_sha256), String(_runtime.active_head_id), selected)
	_check(started.success and int(started.actor_count) == selected.size(), "agency cycle starts selected actor requests")
	_result["selected_actor_count"] = selected.size()
	# 等待 actor 完成（bounded：至多 2 个）。
	var finished := await _wait_for(func() -> bool: return _cycle == null or _cycle.cycle_closed, 420.0)
	_check(finished, "agency cycle reaches terminal state")
	_result["committed_actor_count"] = _cycle.committed_actors.size() if _cycle != null else 0
	_result["cycle_status"] = String(_cycle.last_result.get("status", "")) if _cycle != null and _cycle.has("last_result") else ""
	# 后续 Context 含 independent actor actions。
	_runtime.conversation.begin_turn("我核对刚才已经生效的安排。")
	var continuation: Dictionary = _opening.assemble_continuation_messages()
	_runtime.conversation.cancel_generation()
	var projected_text := JSON.stringify(continuation.get("messages", []))
	_result["context_contains_agency"] = projected_text.contains("Independent Actor Actions")
	_check(continuation.success, "later Provider request assembles with agency boundary")
	_finish()


func _play_real_turn(action: String) -> Dictionary:
	var adapter := ProviderAdapter.new()
	root.add_child(adapter)
	await process_frame
	var terminal := false
	var accepted_result: Dictionary = {}
	adapter.text_delta.connect(func(text: String) -> void: _runtime.conversation.append_delta(text))
	adapter.completed.connect(func() -> void:
		accepted_result = _runtime.complete_active_generation_durably()
		terminal = true
	)
	adapter.cancelled.connect(func() -> void:
		_runtime.conversation.cancel_generation()
		accepted_result = {"success": false, "status": "cancelled"}
		terminal = true
	)
	adapter.failed.connect(func(code: String, _message: String) -> void:
		_runtime.conversation.fail_generation(code)
		accepted_result = {"success": false, "status": code}
		terminal = true
	)
	_runtime.conversation.begin_turn(action)
	var assembled: Dictionary = _opening.assemble_continuation_messages()
	if not assembled.success:
		adapter.queue_free()
		return {"success": false, "status": String(assembled.status)}
	var start_error: Error = adapter.start_stream(assembled.messages)
	if start_error != OK and not terminal:
		_runtime.conversation.fail_generation("start_failure")
		adapter.queue_free()
		return {"success": false, "status": "start_failure"}
	var narrative_finished := await _wait_for(func() -> bool: return terminal, 420.0)
	if not narrative_finished or not bool(accepted_result.get("success", false)):
		if adapter.is_busy():
			adapter.cancel()
		adapter.queue_free()
		return {"success": false, "status": "narrative_timeout" if not narrative_finished else String(accepted_result.get("status", "narrative_failure"))}
	var accepted: Array = _runtime.conversation.get_durable_accepted_entries()
	var gm_text := String((accepted[-1] as Dictionary).gm_text)
	var semantic_finished := await _wait_for(func() -> bool:
		var snapshot: Dictionary = _worker.status_snapshot()
		return int(snapshot.analysis_attempt_count) > 0 and not bool(snapshot.busy) and int(snapshot.queued_count) == 0 and String((snapshot.last_result as Dictionary).status) != "idle",
		420.0)
	var semantic: Dictionary = _worker.last_result.duplicate(true)
	adapter.queue_free()
	return {
		"success": narrative_finished and bool(accepted_result.get("success", false)) and semantic_finished,
		"action_sha256": action.sha256_text(),
		"narrative_response_sha256": gm_text.sha256_text(),
		"narrative_response_chars": gm_text.length(),
		"semantic_status": String(semantic.get("status", "")),
		"semantic_change_count": int(semantic.get("change_count", 0)),
		"knowledge_count": int(semantic.get("knowledge_count", 0)),
		"agency_candidates": (semantic.get("agency_candidates", []) as Array).duplicate(true),
		"source_turn_index": int(semantic.get("source_turn_index", -1)),
		"source_gm_sha256": String(semantic.get("source_gm_sha256", "")),
	}


func _safe_profile(profile: Dictionary) -> Dictionary:
	return {
		"profile_id": String(profile.profile_id),
		"provider_id": String(profile.provider_id),
		"model_id": String(profile.model_id),
		"reasoning_effective": profile.reasoning_effective,
	}


func _wait_for(condition: Callable, timeout_sec: float) -> bool:
	var deadline := Time.get_ticks_msec() + int(timeout_sec * 1000.0)
	while Time.get_ticks_msec() < deadline:
		if condition.call():
			return true
		await process_frame
	return condition.call()


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G5-03 REAL PASS | %s" % label)
	else:
		_failures += 1
		push_error("G5-03 REAL FAIL | %s" % label)


func _write_evidence() -> void:
	var evidence := {
		"task": "G5-03M1",
		"generated_at": Time.get_datetime_string_from_system(true),
		"failures": _failures,
		"effective_profile": _profile,
		"result": _result,
	}
	var file := FileAccess.open(_evidence_path, FileAccess.WRITE)
	if file == null:
		_failures += 1
		return
	file.store_string(JSON.stringify(evidence, "  ") + "\n")
	file.close()


func _finish_with_failure(message: String) -> void:
	_check(false, message)
	_finish()


func _finish() -> void:
	_write_evidence()
	print("G5-03 REAL | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
