extends SceneTree

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
	await _test_healthy_legacy_adoption(root_path.path_join("healthy-legacy"))
	await _test_legacy_corruption_recovery(root_path.path_join("corrupt-legacy"))
	await _test_managed_recovery_isolation(root_path.path_join("managed-isolation"))
	_clear_roots()
	_finish()


func _test_healthy_legacy_adoption(case_root: String) -> void:
	var library_root := case_root.path_join("library")
	var games_root := case_root.path_join("games")
	var legacy_path := case_root.path_join("current-game.sqlite")
	var seeded := _fixture.seed_game(legacy_path, "legacy-game", {"legacy": true, "clock": 7}, "旧行动", "旧回应", true)
	_check(seeded.success and seeded.save_count == 1, "healthy legacy 保留 Conversation + Save fixture")
	_set_roots(library_root, games_root, legacy_path)
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await process_frame
	await process_frame
	_check(shell.session_runtime == null and shell.game_library.list_games().games.is_empty(), "legacy 存在时 Application boot 仍只显示 Main Menu且不预登记")
	shell.continue_button.pressed.emit()
	await process_frame
	await process_frame
	_check(shell.session_runtime != null and String(shell.session_runtime.game_id) == "legacy-game", "显式 Continue 才打开并采用 legacy")
	_check(bool(shell.session_runtime.world_state.get("legacy", false)) and int(shell.session_runtime.world_state.get("clock", -1)) == 7, "legacy World/head truth 原样恢复")
	_check(String(shell.session_runtime.conversation.get_durable_accepted_entries()[0].gm_text) == "旧回应", "legacy Conversation truth 原样恢复")
	_check(shell.session_runtime.list_save_points().save_points.size() == 1, "legacy Save truth 原样恢复")
	var current: Dictionary = shell.game_library.get_current_selection()
	_check(current.success and String(current.record.storage_kind) == "legacy_g3" and String(current.record.database_path) == legacy_path, "legacy record 原位指向 current-game.sqlite")
	_check(not FileAccess.file_exists(games_root.path_join("legacy-game/game.sqlite")), "adoption 未移动/复制为 managed Game")
	shell.return_menu_button.pressed.emit()
	await process_frame
	shell.queue_free()
	await process_frame

	var restarted: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(restarted)
	await process_frame
	_check(restarted.session_runtime == null, "restart Main Menu 不因 current metadata 自动打开 legacy DB")
	restarted.continue_button.pressed.emit()
	await process_frame
	await process_frame
	_check(restarted.session_runtime != null and String(restarted.session_runtime.game_id) == "legacy-game", "restart Continue 解析同一原位 legacy record")
	restarted.return_menu_button.pressed.emit()
	await process_frame
	restarted.queue_free()
	await process_frame


func _test_legacy_corruption_recovery(case_root: String) -> void:
	var library_root := case_root.path_join("library")
	var games_root := case_root.path_join("games")
	var legacy_path := case_root.path_join("current-game.sqlite")
	_check(_fixture.seed_game(legacy_path, "legacy-recovery", {"legacy": "recover"}, "行动", "回应", true).success, "legacy recovery fixture with verified backup")
	_fixture.corrupt(legacy_path)
	_set_roots(library_root, games_root, legacy_path)
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await process_frame
	shell.continue_button.pressed.emit()
	await process_frame
	await process_frame
	_check(shell.session_runtime != null and String(shell.session_runtime.startup_result.status) == "physical_corruption", "legacy corruption 继续走 G3 physical classification")
	_check(shell.game_library.list_games().games.is_empty(), "corrupt legacy 在 recovery 前不伪造 Game record")
	var recovered: Dictionary = shell.session_runtime.recover_damaged_database()
	_check(String(recovered.status) == "reopen_required", "legacy verified backup staged recovery 成功")
	shell.session_runtime.close()
	shell.session_runtime = null
	shell.session_state = shell.SessionState.ABSENT
	shell._show_main_menu()
	shell.continue_button.pressed.emit()
	await process_frame
	await process_frame
	_check(shell.session_runtime != null and String(shell.session_runtime.game_id) == "legacy-recovery", "recovery 后 reopen 才完成 legacy adoption")
	_check(shell.game_library.list_games().games.size() == 1, "successful recovered open 后仅登记一条 legacy record")
	shell.return_menu_button.pressed.emit()
	await process_frame
	shell.queue_free()
	await process_frame


func _test_managed_recovery_isolation(case_root: String) -> void:
	var library_root := case_root.path_join("library")
	var games_root := case_root.path_join("games")
	var legacy_path := case_root.path_join("current-game.sqlite")
	var path_a := games_root.path_join("isolation-a/game.sqlite")
	var path_b := games_root.path_join("isolation-b/game.sqlite")
	_check(_fixture.seed_game(path_a, "isolation-a", {"owner": "A"}, "A行动", "A回应", true).success, "isolation A fixture + backup")
	_check(_fixture.seed_game(path_b, "isolation-b", {"owner": "B"}, "B行动", "B回应", true).success, "isolation B fixture + backup")
	_set_roots(library_root, games_root, legacy_path)
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await process_frame
	_check(shell.register_existing_managed_game("isolation-a", "隔离 A").success, "register isolation A")
	_check(shell.register_existing_managed_game("isolation-b", "隔离 B").success, "register isolation B")
	_check(shell.open_registered_game("isolation-a").success, "healthy A opens before B corruption")
	shell.return_menu_button.pressed.emit()
	await process_frame
	var a_hash_before: String = _fixture.file_hash(path_a)
	_fixture.corrupt(path_b)
	var damaged_b: Dictionary = shell.open_registered_game("isolation-b")
	_check(not damaged_b.success and String(damaged_b.status) == "physical_corruption", "corrupt B classified without opening/replacing A")
	var recovered_b: Dictionary = shell.session_runtime.recover_damaged_database()
	_check(String(recovered_b.status) == "reopen_required", "B uses its own verified recovery root")
	shell.session_runtime.close()
	shell.session_runtime = null
	shell.session_state = shell.SessionState.ABSENT
	shell._show_main_menu()
	_check(_fixture.file_hash(path_a) == a_hash_before, "B corruption/recovery 未修改 A SQLite bytes")
	_check(shell.open_registered_game("isolation-a").success and String(shell.session_runtime.world_state.get("owner", "")) == "A", "B recovery 后 A 仍独立可打开")
	shell.return_menu_button.pressed.emit()
	await process_frame
	_check(shell.open_registered_game("isolation-b").success and String(shell.session_runtime.world_state.get("owner", "")) == "B", "recovered B exact truth 可重新打开")
	shell.return_menu_button.pressed.emit()
	await process_frame
	shell.queue_free()
	await process_frame


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
		print("G4-04 RECOVERY PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-04 RECOVERY FAIL | %s" % label)


func _finish() -> void:
	print("G4-04 RECOVERY | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
