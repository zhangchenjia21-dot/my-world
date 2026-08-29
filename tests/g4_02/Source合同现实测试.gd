extends SceneTree

const Contract := preload("res://src/source/L3_外交层/Source合同公开接口.gd")
const WorldProjection := preload("res://src/source/L3_外交层/世界包公开类型.gd")
const CharacterProjection := preload("res://src/source/L3_外交层/角色卡公开类型.gd")
const Fixture := preload("res://tests/g4_02/Source合同测试夹具.gd")

const WORLD_A := "res://tests/fixtures/g4_02/世界包_边境诸侯"
const WORLD_B := "res://tests/fixtures/g4_02/世界包_星潮群岛"
const CHARACTER_PLAYER := "res://tests/fixtures/g4_02/角色卡_沈砚"
const CHARACTER_NPC := "res://tests/fixtures/g4_02/角色卡_莱娅"

var _failures := 0
var _contract := Contract.new()
var _fixture := Fixture.new()


func _initialize() -> void:
	_run()


func _run() -> void:
	var work_root := _argument("--work-root=")
	if work_root.find("g4_02") < 0:
		_fail("必须提供 task-owned --work-root，且路径包含 g4_02")
		_finish()
		return
	_fixture.reset_directory(work_root)

	var world_a := _contract.load_world_pack(WORLD_A)
	var world_b := _contract.load_world_pack(WORLD_B)
	_check(world_a.success and world_a.source is WorldProjection, "World A 通过 production L3 读取为 typed projection")
	_check(world_b.success and world_b.source is WorldProjection, "World B 通过同一 production L3 读取为 typed projection")
	if world_a.success and world_b.success:
		_check(world_a.source.display_name == "边境诸侯" and world_b.source.display_name == "星潮群岛", "两个 materially different World identity 保持独立")
		_check(world_a.source.source_lore.size() == 2 and world_b.source.source_lore.size() == 3, "ordered Source Lore 基数与内容没有 world-specific hardcode")
		_check(String(world_a.source.source_lore[0].lore_id) == "lore.border_oath", "World A lore 顺序保留")
		_check(String(world_b.source.entries[0].entry_id) == "entry.broken_moon_route", "World B lightweight Entry/T0 保留")
		_check(world_a.source.authored_assets.size() == 3 and world_b.source.authored_assets.size() == 3, "portrait/scene/map/document declarations 被读取")
		_check(String(world_a.source.source_material.tone).contains("低魔") and String(world_b.source.source_material.tone).contains("高魔"), "pre-game World material 能表达差异世界")

	var player := _contract.load_character_card(CHARACTER_PLAYER)
	var npc := _contract.load_character_card(CHARACTER_NPC)
	_check(player.success and player.source is CharacterProjection, "Player-eligible Character 通过 production L3 读取")
	_check(npc.success and npc.source is CharacterProjection, "reusable NPC Character 通过相同 contract 读取")
	if player.success and npc.success:
		_check(player.source.player_character_supported and not npc.source.player_character_supported, "eligibility 不把 Character contract 锁成 player-only")
		_check(player.source.public_profile.summary != player.source.gm_private_profile.background, "public 与 GM/private profile 分离")
		_check(not player.source.public_profile.has("background") and not player.source.gm_private_profile.has("summary"), "private material 未混入 public projection")
		_check(String(npc.source.portrait.path) == "assets/leya.svg", "Character portrait reference 被正式读取")
		_check(not npc.source.identity.has("current_location"), "有效 Character 不依赖 live location/relationship/knowledge")

	_test_fingerprint(work_root, world_a, player)
	_finish()


func _test_fingerprint(work_root: String, world_a: Dictionary, player: Dictionary) -> void:
	if not world_a.success or not player.success:
		_fail("fingerprint 前置 fixture 未成功")
		return
	var original_world_fingerprint := String(world_a.source.identity.generation_fingerprint)
	var repeated := _contract.load_world_pack(WORLD_A)
	_check(repeated.success and String(repeated.source.identity.generation_fingerprint) == original_world_fingerprint, "unchanged package fingerprint stable")

	var reverse_copy := work_root.path_join("world-reverse-copy")
	_fixture.copy_package(WORLD_A, reverse_copy, true)
	var reverse_loaded := _contract.load_world_pack(reverse_copy)
	_check(reverse_loaded.success and String(reverse_loaded.source.identity.generation_fingerprint) == original_world_fingerprint, "文件创建/枚举顺序不改变 fingerprint")

	var text_copy := work_root.path_join("world-text-change")
	_fixture.copy_package(WORLD_A, text_copy)
	var text_manifest := _fixture.read_manifest(text_copy)
	text_manifest.gm_instructions = String(text_manifest.gm_instructions) + " 新的 authored 约束。"
	_fixture.write_manifest(text_copy, text_manifest)
	var text_loaded := _contract.load_world_pack(text_copy)
	_check(text_loaded.success and String(text_loaded.source.identity.generation_fingerprint) != original_world_fingerprint, "contract-owned text change 改变 fingerprint")

	var visual_copy := work_root.path_join("world-visual-change")
	_fixture.copy_package(WORLD_A, visual_copy)
	_fixture.append_text(visual_copy.path_join("assets/river_gate.svg"), "\n<!-- byte mutation -->\n")
	var visual_loaded := _contract.load_world_pack(visual_copy)
	_check(visual_loaded.success and String(visual_loaded.source.identity.generation_fingerprint) != original_world_fingerprint, "declared World visual bytes change 改变 fingerprint")

	var original_character_fingerprint := String(player.source.identity.generation_fingerprint)
	var portrait_copy := work_root.path_join("character-portrait-change")
	_fixture.copy_package(CHARACTER_PLAYER, portrait_copy)
	_fixture.append_text(portrait_copy.path_join("assets/shen_yan.svg"), "\n<!-- portrait mutation -->\n")
	var portrait_loaded := _contract.load_character_card(portrait_copy)
	_check(portrait_loaded.success and String(portrait_loaded.source.identity.generation_fingerprint) != original_character_fingerprint, "declared Character portrait bytes change 改变 fingerprint")

	var undeclared_copy := work_root.path_join("world-undeclared-file")
	_fixture.copy_package(WORLD_A, undeclared_copy)
	_fixture.write_text(undeclared_copy.path_join("not-declared.txt"), "不属于 contract 的工作草稿")
	var undeclared_loaded := _contract.load_world_pack(undeclared_copy)
	_check(undeclared_loaded.success and String(undeclared_loaded.source.identity.generation_fingerprint) == original_world_fingerprint, "未声明文件不被目录扫描并污染 exact generation")


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-02 REALITY PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-02 REALITY FAIL | %s" % label)


func _finish() -> void:
	print("G4-02 REALITY | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
