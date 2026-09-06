extends "res://tests/g4_08b/公开D20界面整合测试.gd"

const RecommendationStub := preload("res://tests/g5_01/世界回合语义桩适配器.gd")
const ACTIONS := ["我去河边观察船只。", "我向守卫问路。", "我回营整理见闻。", "我请同伴谈谈看法。", "我在亭中等候消息。"]

func _boot_shell(case_root: String) -> Variant:
	var shell: Variant = await super._boot_shell(case_root)
	shell.test_action_recommender_adapter_override = RecommendationStub.new()
	shell.test_world_turn_adapter_override = RecommendationStub.new()
	shell.test_information_curator_adapter_override = RecommendationStub.new()
	shell.test_world_evolution_adapter_override = RecommendationStub.new()
	return shell

func _run() -> void:
	_root = _argument("--root=")
	if not _root.contains("mw019"):
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(_root)
	_source_root = _root.path_join("source-library")
	var installed: Dictionary = _fixture.install_real_assets(_source_root)
	_check(installed.success, "task-owned real Source fixtures")
	_library = installed.library
	_check(_library.install_expansion_pack("res://tests/fixtures/g4_08m1/判定与检定_公开d20").success, "real d20 capability installed")
	for with_d20: bool in [false, true]:
		var shell: Variant = await _boot_shell_with_game(_case_root("d20" if with_d20 else "free"), "推荐行动验证", with_d20, true)
		if shell == null:
			quit(1)
			return
		var view: Variant = shell.narrative_view
		var rec: Node = shell.test_action_recommender_adapter_override
		_check(rec.requests.size() == 1, "Wizard opening triggers once")
		rec.simulate_delta(JSON.stringify({"actions": ACTIONS}))
		rec.simulate_completed()
		await _settle(3)
		var legacy := _swap_view_stub(view)
		view.recommendation_grid.get_child(0).pressed.emit()
		_check(legacy.start_calls.is_empty() and not shell.session_runtime.conversation.is_generating(), "click does not submit")
		if with_d20:
			_check(shell.test_adjudication_adapter_override.requests.is_empty() and shell.test_adjudication_rng_override.invocation_count == 0, "click never adjudicates/rolls")
		view.player_input.insert_text_at_caret(" 我先询问守卫是否方便通行。")
		var edited: String = view.player_input.text
		var ctrl := InputEventKey.new()
		ctrl.pressed = true
		ctrl.ctrl_pressed = true
		ctrl.keycode = KEY_ENTER
		view._on_player_input_gui(ctrl)
		_check(not view.recommendation_area.visible, "Ctrl+Enter clears recommendations immediately")
		if with_d20:
			var adjudication: Node = shell.test_adjudication_adapter_override
			_check(adjudication.requests.size() == 1 and legacy.start_calls.is_empty() and not shell.session_runtime.conversation.is_generating(), "d20 foreground starts before Conversation without bypass")
			_check(view._pending_action_text == edited, "d20 receives exact edited draft")
			adjudication.simulate_delta(JSON.stringify({"decision": "NO_CHECK", "reason": "观察与询问无须检定"}))
			adjudication.simulate_completed()
			await _settle(3)
			_check(adjudication.requests.size() == 2, "existing NO_CHECK requests authoritative narrative")
			adjudication.simulate_delta("守卫告诉你可以从栈桥边走过去。")
			adjudication.simulate_completed()
		else:
			_check(legacy.start_calls.size() == 1 and shell.session_runtime.conversation.is_generating(), "ordinary Send uses existing continuation")
			legacy.text_delta.emit("你走到河边，看见船只停在栈桥旁。")
			legacy.simulate_completed()
		await _settle(4)
		_check(shell.session_runtime.conversation.get_durable_accepted_entries()[-1].player_text == edited, "only explicit submission becomes accepted truth")
		_check(rec.requests.size() == 2 and rec.busy, "normal accepted turn triggers one fresh call")
		var stale_delta: Callable = shell.action_recommender._callbacks.text_delta
		var stale_done: Callable = shell.action_recommender._callbacks.completed
		view.player_input.text = "我完全自由地决定回营。"
		view._on_send_pressed()
		_check(not rec.busy, "manual send while recommendation loading cancels immediately")
		stale_delta.call(JSON.stringify({"actions": ACTIONS}))
		stale_done.call()
		_check(not view.recommendation_area.visible, "late response cannot reappear during foreground")
		view._on_cancel_pressed()
		await _settle(3)
		_check(rec.requests.size() == 2, "cancelled foreground no recommendation retry")
		await _shutdown_shell(shell)
	_clear_environment()
	print("MW-019 SEND/D20 failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
