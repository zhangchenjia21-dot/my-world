extends "res://tests/mw022/会话调试观测纵向测试.gd"

const ThreadsSafe := preload("res://src/信息整理/L3_外交层/事务投影公开接口.gd")
const ThreadsFold := preload("res://src/信息整理/L1_器件层/事务快照投影器.gd")
const A := [{"title":"等候渡口消息", "summary":"粮商说会送来消息，结果尚未得知。", "details":["可以继续自己的行程。"]}]
const B := [{"title":"河路消息", "summary":"已得知一部分消息，仍有疑问未解。", "details":[]}]

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="): directory = arg.trim_prefix("--root=")
		if arg == "--visual": visual = true
	if not directory.contains("mw027"): quit(2); return
	DirAccess.make_dir_recursive_absolute(directory)
	contracts()
	runtime = Runtime.new()
	check(runtime.open_current_game(directory.path_join("threads.sqlite")).success, "isolated SQLite")
	check(runtime.commit_world_mutation_durably("setup", "setup", setup()).success, "private fixture")
	observer = Observer.new(runtime); root.add_child(observer)
	semantic = Stub.new(); worker = World.new(runtime, semantic)
	root.add_child(worker)
	curation = Stub.new(); curator = Curator.new(runtime, curation, worker)
	observer.observe_curator(curator); root.add_child(curator)
	await frames()
	check(curation.requests.size() == 1 and not JSON.stringify(curation.requests).contains("open_threads"), "initial only one Character call, no threads input")
	complete(curation, {"character":Safe.project_session(runtime).character, "experiences":[]})
	await frames()
	check(ThreadsSafe.project_session(runtime).is_empty() and row("threads", -1).is_empty(), "initial never creates Threads or reports lived threads")
	runtime.conversation.begin_gm_opening(); runtime.conversation.append_delta("你在河畔暂歇。")
	check(runtime.complete_active_generation_durably().success, "opening accepted")
	await frames()
	check(curation.requests.size() == 1, "no opening curation")
	var before: Dictionary = runtime.create_save_point("before")
	# v0.2 ID 按冻结旧算法构造，不借新实现自证兼容。
	var state: Dictionary = runtime.world_state.duplicate(true)
	var prefix: String = Contract.prefix_hashes(runtime.conversation.get_durable_accepted_entries())[0]
	var old_result := {"character":null,"experiences":[],"people_updates":[]}
	var old_id := JSON.stringify(["information_curation_lived.v0.2", prefix, "", old_result, ""], "", true).sha256_text()
	state.information_curation.turns["0"] = {"schema":"information_curation_lived.v0.2","prefix":prefix,"parent":"","id":old_id,"identity_receipt_id":"","result":old_result}
	check(runtime.commit_world_mutation_durably("legacy", "legacy", state).success, "old v0.2 record stored")
	var original: Dictionary = state.information_curation.turns["0"].duplicate(true)
	check(Contract.current_records(state, runtime.conversation.get_durable_accepted_entries())[0].id == old_id, "old ID validated without injecting new fields")
	var invalid_old := state.duplicate(true)
	invalid_old.information_curation.turns["0"].result["open_threads"] = null
	check(Contract.current_records(invalid_old, runtime.conversation.get_durable_accepted_entries()).is_empty(), "v0.2 rejects injected fields instead of changing old ID rules")
	var initial_safe := Safe.project_session(runtime)
	await turn("询问消息", A)
	check(ThreadsSafe.project_session(runtime) == A and row("threads", 1).change == "changed", "replacement plus Debug changed")
	var snapshot: Dictionary = runtime.create_save_point("with threads")
	check(runtime.world_state.information_curation.turns["0"] == original, "v0.2 bytes/shape remain unchanged")
	var latest: Dictionary = runtime.world_state.information_curation.turns["1"]
	check(latest.schema == "information_curation_lived.v0.3" and latest.parent == old_id, "v0.3 chains to exact v0.2 parent")
	check(latest.id == JSON.stringify([latest.schema, latest.prefix, latest.parent, latest.result, latest.identity_receipt_id], "", true).sha256_text(), "v0.3 exact normalized payload and dependency ID")
	var altered: Dictionary = runtime.world_state.duplicate(true)
	altered.information_curation.turns["1"].result.open_threads = B
	check(ThreadsFold.project(altered, runtime.conversation.get_durable_accepted_entries()).is_empty(), "v0.3 result tampering rejected")
	altered = runtime.world_state.duplicate(true)
	altered.information_curation.turns["1"].identity_receipt_id = "stale-receipt"
	var changed_record: Dictionary = altered.information_curation.turns["1"]
	changed_record.id = Contract.lived_record_id(changed_record.prefix, changed_record.parent, changed_record.result, changed_record.identity_receipt_id)
	check(ThreadsFold.project(altered, runtime.conversation.get_durable_accepted_entries()) == A, "People receipt dependency does not suppress valid Threads")
	await turn("沿河散步", null)
	check(ThreadsSafe.project_session(runtime) == A and row("threads", 2).change == "no-change", "null keeps and Debug no-change")
	check(input().current_open_threads == A, "same call receives current safe threads")
	await turn("得知新消息", B)
	check(ThreadsSafe.project_session(runtime) == B, "complete replacement")
	await turn("消息已经清楚", [])
	check(ThreadsSafe.project_session(runtime).is_empty(), "empty array clears")
	await turn("再次讨论", A)
	await prepare_turn("旧协议回复")
	complete(curation, answer([])); await frames()
	check(ThreadsSafe.project_session(runtime) == A, "old response missing field means keep")
	check(Safe.project_session(runtime) == initial_safe and PeopleSafe.project_session(runtime).is_empty(), "existing domains preserved")
	for canary: String in ["SECRET_PROFILE", "PRIVATE_PLAN", "HIDDEN_EVOLUTION", "npc-a", "identity_receipt_id"]:
		check(not JSON.stringify(input()).contains(canary), "input excludes " + canary)
	var safe := ThreadsSafe.project_session(runtime)
	check(Contract.keys_exact(safe[0], ["title","summary","details"]), "safe projection exact allowlist")
	safe[0].title = "MUTATED"
	check(ThreadsSafe.project_session(runtime) == A, "projection detached")
	for terminal: String in ["malformed", "failure", "cancelled", "timeout"]:
		await prepare_turn(terminal)
		var accepted: Array = runtime.conversation.get_durable_accepted_entries()
		if terminal == "malformed": complete(curation, {"character":null,"experiences":[],"open_threads":[{"bad":true}]})
		elif terminal == "failure": curation.simulate_failed("SECRET_KEY")
		elif terminal == "cancelled": curation.cancel()
		else: curator._on_timeout()
		await frames()
		check(ThreadsSafe.project_session(runtime) == A and runtime.conversation.get_durable_accepted_entries() == accepted, "failure preserves accepted Narrative and Threads " + terminal)
		check(row("threads", accepted.size()-1).terminal == ("cancelled" if terminal == "cancelled" else "failed"), "Debug abnormal " + terminal)
	var calls: int = curation.requests.size()
	runtime.conversation.begin_turn("放慢节奏", "ooc"); runtime.conversation.append_delta("好的。")
	check(runtime.complete_active_generation_durably().success, "OOC accepted")
	await frames()
	check(curation.requests.size() == calls and ThreadsSafe.project_session(runtime) == A, "OOC zero lived opportunity")
	await prepare_turn("待替换行动")
	runtime.conversation.correct_latest("改为另一个行动")
	runtime.conversation.append_delta("不同的当前叙事。")
	check(runtime.complete_active_generation_durably().success, "replacement accepted")
	complete(curation, {"character":null,"experiences":[],"open_threads":B}); await frames()
	check(ThreadsSafe.project_session(runtime) == A, "stale accepted-prefix callback rejected")
	check(observer.snapshot().any(func(r: Dictionary) -> bool: return r.lane == "threads" and r.terminal == "stale"), "Debug stale lane")
	check(runtime.restore_save_point(before.save_id).success, "Restore before")
	curator._on_delta(JSON.stringify({"character":null,"experiences":[],"open_threads":B})); curator._on_completed()
	check(ThreadsSafe.project_session(runtime).is_empty() and row("threads",1).is_empty(), "Restore clears old epoch and displaced future")
	check(runtime.restore_save_point(snapshot.save_id).success, "Restore after")
	await frames()
	check(ThreadsSafe.project_session(runtime) == A, "restored exact current snapshot")
	check(not JSON.stringify(observer.snapshot()).contains(A[0].title), "Debug has no content")
	observer.shutdown(); observer.queue_free(); teardown(); await frames()
	runtime.close()
	runtime = Runtime.new(); check(runtime.open_current_game(directory.path_join("threads.sqlite")).success, "reopen")
	check(ThreadsSafe.project_session(runtime) == A, "reopen preserves snapshot")
	await window_checks()
	print("MW027 checks=%d failures=%d" % [checks, failures])
	quit(0 if failures == 0 else 1)

func prepare_turn(text: String) -> void:
	var calls: int = curation.requests.size()
	accept(text, "玩家已知的叙事：" + text)
	await frames()
	if semantic.busy: complete(semantic, {"changes":[]})
	await frames()
	check(curation.requests.size() == calls + 1 and curation.busy, "one existing lived call " + text)

func turn(text: String, threads: Variant) -> void:
	await prepare_turn(text)
	complete(curation, {"character":null,"experiences":[],"people_updates":[],"open_threads":threads})
	await frames()

func contracts() -> void:
	for value: Variant in [null, [], A]:
		var parsed := Parser.parse(JSON.stringify({"character":null,"experiences":[],"open_threads":value}), true)
		check(not parsed.is_empty() and parsed.open_threads == value, "valid null/replace/clear")
	check(Parser.parse(JSON.stringify({"character":null,"experiences":[]}),true).open_threads == null, "missing compatibility")
	check(Parser.parse(JSON.stringify({"character":null,"experiences":[],"open_threads":A})).is_empty(), "initial parser cannot create Threads")
	for value: Variant in [true, "text", {}, [null], [{"title":"x","summary":"y","details":[],"priority":1}], [{"title":"x".repeat(161),"summary":"y","details":[]}], [{"title":"x","summary":"y".repeat(801),"details":[]}], [{"title":"x","summary":"y","details":["a","b","c","d","e"]}], [{"title":"x","summary":"y","details":["a".repeat(501)]}], [{"title":"x","summary":"y","details":[1]}]]:
		check(Parser.parse(JSON.stringify({"character":null,"experiences":[],"open_threads":value}),true).is_empty(), "invalid machine shape rejected atomically")
	var maximum: Array = []
	for i: int in 12: maximum.append({"title":"字".repeat(160),"summary":"字".repeat(800),"details":["字".repeat(500),"字".repeat(500),"字".repeat(500),"字".repeat(500)]})
	check(Contract.threads_valid(maximum), "exact field bounds")
	maximum.append(A[0]); check(not Contract.threads_valid(maximum), "13 rejected")

func window_checks() -> void:
	var shell: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	shell.session_runtime = runtime
	shell.test_world_turn_adapter_override = Stub.new()
	shell.test_information_curator_adapter_override = Stub.new()
	shell.test_world_evolution_adapter_override = Stub.new()
	shell.test_action_recommender_adapter_override = Stub.new()
	root.add_child(shell); await frames()
	check(shell.test_information_curator_adapter_override.requests.is_empty(), "reopen no historical backfill/no extra curation")
	accept("继续了解消息", "玩家得知新的河路消息。")
	await frames()
	complete(shell.test_world_turn_adapter_override, {"changes":[]})
	await frames()
	complete(shell.test_information_curator_adapter_override, {"character":null,"experiences":[],"open_threads":B})
	await frames()
	check(shell.debug_observer.snapshot().any(func(r: Dictionary) -> bool: return r.lane == "threads" and r.change == "changed"), "production Shell Debug receives Threads change")
	var debug_rows: Array = shell.debug_observer.snapshot()
	var file := FileAccess.open(directory.path_join("debug-threads.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(debug_rows,"\t")); file.close()
	var curator_calls: int = shell.test_information_curator_adapter_override.requests.size()
	var data: Dictionary = runtime.world_state.duplicate(true)
	var entries: Array = runtime.conversation.get_durable_accepted_entries()
	var calls: int = shell.test_action_recommender_adapter_override.requests.size()
	for dimensions: Vector2i in [Vector2i(960,540),Vector2i(1280,720),Vector2i(1920,1080)]:
		root.size = dimensions
		shell.world_toggle.button_pressed = true
		shell.threads_tab.button_pressed = true
		await frames()
		check(shell._threads_panel_body.is_visible_in_tree() and shell.threads_tab.get_theme_font_size("font_size") >= 20, "Threads tab visible/readable " + str(dimensions))
		for label: Node in shell._threads_panel_body.find_children("*", "Label", true, false):
			check(label.get_theme_font_size("font_size") >= 20 and label.get_global_rect().end.x <= root.size.x, "effective font and no horizontal overflow")
		check(shell.narrative_view.player_input.get_global_rect().end.y <= root.size.y, "composer usable")
		if visual:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(directory.path_join("threads-%dx%d.png" % [dimensions.x,dimensions.y]))
		shell.save_tab.button_pressed = true; shell.threads_tab.button_pressed = true
	check(runtime.world_state == data and runtime.conversation.get_durable_accepted_entries() == entries and shell.test_information_curator_adapter_override.requests.size() == curator_calls and shell.test_action_recommender_adapter_override.requests.size() == calls, "tabs/render zero calls and durable mutation")
	shell.debug_toggle.button_pressed = true
	await frames()
	check(shell.debug_panel.visible and shell.debug_panel._rows.get_child_count() > 0, "Debug readable rows")
	if visual:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(directory.path_join("threads-debug.png"))
	shell.debug_toggle.button_pressed = false
	root.size = Vector2i(960,540)
	var crowded: Array = []
	for i: int in 12:
		crowded.append({"title":"当前事项 " + str(i+1), "summary":"仍有玩家已知的问题尚未解决。".repeat(8), "details":["已经得知的细节。".repeat(10)]})
	await shell_turn(shell, crowded)
	await frames()
	var scroll: ScrollContainer = shell.world_surface_scroll
	check(scroll.get_v_scroll_bar().max_value > scroll.get_v_scroll_bar().page, "12 bounded threads use existing vertical scroll")
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
	await frames()
	check(scroll.scroll_vertical > 0 and shell.narrative_view.player_input.get_global_rect().end.y <= root.size.y, "last thread reachable with composer intact")
	if visual:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(directory.path_join("threads-scroll-960x540.png"))
	await shell_turn(shell, [])
	check(shell._threads_panel_body.find_children("*", "Label", true, false)[0].text.contains("没有"), "model clear renders production tab empty state")
	var leaf: Node = load("res://src/ui/事务列表.gd").new(); root.add_child(leaf); leaf.render([])
	check(leaf.get_child(0).text.contains("没有"), "clear empty state")
	leaf.queue_free(); shell._close_game_session(); shell.queue_free(); await frames()

func shell_turn(shell: Node, threads: Array) -> void:
	var calls: int = shell.test_information_curator_adapter_override.requests.size()
	accept("继续观察", "这是玩家已知的后续叙事。")
	await frames()
	complete(shell.test_world_turn_adapter_override, {"changes":[]})
	await frames()
	complete(shell.test_information_curator_adapter_override, {"character":null,"experiences":[],"open_threads":threads})
	await frames()
	check(shell.test_information_curator_adapter_override.requests.size() == calls + 1, "same single Curator opportunity updates UI")
