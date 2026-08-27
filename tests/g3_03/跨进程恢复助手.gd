extends SceneTree

## G3-03 跨进程测试助手。每次 invocation 都是独立 Godot OS process，且只通过
## production CurrentGameRuntime + Persistence L3 操作 task-owned DB。

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")


func _initialize() -> void:
	var mode := _argument_value("--mode=")
	var database_path := _argument_value("--db=")
	var proof_path := _argument_value("--proof=")
	if mode.is_empty() or database_path.is_empty() or proof_path.is_empty():
		_fail("missing --mode/--db/--proof")
		return
	if mode == "seed":
		_seed(database_path, proof_path)
	elif mode == "continue":
		_continue(database_path, proof_path)
	elif mode == "verify-four":
		_verify_four(database_path, proof_path)
	elif mode == "capture-zero":
		_capture_zero(database_path, proof_path)
	elif mode == "verify-zero":
		_verify_zero(database_path, proof_path)
	else:
		_fail("unknown mode: %s" % mode)


func _seed(database_path: String, proof_path: String) -> void:
	var runtime := Runtime.new()
	var opened: Dictionary = runtime.open_current_game(database_path)
	if opened.status != "created": return _fail("seed expected created: %s" % opened)
	for index: int in range(3):
		if not _accept(runtime, "跨进程行动%d" % index, "跨进程回应%d" % index): return
	var proof := {
		"game_id": runtime.game_id,
		"head_id": runtime.active_head_id,
		"world_state": runtime.world_state,
		"accepted_entries": runtime.conversation.get_accepted_entries(),
		"seed_pid": OS.get_process_id(),
	}
	runtime.close()
	if not _write_json(proof_path, proof): return
	print("G3-03 PROCESS A PASS | pid=%d game=%s turns=3" % [OS.get_process_id(), proof.game_id])
	quit(0)


func _continue(database_path: String, proof_path: String) -> void:
	var proof: Dictionary = _read_json(proof_path)
	if proof.is_empty(): return
	var runtime := Runtime.new()
	var opened: Dictionary = runtime.open_current_game(database_path)
	if opened.status != "resumed": return _fail("continue expected resumed: %s" % opened)
	var restored: Array = runtime.conversation.get_accepted_entries()
	if runtime.game_id != String(proof.game_id) or runtime.active_head_id != String(proof.head_id):
		return _fail("Game/head identity changed across processes")
	if JSON.stringify(runtime.world_state, "", true, true) != JSON.stringify(proof.world_state, "", true, true) or not _same_entries(restored, proof.accepted_entries):
		return _fail("World/Conversation did not resume exactly")
	if runtime.conversation.is_generating() or restored.size() != 3:
		return _fail("resume generation state/count mismatch")
	if not _accept(runtime, "跨进程行动3", "跨进程回应3"): return
	proof["accepted_entries"] = runtime.conversation.get_accepted_entries()
	proof["continue_pid"] = OS.get_process_id()
	runtime.close()
	if not _write_json(proof_path, proof): return
	print("G3-03 PROCESS B PASS | pid=%d same_game=%s continued_turns=4" % [OS.get_process_id(), proof.game_id])
	quit(0)


func _verify_four(database_path: String, proof_path: String) -> void:
	var proof: Dictionary = _read_json(proof_path)
	if proof.is_empty(): return
	var runtime := Runtime.new()
	var opened: Dictionary = runtime.open_current_game(database_path)
	if opened.status != "resumed": return _fail("verify expected resumed: %s" % opened)
	var restored: Array = runtime.conversation.get_accepted_entries()
	var expected: Array = proof.get("accepted_entries", []) as Array
	if runtime.game_id != String(proof.game_id) or not _same_entries(restored, expected) or restored.size() != 4:
		return _fail("four-Turn process reopen mismatch")
	if runtime.conversation.is_generating(): return _fail("reopen retained generating state")
	runtime.close()
	print("G3-03 PROCESS VERIFY PASS | pid=%d same_game=%s turns=4" % [OS.get_process_id(), proof.game_id])
	quit(0)


func _capture_zero(database_path: String, proof_path: String) -> void:
	var runtime := Runtime.new()
	var opened: Dictionary = runtime.open_current_game(database_path)
	if opened.status != "resumed" or opened.accepted_count != 0:
		return _fail("capture-zero expected empty resumed Game: %s" % opened)
	var proof := {"game_id": runtime.game_id, "head_id": runtime.active_head_id, "world_state": runtime.world_state}
	runtime.close()
	if not _write_json(proof_path, proof): return
	print("G3-03 PRODUCT FIRST-RUN PASS | game=%s" % proof.game_id)
	quit(0)


func _verify_zero(database_path: String, proof_path: String) -> void:
	var proof: Dictionary = _read_json(proof_path)
	if proof.is_empty(): return
	var runtime := Runtime.new()
	var opened: Dictionary = runtime.open_current_game(database_path)
	if opened.status != "resumed" or opened.accepted_count != 0:
		return _fail("verify-zero expected empty resumed Game: %s" % opened)
	if runtime.game_id != String(proof.game_id) or runtime.active_head_id != String(proof.head_id):
		return _fail("normal product second launch changed Game/root identity")
	if JSON.stringify(runtime.world_state, "", true, true) != JSON.stringify(proof.world_state, "", true, true):
		return _fail("normal product second launch changed World")
	runtime.close()
	print("G3-03 PRODUCT REOPEN PASS | same_game=%s" % proof.game_id)
	quit(0)


func _accept(runtime: RefCounted, player_text: String, gm_text: String) -> bool:
	if runtime.conversation.begin_turn(player_text) == null:
		return _fail("begin Turn failed")
	runtime.conversation.append_delta(gm_text)
	var result: Dictionary = runtime.complete_active_generation_durably()
	return true if result.success else _fail("durable completion failed: %s" % result)


func _same_entries(actual: Array, expected: Array) -> bool:
	if actual.size() != expected.size(): return false
	for index: int in range(actual.size()):
		var left := actual[index] as Dictionary
		var right := expected[index] as Dictionary
		if int(left.get("turn_index", -1)) != int(right.get("turn_index", -1)):
			return false
		if String(left.get("player_text", "")) != String(right.get("player_text", "")):
			return false
		if String(left.get("gm_text", "")) != String(right.get("gm_text", "")):
			return false
	return true


func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null: return _fail("cannot write proof: %s" % FileAccess.get_open_error())
	file.store_string(JSON.stringify(value, "", true, true))
	file.close()
	return true


func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_fail("cannot read proof: %s" % FileAccess.get_open_error())
		return {}
	var value: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(value) != TYPE_DICTIONARY:
		_fail("proof is not JSON object")
		return {}
	return value as Dictionary


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix): return argument.trim_prefix(prefix)
	return ""


func _fail(message: String) -> bool:
	push_error("G3-03 PROCESS FAIL | %s" % message)
	quit(1)
	return false
