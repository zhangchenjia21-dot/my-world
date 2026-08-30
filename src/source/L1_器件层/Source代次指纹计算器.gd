class_name SourceGenerationFingerprintCalculator
extends RefCounted

const Rules := preload("res://src/source/L0_公理层/Source合同规则.gd")


## 指纹只由 canonical manifest 与 contract 声明文件的真实 bytes 决定。
## 文件先按规范路径排序，所以 OS directory iteration 不参与结果。
func calculate(manifest: Dictionary, referenced_files: Array) -> Dictionary:
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK:
		return Rules.failure("fingerprint_failed", "无法初始化 SHA-256。")
	# v0.1 保持历史 domain separator，避免升级后让已安装 generation 身份漂移。
	var separator := "MY_WORLD_SOURCE_V0.2" if String(manifest.get("schema_version", "")).ends_with(".v0.2") else "MY_WORLD_SOURCE_V0.1"
	_update_text(context, "%s\nMANIFEST\n" % separator)
	_update_text(context, JSON.stringify(_canonicalize(manifest)))
	var files := referenced_files.duplicate(true)
	files.sort_custom(func(left: Dictionary, right: Dictionary) -> bool: return String(left.path) < String(right.path))
	for file_data: Dictionary in files:
		var bytes: PackedByteArray = file_data.bytes
		_update_text(context, "\nFILE\n%s\n%d\n" % [String(file_data.path), bytes.size()])
		context.update(bytes)
	var digest := context.finish()
	if digest.size() != 32:
		return Rules.failure("fingerprint_failed", "SHA-256 未返回完整摘要。")
	return Rules.success({"fingerprint": digest.hex_encode()})


func _canonicalize(value: Variant) -> Variant:
	if value is Dictionary:
		var source := value as Dictionary
		var keys := source.keys()
		keys.sort_custom(func(left: Variant, right: Variant) -> bool: return String(left) < String(right))
		var result := {}
		for key: Variant in keys:
			result[key] = _canonicalize(source[key])
		return result
	if value is Array:
		var result_array := []
		for item: Variant in value:
			result_array.append(_canonicalize(item))
		return result_array
	return value


func _update_text(context: HashingContext, value: String) -> void:
	context.update(value.to_utf8_buffer())
