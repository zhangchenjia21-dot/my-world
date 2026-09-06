extends "res://tests/mw018/人物整理卡片纵向测试.gd"

const Recommender := preload("res://src/行动推荐/L3_外交层/行动推荐公开接口.gd")
const RecommendationParser := preload("res://src/行动推荐/L1_器件层/推荐响应解析器.gd")
const InputBuilder := preload("res://src/行动推荐/L1_器件层/推荐材料构建器.gd")
const RecommendationContract := preload("res://src/行动推荐/L0_公理层/行动推荐契约.gd")
const ACTIONS := ["我问问粮商明早何时出发。", "我沿河堤走一段，观察渡口的情况。", "我回到小亭，整理刚才听到的消息。", "我向守门人询问雨后道路是否好走。", "我先准备饮水，再决定下一步。"]
var recommender: Node
var recommendation: Node

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="):
			directory = arg.trim_prefix("--root=")
		if arg == "--visual":
			visual = true
	if not directory.contains("mw019"):
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(directory)
	runtime = Runtime.new()
	check(runtime.open_current_game(directory.path_join("recommendation.sqlite")).success, "isolated production SQLite")
	var private_world := setup()
	private_world["private_knowledge"] = "PRIVATE_KNOWLEDGE"
	private_world["source_current"] = "SOURCE_CURRENT"
	check(runtime.commit_world_mutation_durably("setup", "setup-node", private_world).success, "hidden canaries")
	attach()
	await frames()
	check(recommendation.requests.is_empty(), "empty game zero calls")
	runtime.conversation.begin_gm_opening()
	runtime.conversation.append_delta("雨停了。陈安说他明早要去渡口，守门人在城门旁值守，河边小亭还亮着灯。")
	check(runtime.complete_active_generation_durably().success, "opening durably accepted")
	await frames()
	check(recommendation.requests.size() == 1 and recommender.snapshot().status == "loading", "opening exactly one opportunity")
	var head: String = runtime.active_head_id
	var world: Dictionary = runtime.world_state.duplicate(true)
	var entries: Array = runtime.conversation.get_durable_accepted_entries()
	var count: Dictionary = runtime.persistence.timeline_node_count(runtime.game_id)
	complete(recommendation, {"actions": ACTIONS})
	check(recommender.snapshot().actions == ACTIONS, "exact five safe output")
	check(runtime.active_head_id == head and runtime.world_state == world and runtime.conversation.get_durable_accepted_entries() == entries and runtime.persistence.timeline_node_count(runtime.game_id) == count, "recommendations create no Conversation/World/Timeline/SQLite mutation")
	var save: Dictionary = runtime.create_save_point("opening")
	check(save.success, "Save independent")
	for canary: String in ["SECRET_PROFILE", "PRIVATE_KNOWLEDGE", "PRIVATE_PLAN", "HIDDEN_EVOLUTION", "SOURCE_CURRENT", "local_character_id", "turn_index", "information_curation", "sha256", "npc-a"]:
		check(not JSON.stringify(recommendation.requests[0]).contains(canary), "input excludes " + canary)
	var content: Dictionary = JSON.parse_string(recommendation.requests[0][1].content)
	check(content.conversation == [{"player": "", "gm": entries[0].gm_text}], "opening request includes exact full visible narrative only")
	accept("我询问出发时间。", "陈安说天亮后出发。")
	await frames()
	check(recommendation.requests.size() == 2, "normal turn one fresh call")
	var old_delta: Callable = recommender._callbacks.text_delta
	var old_done: Callable = recommender._callbacks.completed
	runtime.conversation.begin_turn("自由行动")
	check(recommender.snapshot().actions.is_empty() and not recommendation.busy, "foreground clears/cancels immediately")
	old_delta.call(JSON.stringify({"actions": ACTIONS}))
	old_done.call()
	check(recommender.snapshot().actions.is_empty(), "late foreground callbacks cannot publish")
	runtime.conversation.cancel_generation()
	await frames()
	check(recommendation.requests.size() == 2, "cancelled GM no opportunity")
	runtime.conversation.retry_or_regenerate_latest()
	runtime.conversation.append_delta("你停下脚步。")
	check(runtime.complete_active_generation_durably().success, "retry accepted")
	await frames()
	old_delta.call(JSON.stringify({"actions": ACTIONS}))
	old_done.call()
	check(recommendation.busy and recommender.snapshot().actions.is_empty(), "saved old callbacks cannot complete new request")
	complete(recommendation, {"actions": ACTIONS})
	runtime.conversation.correct_latest("我留在亭中。")
	check(recommender.snapshot().status == "empty", "correction clears")
	runtime.conversation.append_delta("你在亭中看雨。")
	runtime.conversation.cancel_generation()
	await frames()
	var calls: int = recommendation.requests.size()
	check(recommender.snapshot().actions.is_empty(), "cancelled correction no new options")
	runtime.conversation.retry_or_regenerate_latest()
	runtime.conversation.fail_generation("transport")
	await frames()
	check(recommendation.requests.size() == calls, "failed replacement no calls")
	runtime.conversation.correct_latest("我留在亭中。")
	runtime.conversation.append_delta("你在亭中看雨。")
	check(runtime.complete_active_generation_durably().success, "corrected replacement accepted")
	await frames()
	check(recommendation.requests.size() == calls + 1, "accepted replacement fresh call")
	old_delta = recommender._callbacks.text_delta
	old_done = recommender._callbacks.completed
	check(runtime.restore_save_point(save.save_id).success, "Restore accepted opening")
	check(recommender.snapshot().status == "empty", "Restore immediately clears")
	await frames()
	check(recommendation.requests.size() == calls + 2, "Restore at most one fresh request")
	old_delta.call(JSON.stringify({"actions": ACTIONS}))
	old_done.call()
	check(recommendation.busy and recommender.snapshot().actions.is_empty(), "pre-Restore callback after new request rejected")
	complete(recommendation, {"actions": ACTIONS})
	for mode: String in ["failure", "cancel", "timeout", "sync", "malformed", "oversize"]:
		recommendation.synchronous_failure = mode == "sync"
		accept("自由行动 " + mode, "叙事已接受 " + mode)
		await frames()
		var accepted_head: String = runtime.active_head_id
		if mode == "failure":
			recommendation.simulate_failed()
		elif mode == "cancel":
			recommendation.cancel()
		elif mode == "timeout":
			recommender._timer.start(0.01)
			await create_timer(0.04).timeout
		elif mode == "malformed":
			recommendation.simulate_delta("not JSON")
			recommendation.simulate_completed()
		elif mode == "oversize":
			recommendation.simulate_delta("x".repeat(8193))
		await frames()
		check(recommender.snapshot().status == "unavailable" and not recommendation.busy and runtime.active_head_id == accepted_head, mode + " fails soft without gameplay mutation")
		recommender._timer.wait_time = 120.0
	recommendation.synchronous_failure = false
	var db: String = runtime.database_path
	detach()
	runtime.close()
	runtime = Runtime.new()
	check(runtime.open_existing_game(db).success, "real reopen")
	attach()
	await frames()
	check(recommendation.requests.size() == 1, "reopen only one fresh call")
	complete(recommendation, {"actions": ACTIONS})
	await frames()
	check(recommendation.requests.size() == 1, "idle no repeated call")
	check(runtime.restore_save_point(save.save_id).success, "restore visible opening for UI")
	detach()
	await ui_checks()
	validator_checks()
	await frames()
	print("MW-019 FOCUSED checks=%d failures=%d" % [checks, failures])
	quit(0 if failures == 0 else 1)

func attach() -> void:
	recommendation = Stub.new()
	recommender = Recommender.new(runtime, recommendation)
	root.add_child(recommender)

func detach() -> void:
	recommender.shutdown()
	recommender.queue_free()

func ui_checks() -> void:
	var shell: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	shell.session_runtime = runtime
	shell.test_world_turn_adapter_override = Stub.new()
	shell.test_information_curator_adapter_override = Stub.new()
	shell.test_world_evolution_adapter_override = Stub.new()
	shell.test_action_recommender_adapter_override = Stub.new()
	root.add_child(shell)
	await frames()
	var view: Node = shell.narrative_view
	var stub: Node = shell.test_action_recommender_adapter_override
	check(view.player_input.editable, "composer editable during recommendation loading")
	view.player_input.text = "我自己的想法"
	complete(stub, {"actions": ACTIONS})
	await frames()
	check(view.player_input.text == "我自己的想法", "response never replaces typed draft")
	check(view.recommendation_grid.get_child_count() == 5, "production UI renders exactly five buttons")
	var before: Array = runtime.conversation.get_durable_accepted_entries()
	view.recommendation_grid.get_child(1).pressed.emit()
	check(view.player_input.text == ACTIONS[1] and view.player_input.has_focus() and view.player_input.get_caret_column() == ACTIONS[1].length(), "click replaces/focuses/caret at editable end")
	check(not runtime.conversation.is_generating() and runtime.conversation.get_durable_accepted_entries() == before, "click never submits or mutates history")
	view.player_input.insert_text_at_caret(" 然后回到小亭。")
	check(view.player_input.text.ends_with("然后回到小亭。"), "prefilled draft freely editable")
	var calls: int = stub.requests.size()
	root.mode = Window.MODE_WINDOWED
	for dimension: Vector2i in [Vector2i(1600, 900), Vector2i(1280, 720), Vector2i(960, 540)]:
		root.size = dimension
		await frames()
		shell.world_toggle.button_pressed = true
		shell._select_world_surface_mode("people")
		await frames()
		view.redraw_from_conversation()
		await frames()
		print("LAYOUT %s narrative=%s recommendations=%s" % [dimension, view.narrative_scroll.size, view.recommendation_area.size])
		check(view.recommendation_grid.size.x <= view.size.x and view.narrative_scroll.size.y > view.recommendation_area.size.y, "bounded guidance and dominant reading area " + str(dimension))
		for button: Button in view.recommendation_grid.get_children():
			check(button.get_global_rect().end.x <= view.get_global_rect().end.x and button.tooltip_text == button.text, "no button overflow/full tooltip " + str(dimension))
		if visual:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(directory.path_join("recommendations-%dx%d.png" % [dimension.x, dimension.y]))
	if visual:
		root.mode = Window.MODE_MAXIMIZED
		await create_timer(0.3).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(directory.path_join("recommendations-maximized.png"))
	check(stub.requests.size() == calls, "render/resize/tabs/edit/click zero calls")
	# 用原 GM adapter 的测试 transport，保留原 Send/Domain/Finalize 路径。
	var gm_stub: Node = preload("res://tests/g2_03_桩适配器.gd").new()
	view._disconnect_adapter_signals(view.adapter)
	view.adapter.queue_free()
	view.adapter = gm_stub
	view.add_child(gm_stub)
	gm_stub.text_delta.connect(view._on_text_delta)
	gm_stub.completed.connect(view._on_completed)
	gm_stub.cancelled.connect(view._on_cancelled)
	gm_stub.failed.connect(view._on_failed)
	# 此最小世界 fixture 使用旧 Conversation context；完整 Wizard/d20 路径另有纵向验证。
	view.bind_opening_runtime(null)
	var edited: String = view.player_input.text
	view._on_send_pressed()
	check(runtime.conversation.is_generating() and not view.recommendation_area.visible, "normal Send begins original route and clears options")
	check(runtime.conversation.latest_turn().pending_player_text == edited, "Send uses edited exact draft")
	gm_stub.text_delta.emit("你在河堤上走了一段，随后回到了小亭。")
	gm_stub.simulate_completed()
	await frames()
	check(stub.requests.size() == calls + 1, "accepted real UI turn creates fresh opportunity")
	var long_actions: Array = []
	for i: int in range(5):
		long_actions.append("我看看\n".repeat(59) + str(i) + "。字字")
	complete(stub, {"actions": long_actions})
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(960, 540)
	await frames()
	for button: Button in view.recommendation_grid.get_children():
		check(button.size.y <= 28 and not button.text.contains("\n") and button.tooltip_text.length() == 240, "240-char multiline draft stays compact with full tooltip")
	view.recommendation_grid.get_child(4).pressed.emit()
	check(view.player_input.text == long_actions[4], "prefill preserves full multiline draft bytes")
	view._on_send_pressed()
	gm_stub.text_delta.emit("你看了看周围。")
	gm_stub.simulate_completed()
	await frames()
	stub.simulate_failed()
	check(view.player_input.editable and not view.error_label.visible, "recommendation failure does not enter main error path")
	view.player_input.text = "全新的自由行动"
	view._on_send_pressed()
	check(runtime.conversation.latest_turn().pending_player_text == "全新的自由行动", "manual input sends after failure")
	gm_stub.cancel()
	# 正在处理的回调在关闭后即使被调用也不能发布；不等 transport 自己终止。
	var recommendation_worker: Node = shell.action_recommender
	var callback: Callable = recommendation_worker._on_completed.bind(recommendation_worker._serial)
	shell._close_game_session()
	callback.call()
	check(recommendation_worker.snapshot().status == "empty", "shutdown callback cannot publish")
	shell.queue_free()

func validator_checks() -> void:
	check(RecommendationParser.parse(JSON.stringify({"actions": ACTIONS})) == ACTIONS, "valid exact five")
	for bad: String in ["bad", "[]", "null", JSON.stringify({"actions": ACTIONS, "extra": 1}), JSON.stringify({"actions": ACTIONS.slice(0,4)}), JSON.stringify({"actions": ACTIONS + ["第六"]}), JSON.stringify({"actions": ["a","a","b","c","d"]}), JSON.stringify({"actions": ["a"," a ","b","c","d"]}), JSON.stringify({"actions": ["a",1,"b","c","d"]}), JSON.stringify({"actions": ["a"," ","b","c","d"]}), JSON.stringify({"actions": ["字".repeat(241),"a","b","c","d"]}), "[".repeat(500)]:
		check(RecommendationParser.parse(bad).is_empty(), "invalid shape/size/depth fail-soft")
	var max_actions: Array = []
	for i: int in range(5):
		max_actions.append("字".repeat(239) + str(i))
	var text := JSON.stringify({"actions": max_actions})
	check(RecommendationParser.parse(text).size() == 5, "five x240 Unicode exact bound")
	var padded := text + " ".repeat(8192 - text.to_utf8_buffer().size())
	check(RecommendationParser.parse(padded).size() == 5 and RecommendationParser.parse(padded + " ").is_empty(), "response exact8192 / over8192")
	var quoted := {"actions": ['我说"你好"。', "我看看[窗外]。", "我写下{记录}。", "我等待。", "我回去。"]}
	check(RecommendationParser.parse(JSON.stringify(quoted)).size() == 5, "brackets/quotes in strings accepted")
	var many: Array = []
	for i: int in range(8):
		many.append({"turn_index": i, "player_text": "行动" + str(i), "gm_text": "叙事" + str(i), "hidden": "CANARY"})
	var built := InputBuilder.build(many)
	var window: Array = JSON.parse_string(built[1].content).conversation
	check(window.size() == 4 and window[0].gm == "叙事4" and window[-1].gm == "叙事7" and not JSON.stringify(built).contains("CANARY"), "latest four deterministic recency and field allowlist")
	check(InputBuilder.prefix(many) != InputBuilder.prefix(many.slice(1)), "currentness includes prefix outside model window")
	var overhead: int = JSON.stringify({"conversation": [{"player": "", "gm": ""}]}).to_utf8_buffer().size()
	var exact := [{"player_text": "", "gm_text": "x".repeat(24576 - overhead)}]
	check(InputBuilder.build(exact)[1].content.to_utf8_buffer().size() == 24576, "input exact24KiB passes latest intact")
	exact[0].gm_text += "x"
	check(InputBuilder.build(exact).is_empty(), "oversize latest fails soft without truncation")
	many[7].gm_text = "x".repeat(24000)
	check(InputBuilder.build(many)[1].content.to_utf8_buffer().size() <= 24576 and JSON.parse_string(InputBuilder.build(many)[1].content).conversation[-1].gm == many[7].gm_text, "byte-limited window retains full latest")

func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("MW-019 FAIL " + label)
	else:
		print("MW-019 PASS " + label)
