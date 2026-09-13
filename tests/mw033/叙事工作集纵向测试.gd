extends "res://tests/mw032/现实门修正纵向测试.gd"

const Assembly33 := preload("res://src/context/L3_外交层/上下文组装公开接口.gd")
const Settings33 := preload("res://src/运行时设置/L3_外交层/模型运行时设置公开接口.gd")
const Opening33 := preload("res://src/首次开场/L3_外交层/首次开场公开接口.gd")
const Rules33 := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")
const OpeningProjector33 := preload("res://src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd")
const Curation33 := preload("res://src/信息整理/L3_外交层/叙事整理上下文公开接口.gd")
const Source33 := preload("res://src/首次开场/L3_外交层/续玩来源上下文公开接口.gd")

class ConfiguredAssembly extends "res://src/context/L3_外交层/上下文组装公开接口.gd":
	var settings: RefCounted
	func runtime_budget_metadata() -> Dictionary:
		return settings.context_budget_metadata()

var measurements33: Array = []

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="): directory=arg.trim_prefix("--root=")
	if not directory.contains("/build/mw033-focused/"): quit(2); return
	DirAccess.make_dir_recursive_absolute(directory)
	var settings := Settings33.new(directory.path_join("settings.json"))
	var assembler := ConfiguredAssembly.new();assembler.settings=settings
	check(settings.save_settings({"profile_id":"deepseek_v4_pro","context_limit":"256k","reasoning_request":"high"}).success,"isolated validated 256k settings")
	runtime=Runtime.new();check(runtime.open_current_game(directory.path_join("game.sqlite")).success,"isolated Game")
	var initial := setup33()
	check(runtime.commit_world_mutation_durably("setup","setup-node",initial).success,"exact frozen setup")
	var opening_stub: Node = load("res://tests/g4_07a/首次开场桩适配器.gd").new()
	var opening := Opening33.new(runtime,opening_stub);root.add_child(opening)
	check(opening.start_first_opening().success,"real first Opening path")
	var first := OpeningProjector33.new().project(initial)
	check(opening_stub.requests[0]==Assembly33.new().assemble_first_opening_messages(first.context_text),"first Opening exact frozen full payload unchanged")
	opening_stub.simulate_delta("开场记得故人，尚有未决事务。" + "长".repeat(6500));opening_stub.simulate_completed()
	opening.queue_free();await frames()
	curate33("CURRENT_PERSON","CURRENT_THREAD","CURRENT_CHARACTER")
	for i: int in range(20): accept("行动%02d" % i,"回应%02d-" % i + "长".repeat(6500))
	var entries: Array=runtime.conversation.get_durable_accepted_entries()
	var world := Rules33.build_world_candidate(runtime.world_state,Rules33.build_record(runtime.game_id,20,entries[20].gm_text,["CURRENT_WORLD_CONSEQUENCE"],"2026-09-13T00:00:00Z"))
	world=Rules33.build_world_candidate(world,Rules33.build_record(runtime.game_id,19,"wrong hash",["STALE_WORLD_CANARY"],"2026-09-13T00:00:00Z"))
	check(runtime.commit_world_mutation_durably("world","world-node",world).success,"current and stale World fixtures")
	var save: Dictionary=runtime.create_save_point("current")
	runtime.conversation.begin_turn("CURRENT_ATTEMPT")
	var roster_before: Variant=runtime.world_state.stable_npcs.duplicate(true)
	var small := assembler.assemble_session(runtime)
	check(small.success,"production session assembly")
	var payload := JSON.stringify(small.messages)
	check(small.context_stats.token_ceiling==262144 and small.context_stats.safe_input_bytes==209715,"256k exact ceiling and floor 80 percent")
	check(payload.to_utf8_buffer().size()==small.context_stats.final_messages_bytes and small.context_stats.final_messages_bytes<=209715,"final serialized actual messages within budget")
	for marker: String in ["CURRENT_PERSON","CURRENT_THREAD","CURRENT_CHARACTER","CURRENT_WORLD_CONSEQUENCE","CURRENT_EXPERIENCE"]:
		check(payload.contains(marker),"current owner contribution survives transcript roll-off: "+marker)
	check(not payload.contains("STALE_WORLD_CANARY") and not payload.contains("RAW_PRIVATE_CANARY"),"stale World and raw unprojected canary excluded")
	check(payload.contains("Player-known People") and runtime.world_state.stable_npcs==roster_before,"referent knowledge does not become World actor")
	check(not payload.contains("BACKGROUND_BEGIN") and small.context_stats.families.source.omitted>0,"large P2 background cannot crowd P1")
	check(small.context_stats.selected_turns.size()<20 and small.context_stats.selected_turns[0]>0,"old originating turn omitted under pressure")
	var selected: Array=small.context_stats.selected_turns
	for i: int in range(1,selected.size()):check(selected[i]>selected[i-1],"selected whole turns chronological")
	for entry: Dictionary in entries:
		if selected.has(entry.turn_index):check(small.messages.any(func(m: Dictionary)->bool:return m.content==entry.gm_text),"GM accepted text exact whole unit")
	check(small.messages[-1].content=="CURRENT_ATTEMPT" and small.messages.filter(func(m: Dictionary)->bool:return m.content=="CURRENT_ATTEMPT").size()==1,"current attempt exactly once last")
	var preferences := Preferences32.new(runtime.game_id,directory.path_join("preferences"))
	for pair: Array in [["people",PeopleSafe.project_presented_people(runtime)],["threads",ThreadSafe32.project_presented_threads(runtime)],["important_experiences",Safe.project_presented_experiences(runtime)]]:
		check(preferences.set_hidden(pair[0],pair[1][0].presentation_key,true),"hide "+pair[0])
	check(assembler.assemble_session(runtime).messages==small.messages,"hide all three changes zero Context bytes")
	measurements33.append(small.context_stats)
	check(settings.save_settings({"profile_id":"deepseek_v4_pro","context_limit":"1m","reasoning_request":"high"}).success,"isolated validated 1m settings")
	var large := assembler.assemble_session(runtime)
	check(large.context_stats.token_ceiling==1048576 and large.context_stats.safe_input_bytes==838860,"1m exact ceiling and floor 80 percent")
	check(JSON.stringify(large.messages).contains("BACKGROUND_BEGIN") and large.context_stats.final_messages_bytes<=838860,"1m admits whole larger background")
	measurements33.append(large.context_stats)
	runtime.conversation.cancel_generation()
	accept("FUTURE_PLAYER","FUTURE_GM")
	curate33("FUTURE_PERSON","FUTURE_THREAD","FUTURE_CHARACTER")
	var future: Array=runtime.conversation.get_durable_accepted_entries()
	world=Rules33.build_world_candidate(runtime.world_state,Rules33.build_record(runtime.game_id,21,future[21].gm_text,["FUTURE_WORLD"],"2026-09-13T00:00:00Z"))
	check(runtime.commit_world_mutation_durably("future","future-node",world).success,"future semantic branch")
	runtime.conversation.begin_turn("after future")
	check(JSON.stringify(assembler.assemble_session(runtime).messages).contains("FUTURE_WORLD"),"future canary truly entered current request before Restore")
	runtime.conversation.cancel_generation()
	check(runtime.restore_save_point(save.save_id).success,"Restore current working set")
	runtime.conversation.begin_turn("CURRENT_ATTEMPT")
	var restored := assembler.assemble_session(runtime)
	check(not JSON.stringify(restored.messages).contains("FUTURE_") and restored.messages==large.messages,"Restore discards future transcript curation and World")
	runtime.conversation.cancel_generation();runtime.close()
	runtime=Runtime.new();check(runtime.open_existing_game(directory.path_join("game.sqlite")).success,"reopen durable Game")
	runtime.conversation.begin_turn("CURRENT_ATTEMPT")
	check(assembler.assemble_session(runtime).messages==large.messages,"reopen derives same messages without Context storage")
	runtime.conversation.cancel_generation();runtime.close()
	runtime=Runtime.new();check(runtime.open_existing_game(directory.path_join("game.sqlite")).success,"drop cancelled draft before accepted Regenerate")
	runtime.conversation.retry_or_regenerate_latest();runtime.conversation.append_delta("REPLACEMENT_GM")
	check(runtime.complete_active_generation_durably().success,"Regenerate replacement accepted")
	runtime.conversation.begin_turn("after replacement")
	var replacement := JSON.stringify(assembler.assemble_session(runtime).messages)
	check(replacement.contains("REPLACEMENT_GM") and not replacement.contains("CURRENT_WORLD_CONSEQUENCE"),"Regenerate invalidates prior GM-bound World")
	runtime.conversation.cancel_generation()
	check(settings.save_settings({"profile_id":"deepseek_v4_pro","context_limit":"256k","reasoning_request":"high"}).success,"reset isolated test capacity")
	runtime.conversation.begin_turn("大".repeat(100000))
	var failed := assembler.assemble_session(runtime)
	check(not failed.success and failed.status=="required_context_overflow" and not failed.has("messages"),"P0 overflow fails loud with no request payload")
	var consumer: Node = load("res://src/ui/叙事对话视图.gd").new()
	var guarded_opening := Opening33.new(runtime,Stub.new());guarded_opening._context_assembler=assembler
	var transport := Stub.new();consumer.conversation=runtime.conversation;consumer.opening_runtime=guarded_opening;consumer.adapter=transport
	consumer._start_request()
	check(transport.requests.is_empty(),"production Narrative UI P0 failure starts Provider zero times")
	consumer.free();guarded_opening.provider_adapter.free();guarded_opening.free();transport.free()
	boundary33(assembler,settings.context_budget_metadata().context_budget)
	runtime.close()
	FileAccess.open(directory.path_join("budget-evidence.json"),FileAccess.WRITE).store_string(JSON.stringify(measurements33,"  "))
	print("MW033 checks=%d failures=%d real_provider_calls=0" % [checks,failures]);quit(0 if failures==0 else 1)

func setup33() -> Dictionary:
	var value := setup()
	value.merge({"schema_version":"game_local_setup.v0.1","creation_origin":{},"setup_ancestry":{},"game":{"game_id":"fixture","display_name":"fixture","control_mode":"Light"},"selected_entry_id":null,"world":{"local_world_id":"world","source_projection":{"display_name":"测试世界","world_instructions":"CURRENT_WORLD_INSTRUCTION","gm_instructions":"继续当前故事。","semantic_sections":[{"section_id":"background","content":"BACKGROUND_BEGIN"+"背".repeat(100000)+"BACKGROUND_END"}]}},"guaranteed_npcs":[]},true)
	value.player_character.source_projection["semantic_sections"]=[]
	value["unprojected_private"]="RAW_PRIVATE_CANARY"
	return value

func curate33(person_marker: String, thread_marker: String, character_marker: String) -> void:
	var entries: Array=runtime.conversation.get_durable_accepted_entries();var index:=entries.size()-1
	var prefixes:=Contract.prefix_hashes(entries)
	var prior:=Contract.current_records(runtime.world_state,entries.slice(0,index));var parent: String="" if prior.is_empty() else prior[-1].id
	var result: Dictionary={"character":{"headline":character_marker,"summary":"目前状态。","groups":[]},"experiences":[{"title":"CURRENT_EXPERIENCE","description":"一次重要转折。"}],"people_updates":[{"subject_id":"referent-only","actor_id":"","snapshot":person(person_marker,"只听说过","未确认其存在。")}],"open_threads":[{"thread_id":"thread","title":thread_marker,"summary":"尚未解决。","details":[]}]}
	var identity:=Contract.lived_record_id(prefixes[index],parent,result,"",Contract.CURRENT_LIVED_SCHEMA)
	var world: Dictionary=runtime.world_state.duplicate(true)
	if not world.has("information_curation"):world["information_curation"]={"schema":Contract.SCHEMA,"turns":{}}
	world.information_curation.turns[str(index)]={"schema":Contract.CURRENT_LIVED_SCHEMA,"prefix":prefixes[index],"parent":parent,"id":identity,"result":result,"identity_receipt_id":""}
	check(runtime.commit_world_mutation_durably("curation"+str(index),"curation-node"+str(index),world).success,"current curation fixture")

func boundary33(assembler: RefCounted, budget: Dictionary) -> void:
	var projection: Dictionary={"accepted_turns":[],"active_attempt":{"turn_index":0,"player_text":"唯一行动"}}
	var blocks: Array=[{"family":"people","tier":2,"text":"x"}]
	var base: Dictionary=assembler.assemble_working_set(projection,blocks,budget)
	var room: int=209715-base.context_stats.final_messages_bytes
	blocks[0].text="x".repeat(room+1)
	var exact: Dictionary=assembler.assemble_working_set(projection,blocks,budget)
	check(exact.context_stats.final_messages_bytes==209715 and exact.context_stats.families.people.included==1,"exact serialized budget retains entire card including envelope")
	blocks[0].text+="x"
	var over: Dictionary=assembler.assemble_working_set(projection,blocks,budget)
	check(over.context_stats.families.people.omitted==1 and not JSON.stringify(over.messages).contains("xxx"),"one byte over omits whole card")
	measurements33.append(exact.context_stats);measurements33.append(over.context_stats)
	var instruction_over: Dictionary=assembler.assemble_working_set(projection,[{"family":"game","tier":0,"text":"指令".repeat(50000)}],budget)
	check(not instruction_over.success and instruction_over.status=="required_context_overflow","required World instructions cannot be silently omitted")
	var invalid := setup33();invalid.guaranteed_npcs=[{"local_character_id":"bad"}]
	check(not OpeningProjector33.new().project_continuation(invalid).success,"invalid frozen NPC projection fails safely")
	var ooc: Dictionary={"accepted_turns":[{"turn_index":0,"player_text":"原文指导","gm_text":"原文回应","input_mode":"ooc"}],"active_attempt":{"turn_index":1,"player_text":"当前指导","input_mode":"ooc"}}
	var copy: Dictionary=ooc.duplicate(true)
	var guided: Dictionary=assembler.assemble_working_set(ooc,[],budget)
	check(guided.messages[1].content=="OOC / GM 指导\n原文指导" and guided.messages[2].content=="原文回应" and guided.messages[-1].content=="OOC / GM 指导\n当前指导" and ooc==copy,"mixed OOC guidance structurally marked with durable original untouched")
	check(not JSON.stringify(measurements33).contains("CURRENT_PERSON") and not JSON.stringify(measurements33).contains("RAW_PRIVATE_CANARY"),"diagnostics contain only structural counts and bytes")

