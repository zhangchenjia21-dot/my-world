extends "res://tests/mw015/角色与重要经历界面测试.gd"

const Library := preload("res://src/source/L3_外交层/Source库公开接口.gd")
var shot_dir := ""

func _run() -> void:
	_root = _argument("--root=")
	shot_dir = _argument("--shot-dir=")
	if not _root.contains("mw015r2"):
		return _finish()
	DirAccess.make_dir_recursive_absolute(_root)
	var evidence: Array = JSON.parse_string(FileAccess.get_file_as_string(_argument("--model-evidence=")))
	var baseline: Dictionary = evidence[-1].projection.character
	var library := Library.new()
	var world := library.get_current_world("world.han_end.unsettled_realm")
	var player := library.get_current_character("character.han_end.zhang_chen")
	var creation := Creation.new(library)
	creation.select_world(world.generation)
	creation.select_entry("t0-208-red-cliffs-eve")
	creation.confirm_expansion_none()
	creation.select_player(player.generation)
	creation.set_settings("MW-015 R2 UI isolated", "Narrative", "")
	var created := FinalCreate.new(library, _root.path_join("creation"), _root.path_join("library"), _root.path_join("games")).create_or_resume("mw015r2-ui", creation.composition_snapshot())
	_check(created.success, "real Zhang Chen Final Create")
	var runtime := Runtime.new()
	_check(runtime.open_existing_game(created.database_path).success, "real frozen Game opens")
	var opening := GenericStub.new()
	var curator := SemanticStub.new()
	var shell: Node = load("res://src/main.tscn").instantiate()
	shell.session_runtime = runtime
	shell.test_opening_adapter_override = opening
	shell.test_information_curator_adapter_override = curator
	shell.test_world_turn_adapter_override = SemanticStub.new()
	shell.test_world_evolution_adapter_override = SemanticStub.new()
	root.add_child(shell)
	await _frames()
	_check(opening.busy and curator.busy, "initial and opening independently in flight")
	opening.simulate_failed()
	await _frames()
	_check(runtime.conversation.get_durable_accepted_entries().is_empty() and curator.busy, "opening failure leaves initial eligible")
	shell.character_tab.button_pressed = true
	curator.simulate_delta(JSON.stringify({"character": baseline, "experiences": []}))
	curator.simulate_completed()
	await _frames()
	var text := _surface_text(shell._character_panel_body)
	for group: Dictionary in baseline.groups:
		_check(text.contains(group.title) and text.contains(group.items[0]), "initial finished refreshes " + group.title)
	_check(not shell.player_panel_host.visible, "left status stays hidden")
	_check(runtime.conversation.get_durable_accepted_entries().is_empty(), "rich surface requires zero accepted turns")
	for label: String in ["1280x720", "960x540", "maximized"]:
		root.mode = Window.MODE_WINDOWED
		if label == "maximized":
			root.mode = Window.MODE_MAXIMIZED
		else:
			root.size = Vector2i(1280, 720) if label == "1280x720" else Vector2i(960, 540)
		for frame: int in range(8):
			await process_frame
		if shell.get_node("%WorldToggle").visible:
			shell.get_node("%WorldToggle").button_pressed = true
		await _frames()
		_check(shell.world_surface_host.visible and not shell.player_panel_host.visible, label + " right visible and empty left hidden")
		var rect: Rect2 = shell.world_surface_scroll.get_global_rect()
		_check(rect.position.x >= 0 and rect.end.x <= root.size.x + 1 and rect.end.y <= root.size.y + 1, label + " sheet scroll inside viewport")
		_check(not shell.world_surface_scroll.get_h_scroll_bar().visible, label + " no horizontal overflow")
		if not shot_dir.is_empty() and DisplayServer.get_name() != "headless":
			DirAccess.make_dir_recursive_absolute(shot_dir)
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(shot_dir.path_join(label + "-character.png"))
			shell.world_surface_scroll.scroll_vertical = 100000
			await _frames()
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(shot_dir.path_join(label + "-bottom.png"))
			shell.world_surface_scroll.scroll_vertical = 0
	shell.queue_free()
	await _frames()
	runtime.close()
	_finish()
