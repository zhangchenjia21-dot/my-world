extends "res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd"

var requests: Array = []

# 记录无 secret 的原始输入后调用正式 transport；不改 Provider、参数或响应。
func start_stream(messages: Array) -> Error:
	requests.append(messages.duplicate(true))
	return super.start_stream(messages)
