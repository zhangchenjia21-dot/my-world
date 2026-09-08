extends "res://src/行动推荐/L2_流程层/行动推荐流程.gd"

const CharacterProjection := preload("res://src/信息整理/L3_外交层/角色经历投影公开接口.gd")

const Adapter := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")

## Shell 为每次 Game 激活建立一个实例并加入树；必须在 Runtime close 前 shutdown。
## 请求启动时只读现有玩家安全 Character；不订阅 Character 更新、不等待 Curator，版本仍由 Conversation 拥有。
## 仅消费 accepted Conversation/Restore，changed + snapshot 向 UI 提供五组 label + 可编辑 draft 的独立副本。
## diagnostic_started/diagnostic_terminal 仅供会话观测 owner：请求版本、闭集原因和耗时；不含原文或凭据。
## adapter_override 是离线/受控验证 seam；默认严格使用当前配置的 Provider，无 fallback。
func _init(runtime: RefCounted, adapter_override: Node = null) -> void:
	_character_reader = func() -> Variant: return CharacterProjection.project_session(runtime).character
	_runtime = runtime
	_adapter = adapter_override if adapter_override != null else Adapter.new()
