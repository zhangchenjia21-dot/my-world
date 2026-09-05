class_name PlayerSafeProjectionPublicInterface
extends RefCounted

## MW-009：player-safe 投影的唯一外交入口。调用方只注入 current Game Runtime；
## 本接口是 UI 与 omniscient Runtime truth 之间的 disclosure 边界——UI 只拿到
## 展示字段，永远拿不到 raw world_state / living_world / expansions / 内部 ID。

const Device := preload("res://src/玩家安全投影/L1_器件层/玩家安全投影器.gd")


## runtime 未就绪/缺 Conversation 时 fail-closed 为安全空投影。
func project_session(runtime: Variant) -> Dictionary:
	if runtime == null or not runtime.is_ready() or runtime.conversation == null:
		return Device.EMPTY_PROJECTION.duplicate(true)
	return Device.project(runtime.world_state, runtime.conversation.get_durable_accepted_entries())
