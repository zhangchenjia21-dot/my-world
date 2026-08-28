extends SceneTree

## 五个独立 OS process 证明 Load/Recover COMMIT 不依赖 memory/UI/shutdown flush。
## 两个 commit-wait 模式直接走 production Persistence L3；COMMIT 后写 exact-PID marker，
## 不执行 Runtime memory apply，由外部 harness 终止已核验进程。

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const FUTURE_A := "G305_CRASH_FUTURE_A"
const BRANCH_B := "G305_CRASH_BRANCH_B"


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var mode := _argument_value("--mode=")
	var database_path := _argument_value("--db=")
	var proof_path := _argument_value("--proof=")
	var marker_path := _argument_value("--marker=")
	if mode.is_empty() or database_path.is_empty() or proof_path.is_empty(): return _fail("missing mode/db/proof")
	match mode:
		"seed": _seed(database_path, proof_path)
		"load-commit-wait": await _load_commit_wait(database_path, proof_path, marker_path)
		"verify-load-seed-branch": _verify_load_seed_branch(database_path, proof_path)
		"recover-commit-wait": await _recover_commit_wait(database_path, proof_path, marker_path)
		"verify-recover": _verify_recover(database_path, proof_path)
		_: _fail("unknown mode")


func _seed(database_path: String, proof_path: String) -> void:
	var runtime := Runtime.new()
	if not runtime.open_current_game(database_path).success or not _accept(runtime, "Save 行动", "Save 回应"): return _fail("seed Save truth")
	var saved: Dictionary = runtime.create_save_point("崩溃保护目标")
	if not saved.success or not _accept(runtime, "Future A 行动", FUTURE_A): return _fail("seed Future A")
	var proof := {"game_id": runtime.game_id, "save_id": saved.save_id, "save_head": saved.timeline_node_id, "future_a": runtime.conversation.get_durable_accepted_entries()}
	runtime.close()
	if not _write_json(proof_path, proof): return
	print("G3-05 CRASH SEED PASS | pid=%d" % OS.get_process_id())
	quit(0)


func _load_commit_wait(database_path: String, proof_path: String, marker_path: String) -> void:
	var proof := _read_json(proof_path)
	var runtime := Runtime.new()
	if not runtime.open_current_game(database_path).success: return _fail("Load commit process open")
	var candidate: Dictionary = runtime.persistence.get_save_point(runtime.game_id, String(proof.save_id))
	var validation: Dictionary = runtime.conversation.validate_accepted_entries(candidate.get("accepted_entries", []))
	if not candidate.success or not validation.ok: return _fail("Load candidate validation")
	var committed: Dictionary = runtime.persistence.restore_save_point(runtime.game_id, String(proof.save_id), validation.accepted_entries, "2026-08-28T03:00:00Z", "recovery-crash-load")
	if not committed.success: return _fail("protected Load COMMIT: %s" % committed)
	if not _write_json(marker_path, {"pid": OS.get_process_id(), "committed": true, "mode": "load"}): return
	print("G3-05 LOAD COMMITTED | pid=%d waiting-before-memory-apply" % OS.get_process_id())
	await create_timer(3600.0).timeout


func _verify_load_seed_branch(database_path: String, proof_path: String) -> void:
	var proof := _read_json(proof_path)
	var runtime := Runtime.new()
	if not runtime.open_current_game(database_path).success: return _fail("verify Load reopen")
	var latest: Dictionary = runtime.persistence.get_latest_recovery(runtime.game_id)
	var normalized: Dictionary = runtime.conversation.validate_accepted_entries(latest.get("accepted_entries", []))
	if runtime.active_head_id != String(proof.save_head) or not latest.success or not normalized.ok or not _same_entries(normalized.accepted_entries, proof.future_a):
		return _fail("Load crash reopen target/Recovery mismatch")
	if not _accept(runtime, "Branch B 行动", BRANCH_B): return
	proof["branch_b"] = runtime.conversation.get_durable_accepted_entries()
	runtime.close()
	if not _write_json(proof_path, proof): return
	print("G3-05 CRASH LOAD VERIFY PASS | target current + Future A Recovery survived")
	quit(0)


func _recover_commit_wait(database_path: String, proof_path: String, marker_path: String) -> void:
	var runtime := Runtime.new()
	if not runtime.open_current_game(database_path).success: return _fail("Recover commit process open")
	var candidate: Dictionary = runtime.persistence.get_latest_recovery(runtime.game_id)
	var validation: Dictionary = runtime.conversation.validate_accepted_entries(candidate.get("accepted_entries", []))
	if not candidate.success or not validation.ok: return _fail("Recover candidate validation")
	var committed: Dictionary = runtime.persistence.recover_previous_progress(runtime.game_id, String(candidate.recovery_id), validation.accepted_entries, "recovery-crash-reciprocal", "2026-08-28T03:00:01Z")
	if not committed.success: return _fail("protected Recover COMMIT: %s" % committed)
	if not _write_json(marker_path, {"pid": OS.get_process_id(), "committed": true, "mode": "recover"}): return
	print("G3-05 RECOVER COMMITTED | pid=%d waiting-before-memory-apply" % OS.get_process_id())
	await create_timer(3600.0).timeout


func _verify_recover(database_path: String, proof_path: String) -> void:
	var proof := _read_json(proof_path)
	var runtime := Runtime.new()
	if not runtime.open_current_game(database_path).success: return _fail("verify Recover reopen")
	if not _same_entries(runtime.conversation.get_durable_accepted_entries(), proof.future_a): return _fail("Recover target Future A mismatch")
	var latest: Dictionary = runtime.persistence.get_latest_recovery(runtime.game_id)
	var normalized: Dictionary = runtime.conversation.validate_accepted_entries(latest.get("accepted_entries", []))
	if not latest.success or not normalized.ok or not _same_entries(normalized.accepted_entries, proof.branch_b): return _fail("Recover reciprocal Branch B missing")
	if JSON.stringify(runtime.conversation.get_durable_accepted_entries()).contains(BRANCH_B): return _fail("Branch B leaked into recovered current")
	runtime.close()
	print("G3-05 CRASH RECOVER VERIFY PASS | target + reciprocal Recovery survived")
	quit(0)


func _accept(runtime: RefCounted, player: String, gm: String) -> bool:
	if runtime.conversation.begin_turn(player) == null: return _fail("begin Turn")
	runtime.conversation.append_delta(gm)
	return true if runtime.complete_active_generation_durably().success else _fail("durable accept")


func _same_entries(actual: Array, expected: Array) -> bool:
	if actual.size() != expected.size(): return false
	for index: int in range(actual.size()):
		var left := actual[index] as Dictionary
		var right := expected[index] as Dictionary
		if int(left.get("turn_index", -1)) != int(right.get("turn_index", -1)): return false
		if String(left.get("player_text", "")) != String(right.get("player_text", "")): return false
		if String(left.get("gm_text", "")) != String(right.get("gm_text", "")): return false
	return true


func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null: return _fail("write proof/marker")
	file.store_string(JSON.stringify(value, "", true, true)); file.close()
	return true


func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_fail("read proof")
		return {}
	var value: Variant = JSON.parse_string(file.get_as_text()); file.close()
	if typeof(value) != TYPE_DICTIONARY:
		_fail("invalid proof")
		return {}
	return value as Dictionary


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix): return argument.trim_prefix(prefix)
	return ""


func _fail(message: String) -> bool:
	push_error("G3-05 CRASH FAIL | %s" % message)
	quit(1)
	return false
