class_name SourceLibraryRules
extends RefCounted

## Managed Library 的稳定存储事实；不读取外部 package，也不拥有任何 Game 状态。

const WORLD_TYPE := "world_pack"
const CHARACTER_TYPE := "character_card"
const SUPPORTED_TYPES := [WORLD_TYPE, CHARACTER_TYPE]
const MANIFEST_NAME := "source.json"
const PRODUCTION_ROOT := "user://my-world/source-library"
const CURRENT_FIELDS := [
	"asset_type", "asset_id", "version", "generation_fingerprint", "display_name",
]


static func success(values: Dictionary = {}) -> Dictionary:
	var result := {"success": true}
	result.merge(values, true)
	return result


static func failure(code: String, message: String) -> Dictionary:
	return {"success": false, "code": code, "message": message}


static func validate_generation_identity(identity: Dictionary) -> Dictionary:
	for field: String in ["asset_type", "asset_id", "version", "generation_fingerprint"]:
		if not identity.has(field) or not identity[field] is String or String(identity[field]).is_empty():
			return failure("invalid_generation_identity", "Source generation 身份字段无效：%s" % field)
	if not SUPPORTED_TYPES.has(String(identity.asset_type)):
		return failure("unsupported_asset_type", "Managed Library 不支持 asset_type：%s" % identity.asset_type)
	if not _is_safe_path_segment(String(identity.asset_id)):
		return failure("invalid_generation_identity", "asset_id 不能安全映射为 Library 路径。")
	if not _is_sha256(String(identity.generation_fingerprint)):
		return failure("invalid_generation_identity", "generation_fingerprint 必须是 SHA-256 hex。")
	return success()


static func validate_current_metadata(metadata: Dictionary) -> Dictionary:
	if metadata.size() != CURRENT_FIELDS.size():
		return failure("invalid_current_metadata", "current metadata 字段集合无效。")
	for field: String in CURRENT_FIELDS:
		if not metadata.has(field) or not metadata[field] is String or String(metadata[field]).is_empty():
			return failure("invalid_current_metadata", "current metadata 字段无效：%s" % field)
	var identity := validate_generation_identity(metadata)
	if not identity.success:
		return failure("invalid_current_metadata", String(identity.message))
	return success()


static func current_metadata(source: RefCounted) -> Dictionary:
	return {
		"asset_type": String(source.identity.asset_type),
		"asset_id": String(source.identity.asset_id),
		"version": String(source.identity.version),
		"generation_fingerprint": String(source.identity.generation_fingerprint),
		"display_name": String(source.display_name),
	}


static func contract_owned_paths(source: RefCounted) -> Array[String]:
	var paths: Array[String] = [MANIFEST_NAME]
	if String(source.identity.asset_type) == WORLD_TYPE:
		for declaration: Dictionary in source.authored_assets:
			paths.append(String(declaration.path))
	else:
		paths.append(String(source.portrait.path))
	return paths


static func _is_safe_path_segment(value: String) -> bool:
	if value.is_empty() or value == "." or value == "..":
		return false
	for index: int in value.length():
		var code := value.unicode_at(index)
		if not ((code >= 97 and code <= 122) or (code >= 48 and code <= 57) or code in [45, 46, 95]):
			return false
	return true


static func _is_sha256(value: String) -> bool:
	if value.length() != 64:
		return false
	for index: int in value.length():
		var code := value.unicode_at(index)
		if not ((code >= 48 and code <= 57) or (code >= 97 and code <= 102)):
			return false
	return true
