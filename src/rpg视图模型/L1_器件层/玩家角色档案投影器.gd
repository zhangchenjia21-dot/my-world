class_name PlayerCharacterProfileProjectionDevice
extends RefCounted

## MW-011 R2 / G6 decision §6：Player Character Profile Projection。
## 输入只有 frozen Game-local `player_character.source_projection.player_profile`
## （Character Card v0.2 optional 字段，loader 已 fail-loud 验证、Final Create 已冻结）。
##
## fail-closed：缺失/无效/过期 profile 产生空投影，R1 紧凑 fallback 保持可用。
## 永不回退 semantic_sections / catalog_summary / Source Library current / raw world_state。
## 输出不含 internal IDs/hashes/fingerprints/instructions；确定性、无副作用、无 Provider。

const Rules := preload("res://src/source/L0_公理层/Source合同规则.gd")

const EMPTY_PROFILE := {
	"success": false,
	"headline": "",
	"summary": "",
	"groups": [],
}


## world_state（durable Game-local setup）→ 展示用 profile 投影。确定性。
static func project(world_state: Variant) -> Dictionary:
	if typeof(world_state) != TYPE_DICTIONARY:
		return EMPTY_PROFILE.duplicate(true)
	var player_value: Variant = (world_state as Dictionary).get("player_character", null)
	if typeof(player_value) != TYPE_DICTIONARY:
		return EMPTY_PROFILE.duplicate(true)
	var source_projection_value: Variant = (player_value as Dictionary).get("source_projection", null)
	if typeof(source_projection_value) != TYPE_DICTIONARY:
		return EMPTY_PROFILE.duplicate(true)
	var profile_value: Variant = (source_projection_value as Dictionary).get("player_profile", null)
	if typeof(profile_value) != TYPE_DICTIONARY or (profile_value as Dictionary).is_empty():
		return EMPTY_PROFILE.duplicate(true)
	# 冻结材料二次校验：即使被篡改也 fail-closed，不借宽松转换进入 UI。
	var validated: Dictionary = Rules.validate_player_profile(profile_value)
	if not validated.success:
		return EMPTY_PROFILE.duplicate(true)
	var profile := validated.player_profile as Dictionary
	var groups: Array = []
	for group_value: Variant in profile.groups:
		var group := group_value as Dictionary
		var items: Array = []
		for item_value: Variant in group.items:
			items.append(String(item_value))
		groups.append({
			"title": String(group.title),
			"items": items,
		})
	return {
		"success": true,
		"headline": String(profile.headline),
		"summary": String(profile.summary),
		"groups": groups,
	}
