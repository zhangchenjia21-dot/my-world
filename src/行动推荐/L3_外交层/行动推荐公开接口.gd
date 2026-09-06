extends "res://src/行动推荐/L2_流程层/行动推荐流程.gd"

const Adapter := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")

## Shell 为每次 Game 激活建立一个实例并加入树；必须在 Runtime close 前 shutdown。
## 仅消费 accepted Conversation/Restore，changed + snapshot 向 UI 提供五条可编辑草稿。
## adapter_override 是离线/受控验证 seam；默认严格使用当前配置的 Provider，无 fallback。
func _init(runtime: RefCounted, adapter_override: Node = null) -> void:
	_runtime = runtime
	_adapter = adapter_override if adapter_override != null else Adapter.new()
