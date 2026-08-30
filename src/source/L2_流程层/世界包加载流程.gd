class_name WorldPackLoadingProcess
extends RefCounted

const Rules := preload("res://src/source/L0_公理层/Source合同规则.gd")
const FileReader := preload("res://src/source/L1_器件层/Source包文件读取器.gd")
const Fingerprinter := preload("res://src/source/L1_器件层/Source代次指纹计算器.gd")

var _reader := FileReader.new()
var _fingerprinter := Fingerprinter.new()


## 从调用方明确指定的 package 读取 World；v0.1 保持历史行为，v0.2 加载所有声明 rich bytes。
func load(package_path: String) -> Dictionary:
	var loaded := _reader.read_manifest(package_path)
	if not loaded.success:
		return loaded
	var data: Dictionary = loaded.manifest
	if String(data.get("schema_version", "")) == Rules.WORLD_SCHEMA:
		return _load_v1(String(loaded.root), data)
	if String(data.get("schema_version", "")) == Rules.WORLD_SCHEMA_V2:
		return _load_v2(String(loaded.root), data)
	return Rules.failure("unsupported_schema", "不支持的 schema_version：%s" % String(data.get("schema_version", "")))


func _load_v1(root: String, data: Dictionary) -> Dictionary:
	var validation := _validate_v1(data)
	if not validation.success:
		return validation
	var files_result := _read_authored_assets(root, data.authored_assets)
	if not files_result.success:
		return files_result
	var generation := _fingerprinter.calculate(data, files_result.files)
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
	var entries := []
	for entry: Dictionary in data.entries:
		var sections_result := _load_sections(root, entry.semantic_sections, files_by_path)
		if not sections_result.success:
			return sections_result
		var loaded_entry := entry.duplicate(true)
		loaded_entry.semantic_sections = sections_result.sections
		entries.append(loaded_entry)
	var assets_result := _read_authored_assets(root, data.authored_assets, files_by_path)
	if not assets_result.success:
		return assets_result
	var generation := _fingerprinter.calculate(data, files_by_path.values())
	if not generation.success:
		return generation
	return Rules.success({"projection": _project_v2(data, top_result.sections, entries, String(generation.fingerprint))})


func _validate_v1(data: Dictionary) -> Dictionary:
	var allowed := Rules.validate_allowed_fields(data, Rules.WORLD_FIELDS)
	if not allowed.success:
		return allowed
	var identity := Rules.validate_identity(data, Rules.WORLD_SCHEMA, Rules.WORLD_TYPE)
	if not identity.success:
		return identity
	for field: String in ["display_name", "world_instructions", "gm_instructions"]:
		var text_result := Rules.validate_non_empty_text(data, field, 120 if field == "display_name" else 0)
		if not text_result.success:
			return text_result
	if not data.get("source_lore") is Array or data.source_lore.is_empty():
		return Rules.failure("invalid_cardinality", "source_lore 必须包含至少一项。")
	var lore_result := _validate_records(data.source_lore, ["lore_id", "title", "content"], "lore_id", "source_lore")
	if not lore_result.success:
		return lore_result
	if not data.get("entries") is Array:
		return Rules.failure("invalid_cardinality", "entries 必须是 0..N 数组。")
	var entries_result := _validate_records(data.entries, ["entry_id", "display_name", "opening_seed"], "entry_id", "entries")
	if not entries_result.success:
		return entries_result
	if not data.get("authored_assets") is Array:
		return Rules.failure("invalid_cardinality", "authored_assets 必须是 0..N 数组。")
	var assets_result := _validate_assets(data.authored_assets)
	if not assets_result.success:
		return assets_result
	if not data.get("source_material") is Dictionary or data.source_material.is_empty():
		return Rules.failure("missing_or_invalid_field", "source_material 必须是非空 JSON object。")
	return Rules.success()


func _validate_v2(data: Dictionary) -> Dictionary:
	var allowed := Rules.validate_allowed_fields(data, Rules.WORLD_FIELDS_V2)
	if not allowed.success:
		return allowed
	var identity := Rules.validate_identity(data, Rules.WORLD_SCHEMA_V2, Rules.WORLD_TYPE)
	if not identity.success:
		return identity
	for field: String in ["display_name", "catalog_summary", "world_instructions", "gm_instructions"]:
		var text_result := Rules.validate_non_empty_text(data, field, 120 if field == "display_name" else 0)
		if not text_result.success:
			return text_result
	if not data.get("semantic_sections") is Array or data.semantic_sections.is_empty():
		return Rules.failure("invalid_cardinality", "World semantic_sections 必须包含至少一项。")
	if not data.get("entries") is Array or not data.get("authored_assets") is Array:
		return Rules.failure("invalid_cardinality", "entries/authored_assets 必须是 0..N 数组。")
	var section_ids := {}
	var top_sections := _validate_sections(data.semantic_sections, section_ids, "semantic_sections")
	if not top_sections.success:
		return top_sections
	var entry_ids := {}
	for value: Variant in data.entries:
		if not value is Dictionary:
			return Rules.failure("missing_or_invalid_field", "entries 每项必须是 object。")
		var entry := value as Dictionary
		if not _has_exact_fields(entry, ["entry_id", "display_name", "opening_seed", "semantic_sections"]):
			return Rules.failure("unknown_field", "v0.2 entries 只允许 entry_id/display_name/opening_seed/semantic_sections。")
		for field: String in ["entry_id", "display_name", "opening_seed"]:
			var text_result := Rules.validate_non_empty_text(entry, field)
			if not text_result.success:
				return text_result
		if entry_ids.has(String(entry.entry_id)):
			return Rules.failure("duplicate_id", "entries ID 重复：%s" % String(entry.entry_id))
		entry_ids[String(entry.entry_id)] = true
		if not entry.semantic_sections is Array:
			return Rules.failure("invalid_cardinality", "Entry semantic_sections 必须是 0..N 数组。")
		var nested_sections := _validate_sections(entry.semantic_sections, section_ids, "entries.%s.semantic_sections" % String(entry.entry_id))
		if not nested_sections.success:
			return nested_sections
	return _validate_assets(data.authored_assets)


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


func _validate_records(records: Array, fields: Array, id_field: String, label: String) -> Dictionary:
	var ids := {}
	for value: Variant in records:
		if not value is Dictionary:
			return Rules.failure("missing_or_invalid_field", "%s 每项必须是 object。" % label)
		var record := value as Dictionary
		if not _has_exact_fields(record, fields):
			return Rules.failure("unknown_field", "%s 项只能包含正式字段。" % label)
		for field: String in fields:
			var field_result := Rules.validate_non_empty_text(record, field)
			if not field_result.success:
				return field_result
		var record_id := String(record[id_field])
		if ids.has(record_id):
			return Rules.failure("duplicate_id", "%s ID 重复：%s" % [label, record_id])
		ids[record_id] = true
	return Rules.success()


func _validate_assets(assets: Array) -> Dictionary:
	var ids := {}
	var paths := {}
	for value: Variant in assets:
		if not value is Dictionary:
			return Rules.failure("missing_or_invalid_field", "authored_assets 每项必须是 object。")
		var asset := value as Dictionary
		if not _has_exact_fields(asset, ["asset_id", "kind", "path"]):
			return Rules.failure("unknown_field", "authored_assets 只允许 asset_id/kind/path。")
		for field: String in ["asset_id", "kind", "path"]:
			var field_result := Rules.validate_non_empty_text(asset, field)
			if not field_result.success:
				return field_result
		if not String(asset.kind) in ["portrait", "scene", "map", "document"]:
			return Rules.failure("unsupported_reference_type", "不支持的 authored asset kind：%s" % String(asset.kind))
		var path_result := _reader.validate_relative_reference(String(asset.path), String(asset.kind))
		if not path_result.success:
			return path_result
		if ids.has(asset.asset_id) or paths.has(asset.path):
			return Rules.failure("duplicate_id", "authored asset ID 或 path 重复。")
		ids[asset.asset_id] = true
		paths[asset.path] = true
	return Rules.success()


func _read_authored_assets(root: String, assets: Array, files_by_path: Dictionary = {}) -> Dictionary:
	var files := []
	for asset: Dictionary in assets:
		var file_result := _reader.read_reference(root, String(asset.path), String(asset.kind))
		if not file_result.success:
			return file_result
		var record := {"path": file_result.path, "bytes": file_result.bytes}
		files.append(record)
		files_by_path[String(file_result.path)] = record
	return Rules.success({"files": files})


func _project_v1(data: Dictionary, fingerprint: String) -> Dictionary:
	return {
		"identity": _identity(data, fingerprint),
		"display_name": data.display_name,
		"catalog_summary": "",
		"world_instructions": data.world_instructions,
		"gm_instructions": data.gm_instructions,
		"semantic_sections": [],
		"source_lore": data.source_lore.duplicate(true),
		"entries": data.entries.duplicate(true),
		"authored_assets": data.authored_assets.duplicate(true),
		"source_material": data.source_material.duplicate(true),
	}


func _project_v2(data: Dictionary, top_sections: Array, entries: Array, fingerprint: String) -> Dictionary:
	return {
		"identity": _identity(data, fingerprint),
		"display_name": data.display_name,
		"catalog_summary": data.catalog_summary,
		"world_instructions": data.world_instructions,
		"gm_instructions": data.gm_instructions,
		"semantic_sections": top_sections,
		"source_lore": [],
		"entries": entries,
		"authored_assets": data.authored_assets.duplicate(true),
		"source_material": {},
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
