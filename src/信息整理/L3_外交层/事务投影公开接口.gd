extends RefCounted

const Device := preload("res://src/信息整理/L1_器件层/事务快照投影器.gd")

## 当前玩家安全事务快照，仅 title/summary/details；无 ID/回执/hash 或 raw World。
## 纯读取，不调用 Provider、不回扫 Source、不改变任何持久状态。
static func project_session(runtime: Variant) -> Array:
	if runtime == null or not runtime.is_ready() or runtime.conversation == null:
		return []
	return Device.project(runtime.world_state, runtime.conversation.get_durable_accepted_entries())
