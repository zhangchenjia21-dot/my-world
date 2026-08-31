class_name ExpansionPackLoadingProcess
extends RefCounted

const Rules := preload("res://src/source/L0_公理层/Source合同规则.gd")
const FileReader := preload("res://src/source/L1_器件层/Source包文件读取器.gd")
const Fingerprinter := preload("res://src/source/L1_器件层/Source代次指纹计算器.gd")

var _reader := FileReader.new()
var _fingerprinter := Fingerprinter.new()


## Expansion 是数据合同，不声明或装载可执行文件；所有 authored rule bytes 都进入 exact generation。
func load(package_path: String) -> Dictionary:
	var loaded := _reader.read_manifest(package_path)
	if not loaded.success:
		return loaded
	var data: Dictionary = loaded.manifest
	var validation := _validate(data)
	if not validation.success:
		return validation
	var files: Array = []
	var sections: Array = []
	for declaration: Dictionary in data.semantic_sections:
		var read := _reader.read_reference(String(loaded.root), String(declaration.content_path), "semantic_content")
		if not read.success:
			return read
		var bytes: PackedByteArray = read.bytes
		var content := bytes.get_string_from_utf8()
		if content.to_utf8_buffer() != bytes:
			return Rules.failure("invalid_encoding", "Expansion semantic section 必须是有效 UTF-8。")
		files.append({"path": read.path, "bytes": bytes})
		var section := declaration.duplicate(true)
		section["content"] = content
		sections.append(section)
	var generation := _fingerprinter.calculate(data, files)
	if not generation.success:
		return generation
	return Rules.success({"projection": {
		"identity": {
			"schema_version": data.schema_version, "asset_id": data.asset_id,
			"asset_type": data.asset_type, "version": data.version,
			"generation_fingerprint": generation.fingerprint,
		},
		"display_name": data.display_name,
		"catalog_summary": data.catalog_summary,
		"capability_binding": data.capability_binding.duplicate(true),
		"semantic_sections": sections,
	}})


func _validate(data: Dictionary) -> Dictionary:
	var allowed := Rules.validate_allowed_fields(data, Rules.EXPANSION_FIELDS)
	if not allowed.success:
		return allowed
	var identity := Rules.validate_identity(data, Rules.EXPANSION_SCHEMA, Rules.EXPANSION_TYPE)
	if not identity.success:
		return identity
	for field: String in ["display_name", "catalog_summary"]:
		var text := Rules.validate_non_empty_text(data, field, 120 if field == "display_name" else 0)
		if not text.success:
			return text
	if not data.get("capability_binding") is Dictionary:
		return Rules.failure("missing_or_invalid_field", "capability_binding 必须是 object。")
	var binding := data.capability_binding as Dictionary
	if binding.size() != 2 or not binding.has("capability_id") or not binding.has("capability_slot"):
		return Rules.failure("unknown_field", "capability_binding 只允许 capability_id/capability_slot。")
	for field: String in ["capability_id", "capability_slot"]:
		var token := Rules.validate_safe_token(binding.get(field), "capability_binding.%s" % field)
		if not token.success:
			return token
	if not data.get("semantic_sections") is Array or data.semantic_sections.is_empty():
		return Rules.failure("invalid_cardinality", "Expansion semantic_sections 必须包含至少一项。")
	var ids := {}
	for value: Variant in data.semantic_sections:
		if not value is Dictionary:
			return Rules.failure("missing_or_invalid_field", "semantic_sections 每项必须是 object。")
		var section := value as Dictionary
		var fields := ["section_id", "section_type", "title", "disclosure", "content_path"]
		if section.size() != fields.size():
			return Rules.failure("unknown_field", "Expansion section 字段集无效。")
		for field: String in fields:
			if not section.has(field):
				return Rules.failure("unknown_field", "Expansion section 字段集无效。")
		for field: String in ["section_id", "title", "content_path"]:
			var text := Rules.validate_non_empty_text(section, field)
			if not text.success:
				return text
		var section_type := Rules.validate_safe_token(section.section_type, "semantic_sections.section_type")
		if not section_type.success:
			return section_type
		if not String(section.disclosure) in Rules.DISCLOSURES:
			return Rules.failure("invalid_disclosure", "disclosure 必须是 gm_reference 或 gm_private。")
		if ids.has(String(section.section_id)):
			return Rules.failure("duplicate_id", "Expansion section_id 重复。")
		ids[String(section.section_id)] = true
		var path := _reader.validate_relative_reference(String(section.content_path), "semantic_content")
		if not path.success:
			return path
	return Rules.success()
