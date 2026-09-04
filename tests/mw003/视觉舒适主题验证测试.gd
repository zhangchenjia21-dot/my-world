extends SceneTree

## MW-003 Visual Comfort Theme Pass —— 真实渲染验证与 UI smoke。
## 以真实产品 main.tscn Shell（与 run-game.cmd 同一 Godot 4.7.2 渲染路径）覆盖：
## Main Menu / Model Settings / New Game Wizard / in-game 三栏 Narrative + composer /
## Save success / error semantic state；逐状态截图到 <root>/shots 供 Owner UAT 参考。
## 断言核心 palette 集中定义真正生效于各表面（Theme 继承 + type variation + runtime 控件）。
## 零真实 Provider 调用：全部 Provider seam 使用 stub。

const Palette := preload("res://src/ui/视觉舒适调色板.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")
const SessionRuntime := preload("res://src/runtime/当前游戏会话运行时.gd")
const OpeningStub := preload("res://tests/g4_07a/首次开场桩适配器.gd")
const ViewStub := preload("res://tests/g2_03_桩适配器.gd")
const SemanticStub := preload("res://tests/g5_01/世界回合语义桩适配器.gd")

var _failures := 0
var _fixture := Fixture.new()
var _root := ""
var _shots := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("mw003") < 0:
		_fail("必须提供 task-owned --root，且路径包含 mw003")
		return _finish()
	_fixture.reset_directory(_root)
	_shots = _root.path_join("shots")
	DirAccess.make_dir_recursive_absolute(_shots)
	DisplayServer.window_set_size(Vector2i(1440, 900))
	var installed: Dictionary = _fixture.install_real_assets(_root.path_join("source-library"))
	_check(installed.success, "wizard Source fixture installs real frozen assets")
	if not installed.success:
		return _finish()
	_set_environment()
	_seed_current_game()
	var shell: Variant = load("res://src/main.tscn").instantiate()
	root.add_child(shell)
	await _settle(4)
	_check(shell.application_state == shell.ApplicationState.MENU_READY, "boot -> Main Menu READY")
	_assert_palette(shell)
	await _capture("01_main_menu")

	# Model Settings 表面。
	shell.model_settings_button.pressed.emit()
	await _settle(3)
	_check(shell.model_settings_overlay.visible, "Model Settings overlay opens")
	await _capture("02_model_settings")
	shell.settings_cancel_button.pressed.emit()
	await _settle(2)
	_check(not shell.model_settings_overlay.visible, "Model Settings cancel closes overlay")

	# New Game Wizard 表面（真实 Source 库存）。
	shell.new_game_button.pressed.emit()
	await _settle(4)
	var wizard: Variant = shell.new_game_wizard
	_check(shell.new_game_surface.visible and wizard.worlds.size() > 0, "New Game Wizard opens with real World inventory")
	_check(wizard.step_label.get_theme_color("font_color") == Palette.TEXT_SECONDARY, "wizard secondary label resolves palette TEXT_SECONDARY via type variation")
	await _capture("03_new_game_wizard")
	shell.new_game_back_button.pressed.emit()
	await _settle(2)
	_check(shell.main_menu_surface.visible and not shell.new_game_surface.visible, "Wizard back returns to Main Menu")

	# In-game：stub Opening + 一个真实 accepted Narrative turn。
	shell.test_opening_adapter_override = OpeningStub.new()
	shell.test_world_turn_adapter_override = SemanticStub.new()
	shell.test_world_evolution_adapter_override = SemanticStub.new()
	shell.continue_button.pressed.emit()
	await _settle(4)
	_check(shell.session_runtime != null and shell.session_runtime.is_ready(), "Continue opens seeded Game Session")
	shell.agency_scheduler.test_selector_adapter_override = SemanticStub.new()
	shell.agency_scheduler.test_actor_adapter_factory = func() -> Node: return SemanticStub.new()
	var opening_stub: Node = shell.test_opening_adapter_override
	opening_stub.simulate_delta("开场叙事：暮色中的渡口。")
	opening_stub.simulate_completed()
	await _settle(4)
	var view_stub := _swap_view_stub(shell.narrative_view)
	shell.narrative_view.player_input.text = "我登上高台远眺。"
	shell.narrative_view._on_send_pressed()
	await _settle(3)
	view_stub.text_delta.emit("你登上渡口的高台，望见远处尘土缓缓升起。")
	view_stub.simulate_completed()
	await _settle(4)
	_check(shell.session_runtime.conversation.get_durable_accepted_entries().size() == 2, "opening + one Narrative turn durably accepted")
	var gm_content: RichTextLabel = shell.narrative_view._current_gm_content
	_check(gm_content != null and gm_content.get_theme_color("default_color") == Palette.TEXT_PRIMARY, "Narrative body resolves palette TEXT_PRIMARY (softened off-white)")
	await _capture("04_ingame_narrative")

	# Save success semantic state（Save/Restore UI-connected 路径）。
	shell.save_name_input.text = "舒适度存档"
	var saved: Dictionary = shell.session_runtime.create_save_point("舒适度存档")
	_check(bool(saved.get("success", false)), "Save Point created through real session")
	shell._show_save_result("已保存：舒适度存档", false)
	await _settle(2)
	_check(shell.save_result_label.get_theme_color("font_color") == Palette.SUCCESS, "Save success label resolves palette SUCCESS")
	await _capture("05_save_success")

	# Error semantic state：transport 失败的玩家可读错误（DEC-11 文案不变）。
	shell.narrative_view.player_input.text = "我再望向江面。"
	shell.narrative_view._on_send_pressed()
	await _settle(3)
	view_stub.simulate_failed("transport", "controlled provider failure")
	await _settle(3)
	_check(shell.narrative_view.error_label.visible and not shell.narrative_view.error_label.text.is_empty(), "transport failure surfaces friendly error label")
	_check(shell.narrative_view.error_label.get_theme_color("font_color") == Palette.DANGER, "error label resolves palette DANGER (restrained, not saturated alarm)")
	await _capture("06_error_state")

	shell._close_game_session()
	await _settle(2)
	shell.queue_free()
	await process_frame
	_clear_environment()
	_finish()


## 核心 palette 集中性断言：根 Theme 语义色/控件表面/Background 全部来自 Palette。
func _assert_palette(shell: Variant) -> void:
	var theme: Theme = shell.theme
	_check(theme != null and theme.get_color("font_color", "Label") == Palette.TEXT_PRIMARY, "root Theme Label font_color is centrally-owned TEXT_PRIMARY")
	_check(theme.get_color("default_color", "RichTextLabel") == Palette.TEXT_PRIMARY, "root Theme RichTextLabel default_color is TEXT_PRIMARY")
	var button_normal := theme.get_stylebox("normal", "Button") as StyleBoxFlat
	_check(button_normal != null and button_normal.bg_color == Palette.SURFACE_RAISED, "Button normal surface is centrally-owned SURFACE_RAISED")
	var panel := theme.get_stylebox("panel", "PanelContainer") as StyleBoxFlat
	_check(panel != null and panel.bg_color == Palette.SURFACE_BASE, "panel surface is centrally-owned SURFACE_BASE")
	var input := theme.get_stylebox("normal", "TextEdit") as StyleBoxFlat
	_check(input != null and input.bg_color == Palette.SURFACE_INPUT and theme.get_color("font_placeholder_color", "TextEdit") == Palette.TEXT_MUTED, "input surface/placeholder use INPUT + MUTED palette")
	_check(theme.get_color("font_color", "LabelMuted") == Palette.TEXT_MUTED and theme.get_color("font_color", "LabelAccent") == Palette.ACCENT, "Label role variations carry palette colors")
	_check((shell.get_node("Background") as ColorRect).color == Palette.CANVAS, "canvas Background is centrally-owned CANVAS (not near-black)")
	_check((shell.find_child("ProductTitle", true, false) as Label).get_theme_color("font_color") == Palette.TEXT_PRIMARY, "product title resolves softened TEXT_PRIMARY (no max-bright white)")
	_check(shell.status_label.get_theme_color("font_color") == Palette.TEXT_MUTED, "status footer resolves LabelMuted variation")


func _swap_view_stub(view: Variant) -> Node:
	var stub: Node = ViewStub.new()
	view._disconnect_adapter_signals(view.adapter)
	view.remove_child(view.adapter)
	view.adapter.queue_free()
	view.adapter = stub
	view.add_child(stub)
	stub.text_delta.connect(view._on_text_delta)
	stub.completed.connect(view._on_completed)
	stub.cancelled.connect(view._on_cancelled)
	stub.failed.connect(view._on_failed)
	return stub


## created-schema 最小 setup（与 MW-002 接线夹具同形），供 Continue 打开。
func _seed_current_game() -> void:
	var database_path := _root.path_join("current-game.sqlite")
	var seed := SessionRuntime.new()
	if not seed.open_current_game(database_path).success:
		_fail("seed runtime opens task-owned Game DB")
		return
	var setup := {
		"schema_version": "game_local_setup.v0.1",
		"creation_origin": {},
		"game": {"game_id": String(seed.game_id), "display_name": "MW-003 视觉验证局", "control_mode": "Narrative", "opening_supplement": ""},
		"setup_ancestry": {},
		"selected_entry_id": null,
		"world": {
			"local_world_id": "local-world-mw003",
			"provenance": {"asset_id": "task.world", "generation_fingerprint": "task-generation"},
			"source_projection": {"display_name": "视觉验证世界", "world_instructions": "", "gm_instructions": "", "semantic_sections": [{"section_id": "w1", "title": "世界前提", "section_type": "premise", "disclosure": "public", "content": "北方旱情持续发展。"}]},
		},
		"player_character": {
			"local_character_id": "char-player-mw003",
			"provenance": {"asset_id": "task.player", "generation_fingerprint": "task-generation"},
			"source_projection": {"display_name": "视觉验证主角", "semantic_sections": [{"section_id": "p1", "title": "身份", "section_type": "premise", "disclosure": "private", "content": "行人"}]},
		},
		"guaranteed_npcs": [],
	}
	var committed: Dictionary = seed.commit_world_mutation_durably("mw003-setup", "mw003-setup-node", setup)
	seed.close()
	_check(bool(committed.get("success", false)), "seed setup committed")


func _set_environment() -> void:
	OS.set_environment("MY_WORLD_TEST_CURRENT_GAME_DB", _root.path_join("current-game.sqlite"))
	OS.set_environment("MY_WORLD_TEST_GAME_LIBRARY_ROOT", _root.path_join("game-library"))
	OS.set_environment("MY_WORLD_TEST_GAMES_ROOT", _root.path_join("games"))
	OS.set_environment("MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", _root.path_join("source-library"))
	OS.set_environment("MY_WORLD_TEST_CREATION_ROOT", _root.path_join("creation"))


func _clear_environment() -> void:
	for key: String in ["MY_WORLD_TEST_SOURCE_LIBRARY_ROOT", "MY_WORLD_TEST_CURRENT_GAME_DB", "MY_WORLD_TEST_GAME_LIBRARY_ROOT", "MY_WORLD_TEST_GAMES_ROOT", "MY_WORLD_TEST_CREATION_ROOT"]:
		OS.set_environment(key, "")


func _capture(name: String) -> void:
	# 等一帧渲染完成后取真实 viewport 像素；失败不阻塞断言结果。
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	var path := _shots.path_join("%s.png" % name)
	var error := image.save_png(path)
	_check(error == OK and FileAccess.file_exists(path), "runtime capture saved: %s.png" % name)


func _settle(frames: int) -> void:
	for _index: int in range(frames):
		await process_frame


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("MW-003 VISUAL PASS | %s" % label)
	else:
		_failures += 1
		push_error("MW-003 VISUAL FAIL | %s" % label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("MW-003 VISUAL FAIL | %s" % label)


func _finish() -> void:
	print("MW-003 VISUAL | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
