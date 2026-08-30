class_name CreationIntentStore
extends RefCounted

const Rules := preload("res://src/最终建局/L0_公理层/最终建局规则.gd")

var _root: String


func _init(root: String) -> void:
	_root = ProjectSettings.globalize_path(root).simplify_path()


func read_intent(creation_id: String) -> Dictionary:
	return _read_json(_intent_path(creation_id), true)


func read_created(creation_id: String) -> Dictionary:
	return _read_json(_created_path(creation_id), false)


## intent 一经发布不可替换；rename 遇到并发已存在时复读既有 authority。
func publish_intent(intent: Dictionary) -> Dictionary:
	var initialized := _initialize()
	if not initialized.success:
		return initialized
	var path := _intent_path(String(intent.creation_id))
	if FileAccess.file_exists(path):
		return read_intent(String(intent.creation_id))
	var published := _publish_new_json(path, intent)
	if published.success:
		return Rules.success({"value": intent.duplicate(true), "published": true})
	if FileAccess.file_exists(path):
		return read_intent(String(intent.creation_id))
	return published


func publish_created(marker: Dictionary) -> Dictionary:
	var initialized := _initialize()
	if not initialized.success:
		return initialized
	var path := _created_path(String(marker.creation_id))
	if FileAccess.file_exists(path):
		var existing := read_created(String(marker.creation_id))
		if not existing.success:
			return existing
		if existing.value != marker:
			return Rules.failure("created_marker_conflict", "created marker 与既有 authority 不一致。")
		return Rules.success({"value": existing.value, "already_created": true})
	var published := _publish_new_json(path, marker)
	if not published.success:
		return published
	return Rules.success({"value": marker.duplicate(true), "already_created": false})


func _initialize() -> Dictionary:
	if _root.strip_edges().is_empty():
		return Rules.failure("invalid_creation_root", "creation protocol root 不能为空。")
	for child: String in ["intents", "created"]:
		var error := DirAccess.make_dir_recursive_absolute(_root.path_join(child))
		if error != OK:
			return Rules.failure("creation_journal_initialize_failed", "无法创建 creation protocol 目录。")
	return Rules.success()


func _publish_new_json(path: String, value: Dictionary) -> Dictionary:
	var temporary := "%s.pending-%d-%d" % [path, OS.get_process_id(), Time.get_ticks_usec()]
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return Rules.failure("creation_journal_publish_failed", "无法创建 journal 临时文件。")
	file.store_string(JSON.stringify(value, "  ") + "\n")
	file.flush()
	if file.get_error() != OK:
		file = null
		DirAccess.remove_absolute(temporary)
		return Rules.failure("creation_journal_publish_failed", "journal 临时文件写入失败。")
	file = null
	var error := DirAccess.rename_absolute(temporary, path)
	if error != OK:
		DirAccess.remove_absolute(temporary)
		return Rules.failure("creation_journal_publish_failed", "journal 原子发布失败：%s" % error_string(error))
	return Rules.success()


func _read_json(path: String, validate_as_intent: bool) -> Dictionary:
	if not FileAccess.file_exists(path):
		return Rules.failure("creation_metadata_missing", "creation metadata 不存在。")
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return Rules.failure("creation_metadata_read_failed", "creation metadata 无法读取。")
	var bytes := file.get_buffer(file.get_length())
	var text := bytes.get_string_from_utf8()
	if text.to_utf8_buffer() != bytes:
		return Rules.failure("invalid_creation_metadata", "creation metadata 不是有效 UTF-8。")
	var parser := JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		return Rules.failure("invalid_creation_metadata", "creation metadata 不是有效 JSON object。")
	var value := parser.data as Dictionary
	if validate_as_intent:
		var validation := Rules.validate_intent(value)
		if not validation.success:
			return validation
	else:
		for field: String in ["schema_version", "creation_id", "composition_fingerprint", "game_id"]:
			if not value.get(field, null) is String or String(value.get(field, "")).is_empty():
				return Rules.failure("invalid_creation_metadata", "created marker 字段无效：%s" % field)
		if String(value.schema_version) != Rules.CREATED_SCHEMA:
			return Rules.failure("invalid_creation_metadata", "不支持的 created marker schema。")
	return Rules.success({"value": value})


func _intent_path(creation_id: String) -> String:
	return _root.path_join("intents").path_join("%s.json" % creation_id)


func _created_path(creation_id: String) -> String:
	return _root.path_join("created").path_join("%s.json" % creation_id)
