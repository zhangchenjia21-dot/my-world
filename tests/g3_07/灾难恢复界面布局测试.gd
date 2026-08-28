extends SceneTree

## G3-07 灾难恢复界面布局测试（DEC-05，真实窗口运行，非 headless）。
##
## 验证 Owner UAT 修正：启动被 physical_corruption 阻断且存在 verified backup 时，
## 唯一恢复动作 [恢复最近安全备份] 位于中央失败说明正下方，不再藏在右下角 BottomBar。
##
## 覆盖：
## - 1280x720 / Maximized / 960x540 三档分辨率下 overlay 可见、按钮紧邻说明下方且水平居中；
## - BottomBar 不再含恢复按钮（无第二个恢复动作）；
## - healthy READY：overlay 与按钮都隐藏；
## - 物理损坏但无 verified backup：overlay 显示说明，无可点击恢复动作；
## - 确认文案仍说明丢进度窗口 / 损坏原件保留 / 不是普通 Save/Load。
##
## 夹具全部为 task-owned 隔离 DB（--db 路径必须含 g3_07）。截图存 user://g3_07_shots/。

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")

var _failures := 0
var _shot_dir := "user://g3_07_shots"


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G3-07 UI PASS | %s" % label)
	else:
		_failures += 1
		push_error("G3-07 UI FAIL | %s" % label)


func _shot(shot_name: String) -> void:
	await process_frame
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, shot_name]
	image.save_png(path)
	print("G3-07 UI shot | %s" % ProjectSettings.globalize_path(path))


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix)
	return ""


func _corrupt(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("intentional G3-07 isolated physical corruption")
	file.close()


func _make_shell(runtime: Variant) -> Variant:
	var shell: Variant = load("res://src/main.tscn").instantiate()
	shell.session_runtime = runtime
	root.add_child(shell)
	return shell


## 按钮在中央失败说明正下方：按钮顶边在说明文本底边附近，且水平居中于窗口。
func _check_central_placement(shell: Variant, label_prefix: String) -> void:
	var overlay: CenterContainer = shell.startup_failure_overlay
	var text_label: Label = shell.startup_failure_label
	var button: Button = shell.database_recovery_button
	_check(overlay.visible, "%s overlay 可见" % label_prefix)
	_check(text_label.visible and not text_label.text.is_empty(), "%s 中央失败说明可见" % label_prefix)
	_check(button.visible, "%s 恢复按钮可见" % label_prefix)
	var label_rect := text_label.get_global_rect()
	var button_rect := button.get_global_rect()
	_check(button_rect.position.y >= label_rect.end.y - 1.0 and button_rect.position.y <= label_rect.end.y + 48.0,
		"%s 按钮紧邻说明正下方（dy=%d）" % [label_prefix, int(button_rect.position.y - label_rect.end.y)])
	var window_center := float(root.size.x) / 2.0
	var button_center := button_rect.get_center().x
	_check(absf(button_center - window_center) <= float(root.size.x) * 0.25,
		"%s 按钮水平居中（center=%d window_center=%d）" % [label_prefix, int(button_center), int(window_center)])
	var bottom_bar: Control = shell.get_node("Margin/Layout/BottomBar")
	_check(bottom_bar.find_child("DatabaseRecoveryButton", true, false) == null,
		"%s BottomBar 不再含恢复按钮（无第二个恢复动作）" % label_prefix)
	# 不遮挡 composer/Narrative 正常使用区：overlay 顶边在 TopBar 之下，面板完整落在窗口内。
	var panel_rect := overlay.get_global_rect()
	_check(panel_rect.position.y >= 40.0 and panel_rect.end.y <= root.size.y and panel_rect.end.x <= root.size.x,
		"%s overlay 完整落在窗口内且未盖住 TopBar" % label_prefix)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_shot_dir))
	var db_path := _argument("--db=")
	if db_path.find("g3_07") < 0:
		_failures += 1
		push_error("G3-07 UI FAIL | task-owned --db required")
		quit(1)
		return
	root.mode = Window.MODE_WINDOWED

	# ---- 场景 1：物理损坏 + verified backup，三档分辨率 ----
	var seed := Runtime.new()
	_check(seed.open_current_game(db_path).success, "夹具：隔离 Game 创建")
	_check(seed.create_save_point("G3-07 布局夹具").success, "夹具：verified backup 存在")
	seed.close()
	_corrupt(db_path)
	var damaged := Runtime.new()
	var startup: Dictionary = damaged.open_current_game(db_path)
	_check(String(startup.get("status", "")) == "physical_corruption" and bool(startup.get("recovery_available", false)),
		"夹具：physical_corruption + recovery_available")

	var shell: Variant = _make_shell(damaged)
	root.size = Vector2i(1280, 720)
	for i in range(10):
		await process_frame
	_check_central_placement(shell, "1280x720")
	await _shot("recovery_1280")

	root.mode = Window.MODE_MAXIMIZED
	for i in range(15):
		await process_frame
	_check(root.size.x > 1280, "Maximized 生效（width=%d）" % root.size.x)
	_check_central_placement(shell, "Maximized")
	await _shot("recovery_maximized")

	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(960, 540)
	for i in range(10):
		await process_frame
	_check_central_placement(shell, "960x540")
	await _shot("recovery_960")

	# 确认文案仍完整（丢进度窗口 / 原件保留 / 非普通 Save/Load）。
	shell.database_recovery_button.pressed.emit()
	await process_frame
	var confirm_text: String = shell.database_recovery_confirmation.dialog_text
	_check(confirm_text.contains("进度可能丢失") and confirm_text.contains("损坏原件会保留") and confirm_text.contains("不是普通存档读取"),
		"确认文案保留损失窗口/原件保留/区别于 Save-Load")
	shell.database_recovery_confirmation.hide()
	shell.queue_free()
	await process_frame
	damaged.close()

	# ---- 场景 2：物理损坏但无 verified backup → 无可点击恢复动作 ----
	var db2 := db_path.trim_suffix(".sqlite") + "_nobackup.sqlite"
	var seed2 := Runtime.new()
	_check(seed2.open_current_game(db2).success, "夹具2：隔离 Game 创建")
	seed2.close()
	# 删除 task-owned backup 目录，制造无 backup 状态。
	var backup_dir2 := "%s.recovery" % db2.trim_suffix(".sqlite")
	if DirAccess.dir_exists_absolute(backup_dir2):
		for f: String in DirAccess.get_files_at(backup_dir2):
			DirAccess.remove_absolute("%s/%s" % [backup_dir2, f])
		DirAccess.remove_absolute(backup_dir2)
	_corrupt(db2)
	var damaged2 := Runtime.new()
	var startup2: Dictionary = damaged2.open_current_game(db2)
	_check(String(startup2.get("status", "")) == "physical_corruption" and not bool(startup2.get("recovery_available", false)),
		"夹具2：physical_corruption 且无 verified backup")
	var shell2: Variant = _make_shell(damaged2)
	root.size = Vector2i(1280, 720)
	for i in range(8):
		await process_frame
	_check(shell2.startup_failure_overlay.visible, "无 backup：中央说明仍显示")
	_check(not shell2.database_recovery_button.visible, "无 backup：不提供可点击恢复动作")
	shell2.queue_free()
	await process_frame
	damaged2.close()

	# ---- 场景 3：healthy READY → overlay 与恢复动作都隐藏 ----
	var db3 := db_path.trim_suffix(".sqlite") + "_healthy.sqlite"
	var healthy := Runtime.new()
	_check(healthy.open_current_game(db3).success, "夹具3：健康隔离 Game 创建")
	var shell3: Variant = _make_shell(healthy)
	for i in range(8):
		await process_frame
	_check(not shell3.startup_failure_overlay.visible, "healthy：overlay 隐藏")
	_check(not shell3.database_recovery_button.visible, "healthy：恢复按钮隐藏")
	shell3.queue_free()
	healthy.close()
	await process_frame

	print("G3-07 UI | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
