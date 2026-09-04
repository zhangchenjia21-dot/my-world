extends SceneTree

## MW-002 Selective World Evolution Evaluator —— focused deterministic 证明。
## 覆盖 task §9 的 1–15：hold / advance / 失败隔离 / Opening 排除 / 生产顺序 /
## 输入构成与隐私边界 / Program identity / replay / regenerate currentness /
## foreground-head 安全 / Save-reopen-Restore / 真实 GM consumer / G5-03 保护 /
## one-event ceiling。
## 零真实 Provider 调用；ControlledRuntime 不含任何 Source 对象。

const Conversation := preload("res://src/domain/会话.gd")
const WorldEvolution := preload("res://src/世界回合/L3_外交层/世界演化评估公开接口.gd")
const EvolutionParser := preload("res://src/世界回合/L1_器件层/世界演化响应解析器.gd")
const WorldTurnContext := preload("res://src/世界回合/L3_外交层/世界回合上下文公开接口.gd")
const Rules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")
const SessionRuntime := preload("res://src/runtime/当前游戏会话运行时.gd")
const FirstOpening := preload("res://src/首次开场/L3_外交层/首次开场公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const StubAdapter := preload("res://tests/g5_01/世界回合语义桩适配器.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")
const OpeningStub := preload("res://tests/g4_07a/首次开场桩适配器.gd")
const ViewStub := preload("res://tests/g2_03_桩适配器.gd")

const GAME_ID := "game-mw002-controlled"
const PLAYER_A := "我登台远眺。"
const GM_A := "你登上渡口的高台，望见远处尘土。"
const PLAYER_B := "我回城处置政务。"
const GM_B := "你回到城中，官吏呈上最新的粮册。"
const EVENT_A := "北方旱情引发粮价上涨。"

const WORLD_HAN := "world.han_end.unsettled_realm"
const ENTRY_208 := "t0-208-red-cliffs-eve"
const LIU_BEI := "character.han_end.liu_bei"


## 最小 Runtime 形状：world_state + conversation + durable commit seam；无任何 Source 对象。
class ControlledRuntime:
	extends RefCounted

	var conversation: RefCounted = Conversation.new()
	var game_id := "game-mw002-controlled"
	var active_head_id := "root"
	var world_state: Dictionary = {}
	var commit_count := 0

	func is_ready() -> bool:
		return true

	func commit_world_mutation_durably(_mutation_id: String, node_id: String, candidate: Dictionary) -> Dictionary:
		commit_count += 1
		active_head_id = node_id
		world_state = candidate.duplicate(true)
		return {"success": true, "status": "committed", "head_id": node_id, "world_state": world_state.duplicate(true)}


var _failures := 0
var _fixture := Fixture.new()
var _root := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("g5_04") < 0:
		_fail("必须提供 task-owned --root，且路径包含 g5_04")
		return _finish()
	_fixture.reset_directory(_root)
	_test_parser_contract()
	await _test_hold()
	await _test_advance()
	await _test_failure_isolation()
	await _test_opening_exclusion()
	await _test_input_composition_and_privacy()
	await _test_replay_idempotence()
	await _test_regenerate_currentness()
	await _test_foreground_and_head_safety()
	await _test_production_save_restore_and_gm_consumer()
	await _test_production_ordering()
	_finish()


## parser 级契约：exact hold|advance、raw string 不 coerce、bounded、未知/伪造字段忽略。
func _test_parser_contract() -> void:
	var parser := EvolutionParser.new()
	var hold: Dictionary = parser.parse('{"decision":"hold"}')
	_check(hold.success and String(hold.decision) == "hold", "3 hold parses as first-class valid result")
	var advance: Dictionary = parser.parse('{"decision":"advance","event":"北方旱情引发粮价上涨。","effects":["邺城粮价上涨三成"],"priority":9,"world_evolution_id":"model-id","mutation_id":"model-mutation"}')
	_check(advance.success and String(advance.event) == "北方旱情引发粮价上涨。" and (advance.effects as Array).size() == 1, "2 advance parses; unknown/model-identity fields ignored")
	_check(not advance.has("priority") and not advance.has("world_evolution_id"), "8 parser never surfaces model-supplied identity/priority")
	for bad: String in ['{"decision":"maybe"}', '{"decision":"advance","event":"","effects":["x"]}', '{"decision":"advance","event":"x","effects":[]}', '{"decision":"advance","event":"x","effects":["a","b","c","d","e"]}', '{"decision":1}', 'not json', '']:
		_check(not parser.parse(bad).success, "3 malformed/invalid evaluation fail-soft: %s" % bad.left(32))
	_check(not parser.parse('{"decision":"advance","event":42,"effects":["x"]}').success, "3 non-string event rejected without coercion")
	_check(not parser.parse('{"decision":"advance","event":"x","effects":[42]}').success, "3 non-string effect rejected without coercion")
	_check(not parser.parse(JSON.stringify({"decision": "advance", "event": "x".repeat(513), "effects": ["y"]})).success, "3 oversized event rejected by bounded validation")
	var fenced: Dictionary = parser.parse("```json\n{\"decision\":\"hold\"}\n```")
	_check(fenced.success and String(fenced.decision) == "hold", "3 code-fenced response parses like semantic lane")


## 证明 1：hold——一次评估请求、hold 结果、零 event/mutation；同机会不自动重试。
func _test_hold() -> void:
	var runtime := ControlledRuntime.new()
	runtime.world_state = _setup_world()
	_accept(runtime, PLAYER_A, GM_A)
	var stub := StubAdapter.new()
	var evaluator := WorldEvolution.new(runtime, null, stub)
	root.add_child(evaluator)
	await process_frame
	var started: Dictionary = evaluator.consider_opportunity(0, Rules.gm_sha256(GM_A))
	_check(String(started.get("status", "")) == "evaluation_started" and stub.requests.size() == 1, "1 terminal wake issues exactly one evaluator request")
	stub.simulate_delta('{"decision":"hold"}')
	stub.simulate_completed()
	await process_frame
	_check(String(evaluator.last_result.get("status", "")) == "hold" and bool(evaluator.last_result.get("success", false)), "1 hold is a first-class successful result")
	_check(runtime.commit_count == 0 and not runtime.world_state.has("living_world"), "1 hold creates no event and no fake mutation")
	var again: Dictionary = evaluator.consider_opportunity(0, Rules.gm_sha256(GM_A))
	_check(String(again.get("status", "")) == "already_attempted" and stub.requests.size() == 1, "1 hold does not auto-retry the same runtime opportunity")
	evaluator.shutdown()
	evaluator.queue_free()


## 证明 2 + 8 + 15：valid advance → 恰好一条 Program-owned durable event；
## identity 绑定 exact opportunity turn/hash + base head；一次机会至多一条记录。
func _test_advance() -> void:
	var runtime := ControlledRuntime.new()
	runtime.world_state = _setup_world()
	_accept(runtime, PLAYER_A, GM_A)
	var stub := StubAdapter.new()
	var evaluator := WorldEvolution.new(runtime, null, stub)
	root.add_child(evaluator)
	await process_frame
	evaluator.consider_opportunity(0, Rules.gm_sha256(GM_A))
	stub.simulate_delta('{"decision":"advance","event":"%s","effects":["邺城粮价上涨三成","流民开始向邺城聚集"],"world_evolution_id":"model-minted"}' % EVENT_A)
	stub.simulate_completed()
	await process_frame
	_check(String(evaluator.last_result.get("status", "")) == "committed" and runtime.commit_count == 1, "2 advance commits exactly one durable mutation")
	var events: Dictionary = runtime.world_state.get("living_world", {}).get("world_evolution_events_by_turn", {})
	_check(events.size() == 1, "15 one opportunity commits at most one evolution record")
	if events.size() != 1:
		evaluator.shutdown()
		evaluator.queue_free()
		return
	var record: Dictionary = events.get("0", {})
	var gm_hash := Rules.gm_sha256(GM_A)
	var expected := Rules.world_evolution_identities(GAME_ID, 0, gm_hash, "root")
	_check(String(record.get("world_evolution_id", "")) == String(expected.world_evolution_id), "8 Program-owned deterministic world_evolution_id")
	_check(String(record.get("world_evolution_id", "")) != "model-minted", "8 model-minted event ID ignored")
	_check(int(record.get("opportunity_turn_index", -1)) == 0 and String(record.get("opportunity_gm_sha256", "")) == gm_hash, "8 record binds exact opportunity turn/hash")
	_check(String(record.get("evolution_base_head_id", "")) == "root", "8 record binds evolution base head")
	var other_head := Rules.world_evolution_identities(GAME_ID, 0, gm_hash, "other-head")
	_check(String(other_head.world_evolution_id) != String(expected.world_evolution_id), "8 identity changes with base head (deterministic derivation)")
	_check(String(other_head.mutation_id) != String(expected.mutation_id) and String(other_head.node_id) != String(expected.node_id), "8 Program owns mutation/node identity too")
	var record_keys: Array = record.keys()
	record_keys.sort()
	_check(record_keys == ["effects", "event", "evolution_base_head_id", "materialized_at", "opportunity_gm_sha256", "opportunity_turn_index", "world_evolution_id"], "2 record carries no model-supplied authority fields")
	_check(String(record.get("event", "")) == EVENT_A and (record.get("effects", []) as Array).size() == 2, "2 bounded event/effects preserved")
	_check(Rules.world_evolution_event_is_valid(record), "2 committed record satisfies v0.1 invariants")
	# 后续新机会是合法的新评估；仍各至多一条。
	_accept(runtime, PLAYER_B, GM_B)
	evaluator.consider_opportunity(1, Rules.gm_sha256(GM_B))
	stub.simulate_delta('{"decision":"advance","event":"邺城粮价继续攀升。","effects":["官府开仓平抑粮价"]}')
	stub.simulate_completed()
	await process_frame
	var events_after: Dictionary = runtime.world_state.get("living_world", {}).get("world_evolution_events_by_turn", {})
	_check(events_after.size() == 2 and runtime.commit_count == 2, "15 each opportunity yields at most one event; sequential opportunities stay legal")
	evaluator.shutdown()
	evaluator.queue_free()


## 证明 3（流程级）：malformed/invalid/provider failure → 无 event，accepted Narrative 不变。
func _test_failure_isolation() -> void:
	for mode: String in ["malformed", "invalid_decision", "provider_failure"]:
		var runtime := ControlledRuntime.new()
		runtime.world_state = _setup_world()
		_accept(runtime, PLAYER_A, GM_A)
		var stub := StubAdapter.new()
		var evaluator := WorldEvolution.new(runtime, null, stub)
		root.add_child(evaluator)
		await process_frame
		evaluator.consider_opportunity(0, Rules.gm_sha256(GM_A))
		if mode == "malformed":
			stub.simulate_delta("not json")
			stub.simulate_completed()
		elif mode == "invalid_decision":
			stub.simulate_delta('{"decision":"escalate","event":"x","effects":["y"]}')
			stub.simulate_completed()
		else:
			stub.simulate_failed("transport")
		await process_frame
		_check(not bool(evaluator.last_result.get("success", true)), "3 %s fails soft without success" % mode)
		_check(runtime.commit_count == 0 and not runtime.world_state.has("living_world"), "3 %s creates no event/mutation" % mode)
		_check(runtime.conversation.get_durable_accepted_entries().size() == 1, "3 %s leaves accepted Narrative intact" % mode)
		var again: Dictionary = evaluator.consider_opportunity(0, Rules.gm_sha256(GM_A))
		_check(String(again.get("status", "")) == "already_attempted" and stub.requests.size() == 1, "3 %s does not auto-retry the same opportunity" % mode)
		evaluator.shutdown()
		evaluator.queue_free()


## 证明 4：Opening-only GM generation 不产生 evolution 机会。
func _test_opening_exclusion() -> void:
	var runtime := ControlledRuntime.new()
	runtime.world_state = _setup_world()
	runtime.conversation.begin_gm_opening()
	runtime.conversation.append_delta("这是只由 GM 叙述的首次开场。")
	runtime.conversation.complete_generation()
	var stub := StubAdapter.new()
	var evaluator := WorldEvolution.new(runtime, null, stub)
	root.add_child(evaluator)
	await process_frame
	var accepted: Array = runtime.conversation.get_durable_accepted_entries()
	var result: Dictionary = evaluator.consider_opportunity(0, Rules.gm_sha256(String((accepted[0] as Dictionary).gm_text)))
	_check(String(result.get("status", "")) == "opening_skipped" and stub.requests.is_empty(), "4 Opening-only generation creates no evolution opportunity")
	evaluator.shutdown()
	evaluator.queue_free()


## 证明 6 + 7：evaluator 输入 = frozen World-only T0 baseline + latest accepted 行动/叙事 +
## current semantic changes + 同机会 Agency actions/effects + prior current evolution events；
## 不含 Actor Knowledge Provenance / Character 私有材料；无 Source 访问（结构性）。
func _test_input_composition_and_privacy() -> void:
	var runtime := ControlledRuntime.new()
	runtime.world_state = _setup_world()
	_accept(runtime, PLAYER_A, GM_A)
	_accept(runtime, PLAYER_B, GM_B)
	var hash_a := Rules.gm_sha256(GM_A)
	# current-hash matching 的 post-T0 世界材料（turn A）。
	runtime.world_state["living_world"] = {
		"schema_version": "living_world.v0.1",
		"semantic_turns_by_index": {
			"0": {"world_turn_id": "wt-0", "source_turn_index": 0, "source_gm_sha256": hash_a, "materialized_at": "2026-09-04T00:00:00Z", "changes": ["SEMANTIC_CHANGE_MARKER 江防哨所已增设。"]},
		},
		"knowledge_turns_by_index": {
			"0": {"knowledge_turn_id": "kt-0", "source_turn_index": 0, "source_gm_sha256": hash_a, "materialized_at": "2026-09-04T00:00:00Z", "events": [{"knower_id": "char-npc-sun", "fact": "KNOWLEDGE_PRIVATE_MARKER", "basis": "told"}]},
		},
		"agency_cycles_by_source_turn": {
			"0": Rules.build_agency_cycle(GAME_ID, 0, GM_A, "root", "2026-09-04T00:00:00Z"),
		},
		"world_evolution_events_by_turn": {
			"0": Rules.build_world_evolution_event(GAME_ID, 0, hash_a, "root", "PRIOR_EVOLUTION_MARKER 蝗灾初起。", ["PRIOR_EFFECT_MARKER"], "2026-09-04T00:00:00Z"),
		},
	}
	var cycles: Dictionary = runtime.world_state.living_world.agency_cycles_by_source_turn
	var cycle: Dictionary = (cycles["0"] as Dictionary).duplicate(true)
	cycle["actions_by_actor"] = {"char-npc-sun": Rules.build_agency_action(GAME_ID, String(cycle.agency_cycle_id), "char-npc-sun", "核实", "AGENCY_ACTION_MARKER 派使者核实荆州水军调动", ["AGENCY_EFFECT_MARKER 使者已出发"], "2026-09-04T00:00:00Z")}
	cycles["0"] = cycle
	var stub := StubAdapter.new()
	var evaluator := WorldEvolution.new(runtime, null, stub)
	root.add_child(evaluator)
	await process_frame
	evaluator.consider_opportunity(1, Rules.gm_sha256(GM_B))
	_check(stub.requests.size() == 1, "6 evaluator request issued for the terminal opportunity")
	var request_text := JSON.stringify(stub.requests[0])
	_check(request_text.contains("WORLD_ONLY_BASELINE_MARKER") and request_text.contains("WORLD_INSTRUCTION_MARKER"), "6 input carries frozen Game-local World-only T0 baseline")
	_check(request_text.contains(PLAYER_B) and request_text.contains(GM_B), "6 input carries latest accepted Player action + GM Narrative")
	_check(request_text.contains("SEMANTIC_CHANGE_MARKER"), "6 input carries recent current-hash semantic world changes")
	_check(request_text.contains("AGENCY_ACTION_MARKER") and request_text.contains("AGENCY_EFFECT_MARKER"), "6 input carries same-opportunity Agency actions/effects")
	_check(request_text.contains("PRIOR_EVOLUTION_MARKER") and request_text.contains("PRIOR_EFFECT_MARKER"), "6 input carries prior current evolution events")
	_check(not request_text.contains("KNOWLEDGE_PRIVATE_MARKER"), "7 Actor Knowledge Provenance never enters evaluator input")
	_check(not request_text.contains("PRIVATE_PLAYER_MARKER") and not request_text.contains("PRIVATE_NPC_MARKER"), "7 Character-private material never enters evaluator input")
	stub.simulate_delta('{"decision":"hold"}')
	stub.simulate_completed()
	await process_frame
	evaluator.shutdown()
	evaluator.queue_free()


## 证明 9：matching committed event 使同机会 replay（含 reopen-like fresh worker）
## 不再发评估请求、不追加重复事件。
func _test_replay_idempotence() -> void:
	var runtime := ControlledRuntime.new()
	runtime.world_state = _setup_world()
	_accept(runtime, PLAYER_A, GM_A)
	var stub := StubAdapter.new()
	var evaluator := WorldEvolution.new(runtime, null, stub)
	root.add_child(evaluator)
	await process_frame
	var gm_hash := Rules.gm_sha256(GM_A)
	evaluator.consider_opportunity(0, gm_hash)
	stub.simulate_delta('{"decision":"advance","event":"%s","effects":["邺城粮价上涨三成"]}' % EVENT_A)
	stub.simulate_completed()
	await process_frame
	_check(String(evaluator.last_result.get("status", "")) == "committed", "9 setup: event committed")
	var again: Dictionary = evaluator.consider_opportunity(0, gm_hash)
	_check(String(again.get("status", "")) == "already_evaluated" and stub.requests.size() == 1, "9 same-worker replay of committed opportunity sends no second request")
	# reopen-like fresh worker：内存 attempted 为空，靠 durable matching event 幂等。
	var stub2 := StubAdapter.new()
	var evaluator2 := WorldEvolution.new(runtime, null, stub2)
	root.add_child(evaluator2)
	await process_frame
	var replay: Dictionary = evaluator2.consider_opportunity(0, gm_hash)
	_check(String(replay.get("status", "")) == "already_evaluated" and stub2.requests.is_empty(), "9 reopen-like re-entry is durable-idempotent (no request)")
	var events: Dictionary = runtime.world_state.get("living_world", {}).get("world_evolution_events_by_turn", {})
	_check(events.size() == 1 and runtime.commit_count == 1, "9 replay appends no duplicate event")
	evaluator.shutdown()
	evaluator.queue_free()
	evaluator2.shutdown()
	evaluator2.queue_free()


## 证明 10：regenerate/correction 后旧事件物理保留，但 current GM Context 按 hash 排除。
func _test_regenerate_currentness() -> void:
	var runtime := ControlledRuntime.new()
	runtime.world_state = _setup_world()
	_accept(runtime, PLAYER_A, GM_A)
	var stub := StubAdapter.new()
	var evaluator := WorldEvolution.new(runtime, null, stub)
	root.add_child(evaluator)
	await process_frame
	evaluator.consider_opportunity(0, Rules.gm_sha256(GM_A))
	stub.simulate_delta('{"decision":"advance","event":"%s","effects":["邺城粮价上涨三成"]}' % EVENT_A)
	stub.simulate_completed()
	await process_frame
	var projector := WorldTurnContext.new()
	var accepted: Array = runtime.conversation.get_durable_accepted_entries()
	var current: Dictionary = projector.project(runtime.world_state, accepted)
	_check(String(current.context_text).contains(EVENT_A), "10 current Context includes the matching committed event")
	_check(String(current.context_text).contains("not automatically Player knowledge") and String(current.context_text).contains("not automatically actor knowledge"), "13 Context carries GM-only / no-auto-knowledge guidance")
	# regenerate 同一 turn：accepted GM hash 改变。
	runtime.conversation.retry_or_regenerate_latest()
	runtime.conversation.append_delta("你登上高台，四野平静无事。")
	runtime.conversation.complete_generation()
	var accepted_after: Array = runtime.conversation.get_durable_accepted_entries()
	var projected_after: Dictionary = projector.project(runtime.world_state, accepted_after)
	_check(not String(projected_after.context_text).contains(EVENT_A), "10 stale event excluded from current GM Context on hash mismatch")
	_check(int(projected_after.get("evolution_event_count", -1)) == 0, "10 stale event counted out of current projection")
	var events: Dictionary = runtime.world_state.get("living_world", {}).get("world_evolution_events_by_turn", {})
	_check(events.size() == 1, "10 stale physical event history is not deleted")
	evaluator.shutdown()
	evaluator.queue_free()


## 证明 11：foreground / head change 使 uncommitted evaluation 失效；late callback 不能 commit。
func _test_foreground_and_head_safety() -> void:
	# (a) foreground invalidation + late completion inert。
	var runtime := ControlledRuntime.new()
	runtime.world_state = _setup_world()
	_accept(runtime, PLAYER_A, GM_A)
	var stub := StubAdapter.new()
	var evaluator := WorldEvolution.new(runtime, null, stub)
	root.add_child(evaluator)
	await process_frame
	evaluator.consider_opportunity(0, Rules.gm_sha256(GM_A))
	_check(bool(stub.is_busy()), "11a evaluation active before foreground")
	runtime.conversation.begin_turn("我突然离开高台。")
	evaluator.invalidate()
	await process_frame
	_check(String(evaluator.last_result.get("status", "")) == "evaluation_cancelled" and runtime.commit_count == 0, "11a foreground invalidates active evaluation immediately")
	stub.simulate_delta('{"decision":"advance","event":"迟到事件","effects":["迟到的效果"]}')
	stub.simulate_completed()
	await process_frame
	_check(runtime.commit_count == 0 and not runtime.world_state.has("living_world"), "11a late completion after invalidation cannot commit")
	runtime.conversation.cancel_generation()
	evaluator.shutdown()
	evaluator.queue_free()
	# (b) unrelated head advance before completion → stale_evaluation, no commit。
	var runtime_b := ControlledRuntime.new()
	runtime_b.world_state = _setup_world()
	_accept(runtime_b, PLAYER_A, GM_A)
	var stub_b := StubAdapter.new()
	var evaluator_b := WorldEvolution.new(runtime_b, null, stub_b)
	root.add_child(evaluator_b)
	await process_frame
	evaluator_b.consider_opportunity(0, Rules.gm_sha256(GM_A))
	var external: Dictionary = runtime_b.commit_world_mutation_durably("external-mutation", "external-node", (runtime_b.world_state as Dictionary).duplicate(true))
	_check(bool(external.get("success", false)), "11b unrelated world head advances during evaluation")
	stub_b.simulate_delta('{"decision":"advance","event":"%s","effects":["邺城粮价上涨三成"]}' % EVENT_A)
	stub_b.simulate_completed()
	await process_frame
	_check(String(evaluator_b.last_result.get("status", "")) == "stale_evaluation", "11b head change invalidates uncommitted evaluation")
	_check(not runtime_b.world_state.has("living_world"), "11b stale evaluation commits nothing")
	evaluator_b.shutdown()
	evaluator_b.queue_free()


## 证明 12 + 13：production Save/reopen/Restore 按 Timeline 快照真相保留/移除 event；
## production assemble_continuation_messages() 让下一个 GM continuation 看见 current event。
func _test_production_save_restore_and_gm_consumer() -> void:
	var case_root := _case_root("persistence")
	var installed: Dictionary = _fixture.install_real_assets(_root.path_join("source-library"))
	_check(installed.success, "12 fixture installs frozen real Source assets (creation-time only)")
	if not installed.success:
		return
	var creation := Creation.new(installed.library)
	creation.select_world(_fixture.find_generation(installed.installed, WORLD_HAN))
	creation.select_entry(ENTRY_208)
	creation.confirm_expansion_none()
	creation.select_player(_fixture.find_generation(installed.installed, LIU_BEI))
	creation.set_settings("MW-002 持久化测试局", "Narrative", "")
	var creator := FinalCreate.new(installed.library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games"))
	var created: Dictionary = creator.create_or_resume("creation-mw002-persistence", creation.composition_snapshot())
	_check(created.success, "12 production Game created")
	if not created.success:
		return
	var session := SessionRuntime.new()
	_check(session.open_existing_game(String(created.database_path)).success, "12 production Runtime opens created Game")
	if not session.is_ready():
		return
	# 无 event 的 baseline Save。
	var saved_before: Dictionary = session.create_save_point("MW-002 演化前基线")
	_check(bool(saved_before.get("success", false)), "12 baseline Save Point created before any event")
	var save_before_id := String(saved_before.get("save_id", ""))
	# production acceptance seam + 真实 evaluator + 真实 durable commit。
	var stub := StubAdapter.new()
	var evaluator := WorldEvolution.new(session, null, stub)
	root.add_child(evaluator)
	await process_frame
	session.conversation.begin_turn("我派斥候查探北方灾情。")
	session.conversation.append_delta("斥候回报：北方旱情正在蔓延。")
	var accepted: Dictionary = session.complete_active_generation_durably()
	_check(bool(accepted.get("success", false)), "12 production durable acceptance succeeds")
	var gm_hash := Rules.gm_sha256("斥候回报：北方旱情正在蔓延。")
	var started: Dictionary = evaluator.consider_opportunity(0, gm_hash)
	_check(String(started.get("status", "")) == "evaluation_started" and stub.requests.size() == 1, "12 production evaluator request issued")
	stub.simulate_delta('{"decision":"advance","event":"冀州边境爆发蝗灾。","effects":["蝗群掠过冀州北部农田"]}')
	stub.simulate_completed()
	await process_frame
	_check(String(evaluator.last_result.get("status", "")) == "committed", "12 production evolution commit succeeds")
	var committed_record := Rules.matching_world_evolution_event(session.world_state, 0, gm_hash)
	_check(not committed_record.is_empty(), "12 event durable in production World")
	if committed_record.is_empty():
		evaluator.shutdown()
		evaluator.queue_free()
		session.close()
		return
	var event_id := String(committed_record.get("world_evolution_id", ""))
	# 证明 13：真实 GM consumer——production assemble_continuation_messages()。
	var opening := FirstOpening.new(session, null)
	var assembled: Dictionary = opening.assemble_continuation_messages()
	_check(bool(assembled.get("success", false)), "13 production continuation assembly succeeds")
	var continuation_text := JSON.stringify(assembled.get("messages", []))
	_check(continuation_text.contains("## World Evolution Events") and continuation_text.contains("冀州边境爆发蝗灾") and continuation_text.contains("蝗群掠过冀州北部农田"), "13 next GM continuation Context sees current event/effects")
	_check(continuation_text.contains("not automatically Player knowledge") and continuation_text.contains("not automatically actor knowledge"), "13 Context carries GM-only disclosure guidance")
	# 含 event 的 Save → head 前进 → Restore → close/reopen：event 原样保持。
	var saved_with: Dictionary = session.create_save_point("MW-002 含事件")
	var save_with_id := String(saved_with.get("save_id", ""))
	var advance: Dictionary = (session.world_state as Dictionary).duplicate(true)
	advance["mw002_marker"] = "advanced"
	var committed: Dictionary = session.commit_world_mutation_durably("mw002-advance", "mw002-advance-node", advance)
	_check(bool(committed.get("success", false)), "12 durable head advanced after Save")
	var restored: Dictionary = session.restore_save_point(save_with_id)
	_check(bool(restored.get("success", false)), "12 Restore to event snapshot succeeds")
	_check(_same_evolution_record(Rules.matching_world_evolution_event(session.world_state, 0, gm_hash), committed_record, event_id), "12 Restore preserves exact event and Program-owned ID")
	evaluator.shutdown()
	evaluator.queue_free()
	session.close()
	var reopened := SessionRuntime.new()
	_check(reopened.open_existing_game(String(created.database_path)).success, "12 Game reopens after Restore")
	if reopened.is_ready():
		_check(_same_evolution_record(Rules.matching_world_evolution_event(reopened.world_state, 0, gm_hash), committed_record, event_id), "12 event survives close/reopen after Restore")
	# Restore 到不含 event 的更早快照：event 按 Timeline 真相从 current 移除。
	var restored_before: Dictionary = reopened.restore_save_point(save_before_id)
	_check(bool(restored_before.get("success", false)), "12 Restore to pre-event snapshot succeeds")
	_check(Rules.matching_world_evolution_event(reopened.world_state, 0, gm_hash).is_empty(), "12 restoring earlier snapshot removes event from current truth")
	reopened.close()
	var reopened2 := SessionRuntime.new()
	_check(reopened2.open_existing_game(String(created.database_path)).success, "12 Game reopens on pre-event snapshot")
	if reopened2.is_ready():
		_check(Rules.matching_world_evolution_event(reopened2.world_state, 0, gm_hash).is_empty(), "12 pre-event Restore survives close/reopen")
	reopened2.close()


## 证明 5 + 14：真实 Application 接线——accepted Narrative → semantic → Agency opportunity
## terminal → World Evolution；evaluator 绝不在 Agency 之前运行；observability 不改变
## dirty/foreground/selector 语义；每个 started opportunity 恰好一次 terminal 信号。
func _test_production_ordering() -> void:
	var case_root := _case_root("ordering")
	var database_path := case_root.path_join("current-game.sqlite")
	OS.set_environment("MY_WORLD_TEST_CURRENT_GAME_DB", database_path)
	OS.set_environment("MY_WORLD_TEST_GAME_LIBRARY_ROOT", case_root.path_join("game-library"))
	OS.set_environment("MY_WORLD_TEST_GAMES_ROOT", case_root.path_join("games"))
	OS.set_environment("MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", case_root.path_join("source-library"))
	OS.set_environment("MY_WORLD_TEST_CREATION_ROOT", case_root.path_join("creation"))
	var seed := SessionRuntime.new()
	_check(seed.open_current_game(database_path).success, "5 wiring fixture opens task-owned Game")
	var setup: Dictionary = seed.commit_world_mutation_durably("mw002-setup", "mw002-setup-node", _shell_game_setup(String(seed.game_id)))
	_check(bool(setup.get("success", false)), "5 wiring fixture commits created-schema setup")
	seed.close()
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await _settle(2)
	_check(shell.application_state == shell.ApplicationState.MENU_READY, "5 shell boots to Main Menu")
	shell.test_opening_adapter_override = OpeningStub.new()
	shell.test_world_turn_adapter_override = StubAdapter.new()
	var evolution_stub := StubAdapter.new()
	shell.test_world_evolution_adapter_override = evolution_stub
	shell.continue_button.pressed.emit()
	await _settle(4)
	_check(shell.session_runtime != null and shell.session_runtime.is_ready(), "5 Continue opens created Game Session")
	_check(shell.world_evolution_evaluator != null, "5 production activation mounts World Evolution evaluator")
	shell.agency_scheduler.test_actor_adapter_factory = func() -> Node: return StubAdapter.new()
	var selector_stub := StubAdapter.new()
	shell.agency_scheduler.test_selector_adapter_override = selector_stub
	var order_log: Array = []
	var opportunity_results: Array = []
	# analysis_requested 在 semantic 请求启动时发出（先于任何 selector/evaluation），
	# 用它而非 finished 记录顺序，避开 signal 连接顺序的日志伪影。
	shell.world_turn_runtime.analysis_requested.connect(func(_t: Variant, _m: Variant) -> void: order_log.append("semantic"))
	shell.agency_scheduler.selector_started.connect(func() -> void: order_log.append("selector"))
	# Shell 在 activation 时先连接 opportunity_finished；evaluation_requested 会先于本 handler
	# 记录——因此 order_log 只跟踪语义顺序（semantic→selector→evaluation），terminal 信号
	# 本身的恰好一次与 frozen payload 由 opportunity_results 单独断言。
	shell.agency_scheduler.opportunity_finished.connect(func(r: Dictionary) -> void:
		opportunity_results.append(r))
	shell.world_evolution_evaluator.evaluation_requested.connect(func(_t: Variant, _m: Variant) -> void: order_log.append("evaluation"))
	# Opening：GM-only turn 完成不得 dirty、不得产生 evolution 机会。
	var opening_stub: Node = shell.test_opening_adapter_override
	opening_stub.simulate_delta("开场叙事。")
	opening_stub.simulate_completed()
	await _settle(4)
	_check(not shell.agency_scheduler.dirty and selector_stub.requests.is_empty(), "5 Opening completion starts no Agency opportunity")
	_check(evolution_stub.requests.is_empty(), "4 Opening completion wakes no World Evolution through real wiring")
	var semantic_stub: Node = shell.test_world_turn_adapter_override
	var view_stub := _swap_view_stub(shell.narrative_view)

	# Turn A（no-actor Agency terminal）：evaluator 只在 selector terminal 后被唤醒一次。
	shell.narrative_view.player_input.text = "我查看江防部署。"
	shell.narrative_view._on_send_pressed()
	await _settle(3)
	view_stub.text_delta.emit("江防部署已经确认。")
	view_stub.simulate_completed()
	await _settle(4)
	_check(shell.agency_scheduler.dirty, "14 Turn A accepted marks dirty only (G5-03 semantics intact)")
	_check(bool(semantic_stub.is_busy()) and selector_stub.requests.is_empty() and evolution_stub.requests.is_empty(), "5 zero selector/evaluation while semantic is active")
	semantic_stub.simulate_delta('{"changes":[],"knowledge_events":[]}')
	semantic_stub.simulate_completed()
	await _settle(4)
	_check(selector_stub.requests.size() == 1 and evolution_stub.requests.is_empty(), "5 Agency selector runs before World Evolution; no evaluation while selector active")
	selector_stub.simulate_delta('{"actors":[]}')
	selector_stub.simulate_completed()
	await _settle(3)
	_check(evolution_stub.requests.size() == 1, "5 evaluator wakes exactly once after Agency opportunity terminal")
	_check(order_log == ["semantic", "selector", "evaluation"], "5 actual order: accepted→semantic→Agency terminal→World Evolution (got %s)" % str(order_log))
	_check(opportunity_results.size() == 1, "14 opportunity terminal signal fires exactly once for the started opportunity")
	var turn_a_entry: Dictionary = shell.session_runtime.conversation.get_durable_accepted_entries()[-1]
	_check(int(opportunity_results[0].get("source_turn_index", -1)) == int(turn_a_entry.get("turn_index", -2)) and String(opportunity_results[0].get("source_gm_sha256", "")) == Rules.gm_sha256(String(turn_a_entry.get("gm_text", ""))), "5 terminal signal carries frozen opportunity turn/hash")
	var head_before_hold := String(shell.session_runtime.active_head_id)
	evolution_stub.simulate_delta('{"decision":"hold"}')
	evolution_stub.simulate_completed()
	await _settle(3)
	_check(String(shell.session_runtime.active_head_id) == head_before_hold, "1 production hold creates no world mutation")
	_check(String(shell.world_evolution_evaluator.last_result.get("status", "")) == "hold", "1 production hold is the evaluator terminal")

	# Turn B（actor cycle terminal）：evaluator 等 cycle 真正终态后才运行；
	# 同机会 Agency action 成为 evolution 输入。
	var selector_stub_b := StubAdapter.new()
	shell.agency_scheduler.test_selector_adapter_override = selector_stub_b
	shell.narrative_view.player_input.text = "我命人增设江防哨所。"
	shell.narrative_view._on_send_pressed()
	await _settle(3)
	view_stub.text_delta.emit("江防哨所已经增设完毕。")
	view_stub.simulate_completed()
	await _settle(4)
	semantic_stub.simulate_delta('{"changes":["江防哨所已增设。"],"knowledge_events":[]}')
	semantic_stub.simulate_completed()
	await _settle(4)
	_check(selector_stub_b.requests.size() == 1 and evolution_stub.requests.size() == 1, "5 Turn B selector starts post-semantic; evaluator still waiting for Agency terminal")
	selector_stub_b.simulate_delta('{"actors":["char-npc-sun"]}')
	selector_stub_b.simulate_completed()
	await _settle(3)
	_check(shell.agency_scheduler.agency_cycle_runtime != null and evolution_stub.requests.size() == 1, "5 no evaluation while actor cycle is running")
	var actor_adapter: Node = shell.agency_scheduler.agency_cycle_runtime._provider_adapters.get("char-npc-sun")
	actor_adapter.text_delta.emit('{"actor_id":"char-npc-sun","decision":"act","intent":"核实荆州水军","action":"派使者核实荆州水军调动","effects":["使者已出发核实荆州水军"]}')
	actor_adapter.completed.emit()
	await _settle(4)
	_check(evolution_stub.requests.size() == 2, "5 evaluator wakes only after actor cycle terminal")
	_check(opportunity_results.size() == 2 and order_log.count("evaluation") == 2, "14 exactly one terminal signal per started opportunity")
	_check(order_log[order_log.size() - 3] == "semantic" and order_log[order_log.size() - 2] == "selector" and order_log[order_log.size() - 1] == "evaluation", "5 Turn B order: semantic → selector → cycle terminal → evolution")
	var evolution_request_b := JSON.stringify(evolution_stub.requests[1])
	_check(evolution_request_b.contains("派使者核实荆州水军调动"), "6 same-opportunity Agency action is evolution input")
	_check(evolution_request_b.contains("江防哨所已增设"), "6 same-opportunity semantic consequence is evolution input")
	evolution_stub.simulate_delta('{"decision":"advance","event":"荆州水军开始夜间操练。","effects":["江陵水寨夜间灯火管制"]}')
	evolution_stub.simulate_completed()
	await _settle(3)
	_check(String(shell.world_evolution_evaluator.last_result.get("status", "")) == "committed", "2 production advance commits through real wiring")
	var turn_b_entry: Dictionary = shell.session_runtime.conversation.get_durable_accepted_entries()[-1]
	var committed_b := Rules.matching_world_evolution_event(shell.session_runtime.world_state, int(turn_b_entry.get("turn_index", -1)), Rules.gm_sha256(String(turn_b_entry.get("gm_text", ""))))
	_check(not committed_b.is_empty() and String(committed_b.get("event", "")) == "荆州水军开始夜间操练。", "2 committed event binds Turn B opportunity and is durable")
	_check(not shell.agency_scheduler.dirty and not shell.agency_scheduler.selector_active, "14 dirty/selector semantics unchanged after full chain")
	shell._close_game_session()
	await _settle(2)
	shell.queue_free()
	await process_frame
	_clear_wiring_environment()


func _setup_world() -> Dictionary:
	var world_section := {"section_id": "w1", "title": "世界前提", "section_type": "premise", "disclosure": "public", "content": "WORLD_ONLY_BASELINE_MARKER 北方旱情持续发展。"}
	return {
		"schema_version": "game_local_setup.v0.1",
		"creation_origin": {},
		"game": {"game_id": GAME_ID, "display_name": "MW-002 测试局", "control_mode": "Narrative", "opening_supplement": ""},
		"setup_ancestry": {},
		"selected_entry_id": null,
		"world": {
			"local_world_id": "local-world-mw002",
			"provenance": {"asset_id": "task.world", "generation_fingerprint": "task-generation"},
			"source_projection": {"display_name": "演化测试世界", "world_instructions": "WORLD_INSTRUCTION_MARKER", "gm_instructions": "", "semantic_sections": [world_section]},
		},
		"player_character": {
			"local_character_id": "char-player-mw002",
			"provenance": {"asset_id": "task.player", "generation_fingerprint": "task-generation"},
			"source_projection": {"display_name": "PRIVATE_PLAYER_MARKER", "semantic_sections": [{"section_id": "p1", "title": "身份", "section_type": "premise", "disclosure": "private", "content": "PRIVATE_PLAYER_MARKER"}]},
		},
		"guaranteed_npcs": [
			{"local_character_id": "char-npc-sun", "provenance": {"asset_id": "task.npc", "generation_fingerprint": "task-generation"}, "source_projection": {"display_name": "孙权", "semantic_sections": [{"section_id": "n1", "title": "身份", "section_type": "premise", "disclosure": "private", "content": "PRIVATE_NPC_MARKER"}]}},
		],
	}


## Shell 接线证明用的 created-schema 最小 setup（含一个 Guaranteed NPC 供 actor cycle 路径）。
func _shell_game_setup(game_id: String) -> Dictionary:
	var setup := _setup_world()
	setup.game = {"game_id": game_id, "display_name": "MW-002 接线测试局", "control_mode": "Narrative", "opening_supplement": ""}
	return setup


func _same_evolution_record(actual: Dictionary, expected: Dictionary, expected_id: String) -> bool:
	if actual.is_empty() or expected.is_empty():
		return false
	return String(actual.get("world_evolution_id", "")) == expected_id \
		and String(actual.get("world_evolution_id", "")) == String(expected.get("world_evolution_id", "")) \
		and int(actual.get("opportunity_turn_index", -1)) == int(expected.get("opportunity_turn_index", -2)) \
		and String(actual.get("opportunity_gm_sha256", "")) == String(expected.get("opportunity_gm_sha256", "")) \
		and String(actual.get("evolution_base_head_id", "")) == String(expected.get("evolution_base_head_id", "")) \
		and String(actual.get("event", "")) == String(expected.get("event", "")) \
		and (actual.get("effects", []) as Array) == (expected.get("effects", []) as Array)


func _accept(runtime: ControlledRuntime, player: String, gm: String) -> void:
	runtime.conversation.begin_turn(player)
	runtime.conversation.append_delta(gm)
	runtime.conversation.complete_generation()


## 玩家 turn 使用 View 自有 adapter；换成 g2 桩，接线与 production 完全一致。
func _swap_view_stub(view: Variant) -> Node:
	var stub: Node = ViewStub.new()
	view._disconnect_adapter_signals(view.adapter)
	view.remove_child(view.adapter)
	view.adapter.queue_free()
	view.adapter = stub
	view.add_child(stub)
	stub.text_delta.connect(view._on_text_delta)
	stub.completed.connect(view._on_completed)
	stub.cancelled.connect(view._on_cancelled)
	stub.failed.connect(view._on_failed)
	return stub


func _settle(frames: int) -> void:
	for _index: int in range(frames):
		await process_frame


func _clear_wiring_environment() -> void:
	for key: String in ["MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", "MY_WORLD_TEST_CURRENT_GAME_DB", "MY_WORLD_TEST_GAME_LIBRARY_ROOT", "MY_WORLD_TEST_GAMES_ROOT", "MY_WORLD_TEST_CREATION_ROOT"]:
		OS.set_environment(key, "")


func _case_root(name: String) -> String:
	var path := _root.path_join(name)
	DirAccess.make_dir_recursive_absolute(path)
	return path


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("MW-002 FOCUSED PASS | %s" % label)
	else:
		_failures += 1
		push_error("MW-002 FOCUSED FAIL | %s" % label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("MW-002 FOCUSED FAIL | %s" % label)


func _finish() -> void:
	print("MW-002 FOCUSED | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
