extends SceneTree

const SafetyFlow := preload("res://src/persistence/L2_流程层/数据库灾难恢复流程.gd")

var _ready_path := ""
var _target_point := ""


func _initialize() -> void:
	var path := _argument("--db=")
	_ready_path = _argument("--ready=")
	_target_point = _argument("--point=")
	var operation := _argument("--operation=")
	if path.find("g3_06") < 0 or _ready_path.is_empty():
		_fail("task-owned paths are required")
		return
	var flow := SafetyFlow.new()
	var owned: Dictionary = flow.acquire_writer(path)
	if not owned.success:
		_fail("cannot acquire writer: %s" % owned)
		return
	flow.set_test_crash_hook(_on_crash_point)
	var result: Dictionary = flow.refresh_backup() if operation == "backup" else flow.recover_current_from_backup()
	flow.release_writer()
	_fail("operation returned before target crash point: %s" % result)


func _on_crash_point(point: String) -> void:
	if point != _target_point:
		return
	var marker := FileAccess.open(_ready_path, FileAccess.WRITE)
	marker.store_string("pid=%d\npoint=%s\n" % [OS.get_process_id(), point])
	marker.close()
	print("G3-06 CRASH POINT READY | %s | pid=%d" % [point, OS.get_process_id()])
	while true:
		OS.delay_msec(50)


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix): return value.trim_prefix(prefix)
	return ""


func _fail(message: String) -> void:
	push_error("G3-06 CRASH HELPER FAIL | %s" % message)
	quit(1)
