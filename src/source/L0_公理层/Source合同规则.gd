class_name SourceContractRules
extends RefCounted

## Source 模块的稳定合同事实。这里不读取文件，也不拥有 Library、Game 或 Runtime 状态。

const WORLD_SCHEMA := "world_pack.v0.1"
const CHARACTER_SCHEMA := "character_card.v0.1"
const WORLD_SCHEMA_V2 := "world_pack.v0.2"
const CHARACTER_SCHEMA_V2 := "character_card.v0.2"
const WORLD_TYPE := "world_pack"
const CHARACTER_TYPE := "character_card"
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
