extends SceneTree

## G3-03 resume product focused test：从 durable Conversation 重建 recent-12 Context，
## 并验证 Narrative UI 只渲染 Domain projection，不持有第二套 history。

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const ContextAssembler := preload("res://src/context/上下文组装器.gd")
const StubAdapter := preload("res://tests/g2_03_桩适配器.gd")

var _failures := 0


func _init() -> void:
	_run.call_deferred()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G3-03 UI/CONTEXT PASS | %s" % label)
	else:
		_failures += 1
		printerr("G3-03 UI/CONTEXT FAIL | %s" % label)


func _run() -> void:
	var root_path := _argument_value("--root=")
	if root_path.is_empty():
		printerr("G3-03 UI/CONTEXT FAIL | missing --root")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(root_path)
	await _test_context_rebuild(root_path.path_join("context.sqlite"))
	await _test_restored_ui(root_path.path_join("ui.sqlite"))
	await _test_startup_failure_ui(root_path.path_join("corrupt-ui.sqlite"))
	print("G3-03 UI/CONTEXT | done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)


func _test_context_rebuild(database_path: String) -> void:
	var seed := Runtime.new()
	_check(seed.open_current_game(database_path).success, "14-Turn fixture first-run opens")
	for index: int in range(14):
		if not _accept(seed, "恢复行动%02d" % index, "恢复回应%02d" % index): break
	seed.close()

	var resumed := Runtime.new()
	_check(resumed.open_current_game(database_path).success, "14-Turn fixture reopens")
	_check(resumed.conversation.get_accepted_entries().size() == 14, "14 accepted Turns rehydrate exactly")
	resumed.conversation.begin_turn("恢复后的当前行动")
	var messages: Array = ContextAssembler.new().assemble_messages(
		resumed.conversation.get_context_projection(), ""
	)
	_check(messages.size() == 26, "recent-12 yields system + 24 history messages + current user")
	_check(String(messages[1].content) == "恢复行动02" and String(messages[2].content) == "恢复回应02", "oldest retained pair is Turn 2")
	_check(String(messages[-2].content) == "恢复回应13", "latest restored GM precedes current user")
	_check(String(messages[-1].role) == "user" and String(messages[-1].content) == "恢复后的当前行动", "current player is last")
	_check(_count_message(messages, "user", "恢复后的当前行动") == 1, "current player appears exactly once")
	_check(not JSON.stringify(messages).contains("accepted_turns_json"), "no persisted Provider/Context blob is consumed")
	_check(not String(messages[0].content).contains("Current Game Context"), "opaque World JSON is not injected as Game Context")
	resumed.close()


func _test_restored_ui(database_path: String) -> void:
	var seed := Runtime.new()
	_check(seed.open_current_game(database_path).success, "UI fixture first-run opens")
	_accept(seed, "界面行动一", "界面回应一")
	_accept(seed, "界面行动二", "界面回应二")
	seed.close()

	var runtime := Runtime.new()
	_check(runtime.open_current_game(database_path).success, "UI fixture resumes")
	var packed: PackedScene = load("res://src/main.tscn")
	var instance: Node = packed.instantiate()
	instance.session_runtime = runtime
	root.add_child(instance)
	await process_frame
	await process_frame
	var view: Node = instance.get_node("%NarrativeHost")
	var entries: VBoxContainer = instance.get_node("%Entries")
	var player_input: TextEdit = instance.get_node("%PlayerInput")
	var send_button: Button = instance.get_node("%SendButton")
	var regenerate_button: Button = instance.get_node("%RegenerateButton")
	_check(view.conversation == runtime.conversation, "UI binds runtime Conversation")
	_check(not ("_history" in view), "UI has no duplicate history owner")
	_check(entries.get_child_count() == 4, "two restored pairs render in order as four visual blocks")
	_check(_rich_text(entries.get_child(0)) == "界面行动一" and _rich_text(entries.get_child(2)) == "界面行动二", "restored player projections preserve order")
	var latest_gm_block: RichTextLabel = view._current_gm_content
	var stub := _install_stub(view)
	regenerate_button.pressed.emit()
	stub.text_delta.emit("界面回应二新版")
	stub.simulate_completed()
	await process_frame
	_check(entries.get_child_count() == 4, "restored latest Regenerate does not duplicate visual Turn")
	_check(view._current_gm_content == latest_gm_block and latest_gm_block.get_parsed_text() == "界面回应二新版", "Regenerate reuses latest restored GM block")
	_check(runtime.conversation.get_accepted_entries().size() == 2, "Regenerate keeps same logical Turn count")

	player_input.text = "界面行动三"
	send_button.pressed.emit()
	stub.text_delta.emit("界面回应三")
	stub.simulate_completed()
	await process_frame
	_check(entries.get_child_count() == 6, "new Turn appends after restored history")
	_check(runtime.conversation.get_accepted_entries().size() == 3, "new Turn becomes durable accepted truth")
	instance.queue_free()
	await process_frame
	runtime.close()
	var reopened := Runtime.new()
	_check(reopened.open_current_game(database_path).success, "UI product path closes/reopens")
	var durable: Array = reopened.conversation.get_accepted_entries()
	_check(durable.size() == 3 and String(durable[1].gm_text) == "界面回应二新版" and String(durable[2].player_text) == "界面行动三", "UI Regenerate/new Turn durable round-trip exact")
	reopened.close()


func _test_startup_failure_ui(database_path: String) -> void:
	var corrupt := FileAccess.open(database_path, FileAccess.WRITE)
	corrupt.store_string("intentional corrupt current Game")
	corrupt.close()
	var runtime := Runtime.new()
	_check(not runtime.open_current_game(database_path).success, "corrupt existing DB fails startup")
	var packed: PackedScene = load("res://src/main.tscn")
	var instance: Node = packed.instantiate()
	instance.session_runtime = runtime
	root.add_child(instance)
	await process_frame
	await process_frame
	var send_button: Button = instance.get_node("%SendButton")
	var error_label: Label = instance.get_node("%ErrorLabel")
	var player_input: TextEdit = instance.get_node("%PlayerInput")
	player_input.text = "不得发送"
	player_input.text_changed.emit()
	_check(send_button.disabled, "failed resume blocks normal send path")
	_check(error_label.visible and error_label.text.contains("不会创建空白新局"), "failed resume shows player-readable protection error")
	instance.queue_free()
	await process_frame


func _install_stub(view: Node) -> Node:
	var old_adapter: Node = view.adapter
	old_adapter.text_delta.disconnect(view._on_text_delta)
	old_adapter.completed.disconnect(view._on_completed)
	old_adapter.cancelled.disconnect(view._on_cancelled)
	old_adapter.failed.disconnect(view._on_failed)
	var stub: Node = StubAdapter.new()
	view.adapter = stub
	view.add_child(stub)
	stub.text_delta.connect(view._on_text_delta)
	stub.completed.connect(view._on_completed)
	stub.cancelled.connect(view._on_cancelled)
	stub.failed.connect(view._on_failed)
	return stub


func _accept(runtime: RefCounted, player_text: String, gm_text: String) -> bool:
	if runtime.conversation.begin_turn(player_text) == null:
		_check(false, "begin Turn: %s" % player_text)
		return false
	runtime.conversation.append_delta(gm_text)
	var result: Dictionary = runtime.complete_active_generation_durably()
	_check(result.success, "durable accept: %s" % player_text)
	return result.success


func _rich_text(block: Node) -> String:
	for child: Node in block.get_children():
		if child is RichTextLabel: return (child as RichTextLabel).get_parsed_text()
	return ""


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
