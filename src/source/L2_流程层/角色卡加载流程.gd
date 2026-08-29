class_name CharacterCardLoadingProcess
extends RefCounted

const Rules := preload("res://src/source/L0_公理层/Source合同规则.gd")
const FileReader := preload("res://src/source/L1_器件层/Source包文件读取器.gd")
const Fingerprinter := preload("res://src/source/L1_器件层/Source代次指纹计算器.gd")

var _reader := FileReader.new()
var _fingerprinter := Fingerprinter.new()


## Character Source 只描述可复用的 authored identity/profile/eligibility。
## live location、relationship、knowledge、inventory 等 Game truth 一律不是此流程输入。
func load(package_path: String) -> Dictionary:
	var loaded := _reader.read_manifest(package_path)
	if not loaded.success:
		return loaded
	var data: Dictionary = loaded.manifest
	var validation := _validate(data)
	if not validation.success:
		return validation
	var portrait_result := _reader.read_reference(String(loaded.root), String(data.portrait.path), "portrait")
	if not portrait_result.success:
		return portrait_result
	var generation := _fingerprinter.calculate(data, [{"path": portrait_result.path, "bytes": portrait_result.bytes}])
	if not generation.success:
		return generation
	return Rules.success({"projection": _project(data, String(generation.fingerprint))})


func _validate(data: Dictionary) -> Dictionary:
	var allowed := Rules.validate_allowed_fields(data, Rules.CHARACTER_FIELDS)
	if not allowed.success:
		return allowed
	var identity := Rules.validate_identity(data, Rules.CHARACTER_SCHEMA, Rules.CHARACTER_TYPE)
	if not identity.success:
		return identity
	var display := Rules.validate_non_empty_text(data, "display_name", 120)
	if not display.success:
		return display
	var public_result := _validate_profile(data.get("public_profile"), "public_profile", "summary", "traits")
	if not public_result.success:
		return public_result
	var private_result := _validate_profile(data.get("gm_private_profile"), "gm_private_profile", "background", "drives")
	if not private_result.success:
		return private_result
	if not data.get("portrait") is Dictionary:
		return Rules.failure("missing_or_invalid_field", "portrait 必须是 object。")
	var portrait: Dictionary = data.portrait
	if portrait.size() != 2:
		return Rules.failure("unknown_field", "portrait 只允许 path/alt_text。")
	for field: String in ["path", "alt_text"]:
		var field_result := Rules.validate_non_empty_text(portrait, field)
		if not field_result.success:
			return field_result
	if not data.has("player_character_supported") or not data.player_character_supported is bool:
		return Rules.failure("missing_or_invalid_field", "player_character_supported 必须是 bool。")
	return Rules.success()


func _validate_profile(value: Variant, label: String, text_field: String, list_field: String) -> Dictionary:
	if not value is Dictionary:
		return Rules.failure("missing_or_invalid_field", "%s 必须是 object。" % label)
	var profile := value as Dictionary
	if profile.size() != 2 or not profile.has(text_field) or not profile.has(list_field):
		return Rules.failure("unknown_field", "%s 只允许 %s/%s。" % [label, text_field, list_field])
	var text_result := Rules.validate_non_empty_text(profile, text_field)
	if not text_result.success:
		return text_result
	return Rules.validate_string_array(profile[list_field], "%s.%s" % [label, list_field])


func _project(data: Dictionary, fingerprint: String) -> Dictionary:
	return {
		"identity": {
			"schema_version": data.schema_version,
			"asset_id": data.asset_id,
			"asset_type": data.asset_type,
			"version": data.version,
			"generation_fingerprint": fingerprint,
		},
		"display_name": data.display_name,
		"public_profile": data.public_profile.duplicate(true),
		"gm_private_profile": data.gm_private_profile.duplicate(true),
		"portrait": data.portrait.duplicate(true),
		"player_character_supported": data.player_character_supported,
	}
