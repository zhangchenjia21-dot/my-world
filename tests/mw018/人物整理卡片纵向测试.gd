extends "res://tests/mw017/人物身份桥屏障纵向测试.gd"

const PeopleSafe := preload("res://src/信息整理/L3_外交层/人物投影公开接口.gd")
const PeopleFold := preload("res://src/信息整理/L1_器件层/人物认知投影器.gd")
const Contract := preload("res://src/信息整理/L0_公理层/信息整理契约.gd")
const Parser := preload("res://src/信息整理/L1_器件层/信息整理响应解析器.gd")
var visual := false

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="):
			directory = arg.trim_prefix("--root=")
		if arg == "--visual":
			visual = true
	if not directory.contains("mw018"):
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(directory)
	runtime = Runtime.new()
	check(runtime.open_current_game(directory.path_join("people.sqlite")).success, "isolated real SQLite")
	check(runtime.commit_world_mutation_durably("setup", "setup-node", setup()).success, "task-owned same-name actors")
	compose()
	await frames()
	complete(curation, {"character": Safe.project_session(runtime).character, "experiences": []})
	await frames()
	var initial := Safe.project_session(runtime)
	check(not JSON.stringify(curation.requests[0]).contains("people_evidence"), "initial request People-free")
	runtime.conversation.begin_gm_opening()
	runtime.conversation.append_delta("陈安在门外等候。")
	check(runtime.complete_active_generation_durably().success, "opening accepted")
	await frames()
	check(semantic.requests.is_empty() and curation.requests.size() == 1 and PeopleSafe.project_session(runtime).is_empty(), "opening no People processing")
	var before: Dictionary = runtime.create_save_point("before")
	# 真正旧结构 + 原 ID；后续新变体必须接在该父链后，不迁移旧 ID。
	var old: Dictionary = runtime.world_state.duplicate(true)
	var prefix: String = Contract.prefix_hashes(runtime.conversation.get_durable_accepted_entries())[0]
	var old_id := Contract.record_id(prefix, "", NO_CHANGE)
	old.information_curation.turns["0"] = {"prefix": prefix, "parent": "", "id": old_id, "result": NO_CHANGE}
	check(runtime.commit_world_mutation_durably("legacy", "legacy-node", old).success, "legacy record committed unchanged")
	accept("我向两位陈安问路。", "陈安说他是粮商。另一位陈安说他是守门人。")
	await frames()
	check(semantic.busy and not curation.busy, "same-turn semantic barrier")
	var refs := request_refs(semantic.requests[-1])
	complete(semantic, {"changes": [], "people_bindings": [
		{"actor_ref": refs[0], "gm_span": {"start": 0, "length": 8}},
		{"actor_ref": refs[1], "gm_span": {"start": 12, "length": 2}}]})
	await frames()
	var context := input()
	check(context.people_evidence.size() == 2, "same existing curator receives two bound people")
	var public_refs: Array = context.people_evidence.map(func(e: Dictionary) -> String: return e.actor_ref)
	for e: Dictionary in context.people_evidence:
		check(Contract.keys_exact(e, ["actor_ref", "quote", "gm_span"]), "only quote/span/request ref before first card")
	for canary: String in ["npc-a", "npc-b", "npc-c", "SECRET_PROFILE", "PRIVATE_PLAN", "HIDDEN_EVOLUTION", "stable_npcs", "identity_receipt_id"]:
		check(not JSON.stringify(context).contains(canary), "curator input excludes " + canary)
	var a := person("陈安", "粮商", "愿意指路的本地粮商。")
	var b := person("陈安", "守门人", "在城门值守。")
	complete(curation, answer([{ "actor_ref": public_refs[0], "snapshot": a}, {"actor_ref": public_refs[1], "snapshot": b}]))
	await frames()
	check(semantic.requests.size() == 1 and curation.requests.size() == 2, "one World plus one lived curator, no third call")
	var cards := PeopleSafe.project_session(runtime)
	check(cards == [a, b], "same-name actors remain two distinct cards")
	var records := Contract.current_records(runtime.world_state, runtime.conversation.get_durable_accepted_entries())
	check(records.size() == 2 and records[0].id == old_id, "mixed old/new parent chain preserves historical ID")
	check(runtime.world_state.information_curation.turns["1"].parent == old_id, "new record parents exact old ID")
	check(runtime.world_state.information_curation.turns["1"].identity_receipt_id == Bridge.current_receipt(runtime, 1).id, "record binds exact receipt")
	check(Safe.project_session(runtime) == initial, "Character/Experiences remain unchanged")
	var v1: Dictionary = runtime.create_save_point("v1")
	var snapshot := JSON.stringify(cards)
	var hidden: Dictionary = runtime.world_state.duplicate(true)
	hidden.stable_npcs[0].game_local_material.profile_text = "NEW_HIDDEN_CANARY"
	hidden.living_world.agency_cycles_by_source_turn = {"private": "NEW_PLAN"}
	hidden.living_world.world_evolution_events_by_turn = {"private": "NEW_EVOLUTION"}
	hidden["private_knowledge"] = "NEW_KNOWLEDGE"
	check(runtime.commit_world_mutation_durably("hidden", "hidden-node", hidden).success, "hidden mutations accepted")
	check(JSON.stringify(PeopleSafe.project_session(runtime)) == snapshot, "private actor/Agency/Evolution changes inert")
	accept("我再向粮商请教。", "陈安告诉你，他明早会去渡口。")
	await frames()
	refs = request_refs(semantic.requests[-1])
	complete(semantic, {"changes": [], "people_bindings": [{"actor_ref": refs[0], "gm_span": {"start": 0, "length": 2}}]})
	await frames()
	context = input()
	check(context.people_evidence.size() == 1 and context.people_evidence[0].current_snapshot == a, "only involved actor previous safe snapshot sent")
	check(not JSON.stringify(context).contains("守门人"), "uninvolved card not sent wholesale")
	var a2 := person("陈安", "明早去渡口的粮商", "他愿意明早与你在渡口碰面。")
	a2.details = ["他说雨后小路泥泞，建议天亮后沿河堤步行。", "粮店就在南门内，平日由家人照看。", "这次去渡口是为接货，预计午前返回。", "他熟悉渡口附近的路，愿意带你同行。", "你问起粮价时，他耐心解释了最近的变动。", "他请你先准备好路上的饮水。", "你们约定在河边小亭相见。", "以上是这次交谈中他告诉你的情况。"]
	complete(curation, answer([{ "actor_ref": context.people_evidence[0].actor_ref, "snapshot": a2}]))
	await frames()
	check(PeopleSafe.project_session(runtime) == [a2, b], "full replacement; update keeps first-appearance order and untouched card")
	var v2: Dictionary = runtime.create_save_point("v2")
	# 使用生产 Shell accepted-history signal 验证持久替换当下，而非直接调用 refresh。
	teardown()
	await frames()
	var shell: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	shell.session_runtime = runtime
	shell.test_world_turn_adapter_override = Stub.new()
	shell.test_information_curator_adapter_override = Stub.new()
	shell.test_world_evolution_adapter_override = Stub.new()
	root.add_child(shell)
	await frames()
	shell.people_tab.button_pressed = true
	await frames()
	var labels: Array = []
	for button: Button in shell.world_nav.get_children():
		labels.append(button.text)
	check(shell.world_nav.visible, "five-tab navigation actually visible")
	check(labels == ["概览", "角色", "重要经历", "人物", "事务", "系统", "存档"], "exact seven-tab navigation")
	var body: VBoxContainer = shell._people_panel_body
	check(body.get_child_count() == 2 and body.get_child(0) is PanelContainer, "real card panels")
	for card: Node in body.get_children():
		check(not card.expanded_body.visible and not card.toggle.button_pressed, "every card starts collapsed")
	check(not visible_text(body).contains(a2.relationship), "relationship hidden while collapsed")
	body.get_child(0).toggle.button_pressed = true
	await frames()
	check(body.get_child(0).expanded_body.visible and not body.get_child(1).expanded_body.visible, "expand only selected card")
	check(visible_text(body).contains(a2.relationship), "expanded known relationship visible")
	shell._render_people_surface()
	check(not body.get_child(0).expanded_body.visible, "rebuild collapses all cards")
	var request_count: int = shell.test_information_curator_adapter_override.requests.size()
	root.mode = Window.MODE_WINDOWED
	for dimension: Vector2i in [Vector2i(1600, 900), Vector2i(1280, 720), Vector2i(960, 540)]:
		root.size = dimension
		await frames()
		shell.world_toggle.button_pressed = true
		shell._select_world_surface_mode("people")
		await frames()
		body.get_child(0).toggle.button_pressed = true
		await frames()
		check(shell.world_surface_column.size.x <= shell.world_surface_scroll.size.x + 1, "cards no horizontal overflow " + str(dimension))
		if dimension.x <= 1280:
			check(shell.world_surface_scroll.get_v_scroll_bar().max_value > shell.world_surface_scroll.get_v_scroll_bar().page, "expanded cards scroll " + str(dimension))
		if visual:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(directory.path_join("people-%dx%d.png" % [dimension.x, dimension.y]))
	if visual:
		root.mode = Window.MODE_MAXIMIZED
		await create_timer(0.2).timeout
		shell._render_people_surface()
		await frames()
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(directory.path_join("people-maximized-collapsed.png"))
		body.get_child(0).toggle.button_pressed = true
		await frames()
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(directory.path_join("people-maximized-expanded.png"))
	check(shell.test_information_curator_adapter_override.requests.size() == request_count, "render/toggle/resize zero Provider calls")
	runtime.conversation.retry_or_regenerate_latest()
	check(PeopleSafe.project_session(runtime) == [a2, b], "provisional regeneration retains accepted truth")
	runtime.conversation.append_delta("陈安这次没有告诉你新的消息。")
	check(runtime.complete_active_generation_durably().success, "replacement accepted durably")
	check(PeopleSafe.project_session(runtime) == [a, b], "accepted replacement reverts before curator completes")
	check(not visible_text(body).contains(a2.summary), "Shell immediately removes stale text")
	check(runtime.restore_save_point(v2.save_id).success, "Restore v2")
	check(PeopleSafe.project_session(runtime) == [a2, b], "Restore v2 snapshot")
	check(runtime.restore_save_point(v1.save_id).success, "Restore v1")
	check(PeopleSafe.project_session(runtime) == [a, b], "Restore between versions returns v1")
	check(runtime.restore_save_point(before.save_id).success, "Restore before creation")
	check(PeopleSafe.project_session(runtime).is_empty(), "Restore before creation has no future card recovery")
	check(runtime.restore_save_point(v2.save_id).success, "Restore for reopen")
	shell._teardown_world_evolution_evaluator()
	shell._teardown_agency_scheduler()
	shell._teardown_world_turn_runtime()
	shell.session_runtime = null
	shell.queue_free()
	await frames()
	runtime.close()
	runtime = Runtime.new()
	check(runtime.open_current_game(directory.path_join("people.sqlite")).success, "reopen current game")
	check(PeopleSafe.project_session(runtime) == [a2, b], "reopen equivalent cards")
	compose()
	await frames()
	check(curation.requests.is_empty() and semantic.requests.is_empty(), "reopen zero calls/no historical backfill")
	# 失败依赖：不清卡，base 整理仍可成功。
	accept("我等候消息。", "没有新的消息。")
	await frames()
	semantic.simulate_failed()
	await frames()
	check(input().people_evidence.is_empty(), "semantic failure gives empty People evidence")
	complete(curation, answer([{ "actor_ref": "npc-a", "snapshot": null}]))
	await frames()
	check(PeopleSafe.project_session(runtime) == [a2, b], "missing evidence does not clear or cross-write")
	# 同一人两个 span refs 的重复操作全部丢弃，同时保留 base。
	accept("我听陈安说话。", "陈安说完，陈安又点头。")
	await frames()
	refs = request_refs(semantic.requests[-1])
	complete(semantic, {"changes": [], "people_bindings": [
		{"actor_ref": refs[0], "gm_span": {"start": 0, "length": 2}},
		{"actor_ref": refs[0], "gm_span": {"start": 5, "length": 2}}]})
	await frames()
	context = input()
	var invalid := answer([{ "actor_ref": context.people_evidence[0].actor_ref, "snapshot": null},
		{ "actor_ref": context.people_evidence[1].actor_ref, "snapshot": a}])
	invalid.experiences = [{"title": "选择留下", "description": "你决定继续学习。"}]
	complete(curation, invalid)
	await frames()
	check(PeopleSafe.project_session(runtime) == [a2, b], "duplicate canonical updates all rejected")
	check(Safe.project_session(runtime).important_experiences.size() == 1, "invalid People does not corrupt valid Experiences")
	# tombstone 与重新出现顺序。
	await update_one(0, null)
	check(PeopleSafe.project_session(runtime) == [b] and runtime.world_state.stable_npcs.size() == 4, "tombstone only removes card, never NPC")
	await update_one(0, a)
	check(PeopleSafe.project_session(runtime) == [b, a], "recreated card gets new first-appearance position")
	# 人物出生在本回合，World mint 与 receipt 后同回合可建卡。
	accept("我问摆渡人姓名。", "沈青说她是摆渡人。")
	await frames()
	complete(semantic, {"changes": [], "new_actor_candidates": [{"candidate_ref": "boat", "display_name": "沈青", "profile_text": "PRIVATE_NEW_PROFILE"}],
		"people_bindings": [{"candidate_ref": "boat", "gm_span": {"start": 0, "length": 2}}]})
	await frames()
	context = input()
	var c := person("沈青", "摆渡人", "她在此经营渡船。")
	check(not JSON.stringify(context).contains("PRIVATE_NEW_PROFILE"), "new actor private material excluded")
	complete(curation, answer([{ "actor_ref": context.people_evidence[0].actor_ref, "snapshot": c}]))
	await frames()
	check(PeopleSafe.project_session(runtime) == [b, a, c], "same-turn minted actor card")
	# 数据篡改只破坏 People 依赖；旧父链以及角色经历仍可投影。
	var current_entries: Array = runtime.conversation.get_durable_accepted_entries()
	var tampered: Dictionary = runtime.world_state.duplicate(true)
	var latest: Dictionary = tampered.information_curation.turns[str(current_entries.size() - 1)]
	latest.identity_receipt_id = "wrong-receipt"
	latest.id = Contract.lived_record_id(latest.prefix, latest.parent, latest.result, latest.identity_receipt_id)
	check(PeopleFold.fold(tampered, runtime.game_id, current_entries).size() == 2, "wrong receipt dependency cannot project new card")
	var missing_actor: Dictionary = runtime.world_state.duplicate(true)
	missing_actor.stable_npcs = missing_actor.stable_npcs.filter(func(actor: Dictionary) -> bool: return actor.local_character_id != "npc-a")
	check(not PeopleFold.fold(missing_actor, runtime.game_id, current_entries).has("npc-a"), "inapplicable actor cannot remain current")
	for dto: Dictionary in PeopleSafe.project_session(runtime):
		check(Contract.keys_exact(dto, ["display_name", "headline", "summary", "relationship", "details"]), "leaf exact five safe fields")
	for token: String in ["local_character_id", "actor_ref", "receipt", "prefix", "information_curation", "PRIVATE", "npc-a"]:
		check(not JSON.stringify(PeopleSafe.project_session(runtime)).contains(token), "leaf excludes " + token)
	contract_checks()
	teardown()
	runtime.close()
	await frames()
	print("MW-018 FOCUSED checks=%d failures=%d" % [checks, failures])
	quit(0 if failures == 0 else 1)

func input() -> Dictionary:
	return JSON.parse_string(curation.requests[-1][1].content)

func person(name: String, headline: String, summary: String) -> Dictionary:
	return {"display_name": name, "headline": headline, "summary": summary,
		"relationship": "曾耐心回应你的询问，目前愿意提供力所能及的帮助。", "details": ["你们已经有过一次交谈。"]}

func answer(updates: Array) -> Dictionary:
	return {"character": null, "experiences": [], "people_updates": updates}

func update_one(ordinal: int, snapshot: Variant) -> void:
	accept("继续交谈", "陈安听你说话。")
	await frames()
	var refs := request_refs(semantic.requests[-1])
	complete(semantic, {"changes": [], "people_bindings": [{"actor_ref": refs[ordinal], "gm_span": {"start": 0, "length": 2}}]})
	await frames()
	complete(curation, answer([{ "actor_ref": input().people_evidence[0].actor_ref, "snapshot": snapshot}]))
	await frames()

func visible_text(node: Node) -> String:
	if node is Control and not node.visible:
		return ""
	var text := ""
	if node is Label or node is Button:
		text = node.text
	for child: Node in node.get_children():
		text += visible_text(child)
	return text

func contract_checks() -> void:
	var a := person("人", "", "")
	var bindings := {"r": "id", "s": "id", "t": "other"}
	for bad: Variant in [null, 7, "bad", {}, [{"actor_ref": "unknown", "snapshot": a}], [{"actor_ref": "r", "snapshot": {}}],
		[{"actor_ref": "r", "snapshot": a, "private": "x"}], [{"actor_ref": "r", "snapshot": a}, {"actor_ref": "s", "snapshot": null}]]:
		var parsed := Parser.parse(JSON.stringify({"character": null, "experiences": [], "people_updates": bad}), true, bindings)
		check(not parsed.is_empty() and parsed.people_updates.is_empty(), "invalid People independent fail-soft")
	var valid := {"actor_ref": "t", "snapshot": a}
	var mixed := Parser.parse(JSON.stringify(answer([{"actor_ref": "r", "snapshot": {}}, valid])), true, bindings)
	check(mixed.people_updates.size() == 1 and mixed.people_updates[0].local_character_id == "other", "malformed entry does not discard valid peer")
	var stale := Parser.parse(JSON.stringify(answer([{"actor_ref": "old-request-r", "snapshot": a}])), true, bindings)
	check(stale.people_updates.is_empty(), "stale request-scoped ref has no authority")
	var too_many: Array = []
	for i: int in range(9):
		too_many.append(valid)
	check(Parser.parse(JSON.stringify(answer(too_many)), true, bindings).people_updates.is_empty(), "over-eight component remains no-op")
	check(Parser.parse(JSON.stringify({"character": {"bad": 1}, "experiences": [], "people_updates": [valid]}), true, bindings).is_empty(), "People does not weaken base validation")
	var result := {"character": null, "experiences": [], "people_updates": []}
	var identity := Contract.lived_record_id("prefix", "parent", result, "receipt")
	check(identity != Contract.lived_record_id("other-prefix", "parent", result, "receipt"), "new ID hashes accepted prefix")
	check(identity != Contract.lived_record_id("prefix", "other-parent", result, "receipt"), "new ID hashes parent")
	check(identity != Contract.lived_record_id("prefix", "parent", result, "other-receipt"), "new ID hashes receipt dependency")
	result.people_updates = [{"local_character_id": "id", "snapshot": null}]
	check(identity != Contract.lived_record_id("prefix", "parent", result, "receipt"), "new ID hashes full result")
	for pair: Array in [["display_name", 64], ["headline", 160], ["summary", 400], ["relationship", 600]]:
		var bounded := a.duplicate(true)
		bounded[pair[0]] = "字".repeat(pair[1])
		check(Contract.person_valid(bounded), "field exact bound " + pair[0])
		bounded[pair[0]] += "字"
		check(not Contract.person_valid(bounded), "field over bound " + pair[0])
	a.details = []
	for i: int in range(8):
		a.details.append("字".repeat(600))
	check(Contract.person_valid(a), "details 8x600 accepted")
	a.details.append("extra")
	check(not Contract.person_valid(a), "details ninth rejected")
	var optional := Parser.parse(JSON.stringify(answer([{"actor_ref": "r", "snapshot": {"display_name": "称呼"}}])), true, bindings)
	check(optional.people_updates[0].snapshot.details.is_empty(), "optional unknown fields normalize to empty")
	check(Parser.parse("not json", true).is_empty(), "global malformed JSON fails whole call")
	check(Parser.parse(JSON.stringify(answer([]))).is_empty(), "initial parser stays People-free")

func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("MW-018 FAIL " + label)
	else:
		print("MW-018 PASS " + label)

func setup() -> Dictionary:
	var world := super.setup()
	world.merge({"schema_version": "game_local_setup.v0.1", "creation_origin": {}, "game": {}, "setup_ancestry": {},
		"guaranteed_npcs": [], "world": {"source_projection": {"display_name": "河畔小城", "selected_entry": {"display_name": "渡口初识"}}}})
	return world
