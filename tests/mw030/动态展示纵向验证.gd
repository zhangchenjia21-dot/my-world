extends "res://tests/mw022/会话调试观测纵向测试.gd"
const Host := preload("res://src/动态展示/L3_外交层/动态展示公开接口.gd")
const Definition := preload("res://src/动态展示/L3_外交层/信息表面定义公开接口.gd")
const Preferences := preload("res://src/动态展示/L3_外交层/展示偏好公开接口.gd")
const UIContract := preload("res://src/动态展示/L0_公理层/展示定义契约.gd")
const Inventory := preload("res://src/行囊/L3_外交层/行囊公开接口.gd")
const Threads := preload("res://src/信息整理/L3_外交层/事务投影公开接口.gd")
const Mechanics := preload("res://src/行动判定/L3_外交层/公开机制历史公开接口.gd")
var shell: Node
var preference_root: String

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="): directory=arg.trim_prefix("--root=")
		if arg=="--visual": visual=true
	if not directory.contains("mw030"): quit(2); return
	DirAccess.make_dir_recursive_absolute(directory)
	preference_root=directory.path_join("preferences")
	await host_contracts()
	preference_contracts()
	runtime=Runtime.new();check(runtime.open_current_game(directory.path_join("game.sqlite")).success,"isolated SQLite")
	check(runtime.commit_world_mutation_durably("setup","setup",setup()).success,"valid setup")
	accept("","你在桥边等候。")
	await open_shell()
	if curation.busy: complete(curation,{"character":Safe.project_session(runtime).character,"experiences":[]})
	await frames()
	var before: Dictionary=runtime.create_save_point("before")
	accept("我向两位陈安问路。","陈安说他是粮商。另一位陈安说他是守门人。")
	await frames()
	var refs:=request_refs(semantic.requests[-1])
	complete(semantic,{"changes":[],"people_bindings":[{"actor_ref":refs[0],"gm_span":{"start":0,"length":8}},{"actor_ref":refs[1],"gm_span":{"start":12,"length":2}}],"inventory_updates":{"add":[{"name":"书信","summary":"你已接过并随身保管的信。"}],"update":[],"remove":[]}})
	await frames()
	var evidence: Array=input().people_evidence
	var a:=person("陈安","粮商","愿意为你引路。".repeat(12));a.details=["他熟悉渡口与河道。".repeat(12)]
	var b:=person("陈安","守门人","守门人与你有不同的交情。")
	var reply:=answer([{"actor_ref":evidence[0].actor_ref,"snapshot":a},{"actor_ref":evidence[1].actor_ref,"snapshot":b}])
	reply.character={"headline":"渡口旅人","summary":"决定走出熟悉的村落。","groups":[{"title":"能力 / 专长说明","items":["学习观察河道","愿意向人请教"]}]}
	reply.experiences=[{"title":"走出村落","description":"从此开始独立生活。".repeat(100)},{"title":"走出村落","description":"在新生活中确定了长久的志向。"}]
	reply.open_threads=[{"title":"等候渡口消息","summary":"河路情况仍有未解的问题。","details":["粮商承诺稍后带来消息。"]}]
	complete(curation,reply);await frames()
	var world: Dictionary=runtime.world_state.duplicate(true)
	world["expansion_runtime"]={"public_d20_checks":[{"accepted_turn_index":1,"narrative_accepted":true,"player_text":"我向两位陈安问路。","intent":"问路","dc":12,"modifier":2,"stance":"normal","raw_rolls":[15],"selected_roll":15,"total":17,"outcome":"success","success_intent":"得知道路","failure_stakes":"耽搁行程","modifier_reason":"提供清楚线索","situation_reason":"正常交谈","private":"HIDDEN_CONTROL"}]}
	check(runtime.commit_world_mutation_durably("check","check",world).success,"controlled existing mechanics record")
	shell._refresh_player_safe_panels();await frames()
	var populated: Dictionary=runtime.create_save_point("populated")
	var presented:=PeopleSafe.project_presented_people(runtime)
	var milestones:=Safe.project_presented_experiences(runtime)
	check(presented.size()==2 and presented[0].presentation_key!=presented[1].presentation_key,"same-name exact actors have distinct opaque keys")
	check(milestones.size()==2 and milestones[0].presentation_key!=milestones[1].presentation_key,"same-title milestones retain record/ordinal identity")
	var records:=Contract.current_records(runtime.world_state,runtime.conversation.get_durable_accepted_entries())
	check(milestones[0].presentation_key==JSON.stringify(["experience",String(runtime.game_id),records[-1].id,0]).sha256_text(),"milestone key exact validated record identity")
	check(presented[0].presentation_key==JSON.stringify(["people",String(runtime.game_id),"npc-a"]).sha256_text(),"People key exact actor identity and Game")
	var baseline:=durable();var calls:=call_count();var safe_before:=Safe.project_session(runtime);var people_before:=PeopleSafe.project_session(runtime)
	for surface: String in ["character","important_experiences","people","threads","inventory","system"]:
		var view:=host(surface)
		var dto: Variant
		match surface:
			"character": dto=Safe.project_session(runtime).character
			"important_experiences": dto=Safe.project_presented_experiences(runtime)
			"people": dto=PeopleSafe.project_presented_people(runtime)
			"threads": dto=Threads.project_session(runtime)
			"inventory": dto=Inventory.project_session(runtime)
			"system": dto=Mechanics.project_session(runtime)
		var encoded:=JSON.stringify(Definition.build(surface,dto))
		for private: String in ["npc-a","npc-b","SECRET_PROFILE","PRIVATE_PLAN","HIDDEN_EVOLUTION","HIDDEN_CONTROL","world_state","source_gm_sha256","identity_receipt_id"]:
			check(not encoded.contains(private),"leaf definition excludes "+private)
		check(view.get_script()==Host and view.accepted_definition,"production shared Host "+surface)
		if surface not in UIContract.HIDEABLE: check(not all_text(view).contains("隐藏"),"no accidental hide "+surface)
	check(all_text(host("character")).contains("渡口旅人") and all_text(host("character")).contains("学习观察河道"),"Character content equivalent")
	check(all_text(host("threads")).contains("粮商承诺稍后带来消息。"),"Threads content equivalent")
	check(all_text(host("inventory")).contains("你已接过并随身保管的信。"),"Inventory content equivalent")
	check(all_text(host("system")).contains("[15] → 15 + 2 = 17 vs DC 12"),"System exact public arithmetic")
	check(not host("people").visible_cards[0].get_meta("expanded_body").visible,"People default collapsed")
	host("people").visible_cards[0].get_meta("visibility_button").pressed.emit()
	host("important_experiences").visible_cards[0].get_meta("visibility_button").pressed.emit()
	await frames()
	check(host("people").visible_cards.size()==1 and host("people").hidden_cards.size()==1,"hide only selected same-name person")
	check(host("important_experiences").visible_cards.size()==1 and host("important_experiences").hidden_cards.size()==1,"hide only selected same-title milestone")
	check(PeopleSafe.project_session(runtime)==people_before and Safe.project_session(runtime)==safe_before,"hide retains all semantic model DTOs")
	check(durable()==baseline and call_count()==calls,"hide zero Provider/Game/Timeline mutation")
	var pref_path: String=shell.visibility_preferences.path
	var preference_bytes:=FileAccess.get_file_as_bytes(pref_path)
	for canary: String in ["npc-a","npc-b","陈安","走出村落","HIDDEN_CONTROL"]: check(not FileAccess.get_file_as_string(pref_path).contains(canary),"preference no raw identity/prose "+canary)
	for surface: String in UIContract.SURFACES:
		shell._select_world_surface_mode("experiences" if surface=="important_experiences" else surface)
		shell._refresh_player_safe_panels()
	check(FileAccess.get_file_as_bytes(pref_path)==preference_bytes and durable()==baseline and call_count()==calls,"render/nav zero sidecar and gameplay writes")
	await update_one(0,person("陈安","新近得知的近况","CURRENT_UPDATED_PERSON"+"他正在渡口等候你。".repeat(15)))
	check(host("people").visible_cards.size()==1 and all_text(host("people").hidden_cards[0]).contains("CURRENT_UPDATED_PERSON"),"hidden update stays hidden and drawer contains current content")
	check(PeopleSafe.project_presented_people(runtime)[0].presentation_key==presented[0].presentation_key,"person key survives semantic update")
	check(not JSON.stringify(curation.requests).contains("presentation_key") and not JSON.stringify(curation.requests).contains(presented[0].presentation_key),"presentation keys/preferences never enter curator input")
	var updated: Dictionary=runtime.create_save_point("updated")
	await windows()
	baseline=durable();calls=call_count()
	host("people").hidden_cards[0].get_meta("visibility_button").pressed.emit();await frames()
	check(host("people").hidden_cards.is_empty() and all_text(host("people")).contains("CURRENT_UPDATED_PERSON"),"recover uses current snapshot")
	check(durable()==baseline and call_count()==calls,"recover zero Provider/Game mutation")
	host("people").visible_cards[0].get_meta("visibility_button").pressed.emit();await frames()
	check(runtime.restore_save_point(before.save_id).success,"Restore before curation")
	check(host("people").hidden_cards.is_empty() and host("important_experiences").hidden_cards.is_empty(),"noncurrent hidden items do not render")
	check(FileAccess.get_file_as_bytes(pref_path)==preference_bytes,"Restore does not rewind visibility preferences")
	check(runtime.restore_save_point(populated.save_id).success,"Restore same legitimate identities")
	check(host("people").hidden_cards.size()==1 and host("important_experiences").hidden_cards.size()==1,"returned identities still hidden")
	runtime.conversation.retry_or_regenerate_latest();runtime.conversation.append_delta("你没有离开村落，也未遇见那两个人。")
	check(runtime.complete_active_generation_durably().success,"Regenerate accepted source replacement")
	await frames()
	check(host("important_experiences").hidden_cards.is_empty() and PeopleSafe.project_session(runtime).is_empty() and Inventory.project_session(runtime).is_empty() and Threads.project_session(runtime).is_empty(),"current domain owners remove stale curation/inventory/thread definitions")
	check(runtime.restore_save_point(updated.save_id).success,"Restore updated for reopen")
	var game_id: String=runtime.game_id
	shell._close_game_session();shell.queue_free();await frames()
	runtime=Runtime.new();check(runtime.open_current_game(directory.path_join("game.sqlite")).success,"actual reopen")
	check(runtime.game_id==game_id,"same Game on reopen")
	await open_shell()
	check(host("people").hidden_cards.size()==1 and host("important_experiences").hidden_cards.size()==1,"reopen preserves both preferences")
	check(all_text(host("people").hidden_cards[0]).contains("CURRENT_UPDATED_PERSON"),"reopened drawer current content")
	baseline=durable();calls=call_count()
	host("important_experiences").hidden_cards[0].get_meta("visibility_button").pressed.emit();await frames()
	check(host("important_experiences").visible_cards.size()==2 and durable()==baseline and call_count()==calls,"milestone recover zero authoritative mutation")
	shell._close_game_session();shell.queue_free();await frames()
	print("MW030 checks=%d failures=%d" % [checks,failures]);quit(0 if failures==0 else 1)

func open_shell() -> void:
	shell=load("res://src/main.tscn").instantiate();shell.session_runtime=runtime
	shell.test_presentation_preference_root=preference_root
	semantic=Stub.new();curation=Stub.new();recommendation=Stub.new()
	shell.test_world_turn_adapter_override=semantic;shell.test_information_curator_adapter_override=curation
	shell.test_world_evolution_adapter_override=Stub.new();shell.test_action_recommender_adapter_override=recommendation
	shell.test_opening_adapter_override=Stub.new()
	root.add_child(shell);await frames();worker=shell.world_turn_runtime;curator=shell.information_curator
	shell.world_toggle.button_pressed=true;await frames()

func host(surface: String) -> Node:
	return shell.get("_"+({"important_experiences":"experiences"}.get(surface,surface))+"_panel_body").get_child(0)

func call_count() -> int:
	return semantic.requests.size()+curation.requests.size()+recommendation.requests.size()+shell.test_world_evolution_adapter_override.requests.size()

func all_text(node: Node) -> String:
	var text: String=String(node.text) if node is Label or node is Button else ""
	for child: Node in node.get_children(): text+=all_text(child)
	return text

func windows() -> void:
	var original:=durable();var calls:=call_count()
	var pref_path: String=shell.visibility_preferences.path
	var bytes:=FileAccess.get_file_as_bytes(pref_path)
	for dimensions: Vector2i in [Vector2i(960,540),Vector2i(1280,720),Vector2i(1920,1080)]:
		root.mode=Window.MODE_WINDOWED;root.size=dimensions;await frames()
		for surface: String in UIContract.SURFACES:
			shell._select_world_surface_mode("experiences" if surface=="important_experiences" else surface)
			var view:=host(surface)
			if visual and view.hidden_toggle!=null:
				view.hidden_toggle.button_pressed=false
				for card: Control in view.visible_cards+view.hidden_cards:
					if card.has_meta("collapse_toggle"): card.get_meta("collapse_toggle").button_pressed=false
				shell.world_surface_scroll.scroll_vertical=0;await frames()
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(directory.path_join("host-%s-hidden-collapsed-%dx%d.png" % [surface,dimensions.x,dimensions.y]))
			if view.hidden_toggle!=null: view.hidden_toggle.button_pressed=true
			for card: Control in view.visible_cards+view.hidden_cards:
				if card.has_meta("collapse_toggle"): card.get_meta("collapse_toggle").button_pressed=true
			await frames()
			for node: Node in view.find_children("*","Control",true,false):
				if (node is Label or node is Button) and node.is_visible_in_tree():
					check(node.get_theme_font_size("font_size")>=20,"effective20 "+surface)
					check(node.get_global_rect().end.x<=root.size.x,"horizontal geometry "+surface)
			check(shell.world_nav.is_visible_in_tree() and shell.world_nav.get_child_count()==8 and shell.narrative_view.player_input.get_global_rect().end.y<=root.size.y and not shell._player_status_has_content,"navigation/composer/status "+str(dimensions))
			var bar: VScrollBar=shell.world_surface_scroll.get_v_scroll_bar()
			if surface in ["people","important_experiences"]:
				check(bar.max_value>bar.page,"long content scrolls "+surface)
				shell.world_surface_scroll.scroll_vertical=int(bar.max_value);await frames()
				check(shell.world_surface_scroll.scroll_vertical>0,"recovery and last content reachable")
			if view.hidden_toggle!=null:
				shell.world_surface_scroll.ensure_control_visible(view.hidden_cards[0].get_meta("visibility_button"));await frames()
				var recovery: Button=view.hidden_cards[0].get_meta("visibility_button")
				check(recovery.get_global_rect().position.y>=shell.world_surface_scroll.get_global_rect().position.y and recovery.get_global_rect().end.y<=shell.world_surface_scroll.get_global_rect().end.y,"recovery button reachable inside scroll viewport")
			if visual:
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(directory.path_join("host-%s-%dx%d.png" % [surface,dimensions.x,dimensions.y]))
	check(durable()==original and call_count()==calls and FileAccess.get_file_as_bytes(pref_path)==bytes,"window operations read-only")

func host_contracts() -> void:
	var view:=Host.new();root.add_child(view)
	var valid:=Definition.build("character",{"headline":"普通 ${no_execution} 文本","summary":"正文","groups":[{"title":"分组","items":["事实"]}]})
	check(view.render(valid) and all_text(view).contains("${no_execution}"),"valid vocabulary and literal text")
	var base:=Definition.build("inventory",[])
	var bads: Array=[]
	var value: Dictionary=base.duplicate(true);value.children[0].kind="script";bads.append(value)
	for field: String in ["callback","NodePath","expression","resource","query","world_state","provider"]:
		value=base.duplicate(true);value.children[0][field]="SHOULD_NOT_EXECUTE";bads.append(value)
	value=base.duplicate(true);value.children.append(value.children[0].duplicate(true));bads.append(value)
	value=base.duplicate(true);value.children[0].text="x".repeat(UIContract.MAX_TEXT+1);bads.append(value)
	value=base.duplicate(true);value.children[0].role="arbitrary";bads.append(value)
	value=base.duplicate(true);value.children[0].text={"nested":"dict"};bads.append(value)
	var deep: Dictionary={"kind":"section","component_id":"deep0","title":"","children":[]};var tip: Dictionary=deep
	for i: int in 10:
		var next: Dictionary={"kind":"section","component_id":"deep"+str(i+1),"title":"","children":[]};tip.children.append(next);tip=next
	bads.append({"surface":"character","children":[deep]})
	value=base.duplicate(true);value.children.resize(UIContract.MAX_LIST+1);bads.append(value)
	var crowded: Array=[]
	for i: int in 1024:
		var children: Array=[]
		for j: int in 4: children.append({"kind":"text","component_id":"n_%d_%d" % [i,j],"text":"","role":"body"})
		crowded.append({"kind":"section","component_id":"s"+str(i),"title":"","children":children})
	bads.append({"surface":"character","children":crowded})
	for surface: String in ["inventory","system","threads","character"]:
		bads.append({"surface":surface,"children":[{"kind":"card","component_id":"bad_hide","title":"x","subtitle":"","collapsible":false,"visibility_key":"a".repeat(64),"children":[]}]})
	for bad: Variant in bads: check(not view.render(bad) and view.get_child_count()==1,"invalid contribution locally rejected")
	var card: Dictionary={"kind":"card","component_id":"card","title":"x","subtitle":"","collapsible":false,"visibility_key":"a".repeat(64),"children":[]}
	var bad_bool:=card.duplicate(true);bad_bool.collapsible="true"
	check(not view.render({"surface":"people","children":[bad_bool]}),"card boolean closed")
	var duplicate_key:=card.duplicate(true);duplicate_key.component_id="other"
	check(not view.render({"surface":"people","children":[card,duplicate_key]}),"duplicate visibility keys rejected")
	check(view.render(base),"renderer recovers after invalid contribution")
	view.queue_free();await frames()

func preference_contracts() -> void:
	var store:=Preferences.new("isolated",preference_root)
	check(not FileAccess.file_exists(store.path),"read absent creates no preference file")
	check(store.set_hidden("people","a".repeat(64),true),"atomic first hide")
	check(store.set_hidden("people","b".repeat(64),true),"atomic replacement existing preference")
	var reopened:=Preferences.new("isolated",preference_root)
	check(reopened.keys_for("people").size()==2,"preference standalone reopen")
	var before:=FileAccess.get_file_as_bytes(store.path)
	check(not store.set_hidden("inventory","a".repeat(64),true) and not store.set_hidden("people","npc-a",true),"preference rejects unsupported surface/raw ID")
	check(FileAccess.get_file_as_bytes(store.path)==before,"rejected preference no write")
	var file:=FileAccess.open(store.path,FileAccess.WRITE);file.store_string("corrupt");file.close()
	check(Preferences.new("isolated",preference_root).keys_for("people").is_empty(),"corrupt preference defaults visible")
	check(FileAccess.get_file_as_string(store.path)=="corrupt","corrupt read never rewrites")
	var oversized: Dictionary={"schema":Preferences.SCHEMA,"hidden_by_surface":{"people":[],"important_experiences":[]}}
	oversized.hidden_by_surface.people.resize(Preferences.MAX_KEYS+1)
	check(not Preferences.valid(oversized),"preference key count bounded")
	oversized.hidden_by_surface.people=["a".repeat(64),"a".repeat(64)]
	check(not Preferences.valid(oversized),"duplicate preference key rejected")
	file=FileAccess.open(store.path,FileAccess.WRITE);file.store_string(" ".repeat(Preferences.MAX_BYTES+1));file.close()
	check(Preferences.new("isolated",preference_root).keys_for("people").is_empty(),"oversized preference file defaults visible")
	var other:=Preferences.new("another-game",preference_root)
	check(other.path!=store.path and other.keys_for("people").is_empty(),"Game scoped preference")
	var blocked:=directory.path_join("not-a-directory");file=FileAccess.open(blocked,FileAccess.WRITE);file.store_string("fixture");file.close()
	var failed:=Preferences.new("isolated",blocked)
	check(not failed.set_hidden("people","a".repeat(64),true) and failed.keys_for("people").is_empty(),"write failure preserves in-memory visible state")

func setup() -> Dictionary:
	var state:=super.setup()
	state.world.source_projection["semantic_sections"]=[{"content":"桥旁道路。"}]
	state.player_character.source_projection["semantic_sections"]=[{"content":"旅人。"}]
	return state

func request_refs(messages: Array) -> Array:
	var refs: Array=[]
	var block: String=messages[1].content.split("People Actor References (identity only)\n")[1].split("\n\n")[0]
	for line: String in block.split("\n"):
		if line.is_empty(): continue
		var row: Dictionary=JSON.parse_string(line)
		refs.append(row.actor_ref)
	return refs
