extends "res://tests/mw019/行动推荐纵向测试.gd"

const History := preload("res://src/行动判定/L3_外交层/公开机制历史公开接口.gd")
const Adjudication := preload("res://src/行动判定/L3_外交层/行动判定公开接口.gd")
const Opening := preload("res://src/首次开场/L3_外交层/首次开场公开接口.gd")

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="): directory = arg.trim_prefix("--root=")
	if not directory.contains("mw026"): quit(2); return
	DirAccess.make_dir_recursive_absolute(directory)
	runtime = Runtime.new()
	check(runtime.open_current_game(directory.path_join("mechanics.sqlite")).success, "isolated runtime")
	var fixture := setup()
	fixture.player_character.source_projection["semantic_sections"] = [{"content":"一名旅人。"}]
	fixture.world.source_projection["semantic_sections"] = [{"content":"城门外有一条道路。"}]
	check(runtime.commit_world_mutation_durably("setup", "setup", fixture).success, "setup")
	accept("", "你站在城门外。")
	var before: Dictionary = runtime.create_save_point("before")
	accept("我试着说服守卫放行。", "守卫拒绝放行。")
	var record := {"action_id":"PRIVATE_ACTION", "check_id":"PRIVATE_CHECK", "player_text":"我试着说服守卫放行。", "conversation_base_count":1, "accepted_turn_index":1, "narrative_accepted":true, "intent":"说服守卫", "dc":18, "modifier":1, "stance":"normal", "selected_roll":4, "total":5, "outcome":"failure", "success_intent":"进入城门", "failure_stakes":"守卫提高警觉", "control_reasoning":"PRIVATE_CONTROL"}
	var state: Dictionary = runtime.world_state.duplicate(true)
	state["expansion_runtime"] = {"public_d20_checks":[record], "private":"PRIVATE_WORLD"}
	check(runtime.commit_world_mutation_durably("check", "check", state).success, "durable disclosed failed check")
	var after: Dictionary = runtime.create_save_point("after")
	var stub := Stub.new()
	var opening := Opening.new(runtime, stub)
	root.add_child(opening)
	for mode: String in ["action", "ooc"]:
		runtime.conversation.begin_turn("接下来呢？", mode)
		var request: Dictionary = opening.assemble_continuation_messages()
		if not request.success:
			print(request); quit(1); return
		var text := JSON.stringify(request.messages)
		check(request.success and text.contains("failure") and text.contains("守卫提高警觉") and text.contains("selected_roll"), mode + " sees accepted failed check and stakes")
		for canary: String in ["PRIVATE_ACTION", "PRIVATE_CHECK", "PRIVATE_CONTROL", "PRIVATE_WORLD", "input_mode=ooc", "[GM OOC response"]:
			check(not text.contains(canary), mode + " excludes " + canary)
		runtime.conversation.cancel_generation()
	var mechanics_lane := Adjudication.new(runtime, Stub.new())
	root.add_child(mechanics_lane)
	check(JSON.stringify(mechanics_lane._ordinary_narrative_messages({}, false)).contains("守卫提高警觉"), "mechanics-owned continuation also retains prior stakes")
	mechanics_lane.queue_free()
	check(stub.requests.is_empty(), "assembly adds zero Provider calls")
	check(runtime.restore_save_point(before.save_id).success, "Restore before check")
	check(not JSON.stringify(opening.assemble_continuation_messages()).contains("Public Mechanics"), "displaced future absent")
	check(runtime.restore_save_point(after.save_id).success, "Restore after check")
	check(JSON.stringify(opening.assemble_continuation_messages()).contains("守卫提高警觉"), "restored current check present")
	var entries: Array = runtime.conversation.get_durable_accepted_entries()
	var changed := entries.duplicate(true)
	changed[1].player_text = "不同的行动"
	check(History.project(state, changed).is_empty(), "replaced Player slot excluded")
	changed = entries.duplicate(true); changed[1]["input_mode"] = "ooc"
	check(History.project(state, changed).is_empty(), "same prose OOC excluded")
	var pending := state.duplicate(true); pending.expansion_runtime.public_d20_checks[0].narrative_accepted = false
	check(History.project(pending, entries).is_empty(), "unaccepted check excluded")
	pending = state.duplicate(true); pending.expansion_runtime.public_d20_checks.append(record)
	check(History.project(pending, entries).is_empty(), "ambiguous checks excluded")
	var no_check := {"narrative_accepted":true,"accepted_turn_index":1,"player_text":entries[1].player_text,"narrative":entries[1].gm_text,"reason":"普通交谈无需掷骰", "resolution_id":"PRIVATE_RESOLUTION"}
	var quiet := {"expansion_runtime":{"public_d20_no_check_actions":[no_check]}}
	check(History.project(quiet, entries).contains("NO_CHECK") and not History.project(quiet, entries).contains("PRIVATE_RESOLUTION"), "NO_CHECK safe reason")
	var quiet_state := state.duplicate(true)
	quiet_state.expansion_runtime = quiet.expansion_runtime
	check(runtime.commit_world_mutation_durably("quiet", "quiet", quiet_state).success, "durable NO_CHECK fixture")
	check(JSON.stringify(opening.assemble_continuation_messages()).contains("普通交谈无需掷骰"), "NO_CHECK reaches production continuation")
	check(runtime.restore_save_point(after.save_id).success, "return to CHECK snapshot")
	changed = entries.duplicate(true); changed[1].gm_text = "被替换的回答"
	check(History.project(quiet, changed).is_empty(), "NO_CHECK replaced narrative excluded")
	var many: Array = []
	var records: Array = []
	for i: int in 20:
		many.append({"player_text":"a", "gm_text":"b"})
		var item := no_check.duplicate(true); item.accepted_turn_index = i; item.player_text = "a"; item.narrative = "b"; records.append(item)
	var bounded := History.project({"expansion_runtime":{"public_d20_no_check_actions":records}}, many)
	check(JSON.parse_string(bounded.split("\n")[-1]).size() == 12, "bounded latest twelve")
	var raw := entries.duplicate(true)
	runtime.conversation.begin_turn("请放慢节奏", "ooc")
	runtime.conversation.append_delta("好的，我会放慢。")
	check(runtime.complete_active_generation_durably().success, "accepted OOC")
	runtime.conversation.begin_turn("继续", "ooc")
	var messages: Array = opening.assemble_continuation_messages().messages
	check(messages[-2].content == "好的，我会放慢。" and messages[-3].content == "OOC / GM 指导\n请放慢节奏", "readable history with exact assistant prose")
	check(not JSON.stringify(messages).contains("input_mode=ooc"), "no implementation wrapper")
	runtime.conversation.cancel_generation()
	check(runtime.conversation.get_durable_accepted_entries().slice(0,raw.size()) == raw, "derived request leaves durable bytes unchanged")
	opening.queue_free()
	await frames()
	print("MW026 focused checks=%d failures=%d" % [checks, failures])
	quit(0 if failures == 0 else 1)
