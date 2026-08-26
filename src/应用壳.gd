extends Control

## my world 正式 Application / Game Shell。
## 职责边界：只拥有应用壳生命周期（STARTING -> READY -> EXITING）与三 Host Slot 的
## 宽/窄响应式布局；不承载 Game / World / Timeline 领域语义。
## Narrative 交互逻辑在 src/ui/叙事对话视图.gd（NarrativeHost 节点）。

enum ShellState {
	STARTING,
	READY,
	EXITING,
}

## 窄窗口阈值：低于该宽度时左右 Host 折叠为 TopBar toggle，Narrative 保持主角（DEC-02）。
const NARROW_BREAKPOINT := 1100.0

@onready var status_label: Label = %StatusLabel
@onready var exit_button: Button = %ExitButton
@onready var player_panel_host: PanelContainer = %PlayerPanelHost
@onready var world_surface_host: PanelContainer = %WorldSurfaceHost
@onready var player_toggle: Button = %PlayerToggle
@onready var world_toggle: Button = %WorldToggle

var shell_state: ShellState = ShellState.STARTING
var _narrow := false


func _ready() -> void:
	exit_button.pressed.connect(_request_exit)
	player_toggle.toggled.connect(_on_player_toggle)
	world_toggle.toggled.connect(_on_world_toggle)
	_update_responsive_layout()
	shell_state = ShellState.READY
	status_label.text = "状态：就绪"
	print("[shell] state=ready")


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
	get_tree().quit()


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
