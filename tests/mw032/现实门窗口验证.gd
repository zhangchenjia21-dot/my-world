extends "res://tests/mw030/动态展示纵向验证.gd"

## 复用真实 main.tscn 六个 Surface 场景；额外覆盖稳定 Thread 与恢复抽屉。
func complete(stub: Node, result: Dictionary) -> void:
	var payload := result.duplicate(true)
	if stub.get_parent()!=null and stub.get_parent().get("_active") is Dictionary:
		var active: Dictionary=stub.get_parent().get("_active")
		if active.has("subjects"):
			if payload.get("open_threads") is Array and not payload.open_threads.is_empty():
				payload.open_threads[0].details=["粮商承诺稍后带来消息。","未解决事项仍待进一步了解。".repeat(35),"玩家目前掌握的相关信息。".repeat(35),"这些信息只用于玩家可见的当前事务。".repeat(28)]
			payload=load("res://tests/mw032/旧场景响应适配.gd").convert(payload,active.subjects,active.get("bindings",{}))
	super.complete(stub,payload)

func windows() -> void:
	var original:=durable();var calls:=call_count()
	shell._select_world_surface_mode("threads");await frames()
	var key: String=Threads.project_presented_threads(runtime)[0].presentation_key
	host("threads").visible_cards[0].get_meta("visibility_button").pressed.emit();await frames()
	check(host("threads").hidden_cards.size()==1 and shell.visibility_preferences.keys_for("threads")==[key],"Thread hides through actual Host control")
	check(durable()==original and call_count()==calls,"Thread hide zero gameplay mutation/calls")
	complete(recommendation,{"actions":ACTIONS})
	for dimensions: Vector2i in [Vector2i(960,540),Vector2i(1280,720),Vector2i(1920,1080)]:
		root.mode=Window.MODE_WINDOWED;root.size=dimensions;await frames()
		host("threads").hidden_toggle.button_pressed=true;await frames()
		var recovery: Button=host("threads").hidden_cards[0].get_meta("visibility_button")
		shell.world_surface_scroll.ensure_control_visible(recovery);await frames()
		check(recovery.get_theme_font_size("font_size")>=20,"Thread recovery effective20")
		check(recovery.get_global_rect().end.x<=root.size.x and recovery.get_global_rect().end.y<=shell.world_surface_scroll.get_global_rect().end.y,"Thread recovery reachable "+str(dimensions))
		check(shell.world_surface_scroll.get_v_scroll_bar().max_value>shell.world_surface_scroll.get_v_scroll_bar().page,"long Thread vertical overflow")
		for node: Node in shell.narrative_view.find_children("*","Button",true,false):
			if node.is_visible_in_tree(): check(node.get_theme_font_size("font_size")>=20 and node.get_global_rect().end.x<=root.size.x,"composer/recommendation usable typography")
		if visual:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(directory.path_join("threads-recovery-%dx%d.png" % [dimensions.x,dimensions.y]))
	host("threads").hidden_cards[0].get_meta("visibility_button").pressed.emit();await frames()
	check(host("threads").hidden_cards.is_empty() and durable()==original,"actual Thread recover presentation only")
	await super.windows()
