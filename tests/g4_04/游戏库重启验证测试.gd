extends SceneTree

const Library := preload("res://src/游戏库/L3_外交层/游戏库公开接口.gd")

var _failures := 0


func _initialize() -> void:
	var root_path := _argument("--root=")
	if root_path.find("g4_04") < 0:
		_fail("必须提供 metadata test 已创建的 task-owned --root")
		_finish()
		return
	var library := Library.new(root_path.path_join("library"), root_path.path_join("games"), root_path.path_join("legacy/current-game.sqlite"))
	var inventory := library.list_games()
	var current := library.get_current_selection()
	_check(inventory.success and inventory.games.size() == 2, "新 Godot process 恢复相同 record set")
	_check(current.success and String(current.record.game_id) == "game-b", "新 Godot process 恢复 current B")
	_check(String(inventory.games[0].game_id) == "game-a" and String(inventory.games[1].game_id) == "game-b", "metadata inventory deterministic，不按 DB mtime 猜测")
	_finish()


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-04 RESTART PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-04 RESTART FAIL | %s" % label)


func _finish() -> void:
	print("G4-04 RESTART | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
