extends Node

const InputBuilder := preload("res://src/行动推荐/L1_器件层/推荐材料构建器.gd")
const Parser := preload("res://src/行动推荐/L1_器件层/推荐响应解析器.gd")
const Contract := preload("res://src/行动推荐/L0_公理层/行动推荐契约.gd")

signal changed

var _runtime: RefCounted
var _conversation: RefCounted
var _adapter: Node
var _timer: Timer
var _serial := 0
var _active := false
var _closed := false
var _foreground := false
var _attempted_prefix := ""
var _request_prefix := ""
var _text := ""
var _state := "empty"
var _actions: Array = []
var _callbacks: Dictionary = {}

func _ready() -> void:
	add_child(_adapter)
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.wait_time = 120.0
	add_child(_timer)
	_conversation = _runtime.conversation
	_conversation.attempt_started.connect(_on_attempt)
	_conversation.generation_completed.connect(_on_accepted)
	_runtime.restore_completed.connect(_on_restore)
	_foreground = _conversation.is_generating()
	_consider.call_deferred(_serial)

## 只读、内存中的玩家安全投影；调用不会发起请求，也不暴露 epoch/prefix/运行时材料。
func snapshot() -> Dictionary:
	return {"status": _state, "actions": _actions.duplicate()}

## 前台优先：d20 在 Conversation attempt 前开始，调用方须在判定启动前调用此 seam。
func interrupt_foreground() -> void:
	_invalidate()
	_foreground = true

func _on_attempt(_turn: RefCounted) -> void:
	interrupt_foreground()

func _on_accepted(_turn: RefCounted) -> void:
	_invalidate()
	_foreground = false
	_consider.call_deferred(_serial)

func _on_restore(_result: Dictionary) -> void:
	_invalidate()
	_foreground = _conversation.is_generating()
	_consider.call_deferred(_serial)

func _consider(epoch: int) -> void:
	if _closed or epoch != _serial or _foreground or not _runtime.is_ready() or _conversation.is_generating():
		return
	var entries: Array = _conversation.get_durable_accepted_entries()
	if entries.is_empty():
		return
	var prefix := InputBuilder.prefix(entries)
	if prefix == _attempted_prefix:
		return
	_attempted_prefix = prefix
	var messages := InputBuilder.build(entries)
	if messages.is_empty():
		_publish("unavailable")
		return
	_request_prefix = prefix
	_active = true
	_callbacks = {"text_delta": _on_delta.bind(epoch), "completed": _on_completed.bind(epoch),
		"failed": _on_failed.bind(epoch), "cancelled": _on_cancelled.bind(epoch)}
	for key: String in _callbacks:
		_adapter.connect(key, _callbacks[key])
	_timer.timeout.connect(_on_timeout.bind(epoch), CONNECT_ONE_SHOT)
	_timer.start()
	_publish("loading")
	var result: Error = _adapter.start_stream(messages)
	if result != OK and _is_current(epoch):
		_finish([], true)

func _is_current(epoch: int) -> bool:
	return (not _closed and _active and epoch == _serial and not _foreground
		and _runtime.is_ready() and not _conversation.is_generating()
		and _request_prefix == InputBuilder.prefix(_conversation.get_durable_accepted_entries()))

func _on_delta(delta: String, epoch: int) -> void:
	if not _is_current(epoch):
		return
	if _text.to_utf8_buffer().size() + delta.to_utf8_buffer().size() > Contract.RESPONSE_BYTES:
		_finish([], true)
		return
	_text += delta

func _on_completed(epoch: int) -> void:
	if _is_current(epoch):
		_finish(Parser.parse(_text))

func _on_failed(_code: String, _message: String, epoch: int) -> void:
	if _is_current(epoch):
		_finish([])

func _on_cancelled(epoch: int) -> void:
	if _is_current(epoch):
		_finish([])

func _on_timeout(epoch: int) -> void:
	if _is_current(epoch):
		_finish([], true)

func _finish(actions: Array, cancel_transport: bool = false) -> void:
	_disconnect_request(cancel_transport)
	_actions = actions
	_publish("ready" if actions.size() == Contract.ACTION_COUNT else "unavailable")

func _publish(state: String) -> void:
	_state = state
	changed.emit()

func _invalidate() -> void:
	_serial += 1
	_disconnect_request(true)
	_attempted_prefix = ""
	_actions.clear()
	_publish("empty")

## 先解绑再取消，避免同步 cancelled 与已排队旧回调重入；serial 还隔离新请求后的旧闭包。
func _disconnect_request(cancel_transport: bool) -> void:
	_active = false
	for key: String in _callbacks:
		if _adapter.is_connected(key, _callbacks[key]):
			_adapter.disconnect(key, _callbacks[key])
	_callbacks.clear()
	if _timer != null:
		_timer.stop()
		for connection: Dictionary in _timer.timeout.get_connections():
			_timer.timeout.disconnect(connection.callable)
	if cancel_transport and _adapter != null and _adapter.is_busy():
		_adapter.cancel()
	_text = ""
	_request_prefix = ""

## 在关闭 Runtime/数据库之前拆除；不写 Save/World/Conversation，也不依赖后台 lane 成功。
func shutdown() -> void:
	if _closed:
		return
	_closed = true
	_invalidate()
	if _conversation != null:
		_conversation.attempt_started.disconnect(_on_attempt)
		_conversation.generation_completed.disconnect(_on_accepted)
		_runtime.restore_completed.disconnect(_on_restore)
	_runtime = null
	_conversation = null

func _exit_tree() -> void:
	shutdown()
