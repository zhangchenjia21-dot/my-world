extends Control

enum RequestMode {
	NONE,
	PROVIDER,
	FAILURE_TEST,
}

enum ProviderId {
	DEEPSEEK,
	KIMI,
}

const PROVIDER_CONFIGS := {
	ProviderId.DEEPSEEK: {
		"name": "DeepSeek",
		"host": "api.deepseek.com",
		"port": 443,
		"path": "/chat/completions",
		"api_key_env": "DEEPSEEK_API_KEY",
		"model_env": "MY_WORLD_G1_04_DEEPSEEK_MODEL",
		"default_model": "deepseek-v4-pro",
	},
	ProviderId.KIMI: {
		"name": "Kimi",
		"host": "api.moonshot.ai",
		"port": 443,
		"path": "/v1/chat/completions",
		"api_key_env": "MOONSHOT_API_KEY",
		"model_env": "MY_WORLD_G1_04_KIMI_MODEL",
		"default_model": "kimi-k3",
	},
}

const SYSTEM_PROMPT := "你是 my world 的 G1-04 Foundation Spike 测试 GM。请只用中文输出 6 到 8 段连续叙事，每段 2 到 4 句。不要解释测试本身，不要使用 Markdown 标题。保持具体场景、人物行动与可继续游玩的悬念，让输出足够长以观察真实流式文本和中途取消。"
const FAILURE_HOST := "127.0.0.1"
const FAILURE_PORT := 1
const MAX_ERROR_BODY_CHARS := 2000

@onready var provider_select: OptionButton = %ProviderSelect
@onready var config_label: Label = %ConfigLabel
@onready var transcript: RichTextLabel = %Transcript
@onready var player_input: TextEdit = %PlayerInput
@onready var send_button: Button = %SendButton
@onready var cancel_button: Button = %CancelButton
@onready var failure_button: Button = %FailureButton
@onready var ping_button: Button = %PingButton
@onready var clear_button: Button = %ClearButton
@onready var status_label: Label = %StatusLabel
@onready var heartbeat_label: Label = %HeartbeatLabel

var http_client := HTTPClient.new()
var request_mode: RequestMode = RequestMode.NONE
var provider_id: ProviderId = ProviderId.DEEPSEEK
var request_active := false
var request_sent := false
var response_started := false
var response_code := 0
var pending_sse_bytes := PackedByteArray()
var error_body_bytes := PackedByteArray()
var provider_name := "DeepSeek"
var provider_host := "api.deepseek.com"
var provider_port := 443
var provider_path := "/chat/completions"
var api_key_env := "DEEPSEEK_API_KEY"
var model_env := "MY_WORLD_G1_04_DEEPSEEK_MODEL"
var api_key := ""
var model_name := "deepseek-v4-pro"
var request_started_msec := 0
var first_content_msec := -1
var output_characters := 0
var last_http_status := -1
var heartbeat_count := 0
var ui_ping_count := 0
var last_heartbeat_msec := 0


func _ready() -> void:
	http_client.read_chunk_size = 4096
	_build_provider_selector()
	provider_select.item_selected.connect(_on_provider_selected)
	send_button.pressed.connect(_start_provider_request)
	cancel_button.pressed.connect(_cancel_provider_request)
	failure_button.pressed.connect(_start_failure_test)
	ping_button.pressed.connect(_on_ui_ping)
	clear_button.pressed.connect(_clear_transcript)
	player_input.gui_input.connect(_on_player_input_gui_input)

	_reload_local_configuration()
	_seed_transcript()
	_update_controls()
	_update_status("就绪：请分别测试 DeepSeek 与 Kimi。")
	player_input.grab_focus()


func _process(_delta: float) -> void:
	_update_heartbeat()
	if not request_active:
		return

	var poll_error := http_client.poll()
	if poll_error != OK:
		_finish_failure("HTTPClient.poll() 失败，错误码 %d。" % poll_error)
		return

	var status := http_client.get_status()
	if status != last_http_status:
		last_http_status = status
		_update_status("%s ｜ %s" % [provider_name, _http_status_text(status)])

	match status:
		HTTPClient.STATUS_RESOLVING, HTTPClient.STATUS_CONNECTING, HTTPClient.STATUS_REQUESTING:
			pass
		HTTPClient.STATUS_CONNECTED:
			_handle_connected_status()
		HTTPClient.STATUS_BODY:
			_consume_response_body()
		HTTPClient.STATUS_CANT_RESOLVE:
			_finish_transport_error("DNS 解析失败")
		HTTPClient.STATUS_CANT_CONNECT:
			_finish_transport_error("无法连接到目标主机")
		HTTPClient.STATUS_CONNECTION_ERROR:
			_finish_transport_error("连接错误")
		HTTPClient.STATUS_TLS_HANDSHAKE_ERROR:
			_finish_transport_error("TLS 握手失败")
		HTTPClient.STATUS_DISCONNECTED:
			_handle_disconnected_status()


func _build_provider_selector() -> void:
	provider_select.clear()
	provider_select.add_item("DeepSeek", ProviderId.DEEPSEEK)
	provider_select.add_item("Kimi", ProviderId.KIMI)
	provider_select.select(0)


func _on_provider_selected(_index: int) -> void:
	if request_active:
		return
	_reload_local_configuration()
	_update_status("已选择 %s；等待发送。" % provider_name)


func _reload_local_configuration() -> void:
	provider_id = provider_select.get_selected_id() as ProviderId
	var config: Dictionary = PROVIDER_CONFIGS.get(provider_id, PROVIDER_CONFIGS[ProviderId.DEEPSEEK])
	provider_name = String(config.get("name", "Unknown"))
	provider_host = String(config.get("host", ""))
	provider_port = int(config.get("port", 443))
	provider_path = String(config.get("path", "/chat/completions"))
	api_key_env = String(config.get("api_key_env", ""))
	model_env = String(config.get("model_env", ""))
	var default_model := String(config.get("default_model", ""))
	api_key = OS.get_environment(api_key_env).strip_edges()
	var configured_model := OS.get_environment(model_env).strip_edges()
	model_name = configured_model if not configured_model.is_empty() else default_model

	config_label.text = "当前：%s ｜ Model: %s ｜ %s: %s ｜ DEEPSEEK_API_KEY: %s ｜ MOONSHOT_API_KEY: %s" % [
		provider_name,
		model_name,
		api_key_env,
		_key_state(api_key_env),
		_key_state("DEEPSEEK_API_KEY"),
		_key_state("MOONSHOT_API_KEY"),
	]


func _key_state(env_name: String) -> String:
	return "已设置" if not OS.get_environment(env_name).strip_edges().is_empty() else "未设置"


func _seed_transcript() -> void:
	transcript.clear()
	transcript.add_text("G1-04 DeepSeek + Kimi 真实 Provider stream / cancel / UI 非冻结 Foundation Spike\n\n")
	transcript.add_text("Provider 下拉框必须分别跑通 DeepSeek 与 Kimi。凭据只从 DEEPSEEK_API_KEY / MOONSHOT_API_KEY 读取，UI 只显示是否设置，不显示值。\n")
	transcript.add_text("发送后观察文字是否逐步出现；生成期间持续观察 heartbeat，并点击“UI 响应 +1”。\n")
	transcript.add_text("“连接失败测试”只连接本机 127.0.0.1:1，不携带任何 Provider 凭据。\n\n")


func _start_provider_request() -> void:
	if request_active:
		return

	_reload_local_configuration()
	if api_key.is_empty():
		_update_status("缺少 %s；请在启动 Godot 的同一个 PowerShell 会话中设置。" % api_key_env)
		return

	var prompt := player_input.text.strip_edges()
	if prompt.is_empty():
		_update_status("请输入一段中文玩家行动后再发送。")
		return

	_reset_transport_state()
	request_mode = RequestMode.PROVIDER
	request_active = true
	request_started_msec = Time.get_ticks_msec()
	transcript.add_text("【玩家】\n%s\n\n【%s · %s · real stream】\n" % [prompt, provider_name, model_name])
	_update_controls()
	_update_status("连接 %s…" % provider_name)

	var connect_error := http_client.connect_to_host(provider_host, provider_port, TLSOptions.client())
	if connect_error != OK:
		_finish_failure("%s connect_to_host() 失败，错误码 %d。" % [provider_name, connect_error])


func _start_failure_test() -> void:
	if request_active:
		return

	_reset_transport_state()
	request_mode = RequestMode.FAILURE_TEST
	request_active = true
	request_started_msec = Time.get_ticks_msec()
	transcript.add_text("\n【连接失败测试】尝试连接 127.0.0.1:1（无 API key / 无 Provider 请求）。\n")
	_update_controls()
	_update_status("执行确定性连接失败测试…")

	var connect_error := http_client.connect_to_host(FAILURE_HOST, FAILURE_PORT)
	if connect_error != OK:
		_finish_expected_failure("connect_to_host() 立即返回错误码 %d" % connect_error)


func _handle_connected_status() -> void:
	if request_mode == RequestMode.FAILURE_TEST:
		_finish_failure("连接失败测试意外连上了 127.0.0.1:1；该端口在本机可能被占用。")
		return

	if request_mode != RequestMode.PROVIDER:
		return

	if not request_sent:
		_send_provider_request()
		return

	if response_started:
		if response_code < 200 or response_code >= 300:
			_finish_http_error()
		else:
			_finish_failure("%s HTTP 连接在收到 data: [DONE] 之前结束。" % provider_name)


func _send_provider_request() -> void:
	var payload := {
		"model": model_name,
		"messages": [
			{"role": "system", "content": SYSTEM_PROMPT},
			{"role": "user", "content": player_input.text.strip_edges()},
		],
		"stream": true,
	}
	if provider_id == ProviderId.KIMI and model_name == "kimi-k3":
		payload["reasoning_effort"] = "low"

	var body := JSON.stringify(payload)
	var body_bytes := body.to_utf8_buffer()
	var headers := PackedStringArray([
		"Authorization: Bearer %s" % api_key,
		"Content-Type: application/json",
		"Accept: text/event-stream",
		"Content-Length: %d" % body_bytes.size(),
	])

	var request_error := http_client.request(
		HTTPClient.METHOD_POST,
		provider_path,
		headers,
		body,
	)
	if request_error != OK:
		_finish_failure("%s HTTP request() 失败，错误码 %d。" % [provider_name, request_error])
		return

	request_sent = true
	_update_status("%s 请求已发送，等待 HTTP 响应…" % provider_name)


func _consume_response_body() -> void:
	if not response_started:
		response_started = true
		response_code = http_client.get_response_code()
		if response_code >= 200 and response_code < 300:
			_update_status("%s HTTP %d；正在接收真实 SSE…" % [provider_name, response_code])
		else:
			_update_status("%s HTTP %d；正在读取错误响应…" % [provider_name, response_code])

	for _index in range(32):
		var chunk := http_client.read_response_body_chunk()
		if chunk.is_empty():
			break

		if response_code >= 200 and response_code < 300:
			_feed_sse_bytes(chunk)
		else:
			error_body_bytes.append_array(chunk)

		if not request_active:
			break


func _feed_sse_bytes(chunk: PackedByteArray) -> void:
	pending_sse_bytes.append_array(chunk)

	while true:
		var newline_index := pending_sse_bytes.find(10)
		if newline_index < 0:
			return

		var line_bytes := pending_sse_bytes.slice(0, newline_index)
		pending_sse_bytes = pending_sse_bytes.slice(newline_index + 1)
		if not line_bytes.is_empty() and line_bytes[line_bytes.size() - 1] == 13:
			line_bytes.resize(line_bytes.size() - 1)

		_handle_sse_line(line_bytes.get_string_from_utf8())
		if not request_active:
			return


func _handle_sse_line(line: String) -> void:
	if line.is_empty() or line.begins_with(":") or line.begins_with("event:"):
		return
	if not line.begins_with("data:"):
		return

	var payload := line.substr(5).strip_edges()
	if payload == "[DONE]":
		_finish_success()
		return
	if payload.is_empty():
		return

	var decoded: Variant = JSON.parse_string(payload)
	if typeof(decoded) != TYPE_DICTIONARY:
		_finish_failure("%s 收到无法解析的 SSE JSON 数据。" % provider_name)
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

	if first_content_msec < 0:
		first_content_msec = Time.get_ticks_msec()
	transcript.add_text(content)
	output_characters += content.length()
	_update_stream_metrics()


func _cancel_provider_request() -> void:
	if not request_active or request_mode != RequestMode.PROVIDER:
		return

	var elapsed := Time.get_ticks_msec() - request_started_msec
	http_client.close()
	request_active = false
	request_mode = RequestMode.NONE
	transcript.add_text("\n\n【%s 已取消】收到 %d 个字符，用时 %.2f 秒。\n\n" % [provider_name, output_characters, elapsed / 1000.0])
	_update_controls()
	_update_status("%s 已取消；可以切换 Provider 或立即重试。" % provider_name)


func _finish_success() -> void:
	var elapsed := Time.get_ticks_msec() - request_started_msec
	var first_token_text := "未记录"
	if first_content_msec >= 0:
		first_token_text = "%.0f ms" % float(first_content_msec - request_started_msec)

	http_client.close()
	request_active = false
	request_mode = RequestMode.NONE
	transcript.add_text("\n\n【%s 完成】真实 SSE 完成；字符 %d；首段内容延迟 %s；总用时 %.2f 秒。\n\n" % [
		provider_name,
		output_characters,
		first_token_text,
		elapsed / 1000.0,
	])
	_update_controls()
	_update_status("%s 真实 Provider 流式请求完成。" % provider_name)


func _finish_http_error() -> void:
	var error_text := error_body_bytes.get_string_from_utf8().strip_edges()
	if error_text.length() > MAX_ERROR_BODY_CHARS:
		error_text = error_text.left(MAX_ERROR_BODY_CHARS) + "…"
	if error_text.is_empty():
		error_text = "<empty body>"
	_finish_failure("%s 返回 HTTP %d：%s" % [provider_name, response_code, error_text])


func _finish_transport_error(message: String) -> void:
	if request_mode == RequestMode.FAILURE_TEST:
		_finish_expected_failure(message)
	else:
		_finish_failure("%s：%s" % [provider_name, message])


func _finish_expected_failure(message: String) -> void:
	http_client.close()
	request_active = false
	request_mode = RequestMode.NONE
	transcript.add_text("【连接失败路径 PASS】%s。UI 仍可继续操作。\n\n" % message)
	_update_controls()
	_update_status("连接失败路径已明确处理。")


func _finish_failure(message: String) -> void:
	http_client.close()
	request_active = false
	request_mode = RequestMode.NONE
	transcript.add_text("\n【错误】%s\n\n" % message)
	_update_controls()
	_update_status(message)


func _handle_disconnected_status() -> void:
	if request_mode == RequestMode.FAILURE_TEST:
		_finish_expected_failure("连接保持为 DISCONNECTED")
		return
	if request_mode == RequestMode.PROVIDER:
		if response_started and (response_code < 200 or response_code >= 300):
			_finish_http_error()
		else:
			_finish_failure("%s 连接在完成前断开。" % provider_name)


func _reset_transport_state() -> void:
	http_client.close()
	request_mode = RequestMode.NONE
	request_active = false
	request_sent = false
	response_started = false
	response_code = 0
	pending_sse_bytes.clear()
	error_body_bytes.clear()
	request_started_msec = 0
	first_content_msec = -1
	output_characters = 0
	last_http_status = -1


func _on_ui_ping() -> void:
	ui_ping_count += 1
	_update_status("UI 响应计数 = %d；当前 Provider = %s；网络状态 = %s" % [ui_ping_count, provider_name, _http_status_text(http_client.get_status())])


func _clear_transcript() -> void:
	if request_active:
		_update_status("请求进行中时不清空；可先 Cancel。")
		return
	_seed_transcript()
	_update_status("文本已清空。")


func _on_player_input_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.ctrl_pressed and key_event.keycode == KEY_ENTER:
			_start_provider_request()
			player_input.accept_event()


func _update_controls() -> void:
	provider_select.disabled = request_active
	send_button.disabled = request_active
	cancel_button.disabled = not request_active or request_mode != RequestMode.PROVIDER
	failure_button.disabled = request_active
	clear_button.disabled = request_active


func _update_heartbeat() -> void:
	var now := Time.get_ticks_msec()
	if now - last_heartbeat_msec < 250:
		return
	last_heartbeat_msec = now
	heartbeat_count += 1
	var mode_text := "idle"
	if request_active:
		mode_text = "network active"
	heartbeat_label.text = "UI heartbeat: %d ｜ %s ｜ Provider: %s ｜ UI ping: %d" % [heartbeat_count, mode_text, provider_name, ui_ping_count]


func _update_stream_metrics() -> void:
	var first_token_text := "等待首段内容"
	if first_content_msec >= 0:
		first_token_text = "first content %d ms" % (first_content_msec - request_started_msec)
	status_label.text = "%s 真实 SSE：%d 字符 ｜ %s ｜ HTTP %d" % [provider_name, output_characters, first_token_text, response_code]


func _update_status(message: String) -> void:
	status_label.text = message


func _http_status_text(status: int) -> String:
	match status:
		HTTPClient.STATUS_DISCONNECTED:
			return "DISCONNECTED"
		HTTPClient.STATUS_RESOLVING:
			return "RESOLVING"
		HTTPClient.STATUS_CANT_RESOLVE:
			return "CANT_RESOLVE"
		HTTPClient.STATUS_CONNECTING:
			return "CONNECTING"
		HTTPClient.STATUS_CANT_CONNECT:
			return "CANT_CONNECT"
		HTTPClient.STATUS_CONNECTED:
			return "CONNECTED"
		HTTPClient.STATUS_REQUESTING:
			return "REQUESTING"
		HTTPClient.STATUS_BODY:
			return "BODY"
		HTTPClient.STATUS_CONNECTION_ERROR:
			return "CONNECTION_ERROR"
		HTTPClient.STATUS_TLS_HANDSHAKE_ERROR:
			return "TLS_HANDSHAKE_ERROR"
		_:
			return "UNKNOWN(%d)" % status
