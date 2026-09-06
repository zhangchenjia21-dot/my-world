extends SceneTree

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const World := preload("res://src/世界回合/L3_外交层/世界回合公开接口.gd")
const Bridge := preload("res://src/世界回合/L3_外交层/人物身份桥公开接口.gd")
const Curator := preload("res://src/信息整理/L3_外交层/信息整理公开接口.gd")
const Safe := preload("res://src/信息整理/L3_外交层/角色经历投影公开接口.gd")
const Stub := preload("res://tests/g5_01/世界回合语义桩适配器.gd")
const NO_CHANGE := {"character": null, "experiences": []}
var failures := 0
var checks := 0
var directory := ""
var runtime: RefCounted
var worker: Node
var semantic: Node
var curator: Node
var curation: Node

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="):
			directory = arg.trim_prefix("--root=")
	if not directory.contains("mw017"):
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(directory)
	runtime = Runtime.new()
	check(runtime.open_current_game(directory.path_join("identity.sqlite")).success, "production SQLite opens")
	check(runtime.commit_world_mutation_durably("setup", "setup-node", setup()).success, "task-local setup")
	compose()
	await frames()
	check(curation.busy and semantic.requests.is_empty(), "T0 initial starts without opening or semantic")
	complete(curation, {"character": Safe.project_session(runtime).character, "experiences": []})
	await frames()
	var initial := Safe.project_session(runtime)
	runtime.conversation.begin_gm_opening()
	runtime.conversation.append_delta("陈安在门外等候。")
	check(runtime.complete_active_generation_durably().success, "opening accepted")
	await frames()
	check(semantic.requests.is_empty() and curation.requests.size() == 1, "GM-only opening skipped by both lived lanes")
	var before: Dictionary = runtime.create_save_point("before people")
	check(before.success, "save before learning")

	accept("我询问粮商。", "陈安说明粮价。")
	await frames()
	check(semantic.busy and not curation.busy, "lived curator waits for semantic")
	worker.consider_latest_accepted_turn()
	await frames()
	check(not curation.busy, "already_attempted does not release barrier")
	var refs := request_refs(semantic.requests[-1])
	check(refs.size() == 3, "distinct same-name NPC refs; no Player/stale actor ref")
	check(not JSON.stringify(semantic.requests[-1]).contains("SECRET_PROFILE"), "resolver input has no raw profile expansion")
	var head: String = runtime.active_head_id
	complete(semantic, {"changes": [], "people_bindings": [{"actor_ref": refs[1], "gm_span": {"start": 0, "length": 2}}]})
	var receipt := Bridge.current_receipt(runtime, 1)
	check(receipt.status == "resolved" and receipt.bindings[0].local_character_id == "npc-b", "exact second same-name ref persists npc-b")
	check(runtime.active_head_id != head and not runtime.world_state.living_world.has("semantic_turns_by_index") and not runtime.world_state.living_world.has("knowledge_turns_by_index"), "identity-only single commit has no fabricated facts")
	await frames()
	check(curation.busy, "durable terminal releases same-turn curator")
	check(not JSON.stringify(curation.requests[-1]).contains("People Actor References"), "MW017 curation content contract unchanged")
	complete(curation, NO_CHANGE)
	await frames()
	check(Safe.project_session(runtime) == initial, "no-change Character/Experiences unchanged")
	var bridge := Bridge.request_evidence(runtime, 1)
	check(bridge.evidence[0].quote == "陈安" and bridge.bindings.values() == ["npc-b"], "public bridge re-slices accepted span and privately maps ID")
	for secret: String in ["SECRET_PROFILE", "PRIVATE_KNOWLEDGE", "PRIVATE_PLAN", "HIDDEN_EVOLUTION", "SOURCE_CURRENT"]:
		check(not JSON.stringify(bridge).contains(secret), "safe bridge excludes " + secret)
	var same_snapshot := Bridge.current_receipt(runtime, 1)
	var changed_world: Dictionary = runtime.world_state.duplicate(true)
	changed_world.stable_npcs[1].game_local_material.profile_text = "CHANGED_PRIVATE_SECRET"
	check(runtime.commit_world_mutation_durably("hidden", "hidden-node", changed_world).success, "hidden-only mutation")
	check(Bridge.current_receipt(runtime, 1) == same_snapshot, "hidden profile changes do not alter receipt")
	var saved: Dictionary = runtime.create_save_point("bound")
	check(saved.success, "save bound receipt")
	# 新候选里 invalid、完全相同 material、重复 ref 都不能产生 ordinal 漂移。
	accept("我请她带路。", "沈青答应带你渡河。")
	await frames()
	head = runtime.active_head_id
	complete(semantic, {"changes": [], "new_actor_candidates": [
		{"candidate_ref": "bad", "display_name": 7, "profile_text": "bad"},
		{"candidate_ref": "first", "display_name": "沈青", "profile_text": "摆渡人"},
		{"candidate_ref": "duplicate", "display_name": "沈青", "profile_text": "摆渡人"},
		{"candidate_ref": "collision", "display_name": "甲", "profile_text": "甲的材料"},
		{"candidate_ref": "collision", "display_name": "乙", "profile_text": "乙的材料"}],
		"people_bindings": [
			{"candidate_ref": "bad", "gm_span": {"start": 0, "length": 2}},
			{"candidate_ref": "duplicate", "gm_span": {"start": 0, "length": 2}},
			{"candidate_ref": "collision", "gm_span": {"start": 0, "length": 2}}]})
	receipt = Bridge.current_receipt(runtime, 2)
	check(receipt.bindings.size() == 1, "rejected/duplicate-ref candidates cannot drift")
	var new_id: String = receipt.bindings[0].local_character_id
	var actors: Array = runtime.world_state.stable_npcs.filter(func(a: Dictionary) -> bool: return a.local_character_id == new_id)
	check(actors.size() == 1 and actors[0].game_local_material.display_name == "沈青", "new candidate minted then exact binding resolves")
	check(runtime.active_head_id != head and runtime.world_state.stable_npcs.size() == 7, "normalized material dedupe keeps one new 沈青")
	# 读取同一次 mutation 的 Timeline snapshot 证明两类数据原子落盘。
	var node: Dictionary = runtime.persistence.get_timeline_node(runtime.game_id, runtime.active_head_id)
	check(node.success and node.world_state.stable_npcs.any(func(a: Dictionary) -> bool: return a.local_character_id == new_id) and node.world_state.living_world.people_identity_turns_by_index["2"].id == receipt.id, "one durable node contains actors and receipt together")
	await frames()
	complete(curation, NO_CHANGE)
	await frames()

	accept("我看向陈安。", "陈安点头。")
	await frames()
	complete(semantic, {"changes": [], "people_bindings": []})
	receipt = Bridge.current_receipt(runtime, 3)
	check(receipt.status == "empty", "ambiguous same-name model no-binding stays empty; no Program matching")
	await frames()
	complete(curation, NO_CHANGE)
	await frames()
	accept("我辨认来人。", "来人没有回答。")
	await frames()
	refs = request_refs(semantic.requests[-1])
	complete(semantic, {"changes": [], "people_bindings": [
		{"actor_ref": "npc-a", "gm_span": {"start": 0, "length": 2}},
		{"actor_ref": "player", "gm_span": {"start": 0, "length": 2}},
		{"actor_ref": "stale", "gm_span": {"start": 0, "length": 2}},
		{"actor_ref": refs[0], "gm_span": {"start": -1, "length": 2}},
		{"actor_ref": refs[0], "gm_span": {"start": 0.5, "length": 2}},
		{"actor_ref": refs[0], "gm_span": {"start": 0, "length": 601}},
		{"actor_ref": refs[0], "gm_span": {"start": 999, "length": 1}}]})
	check(Bridge.current_receipt(runtime, 4).status == "empty", "unknown/canonical/Player/stale refs and malformed spans rejected fail-soft")
	await frames()
	complete(curation, NO_CHANGE)
	await frames()

	var old_id: String = Bridge.current_receipt(runtime, 4).id
	# correction 使用实际 Player correction → durable completion，不伪造 accepted 信号。
	runtime.conversation.correct_latest("更正我的输入")
	runtime.conversation.append_delta("来人没有回答。")
	check(runtime.complete_active_generation_durably().success, "corrected Player+GM pair durably accepted")
	check(Bridge.current_receipt(runtime, 4).is_empty(), "same GM / different Player invalidates full-prefix receipt")
	await frames()
	complete(semantic, {"changes": []})
	check(Bridge.current_receipt(runtime, 4).id != old_id, "new accepted corrected prefix commits new receipt")
	await frames()
	complete(curation, NO_CHANGE)
	await frames()

	for mode: String in ["failure", "timeout", "cancel", "malformed", "synchronous"]:
		semantic.synchronous_failure = mode == "synchronous"
		accept("继续 " + mode, "这一回合仍已接受。")
		await frames()
		if mode != "synchronous":
			check(not curation.busy, mode + " awaits terminal")
		if mode == "failure":
			semantic.simulate_failed()
		elif mode == "timeout":
			worker._timer.start(0.01)
			await create_timer(0.03).timeout
			worker._timer.wait_time = 120.0
		elif mode == "cancel":
			semantic.cancel()
		elif mode == "malformed":
			semantic.simulate_delta("invalid")
			semantic.simulate_completed()
		await frames()
		check(curation.busy and Bridge.current_receipt(runtime, runtime.conversation.get_durable_accepted_entries().size() - 1).is_empty(), mode + " releases curator without People evidence")
		complete(curation, NO_CHANGE)
		await frames()
		check(runtime.conversation.begin_turn("下一行动") != null, mode + " Narrative still playable")
		runtime.conversation.cancel_generation()
	semantic.synchronous_failure = false

	accept("等待", "沈青等着你。")
	await frames()
	var old_delta: Callable = worker._provider_callbacks.text_delta
	var old_complete: Callable = worker._provider_callbacks.completed
	var terminal_count := []
	worker.opportunity_terminal.connect(func(r: Dictionary) -> void: terminal_count.append(r))
	check(runtime.restore_save_point(before.save_id).success, "Restore while semantic active")
	var restored_head: String = runtime.active_head_id
	old_delta.call('{"changes":[]}')
	old_complete.call()
	await frames()
	check(runtime.active_head_id == restored_head and terminal_count.is_empty() and not curation.busy, "old epoch cannot commit or release stale curator")
	check(Bridge.current_receipt(runtime, 1).is_empty(), "Restore before learning removes receipt")
	accept("新行动", "陈安回答。")
	await frames()
	old_delta.call('{"changes":["STALE_CALLBACK"]}')
	old_complete.call()
	check(semantic.busy and not curation.busy and runtime.active_head_id == restored_head, "late saved callbacks cannot act on new request")
	complete(semantic, {"changes": []})
	await frames()
	complete(curation, NO_CHANGE)
	await frames()
	check(runtime.restore_save_point(saved.save_id).success, "Restore bound save")
	check(Bridge.current_receipt(runtime, 1) == same_snapshot, "Restore reconstructs exact old player identity receipt")
	var db: String = runtime.database_path
	teardown()
	runtime.close()
	runtime = Runtime.new()
	check(runtime.open_existing_game(db).success, "reopen production database")
	compose()
	await frames()
	check(semantic.requests.is_empty() and curation.requests.is_empty(), "reopen rendering makes no Provider calls")
	worker.consider_latest_accepted_turn()
	check(Bridge.current_receipt(runtime, 1) == same_snapshot and semantic.requests.is_empty(), "durable receipt replay without another call")
	runtime.conversation.retry_or_regenerate_latest()
	check(not Bridge.current_receipt(runtime, 1).is_empty(), "provisional Regenerate preserves still-accepted receipt")
	runtime.conversation.append_delta("新版本中没有可辨认的人。")
	check(runtime.complete_active_generation_durably().success, "replacement accepted")
	check(Bridge.current_receipt(runtime, 1).is_empty(), "accepted Regenerate immediately invalidates superseded receipt")
	await frames()
	complete(semantic, {"changes": []})
	await frames()
	complete(curation, NO_CHANGE)
	await frames()
	teardown()
	runtime.close()
	# 旧 Game 在安装前已有无 receipt 历史，重开以及下一回合均不能触发历史 backfill。
	runtime = Runtime.new()
	check(runtime.open_current_game(directory.path_join("legacy.sqlite")).success, "legacy database")
	runtime.commit_world_mutation_durably("legacy-setup", "legacy-node", setup())
	accept("旧行动", "旧叙事人物。")
	compose()
	await frames()
	complete(curation, {"character": Safe.project_session(runtime).character, "experiences": []})
	await frames()
	worker.consider_latest_accepted_turn()
	check(semantic.requests.is_empty() and Bridge.current_receipt(runtime, 0).is_empty(), "legacy missing collection valid, explicit reopen consideration does not backfill")
	accept("新行动", "新叙事人物。")
	await frames()
	check(semantic.requests.size() == 1 and not curation.busy, "only newly accepted opportunity enters barrier")
	complete(semantic, {"changes": []})
	await frames()
	check(JSON.parse_string(curation.requests[-1][1].content).accepted_narrative == "新叙事人物。", "old missed lived curation is not retrospectively requested")
	complete(curation, NO_CHANGE)
	await frames()
	check(not runtime.world_state.living_world.people_identity_turns_by_index.has("0"), "no identity history backfill")
	accept("检验跨度上限", "甲".repeat(600))
	await frames()
	refs = request_refs(semantic.requests[-1])
	var bounded: Array = [
		{"actor_ref": refs[0], "gm_span": {"start": 0, "length": 601}},
		{"actor_ref": refs[0], "gm_span": {"start": 0, "length": 2}, "cue": "PRIVATE_KNOWLEDGE"},
		{"actor_ref": refs[0], "gm_span": {"start": 0, "length": 600}}]
	for i: int in range(9):
		bounded.append({"actor_ref": refs[0], "gm_span": {"start": i, "length": 1}})
	var count_before: Dictionary = runtime.persistence.timeline_node_count(runtime.game_id)
	complete(semantic, {"changes": [], "people_bindings": bounded})
	receipt = Bridge.current_receipt(runtime, 2)
	check(receipt.bindings.size() == 8 and receipt.bindings[0].gm_span.length == 600, "8 binding / 600 Unicode character ceilings; free cue rejected")
	var count_after: Dictionary = runtime.persistence.timeline_node_count(runtime.game_id)
	check(count_after.node_count == count_before.node_count + 1, "identity-only outcome adds exactly one durable node")
	await frames()
	complete(curation, NO_CHANGE)
	await frames()
	var corrupt: Dictionary = runtime.world_state.duplicate(true)
	corrupt.living_world.people_identity_turns_by_index["2"].bindings[0].local_character_id = "player"
	runtime.commit_world_mutation_durably("tampered", "tampered-node", corrupt)
	check(Bridge.current_receipt(runtime, 2).is_empty() and Bridge.request_evidence(runtime, 2).is_empty(), "corrupt durable binding fails closed at public seam")
	teardown()
	runtime.close()
	await frames()
	print("MW-017 FOCUSED checks=%d failures=%d" % [checks, failures])
	quit(0 if failures == 0 else 1)

func setup() -> Dictionary:
	var actors: Array = []
	for pair: Array in [["npc-a", "陈安"], ["npc-b", "陈安"], ["npc-c", "县尉"]]:
		actors.append({"local_character_id": pair[0], "role": "stable_npc", "origin": {"kind": "creation_authored"},
			"game_local_material": {"display_name": pair[1], "profile_text": "SECRET_PROFILE"}})
	actors.append({"local_character_id": "stale", "role": "stable_npc", "origin": {"kind": "runtime_narrative", "source_turn_index": 99, "source_gm_sha256": "bad"}, "game_local_material": {"display_name": "未来人", "profile_text": "SECRET_PROFILE"}})
	return {"player_character": {"local_character_id": "player", "source_projection": {
		"display_name": "玩家", "player_profile": {"headline": "玩家", "summary": "学习中的旅人", "groups": [{"group_id": "abilities", "title": "能力", "items": ["常识"]}]}}},
		"stable_npcs": actors, "living_world": {"schema_version": "living_world.v0.1",
		"agency_cycles_by_source_turn": {"secret": "PRIVATE_PLAN"}, "world_evolution_events_by_turn": {"secret": "HIDDEN_EVOLUTION"}}}

func compose() -> void:
	semantic = Stub.new()
	worker = World.new(runtime, semantic)
	root.add_child(worker)
	curation = Stub.new()
	curator = Curator.new(runtime, curation, worker)
	root.add_child(curator)

func teardown() -> void:
	curator.shutdown()
	worker.shutdown()
	curator.queue_free()
	worker.queue_free()

func request_refs(messages: Array) -> Array:
	var content: String = messages[1].content
	var block := content.split("People Actor References (identity only)\n")[1]
	var refs: Array = []
	for line: String in block.split("\n"):
		var parsed: Variant = JSON.parse_string(line)
		if parsed is Dictionary:
			refs.append(parsed.actor_ref)
	return refs

func accept(player: String, gm: String) -> void:
	check(runtime.conversation.begin_turn(player) != null, "begin player turn")
	runtime.conversation.append_delta(gm)
	check(runtime.complete_active_generation_durably().success, "durable accepted Narrative")

func complete(stub: Node, result: Dictionary) -> void:
	check(stub.busy, "expected request active")
	stub.simulate_delta(JSON.stringify(result))
	stub.simulate_completed()

func frames() -> void:
	await process_frame
	await process_frame

func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("MW-017 FAIL " + label)
	else:
		print("MW-017 PASS " + label)
