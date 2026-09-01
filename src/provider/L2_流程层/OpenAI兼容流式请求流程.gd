class_name OpenAICompatibleStreamingRequestProcess
extends Node

const DeltaParser := preload("res://src/provider/L1_器件层/OpenAI兼容流增量解析器.gd")
const MAX_ERROR_BODY_CHARS := 500

signal text_delta(text: String)
signal completed()
signal cancelled()
signal failed(code: String, message: String)

enum State { IDLE, ACTIVE }

var test_host_override := ""
var test_port_override := 0
var started_msec := 0
var first_delta_msec := -1
var finished_msec := -1
var delta_count := 0
var output_chars := 0
var network_attempt_count := 0
var last_request_snapshot: Dictionary = {}
var last_request_payload: Dictionary = {}

var _http := HTTPClient.new()
var _state: State = State.IDLE
var _terminated := false
var _request_sent := false
var _response_started := false
var _response_code := 0
var _sse_pending := PackedByteArray()
var _error_body := PackedByteArray()
var _api_key := ""
var _parser := DeltaParser.new()


func _ready() -> void:
	_http.read_chunk_size = 4096


## profile 与 credential 已由 L3 trust boundary 校验并冻结；本流程只执行单一 HTTP/SSE 生命周期。
func start_stream_with_profile(messages: Array, profile: Dictionary, api_key: String) -> Error:
	if _state == State.ACTIVE:
		return ERR_BUSY
	last_request_snapshot = profile.duplicate(true)
	last_request_payload = _build_payload(messages, profile)
	_api_key = api_key
	_http.close()
	_state = State.ACTIVE
	_terminated = false
	_request_sent = false
	_response_started = false
	_response_code = 0
	_sse_pending.clear()
	_error_body.clear()
	started_msec = Time.get_ticks_msec()
	first_delta_msec = -1
	finished_msec = -1
	delta_count = 0
	output_chars = 0
	var host := test_host_override if not test_host_override.is_empty() else String(profile.host)
	var port := test_port_override if test_port_override > 0 else int(profile.port)
	network_attempt_count += 1
	var connect_error: Error
	if test_host_override.is_empty():
		connect_error = _http.connect_to_host(host, port, TLSOptions.client())
	else:
		connect_error = _http.connect_to_host(host, port)
	if connect_error != OK:
		_finish_failed("transport", "connect_to_host() 失败，错误码 %d。" % connect_error)
		return connect_error
	return OK


func cancel() -> void:
	if _state == State.ACTIVE:
		_finish_cancelled()


func is_busy() -> bool:
	return _state == State.ACTIVE


func _process(_delta: float) -> void:
	if _state != State.ACTIVE:
		return
	var poll_error := _http.poll()
	if poll_error != OK:
		_finish_failed("transport", "HTTPClient.poll() 失败，错误码 %d。" % poll_error)
		return
	match _http.get_status():
		HTTPClient.STATUS_RESOLVING, HTTPClient.STATUS_CONNECTING, HTTPClient.STATUS_REQUESTING:
			pass
		HTTPClient.STATUS_CONNECTED:
			if not _request_sent:
				_send_request()
		HTTPClient.STATUS_BODY:
			_consume_body()
		HTTPClient.STATUS_CANT_RESOLVE:
			_finish_failed("transport", "DNS 解析失败。")
		HTTPClient.STATUS_CANT_CONNECT:
			_finish_failed("transport", "无法连接到目标主机。")
		HTTPClient.STATUS_CONNECTION_ERROR:
			_finish_failed("transport", "连接错误。")
		HTTPClient.STATUS_TLS_HANDSHAKE_ERROR:
			_finish_failed("transport", "TLS 握手失败。")
		HTTPClient.STATUS_DISCONNECTED:
			_handle_disconnected()


func _build_payload(messages: Array, profile: Dictionary) -> Dictionary:
	var payload := {"model": String(profile.model_id), "messages": messages.duplicate(true), "stream": true}
	if bool(profile.graded_reasoning):
		payload["reasoning_effort"] = String(profile.reasoning_effective)
	return payload


func _send_request() -> void:
	var body := JSON.stringify(last_request_payload)
	var body_bytes := body.to_utf8_buffer()
	var headers := PackedStringArray([
		"Authorization: Bearer %s" % _api_key,
		"Content-Type: application/json",
		"Accept: text/event-stream",
		"Content-Length: %d" % body_bytes.size(),
	])
	var request_error := _http.request(HTTPClient.METHOD_POST, String(last_request_snapshot.request_path), headers, body)
	if request_error != OK:
		_finish_failed("transport", "HTTP request() 失败，错误码 %d。" % request_error)
		return
	_request_sent = true


func _consume_body() -> void:
	if not _response_started:
		_response_started = true
		_response_code = _http.get_response_code()
	for _index in range(32):
		var chunk := _http.read_response_body_chunk()
		if chunk.is_empty():
			break
		if _response_code >= 200 and _response_code < 300:
			_feed_sse_bytes(chunk)
		else:
			_error_body.append_array(chunk)
		if _state != State.ACTIVE:
			break


func _feed_sse_bytes(chunk: PackedByteArray) -> void:
	_sse_pending.append_array(chunk)
	while true:
		var newline_index := _sse_pending.find(10)
		if newline_index < 0:
			return
		var line_bytes := _sse_pending.slice(0, newline_index)
		_sse_pending = _sse_pending.slice(newline_index + 1)
		if not line_bytes.is_empty() and line_bytes[line_bytes.size() - 1] == 13:
			line_bytes.resize(line_bytes.size() - 1)
		_handle_sse_line(line_bytes.get_string_from_utf8())
		if _state != State.ACTIVE:
			return


func _handle_sse_line(line: String) -> void:
	if line.is_empty() or line.begins_with(":") or line.begins_with("event:") or not line.begins_with("data:"):
		return
	var payload := line.substr(5).strip_edges()
	if payload.is_empty():
		return
	var parsed := _parser.parse_data_payload(payload)
	if not parsed.success:
		_finish_failed(String(parsed.status), String(parsed.message))
		return
	match String(parsed.kind):
		"done":
			_finish_completed()
		"content":
			var content := String(parsed.content)
			if first_delta_msec < 0:
				first_delta_msec = Time.get_ticks_msec()
			delta_count += 1
			output_chars += content.length()
			text_delta.emit(content)


func _handle_disconnected() -> void:
	if _state != State.ACTIVE:
		return
	if _response_started and (_response_code < 200 or _response_code >= 300):
		_finish_http_error()
	else:
		_finish_failed("transport", "连接在完成前断开。")


func _finish_http_error() -> void:
	var error_text := _error_body.get_string_from_utf8().strip_edges()
	if not _api_key.is_empty():
		error_text = error_text.replace(_api_key, "[redacted]")
	if error_text.length() > MAX_ERROR_BODY_CHARS:
		error_text = error_text.left(MAX_ERROR_BODY_CHARS) + "…"
	if error_text.is_empty():
		error_text = "<empty body>"
	_finish_failed("http_%d" % _response_code, "Provider 返回 HTTP %d：%s" % [_response_code, error_text])


func _finish_completed() -> void:
	if _terminated:
		return
	_terminated = true
	finished_msec = Time.get_ticks_msec()
	_http.close()
	_state = State.IDLE
	_api_key = ""
	completed.emit()


func _finish_cancelled() -> void:
	if _terminated:
		return
	_terminated = true
	finished_msec = Time.get_ticks_msec()
	_http.close()
	_state = State.IDLE
	_api_key = ""
	cancelled.emit()


func _finish_failed(code: String, message: String) -> void:
	if _terminated:
		return
	_terminated = true
	finished_msec = Time.get_ticks_msec()
	_http.close()
	_state = State.IDLE
	_api_key = ""
	failed.emit(code, message)
