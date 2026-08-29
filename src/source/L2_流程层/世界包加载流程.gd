class_name WorldPackLoadingProcess
extends RefCounted

const Rules := preload("res://src/source/L0_公理层/Source合同规则.gd")
const FileReader := preload("res://src/source/L1_器件层/Source包文件读取器.gd")
const Fingerprinter := preload("res://src/source/L1_器件层/Source代次指纹计算器.gd")

var _reader := FileReader.new()
var _fingerprinter := Fingerprinter.new()


## 从一个显式 package path 完成 World contract 的读取、验证和 exact generation 派生。
## 失败不写 package，也不会 fallback 到空 World 或其它 asset type。
func load(package_path: String) -> Dictionary:
	var loaded := _reader.read_manifest(package_path)
	if not loaded.success:
		return loaded
	var data: Dictionary = loaded.manifest
	var validation := _validate(data)
	if not validation.success:
		return validation
	var files_result := _read_authored_assets(String(loaded.root), data.authored_assets)
	if not files_result.success:
		return files_result
	var generation := _fingerprinter.calculate(data, files_result.files)
	if not generation.success:
		return generation
	return Rules.success({"projection": _project(data, String(generation.fingerprint))})


func _validate(data: Dictionary) -> Dictionary:
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


func _validate_records(records: Array, fields: Array, id_field: String, label: String) -> Dictionary:
	var ids := {}
	for value: Variant in records:
		if not value is Dictionary:
			return Rules.failure("missing_or_invalid_field", "%s 每项必须是 object。" % label)
		var record := value as Dictionary
		if record.size() != fields.size():
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
		if asset.size() != 3:
			return Rules.failure("unknown_field", "authored_assets 只允许 asset_id/kind/path。")
		for field: String in ["asset_id", "kind", "path"]:
			var field_result := Rules.validate_non_empty_text(asset, field)
			if not field_result.success:
				return field_result
		if not String(asset.kind) in ["portrait", "scene", "map", "document"]:
			return Rules.failure("unsupported_reference_type", "不支持的 authored asset kind：%s" % String(asset.kind))
		if ids.has(asset.asset_id) or paths.has(asset.path):
			return Rules.failure("duplicate_id", "authored asset ID 或 path 重复。")
		ids[asset.asset_id] = true
		paths[asset.path] = true
	return Rules.success()


func _read_authored_assets(root: String, assets: Array) -> Dictionary:
	var files := []
	for asset: Dictionary in assets:
		var file_result := _reader.read_reference(root, String(asset.path), String(asset.kind))
		if not file_result.success:
			return file_result
		files.append({"path": file_result.path, "bytes": file_result.bytes})
	return Rules.success({"files": files})


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
		"world_instructions": data.world_instructions,
		"gm_instructions": data.gm_instructions,
		"source_lore": data.source_lore.duplicate(true),
		"entries": data.entries.duplicate(true),
		"authored_assets": data.authored_assets.duplicate(true),
		"source_material": data.source_material.duplicate(true),
	}
