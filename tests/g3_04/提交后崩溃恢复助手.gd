extends SceneTree

## 三次独立 OS process 证明：Restore COMMIT 不依赖 memory/UI/shutdown flush。
## restore-commit-wait 直接走 production Persistence L3，COMMIT 后写 marker，随后不执行
## Runtime/Conversation/UI apply；外部 harness 只终止这个已核验 PID。

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var mode := _argument_value("--mode=")
	var database_path := _argument_value("--db=")
	var proof_path := _argument_value("--proof=")
	var marker_path := _argument_value("--marker=")
	if mode.is_empty() or database_path.is_empty() or proof_path.is_empty():
		return _fail("missing mode/db/proof")
	if mode == "seed":
		_seed(database_path, proof_path)
	elif mode == "restore-commit-wait":
		await _restore_commit_wait(database_path, proof_path, marker_path)
	elif mode == "verify":
		_verify(database_path, proof_path)
	else:
		_fail("unknown mode")


func _seed(database_path: String, proof_path: String) -> void:
	var runtime := Runtime.new()
	if not runtime.open_current_game(database_path).success or not _accept(runtime, "崩溃前保存行动", "崩溃前保存回应"):
		return _fail("seed current Game")
	var saved: Dictionary = runtime.create_save_point("崩溃恢复点")
	if not saved.success: return _fail("seed Save")
	var expected := {
		"game_id": runtime.game_id,
		"head_id": runtime.active_head_id,
		"world_state": runtime.world_state,
		"accepted_entries": runtime.conversation.get_durable_accepted_entries(),
		"save_id": saved.save_id,
	}
	if not _accept(runtime, "崩溃前未来", "FUTURE_ONLY_SECRET_G304 崩溃前未来回应"):
		return
	runtime.close()
	if not _write_json(proof_path, expected): return
	print("G3-04 CRASH SEED PASS | pid=%d" % OS.get_process_id())
	quit(0)


func _restore_commit_wait(database_path: String, proof_path: String, marker_path: String) -> void:
	var proof := _read_json(proof_path)
	var runtime := Runtime.new()
	if not runtime.open_current_game(database_path).success: return _fail("commit process open")
	var candidate: Dictionary = runtime.persistence.get_save_point(runtime.game_id, String(proof.save_id))
	var validation: Dictionary = runtime.conversation.validate_accepted_entries(candidate.accepted_entries)
	if not candidate.success or not validation.ok: return _fail("commit process candidate validation")
	var committed: Dictionary = runtime.persistence.restore_save_point(runtime.game_id, String(proof.save_id), validation.accepted_entries, "2026-08-27T09:00:00Z")
	if not committed.success: return _fail("Restore COMMIT failed: %s" % committed)
	if not _write_json(marker_path, {"pid": OS.get_process_id(), "committed": true}): return
	print("G3-04 RESTORE COMMITTED | pid=%d waiting-before-memory-apply" % OS.get_process_id())
	# 不调用 runtime memory apply，也不 close；由外部 exact-PID harness 模拟进程死亡。
	await create_timer(3600.0).timeout


func _verify(database_path: String, proof_path: String) -> void:
	var proof := _read_json(proof_path)
	var runtime := Runtime.new()
	if not runtime.open_current_game(database_path).success: return _fail("verify reopen")
	if runtime.game_id != String(proof.game_id) or runtime.active_head_id != String(proof.head_id):
		return _fail("restored Game/head mismatch")
	var actual_world := JSON.stringify(runtime.world_state, "", true, true)
	var expected_world := JSON.stringify(proof.world_state, "", true, true)
	var actual_entries: Array = runtime.conversation.get_durable_accepted_entries()
	var expected_entries: Array = proof.accepted_entries as Array
	if actual_world != expected_world or not _same_entries(actual_entries, expected_entries):
		return _fail("restored World/Conversation mismatch")
	if JSON.stringify(runtime.conversation.get_durable_accepted_entries()).contains("FUTURE_ONLY_SECRET_G304"):
		return _fail("future marker survived crash/reopen")
	runtime.close()
	print("G3-04 CRASH VERIFY PASS | restored COMMIT survived exact-PID death before memory/UI apply")
	quit(0)


func _accept(runtime: RefCounted, player: String, gm: String) -> bool:
	if runtime.conversation.begin_turn(player) == null: return _fail("begin Turn")
	runtime.conversation.append_delta(gm)
	var result: Dictionary = runtime.complete_active_generation_durably()
	return true if result.success else _fail("durable accept")


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
	push_error("G3-04 CRASH FAIL | %s" % message)
	quit(1)
	return false
