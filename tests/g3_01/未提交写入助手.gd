extends SceneTree

const Fixture := preload("res://tests/g3_01/持久化夹具.gd")


func _initialize() -> void:
	var database_path := _argument_value("--db=")
	var ready_path := _argument_value("--ready=")
	if database_path.is_empty() or ready_path.is_empty():
		quit(2)
		return
	var database := Fixture.open_database(database_path)
	if database == null or not Fixture.execute(database, "BEGIN IMMEDIATE;"):
		quit(3)
		return
	var writes := [
		["UPDATE g3_fixture_state SET value = 'must-not-survive-crash' WHERE game_id = ? AND key = 'fixture_status';", [Fixture.GAME_ID]],
		["INSERT INTO g3_fixture_timeline_nodes(node_id, game_id, parent_node_id, sequence, kind, created_at) VALUES ('g3-head-crash', ?, ?, 2, 'mutation', '2026-08-26T00:00:02Z');", [Fixture.GAME_ID, Fixture.INITIAL_HEAD_ID]],
		["UPDATE g3_fixture_games SET active_head_id = 'g3-head-crash' WHERE game_id = ?;", [Fixture.GAME_ID]],
	]
	for write: Array in writes:
		if not Fixture.execute(database, write[0], write[1]):
			quit(4)
			return

	# Marker 只在 transaction 内三类写入都完成、COMMIT 尚未执行时出现；外部 harness
	# 取得这个 exact helper PID 后终止进程，避免依赖时序猜测或模糊进程匹配。
	var ready_file := FileAccess.open(ready_path, FileAccess.WRITE)
	if ready_file == null:
		quit(5)
		return
	ready_file.store_string("transaction-written-before-commit")
	ready_file.close()
	while true:
		OS.delay_msec(50)


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
