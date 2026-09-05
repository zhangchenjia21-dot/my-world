extends SceneTree

## MW-012 张琛 Player Character Card acceptance proof。
## 走真实 Character Card v0.2 合同 + Managed Source Library + 建局 Composition +
## Final Create + 冻结 Game-local projection + GM 上下文投影 + player-safe 投影。
## 证明张琛经真实 first-party ingress（repo 包 → install → Wizard inventory）可被
## New Game 发现并选择；兼容矩阵覆盖 7 个汉末开局；刘备路径不回归；跨世界不合资格。
## real Provider calls = 0。

const SourceContract := preload("res://src/source/L3_外交层/Source合同公开接口.gd")
const SourceLibrary := preload("res://src/source/L3_外交层/Source库公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const PlayerSafe := preload("res://src/玩家安全投影/L3_外交层/玩家安全投影公开接口.gd")
const Projector := preload("res://src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

const ZHANG_PACKAGE := "res://tests/fixtures/mw012/汉末三国/张琛"
const LIUBEI_PACKAGE := "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/刘备"
const WORLD_PACKAGE := "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定"
const ZHANG_ID := "character.han_end.zhang_chen"
const ZHANG_PROFILE := "han-t0-transport"
const HAN_WORLD := "world.han_end.unsettled_realm"
const SUPPORTED_ENTRIES := [
	"t0-184-yellow-turban", "t0-189-luoyang-crisis", "t0-196-emperor-xu",
	"t0-200-guandu-eve", "t0-208-red-cliffs-eve", "t0-214-yizhou-transition",
	"t0-220-han-wei-transition",
]

var _failures := 0
var _root := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("mw012") < 0:
		_fail("必须提供 task-owned --root，且路径包含 mw012")
		return _finish()
	DirAccess.make_dir_recursive_absolute(_root)
	var fixture := Fixture.new()
	fixture.reset_directory(_root)
	var library_root := _root.path_join("source-library")

	# 1/2 真实合同校验 + Managed Library 发布（exact immutable generation）
	var contract := SourceContract.new()
	var loaded := contract.load_character_card(ZHANG_PACKAGE)
	_check(loaded.success, "package validates under the existing character_card.v0.2 contract")
	if not loaded.success:
		return _finish()
	var zhang_fingerprint := String(loaded.source.identity.generation_fingerprint)
	_check(String(loaded.source.identity.asset_id) == ZHANG_ID and String(loaded.source.display_name) == "张琛" and bool(loaded.source.player_character_supported) and not zhang_fingerprint.is_empty(), "identity/version/player_character_supported/fingerprint as contracted")

	var library := SourceLibrary.new(library_root)
	var installed: Dictionary = library.install_character_card(ZHANG_PACKAGE)
	_check(installed.success, "exact immutable generation published through the normal Managed Source path")
	if not installed.success:
		return _finish()
	var fingerprint := String(installed.generation.identity.generation_fingerprint)
	var current: Dictionary = library.get_current_character(ZHANG_ID)
	var exact: Dictionary = library.get_exact_character(ZHANG_ID, fingerprint)
	_check(current.success and exact.success and String(current.generation.identity.generation_fingerprint) == fingerprint, "current/exact lookup converge on the installed generation")

	# 3 Wizard 级发现：Composition inventory（与产品 New Game 相同 seam）
	var composition := Creation.new(library)
	var inventory: Dictionary = composition.load_current_inventory()
	var zhang_in_inventory := false
	var liubei_in_inventory := false
	for generation: RefCounted in inventory.characters:
		if String(generation.identity.asset_id) == ZHANG_ID:
			zhang_in_inventory = bool(generation.source.player_character_supported)
		if String(generation.identity.asset_id) == "character.han_end.liu_bei":
			liubei_in_inventory = true
	_check(zhang_in_inventory, "3 New Game inventory discovers 张琛 as a selectable Player Character (no picker hardcoding)")
	var liu_installed: Dictionary = library.install_character_card(LIUBEI_PACKAGE)
	inventory = composition.load_current_inventory()
	var liu_beie_found := false
	for generation: RefCounted in inventory.characters:
		if String(generation.identity.asset_id) == "character.han_end.liu_bei":
			liu_beie_found = bool(generation.source.player_character_supported)
	_check(liu_installed.success and liu_beie_found, "9 existing 刘备 discovery path remains green")

	# 4 T0 兼容矩阵：7 个汉末开局全部 exact_profile_match
	for entry_id: String in SUPPORTED_ENTRIES:
		var projected: Dictionary = contract.project_character_t0(loaded.source, HAN_WORLD, entry_id)
		_check(projected.success and String(projected.compatibility_state) == "exact_profile_match" and String(projected.projection.selected_profile.profile_id) == ZHANG_PROFILE,
			"4 T0 binding %s → exact_profile_match" % entry_id)

	# 5 无关世界不得获得假资格
	var other_manifest: Dictionary = fixture.read_json("res://tests/fixtures/g4_02r1/full_fidelity/诸界余辉/埃瑟维亚/source.json")
	var other_entry_id := String((other_manifest.entries[0] as Dictionary).entry_id)
	var cross_world: Dictionary = contract.project_character_t0(loaded.source, "world.ashtervia.afterglow", other_entry_id)
	_check(cross_world.success and String(cross_world.compatibility_state) == "no_world_coverage", "5 unrelated world gains no false eligibility (no_world_coverage)")

	# 6 208 赤壁前夕 + 张琛：真实 Final Create
	var creation := Creation.new(library)
	var world_install: Dictionary = library.install_world_pack(WORLD_PACKAGE)
	_check(world_install.success, "Han world pack installed in the same library")
	creation.select_world(world_install.generation)
	creation.select_entry("t0-208-red-cliffs-eve")
	creation.confirm_expansion_none()
	creation.select_player(_zhang_generation(library))
	creation.set_settings("MW-012", "Light", "")
	var case_root := _root.path_join("create-zhang")
	var game_created: Dictionary = FinalCreate.new(library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games")).create_or_resume("mw012-zhang-208", creation.composition_snapshot())
	_check(game_created.success, "6 Final Create with 208 Red Cliffs + 张琛 succeeds through the real product seam")
	if not game_created.success:
		return _finish()
	var runtime := Runtime.new()
	_check(runtime.open_existing_game(String(game_created.database_path)).success, "created Game existing-only opens")
	var player_projection := (runtime.world_state.player_character as Dictionary)
	var zhang_projection := player_projection.get("source_projection", {}) as Dictionary
	_check(String(zhang_projection.get("display_name", "")) == "张琛", "7 frozen Game-local Player projection identifies 张琛")
	_check(String((zhang_projection.get("selected_profile", {}) as Dictionary).get("profile_id", "")) == ZHANG_PROFILE, "7 frozen projection binds the selected T0 profile")
	var zhang_runtime_id := String(player_projection.get("local_character_id", ""))

	# 8 GM 上下文获得实质材料（穿越 premise / 能力与限制 / 目标 / 历史记忆非 canon 边界 / 物品）
	var projected_context: Dictionary = Projector.new().project(runtime.world_state)
	var gm_text := String(projected_context.context_text)
	_check(gm_text.contains("身体被整体搬运") and gm_text.contains("汉末世界"), "8 GM context receives the transport premise")
	_check(gm_text.contains("寻找一条可能回家的路") and gm_text.contains("不滥杀无辜"), "8 GM context receives goals and moral boundaries")
	_check(gm_text.contains("没有学过隶书") and gm_text.contains("军用水壶"), "8 GM context receives limits and finite possessions")
	_check(gm_text.contains("不是本局世界的事实") and gm_text.contains("没有权威性"), "8 GM context receives the historical-knowledge non-canon boundary")
	var player_safe: Dictionary = PlayerSafe.new().project_session(runtime)
	_check(String(player_safe.player_display_name) == "张琛" and String(player_safe.player_profile_name) == "现代来客起点", "7 player-safe projection identifies 张琛 + selected profile")
	_check(zhang_runtime_id.begins_with("character-"), "frozen Player projection carries the runtime local id (existing GM-context design)")
	_check(not JSON.stringify(player_safe).contains(zhang_runtime_id), "player-safe projection keeps the internal local id out (MW-009 boundary)")

	# 6b 刘备路径不回归：同库 208 + 刘备 Final Create
	var creation_liu := Creation.new(library)
	creation_liu.select_world(world_install.generation)
	creation_liu.select_entry("t0-208-red-cliffs-eve")
	creation_liu.confirm_expansion_none()
	creation_liu.select_player(_liubei_generation(library))
	creation_liu.set_settings("MW-012", "Light", "")
	var liu_created: Dictionary = FinalCreate.new(library, _root.path_join("create-liu").path_join("creation"), _root.path_join("create-liu").path_join("library"), _root.path_join("create-liu").path_join("games")).create_or_resume("mw012-liu-208", creation_liu.composition_snapshot())
	_check(liu_created.success, "6b existing 刘备 208 Final Create path remains green")
	if liu_created.success:
		var liu_runtime := Runtime.new()
		_check(liu_runtime.open_existing_game(String(liu_created.database_path)).success and String((liu_runtime.world_state.player_character as Dictionary).source_projection.display_name) == "刘备", "6b 刘备 frozen projection unchanged")
		liu_runtime.close()
	runtime.close()

	# R2-02：production prep 脚本冒烟——真实加载执行（不触碰 Owner production 数据）
	var prep_script := load("res://scripts/MW-012_张琛角色卡生产Source发布.gd")
	_check(prep_script != null and prep_script.get_script_constant_map().get("ASSET_ID", "") == ZHANG_ID and prep_script.get_script_constant_map().get("PACKAGE_PATH", "") == ZHANG_PACKAGE and prep_script.get_script_constant_map().get("CONFIRMATION", "") == "--confirm-owner-production-source-prep", "R2-02 production prep script loads with the reviewed Zhang Chen contract constants")
	_finish()
	return


func _liubei_generation(library: RefCounted) -> RefCounted:
	for generation: RefCounted in _installed_generations(library):
		if String(generation.identity.asset_id) == "character.han_end.liu_bei":
			return generation
	return null


func _zhang_generation(library: RefCounted) -> RefCounted:
	for generation: RefCounted in _installed_generations(library):
		if String(generation.identity.asset_id) == ZHANG_ID:
			return generation
	return null


func _world_generation(library: RefCounted) -> RefCounted:
	for generation: RefCounted in _installed_generations(library):
		if String(generation.identity.asset_id) == HAN_WORLD:
			return generation
	return null


func _installed_generations(library: RefCounted) -> Array:
	var inventory: Dictionary = library.list_current_sources()
	return inventory.get("sources", []) as Array if inventory.success else []


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("MW-012 PASS | %s" % label)
	else:
		_failures += 1
		push_error("MW-012 FAIL | %s" % label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("MW-012 FAIL | %s" % label)


func _finish() -> void:
	print("MW-012 ACCEPTANCE | done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)
