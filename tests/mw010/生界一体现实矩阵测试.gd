extends SceneTree

## MW-010 G5 Living-World Integrated Reality Matrix —— G5-07 工程一体现实证明。
## 单个真实 durable Game 时间线：real FinalCreate + real Shell + real SQLite +
## deterministic stubs（opening / Public-d20 adjudication / semantic / agency selector+actor /
## world evolution）。production 期望零 diff；real Provider calls = 0。
##
## 场景拓扑（packet §6 / canonical decision §4）：
##   T1 普通 NO_CHECK 回合 → semantic 记录 → Agency quiet（no actors）→ Evolution hold   [A-hold]
##   T2 普通回合 → Agency 独立行动（孙权，玩家未选择）→ Evolution advance                [A-advance/C]
##   T3 风险行动 → Program d20 → Narrative → MW-006 grounding → G5-01 consequence        [D]
##   close/reopen → 全部 truth family 重建 + no-reroll/no-duplicate                      [E]
##   Save S → Path A（后果+知识）→ Restore S → Path B（不同后果）→ currentness 隔离      [B]
##   全程：player-safe 侧栏永不泄露 NPC 秘密 / Agency / Evolution / 原始后果；主角知识才显示。

const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Adjudication := preload("res://src/行动判定/L3_外交层/行动判定公开接口.gd")
const WorldTurnContext := preload("res://src/世界回合/L3_外交层/世界回合上下文公开接口.gd")
const PlayerSafe := preload("res://src/玩家安全投影/L3_外交层/玩家安全投影公开接口.gd")
const GenericStub := preload("res://tests/g4_07a/首次开场桩适配器.gd")
const SemanticStub := preload("res://tests/g5_01/世界回合语义桩适配器.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

const NPC_SECRET_ACTION := "孙权密令水军连夜加固船阵。"
const EVOLUTION_EVENT := "江面大雾弥漫，水军操练受阻。"
const PATH_A_CHANGE := "全军进入备战状态。"
const PATH_B_CHANGE := "密使已连夜渡江赴江东。"
const MECHANICS_CONSEQUENCE := "曹军水寨因夜袭而加强巡江戒备。"
const MECHANICS_KNOWLEDGE := "曹军水寨巡江戒备因夜袭提升。"

class DeterministicRng:
	extends RefCounted
	var values: Array
	var invocation_count := 0
	func _init(faces: Array) -> void:
		values = faces.duplicate()
	func roll_d20() -> int:
		var value := int(values[invocation_count])
		invocation_count += 1
		return value

var _failures := 0
var _root := ""
## Agency scheduler 会在 selector/actor 终态后 queue_free 注入的 adapter override；
## 因此每次机会使用全新 selector stub，actor factory 每次新建并追踪最新实例。
var _actor_stubs: Array = []


func _fresh_selector(inst: Node) -> Node:
	var stub := GenericStub.new()
	inst.agency_scheduler.test_selector_adapter_override = stub
	return stub


func _latest_actor_stub() -> Node:
	return _actor_stubs[-1] as Node


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("mw010") < 0:
		_fail("必须提供 task-owned --root，且路径包含 mw010")
		return _finish()
	DirAccess.make_dir_recursive_absolute(_root)

	# ---- 组合 Game：real FinalCreate + real Shell + 全部确定性 stub ----
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
	var expansion: Dictionary = library.install_expansion_pack("res://tests/fixtures/g4_08m1/判定与检定_公开d20")
	var creation := Creation.new(library)
	creation.select_world(fixture.find_generation(installed.installed, "world.han_end.unsettled_realm"))
	creation.select_entry("t0-208-red-cliffs-eve")
	creation.set_expansion(expansion.generation, true)
	creation.select_player(fixture.find_generation(installed.installed, "character.han_end.liu_bei"))
	creation.set_guaranteed_npc(fixture.find_generation(installed.installed, "character.han_end.sun_quan"), true)
	creation.set_settings("MW-010", "Light", "")
	var created: Dictionary = FinalCreate.new(library, _root.path_join("creation"), _root.path_join("library"), _root.path_join("games")).create_or_resume("mw010-matrix", creation.composition_snapshot())
	if not created.success:
		_fail("Final Create | %s" % JSON.stringify(created))
		return _finish()
	var runtime: RefCounted = Runtime.new()
	_check(runtime.open_existing_game(String(created.database_path)).success, "real Game opens")

	var opening_stub := GenericStub.new()
	var d20_stub := GenericStub.new()
	var semantic_stub := SemanticStub.new()
	var evolution_stub := GenericStub.new()

	var inst: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	inst.session_runtime = runtime
	inst.test_opening_adapter_override = opening_stub
	inst.test_adjudication_adapter_override = d20_stub
	inst.test_adjudication_rng_override = DeterministicRng.new([6])
	inst.test_world_turn_adapter_override = semantic_stub
	inst.test_world_evolution_adapter_override = evolution_stub
	root.add_child(inst)
	await process_frame
	await process_frame
	inst.agency_scheduler.test_actor_adapter_factory = func() -> Node:
		var created_stub := GenericStub.new()
		_actor_stubs.append(created_stub)
		return created_stub
	var selector_stub: Node = _fresh_selector(inst)
	_check(inst.agency_scheduler != null and inst.world_turn_runtime != null and inst.world_evolution_evaluator != null, "real Shell composes semantic + agency + evolution lanes")
	# GM-only opening（turn 0）经 Shell 自动开启
	opening_stub.simulate_delta("建安十三年秋，曹操大军压境，江东震动。")
	opening_stub.simulate_completed()
	await process_frame
	_check(runtime.conversation.get_durable_accepted_entries().size() == 1, "GM opening accepted")

	# ---- T1 普通 NO_CHECK 回合 → semantic → Agency quiet → Evolution hold [A] ----
	_send(view_of(inst), "我在营中巡视粮草。")
	d20_stub.simulate_delta(JSON.stringify({"decision": "NO_CHECK", "reason": "例行巡视，无风险"}))
	d20_stub.simulate_completed()
	d20_stub.simulate_delta("你巡视粮仓，仓吏禀报存粮账目清楚。")
	d20_stub.simulate_completed()
	await process_frame
	await process_frame
	selector_stub = _fresh_selector(inst)
	semantic_stub.simulate_delta(JSON.stringify({"changes": ["粮草盘点完毕，营中存粮可支两月。"]}))
	semantic_stub.simulate_completed()
	await process_frame
	await process_frame
	selector_stub.simulate_delta(JSON.stringify({"actors": []}))
	selector_stub.simulate_completed()
	await process_frame
	await process_frame
	evolution_stub.simulate_delta(JSON.stringify({"decision": "hold"}))
	evolution_stub.simulate_completed()
	await process_frame
	await process_frame
	var sun_id := String((runtime.world_state.guaranteed_npcs[0] as Dictionary).local_character_id)
	_check(_semantic_changes(runtime, 1) == ["粮草盘点完毕，营中存粮可支两月。"], "1 ordinary turn leaves a durable semantic consequence")
	_check(_agency_cycles(runtime).is_empty() and _evolution_events(runtime).is_empty(), "1 quiet opportunity holds: no fabricated agency action or evolution event")

	# ---- T2 普通回合 → Agency 独立行动（玩家未选择）→ Evolution advance [A/C] ----
	_send(view_of(inst), "我回帐歇息。")
	d20_stub.simulate_delta(JSON.stringify({"decision": "NO_CHECK", "reason": "休整无风险"}))
	d20_stub.simulate_completed()
	d20_stub.simulate_delta("你回帐休息；帐外孙权与众将彻夜议事。")
	d20_stub.simulate_completed()
	await process_frame
	await process_frame
	selector_stub = _fresh_selector(inst)
	semantic_stub.simulate_delta(JSON.stringify({"changes": []}))
	semantic_stub.simulate_completed()
	await process_frame
	await process_frame
	selector_stub.simulate_delta(JSON.stringify({"actors": [sun_id]}))
	selector_stub.simulate_completed()
	await process_frame
	_latest_actor_stub().simulate_delta(JSON.stringify({"actor_id": sun_id, "decision": "act", "intent": "部署江防", "action": NPC_SECRET_ACTION, "effects": ["水军船阵连夜加固完毕。"]}))
	_latest_actor_stub().simulate_completed()
	await process_frame
	await process_frame
	evolution_stub.simulate_delta(JSON.stringify({"decision": "advance", "event": EVOLUTION_EVENT, "effects": ["大雾持续到次日清晨。"]}))
	evolution_stub.simulate_completed()
	await process_frame
	await process_frame
	_check(not _agency_cycles(runtime).is_empty() and String(_agency_action(runtime, 2, sun_id).action) == NPC_SECRET_ACTION, "2 stable NPC authors a durable independent action without the Player choosing it")
	_check(not _evolution_events(runtime).is_empty() and String(_evolution_events(runtime)["2"].event) == EVOLUTION_EVENT, "2 world evolution advances through the existing evaluator seam")
	var context_after_t2 := String(WorldTurnContext.new().project(runtime.world_state, runtime.conversation.get_durable_accepted_entries()).context_text)
	_check(context_after_t2.contains(NPC_SECRET_ACTION) and context_after_t2.contains(EVOLUTION_EVENT), "2 GM continuation context carries independent actor action and evolution as current world reference")
	var panel_world := _panel_text(inst, false)
	_check(not panel_world.contains(NPC_SECRET_ACTION) and not panel_world.contains(EVOLUTION_EVENT), "2/5 player-safe panel excludes hidden agency/evolution truth")

	# ---- T3 风险行动 → Program d20 → grounding → G5-01 consequence [D] ----
	var semantic_requests_before := semantic_stub.requests.size()
	_send(view_of(inst), "我趁夜渡江探查曹军水寨。")
	d20_stub.simulate_delta(JSON.stringify({"decision": "CHECK_REQUIRED", "proposal": {
		"intent": "夜渡探查水寨", "dc": 14, "modifier": 1, "stance": "normal",
		"modifier_reason": "熟悉水路", "situation_reason": "夜间巡江严密",
		"success_intent": "查明水寨布防", "failure_stakes": "被巡江哨船发现",
	}}))
	d20_stub.simulate_completed()
	await process_frame
	var checks: Array = runtime.world_state.expansion_runtime.public_d20_checks
	_check(checks.size() == 1 and int((checks[0] as Dictionary).selected_roll) == 6 and int((checks[0] as Dictionary).total) == 7 and String((checks[0] as Dictionary).outcome) == "failure", "3 Program-owned d20 result durable before narrative (deterministic losing roll)")
	d20_stub.simulate_delta("夜色没有掩护你的小舟；巡江哨船鸣角示警，你仓促撤回。")
	d20_stub.simulate_completed()
	await process_frame
	await process_frame
	var grounding_request := String((semantic_stub.requests[semantic_requests_before][1] as Dictionary).get("content", ""))
	_check(grounding_request.count("Durable Mechanical Resolution") == 1 and grounding_request.contains('outcome: "failure"') and grounding_request.contains("- total: 7"), "3 MW-006 grounding carries the authoritative mechanics fact exactly once into the normal semantic opportunity")
	selector_stub = _fresh_selector(inst)
	semantic_stub.simulate_delta(JSON.stringify({"changes": [MECHANICS_CONSEQUENCE], "knowledge_events": [{"knower_id": String((runtime.world_state.player_character as Dictionary).local_character_id), "fact": MECHANICS_KNOWLEDGE, "basis": "participated"}]}))
	semantic_stub.simulate_completed()
	await process_frame
	await process_frame
	_check(_semantic_changes(runtime, 3) == [MECHANICS_CONSEQUENCE], "3 mechanics-grounded consequence materializes through the normal G5-01 seam")
	var accepted_check: Dictionary = runtime.world_state.expansion_runtime.public_d20_checks[0]
	_check(bool(accepted_check.narrative_accepted) and int(accepted_check.accepted_turn_index) == 3, "3 acceptance marker binds the check to the accepted turn")
	selector_stub.simulate_delta(JSON.stringify({"actors": []}))
	selector_stub.simulate_completed()
	await process_frame
	await process_frame
	evolution_stub.simulate_delta(JSON.stringify({"decision": "hold"}))
	evolution_stub.simulate_completed()
	await process_frame
	await process_frame
	_check(_panel_text(inst, false).contains("• %s" % MECHANICS_KNOWLEDGE), "7 player-safe panel shows the fact only after real Player knowledge")

	# ---- E：close/reopen 重建全部 truth family + no-reroll/no-duplicate ----
	var before_close := _family_snapshot(runtime)
	var projection_before: Dictionary = PlayerSafe.new().project_session(runtime)
	inst.queue_free()
	await process_frame
	runtime.close()
	var reopened := Runtime.new()
	_check(reopened.open_existing_game(String(created.database_path)).success, "reopen existing Game")
	_check(_family_snapshot(reopened) == before_close, "9 close/reopen reconstructs all truth families exactly")
	_check(PlayerSafe.new().project_session(reopened) == projection_before, "9 player-safe projection reconstructs identically after reopen")
	var replay_stub := GenericStub.new()
	var replay := Adjudication.new(reopened, replay_stub, DeterministicRng.new([20]))
	root.add_child(replay)
	var action_id := String((reopened.world_state.expansion_runtime.public_d20_checks[0] as Dictionary).action_id)
	var replayed: Dictionary = replay.start_action(action_id, "我趁夜渡江探查曹军水寨。")
	_check(replayed.success and String(replayed.status) == "already_accepted" and replay_stub.requests.is_empty(), "7 same action after reopen never rerolls")
	replay.queue_free()

	# ---- B：counterfactual propagation（Save S → Path A → Restore S → Path B）----
	# reopen 后以新 Shell 实例继续组合时间线（production reopen 组合）。
	var d20_stub2 := GenericStub.new()
	var semantic_stub2 := SemanticStub.new()
	var evolution_stub2 := GenericStub.new()
	var inst2: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	inst2.session_runtime = reopened
	inst2.test_opening_adapter_override = GenericStub.new()
	inst2.test_adjudication_adapter_override = d20_stub2
	inst2.test_adjudication_rng_override = DeterministicRng.new([6])
	inst2.test_world_turn_adapter_override = semantic_stub2
	inst2.test_world_evolution_adapter_override = evolution_stub2
	root.add_child(inst2)
	await process_frame
	await process_frame
	inst2.agency_scheduler.test_actor_adapter_factory = func() -> Node:
		var created_stub := GenericStub.new()
		_actor_stubs.append(created_stub)
		return created_stub
	var selector_stub2: Node = _fresh_selector(inst2)
	var save_s: Dictionary = reopened.create_save_point("分岔前")
	_check(save_s.success, "Save S captured before the causal turn")

	# Path A：可感知不同的因果回合
	_send(view_of(inst2), "我下令全军备战。")
	d20_stub2.simulate_delta(JSON.stringify({"decision": "NO_CHECK", "reason": "军令无需检定"}))
	d20_stub2.simulate_completed()
	d20_stub2.simulate_delta("中军帐内令旗齐举，各营闻令而动。")
	d20_stub2.simulate_completed()
	await process_frame
	await process_frame
	var player_id := String((reopened.world_state.player_character as Dictionary).local_character_id)
	selector_stub2 = _fresh_selector(inst2)
	semantic_stub2.simulate_delta(JSON.stringify({"changes": [PATH_A_CHANGE], "knowledge_events": [{"knower_id": player_id, "fact": PATH_A_CHANGE, "basis": "participated"}]}))
	semantic_stub2.simulate_completed()
	await process_frame
	await process_frame
	selector_stub2.simulate_delta(JSON.stringify({"actors": []}))
	selector_stub2.simulate_completed()
	await process_frame
	await process_frame
	evolution_stub2.simulate_delta(JSON.stringify({"decision": "hold"}))
	evolution_stub2.simulate_completed()
	await process_frame
	await process_frame
	var path_a_context := String(WorldTurnContext.new().project(reopened.world_state, reopened.conversation.get_durable_accepted_entries()).context_text)
	_check(_semantic_changes(reopened, 4) == [PATH_A_CHANGE] and path_a_context.contains(PATH_A_CHANGE), "Path A establishes its own current truth in GM context")
	_check(_panel_text(inst2, false).contains("• %s" % PATH_A_CHANGE), "Path A knowledge visible in player-safe panel while current")
	_check(path_a_context.contains(NPC_SECRET_ACTION) and path_a_context.contains(EVOLUTION_EVENT), "pre-S independent truth remains current after Path A")

	# Restore S → Path A current truth 从全部 current consumers 消失
	var restored: Dictionary = reopened.restore_save_point(String(save_s.save_id))
	_check(restored.success, "Restore S succeeds")
	await process_frame
	await process_frame
	_check(_semantic_changes(reopened, 4) == [] and not _semantic_records(reopened).has("4"), "restored-away Path A semantic consequence gone from durable current")
	_check(not String(WorldTurnContext.new().project(reopened.world_state, reopened.conversation.get_durable_accepted_entries()).context_text).contains(PATH_A_CHANGE), "Path A material absent from current GM context after Restore")
	_check(not _panel_text(inst2, false).contains(PATH_A_CHANGE), "Path A knowledge absent from player-safe panel after Restore")
	_check(not _agency_cycles(reopened).is_empty() and not _evolution_events(reopened).is_empty(), "pre-S agency/evolution truth remains current after Restore (currentness, not deletion)")

	# Path B：可感知不同的另一分支
	_send(view_of(inst2), "我遣密使联络江东。")
	d20_stub2.simulate_delta(JSON.stringify({"decision": "NO_CHECK", "reason": "密使出发无需检定"}))
	d20_stub2.simulate_completed()
	d20_stub2.simulate_delta("一叶小舟载着密信连夜离岸。")
	d20_stub2.simulate_completed()
	await process_frame
	await process_frame
	selector_stub2 = _fresh_selector(inst2)
	semantic_stub2.simulate_delta(JSON.stringify({"changes": [PATH_B_CHANGE]}))
	semantic_stub2.simulate_completed()
	await process_frame
	await process_frame
	selector_stub2.simulate_delta(JSON.stringify({"actors": []}))
	selector_stub2.simulate_completed()
	await process_frame
	await process_frame
	evolution_stub2.simulate_delta(JSON.stringify({"decision": "hold"}))
	evolution_stub2.simulate_completed()
	await process_frame
	await process_frame
	var path_b_context := String(WorldTurnContext.new().project(reopened.world_state, reopened.conversation.get_durable_accepted_entries()).context_text)
	_check(_semantic_changes(reopened, 4) == [PATH_B_CHANGE] and path_b_context.contains(PATH_B_CHANGE), "Path B establishes its own current truth after Restore")
	_check(not path_b_context.contains(PATH_A_CHANGE) and not _panel_text(inst2, false).contains(PATH_A_CHANGE), "3 restored-away Path A never re-enters current consumers")
	_check(path_b_context.contains(MECHANICS_CONSEQUENCE) and (reopened.world_state.expansion_runtime.public_d20_checks as Array).size() == 1, "pre-S mechanics consequence and d20 truth remain current through the counterfactual composition")

	# 12：无第二 truth store；13：SQLite schema/table 由零 production diff 保证（见 evidence）
	var world_keys := reopened.world_state.keys()
	_check(not world_keys.has("player_safe_projection") and not world_keys.has("matrix_state"), "12 no second projection/matrix truth store on world state")
	_check(reopened.conversation.get_durable_accepted_entries().size() == 5, "composed timeline: opening + 3 pre-S turns + Path B turn, exactly once each")
	inst2.queue_free()
	reopened.close()
	_finish()
	return


func view_of(inst: Node) -> Node:
	return inst.get_node("%NarrativeHost")


func _send(view: Node, text: String) -> void:
	view.player_input.text = text
	view.get_node("%SendButton").pressed.emit()


func _semantic_records(runtime: RefCounted) -> Dictionary:
	return runtime.world_state.get("living_world", {}).get("semantic_turns_by_index", {})


func _semantic_changes(runtime: RefCounted, turn: int) -> Array:
	return (_semantic_records(runtime).get(str(turn), {}) as Dictionary).get("changes", [])


func _agency_cycles(runtime: RefCounted) -> Dictionary:
	return runtime.world_state.get("living_world", {}).get("agency_cycles_by_source_turn", {})


func _agency_action(runtime: RefCounted, turn: int, actor_id: String) -> Dictionary:
	return (_agency_cycles(runtime).get(str(turn), {}) as Dictionary).get("actions_by_actor", {}).get(actor_id, {})


func _evolution_events(runtime: RefCounted) -> Dictionary:
	return runtime.world_state.get("living_world", {}).get("world_evolution_events_by_turn", {})


func _knowledge_records(runtime: RefCounted) -> Dictionary:
	return runtime.world_state.get("living_world", {}).get("knowledge_turns_by_index", {})


## 六个 truth family + projection + head 的一次性快照；reopen 前后 deep-equal。
func _family_snapshot(runtime: RefCounted) -> Dictionary:
	return {
		"conversation": runtime.conversation.get_durable_accepted_entries(),
		"semantic_turns": _semantic_records(runtime),
		"knowledge_turns": _knowledge_records(runtime),
		"agency_cycles": _agency_cycles(runtime),
		"evolution_events": _evolution_events(runtime),
		"d20_checks": runtime.world_state.get("expansion_runtime", {}).get("public_d20_checks", []),
		"panel_projection": PlayerSafe.new().project_session(runtime),
		"head": String(runtime.active_head_id),
	}


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
		print("MW-010 PASS | %s" % label)
	else:
		_failures += 1
		push_error("MW-010 FAIL | %s" % label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("MW-010 FAIL | %s" % label)


func _finish() -> void:
	print("MW-010 MATRIX | done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)
