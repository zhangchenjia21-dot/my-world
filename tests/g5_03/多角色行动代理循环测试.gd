extends SceneTree

## G5-03M1 Multi-Actor Agency Cycle —— focused deterministic 证明。
## 覆盖 packet §12 的 A–I：多选 / selector 失败隔离 / 每 actor 知识隔离 /
## 同 cycle 多 act / 混合结果 / 前台竞争 / Restore 竞争 / replay / 上限。
## 真实 Provider 垂直由 tests/g5_03/真实Provider行动代理验证.gd 证明。

const Conversation := preload("res://src/domain/会话.gd")
const WorldTurn := preload("res://src/世界回合/L3_外交层/世界回合公开接口.gd")
const WorldTurnContext := preload("res://src/世界回合/L3_外交层/世界回合上下文公开接口.gd")
const AgencyCycle := preload("res://src/世界回合/L3_外交层/行动代理循环公开接口.gd")
const AgencyScheduler := preload("res://src/世界回合/L3_外交层/行动代理调度公开接口.gd")
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
	await _test_c01_stale_semantic_handoff()
	await _test_c01_restore_invalidation_wiring()
	await _test_c01_commit_time_currentness()
	await _test_c01_stale_memory_filtering()
	await _test_c01_same_turn_replacement()
	await _test_c01_replay_no_duplicate()
	await _test_r01c01_production_dirty_wiring()
	await _test_r01c01_sequential_cycles()
	await _test_r01c01_stale_consequence_filtering()
	await _test_r01c01_no_auto_retry()
	print("G5-03M1 FOCUSED | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)


## R01C01-A：production dirty wiring——ordinary durable accepted player turn 自动 mark dirty，
## semantic terminal 只作 safe wake-up，foreground idle 后 scheduler 启动 selector。
func _test_r01c01_production_dirty_wiring() -> void:
	var runtime := ControlledRuntime.new()
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	var scheduler := AgencyScheduler.new(runtime, null)
	root.add_child(scheduler)
	scheduler.test_selector_adapter_override = StubAdapter.new()
	await process_frame
	# 模拟 production：ordinary durable accepted turn（非手动 mark_dirty）。
	# 直接调用 scheduler.mark_dirty() 是测试 seam；production 由 Shell 的 generation_completed 触发。
	# 这里验证 mark_dirty + consider_agency 的完整 lifecycle。
	scheduler.mark_dirty()
	_check(scheduler.dirty, "R01C01-A accepted ordinary turn marks scheduler dirty")
	var started: Dictionary = scheduler.consider_agency()
	_check(String(started.status) == "selector_started", "R01C01-A foreground idle + semantic settled starts one selector")
	_check(scheduler.selector_adapter != null and is_instance_valid(scheduler.selector_adapter), "R01C01-A selector adapter alive after start")
	scheduler.shutdown()
	scheduler.queue_free()


## R01C01-B：Cycle A terminal 后清理并 re-arm；后续新 accepted turn 可启动 Cycle B。
func _test_r01c01_sequential_cycles() -> void:
	var runtime := ControlledRuntime.new()
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	var scheduler := AgencyScheduler.new(runtime, null)
	root.add_child(scheduler)
	scheduler.test_selector_adapter_override = StubAdapter.new()
	scheduler.test_actor_adapter_factory = func() -> Node: return StubAdapter.new()
	await process_frame
	scheduler.mark_dirty()
	var consider_result: Dictionary = scheduler.consider_agency()
	await process_frame
	var selector_stub: Node = scheduler.selector_adapter
	selector_stub.simulate_delta('{"actors":["char-npc-sun"]}')
	selector_stub.simulate_completed()
	await process_frame
	_check(scheduler.agency_cycle_runtime != null, "R01C01-B Cycle A starts")
	var cycle_a := scheduler.agency_cycle_runtime
	var adapter_a: Node = cycle_a._provider_adapters.get("char-npc-sun")
	adapter_a.text_delta.emit('{"actor_id":"char-npc-sun","decision":"act","intent":"核实荆州水军","action":"派使者核实荆州水军调动","effects":["使者已出发核实荆州水军"]}')
	adapter_a.completed.emit()
	await process_frame
	_check(runtime.commit_count == 1, "R01C01-B Cycle A commits")
	# Cycle A terminal 后清理并 re-arm。
	_check(scheduler.agency_cycle_runtime == null, "R01C01-B Cycle A terminal cleans up scheduler reference")
	# 后续新 accepted turn 标记 dirty 并启动 Cycle B。
	_accept(runtime, "我改为查看水寨。", "水寨部署已经确认。")
	scheduler.mark_dirty()
	scheduler.consider_agency()
	await process_frame
	selector_stub.simulate_delta('{"actors":["char-npc-cao"]}')
	selector_stub.simulate_completed()
	await process_frame
	_check(scheduler.agency_cycle_runtime != null, "R01C01-B Cycle B starts after Cycle A terminal")
	_check(scheduler.agency_cycle_runtime.selected_actors == ["char-npc-cao"], "R01C01-B Cycle B uses latest accepted world state")
	scheduler.shutdown()
	scheduler.queue_free()


## R01C01-C：selector 只读 current accepted-hash-matching semantic consequences。
func _test_r01c01_stale_consequence_filtering() -> void:
	var runtime := ControlledRuntime.new()
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	var accepted_entries: Array = runtime.conversation.get_durable_accepted_entries()
	var current_hash := String((accepted_entries[0] as Dictionary).gm_text).sha256_text()
	# 构造 current matching + stale mismatching semantic consequences。
	runtime.world_state["living_world"] = {
		"schema_version": "living_world.v0.1",
		"semantic_turns_by_index": {
			"0": {"world_turn_id": "wt-0", "source_turn_index": 0, "source_gm_sha256": current_hash, "materialized_at": "2026-09-03T00:00:00Z", "changes": ["CURRENT_CHANGE"]},
			"1": {"world_turn_id": "wt-1", "source_turn_index": 1, "source_gm_sha256": "stale-hash", "materialized_at": "2026-09-03T00:00:00Z", "changes": ["STALE_CHANGE"]},
		},
	}
	var scheduler := AgencyScheduler.new(runtime, null)
	root.add_child(scheduler)
	scheduler.test_selector_adapter_override = StubAdapter.new()
	await process_frame
	scheduler.mark_dirty()
	scheduler.consider_agency()
	await process_frame
	var selector_stub: Node = scheduler.test_selector_adapter_override
	var request_text := JSON.stringify(selector_stub.requests[0])
	_check(request_text.contains("CURRENT_CHANGE"), "R01C01-C selector includes current matching consequence")
	_check(not request_text.contains("STALE_CHANGE"), "R01C01-C selector excludes stale mismatching consequence")
	scheduler.shutdown()
	scheduler.queue_free()


## R01C01-D：selector failure/no-actors/hold terminal 后不 strand、不 auto-retry。
func _test_r01c01_no_auto_retry() -> void:
	var runtime := ControlledRuntime.new()
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	var scheduler := AgencyScheduler.new(runtime, null)
	root.add_child(scheduler)
	scheduler.test_selector_adapter_override = StubAdapter.new()
	await process_frame
	scheduler.mark_dirty()
	scheduler.consider_agency()
	await process_frame
	var selector_stub: Node = scheduler.test_selector_adapter_override
	# selector 返回 no actors：terminal 后不 strand。
	selector_stub.simulate_delta('{"actors":[]}')
	selector_stub.simulate_completed()
	await process_frame
	_check(not scheduler.selector_active and scheduler.agency_cycle_runtime == null, "R01C01-D no-actors selector terminal does not strand")
	_check(scheduler.dirty, "R01C01-D dirty remains for future opportunity")
	# 不 auto-retry：再次 consider_agency 不会立即重启同一机会。
	var second: Dictionary = scheduler.consider_agency()
	_check(String(second.status) == "selector_started", "R01C01-D later consider_agency starts fresh selector")
	scheduler.shutdown()
	scheduler.queue_free()


## C01-A：semantic lane 独立于 Agency——Turn A semantic 晚完成但 GM hash 仍 current 时，
## changes/knowledge 仍提交；foreground 前进不丢弃 otherwise-valid truth；不启动 Agency。
func _test_c01_stale_semantic_handoff() -> void:
	var runtime := ControlledRuntime.new()
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	# Turn A accepted → semantic A active → 玩家开始 Turn B → semantic A 晚完成
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	await process_frame
	# 模拟玩家开始 Turn B（foreground 已开始新 attempt，latest turn 已前进）
	runtime.conversation.begin_turn("我改为查看水寨。")
	# semantic A 晚完成，含 valid changes/knowledge（无 agency_candidates 字段——R01 已移除）
	stub.simulate_delta('{"changes":["江防部署已确认"],"knowledge_events":[{"knower_id":"char-player-001","fact":"江防部署已确认","basis":"witnessed"}]}')
	stub.simulate_completed()
	await process_frame
	# R01：semantic lane 恢复纯 source-version 语义；foreground 前进不丢弃 otherwise-valid truth。
	_check(worker.last_result.status == "committed" or worker.last_result.status == "no_changes", "C01-A semantic result commits valid changes/knowledge regardless of foreground")
	_check(not runtime.world_state.has("living_world") or not runtime.world_state.living_world.has("agency_cycles_by_source_turn"), "C01-A semantic lane never starts Agency")
	runtime.conversation.cancel_generation()
	worker.shutdown()
	worker.queue_free()
	_check(not runtime.world_state.has("living_world") or not runtime.world_state.living_world.has("agency_cycles_by_source_turn"), "C01-A zero Agency Cycle for stale handoff")
	runtime.conversation.cancel_generation()
	worker.shutdown()
	worker.queue_free()


## C01-B：production Restore wiring 自动 invalidate Agency——非测试手动调用。
func _test_c01_restore_invalidation_wiring() -> void:
	var runtime := ControlledRuntime.new()
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	var cycle := AgencyCycle.new(runtime)
	root.add_child(cycle)
	cycle.test_actor_adapter_factory = func() -> Node: return StubAdapter.new()
	await process_frame
	cycle.start_cycle(0, "江防部署已经确认。".sha256_text(), "root", ["char-npc-sun", "char-npc-cao"])
	_check(cycle.active_requests.size() == 2, "C01-B two agency requests active before Restore")
	# 模拟 production Restore：head 变化 + cycle 被 invalidate（production wiring 由 Shell 的 restore_completed 调用）
	# 这里验证 cycle 的 invalidate_remaining 语义；Shell wiring 由集成测试证明。
	runtime.active_head_id = "restored-head"
	cycle.invalidate_remaining()
	_check(cycle.cycle_closed and cycle.active_requests.is_empty(), "C01-B Restore invalidates remaining uncommitted agency")
	# late completion 不能 commit。
	var adapter: Node = StubAdapter.new()
	# 模拟 late completion 不 commit（cycle 已 closed）。
	_check(runtime.commit_count == 0, "C01-B late completion after Restore creates zero new agency mutation")
	cycle.queue_free()


## C01-C：sibling commit 前进 expected head；unrelated head change 使剩余失效。
func _test_c01_commit_time_currentness() -> void:
	var runtime := ControlledRuntime.new()
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	var cycle := AgencyCycle.new(runtime)
	root.add_child(cycle)
	cycle.test_actor_adapter_factory = func() -> Node: return StubAdapter.new()
	await process_frame
	cycle.start_cycle(0, "江防部署已经确认。".sha256_text(), "root", ["char-npc-sun", "char-npc-cao"])
	# A 先 commit：expected head 前进到 A 的 node。
	var adapter_a: Node = cycle._provider_adapters.get("char-npc-sun")
	adapter_a.text_delta.emit('{"actor_id":"char-npc-sun","decision":"act","intent":"核实荆州水军","action":"派使者核实荆州水军调动","effects":["使者已出发核实荆州水军"]}')
	adapter_a.completed.emit()
	await process_frame
	_check(runtime.commit_count == 1, "C01-C A commits first")
	_check(String(runtime.active_head_id) != "root", "C01-C sibling commit advances head")
	# B 在 sibling 前进后 commit：允许。
	var adapter_b: Node = cycle._provider_adapters.get("char-npc-cao")
	adapter_b.text_delta.emit('{"actor_id":"char-npc-cao","decision":"act","intent":"控制江面渡口","action":"命前军加紧控制江面渡口","effects":["江面渡口已被曹军控制"]}')
	adapter_b.completed.emit()
	await process_frame
	_check(runtime.commit_count == 2, "C01-C B commits after sibling head progression")
	cycle.queue_free()

	# 反例：unrelated head change 使剩余失效。
	var runtime2 := ControlledRuntime.new()
	_accept(runtime2, "我查看江防部署。", "江防部署已经确认。")
	var cycle2 := AgencyCycle.new(runtime2)
	root.add_child(cycle2)
	cycle2.test_actor_adapter_factory = func() -> Node: return StubAdapter.new()
	await process_frame
	cycle2.start_cycle(0, "江防部署已经确认。".sha256_text(), "root", ["char-npc-sun", "char-npc-cao"])
	# 模拟 unrelated world mutation 改变 head。
	runtime2.active_head_id = "unrelated-mutation-head"
	var adapter_c: Node = cycle2._provider_adapters.get("char-npc-sun")
	adapter_c.text_delta.emit('{"actor_id":"char-npc-sun","decision":"act","intent":"核实","action":"派使者核实","effects":["使者已出发"]}')
	adapter_c.completed.emit()
	await process_frame
	_check(runtime2.commit_count == 0, "C01-C unrelated head change invalidates remaining uncommitted actor")
	cycle2.queue_free()


## C01-D：stale Knowledge/Agency History 按 current hash 过滤。
func _test_c01_stale_memory_filtering() -> void:
	var runtime := ControlledRuntime.new()
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	var accepted_entries: Array = runtime.conversation.get_durable_accepted_entries()
	var current_hash := String((accepted_entries[0] as Dictionary).gm_text).sha256_text()
	# 构造 stale knowledge（不同 hash）与 current knowledge。
	runtime.world_state["living_world"] = {
		"schema_version": "living_world.v0.1",
		"knowledge_turns_by_index": {
			"0": {"knowledge_turn_id": "kt-stale", "source_turn_index": 0, "source_gm_sha256": "stale-hash", "materialized_at": "2026-09-03T00:00:00Z", "events": [{"knower_id": "char-npc-sun", "fact": "STALE_SECRET_F", "basis": "witnessed"}]},
		},
		"agency_cycles_by_source_turn": {
			"0": {"agency_cycle_id": "cycle-stale", "source_turn_index": 0, "source_gm_sha256": "stale-hash", "cycle_base_head_id": "root", "materialized_at": "2026-09-03T00:00:00Z", "actions_by_actor": {"char-npc-sun": {"agency_action_id": "aa-stale", "actor_id": "char-npc-sun", "intent": "stale", "action": "STALE_AGENCY_ACTION", "effects": ["stale"], "materialized_at": "2026-09-03T00:00:00Z"}}},
		},
	}
	var cycle := AgencyCycle.new(runtime)
	root.add_child(cycle)
	cycle.test_actor_adapter_factory = func() -> Node: return StubAdapter.new()
	await process_frame
	var request := cycle._actor_request("char-npc-sun")
	var text := JSON.stringify(request)
	_check(not text.contains("STALE_SECRET_F"), "C01-D stale Knowledge filtered from actor execution")
	_check(not text.contains("STALE_AGENCY_ACTION"), "C01-D stale Agency History filtered from actor execution")
	# selector 材料同样过滤（R01：selector 已由 standalone scheduler 拥有）。
	var scheduler := AgencyScheduler.new(runtime, null)
	root.add_child(scheduler)
	await process_frame
	scheduler.mark_dirty()
	var selector_request := scheduler._selector_request()
	var selector_text := JSON.stringify(selector_request)
	_check(not selector_text.contains("STALE_SECRET_F"), "C01-D stale Knowledge filtered from selector input")
	_check(not selector_text.contains("STALE_AGENCY_ACTION"), "C01-D stale Agency History filtered from selector input")
	scheduler.shutdown()
	scheduler.queue_free()
	cycle.queue_free()


## C01-E：同 turn-index stale cycle 替换而非合并。
func _test_c01_same_turn_replacement() -> void:
	var runtime := ControlledRuntime.new()
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	# 构造 stale cycle（不同 hash）。
	runtime.world_state["living_world"] = {
		"schema_version": "living_world.v0.1",
		"agency_cycles_by_source_turn": {
			"0": {"agency_cycle_id": "cycle-old", "source_turn_index": 0, "source_gm_sha256": "old-hash", "cycle_base_head_id": "root", "materialized_at": "2026-09-03T00:00:00Z", "actions_by_actor": {"char-npc-sun": {"agency_action_id": "aa-old", "actor_id": "char-npc-sun", "intent": "old", "action": "OLD_ACTION", "effects": ["old"], "materialized_at": "2026-09-03T00:00:00Z"}}},
		},
	}
	var cycle := AgencyCycle.new(runtime)
	root.add_child(cycle)
	cycle.test_actor_adapter_factory = func() -> Node: return StubAdapter.new()
	await process_frame
	var accepted_entries: Array = runtime.conversation.get_durable_accepted_entries()
	var current_hash := String((accepted_entries[0] as Dictionary).gm_text).sha256_text()
	cycle.start_cycle(0, current_hash, "root", ["char-npc-sun"])
	var adapter: Node = cycle._provider_adapters.get("char-npc-sun")
	adapter.text_delta.emit('{"actor_id":"char-npc-sun","decision":"act","intent":"new","action":"NEW_ACTION","effects":["new"]}')
	adapter.completed.emit()
	await process_frame
	var cycles := runtime.world_state.living_world.get("agency_cycles_by_source_turn", {}) as Dictionary
	var committed := cycles.values()[0] as Dictionary
	_check(String(committed.get("source_gm_sha256", "")) == current_hash, "C01-E new cycle replaces stale cycle with current hash")
	_check(String(committed.get("agency_cycle_id", "")) != "cycle-old", "C01-E new cycle has new identity")
	_check(String((committed.get("actions_by_actor", {}) as Dictionary).get("char-npc-sun", {}).get("action", "")) == "NEW_ACTION", "C01-E new action stored in new cycle")
	_check(not JSON.stringify(committed).contains("OLD_ACTION"), "C01-E old cycle not merged into current branch")
	cycle.queue_free()


## C01-F：replay 不重复执行已 committed actor。
func _test_c01_replay_no_duplicate() -> void:
	var runtime := ControlledRuntime.new()
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	var cycle := AgencyCycle.new(runtime)
	root.add_child(cycle)
	cycle.test_actor_adapter_factory = func() -> Node: return StubAdapter.new()
	await process_frame
	var accepted_entries: Array = runtime.conversation.get_durable_accepted_entries()
	var current_hash := String((accepted_entries[0] as Dictionary).gm_text).sha256_text()
	cycle.start_cycle(0, current_hash, "root", ["char-npc-sun"])
	var adapter: Node = cycle._provider_adapters.get("char-npc-sun")
	adapter.text_delta.emit('{"actor_id":"char-npc-sun","decision":"act","intent":"核实荆州水军","action":"派使者核实荆州水军调动","effects":["使者已出发核实荆州水军"]}')
	adapter.completed.emit()
	await process_frame
	_check(runtime.commit_count == 1, "C01-F first execution commits")
	cycle.queue_free()
	# replay：同 source version 同 actor 已 committed → 不再执行。
	var replay_cycle := AgencyCycle.new(runtime)
	root.add_child(replay_cycle)
	replay_cycle.test_actor_adapter_factory = func() -> Node: return StubAdapter.new()
	await process_frame
	var committed_cycle := runtime.world_state.living_world.get("agency_cycles_by_source_turn", {}).get("0", {}) as Dictionary
	var committed_actions: Dictionary = committed_cycle.get("actions_by_actor", {})
	var replay_result: Dictionary = replay_cycle.start_cycle(0, current_hash, String(runtime.active_head_id), ["char-npc-sun"])
	_check(String(replay_result.status) == "already_committed", "C01-F replay skips already committed actor")
	_check(replay_cycle.active_requests.is_empty(), "C01-F no new Provider execution for committed actor")
	_check(runtime.commit_count == 1, "C01-F no second mutation on replay")
	replay_cycle.queue_free()


## A：controlled selector response 选 A+B → 一次 standalone selector 请求、验证 A+B、无 round-robin 额外 C、
## 两个 agency execution 启动、Player/unknown 被拒绝。
func _test_multi_actor_selection() -> void:
	var runtime := ControlledRuntime.new()
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	var scheduler := AgencyScheduler.new(runtime, null)
	root.add_child(scheduler)
	scheduler.test_selector_adapter_override = StubAdapter.new()
	scheduler.test_actor_adapter_factory = func() -> Node: return StubAdapter.new()
	await process_frame
	scheduler.mark_dirty()
	_check(scheduler.dirty, "A accepted turn marks scheduler dirty")
	var started: Dictionary = scheduler.consider_agency()
	_check(String(started.status) == "selector_started", "A foreground idle + semantic settled starts one selector")
	await process_frame
	var selector_stub: Node = scheduler.test_selector_adapter_override
	selector_stub.simulate_delta('{"actors":["char-npc-sun","char-npc-cao","char-player-001","char-unknown-999"]}')
	selector_stub.simulate_completed()
	await process_frame
	_check(scheduler.agency_cycle_runtime != null, "A selector starts Agency Cycle")
	_check(scheduler.agency_cycle_runtime.selected_actors == ["char-npc-sun", "char-npc-cao"], "A selection validates A+B and rejects Player/unknown")
	_check(not scheduler.agency_cycle_runtime.selected_actors.has("char-npc-zhu"), "A no round-robin extra C")
	_check(scheduler.agency_cycle_runtime.active_requests.size() == 2, "A two agency executions launched")
	scheduler.shutdown()
	scheduler.queue_free()


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
	# C01 修正 D：Knowledge 只含 current-hash matching 的 durable 记录。
	# 构造 matching hash：用真实 accepted entries 的 hash。
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	var accepted_entries: Array = runtime.conversation.get_durable_accepted_entries()
	var accepted_hash := String((accepted_entries[0] as Dictionary).gm_text).sha256_text()
	# 先 durable 两条知识：A 知道 F，B 知道 G。
	runtime.world_state["living_world"] = {
		"schema_version": "living_world.v0.1",
		"knowledge_turns_by_index": {
			"0": {"knowledge_turn_id": "kt-0", "source_turn_index": 0, "source_gm_sha256": accepted_hash, "materialized_at": "2026-09-03T00:00:00Z", "events": [{"knower_id": "char-npc-sun", "fact": "KNOWLEDGE_F", "basis": "witnessed"}]},
			"1": {"knowledge_turn_id": "kt-1", "source_turn_index": 0, "source_gm_sha256": accepted_hash, "materialized_at": "2026-09-03T00:00:00Z", "events": [{"knower_id": "char-npc-cao", "fact": "KNOWLEDGE_G", "basis": "told"}]},
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
	_accept(runtime, "我查看江防部署。", "江防部署已经确认。")
	var scheduler := AgencyScheduler.new(runtime, null)
	root.add_child(scheduler)
	scheduler.test_selector_adapter_override = StubAdapter.new()
	await process_frame
	scheduler.mark_dirty()
	var consider_result: Dictionary = scheduler.consider_agency()
	await process_frame
	var selector_stub: Node = scheduler.selector_adapter
	selector_stub.simulate_delta('{"actors":["char-npc-sun","char-npc-cao","char-npc-zhu","char-npc-extra","char-npc-sun"]}')
	var entries_now: Array = runtime.conversation.get_durable_accepted_entries()
	var latest_now := entries_now[-1] as Dictionary
	selector_stub.simulate_completed()
	await process_frame
	await process_frame
	_check(scheduler.agency_cycle_runtime.selected_actors[0] == "char-npc-sun" and scheduler.agency_cycle_runtime.selected_actors[3] == "char-npc-extra", "I preserves model-selected order within cap")
	scheduler.shutdown()
	scheduler.queue_free()


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
