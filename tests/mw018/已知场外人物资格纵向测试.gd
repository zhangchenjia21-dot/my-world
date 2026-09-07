extends "res://tests/mw018/人物整理卡片纵向测试.gd"

const Receipt := preload("res://src/世界回合/L0_公理层/人物身份回执规则.gd")

# 真实 Runtime / SQLite / 两条生产 lane；模型桩只决定语义，不在测试里替生产做姓名匹配。
func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="):
			directory = arg.trim_prefix("--root=")
	if not directory.contains("mw018"):
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(directory)
	runtime = Runtime.new()
	check(runtime.open_current_game(directory.path_join("known.sqlite")).success, "isolated SQLite")
	check(runtime.commit_world_mutation_durably("setup", "setup-node", setup()).success, "same-name existing actors, no scene-presence metadata")
	compose()
	await frames()
	complete(curation, {"character": Safe.project_session(runtime).character, "experiences": []})
	await frames()
	var initial := Safe.project_session(runtime)

	# 原生产 GM-only 响应形成原格式回执和有效卡片父链。
	accept("询问县尉。", "县尉说他明天出城。")
	await frames()
	var refs := request_refs(semantic.requests[-1])
	complete(semantic, {"changes": [], "people_bindings": [{"actor_ref": refs[2], "gm_span": {"start": 0, "length": 2}}]})
	await frames()
	var legacy := Bridge.current_receipt(runtime, 0)
	check(legacy.schema == Receipt.SCHEMA, "legacy receipt schema remains byte-compatible")
	var legacy_material := legacy.duplicate(true)
	legacy_material.erase("id")
	check(legacy.id == JSON.stringify(legacy_material, "", true).sha256_text(), "legacy ID unchanged")
	var c := person("县尉", "明日出城", "他说自己明天出城。")
	complete(curation, answer([{"actor_ref": input().people_evidence[0].actor_ref, "snapshot": c}]))
	await frames()
	var legacy_curation_id: String = runtime.world_state.information_curation.turns["0"].id
	var before: Dictionary = runtime.create_save_point("legacy")

	# Player 回忆第一个陈安；GM 提及不在场的第二个陈安。Program 仅解析两个精确引用。
	accept("😀我想起粮商陈安。", "另一位陈安仍在远方，今天不在这里。")
	await frames()
	refs = request_refs(semantic.requests[-1])
	check(refs.size() == 4 and not curation.busy, "all existing NPC refs available without presence gate; curator waits")
	complete(semantic, {"changes": [], "people_bindings": [bound(refs[0], "player", 6, 2), bound(refs[1], "gm", 3, 2)]})
	await frames()
	var receipt := Bridge.current_receipt(runtime, 1)
	check(receipt.schema == Receipt.PAIR_SCHEMA and receipt.bindings.size() == 2, "new pair receipt accepted")
	check(receipt.bindings[0].local_character_id == "npc-a" and receipt.bindings[1].local_character_id == "npc-b", "same-name actors bound by exact separate refs")
	var context := input()
	check(context.people_evidence.size() == 2, "both Player and off-screen GM reach same curator")
	for evidence: Dictionary in context.people_evidence:
		check(Contract.keys_exact(evidence, ["actor_ref", "source_role", "source_span", "quote"]), "strict player-safe evidence shape")
		check(evidence.quote == "陈安", "verbatim Unicode source slice including supplementary character offset")
	check(context.people_evidence[0].source_role == "player" and context.people_evidence[1].source_role == "gm", "source role preserved")
	for canary: String in ["npc-a", "npc-b", "npc-c", "SECRET_PROFILE", "PRIVATE_PLAN", "HIDDEN_EVOLUTION", "stable_npcs", "source_projection"]:
		check(not JSON.stringify(context).contains(canary), "curator excludes " + canary)
	var a := person("陈安", "记忆中的粮商", "你想起曾经认识的粮商。")
	var b := person("陈安", "远方的故人", "目前你只知道他还在远方。")
	complete(curation, answer([{"actor_ref": context.people_evidence[0].actor_ref, "snapshot": a}, {"actor_ref": context.people_evidence[1].actor_ref, "snapshot": b}]))
	await frames()
	check(PeopleSafe.project_session(runtime) == [c, a, b], "model can card both off-screen existing people")
	check(runtime.world_state.information_curation.turns["1"].parent == legacy_curation_id and Bridge.current_receipt(runtime, 0) == legacy, "mixed receipt history retains exact legacy dependency")
	check(semantic.requests.size() == 2 and curation.requests.size() == 3, "one semantic plus one lived curator per turn; no third call")

	accept("我又想起粮商陈安。", "你停下脚步，整理记忆。")
	await frames()
	refs = request_refs(semantic.requests[-1])
	complete(semantic, {"changes": [], "people_bindings": [bound(refs[0], "player", 6, 2)]})
	await frames()
	check(input().people_evidence[0].current_snapshot == a, "Player reference receives only exact actor previous safe snapshot")
	var a2 := person("陈安", "熟识的粮商", "你仍记得他的帮助。")
	complete(curation, answer([{"actor_ref": input().people_evidence[0].actor_ref, "snapshot": a2}]))
	await frames()
	check(PeopleSafe.project_session(runtime) == [c, a2, b], "Player evidence updates same card without duplicating identity")

	# 无法解析的 Player 名字没有物化副作用；模型不确定则无绑定。即使伪造姓名/ID引用也无权威。
	var actors_before: Array = runtime.world_state.stable_npcs.duplicate(true)
	accept("我想起幻想中的何某，还有不确定是哪位的陈安。", "你继续思索，没有得到任何确证。")
	await frames()
	complete(semantic, {"changes": [], "new_actor_candidates": [], "people_bindings": [bound("陈安", "player", 0, 2), bound("npc-a", "player", 0, 2), {"candidate_ref": "imaginary", "source_role": "player", "source_span": {"start": 0, "length": 2}}]})
	await frames()
	check(runtime.world_state.stable_npcs == actors_before and input().people_evidence.is_empty(), "unresolved Player-only assertions neither mint actors nor guess bindings")
	complete(curation, answer([]))
	await frames()
	check(PeopleSafe.project_session(runtime) == [c, a2, b], "unresolved name leaves known cards intact")

	accept("听完消息后继续走。", "信使告诉你：沈青已被任命为远方郡守，他仍在任上。门边的士兵让开了路。")
	await frames()
	refs = request_refs(semantic.requests[-1])
	complete(semantic, {"changes": [], "new_actor_candidates": [{"candidate_ref": "remote-person", "display_name": "沈青", "profile_text": "远方新任郡守，仍在任上。"}], "people_bindings": [
		{"candidate_ref": "remote-person", "source_role": "gm", "source_span": {"start": 6, "length": 2}},
		{"candidate_ref": "remote-person", "source_role": "player", "source_span": {"start": 0, "length": 2}}]})
	await frames()
	receipt = Bridge.current_receipt(runtime, 4)
	check(runtime.world_state.stable_npcs.size() == actors_before.size() + 1 and receipt.bindings.size() == 1, "GM-established off-screen actor materializes; Player candidate_ref rejected")
	check(receipt.bindings[0].local_character_id == runtime.world_state.stable_npcs[-1].local_character_id and input().people_evidence[0].quote == "沈青", "same-turn minted exact ID bound before curator")
	var d := person("沈青", "远方的新郡守", "信使说他已任远方郡守。")
	complete(curation, answer([{"actor_ref": input().people_evidence[0].actor_ref, "snapshot": d}]))
	await frames()
	check(PeopleSafe.project_session(runtime) == [c, a2, b, d], "new off-screen card follows model decision")
	var saved: Dictionary = runtime.create_save_point("known people")
	var saved_receipt := Bridge.current_receipt(runtime, 4)

	accept("经过城门。", "士兵在门边让开一步，没有更多交谈。")
	await frames()
	refs = request_refs(semantic.requests[-1])
	complete(semantic, {"changes": [], "people_bindings": [bound(refs[3], "gm", 0, 2)]})
	await frames()
	complete(curation, answer([]))
	await frames()
	check(PeopleSafe.project_session(runtime) == [c, a2, b, d], "incidental present soldier with no previous card remains uncarded on model no-op")
	check(Safe.project_session(runtime) == initial, "Character and Experiences unchanged across role variants")

	# 含 Player evidence 的 pending semantic 在 Restore epoch 后不得提交或释放旧屏障。
	accept("我想起粮商陈安。", "你站在原地回忆。")
	await frames()
	refs = request_refs(semantic.requests[-1])
	var late_delta: Callable = worker._provider_callbacks.text_delta
	var late_complete: Callable = worker._provider_callbacks.completed
	check(runtime.restore_save_point(saved.save_id).success, "Restore while Player reference analysis pending")
	var restored_head: String = runtime.active_head_id
	late_delta.call(JSON.stringify({"changes": [], "people_bindings": [bound(refs[0], "player", 5, 2)]}))
	late_complete.call()
	await frames()
	check(runtime.active_head_id == restored_head and not curation.busy, "stale Player binding callback inert")
	check(Bridge.current_receipt(runtime, 4) == saved_receipt and PeopleSafe.project_session(runtime) == [c, a2, b, d], "Restore restores exact known-person snapshot")
	check(runtime.restore_save_point(before.save_id).success and PeopleSafe.project_session(runtime) == [c], "Restore before pair evidence removes future cards")
	check(runtime.restore_save_point(saved.save_id).success, "Restore current mixed history for reopen")
	var db: String = runtime.database_path
	teardown()
	runtime.close()
	runtime = Runtime.new()
	check(runtime.open_existing_game(db).success, "reopen mixed receipt history")
	compose()
	await frames()
	check(semantic.requests.is_empty() and curation.requests.is_empty() and PeopleSafe.project_session(runtime) == [c, a2, b, d], "reopen projects old/new cards without replay/backfill")
	# Player-only correction，同 GM 文本也必须立刻失效旧 pair 回执。
	var old_gm: String = runtime.conversation.get_durable_accepted_entries()[-1].gm_text
	runtime.conversation.correct_latest("我重新听取消息。")
	runtime.conversation.append_delta(old_gm)
	check(runtime.complete_active_generation_durably().success, "Player-only correction accepted with same GM")
	check(Bridge.current_receipt(runtime, 4).is_empty() and PeopleSafe.project_session(runtime) == [c, a2, b], "full pair prefix invalidates receipt and future card on correction")
	await frames()
	complete(semantic, {"changes": []})
	await frames()
	complete(curation, answer([]))
	await frames()
	teardown()
	runtime.close()
	await frames()
	boundary_checks()
	print("MW-018 R1 FOCUSED checks=%d failures=%d" % [checks, failures])
	quit(0 if failures == 0 else 1)

func bound(ref: String, role: String, start: int, length: int) -> Dictionary:
	return {"actor_ref": ref, "source_role": role, "source_span": {"start": start, "length": length}}

func boundary_checks() -> void:
	var actors := {"exact": "id"}
	var allowed := {"id": true, "new-id": true}
	var candidates := {"new": "new-id"}
	var invalid: Array = [bound("exact", "system", 0, 1), bound("exact", "player", -1, 1), bound("exact", "player", 0, 601), bound("exact", "player", 0, 0), bound("missing", "gm", 0, 1), {"actor_ref": "exact", "source_role": "player", "source_span": {"start": 0.5, "length": 1}}, {"candidate_ref": "new", "source_role": "player", "source_span": {"start": 0, "length": 1}}, {"actor_ref": "exact", "source_role": "gm", "source_span": {"start": 0, "length": 1}, "quote": "PRIVATE"}]
	check(Receipt.resolve_bindings(invalid, actors, candidates, allowed, "甲", "甲".repeat(600)).is_empty(), "invalid roles/refs/spans/free quote and Player minted-candidate refs rejected")
	var values: Array = [bound("exact", "player", 0, 600)]
	for i: int in range(9):
		values.append(bound("exact", "player", i, 1))
	var bindings := Receipt.resolve_bindings(values, actors, candidates, allowed, "甲", "甲".repeat(600))
	check(bindings.size() == 8 and bindings[0].source_span.length == 600, "Player span 600 Unicode and eight-binding ceilings")
	var mixed := Receipt.resolve_bindings([{"actor_ref": "exact", "gm_span": {"start": 0, "length": 1}}, bound("exact", "gm", 0, 1)], actors, {}, allowed, "甲")
	var record := Receipt.build("g", 0, "p", mixed)
	check(record.schema == Receipt.PAIR_SCHEMA and record.bindings.size() == 1, "mixed response representations normalize without duplicate evidence")

	var entries := [{"player_text": "😀记起陈安", "gm_text": "你继续回忆。"}]
	var prefix := Receipt.prefix_at(entries, 0)
	var valid := Receipt.build("g", 0, prefix, [{"local_character_id": "npc-a", "source_role": "player", "source_span": {"start": 3, "length": 2}}])
	var world := Receipt.with_receipt(setup(), valid)
	check(Receipt.current(world, "g", entries, 0) == valid, "v0.2 persisted receipt roundtrip")
	for patch: Dictionary in [{"source_role": "system"}, {"local_character_id": "player"}, {"source_span": {"start": -1, "length": 1}}, {"private": "hidden"}]:
		var corrupt := valid.duplicate(true)
		corrupt.bindings[0].merge(patch, true)
		corrupt.erase("id")
		corrupt["id"] = JSON.stringify(corrupt, "", true).sha256_text()
		check(Receipt.current(Receipt.with_receipt(setup(), corrupt), "g", entries, 0).is_empty(), "rehashing cannot authorize corrupt role/actor/span/extra material")
	var edited := entries.duplicate(true)
	edited[0].player_text = "改了陈安"
	check(Receipt.current(world, "g", edited, 0).is_empty(), "persisted Player bytes covered by receipt prefix")
	check(Receipt.current(world, "other-game", entries, 0).is_empty(), "cross-game receipt rejected")

func setup() -> Dictionary:
	var world := super.setup()
	world.stable_npcs.insert(3, {"local_character_id": "npc-soldier", "role": "stable_npc", "origin": {"kind": "creation_authored"}, "game_local_material": {"display_name": "士兵", "profile_text": "SECRET_PROFILE"}})
	return world

func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("MW-018 R1 FAIL " + label)
	else:
		print("MW-018 R1 PASS " + label)
