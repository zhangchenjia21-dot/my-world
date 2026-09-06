class_name SourceContractRules
extends RefCounted

## Source 模块的稳定合同事实。这里不读取文件，也不拥有 Library、Game 或 Runtime 状态。

const WORLD_SCHEMA := "world_pack.v0.1"
const CHARACTER_SCHEMA := "character_card.v0.1"
const WORLD_SCHEMA_V2 := "world_pack.v0.2"
const CHARACTER_SCHEMA_V2 := "character_card.v0.2"
const EXPANSION_SCHEMA := "expansion_pack.v0.1"
const WORLD_TYPE := "world_pack"
const CHARACTER_TYPE := "character_card"
const EXPANSION_TYPE := "expansion_pack"
const MANIFEST_NAME := "source.json"

const WORLD_FIELDS := [
	"schema_version", "asset_id", "asset_type", "version", "display_name",
	"world_instructions", "gm_instructions", "source_lore", "entries",
	"authored_assets", "source_material",
]
const CHARACTER_FIELDS := [
	"schema_version", "asset_id", "asset_type", "version", "display_name",
	"public_profile", "gm_private_profile", "portrait", "player_character_supported",
]
const WORLD_FIELDS_V2 := [
	"schema_version", "asset_id", "asset_type", "version", "display_name",
	"catalog_summary", "world_instructions", "gm_instructions", "semantic_sections",
	"entries", "authored_assets",
]
const CHARACTER_FIELDS_V2 := [
	"schema_version", "asset_id", "asset_type", "version", "display_name",
	"catalog_summary", "semantic_sections", "t0_profiles", "portrait",
	"player_character_supported",
	"player_profile",
]
## MW-011 R2 / G6 decision §3：Character Card v0.2 的 optional player-facing
## presentation 字段边界；仅当字段存在时启用。
const PLAYER_PROFILE_FIELDS := ["headline", "summary", "groups"]
const PLAYER_PROFILE_GROUP_FIELDS := ["group_id", "title", "items"]
const PLAYER_PROFILE_HEADLINE_CHARS := 120
const PLAYER_PROFILE_SUMMARY_CHARS := 360
const PLAYER_PROFILE_GROUP_TITLE_CHARS := 60
const PLAYER_PROFILE_ITEM_CHARS := 160
const PLAYER_PROFILE_MAX_GROUPS := 8
const PLAYER_PROFILE_MAX_ITEMS := 8
const EXPANSION_FIELDS := [
	"schema_version", "asset_id", "asset_type", "version", "display_name",
	"catalog_summary", "capability_binding", "semantic_sections",
]
const DISCLOSURES := ["gm_reference", "gm_private"]
const COMPATIBILITY_EXACT_PROFILE := "exact_profile_match"
const COMPATIBILITY_NO_WORLD_COVERAGE := "no_world_coverage"
const COMPATIBILITY_TEMPORAL_INCOMPATIBLE := "temporal_incompatible"
const LIVE_STATE_FIELDS := [
	"current_timeline_head", "save_state", "current_conversation", "runtime_history",
	"current_location", "current_relationship", "current_injury", "current_condition",
	"current_knowledge", "current_inventory", "player_known", "opening_appearance",
	"current_context_membership",
]


static func success(values: Dictionary = {}) -> Dictionary:
	var result := {"success": true}
	result.merge(values, true)
	return result


static func failure(code: String, message: String) -> Dictionary:
	return {"success": false, "code": code, "message": message}


static func validate_identity(data: Dictionary, expected_schema: String, expected_type: String) -> Dictionary:
	for field: String in ["schema_version", "asset_id", "asset_type", "version"]:
		if not data.has(field) or not data[field] is String or String(data[field]).strip_edges().is_empty():
			return failure("missing_or_invalid_field", "必填身份字段无效：%s" % field)
	if String(data.schema_version) != expected_schema:
		return failure("unsupported_schema", "不支持的 schema_version：%s" % String(data.schema_version))
	if String(data.asset_type) != expected_type:
		return failure("unsupported_asset_type", "asset_type 必须是 %s。" % expected_type)
	var asset_id := String(data.asset_id)
	if asset_id.length() > 128 or not _is_safe_asset_id(asset_id):
		return failure("missing_or_invalid_field", "asset_id 只允许 a-z、0-9、点、下划线和连字符。")
	if String(data.version).length() > 64:
		return failure("missing_or_invalid_field", "version 长度不能超过 64。")
	return success()


## MW-011 R2：player_profile 存在时必须整体有效（fail-loud），shape 见 decision §3。
## 只接受 bounded 纯文本结构；禁止未知字段、嵌套对象、空项与超长文本。
static func validate_player_profile(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return failure("invalid_player_profile", "player_profile 必须是 object。")
	var profile := value as Dictionary
	if not _player_profile_exact_fields(profile, PLAYER_PROFILE_FIELDS):
		return failure("unknown_field", "player_profile 只允许 headline/summary/groups。")
	for field: String in ["headline", "summary"]:
		if typeof(profile[field]) != TYPE_STRING or String(profile[field]).strip_edges().is_empty():
			return failure("missing_or_invalid_field", "player_profile.%s 必须是非空字符串。" % field)
	if String(profile.headline).length() > PLAYER_PROFILE_HEADLINE_CHARS:
		return failure("invalid_cardinality", "player_profile.headline 超出 %d 字符。" % PLAYER_PROFILE_HEADLINE_CHARS)
	if String(profile.summary).length() > PLAYER_PROFILE_SUMMARY_CHARS:
		return failure("invalid_cardinality", "player_profile.summary 超出 %d 字符。" % PLAYER_PROFILE_SUMMARY_CHARS)
	if not profile.groups is Array or (profile.groups as Array).is_empty() or (profile.groups as Array).size() > PLAYER_PROFILE_MAX_GROUPS:
		return failure("invalid_cardinality", "player_profile.groups 必须是 1..%d 数组。" % PLAYER_PROFILE_MAX_GROUPS)
	var group_ids := {}
	for group_value: Variant in profile.groups:
		if not group_value is Dictionary:
			return failure("missing_or_invalid_field", "player_profile.groups 每项必须是 object。")
		var group := group_value as Dictionary
		if not _player_profile_exact_fields(group, PLAYER_PROFILE_GROUP_FIELDS):
			return failure("unknown_field", "player_profile group 只允许 group_id/title/items。")
		var group_id := validate_safe_token(group.group_id, "player_profile.group_id")
		if not group_id.success:
			return group_id
		if group_ids.has(String(group.group_id)):
			return failure("duplicate_id", "player_profile.group_id 重复：%s" % String(group.group_id))
		group_ids[String(group.group_id)] = true
		if typeof(group.title) != TYPE_STRING or String(group.title).strip_edges().is_empty():
			return failure("missing_or_invalid_field", "player_profile group title 必须是非空字符串。")
		if String(group.title).length() > PLAYER_PROFILE_GROUP_TITLE_CHARS:
			return failure("invalid_cardinality", "player_profile group title 超出 %d 字符。" % PLAYER_PROFILE_GROUP_TITLE_CHARS)
		if not group.items is Array or (group.items as Array).is_empty() or (group.items as Array).size() > PLAYER_PROFILE_MAX_ITEMS:
			return failure("invalid_cardinality", "player_profile group items 必须是 1..%d 数组。" % PLAYER_PROFILE_MAX_ITEMS)
		for item_value: Variant in group.items:
			if typeof(item_value) != TYPE_STRING or String(item_value).strip_edges().is_empty():
				return failure("missing_or_invalid_field", "player_profile item 必须是非空字符串。")
			if String(item_value).length() > PLAYER_PROFILE_ITEM_CHARS:
				return failure("invalid_cardinality", "player_profile item 超出 %d 字符。" % PLAYER_PROFILE_ITEM_CHARS)
	return success({"player_profile": profile.duplicate(true)})



static func validate_allowed_fields(data: Dictionary, allowed_fields: Array) -> Dictionary:
	var boundary := validate_no_live_state_fields(data)
	if not boundary.success:
		return boundary
	for raw_key: Variant in data.keys():
		if not raw_key is String:
			return failure("unknown_field", "Source 顶层字段名必须是字符串。")
		var key := String(raw_key)
		if LIVE_STATE_FIELDS.has(key):
			return failure("forbidden_source_field", "Source 不得拥有 Game-local/live 字段：%s" % key)
		if not allowed_fields.has(key):
			return failure("unknown_field", "未定义的 Source 顶层字段：%s" % key)
	return success()


## 禁止字段在任何结构层级都保持禁止；不能借 source_material/profile 嵌套绕过 Source/Game owner 边界。
static func validate_no_live_state_fields(value: Variant) -> Dictionary:
	if value is Dictionary:
		for raw_key: Variant in value.keys():
			var key := String(raw_key)
			if LIVE_STATE_FIELDS.has(key):
				return failure("forbidden_source_field", "Source 不得拥有 Game-local/live 字段：%s" % key)
			var nested := validate_no_live_state_fields(value[raw_key])
			if not nested.success:
				return nested
	elif value is Array:
		for item: Variant in value:
			var nested := validate_no_live_state_fields(item)
			if not nested.success:
				return nested
	return success()


static func validate_non_empty_text(data: Dictionary, field: String, maximum: int = 0) -> Dictionary:
	if not data.has(field) or not data[field] is String or String(data[field]).strip_edges().is_empty():
		return failure("missing_or_invalid_field", "字段必须是非空字符串：%s" % field)
	if maximum > 0 and String(data[field]).length() > maximum:
		return failure("missing_or_invalid_field", "字段超过最大长度：%s" % field)
	return success()


static func validate_string_array(value: Variant, field: String) -> Dictionary:
	if not value is Array:
		return failure("missing_or_invalid_field", "%s 必须是数组。" % field)
	for item: Variant in value:
		if not item is String or String(item).strip_edges().is_empty():
			return failure("missing_or_invalid_field", "%s 只能包含非空字符串。" % field)
	return success()


static func validate_safe_token(value: Variant, field: String) -> Dictionary:
	if not value is String or String(value).is_empty() or String(value) != String(value).strip_edges():
		return failure("missing_or_invalid_field", "%s 必须是非空安全 token。" % field)
	for index: int in String(value).length():
		var code := String(value).unicode_at(index)
		var allowed := (code >= 97 and code <= 122) or (code >= 48 and code <= 57) or code in [45, 46, 95]
		if not allowed:
			return failure("missing_or_invalid_field", "%s 只允许 a-z、0-9、点、下划线和连字符。" % field)
	return success()


static func _is_safe_asset_id(value: String) -> bool:
	for index: int in value.length():
		var code := value.unicode_at(index)
		var allowed := (code >= 97 and code <= 122) or (code >= 48 and code <= 57) or code in [45, 46, 95]
		if not allowed:
			return false
	return true

## MW-011 R2：player_profile 的 exact-fields 检查（本规则文件内的局部实现）。
static func _player_profile_exact_fields(value: Dictionary, fields: Array) -> bool:
	if value.size() != fields.size():
		return false
	for field: String in fields:
		if not value.has(field):
			return false
	return true
