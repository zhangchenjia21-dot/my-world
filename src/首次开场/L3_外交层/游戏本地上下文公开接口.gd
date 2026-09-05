class_name GameLocalContextPublicInterface
extends RefCounted

const Projector := preload("res://src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd")

var _projector := Projector.new()


## 供其它模块从 durable Game-local World document 取得同一份 bounded-rich context；不接收 Wizard/Source current。
## MW-005 R2：include_style=false 仅供 Public d20 control/control_recovery mechanics
## adjudication——保留全部事实材料，只过滤 literary_style_reference。
func project(world_state: Dictionary, include_style: bool = true) -> Dictionary:
	return _projector.project(world_state, include_style)
