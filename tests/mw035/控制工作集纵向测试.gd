extends "res://tests/mw033/叙事工作集纵向测试.gd"

const D35 := preload("res://src/行动判定/L3_外交层/行动判定公开接口.gd")
const I35 := preload("res://src/行囊/L3_外交层/行囊公开接口.gd")
class Rng35 extends RefCounted:
	var calls := 0
	func roll_d20() -> int:
		calls += 1
		return 12
var evidence35: Array = []
var assembly35: RefCounted
var settings35: RefCounted

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="): directory = arg.trim_prefix("--root=")
	if not directory.contains("/build/mw035-focused/"): quit(2); return
	DirAccess.make_dir_recursive_absolute(directory)
	settings35 = Settings33.new(directory.path_join("settings.json"))
	assembly35 = ConfiguredAssembly.new(); assembly35.settings = settings35
	capacity35("256k")
	runtime = Runtime.new()
	check(runtime.open_current_game(directory.path_join("control.sqlite")).success,"isolated SQLite")
	var initial := setup33()
	initial.world.source_projection.semantic_sections = [{"content":body35("BACKGROUND",80000)},{"section_type":"literary_style_reference","content":"STYLE_ONLY_CANARY"}]
	initial.game["opening_supplement"] = body35("SUPPLEMENT",80000)
	initial.selected_entry_id = "ENTRY_ID"
	initial.world.source_projection["selected_entry"] = {"entry_id":"ENTRY_ID","display_name":"entry","opening_seed":body35("SEED",80000)}
	initial.guaranteed_npcs = [{"local_character_id":"courier","source_projection":{"display_name":"信使","semantic_sections":[{"content":body35("NPC",80000)}]}}]
	initial["expansions"] = [{"capability_slot":"action_resolution","capability_id":"action_check.public_d20.v1","semantic_sections":[{"content":"EXACT_EXPANSION_RULE"}]}]
	check(runtime.commit_world_mutation_durably("setup","setup",initial).success,"frozen sources")
	accept("","GM_ONLY_OPENING" + "旧".repeat(6500))
	curate33("EXCLUDED_PERSON","EXCLUDED_THREAD","CURRENT_CHARACTER_CAPABILITY")
	for i: int in 20: accept("player%02d" % i,"gm%02d" % i + "长".repeat(6500))
	var entries: Array = runtime.conversation.get_durable_accepted_entries()
	var world := Rules33.build_world_candidate(runtime.world_state,Rules33.build_record(runtime.game_id,0,entries[0].gm_text,["CURRENT_WORLD_OLD_ORIGIN"],"stamp"))
	world = Rules33.build_world_candidate(world,Rules33.build_record(runtime.game_id,1,"wrong",["STALE_WORLD_CANARY"],"stamp"))
	var knowledge := Rules33.build_knowledge_record(runtime.game_id,0,entries[0].gm_text,[{"knower_id":"courier","fact":"CURRENT_KNOWLEDGE","basis":"witnessed"}],"stamp")
	world = Rules33.build_world_candidate_with_knowledge(world,{},knowledge)
	var cycle := Rules33.build_agency_cycle(runtime.game_id,0,entries[0].gm_text,runtime.active_head_id,"stamp")
	world = Rules33.build_agency_candidate(world,cycle,Rules33.build_agency_action(runtime.game_id,cycle.agency_cycle_id,"courier","核实","CURRENT_AGENCY",["已经出发"],"stamp"))
	world = Rules33.build_world_candidate_with_evolution(world,Rules33.build_world_evolution_event(runtime.game_id,0,Rules33.gm_sha256(entries[0].gm_text),runtime.active_head_id,"CURRENT_EVOLUTION",["水位上涨"],"stamp"))
	var inventory := I35.parse_updates({"add":[{"name":"信","summary":"CURRENT_INVENTORY"}],"update":[],"remove":[]})
	world = I35.candidate(world,entries,0,inventory,{}).world
	world["expansion_runtime"] = {"public_d20_no_check_actions":[{"narrative_accepted":true,"accepted_turn_index":1,"player_text":entries[1].player_text,"narrative":entries[1].gm_text,"reason":"CURRENT_MECHANICS","resolution_id":"PRIVATE_RESOLUTION"}]}
	check(runtime.commit_world_mutation_durably("current","current",world).success,"current owner records")
	world = Rules33.build_world_candidate(runtime.world_state,Rules33.build_record(runtime.game_id,20,entries[20].gm_text,["LATEST_WORLD_CANARY"],"stamp"))
	check(runtime.commit_world_mutation_durably("latest","latest",world).success,"latest replaceable World")
	var save: Dictionary = runtime.create_save_point("current")
	for capacity: String in ["256k","1m"]:
		capacity35(capacity)
		for recovery: bool in [false,true]:
			var lane := D35.new(runtime,Stub.new(),Rng35.new()); lane._assembler = assembly35
			lane._player_text = "ACTIVE_EXACT_ACTION"
			var messages: Array = lane._control_messages(initial.expansions[0],recovery)
			var text := JSON.stringify(messages)
			var stats: Dictionary = lane.control_context_stats
			check(not messages.is_empty(),capacity+" assembled")
			check(stats.final_messages_bytes==text.to_utf8_buffer().size() and stats.final_messages_bytes<=stats.safe_input_bytes,capacity+" actual serialized bound")
			for marker: String in ["CURRENT_CHARACTER_CAPABILITY","CURRENT_WORLD_OLD_ORIGIN","CURRENT_KNOWLEDGE","CURRENT_AGENCY","CURRENT_EVOLUTION","CURRENT_INVENTORY","CURRENT_MECHANICS","EXACT_EXPANSION_RULE","ENTRY_ID"]:
				check(text.contains(marker),capacity+" current owner "+marker)
			for marker: String in ["STYLE_ONLY_CANARY","STALE_WORLD_CANARY","RAW_PRIVATE_CANARY","EXCLUDED_PERSON","EXCLUDED_THREAD","CURRENT_EXPERIENCE","PRIVATE_RESOLUTION"]:
				check(not text.contains(marker),"exclude "+marker)
			check(messages.filter(func(m:Dictionary)->bool:return m.content=="ACTIVE_EXACT_ACTION").size()==1,"active once")
			for marker: String in ["BACKGROUND","SUPPLEMENT","SEED","NPC"]:
				check(not text.contains(marker+"_BEGIN") or messages[0].content.contains(body35(marker,80000)),"atomic "+marker)
			if capacity=="256k":
				check(not text.contains("SUPPLEMENT_BEGIN") and stats.families.source.omitted>0 and stats.families.npc_source.omitted>0,"256k omits P2 whole")
				check(not stats.selected_turns.has(0),"origin older than retained transcript")
			else: check(text.contains("SUPPLEMENT_BEGIN"),"1m admits more complete P2")
			var selected: Array = stats.selected_turns
			for i: int in range(1,selected.size()): check(selected[i]>selected[i-1],"chronological selected turns")
			for entry: Dictionary in entries:
				if selected.has(entry.turn_index): check(messages.any(func(m:Dictionary)->bool:return m.content==entry.gm_text),"whole accepted GM")
			check(not messages.any(func(m:Dictionary)->bool:return m.role=="user" and m.content.is_empty()),"no fake opening user")
			check(not JSON.stringify(stats).contains("CURRENT_") and not JSON.stringify(stats).contains("ACTIVE_EXACT_ACTION"),"safe stats")
			evidence35.append(stats)
			lane.provider_adapter.free(); lane.free()
	# Restore/reopen/Regenerate 使用同一生产 control 消费者，不能回收 displaced material。
	accept("FUTURE_PLAYER","FUTURE_GM")
	var future: Array = runtime.conversation.get_durable_accepted_entries()
	world = Rules33.build_world_candidate(runtime.world_state,Rules33.build_record(runtime.game_id,21,future[21].gm_text,["FUTURE_WORLD"],"stamp"))
	check(runtime.commit_world_mutation_durably("future","future",world).success,"future record")
	check(control_text35().contains("FUTURE_WORLD"),"future truly current before Restore")
	check(runtime.restore_save_point(save.save_id).success,"Restore")
	check(not control_text35().contains("FUTURE_"),"Restore excludes future")
	var current := control_text35()
	runtime.close(); runtime = Runtime.new()
	check(runtime.open_existing_game(directory.path_join("control.sqlite")).success,"reopen")
	check(control_text35()==current,"reopen same control without cache")
	runtime.conversation.retry_or_regenerate_latest(); runtime.conversation.append_delta("REGENERATED_GM")
	check(runtime.complete_active_generation_durably().success,"Regenerate")
	check(control_text35().contains("REGENERATED_GM") and not control_text35().contains(entries[-1].gm_text) and not control_text35().contains("LATEST_WORLD_CANARY"),"Regenerate excludes old pair and hash-bound World")
	capacity35("256k")
	for kind: String in ["expansion","instructions"]:
		world = runtime.world_state.duplicate(true)
		if kind=="expansion": world.expansions[0].semantic_sections=[{"content":"巨".repeat(80000)}]
		else: world.world.source_projection.world_instructions="巨".repeat(80000)
		check(runtime.commit_world_mutation_durably(kind,kind,world).success,"oversized P0 fixture")
		var rng := Rng35.new(); var stub := Stub.new(); var lane := D35.new(runtime,stub,rng); lane._assembler=assembly35; root.add_child(lane)
		var head: String=runtime.active_head_id; var before: Dictionary=runtime.world_state.duplicate(true)
		var result: Dictionary=lane.start_action("overflow-"+kind,"check this")
		check(not result.success and result.status=="required_context_overflow","P0 fail loud "+kind)
		check(stub.requests.is_empty() and rng.calls==0 and runtime.active_head_id==head and runtime.world_state==before,"overflow zero Provider RNG mutation")
		lane.queue_free(); await frames()
		check(runtime.restore_save_point(save.save_id).success,"restore P0 fixture")
	world = runtime.world_state.duplicate(true)
	world.game.opening_supplement = body35("SUPPLEMENT",8)
	world.world.source_projection.selected_entry.opening_seed = body35("SEED",8)
	world.world.source_projection.semantic_sections[0].content = body35("BACKGROUND",8)
	world.guaranteed_npcs[0].source_projection.semantic_sections[0].content = body35("NPC",8)
	check(runtime.commit_world_mutation_durably("small","small",world).success,"small whole background fixture")
	for marker: String in ["SUPPLEMENT","SEED","BACKGROUND","NPC"]:
		check(control_text35().contains(body35(marker,8)),"small P2 preserved "+marker)
	check(runtime.restore_save_point(save.save_id).success,"restore large fixture")
	await lifecycle35()
	runtime.close()
	FileAccess.open(directory.path_join("budget-evidence.json"),FileAccess.WRITE).store_string(JSON.stringify(evidence35,"  "))
	print("MW035 checks=%d failures=%d real_provider_calls=0" % [checks,failures]); quit(0 if failures==0 else 1)

func body35(label: String, count: int) -> String:
	return label+"_BEGIN"+"背".repeat(count)+label+"_END"

func capacity35(value: String) -> void:
	check(settings35.save_settings({"profile_id":"deepseek_v4_pro","context_limit":value,"reasoning_request":"high"}).success,"validated "+value)

func control_text35() -> String:
	var lane := D35.new(runtime,Stub.new(),Rng35.new()); lane._assembler=assembly35; lane._player_text="probe"
	var text := JSON.stringify(lane._control_messages(runtime.world_state.expansions[0],false))
	lane.provider_adapter.free(); lane.free(); return text

func lifecycle35() -> void:
	for decision: String in ["CHECK_REQUIRED","NO_CHECK","degraded"]:
		var stub := Stub.new(); var rng := Rng35.new(); var lane := D35.new(runtime,stub,rng); lane._assembler=assembly35; root.add_child(lane)
		check(lane.start_action(decision,"action "+decision).success,"start "+decision)
		check(rng.calls==0,"no RNG before parsed control")
		if decision=="degraded":
			curate33("EXCLUDED_PERSON","EXCLUDED_THREAD","FRESH_RECOVERY_CHARACTER")
			capacity35("1m")
			stub.text_delta.emit("invalid"); stub.busy=false; stub.completed.emit()
			check(stub.requests.size()==2 and JSON.stringify(stub.requests[1]).contains("FRESH_RECOVERY_CHARACTER"),"recovery rebuilds current owners")
			check(lane.control_context_stats.safe_input_bytes==838860 and lane.control_context_stats.final_messages_bytes==JSON.stringify(stub.requests[1]).to_utf8_buffer().size(),"recovery revalidates changed capacity and actual bytes")
			evidence35.append(lane.control_context_stats.duplicate(true))
			check(lane.control_context_stats.stage=="control_recovery" and not JSON.stringify(stub.requests[1]).contains("STYLE_ONLY_CANARY"),"bounded style-free recovery")
			stub.text_delta.emit("invalid"); stub.busy=false; stub.completed.emit()
			check(stub.requests.size()==3 and rng.calls==0,"second malformed degraded without RNG")
		elif decision=="NO_CHECK": complete(stub,{"decision":"NO_CHECK","reason":"无需检定"})
		else:
			complete(stub,{"decision":"CHECK_REQUIRED","proposal":{"intent":"尝试","dc":10,"modifier":0,"stance":"normal","modifier_reason":"无加值","situation_reason":"普通情况","success_intent":"通过","failure_stakes":"停留"}})
			check(rng.calls==1,"RNG after valid CHECK exactly once")
		check(JSON.stringify(stub.requests[-1]).contains("STYLE_ONLY_CANARY"),"Narrative stage retains MW033 style family "+decision)
		stub.text_delta.emit("本次行动已经结束。"); stub.busy=false; stub.completed.emit()
		check(lane.last_result.success,"accepted "+decision)
		if decision!="degraded":
			var calls: int=stub.requests.size(); var rolls: int=rng.calls
			check(lane.start_action(decision,"action "+decision).success and stub.requests.size()==calls and rng.calls==rolls,"durable replay no request or reroll")
		lane.queue_free(); await frames()
