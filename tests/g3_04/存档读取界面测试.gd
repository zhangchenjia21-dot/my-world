extends SceneTree

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")

var _failures := 0


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var database_path := _argument_value("--db=")
	if database_path.is_empty():
		return _finish_failure("missing --db")
	var runtime := Runtime.new()
	_check(runtime.open_current_game(database_path).success, "isolated current Game opens")
	_accept(runtime, "保存时行动", "保存时回应")
	var packed: PackedScene = load("res://src/main.tscn")
	var instance: Node = packed.instantiate()
	instance.session_runtime = runtime
	root.add_child(instance)
	await process_frame
	await process_frame

	var save_input: LineEdit = instance.get_node("%SaveNameInput")
	var save_button: Button = instance.get_node("%CreateSaveButton")
	var selector: OptionButton = instance.get_node("%SaveSelector")
	var load_button: Button = instance.get_node("%LoadSaveButton")
	var confirmation: ConfirmationDialog = instance.get_node("%LoadConfirmation")
	var result_label: Label = instance.get_node("%SaveResultLabel")
	var entries: VBoxContainer = instance.get_node("%Entries")
	var world_host: PanelContainer = instance.get_node("%WorldSurfaceHost")
	var world_toggle: Button = instance.get_node("%WorldToggle")
	root.size = Vector2i(1280, 720)
	await process_frame
	_check(world_host.visible and not world_toggle.visible, "1280x720 keeps three-column World surface visible")
	root.size = Vector2i(960, 540)
	await process_frame
	world_toggle.button_pressed = true
	world_toggle.toggled.emit(true)
	_check(world_toggle.visible and world_host.visible, "960x540 exposes World Save surface through narrow toggle")
	root.size = Vector2i(1280, 720)
	await process_frame

	runtime.conversation.retry_or_regenerate_latest()
	await process_frame
	_check(save_button.disabled and load_button.disabled, "active generation disables Save/Load")
	runtime.conversation.cancel_generation()
	await process_frame
	save_input.text = "重要节点甲"
	save_input.text_changed.emit(save_input.text)
	save_button.pressed.emit()
	await process_frame
	_check(selector.item_count == 1 and selector.get_item_text(0) == "重要节点甲", "Save appears immediately in World surface")
	_check(result_label.text.contains("已保存当前进度"), "Save success is player-readable")

	_accept(runtime, "未来行动", "未来回应")
	await process_frame
	_check(entries.get_child_count() == 4, "future Narrative appears before Load")
	selector.select(0)
	load_button.pressed.emit()
	_check(confirmation.title.contains("重要节点甲") and confirmation.dialog_text.contains("读取前的当前进度会被自动保护"), "Load identifies target and states protected high-impact intent")
	confirmation.confirmed.emit()
	await process_frame
	await process_frame
	_check(runtime.conversation.get_durable_accepted_entries().size() == 1, "Load restores Domain Conversation")
	_check(entries.get_child_count() == 2 and _rich_text(entries.get_child(0)) == "保存时行动", "Load full-redraw removes future visual blocks")

	save_input.text = "故障存档"
	save_input.text_changed.emit(save_input.text)
	save_button.pressed.emit()
	await process_frame
	_accept(runtime, "读取失败前未来", "读取失败前回应")
	await process_frame
	var before_count := entries.get_child_count()
	var bad_index := _find_item(selector, "故障存档")
	var bad_id := String(selector.get_item_metadata(bad_index))
	_check(_corrupt_anchor(database_path, bad_id), "isolated bad-anchor fixture installed")
	selector.select(bad_index)
	load_button.pressed.emit()
	confirmation.confirmed.emit()
	await process_frame
	_check(entries.get_child_count() == before_count and runtime.conversation.get_durable_accepted_entries().size() == 2, "failed Load leaves Narrative/Domain unchanged")
	_check(result_label.text.contains("当前进度没有改变"), "failed Load shows player-readable non-destructive result")

	instance.queue_free()
	await process_frame
	runtime.close()
	print("G3-04 UI | done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)


func _accept(runtime: RefCounted, player: String, gm: String) -> void:
	if runtime.conversation.begin_turn(player) == null:
		_check(false, "begin Turn %s" % player)
		return
	runtime.conversation.append_delta(gm)
	_check(runtime.complete_active_generation_durably().success, "durable accept %s" % player)


func _find_item(selector: OptionButton, text: String) -> int:
	for index: int in range(selector.item_count):
		if selector.get_item_text(index) == text: return index
	return -1


func _corrupt_anchor(path: String, save_id: String) -> bool:
	var db := SQLite.new(); db.path = path; db.default_extension = ""
	if not db.open_db(): return false
	var ok: bool = db.query_with_bindings("UPDATE save_points SET timeline_node_id='missing-ui-anchor' WHERE save_id=?;", [save_id])
	db.close_db()
	return ok


func _rich_text(block: Node) -> String:
	for child: Node in block.get_children():
		if child is RichTextLabel: return (child as RichTextLabel).get_parsed_text()
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G3-04 UI PASS | %s" % label)
	else:
		_failures += 1
		printerr("G3-04 UI FAIL | %s" % label)


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix): return argument.trim_prefix(prefix)
	return ""


func _finish_failure(message: String) -> void:
	printerr("G3-04 UI FAIL | %s" % message)
	quit(1)
