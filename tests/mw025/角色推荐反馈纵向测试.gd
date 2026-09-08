extends "res://tests/mw019/行动推荐纵向测试.gd"

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="): directory = arg.trim_prefix("--root=")
		if arg == "--visual": visual = true
	if not directory.contains("mw025"): quit(2); return
	DirAccess.make_dir_recursive_absolute(directory)
	budget_checks()
	runtime = Runtime.new()
	check(runtime.open_current_game(directory.path_join("feedback.sqlite")).success, "isolated SQLite")
	var world := setup()
	world["source_current"] = "SOURCE_PRIVATE_CANARY"
	world["private_knowledge"] = "KNOWLEDGE_CANARY"
	world["credential"] = "CREDENTIAL_CANARY"
	check(runtime.commit_world_mutation_durably("setup", "setup-node", world).success, "private fixture")
	compose()
	await frames()
	var initial := {"headline": "谨慎的旅人", "summary": "习惯先倾听，但愿意尝试新事物。", "groups": []}
	complete(curation, {"character": initial, "experiences": []})
	await frames()
	attach()
	await frames()
	check(recommendation.requests.is_empty(), "no accepted conversation zero recommendation calls")
	accept("我决定主动与船工交谈。", "船工放下绳索，听你说话。")
	await frames()
	var payload: Dictionary = JSON.parse_string(recommendation.requests[-1][1].content)
	check(recommendation.requests.size() == 1 and semantic.busy and not curation.busy, "recommendation starts before same-turn Curator")
	check(payload.current_character == initial and payload.latest_accepted_role_action == "我决定主动与船工交谈。", "request-time Character plus just accepted action")
	var request_text := JSON.stringify(recommendation.requests[-1])
	for canary: String in ["SECRET_PROFILE", "PRIVATE_PLAN", "HIDDEN_EVOLUTION", "SOURCE_PRIVATE_CANARY", "KNOWLEDGE_CANARY", "CREDENTIAL_CANARY", "information_curation", "local_character_id", "sha256", "prefix", "npc-a"]:
		check(not request_text.contains(canary), "safe request excludes " + canary)
	complete(semantic, {"changes": []})
	await frames()
	check(input().accepted_player == payload.latest_accepted_role_action, "final accepted role action reaches lived Curator")
	check(curation.requests[-1][0].content.contains("一次反常或情境性行为不机械覆盖") and curation.requests[-1][0].content.contains("普通行动可保持 character=null"), "model-owned behavioral evidence instruction")
	var updated := {"headline": "愿意主动沟通的旅人", "summary": "仍重视倾听，也愿意主动表达和承担交谈。", "groups": []}
	complete(curation, {"character": updated, "experiences": [], "people_updates": []})
	await frames()
	check(Safe.project_session(runtime).character == updated and recommendation.requests.size() == 1, "later Character commit causes no second call")
	check(JSON.parse_string(recommendation.requests[0][1].content).current_character == initial, "in-flight snapshot stays frozen")
	complete(recommendation, {"actions": ACTIONS})
	check(recommender.snapshot().status == "ready", "Character update does not stale current recommendation")
	var save: Dictionary = runtime.create_save_point("updated Character")
	accept("我听他说完。", "船工说起了渡口的情况。")
	await frames()
	payload = JSON.parse_string(recommendation.requests[-1][1].content)
	check(payload.current_character == updated and payload.latest_accepted_role_action == "我听他说完。", "next opportunity uses updated Character")
	complete(semantic, {"changes": []})
	await frames()
	complete(curation, answer([]))
	await frames()
	check(Safe.project_session(runtime).character == updated, "ordinary accepted action permits Character null")
	var curator_count: int = curation.requests.size()
	for failure: String in ["cancel", "fail"]:
		runtime.conversation.begin_turn("UNACCEPTED_CANARY")
		if failure == "cancel": runtime.conversation.cancel_generation()
		else: runtime.conversation.fail_generation("controlled")
		await frames()
	check(curation.requests.size() == curator_count, "cancelled/failed attempts never become lived evidence")
	var before_ooc_calls: int = recommendation.requests.size()
	runtime.conversation.begin_turn("OOC_GUIDANCE_CANARY", "ooc")
	runtime.conversation.append_delta("好的，我会放慢节奏。")
	check(runtime.complete_active_generation_durably().success, "OOC accepted")
	await frames()
	payload = JSON.parse_string(recommendation.requests[-1][1].content)
	check(payload.current_character == updated and payload.latest_accepted_role_action == "我听他说完。" and payload.conversation[-1].input_mode == "ooc", "OOC uses prior role action, never OOC behavioral evidence")
	check(recommendation.requests.size() == before_ooc_calls + 1, "OOC exactly one ordinary recommendation opportunity")
	check(curation.requests.size() == curator_count and not JSON.stringify(payload).contains("UNACCEPTED_CANARY"), "OOC no lived call; failed drafts excluded")
	var late_delta: Callable = recommender._callbacks.text_delta
	var late_done: Callable = recommender._callbacks.completed
	check(runtime.restore_save_point(save.save_id).success, "Restore earlier Character/accepted history")
	await frames()
	late_delta.call(JSON.stringify({"actions": ACTIONS})); late_done.call()
	check(recommender.snapshot().actions.is_empty() and recommendation.busy, "pre-Restore callbacks cannot publish")
	payload = JSON.parse_string(recommendation.requests[-1][1].content)
	check(payload.current_character == updated and payload.latest_accepted_role_action == "我决定主动与船工交谈。", "Restore request follows restored accepted version")
	var db: String = runtime.database_path
	detach(); teardown(); runtime.close()
	await frames()
	runtime = Runtime.new()
	check(runtime.open_existing_game(db).success, "actual reopen")
	attach()
	await frames()
	check(recommendation.requests.size() == 1 and JSON.parse_string(recommendation.requests[0][1].content).current_character == updated, "reopen one fresh call with current Character")
	detach()
	await frames()
	attach()
	recommender._character_reader = func() -> Variant: return {"headline": "", "summary": "x".repeat(RecommendationContract.INPUT_BYTES), "groups": []}
	await frames()
	check(recommendation.requests.is_empty() and recommender.snapshot().status == "unavailable", "fixed safe material oversized means zero Provider requests")
	detach()
	await frames()
	await ui_evidence()
	print("MW025 FOCUSED checks=%d failures=%d" % [checks, failures])
	quit(0 if failures == 0 else 1)

func budget_checks() -> void:
	var character := {"headline": "旅人", "summary": "谨慎但愿意成长", "groups": []}
	var entries := [{"turn_index": 0, "player_text": "完整行动", "gm_text": "完整叙事", "input_mode": "action"}]
	var built := InputBuilder.build(entries, character)
	var payload: Dictionary = JSON.parse_string(built[1].content)
	check(payload.current_character == character and payload.latest_accepted_role_action == "完整行动", "complete safe fixed material")
	var remaining: int = RecommendationContract.INPUT_BYTES - String(built[1].content).to_utf8_buffer().size()
	entries[0].gm_text += "x".repeat(remaining)
	check(InputBuilder.build(entries, character)[1].content.to_utf8_buffer().size() == RecommendationContract.INPUT_BYTES, "exact 24KiB includes all fixed fields")
	entries[0].gm_text += "x"
	check(InputBuilder.build(entries, character).is_empty(), "24KiB plus one fails soft without truncation")
	entries[0].gm_text = "完整叙事"
	character.summary = "x".repeat(RecommendationContract.INPUT_BYTES)
	check(InputBuilder.build(entries, character).is_empty(), "oversized fixed Character has no request")
	var many: Array = [entries[0]]
	for i: int in range(1, 7): many.append({"turn_index": i, "player_text": "指导", "gm_text": "确认", "input_mode": "ooc"})
	payload = JSON.parse_string(InputBuilder.build(many)[1].content)
	check(payload.conversation.size() == 4 and payload.latest_accepted_role_action == "完整行动", "prior final action remains fixed evidence outside recent four OOC")
	check(JSON.parse_string(InputBuilder.build(many.slice(1))[1].content).latest_accepted_role_action == null, "no accepted action yields null")

func ui_evidence() -> void:
	var shell: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	shell.session_runtime = runtime
	shell.test_world_turn_adapter_override = Stub.new()
	shell.test_information_curator_adapter_override = Stub.new()
	shell.test_world_evolution_adapter_override = Stub.new()
	shell.test_action_recommender_adapter_override = Stub.new()
	root.add_child(shell)
	await frames()
	var view: Node = shell.narrative_view
	complete(shell.test_action_recommender_adapter_override, {"actions": ACTIONS})
	var before: Array = runtime.conversation.get_durable_accepted_entries()
	var current: Dictionary = runtime.world_state.duplicate(true)
	var calls: int = shell.test_information_curator_adapter_override.requests.size()
	view.input_mode.select(1)
	view.recommendation_grid.get_child(0).pressed.emit()
	await frames()
	check(view.input_mode.selected == 0 and view.player_input.text == ACTIONS[0].draft and not runtime.conversation.is_generating(), "click action mode exact prefill never-send")
	check(shell.test_information_curator_adapter_override.requests.size() == calls and runtime.world_state == current and runtime.conversation.get_durable_accepted_entries() == before, "clicked unsent draft zero Curator/evidence/durable mutation")
	view.player_input.text = "UNACCEPTED_COMPOSER_CANARY"
	check(not JSON.stringify(shell.test_action_recommender_adapter_override.requests).contains("UNACCEPTED_COMPOSER_CANARY"), "composer excluded from request")
	if visual:
		for dimensions: Vector2i in [Vector2i(960,540), Vector2i(1280,720), Vector2i(1920,1080)]:
			root.size = dimensions
			await frames()
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(directory.path_join("feedback-%dx%d.png" % [dimensions.x, dimensions.y]))
	shell._close_game_session()
	shell.queue_free()
	await frames()
