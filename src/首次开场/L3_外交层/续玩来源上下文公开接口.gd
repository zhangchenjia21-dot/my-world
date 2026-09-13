extends RefCounted

const Projector := preload("res://src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd")

## 仅从当前已打开 Game 的 exact durable setup 派生续玩块；不访问可变 Source。
static func project_session(runtime: Variant) -> Dictionary:
	return Projector.new().project_continuation(runtime.world_state)
