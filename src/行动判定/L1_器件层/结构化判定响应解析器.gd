class_name StructuredAdjudicationResponseParser
extends RefCounted

const Rules := preload("res://src/行动判定/L0_公理层/公开D20判定规则.gd")

var _action_id := ""
var _header_buffer := ""
var _body := ""
var _header_result: Dictionary = {}
var _failure: Dictionary = {}


## 每个 adjudication request 必须显式重置；解析器只保存当前请求的临时 framing 状态。
func reset(action_id: String) -> void:
	_action_id = action_id
	_header_buffer = ""
	_body = ""
	_header_result = {}
	_failure = {}


## 首个物理 LF 之前只累计控制头；验证成功后，NO_CHECK 的后续原文立即作为可见正文增量返回。
func push_delta(text: String) -> Dictionary:
	if not _failure.is_empty():
		return _failure.duplicate(true)
	if not _header_result.is_empty():
		return _consume_after_header(text)
	_header_buffer += text
	var newline_index := _header_buffer.find("\n")
	if newline_index < 0:
		return Rules.success({"status": "awaiting_header"})
	var header := _header_buffer.substr(0, newline_index)
	if header.ends_with("\r"):
		header = header.left(header.length() - 1)
	var remainder := _header_buffer.substr(newline_index + 1)
	_header_buffer = ""
	var parsed := _parse_header(header)
	if not parsed.success:
		return _remember_failure(parsed)
	_header_result = parsed.duplicate(true)
	var output := _header_result.duplicate(true)
	output["status"] = "header_validated"
	if not remainder.is_empty():
		var consumed := _consume_after_header(remainder)
		if not consumed.success:
			return consumed
		output.merge(consumed, true)
	return output


## Provider terminal 时，CHECK_REQUIRED 可用无尾 LF 的单行控制头；NO_CHECK 必须有 LF 分隔正文。
func finish() -> Dictionary:
	if not _failure.is_empty():
		return _failure.duplicate(true)
	if _header_result.is_empty():
		var parsed := _parse_header(_header_buffer)
		if not parsed.success:
			return _remember_failure(parsed)
		if String(parsed.decision) == "NO_CHECK":
			return _remember_failure(Rules.failure("missing_narrative_separator", "NO_CHECK 控制头后缺少物理 LF 与 narrative body。"))
		_header_result = parsed.duplicate(true)
	if String(_header_result.decision) == "CHECK_REQUIRED":
		return _header_result.duplicate(true)
	if _body.strip_edges().is_empty():
		return _remember_failure(Rules.failure("empty_generation", "NO_CHECK narrative body 为空。"))
	return Rules.success({
		"decision": "NO_CHECK",
		"reason": String(_header_result.reason),
		"narrative": _body,
	})


func _parse_header(text: String) -> Dictionary:
	if text.is_empty() or text != text.strip_edges():
		return Rules.failure("invalid_adjudication_json", "Provider adjudication 控制头必须是无前后空白的单行 JSON。")
	var parser := JSON.new()
	if parser.parse(text) != OK:
		return Rules.failure("invalid_adjudication_json", "Provider adjudication 控制头不是有效 JSON。")
	return Rules.validate_envelope(parser.data, _action_id)


func _consume_after_header(text: String) -> Dictionary:
	if String(_header_result.decision) == "CHECK_REQUIRED":
		if not text.strip_edges().is_empty():
			return _remember_failure(Rules.failure("unexpected_check_body", "CHECK_REQUIRED 控制头后不允许 narrative body。"))
		return Rules.success({"status": "control_only"})
	_body += text
	return Rules.success({
		"status": "narrative",
		"decision": "NO_CHECK",
		"reason": String(_header_result.reason),
		"narrative_delta": text,
	})


func _remember_failure(result: Dictionary) -> Dictionary:
	_failure = result.duplicate(true)
	return _failure.duplicate(true)
