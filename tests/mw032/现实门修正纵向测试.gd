extends "res://tests/mw022/会话调试观测纵向测试.gd"

const Subjects32 := preload("res://src/信息整理/L1_器件层/整理主体引用器.gd")
const ThreadSafe32 := preload("res://src/信息整理/L3_外交层/事务投影公开接口.gd")
const Inventory32 := preload("res://src/行囊/L3_外交层/行囊公开接口.gd")
const Preferences32 := preload("res://src/动态展示/L3_外交层/展示偏好公开接口.gd")
var prefs32: RefCounted

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="): directory = arg.trim_prefix("--root=")
	if not directory.contains("mw032"): quit(2); return
	DirAccess.make_dir_recursive_absolute(directory)
	contracts32()
	runtime = Runtime.new()
	check(runtime.open_current_game(directory.path_join("focused.sqlite")).success,"isolated database")
	check(runtime.commit_world_mutation_durably("setup","setup",setup()).success,"isolated initial state")
	semantic = Stub.new(); worker = World.new(runtime,semantic); root.add_child(worker)
	curation = Stub.new(); curator = Curator.new(runtime,curation,worker); root.add_child(curator)
	recommendation = Stub.new(); recommender = Recommender.new(runtime,recommendation); root.add_child(recommender)
	await frames()
	complete(curation,{"character":Safe.project_session(runtime).character,"experiences":[]}); await frames()
	var before: Dictionary = runtime.create_save_point("before opening")
	var roster: Variant = runtime.world_state.stable_npcs.duplicate(true)
	runtime.conversation.begin_gm_opening();runtime.conversation.append_delta("你携带封口书信，尚欠一笔债。你记得陈安的传闻。")
	check(runtime.complete_active_generation_durably().success,"accepted GM-only Opening")
	await frames()
	check(semantic.requests.size()==1 and not curation.busy,"Opening waits same semantic lane")
	check(not JSON.stringify(semantic.requests).contains("Durable Mechanical Resolution ("),"Opening no synthetic d20")
	complete(semantic,{"changes":[],"inventory_updates":{"add":[{"name":"封口书信","summary":"你正携带，封口完整。"}],"update":[],"remove":[]}})
	await frames()
	check(Inventory32.project_session(runtime).size()==1,"Opening Inventory before Player turn")
	check(curation.busy and input().input_mode=="opening" and input().accepted_player=="","Opening Curator no action evidence")
	var new_person := proposal32(null,null,person("陈安","记忆中的人","只听说过其事迹。"),"gm",{"start":18,"length":2})
	complete(curation,response32([new_person],[thread32(null,"偿还欠债")]))
	await frames()
	check(PeopleSafe.project_session(runtime).size()==1,"referent-only People accepted")
	check(runtime.world_state.stable_npcs==roster,"referent does not materialize actor")
	check(ThreadSafe32.project_session(runtime).size()==1,"Opening unresolved Thread")
	var initial_people := PeopleSafe.project_presented_people(runtime)
	var initial_threads := ThreadSafe32.project_presented_threads(runtime)
	prefs32=Preferences32.new(runtime.game_id,directory.path_join("preferences"))
	var stable_key: String=initial_threads[0].presentation_key
	check(prefs32.set_hidden("threads",stable_key,true),"Thread explicit hide")
	var preference_bytes:=FileAccess.get_file_as_bytes(prefs32.path)
	var saved: Dictionary=runtime.create_save_point("opening-current")
	complete(recommendation,{"actions":[]});await frames()
	check(recommendation.requests.size()==2 and recommendation.busy,"malformed first response starts only recovery")
	complete(recommendation,{"actions":ACTIONS});await frames()
	check(recommender.snapshot().actions==ACTIONS,"recovery exact five ready")
	await prepare32("我打听陈安","陈安正在岸边等你，债务已展期。")
	var refs: Array=[]
	for line: String in String(semantic.requests[-1][1].content).split("People Actor References (identity only)\n")[1].split("\n\n")[0].split("\n"):
		if not line.is_empty(): refs.append(JSON.parse_string(line).actor_ref)
	complete(semantic,{"changes":[],"people_bindings":[{"actor_ref":refs[0],"source_role":"gm","source_span":{"start":0,"length":2}}]});await frames()
	var person_ref: String=input().current_people[0].person_ref
	var actor_ref: String=input().people_evidence[0].actor_ref
	var thread_ref: String=input().current_open_threads[0].thread_ref
	complete(curation,response32([proposal32(person_ref,actor_ref,person("陈安","已见到本人","你见到了此人。"))],[thread32(thread_ref,"欠债已展期")]))
	await frames()
	check(PeopleSafe.project_presented_people(runtime)[0].presentation_key==initial_people[0].presentation_key,"exact actor link retains subject presentation identity")
	check(ThreadSafe32.project_presented_threads(runtime)[0].presentation_key==stable_key,"Thread update retains stable identity")
	check(prefs32.keys_for("threads")==[stable_key] and FileAccess.get_file_as_bytes(prefs32.path)==preference_bytes,"semantic update does not unhide or write preference")
	var context: Dictionary=curator._active.get("subjects",{})
	check(context.is_empty(),"completed request private maps released")
	for token: String in ["npc-a","subject_id","thread_id","SECRET_PROFILE","PRIVATE_PLAN","HIDDEN_EVOLUTION"]:
		check(not JSON.stringify(input()).contains(token),"request excludes "+token)
	complete(recommendation,{"actions":[]});await frames();complete(recommendation,{"actions":[]});await frames()
	var attempts: int=recommendation.requests.size();recommender._consider(recommender._serial);await frames()
	check(recommendation.requests.size()==attempts and recommender.snapshot().status=="unavailable","second failure final no third start")
	await prepare32("我还清债务","你还清了债务，当前没有待办。")
	complete(semantic,{"changes":[]});await frames();complete(curation,response32([],[]));await frames()
	check(ThreadSafe32.project_session(runtime).is_empty(),"explicit review omission removes Thread")
	complete(recommendation,{"actions":[]})
	recommender.interrupt_foreground();var starts: int=recommendation.requests.size();await frames()
	check(recommendation.requests.size()==starts,"foreground before deferred retry cancels old retry")
	check(runtime.restore_save_point(saved.save_id).success,"Restore opening-current")
	await frames()
	check(ThreadSafe32.project_presented_threads(runtime)[0].presentation_key==stable_key,"Restore recovers original semantic identity")
	check(PeopleSafe.project_session(runtime)[0].summary=="只听说过其事迹。","Restore removes future actor link snapshot")
	check(FileAccess.get_file_as_bytes(prefs32.path)==preference_bytes,"Restore does not rewind preference bytes")
	check(runtime.restore_save_point(before.save_id).success,"Restore before opening")
	await frames()
	check(Inventory32.project_session(runtime).is_empty() and PeopleSafe.project_session(runtime).is_empty() and ThreadSafe32.project_session(runtime).is_empty(),"restored-away Opening material absent")
	check(runtime.restore_save_point(saved.save_id).success,"restore for reopen")
	await frames()
	recommender.shutdown();recommender.queue_free();teardown();await frames();runtime.close()
	runtime=Runtime.new();check(runtime.open_existing_game(directory.path_join("focused.sqlite")).success,"reopen")
	semantic=Stub.new();worker=World.new(runtime,semantic);root.add_child(worker)
	curation=Stub.new();curator=Curator.new(runtime,curation,worker);root.add_child(curator);await frames()
	worker.consider_latest_accepted_turn();await frames()
	check(semantic.requests.is_empty() and curation.requests.is_empty(),"reopen durable current no Provider replay")
	var reopened_prefs:=Preferences32.new(runtime.game_id,directory.path_join("preferences"))
	check(reopened_prefs.keys_for("threads")==[stable_key],"reopen Thread hide retained")
	check(reopened_prefs.set_hidden("threads",stable_key,false),"recover current Thread")
	check(not reopened_prefs.set_hidden("inventory",stable_key,true) and not reopened_prefs.set_hidden("system",stable_key,true),"authoritative surfaces not hideable")
	teardown();await frames();runtime.close()
	await extra32()
	print("MW032 checks=%d failures=%d" % [checks,failures]);quit(0 if failures==0 else 1)

func prepare32(player: String, gm: String) -> void:
	accept(player,gm);await frames()

func proposal32(ref: Variant, actor: Variant, snapshot: Variant, role: Variant=null, span: Variant=null) -> Dictionary:
	return {"person_ref":ref,"actor_ref":actor,"source_role":role,"source_span":span,"snapshot":snapshot}

func thread32(ref: Variant, summary: String) -> Dictionary:
	return {"thread_ref":ref,"title":"欠债","summary":summary,"details":[]}

func response32(people: Array, threads: Array) -> Dictionary:
	return {"character":null,"experiences":[],"people_updates":people,"open_threads":threads}

func contracts32() -> void:
	var entry := {"turn_index":0,"player_text":"我记得陈安与另一位陈安。","gm_text":"路旁有一把剑。"}
	var prefix: String=Contract.prefix_hashes([entry])[0]
	var receipt_rules = load("res://src/世界回合/L0_公理层/人物身份回执规则.gd")
	var legacy_receipt: Dictionary = receipt_rules.build("fixture",0,prefix,[{"local_character_id":"npc-a","gm_span":{"start":0,"length":2}}])
	var legacy_world: Dictionary = receipt_rules.with_receipt(setup(),legacy_receipt)
	var legacy_person: Dictionary = person("陈安","旧卡","旧版已知人物。")
	var old_result: Dictionary = {"character":null,"experiences":[],"people_updates":[{"local_character_id":"npc-a","snapshot":legacy_person}]}
	var old_id: String = Contract.lived_record_id(prefix,"",old_result,legacy_receipt.id,Contract.PREVIOUS_LIVED_SCHEMA)
	legacy_world["information_curation"] = {"schema":Contract.SCHEMA,"turns":{"0":{"schema":Contract.PREVIOUS_LIVED_SCHEMA,"prefix":prefix,"parent":"","id":old_id,"result":old_result,"identity_receipt_id":legacy_receipt.id}}}
	var legacy_before: Dictionary = legacy_world.duplicate(true)
	var people_device = load("res://src/信息整理/L1_器件层/人物认知投影器.gd")
	var old_people: Dictionary = people_device.subjects(legacy_world,"fixture",[entry])
	check(old_people.has("npc-a") and old_people["npc-a"].snapshot==legacy_person and old_people["npc-a"].actor_id=="npc-a","legacy v0.2 actor-backed People retains exact subject and snapshot")
	check(Contract.current_records(legacy_world,[entry])[0].id==old_id and legacy_world==legacy_before,"legacy People hash and Timeline bytes unchanged on read")
	var context:=Subjects32.request({},[],"fixture",prefix,entry,{"actor":"npc-a"})
	var a:=proposal32(null,null,person("陈安","传闻","未确认其存在。"),"player",{"start":3,"length":2})
	var b:=proposal32(null,null,person("陈安","另一人","只知道称呼。"),"player",{"start":9,"length":2})
	var result:=Subjects32.resolve_people([a,b],context)
	check(result.size()==2 and result[0].subject_id!=result[1].subject_id,"same-name referents are distinct without actor")
	check(Subjects32.resolve_people([a,b],context)==result,"same accepted proposal replay has deterministic IDs")
	var bad:=a.duplicate(true);bad.source_span.start=999
	check(Subjects32.resolve_people([bad],context).is_empty(),"out-of-range source evidence rejected")
	bad=a.duplicate(true);bad.source_span.start=1.5
	check(Subjects32.resolve_people([bad],context).is_empty(),"fractional span rejected")
	bad=a.duplicate(true);bad.actor_ref="unknown"
	check(Subjects32.resolve_people([bad],context).is_empty(),"unknown actor ref never name-resolved")
	var subjects: Dictionary={}
	for item: Dictionary in result: subjects[item.subject_id]={"snapshot":item.snapshot,"actor_id":""}
	context=Subjects32.request(subjects,[],"fixture",prefix,entry,{"actor":"npc-a"})
	var one: String=context.person_rows[0].person_ref
	var two: String=context.person_rows[1].person_ref
	check(Subjects32.resolve_people([proposal32(one,"actor",a.snapshot),proposal32(two,"actor",b.snapshot)],context).is_empty(),"ambiguous two-subject actor link rejected")
	check(Subjects32.resolve_people([proposal32(one,null,a.snapshot),proposal32(one,null,a.snapshot)],context).is_empty(),"duplicate subject operations rejected")
	var kept:=Subjects32.resolve_people([proposal32(one,"actor",a.snapshot)],context)
	check(kept.size()==1 and kept[0].subject_id==result[0].subject_id,"later exact link preserves referent identity")
	var legacy_result: Dictionary={"character":null,"experiences":[],"people_updates":[],"open_threads":[{"title":"同名事务","summary":"旧事项","details":[]},{"title":"同名事务","summary":"另一个旧事项","details":[]}]}
	var id:=Contract.lived_record_id(prefix,"",legacy_result,"",Contract.LIVED_SCHEMA)
	var world: Dictionary={"information_curation":{"schema":Contract.SCHEMA,"turns":{"0":{"schema":Contract.LIVED_SCHEMA,"prefix":prefix,"parent":"","id":id,"result":legacy_result,"identity_receipt_id":""}}}}
	var Fold32=load("res://src/信息整理/L1_器件层/事务快照投影器.gd")
	var old: Array=Fold32.fold(world,[entry])
	check(old.size()==2 and old[0].thread_id!=old[1].thread_id and not old[0].hide_eligible,"legacy v0.3 uses record+ordinal bridge without hide")
	var original:=world.duplicate(true)
	context=Subjects32.request({},old,"fixture",prefix,entry,{})
	var threads: Variant=Subjects32.resolve_threads([thread32(context.thread_rows[1].thread_ref,"修改后的内容")],context)
	check(threads.size()==1 and threads[0].thread_id==old[1].thread_id,"legacy transition uses exact ref not title")
	check(world==original,"legacy record not rewritten during transition")
	check(Subjects32.resolve_threads(null,context)==null,"new opportunity cannot skip Thread review")
	check(Subjects32.resolve_threads([thread32("unknown","x")],context)==null,"unknown Thread ref rejected")
	check(Subjects32.resolve_threads([],context)==[],"empty explicit reviewed set valid")
	var v4: Dictionary={"character":null,"experiences":[],"people_updates":result,"open_threads":threads}
	check(Contract.normalize_lived(v4,Contract.CURRENT_LIVED_SCHEMA)==v4,"new normalized schema retains identities")
	check(Contract.normalize_lived(v4,Contract.LIVED_SCHEMA).is_empty(),"new IDs cannot masquerade as legacy schema")
	var prefs:=Preferences32.new("legacy",directory.path_join("compat-preferences"))
	DirAccess.make_dir_recursive_absolute(prefs.path.get_base_dir())
	var key: String="old-person".sha256_text()
	var experience: String="old-experience".sha256_text()
	var file:=FileAccess.open(prefs.path,FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema":"ui_visibility.v0.1","hidden_by_surface":{"people":[key],"important_experiences":[experience]}}));file.close()
	var bytes:=FileAccess.get_file_as_bytes(prefs.path)
	prefs=Preferences32.new("legacy",directory.path_join("compat-preferences"))
	check(prefs.keys_for("people")==[key] and prefs.keys_for("important_experiences")==[experience],"old preference choices preserved")
	check(FileAccess.get_file_as_bytes(prefs.path)==bytes,"no write-on-read migration")
	check(prefs.set_hidden("threads","thread".sha256_text(),true),"explicit Thread hide upgrades preference schema")
	var stored: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(prefs.path))
	check(stored.schema=="ui_visibility.v0.2" and stored.hidden_by_surface.people==[key] and stored.hidden_by_surface.important_experiences==[experience],"v0.2 keeps exact v0.1 keys")

func extra32() -> void:
	runtime=Runtime.new();check(runtime.open_current_game(directory.path_join("extra.sqlite")).success,"extra isolated Game")
	check(runtime.commit_world_mutation_durably("setup","setup",setup()).success,"extra setup")
	semantic=Stub.new();worker=World.new(runtime,semantic);root.add_child(worker)
	curation=Stub.new();curator=Curator.new(runtime,curation,worker);root.add_child(curator)
	recommendation=Stub.new();recommender=Recommender.new(runtime,recommendation);root.add_child(recommender);await frames()
	complete(curation,{"character":Safe.project_session(runtime).character,"experiences":[]});await frames()
	runtime.conversation.begin_gm_opening();runtime.conversation.append_delta("沈青是你的新向导，正在路边等候。墙上挂着一把剑。")
	runtime.complete_active_generation_durably();await frames()
	var old_count: int=runtime.world_state.stable_npcs.size()
	complete(semantic,{"changes":[],"new_actor_candidates":[{"candidate_ref":"guide","display_name":"沈青","profile_text":"你的向导，已在路边等候。"}],"people_bindings":[{"candidate_ref":"guide","source_role":"gm","source_span":{"start":0,"length":2}}]});await frames()
	check(runtime.world_state.stable_npcs.size()==old_count+1 and not input().people_evidence.is_empty(),"Opening actual continuing NPC materialized and bound")
	check(Inventory32.project_session(runtime).is_empty(),"environment sword creates no Inventory")
	complete(curation,response32([],[]));await frames()
	check(ThreadSafe32.project_session(runtime).is_empty(),"Opening without pending matter creates no fake Thread")
	var saved: Dictionary=runtime.create_save_point("before replace")
	var old_delta: Callable=recommender._callbacks.text_delta
	var old_done: Callable=recommender._callbacks.completed
	recommender._on_timeout(recommender._serial);await frames()
	check(recommendation.requests.size()==2 and recommendation.busy,"timeout one recovery")
	old_delta.call(JSON.stringify({"actions":ACTIONS}));old_done.call()
	check(recommender.snapshot().actions.is_empty() and recommendation.busy,"old attempt callbacks cannot complete recovery")
	complete(recommendation,{"actions":ACTIONS});await frames()
	runtime.conversation.retry_or_regenerate_latest();runtime.conversation.append_delta("路边空无一人，剑仍在墙上。")
	runtime.complete_active_generation_durably();await frames()
	check(Bridge.applicable_npc_ids(runtime.world_state,runtime.conversation.get_durable_accepted_entries()).size()==3,"Regenerate excludes Opening runtime actor immediately")
	var previous_done: Callable=recommender._callbacks.completed
	var previous_delta: Callable=recommender._callbacks.text_delta
	check(runtime.restore_save_point(saved.save_id).success,"Restore cancels replacement requests")
	await frames();previous_delta.call(JSON.stringify({"actions":ACTIONS}));previous_done.call()
	check(recommender.snapshot().actions.is_empty(),"pre-Restore callbacks cannot publish")
	if recommendation.busy: complete(recommendation,{"actions":ACTIONS})
	accept("看一看","你只是环顾四周。");await frames()
	recommendation.simulate_failed();await frames()
	check(recommender._attempt_count==2 and recommendation.busy,"transient Provider failure retries once")
	recommendation.simulate_failed();await frames()
	check(not recommendation.busy and recommender.snapshot().status=="unavailable","second transport failure ends recovery")
	accept("休息","你坐下来休息。");await frames()
	var starts: int=recommendation.requests.size()
	recommendation.simulate_failed("missing_key");await frames()
	check(recommendation.requests.size()==starts and not recommendation.busy,"missing credential never retries")
	recommender.shutdown();recommender.queue_free();teardown();await frames();runtime.close()
