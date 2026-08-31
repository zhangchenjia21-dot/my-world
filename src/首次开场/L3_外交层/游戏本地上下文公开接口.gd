class_name GameLocalContextPublicInterface
extends RefCounted

const Projector := preload("res://src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd")

var _projector := Projector.new()


## 供其它模块从 durable Game-local World document 取得同一份 bounded-rich context；不接收 Wizard/Source current。
func project(world_state: Dictionary) -> Dictionary:
	return _projector.project(world_state)
