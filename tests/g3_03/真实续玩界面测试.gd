extends SceneTree

## 真实 DeepSeek continuity 证据：启动前 DB 已含 accepted history，本进程通过正式
## Narrative View + Provider Adapter 发起请求，捕获一次性 derived messages，等待 durable accept。

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")

var _failures := 0
var _captured_messages: Array = []
var _failure_code := ""


func _init() -> void:
	_run.call_deferred()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G3-03 REAL PASS | %s" % label)
	else:
		_failures += 1
		printerr("G3-03 REAL FAIL | %s" % label)


func _run() -> void:
	var database_path := _argument_value("--db=")
	var proof_path := _argument_value("--proof=")
	if database_path.is_empty() or proof_path.is_empty():
		printerr("G3-03 REAL FAIL | missing --db/--proof")
		quit(1)
		return
	if OS.get_environment("DEEPSEEK_API_KEY").strip_edges().is_empty():
		printerr("G3-03 REAL FAIL | DEEPSEEK_API_KEY is unavailable")
		quit(1)
		return
	_check(true, "real Provider credential is available without logging it")
	var runtime := Runtime.new()
	var opened: Dictionary = runtime.open_current_game(database_path)
	if opened.status != "resumed" or opened.accepted_count != 3:
		printerr("G3-03 REAL FAIL | GUI did not start from three pre-existing durable Turns")
		runtime.close()
		quit(1)
		return
	_check(true, "GUI starts from three pre-existing durable Turns")
	var expected_before: Array = runtime.conversation.get_accepted_entries()

	var packed: PackedScene = load("res://src/main.tscn")
	var instance: Node = packed.instantiate()
	instance.session_runtime = runtime
	root.add_child(instance)
	await process_frame
	await process_frame
	var view: Node = instance.get_node("%NarrativeHost")
	view.request_messages_assembled.connect(func(messages: Array) -> void: _captured_messages = messages)
	runtime.conversation.generation_failed.connect(func(_turn: RefCounted, code: String) -> void: _failure_code = code)
	var player_input: TextEdit = instance.get_node("%PlayerInput")
	var send_button: Button = instance.get_node("%SendButton")
	var action := "我继续沿着重启前发现的线索前进，并留意周围是否有人跟踪。"
	player_input.text = action
	send_button.pressed.emit()
	_check(runtime.conversation.is_generating(), "real GUI begins streamed continuation")
	var deadline := Time.get_ticks_msec() + 240000
	while runtime.conversation.is_generating() and Time.get_ticks_msec() < deadline:
		await process_frame
	_check(not runtime.conversation.is_generating(), "real DeepSeek stream reaches terminal state")
	if not _failure_code.is_empty():
		printerr("G3-03 REAL EVIDENCE | terminal failure code=%s" % _failure_code)
	var accepted: Array = runtime.conversation.get_accepted_entries()
	_check(accepted.size() == 4, "real completion becomes fourth accepted Turn")
	_check(accepted.slice(0, 3) == expected_before, "restored accepted history remains exact")
	_check(accepted.size() == 4 and not String(accepted[-1].gm_text).strip_edges().is_empty(), "real GM completion is non-empty")
	_check(_captured_messages.size() == 8, "Provider request contains system + three restored pairs + current user")
	if not _captured_messages.is_empty():
		_check(String(_captured_messages[-1].role) == "user" and String(_captured_messages[-1].content) == action, "current user is last in captured request")
		_check(_count_message(_captured_messages, "user", action) == 1, "current user appears exactly once in captured request")
		_check(String(_captured_messages[1].content) == "跨进程行动0" and String(_captured_messages[6].content) == "跨进程回应2", "restored Conversation appears in correct Provider order")
		_check(not String(_captured_messages[0].content).contains("Current Game Context"), "raw World JSON is not injected")
	instance.queue_free()
	await process_frame
	runtime.close()
	if _failures == 0:
		var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
		proof_file.store_string(JSON.stringify({
			"game_id": opened.game_id,
			"accepted_entries": accepted,
			"real_gui_pid": OS.get_process_id(),
		}, "", true, true))
		proof_file.close()
	print("G3-03 REAL | done failures=%d pid=%d" % [_failures, OS.get_process_id()])
	quit(1 if _failures > 0 else 0)


func _count_message(messages: Array, role: String, content: String) -> int:
	var count := 0
	for value: Variant in messages:
		var message := value as Dictionary
		if String(message.get("role", "")) == role and String(message.get("content", "")) == content:
			count += 1
	return count


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix): return argument.trim_prefix(prefix)
	return ""
