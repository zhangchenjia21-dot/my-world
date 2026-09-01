class_name FirstOpeningRuntimeProcess
extends Node

const Rules := preload("res://src/首次开场/L0_公理层/首次开场规则.gd")
const Projector := preload("res://src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd")
const ContextAssembler := preload("res://src/context/L3_外交层/上下文组装公开接口.gd")
const ProviderAdapter := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")

signal request_assembled(messages, context_stats)
signal text_delta(text)
signal finished(result)

var session_runtime: Variant = null
var provider_adapter: Node = null
var last_request_messages: Array = []
var last_context_stats: Dictionary = {}
var last_result: Dictionary = {"success": false, "status": "not_started", "message": ""}

var _projector := Projector.new()
var _context_assembler := ContextAssembler.new()


func _init(runtime: Variant = null, adapter_override: Node = null) -> void:
	session_runtime = runtime
	provider_adapter = adapter_override if adapter_override != null else ProviderAdapter.new()
	_connect_provider()


func _ready() -> void:
	if provider_adapter != null and provider_adapter.get_parent() == null:
		add_child(provider_adapter)


## 成功启动只表示 request 已进入既有 Provider streaming；accepted 必须等待 finished。
func start_first_opening() -> Dictionary:
	if provider_adapter == null:
		return _publish_terminal(Rules.failure("provider_unavailable", "当前模型 Provider adapter 不可用。"))
	if provider_adapter.is_busy():
		return Rules.failure("generation_active", "当前模型 Provider 已有 active request。")
	var eligibility := Rules.inspect_eligibility(session_runtime)
	if not eligibility.success:
		last_result = eligibility.duplicate(true)
		return last_result.duplicate(true)
	var projected := _projector.project(eligibility.setup)
	if not projected.success:
		last_result = projected.duplicate(true)
		return last_result.duplicate(true)
	if session_runtime.conversation.begin_gm_opening() == null:
		return _publish_terminal(Rules.failure("generation_active", "无法建立首次 GM Opening attempt。"))

	last_context_stats = (projected.stats as Dictionary).duplicate(true)
	last_request_messages = _context_assembler.assemble_first_opening_messages(String(projected.context_text))
	request_assembled.emit(last_request_messages.duplicate(true), last_context_stats.duplicate(true))
	last_result = {"success": true, "status": "streaming", "message": "", "context_stats": last_context_stats.duplicate(true)}
	var start_error: Error = provider_adapter.start_stream(last_request_messages)
	# missing-key 等同步终态会在 start_stream 返回前经 failed signal 发布。
	if start_error != OK and String(last_result.get("status", "")) == "streaming":
		session_runtime.conversation.fail_generation("provider_start_failure")
		return _publish_terminal(Rules.failure("provider_start_failure", "当前模型 request 未能启动。", {"error": start_error}))
	return last_result.duplicate(true)


func cancel() -> void:
	if provider_adapter != null and provider_adapter.is_busy():
		provider_adapter.cancel()


## Reopen 后的普通续玩仍使用同一个 Game-local projector 与 G2 Context owner。
## 调用方先在 existing Conversation 上 begin_turn，再把 derived messages 交给既有 Provider；
## 本方法不发网、不持久化 messages，也不另建 continuation transcript。
func assemble_continuation_messages() -> Dictionary:
	if session_runtime == null or not session_runtime.has_method("is_ready") or not session_runtime.is_ready():
		return Rules.failure("runtime_not_ready", "既有 Game session 尚未安全打开。")
	var projected := _projector.project(session_runtime.world_state)
	if not projected.success:
		return projected
	var messages := _context_assembler.assemble_messages(
		session_runtime.conversation.get_context_projection(),
		String(projected.context_text)
	)
	return Rules.success({
		"messages": messages,
		"context_stats": (projected.stats as Dictionary).duplicate(true),
	})


func _on_text_delta(text: String) -> void:
	if session_runtime == null or session_runtime.conversation == null:
		return
	session_runtime.conversation.append_delta(text)
	text_delta.emit(text)


func _on_completed() -> void:
	if session_runtime == null:
		_publish_terminal(Rules.failure("runtime_not_ready", "Provider completed 后 Game runtime 不可用。"))
		return
	var accepted: Dictionary = session_runtime.complete_active_generation_durably()
	if accepted.success:
		_publish_terminal(Rules.success({
			"status": "accepted",
			"accepted_count": session_runtime.conversation.get_durable_accepted_entries().size(),
			"context_stats": last_context_stats.duplicate(true),
		}))
	else:
		_publish_terminal(Rules.failure(String(accepted.get("status", "acceptance_failure")), String(accepted.get("message", "Opening 未能 durable accept。"))))


func _on_cancelled() -> void:
	if session_runtime != null and session_runtime.conversation != null:
		session_runtime.conversation.cancel_generation()
	_publish_terminal(Rules.failure("cancelled", "首次 Opening 已取消；partial draft 未进入 durable truth。"))


func _on_failed(code: String, message: String) -> void:
	if session_runtime != null and session_runtime.conversation != null:
		session_runtime.conversation.fail_generation(code)
	_publish_terminal(Rules.failure(code, message))


func _publish_terminal(result: Dictionary) -> Dictionary:
	last_result = result.duplicate(true)
	finished.emit(last_result.duplicate(true))
	return last_result.duplicate(true)


func _connect_provider() -> void:
	if provider_adapter == null:
		return
	provider_adapter.text_delta.connect(_on_text_delta)
	provider_adapter.completed.connect(_on_completed)
	provider_adapter.cancelled.connect(_on_cancelled)
	provider_adapter.failed.connect(_on_failed)
