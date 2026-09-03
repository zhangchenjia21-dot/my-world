extends SceneTree

## G5-03M1 Multi-Actor Agency Cycle —— focused deterministic 证明。
## 覆盖 packet §12 的 A–I：多选 / selector 失败隔离 / 每 actor 知识隔离 /
## 同 cycle 多 act / 混合结果 / 前台竞争 / Restore 竞争 / replay / 上限。
## 真实 Provider 垂直由 tests/g5_03/真实Provider行动代理验证.gd 证明。

const Conversation := preload("res://src/domain/会话.gd")
const WorldTurn := preload("res://src/世界回合/L3_外交层/世界回合公开接口.gd")
const WorldTurnContext := preload("res://src/世界回合/L3_外交层/世界回合上下文公开接口.gd")
const AgencyCycle := preload("res://src/世界回合/L3_外交层/行动代理循环公开接口.gd")
const StubAdapter := preload("res://tests/g5_01/世界回合语义桩适配器.gd")

class ControlledRuntime:
	extends RefCounted

	var conversation: RefCounted = Conversation.new()
	var game_id := "game-g5-03-controlled"
	var active_head_id := "root"
	## Player + 三个 Guaranteed NPC（孙权/曹操/诸葛亮）。
	var world_state: Dictionary = {
		"player_character": {"local_character_id": "char-player-001", "source_projection": {"display_name": "刘备"}},
		"guaranteed_npcs": [
			{"local_character_id": "char-npc-sun", "source_projection": {"display_name": "孙权", "semantic_sections": [{"title": "身份", "content": "江东之主。"}]}},
			{"local_character_id": "char-npc-cao", "source_projection": {"display_name": "曹操", "semantic_sections": [{"title": "身份", "content": "北方霸主。"}]}},
			{"local_character_id": "char-npc-zhu", "source_projection": {"display_name": "诸葛亮", "semantic_sections": [{"title": "身份", "content": "军师。"}]}},
		],
	}
	var commit_count := 0
	var fail_commit := false

	func is_ready() -> bool:
		return true

	func commit_world_mutation_durably(_mutation_id: String, node_id: String, candidate: Dictionary) -> Dictionary:
		commit_count += 1
		if fail_commit:
			return {"success": false, "status": "storage_failure", "message": "controlled persistence failure"}
		active_head_id = node_id
		world_state = candidate.duplicate(true)
		return {"success": true, "status": "committed", "head_id": node_id, "world_state": world_state.duplicate(true)}

var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await _test_multi_actor_selection()
	await _test_selector_failure_isolation()
	await _test_per_actor_knowledge_isolation()
	await _test_several_acts_same_cycle()
	await _test_mixed_results()
	await _test_foreground_race()
	await _test_restore_race()
	await _test_replay_reopen()
	await _test_selection_bound()
	print("G5-03M1 FOCUSED | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)


## A：controlled semantic response 选 A+B → 一次语义请求、验证 A+B、无 round-robin 额外 C、
## 两个 agency execution 启动、Player/unknown 被拒绝。
func _test_multi_actor_selection() -> void:
	var runtime := ControlledRuntime.new()
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	await process_frame
	stub.simulate_delta('{"changes":[],"knowledge_events":[],"agency_candidates":["char-npc-sun","char-npc-cao","char-player-001","char-unknown-999"]}')
	stub.simulate_completed()
	await process_frame
	_check(stub.requests.size() == 1, "A one existing semantic-analysis request only")
	var candidates: Array = worker.last_result.get("agency_candidates", [])
	_check(candidates == ["char-npc-sun", "char-npc-cao"], "A selection validates A+B and rejects Player/unknown")
	_check(not candidates.has("char-npc-zhu"), "A no round-robin extra C")
	worker.shutdown()
	worker.queue_free()


## B：valid changes + valid knowledge + malformed/oversized agency_candidates →
## changes/knowledge 仍提交；无 agency execution；Narrative 不变。
func _test_selector_failure_isolation() -> void:
	var runtime := ControlledRuntime.new()
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	_accept(runtime, "我修好了村口被冲毁的木桥。", "村民确认木桥已经恢复通行。")
	await process_frame
	stub.simulate_delta('{"changes":["村口木桥已修复并恢复通行。"],"knowledge_events":[{"knower_id":"char-player-001","fact":"木桥已修复","basis":"witnessed"}],"agency_candidates":"not-an-array"}')
	stub.simulate_completed()
	await process_frame
	_check(worker.last_result.status == "committed" and runtime.commit_count == 1, "B valid changes commit despite malformed agency_candidates")
	_check(runtime.world_state.living_world.has("semantic_turns_by_index"), "B G5-01 consequence record committed")
	_check(runtime.world_state.living_world.has("knowledge_turns_by_index"), "B G5-02 knowledge record committed")
	_check(not runtime.world_state.living_world.has("agency_cycles_by_source_turn"), "B no agency cycle created")
	_check(runtime.conversation.get_durable_accepted_entries().size() == 1, "B accepted Narrative unaffected")
	worker.shutdown()
	worker.queue_free()


## C：A 知道 F、B 知道 G、Player 知道 P → execution request A 含 F 不含 G/P；B 含 G 不含 F/P。
func _test_per_actor_knowledge_isolation() -> void:
	var runtime := ControlledRuntime.new()
	# 先 durable 两条知识：A 知道 F，B 知道 G。
	runtime.world_state["living_world"] = {
		"schema_version": "living_world.v0.1",
		"knowledge_turns_by_index": {
			"0": {"knowledge_turn_id": "kt-0", "source_turn_index": 0, "source_gm_sha256": "0".repeat(64), "materialized_at": "2026-09-03T00:00:00Z", "events": [{"knower_id": "char-npc-sun", "fact": "KNOWLEDGE_F", "basis": "witnessed"}]},
			"1": {"knowledge_turn_id": "kt-1", "source_turn_index": 1, "source_gm_sha256": "1".repeat(64), "materialized_at": "2026-09-03T00:00:00Z", "events": [{"knower_id": "char-npc-cao", "fact": "KNOWLEDGE_G", "basis": "told"}]},
		},
	}
	var cycle := AgencyCycle.new(runtime)
	root.add_child(cycle)
	await process_frame
	var request_a := cycle._actor_request("char-npc-sun")
	var text_a := JSON.stringify(request_a)
	_check(text_a.contains("KNOWLEDGE_F") and not text_a.contains("KNOWLEDGE_G"), "C execution request A contains F, not G")
	_check(not text_a.contains("char-player-001"), "C execution request A never contains Player private knowledge")
	var request_b := cycle._actor_request("char-npc-cao")
	var text_b := JSON.stringify(request_b)
	_check(text_b.contains("KNOWLEDGE_G") and not text_b.contains("KNOWLEDGE_F"), "C execution request B contains G, not F")
	cycle.shutdown()
	cycle.queue_free()


## D：A 与 B 并发 active；任意完成顺序都 act → 两条 durable action；serialized commit 经
## cycle-owned head progression；后到者不因此 stale；后续 GM Context 含两者。
func _test_several_acts_same_cycle() -> void:
	var runtime := ControlledRuntime.new()
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	var cycle := AgencyCycle.new(runtime)
	root.add_child(cycle)
	cycle.test_actor_adapter_factory = func() -> Node: return StubAdapter.new()
	await process_frame
	var started: Dictionary = cycle.start_cycle(0, "江防部署已经确认。".sha256_text(), "root", ["char-npc-sun", "char-npc-cao"])
	_check(started.success and int(started.actor_count) == 2, "D two agency executions launched concurrently")
	_check(cycle.active_requests.size() == 2, "D both actor requests active before completion")
	# 模拟 B 先完成（任意顺序）。保存 adapter 引用，因为 completion 后 dict 会清理。
	var adapter_b: Node = cycle._provider_adapters.get("char-npc-cao")
	adapter_b.text_delta.emit('{"actor_id":"char-npc-cao","decision":"act","intent":"控制江面渡口","action":"命前军加紧控制江面渡口","effects":["江面渡口已被曹军控制"]}')
	adapter_b.completed.emit()
	await process_frame
	_check(runtime.commit_count == 1, "D B commits first through cycle-owned head progression")
	var adapter_a: Node = cycle._provider_adapters.get("char-npc-sun")
	adapter_a.text_delta.emit('{"actor_id":"char-npc-sun","decision":"act","intent":"核实荆州水军","action":"派使者核实荆州水军调动","effects":["使者已出发核实荆州水军"]}')
	adapter_a.completed.emit()
	await process_frame
	_check(runtime.commit_count == 2, "D A commits after B without being staled by sibling")
	var cycles := runtime.world_state.living_world.get("agency_cycles_by_source_turn", {}) as Dictionary
	_check(cycles.size() == 1 and (cycles.values()[0] as Dictionary).actions_by_actor.size() == 2, "D both actor actions durable in same cycle")
	var projected := WorldTurnContext.new().project(runtime.world_state, runtime.conversation.get_durable_accepted_entries())
	var text := String(projected.context_text)
	_check(text.contains("Independent Actor Actions") and text.contains("孙权") and text.contains("曹操"), "D later GM Context contains both independent actions")
	cycle.queue_free()


## E：A=act、B=hold、C=malformed/provider failure → 只有 A durable；foreground 不受影响。
func _test_mixed_results() -> void:
	var runtime := ControlledRuntime.new()
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	var cycle := AgencyCycle.new(runtime)
	root.add_child(cycle)
	cycle.test_actor_adapter_factory = func() -> Node: return StubAdapter.new()
	await process_frame
	cycle.start_cycle(0, "江防部署已经确认。".sha256_text(), "root", ["char-npc-sun", "char-npc-cao", "char-npc-zhu"])
	var adapter_a: Node = cycle._provider_adapters.get("char-npc-sun")
	adapter_a.text_delta.emit('{"actor_id":"char-npc-sun","decision":"act","intent":"核实荆州水军","action":"派使者核实荆州水军调动","effects":["使者已出发核实荆州水军"]}')
	adapter_a.completed.emit()
	await process_frame
	var adapter_b: Node = cycle._provider_adapters.get("char-npc-cao")
	adapter_b.text_delta.emit('{"actor_id":"char-npc-cao","decision":"hold"}')
	adapter_b.completed.emit()
	await process_frame
	var adapter_c: Node = cycle._provider_adapters.get("char-npc-zhu")
	adapter_c.failed.emit("transport", "controlled provider failure")
	await process_frame
	_check(runtime.commit_count == 1, "E only A creates durable action")
	var cycles := runtime.world_state.living_world.get("agency_cycles_by_source_turn", {}) as Dictionary
	_check((cycles.values()[0] as Dictionary).actions_by_actor.size() == 1, "E hold/malformed/provider failure create no fake mutation")
	_check(runtime.conversation.get_durable_accepted_entries().size() == 1, "E foreground Narrative unaffected")
	cycle.queue_free()


## F：A 在下一玩家 attempt 前 commit；B 仍 active；玩家开始下一回合后 B 完成 →
## A 保持 durable；B 不能 late-commit；玩家回合不被阻塞。
func _test_foreground_race() -> void:
	var runtime := ControlledRuntime.new()
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	var cycle := AgencyCycle.new(runtime)
	root.add_child(cycle)
	cycle.test_actor_adapter_factory = func() -> Node: return StubAdapter.new()
	await process_frame
	cycle.start_cycle(0, "江防部署已经确认。".sha256_text(), "root", ["char-npc-sun", "char-npc-cao"])
	var adapter_a: Node = cycle._provider_adapters.get("char-npc-sun")
	adapter_a.text_delta.emit('{"actor_id":"char-npc-sun","decision":"act","intent":"核实荆州水军","action":"派使者核实荆州水军调动","effects":["使者已出发核实荆州水军"]}')
	adapter_a.completed.emit()
	await process_frame
	_check(runtime.commit_count == 1, "F A commits before foreground boundary")
	# 玩家开始下一回合：invalidate 剩余 uncommitted agency。
	cycle.invalidate_remaining()
	_check(cycle.cycle_closed and cycle.active_requests.is_empty(), "F foreground invalidates remaining uncommitted agency")
	# B 的 late callback 不能 commit。
	var adapter_b: Node = cycle._provider_adapters.get("char-npc-cao", null)
	if adapter_b != null and is_instance_valid(adapter_b):
		adapter_b.text_delta.emit('{"actor_id":"char-npc-cao","decision":"act","intent":"控制江面","action":"命前军加紧控制江面渡口","effects":["江面渡口已被曹军控制"]}')
		adapter_b.completed.emit()
		await process_frame
	_check(runtime.commit_count == 1, "F B late completion cannot commit")
	_check(runtime.conversation.get_durable_accepted_entries().size() == 1, "F player turn is not blocked")
	cycle.queue_free()


## G：多个 actor request active；Restore commit 后 late completion 不产生新 agency action。
func _test_restore_race() -> void:
	var runtime := ControlledRuntime.new()
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	var cycle := AgencyCycle.new(runtime)
	root.add_child(cycle)
	await process_frame
	cycle.start_cycle(0, "江防部署已经确认。".sha256_text(), "root", ["char-npc-sun", "char-npc-cao"])
	# 模拟 Restore：head 变化 + invalidate。
	runtime.active_head_id = "restored-head"
	cycle.invalidate_remaining()
	var adapter_a: Node = cycle._provider_adapters.get("char-npc-sun", null)
	if adapter_a != null and is_instance_valid(adapter_a):
		adapter_a.text_delta.emit('{"actor_id":"char-npc-sun","decision":"act","intent":"核实","action":"派使者核实","effects":["使者已出发"]}')
		adapter_a.completed.emit()
		await process_frame
	_check(runtime.commit_count == 0, "G late completions after Restore create zero new agency actions")
	cycle.queue_free()


## H：committed cycle/action identity 不重复；Save/reopen 保留多 actor 行动于后续 GM Context。
func _test_replay_reopen() -> void:
	var runtime := ControlledRuntime.new()
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	var cycle := AgencyCycle.new(runtime)
	root.add_child(cycle)
	cycle.test_actor_adapter_factory = func() -> Node: return StubAdapter.new()
	await process_frame
	cycle.start_cycle(0, "江防部署已经确认。".sha256_text(), "root", ["char-npc-sun"])
	var adapter_a: Node = cycle._provider_adapters.get("char-npc-sun")
	adapter_a.text_delta.emit('{"actor_id":"char-npc-sun","decision":"act","intent":"核实荆州水军","action":"派使者核实荆州水军调动","effects":["使者已出发核实荆州水军"]}')
	adapter_a.completed.emit()
	await process_frame
	_check(runtime.commit_count == 1, "H first cycle commits")
	var cycles := runtime.world_state.living_world.get("agency_cycles_by_source_turn", {}) as Dictionary
	_check(cycles.size() == 1, "H one durable agency cycle committed")
	var committed_cycle := cycles.values()[0] as Dictionary
	var cycle_id := String(committed_cycle.get("agency_cycle_id", ""))
	# 同 cycle identity replay 不重复。
	var replay_cycle := AgencyCycle.new(runtime)
	root.add_child(replay_cycle)
	await process_frame
	replay_cycle.start_cycle(0, "江防部署已经确认。".sha256_text(), "root", ["char-npc-sun"])
	_check(replay_cycle.agency_cycle.agency_cycle_id == cycle_id, "H replay produces same stable cycle identity")
	replay_cycle.shutdown()
	replay_cycle.queue_free()
	cycle.queue_free()
	# Save/reopen：world_state 保留。
	var reopened := ControlledRuntime.new()
	reopened.world_state = runtime.world_state.duplicate(true)
	reopened.conversation = runtime.conversation
	var projected := WorldTurnContext.new().project(reopened.world_state, reopened.conversation.get_durable_accepted_entries())
	_check(String(projected.context_text).contains("派使者核实荆州水军调动"), "H Save/reopen preserves multi-actor actions in later GM Context")


## I：selector 返回 >4 valid IDs → 只有前 4 个执行；无隐藏 fallback loop。
func _test_selection_bound() -> void:
	var runtime := ControlledRuntime.new()
	# 构造 5 个 eligible NPC。
	runtime.world_state.guaranteed_npcs.append({"local_character_id": "char-npc-extra", "source_projection": {"display_name": "额外", "semantic_sections": []}})
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	await process_frame
	stub.simulate_delta('{"changes":[],"knowledge_events":[],"agency_candidates":["char-npc-sun","char-npc-cao","char-npc-zhu","char-npc-extra","char-npc-sun"]}')
	stub.simulate_completed()
	await process_frame
	var candidates: Array = worker.last_result.get("agency_candidates", [])
	_check(candidates.size() == 4, "I selector cap keeps exactly four actors")
	_check(candidates[0] == "char-npc-sun" and candidates[3] == "char-npc-extra", "I preserves model-selected order within cap")
	worker.shutdown()
	worker.queue_free()


func _accept(runtime: ControlledRuntime, player: String, gm: String) -> void:
	runtime.conversation.begin_turn(player)
	runtime.conversation.append_delta(gm)
	runtime.conversation.complete_generation()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G5-03M1 FOCUSED PASS | %s" % label)
	else:
		_failures += 1
		push_error("G5-03M1 FOCUSED FAIL | %s" % label)
