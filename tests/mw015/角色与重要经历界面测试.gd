extends SceneTree

## MW-015 Character + Important Experiences Surfaces v0.1 focused proof。
## 真实 FinalCreate Game + real Shell(main.tscn) + real SQLite：右侧 概览|角色|重要经历|人物|事务|存档
## 有界导航真实消费 MW-014 player-safe L3 投影 seam；左 Player Status Host 过渡 biography
## 迁出后 collapse/hide。不含语义分类器/解析器/打分；Provider 全部走桩；real Provider calls = 0。

const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const SafeView := preload("res://src/信息整理/L3_外交层/角色经历投影公开接口.gd")
const GenericStub := preload("res://tests/g4_07a/首次开场桩适配器.gd")
const SemanticStub := preload("res://tests/g5_01/世界回合语义桩适配器.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

const NO_CHANGE := {"character": null, "experiences": []}

var _failures := 0
var _root := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("mw015") < 0:
		_fail("必须提供 task-owned --root，且路径包含 mw015")
		return _finish()
	DirAccess.make_dir_recursive_absolute(_root)
	await _test_shell_surfaces()
	_finish()


func _curated(item: String, title: String) -> Dictionary:
	return {
		"character": {"headline": "刘备", "summary": "汉室宗亲，正在乱世中建立自己的根基。", "groups": [{"title": "能力 / 专长说明", "items": [item]}]},
		"experiences": [{"title": title, "description": "这是一次由模型判断的主角重要经历。"}],
	}


func _test_shell_surfaces() -> void:
	var fixture := Fixture.new()
	fixture.reset_directory(_root)
	var installed: Dictionary = fixture.install_packages(_root.path_join("source-library"), [
		{"type": "world", "path": "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定"},
		{"type": "character", "path": "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/刘备"},
		{"type": "character", "path": "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/孙权"},
	])
	if not installed.success:
		_fail("real Source install")
		return
	var library: RefCounted = installed.library
	var creation := Creation.new(library)
	creation.select_world(fixture.find_generation(installed.installed, "world.han_end.unsettled_realm"))
	creation.select_entry("t0-208-red-cliffs-eve")
	creation.confirm_expansion_none()
	creation.select_player(fixture.find_generation(installed.installed, "character.han_end.liu_bei"))
	creation.set_guaranteed_npc(fixture.find_generation(installed.installed, "character.han_end.sun_quan"), true)
	creation.set_settings("MW-015", "Light", "")
	var created: Dictionary = FinalCreate.new(library, _root.path_join("creation"), _root.path_join("library"), _root.path_join("games")).create_or_resume("mw015-surfaces", creation.composition_snapshot())
	if not created.success:
		_fail("Final Create | %s" % JSON.stringify(created))
		return
	var runtime: RefCounted = Runtime.new()
	_check(runtime.open_existing_game(String(created.database_path)).success, "real Game opens")

	var opening_stub := GenericStub.new()
	var narrative_stub := GenericStub.new()
	var semantic_stub := SemanticStub.new()
	var curator_stub := SemanticStub.new()
	var evolution_stub := SemanticStub.new()
	root.size = Vector2i(1600, 900)
	await process_frame
	var inst: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	inst.session_runtime = runtime
	inst.test_opening_adapter_override = opening_stub
	inst.test_world_turn_adapter_override = semantic_stub
	inst.test_information_curator_adapter_override = curator_stub
	inst.test_world_evolution_adapter_override = evolution_stub
	root.add_child(inst)
	await _frames()
	opening_stub.simulate_delta("建安十三年秋，大军压境。")
	opening_stub.simulate_completed()
	await _frames()
	_check(runtime.conversation.get_durable_accepted_entries().size() == 1, "GM opening accepted")

	# 1 导航结构：恰好 概览|角色|重要经历|人物|事务|存档 六个互斥 toggle，默认概览。
	var nav_labels := PackedStringArray()
	var all_toggle := true
	for child: Node in inst.world_nav.get_children():
		var tab := child as Button
		if tab == null:
			all_toggle = false
			continue
		nav_labels.append(tab.text)
		all_toggle = all_toggle and tab.toggle_mode
	_check(nav_labels == PackedStringArray(["概览", "角色", "重要经历", "人物", "事务", "存档"]) and all_toggle, "1 right navigation is exactly 概览|角色|重要经历|人物|事务|存档 toggles")
	_check(inst.overview_tab.button_pressed and not inst.character_tab.button_pressed and not inst.experiences_tab.button_pressed and not inst.save_tab.button_pressed, "1 bounded navigation defaults to Overview")
	_check(inst.get_node(NodePath("Margin/Layout/HostLayout/WorldSurfaceHost/WorldPanelMargin/WorldPanelColumn/WorldHeader")).text == "信息", "1 right chrome renamed to 信息")
	_check(inst.get_node("%WorldToggle").text == "信息", "1 narrow World toggle renamed to 信息")
	_check(inst.world_surface_scroll is ScrollContainer and inst.world_surface_column.get_parent() == inst.world_surface_scroll, "1 right surfaces live inside a scroll container")

	# 2 默认概览保留 world/entry/主角所知；recent actions/turn count 不搬进概览。
	var overview_text := _surface_text(inst._world_panel_body)
	_check(overview_text.contains("汉末三国：天下未定") and overview_text.contains("208｜赤壁前夕") and overview_text.contains("主角所知"), "2 Overview keeps world/entry/player-known facts")
	_check(not overview_text.contains("已进行") and not overview_text.contains("最近行动"), "2 recent actions / turn count not moved into Overview")
	_check(inst._world_panel_body.visible and not inst._character_panel_body.visible and not inst._experiences_panel_body.visible and not inst.save_surface.visible, "2 only Overview surface visible by default")

	# 3 左 Player Status Host：过渡 biography 已迁出；无真实 portrait/mechanics → collapse/hide。
	var player_text := _panel_text(inst, "Margin/Layout/HostLayout/PlayerPanelHost/PlayerPanelMargin/PlayerPanelScroll/PlayerPanelColumn")
	_check(not player_text.contains("刘备") and not player_text.contains("208 人物起点") and not player_text.contains("最近行动") and not player_text.contains("已进行"), "3 left Host no longer carries biography/profile/recent-actions/turn-count")
	_check(not inst.player_panel_host.visible, "3 empty Player Status Host collapses in wide layout")
	_check(not inst._player_status_has_content, "3 no fabricated portrait/mechanics contribution")

	# 4 Character Surface 初始 = MW-014 seam 的 frozen profile（groups 刻意不回填 authored 组）。
	inst.character_tab.button_pressed = true
	await process_frame
	_check(inst._character_panel_body.visible and not inst._world_panel_body.visible and not inst.save_surface.visible, "4 switching to Character shows only Character surface")
	var initial: Dictionary = SafeView.project_session(runtime)
	var character_text := _surface_text(inst._character_panel_body)
	var initial_headline := String(initial.character.headline).strip_edges()
	if initial_headline.is_empty():
		_check(character_text.contains("角色信息将随游戏进展整理显示。"), "4 Character quiet empty state without frozen profile")
	else:
		_check(character_text.contains(initial_headline) and character_text.contains(String(initial.character.summary).strip_edges()), "4 Character Surface renders frozen profile via MW-014 seam")
		if (initial.character.groups as Array).is_empty():
			_check(character_text.contains("暂无更多角色信息。"), "4 authored groups are not backfilled into Character")

	# 5 Important Experiences 初始安静空态；无权威 calendar 时不伪造日期标签。
	inst.experiences_tab.button_pressed = true
	await process_frame
	var experiences_text := _surface_text(inst._experiences_panel_body)
	_check(inst._experiences_panel_body.visible and experiences_text.contains("尚无需要长期记录的重要经历。"), "5 Important Experiences quiet empty state")

	# 6 tab 切换纯 UI 可见性操作：零 Runtime mutation。
	var frozen_world: Dictionary = runtime.world_state.duplicate(true)
	var frozen_head := String(runtime.active_head_id)
	for tab: Button in [inst.overview_tab, inst.character_tab, inst.experiences_tab, inst.save_tab, inst.overview_tab]:
		tab.button_pressed = true
		await process_frame
	_check(runtime.world_state == frozen_world and String(runtime.active_head_id) == frozen_head, "6 surface switching is zero-mutation")
	_check(inst.save_surface.visible == false and inst._world_panel_body.visible, "6 switching back to Overview restores overview content")

	# 7 accepted turn → curator finished 刷新：模型整理结果同回合可见。
	var pre_curation_save: Dictionary = runtime.create_save_point("整理之前")
	_check(pre_curation_save.success, "save before curation")
	var view: Node = inst.get_node("%NarrativeHost")
	_swap_view_adapter(inst, narrative_stub)
	_send(view, "我巡视粮草。")
	narrative_stub.simulate_delta("你巡视粮仓，账目清楚。")
	narrative_stub.simulate_completed()
	await _frames()
	_settle_lane(semantic_stub, JSON.stringify({"changes": []}))
	await _frames() # MW-017：curator 在 current semantic terminal 之后启动。
	_check(curator_stub.busy, "7 production curator request starts after accepted turn")
	curator_stub.simulate_delta(JSON.stringify(_curated("善抚士卒", "首巡粮仓")))
	curator_stub.simulate_completed()
	await _frames()
	inst.character_tab.button_pressed = true
	await process_frame
	_check(_surface_text(inst._character_panel_body).contains("善抚士卒"), "7 curator finished refreshes Character Surface same-turn")
	inst.experiences_tab.button_pressed = true
	await process_frame
	var curated_experiences := _surface_text(inst._experiences_panel_body)
	_check(curated_experiences.contains("首巡粮仓") and curated_experiences.contains("这是一次由模型判断的主角重要经历。"), "7 curator finished refreshes Important Experiences same-turn")
	_check(not curated_experiences.contains("2026") and not curated_experiences.contains("回合"), "7 no invented calendar/turn label on milestone")

	# 8 curator 失败不白屏、不阻断：表面保持 current durable 投影，前台不被 gate。
	_send(view, "我回帐休息。")
	narrative_stub.simulate_delta("你回帐安歇。")
	narrative_stub.simulate_completed()
	await _frames()
	_settle_lane(semantic_stub, JSON.stringify({"changes": []}))
	await _frames() # MW-017：curator 在 current semantic terminal 之后启动。
	_check(curator_stub.busy, "8 curator request starts for second turn")
	curator_stub.simulate_failed()
	await _frames()
	_check(_surface_text(inst._character_panel_body).contains("善抚士卒") and _surface_text(inst._experiences_panel_body).contains("首巡粮仓"), "8 curator failure preserves current surfaces")
	_check(runtime.conversation.begin_turn("探头看看。") != null, "8 curator failure does not gate foreground")
	runtime.conversation.cancel_generation()
	await _frames()

	# 9 Restore currentness：回到整理之前 → restored-away Character/经历立即从表面消失。
	_check(runtime.restore_save_point(String(pre_curation_save.save_id)).success, "production Restore to pre-curation snapshot")
	await _frames()
	inst.character_tab.button_pressed = true
	await process_frame
	_check(not _surface_text(inst._character_panel_body).contains("善抚士卒"), "9 restored-away Character material disappears")
	inst.experiences_tab.button_pressed = true
	await process_frame
	_check(_surface_text(inst._experiences_panel_body).contains("尚无需要长期记录的重要经历。"), "9 restored-away milestones disappear")

	# 10 Restore 后重新整理可恢复；Regenerate 替换 accepted 版本 → 旧 prefix 整理结果立即失效。
	_send(view, "我夜查营门。")
	narrative_stub.simulate_delta("你夜查营门，戒备森严。")
	narrative_stub.simulate_completed()
	await _frames()
	_settle_lane(semantic_stub, JSON.stringify({"changes": []}))
	await _frames() # MW-017：curator 在 current semantic terminal 之后启动。
	if curator_stub.busy:
		curator_stub.simulate_delta(JSON.stringify(_curated("纪律严明", "夜查营门")))
		curator_stub.simulate_completed()
		await _frames()
	inst.character_tab.button_pressed = true
	await process_frame
	_check(_surface_text(inst._character_panel_body).contains("纪律严明"), "10 re-curation after Restore updates surfaces")
	runtime.conversation.retry_or_regenerate_latest()
	runtime.conversation.append_delta("你巡营而归，一夜无事。")
	_check(runtime.complete_active_generation_durably().success, "regenerate replaces accepted version")
	_check((SafeView.project_session(runtime).important_experiences as Array).is_empty(), "10 superseded curation fails currentness immediately at seam level")
	await _frames()
	_settle_lane(semantic_stub, JSON.stringify({"changes": []}))
	await _frames() # MW-017：curator 在 current semantic terminal 之后启动。
	_settle_lane(curator_stub, JSON.stringify(NO_CHANGE))
	inst.character_tab.button_pressed = true
	await process_frame
	_check(not _surface_text(inst._character_panel_body).contains("纪律严明"), "10 superseded curation disappears from Character Surface after Regenerate")

	# 11 响应式：narrow 下无内容的 Player toggle 不显示；信息 toggle 折叠右栏；wide 恢复。
	root.size = Vector2i(900, 600)
	await _frames()
	_check(inst.get_node("%WorldToggle").visible, "11 narrow width shows 信息 toggle")
	_check(not inst.get_node("%PlayerToggle").visible, "11 narrow width hides useless Player toggle")
	_check(not inst.player_panel_host.visible, "11 empty left Host stays collapsed in narrow layout")
	var world_toggle: Button = inst.get_node("%WorldToggle")
	world_toggle.button_pressed = true
	await process_frame
	_check(inst.world_surface_host.visible, "11 信息 toggle expands right Host")
	root.size = Vector2i(1600, 900)
	await _frames()
	_check(inst.world_surface_host.visible and not inst.player_panel_host.visible, "11 wide layout keeps empty left Host collapsed")

	# 12 表面不含内部 ID / 出处 / 语义元数据。
	var visible_text := _surface_text(inst._world_panel_body) + _surface_text(inst._character_panel_body) + _surface_text(inst._experiences_panel_body)
	for forbidden: String in ["local_character_id", "character.han_end", "prefix", "hash", "schema", "mutation", "game_id", "information_curation"]:
		_check(not visible_text.contains(forbidden), "12 surfaces contain no " + forbidden)

	inst.queue_free()
	await process_frame
	runtime.close()
	await process_frame


## 在途 lane 请求可能被 Regenerate/Restore 重新排队；只在确有在途请求时收尾一轮。
func _settle_lane(stub: Node, payload: String) -> void:
	for _round: int in range(4):
		if not stub.busy:
			return
		stub.simulate_delta(payload)
		stub.simulate_completed()
		await _frames()


func _swap_view_adapter(inst: Node, stub: Node) -> void:
	var view: Node = inst.get_node("%NarrativeHost")
	var real_adapter: Node = view.adapter
	real_adapter.text_delta.disconnect(view._on_text_delta)
	real_adapter.completed.disconnect(view._on_completed)
	real_adapter.cancelled.disconnect(view._on_cancelled)
	real_adapter.failed.disconnect(view._on_failed)
	view.adapter = stub
	inst.add_child(stub)
	stub.text_delta.connect(view._on_text_delta)
	stub.completed.connect(view._on_completed)
	stub.cancelled.connect(view._on_cancelled)
	stub.failed.connect(view._on_failed)


func _send(view: Node, text: String) -> void:
	view.player_input.text = text
	view.get_node("%SendButton").pressed.emit()


func _surface_text(body: Variant) -> String:
	if body == null or not is_instance_valid(body):
		return ""
	var parts := PackedStringArray()
	for child: Node in body.get_children():
		if child is Label:
			parts.append(child.text)
	return "\n".join(parts)


func _panel_text(inst: Node, host_path: String) -> String:
	var column: VBoxContainer = inst.get_node(NodePath(host_path))
	var parts := PackedStringArray()
	for child: Node in column.get_children():
		parts.append(child.text if child is Label else "")
		for grandchild: Node in child.get_children():
			parts.append(grandchild.text if grandchild is Label else "")
	return "\n".join(parts)


func _frames() -> void:
	await process_frame
	await process_frame


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("MW-015 PASS | %s" % label)
	else:
		_failures += 1
		push_error("MW-015 FAIL | %s" % label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("MW-015 FAIL | %s" % label)


func _finish() -> void:
	print("MW-015 FOCUSED | done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)
