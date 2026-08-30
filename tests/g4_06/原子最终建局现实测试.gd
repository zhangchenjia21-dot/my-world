extends SceneTree

const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const GameLibrary := preload("res://src/游戏库/L3_外交层/游戏库公开接口.gd")
const Persistence := preload("res://src/persistence/L3_外交层/世界持久化公开接口.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

var _failures := 0
var _fixture := Fixture.new()
var _root := ""
var _source_root := ""
var _library: RefCounted
var _generations: Array


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("g4_06") < 0:
		_fail("必须提供 task-owned --root，且路径包含 g4_06")
		return _finish()
	_fixture.reset_directory(_root)
	_source_root = _root.path_join("source-library")
	var installed := _fixture.install_real_assets(_source_root)
	_check(installed.success, "real 2 World + 6 Character installed through production Source Library")
	if not installed.success:
		return _finish()
	_library = installed.library
	_generations = installed.installed
	_prove_han_create_replay_and_conflict()
	_prove_afterglow_create()
	_prove_no_entry_create()
	_prove_non_temporal_optional_capability()
	_prove_temporal_negative_before_side_effect()
	_prove_pinned_generation_survives_current_change()
	_finish()


func _prove_han_create_replay_and_conflict() -> void:
	var case_root := _case_root("han")
	var composition := _composition(
		"world.han_end.unsettled_realm", "t0-208-red-cliffs-eve",
		"character.han_end.liu_bei", ["character.han_end.sun_quan"], "赤壁前夕", "Light", "从江夏的雨夜开始。"
	)
	var creator := _creator(case_root)
	var created: Dictionary = creator.create_or_resume("creation-han", composition)
	_check(created.success and String(created.status) == "created", "Han exact Composition creates terminal created result")
	if not created.success:
		return
	var verified := _read_created_game(case_root, created)
	_check(verified.success, "Han DB internal identity/root snapshot/Game Library current exact consistency")
	if not verified.success:
		return
	var setup: Dictionary = verified.setup
	_check(String(setup.selected_entry_id) == "t0-208-red-cliffs-eve", "Han exact Entry survives durably")
	_check(String(setup.world.source_projection.selected_entry.entry_id) == "t0-208-red-cliffs-eve", "World projection is top-level + exact selected 208 Entry")
	_check(String(setup.player_character.source_projection.selected_profile.profile_id) == "han-208", "Player projection is exact Liu Bei 208 profile")
	_check(String(setup.guaranteed_npcs[0].source_projection.selected_profile.profile_id) == "han-208", "Guaranteed NPC projection is exact Sun Quan 208 profile")
	_check(not _contains_text(setup, "liu-bei-220") and not _contains_text(setup, "e220-snapshot"), "Han setup excludes unselected future Entry/profile material")
	_check(String(setup.player_character.local_character_id) != String(setup.player_character.provenance.asset_id), "Game-local Player ID differs from Source asset_id")
	_check(String(setup.guaranteed_npcs[0].local_character_id) != String(setup.guaranteed_npcs[0].provenance.asset_id), "Game-local NPC ID differs from Source asset_id")
	_check(not setup.guaranteed_npcs[0].has("opening_presence") and not setup.guaranteed_npcs[0].has("location") and not setup.guaranteed_npcs[0].has("player_knows") and not setup.guaranteed_npcs[0].has("relationship"), "Guaranteed NPC does not invent opening/location/knowledge/relationship")
	_check(String(setup.game.opening_supplement) == "从江夏的雨夜开始。" and String(setup.game.control_mode) == "Light", "settings and exact opening supplement survive")
	_check(verified.accepted_count == 0, "initial Conversation is empty: no Provider request / AI Opening")

	var replay: Dictionary = _creator(case_root).create_or_resume("creation-han", composition)
	_check(replay.success and String(replay.game_id) == String(created.game_id), "same creation identity + same payload returns same Game")
	_check(String(replay.local_player_id) == String(created.local_player_id) and replay.local_npc_ids == created.local_npc_ids, "exact replay does not mint duplicate local identities")
	_check(_count_sqlite(case_root.path_join("games")) == 1 and _record_count(case_root.path_join("library")) == 1, "exact replay leaves exactly one SQLite and one Game Library record")
	var reordered := composition.duplicate(true)
	reordered.guaranteed_npcs.reverse()
	var set_replay: Dictionary = _creator(case_root).create_or_resume("creation-han", reordered)
	_check(set_replay.success and String(set_replay.game_id) == String(created.game_id), "Guaranteed NPC enumeration order is canonicalized as a set")
	var altered := composition.duplicate(true)
	altered.display_name = "不同 payload"
	var conflict: Dictionary = _creator(case_root).create_or_resume("creation-han", altered)
	_check(not conflict.success and String(conflict.code) == "creation_payload_conflict", "same creation identity + different payload conflicts fail-loud")
	_check(_count_sqlite(case_root.path_join("games")) == 1 and _record_count(case_root.path_join("library")) == 1, "payload conflict does not mutate existing Game/Library")


func _prove_afterglow_create() -> void:
	var case_root := _case_root("afterglow")
	var composition := _composition(
		"world.ashtervia.afterglow", "t0-1287-public-works",
		"character.ashtervia.livia_selan", ["character.ashtervia.adrian_wilk", "character.ashtervia.duen_stonescar"],
		"公共工程余波", "Narrative", "保留角色各自的信息边界。"
	)
	var result: Dictionary = _creator(case_root).create_or_resume("creation-afterglow", composition)
	_check(result.success, "Afterglow ordinary scenario Composition creates successfully")
	if not result.success:
		return
	var verified := _read_created_game(case_root, result)
	_check(verified.success and String(verified.setup.world.source_projection.selected_entry.entry_id) == "t0-1287-public-works", "Afterglow exact scenario Entry materializes without historical mode")
	_check(verified.setup.guaranteed_npcs.size() == 2, "Afterglow canonical cast materializes exact NPC set")


func _prove_no_entry_create() -> void:
	var case_root := _case_root("no-entry")
	var composition := _composition(
		"world.han_end.unsettled_realm", "", "character.han_end.liu_bei", [],
		"无预选年代", "Light", "只使用顶层起始语义。"
	)
	var result: Dictionary = _creator(case_root).create_or_resume("creation-no-entry", composition)
	_check(result.success, "explicit no-Entry Composition creates successfully")
	if not result.success:
		return
	var verified := _read_created_game(case_root, result)
	_check(verified.success and verified.setup.selected_entry_id == null, "no-Entry remains explicit null")
	_check(verified.setup.world.source_projection.selected_entry.is_empty(), "no World Entry is silently selected")
	_check(verified.setup.player_character.source_projection.selected_profile.is_empty(), "no Character T0 profile is silently selected")
	_check(verified.setup.world.source_projection.semantic_sections.size() == _generation("world.han_end.unsettled_realm").source.semantic_sections.size(), "no-Entry World copies top-level sections only")
	_check(verified.setup.player_character.source_projection.semantic_sections.size() == _generation("character.han_end.liu_bei").source.semantic_sections.size(), "no-Entry Character copies top-level sections only")


func _prove_non_temporal_optional_capability() -> void:
	var case_root := _case_root("non-temporal")
	var installed := _fixture.install_packages(case_root.path_join("source-library"), Fixture.IR01_NON_TEMPORAL_PACKAGES)
	_check(installed.success, "task-owned non-temporal World/Character installed")
	if not installed.success:
		return
	var library: RefCounted = installed.library
	var generations: Array = installed.installed
	var creation := Creation.new(library)
	creation.select_world(_fixture.find_generation(generations, "world.ir01.tidal_archipelago"))
	creation.select_entry("opening-harbor-market")
	creation.confirm_expansion_none()
	creation.select_player(_fixture.find_generation(generations, "character.ir01.river_cartographer"))
	creation.set_settings("潮汐群岛", "Narrative", "")
	var result: Dictionary = FinalCreate.new(
		library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games")
	).create_or_resume("creation-non-temporal", creation.composition_snapshot())
	_check(result.success, "non-temporal scenario Entry creates without global temporal mode")
	if not result.success:
		return
	var verified := _read_created_game(case_root, result)
	_check(verified.success and String(verified.setup.world.source_projection.selected_entry.entry_id) == "opening-harbor-market", "non-temporal World exact scenario Entry materializes")
	_check(verified.setup.player_character.source_projection.selected_profile.is_empty(), "profile-free Character remains always-safe-only with no fake profile")


func _prove_temporal_negative_before_side_effect() -> void:
	var case_root := _case_root("temporal-negative")
	var incompatible := _composition(
		"world.han_end.unsettled_realm", "t0-229-three-states",
		"character.han_end.liu_bei", [], "不兼容局", "Light", ""
	)
	var result: Dictionary = _creator(case_root).create_or_resume("creation-incompatible", incompatible)
	_check(not result.success and String(result.code) == "character_temporal_incompatible", "Han incompatible exact Entry fails without profile fallback")
	_check(not DirAccess.dir_exists_absolute(case_root.path_join("creation/intents")) and _count_sqlite(case_root.path_join("games")) == 0 and _record_count(case_root.path_join("library")) == 0, "temporal negative fails before intent/Game DB/Game Library side effects")


func _prove_pinned_generation_survives_current_change() -> void:
	var case_root := _case_root("pin-drift")
	var composition := _composition(
		"world.ashtervia.afterglow", "t0-1287-ovista", "character.ashtervia.livia_selan", [],
		"代次锁定", "Light", ""
	)
	var pinned_fingerprint := String(composition.world.identity.generation_fingerprint)
	var newer_path := case_root.path_join("newer-world")
	_fixture.copy_package("res://tests/fixtures/g4_02r1/full_fidelity/诸界余辉/埃瑟维亚", newer_path)
	var source := _fixture.read_json(newer_path.path_join("source.json"))
	source.version = "%s-newer" % String(source.version)
	source.catalog_summary = "%s（newer current）" % String(source.catalog_summary)
	_fixture.write_json(newer_path.path_join("source.json"), source)
	var newer: Dictionary = _library.install_world_pack(newer_path)
	_check(newer.success and String(newer.generation.identity.generation_fingerprint) != pinned_fingerprint, "newer Y becomes Source current after Composition pinned X")
	var result: Dictionary = _creator(case_root).create_or_resume("creation-pin-x", composition)
	_check(result.success, "Final Create exact-resolves pinned X after current changed to Y")
	if result.success:
		var verified := _read_created_game(case_root, result)
		_check(verified.success and String(verified.setup.world.provenance.generation_fingerprint) == pinned_fingerprint, "durable Source pin remains exact X, never current Y")


func _composition(world_id: String, entry_id: String, player_id: String, npc_ids: Array, display_name: String, mode: String, supplement: String) -> Dictionary:
	var creation := Creation.new(_library)
	creation.select_world(_generation(world_id))
	creation.select_entry(entry_id)
	creation.confirm_expansion_none()
	creation.select_player(_generation(player_id))
	for npc_id: String in npc_ids:
		creation.set_guaranteed_npc(_generation(npc_id), true)
	creation.set_settings(display_name, mode, supplement)
	return creation.composition_snapshot()


func _read_created_game(case_root: String, result: Dictionary) -> Dictionary:
	var persistence := Persistence.new()
	var opened := persistence.open_database(String(result.database_path))
	if not opened.success:
		return {"success": false}
	var ids := persistence.list_game_identities()
	var root := persistence.get_timeline_node(String(result.game_id), String(result.root_node_id))
	var conversation := persistence.get_current_conversation(String(result.game_id))
	persistence.close_database()
	var library := GameLibrary.new(case_root.path_join("library"), case_root.path_join("games"))
	var inventory := library.list_games()
	var current := library.get_current_selection()
	var success: bool = ids.success and ids.game_ids == [result.game_id] and root.success and conversation.success \
		and inventory.success and inventory.games.size() == 1 and current.success \
		and String(current.record.game_id) == String(result.game_id)
	return {"success": success, "setup": root.get("world_state", {}), "accepted_count": conversation.get("accepted_entries", []).size()}


func _creator(case_root: String) -> RefCounted:
	return FinalCreate.new(_library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games"))


func _generation(asset_id: String) -> RefCounted:
	return _fixture.find_generation(_generations, asset_id)


func _case_root(name: String) -> String:
	var path := _root.path_join(name)
	DirAccess.make_dir_recursive_absolute(path)
	return path


func _count_sqlite(root_path: String) -> int:
	if not DirAccess.dir_exists_absolute(root_path):
		return 0
	var count := 0
	for game_directory: String in DirAccess.get_directories_at(root_path):
		if FileAccess.file_exists(root_path.path_join(game_directory).path_join("game.sqlite")):
			count += 1
	return count


func _record_count(root_path: String) -> int:
	var records := root_path.path_join("records")
	if not DirAccess.dir_exists_absolute(records):
		return 0
	var count := 0
	for file_name: String in DirAccess.get_files_at(records):
		if file_name.ends_with(".json"):
			count += 1
	return count


func _contains_text(value: Variant, needle: String) -> bool:
	return JSON.stringify(value).find(needle) >= 0


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-06 CREATE PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-06 CREATE FAIL | %s" % label)


func _finish() -> void:
	print("G4-06 CREATE | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
