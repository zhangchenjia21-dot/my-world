extends Control

## my world 正式 Application / Game Shell。
## 职责边界：拥有 Application 与当前 Game Session 的 composition/lifecycle，以及三 Host
## Slot 的宽/窄响应式布局；不承载 Game / World / Timeline 领域语义。
## Narrative 交互逻辑在 src/ui/叙事对话视图.gd（NarrativeHost 节点）。

const CurrentGameRuntime := preload("res://src/runtime/当前游戏会话运行时.gd")
const GameLibrary := preload("res://src/游戏库/L3_外交层/游戏库公开接口.gd")
const SourceLibrary := preload("res://src/source/L3_外交层/Source库公开接口.gd")

enum ApplicationState {
	BOOTING,
	MENU_READY,
	OPENING_GAME,
	GAME_ACTIVE,
	EXITING,
}

enum SessionState {
	ABSENT,
	OPENING,
	READY,
	CLOSING,
	FAILED,
}

## 窄窗口阈值：低于该宽度时左右 Host 折叠为 TopBar toggle，Narrative 保持主角（DEC-02）。
const NARROW_BREAKPOINT := 1100.0
const G3_01_EXPORT_SPIKE_FEATURE := "g3_01_persistence_spike"

@onready var status_label: Label = %StatusLabel
@onready var exit_button: Button = %ExitButton
@onready var return_menu_button: Button = %ReturnMenuButton
@onready var main_menu_surface: Control = %MainMenuSurface
@onready var continue_button: Button = %ContinueButton
@onready var new_game_button: Button = %NewGameButton
@onready var quit_button: Button = %QuitButton
@onready var menu_result_label: Label = %MenuResultLabel
@onready var new_game_surface: Control = %NewGameSurface
@onready var new_game_wizard: Control = %NewGameWizard
@onready var new_game_back_button: Button = new_game_wizard.cancel_button
@onready var game_surface: Control = $Margin
@onready var narrative_view: Control = %NarrativeHost
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
@onready var startup_failure_back_button: Button = %StartupFailureBackButton

var application_state: ApplicationState = ApplicationState.BOOTING
var session_state: SessionState = SessionState.ABSENT
var _narrow := false
## Application composition root 唯一持有的 current Game runtime；UI 只绑定引用。
var session_runtime: Variant = null
## Game Library 只保存 Application selection/index；active gameplay truth 仍由 session_runtime/SQLite 拥有。
var game_library: RefCounted = null
var active_game_record: RefCounted = null
var _pending_load_save_id := ""
var _isolated_narrative_test_mode := false


func _enter_tree() -> void:
	# Application boot 只建立 Main Menu；Game DB 只能由显式 Continue 打开。
	pass


func _ready() -> void:
	if OS.has_feature(G3_01_EXPORT_SPIKE_FEATURE):
		_run_g3_01_export_spike()
		return
	_ensure_game_library()
	exit_button.pressed.connect(_request_exit)
	return_menu_button.pressed.connect(_return_to_main_menu)
	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_show_new_game_surface)
	quit_button.pressed.connect(_request_exit)
	new_game_wizard.cancelled.connect(_cancel_new_game)
	player_toggle.toggled.connect(_on_player_toggle)
	world_toggle.toggled.connect(_on_world_toggle)
	create_save_button.pressed.connect(_on_create_save_pressed)
	load_save_button.pressed.connect(_on_load_save_pressed)
	load_confirmation.confirmed.connect(_on_load_confirmed)
	recover_button.pressed.connect(_on_recover_pressed)
	recover_confirmation.confirmed.connect(_on_recover_confirmed)
	database_recovery_button.pressed.connect(_on_database_recovery_pressed)
	database_recovery_confirmation.confirmed.connect(_on_database_recovery_confirmed)
	startup_failure_back_button.pressed.connect(_dismiss_startup_failure)
	save_name_input.text_changed.connect(_on_save_name_changed)
	_update_responsive_layout()
	if session_runtime != null:
		# 既有 scene tests 会在 add_child 前注入 task-owned、已打开 Runtime；production 不走此路。
		if session_runtime.is_ready():
			_activate_game_surface()
		else:
			_show_session_startup_failure(session_runtime.startup_result)
	elif _isolated_narrative_test_mode:
		_show_isolated_narrative_test_surface()
	else:
		_show_main_menu()
	_update_save_controls()
	_run_g3_06_export_smoke_if_requested()
	_run_g4_01_export_smoke_if_requested.call_deferred()


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
	# 历史 export smoke 显式携带 task-owned DB；G4-01 后仍需先走同一 Session open seam。
	var smoke_startup: Dictionary = {}
	if session_runtime == null:
		smoke_startup = _open_game_session()
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
			var blocked := String(smoke_startup.get("status", "")) == "already_running" or (session_runtime != null and String(session_runtime.startup_result.get("status", "")) == "already_running")
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


## G4-01 exported EXE 的 task-owned lifecycle evidence。只在显式 smoke args 下运行；
## normal product 不自动 Continue，亦不触碰默认 user:// Current Game。
func _run_g4_01_export_smoke_if_requested() -> void:
	var mode := ""
	var proof_path := ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--g4-01-smoke-mode="):
			mode = argument.trim_prefix("--g4-01-smoke-mode=")
		elif argument.begins_with("--g4-01-proof="):
			proof_path = argument.trim_prefix("--g4-01-proof=")
	if mode.is_empty():
		return
	var database_path := _product_database_path()
	if database_path.find("g4_01") < 0 or proof_path.find("g4_01") < 0:
		push_error("G4-01 EXPORT SMOKE FAIL | task-owned DB/proof paths required")
		get_tree().quit(1)
		return
	match mode:
		"menu_absent":
			var okay := application_state == ApplicationState.MENU_READY \
				and session_state == SessionState.ABSENT \
				and session_runtime == null \
				and main_menu_surface.visible \
				and not FileAccess.file_exists(database_path)
			_write_g4_01_smoke_proof(proof_path, {"mode": mode, "success": okay, "db_absent": not FileAccess.file_exists(database_path)})
			print("G4-01 EXPORT MENU PASS" if okay else "G4-01 EXPORT MENU FAIL")
			get_tree().quit(0 if okay else 1)
		"lifecycle":
			continue_button.pressed.emit()
			await get_tree().process_frame
			var first_ready: bool = session_runtime != null and bool(session_runtime.is_ready())
			var first_game_id := String(session_runtime.game_id) if first_ready else ""
			if first_ready:
				return_menu_button.pressed.emit()
			await get_tree().process_frame
			var closed := session_runtime == null and session_state == SessionState.ABSENT and main_menu_surface.visible
			var lock_probe := CurrentGameRuntime.new()
			var probe: Dictionary = lock_probe.open_current_game(database_path) if closed else {"success": false}
			var lock_released := bool(probe.get("success", false))
			if lock_released:
				lock_probe.close()
			continue_button.pressed.emit()
			await get_tree().process_frame
			var reopened: bool = session_runtime != null and bool(session_runtime.is_ready()) and String(session_runtime.game_id) == first_game_id
			if reopened:
				return_menu_button.pressed.emit()
			await get_tree().process_frame
			var okay: bool = first_ready and closed and lock_released and reopened and session_runtime == null
			_write_g4_01_smoke_proof(proof_path, {
				"mode": mode,
				"success": okay,
				"first_ready": first_ready,
				"closed": closed,
				"lock_released": lock_released,
				"reopened_same_game": reopened,
			})
			print("G4-01 EXPORT LIFECYCLE PASS" if okay else "G4-01 EXPORT LIFECYCLE FAIL")
			get_tree().quit(0 if okay else 1)
		_:
			push_error("G4-01 EXPORT SMOKE FAIL | unknown mode")
			get_tree().quit(1)


func _write_g4_01_smoke_proof(path: String, result: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("G4-01 EXPORT SMOKE FAIL | proof file unavailable")
		return
	file.store_string(JSON.stringify(result, "", true, true))
	file.close()


## Windows 窗口关闭与界面“退出”按钮走同一条正式退出路径。
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_request_exit()
	elif what == NOTIFICATION_RESIZED:
		_update_responsive_layout()


func _request_exit() -> void:
	if application_state == ApplicationState.EXITING:
		return
	application_state = ApplicationState.EXITING
	status_label.text = "状态：正在退出…"
	print("[shell] state=exiting")
	_close_game_session()
	get_tree().quit()


## Continue 只解析显式 current record；无 current 时唯一兼容分支是原位 legacy adoption。
## Main Menu boot 本身仍不探测或预开任何 Game DB。
func _on_continue_pressed() -> void:
	if application_state != ApplicationState.MENU_READY or session_state != SessionState.ABSENT:
		return
	_open_game_session()


func _open_game_session() -> Dictionary:
	_ensure_game_library()
	var selected: Dictionary = game_library.resolve_current_existing_game()
	if selected.success:
		return _open_resolved_game(selected.record)
	if String(selected.get("code", "")) == "no_current_selection":
		return _open_and_adopt_legacy_game()
	return _show_library_open_failure(selected)


## G4-04 narrow select/switch seam。若 A 正在运行，必须先完整 close A，再 resolve/open B；
## B 的任何失败都不会让两个 writable Runtime 同时存在。
func open_registered_game(game_id: String) -> Dictionary:
	_ensure_game_library()
	if session_runtime != null:
		_close_game_session()
		_show_main_menu()
	if application_state != ApplicationState.MENU_READY or session_state != SessionState.ABSENT:
		return {"success": false, "status": "invalid_application_state", "message": "Application 当前不能切换 Game。"}
	var resolved: Dictionary = game_library.resolve_existing_game(game_id)
	if not resolved.success:
		return _show_library_open_failure(resolved)
	return _open_resolved_game(resolved.record)


## 后续 Final Create 可复用的窄登记 seam：这里只接受已存在 managed path，并通过真实 Runtime
## 打开/identity cross-check 后登记；不会创建 DB、Source pin 或 Game-local materialization。
func register_existing_managed_game(game_id: String, display_name: String) -> Dictionary:
	_ensure_game_library()
	var path_result: Dictionary = game_library.managed_database_path(game_id)
	if not path_result.success:
		return path_result
	var runtime: Variant = CurrentGameRuntime.new()
	var opened: Dictionary = runtime.open_existing_game(String(path_result.path))
	if not opened.success:
		runtime.close()
		return opened
	var verified_id := String(runtime.game_id)
	runtime.close()
	if verified_id != game_id:
		return {"success": false, "code": "game_identity_mismatch", "message": "managed path 内部 Game identity 与登记 intent 不一致。"}
	return game_library.register_verified_managed_game(game_id, display_name, verified_id)


func _open_and_adopt_legacy_game() -> Dictionary:
	var legacy_path: String = game_library.legacy_database_path()
	if not FileAccess.file_exists(legacy_path):
		return _show_library_open_failure({"success": false, "code": "no_existing_game", "message": "当前没有可继续的游戏。"})
	_begin_session_open("正在验证现有游戏…")
	var runtime: Variant = CurrentGameRuntime.new()
	var startup: Dictionary = runtime.open_existing_game(legacy_path)
	session_runtime = runtime
	if not startup.success:
		_show_session_startup_failure(startup)
		return startup
	var verified_id := String(runtime.game_id)
	var registered: Dictionary = game_library.register_verified_legacy_game(verified_id, "现有游戏", verified_id)
	if not registered.success:
		return _abort_open_for_library_failure(registered)
	var current: Dictionary = game_library.commit_current(verified_id, verified_id)
	if not current.success:
		return _abort_open_for_library_failure(current)
	active_game_record = current.record
	_activate_game_surface()
	startup["game_record"] = current.record
	startup["adopted_legacy"] = true
	return startup


func _open_resolved_game(record: RefCounted) -> Dictionary:
	_begin_session_open("正在打开所选游戏…")
	var runtime: Variant = CurrentGameRuntime.new()
	var startup: Dictionary = runtime.open_existing_game(record.database_path)
	session_runtime = runtime
	if not startup.success:
		_show_session_startup_failure(startup)
		return startup
	if String(runtime.game_id) != String(record.game_id):
		runtime.close()
		session_runtime = null
		return _show_library_open_failure({"success": false, "code": "game_identity_mismatch", "message": "Game Library record 与数据库内部 identity 不一致。"})
	var committed: Dictionary = game_library.commit_current(String(record.game_id), String(runtime.game_id))
	if not committed.success:
		return _abort_open_for_library_failure(committed)
	active_game_record = committed.record
	_activate_game_surface()
	startup["game_record"] = committed.record
	return startup


func _begin_session_open(message: String) -> void:
	application_state = ApplicationState.OPENING_GAME
	session_state = SessionState.OPENING
	_set_menu_busy(true)
	menu_result_label.text = message
	menu_result_label.add_theme_color_override("font_color", Color(0.72, 0.74, 0.82))


func _abort_open_for_library_failure(failure: Dictionary) -> Dictionary:
	if session_runtime != null:
		session_runtime.close()
		session_runtime = null
	active_game_record = null
	return _show_library_open_failure(failure)


func _show_library_open_failure(failure: Dictionary) -> Dictionary:
	var startup := {
		"success": false,
		"status": String(failure.get("code", failure.get("status", "game_library_failure"))),
		"message": String(failure.get("message", "无法解析所选游戏。")),
	}
	_show_session_startup_failure(startup)
	return startup


func _activate_game_surface() -> void:
	if session_runtime == null or not session_runtime.is_ready():
		return
	narrative_view.bind_session_runtime(session_runtime)
	session_state = SessionState.READY
	application_state = ApplicationState.GAME_ACTIVE
	main_menu_surface.visible = false
	new_game_surface.visible = false
	game_surface.visible = true
	startup_failure_overlay.visible = false
	database_recovery_button.visible = false
	status_label.text = "状态：就绪"
	_connect_save_runtime()
	_refresh_save_points()
	_refresh_recovery_availability()
	_update_save_controls()
	_update_responsive_layout()
	print("[shell] application=game_active session=ready")


func _return_to_main_menu() -> void:
	if application_state != ApplicationState.GAME_ACTIVE:
		return
	_close_game_session()
	_show_main_menu()


## 关闭顺序固定为 Provider transport -> View callbacks -> Runtime/SQLite/writer lock。
## accepted truth 已在每次 completion 前 durable，不依赖本函数做最后保存。
func _close_game_session() -> Dictionary:
	if session_runtime == null:
		session_state = SessionState.ABSENT
		return {"status": "absent", "success": true}
	session_state = SessionState.CLOSING
	if narrative_view != null:
		narrative_view.shutdown_session()
	var closed: Dictionary = session_runtime.close()
	session_runtime = null
	active_game_record = null
	session_state = SessionState.ABSENT
	_pending_load_save_id = ""
	_reset_session_controls()
	print("[shell] session=absent close_status=%s" % String(closed.get("status", "unknown")))
	return closed


func _show_main_menu() -> void:
	if application_state == ApplicationState.EXITING:
		return
	application_state = ApplicationState.MENU_READY
	if session_runtime == null:
		session_state = SessionState.ABSENT
	game_surface.visible = false
	new_game_surface.visible = false
	new_game_wizard.discard()
	main_menu_surface.visible = true
	startup_failure_overlay.visible = false
	database_recovery_button.visible = false
	menu_result_label.text = ""
	_set_menu_busy(false)
	continue_button.grab_focus.call_deferred()
	print("[shell] application=menu_ready session=%s" % SessionState.keys()[session_state].to_lower())


func _show_new_game_surface() -> void:
	if application_state != ApplicationState.MENU_READY or session_state != SessionState.ABSENT:
		return
	main_menu_surface.visible = false
	game_surface.visible = false
	new_game_surface.visible = true
	var started: Dictionary = new_game_wizard.begin(SourceLibrary.new(_source_library_root()))
	if started.success:
		new_game_wizard.next_button.grab_focus.call_deferred()
	else:
		new_game_back_button.grab_focus.call_deferred()


func _cancel_new_game() -> void:
	if not new_game_surface.visible or session_runtime != null:
		return
	_show_main_menu()


func _show_session_startup_failure(startup: Dictionary) -> void:
	application_state = ApplicationState.MENU_READY
	session_state = SessionState.FAILED
	game_surface.visible = false
	new_game_surface.visible = false
	main_menu_surface.visible = true
	var status := String(startup.get("status", "startup_failure"))
	if status in ["physical_corruption", "interrupted_recovery"]:
		# G3-07：唯一恢复动作与中央失败说明相邻；Application Menu 不隐藏 recovery。
		startup_failure_label.text = "当前游戏数据已损坏，无法安全使用。可恢复到最近安全备份；备份后的进度可能丢失，损坏原件会保留。"
		startup_failure_overlay.visible = true
		database_recovery_button.visible = bool(startup.get("recovery_available", false))
		menu_result_label.text = "当前游戏无法安全打开。"
		_set_menu_busy(true)
		if not database_recovery_button.visible and session_runtime != null:
			# 无 verified backup 时没有理由继续占有 writer；失败说明仍留在 Application surface。
			session_runtime.close()
			session_runtime = null
	else:
		var player_message := String(startup.get("message", "当前游戏暂时无法打开。"))
		menu_result_label.text = player_message
		menu_result_label.add_theme_color_override("font_color", Color(0.90, 0.52, 0.46))
		startup_failure_overlay.visible = false
		database_recovery_button.visible = false
		if session_runtime != null:
			session_runtime.close()
		session_runtime = null
		session_state = SessionState.ABSENT
		_set_menu_busy(false)
	print("[shell] application=menu_ready session_failure=%s" % status)


func _set_menu_busy(busy: bool) -> void:
	continue_button.disabled = busy
	new_game_button.disabled = busy
	quit_button.disabled = false


func _reset_session_controls() -> void:
	save_selector.clear()
	save_name_input.clear()
	save_result_label.text = ""
	recovery_separator.visible = false
	recovery_hint.visible = false
	recover_button.visible = false
	_update_save_controls()


## G2 view-focused tests 可显式选择无 Persistence 的隔离 surface；默认 `--script` 不启用。
func enable_isolated_narrative_test_mode() -> void:
	_isolated_narrative_test_mode = true
	var view: Variant = get_node_or_null("%NarrativeHost")
	if view != null:
		view.enable_isolated_test_mode()


func _show_isolated_narrative_test_surface() -> void:
	application_state = ApplicationState.GAME_ACTIVE
	main_menu_surface.visible = false
	new_game_surface.visible = false
	game_surface.visible = true
	_update_responsive_layout()


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


func _dismiss_startup_failure() -> void:
	if session_runtime != null:
		session_runtime.close()
		session_runtime = null
	active_game_record = null
	session_state = SessionState.ABSENT
	startup_failure_overlay.visible = false
	database_recovery_button.visible = false
	_show_main_menu()


func _on_database_recovery_confirmed() -> void:
	if session_runtime == null:
		return
	var result: Dictionary = session_runtime.recover_damaged_database()
	# recovery publish 后旧 Runtime 不得继续承载 Session；释放 writer 后由下一次 Continue reopen。
	session_runtime.close()
	session_runtime = null
	active_game_record = null
	session_state = SessionState.ABSENT
	database_recovery_button.visible = false
	startup_failure_overlay.visible = false
	menu_result_label.text = String(result.message)
	if result.success or String(result.status) == "reopen_required":
		menu_result_label.add_theme_color_override("font_color", Color(0.58, 0.78, 0.62))
	else:
		menu_result_label.add_theme_color_override("font_color", Color(0.90, 0.52, 0.46))
	_set_menu_busy(false)


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


func _ensure_game_library() -> void:
	if game_library != null:
		return
	game_library = GameLibrary.new(_game_library_root(), _managed_games_root(), _product_database_path())


func _game_library_root() -> String:
	var argument := _command_argument("--game-library-root=")
	if not argument.is_empty():
		return argument
	var test_override := OS.get_environment("MY_WORLD_TEST_GAME_LIBRARY_ROOT").strip_edges()
	return test_override if not test_override.is_empty() else "user://my-world/game-library"


func _managed_games_root() -> String:
	var argument := _command_argument("--managed-games-root=")
	if not argument.is_empty():
		return argument
	var test_override := OS.get_environment("MY_WORLD_TEST_GAMES_ROOT").strip_edges()
	return test_override if not test_override.is_empty() else "user://my-world/games"


func _source_library_root() -> String:
	var argument := _command_argument("--source-library-root=")
	if not argument.is_empty():
		return argument
	var test_override := OS.get_environment("MY_WORLD_TEST_SOURCE_LIBRARY_ROOT").strip_edges()
	return test_override if not test_override.is_empty() else "user://my-world/source-library"


func _command_argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


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
