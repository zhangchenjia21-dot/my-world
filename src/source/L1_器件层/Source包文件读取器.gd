class_name SourcePackageFileReader
extends RefCounted

const Rules := preload("res://src/source/L0_公理层/Source合同规则.gd")
const IMAGE_EXTENSIONS := ["png", "jpg", "jpeg", "webp", "svg"]
const DOCUMENT_EXTENSIONS := ["txt", "md", "json"]


## 读取固定 manifest，不扫描默认目录。调用方始终明确拥有 package path 的选择权。
func read_manifest(package_path: String) -> Dictionary:
	var root_result := normalize_package_root(package_path)
	if not root_result.success:
		return root_result
	var manifest_path := String(root_result.root).path_join(Rules.MANIFEST_NAME)
	if not FileAccess.file_exists(manifest_path):
		return Rules.failure("manifest_missing", "Source package 缺少 source.json。")
	var file := FileAccess.open(manifest_path, FileAccess.READ)
	if file == null:
		return Rules.failure("manifest_read_failed", "无法读取 Source manifest。")
	var bytes := file.get_buffer(file.get_length())
	var text := bytes.get_string_from_utf8()
	# round-trip 不一致意味着输入不是无歧义 UTF-8；禁止替换字符静默改变作者内容。
	if text.to_utf8_buffer() != bytes:
		return Rules.failure("invalid_encoding", "Source manifest 必须是无 BOM 的有效 UTF-8。")
	var parser := JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		return Rules.failure("malformed_json", "Source manifest 必须是有效 JSON object：%s" % parser.get_error_message())
	return Rules.success({"root": root_result.root, "manifest": parser.data})


func normalize_package_root(package_path: String) -> Dictionary:
	if package_path.strip_edges().is_empty():
		return Rules.failure("missing_package", "必须显式提供 Source package path。")
	var root := ProjectSettings.globalize_path(package_path).simplify_path()
	if not DirAccess.dir_exists_absolute(root):
		return Rules.failure("missing_package", "Source package 目录不存在。")
	return Rules.success({"root": root})


## 校验并读取 contract-owned file bytes。任何失败都不会改写或修复 package。
func read_reference(package_root: String, relative_path: String, kind: String) -> Dictionary:
	var path_result := validate_relative_reference(relative_path, kind)
	if not path_result.success:
		return path_result
	var normalized := String(path_result.path)
	var target := package_root.path_join(normalized).simplify_path()
	var root_prefix := package_root.replace("\\", "/").trim_suffix("/").to_lower() + "/"
	var target_normalized := target.replace("\\", "/").to_lower()
	if not target_normalized.begins_with(root_prefix):
		return Rules.failure("unsafe_reference", "Source 文件引用越出 package root：%s" % relative_path)
	if not FileAccess.file_exists(target) or DirAccess.dir_exists_absolute(target):
		return Rules.failure("missing_reference", "Source 声明文件不存在：%s" % relative_path)
	if _contains_link(package_root, normalized):
		return Rules.failure("unsafe_reference", "Source 文件引用不得经过符号链接：%s" % relative_path)
	var file := FileAccess.open(target, FileAccess.READ)
	if file == null:
		return Rules.failure("missing_reference", "无法读取 Source 声明文件：%s" % relative_path)
	return Rules.success({"path": normalized, "bytes": file.get_buffer(file.get_length())})


func validate_relative_reference(relative_path: String, kind: String) -> Dictionary:
	if relative_path.is_empty() or relative_path != relative_path.strip_edges():
		return Rules.failure("unsafe_reference", "Source 文件引用不能为空或包含首尾空白。")
	if relative_path.contains("\\") or relative_path.contains(":") or relative_path.begins_with("/") or relative_path.is_absolute_path():
		return Rules.failure("unsafe_reference", "Source 文件引用必须是使用 / 的 package-local relative path。")
	var segments := relative_path.split("/", false)
	if segments.is_empty():
		return Rules.failure("unsafe_reference", "Source 文件引用无效。")
	for segment: String in segments:
		if segment.is_empty() or segment == "." or segment == "..":
			return Rules.failure("unsafe_reference", "Source 文件引用不得包含空、. 或 .. 路径段。")
	var extension := relative_path.get_extension().to_lower()
	var allowed := IMAGE_EXTENSIONS if kind in ["portrait", "scene", "map"] else DOCUMENT_EXTENSIONS if kind == "document" else []
	if not allowed.has(extension):
		return Rules.failure("unsupported_reference_type", "Source 文件类型与声明 kind 不匹配：%s" % relative_path)
	return Rules.success({"path": "/".join(segments)})


func _contains_link(package_root: String, relative_path: String) -> bool:
	var directory := DirAccess.open(package_root)
	if directory == null:
		return true
	var prefix := ""
	for segment: String in relative_path.split("/", false):
		prefix = segment if prefix.is_empty() else "%s/%s" % [prefix, segment]
		if directory.is_link(prefix):
			return true
	return false
