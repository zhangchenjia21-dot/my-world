extends SceneTree

## 真实 DeepSeek 证据：Save → Future A → Load → Branch B → Recover A 后，通过正式
## Narrative UI 发起请求；捕获 derived messages 证明只包含 recovered A，不含 B。

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const MARKER_A := "RECOVERED_FUTURE_MARKER_A"
const MARKER_B := "DISPLACED_BRANCH_MARKER_B"

var _failures := 0
var _captured_messages: Array = []
var _failure_code := ""


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var database_path := _argument_value("--db=")
	if database_path.is_empty() or OS.get_environment("DEEPSEEK_API_KEY").strip_edges().is_empty():
		return _finish_failure("missing isolated DB path or Provider credential")
	var runtime := Runtime.new()
	_check(runtime.open_current_game(database_path).success, "isolated real-Provider Game opens")
	_accept(runtime, "存档前线索一", "你在旧塔门口发现一道新鲜划痕。")
	_accept(runtime, "存档前线索二", "远处钟声响起，门缝透出微光。")
	var saved: Dictionary = runtime.create_save_point("真实恢复点")
	_check(saved.success, "named Save is durable")
	_accept(runtime, "Future A 行动", "Future A 的线索 %s" % MARKER_A)
	_check(runtime.restore_save_point(saved.save_id).success, "protected Load creates Future A Recovery")
	_accept(runtime, "Branch B 行动", "Branch B 的秘密 %s" % MARKER_B)

	var packed: PackedScene = load("res://src/main.tscn")
	var instance: Node = packed.instantiate()
	instance.session_runtime = runtime
	root.add_child(instance)
	await process_frame
	await process_frame
	var view: Node = instance.get_node("%NarrativeHost")
	view.request_messages_assembled.connect(func(messages: Array) -> void: _captured_messages = messages)
	runtime.conversation.generation_failed.connect(func(_turn: RefCounted, code: String) -> void: _failure_code = code)
	var recover_button: Button = instance.get_node("%RecoverButton")
	var confirmation: ConfirmationDialog = instance.get_node("%RecoverConfirmation")
	_check(recover_button.visible, "latest Recovery appears in normal product composition")
	recover_button.pressed.emit()
	confirmation.confirmed.emit()
	await process_frame
	await process_frame
	var recovered: Array = runtime.conversation.get_durable_accepted_entries()
	_check(JSON.stringify(recovered).contains(MARKER_A) and not JSON.stringify(recovered).contains(MARKER_B), "Recover selects exact Future A before real request")

	var action := "根据刚才 Future A 的线索继续调查旧塔，并说明你记得的关键细节。"
	var player_input: TextEdit = instance.get_node("%PlayerInput")
	var send_button: Button = instance.get_node("%SendButton")
	player_input.text = action
	send_button.pressed.emit()
	_check(runtime.conversation.is_generating(), "post-Recover real stream begins")
	var deadline := Time.get_ticks_msec() + 240000
	while runtime.conversation.is_generating() and Time.get_ticks_msec() < deadline:
		await process_frame
	_check(not runtime.conversation.is_generating(), "real DeepSeek stream reaches terminal state")
	if not _failure_code.is_empty(): printerr("G3-05 REAL EVIDENCE | terminal failure code=%s" % _failure_code)
	var accepted: Array = runtime.conversation.get_durable_accepted_entries()
	_check(accepted.size() == 4 and not String(accepted[-1].gm_text).strip_edges().is_empty(), "real result becomes durable post-Recover Turn")
	var messages_json := JSON.stringify(_captured_messages)
	_check(messages_json.contains(MARKER_A), "recovered Future A marker reaches real Provider request")
	_check(not messages_json.contains(MARKER_B), "displaced Branch B marker absent from real Provider request")
	if not _captured_messages.is_empty():
		_check(String(_captured_messages[-1].content) == action and _count_message(action) == 1, "current user appears exactly once and last")
		_check(not String(_captured_messages[0].content).contains("Current Game Context"), "opaque World JSON is not dumped into prompt")
	instance.queue_free()
	await process_frame
	runtime.close()
	var reopened := Runtime.new()
	_check(reopened.open_current_game(database_path).success, "post-Recover real continuation reopens")
	_check(reopened.conversation.get_durable_accepted_entries().size() == 4 and reopened.get_recovery_availability().available, "real Turn and reciprocal Recovery survive reopen")
	reopened.close()
	print("G3-05 REAL | done failures=%d pid=%d" % [_failures, OS.get_process_id()])
	quit(1 if _failures > 0 else 0)


func _accept(runtime: RefCounted, player: String, gm: String) -> void:
	if runtime.conversation.begin_turn(player) == null:
		_check(false, "seed begin Turn")
		return
	runtime.conversation.append_delta(gm)
	_check(runtime.complete_active_generation_durably().success, "seed accepted Turn")


func _count_message(content: String) -> int:
	var count := 0
	for value: Variant in _captured_messages:
		if String((value as Dictionary).get("content", "")) == content: count += 1
	return count


func _check(condition: bool, label: String) -> void:
	if condition: print("G3-05 REAL PASS | %s" % label)
	else:
		_failures += 1
		printerr("G3-05 REAL FAIL | %s" % label)


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix): return argument.trim_prefix(prefix)
	return ""


func _finish_failure(message: String) -> void:
	printerr("G3-05 REAL FAIL | %s" % message)
	quit(1)
