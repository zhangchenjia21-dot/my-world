extends SceneTree

## MW-007 Mechanics Consequence Timeline Continuity focused proof。
## 全部经由真实 production seams：Source Managed Library + Final Create materialization +
## 当前游戏会话运行时（SQLite v4）+ 公开D20行动判定流程（受控 RNG）+ G5-01 语义物化流程 +
## Save/Restore + reopen + 首次开场 continuation Context 组装。
## production code 期望零修改；Provider 全部 stub（real Provider calls = 0）。

const SourceLibrary := preload("res://src/source/L3_外交层/Source库公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Adjudication := preload("res://src/行动判定/L3_外交层/行动判定公开接口.gd")
const D20Rules := preload("res://src/行动判定/L0_公理层/公开D20判定规则.gd")
const WorldTurn := preload("res://src/世界回合/L3_外交层/世界回合公开接口.gd")
const Opening := preload("res://src/首次开场/L3_外交层/首次开场公开接口.gd")
const D20Stub := preload("res://tests/g4_07a/首次开场桩适配器.gd")
const SemanticStub := preload("res://tests/g5_01/世界回合语义桩适配器.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

const GROUNDING_MARKER := "Durable Mechanical Resolution"
const V1_CONSEQUENCE := "MW007_V1_CONSEQUENCE 警火已在灯塔顶端点燃，远处哨站进入戒备。"
const V2_BASELINE := "MW007_V2_BASELINE 灯塔下营地休整完毕。"
const V2_CONSEQUENCE := "MW007_V2_CONSEQUENCE 矿道入口被二次塌方封死，救援中断。"
const V2_ACTION_TEXT := "我冒着塌方风险冲进塌陷的矿道抢救受困矿工。"

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
var _runtime_gc: Array = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("mw007") < 0:
		_fail("必须提供 task-owned --root，且路径包含 mw007")
		return _finish()
	DirAccess.make_dir_recursive_absolute(_root)
	await _test_v1_post_consequence_save_reopen_continue()
	await _test_v2_pre_action_restore_rewind()
	_finish()


## V1：action + d20 + Narrative + MW-006 grounding + semantic consequence
## → Save AFTER consequence → close → reopen → 全部恰好一次 → 不 reroll →
## 无 duplicate semantic mutation → 后续 continuation Context 看到有效 consequence。
func _test_v1_post_consequence_save_reopen_continue() -> void:
	var case := _setup_game("v1", "mw007-v1-create")
	var runtime: RefCounted = case.runtime
	var semantic_stub := SemanticStub.new()
	var worker := WorldTurn.new(runtime, semantic_stub)
	root.add_child(worker)
	await process_frame
	var d20_stub := D20Stub.new()
	var rng := DeterministicRng.new([15])
	var adjudication := Adjudication.new(runtime, d20_stub, rng)
	root.add_child(adjudication)
	var started: Dictionary = adjudication.start_action("mw007-v1-action", "我尝试在暴风雨中攀上灯塔顶端点燃警火。")
	_check(started.success and d20_stub.requests.size() == 1, "V1 production adjudication control request starts on real Game")
	d20_stub.simulate_delta(JSON.stringify(_proposal()))
	d20_stub.simulate_completed()
	_check(rng.invocation_count == 1 and d20_stub.requests.size() == 2, "V1 proposal frozen before exactly one Program RNG roll")
	var check := _check_record(runtime, "mw007-v1-action")
	_check(check.success and int(check.check.total) == 17 and String(check.check.outcome) == "success" and not bool(check.check.narrative_accepted), "V1 Program-owned success result is durable before narrative")
	var saved_check: Dictionary = {}
	d20_stub.simulate_delta("警火在灯塔顶端燃起，风雨中远处哨站望见了火光。")
	d20_stub.simulate_completed()
	await process_frame
	await process_frame
	_check(semantic_stub.requests.size() == 1, "V1 accepted narrative wakes exactly one normal G5-01 semantic opportunity")
	var grounding := String((semantic_stub.requests[0][1] as Dictionary).get("content", ""))
	_check(grounding.count(GROUNDING_MARKER) == 1 and grounding.contains(String(check.check.check_id)) and grounding.contains('outcome: "success"') and grounding.contains("- total: 17") and grounding.contains("- selected_roll: 15"), "V1 MW-006 grounding carries the exact authoritative check exactly once")
	semantic_stub.simulate_delta(JSON.stringify({"changes": [V1_CONSEQUENCE]}))
	semantic_stub.simulate_completed()
	await process_frame
	_check(worker.last_result.status == "committed" and _semantic_change(runtime, 0) == V1_CONSEQUENCE, "V1 model-authored consequence commits through existing world mutation seam")
	var accepted_check := _check_record(runtime, "mw007-v1-action")
	_check(accepted_check.success and bool(accepted_check.check.narrative_accepted) and int(accepted_check.check.accepted_turn_index) == 0, "V1 acceptance marker durable on the authoritative check")
	saved_check = accepted_check.check.duplicate(true)
	var save: Dictionary = runtime.create_save_point("后果后存档")
	_check(save.success, "V1 Save created AFTER the consequence")
	runtime.close()
	await process_frame

	var reopened := Runtime.new()
	_check(reopened.open_existing_game(String(case.database_path)).success, "V1 reopen existing Game through production Runtime")
	_runtime_gc.append(reopened)
	var reopened_entries: Array = reopened.conversation.get_durable_accepted_entries()
	_check(reopened_entries.size() == 1 and String(reopened_entries[0].player_text).contains("灯塔") and reopened_entries[0].gm_text.contains("警火"), "V1 accepted Conversation still contains the action/Narrative exactly once")
	var reopened_check := _check_record(reopened, "mw007-v1-action")
	_check(reopened_check.success and JSON.stringify(_norm(reopened_check.check)) == JSON.stringify(_norm(saved_check)), "V1 exact same durable d20 check remains, no reroll/new identity")
	_check(_semantic_change(reopened, 0) == V1_CONSEQUENCE, "V1 semantic consequence remains exactly once")
	var reopen_stub := SemanticStub.new()
	var reopen_worker := WorldTurn.new(reopened, reopen_stub)
	root.add_child(reopen_worker)
	await process_frame
	await process_frame
	_check(reopen_stub.requests.is_empty() and reopen_worker.status_snapshot().busy == false, "V1 reopen alone starts no duplicate semantic request")
	reopen_worker.consider_latest_accepted_turn()
	await process_frame
	_check(reopen_worker.last_result.status == "already_materialized" and reopen_stub.requests.is_empty(), "V1 replay after reopen is idempotent, no duplicate mutation")
	var retry_stub := D20Stub.new()
	var retry_rng := DeterministicRng.new([20])
	var retry := Adjudication.new(reopened, retry_stub, retry_rng)
	root.add_child(retry)
	var replayed: Dictionary = retry.start_action("mw007-v1-action", "我尝试在暴风雨中攀上灯塔顶端点燃警火。")
	_check(replayed.success and String(replayed.status) == "already_accepted" and retry_stub.requests.is_empty() and retry_rng.invocation_count == 0, "V1 same action submit after reopen never rerolls")
	var opening := Opening.new(reopened, D20Stub.new())
	root.add_child(opening)
	reopened.conversation.begin_turn("恢复后继续眺望海岸。")
	var continuation: Dictionary = opening.assemble_continuation_messages()
	var serialized := JSON.stringify(continuation.get("messages", []))
	_check(continuation.success and serialized.contains(V1_CONSEQUENCE) and serialized.contains("## Materialized World Changes"), "V1 continuation Context sees the committed consequence via the normal World Turn seam")
	_check(not serialized.contains(GROUNDING_MARKER) and not serialized.contains(String(saved_check.check_id)), "V1 continuation creates/requires no second mechanics truth")
	reopened.conversation.cancel_generation()
	_retry_cleanup([worker, reopen_worker, retry, opening])
	reopened.close()


## V2：Save BEFORE action → action + d20 + Narrative + consequence → Restore pre-action Save
## → Conversation/consequence/d20 future truth 一并回滚 → 无 ghost grounding →
## continuation 无 restored-away memory → 新行动按既有 identity/RNG 规则执行。
func _test_v2_pre_action_restore_rewind() -> void:
	var case := _setup_game("v2", "mw007-v2-create")
	var runtime: RefCounted = case.runtime
	var semantic_stub := SemanticStub.new()
	var worker := WorldTurn.new(runtime, semantic_stub)
	root.add_child(worker)
	await process_frame
	# 行动前的普通回合 + 语义 consequence，作为 Restore 保留侧。
	runtime.conversation.begin_turn("我在灯塔下休整。")
	runtime.conversation.append_delta("你在灯塔下休整，海风平静。")
	runtime.complete_active_generation_durably()
	await process_frame
	await process_frame
	semantic_stub.simulate_delta(JSON.stringify({"changes": [V2_BASELINE]}))
	semantic_stub.simulate_completed()
	await process_frame
	_check(_semantic_change(runtime, 0) == V2_BASELINE, "V2 baseline consequence commits before Save")
	var save: Dictionary = runtime.create_save_point("行动前存档")
	_check(save.success, "V2 pre-action Save created")
	# CHECK_REQUIRED action（turn 1）
	var d20_stub := D20Stub.new()
	var rng := DeterministicRng.new([7])
	var adjudication := Adjudication.new(runtime, d20_stub, rng)
	root.add_child(adjudication)
	var started: Dictionary = adjudication.start_action("mw007-v2-action", V2_ACTION_TEXT)
	_check(started.success, "V2 action starts after Save")
	d20_stub.simulate_delta(JSON.stringify(_proposal()))
	d20_stub.simulate_completed()
	var check := _check_record(runtime, "mw007-v2-action")
	_check(rng.invocation_count == 1 and check.success and int(check.check.total) == 9 and String(check.check.outcome) == "failure", "V2 losing Program result durable before narrative")
	d20_stub.simulate_delta("矿道二次塌方，你被迫撤出；被困矿工仍未见踪影。")
	d20_stub.simulate_completed()
	await process_frame
	await process_frame
	_check(semantic_stub.requests.size() == 2, "V2 grounded semantic opportunity fires for the mechanics turn")
	var grounding := String((semantic_stub.requests[1][1] as Dictionary).get("content", ""))
	_check(grounding.contains(String(check.check.check_id)) and grounding.contains('outcome: "failure"') and grounding.contains("- total: 9"), "V2 MW-006 grounding presents the authoritative losing result")
	semantic_stub.simulate_delta(JSON.stringify({"changes": [V2_CONSEQUENCE]}))
	semantic_stub.simulate_completed()
	await process_frame
	_check(_semantic_change(runtime, 1) == V2_CONSEQUENCE and _check_record(runtime, "mw007-v2-action").check.narrative_accepted == true, "V2 action/Narrative/consequence/check all exist before Restore")
	var future_check_id := String(check.check.check_id)
	var restored: Dictionary = runtime.restore_save_point(String(save.save_id))
	_check(restored.success, "V2 Restore to pre-action Save succeeds")
	_check(runtime.conversation.get_durable_accepted_entries().size() == 1 and _semantic_record_count(runtime) == 1, "V2 restored Conversation and semantic consequence no longer contain the later turn")
	_check(_check_record(runtime, "mw007-v2-action").success == false, "V2 d20 check created after Save is rewound by the same World snapshot ownership")
	_check(D20Rules.matching_accepted_check_for_turn(runtime.world_state, 1, V2_ACTION_TEXT).is_empty(), "V2 no ghost mechanics grounding can match the restored-away turn")
	runtime.conversation.begin_turn("恢复后的下一步行动。")
	var continuation: Dictionary = opening_continuation(runtime)
	var serialized := JSON.stringify(continuation.get("messages", []))
	_check(serialized.contains(V2_BASELINE) and not serialized.contains(V2_CONSEQUENCE) and not serialized.contains("被困矿工仍未见踪影") and not serialized.contains(GROUNDING_MARKER) and not serialized.contains(future_check_id), "V2 continuation Context contains neither restored-away consequence nor stale mechanics memory")
	runtime.conversation.cancel_generation()
	# 同一 action_id 重放：既有 identity 规则 fail-loud，不静默复用 restored-away future truth。
	var replay_stub := D20Stub.new()
	var replay_rng := DeterministicRng.new([19])
	var replay := Adjudication.new(runtime, replay_stub, replay_rng)
	root.add_child(replay)
	var replay_started: Dictionary = replay.start_action("mw007-v2-action", V2_ACTION_TEXT)
	_check(replay_started.success and replay_stub.requests.size() == 1, "V2 same action_id after restore starts a fresh control request (no durable check reused)")
	replay_stub.simulate_delta(JSON.stringify(_proposal()))
	replay_stub.simulate_completed()
	await process_frame
	_check(String(replay.last_result.get("code", "")) == "check_persistence_failed" and _check_record(runtime, "mw007-v2-action").success == false and runtime.conversation.get_durable_accepted_entries().size() == 1, "V2 replayed action_id hits existing identity rule and creates no silent truth/narrative")
	# 新 action_id：按既有规则全新判定，不复用 restored-away future truth。
	var new_stub := D20Stub.new()
	var new_rng := DeterministicRng.new([20])
	var fresh := Adjudication.new(runtime, new_stub, new_rng)
	root.add_child(fresh)
	var fresh_started: Dictionary = fresh.start_action("mw007-v2-action-b", V2_ACTION_TEXT)
	_check(fresh_started.success, "V2 new action after restore starts normally")
	new_stub.simulate_delta(JSON.stringify(_proposal()))
	new_stub.simulate_completed()
	var new_check := _check_record(runtime, "mw007-v2-action-b")
	_check(new_check.success and int(new_check.check.selected_roll) == 20 and String(new_check.check.check_id) != future_check_id, "V2 fresh action rolls under existing RNG rules with a new identity")
	new_stub.simulate_delta("你抓住塌方间隙把矿工拖出，众人撤到安全处。")
	new_stub.simulate_completed()
	await process_frame
	await process_frame
	var new_grounding := String((semantic_stub.requests[-1][1] as Dictionary).get("content", ""))
	_check(new_grounding.contains(String(new_check.check.check_id)) and not new_grounding.contains(future_check_id), "V2 fresh grounding binds only the new authoritative check, no ghost mechanics")
	semantic_stub.simulate_delta(JSON.stringify({"changes": ["MW007_V2_NEW_CONSEQUENCE 矿工获救，矿道入口仍被封闭。"]}))
	semantic_stub.simulate_completed()
	await process_frame
	_check(_semantic_change(runtime, 1) == "MW007_V2_NEW_CONSEQUENCE 矿工获救，矿道入口仍被封闭。" and _semantic_record_count(runtime) == 2, "V2 post-Restore consequence materializes through the normal seam exactly once")
	worker.shutdown()
	_retry_cleanup([worker, replay, fresh])
	runtime.close()


func _setup_game(case_name: String, creation_id: String) -> Dictionary:
	var case_root := _root.path_join(case_name)
	var fixture := Fixture.new()
	fixture.reset_directory(case_root)
	var installed: Dictionary = fixture.install_real_assets(case_root.path_join("source-library"))
	if not installed.success:
		_fail("V %s real Source assets install | %s" % [case_name.to_upper(), JSON.stringify(installed)])
		return {"runtime": null, "database_path": ""}
	var library: RefCounted = installed.library
	var expansion: Dictionary = library.install_expansion_pack("res://tests/fixtures/g4_08m1/判定与检定_公开d20")
	if not expansion.success:
		_fail("V %s expansion install" % case_name.to_upper())
		return {"runtime": null, "database_path": ""}
	var creation := Creation.new(library)
	creation.select_world(fixture.find_generation(installed.installed, "world.han_end.unsettled_realm"))
	creation.select_entry("t0-208-red-cliffs-eve")
	creation.set_expansion(expansion.generation, true)
	creation.select_player(fixture.find_generation(installed.installed, "character.han_end.liu_bei"))
	creation.set_settings("MW-007", "Light", "")
	var creator := FinalCreate.new(library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games"))
	var created: Dictionary = creator.create_or_resume(creation_id, creation.composition_snapshot())
	if not created.success:
		_fail("V %s Final Create | %s" % [case_name.to_upper(), JSON.stringify(created)])
		return {"runtime": null, "database_path": ""}
	var runtime := Runtime.new()
	var opened: Dictionary = runtime.open_existing_game(String(created.database_path))
	if not opened.success or (runtime.world_state.get("expansions", []) as Array).is_empty():
		_fail("V %s runtime open with materialized capability" % case_name.to_upper())
		return {"runtime": null, "database_path": ""}
	_runtime_gc.append(runtime)
	return {"runtime": runtime, "database_path": String(created.database_path)}


## SQLite/JSON round-trip 把整数恢复为 integral float；比较前统一数值表示。
func _norm(value: Variant) -> Variant:
	if value is Array:
		var out: Array = []
		for item: Variant in value:
			out.append(_norm(item))
		return out
	if value is Dictionary:
		var out_dict: Dictionary = {}
		for key: Variant in value:
			out_dict[key] = _norm(value[key])
		return out_dict
	if value is float and is_equal_approx(value, floorf(value)):
		return int(value)
	return value


func _proposal() -> Dictionary:
	return {"decision": "CHECK_REQUIRED", "proposal": {
		"intent": "完成本次高风险行动", "dc": 12, "modifier": 2, "stance": "normal",
		"modifier_reason": "来自 Game-local 角色事实", "situation_reason": "存在不确定性与代价",
		"success_intent": "行动达成", "failure_stakes": "暴露并承受后果",
	}}


func _check_record(runtime: RefCounted, action_id: String) -> Dictionary:
	for value: Variant in runtime.world_state.get("expansion_runtime", {}).get("public_d20_checks", []):
		if value is Dictionary and String(value.get("action_id", "")) == action_id:
			return {"success": true, "check": value}
	return {"success": false}


func _semantic_record_count(runtime: RefCounted) -> int:
	if not runtime.world_state.has("living_world"):
		return 0
	return (runtime.world_state.living_world.semantic_turns_by_index as Dictionary).size()


func _semantic_change(runtime: RefCounted, turn_index: int) -> String:
	var records: Dictionary = runtime.world_state.get("living_world", {}).get("semantic_turns_by_index", {})
	if not records.has(str(turn_index)):
		return ""
	return String(((records[str(turn_index)] as Dictionary).changes as Array)[0])


func opening_continuation(runtime: RefCounted) -> Dictionary:
	var opening := Opening.new(runtime, D20Stub.new())
	root.add_child(opening)
	var result: Dictionary = opening.assemble_continuation_messages()
	opening.queue_free()
	return result


func _retry_cleanup(nodes: Array) -> void:
	for node: Variant in nodes:
		if node != null and is_instance_valid(node):
			node.queue_free()


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("MW-007 FOCUSED PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("MW-007 FOCUSED FAIL | %s" % label)


func _finish() -> void:
	print("MW-007 FOCUSED | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
