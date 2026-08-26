extends Node

## DeepSeek Provider Adapter v0.1（G2-02）。
##
## 公开契约（薄 seam，供 G2-03 Conversation View 消费）：
##   start_stream(messages) -> Error  启动一条流式请求；busy 时返回 ERR_BUSY 且不影响进行中的请求
##   cancel()                        主动取消当前 generation
##   is_busy() -> bool               是否有 active 请求
##   信号 text_delta(text) / completed() / cancelled() / failed(code, message)
##
## 边界：
## - 只产品化 DeepSeek；不做 registry / routing / fallback / 账号体系。
## - messages 形态是 provisional adapter contract，不是 G2-04 Turn/Conversation Domain DTO。
## - API key 只从 DEEPSEEK_API_KEY 环境变量读取；不打印、不进入日志、不进入错误详情（INV-SECRET-01）。
## - 同一 generation 的 completed / cancelled / failed 只发一次（INV-CANCEL-01 双终止保护）。

signal text_delta(text: String)
signal completed()
signal cancelled()
signal failed(code: String, message: String)

const HOST := "api.deepseek.com"
const PORT := 443
const REQUEST_PATH := "/chat/completions"
const DEFAULT_MODEL := "deepseek-v4-pro"
const API_KEY_ENV := "DEEPSEEK_API_KEY"
const MODEL_ENV := "MY_WORLD_DEEPSEEK_MODEL"
const MAX_ERROR_BODY_CHARS := 500

enum State {
	IDLE,
	ACTIVE,
}

## 仅测试注入用：非空时替代真实 HOST/PORT，供 credential-free deterministic failure 测试
## 指向本机拒绝端口。不是通用 endpoint 平台，产品路径不得设置。
var test_host_override := ""
var test_port_override := 0

# 粗粒度性能证据（TTFT / 完成耗时 / delta 计数），供测试与报告读取。
var started_msec := 0
var first_delta_msec := -1
var finished_msec := -1
var delta_count := 0
var output_chars := 0

var _http := HTTPClient.new()
var _state: State = State.IDLE
var _terminated := false
var _request_sent := false
var _response_started := false
var _response_code := 0
var _sse_pending := PackedByteArray()
var _error_body := PackedByteArray()
var _api_key := ""
var _model := DEFAULT_MODEL
var _messages: Array = []


func _ready() -> void:
	_http.read_chunk_size = 4096


## messages 使用 OpenAI-compatible [{"role": ..., "content": ...}, ...] 形态。
## key 缺失时禁止发网（INV-ERROR-01），同步发出 failed("missing_key")。
func start_stream(messages: Array) -> Error:
	if _state == State.ACTIVE:
		# 重复 start 只返回错误码；不发 failed 信号，避免被误读为进行中请求的终态。
		return ERR_BUSY

	var api_key := OS.get_environment(API_KEY_ENV).strip_edges()
	if api_key.is_empty():
		_terminated = true
		failed.emit("missing_key", "%s 未设置；未发起任何网络请求。" % API_KEY_ENV)
		return ERR_UNAUTHORIZED

	var model := OS.get_environment(MODEL_ENV).strip_edges()
	_model = model if not model.is_empty() else DEFAULT_MODEL
	_api_key = api_key
	_messages = messages

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

	var host := test_host_override if not test_host_override.is_empty() else HOST
	var port := test_port_override if test_port_override > 0 else PORT
	# 测试注入目标是本机明文拒绝端口，不走 TLS（沿用 G1-04 已验证的确定性失败形态）。
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
	if _state != State.ACTIVE:
		return
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


func _send_request() -> void:
	var payload := {
		"model": _model,
		"messages": _messages,
		"stream": true,
	}
	var body := JSON.stringify(payload)
	var body_bytes := body.to_utf8_buffer()
	var headers := PackedStringArray([
		"Authorization: Bearer %s" % _api_key,
		"Content-Type: application/json",
		"Accept: text/event-stream",
		"Content-Length: %d" % body_bytes.size(),
	])

	var request_error := _http.request(HTTPClient.METHOD_POST, REQUEST_PATH, headers, body)
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
	if line.is_empty() or line.begins_with(":") or line.begins_with("event:"):
		return
	if not line.begins_with("data:"):
		return

	var payload := line.substr(5).strip_edges()
	if payload == "[DONE]":
		_finish_completed()
		return
	if payload.is_empty():
		return

	var decoded: Variant = JSON.parse_string(payload)
	if typeof(decoded) != TYPE_DICTIONARY:
		_finish_failed("malformed_stream", "收到无法解析的 SSE JSON 数据。")
		return

	var data: Dictionary = decoded
	var choices_value: Variant = data.get("choices", [])
	if typeof(choices_value) != TYPE_ARRAY:
		return
	var choices: Array = choices_value
	if choices.is_empty():
		return

	var first_choice_value: Variant = choices[0]
	if typeof(first_choice_value) != TYPE_DICTIONARY:
		return
	var first_choice: Dictionary = first_choice_value
	var delta_value: Variant = first_choice.get("delta", {})
	if typeof(delta_value) != TYPE_DICTIONARY:
		return
	var delta: Dictionary = delta_value
	var content_value: Variant = delta.get("content", "")
	if typeof(content_value) != TYPE_STRING:
		return
	var content: String = content_value
	if content.is_empty():
		return

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
	completed.emit()


func _finish_cancelled() -> void:
	if _terminated:
		return
	_terminated = true
	finished_msec = Time.get_ticks_msec()
	_http.close()
	_state = State.IDLE
	cancelled.emit()


func _finish_failed(code: String, message: String) -> void:
	if _terminated:
		return
	_terminated = true
	finished_msec = Time.get_ticks_msec()
	_http.close()
	_state = State.IDLE
	failed.emit(code, message)
