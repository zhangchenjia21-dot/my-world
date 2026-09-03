extends SceneTree

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const WorldTurn := preload("res://src/世界回合/L3_外交层/世界回合公开接口.gd")
const Opening := preload("res://src/首次开场/L3_外交层/首次开场公开接口.gd")
const StubAdapter := preload("res://tests/g5_01/世界回合语义桩适配器.gd")

const OLD_CHANGE := "OLD_SEMANTIC_BRIDGE_DAMAGED"
const NEW_CHANGE := "NEW_SEMANTIC_BRIDGE_REPAIRED"
const FUTURE_CHANGE := "FUTURE_SEMANTIC_GATE_OPEN"

var _failures := 0
var _root_path := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root_path = _argument("--root=")
	if _root_path.find("g5_01") < 0:
		return _finish_with_failure("必须提供 task-owned g5_01 root")
	DirAccess.make_dir_recursive_absolute(_root_path)
	await _test_correction_save_restore_and_context()
	print("G5-01 TIMELINE | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)


func _test_correction_save_restore_and_context() -> void:
	var database_path := _root_path.path_join("world-turn-timeline.sqlite")
	var runtime := Runtime.new()
	_check(runtime.open_current_game(database_path).success, "production v4 Runtime opens task-owned Game")
	var setup_commit := runtime.commit_world_mutation_durably("g5-01-setup", "g5-01-setup-node", _minimal_game_setup(runtime.game_id))
	_check(setup_commit.success, "task-owned Game receives a valid G4-compatible setup without schema migration")
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	_accept_durably(runtime, "我查看河桥。", "河桥已被洪水冲断。")
	await process_frame
	_complete_analysis(stub, OLD_CHANGE)
	await process_frame
	_check(runtime.world_state.has("living_world") and _current_change(runtime) == OLD_CHANGE, "first semantic record commits through production World mutation")

	runtime.conversation.correct_latest("我组织村民修复河桥。")
	runtime.conversation.append_delta("村民已经修复河桥，商路重新通行。")
	_check(runtime.complete_active_generation_durably().success, "latest-turn correction becomes durable before semantic analysis")
	await process_frame
	var opening := Opening.new(runtime, StubAdapter.new())
	root.add_child(opening)
	runtime.conversation.begin_turn("我检查新桥。")
	var before_new := opening.assemble_continuation_messages()
	_check(before_new.success and not JSON.stringify(before_new.get("messages", [])).contains(OLD_CHANGE), "stale old GM hash is excluded immediately after accepted replacement")
	runtime.conversation.cancel_generation()
	_complete_analysis(stub, NEW_CHANGE)
	await process_frame
	_check(_current_change(runtime) == NEW_CHANGE and _record_count(runtime) == 1, "rematerialization replaces same turn-index record without duplicate")

	var save := runtime.create_save_point("语义快照")
	_check(save.success, "Save captures matching Conversation and semantic World snapshot")
	_accept_durably(runtime, "我打开北门。", "北门已经打开，商队开始入城。")
	await process_frame
	_complete_analysis(stub, FUTURE_CHANGE)
	await process_frame
	_check(_record_count(runtime) == 2, "later semantic future commits before Restore")
	var restored := runtime.restore_save_point(String(save.save_id))
	_check(restored.success and runtime.conversation.get_durable_accepted_entries().size() == 1 and _record_count(runtime) == 1, "Save/Restore atomically returns matching Conversation and semantic snapshot")
	runtime.conversation.begin_turn("恢复后继续查看河桥。")
	var continuation := opening.assemble_continuation_messages()
	var serialized := JSON.stringify(continuation.get("messages", []))
	_check(continuation.success and serialized.contains(NEW_CHANGE), "subsequent Provider request contains committed matching World change")
	_check(not serialized.contains(OLD_CHANGE) and not serialized.contains(FUTURE_CHANGE), "subsequent request excludes stale and restored-away future semantic memory")
	runtime.conversation.cancel_generation()
	worker.shutdown()
	worker.queue_free()
	opening.queue_free()
	runtime.close()
	await process_frame

	var reopened := Runtime.new()
	_check(reopened.open_existing_game(database_path).success and reopened.conversation.get_durable_accepted_entries().size() == 1 and _record_count(reopened) == 1, "close/reopen preserves restored semantic snapshot coherently")
	_check(_current_change(reopened) == NEW_CHANGE, "reopen retains replacement consequence, not stale/future records")
	reopened.close()


func _minimal_game_setup(game_id: String) -> Dictionary:
	var section := {"section_id": "safe", "title": "安全起始语义", "section_type": "premise", "disclosure": "public", "content": "这是一份 task-owned 的最小 G4 兼容世界起始事实。"}
	return {
		"schema_version": "game_local_setup.v0.1",
		"creation_origin": {},
		"game": {"game_id": game_id, "display_name": "G5-01 测试局", "control_mode": "Narrative", "opening_supplement": ""},
		"setup_ancestry": {},
		"selected_entry_id": null,
		"world": {
			"local_world_id": "local-world-g5-01",
			"provenance": {"asset_id": "task.world", "generation_fingerprint": "task-generation"},
			"source_projection": {"display_name": "测试世界", "world_instructions": "", "gm_instructions": "", "semantic_sections": [section]},
		},
		"player_character": {
			"local_character_id": "local-player-g5-01",
			"provenance": {"asset_id": "task.player", "generation_fingerprint": "task-generation"},
			"source_projection": {"display_name": "测试玩家", "semantic_sections": [section]},
		},
		"guaranteed_npcs": [],
	}


func _accept_durably(runtime: RefCounted, player: String, gm: String) -> void:
	runtime.conversation.begin_turn(player)
	runtime.conversation.append_delta(gm)
	_check(runtime.complete_active_generation_durably().success, "ordinary Narrative accepted durably")


func _complete_analysis(stub: Node, change: String) -> void:
	stub.simulate_delta(JSON.stringify({"changes": [change]}))
	stub.simulate_completed()


func _record_count(runtime: RefCounted) -> int:
	if not runtime.world_state.has("living_world"):
		return 0
	return (runtime.world_state.living_world.semantic_turns_by_index as Dictionary).size()


func _current_change(runtime: RefCounted) -> String:
	var records := runtime.world_state.living_world.semantic_turns_by_index as Dictionary
	if records.is_empty():
		return ""
	return String(((records.values()[0] as Dictionary).changes as Array)[0])


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G5-01 TIMELINE PASS | %s" % label)
	else:
		_failures += 1
		push_error("G5-01 TIMELINE FAIL | %s" % label)


func _finish_with_failure(message: String) -> void:
	_check(false, message)
	print("G5-01 TIMELINE | done failures=%d" % _failures)
	quit(1)
