extends SceneTree

const Persistence := preload("res://src/persistence/L3_外交层/世界持久化公开接口.gd")


func _initialize() -> void:
	var database_path := _argument_value("--db=")
	var marker_path := _argument_value("--marker=")
	if database_path.is_empty() or marker_path.is_empty():
		_fail("missing db/marker argument")
		return
	var api := Persistence.new()
	var opened: Dictionary = api.open_database(database_path)
	if opened.status != "ready":
		_fail("open failed: %s" % opened)
		return
	var created: Dictionary = api.create_initial_game("lost-ack-game", "lost-head-0", {"effect_count": 0}, "2026-08-27T00:00:00Z")
	if created.status not in ["committed", "already_exists"]:
		_fail("seed failed: %s" % created)
		return
	var committed: Dictionary = api.commit_world_mutation("lost-ack-game", "stable-mutation-1", "lost-head-0", "lost-head-1", {"effect_count": 1}, "2026-08-27T00:00:01Z")
	if committed.status != "committed":
		_fail("commit failed: %s" % committed)
		return
	# marker 只在 production API 已返回 committed 后出现；harness 随后在任何外部 ACK 前终止此 PID。
	var marker := FileAccess.open(marker_path, FileAccess.WRITE)
	if marker == null:
		_fail("cannot create post-COMMIT marker")
		return
	marker.store_string("POST_COMMIT_NO_ACK\n")
	marker.close()
	while true:
		OS.delay_msec(100)


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix): return argument.trim_prefix(prefix)
	return ""


func _fail(message: String) -> void:
	push_error("G3-02 LOST-ACK HELPER FAIL | %s" % message)
	quit(1)
