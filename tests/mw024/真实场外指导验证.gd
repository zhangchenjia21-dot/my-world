extends SceneTree

const Conversation := preload("res://src/domain/会话.gd")
const Context := preload("res://src/context/L3_外交层/上下文组装公开接口.gd")
const Provider := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")
var response := ""
var terminal := ""

# 一个生产 Narrative 请求；无 World/Curator/Recommender 实例、无游戏持久化。
func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var output := ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
	if not output.contains("build/mw024/"): quit(2); return
	var conversation := Conversation.new()
	conversation.restore_accepted_entries([{"player_text": "", "gm_text": "你在渡口的小亭里避雨，船工正在岸边整理绳索。"}])
	conversation.begin_turn("请放慢节奏，多给我与人物交谈的空间。先不要推进剧情，只确认这条场外指导。", "ooc")
	var messages := Context.new().assemble_messages(conversation.get_context_projection(), "")
	var adapter := Provider.new()
	root.add_child(adapter)
	adapter.text_delta.connect(func(text: String) -> void: response += text)
	adapter.completed.connect(func() -> void: terminal = "completed")
	adapter.failed.connect(func(code: String, _message: String) -> void: terminal = code)
	adapter.cancelled.connect(func() -> void: terminal = "cancelled")
	var started := Time.get_ticks_msec()
	var start_result := adapter.start_stream(messages)
	while terminal.is_empty() and Time.get_ticks_msec() - started < 180000:
		await process_frame
	if terminal.is_empty():
		adapter.cancel()
		terminal = "bounded_timeout"
	var report := {"terminal": terminal, "start_error": start_result, "network_attempt_count": adapter.network_attempt_count, "model": adapter.last_request_snapshot.get("model_id", ""), "input_mode": "ooc", "response": response, "elapsed_ms": Time.get_ticks_msec() - started, "messages": messages}
	var file := FileAccess.open(output, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("MW024 REAL terminal=" + terminal + " requests=" + str(adapter.network_attempt_count))
	adapter.queue_free()
	await process_frame
	quit(0 if terminal == "completed" else 1)
