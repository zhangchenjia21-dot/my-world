extends Control

## my world 正式 Application / Game Shell。
## 职责边界：只拥有应用壳生命周期（STARTING -> READY -> EXITING）与三 Host Slot 的
## 宽/窄响应式布局；不承载 Game / World / Timeline 领域语义。
## Narrative 交互逻辑在 src/ui/叙事对话视图.gd（NarrativeHost 节点）。

const CurrentGameRuntime := preload("res://src/runtime/当前游戏会话运行时.gd")

enum ShellState {
	STARTING,
	READY,
	EXITING,
}

## 窄窗口阈值：低于该宽度时左右 Host 折叠为 TopBar toggle，Narrative 保持主角（DEC-02）。
const NARROW_BREAKPOINT := 1100.0
const G3_01_EXPORT_SPIKE_FEATURE := "g3_01_persistence_spike"

@onready var status_label: Label = %StatusLabel
@onready var exit_button: Button = %ExitButton
@onready var player_panel_host: PanelContainer = %PlayerPanelHost
@onready var world_surface_host: PanelContainer = %WorldSurfaceHost
@onready var player_toggle: Button = %PlayerToggle
@onready var world_toggle: Button = %WorldToggle
@onready var save_name_input: LineEdit = %SaveNameInput
@onready var create_save_button: Button = %CreateSaveButton
@onready var save_selector: OptionButton = %SaveSelector
@onready var load_save_button: Button = %LoadSaveButton
@onready var save_result_label: Label = %SaveResultLabel
@onready var load_confirmation: ConfirmationDialog = %LoadConfirmation
@onready var recovery_hint: Label = %RecoveryHint
@onready var recover_button: Button = %RecoverButton
@onready var recover_confirmation: ConfirmationDialog = %RecoverConfirmation
@onready var recovery_separator: HSeparator = %RecoverySeparator
@onready var database_recovery_button: Button = %DatabaseRecoveryButton
@onready var database_recovery_confirmation: ConfirmationDialog = %DatabaseRecoveryConfirmation
@onready var startup_failure_overlay: CenterContainer = %StartupFailureOverlay
@onready var startup_failure_label: Label = %StartupFailureLabel

var shell_state: ShellState = ShellState.STARTING
var _narrow := false
## Application composition root 唯一持有的 current Game runtime；UI 只绑定引用。
var session_runtime: Variant = null
var _pending_load_save_id := ""


func _enter_tree() -> void:
	if OS.has_feature(G3_01_EXPORT_SPIKE_FEATURE) or session_runtime != null:
		return
	# `--script` 进程默认是隔离测试，不得无意打开/创建真实 user:// Current Game。
	# G3-03 scene tests 会在 add_child 前显式注入 task-owned runtime。
	if "--script" in OS.get_cmdline_args():
		return
	session_runtime = CurrentGameRuntime.new()
	var startup: Dictionary = session_runtime.open_current_game(_product_database_path())
	if not startup.success:
		push_error("G3-03 startup failure [%s]: %s" % [startup.status, startup.get("engineering_cause", "")])


func _ready() -> void:
	if OS.has_feature(G3_01_EXPORT_SPIKE_FEATURE):
		_run_g3_01_export_spike()
		return
	exit_button.pressed.connect(_request_exit)
	player_toggle.toggled.connect(_on_player_toggle)
	world_toggle.toggled.connect(_on_world_toggle)
	create_save_button.pressed.connect(_on_create_save_pressed)
	load_save_button.pressed.connect(_on_load_save_pressed)
	load_confirmation.confirmed.connect(_on_load_confirmed)
	recover_button.pressed.connect(_on_recover_pressed)
	recover_confirmation.confirmed.connect(_on_recover_confirmed)
	database_recovery_button.pressed.connect(_on_database_recovery_pressed)
	database_recovery_confirmation.confirmed.connect(_on_database_recovery_confirmed)
	save_name_input.text_changed.connect(_on_save_name_changed)
	_update_responsive_layout()
	if session_runtime != null and not session_runtime.is_ready():
		shell_state = ShellState.STARTING
		var startup: Dictionary = session_runtime.startup_result
		if String(startup.get("status", "")) in ["physical_corruption", "interrupted_recovery"]:
			# DEC-05（G3-07）：失败说明与唯一恢复动作居中展示，按钮紧邻说明正下方；
			# 无 verified backup 时不提供可点击恢复动作；BottomBar 只保留短状态。
			startup_failure_label.text = "当前游戏数据已损坏，无法安全使用。可恢复到最近安全备份；备份后的进度可能丢失，损坏原件会保留。"
			startup_failure_overlay.visible = true
			database_recovery_button.visible = bool(startup.get("recovery_available", false))
			status_label.text = "状态：当前游戏数据已损坏"
		else:
			status_label.text = "状态：%s" % String(startup.get("message", "当前游戏恢复失败"))
		print("[shell] state=resume_failed")
	else:
		shell_state = ShellState.READY
		status_label.text = "状态：就绪"
		startup_failure_overlay.visible = false
		database_recovery_button.visible = false
		print("[shell] state=ready")
		_connect_save_runtime()
		_refresh_save_points()
		_refresh_recovery_availability()
	_update_save_controls()
	_run_g3_06_export_smoke_if_requested()


## 仅由 G3-01 专用 export preset 编译启用；正式 Windows Desktop preset 不含此 feature。
## 该入口只证明 GDExtension 随 exported EXE 打包后的 open/write/reopen，不承载产品 Save flow。
func _run_g3_01_export_spike() -> void:
	var database_path := ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--db="):
			database_path = argument.trim_prefix("--db=")
			break
	var spike_script: Script = load("res://tests/g3_01/导出持久化冒烟.gd")
	var succeeded: bool = spike_script.new().run(database_path)
	get_tree().quit(0 if succeeded else 1)


## exported EXE 验证仍走正式 Runtime/product startup；仅当显式 task-owned G3-06
## database 与 smoke mode 同时存在时写 marker/自动确认，绝不指向默认 user:// 数据。
func _run_g3_06_export_smoke_if_requested() -> void:
	var mode := ""
	var ready_path := ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--g3-06-smoke-mode="):
			mode = argument.trim_prefix("--g3-06-smoke-mode=")
		elif argument.begins_with("--g3-06-ready="):
			ready_path = argument.trim_prefix("--g3-06-ready=")
	if mode.is_empty():
		return
	var explicit_path := _product_database_path()
	if explicit_path.find("g3_06") < 0:
		push_error("G3-06 EXPORT SMOKE FAIL | task-owned database path required")
		get_tree().quit(1)
		return
	match mode:
		"hold":
			if session_runtime == null or not session_runtime.is_ready() or ready_path.is_empty():
				push_error("G3-06 EXPORT SMOKE FAIL | hold did not reach READY")
				get_tree().quit(1)
				return
			var marker := FileAccess.open(ready_path, FileAccess.WRITE)
			marker.store_string("pid=%d\n" % OS.get_process_id())
			marker.close()
			print("G3-06 EXPORT A READY | pid=%d" % OS.get_process_id())
		"expect_blocked":
			var blocked := session_runtime != null and String(session_runtime.startup_result.get("status", "")) == "already_running"
			print("G3-06 EXPORT B PASS | already_running" if blocked else "G3-06 EXPORT B FAIL")
			get_tree().quit(0 if blocked else 1)
		"recover":
			var recovered: Dictionary = session_runtime.recover_damaged_database() if session_runtime != null else {}
			var okay: bool = String(recovered.get("status", "")) == "reopen_required"
			print("G3-06 EXPORT RECOVERY PASS | staged replacement published" if okay else "G3-06 EXPORT RECOVERY FAIL")
			get_tree().quit(0 if okay else 1)
		"expect_recovered":
			var okay: bool = session_runtime != null and session_runtime.is_ready()
			if okay: session_runtime.close()
			print("G3-06 EXPORT REOPEN PASS | recovered current coherent" if okay else "G3-06 EXPORT REOPEN FAIL")
			get_tree().quit(0 if okay else 1)
		_:
			push_error("G3-06 EXPORT SMOKE FAIL | unknown mode")
			get_tree().quit(1)


## Windows 窗口关闭与界面“退出”按钮走同一条正式退出路径。
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_request_exit()
	elif what == NOTIFICATION_RESIZED:
		_update_responsive_layout()


func _request_exit() -> void:
	if shell_state == ShellState.EXITING:
		return
	shell_state = ShellState.EXITING
	status_label.text = "状态：正在退出…"
	print("[shell] state=exiting")
	if session_runtime != null:
		session_runtime.close()
	get_tree().quit()


func get_session_runtime() -> Variant:
	return session_runtime


func _connect_save_runtime() -> void:
	if session_runtime == null:
		return
	if session_runtime.has_signal("save_points_changed"):
		session_runtime.save_points_changed.connect(_on_save_points_changed)
	if session_runtime.has_signal("restore_completed"):
		session_runtime.restore_completed.connect(_on_restore_completed)
	if session_runtime.has_signal("recovery_availability_changed"):
		session_runtime.recovery_availability_changed.connect(_on_recovery_availability_changed)
	var conversation: Variant = session_runtime.conversation
	conversation.attempt_started.connect(_on_generation_state_changed)
	conversation.generation_completed.connect(_on_generation_state_changed)
	conversation.generation_cancelled.connect(_on_generation_state_changed)
	conversation.generation_failed.connect(_on_generation_failed_state_changed)


func _refresh_save_points() -> void:
	if session_runtime == null or not session_runtime.is_ready():
		return
	var listed: Dictionary = session_runtime.list_save_points()
	if not listed.success:
		_show_save_result("无法读取存档列表。", true)
		return
	_on_save_points_changed(listed.save_points)


func _on_save_points_changed(save_points: Array) -> void:
	save_selector.clear()
	for save_value: Variant in save_points:
		var save := save_value as Dictionary
		save_selector.add_item(String(save.display_name))
		save_selector.set_item_metadata(save_selector.item_count - 1, String(save.save_id))
	_update_save_controls()


func _on_create_save_pressed() -> void:
	if session_runtime == null:
		return
	var result: Dictionary = session_runtime.create_save_point(save_name_input.text)
	if not result.success:
		_show_save_result(String(result.message), true)
		_update_save_controls()
		return
	save_name_input.clear()
	_show_save_result(String(result.message) if bool(result.get("backup_warning", false)) else "已保存当前进度：%s" % String(result.display_name), bool(result.get("backup_warning", false)))
	_update_save_controls()


func _on_load_save_pressed() -> void:
	if save_selector.selected < 0 or save_selector.item_count == 0:
		return
	_pending_load_save_id = String(save_selector.get_item_metadata(save_selector.selected))
	var display_name := save_selector.get_item_text(save_selector.selected)
	load_confirmation.title = "读取存档「%s」" % display_name
	load_confirmation.dialog_text = "读取将切换当前进度到「%s」。读取前的当前进度会被自动保护，可通过“恢复读取前进度”找回。" % display_name
	load_confirmation.popup_centered()


func _on_load_confirmed() -> void:
	if session_runtime == null or _pending_load_save_id.is_empty():
		return
	var result: Dictionary = session_runtime.restore_save_point(_pending_load_save_id)
	_pending_load_save_id = ""
	if not result.success:
		_show_save_result(String(result.message), true)
		_update_save_controls()
		return
	if String(result.status) == "already_current":
		_show_save_result(String(result.message), false)
		_update_save_controls()
		return
	_show_save_result("已读取存档：%s" % String(result.display_name), false)
	status_label.text = "状态：已读取存档"
	_update_save_controls()


func _on_restore_completed(_result: Dictionary) -> void:
	_update_save_controls()


func _refresh_recovery_availability() -> void:
	if session_runtime == null or not session_runtime.is_ready():
		_on_recovery_availability_changed({"success": false, "available": false})
		return
	_on_recovery_availability_changed(session_runtime.get_recovery_availability())


func _on_recovery_availability_changed(recovery: Dictionary) -> void:
	var available := bool(recovery.get("success", false)) and bool(recovery.get("available", false))
	recovery_separator.visible = available
	recovery_hint.visible = available
	recover_button.visible = available
	if available:
		recovery_hint.text = "可恢复：最近一次进度切换前的进度（%s）" % String(recovery.get("created_at", "时间未知"))
	_update_save_controls()


func _on_recover_pressed() -> void:
	recover_confirmation.title = "恢复上一进度"
	recover_confirmation.dialog_text = "恢复会切换当前进度；你现在的进度也会被自动保护，因此之后仍可再次恢复回来。"
	recover_confirmation.popup_centered()


func _on_recover_confirmed() -> void:
	if session_runtime == null:
		return
	var result: Dictionary = session_runtime.recover_previous_progress()
	if not result.success:
		_show_save_result(String(result.message), true)
		_update_save_controls()
		return
	_show_save_result(String(result.get("message", "已恢复上一进度。")), false)
	status_label.text = "状态：已恢复上一进度"
	_update_save_controls()


func _on_database_recovery_pressed() -> void:
	database_recovery_confirmation.title = "恢复最近安全备份"
	database_recovery_confirmation.dialog_text = "当前游戏数据已损坏，无法安全使用。恢复会回到最近一份已验证的安全备份，备份之后的进度可能丢失；损坏原件会保留用于诊断。这不是普通存档读取。"
	database_recovery_confirmation.popup_centered()


func _on_database_recovery_confirmed() -> void:
	if session_runtime == null:
		return
	var result: Dictionary = session_runtime.recover_damaged_database()
	database_recovery_button.visible = false
	startup_failure_overlay.visible = false
	status_label.text = String(result.message)
	if result.success or String(result.status) == "reopen_required":
		status_label.add_theme_color_override("font_color", Color(0.58, 0.78, 0.62))
	else:
		status_label.add_theme_color_override("font_color", Color(0.90, 0.52, 0.46))


func _on_generation_state_changed(_turn: RefCounted) -> void:
	_update_save_controls()


func _on_generation_failed_state_changed(_turn: RefCounted, _code: String) -> void:
	_update_save_controls()


func _on_save_name_changed(_text: String) -> void:
	_update_save_controls()


func _update_save_controls() -> void:
	var ready: bool = session_runtime != null and bool(session_runtime.is_ready())
	var generating: bool = ready and bool(session_runtime.conversation.is_generating())
	save_name_input.editable = ready and not generating
	create_save_button.disabled = not ready or generating or save_name_input.text.strip_edges().is_empty()
	save_selector.disabled = not ready or generating or save_selector.item_count == 0
	load_save_button.disabled = not ready or generating or save_selector.item_count == 0
	recover_button.disabled = not ready or generating or not recover_button.visible


func _show_save_result(message: String, is_error: bool) -> void:
	save_result_label.text = message
	save_result_label.add_theme_color_override("font_color", Color(0.90, 0.52, 0.46) if is_error else Color(0.58, 0.78, 0.62))


func _product_database_path() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--current-game-db="):
			return argument.trim_prefix("--current-game-db=")
	# 自动化只可显式设置 task-owned path；normal product 未设置时始终使用集中 user:// path。
	var test_override := OS.get_environment("MY_WORLD_TEST_CURRENT_GAME_DB").strip_edges()
	if not test_override.is_empty():
		return test_override
	return CurrentGameRuntime.default_database_path()


func _on_player_toggle(pressed: bool) -> void:
	if _narrow:
		player_panel_host.visible = pressed


func _on_world_toggle(pressed: bool) -> void:
	if _narrow:
		world_surface_host.visible = pressed


func _update_responsive_layout() -> void:
	if not is_node_ready():
		return
	var narrow := size.x < NARROW_BREAKPOINT
	_narrow = narrow
	player_toggle.visible = narrow
	world_toggle.visible = narrow
	if narrow:
		# 窄窗口：侧 Host 由 toggle 控制，默认折叠。
		player_panel_host.visible = player_toggle.button_pressed
		world_surface_host.visible = world_toggle.button_pressed
	else:
		player_panel_host.visible = true
		world_surface_host.visible = true
