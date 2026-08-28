extends SceneTree

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")

var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var path := _argument("--db=")
	if path.find("g3_06") < 0:
		_fail("task-owned --db required"); _finish(); return
	var seed := Runtime.new()
	_check(seed.open_current_game(path).success, "isolated fixture opens")
	_check(seed.create_save_point("安全备份目标").success, "verified backup exists")
	seed.close()
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("intentional isolated Owner-UAT corruption")
	file.close()
	var damaged := Runtime.new()
	var startup: Dictionary = damaged.open_current_game(path)
	_check(startup.status == "physical_corruption" and bool(startup.recovery_available), "physical corruption exposes verified recovery candidate")

	var shell: Variant = load("res://src/main.tscn").instantiate()
	shell.session_runtime = damaged
	root.add_child(shell)
	await process_frame
	_check(shell.database_recovery_button.visible, "recovery action is visible")
	# G3-07 DEC-05：说明文案移到中央失败提示（startup_failure_label），BottomBar 只留短状态。
	_check(shell.startup_failure_overlay.visible, "central failure overlay is visible")
	_check(shell.startup_failure_label.text.contains("已损坏") and shell.startup_failure_label.text.contains("进度可能丢失") and shell.startup_failure_label.text.contains("损坏原件会保留"), "player copy explains damage, loss window, preservation")
	shell.database_recovery_button.pressed.emit()
	_check(shell.database_recovery_confirmation.dialog_text.contains("不是普通存档读取"), "confirmation distinguishes disaster recovery from Save/Load")
	shell.database_recovery_confirmation.confirmed.emit()
	await process_frame
	_check(shell.status_label.text.contains("请重新打开游戏"), "successful publication requires controlled reopen")
	_check(not shell.database_recovery_button.visible, "old Runtime cannot continue recovery action")
	shell.queue_free()
	await process_frame
	var reopened := Runtime.new()
	_check(reopened.open_current_game(path).success, "recovered fixture reopens exact product path")
	reopened.close()
	_finish()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G3-06 UI PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G3-06 UI FAIL | %s" % label)


func _finish() -> void:
	print("G3-06 UI | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix): return value.trim_prefix(prefix)
	return ""
