extends "res://tests/mw022/会话调试观测纵向测试.gd"
const Inventory := preload("res://src/行囊/L3_外交层/行囊公开接口.gd")
const SemanticParser := preload("res://src/世界回合/L1_器件层/语义变更响应解析器.gd")
const Opening := preload("res://src/首次开场/L3_外交层/首次开场公开接口.gd")
const D20 := preload("res://src/行动判定/L3_外交层/行动判定公开接口.gd")
const WorldOnly := preload("res://src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd")
var shell: Node
const ITEM := {"name":"封口书信", "summary":"封口仍完整。INVENTORY_CANARY_ONLY"}

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="): directory = arg.trim_prefix("--root=")
		if arg == "--visual": visual = true
	if not directory.contains("mw029"): quit(2); return
	DirAccess.make_dir_recursive_absolute(directory)
	contracts()
	runtime = Runtime.new()
	check(runtime.open_current_game(directory.path_join("inventory.sqlite")).success,"isolated SQLite")
	check(runtime.commit_world_mutation_durably("setup","setup",setup()).success,"existing setup no invented gear")
	accept("","你在桥边等候。")
	shell = load("res://src/main.tscn").instantiate(); shell.session_runtime = runtime
	semantic=Stub.new(); shell.test_world_turn_adapter_override=semantic
	shell.test_information_curator_adapter_override=Stub.new()
	shell.test_world_evolution_adapter_override=Stub.new()
	shell.test_action_recommender_adapter_override=Stub.new()
	root.add_child(shell); await frames(); worker=shell.world_turn_runtime; observer=shell.debug_observer
	shell.world_toggle.button_pressed=true; shell.inventory_tab.button_pressed=true; await frames()
	check(Inventory.project_session(runtime).is_empty() and text_of(shell._inventory_panel_body).contains("当前没有已记录"),"initial Inventory empty in real Shell")
	check(semantic.requests.is_empty(),"reopen no historical semantic backfill")
	var before: Dictionary=runtime.create_save_point("before possession")
	await begin("我接过信。","你接过封口书信，收进怀中。")
	check(Inventory.project_session(runtime).is_empty(),"pending semantic never publishes proposed possession")
	var nodes: int=runtime.persistence.timeline_node_count(runtime.game_id).node_count
	complete(semantic,{"changes":["桥旁的通道已经开放。"],"inventory_updates":ops([ITEM])})
	check(runtime.persistence.timeline_node_count(runtime.game_id).node_count==nodes+1,"Inventory and World share exactly one candidate commit")
	await frames()
	check(Inventory.project_session(runtime)==[ITEM] and text_of(shell._inventory_panel_body).contains("封口书信"),"ADD immediately visible after semantic durable terminal")
	check(row("inventory",1).change=="changed" and row("inventory",1).counts.added==1,"Debug ADD safe count")
	check(runtime.world_state.has("living_world") and runtime.world_state.has("player_inventory"),"same snapshot owns World and Inventory")
	var after: Dictionary=runtime.create_save_point("with letter")
	var original: Dictionary=runtime.world_state.duplicate(true)
	var call_count: int=semantic.requests.size(); worker.consider_latest_accepted_turn(); await frames()
	check(semantic.requests.size()==call_count and Inventory.project_session(runtime)==[ITEM],"replay no call/no duplicate item")
	context_checks()
	await begin("我展开信查看。","你打开封口，读完信仍将它收好。")
	var rows := request_items()
	check(rows.size()==1 and rows[0].keys().size()==3 and not JSON.stringify(rows).contains("item_id"),"request-only refs plus safe material")
	var ref: String=rows[0].item_ref
	complete(semantic,{"changes":[],"inventory_updates":ops([], [{"item_ref":ref,"name":"书信","summary":"已读，仍由你保管。"}])}); await frames()
	check(Inventory.project_session(runtime)==[{"name":"书信","summary":"已读，仍由你保管。"}] and row("inventory",2).counts.updated==1,"use changes state through exact UPDATE, no mechanical consumption")
	await begin("我借着信纸辨认方向。","你看了一眼标记，依然带着信。")
	complete(semantic,{"changes":[]}); await frames()
	check(row("inventory",3).change=="no-change" and Inventory.project_session(runtime).size()==1,"ordinary use may be no-change")
	await begin("我把信交给信使。","信使接过书信，你已不再持有它。")
	complete(semantic,{"changes":[],"inventory_updates":ops([],[],[{"item_ref":request_items()[0].item_ref}])}); await frames()
	check(Inventory.project_session(runtime).is_empty() and row("inventory",4).counts.removed==1,"exact REMOVE clears possession")
	check(text_of(shell._inventory_panel_body).contains("当前没有已记录"),"real empty state after removal")
	check(runtime.restore_save_point(after.save_id).success,"Restore after ADD")
	check(Inventory.project_session(runtime)==[ITEM],"Restore exact possession")
	await begin("我等待。","你在桥边停留。")
	complete(semantic,{"changes":["远处的钟声已经停下。"],"inventory_updates":{"add":"invalid"}}); await frames()
	check(Inventory.project_session(runtime)==[ITEM] and row("inventory",2).terminal=="failed" and row("world",2).terminal=="committed","invalid optional subfield isolated from valid World commit")
	await begin("我继续等。","你听见脚步声。")
	semantic.simulate_failed(); await frames()
	check(row("inventory",3).terminal=="failed" and Inventory.project_session(runtime)==[ITEM],"Provider failure cannot mutate Inventory")
	await begin("我回望。","你回头看向桥面。")
	semantic.cancel(); await frames()
	check(row("inventory",4).terminal=="cancelled","cancelled semantic terminal")
	await begin("我稍作休息。","你坐在路边。")
	var stale_done: Callable=worker._provider_callbacks.completed
	var stale_delta: Callable=worker._provider_callbacks.text_delta
	check(runtime.restore_save_point(before.save_id).success,"Restore before possession with active request")
	stale_delta.call(JSON.stringify({"changes":[],"inventory_updates":ops([ITEM])})); stale_done.call(); await frames()
	check(Inventory.project_session(runtime).is_empty() and not observer.snapshot().any(func(r:Dictionary)->bool:return r.lane=="inventory"),"Restore clears epoch and late callback cannot publish")
	check(runtime.restore_save_point(after.save_id).success,"Restore after again")
	# 真实 Regenerate 接受另一 GM 版本，旧事件在新语义完成前就消失。
	check(runtime.conversation.retry_or_regenerate_latest()!=null,"Regenerate latest accepted version")
	runtime.conversation.append_delta("信使没有交出书信，只请你等候。")
	check(runtime.complete_active_generation_durably().success,"replacement accepted")
	check(Inventory.project_session(runtime).is_empty() and text_of(shell._inventory_panel_body).contains("当前没有已记录"),"source replacement invalidates event and UI immediately")
	await frames(); complete(semantic,{"changes":[]}); await frames()
	check(Inventory.project_session(runtime).is_empty(),"replacement no-change does not resurrect old item")
	var ooc_calls: int=semantic.requests.size()
	runtime.conversation.begin_turn("请放慢节奏","ooc"); runtime.conversation.append_delta("好的。"); runtime.complete_active_generation_durably(); await frames()
	check(semantic.requests.size()==ooc_calls,"OOC has zero Inventory/semantic opportunity")
	check(runtime.restore_save_point(after.save_id).success,"return to possession for UI")
	await windows("one")
	# 同一生产路径建立64个结构上限内的物品，非物品类别/负重规则。
	for batch:int in 8:
		var adds:Array=[]
		for j:int in 8: adds.append({"name":"已获物品 %d-%d" % [batch,j],"summary":"玩家已明确持有的事实描述。".repeat(6)})
		await begin("接过物品 "+str(batch),"你收下了这批物品。")
		complete(semantic,{"changes":[],"inventory_updates":ops(adds)}); await frames()
	check(Inventory.project_session(runtime).size()==64,"current snapshot defensive ceiling64")
	await windows("many")
	shell.debug_toggle.button_pressed=true; await frames(); await screenshot("inventory-debug.png")
	var trace:=JSON.stringify(observer.snapshot())
	for canary:String in ["封口书信","INVENTORY_CANARY_ONLY","item_id","item_ref","source_gm_sha256","SECRET_PROFILE"]:
		check(not trace.contains(canary),"Debug excludes "+canary)
	var file:=FileAccess.open(directory.path_join("inventory-debug.json"),FileAccess.WRITE);file.store_string(trace);file.close()
	var final_items:=Inventory.project_session(runtime)
	shell._close_game_session();shell.queue_free();await frames()
	var reopened:=Runtime.new();check(reopened.open_current_game(directory.path_join("inventory.sqlite")).success,"reopen real SQLite")
	check(Inventory.project_session(reopened)==final_items,"Save/reopen folded current items exact")
	var quiet:=Stub.new();var replay:=World.new(reopened,quiet);root.add_child(replay); replay.consider_latest_accepted_turn();await frames()
	check(quiet.requests.is_empty(),"reopen no historical backfill even on explicit consideration")
	replay.shutdown();replay.queue_free();await frames();reopened.close()
	print("MW029 checks=%d failures=%d" % [checks,failures]);quit(0 if failures==0 else 1)

func begin(player:String,gm:String) -> void:
	var calls:int=semantic.requests.size();accept(player,gm);await frames()
	check(semantic.requests.size()==calls+1,"one existing semantic opportunity per accepted action")

func request_items() -> Array:
	var content:String=semantic.requests[-1][1].content
	return JSON.parse_string(content.split("Current Inventory References\n")[1].split("\n\n")[0])

func ops(add:Array=[],update:Array=[],remove:Array=[]) -> Dictionary:
	return {"add":add,"update":update,"remove":remove}

func context_checks() -> void:
	var stub:=Stub.new();var opening:=Opening.new(runtime,stub);root.add_child(opening)
	for mode:String in ["action","ooc"]:
		runtime.conversation.begin_turn("接下来呢？",mode)
		var request:Dictionary=opening.assemble_continuation_messages()
		if not request.success: print(request)
		check(request.success and JSON.stringify(request.messages).contains("INVENTORY_CANARY_ONLY"),mode+" receives safe current Inventory")
		for key:String in ["player_inventory","item_id","item_ref","turns_by_index"]: check(not JSON.stringify(request.messages).contains(key),"foreground excludes "+key)
		runtime.conversation.cancel_generation()
	var d20:=D20.new(runtime,Stub.new());root.add_child(d20)
	for request:Array in [d20._control_messages({},false),d20._resolution_messages({}),d20._ordinary_narrative_messages({},false),d20._ordinary_narrative_messages({},true)]:
		check(JSON.stringify(request).contains("INVENTORY_CANARY_ONLY") and not JSON.stringify(request).contains("item_ref"),"all d20 stages safe Inventory grounding")
	check(not JSON.stringify(WorldOnly.new().project_world_only(runtime.world_state)).contains("INVENTORY_CANARY_ONLY"),"World-only authority excludes Inventory")
	check(stub.requests.is_empty() and d20.provider_adapter.requests.is_empty(),"projection adds zero Provider calls")
	opening.queue_free();d20.queue_free()

func contracts() -> void:
	var entries: Array=[{"turn_index":0,"player_text":"take","gm_text":"possess"}]
	check(Inventory.project({},entries).is_empty(),"no event means empty")
	var parsed:=Inventory.parse_updates(ops([ITEM,ITEM]))
	var first:=Inventory.candidate({},entries,0,parsed,{})
	check(Inventory.project(first.world,entries)==[ITEM,ITEM],"same-name distinct items never collapsed")
	check(Inventory.candidate(first.world,entries,0,parsed,{}).world==first.world,"deterministic replay stable IDs")
	var roundtrip:Dictionary=JSON.parse_string(JSON.stringify(first.world))
	check(Inventory.project(roundtrip,entries)==[ITEM,ITEM],"JSON event roundtrip")
	var detached:=Inventory.project(first.world,entries);detached[0].name="changed"
	check(Inventory.project(first.world,entries)[0]==ITEM,"detached safe DTO")
	entries.append({"turn_index":1,"player_text":"use","gm_text":"changed item"})
	var request:=Inventory.request(first.world,entries,1)
	check(request.rows[0].item_ref != Inventory.request(first.world,entries,1).rows[0].item_ref,"refs ephemeral per request")
	var ref:String=request.rows[1].item_ref
	var updated:=Inventory.candidate(first.world,entries,1,Inventory.parse_updates(ops([],[{"item_ref":ref,"name":"opened","summary":"retained"}])),request.refs)
	check(Inventory.project(updated.world,entries)==[ITEM,{"name":"opened","summary":"retained"}],"same-name second item targeted exactly")
	var duplicate:=Inventory.candidate(first.world,entries,1,Inventory.parse_updates(ops([],[{"item_ref":ref,"name":"bad","summary":"bad"}],[{"item_ref":ref}])),request.refs)
	check(duplicate.world==first.world,"duplicate refs rejected together")
	var unknown:=Inventory.candidate(first.world,entries,1,Inventory.parse_updates(ops([],[],[{"item_ref":"unknown"}])),request.refs)
	check(unknown.world==first.world,"unknown refs never name-match")
	entries.append({"turn_index":2,"player_text":"lose","gm_text":"lost"})
	var stale:=Inventory.candidate(updated.world,entries,2,Inventory.parse_updates(ops([],[],[{"item_ref":ref}])),request.refs)
	check(stale.world==updated.world,"stale snapshot ref cannot mutate changed item")
	var absent:Dictionary=updated.world.duplicate(true);absent.player_inventory.turns_by_index.erase("0")
	check(Inventory.project(absent,entries).is_empty(),"later UPDATE cannot resurrect absent ADD")
	var corrupt:Dictionary=first.world.duplicate(true);corrupt.player_inventory.turns_by_index["0"].ops[0].name="tampered"
	check(Inventory.project(corrupt,entries).is_empty(),"event corruption fail-soft")
	var replaced:=entries.duplicate(true);replaced[0].gm_text="never possessed"
	check(Inventory.project(updated.world,replaced).is_empty(),"replaced source invalidates old events")
	replaced=entries.duplicate(true);replaced[0]["input_mode"]="ooc"
	check(Inventory.project(first.world,replaced).is_empty(),"OOC not possession")
	for bad:Variant in [true,{},ops([{"name":"x","summary":"y","item_id":"forged"}]),ops([{"name":"x".repeat(121),"summary":"y"}]),ops([{"name":"x","summary":"y".repeat(601)}]),ops([],[],[{"item_ref":"x".repeat(129)}]),ops([ITEM,ITEM,ITEM,ITEM,ITEM,ITEM,ITEM,ITEM,ITEM])]:
		check(not Inventory.parse_updates(bad).valid,"invalid bounded Inventory subfield")
		var existing:=SemanticParser.new().parse(JSON.stringify({"changes":["valid world change"],"inventory_updates":bad}))
		check(existing.success and existing.changes==["valid world change"],"invalid Inventory preserves otherwise-valid World parser")
	check(Inventory.parse_updates(ops([{"name":"x".repeat(120),"summary":"y".repeat(600)}])).valid,"exact max material bounds")

func text_of(node:Node) -> String:
	var text:=String(node.text) if node is Label else ""
	for child:Node in node.get_children(): text+=text_of(child)
	return text

func windows(label:String) -> void:
	var snapshot:=durable();var calls:int=semantic.requests.size()
	for dimensions:Vector2i in [Vector2i(960,540),Vector2i(1280,720),Vector2i(1920,1080)]:
		root.size=dimensions;await frames()
		check(shell.world_nav.get_children().map(func(n:Node)->String:return n.text)==["概览","角色","重要经历","人物","事务","行囊","系统","存档"],"eight exact tabs")
		for tab:Button in shell.world_nav.get_children(): tab.button_pressed=true
		shell.inventory_tab.button_pressed=true;await frames()
		var labels:Array[Node]=shell._inventory_panel_body.find_children("*","Label",true,false)
		check(labels.all(func(n:Node)->bool:return n.get_theme_font_size("font_size")>=20 and n.get_global_rect().end.x<=root.size.x),"effective font>=20 and no horizontal overflow")
		check(shell.narrative_view.player_input.get_global_rect().end.y<=root.size.y and not shell._player_status_has_content,"composer usable and status host collapsed")
		shell.world_surface_scroll.scroll_vertical=0;await frames();await screenshot("inventory-%s-%dx%d.png" % [label,dimensions.x,dimensions.y])
		if label=="many":
			var bar:VScrollBar=shell.world_surface_scroll.get_v_scroll_bar();check(bar.max_value>bar.page,"crowded list scrolls")
			shell.world_surface_scroll.scroll_vertical=int(bar.max_value);await frames();check(shell.world_surface_scroll.scroll_vertical>0,"last item reachable")
	check(durable()==snapshot and semantic.requests.size()==calls,"tab/render zero Provider and durable writes")

func screenshot(name:String) -> void:
	if visual:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(directory.path_join(name))

func setup() -> Dictionary:
	var state:=super.setup()
	state.merge({"schema_version":"game_local_setup.v0.1","creation_origin":{},"game":{},"setup_ancestry":{},"guaranteed_npcs":[],"world":{"source_projection":{"display_name":"河畔小城","semantic_sections":[{"content":"桥旁有道路。"}]}}},true)
	state.player_character.source_projection["semantic_sections"]=[{"content":"一名旅人。"}]
	return state