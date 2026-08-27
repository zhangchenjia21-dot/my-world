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

var shell_state: ShellState = ShellState.STARTING
var _narrow := false
## Application composition root 唯一持有的 current Game runtime；UI 只绑定引用。
var session_runtime: Variant = null


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
	_update_responsive_layout()
	if session_runtime != null and not session_runtime.is_ready():
		shell_state = ShellState.STARTING
		status_label.text = "状态：当前游戏恢复失败"
		print("[shell] state=resume_failed")
	else:
		shell_state = ShellState.READY
		status_label.text = "状态：就绪"
		print("[shell] state=ready")


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
