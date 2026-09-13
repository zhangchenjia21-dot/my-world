## 当前 Timeline 的 player-safe 机制上下文；纯投影、无 I/O，不返回内部记录。
extends "res://src/行动判定/L1_器件层/公开机制历史投影器.gd"

## 仅返回当前玩家公开 CHECK 的结构副本；无 Provider/I/O/持久化，也不改变既有 GM 上下文。
static func project_session(runtime: Variant) -> Array:
	if runtime == null or not runtime.is_ready() or runtime.conversation == null: return []
	return project_checks(runtime.world_state, runtime.conversation.get_durable_accepted_entries())


## 返回当前已接受机制的完整 bounded Narrative 文本，Context 不维护第二份机制状态。
static func project_context(runtime: Variant) -> String:
	return project(runtime.world_state, runtime.conversation.get_durable_accepted_entries())
