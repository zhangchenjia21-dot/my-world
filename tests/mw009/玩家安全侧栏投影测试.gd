extends SceneTree

## MW-009 Player-Safe Runtime Side Panels focused proof。
## 真实 Final Create 冻结 Game + 当前游戏会话运行时 + 真实 main.tscn Shell 侧栏消费。
## 证明 disclosure/currentness：主角身份与主角所知进入 UI；NPC 私知、原始 world
## consequences、Agency、World Evolution、内部 ID/fingerprint/Primer 全部不进入投影。
## Provider 全部走桩；real Provider calls = 0。

const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const PlayerSafe := preload("res://src/玩家安全投影/L3_外交层/玩家安全投影公开接口.gd")
const Device := preload("res://src/玩家安全投影/L1_器件层/玩家安全投影器.gd")
const WorldTurnRules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")
const SemanticStub := preload("res://tests/g5_01/世界回合语义桩适配器.gd")
const WorldTurn := preload("res://src/世界回合/L3_外交层/世界回合公开接口.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

const FACT_A := "粮仓存粮仅支三月。"
const FACT_B_NPC := "NPC 私知：守将已暗中通敌。"
const CHANGE_C := "豪户囤粮推高市价，县吏已呈报郡府。"
const FACT_F := "主角亲见粮价因囤粮而上涨。"

var _failures := 0
var _root := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("mw009") < 0:
		_fail("必须提供 task-owned --root，且路径包含 mw009")
		return _finish()
	DirAccess.make_dir_recursive_absolute(_root)
	await _test_device_with_real_runtime()
	await _test_shell_consumer_lifecycle()
	_finish()


## Part 1：真实 Runtime 结构上的投影设备证明（disclosure/currentness/bounds/stale/reopen）。
func _test_device_with_real_runtime() -> void:
	var case_root := _root.path_join("device")
	var fixture := Fixture.new()
	fixture.reset_directory(case_root)
	var created := _create_game(fixture, case_root, "mw009-device")
	if created.runtime == null:
		return _finish()
	var runtime: RefCounted = created.runtime
	var player_id := String(runtime.world_state.player_character.local_character_id)
	var npc_id := String((runtime.world_state.guaranteed_npcs[0] as Dictionary).local_character_id)
	var projector := PlayerSafe.new()

	# 1 身份：安全字段精确、无内部材料
	var projected: Dictionary = projector.project_session(runtime)
	_check(projected.success and String(projected.player_display_name) == String(created.player_name), "frozen Game projects safe Player display name")
	_check(String(projected.player_profile_name) == String(created.profile_name) and not String(projected.player_profile_name).is_empty(), "frozen Game projects safe selected profile name")
	_check(String(projected.world_display_name) == String(created.world_name) and String(projected.world_entry_name) == String(created.entry_name), "frozen Game projects safe World/Entry names")
	var serialized := JSON.stringify(projected)
	_check(not serialized.contains("character.han_end") and not serialized.contains("58966f73") and not serialized.contains(player_id) and not serialized.contains("local_character_id") and not serialized.contains("gm_instructions") and not serialized.contains("literary"),
		"projection object carries no internal IDs/fingerprints/instructions/Primer")

	# 开场 + 主角行动，随后 semantic lane 提交主角/NPC knowledge
	_accept_opening(runtime)
	_accept_turn(runtime, "我在粮仓前驻足。", "仓吏禀报：粮秣仅支三月，仓储见底在即。")
	var stub := SemanticStub.new()
	var worker: Node = WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	worker.consider_latest_accepted_turn()
	await process_frame
	stub.simulate_delta(JSON.stringify({"changes": [], "knowledge_events": [
		{"knower_id": player_id, "fact": FACT_A, "basis": "witnessed"},
		{"knower_id": npc_id, "fact": FACT_B_NPC, "basis": "told"},
	]}))
	stub.simulate_completed()
	await process_frame
	_check(worker.last_result.status == "committed", "knowledge record commits through production semantic seam")
	projected = projector.project_session(runtime)
	_check((projected.known_facts as Array) == [FACT_A], "2 valid Player knowledge fact A displays; 3 NPC-only fact B does not")

	# 4 semantic 原始后果 C 不展示
	_accept_turn(runtime, "我打听市价。", "市面喧哗，粮价一日三变。")
	await process_frame
	stub.simulate_delta(JSON.stringify({"changes": [CHANGE_C]}))
	stub.simulate_completed()
	await process_frame
	projected = projector.project_session(runtime)
	_check(not (projected.known_facts as Array).has(CHANGE_C) and (projected.known_facts as Array).has(FACT_A), "4 raw semantic consequence C does not display")

	# 5/6 Agency 行动 D 与 World Evolution 事件 E 不展示（即使刷新发生）
	var turn2_gm := String((runtime.conversation.get_durable_accepted_entries() as Array)[2].gm_text)
	var turn2_hash := WorldTurnRules.gm_sha256(turn2_gm)
	var cycle := WorldTurnRules.build_agency_cycle(String(runtime.game_id), 2, turn2_gm, String(runtime.active_head_id), "2026-09-05T00:00:00Z")
	var action := WorldTurnRules.build_agency_action(String(runtime.game_id), String(cycle.agency_cycle_id), npc_id, "巡查粮仓", "仓曹私下清点存粮。", ["粮仓戒备提升"], "2026-09-05T00:00:00Z")
	var agency_candidate := WorldTurnRules.build_agency_candidate(runtime.world_state, cycle, action)
	var agency_ids := WorldTurnRules.agency_action_identities(String(runtime.game_id), String(cycle.agency_cycle_id), npc_id)
	_check(runtime.commit_world_mutation_durably(String(agency_ids.mutation_id), String(agency_ids.node_id), agency_candidate).success, "5 agency action D commits hidden truth")
	var evolution := WorldTurnRules.build_world_evolution_event(String(runtime.game_id), 2, turn2_hash, String(runtime.active_head_id), "郡府下令核查粮价。", ["粮价文书下发"], "2026-09-05T00:00:00Z")
	var evolution_candidate := WorldTurnRules.build_world_candidate_with_evolution(runtime.world_state, evolution)
	var evolution_ids := WorldTurnRules.world_evolution_identities(String(runtime.game_id), 2, turn2_hash, String(runtime.active_head_id))
	_check(runtime.commit_world_mutation_durably(String(evolution_ids.mutation_id), String(evolution_ids.node_id), evolution_candidate).success, "6 world evolution event E commits hidden truth")
	projected = projector.project_session(runtime)
	_check(not (projected.known_facts as Array).has("仓曹私下清点存粮。") and not (projected.known_facts as Array).has("郡府下令核查粮价。"), "5/6 hidden Agency/Evolution truth stays out of projection after refresh")

	# 7 knowledge 明确携带 C 的实质 → 经 knowledge seam 展示
	_accept_turn(runtime, "我亲自查看粮价。", "你亲眼见到粮价因囤粮而上涨。")
	await process_frame
	stub.simulate_delta(JSON.stringify({"changes": [], "knowledge_events": [{"knower_id": player_id, "fact": FACT_F, "basis": "discovered"}]}))
	stub.simulate_completed()
	await process_frame
	projected = projector.project_session(runtime)
	_check((projected.known_facts as Array).has(FACT_F), "7 knowledge carrying substance of C displays through the knowledge seam")

	worker.shutdown()
	worker.queue_free()
	await process_frame

	# bounds + dedup：10 个新 turn 的主角 knowledge（含重复对）直接经生产 commit seam 注入
	for index: int in range(4, 14):
		var gm_text := "叙事 %d。" % index
		_accept_turn(runtime, "行动 %d。" % index, gm_text)
		var fact := "重复事实。" if index == 12 else "事实 %d。" % index
		_inject_knowledge(runtime, index, gm_text, player_id, fact)
	var bounded: Array = projector.project_session(runtime).known_facts
	_check((bounded as Array).size() == Device.MAX_KNOWN_FACTS, "known facts bounded to %d" % Device.MAX_KNOWN_FACTS)
	_check((bounded as Array).count("重复事实。") == 1 and (bounded as Array)[-1] == "事实 13。", "duplicate fact kept once at newest occurrence; chronological order ends with newest")

	# 8 stale：regenerate latest turn 使其 hash 改变 → 该 turn 的 knowledge 不再展示
	_check((bounded as Array).has("事实 13。"), "pre-regenerate fact 13 displayed")
	runtime.conversation.retry_or_regenerate_latest()
	runtime.conversation.append_delta("完全不同的新叙事内容。")
	_check(runtime.complete_active_generation_durably().success, "latest turn regenerated with new hash")
	projected = projector.project_session(runtime)
	_check(not (projected.known_facts as Array).has("事实 13。"), "8 stale hash-mismatched knowledge excluded after replacement")

	# 10 reopen：durable state reconstructs the same safe projection
	var before_close: Dictionary = projector.project_session(runtime)
	runtime.close()
	var reopened := Runtime.new()
	_check(reopened.open_existing_game(String(created.database_path)).success, "reopen existing Game")
	var reopened_projection: Dictionary = projector.project_session(reopened)
	_check(reopened_projection == before_close, "10 reopen reconstructs the same safe projection")
	reopened.close()


## Part 2：真实 Shell 侧栏消费（激活 → live semantic 刷新 → Restore 回退）。
func _test_shell_consumer_lifecycle() -> void:
	var case_root := _root.path_join("shell")
	var fixture := Fixture.new()
	fixture.reset_directory(case_root)
	var created := _create_game(fixture, case_root, "mw009-shell")
	if created.runtime == null:
		return _finish()
	var runtime: RefCounted = created.runtime
	_accept_opening(runtime)
	_accept_turn(runtime, "我在粮仓前驻足。", "仓吏禀报：粮秣仅支三月。")
	var save_before_knowledge: Dictionary = runtime.create_save_point("已知事实前")
	_check(save_before_knowledge.success, "Save captured before Player knowledge")

	var stub := SemanticStub.new()
	var inst: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	inst.session_runtime = runtime
	inst.test_world_turn_adapter_override = stub
	root.add_child(inst)
	await process_frame
	await process_frame

	var player_text := _panel_text(inst, true)
	var world_text := _panel_text(inst, false)
	var player_id := String(runtime.world_state.player_character.local_character_id)
	_check(player_text.contains(String(created.player_name)) and player_text.contains(String(created.profile_name)), "Shell player panel shows safe identity")
	_check(world_text.contains(String(created.world_name)) and world_text.contains(String(created.entry_name)), "Shell world panel shows safe World/Entry identity")
	_check(world_text.contains("主角所知") and world_text.contains("尚无新的已知事实。"), "quiet empty state before any Player knowledge")
	var all_panels := player_text + world_text
	_check(not all_panels.contains(player_id) and not all_panels.contains("character.han_end") and not all_panels.contains("58966f73") and not all_panels.contains("gm_instructions") and not all_panels.contains("literary"),
		"12 side panels expose no internal IDs/fingerprints/instructions/Primer")

	# 9 semantic commit 主角 knowledge → 侧栏无 reopen 实时刷新
	inst.world_turn_runtime.consider_latest_accepted_turn()
	await process_frame
	stub.simulate_delta(JSON.stringify({"changes": [], "knowledge_events": [{"knower_id": player_id, "fact": FACT_A, "basis": "witnessed"}]}))
	stub.simulate_completed()
	await process_frame
	await process_frame
	world_text = _panel_text(inst, false)
	_check(world_text.contains("• %s" % FACT_A), "9 semantic terminal refreshes panel live without reopen")
	_check(not world_text.contains("尚无新的已知事实。"), "empty state replaced once facts exist")

	# 11 Restore 到已知事实前 → restored-away 事实消失
	var restored: Dictionary = runtime.restore_save_point(String(save_before_knowledge.save_id))
	_check(restored.success, "Restore to pre-knowledge Save succeeds")
	await process_frame
	world_text = _panel_text(inst, false)
	_check(not world_text.contains(FACT_A) and world_text.contains("尚无新的已知事实。"), "11 restored-away fact removed from panel after Restore")

	# 12 fail-closed：无效投影输入产生安全空展示，绝不倾倒 raw world state
	var broken: Dictionary = Device.project({"player_character": 5, "world": {"semantic_sections": "ALL THE SECRET SECTIONS"}}, [])
	_check(not broken.success and String(broken.world_display_name).is_empty() and (broken.known_facts as Array).is_empty(), "12 invalid projection input fails closed to safe/empty display")
	_check(not JSON.stringify(broken).contains("ALL THE SECRET SECTIONS"), "12 raw world state never dumped through projection")
	_check(Device.project({}, []).success == false, "legacy/absent setup fails closed")
	inst.queue_free()
	runtime.close()


func _create_game(fixture: Fixture, case_root: String, creation_id: String) -> Dictionary:
	var installed: Dictionary = fixture.install_packages(case_root.path_join("source-library"), [
		{"type": "world", "path": "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定"},
		{"type": "character", "path": "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/刘备"},
		{"type": "character", "path": "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/孙权"},
	])
	if not installed.success:
		_fail("real Source assets install")
		return {"runtime": null}
	var library: RefCounted = installed.library
	var creation := Creation.new(library)
	creation.select_world(fixture.find_generation(installed.installed, "world.han_end.unsettled_realm"))
	creation.select_entry("t0-208-red-cliffs-eve")
	creation.confirm_expansion_none()
	creation.select_player(fixture.find_generation(installed.installed, "character.han_end.liu_bei"))
	creation.set_guaranteed_npc(fixture.find_generation(installed.installed, "character.han_end.sun_quan"), true)
	creation.set_settings("MW-009", "Light", "")
	var created: Dictionary = FinalCreate.new(library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games")).create_or_resume(creation_id, creation.composition_snapshot())
	if not created.success:
		_fail("Final Create | %s" % JSON.stringify(created))
		return {"runtime": null}
	var runtime := Runtime.new()
	if not runtime.open_existing_game(String(created.database_path)).success:
		_fail("runtime open")
		return {"runtime": null}
	var world_projection := (runtime.world_state.world as Dictionary).source_projection as Dictionary
	var player_projection := (runtime.world_state.player_character as Dictionary).source_projection as Dictionary
	var profile := player_projection.get("selected_profile", {}) as Dictionary
	return {
		"runtime": runtime,
		"database_path": String(created.database_path),
		"player_name": String(player_projection.display_name),
		"profile_name": String(profile.get("display_name", "")),
		"world_name": String(world_projection.display_name),
		"entry_name": String((world_projection.get("selected_entry", {}) as Dictionary).get("display_name", "")),
	}


func _accept_opening(runtime: RefCounted) -> void:
	runtime.conversation.begin_gm_opening()
	runtime.conversation.append_delta("汉末建安十三年，风云聚于赤壁。")
	_check(runtime.complete_active_generation_durably().success, "opening accepted durably")


func _accept_turn(runtime: RefCounted, player: String, gm: String) -> void:
	runtime.conversation.begin_turn(player)
	runtime.conversation.append_delta(gm)
	_check(runtime.complete_active_generation_durably().success, "turn accepted durably: %s" % player)


## 与 semantic lane 完全相同的 commit seam（identities + knowledge record + candidate）。
func _inject_knowledge(runtime: RefCounted, turn_index: int, gm_text: String, knower_id: String, fact: String) -> void:
	var identities := WorldTurnRules.identities(String(runtime.game_id), turn_index, WorldTurnRules.gm_sha256(gm_text))
	var record := WorldTurnRules.build_knowledge_record(String(runtime.game_id), turn_index, gm_text, [{"knower_id": knower_id, "fact": fact, "basis": "witnessed"}], "2026-09-05T00:00:00Z")
	var candidate := WorldTurnRules.build_world_candidate_with_knowledge(runtime.world_state, {}, record)
	_check(runtime.commit_world_mutation_durably(String(identities.mutation_id), String(identities.node_id), candidate).success, "knowledge injected via production commit seam (turn %d)" % turn_index)


func _panel_text(inst: Node, player_panel: bool) -> String:
	var host_path := "Margin/Layout/HostLayout/PlayerPanelHost/PlayerPanelMargin/PlayerPanelColumn" if player_panel else "Margin/Layout/HostLayout/WorldSurfaceHost/WorldPanelMargin/WorldPanelColumn"
	var column: VBoxContainer = inst.get_node(NodePath(host_path))
	var parts := PackedStringArray()
	for child: Node in column.get_children():
		parts.append(child.text if child is Label else "")
		for grandchild: Node in child.get_children():
			parts.append(grandchild.text if grandchild is Label else "")
	return "\n".join(parts)


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("MW-009 PASS | %s" % label)
	else:
		_failures += 1
		push_error("MW-009 FAIL | %s" % label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("MW-009 FAIL | %s" % label)


func _finish() -> void:
	print("MW-009 FOCUSED | done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)
