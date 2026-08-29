extends SceneTree

## G4-01 Application / Game Session focused test。
## 全部 SQLite 使用 --db 指定的 task-owned 路径；Main Menu 本身不打开真实 user:// Game。

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const StubAdapter := preload("res://tests/g2_03_桩适配器.gd")

var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var database_path := _argument("--db=")
	if database_path.find("g4_01") < 0:
		_fail("task-owned --db path containing g4_01 is required")
		_finish()
		return
	_remove_fixture(database_path)
	var library_root := database_path.get_base_dir().path_join("g4_01-game-library")
	var games_root := database_path.get_base_dir().path_join("g4_01-games")
	var source_root := database_path.get_base_dir().path_join("g4_01-source-library")
	_remove_tree(library_root)
	_remove_tree(games_root)
	_remove_tree(source_root)
	OS.set_environment("MY_WORLD_TEST_CURRENT_GAME_DB", database_path)
	OS.set_environment("MY_WORLD_TEST_GAME_LIBRARY_ROOT", library_root)
	OS.set_environment("MY_WORLD_TEST_GAMES_ROOT", games_root)
	OS.set_environment("MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", source_root)

	# A/B：Application launch 只到 Main Menu；missing DB 不创建，View 不建立 Provider state。
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await process_frame
	await process_frame
	_check(shell.application_state == shell.ApplicationState.MENU_READY, "boot -> MENU_READY")
	_check(shell.session_state == shell.SessionState.ABSENT and shell.session_runtime == null, "boot keeps Session ABSENT")
	_check(shell.main_menu_surface.visible and not shell.game_surface.visible, "Main Menu is first product surface")
	_check(not FileAccess.file_exists(database_path), "boot does not create missing current Game DB")
	_check(shell.narrative_view.conversation == null and shell.narrative_view.adapter == null, "Main Menu creates no Game Conversation/Provider")

	# D：New Game Wizard 是 Application-owned Composition surface；空 Source inventory 仍不产生 Game mutation。
	shell.new_game_button.pressed.emit()
	await process_frame
	_check(shell.new_game_surface.visible and not shell.main_menu_surface.visible, "New Game opens honest stable surface")
	_check(not FileAccess.file_exists(database_path) and shell.session_runtime == null, "New Game surface does not create Game/DB")
	shell.new_game_back_button.pressed.emit()
	await process_frame
	_check(shell.main_menu_surface.visible and shell.session_state == shell.SessionState.ABSENT, "New Game Back returns to clean Main Menu")

	# G4-04 后 Continue 只能打开 existing Game；测试 fixture 仍可用历史 seam 创建 task-owned legacy DB。
	var seed := Runtime.new()
	var seeded: Dictionary = seed.open_current_game(database_path)
	_check(seeded.success, "test fixture creates an existing legacy Game before Continue")
	var seeded_game_id := String(seed.game_id)
	seed.close()

	# C：显式 Continue 验证 existing legacy identity，原位登记后进入 Session；绝不由 Continue mint。
	shell.continue_button.pressed.emit()
	await process_frame
	await process_frame
	_check(shell.application_state == shell.ApplicationState.GAME_ACTIVE and shell.session_state == shell.SessionState.READY, "Continue opens Game Session")
	_check(FileAccess.file_exists(database_path) and String(shell.session_runtime.game_id) == seeded_game_id, "Continue adopts exact existing legacy Game without replacement")
	_check(shell.game_surface.visible and not shell.main_menu_surface.visible, "Continue enters existing Game Surface")
	_check(shell.narrative_view.session_runtime == shell.session_runtime and shell.narrative_view.adapter != null, "Game View binds this Session only after Continue")

	var first_game_id := String(shell.session_runtime.game_id)
	var first_head_id := String(shell.session_runtime.active_head_id)
	_accept(shell.session_runtime, "生命周期行动", "生命周期回应")
	var accepted_before: Array = shell.session_runtime.conversation.get_durable_accepted_entries()

	# H/F：真实 adapter double 进入 busy；Return 必须 cancel transport、放弃 partial、释放 Runtime/lock。
	var view: Variant = shell.narrative_view
	view._disconnect_adapter_signals(view.adapter)
	view.adapter.queue_free()
	var stub := StubAdapter.new()
	view.adapter = stub
	view.add_child(stub)
	var stub_cancelled := [false]
	stub.text_delta.connect(view._on_text_delta)
	stub.completed.connect(view._on_completed)
	stub.cancelled.connect(func() -> void: stub_cancelled[0] = true)
	stub.cancelled.connect(view._on_cancelled)
	stub.failed.connect(view._on_failed)
	var input: TextEdit = shell.get_node("%PlayerInput")
	input.text = "这条生成会在返回菜单时取消。"
	input.text_changed.emit()
	shell.get_node("%SendButton").pressed.emit()
	stub.text_delta.emit("未完成草稿")
	_check(stub.is_busy() and shell.session_runtime.conversation.is_generating(), "fixture generation is active before Return")
	var closing_runtime: Variant = shell.session_runtime
	shell.return_menu_button.pressed.emit()
	await process_frame
	await process_frame
	_check(bool(stub_cancelled[0]), "Return cancels Provider transport")
	_check(not closing_runtime.conversation.is_generating(), "Return abandons active Conversation attempt")
	_check(closing_runtime.conversation.get_durable_accepted_entries() == accepted_before, "cancelled partial is not durable")
	_check(shell.application_state == shell.ApplicationState.MENU_READY and shell.session_state == shell.SessionState.ABSENT, "Return keeps Application READY and Session absent")
	_check(shell.session_runtime == null and closing_runtime.persistence == null, "Return releases Runtime persistence and Shell reference")

	# 真实第二 Runtime 能立刻取得 writer，证明 Return 不是 visibility-only close。
	var lock_probe := Runtime.new()
	var probe_open: Dictionary = lock_probe.open_current_game(database_path)
	_check(probe_open.success, "Return releases writer lock for an independent Runtime")
	if probe_open.success:
		_check(String(lock_probe.game_id) == first_game_id, "lock probe opens the same Game identity")
	lock_probe.close()

	# G/I：Continue again 从 durable truth rehydrate，不复用菜单缓存。
	shell.continue_button.pressed.emit()
	await process_frame
	await process_frame
	_check(shell.session_state == shell.SessionState.READY, "Continue again reopens Session")
	_check(String(shell.session_runtime.game_id) == first_game_id and String(shell.session_runtime.active_head_id) == first_head_id, "Continue again restores same Game/head")
	_check(shell.session_runtime.conversation.get_durable_accepted_entries() == accepted_before, "Continue again restores exact accepted Conversation")

	# 结束本 fixture Session；再次回到菜单后另一个 Runtime仍可获得 lock。
	shell.return_menu_button.pressed.emit()
	await process_frame
	_check(shell.session_runtime == null, "second Return closes reopened Session")
	shell.queue_free()
	await process_frame
	OS.set_environment("MY_WORLD_TEST_CURRENT_GAME_DB", "")
	OS.set_environment("MY_WORLD_TEST_GAME_LIBRARY_ROOT", "")
	OS.set_environment("MY_WORLD_TEST_GAMES_ROOT", "")
	OS.set_environment("MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", "")
	_finish()


func _accept(runtime: RefCounted, player: String, gm: String) -> void:
	_check(runtime.conversation.begin_turn(player) != null, "fixture begin accepted Turn")
	runtime.conversation.append_delta(gm)
	_check(runtime.complete_active_generation_durably().success, "fixture accepted Turn commits durably")


func _remove_fixture(path: String) -> void:
	for suffix: String in ["", "-wal", "-shm"]:
		var target := "%s%s" % [path, suffix]
		if FileAccess.file_exists(target):
			DirAccess.remove_absolute(target)
	var lock_path := "%s.writer.sqlite" % path.trim_suffix(".sqlite")
	for suffix: String in ["", "-wal", "-shm"]:
		var target := "%s%s" % [lock_path, suffix]
		if FileAccess.file_exists(target):
			DirAccess.remove_absolute(target)
	var recovery_dir := "%s.recovery" % path.trim_suffix(".sqlite")
	if DirAccess.dir_exists_absolute(recovery_dir):
		for file_name: String in DirAccess.get_files_at(recovery_dir):
			DirAccess.remove_absolute("%s/%s" % [recovery_dir, file_name])
		DirAccess.remove_absolute(recovery_dir)


func _remove_tree(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		return
	for file_name: String in DirAccess.get_files_at(path):
		DirAccess.remove_absolute(path.path_join(file_name))
	for directory_name: String in DirAccess.get_directories_at(path):
		_remove_tree(path.path_join(directory_name))
	DirAccess.remove_absolute(path)


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix)
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-01 LIFECYCLE PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-01 LIFECYCLE FAIL | %s" % label)


func _finish() -> void:
	print("G4-01 LIFECYCLE | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
