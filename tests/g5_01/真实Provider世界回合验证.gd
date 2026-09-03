extends SceneTree

## G5-01M1 真实纵切仅持久化在 task-owned root；证据只记录 profile、hash、计数与
## 已提交 consequence，不保存完整请求、完整 Narrative response、reasoning 或 credential。

const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Opening := preload("res://src/首次开场/L3_外交层/首次开场公开接口.gd")
const WorldTurn := preload("res://src/世界回合/L3_外交层/世界回合公开接口.gd")
const ProviderAdapter := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")
const ModelSettings := preload("res://src/运行时设置/L3_外交层/模型运行时设置公开接口.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")
const StubAdapter := preload("res://tests/g4_07a/首次开场桩适配器.gd")

const ACTIONS := [
	"我当众任命糜竺负责整顿军粮，并命书记官立即把任命与职责写入军令册，当场生效。",
	"我命工匠当场修复营门外被雨水冲坏的木桥，并亲自验收，直到木桥重新恢复通行。",
]

var _failures := 0
var _task_root := ""
var _evidence_path := ""
var _fixture := Fixture.new()
var _runtime: RefCounted
var _opening: Node
var _worker: Node
var _profile: Dictionary = {}
var _narrative_results: Array = []
var _final_world_turn_proof: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_task_root = _argument("--root=")
	_evidence_path = _argument("--evidence=")
	if _task_root.find("g501") < 0 or _evidence_path.is_empty():
		return _finish_with_failure("必须提供 task-owned g501 root/evidence")
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
	creation.set_settings("G5-01M1 真实语义物化", "Narrative", "从赤壁前夕刘备军营的现实压力自然开始。")
	var created := FinalCreate.new(library, _task_root.path_join("creation"), _task_root.path_join("library"), _task_root.path_join("games")).create_or_resume("g5-01-real-han", creation.composition_snapshot())
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
	_check(_runtime.conversation.get_durable_accepted_entries().size() == 1, "task-owned GM-only Opening is durable before ordinary action")
	_worker = WorldTurn.new(_runtime)
	root.add_child(_worker)
	await process_frame

	var committed := false
	for action: String in ACTIONS:
		var result := await _play_real_turn(action)
		_narrative_results.append(result)
		if not result.success:
			break
		if String(result.semantic_status) == "committed":
			committed = true
			break
		if String(result.semantic_status) != "no_changes":
			break
	_check(committed, "real selected Provider yields at least one atomic materialized consequence")
	if not committed:
		return _finish()

	var before_close := _world_turn_proof(_runtime)
	_runtime.conversation.begin_turn("我核对刚才已经生效的安排。")
	var continuation: Dictionary = _opening.assemble_continuation_messages()
	_runtime.conversation.cancel_generation()
	var projected_text := JSON.stringify(continuation.get("messages", []))
	var changes := before_close.changes as Array
	var change_visible := not changes.is_empty() and projected_text.contains(String(changes[0]))
	_check(continuation.success and change_visible, "later Provider request contains matching committed consequence")
	var database_path := String(_runtime.database_path)
	var game_id := String(_runtime.game_id)
	_worker.shutdown()
	_worker.queue_free()
	_opening.queue_free()
	_runtime.close()
	await process_frame

	var reopened := Runtime.new()
	_check(reopened.open_existing_game(database_path).success, "close/reopen restores exact task-owned Game")
	var after_reopen := _world_turn_proof(reopened)
	_check(String(reopened.game_id) == game_id and after_reopen == before_close, "reopen restores same Conversation-linked World Turn record")
	_final_world_turn_proof = after_reopen.duplicate(true)
	var reopen_opening := Opening.new(reopened, StubAdapter.new())
	root.add_child(reopen_opening)
	reopened.conversation.begin_turn("重开后继续核对已生效的安排。")
	var reopened_context := reopen_opening.assemble_continuation_messages()
	reopened.conversation.cancel_generation()
	_check(reopened_context.success and JSON.stringify(reopened_context.messages).contains(String(changes[0])), "reopen later request still projects matching committed consequence")
	reopen_opening.queue_free()
	reopened.close()
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
	var request_serialized := JSON.stringify(assembled.messages)
	var started := Time.get_ticks_msec()
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
	_check(narrative_finished and accepted_result.success, "real free-form Narrative accepts durably before semantic outcome")
	_check(semantic_finished, "one independent semantic analysis request reaches a terminal result")
	return {
		"success": narrative_finished and bool(accepted_result.get("success", false)) and semantic_finished,
		"action_sha256": action.sha256_text(),
		"narrative_request_sha256": request_serialized.sha256_text(),
		"narrative_response_sha256": gm_text.sha256_text(),
		"narrative_response_chars": gm_text.length(),
		"semantic_status": String(semantic.get("status", "")),
		"semantic_change_count": int(semantic.get("change_count", 0)),
	}


func _world_turn_proof(runtime: RefCounted) -> Dictionary:
	var living := runtime.world_state.get("living_world", {}) as Dictionary
	var records := living.get("semantic_turns_by_index", {}) as Dictionary
	var record: Dictionary = records.values()[-1] as Dictionary if not records.is_empty() else {}
	return {
		"schema_version": String(living.get("schema_version", "")),
		"record_count": records.size(),
		"world_turn_id": String(record.get("world_turn_id", "")),
		"source_turn_index": int(record.get("source_turn_index", -1)),
		"source_gm_sha256": String(record.get("source_gm_sha256", "")),
		"changes": (record.get("changes", []) as Array).duplicate(true),
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
		print("G5-01 REAL PASS | %s" % label)
	else:
		_failures += 1
		push_error("G5-01 REAL FAIL | %s" % label)


func _write_evidence() -> void:
	var evidence := {
		"task": "G5-01M1",
		"generated_at": Time.get_datetime_string_from_system(true),
		"failures": _failures,
		"effective_profile": _profile,
		"narrative_results": _narrative_results,
		"world_turn": _final_world_turn_proof,
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
	if _worker != null and is_instance_valid(_worker):
		_worker.shutdown()
	if _runtime != null and _runtime.is_ready():
		_runtime.close()
	print("G5-01 REAL | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
