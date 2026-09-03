extends Node

signal text_delta(text)
signal completed()
signal cancelled()
signal failed(code, message)

var requests: Array = []
var busy := false
var synchronous_failure := false


func start_stream(messages: Array) -> Error:
	requests.append(messages.duplicate(true))
	if synchronous_failure:
		failed.emit("missing_credential", "controlled synchronous failure")
		return ERR_UNCONFIGURED
	busy = true
	return OK


func is_busy() -> bool:
	return busy


func cancel() -> void:
	if not busy:
		return
	busy = false
	cancelled.emit()


func simulate_delta(text: String) -> void:
	if busy:
		text_delta.emit(text)


func simulate_completed() -> void:
	if not busy:
		return
	busy = false
	completed.emit()


func simulate_failed(code: String = "transport") -> void:
	if not busy:
		return
	busy = false
	failed.emit(code, "controlled provider failure")
