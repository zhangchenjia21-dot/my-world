class_name ManagedSourceGenerationProjection
extends RefCounted

## managed_path 指向 Program 管理的 immutable generation；external authored path 不进入公开 installed truth。
var identity: Dictionary
var display_name: String
var managed_path: String
var source: RefCounted


func _init(metadata: Dictionary, generation_path: String, source_projection: RefCounted) -> void:
	identity = {
		"asset_type": String(metadata.asset_type),
		"asset_id": String(metadata.asset_id),
		"version": String(metadata.version),
		"generation_fingerprint": String(metadata.generation_fingerprint),
	}
	display_name = String(metadata.display_name)
	managed_path = generation_path
	source = source_projection
