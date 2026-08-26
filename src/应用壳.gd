extends Control

## my world 正式 Application / Game Shell。
## 职责边界：只拥有应用壳生命周期与界面行为（STARTING -> READY -> EXITING），
## 不承载 Game / World / Timeline 等领域语义；不接 Provider，不做持久化。
## 当前唯一真实产品操作是正常退出；空状态文案保持诚实，不提供无行为的假按钮。

enum ShellState {
	STARTING,
	READY,
	EXITING,
}

@onready var status_label: Label = %StatusLabel
@onready var exit_button: Button = %ExitButton

var shell_state: ShellState = ShellState.STARTING


func _ready() -> void:
	exit_button.pressed.connect(_request_exit)
	shell_state = ShellState.READY
	status_label.text = "状态：就绪"
	print("[shell] state=ready")


## Windows 窗口关闭与界面“退出”按钮走同一条正式退出路径。
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_request_exit()


func _request_exit() -> void:
	if shell_state == ShellState.EXITING:
		return
	shell_state = ShellState.EXITING
	status_label.text = "状态：正在退出…"
	print("[shell] state=exiting")
	get_tree().quit()
