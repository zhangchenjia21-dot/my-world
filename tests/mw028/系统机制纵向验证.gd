extends "res://tests/mw022/会话调试观测纵向测试.gd"

const Mechanics := preload("res://src/行动判定/L3_外交层/公开机制历史公开接口.gd")
class FixedRng:
	extends RefCounted
	var calls := 0
	func roll_d20() -> int:
		calls += 1
		return 7 if calls % 2 == 1 else 18
var shell: Node
var dice: Node
var early_empty := false

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="): directory = arg.trim_prefix("--root=")
		if arg == "--visual": visual = true
	if not directory.contains("mw028"): quit(2); return
	DirAccess.make_dir_recursive_absolute(directory)
	pure_checks()
	runtime = Runtime.new()
	check(runtime.open_current_game(directory.path_join("system.sqlite")).success, "isolated real SQLite")
	var state := setup()
	state["expansions"] = [{"capability_slot":"action_resolution", "capability_id":"action_check.public_d20.v1", "semantic_sections":[]}]
	check(runtime.commit_world_mutation_durably("setup", "setup", state).success, "fixture setup")
	accept("", "你在城门外停步。")
	shell = load("res://src/main.tscn").instantiate()
	shell.session_runtime = runtime
	shell.test_world_turn_adapter_override = Stub.new()
	shell.test_information_curator_adapter_override = Stub.new()
	shell.test_world_evolution_adapter_override = Stub.new()
	shell.test_action_recommender_adapter_override = Stub.new()
	dice = Stub.new(); shell.test_adjudication_adapter_override = dice
	shell.test_adjudication_rng_override = FixedRng.new()
	root.add_child(shell); await frames()
	observer = shell.debug_observer
	shell.world_toggle.button_pressed = true; shell.system_tab.button_pressed = true
	await frames()
	check(text_of(shell._system_panel_body).contains("暂无公开判定记录。"), "production empty state")
	check(not shell.debug_panel.visible, "Debug defaults OFF")
	var before: Dictionary = runtime.create_save_point("before check")
	var timing := func(_turn: RefCounted) -> void: early_empty = Mechanics.project_session(runtime).is_empty()
	runtime.conversation.generation_completed.connect(timing)
	await checked_action("我尝试说服守卫。", "advantage")
	runtime.conversation.generation_completed.disconnect(timing)
	check(early_empty, "Conversation completion really precedes acceptance marker")
	var projected := Mechanics.project_session(runtime)
	check(projected.size() == 1 and text_of(shell._system_panel_body).contains("说服守卫"), "terminal refresh shows new CHECK without tab/reopen/next turn")
	check(projected[0].raw_rolls == [7,18] and projected[0].selected_roll == 18 and projected[0].total == 20, "exact Program advantage arithmetic")
	check(row("mechanics",1).code == "check_accepted" and row("mechanics",1).change == "changed", "wired real CHECK Debug")
	check(shell.narrative_view.entries.get_children().any(func(n:Node)->bool: return n.has_meta("mechanic_card")), "inline dice card retained")
	check(dice.requests.size() == 2 and shell.test_adjudication_rng_override.calls == 2, "one existing control plus narrative, no projection calls/RNG")
	root.size = Vector2i(1280,720)
	shell.debug_toggle.button_pressed = true; await frames()
	check(text_of(shell.debug_panel).contains("公开检定已接受"), "real Debug panel shows accepted CHECK safe reason")
	await screenshot("system-check-debug.png")
	shell.debug_toggle.button_pressed = false
	var after: Dictionary = runtime.create_save_point("after check")
	var record: Dictionary = runtime.world_state.expansion_runtime.public_d20_checks[0]
	var calls: int = dice.requests.size()
	shell.action_adjudication.start_action(record.action_id, record.player_text)
	check(row("mechanics",1).code == "already_accepted" and row("mechanics",1).change == "no-change" and dice.requests.size() == calls, "accepted replay no call/no change")
	await windows("single")
	check(runtime.restore_save_point(before.save_id).success, "Restore before")
	check(Mechanics.project_session(runtime).is_empty() and text_of(shell._system_panel_body).contains("暂无"), "Restore removes displaced CHECK immediately")
	check(not observer.snapshot().any(func(r:Dictionary)->bool:return r.lane == "mechanics"), "Restore clears old diagnostic epoch")
	check(runtime.restore_save_point(after.save_id).success, "Restore after")
	check(Mechanics.project_session(runtime) == projected and text_of(shell._system_panel_body).contains("说服守卫"), "Restore returns exact CHECK")
	await plain_action("我在门口等候。", false)
	check(row("mechanics",2).code == "no_check_accepted" and row("mechanics",2).counts.no_checks == 1 and row("mechanics",2).change == "changed", "NO_CHECK true durable change")
	check(Mechanics.project_session(runtime) == projected and Mechanics.project(runtime.world_state,runtime.conversation.get_durable_accepted_entries()).contains("NO_CHECK"), "NO_CHECK continuity but no player card")
	await plain_action("我眺望远处。", true)
	check(row("mechanics",3).code == "degraded" and row("mechanics",3).change == "no-change", "degraded accepted has no invented mechanics")
	shell.narrative_view.player_input.text = "我继续询问。"; shell.narrative_view._on_send_pressed(); await frames()
	dice.busy = false; dice.failed.emit("transport", "PRIVATE_PROVIDER_CANARY")
	await frames()
	check(row("mechanics",-1).terminal == "failed" and row("mechanics",-1).code == "provider_failure", "safe Provider failure terminal")
	shell.narrative_view.player_input.text = "我准备离开。"; shell.narrative_view._on_send_pressed(); await frames()
	shell.action_adjudication.cancel(); await frames()
	check(row("mechanics",-1).terminal == "cancelled", "cancelled terminal")
	var raw_debug := JSON.stringify(observer.snapshot())
	for canary: String in ["PRIVATE", "action_id", "check_id", "resolution_id", "说服守卫", "success_intent"]:
		check(not raw_debug.contains(canary), "Debug excludes " + canary)
	shell.action_adjudication.action_started.emit()
	check(runtime.restore_save_point(before.save_id).success, "Restore with pending diagnostic")
	shell.action_adjudication.finished.emit({"success":true,"status":"accepted","check":record})
	check(not observer.snapshot().any(func(r:Dictionary)->bool:return r.lane == "mechanics"), "late terminal cannot cross Restore epoch")
	check(runtime.restore_save_point(after.save_id).success, "return to after")
	# 使用已接受序列构建最大 history，仅替换测试 fixture；生产 selector/view 仍走真实路径。
	for i: int in 14: accept("历史行动" + str(i), "公开结果" + str(i))
	var many: Dictionary = runtime.world_state.duplicate(true)
	var history: Array = runtime.conversation.get_durable_accepted_entries()
	for i: int in range(2,history.size()):
		var item := record.duplicate(true); item.accepted_turn_index = i; item.player_text = history[i].player_text
		item.intent = "历史判定 %d " % i + "已公开的行动细节。".repeat(8)
		item.check_id = "fixture-" + str(i); many.expansion_runtime.public_d20_checks.append(item)
	check(runtime.commit_world_mutation_durably("many","many",many).success, "12+ accepted fixture checks")
	shell.system_tab.button_pressed = false; shell.system_tab.button_pressed = true
	check(Mechanics.project_session(runtime).size() == 12 and Mechanics.project_session(runtime)[0].accepted_turn == history.size(), "System bounded twelve")
	await windows("many")
	shell.debug_toggle.button_pressed = true; await frames()
	check(shell.debug_panel.visible, "Debug ON renders safely")
	await screenshot("system-debug.png")
	var file := FileAccess.open(directory.path_join("debug-mechanics.json"),FileAccess.WRITE); file.store_string(raw_debug); file.close()
	var final_projection := Mechanics.project_session(runtime)
	shell._close_game_session(); shell.queue_free(); await frames()
	var reopened := Runtime.new()
	check(reopened.open_current_game(directory.path_join("system.sqlite")).success, "reopen SQLite after releasing session lock")
	check(Mechanics.project_session(reopened) == final_projection, "reopen exact integer CHECK projection")
	reopened.close()
	print("MW028 checks=%d failures=%d" % [checks,failures]); quit(0 if failures == 0 else 1)

func checked_action(player: String, stance: String) -> void:
	shell.narrative_view.player_input.text = player; shell.narrative_view._on_send_pressed(); await frames()
	complete(dice, {"decision":"CHECK_REQUIRED","proposal":{"intent":"说服守卫","dc":18,"modifier":2,"stance":stance,"modifier_reason":"熟悉本地礼节","situation_reason":"守卫愿意听取解释","success_intent":"获准进城","failure_stakes":"守卫提高警觉"}})
	await frames(); dice.text_delta.emit("守卫听完解释，允许你通过。"); dice.busy = false; dice.completed.emit(); await frames()

func plain_action(player: String, degraded: bool) -> void:
	shell.narrative_view.player_input.text = player; shell.narrative_view._on_send_pressed(); await frames()
	if degraded:
		for i:int in 2:
			dice.text_delta.emit("invalid"); dice.busy = false; dice.completed.emit(); await frames()
	else:
		complete(dice,{"decision":"NO_CHECK","reason":"普通等候无需检定"}); await frames()
	dice.text_delta.emit("你在城门外安静地等待。"); dice.busy = false; dice.completed.emit(); await frames()

func windows(label: String) -> void:
	var state: Dictionary = runtime.world_state.duplicate(true)
	var entries: Array = runtime.conversation.get_durable_accepted_entries()
	var head: String = runtime.active_head_id
	var calls: int = dice.requests.size()
	for dimensions: Vector2i in [Vector2i(960,540),Vector2i(1280,720),Vector2i(1920,1080)]:
		root.size = dimensions; await frames()
		var names: Array = shell.world_nav.get_children().map(func(n:Node)->String:return n.text)
		check(names == ["概览","角色","重要经历","人物","事务","系统","存档"], "seven tabs in order")
		for tab: Button in shell.world_nav.get_children(): tab.button_pressed = true
		shell.system_tab.button_pressed = true; await frames()
		for control: Node in shell._system_panel_body.find_children("*","Label",true,false):
			check(control.get_theme_font_size("font_size") >= 20 and control.get_global_rect().end.x <= root.size.x, "font>=20 and horizontal bounds")
		check(shell.narrative_view.player_input.get_global_rect().end.y <= root.size.y and not shell._player_status_has_content,"composer reachable/status host stays collapsed")
		shell.world_surface_scroll.scroll_vertical = 0; await frames()
		await screenshot("system-%s-%dx%d.png" % [label,dimensions.x,dimensions.y])
		var bar: VScrollBar = shell.world_surface_scroll.get_v_scroll_bar()
		if label == "many":
			check(bar.max_value > bar.page,"long history overflows vertically")
			shell.world_surface_scroll.scroll_vertical = int(bar.max_value); await frames()
			check(shell.world_surface_scroll.scroll_vertical > 0,"last card reachable")
	check(runtime.world_state == state and runtime.conversation.get_durable_accepted_entries() == entries and runtime.active_head_id == head and dice.requests.size() == calls,"tabs/render zero Provider and durable mutation")

func screenshot(name: String) -> void:
	if visual:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(directory.path_join(name))

func text_of(node: Node) -> String:
	var value := String(node.text) if node is Label else ""
	for child: Node in node.get_children(): value += text_of(child)
	return value

func pure_checks() -> void:
	var entries := [{"player_text":"a","gm_text":"b"}]
	var record := {"narrative_accepted":true,"accepted_turn_index":0,"player_text":"a","intent":"x","dc":18,"modifier":2,"stance":"advantage","raw_rolls":[7,18],"selected_roll":18,"total":20,"outcome":"success","modifier_reason":"m","situation_reason":"s","success_intent":"yes","failure_stakes":"no","check_id":"PRIVATE_CHECK","action_id":"PRIVATE_ACTION","control":"PRIVATE_CONTROL"}
	var world := {"expansion_runtime":{"public_d20_checks":[record],"private":"PRIVATE_WORLD"}}
	var safe := Mechanics.project_checks(JSON.parse_string(JSON.stringify(world)),entries)
	check(safe.size()==1 and safe[0].size()==13,"exact thirteen allowed fields")
	check(safe[0].raw_rolls[0] is int and safe[0].dc is int and safe[0].accepted_turn == 1,"JSON round-trip integer semantics")
	check(not JSON.stringify(safe).contains("PRIVATE"),"projection excludes private/internal canaries")
	safe[0].raw_rolls[0] = 1; check(record.raw_rolls == [7,18],"detached mutable array")
	var expected := {"accepted_turn":1,"branch":"CHECK"}
	for key:String in ["intent","dc","modifier","stance","selected_roll","total","outcome","success_intent","failure_stakes"]: expected[key] = record[key]
	check(Mechanics.project(world,entries).split("\n")[-1] == JSON.stringify([expected]),"GM context exact old fields/values")
	var changed := entries.duplicate(true); changed[0]["input_mode"]="ooc"
	check(Mechanics.project_checks(world,changed).is_empty(),"OOC absent")
	changed=entries.duplicate(true); changed[0].player_text="replaced"
	check(Mechanics.project_checks(world,changed).is_empty(),"replaced accepted action absent")
	record.narrative_accepted=false; check(Mechanics.project_checks(world,entries).is_empty(),"unaccepted absent"); record.narrative_accepted=true
	var quiet := {"narrative_accepted":true,"accepted_turn_index":0,"player_text":"a","narrative":"b","reason":"quiet"}
	world.expansion_runtime["public_d20_no_check_actions"]=[quiet]
	check(Mechanics.project_checks(world,entries).is_empty() and Mechanics.project(world,entries).is_empty(),"conflicting CHECK/NO_CHECK fails soft")
	world.expansion_runtime.public_d20_checks=[]
	check(Mechanics.project_checks(world,entries).is_empty() and Mechanics.project(world,entries).contains("NO_CHECK"),"quiet durable truth is context only")
