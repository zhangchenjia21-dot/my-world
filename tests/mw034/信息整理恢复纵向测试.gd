extends "res://tests/mw015r2/初始角色基线纵向测试.gd"

var r: RefCounted
var w: Node
var s: Node
var events: Array = []
var case_number := 0

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="): directory = arg.trim_prefix("--root=")
	if not directory.contains("/build/mw034/"): quit(2); return
	DirAccess.make_dir_recursive_absolute(directory)
	await initial_recovery()
	await lived_recovery()
	await failures_matrix()
	await invalidations()
	await extra_boundaries()
	await actor_refs()
	FileAccess.open(directory.path_join("safe-attempt-evidence.json"), FileAccess.WRITE).store_string(JSON.stringify(events, "  "))
	print("MW034 checks=%d failures=%d real_provider_calls=0" % [checks, failures])
	quit(0 if failures == 0 else 1)

func fresh() -> void:
	case_number += 1
	r = RejectingRuntime.new()
	check(r.open_current_game(directory.path_join("case%d.sqlite" % case_number)).success, "isolated real Runtime")
	check(r.commit_world_mutation_durably("setup", "setup", setup()).success, "frozen setup")
	s = Stub.new(); w = Curator.new(r, s)
	w.diagnostic_started.connect(func(value: Dictionary) -> void: note(value, "started"))
	w.diagnostic_terminal.connect(func(value: Dictionary) -> void: note(value, "terminal"))
	root.add_child(w); await frames()
	check(s.requests.size() == 1, "initial Provider start")

func note(value: Dictionary, phase: String) -> void:
	# prefix/epoch 是既有 owner currentness seam；归档只保留公开结构值。
	var safe := {"case":case_number, "phase":phase}
	for key: String in ["request", "mode", "attempt", "status", "recovery_scheduled", "recovery_started", "elapsed_ms"]:
		if value.has(key): safe[key] = value[key]
	events.append(safe)
	check(not JSON.stringify(safe).contains("CANARY"), "safe diagnostic has no raw malformed/private content")

func dispose() -> void:
	w.shutdown(); w.queue_free(); await frames(); r.close()

func malformed() -> void:
	s.simulate_delta("```json RAW_MALFORMED_CANARY"); s.simulate_completed()

func old_callbacks(callbacks: Dictionary) -> void:
	callbacks.text_delta.call("OLD_DELTA_CANARY")
	callbacks.completed.call()
	callbacks.failed.call("transport", "OLD_FAILURE_CANARY")
	callbacks.cancelled.call()

func initial_recovery() -> void:
	await fresh()
	var before: Dictionary = r.world_state.duplicate(true)
	var nodes: int = r.persistence.timeline_node_count(r.game_id).node_count
	var old: Dictionary = w._callbacks.duplicate()
	malformed()
	check(w._recovery_pending and r.world_state == before, "initial malformed schedules once with zero write")
	await frames()
	check(s.requests.size() == 2 and w._active.attempt == 2, "initial recovery exactly second start")
	old_callbacks(old)
	check(s.busy and w._response.is_empty(), "all four old callbacks ignored on attempt2")
	check(s.requests[1][1] == s.requests[0][1] and s.requests[1][0].content.ends_with(w.RECOVERY_CUE), "initial same frozen material plus bounded cue")
	check(not JSON.stringify(s.requests[1]).contains("RAW_MALFORMED_CANARY"), "initial recovery never echoes raw response")
	complete(s, BASELINE); await frames()
	check(r.persistence.timeline_node_count(r.game_id).node_count == nodes + 1, "recovered baseline exactly one durable node")
	check(r.world_state.information_curation.initial.result.experiences.is_empty(), "initial no milestone")
	var db := directory.path_join("case%d.sqlite" % case_number)
	await dispose()
	r = Runtime.new(); check(r.open_existing_game(db).success, "reopen recovered initial")
	s = Stub.new(); w = Curator.new(r, s); root.add_child(w); await frames()
	check(s.requests.is_empty(), "reopen recovered initial zero starts")
	await dispose()

func lived_answer() -> Dictionary:
	return {"character":BASELINE.character, "experiences":[{"title":"转折", "description":"人生道路改变。"}], "people_updates":[{"person_ref":null, "actor_ref":null, "source_role":"gm", "source_span":{"start":0,"length":2}, "snapshot":{"display_name":"陈安","headline":"故人","summary":"已知近况","relationship":"认识","details":[]}}], "open_threads":[{"thread_ref":null,"title":"未决事务","summary":"仍需回应","details":[]}]}

func raw_complete(answer: Dictionary) -> void:
	s.simulate_delta(JSON.stringify(answer)); s.simulate_completed()

func lived_recovery() -> void:
	await fresh(); complete(s, BASELINE); await frames()
	accept(r, "问候", "陈安向你求助。"); await frames()
	var count: int = s.requests.size()
	var before: Dictionary = r.world_state.duplicate(true)
	malformed(); check(r.world_state == before, "lived malformed no partial durable write")
	await frames()
	check(s.requests.size() == count + 1, "lived exactly one recovery")
	raw_complete(lived_answer()); await frames()
	check(r.world_state.information_curation.turns.size() == 1, "one recovered lived record")
	check(SafeView.project_session(r).important_experiences.size() == 1, "one recovered experience")
	accept(r, "再问", "陈安回应你的疑问。"); await frames()
	var first: Dictionary = JSON.parse_string(s.requests[-1][1].content)
	var old: Dictionary = w._callbacks.duplicate()
	malformed(); await frames()
	var second: Dictionary = JSON.parse_string(s.requests[-1][1].content)
	check(first.current_people[0].person_ref != second.current_people[0].person_ref and first.current_open_threads[0].thread_ref != second.current_open_threads[0].thread_ref, "attempt2 fresh People and Thread refs")
	check(not JSON.stringify(s.requests[-1]).contains(first.current_people[0].person_ref) and not JSON.stringify(s.requests[-1]).contains("RAW_MALFORMED_CANARY"), "attempt2 excludes old refs/raw response")
	old_callbacks(old)
	var answer := {"character":null,"experiences":[],"people_updates":[{"person_ref":second.current_people[0].person_ref,"actor_ref":null,"source_role":null,"source_span":null,"snapshot":second.current_people[0].snapshot}],"open_threads":second.current_open_threads}
	var stale := answer.duplicate(true); stale.open_threads[0].thread_ref = first.current_open_threads[0].thread_ref
	check(load("res://src/信息整理/L1_器件层/信息整理响应解析器.gd").parse(JSON.stringify(stale),true,w._active.bindings,w._active.subjects).is_empty(), "attempt1 Thread ref rejected by unchanged parser")
	var stale_person := answer.duplicate(true); stale_person.people_updates[0].person_ref = first.current_people[0].person_ref
	check(load("res://src/信息整理/L1_器件层/信息整理响应解析器.gd").parse(JSON.stringify(stale_person),true,w._active.bindings,w._active.subjects).people_updates.is_empty(), "attempt1 People ref has no write authority")
	raw_complete(answer); await frames()
	var records: Array = Contract.current_records(r.world_state,r.conversation.get_durable_accepted_entries())
	check(records.size() == 2 and records[0].result.open_threads[0].thread_id == records[1].result.open_threads[0].thread_id, "fresh refs retain one stable Thread identity")
	check(records[0].result.people_updates[0].subject_id == records[1].result.people_updates[0].subject_id, "fresh refs retain one People subject")
	accept(r, "失败机会", "普通叙事"); await frames()
	count = s.requests.size(); malformed(); w.retry_pending(); await frames(); w.retry_pending(); malformed(); await frames()
	check(s.requests.size() == count + 1 and not s.busy, "two failures no automatic third start")
	accept(r, "下一轮", "后续叙事仍可被整理"); await frames()
	check(s.busy, "later lived turn runs after final failure")
	raw_complete({"character":null,"experiences":[],"people_updates":[],"open_threads":[]}); await frames()
	check(r.conversation.get_durable_accepted_entries().size() == 4, "Narrative accepts independently through failure")
	w.retry_pending(); await frames()
	check(s.busy, "explicit retry_pending repairs prior failed opportunity")
	raw_complete({"character":null,"experiences":[],"people_updates":[],"open_threads":[]}); await frames()
	# 旧后继 parent 失效后按现有流程重新整理，不能重复自动重试同一机会。
	if s.busy: raw_complete({"character":null,"experiences":[],"people_updates":[],"open_threads":[]}); await frames()
	var db := directory.path_join("case%d.sqlite" % case_number)
	await dispose(); r = Runtime.new(); check(r.open_existing_game(db).success, "reopen lived recovery")
	s = Stub.new(); w = Curator.new(r,s); root.add_child(w); await frames()
	check(s.requests.is_empty(), "reopen no duplicate lived curation")
	await dispose()

func failures_matrix() -> void:
	for code: String in ["transport","http_408","http_429","http_500","http_502","http_503","http_504"]:
		await fresh(); s.simulate_failed(code); await frames()
		check(s.requests.size() == 2 and s.busy, "recognized transient retries " + code)
		complete(s, BASELINE); await frames(); check(w.last_result.success, "transient recovery commits " + code); await dispose()
	for code: String in ["missing_key","missing_credential","invalid_profile","invalid_persisted_settings","invalid_settings","unknown_profile","unknown_context_limit","unknown_reasoning_request","incompatible_context_limit","http_401","http_403","unknown_error","http_400"]:
		await fresh(); s.simulate_failed(code); await frames()
		check(s.requests.size() == 1 and not s.busy and not w._recovery_pending, "permanent/unknown no retry " + code); await dispose()
	await fresh(); var old: Dictionary = w._callbacks.duplicate()
	w._timer.timeout.emit(); await frames()
	check(s.requests.size() == 2 and s.busy, "timeout cancels old transport then retries")
	old_callbacks(old); check(s.busy and w._response.is_empty(), "timeout late delta/completed/failed/cancelled isolated")
	w._timer.timeout.emit(); await frames()
	check(s.requests.size() == 2 and not s.busy and w.last_result.status == "timeout", "second timeout no third start")
	w.retry_pending(); await frames(); check(s.requests.size() == 3, "explicit initial repair distinct from automatic budget")
	complete(s, BASELINE); await frames(); await dispose()
	await fresh(); s.simulate_failed(); await frames(); s.simulate_failed(); await frames()
	check(s.requests.size() == 2 and not s.busy, "second transport failure no third start"); await dispose()
	await fresh(); s.simulate_delta("x".repeat(Contract.MAX_RESPONSE_BYTES + 1)); await frames()
	check(s.requests.size() == 1 and not s.busy and w.last_result.status == "response_oversized", "response oversized no retry"); await dispose()
	await fresh(); complete(s,BASELINE); await frames()
	accept(r,"输入过大","大".repeat(50000)); await frames()
	check(s.requests.size() == 1 and w.last_result.status == "input_oversized", "lived input oversized zero new starts"); await dispose()
	await fresh(); r.reject_curation = true; complete(s,BASELINE); await frames()
	check(s.requests.size() == 1 and w.last_result.status == "persistence_failure", "persistence failure no retry"); r.reject_curation = false; await dispose()
	await fresh(); old = w._callbacks.duplicate(); w.cancel(); await frames(); old_callbacks(old)
	check(s.requests.size() == 1 and not s.busy and w.last_result.status == "cancelled", "explicit cancel no retry or late callback"); await dispose()
	await fresh(); old = w._callbacks.duplicate(); w.shutdown(); old_callbacks(old); await frames()
	check(s.requests.size() == 1 and not s.busy, "shutdown no retry or old callback"); await dispose()

func invalidations() -> void:
	for phase: String in ["attempt1","pending","attempt2"]:
		await fresh(); complete(s,BASELINE); await frames()
		var save: Dictionary = r.create_save_point("before lived")
		accept(r,"future action","DISPLACED_CANARY"); await frames()
		if phase != "attempt1": malformed()
		if phase == "attempt2": await frames()
		var old: Dictionary = w._callbacks.duplicate()
		var count: int = s.requests.size()
		check(r.restore_save_point(save.save_id).success, "Restore " + phase)
		if not old.is_empty(): old_callbacks(old)
		await frames()
		check(s.requests.size() == count and not s.busy and not JSON.stringify(r.world_state).contains("DISPLACED_CANARY"), "Restore invalidates all old work " + phase)
		await dispose()
	await fresh(); complete(s,BASELINE); await frames()
	accept(r,"original","原叙事"); await frames(); malformed()
	r.conversation.correct_latest("replacement"); r.conversation.append_delta("替代叙事")
	check(r.complete_active_generation_durably().success, "replace while recovery pending")
	await frames()
	check(w._active.attempt == 1 and w._active.prefix == Contract.prefix_hashes(r.conversation.get_durable_accepted_entries())[0], "stale prefix gets no recovery; new opportunity starts")
	raw_complete({"character":null,"experiences":[],"people_updates":[],"open_threads":[]}); await frames(); await dispose()
	await fresh(); complete(s,BASELINE); await frames()
	accept(r,"one","first"); await frames(); raw_complete({"character":null,"experiences":[],"people_updates":[],"open_threads":[]}); await frames()
	accept(r,"two","second"); await frames(); malformed()
	var state: Dictionary = r.world_state.duplicate(true); state.information_curation.turns.clear()
	check(r.commit_world_mutation_durably("parent-change","parent-change",state).success, "current parent displaced while pending")
	await frames()
	check(events.any(func(e:Dictionary)->bool: return e.case == case_number and e.get("status") == "stale_parent") and r.world_state.information_curation.turns.is_empty() and w._active.attempt == 1, "stale parent cannot recover/commit; changed opportunity may start"); await dispose()


func extra_boundaries() -> void:
	for phase: String in ["attempt1","pending","attempt2"]:
		await fresh()
		var save: Dictionary = r.create_save_point("pre initial")
		var state: Dictionary = r.world_state.duplicate(true); state["fixture_marker"] = true
		check(r.commit_world_mutation_durably("advance","advance",state).success, "advance initial Restore fixture")
		var old: Dictionary = w._callbacks.duplicate()
		if phase != "attempt1": malformed()
		if phase == "attempt2": await frames()
		check(r.restore_save_point(save.save_id).success, "initial Restore " + phase)
		old_callbacks(old); await frames()
		check(w._active.attempt == 1 and not r.world_state.has("information_curation"), "initial Restore invalidates old opportunity " + phase)
		complete(s,BASELINE); await frames(); await dispose()
	for terminal: String in ["cancel", "shutdown"]:
		await fresh(); malformed()
		if terminal == "cancel": w.cancel()
		else: w.shutdown()
		await frames(); check(s.requests.size() == 1 and not s.busy, "pending recovery " + terminal + " no second start"); await dispose()
	await fresh(); var old: Dictionary = w._callbacks.duplicate(); w.cancel(); s.synchronous_failure = true
	w.retry_pending(); await frames()
	check(s.requests.size() == 2 and not s.busy and w.last_result.status == "configuration_failure", "synchronous permanent start failure not overwritten")
	old_callbacks(old); await dispose()
	await fresh(); w.cancel()
	w.profile_reader = func(_state:Dictionary)->Dictionary: return {"success":true, "headline":"large", "summary":"大".repeat(50000), "groups":[]}
	w.retry_pending(); await frames()
	check(s.requests.size() == 1 and w.last_result.status == "input_oversized", "initial oversized input zero additional starts"); await dispose()
	await fresh(); var state: Dictionary = r.world_state.duplicate(true); state["information_curation"] = {"schema":"invalid"}
	check(r.commit_world_mutation_durably("invalid-owner","invalid-owner",state).success, "invalid storage fixture")
	malformed(); await frames()
	check(s.requests.size() == 1 and w.last_result.status == "invalid_storage", "invalid storage prerequisite prevents recovery start"); await dispose()
	await fresh(); complete(s,BASELINE); await frames()
	accept(r,"first","accepted"); await frames(); malformed(); await frames()
	var old_prefix: String = w._active.prefix
	r.conversation.correct_latest("replacement"); r.conversation.append_delta("replacement GM")
	check(r.complete_active_generation_durably().success, "replace during attempt2")
	raw_complete(lived_answer()); await frames()
	check(Contract.current_records(r.world_state,r.conversation.get_durable_accepted_entries()).is_empty() and w._active.prefix != old_prefix, "attempt2 stale completion zero commit")
	await dispose()


func actor_refs() -> void:
	await fresh(); complete(s,BASELINE); await frames()
	accept(r,"问候","陈安走来。")
	var receipt_rules = load("res://src/世界回合/L0_公理层/人物身份回执规则.gd")
	var state: Dictionary = r.world_state.duplicate(true)
	state["stable_npcs"] = [{"local_character_id":"actor-fixture","role":"stable_npc","origin":{"kind":"creation_authored"},"game_local_material":{"display_name":"陈安","profile_text":"ACTOR_PRIVATE_CANARY"}}]
	var receipt: Dictionary = receipt_rules.build(r.game_id,0,Contract.prefix_hashes(r.conversation.get_durable_accepted_entries())[0],[{"local_character_id":"actor-fixture","gm_span":{"start":0,"length":2}}])
	state = receipt_rules.with_receipt(state,receipt)
	check(r.commit_world_mutation_durably("receipt","receipt",state).success, "fixture exact actor receipt")
	await frames()
	var first: Dictionary = JSON.parse_string(s.requests[-1][1].content)
	malformed(); await frames()
	var second: Dictionary = JSON.parse_string(s.requests[-1][1].content)
	check(first.people_evidence.size() == 1 and second.people_evidence.size() == 1, "both attempts use current validated actor receipt")
	if first.people_evidence.is_empty() or second.people_evidence.is_empty(): await dispose(); return
	check(first.people_evidence[0].actor_ref != second.people_evidence[0].actor_ref, "actor request refs regenerated on recovery")
	check(not JSON.stringify(s.requests[-1]).contains("ACTOR_PRIVATE_CANARY") and not JSON.stringify(s.requests[-1]).contains(first.people_evidence[0].actor_ref), "no private actor or old actor ref in retry prompt")
	var answer := lived_answer(); answer.people_updates[0].actor_ref = first.people_evidence[0].actor_ref
	check(load("res://src/信息整理/L1_器件层/信息整理响应解析器.gd").parse(JSON.stringify(answer),true,w._active.bindings,w._active.subjects).people_updates.is_empty(), "old actor ref has no write authority")
	answer.people_updates[0].actor_ref = second.people_evidence[0].actor_ref
	raw_complete(answer); await frames()
	check(r.world_state.information_curation.turns["0"].result.people_updates[0].actor_id == "actor-fixture", "fresh actor ref exact stable binding commits once")
	await dispose()
