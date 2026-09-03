class_name WorldTurnContextPublicInterface
extends RefCounted

const Projector := preload("res://src/世界回合/L1_器件层/世界回合上下文投影器.gd")

var _projector := Projector.new()


## 返回 committed + current Conversation hash-matching 的 bounded derived request material；
## 不暴露内部可变 record，也不把投影反写 World/Conversation。
func project(world_state: Dictionary, accepted_entries: Array) -> Dictionary:
	return _projector.project(world_state, accepted_entries)
