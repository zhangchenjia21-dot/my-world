extends SceneTree

const Fixture := preload("res://tests/g4_04/游戏库测试夹具.gd")

var _fixture := Fixture.new()


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var root_path := _argument("--root=")
	if root_path.find("g4_04") < 0:
		push_error("G4-04 WINDOW CLOSE FAIL | task-owned root required")
		quit(1)
		return
	_fixture.reset_directory(root_path)
	var library_root := root_path.path_join("library")
	var games_root := root_path.path_join("games")
	var legacy_path := root_path.path_join("legacy/current-game.sqlite")
	var database_path := games_root.path_join("window-game/game.sqlite")
	if not _fixture.seed_game(database_path, "window-game", {"window": true}, "行动", "回应").success:
		push_error("G4-04 WINDOW CLOSE FAIL | fixture seed")
		quit(1)
		return
	OS.set_environment("MY_WORLD_TEST_GAME_LIBRARY_ROOT", library_root)
	OS.set_environment("MY_WORLD_TEST_GAMES_ROOT", games_root)
	OS.set_environment("MY_WORLD_TEST_CURRENT_GAME_DB", legacy_path)
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await process_frame
	if not shell.register_existing_managed_game("window-game", "窗口关闭局").success or not shell.open_registered_game("window-game").success:
		push_error("G4-04 WINDOW CLOSE FAIL | open active Game")
		quit(1)
		return
	var marker := FileAccess.open(root_path.path_join("active-before-close.txt"), FileAccess.WRITE)
	marker.store_string("game_id=%s\n" % String(shell.session_runtime.game_id))
	marker.close()
	print("G4-04 WINDOW CLOSE READY | active Game writer acquired")
	# 直接触发 Godot Windows close notification，必须走 production _request_exit/_close_game_session。
	shell._notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""
