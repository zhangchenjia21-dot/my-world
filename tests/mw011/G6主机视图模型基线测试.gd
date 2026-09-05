extends SceneTree

## MW-011 G6 RPG Host ViewModel Baseline focused proof。
## 真实 FinalCreate Game + real Shell + real SQLite：ViewModel（presentation-only）
## → Player Host / World Surface（概览/存档有界导航）真实消费。
## production 架构：Runtime projection → MW-009 disclosure 边界 → ViewModel → UI。
## 不虚构 HP/位置/物品/关系/阵营/任务；隐藏 truth 不得进入 ViewModel 或可见 Host。
## Provider 全部走桩；real Provider calls = 0。

const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const RPGViewModel := preload("res://src/rpg视图模型/L3_外交层/RPG主机视图模型公开接口.gd")
const ViewModelDevice := preload("res://src/rpg视图模型/L1_器件层/RPG主机视图模型.gd")
const WorldTurnRules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")
const GenericStub := preload("res://tests/g4_07a/首次开场桩适配器.gd")
const SemanticStub := preload("res://tests/g5_01/世界回合语义桩适配器.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

const PLAYER_FACT := "粮仓存量可支两月。"
const NPC_ONLY_FACT := "孙权知晓密使行程安排。"

var _failures := 0
var _root := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("mw011") < 0:
		_fail("必须提供 task-owned --root，且路径包含 mw011")
		return _finish()
	DirAccess.make_dir_recursive_absolute(_root)
	_test_view_model_device()
	await _test_shell_integration()
	_finish()


## Part 1：设备级确定性/边界（不含 Shell）。
func _test_view_model_device() -> void:
	var player_safe := {
		"success": true, "player_display_name": "刘备", "player_profile_name": "208 人物起点",
		"world_display_name": "汉末三国：天下未定", "world_entry_name": "208｜赤壁前夕",
		"known_facts": ["已知事实甲。"],
	}
	var entries: Array = [
		{"turn_index": 0, "player_text": "", "gm_text": "开场。"},
		{"turn_index": 1, "player_text": "行动一。", "gm_text": "叙事一。"},
		{"turn_index": 2, "player_text": "行动二。", "gm_text": "叙事二。"},
		{"turn_index": 3, "player_text": "行动三。", "gm_text": "叙事三。"},
		{"turn_index": 4, "player_text": "行动四。", "gm_text": "叙事四。"},
		{"turn_index": 5, "player_text": "行动五。", "gm_text": "叙事五。"},
	]
	var model: Dictionary = ViewModelDevice.build(player_safe, entries)
	_check(String(model.recent_actions[0]) == "行动二。" and (model.recent_actions as Array).size() == 4, "recent actions bounded to latest 4, chronological")
	_check(int(model.player_turn_count) == 5, "player turn count excludes GM-only opening")
	_check((model.known_facts as Array) == ["已知事实甲。"], "known facts pass through the MW-009 boundary unchanged")
	var empty_model: Dictionary = ViewModelDevice.build({"success": false}, [])
	_check(not empty_model.success and (empty_model.recent_actions as Array).is_empty() and int(empty_model.player_turn_count) == 0, "fail-closed input yields safe empty view model")
	var fabricated: Dictionary = ViewModelDevice.build(player_safe, entries)
	_check(not fabricated.has("hp") and not fabricated.has("location") and not fabricated.has("inventory") and not fabricated.has("faction") and not fabricated.has("quest"), "no fabricated RPG domain state keys")


## Part 2：真实 Shell 集成（激活 → live 更新 → Save 导航 → reopen → Restore → 响应式）。
func _test_shell_integration() -> void:
	var fixture := Fixture.new()
	fixture.reset_directory(_root)
	var installed: Dictionary = fixture.install_packages(_root.path_join("source-library"), [
		{"type": "world", "path": "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定"},
		{"type": "character", "path": "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/刘备"},
		{"type": "character", "path": "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/孙权"},
	])
	if not installed.success:
		_fail("real Source install")
		return _finish()
	var library: RefCounted = installed.library
	var creation := Creation.new(library)
	creation.select_world(fixture.find_generation(installed.installed, "world.han_end.unsettled_realm"))
	creation.select_entry("t0-208-red-cliffs-eve")
	creation.confirm_expansion_none()
	creation.select_player(fixture.find_generation(installed.installed, "character.han_end.liu_bei"))
	creation.set_guaranteed_npc(fixture.find_generation(installed.installed, "character.han_end.sun_quan"), true)
	creation.set_settings("MW-011", "Light", "")
	var created: Dictionary = FinalCreate.new(library, _root.path_join("creation"), _root.path_join("library"), _root.path_join("games")).create_or_resume("mw011-baseline", creation.composition_snapshot())
	if not created.success:
		_fail("Final Create | %s" % JSON.stringify(created))
		return _finish()
	var runtime: RefCounted = Runtime.new()
	_check(runtime.open_existing_game(String(created.database_path)).success, "real Game opens")

	var opening_stub := GenericStub.new()
	var narrative_stub := GenericStub.new()
	var semantic_stub := SemanticStub.new()
	root.size = Vector2i(1600, 900)
	await process_frame
	var inst: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	inst.session_runtime = runtime
	inst.test_opening_adapter_override = opening_stub
	inst.test_world_turn_adapter_override = semantic_stub
	root.add_child(inst)
	await process_frame
	await process_frame
	opening_stub.simulate_delta("建安十三年秋，大军压境。")
	opening_stub.simulate_completed()
	await process_frame
	_check(runtime.conversation.get_durable_accepted_entries().size() == 1, "GM opening accepted")

	# 1 fresh Game：ViewModel 驱动的身份/世界上下文/空态
	var view: Node = inst.get_node("%NarrativeHost")
	var player_text := _panel_text(inst, true)
	var world_text := _panel_text(inst, false)
	_check(player_text.contains("刘备") and player_text.contains("208 人物起点"), "1 Player Host renders identity/profile via ViewModel")
	_check(player_text.contains("世界：汉末三国：天下未定 · 208｜赤壁前夕"), "1 Player Host carries safe World/Entry context")
	_check(player_text.contains("最近行动") and player_text.contains("尚无已完成的行动。"), "1 recent actions quiet empty state before any turn")
	_check(player_text.contains("已进行 0 个玩家回合"), "3 player-turn count excludes GM-only Opening")
	_check(world_text.contains("汉末三国：天下未定") and world_text.contains("208｜赤壁前夕") and world_text.contains("主角所知") and world_text.contains("尚无新的已知事实。"), "4 World Overview is the default content")
	_check(inst.save_surface.visible == false and not inst.get_node("%SaveNameInput").is_visible_in_tree(), "4 Save controls not part of the default Overview hierarchy")
	_check(inst.world_nav.visible == true and inst.overview_tab.button_pressed and not inst.save_tab.button_pressed, "4 bounded navigation defaults to Overview")

	# 6 Save 表面：既有 G3 控件功能保持（经 UI 创建真实 Save，同时作为 Restore 目标）
	inst.save_tab.button_pressed = true
	await process_frame
	_check(inst.save_surface.visible and inst.save_tab.button_pressed and not inst.overview_tab.button_pressed, "5 switching to Save exposes the existing Save surface")
	var input_node: LineEdit = inst.get_node("%SaveNameInput")
	_check(not _world_body_visible(inst) and inst.get_node("%SaveNameInput").is_visible_in_tree(), "5 Overview content hidden while on Save surface")
	var save_input: LineEdit = inst.get_node("%SaveNameInput")
	save_input.text = "MW011分岔存档"
	inst.get_node("%CreateSaveButton").pressed.emit()
	await process_frame
	var save_listed: Dictionary = runtime.list_save_points()
	_check(save_listed.success and (save_listed.save_points as Array).size() == 1, "6 Save creation through the existing G3 owner works inside the Save surface")
	_check(inst.get_node("%LoadSaveButton").disabled == false, "6 load selector refreshed and load available")
	inst.overview_tab.button_pressed = true
	await process_frame
	_check(_world_body_visible(inst) and not inst.save_surface.visible, "5 switching back to Overview restores world content")

	# 2 两个 accepted Player turns → recent actions live 更新（无 reopen）
	_swap_view_adapter(inst, narrative_stub)
	_send(view, "我巡视粮草。")
	narrative_stub.simulate_delta("你巡视粮仓，账目清楚。")
	narrative_stub.simulate_completed()
	await process_frame
	await process_frame
	semantic_stub.simulate_delta(JSON.stringify({"changes": ["营中粮草盘点完毕。"]}))
	semantic_stub.simulate_completed()
	await process_frame
	await process_frame
	player_text = _panel_text(inst, true)
	_check(player_text.contains("• 我巡视粮草。") and player_text.contains("已进行 1 个玩家回合"), "2 first accepted Player action appears live without reopen")
	_send(view, "我回帐休息。")
	narrative_stub.simulate_delta("你回帐安歇。")
	narrative_stub.simulate_completed()
	await process_frame
	await process_frame
	semantic_stub.simulate_delta(JSON.stringify({"changes": [], "knowledge_events": [{"knower_id": String((runtime.world_state.player_character as Dictionary).local_character_id), "fact": PLAYER_FACT, "basis": "witnessed"}]}))
	semantic_stub.simulate_completed()
	await process_frame
	await process_frame
	player_text = _panel_text(inst, true)
	_check(player_text.contains("• 我巡视粮草。") and player_text.contains("• 我回帐休息。") and player_text.contains("已进行 2 个玩家回合"), "2 recent actions update in order after 2+ turns")
	# 7 主角 knowledge → Overview 显示；原始 semantic consequence 不显示
	world_text = _panel_text(inst, false)
	_check(world_text.contains("• %s" % PLAYER_FACT), "7 Player-known fact appears after normal knowledge materialization")
	_check(not world_text.contains("营中粮草盘点完毕。"), "8 raw semantic consequence stays out of World Overview")

	# 8 隐藏 truth：NPC knowledge / Agency / Evolution 注入后不得进入 ViewModel 或 Host
	var sun_id := String((runtime.world_state.guaranteed_npcs[0] as Dictionary).local_character_id)
	var turn2_gm := String((runtime.conversation.get_durable_accepted_entries() as Array)[2].gm_text)
	var turn2_hash := WorldTurnRules.gm_sha256(turn2_gm)
	var npc_record := WorldTurnRules.build_knowledge_record(String(runtime.game_id), 2, turn2_gm, [{"knower_id": sun_id, "fact": NPC_ONLY_FACT, "basis": "participated"}], "2026-09-06T00:00:00Z")
	var npc_candidate := WorldTurnRules.build_world_candidate_with_knowledge(runtime.world_state, {}, npc_record)
	_check(runtime.commit_world_mutation_durably("mw011-npc-knowledge", "mw011-npc-knowledge-node", npc_candidate).success, "NPC-only knowledge commits hidden truth")
	var cycle := WorldTurnRules.build_agency_cycle(String(runtime.game_id), 2, turn2_gm, String(runtime.active_head_id), "2026-09-06T00:00:00Z")
	var action := WorldTurnRules.build_agency_action(String(runtime.game_id), String(cycle.agency_cycle_id), sun_id, "部署江防", "孙权密令水军加固船阵。", ["船阵加固完毕。"], "2026-09-06T00:00:00Z")
	var agency_candidate := WorldTurnRules.build_agency_candidate(runtime.world_state, cycle, action)
	var agency_ids := WorldTurnRules.agency_action_identities(String(runtime.game_id), String(cycle.agency_cycle_id), sun_id)
	runtime.commit_world_mutation_durably(String(agency_ids.mutation_id), String(agency_ids.node_id), agency_candidate)
	var evolution := WorldTurnRules.build_world_evolution_event(String(runtime.game_id), 2, turn2_hash, String(runtime.active_head_id), "江面大雾弥漫。", ["大雾至清晨。"], "2026-09-06T00:00:00Z")
	var evolution_candidate := WorldTurnRules.build_world_candidate_with_evolution(runtime.world_state, evolution)
	var evolution_ids := WorldTurnRules.world_evolution_identities(String(runtime.game_id), 2, turn2_hash, String(runtime.active_head_id))
	runtime.commit_world_mutation_durably(String(evolution_ids.mutation_id), String(evolution_ids.node_id), evolution_candidate)
	var view_model: Dictionary = RPGViewModel.new().build_from_runtime(runtime)
	var vm_serialized := JSON.stringify(view_model)
	_check(not vm_serialized.contains(NPC_ONLY_FACT) and not vm_serialized.contains("孙权密令水军加固船阵。") and not vm_serialized.contains("江面大雾弥漫。"), "8 NPC knowledge / agency / evolution absent from ViewModel")
	_check(not vm_serialized.contains("local_character_id") and not vm_serialized.contains("character.han_end") and not vm_serialized.contains("58966f73") and not vm_serialized.contains("gm_instructions") and not vm_serialized.contains("literary"), "11 no internal IDs/fingerprints/instructions/style material in ViewModel")
	_check(not _panel_text(inst, true).contains(NPC_ONLY_FACT) and not _panel_text(inst, false).contains(NPC_ONLY_FACT), "8 hidden truth stays out of visible Hosts")

	# 9 close/reopen：ViewModel 重建一致
	var before_close: Dictionary = RPGViewModel.new().build_from_runtime(runtime)
	inst.queue_free()
	await process_frame
	runtime.close()
	var reopened := Runtime.new()
	_check(reopened.open_existing_game(String(created.database_path)).success, "reopen existing Game")
	var after_reopen: Dictionary = RPGViewModel.new().build_from_runtime(reopened)
	_check(after_reopen == before_close, "9 Save/reopen reconstructs the same current ViewModel")

	# 10 Restore 到 UI 建立的分岔存档 → recent actions / knowledge 回退
	var restored: Dictionary = reopened.restore_save_point(String(save_listed.save_points[0].save_id))
	_check(restored.success, "Restore to the UI-created Save succeeds")
	var inst2: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	inst2.session_runtime = reopened
	inst2.test_opening_adapter_override = GenericStub.new()
	inst2.test_world_turn_adapter_override = SemanticStub.new()
	root.add_child(inst2)
	await process_frame
	await process_frame
	player_text = _panel_text(inst2, true)
	world_text = _panel_text(inst2, false)
	_check(player_text.contains("尚无已完成的行动。") and player_text.contains("已进行 0 个玩家回合"), "10 restored-away recent actions disappear after Restore")
	_check(world_text.contains("尚无新的已知事实。") and not world_text.contains(PLAYER_FACT), "10 restored-away known facts disappear after Restore")

	# 15 响应式：窄窗口 toggle 仍可用（World/Player 折叠行为不变）
	root.size = Vector2i(900, 600)
	await process_frame
	await process_frame
	_check(inst2.get_node("%WorldToggle").visible, "15 narrow width shows World toggle")
	root.size = Vector2i(1600, 900)
	await process_frame
	await process_frame
	_check(not inst2.get_node("%WorldToggle").visible, "15 wide width hides World toggle")
	inst2.queue_free()
	reopened.close()
	_finish()
	return


func _world_body_visible(inst: Node) -> bool:
	var body: Node = inst._world_panel_body
	return body != null and is_instance_valid(body) and body.visible


func _swap_view_adapter(inst: Node, stub: Node) -> void:
	var view: Node = inst.get_node("%NarrativeHost")
	var real_adapter: Node = view.adapter
	real_adapter.text_delta.disconnect(view._on_text_delta)
	real_adapter.completed.disconnect(view._on_completed)
	real_adapter.cancelled.disconnect(view._on_cancelled)
	real_adapter.failed.disconnect(view._on_failed)
	view.adapter = stub
	inst.add_child(stub)
	stub.text_delta.connect(view._on_text_delta)
	stub.completed.connect(view._on_completed)
	stub.cancelled.connect(view._on_cancelled)
	stub.failed.connect(view._on_failed)


func _send(view: Node, text: String) -> void:
	view.player_input.text = text
	view.get_node("%SendButton").pressed.emit()


func _panel_text(inst: Node, player_panel: bool) -> String:
	var host_path := "Margin/Layout/HostLayout/PlayerPanelHost/PlayerPanelMargin/PlayerPanelColumn" if player_panel else "Margin/Layout/HostLayout/WorldSurfaceHost/WorldPanelMargin/WorldPanelColumn"
	var column: VBoxContainer = inst.get_node(NodePath(host_path))
	var parts := PackedStringArray()
	for child: Node in column.get_children():
		parts.append(child.text if child is Label else "")
		for grandchild: Node in child.get_children():
			parts.append(grandchild.text if grandchild is Label else "")
			for great_grandchild: Node in grandchild.get_children():
				parts.append(great_grandchild.text if great_grandchild is Label else "")
	return "\n".join(parts)


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("MW-011 PASS | %s" % label)
	else:
		_failures += 1
		push_error("MW-011 FAIL | %s" % label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("MW-011 FAIL | %s" % label)


func _finish() -> void:
	print("MW-011 BASELINE | done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)
