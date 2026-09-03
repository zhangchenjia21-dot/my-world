extends SceneTree

## G5-02M1 Known-Actor Knowledge Provenance Spine —— focused deterministic 证明。
## 覆盖 packet §11 的 A–F：私有获取不对称 / 后续披露 / 未知 actor 拒绝 /
## knowledge 解析隔离 / 仅知识 mutation / replay/reopen/hash 匹配。
## 真实 Provider 垂直由 tests/g5_02/真实Provider知识溯源验证.gd 证明。

const Conversation := preload("res://src/domain/会话.gd")
const WorldTurn := preload("res://src/世界回合/L3_外交层/世界回合公开接口.gd")
const WorldTurnContext := preload("res://src/世界回合/L3_外交层/世界回合上下文公开接口.gd")
const Rules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")
const StubAdapter := preload("res://tests/g5_01/世界回合语义桩适配器.gd")

class ControlledRuntime:
	extends RefCounted

	var conversation: RefCounted = Conversation.new()
	var game_id := "game-g5-02-controlled"
	var active_head_id := "root"
	## 最小 Game-local setup：Player + Guaranteed NPC A，各持 stable local ID。
	var world_state: Dictionary = {
		"player_character": {"local_character_id": "char-player-001", "source_projection": {"display_name": "刘备"}},
		"guaranteed_npcs": [{"local_character_id": "char-npc-002", "source_projection": {"display_name": "孙权"}}],
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
	await _test_private_acquisition_asymmetry()
	await _test_later_disclosure()
	await _test_unknown_actor_rejection()
	await _test_knowledge_parse_isolation()
	await _test_knowledge_only_mutation()
	await _test_replay_reopen_hash_matching()
	print("G5-02M1 FOCUSED | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)


## A：Player 单独发现私有事实 F → 只有 Player 获得 durable provenance；NPC A 没有；
## 后续 Context 保留不对称。
func _test_private_acquisition_asymmetry() -> void:
	var runtime := ControlledRuntime.new()
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	_accept(runtime, "我独自查看北门守军的换防记录。", "你从记录中发现北门守军每夜三更换防。")
	await process_frame
	stub.simulate_delta('{"changes":[],"knowledge_events":[{"knower_id":"char-player-001","fact":"北门守军每夜三更换防。","basis":"discovered"}]}')
	stub.simulate_completed()
	await process_frame
	_check(worker.last_result.status == "committed" and runtime.commit_count == 1, "A knowledge-only result commits one atomic mutation")
	var knowledge_records := runtime.world_state.living_world.get("knowledge_turns_by_index", {}) as Dictionary
	_check(knowledge_records.size() == 1, "A one durable knowledge record committed")
	var events: Array = (knowledge_records.values()[0] as Dictionary).events
	_check(events.size() == 1 and String(events[0].knower_id) == "char-player-001", "A only Player Character gains provenance")
	_check(String(events[0].fact) == "北门守军每夜三更换防。" and String(events[0].basis) == "discovered", "A event carries exact fact and basis")
	# Context 投影：Player 知道 F，NPC A 不知道。
	var projected := WorldTurnContext.new().project(runtime.world_state, runtime.conversation.get_durable_accepted_entries())
	var text := String(projected.context_text)
	_check(text.contains("刘备") and text.contains("char-player-001") and text.contains("北门守军每夜三更换防"), "A Context shows Player Character knows F")
	_check(not text.contains("孙权"), "A Context preserves asymmetry: NPC A has no provenance")
	worker.shutdown()
	worker.queue_free()


## B：后续 accepted Narrative 明确告诉 NPC A 事实 F → NPC A 获得 provenance；
## 后续 Context 现在显示 NPC A 知道 F。
func _test_later_disclosure() -> void:
	var runtime := ControlledRuntime.new()
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	_accept(runtime, "我独自查看北门守军的换防记录。", "你从记录中发现北门守军每夜三更换防。")
	await process_frame
	stub.simulate_delta('{"changes":[],"knowledge_events":[{"knower_id":"char-player-001","fact":"北门守军每夜三更换防。","basis":"discovered"}]}')
	stub.simulate_completed()
	await process_frame
	_accept(runtime, "我把换防记录告诉孙权。", "孙权听完，记下了北门守军每夜三更换防。")
	await process_frame
	stub.simulate_delta('{"changes":[],"knowledge_events":[{"knower_id":"char-npc-002","fact":"北门守军每夜三更换防。","basis":"told"}]}')
	stub.simulate_completed()
	await process_frame
	_check(worker.last_result.status == "committed" and runtime.commit_count == 2, "B later disclosure commits second knowledge record")
	var projected := WorldTurnContext.new().project(runtime.world_state, runtime.conversation.get_durable_accepted_entries())
	var text := String(projected.context_text)
	_check(text.contains("刘备") and text.contains("孙权"), "B Context now shows both actors")
	_check(text.contains("孙权") and text.contains("[told] 北门守军每夜三更换防"), "B NPC A gains provenance for F")
	worker.shutdown()
	worker.queue_free()


## C：machine 响应含 non-roster knower_id → 不得创建 durable knowledge authority。
func _test_unknown_actor_rejection() -> void:
	var runtime := ControlledRuntime.new()
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	_accept(runtime, "我查看四周。", "四周安静。")
	await process_frame
	stub.simulate_delta('{"changes":[],"knowledge_events":[{"knower_id":"char-unknown-999","fact":"虚构的幕后事实。","basis":"witnessed"},{"knower_id":"char-player-001","fact":"玩家亲眼看到江面巡逻船。","basis":"witnessed"}]}')
	stub.simulate_completed()
	await process_frame
	_check(worker.last_result.status == "committed", "C valid roster event still commits")
	var knowledge_records := runtime.world_state.living_world.get("knowledge_turns_by_index", {}) as Dictionary
	var events: Array = (knowledge_records.values()[0] as Dictionary).events
	_check(events.size() == 1 and String(events[0].knower_id) == "char-player-001", "C unknown actor ID is discarded and never becomes durable authority")
	_check(int(worker.last_result.get("knowledge_dropped", 0)) >= 1, "C dropped unknown event is counted")
	worker.shutdown()
	worker.queue_free()


## D：valid changes + invalid/oversized/malformed knowledge_events → changes 仍提交；
## 无无效 knowledge 记录；accepted Narrative 不受影响。
func _test_knowledge_parse_isolation() -> void:
	var runtime := ControlledRuntime.new()
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	_accept(runtime, "我修好了村口被冲毁的木桥。", "村民确认木桥已经恢复通行。")
	await process_frame
	stub.simulate_delta('{"changes":["村口木桥已修复并恢复通行。"],"knowledge_events":[{"knower_id":"","fact":"","basis":"invalid"},{"knower_id":"char-player-001","fact":"x","basis":"not_a_basis"},"not-an-object"]}')
	stub.simulate_completed()
	await process_frame
	_check(worker.last_result.status == "committed" and runtime.commit_count == 1, "D valid changes commit despite invalid knowledge_events")
	var records := runtime.world_state.living_world.semantic_turns_by_index as Dictionary
	_check(records.size() == 1, "D G5-01 consequence record committed")
	_check(not runtime.world_state.living_world.has("knowledge_turns_by_index"), "D no invalid knowledge record created")
	_check(runtime.conversation.get_durable_accepted_entries().size() == 1, "D accepted Narrative unaffected")
	_check(int(worker.last_result.get("knowledge_dropped", 0)) >= 3, "D all invalid knowledge events dropped")
	worker.shutdown()
	worker.queue_free()


## E：无 durable world changes 但有有效 post-T0 知识获取 → 一次原子 mutation 只含知识记录。
func _test_knowledge_only_mutation() -> void:
	var runtime := ControlledRuntime.new()
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	_accept(runtime, "我独自查看北门守军的换防记录。", "你从记录中发现北门守军每夜三更换防。")
	await process_frame
	stub.simulate_delta('{"changes":[],"knowledge_events":[{"knower_id":"char-player-001","fact":"北门守军每夜三更换防。","basis":"discovered"}]}')
	stub.simulate_completed()
	await process_frame
	_check(runtime.commit_count == 1, "E knowledge-only result makes one atomic mutation")
	_check(not runtime.world_state.living_world.has("semantic_turns_by_index") or (runtime.world_state.living_world.semantic_turns_by_index as Dictionary).is_empty(), "E no world consequence record when changes is empty")
	_check((runtime.world_state.living_world.knowledge_turns_by_index as Dictionary).size() == 1, "E knowledge record present in same snapshot")
	worker.shutdown()
	worker.queue_free()


## F：同一 accepted 版本不重复知识；Save/reopen 保留；stale hash 不投影。
func _test_replay_reopen_hash_matching() -> void:
	var runtime := ControlledRuntime.new()
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	_accept(runtime, "我独自查看北门守军的换防记录。", "你从记录中发现北门守军每夜三更换防。")
	await process_frame
	stub.simulate_delta('{"changes":[],"knowledge_events":[{"knower_id":"char-player-001","fact":"北门守军每夜三更换防。","basis":"discovered"}]}')
	stub.simulate_completed()
	await process_frame
	_check(runtime.commit_count == 1, "F first materialization commits")
	worker.consider_latest_accepted_turn()
	await process_frame
	_check(stub.requests.size() == 1 and runtime.commit_count == 1 and worker.last_result.status == "already_materialized", "F same accepted version replay does not duplicate knowledge")
	worker.shutdown()
	worker.queue_free()

	# Save/reopen：world_state 保留知识记录。
	var reopened := ControlledRuntime.new()
	reopened.world_state = runtime.world_state.duplicate(true)
	reopened.conversation = runtime.conversation
	var projected := WorldTurnContext.new().project(reopened.world_state, reopened.conversation.get_durable_accepted_entries())
	_check(String(projected.context_text).contains("北门守军每夜三更换防"), "F Save/reopen preserves knowledge record in Context")

	# stale hash：替换 accepted GM 文本后旧知识不投影。
	var stale_entries: Array = [{"turn_index": 0, "player_text": "我独自查看北门守军的换防记录。", "gm_text": "替换后的不同叙事。"}]
	var stale_projected := WorldTurnContext.new().project(reopened.world_state, stale_entries)
	_check(not String(stale_projected.context_text).contains("北门守军每夜三更换防"), "F stale knowledge record whose source GM hash no longer matches is excluded from Context")


func _accept(runtime: ControlledRuntime, player: String, gm: String) -> void:
	runtime.conversation.begin_turn(player)
	runtime.conversation.append_delta(gm)
	runtime.conversation.complete_generation()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G5-02M1 FOCUSED PASS | %s" % label)
	else:
		_failures += 1
		push_error("G5-02M1 FOCUSED FAIL | %s" % label)
