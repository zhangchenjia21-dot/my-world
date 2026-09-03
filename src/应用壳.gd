extends Control

## my world 正式 Application / Game Shell。
## 职责边界：拥有 Application 与当前 Game Session 的 composition/lifecycle，以及三 Host
## Slot 的宽/窄响应式布局；不承载 Game / World / Timeline 领域语义。
## Narrative 交互逻辑在 src/ui/叙事对话视图.gd（NarrativeHost 节点）。

const CurrentGameRuntime := preload("res://src/runtime/当前游戏会话运行时.gd")
const GameLibrary := preload("res://src/游戏库/L3_外交层/游戏库公开接口.gd")
const SourceLibrary := preload("res://src/source/L3_外交层/Source库公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const FirstOpening := preload("res://src/首次开场/L3_外交层/首次开场公开接口.gd")
const ActionAdjudication := preload("res://src/行动判定/L3_外交层/行动判定公开接口.gd")
const ModelRuntimeSettings := preload("res://src/运行时设置/L3_外交层/模型运行时设置公开接口.gd")
const AgencyCycle := preload("res://src/世界回合/L3_外交层/行动代理循环公开接口.gd")
const WorldTurnRules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")
const WorldTurn := preload("res://src/世界回合/L3_外交层/世界回合公开接口.gd")

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
## G4-06 created Game 的 durable setup 自声明 schema；仅用于决定是否挂载 G4-07A opening runtime。
const GAME_LOCAL_SETUP_SCHEMA := "game_local_setup.v0.1"

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
@onready var model_settings_button: Button = %ModelSettingsButton
@onready var model_settings_overlay: CenterContainer = %ModelSettingsOverlay
@onready var model_option: OptionButton = %ModelOption
@onready var context_option: OptionButton = %ContextOption
@onready var reasoning_option: OptionButton = %ReasoningOption
@onready var model_settings_note: Label = %ModelSettingsNote
@onready var credential_label: Label = %CredentialLabel
@onready var summary_label: Label = %SummaryLabel
@onready var settings_result_label: Label = %SettingsResultLabel
@onready var settings_save_button: Button = %SettingsSaveButton
@onready var settings_cancel_button: Button = %SettingsCancelButton
@onready var opening_banner: PanelContainer = %OpeningBanner
@onready var opening_banner_label: Label = %OpeningBannerLabel
@onready var opening_retry_button: Button = %OpeningRetryButton
@onready var opening_cancel_button: Button = %OpeningCancelButton

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
## created Game 的 G4-07A opening runtime；随 Game Session 挂载/拆除，归 Application 拥有。
var opening_runtime: Node = null
## Game-local materialized Public d20 capability 存在时挂载的 G4-08 行动判定 Host。
var action_adjudication: Node = null
## durable Conversation acceptance 后运行的独立 best-effort semantic lane；不拥有 Narrative/UI truth。
var world_turn_runtime: Node = null
var agency_cycle_runtime: Node = null
## 测试专用 seam：focused/real-vertical 测试在激活前注入 stub 或受控 adapter；production 恒为 null。
var test_opening_adapter_override: Node = null
var test_adjudication_adapter_override: Node = null
var test_adjudication_rng_override: RefCounted = null
var test_world_turn_adapter_override: Node = null
## Opening UI 状态机："" / streaming / accepted / failed / cancelled；终态处理幂等。
var _opening_state := ""
## 模型设置 UI：backend 接口与当前编辑候选（未保存；预览只走 inspect_candidate）。
var model_settings: RefCounted = null
var _settings_candidate: Dictionary = {}
var _settings_persisted_invalid := false


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
	new_game_wizard.final_create_requested.connect(_on_final_create_requested)
	opening_retry_button.pressed.connect(_on_opening_retry_pressed)
	opening_cancel_button.pressed.connect(_on_opening_cancel_pressed)
	model_settings_button.pressed.connect(_show_model_settings)
	settings_save_button.pressed.connect(_on_settings_save_pressed)
	settings_cancel_button.pressed.connect(_on_settings_cancel_pressed)
	model_option.item_selected.connect(func(_index: int) -> void: _on_settings_control_changed())
	context_option.item_selected.connect(func(_index: int) -> void: _on_settings_control_changed())
	reasoning_option.item_selected.connect(func(_index: int) -> void: _on_settings_control_changed())
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
	_prepare_world_turn_after_activation()
	_prepare_action_adjudication_after_activation()
	_prepare_opening_after_activation()
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
	_teardown_agency_cycle()
	_teardown_world_turn_runtime()
	_teardown_action_adjudication()
	_teardown_opening_runtime()
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


func _prepare_world_turn_after_activation() -> void:
	if session_runtime == null or not session_runtime.is_ready() or world_turn_runtime != null:
		return
	world_turn_runtime = WorldTurn.new(session_runtime, test_world_turn_adapter_override)
	add_child(world_turn_runtime)
	# G5-03M1：Agency Cycle 复用 WorldTurn 的 semantic finished 结果；不新增 selector 调用。
	world_turn_runtime.finished.connect(_on_world_turn_finished)


func _on_world_turn_finished(result: Dictionary) -> void:
	if session_runtime == null or not session_runtime.is_ready():
		return
	# C01 修正 A：stale semantic handoff 不得启动 Agency。
	# 要求：source turn 仍是 latest accepted ordinary turn、source GM hash 仍匹配、
	# Conversation 空闲、foreground 未在 semantic 完成前开始新 attempt。
	var candidates: Array = result.get("agency_candidates", [])
	if candidates.is_empty():
		return
	var source_turn_index := int(result.get("source_turn_index", -1))
	var source_gm_sha256 := String(result.get("source_gm_sha256", ""))
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	if entries.is_empty() or source_turn_index != entries.size() - 1:
		return
	var current := entries[source_turn_index] as Dictionary
	if WorldTurnRules.gm_sha256(String(current.get("gm_text", ""))) != source_gm_sha256:
		return
	if session_runtime.conversation.is_generating():
		return
	if agency_cycle_runtime != null:
		agency_cycle_runtime.shutdown()
		agency_cycle_runtime.queue_free()
		agency_cycle_runtime = null
	agency_cycle_runtime = AgencyCycle.new(session_runtime)
	add_child(agency_cycle_runtime)
	var cycle_base_head_id := String(session_runtime.active_head_id)
	agency_cycle_runtime.start_cycle(source_turn_index, source_gm_sha256, cycle_base_head_id, candidates)


func _teardown_agency_cycle() -> void:
	if agency_cycle_runtime == null:
		return
	agency_cycle_runtime.shutdown()
	if is_instance_valid(agency_cycle_runtime):
		remove_child(agency_cycle_runtime)
		agency_cycle_runtime.queue_free()
	agency_cycle_runtime = null


func _teardown_world_turn_runtime() -> void:
	if world_turn_runtime == null:
		return
	world_turn_runtime.shutdown()
	if is_instance_valid(world_turn_runtime):
		remove_child(world_turn_runtime)
		world_turn_runtime.queue_free()
	world_turn_runtime = null


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


## ---- 模型设置（Main Menu only）----
## UI 只投影与交互；backend inspect_candidate 拥有兼容性/有效值真相。

const SETTINGS_MODEL_ORDER := ["deepseek_v4_pro", "deepseek_v4_flash", "kimi_k3", "kimi_k27"]
const SETTINGS_CONTEXT_ORDER := ["256k", "1m"]
const SETTINGS_REASONING_ORDER := ["low", "medium", "high", "max"]
const SETTINGS_CONTEXT_LABELS := {"256k": "256K", "1m": "1M"}
const SETTINGS_REASONING_LABELS := {"low": "Low", "medium": "Medium", "high": "High", "max": "Max"}


func _ensure_model_settings() -> void:
	if model_settings != null:
		return
	model_settings = ModelRuntimeSettings.new(_model_settings_path())


func _model_settings_path() -> String:
	var argument := _command_argument("--settings-path=")
	if not argument.is_empty():
		return argument
	return OS.get_environment("MY_WORLD_TEST_SETTINGS_PATH").strip_edges()


func _show_model_settings() -> void:
	if application_state != ApplicationState.MENU_READY or model_settings_overlay.visible:
		return
	_ensure_model_settings()
	var loaded: Dictionary = model_settings.load_settings()
	_settings_persisted_invalid = false
	if loaded.success:
		_settings_candidate = (loaded.settings as Dictionary).duplicate(true)
	else:
		# invalid persisted：以 L3 冻结默认作编辑起点，但不静默保存；玩家显式 Save 才覆盖。
		_settings_persisted_invalid = true
		_settings_candidate = model_settings.validated_default_settings()
	_populate_settings_controls()
	_refresh_settings_projection()
	if _settings_persisted_invalid:
		settings_result_label.text = "已保存的设置无效；已载入默认值供修改，保存后生效。"
		settings_result_label.visible = true
		settings_result_label.add_theme_color_override("font_color", Color(0.90, 0.52, 0.46))
	main_menu_surface.visible = false
	model_settings_overlay.visible = true
	settings_cancel_button.grab_focus.call_deferred()


func _populate_settings_controls() -> void:
	model_option.clear()
	for profile_id: String in SETTINGS_MODEL_ORDER:
		model_option.add_item(_model_display_name(profile_id))
	context_option.clear()
	for context_limit: String in SETTINGS_CONTEXT_ORDER:
		context_option.add_item(String(SETTINGS_CONTEXT_LABELS[context_limit]))
	reasoning_option.clear()
	for reasoning: String in SETTINGS_REASONING_ORDER:
		reasoning_option.add_item(String(SETTINGS_REASONING_LABELS[reasoning]))
	model_option.selected = maxi(0, SETTINGS_MODEL_ORDER.find(String(_settings_candidate.get("profile_id", "deepseek_v4_pro"))))
	context_option.selected = maxi(0, SETTINGS_CONTEXT_ORDER.find(String(_settings_candidate.get("context_limit", "256k"))))
	reasoning_option.selected = maxi(0, SETTINGS_REASONING_ORDER.find(String(_settings_candidate.get("reasoning_request", "high"))))


func _model_display_name(profile_id: String) -> String:
	return String((model_settings.catalog()[profile_id] as Dictionary).display_name)


func _candidate_from_controls() -> Dictionary:
	return {
		"profile_id": SETTINGS_MODEL_ORDER[clampi(model_option.selected, 0, SETTINGS_MODEL_ORDER.size() - 1)],
		"context_limit": SETTINGS_CONTEXT_ORDER[clampi(context_option.selected, 0, SETTINGS_CONTEXT_ORDER.size() - 1)],
		"reasoning_request": SETTINGS_REASONING_ORDER[clampi(reasoning_option.selected, 0, SETTINGS_REASONING_ORDER.size() - 1)],
	}


func _on_settings_control_changed() -> void:
	_settings_candidate = _candidate_from_controls()
	_refresh_settings_projection()


## 未保存候选只走 backend inspect_candidate；不复制 provider 政策，不写设置文件。
func _refresh_settings_projection() -> void:
	_ensure_model_settings()
	var candidate := _candidate_from_controls()
	var inspected: Dictionary = model_settings.inspect_candidate(candidate)
	var availability: Dictionary = model_settings.credential_availability()
	var deepseek_ok := bool((availability["deepseek"] as Dictionary).configured)
	var kimi_ok := bool((availability["kimi"] as Dictionary).configured)
	credential_label.text = "DeepSeek：%s　Kimi：%s" % ["已配置" if deepseek_ok else "未配置", "已配置" if kimi_ok else "未配置"]
	if not inspected.success:
		settings_save_button.disabled = true
		# inspect 失败但 C01A partial candidate 保留 capability truth：
		# 禁 context/思考控件、保留固定思考说明，不伪造 graded effective。
		var partial: Dictionary = inspected.get("candidate", {})
		if not partial.is_empty():
			var partial_allowed: Array = partial.get("allowed_context_limits", [])
			for index: int in SETTINGS_CONTEXT_ORDER.size():
				context_option.set_item_disabled(index, not partial_allowed.has(SETTINGS_CONTEXT_ORDER[index]))
			var partial_fixed := bool(partial.get("fixed_thinking", false))
			reasoning_option.disabled = partial_fixed
			if partial_fixed:
				model_settings_note.text = "Kimi K2.7 当前仅支持 256K，并使用固定 Thinking ON；不提供 Low/Medium/High/Max 选择。"
				model_settings_note.visible = true
			else:
				model_settings_note.visible = false
			summary_label.text = ""
		else:
			model_settings_note.visible = false
			summary_label.text = ""
		settings_result_label.text = _plain_settings_failure(String(inspected.get("status", "")))
		settings_result_label.visible = true
		settings_result_label.add_theme_color_override("font_color", Color(0.90, 0.52, 0.46))
		return
	var projection: Dictionary = inspected.candidate
	settings_save_button.disabled = false
	settings_result_label.visible = false
	var fixed := bool(projection.fixed_thinking)
	reasoning_option.disabled = fixed
	var allowed: Array = projection.allowed_context_limits
	for index: int in SETTINGS_CONTEXT_ORDER.size():
		context_option.set_item_disabled(index, not allowed.has(SETTINGS_CONTEXT_ORDER[index]))
	if fixed:
		model_settings_note.text = "Kimi K2.7 当前仅支持 256K，并使用固定 Thinking ON；不提供 Low/Medium/High/Max 选择。"
		model_settings_note.visible = true
	elif not allowed.has(String(projection.context_limit)):
		model_settings_note.text = "当前模型不支持所选上下文上限。"
		model_settings_note.visible = true
	else:
		model_settings_note.visible = false
	summary_label.text = "实际配置摘要：%s" % _settings_summary_text(projection)
	if not bool(projection.credential_configured):
		settings_result_label.text = "当前模型的凭证未配置；保存后生成将失败，直到配置凭证。"
		settings_result_label.visible = true
		settings_result_label.add_theme_color_override("font_color", Color(0.90, 0.66, 0.46))


## 摘要只来自 backend 投影：Medium 必披露实际 High；K2.7 显示固定思考。
func _settings_summary_text(projection: Dictionary) -> String:
	if bool(projection.fixed_thinking):
		return "%s · %s · 固定思考" % [String(projection.display_name), String(SETTINGS_CONTEXT_LABELS[String(projection.context_limit)])]
	var requested := String(projection.reasoning_requested)
	var effective := String(projection.reasoning_effective)
	var reasoning_text := String(SETTINGS_REASONING_LABELS[requested])
	if requested != effective:
		reasoning_text += "（实际 %s）" % String(SETTINGS_REASONING_LABELS[effective])
	return "%s · %s · %s" % [String(projection.display_name), String(SETTINGS_CONTEXT_LABELS[String(projection.context_limit)]), reasoning_text]


func _plain_settings_failure(status: String) -> String:
	match status:
		"incompatible_context_limit":
			return "当前模型不支持所选上下文上限；请调整后再保存。"
		"unknown_profile", "unknown_context_limit", "unknown_reasoning_request", "invalid_settings":
			return "当前组合无效；请调整后再保存。"
		_:
			return "当前组合无法保存；请调整后再试。"


func _on_settings_save_pressed() -> void:
	_ensure_model_settings()
	var saved: Dictionary = model_settings.save_settings(_candidate_from_controls())
	if not saved.success:
		settings_result_label.text = _plain_settings_failure(String(saved.get("status", "")))
		settings_result_label.visible = true
		settings_result_label.add_theme_color_override("font_color", Color(0.90, 0.52, 0.46))
		return
	_close_model_settings("已保存模型设置。")


func _on_settings_cancel_pressed() -> void:
	_close_model_settings("")


func _close_model_settings(message: String) -> void:
	model_settings_overlay.visible = false
	main_menu_surface.visible = true
	_settings_candidate = {}
	_settings_persisted_invalid = false
	menu_result_label.text = message
	if not message.is_empty():
		menu_result_label.add_theme_color_override("font_color", Color(0.58, 0.78, 0.62))
	model_settings_button.grab_focus.call_deferred()


## 设置面板打开时 Escape/ui_cancel = Cancel：不退出应用、不保存、恢复焦点到模型设置。
func _unhandled_input(event: InputEvent) -> void:
	if model_settings_overlay.visible and event.is_action_pressed("ui_cancel"):
		_on_settings_cancel_pressed()
		get_viewport().set_input_as_handled()


## Wizard 提交 frozen Review payload。creation_id 由 Wizard 在一次 attempt 内固定；
## 成功后经 existing-only open 进入刚创建的 exact Game，失败时 Game 不删除不重建。
func _on_final_create_requested(creation_id: String, composition: Dictionary) -> void:
	if application_state != ApplicationState.MENU_READY or session_state != SessionState.ABSENT:
		new_game_wizard.create_failed("当前无法创建游戏；请返回主菜单后重试。")
		return
	_ensure_game_library()
	var creator := FinalCreate.new(
		SourceLibrary.new(_source_library_root()),
		_creation_root(),
		_game_library_root(),
		_managed_games_root()
	)
	var created: Dictionary = creator.create_or_resume(creation_id, composition)
	if not created.success:
		new_game_wizard.create_failed(_plain_create_failure(created))
		return
	new_game_wizard.create_succeeded()
	_open_created_game(String(created.game_id))


## 创建成功后的 open 必须 existing-only；打开失败不删除已创建 Game，引导 Continue 重试。
func _open_created_game(game_id: String) -> void:
	var opened: Dictionary = open_registered_game(game_id)
	if opened.success:
		return
	_show_main_menu()
	menu_result_label.text = "游戏已创建；本次进入未完成。可在主菜单使用「继续游戏」重试。"
	menu_result_label.add_theme_color_override("font_color", Color(0.90, 0.52, 0.46))
	print("[shell] create succeeded but open failed: %s" % String(opened.get("status", opened.get("code", "unknown"))))


## 玩家可读创建失败：不暴露内部码/fingerprint/path。
func _plain_create_failure(result: Dictionary) -> String:
	var code := String(result.get("code", result.get("status", "")))
	match code:
		"composition_incomplete", "composition_invalid":
			return "创建未完成：开局信息不完整。请返回检查选择与设置后重试。"
		"character_temporal_incompatible":
			return "创建未完成：阵容中有角色不适用于所选开局。请返回调整开局或角色。"
		"exact_generation_unavailable", "exact_generation_mismatch":
			return "创建未完成：所选资料版本在本机已不可用。请返回重新选择后重试。"
		"payload_conflict", "creation_conflict":
			return "创建未完成：本次创建与已存在的创建请求不一致。请返回主菜单重新开始。"
		_:
			return "创建未完成，未创建任何游戏。可直接重试；若反复失败请退出后重试。"


## created Game 激活后挂载 G4-07A opening runtime：
## - 始终挂载：玩家行动也经由 durable continuation context 组装；
## - durable accepted Conversation = 0（legal opening-pending）时自动开始第一幕并锁住输入；
## - 已 accepted 的 Game 绝不自动再生成第一幕。
func _prepare_opening_after_activation() -> void:
	if session_runtime == null or not session_runtime.is_ready():
		return
	if String(session_runtime.world_state.get("schema_version", "")) != GAME_LOCAL_SETUP_SCHEMA:
		return
	var opening_adapter: Node = test_opening_adapter_override if is_instance_valid(test_opening_adapter_override) else null
	opening_runtime = FirstOpening.new(session_runtime, opening_adapter)
	add_child(opening_runtime)
	opening_runtime.finished.connect(_on_opening_finished)
	narrative_view.bind_opening_runtime(opening_runtime)
	if session_runtime.conversation.get_durable_accepted_entries().is_empty():
		narrative_view.set_opening_gate(true)
		_begin_first_opening()


func _begin_first_opening() -> void:
	if opening_runtime == null or session_runtime == null or not session_runtime.is_ready():
		return
	_opening_state = "streaming"
	_show_opening_banner("正在生成第一幕…", false, true)
	status_label.text = "状态：正在生成第一幕…"
	var started: Dictionary = opening_runtime.start_first_opening()
	if _opening_state != "streaming":
		# 同步终态已由 finished 处理，避免二次落地。
		return
	if started.success and String(started.get("status", "")) == "streaming":
		return
	# 资格类失败（如 already_opened / invalid_game_setup）不经过 finished，直接落地。
	_handle_opening_terminal(started)


func _on_opening_finished(result: Dictionary) -> void:
	_handle_opening_terminal(result)


func _handle_opening_terminal(result: Dictionary) -> void:
	if _opening_state != "streaming":
		return
	var status := String(result.get("status", ""))
	if status == "accepted" or status == "already_opened":
		_opening_state = "accepted"
		opening_banner.visible = false
		narrative_view.set_opening_gate(false)
		status_label.text = "状态：就绪"
		_update_save_controls()
		return
	_opening_state = "cancelled" if status == "cancelled" else "failed"
	var message := "第一幕已取消；本局已保存，可随时重试。" if status == "cancelled" \
		else "第一幕生成未完成：%s本局已保存，可直接重试。" % _plain_opening_failure(status, String(result.get("message", "")))
	_show_opening_banner(message, true, false)
	status_label.text = "状态：第一幕未完成"
	_update_save_controls()


func _on_opening_retry_pressed() -> void:
	_begin_first_opening()


func _on_opening_cancel_pressed() -> void:
	if opening_runtime != null and _opening_state == "streaming":
		opening_runtime.cancel()


func _show_opening_banner(message: String, show_retry: bool, show_cancel: bool) -> void:
	opening_banner_label.text = message
	opening_retry_button.visible = show_retry
	opening_cancel_button.visible = show_cancel
	opening_banner.visible = true


## 玩家可读 Opening 失败：不暴露内部码，key 配置说明与 View 一致。
func _plain_opening_failure(status: String, _message: String) -> String:
	match status:
		"missing_key":
			return "未检测到当前所选模型的 API Key，请在本机 .env.local 中配置对应凭据；"
		"transport":
			return "暂时无法连接当前模型服务；"
		"malformed_stream":
			return "收到了无法识别的响应数据；"
		"empty_generation", "empty_opening":
			return "本次没有生成有效开场；"
		"persistence_failure":
			return "开场未能安全保存；"
		_:
			if status.begins_with("http_"):
				return "当前模型服务暂时返回异常；"
			return ""


## 能力路由只读 Game-local materialized state（INV-D20-01）：永不读 SourceLibrary.current。
## 无 Expansion 时不挂载 Host，View 保持既有 G4-07 单次续玩路径。
## 未知 action_resolution capability 必须 fail loud：玩家可见、锁输入、不走 legacy。
func _prepare_action_adjudication_after_activation() -> void:
	if session_runtime == null or not session_runtime.is_ready():
		return
	var expansions: Array = session_runtime.world_state.get("expansions", [])
	for value: Variant in expansions:
		if not value is Dictionary:
			continue
		var expansion := value as Dictionary
		if String(expansion.get("capability_slot", "")) != "action_resolution":
			continue
		if String(expansion.get("capability_id", "")) != "action_check.public_d20.v1":
			narrative_view.show_unsupported_capability()
			return
		action_adjudication = ActionAdjudication.new(session_runtime, test_adjudication_adapter_override, test_adjudication_rng_override)
		add_child(action_adjudication)
		narrative_view.bind_action_adjudication(action_adjudication)
		return


func _teardown_action_adjudication() -> void:
	if action_adjudication == null:
		return
	if is_instance_valid(action_adjudication):
		remove_child(action_adjudication)
		action_adjudication.queue_free()
	action_adjudication = null


func _teardown_opening_runtime() -> void:
	if opening_runtime == null:
		return
	var finished_callback := Callable(self, "_on_opening_finished")
	if opening_runtime.finished.is_connected(finished_callback):
		opening_runtime.finished.disconnect(finished_callback)
	if _opening_state == "streaming":
		opening_runtime.cancel()
	remove_child(opening_runtime)
	opening_runtime.queue_free()
	opening_runtime = null
	_opening_state = ""
	opening_banner.visible = false


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
	conversation.attempt_started.connect(_on_foreground_attempt_started)
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
	# C01 修正 B：production Restore 自动 invalidate 剩余 uncommitted Agency。
	if agency_cycle_runtime != null:
		agency_cycle_runtime.invalidate_remaining()
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


## Foreground 永远优先：新 Conversation attempt 使剩余 uncommitted agency 失效。
func _on_foreground_attempt_started(_turn: RefCounted) -> void:
	if agency_cycle_runtime != null:
		agency_cycle_runtime.invalidate_remaining()


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


## 自动化只可显式设置 task-owned creation root；normal product 始终使用固定 user:// root。
func _creation_root() -> String:
	var argument := _command_argument("--creation-root=")
	if not argument.is_empty():
		return argument
	var test_override := OS.get_environment("MY_WORLD_TEST_CREATION_ROOT").strip_edges()
	return test_override if not test_override.is_empty() else "user://my-world/creation-protocol"


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
