class_name CharacterCardSourceProjection
extends RefCounted

## public 与 GM/private profile 始终分栏暴露；eligibility 不把 Character 锁成 player-only role。
var identity: Dictionary
var display_name: String
var public_profile: Dictionary
var gm_private_profile: Dictionary
var portrait: Dictionary
var player_character_supported: bool


func _init(data: Dictionary) -> void:
	identity = data.identity.duplicate(true)
	display_name = String(data.display_name)
	public_profile = data.public_profile.duplicate(true)
	gm_private_profile = data.gm_private_profile.duplicate(true)
	portrait = data.portrait.duplicate(true)
	player_character_supported = bool(data.player_character_supported)
