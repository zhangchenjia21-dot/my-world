extends SceneTree

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Library := preload("res://src/游戏库/L3_外交层/游戏库公开接口.gd")


func _initialize() -> void:
	var root_path := _argument("--root=")
	if root_path.find("g4_04") < 0 or not FileAccess.file_exists(root_path.path_join("active-before-close.txt")):
		return _fail("close helper evidence missing")
	var library := Library.new(root_path.path_join("library"), root_path.path_join("games"), root_path.path_join("legacy/current-game.sqlite"))
	var current := library.get_current_selection()
	if not current.success or String(current.record.game_id) != "window-game":
		return _fail("current selection did not survive Windows close")
	var runtime := Runtime.new()
	var reopened: Dictionary = runtime.open_existing_game(String(current.record.database_path))
	if not reopened.success or String(runtime.game_id) != "window-game":
		return _fail("Windows close did not release writer/exact reopen failed")
	runtime.close()
	print("G4-04 WINDOW CLOSE PASS | current persisted and writer released for next process")
	quit(0)


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _fail(message: String) -> void:
	push_error("G4-04 WINDOW CLOSE FAIL | %s" % message)
	quit(1)
