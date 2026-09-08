extends "res://tests/mw022/会话调试窗口测试.gd"

var inventory: Array = []

# 使用真实 Shell、durable accepted Conversation 及既有 lane stub；不读取 Owner 数据。
func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="): directory = arg.trim_prefix("--root=")
	if not directory.contains("mw023"):
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(directory)
	runtime = Runtime.new()
	check(runtime.open_current_game(directory.path_join("type.sqlite")).success, "isolated Game")
	var document := setup()
	document.merge({"schema_version": "game_local_setup.v0.1", "creation_origin": {}, "setup_ancestry": {}, "game": {"game_id": runtime.game_id, "display_name": "阅读测试", "control_mode": "Narrative"}, "world": {"source_projection": {"display_name": "河畔的世界", "semantic_sections": []}}, "guaranteed_npcs": []})
	check(runtime.commit_world_mutation_durably("fixture", "fixture", document).success, "valid local setup")
	runtime.conversation.begin_gm_opening()
	runtime.conversation.append_delta("亭外下着雨，河流从村边流过。\n".repeat(30))
	check(runtime.complete_active_generation_durably().success, "long accepted opening")
	var shell: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	shell.session_runtime = runtime
	shell.test_world_turn_adapter_override = Stub.new()
	shell.test_information_curator_adapter_override = Stub.new()
	shell.test_world_evolution_adapter_override = Stub.new()
	shell.test_action_recommender_adapter_override = Stub.new()
	shell.test_opening_adapter_override = Stub.new()
	root.add_child(shell)
	await frames()
	observer = shell.debug_observer
	semantic = shell.test_world_turn_adapter_override
	curation = shell.test_information_curator_adapter_override
	recommendation = shell.test_action_recommender_adapter_override
	curator = shell.information_curator
	complete(curation, {"character": Safe.project_session(runtime).character, "experiences": []})
	complete(recommendation, {"actions": ACTIONS})
	accept("我接受沈青的邀请，从此随他行船。", "沈青答应带你渡河，你决定成为船工。")
	await frames()
	complete(semantic, {"changes": [], "new_actor_candidates": [{"candidate_ref": "new", "display_name": "沈青", "profile_text": "PRIVATE_CANARY"}], "people_bindings": [{"candidate_ref": "new", "gm_span": {"start": 0, "length": 2}}]})
	await frames()
	var reply := answer([{"actor_ref": input().people_evidence[0].actor_ref, "snapshot": person("沈青", "同行的船工", "邀请你同行，熟悉河道。".repeat(15))}])
	reply.character = {"headline": "船工", "summary": "开始水上生涯。".repeat(20), "groups": [{"title": "能力 / 专长说明", "items": ["学习辨认水流，留心同行者的经验。"]}]}
	reply.experiences = [{"title": "成为船工", "description": "选择随船生活，开始新的人生道路。".repeat(15)}]
	complete(curation, reply)
	complete(recommendation, {"actions": ACTIONS})
	await frames()
	check(shell._people_panel_body.get_child_count() == 1 and "toggle" in shell._people_panel_body.get_child(0), "populated real People projection")
	shell.save_name_input.text = "阅读验证存档"
	shell._on_create_save_pressed()
	await frames()
	check(runtime.list_save_points().save_points.size() == 1, "Save created through real Shell")
	var original := durable()
	var calls := request_counts(shell)
	root.mode = Window.MODE_WINDOWED
	for dimensions: Vector2i in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.size = dimensions
		await frames()
		shell.world_toggle.button_pressed = true
		await frames()
		check(shell.world_nav.is_visible_in_tree(), "real navigation visible " + str(dimensions))
		for tab: Button in [shell.overview_tab, shell.character_tab, shell.experiences_tab, shell.people_tab, shell.save_tab]:
			tab.button_pressed = true
			await frames()
			if tab == shell.people_tab:
				for card: Node in shell._people_panel_body.get_children():
					if "toggle" in card: card.toggle.button_pressed = true
			await create_timer(0.12).timeout
			var tag := "%dx%d-%s" % [dimensions.x, dimensions.y, tab.name]
			inspect_fonts(shell.get_node("Margin"), tag)
			if tab == shell.save_tab:
				print("SAVE GEOMETRY scroll=%s body=%s result=%s bar=%s" % [shell.get_node("%SaveScroll").get_global_rect(), shell.save_surface.get_global_rect(), shell.get_node("%SaveResultLabel").get_global_rect(), shell.get_node("%SaveScroll").get_v_scroll_bar().get_global_rect()])
			print("LAYOUT %s narrative=%s composer=%s" % [tag, shell.narrative_view.narrative_scroll.get_global_rect(), shell.narrative_view.player_input.get_global_rect()])
			check(shell.narrative_view.player_input.get_global_rect().end.y <= dimensions.y and shell.narrative_view.narrative_scroll.size.y > 80, "composer and Narrative fit " + tag)
			for nav: Control in shell.world_nav.get_children():
				check(nav.get_global_rect().end.x <= dimensions.x and nav.get_global_rect().end.y <= dimensions.y, "accessible nav " + tag + str(nav.name))
			check(shell.world_surface_host.get_global_rect().end.x <= dimensions.x, "no horizontal host overflow " + tag)
			if DisplayServer.get_name() != "headless": await capture(tag + ".png")
			var scroll: ScrollContainer = shell.get_node("%SaveScroll") if tab == shell.save_tab else shell.world_surface_scroll
			if tab != shell.overview_tab and scroll.get_v_scroll_bar().max_value > scroll.get_v_scroll_bar().page:
				check(scroll.get_v_scroll_bar().max_value > scroll.get_v_scroll_bar().page and scroll.get_v_scroll_bar().size.x >= 18, "overflow has draggable scrollbar " + tag)
				scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
				await frames()
				check(scroll.scroll_vertical > 0, "right content scroll reaches lower rows " + tag)
				check(scroll.get_child(0).get_global_rect().end.x <= scroll.get_v_scroll_bar().get_global_rect().position.x, "scrollbar never covers right-side text " + tag)
				if tab == shell.save_tab:
					check(scroll.get_global_rect().encloses(shell.get_node("%LoadSaveButton").get_global_rect()), "Load button accessible after scroll " + tag)
				if DisplayServer.get_name() != "headless": await capture(tag + "-bottom.png")
				scroll.scroll_vertical = 0
		shell.overview_tab.button_pressed = true
		shell.debug_toggle.button_pressed = true
		await frames()
		inspect_fonts(shell.debug_panel, str(dimensions) + " Debug")
		check(shell.debug_panel._rows.get_global_rect().end.x <= shell.debug_panel._scroll.get_v_scroll_bar().get_global_rect().position.x, "Debug text clear of scrollbar")
		check(shell.debug_panel._scroll.get_v_scroll_bar().max_value > shell.debug_panel._scroll.get_v_scroll_bar().page, "Debug vertical scroll " + str(dimensions))
		if DisplayServer.get_name() != "headless": await capture("debug-%dx%d.png" % [dimensions.x, dimensions.y])
		shell.debug_toggle.button_pressed = false
	# 强制只读展示辅助/error/d20 分支，覆盖通常暂时隐藏的字体来源。
	var view: Node = shell.narrative_view
	view.get_node("%ErrorLabel").text = "安全可读的错误提示"
	view.get_node("%ErrorLabel").show()
	view.get_node("%ActionStatusPanel").show()
	view.get_node("%ActionStatusLabel").text = "正在处理行动"
	view._append_mechanic_card({"check_id": "font", "intent": "涉水", "outcome": "failure", "failure_stakes": "衣物打湿"})
	await frames()
	inspect_fonts(shell.get_node("Margin"), "auxiliary-public-d20")
	view.recommendation_grid.get_child(0).pressed.emit()
	check(view.player_input.text == ACTIONS[0].draft, "recommendation exact editable draft")
	check(durable() == original and request_counts(shell) == calls, "presentation zero durable mutation or Provider calls")
	for dialog_name: String in ["LoadConfirmation", "RecoverConfirmation", "DatabaseRecoveryConfirmation"]:
		var dialog: ConfirmationDialog = shell.get_node("%" + dialog_name)
		dialog.dialog_text = "读取存档会切换当前进度。"
		dialog.popup_centered()
		await frames()
		for control: Control in [dialog.get_label(), dialog.get_ok_button(), dialog.get_cancel_button()]:
			check(control.get_theme_font_size("font_size") >= 20, "effective dialog font " + dialog_name)
		dialog.hide()
	check(shell.get_node("%SaveSelector").get_popup().get_theme_font_size("font_size") >= 20, "Save dropdown effective font")
	var file := FileAccess.open(directory.path_join("effective-fonts.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(inventory, "\t"))
	file.close()
	shell._close_game_session()
	shell.queue_free()
	await frames()
	print("MW-023 checks=%d failures=%d font_samples=%d" % [checks, failures, inventory.size()])
	quit(0 if failures == 0 else 1)

func inspect_fonts(node: Node, surface: String) -> void:
	if node is Control and node.is_visible_in_tree():
		var keys: Array = []
		if node is RichTextLabel: keys = ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size", "mono_font_size"]
		elif node is Label or node is Button or node is TextEdit or node is LineEdit: keys = ["font_size"]
		for key: String in keys:
			var effective: int = node.get_theme_font_size(key)
			inventory.append({"surface": surface, "path": str(node.get_path()), "property": key, "effective_px": effective})
			check(effective >= 20, "effective >=20 " + str(node.get_path()) + " " + key + " actual=" + str(effective))
	for child: Node in node.get_children(): inspect_fonts(child, surface)
