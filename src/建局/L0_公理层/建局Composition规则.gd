class_name GameCreationCompositionRules
extends RefCounted

## Composition 只保存玩家明确确认的建局意图；这些字段不得被解释为已创建的 Game truth。

const CONTROL_MODES := ["Full", "Light", "Narrative"]
const DEFAULT_CONTROL_MODE := "Light"
const IDENTITY_FIELDS := ["asset_type", "asset_id", "version", "generation_fingerprint"]


static func success(values: Dictionary = {}) -> Dictionary:
	var result := {"success": true}
	result.merge(values, true)
	return result


static func failure(code: String, message: String) -> Dictionary:
	return {"success": false, "code": code, "message": message}


static func exact_identity(generation: RefCounted) -> Dictionary:
	return generation.identity.duplicate(true)


static func same_generation(left: Dictionary, right: Dictionary) -> bool:
	for field: String in IDENTITY_FIELDS:
		if String(left.get(field, "")) != String(right.get(field, "")):
			return false
	return true


static func validate_identity(identity: Dictionary, asset_type: String) -> Dictionary:
	if identity.size() != IDENTITY_FIELDS.size():
		return failure("invalid_exact_identity", "Source exact identity 字段不完整。")
	for field: String in IDENTITY_FIELDS:
		if String(identity.get(field, "")).strip_edges().is_empty():
			return failure("invalid_exact_identity", "Source exact identity 字段为空：%s" % field)
	if String(identity.asset_type) != asset_type:
		return failure("invalid_asset_type", "Source 类型与建局角色不匹配。")
	return success()


static func identity_sort_key(identity: Dictionary) -> String:
	return "%s\u001f%s\u001f%s\u001f%s" % [identity.asset_type, identity.asset_id, identity.version, identity.generation_fingerprint]
