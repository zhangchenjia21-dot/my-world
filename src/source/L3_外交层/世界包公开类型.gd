class_name WorldPackSourceProjection
extends RefCounted

## 跨模块只消费这份调用方自有 projection；Source 流程不会保留或接收其后续修改。
var identity: Dictionary
var display_name: String
var world_instructions: String
var gm_instructions: String
var source_lore: Array
var entries: Array
var authored_assets: Array
var source_material: Dictionary


func _init(data: Dictionary) -> void:
	identity = data.identity.duplicate(true)
	display_name = String(data.display_name)
	world_instructions = String(data.world_instructions)
	gm_instructions = String(data.gm_instructions)
	source_lore = data.source_lore.duplicate(true)
	entries = data.entries.duplicate(true)
	authored_assets = data.authored_assets.duplicate(true)
	source_material = data.source_material.duplicate(true)
