extends SceneTree

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")

var _runtime: RefCounted = null


func _initialize() -> void:
	var path := _argument("--db=")
	var mode := _argument("--mode=")
	if path.is_empty() or path.find("g3_06") < 0:
		_fail("task-owned --db containing g3_06 is required")
		return
	_runtime = Runtime.new()
	var opened: Dictionary = _runtime.open_current_game(path)
	match mode:
		"hold":
			if not opened.success:
				_fail("owner A failed: %s" % opened)
				return
			var ready := _argument("--ready=")
			var marker := FileAccess.open(ready, FileAccess.WRITE)
			if marker == null:
				_fail("cannot write ready marker")
				return
			marker.store_string("pid=%d\ngame_id=%s\n" % [OS.get_process_id(), _runtime.game_id])
			marker.close()
			print("G3-06 SINGLE WRITER A READY | pid=%d" % OS.get_process_id())
			# 返回 SceneTree event loop，所有权 transaction 持有到 exact-PID termination。
		"probe_blocked":
			if opened.success or String(opened.status) != "already_running":
				_fail("second process was not rejected before gameplay open: %s" % opened)
				return
			print("G3-06 SINGLE WRITER B PASS | already_running before gameplay DB touch")
			quit(0)
		"probe_reopen":
			if not opened.success:
				_fail("post-crash process C could not acquire/reopen: %s" % opened)
				return
			_runtime.close()
			print("G3-06 SINGLE WRITER C PASS | crash-released lock and exact Game reopened")
			quit(0)
		_:
			_fail("unknown --mode")


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix): return value.trim_prefix(prefix)
	return ""


func _fail(message: String) -> void:
	push_error("G3-06 SINGLE WRITER FAIL | %s" % message)
	if _runtime != null: _runtime.close()
	quit(1)
