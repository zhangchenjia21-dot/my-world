extends Node

## G2-03 离线测试专用 adapter double（桩）：只实现 G2-02 seam 的最小表面
## —— 同名信号 + start_stream/cancel/is_busy，完全不触网、不读 key。
## 用途：T4–T6 专注验证叙事视图的 provisional history/context 记账逻辑；
## 真实 transport 行为由 T2/T3（真实 adapter）与 tests/g2_02_适配器冒烟测试.gd 覆盖。

signal text_delta(text: String)
signal completed()
signal cancelled()
signal failed(code: String, message: String)

## 记录每次 start_stream 收到的 messages，供测试断言 Provider context。
var start_calls: Array = []
var _busy := false


func start_stream(messages: Array) -> Error:
	start_calls.append(messages)
	_busy = true
	return OK


func cancel() -> void:
	if not _busy:
		return
	_busy = false
	cancelled.emit()


func is_busy() -> bool:
	return _busy


## 测试主动驱动终态时调用，保持 busy 记账一致。
func simulate_completed() -> void:
	_busy = false
	completed.emit()


func simulate_failed(code: String, message: String) -> void:
	_busy = false
	failed.emit(code, message)
