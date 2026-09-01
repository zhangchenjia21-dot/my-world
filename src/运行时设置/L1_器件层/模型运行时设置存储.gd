class_name ModelRuntimeSettingsStore
extends RefCounted

const DEFAULT_PATH := "user://my-world/settings/provider-runtime.json"

var settings_path := DEFAULT_PATH


func _init(path_override: String = "") -> void:
	if not path_override.is_empty():
		settings_path = path_override


func read_record() -> Dictionary:
	var absolute_path := ProjectSettings.globalize_path(settings_path)
	var previous_path := absolute_path + ".previous"
	# publish 窗口若进程在 old->previous 后中断，下一次读取先恢复最后一份已发布记录。
	if not FileAccess.file_exists(absolute_path) and FileAccess.file_exists(previous_path):
		var recovery_error := DirAccess.rename_absolute(previous_path, absolute_path)
		if recovery_error != OK:
			return _failure("settings_recovery_failed", "无法恢复上一份模型运行时设置。")
	if not FileAccess.file_exists(settings_path):
		return {"success": true, "status": "missing", "record": null}
	var file := FileAccess.open(settings_path, FileAccess.READ)
	if file == null:
		return _failure("settings_read_failed", "无法读取模型运行时设置。")
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or typeof(parser.data) != TYPE_DICTIONARY:
		return _failure("settings_malformed", "模型运行时设置文件不是有效 JSON 对象。")
	return {"success": true, "status": "loaded", "record": parser.data}


## 写入先在同目录完成并 flush，再通过 previous 保护旧有效记录后发布；任何失败都不留下半份 active 文件。
func write_record(record: Dictionary) -> Dictionary:
	var absolute_path := ProjectSettings.globalize_path(settings_path)
	var directory_path := absolute_path.get_base_dir()
	var directory_error := DirAccess.make_dir_recursive_absolute(directory_path)
	if directory_error != OK:
		return _failure("settings_directory_failed", "无法创建模型运行时设置目录。")
	var temporary_path := absolute_path + ".tmp"
	var previous_path := absolute_path + ".previous"
	if FileAccess.file_exists(temporary_path):
		DirAccess.remove_absolute(temporary_path)
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return _failure("settings_write_failed", "无法写入模型运行时设置临时文件。")
	file.store_string(JSON.stringify(record, "\t") + "\n")
	file.flush()
	file.close()
	var verify_file := FileAccess.open(temporary_path, FileAccess.READ)
	var verified := false
	if verify_file != null:
		var verify_parser := JSON.new()
		verified = verify_parser.parse(verify_file.get_as_text()) == OK and typeof(verify_parser.data) == TYPE_DICTIONARY
		verify_file.close()
	if not verified:
		DirAccess.remove_absolute(temporary_path)
		return _failure("settings_write_failed", "模型运行时设置临时文件校验失败。")
	if FileAccess.file_exists(previous_path):
		DirAccess.remove_absolute(previous_path)
	var had_current := FileAccess.file_exists(absolute_path)
	if had_current:
		var protect_error := DirAccess.rename_absolute(absolute_path, previous_path)
		if protect_error != OK:
			DirAccess.remove_absolute(temporary_path)
			return _failure("settings_publish_failed", "无法保护上一份模型运行时设置。")
	var publish_error := DirAccess.rename_absolute(temporary_path, absolute_path)
	if publish_error != OK:
		if had_current:
			DirAccess.rename_absolute(previous_path, absolute_path)
		DirAccess.remove_absolute(temporary_path)
		return _failure("settings_publish_failed", "无法发布模型运行时设置。")
	if FileAccess.file_exists(previous_path):
		DirAccess.remove_absolute(previous_path)
	return {"success": true, "status": "saved", "path": settings_path}


func _failure(status: String, message: String) -> Dictionary:
	return {"success": false, "status": status, "message": message}
