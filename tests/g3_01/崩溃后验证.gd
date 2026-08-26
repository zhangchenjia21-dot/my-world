extends SceneTree

const Fixture := preload("res://tests/g3_01/持久化夹具.gd")


func _initialize() -> void:
	var database_path := _argument_value("--db=")
	var database := Fixture.open_database(database_path)
	if database == null:
		_fail("crash database reopen")
		return
	var state: Variant = Fixture.scalar(database, "SELECT value FROM g3_fixture_state WHERE game_id = ? AND key = 'fixture_status';", [Fixture.GAME_ID], "value")
	var head: Variant = Fixture.scalar(database, "SELECT active_head_id FROM g3_fixture_games WHERE game_id = ?;", [Fixture.GAME_ID], "active_head_id")
	var crash_nodes: Variant = Fixture.scalar(database, "SELECT COUNT(*) AS count FROM g3_fixture_timeline_nodes WHERE node_id = 'g3-head-crash';", [], "count")
	database.close_db()
	if state != "stable-1" or head != Fixture.INITIAL_HEAD_ID or int(crash_nodes) != 0:
		_fail("pre-COMMIT termination left partial durable state")
		return
	print("G3-01 PASS | exact-PID pre-COMMIT termination preserves last committed state")
	quit(0)


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


func _fail(message: String) -> void:
	push_error("G3-01 FAIL | %s" % message)
	quit(1)
