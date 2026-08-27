extends SceneTree

## 真实 DeepSeek 证据：通过 World Surface 明确 Load，Narrative full redraw 后从 restored
## Conversation 重建 Provider request；捕获 messages 证明 future marker 不可见，再 durable accept。

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const FUTURE_MARKER := "FUTURE_ONLY_SECRET_G304"

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
	_accept(runtime, "保存前线索一", "你在旧塔门口发现一道新鲜划痕。")
	_accept(runtime, "保存前线索二", "远处钟声响起，门缝透出微光。")
	var saved: Dictionary = runtime.create_save_point("真实读取点")
	_check(saved.success, "named Save is durable before future")
	_accept(runtime, "我进入未来分支 %s" % FUTURE_MARKER, "未来秘密 %s" % FUTURE_MARKER)

	var packed: PackedScene = load("res://src/main.tscn")
	var instance: Node = packed.instantiate()
	instance.session_runtime = runtime
	root.add_child(instance)
	await process_frame
	await process_frame
	var view: Node = instance.get_node("%NarrativeHost")
	view.request_messages_assembled.connect(func(messages: Array) -> void: _captured_messages = messages)
	runtime.conversation.generation_failed.connect(func(_turn: RefCounted, code: String) -> void: _failure_code = code)
	var selector: OptionButton = instance.get_node("%SaveSelector")
	var load_button: Button = instance.get_node("%LoadSaveButton")
	var confirmation: ConfirmationDialog = instance.get_node("%LoadConfirmation")
	var index := _find_save(selector, "真实读取点")
	_check(index >= 0, "real Save appears in World Surface")
	selector.select(index)
	load_button.pressed.emit()
	confirmation.confirmed.emit()
	await process_frame
	_check(runtime.conversation.get_durable_accepted_entries().size() == 2, "World Surface Load restores saved Conversation")

	var action := "我从钟声与门缝的微光继续调查，并谨慎推开旧塔的门。"
	var player_input: TextEdit = instance.get_node("%PlayerInput")
	var send_button: Button = instance.get_node("%SendButton")
	player_input.text = action
	send_button.pressed.emit()
	_check(runtime.conversation.is_generating(), "post-Restore real stream begins")
	var deadline := Time.get_ticks_msec() + 240000
	while runtime.conversation.is_generating() and Time.get_ticks_msec() < deadline:
		await process_frame
	_check(not runtime.conversation.is_generating(), "real DeepSeek stream reaches terminal state")
	if not _failure_code.is_empty(): printerr("G3-04 REAL EVIDENCE | terminal failure code=%s" % _failure_code)
	var accepted: Array = runtime.conversation.get_durable_accepted_entries()
	_check(accepted.size() == 3 and not String(accepted[-1].gm_text).strip_edges().is_empty(), "real result becomes durable third Turn")
	var messages_json := JSON.stringify(_captured_messages)
	_check(not messages_json.contains(FUTURE_MARKER), "future-only marker absent from real Provider request")
	_check(_captured_messages.size() == 6, "request is system + two restored pairs + current user")
	if not _captured_messages.is_empty():
		_check(String(_captured_messages[-1].content) == action and _count_message(action) == 1, "current user appears exactly once and last")
		_check(not String(_captured_messages[0].content).contains("Current Game Context"), "opaque World JSON is not dumped into prompt")
	instance.queue_free()
	await process_frame
	runtime.close()
	var reopened := Runtime.new()
	_check(reopened.open_current_game(database_path).success, "post-Restore real result reopens")
	_check(reopened.conversation.get_durable_accepted_entries().size() == 3, "post-Restore real Turn survives reopen")
	reopened.close()
	print("G3-04 REAL | done failures=%d pid=%d" % [_failures, OS.get_process_id()])
	quit(1 if _failures > 0 else 0)


func _accept(runtime: RefCounted, player: String, gm: String) -> void:
	if runtime.conversation.begin_turn(player) == null:
		_check(false, "seed begin Turn")
		return
	runtime.conversation.append_delta(gm)
	_check(runtime.complete_active_generation_durably().success, "seed accepted Turn")


func _find_save(selector: OptionButton, display_name: String) -> int:
	for index: int in range(selector.item_count):
		if selector.get_item_text(index) == display_name: return index
	return -1


func _count_message(content: String) -> int:
	var count := 0
	for value: Variant in _captured_messages:
		if String((value as Dictionary).get("content", "")) == content: count += 1
	return count


func _check(condition: bool, label: String) -> void:
	if condition: print("G3-04 REAL PASS | %s" % label)
	else:
		_failures += 1
		printerr("G3-04 REAL FAIL | %s" % label)


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix): return argument.trim_prefix(prefix)
	return ""


func _finish_failure(message: String) -> void:
	printerr("G3-04 REAL FAIL | %s" % message)
	quit(1)
