extends SceneTree

const Persistence := preload("res://src/persistence/L3_外交层/世界持久化公开接口.gd")


func _initialize() -> void:
	var database_path := _argument_value("--db=")
	if database_path.is_empty():
		_fail("missing db argument")
		return
	var api := Persistence.new()
	var opened: Dictionary = api.open_database(database_path)
	if opened.status != "ready":
		_fail("reopen failed: %s" % opened)
		return
	var replay: Dictionary = api.commit_world_mutation("lost-ack-game", "stable-mutation-1", "lost-head-0", "lost-head-1", {"effect_count": 1}, "2026-08-27T00:00:59Z")
	var current: Dictionary = api.get_current_game("lost-ack-game")
	var count: Dictionary = api.timeline_node_count("lost-ack-game")
	var node: Dictionary = api.get_timeline_node("lost-ack-game", "lost-head-1")
	if replay.status != "replay_success" or replay.node_id != "lost-head-1":
		_fail("retry did not recover committed result: %s" % replay)
		return
	if current.status != "found" or current.head_id != "lost-head-1" or int(current.world_state.effect_count) != 1:
		_fail("current durable effect differs: %s" % current)
		return
	if count.status != "found" or count.node_count != 2 or node.status != "found" or int(node.world_state.effect_count) != 1:
		_fail("duplicate node/effect detected: count=%s node=%s" % [count, node])
		return
	api.close_database()
	print("G3-02 PASS | post-COMMIT lost-ACK retry recovered same node with one effect")
	quit(0)


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix): return argument.trim_prefix(prefix)
	return ""


func _fail(message: String) -> void:
	push_error("G3-02 LOST-ACK VERIFY FAIL | %s" % message)
	quit(1)
