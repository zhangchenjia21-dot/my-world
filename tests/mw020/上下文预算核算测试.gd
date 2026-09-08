extends "res://tests/g5_01/世界回合时间线恢复测试.gd"

const Rules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")
const Context := preload("res://src/世界回合/L3_外交层/世界回合上下文公开接口.gd")
const EvolutionParser := preload("res://src/世界回合/L1_器件层/世界演化响应解析器.gd")
const GAME := "mw020-accounting"
const STAMP := "2026-09-08T00:00:00Z"
const ACTOR := "npc-courier"
const ACTION := "使者已经离城前往渡口核实水位。"
const WORLD_HEADING := "## Materialized World Changes\nOnly durable consequences matching the current accepted Conversation are listed.\n"
const KNOWLEDGE := "## Actor Knowledge Provenance\nGM has broader world reference; actors do not automatically share GM knowledge.\nA post-T0 fact present in World/GM context is not automatically actor knowledge. Let an actor speak, plan, react or decide from it only when durable provenance below or the current scene supports awareness.\n信使 [npc-courier]\n- [witnessed] 信使亲眼看见渡口水位上涨。"
const AGENCY := "## Independent Actor Actions\nAgency Cycle source turn 3\n- 信使 [npc-courier]: " + ACTION
const EVOLUTION := "## World Evolution Events\nThese are omniscient GM current-world facts. They are not automatically Player knowledge and not automatically actor knowledge. Surface them only when scene, information flow and pacing make them relevant.\n- 渡口上游降雨持续。\n  - 河道水位上涨。"
var checks := 0
var measurements: Array = []

func _run() -> void:
	_root_path = _argument("--root=")
	if not _root_path.contains("mw020"):
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(_root_path)
	_test_boundaries()
	_test_quiet_and_currentness()
	await _test_durable_gm_consumer()
	FileAccess.open(_root_path.path_join("measurements.json"), FileAccess.WRITE).store_string(JSON.stringify(measurements, "  ") + "\n")
	print("MW-020 FOCUSED checks=%d failures=%d" % [checks, _failures])
	quit(0 if _failures == 0 else 1)

func _entries() -> Array:
	var entries: Array = []
	for i: int in range(4):
		entries.append({"turn_index": i, "player_text": "查看水情%d" % i, "gm_text": "已接受水情叙事%d" % i})
	return entries

func _roster() -> Dictionary:
	return {"guaranteed_npcs": [{"local_character_id": ACTOR, "source_projection": {"display_name": "信使"}}]}

## 预算夹具按合法 4 turns × 8 changes 构造，每条 <=512 字符；不绕过生产 validator。
## 独立预期渲染用于定长，绝不读取 projector 的私有预算计数或截断记录来伪造边界。
func _world_at_length(length: int, game_id: String = GAME) -> Dictionary:
	var base_cost := WORLD_HEADING.length() + 3
	for i: int in range(4):
		base_cost += ("Conversation Turn %d" % i).length() + 8 * 4
	var remaining := length - base_cost
	var world := _roster()
	for i: int in range(4):
		var changes: Array = []
		for j: int in range(8):
			var extra := mini(511, remaining)
			changes.append("水".repeat(1 + extra))
			remaining -= extra
		var record := Rules.build_record(game_id, i, _entries()[i].gm_text, changes, STAMP)
		_check(Rules.record_is_valid(record), "legitimate bounded semantic record")
		world = Rules.build_world_candidate(world, record)
	_check(remaining == 0 and _world_text(world).length() == length, "fixture physical world length %d" % length)
	return world

func _world_text(world: Dictionary, first_turn: int = 0) -> String:
	var blocks: PackedStringArray = []
	for i: int in range(first_turn, 4):
		var lines := PackedStringArray(["Conversation Turn %d" % i])
		for change: String in world.living_world.semantic_turns_by_index[str(i)].changes:
			lines.append("- " + change)
		blocks.append("\n".join(lines))
	return WORLD_HEADING + "\n".join(blocks)

func _with_knowledge(world: Dictionary) -> Dictionary:
	var record := Rules.build_knowledge_record(GAME, 3, _entries()[3].gm_text, [{"knower_id": ACTOR, "fact": "信使亲眼看见渡口水位上涨。", "basis": "witnessed"}], STAMP)
	_check(Rules.knowledge_record_is_valid(record), "legitimate Knowledge record")
	return Rules.build_world_candidate_with_knowledge(world, {}, record)

func _with_agency(world: Dictionary, game_id: String = GAME, head: String = "fixture-head") -> Dictionary:
	var cycle := Rules.build_agency_cycle(game_id, 3, _entries()[3].gm_text, head, STAMP)
	var action := Rules.build_agency_action(game_id, cycle.agency_cycle_id, ACTOR, "核实水情", ACTION, ["使者已经出发。"], STAMP)
	_check(Rules.agency_action_is_valid(action), "legitimate Agency action")
	var candidate := Rules.build_agency_candidate(world, cycle, action)
	_check(Rules.agency_cycle_is_valid(candidate.living_world.agency_cycles_by_source_turn["3"]), "legitimate committed-form Agency cycle")
	return candidate

func _with_evolution(world: Dictionary) -> Dictionary:
	var record := Rules.build_world_evolution_event(GAME, 3, Rules.gm_sha256(_entries()[3].gm_text), "fixture-head", "渡口上游降雨持续。", ["河道水位上涨。"], STAMP)
	_check(Rules.world_evolution_event_is_valid(record), "legitimate Evolution event")
	return Rules.build_world_candidate_with_evolution(world, record)

func _project(world: Dictionary, entries: Array, label: String) -> Dictionary:
	var before := world.duplicate(true)
	var result := Context.new().project(world, entries)
	_check(result.success and result.context_text.length() <= 16000, label + " final hard ceiling")
	_check(world == before, label + " projection never mutates durable material")
	measurements.append({"case": label, "length": result.context_text.length(), "records": result.get("record_count", 0), "knowledge": result.get("knowledge_event_count", 0), "agency": result.get("agency_action_count", 0), "evolution": result.get("evolution_event_count", 0), "sha256": result.context_text.sha256_text()})
	return result

func _test_boundaries() -> void:
	# 每个 later section 都在其实际前缀下覆盖 exact fit / one-over，包含真实 heading 和双换行。
	var suffix := ""
	for count: int in range(1, 4):
		suffix += "\n\n" + [KNOWLEDGE, AGENCY, EVOLUTION][count - 1]
		for overflow: int in [0, 1]:
			var world := _world_at_length(16000 - suffix.length() + overflow)
			var expected := _world_text(world)
			world = _with_knowledge(world)
			if count >= 2:
				world = _with_agency(world)
			if count >= 3:
				world = _with_evolution(world)
			var result := _project(world, _entries(), "section-%d over-%d" % [count, overflow])
			var kept := count if overflow == 0 else count - 1
			for i: int in range(kept):
				expected += "\n\n" + [KNOWLEDGE, AGENCY, EVOLUTION][i]
			_check(result.context_text == expected, "full-section exact inclusion/omission and framing counted once")
			_check(result.context_text.length() == 16000 if overflow == 0 else result.context_text.length() < 16000, "16000 retained; hypothetical 16001 omitted")
			_check(result.knowledge_event_count == int(kept >= 1) and result.agency_action_count == int(kept >= 2) and result.evolution_event_count == int(kept >= 3), "projection counts match included sections")
	# 初始 section 也必须计标题与三个 block separators；one-over 仍按 newest-first 丢最旧整块。
	for length: int in [16000, 16001]:
		var world := _world_at_length(length)
		var result := _project(world, _entries(), "initial-%d" % length)
		_check(result.context_text == _world_text(world, 0 if length == 16000 else 1), "world heading/block separators exact and latest blocks retained")
		_check(result.record_count == (4 if length == 16000 else 3), "initial exact bound keeps four; one-over drops oldest")
	# 若 Knowledge 放不下，空 section 不收取分隔符，也不消耗后续 Agency 的真实余量。
	var world := _with_agency(_with_knowledge(_world_at_length(16000 - 2 - AGENCY.length())))
	var result := _project(world, _entries(), "omitted-knowledge-agency-exact")
	_check(result.context_text == _world_text(world) + "\n\n" + AGENCY and result.context_text.length() == 16000, "omitted Knowledge does not spend Agency budget")

func _test_quiet_and_currentness() -> void:
	for family: int in range(3):
		var world: Dictionary = [_with_knowledge(_roster()), _with_agency(_roster()), _with_evolution(_roster())][family]
		var result := _project(world, _entries(), "standalone-%d" % family)
		_check(result.context_text == [KNOWLEDGE, AGENCY, EVOLUTION][family], "standalone section has no invented leading separator")
	var world := _with_evolution(_with_agency(_with_knowledge(_world_at_length(1000))))
	var entries := _entries()
	entries[3].gm_text = "replacement accepted version"
	var result := _project(world, entries, "same-index-replacement")
	_check(result.knowledge_event_count == 0 and result.agency_action_count == 0 and result.evolution_event_count == 0 and result.record_count == 3, "all four families reject stale accepted hashes")
	result = _project(world, _entries().slice(0, 3), "displaced-future")
	_check(result.knowledge_event_count == 0 and result.agency_action_count == 0 and result.evolution_event_count == 0 and result.record_count == 3, "absent accepted future stays excluded")
	result = _project(_world_at_length(1000), _entries(), "no-agency-no-evolution")
	_check(result.agency_action_count == 0 and result.evolution_event_count == 0, "absent lanes add no fake headings")
	_check(EvolutionParser.new().parse('{"decision":"hold"}').success, "world hold remains legitimate")
	result = _project({}, _entries(), "quiet-world")
	_check(result.status == "empty" and result.context_text.is_empty(), "quiet world stays empty")

func _test_durable_gm_consumer() -> void:
	var db := _root_path.path_join("durable-context.sqlite")
	var runtime := Runtime.new()
	_check(runtime.open_current_game(db).success, "isolated real SQLite runtime")
	var setup := _minimal_game_setup(runtime.game_id)
	var npc: Dictionary = setup.player_character.duplicate(true)
	npc.local_character_id = ACTOR
	npc.source_projection.display_name = "信使"
	setup.guaranteed_npcs = [npc]
	_check(runtime.commit_world_mutation_durably("setup", "setup-node", setup).success, "production setup commit")
	for entry: Dictionary in _entries():
		_accept_durably(runtime, entry.player_text, entry.gm_text)
	var candidate := runtime.world_state.duplicate(true)
	candidate["living_world"] = _world_at_length(10000, runtime.game_id).living_world
	var committed := runtime.commit_world_mutation_durably("semantic", "semantic-node", candidate)
	print("DURABLE_STATUS ", committed.get("status"), " ", committed.get("message", ""))
	_check(committed.success, "substantial valid semantic changes durable")
	var before := runtime.create_save_point("before-agency")
	_check(before.success, "Save before Agency")
	candidate = _with_agency(runtime.world_state, runtime.game_id, runtime.active_head_id)
	_check(runtime.commit_world_mutation_durably("agency", "agency-node", candidate).success, "production Agency durable commit")
	var result := _project(runtime.world_state, runtime.conversation.get_durable_accepted_entries(), "audit-equivalent-durable")
	_check(result.context_text.length() == 10000 + 2 + AGENCY.length() and result.context_text.contains(ACTION), "physical room includes durable Agency despite substantial changes")
	runtime.close()
	runtime = Runtime.new()
	_check(runtime.open_existing_game(db).success, "reopen durable world")
	var opening := Opening.new(runtime, StubAdapter.new())
	root.add_child(opening)
	runtime.conversation.begin_turn("后续 GM 检查水情。")
	var messages := opening.assemble_continuation_messages()
	print("GM_ASSEMBLY_STATUS ", messages.get("status"), " ", messages.get("message", ""))
	_check(messages.success and JSON.stringify(messages.get("messages", [])).contains(ACTION), "actual later GM request assembly includes durable Agency without Provider call")
	runtime.conversation.cancel_generation()
	_check(runtime.restore_save_point(before.save_id).success, "Restore earlier snapshot")
	result = _project(runtime.world_state, runtime.conversation.get_durable_accepted_entries(), "restored-before-agency")
	_check(not result.context_text.contains(ACTION) and result.get("agency_action_count", 0) == 0, "restored-away Agency cannot re-enter")
	opening.queue_free()
	runtime.close()
	await process_frame

func _check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("MW-020 PASS " + label)
	else:
		_failures += 1
		push_error("MW-020 FAIL " + label)
