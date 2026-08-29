class_name GameLibraryRecordProjection
extends RefCounted

var game_id: String
var display_name: String
var storage_kind: String
var database_path: String


func _init(record: Dictionary) -> void:
	game_id = String(record.game_id)
	display_name = String(record.display_name)
	storage_kind = String(record.storage_kind)
	database_path = String(record.database_path)
