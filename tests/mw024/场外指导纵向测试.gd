extends "res://tests/mw019/行动推荐发送判定测试.gd"

var visual := false

func _run() -> void:
	_root = _argument("--root=")
	visual = "--visual" in OS.get_cmdline_user_args()
	if not _root.contains("mw024"): quit(2); return
	DirAccess.make_dir_recursive_absolute(_root)
	_source_root = _root.path_join("sources")
	var installed: Dictionary = _fixture.install_real_assets(_source_root)
	_check(installed.success, "isolated Source fixture")
	_library = installed.library
	_check(_library.install_expansion_pack("res://tests/fixtures/g4_08m1/判定与检定_公开d20").success, "real d20 capability")
	for with_d20: bool in [false, true]:
		var shell: Variant = await _boot_shell_with_game(_case_root("d20" if with_d20 else "free"), "场外指导验证", with_d20, true)
		if shell == null: quit(1); return
		var view: Variant = shell.narrative_view
		var runtime: Variant = shell.session_runtime
		var rec: Node = shell.test_action_recommender_adapter_override
		var curator: Node = shell.test_information_curator_adapter_override
		var world: Node = shell.test_world_turn_adapter_override
		var evolution: Node = shell.test_world_evolution_adapter_override
		var selector := RecommendationStub.new()
		shell.agency_scheduler.test_selector_adapter_override = selector
		curator.simulate_delta(JSON.stringify({"character": {"headline": "旅人", "summary": "水边的旅人", "groups": []}, "experiences": []}))
		curator.simulate_completed()
		rec.simulate_delta(JSON.stringify({"actions": ACTIONS}))
		rec.simulate_completed()
		await _settle(4)
		var narrative := _swap_view_stub(view)
		var before_world: Dictionary = runtime.world_state.duplicate(true)
		var before_head: String = runtime.active_head_id
		var counts := [world.requests.size(), curator.requests.size(), evolution.requests.size(), selector.requests.size()]
		_check(view.input_mode.selected == 0 and view.input_mode.get_theme_font_size("font_size") >= 20, "activation action mode and >=20px")
		view.input_mode.select(1)
		_check(runtime.world_state == before_world and narrative.start_calls.is_empty(), "toggle is read-only")
		view.player_input.text = "请放慢节奏，多给我与人物交谈的空间。"
		view._on_send_pressed()
		_check(narrative.start_calls.size() == 1 and runtime.conversation.latest_turn().pending_input_mode == "ooc", "OOC exactly one existing Narrative request")
		_check(JSON.stringify(narrative.start_calls).contains("当前对话：OOC / GM 指导"), "request explicitly marked OOC")
		if with_d20:
			_check(shell.test_adjudication_adapter_override.requests.is_empty() and shell.test_adjudication_rng_override.invocation_count == 0, "OOC zero adjudication/dice")
		narrative.text_delta.emit("好的，我会放慢当前段落的节奏，给你留出与人物交谈和作出选择的空间。")
		narrative.simulate_completed()
		await _settle(5)
		_check(runtime.conversation.get_durable_accepted_entries()[-1].input_mode == "ooc", "OOC durably accepted")
		_check(runtime.world_state == before_world and runtime.active_head_id == before_head, "OOC zero World/identity/Character/People durable change")
		_check([world.requests.size(), curator.requests.size(), evolution.requests.size(), selector.requests.size()] == counts, "OOC zero semantic/curator/evolution/agency calls")
		_check(rec.requests.size() == 2, "OOC one normal recommendation opportunity")
		_check(JSON.parse_string(rec.requests[-1][1].content).conversation[-1].input_mode == "ooc", "recommendation sees typed guidance")
		_check(_count_headers(view, "OOC / GM 指导") == 1 and _count_headers(view, "GM · OOC") == 1, "live OOC headers")
		for row: Dictionary in shell.debug_observer.snapshot():
			if row.turn == 1: _check(row.lane in ["narrative", "recommendations"], "OOC Debug only scheduled lanes")
		rec.simulate_delta(JSON.stringify({"actions": ACTIONS}))
		rec.simulate_completed()
		await _settle(3)
		view.recommendation_grid.get_child(0).pressed.emit()
		_check(view.input_mode.selected == 0 and view.player_input.text == ACTIONS[0].draft and narrative.start_calls.size() == 1 and not runtime.conversation.is_generating(), "recommendation ensures action/exact draft/no-send")
		var mixed: Array = runtime.conversation.get_durable_accepted_entries()
		var saved: Dictionary = runtime.create_save_point("OOC snapshot")
		_check(saved.success, "Save includes OOC")
		# Latest OOC regenerate is valid even when the Game supports d20.
		view._on_regenerate_pressed()
		_check(narrative.start_calls.size() == 2 and runtime.conversation.latest_turn().pending_input_mode == "ooc", "OOC regenerate preserves mode and lane")
		narrative.text_delta.emit("明白，我会留出更多对话空间。")
		narrative.simulate_completed()
		await _settle(4)
		var late_delta: Callable = shell.action_recommender._callbacks.text_delta
		var late_done: Callable = shell.action_recommender._callbacks.completed
		_check(runtime.restore_save_point(saved.save_id).success, "Restore displaces OOC regenerated future")
		late_delta.call(JSON.stringify({"actions": ACTIONS}))
		late_done.call()
		await _settle(4)
		_check(runtime.conversation.get_durable_accepted_entries() == mixed and shell.debug_observer.snapshot().all(func(row: Dictionary) -> bool: return row.turn == -1) and shell.debug_observer.snapshot().any(func(row: Dictionary) -> bool: return row.lane == "restore"), "Restore preserves exact modes and clears diagnostic epoch")
		_check(shell.action_recommender.snapshot().actions.is_empty(), "old recommendation callback cannot cross Restore")
		_check(_count_headers(view, "GM · OOC") == 1, "Restore re-renders OOC label")
		if visual:
			root.mode = Window.MODE_WINDOWED
			for dimensions: Vector2i in [Vector2i(960,540), Vector2i(1280,720), Vector2i(1920,1080)]:
				root.size = dimensions
				await _settle(5)
				view.input_mode.select(1)
				_check(view.input_mode.get_global_rect().end.x <= dimensions.x and view.input_mode.get_global_rect().end.y <= dimensions.y and view.player_input.get_global_rect().end.y <= dimensions.y and view.narrative_scroll.size.y >= 80, "mode/composer/Narrative usable " + str(dimensions))
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(_root.path_join("%s-%dx%d.png" % ["d20" if with_d20 else "free", dimensions.x, dimensions.y]))
		# A subsequent ordinary action still routes to the original d20/free-form path.
		view.input_mode.select(0)
		view.player_input.text = "我向船工询问渡河的路线。"
		view._on_send_pressed()
		if with_d20:
			var adjudication: Node = shell.test_adjudication_adapter_override
			_check(adjudication.requests.size() == 1, "normal action still adjudicates")
			adjudication.simulate_delta(JSON.stringify(_proposal(15, 0, "normal")))
			adjudication.simulate_completed()
			await _settle(3)
			_check(JSON.stringify(adjudication.requests[-1]).contains("OOC / GM 指导"), "d20 continuation honors recent typed OOC")
			# Cancel after durable d20 CHECK: OOC cannot bypass pending action protection.
			view._on_cancel_pressed()
			await _settle(3)
			var requests: int = narrative.start_calls.size()
			view.input_mode.select(1)
			view.player_input.text = "请继续指导。"
			view._on_send_pressed()
			_check(narrative.start_calls.size() == requests and view.send_button.disabled, "unresolved durable action blocks OOC")
			view._on_retry_action_pressed()
			await _settle(3)
			adjudication.simulate_delta("船工向你说明了路线。")
			adjudication.simulate_completed()
		else:
			_check(narrative.start_calls.size() == 3 and JSON.stringify(narrative.start_calls[-1]).contains("OOC / GM 指导"), "normal continuation carries recent OOC")
			narrative.text_delta.emit("船工向你说明了路线。")
			narrative.simulate_completed()
		await _settle(4)
		_check(world.requests.size() == counts[0] + 1, "normal action still schedules World")
		world.simulate_delta(JSON.stringify({"changes": []}))
		world.simulate_completed()
		await _settle(4)
		_check(curator.requests.size() == counts[1] + 1, "normal action still schedules lived Curator")
		curator.simulate_delta(JSON.stringify({"character": null, "experiences": [], "people_updates": []}))
		curator.simulate_completed()
		await _settle(3)
		if not with_d20: await _mode_replacement_callbacks(shell)
		var database: String = runtime.database_path
		var expected: Array = runtime.conversation.get_durable_accepted_entries()
		await _shutdown_shell(shell)
		# Actual Continue through Game library reopens mixed history and defaults composer to action.
		shell = await _boot_shell(_case_root("d20" if with_d20 else "free"))
		shell.continue_button.pressed.emit()
		await _settle(6)
		_check(shell.session_runtime != null and shell.session_runtime.database_path == database, "Continue actual same Game")
		_check(shell.session_runtime.conversation.get_durable_accepted_entries() == expected and shell.narrative_view.input_mode.selected == 0, "reopen mixed mode bytes/default action")
		_check(_count_headers(shell.narrative_view, "GM · OOC") == (1 if with_d20 else 3), "reopen OOC label")
		await _shutdown_shell(shell)
		if is_instance_valid(selector) and selector.get_parent() == null: selector.free()
	_clear_environment()
	print("MW-024 VERTICAL failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)

# 同文 action -> OOC 原子替换：实际后台请求的旧 completion 不得跨 accepted version。
func _mode_replacement_callbacks(shell: Variant) -> void:
	var runtime: Variant = shell.session_runtime
	var world: Node = shell.test_world_turn_adapter_override
	var curator: Node = shell.test_information_curator_adapter_override
	for pending_lane: String in ["world", "curator"]:
		runtime.conversation.begin_turn("相同玩家文本")
		runtime.conversation.append_delta("相同 GM 文本")
		_check(runtime.complete_active_generation_durably().success, "seed action for mode replacement")
		await _settle(4)
		var world_delta: Callable = shell.world_turn_runtime._provider_callbacks.text_delta
		var world_done: Callable = shell.world_turn_runtime._provider_callbacks.completed
		if pending_lane == "curator":
			world.simulate_delta(JSON.stringify({"changes": []}))
			world.simulate_completed()
			await _settle(4)
		var old_rec_delta: Callable = shell.action_recommender._callbacks.text_delta
		var old_rec_done: Callable = shell.action_recommender._callbacks.completed
		var state: Dictionary = runtime.world_state.duplicate(true)
		var head: String = runtime.active_head_id
		runtime.conversation.correct_latest("相同玩家文本", "ooc")
		runtime.conversation.append_delta("相同 GM 文本")
		_check(runtime.complete_active_generation_durably().success, "same prose OOC replacement durable")
		await _settle(4)
		if pending_lane == "world":
			world_delta.call(JSON.stringify({"changes": []}))
			world_done.call()
			world.simulate_completed()
		else:
			curator.simulate_delta(JSON.stringify({"character": null, "experiences": [{"text": "STALE_MODE_CANARY"}], "people_updates": []}))
			curator.simulate_completed()
		old_rec_delta.call(JSON.stringify({"actions": ACTIONS}))
		old_rec_done.call()
		await _settle(4)
		_check(runtime.world_state == state and runtime.active_head_id == head, pending_lane + " stale callback cannot commit across mode replacement")
		_check(shell.action_recommender.snapshot().actions.is_empty(), "old recommendation callback cannot cross mode replacement")
		var current_turn: int = runtime.conversation.get_durable_accepted_entries().size() - 1
		_check(shell.debug_observer.snapshot().all(func(row: Dictionary) -> bool: return row.turn != current_turn or row.lane in ["narrative", "recommendations"]), "Debug discards old action lanes on OOC replacement")
