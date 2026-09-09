extends "res://tests/mw022/会话调试观测纵向测试.gd"

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="): directory = arg.trim_prefix("--root=")
	if not directory.contains("mw022") or DisplayServer.get_name() == "headless":
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(directory)
	runtime = Runtime.new()
	check(runtime.open_current_game(directory.path_join("window.sqlite")).success, "window isolated SQLite")
	check(runtime.commit_world_mutation_durably("setup", "setup-node", setup()).success, "private fixture")
	runtime.conversation.begin_gm_opening()
	runtime.conversation.append_delta("亭外下着小雨。")
	check(runtime.complete_active_generation_durably().success, "accepted opening before activation")
	var shell: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	shell.session_runtime = runtime
	shell.test_presentation_preference_root = directory.path_join("presentation-preferences")
	shell.test_world_turn_adapter_override = Stub.new()
	shell.test_information_curator_adapter_override = Stub.new()
	shell.test_world_evolution_adapter_override = Stub.new()
	shell.test_action_recommender_adapter_override = Stub.new()
	root.add_child(shell)
	await frames()
	observer = shell.debug_observer
	semantic = shell.test_world_turn_adapter_override
	curation = shell.test_information_curator_adapter_override
	recommendation = shell.test_action_recommender_adapter_override
	# 最小 fixture 不含 Wizard opening facts，沿用既有 UI 测试的旧 Conversation seam。
	shell.narrative_view.bind_opening_runtime(null)
	worker = shell.world_turn_runtime
	curator = shell.information_curator
	recommender = shell.action_recommender
	check(not shell.debug_toggle.button_pressed and not shell.debug_panel.visible, "activation default OFF")
	complete(curation, {"character": Safe.project_session(runtime).character, "experiences": []})
	await frames()
	complete(recommendation, {"actions": ACTIONS})
	accept("我在亭中休息。", "亭外的雨渐渐停了。\n".repeat(30))
	await frames()
	complete(semantic, {"changes": []})
	await frames()
	complete(curation, answer([]))
	complete(recommendation, {"actions": ACTIONS})
	await frames()
	check(not shell.debug_panel.visible and row("world", 1).change == "no-change", "OFF collects real terminal without panel")
	var original := durable()
	var calls := request_counts(shell)
	root.mode = Window.MODE_WINDOWED
	for size: Vector2i in [Vector2i(1280, 720), Vector2i(960, 540)]:
		root.size = size
		shell.debug_toggle.button_pressed = false
		await frames()
		var normal_rect: Rect2 = shell.narrative_view.get_global_rect()
		var normal_scroll: Vector2 = shell.narrative_view.narrative_scroll.size
		shell.debug_toggle.button_pressed = true
		await frames()
		await create_timer(0.1).timeout
		check(shell.debug_panel.visible and shell.debug_panel.size.y <= 180, "compact visible bounded panel " + str(size))
		print("DEBUG LAYOUT %s panel=%s narrative=%s input=%s" % [size, shell.debug_panel.get_global_rect(), shell.narrative_view.narrative_scroll.get_global_rect(), shell.narrative_view.player_input.get_global_rect()])
		check(shell.debug_panel.get_global_rect().end.x <= root.size.x and shell.narrative_view.player_input.get_global_rect().end.y <= root.size.y and shell.narrative_view.send_button.get_global_rect().end.y <= root.size.y, "Debug and main Send/composer fit " + str(size))
		check(shell.narrative_view.narrative_scroll.size == normal_scroll and normal_scroll.y > 0, "Narrative remains useful " + str(size))
		check(shell.debug_panel._scroll.get_v_scroll_bar().max_value > shell.debug_panel._scroll.get_v_scroll_bar().page and shell.debug_panel._scroll.get_v_scroll_bar().visible, "debug overflow scrolls " + str(size))
		await capture("debug-on-%dx%d.png" % [size.x, size.y])
		shell.debug_toggle.button_pressed = false
		await frames()
		check(not shell.debug_panel.visible and shell.narrative_view.get_global_rect() == normal_rect, "OFF restores exact normal layout " + str(size))
		await capture("debug-off-%dx%d.png" % [size.x, size.y])
	check(durable() == original and request_counts(shell) == calls, "toggle/resize zero Provider calls and durable mutations")
	# 实际 Viewport 鼠标命中 TopBar toggle；窗口交互也不触发 Provider 或写入。
	for pressed: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = shell.debug_toggle.get_global_rect().get_center()
		root.push_input(event)
	await frames()
	check(shell.debug_toggle.button_pressed and shell.debug_panel.visible and durable() == original and request_counts(shell) == calls, "real mouse toggle has zero gameplay effects")
	var view: Node = shell.narrative_view
	view.recommendation_grid.get_child(0).pressed.emit()
	check(view.player_input.text == ACTIONS[0].draft and not runtime.conversation.is_generating() and durable() == original and request_counts(shell) == calls, "Debug ON recommendation click exact draft, no auto-send/call/write")
	var gm_stub: Node = preload("res://tests/g2_03_桩适配器.gd").new()
	view._disconnect_adapter_signals(view.adapter)
	view.adapter.queue_free()
	view.adapter = gm_stub
	view.add_child(gm_stub)
	gm_stub.text_delta.connect(view._on_text_delta)
	gm_stub.completed.connect(view._on_completed)
	gm_stub.cancelled.connect(view._on_cancelled)
	gm_stub.failed.connect(view._on_failed)
	view.player_input.text = "我自由选择下一步。"
	view._on_send_pressed()
	check(runtime.conversation.latest_turn().pending_player_text == "我自由选择下一步。" and runtime.conversation.is_generating(), "Debug ON free-form Send uses original route")
	gm_stub.text_delta.emit("你走出了亭子。")
	gm_stub.simulate_completed()
	await frames()
	semantic.simulate_failed()
	await frames()
	curation.simulate_failed("Authorization SECRET_KEY")
	recommendation.simulate_delta("not JSON SECRET_KEY")
	recommendation.simulate_completed()
	await frames()
	var text: String = visible_text(shell.debug_panel)
	check(text.contains("模型服务调用失败") and text.contains("模型响应结构无效") and text.contains("无变化"), "human-visible failure and no-change differ")
	privacy()
	check(not text.contains("SECRET_KEY") and not text.contains("Authorization") and not text.contains("SECRET_PROFILE"), "real UI hidden canaries absent")
	await capture("debug-failures-960x540.png")
	# Shell 的原有 Save/Restore action handlers 仍使用同一 Runtime，仅附加观测。
	shell.save_name_input.text = "MW-022 test"
	shell._on_create_save_pressed()
	check(row("save", -1).terminal == "saved", "Shell Save diagnostic")
	var saved: Dictionary = runtime.create_save_point("window return")
	accept("继续自由行动。", "你在河边停下。")
	await frames()
	shell._pending_load_save_id = saved.save_id
	shell._on_load_confirmed()
	check(observer.snapshot().size() == 1 and row("restore", -1).terminal == "restored", "Shell Restore invalidates displaced rows")
	await frames()
	shell.debug_toggle.button_pressed = false
	shell.debug_toggle.button_pressed = true
	await frames()
	check(row("restore", -1).terminal == "restored", "toggle does not clear epoch")
	# Close/reopen 同一 DB；每次 activation OFF，原 buffer 丢弃。
	var database: String = runtime.database_path
	shell._close_game_session()
	check(not shell.debug_panel.visible and not shell.debug_toggle.button_pressed and observer.snapshot().is_empty(), "close clears visible state and memory")
	shell.queue_free()
	await frames()
	runtime = Runtime.new()
	check(runtime.open_existing_game(database).success, "reopen same isolated Game")
	var next_shell: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	next_shell.session_runtime = runtime
	next_shell.test_presentation_preference_root = directory.path_join("presentation-preferences")
	next_shell.test_world_turn_adapter_override = Stub.new()
	next_shell.test_information_curator_adapter_override = Stub.new()
	next_shell.test_world_evolution_adapter_override = Stub.new()
	next_shell.test_action_recommender_adapter_override = Stub.new()
	root.add_child(next_shell)
	await frames()
	check(not next_shell.debug_toggle.button_pressed and not next_shell.debug_panel.visible and next_shell.debug_observer.snapshot().is_empty(), "reopen OFF without persisted trace")
	next_shell._close_game_session()
	next_shell.queue_free()
	await frames()
	print("MW-022 WINDOW checks=%d failures=%d" % [checks, failures])
	quit(0 if failures == 0 else 1)

func request_counts(shell: Node) -> Array:
	return [semantic.requests.size(), curation.requests.size(), recommendation.requests.size(), shell.test_world_evolution_adapter_override.requests.size()]

func capture(file: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory.path_join(file))
