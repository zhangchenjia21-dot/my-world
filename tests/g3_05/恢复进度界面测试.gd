extends SceneTree

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")

var _failures := 0


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var database_path := _argument_value("--db=")
	if database_path.is_empty(): return _finish_failure("missing --db")
	var runtime := Runtime.new()
	_check(runtime.open_current_game(database_path).success, "isolated current Game opens")
	_accept(runtime, "存档时行动", "存档时回应")
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
	var load_confirmation: ConfirmationDialog = instance.get_node("%LoadConfirmation")
	var recovery_hint: Label = instance.get_node("%RecoveryHint")
	var recover_button: Button = instance.get_node("%RecoverButton")
	var recover_confirmation: ConfirmationDialog = instance.get_node("%RecoverConfirmation")
	var result_label: Label = instance.get_node("%SaveResultLabel")
	var entries: VBoxContainer = instance.get_node("%Entries")
	var world_host: PanelContainer = instance.get_node("%WorldSurfaceHost")
	var world_toggle: Button = instance.get_node("%WorldToggle")

	root.size = Vector2i(1280, 720)
	await process_frame
	_check(world_host.visible and not world_toggle.visible, "1280x720 keeps World Save/Recovery surface visible")
	root.size = Vector2i(960, 540)
	await process_frame
	world_toggle.button_pressed = true
	world_toggle.toggled.emit(true)
	_check(world_toggle.visible and world_host.visible, "960x540 exposes Save/Recovery through narrow toggle")
	root.size = Vector2i(1280, 720)
	await process_frame
	_check(not recovery_hint.visible and not recover_button.visible, "no Recovery does not show false affordance")

	save_input.text = "恢复目标"
	save_input.text_changed.emit(save_input.text)
	save_button.pressed.emit()
	await process_frame
	_accept(runtime, "Future A 行动", "Future A 回应")
	await process_frame
	selector.select(0)
	load_button.pressed.emit()
	_check(load_confirmation.dialog_text.contains("自动保护"), "Load confirmation explains automatic protection")
	load_confirmation.confirmed.emit()
	load_confirmation.hide()
	await process_frame
	await process_frame
	_check(recovery_hint.visible and recover_button.visible and recovery_hint.text.contains("可恢复"), "successful Load shows latest Recovery separately")
	_check(entries.get_child_count() == 2, "Load redraws exact saved Conversation")

	_accept(runtime, "Branch B 行动", "Branch B 回应")
	await process_frame
	_check(entries.get_child_count() == 4, "branch Narrative appears before Recover")
	runtime.conversation.retry_or_regenerate_latest()
	await process_frame
	_check(load_button.disabled and recover_button.disabled, "active generation disables Load and Recover")
	runtime.conversation.cancel_generation()
	await process_frame
	recover_button.pressed.emit()
	_check(recover_confirmation.dialog_text.contains("当前进度") and recover_confirmation.dialog_text.contains("自动保护"), "Recover confirmation states switch and reciprocal protection")
	recover_confirmation.confirmed.emit()
	await process_frame
	await process_frame
	var accepted: Array = runtime.conversation.get_durable_accepted_entries()
	_check(accepted.size() == 2 and String(accepted[-1].player_text) == "Future A 行动", "Recover restores displaced Future A Domain truth")
	_check(entries.get_child_count() == 4 and _rich_text(entries.get_child(2)) == "Future A 行动", "Recover full-redraw removes Branch B instead of mixing futures")
	_check(recovery_hint.visible and recover_button.visible, "Recover exposes reciprocal previous progress")
	_check(not recovery_hint.text.contains("head-") and not result_label.text.contains("recovery-"), "UI does not leak Timeline/Recovery ids")

	instance.queue_free()
	await process_frame
	runtime.close()
	print("G3-05 UI | done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)


func _accept(runtime: RefCounted, player: String, gm: String) -> void:
	if runtime.conversation.begin_turn(player) == null:
		_check(false, "begin Turn %s" % player)
		return
	runtime.conversation.append_delta(gm)
	_check(runtime.complete_active_generation_durably().success, "durable accept %s" % player)


func _rich_text(block: Node) -> String:
	for child: Node in block.get_children():
		if child is RichTextLabel: return (child as RichTextLabel).get_parsed_text()
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G3-05 UI PASS | %s" % label)
	else:
		_failures += 1
		printerr("G3-05 UI FAIL | %s" % label)


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix): return argument.trim_prefix(prefix)
	return ""


func _finish_failure(message: String) -> void:
	printerr("G3-05 UI FAIL | %s" % message)
	quit(1)
