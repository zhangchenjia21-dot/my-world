class_name CharacterCardLoadingProcess
extends RefCounted

const Rules := preload("res://src/source/L0_公理层/Source合同规则.gd")
const FileReader := preload("res://src/source/L1_器件层/Source包文件读取器.gd")
const Fingerprinter := preload("res://src/source/L1_器件层/Source代次指纹计算器.gd")

var _reader := FileReader.new()
var _fingerprinter := Fingerprinter.new()


## Character Source 只提供可复用 starting semantics；所有 profile bytes 进入 generation，但只有 exact binding 可进入选定投影。
func load(package_path: String) -> Dictionary:
	var loaded := _reader.read_manifest(package_path)
	if not loaded.success:
		return loaded
	var data: Dictionary = loaded.manifest
	if String(data.get("schema_version", "")) == Rules.CHARACTER_SCHEMA:
		return _load_v1(String(loaded.root), data)
	if String(data.get("schema_version", "")) == Rules.CHARACTER_SCHEMA_V2:
		return _load_v2(String(loaded.root), data)
	return Rules.failure("unsupported_schema", "不支持的 schema_version：%s" % String(data.get("schema_version", "")))


func _load_v1(root: String, data: Dictionary) -> Dictionary:
	var validation := _validate_v1(data)
	if not validation.success:
		return validation
	var portrait_result := _reader.read_reference(root, String(data.portrait.path), "portrait")
	if not portrait_result.success:
		return portrait_result
	var generation := _fingerprinter.calculate(data, [{"path": portrait_result.path, "bytes": portrait_result.bytes}])
	if not generation.success:
		return generation
	return Rules.success({"projection": _project_v1(data, String(generation.fingerprint))})


func _load_v2(root: String, data: Dictionary) -> Dictionary:
	var validation := _validate_v2(data)
	if not validation.success:
		return validation
	var files_by_path := {}
	var top_result := _load_sections(root, data.semantic_sections, files_by_path)
	if not top_result.success:
		return top_result
	var profiles := []
	for profile: Dictionary in data.get("t0_profiles", []):
		var sections_result := _load_sections(root, profile.semantic_sections, files_by_path)
		if not sections_result.success:
			return sections_result
		var loaded_profile := profile.duplicate(true)
		loaded_profile.semantic_sections = sections_result.sections
		profiles.append(loaded_profile)
	var portrait := {}
	if data.has("portrait"):
		var portrait_result := _reader.read_reference(root, String(data.portrait.path), "portrait")
		if not portrait_result.success:
			return portrait_result
		portrait = data.portrait.duplicate(true)
		files_by_path[String(portrait_result.path)] = {"path": portrait_result.path, "bytes": portrait_result.bytes}
	var generation := _fingerprinter.calculate(data, files_by_path.values())
	if not generation.success:
		return generation
	return Rules.success({"projection": _project_v2(data, top_result.sections, profiles, portrait, String(generation.fingerprint))})


func _validate_v1(data: Dictionary) -> Dictionary:
	var allowed := Rules.validate_allowed_fields(data, Rules.CHARACTER_FIELDS)
	if not allowed.success:
		return allowed
	var identity := Rules.validate_identity(data, Rules.CHARACTER_SCHEMA, Rules.CHARACTER_TYPE)
	if not identity.success:
		return identity
	var display := Rules.validate_non_empty_text(data, "display_name", 120)
	if not display.success:
		return display
	var public_result := _validate_legacy_profile(data.get("public_profile"), "public_profile", "summary", "traits")
	if not public_result.success:
		return public_result
	var private_result := _validate_legacy_profile(data.get("gm_private_profile"), "gm_private_profile", "background", "drives")
	if not private_result.success:
		return private_result
	if not data.get("portrait") is Dictionary:
		return Rules.failure("missing_or_invalid_field", "portrait 必须是 object。")
	var portrait: Dictionary = data.portrait
	if not _has_exact_fields(portrait, ["path", "alt_text"]):
		return Rules.failure("unknown_field", "portrait 只允许 path/alt_text。")
	for field: String in ["path", "alt_text"]:
		var field_result := Rules.validate_non_empty_text(portrait, field)
		if not field_result.success:
			return field_result
	if not data.has("player_character_supported") or not data.player_character_supported is bool:
		return Rules.failure("missing_or_invalid_field", "player_character_supported 必须是 bool。")
	return Rules.success()


func _validate_v2(data: Dictionary) -> Dictionary:
	var allowed := Rules.validate_allowed_fields(data, Rules.CHARACTER_FIELDS_V2)
	if not allowed.success:
		return allowed
	var identity := Rules.validate_identity(data, Rules.CHARACTER_SCHEMA_V2, Rules.CHARACTER_TYPE)
	if not identity.success:
		return identity
	for field: String in ["display_name", "catalog_summary"]:
		var text_result := Rules.validate_non_empty_text(data, field, 120 if field == "display_name" else 0)
		if not text_result.success:
			return text_result
	if not data.get("semantic_sections") is Array or data.semantic_sections.is_empty():
		return Rules.failure("invalid_cardinality", "Character semantic_sections 必须包含至少一项。")
	if data.has("t0_profiles") and not data.t0_profiles is Array:
		return Rules.failure("invalid_cardinality", "t0_profiles 必须是 0..N 数组。")
	if not data.has("player_character_supported") or not data.player_character_supported is bool:
		return Rules.failure("missing_or_invalid_field", "player_character_supported 必须是 bool。")
	var section_ids := {}
	var top_sections := _validate_sections(data.semantic_sections, section_ids, "semantic_sections")
	if not top_sections.success:
		return top_sections
	var has_identity := false
	for section: Dictionary in data.semantic_sections:
		if String(section.section_type) == "identity":
			has_identity = true
	if not has_identity:
		return Rules.failure("missing_or_invalid_field", "Character 必须有 section_type=identity 的 top-level section。")
	var profile_ids := {}
	var exact_bindings := {}
	for value: Variant in data.get("t0_profiles", []):
		if not value is Dictionary:
			return Rules.failure("missing_or_invalid_field", "t0_profiles 每项必须是 object。")
		var profile := value as Dictionary
		if not _has_exact_fields(profile, ["profile_id", "display_name", "bindings", "semantic_sections"]):
			return Rules.failure("unknown_field", "t0_profile 只允许 profile_id/display_name/bindings/semantic_sections。")
		var profile_id_result := Rules.validate_non_empty_text(profile, "profile_id")
		if not profile_id_result.success:
			return profile_id_result
		var profile_name := Rules.validate_non_empty_text(profile, "display_name")
		if not profile_name.success:
			return profile_name
		if profile_ids.has(String(profile.profile_id)):
			return Rules.failure("duplicate_id", "profile_id 重复：%s" % String(profile.profile_id))
		profile_ids[String(profile.profile_id)] = true
		if not profile.bindings is Array or not profile.semantic_sections is Array:
			return Rules.failure("invalid_cardinality", "bindings/semantic_sections 必须是数组。")
		for binding_value: Variant in profile.bindings:
			if not binding_value is Dictionary:
				return Rules.failure("missing_or_invalid_field", "binding 必须是 object。")
			var binding := binding_value as Dictionary
			if not _has_exact_fields(binding, ["world_asset_id", "entry_id"]):
				return Rules.failure("unknown_field", "binding 只允许 world_asset_id/entry_id。")
			for field: String in ["world_asset_id", "entry_id"]:
				var binding_field := Rules.validate_non_empty_text(binding, field)
				if not binding_field.success:
					return binding_field
			var key := "%s\n%s" % [String(binding.world_asset_id), String(binding.entry_id)]
			if exact_bindings.has(key):
				return Rules.failure("duplicate_binding", "Character exact T0 binding 重复。")
			exact_bindings[key] = true
		var nested_sections := _validate_sections(profile.semantic_sections, section_ids, "t0_profiles.%s.semantic_sections" % String(profile.profile_id))
		if not nested_sections.success:
			return nested_sections
	if data.has("portrait"):
		if not data.portrait is Dictionary or not _has_exact_fields(data.portrait, ["path", "alt_text"]):
			return Rules.failure("missing_or_invalid_field", "optional portrait 必须是 path/alt_text object；缺省时应省略字段。")
		for field: String in ["path", "alt_text"]:
			var portrait_field := Rules.validate_non_empty_text(data.portrait, field)
			if not portrait_field.success:
				return portrait_field
		var path_result := _reader.validate_relative_reference(String(data.portrait.path), "portrait")
		if not path_result.success:
			return path_result
	return Rules.success()


func _validate_sections(sections: Array, section_ids: Dictionary, label: String) -> Dictionary:
	for value: Variant in sections:
		if not value is Dictionary:
			return Rules.failure("missing_or_invalid_field", "%s 每项必须是 object。" % label)
		var section := value as Dictionary
		if not _has_exact_fields(section, ["section_id", "section_type", "title", "disclosure", "content_path"]):
			return Rules.failure("unknown_field", "%s section 字段集无效。" % label)
		var section_type := Rules.validate_safe_token(section.get("section_type"), "%s.section_type" % label)
		if not section_type.success:
			return section_type
		for field: String in ["section_id", "title", "content_path"]:
			var text_result := Rules.validate_non_empty_text(section, field)
			if not text_result.success:
				return text_result
		if not String(section.disclosure) in Rules.DISCLOSURES:
			return Rules.failure("invalid_disclosure", "disclosure 必须是 gm_reference 或 gm_private。")
		var path_result := _reader.validate_relative_reference(String(section.content_path), "semantic_content")
		if not path_result.success:
			return path_result
		if section_ids.has(String(section.section_id)):
			return Rules.failure("duplicate_id", "package-wide section_id 重复：%s" % String(section.section_id))
		section_ids[String(section.section_id)] = true
	return Rules.success()


func _load_sections(root: String, declarations: Array, files_by_path: Dictionary) -> Dictionary:
	var sections := []
	for declaration: Dictionary in declarations:
		var path := String(declaration.content_path)
		var file_result := _reader.read_reference(root, path, "semantic_content")
		if not file_result.success:
			return file_result
		var bytes: PackedByteArray = file_result.bytes
		var content := bytes.get_string_from_utf8()
		if content.to_utf8_buffer() != bytes:
			return Rules.failure("invalid_encoding", "semantic section 必须是有效 UTF-8：%s" % path)
		files_by_path[path] = {"path": path, "bytes": bytes}
		var section := declaration.duplicate(true)
		section["content"] = content
		sections.append(section)
	return Rules.success({"sections": sections})


func _validate_legacy_profile(value: Variant, label: String, text_field: String, list_field: String) -> Dictionary:
	if not value is Dictionary:
		return Rules.failure("missing_or_invalid_field", "%s 必须是 object。" % label)
	var profile := value as Dictionary
	if not _has_exact_fields(profile, [text_field, list_field]):
		return Rules.failure("unknown_field", "%s 只允许 %s/%s。" % [label, text_field, list_field])
	var text_result := Rules.validate_non_empty_text(profile, text_field)
	if not text_result.success:
		return text_result
	return Rules.validate_string_array(profile[list_field], "%s.%s" % [label, list_field])


func _project_v1(data: Dictionary, fingerprint: String) -> Dictionary:
	return {
		"identity": _identity(data, fingerprint),
		"display_name": data.display_name,
		"catalog_summary": "",
		"semantic_sections": [],
		"t0_profiles": [],
		"public_profile": data.public_profile.duplicate(true),
		"gm_private_profile": data.gm_private_profile.duplicate(true),
		"portrait": data.portrait.duplicate(true),
		"player_character_supported": data.player_character_supported,
	}


func _project_v2(data: Dictionary, sections: Array, profiles: Array, portrait: Dictionary, fingerprint: String) -> Dictionary:
	return {
		"identity": _identity(data, fingerprint),
		"display_name": data.display_name,
		"catalog_summary": data.catalog_summary,
		"semantic_sections": sections,
		"t0_profiles": profiles,
		"public_profile": {},
		"gm_private_profile": {},
		"portrait": portrait,
		"player_character_supported": data.player_character_supported,
	}


func _identity(data: Dictionary, fingerprint: String) -> Dictionary:
	return {
		"schema_version": data.schema_version,
		"asset_id": data.asset_id,
		"asset_type": data.asset_type,
		"version": data.version,
		"generation_fingerprint": fingerprint,
	}


func _has_exact_fields(value: Dictionary, fields: Array) -> bool:
	if value.size() != fields.size():
		return false
	for field: String in fields:
		if not value.has(field):
			return false
	return true
