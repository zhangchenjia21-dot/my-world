extends SceneTree

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Fixture := preload("res://tests/g4_04/游戏库测试夹具.gd")

var _failures := 0
var _fixture := Fixture.new()


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var root_path := _argument("--root=")
	if root_path.find("g4_04") < 0:
		_fail("必须提供 task-owned --root，且路径包含 g4_04")
		_finish()
		return
	_fixture.reset_directory(root_path)
	var library_root := root_path.path_join("library")
	var games_root := root_path.path_join("games")
	var legacy_path := root_path.path_join("legacy/current-game.sqlite")
	_set_roots(library_root, games_root, legacy_path)
	var path_a := games_root.path_join("game-a/game.sqlite")
	var path_b := games_root.path_join("game-b/game.sqlite")
	_check(_fixture.seed_game(path_a, "game-a", {"world": "A", "clock": 1}, "A行动", "A回应").success, "Game A fixture ready")
	_check(_fixture.seed_game(path_b, "game-b", {"world": "B", "clock": 9}, "B行动", "B回应").success, "Game B fixture ready")

	# 持有 A writer 时启动 Application；Main Menu boot 不应触碰 Game DB。
	var boot_lock_probe := Runtime.new()
	_check(boot_lock_probe.open_existing_game(path_a).success, "boot isolation probe owns A writer")
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await process_frame
	await process_frame
	_check(shell.application_state == shell.ApplicationState.MENU_READY and shell.session_runtime == null, "Launch → Main Menu，不自动 open current/任何 Game")
	_check(boot_lock_probe.is_ready(), "Main Menu boot 未争抢 A writer")
	shell.continue_button.pressed.emit()
	await process_frame
	_check(shell.session_runtime == null and not FileAccess.file_exists(legacy_path), "无 current/legacy 时 Continue 不创建 replacement Game")
	boot_lock_probe.close()

	_check(shell.register_existing_managed_game("game-a", "游戏 A").success, "Application seam 验证并登记 A")
	_check(shell.register_existing_managed_game("game-b", "游戏 B").success, "Application seam 验证并登记 B")
	var opened_a: Dictionary = shell.open_registered_game("game-a")
	_check(opened_a.success and String(shell.session_runtime.game_id) == "game-a", "select/open A enters one writable Session")
	_check(String(shell.session_runtime.world_state.get("world", "")) == "A" and int(shell.session_runtime.world_state.get("clock", -1)) == 1, "A 恢复自己的 World truth")
	_check(String(shell.session_runtime.conversation.get_durable_accepted_entries()[0].gm_text) == "A回应", "A 恢复自己的 Conversation truth")

	var same_game_probe := Runtime.new()
	var blocked: Dictionary = same_game_probe.open_existing_game(path_a)
	_check(not blocked.success and String(blocked.status) == "already_running", "同一 Game writer 已占用时 fail-loud")
	same_game_probe.close()
	var other_game_probe := Runtime.new()
	_check(other_game_probe.open_existing_game(path_b).success, "A active 时 B 物理 writer/SQLite 仍独立")
	other_game_probe.close()

	var switched_b: Dictionary = shell.open_registered_game("game-b")
	_check(switched_b.success and String(shell.session_runtime.game_id) == "game-b", "A close/release 后才打开 B")
	_check(String(shell.session_runtime.world_state.get("world", "")) == "B" and int(shell.session_runtime.world_state.get("clock", -1)) == 9, "B truth 未被 A 覆盖")
	_check(String(shell.game_library.get_current_selection().record.game_id) == "game-b", "B successful open 后显式 current=B")
	shell.return_menu_button.pressed.emit()
	await process_frame
	_check(shell.session_runtime == null and shell.session_state == shell.SessionState.ABSENT, "B Return 完整关闭 Session")
	var reopened_a: Dictionary = shell.open_registered_game("game-a")
	_check(reopened_a.success and String(shell.session_runtime.world_state.get("world", "")) == "A" and int(shell.session_runtime.world_state.get("clock", -1)) == 1, "切回 A 恢复原 durable truth")

	# missing record DB：先合法登记后删除 task fixture；Select 不得调用 historical create seam。
	var missing_path := games_root.path_join("game-missing/game.sqlite")
	_check(_fixture.seed_game(missing_path, "game-missing", {"world": "missing"}, "行动", "回应").success, "missing fixture seed")
	_check(shell.register_existing_managed_game("game-missing", "缺失局").success, "missing fixture 先合法登记")
	DirAccess.remove_absolute(missing_path)
	var missing_open: Dictionary = shell.open_registered_game("game-missing")
	_check(not missing_open.success and String(missing_open.status) == "game_database_missing", "selected DB missing fail-loud")
	_check(not FileAccess.file_exists(missing_path), "missing Select 未创建替代 SQLite")
	_check(String(shell.game_library.get_current_selection().record.game_id) == "game-a", "missing failure 不切换旧 current A")

	# 合法登记后替换为另一 internal identity，证明 open 时不是只信 record/path。
	var mismatch_path := games_root.path_join("game-mismatch/game.sqlite")
	var other_path := root_path.path_join("other/game.sqlite")
	_check(_fixture.seed_game(mismatch_path, "game-mismatch", {"world": "original"}, "行动", "回应").success, "mismatch original fixture seed")
	_check(shell.register_existing_managed_game("game-mismatch", "错配局").success, "mismatch record 初始合法登记")
	_check(_fixture.seed_game(other_path, "game-other", {"world": "other"}, "行动", "回应").success, "mismatch replacement fixture seed")
	_fixture.overwrite_file(other_path, mismatch_path)
	var mismatch_open: Dictionary = shell.open_registered_game("game-mismatch")
	_check(not mismatch_open.success and String(mismatch_open.status) == "game_identity_mismatch", "record/DB internal game_id mismatch fail-loud")
	_check(shell.session_runtime == null, "identity mismatch 立即 close Runtime/release writer")
	_check(String(shell.game_library.get_current_selection().record.game_id) == "game-a", "identity mismatch 不切 current")

	shell.queue_free()
	await process_frame
	_clear_roots()
	_finish()


func _set_roots(library_root: String, games_root: String, legacy_path: String) -> void:
	OS.set_environment("MY_WORLD_TEST_GAME_LIBRARY_ROOT", library_root)
	OS.set_environment("MY_WORLD_TEST_GAMES_ROOT", games_root)
	OS.set_environment("MY_WORLD_TEST_CURRENT_GAME_DB", legacy_path)


func _clear_roots() -> void:
	OS.set_environment("MY_WORLD_TEST_GAME_LIBRARY_ROOT", "")
	OS.set_environment("MY_WORLD_TEST_GAMES_ROOT", "")
	OS.set_environment("MY_WORLD_TEST_CURRENT_GAME_DB", "")


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-04 LIFECYCLE PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-04 LIFECYCLE FAIL | %s" % label)


func _finish() -> void:
	print("G4-04 LIFECYCLE | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
