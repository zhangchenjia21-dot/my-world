class_name CharacterCardSourceProjection
extends RefCounted

## v0.2 保留 section-level disclosure 与 T0 profiles；v0.1 历史 public/private 栏位仍可回归。
var identity: Dictionary
var display_name: String
var catalog_summary: String
var semantic_sections: Array
var t0_profiles: Array
var public_profile: Dictionary
var gm_private_profile: Dictionary
var portrait: Dictionary
var player_character_supported: bool


func _init(data: Dictionary) -> void:
	identity = data.identity.duplicate(true)
	display_name = String(data.display_name)
	catalog_summary = String(data.catalog_summary)
	semantic_sections = data.semantic_sections.duplicate(true)
	t0_profiles = data.t0_profiles.duplicate(true)
	public_profile = data.public_profile.duplicate(true)
	gm_private_profile = data.gm_private_profile.duplicate(true)
	portrait = data.portrait.duplicate(true)
	player_character_supported = bool(data.player_character_supported)
