extends SceneTree

## MW-011 R2 Player Character Profile Projection + Player Host Surface focused proof。
## 真实 FinalCreate Game + real Shell + real SQLite；deterministic stubs；Provider calls = 0。
## 覆盖 addendum §9：legacy 兼容 / fail-loud 验证 / 冻结 / fail-closed 档案投影 /
## 张琛第一幕完整 profile / GM 哨兵不泄露 / R1 行为保持 / reopen / Restore / 响应式。

const SourceContract := preload("res://src/source/L3_外交层/Source合同公开接口.gd")
const SourceLibrary := preload("res://src/source/L3_外交层/Source库公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const ProfileProjection := preload("res://src/rpg视图模型/L1_器件层/玩家角色档案投影器.gd")
const RPGViewModel := preload("res://src/rpg视图模型/L3_外交层/RPG主机视图模型公开接口.gd")
const WorldTurnRules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")
const GenericStub := preload("res://tests/g4_07a/首次开场桩适配器.gd")
const SemanticStub := preload("res://tests/g5_01/世界回合语义桩适配器.gd")
const WorldTurn := preload("res://src/世界回合/L3_外交层/世界回合公开接口.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

const ZHANG_PACKAGE := "res://tests/fixtures/mw012/汉末三国/张琛"
const ZHANG_ID := "character.han_end.zhang_chen"
const HAN_WORLD := "world.han_end.unsettled_realm"
const GM_SENTINEL := "权威边界（硬性要求）"

var _failures := 0
var _root := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("mw011r2") < 0:
		_fail("必须提供 task-owned --root，且路径包含 mw011r2")
		return _finish()
	DirAccess.make_dir_recursive_absolute(_root)
	_test_validation_fail_loud()
	await _test_shell_integration()
	_finish()


## 2：有效 profile 验证通过；malformed/oversized/未知字段 fail-loud。
func _test_validation_fail_loud() -> void:
	var Rules := load("res://src/source/L0_公理层/Source合同规则.gd")
	var valid := {
		"headline": "24岁 · 现代穿越者", "summary": "退役武警义务兵、985高校出身。",
		"groups": [{"group_id": "background", "title": "背景", "items": ["现代来客"]}],
	}
	_check(Rules.validate_player_profile(valid).success, "2 valid bounded player_profile validates")
	var malformed := [
		{"headline": "", "summary": "s", "groups": valid.groups},
		{"headline": "h", "summary": "", "groups": valid.groups},
		{"headline": "h", "summary": "s"},
		{"headline": "h", "summary": "s", "groups": []},
		{"headline": "h", "summary": "s", "groups": [{"group_id": "a", "title": "t", "items": []}]},
		{"headline": "h", "summary": "s", "groups": [{"group_id": "a b", "title": "t", "items": ["x"]}]},
		{"headline": "h", "summary": "s", "groups": [{"group_id": "a", "title": "t", "items": ["x"], "extra": 1}]},
		{"headline": "h", "summary": "s", "groups": [{"group_id": "a", "title": "t", "items": ["x"]}, {"group_id": "a", "title": "t", "items": ["x"]}]},
		{"headline": "h".repeat(121), "summary": "s", "groups": valid.groups},
		{"headline": "h", "summary": "s".repeat(361), "groups": valid.groups},
		{"headline": "h", "summary": "s", "groups": valid.groups, "portrait": "x"},
	]
	var all_failed := true
	for case_value: Variant in malformed:
		if Rules.validate_player_profile(case_value).success:
			all_failed = false
	_check(all_failed, "2 malformed/oversized/unknown-field player_profile shapes all fail loudly")


## 集成：legacy 兼容、冻结、档案投影、Shell 渲染、reopen/Restore。
func _test_shell_integration() -> void:
	var fixture := Fixture.new()
	fixture.reset_directory(_root)
	var installed: Dictionary = fixture.install_packages(_root.path_join("source-library"), [
		{"type": "world", "path": "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定"},
		{"type": "character", "path": "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/刘备"},
		{"type": "character", "path": ZHANG_PACKAGE},
	])
	if not installed.success:
		_fail("real Source install")
		return _finish()
	var library: RefCounted = installed.library
	var world_gen := fixture.find_generation(installed.installed, HAN_WORLD)
	var contract := SourceContract.new()
	var zhang_loaded: Dictionary = contract.load_character_card(ZHANG_PACKAGE)
	_check(zhang_loaded.success and String(zhang_loaded.source.player_profile.headline) == "24岁 · 现代穿越者", "Zhang Chen card carries the authored player_profile")

	# 1/12 legacy 刘备（无 player_profile）仍可安装/选择/Final Create
	var creation := Creation.new(library)
	creation.select_world(world_gen)
	creation.select_entry("t0-208-red-cliffs-eve")
	creation.confirm_expansion_none()
	creation.select_player(fixture.find_generation(installed.installed, "character.han_end.liu_bei"))
	creation.set_settings("MW-011R2", "Light", "")
	var liu_created: Dictionary = FinalCreate.new(library, _root.path_join("create-liu").path_join("creation"), _root.path_join("create-liu").path_join("library"), _root.path_join("create-liu").path_join("games")).create_or_resume("mw011r2-liu", creation.composition_snapshot())
	_check(liu_created.success, "1/12 legacy card without player_profile still Final Creates")
	if liu_created.success:
		var liu_runtime := Runtime.new()
		liu_runtime.open_existing_game(String(liu_created.database_path))
		_check(ProfileProjection.project(liu_runtime.world_state).success == false, "1/12 legacy Game stays profile-empty (fail-closed, no backfill)")
		liu_runtime.close()

	# 3 张琛 208 Final Create → 冻结 profile
	var creation_zhang := Creation.new(library)
	creation_zhang.select_world(world_gen)
	creation_zhang.select_entry("t0-208-red-cliffs-eve")
	creation_zhang.confirm_expansion_none()
	creation_zhang.select_player(fixture.find_generation(installed.installed, ZHANG_ID))
	creation_zhang.set_settings("MW-011R2", "Light", "")
	var created: Dictionary = FinalCreate.new(library, _root.path_join("create-zhang").path_join("creation"), _root.path_join("create-zhang").path_join("library"), _root.path_join("create-zhang").path_join("games")).create_or_resume("mw011r2-zhang", creation_zhang.composition_snapshot())
	_check(created.success, "3 Zhang Chen 208 Final Create succeeds")
	if not created.success:
		return _finish()
	var runtime := Runtime.new()
	_check(runtime.open_existing_game(String(created.database_path)).success, "created Game opens")
	var frozen_profile: Dictionary = ((((runtime.world_state.player_character as Dictionary).source_projection as Dictionary).get("player_profile", {})) as Dictionary)
	_check(String(frozen_profile.get("headline", "")) == "24岁 · 现代穿越者" and (frozen_profile.get("groups", []) as Array).size() == 7, "3 selected projection freezes the exact player_profile into the Game")
	_check(_semantic_sentinel(frozen_profile) == false, "4 frozen player_profile is presentation-only (no GM prose inside)")

	# 4 档案投影 fail-closed：篡改/缺失 → 空
	_check(ProfileProjection.project({"player_character": 5}).success == false, "4 invalid input fails closed")
	var tampered := runtime.world_state.duplicate(true)
	(tampered.player_character as Dictionary).source_projection.player_profile = {"headline": "x"}
	_check(ProfileProjection.project(tampered).success == false, "4 tampered frozen profile fails closed")

	# 5 真实 Shell：第一幕前完整 profile + 6 GM 哨兵不泄露 + R1 材料仍在
	var opening_stub := GenericStub.new()
	var narrative_stub := GenericStub.new()
	var semantic_stub := SemanticStub.new()
	var inst: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	inst.session_runtime = runtime
	inst.test_opening_adapter_override = opening_stub
	inst.test_world_turn_adapter_override = semantic_stub
	root.add_child(inst)
	await process_frame
	await process_frame
	opening_stub.simulate_delta("建安十三年冬，你出现在赤壁沿岸的芦苇滩上。")
	opening_stub.simulate_completed()
	await process_frame
	var player_text := _panel_text(inst, true)
	var body_node: Container = inst._player_panel_body
	_check(player_text.contains("主角") and player_text.contains("张琛") and player_text.contains("现代来客起点"), "5 Player Host renders identity/profile labels")
	_check(player_text.contains("24岁 · 现代穿越者") and player_text.contains("退役武警义务兵"), "5 headline and summary render before any Player turn")
	for group_title: String in ["背景", "性格", "能力", "局限", "初始目标", "行为原则", "随身物品"]:
		if not player_text.contains(group_title):
			_fail("5 group title missing: " + group_title)
	_check(player_text.contains("• 军用水壶") and player_text.contains("• 不滥杀无辜"), "5 representative group items render")
	_check(not player_text.contains(GM_SENTINEL), "6 GM-reference sentinel text absent from visible Player Host")
	var vm_serialized := JSON.stringify(RPGViewModel.new().build_from_runtime(runtime))
	_check(not vm_serialized.contains(GM_SENTINEL) and not vm_serialized.contains("semantic_sections") and not vm_serialized.contains("catalog_summary"), "6 ViewModel carries no GM prose/sections/catalog fallback")

	# 7/8 R1 行为保持：recent actions / turn count / MW-009 facts
	_swap_view_adapter(inst, narrative_stub)
	_send(view_of(inst), "我检查随身物品。")
	narrative_stub.simulate_delta("你清点 items：水壶、刀具、手表、指南针与口粮俱在。")
	narrative_stub.simulate_completed()
	await process_frame
	await process_frame
	semantic_stub.simulate_delta(JSON.stringify({"changes": [], "knowledge_events": [{"knower_id": String((runtime.world_state.player_character as Dictionary).local_character_id), "fact": "随身物品清点完毕。", "basis": "participated"}]}))
	semantic_stub.simulate_completed()
	await process_frame
	await process_frame
	player_text = _panel_text(inst, true)
	_check(player_text.contains("• 我检查随身物品。") and player_text.contains("已进行 1 个玩家回合"), "7 recent actions and turn count still update")
	var world_text := _panel_text(inst, false)
	_check(world_text.contains("• 随身物品清点完毕。"), "8 Player-known facts still come from MW-009 and update")

	# 9 close/reopen：profile + R1 ViewModel 重建一致
	var before_close: Dictionary = RPGViewModel.new().build_from_runtime(runtime)
	inst.queue_free()
	await process_frame
	runtime.close()
	var reopened := Runtime.new()
	_check(reopened.open_existing_game(String(created.database_path)).success, "reopen existing Game")
	_check(RPGViewModel.new().build_from_runtime(reopened) == before_close, "9 reopen reproduces profile + R1 ViewModel exactly")

	# 10 Restore：动态回退、冻结 profile 保留
	var save_before_turn: Dictionary = reopened.create_save_point("turns 前")
	reopened.close()
	var runtime3 := Runtime.new()
	runtime3.open_existing_game(String(created.database_path))
	# 在 Save 之后加一个 turn，再 Restore 回 Save
	var semantic_stub3 := SemanticStub.new()
	var worker3: Node = WorldTurn.new(runtime3, semantic_stub3)
	root.add_child(worker3)
	await process_frame
	runtime3.conversation.begin_turn("我试探四周。")
	runtime3.conversation.append_delta("四周是陌生的古代营地。")
	runtime3.complete_active_generation_durably()
	await process_frame
	await process_frame
	worker3.shutdown()
	worker3.queue_free()
	runtime3.close()
	var runtime4 := Runtime.new()
	runtime4.open_existing_game(String(created.database_path))
	_check(RPGViewModel.new().build_from_runtime(runtime4).player_turn_count == 2, "post-turn count is 2 before Restore")
	var restored: Dictionary = runtime4.restore_save_point(String(save_before_turn.save_id))
	_check(restored.success, "Restore succeeds")
	var model_after_restore: Dictionary = RPGViewModel.new().build_from_runtime(runtime4)
	_check(int(model_after_restore.player_turn_count) == 1 and (model_after_restore.recent_actions as Array).size() == 1, "10 Restore removes restored-away recent actions/count")
	var restored_profile: Dictionary = model_after_restore.player_profile
	_check(bool(restored_profile.success) and String(restored_profile.headline) == "24岁 · 现代穿越者", "10 frozen profile preserved across Restore")
	var inst2: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	inst2.session_runtime = runtime4
	inst2.test_opening_adapter_override = GenericStub.new()
	inst2.test_world_turn_adapter_override = SemanticStub.new()
	root.add_child(inst2)
	await process_frame
	await process_frame
	_check(_panel_text(inst2, true).contains("24岁 · 现代穿越者"), "10 restored Game still renders frozen profile")
	inst2.queue_free()
	runtime4.close()

	# 18 响应式：Player Host 滚动容器存在，Narrative stretch_ratio 仍为主
	var packed: PackedScene = load("res://src/main.tscn")
	var probe: Node = packed.instantiate()
	root.add_child(probe)
	await process_frame
	var scroll: ScrollContainer = probe.get_node("%PlayerPanelScroll")
	_check(scroll != null and scroll.get_node("PlayerPanelColumn") != null, "18 Player Host scrollable container present")
	probe.queue_free()
	_finish()
	return


func _semantic_sentinel(profile: Dictionary) -> bool:
	return JSON.stringify(profile).contains(GM_SENTINEL)


func view_of(inst: Node) -> Node:
	return inst.get_node("%NarrativeHost")


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


func _panel_text(inst: Node, player_panel: bool) -> String:
	var host_path := "Margin/Layout/HostLayout/PlayerPanelHost/PlayerPanelMargin/PlayerPanelScroll/PlayerPanelColumn" if player_panel else "Margin/Layout/HostLayout/WorldSurfaceHost/WorldPanelMargin/WorldPanelColumn"
	var column: VBoxContainer = inst.get_node(NodePath(host_path))
	var parts := PackedStringArray()
	for child: Node in column.get_children():
		parts.append(child.text if child is Label else "")
		for grandchild: Node in child.get_children():
			parts.append(grandchild.text if grandchild is Label else "")
			for great_grandchild: Node in grandchild.get_children():
				parts.append(great_grandchild.text if great_grandchild is Label else "")
	return "\n".join(parts)


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("MW-011R2 PASS | %s" % label)
	else:
		_failures += 1
		push_error("MW-011R2 FAIL | %s" % label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("MW-011R2 FAIL | %s" % label)


func _finish() -> void:
	print("MW-011R2 FOCUSED | done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)
