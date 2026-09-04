extends SceneTree

## G5-03M2A Stable Actor Registry Foundation —— focused deterministic 证明。
## 覆盖 task §4 的 1–9：Source-backed snapshot / no-Card 创建 actor / 同名不同人 /
## retry authority / 旧 Game 兼容 / 统一 roster 与 eligibility / material family 解析 /
## runtime_narrative currentness 契约预留 / Save-reopen 持久化。
## 零真实 Provider 调用。

const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const CreateRules := preload("res://src/最终建局/L0_公理层/最终建局规则.gd")
const Rules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")
const Scheduler := preload("res://src/世界回合/L3_外交层/行动代理调度公开接口.gd")
const Cycle := preload("res://src/世界回合/L3_外交层/行动代理循环公开接口.gd")
const Conversation := preload("res://src/domain/会话.gd")
const Persistence := preload("res://src/persistence/L3_外交层/世界持久化公开接口.gd")
const SessionRuntime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

const WORLD_HAN := "world.han_end.unsettled_realm"
const ENTRY_208 := "t0-208-red-cliffs-eve"
const ENTRY_220 := "t0-220-han-wei-transition"
const LIU_BEI := "character.han_end.liu_bei"
const CAO_CAO := "character.han_end.cao_cao"
const SUN_QUAN := "character.han_end.sun_quan"


## 最小 Runtime 形状：helper/consumer 级证明只需要 world_state + conversation；
## 不存在任何 Source 对象，旧形状兼容与「无 runtime Source lookup」由结构保证。
class MockRuntime:
	extends RefCounted

	var conversation: RefCounted = Conversation.new()
	var game_id := "game-m2a-mock"
	var active_head_id := "root"
	var world_state: Dictionary = {}

	func is_ready() -> bool:
		return true


var _failures := 0
var _fixture := Fixture.new()
var _root := ""
var _library: RefCounted
var _generations: Array = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("g5_03m2a") < 0:
		_fail("必须提供 task-owned --root，且路径包含 g5_03m2a")
		return _finish()
	_fixture.reset_directory(_root)
	var installed := _fixture.install_real_assets(_root.path_join("source-library"))
	_check(installed.success, "M2A fixture installs frozen real Source assets")
	if not installed.success:
		return _finish()
	_library = installed.library
	_generations = installed.installed
	_test_source_backed_snapshot()
	_test_no_card_and_same_name_actors()
	_test_retry_authority_after_source_current_change()
	_test_invalid_game_local_npc_rejected()
	_test_old_game_compatibility()
	await _test_unified_roster_eligibility_and_material()
	_test_runtime_narrative_currentness_contract()
	_test_persistence_reopen_preserves_registry()
	_finish()


## 证明 1：automatic Source-backed snapshot——exact_profile Character 物化；
## Player/Guaranteed/temporal-incompatible/no-world-coverage 均排除；deterministic 排序。
func _test_source_backed_snapshot() -> void:
	# Create A：entry 208、Player 刘备、无 Guaranteed → 曹操与孙权均 exact_profile，按 exact identity 排序。
	var case_a := _case_root("snapshot-a")
	var composition_a := _composition(ENTRY_208, LIU_BEI, [], [])
	var created_a: Dictionary = _creator(case_a).create_or_resume("creation-m2a-a", composition_a)
	_check(created_a.success, "1 Create A with exact Entry succeeds")
	if not created_a.success:
		return
	var setup_a := _read_setup(created_a)
	var stable_a: Array = setup_a.get("stable_npcs", [])
	_check(stable_a.size() == 2, "1 automatic snapshot materializes both extra exact-profile Characters")
	if stable_a.size() != 2:
		return
	_check(String(stable_a[0].get("provenance", {}).get("asset_id", "")) == CAO_CAO \
		and String(stable_a[1].get("provenance", {}).get("asset_id", "")) == SUN_QUAN, "1 snapshot deterministic order by exact Source identity")
	for record: Dictionary in stable_a:
		_check(String(record.get("origin", {}).get("kind", "")) == "source_character", "1 snapshot record origin is source_character")
		_check(not String(record.get("local_character_id", "")).is_empty(), "1 snapshot record has Program-owned local ID")
		_check(String(record.get("source_projection", {}).get("selected_profile", {}).get("profile_id", "")) == "han-208", "1 snapshot freezes exact T0 selected profile")
	var snapshot_text := JSON.stringify(stable_a)
	_check(not snapshot_text.contains(LIU_BEI), "1 Player Character asset excluded from snapshot")
	_check(not snapshot_text.contains("ashtervia"), "1 no-world-coverage Character excluded from snapshot")

	# Create D：entry 208、Player 刘备、Guaranteed 孙权 → snapshot 只含曹操；Guaranteed 角色不重复物化。
	var case_d := _case_root("snapshot-d")
	var composition_d := _composition(ENTRY_208, LIU_BEI, [SUN_QUAN], [_chen_an_material()])
	var created_d: Dictionary = _creator(case_d).create_or_resume("creation-m2a-d", composition_d)
	_check(created_d.success, "1 Create D with Guaranteed NPC succeeds")
	if not created_d.success:
		return
	var setup_d := _read_setup(created_d)
	var stable_d: Array = setup_d.get("stable_npcs", [])
	_check(stable_d.size() == 2, "1 Create D snapshot excludes Guaranteed NPC asset")
	if stable_d.size() >= 1:
		_check(String(stable_d[0].get("provenance", {}).get("asset_id", "")) == CAO_CAO, "1 only non-Guaranteed exact-profile Character materializes")
	_check(String(setup_d.get("guaranteed_npcs", [{}])[0].get("role", "")) == "guaranteed_npc", "1 Guaranteed remains a distinct product role")
	_check(JSON.stringify(stable_d).contains("creation_authored"), "1 Create D keeps creation-authored record alongside Source-backed")
	# provenance 是 exact pin（含 generation_fingerprint），不是 current 引用。
	var pin: Dictionary = stable_d[0].get("provenance", {})
	var pin_keys: Array = pin.keys()
	pin_keys.sort()
	var pin_fields: Array = CreateRules.PIN_FIELDS.duplicate()
	pin_fields.sort()
	_check(pin_keys == pin_fields, "1 snapshot provenance is an exact pin")


## 证明 2 + 3：no-Card 创建 actor——Program ID + game_local_material、无假 provenance；
## 同名 display name 是合法的不同人，各自获得 distinct local ID。
func _test_no_card_and_same_name_actors() -> void:
	var case_b := _case_root("local-b")
	var composition_b := _composition(ENTRY_208, LIU_BEI, [], [
		_chen_an_material(),
		{"display_name": "陈安", "profile_text": "同名同姓的另一位荆州驿卒；与粮商陈安不是同一人。"},
	])
	var created_b: Dictionary = _creator(case_b).create_or_resume("creation-m2a-b", composition_b)
	_check(created_b.success, "2 Create B with no-Card NPCs succeeds")
	if not created_b.success:
		return
	var setup_b := _read_setup(created_b)
	var stable_b: Array = setup_b.get("stable_npcs", [])
	var authored: Array = []
	for record: Dictionary in stable_b:
		if String(record.get("origin", {}).get("kind", "")) == "creation_authored":
			authored.append(record)
	_check(authored.size() == 2, "2 both creation-authored no-Card NPCs materialize")
	if authored.size() != 2:
		return
	var first := authored[0] as Dictionary
	_check(not first.has("provenance") and not first.has("source_projection"), "2 no-Card record never fabricates Source provenance")
	_check(String(first.get("game_local_material", {}).get("display_name", "")) == "陈安" \
		and not String(first.get("game_local_material", {}).get("profile_text", "")).is_empty(), "2 no-Card record keeps honest game_local_material")
	_check(String(first.get("role", "")) == "stable_npc", "2 no-Card record role is stable_npc")
	var first_id := String(first.get("local_character_id", ""))
	var second_id := String(authored[1].get("local_character_id", ""))
	_check(not first_id.is_empty() and not second_id.is_empty() and first_id != second_id, "3 same display name yields distinct Program-owned local IDs")
	_check(String((authored[1] as Dictionary).get("game_local_material", {}).get("display_name", "")) == "陈安", "3 duplicate display name stays legal")
	var player_id := String(setup_b.get("player_character", {}).get("local_character_id", ""))
	_check(first_id != player_id and second_id != player_id, "2 stable NPC IDs never collide with Player ID")


## 证明 4：retry authority——同 creation_id resume 复用冻结 snapshot；
## Source current 后续变化（曹操补绑 220 / 孙权新代次）绝不重扫。
func _test_retry_authority_after_source_current_change() -> void:
	var case_c := _case_root("retry-c")
	var composition_c := _composition(ENTRY_220, LIU_BEI, [], [])
	# missing game_local_npcs 字段：既有调用方保持有效，canonicalize 为 []。
	composition_c.erase("game_local_npcs")
	var created_c: Dictionary = _creator(case_c).create_or_resume("creation-m2a-c", composition_c)
	_check(created_c.success, "4 Create C without game_local_npcs field stays valid")
	if not created_c.success:
		return
	var setup_c := _read_setup(created_c)
	var stable_c: Array = setup_c.get("stable_npcs", [])
	_check(stable_c.size() == 1 and String(stable_c[0].get("provenance", {}).get("asset_id", "")) == SUN_QUAN, "4 temporal-incompatible Character (Cao Cao at 220) excluded from snapshot")
	if stable_c.size() != 1:
		return
	var frozen_fingerprint := String(stable_c[0].get("provenance", {}).get("generation_fingerprint", ""))
	_check(not frozen_fingerprint.is_empty(), "4 snapshot freezes exact generation fingerprint")

	# Source current 变化一：曹操补绑 t0-220 → current 现在是 exact_profile。
	var cao_mod_path := case_c.path_join("modified-cao")
	_fixture.copy_package("res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/曹操", cao_mod_path)
	var cao_mod_source := _fixture.read_json(cao_mod_path.path_join("source.json"))
	cao_mod_source["version"] = "%s-m2a" % String(cao_mod_source.get("version", "0"))
	(cao_mod_source["t0_profiles"][0] as Dictionary)["bindings"].append({"world_asset_id": WORLD_HAN, "entry_id": ENTRY_220})
	_fixture.write_json(cao_mod_path.path_join("source.json"), cao_mod_source)
	var cao_mod_installed: Dictionary = _library.install_character_card(cao_mod_path)
	_check(cao_mod_installed.success, "4 modified Cao Cao becomes Source current with 220 coverage")
	# Source current 变化二：孙权新代次（同 asset、新 fingerprint）。
	var sun_path := case_c.path_join("modified-sun")
	_fixture.copy_package("res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/孙权", sun_path)
	var sun_source := _fixture.read_json(sun_path.path_join("source.json"))
	sun_source["version"] = "%s-m2a" % String(sun_source.get("version", "0"))
	sun_source["catalog_summary"] = "%s（newer current）" % String(sun_source.get("catalog_summary", ""))
	_fixture.write_json(sun_path.path_join("source.json"), sun_source)
	var sun_installed: Dictionary = _library.install_character_card(sun_path)
	_check(sun_installed.success and String(sun_installed.generation.identity.generation_fingerprint) != frozen_fingerprint, "4 newer Sun Quan generation becomes Source current")

	var resumed: Dictionary = _creator(case_c).create_or_resume("creation-m2a-c", composition_c)
	_check(resumed.success and bool(resumed.get("already_created", false)), "4 same creation_id resumes frozen intent")
	if not resumed.success:
		return
	var setup_resumed := _read_setup(resumed)
	var stable_resumed: Array = setup_resumed.get("stable_npcs", [])
	_check(stable_resumed.size() == 1, "4 resume never rescans later Source current (no Cao Cao retrofit)")
	if stable_resumed.size() == 1:
		_check(String(stable_resumed[0].get("provenance", {}).get("generation_fingerprint", "")) == frozen_fingerprint, "4 resume keeps frozen exact provenance, not current generation")
		_check(String(stable_resumed[0].get("local_character_id", "")) == String(stable_c[0].get("local_character_id", "")), "4 resume keeps frozen Program-owned local ID")


## 证明 2 附：非法 game_local_npcs 输入 fail-closed。
## IR1-F01：raw 非字符串必须拒绝，不允许 String(...) coercion 混入。
func _test_invalid_game_local_npc_rejected() -> void:
	var case_root := _case_root("invalid")
	var bad := _composition(ENTRY_208, LIU_BEI, [], [{"display_name": "", "profile_text": "x"}])
	var result: Dictionary = _creator(case_root).create_or_resume("creation-m2a-invalid", bad)
	_check(not result.success and String(result.get("code", "")) == "invalid_composition", "2 empty display_name rejected at Composition canonicalization")
	var oversized := _composition(ENTRY_208, LIU_BEI, [], [{"display_name": "陈安", "profile_text": "x".repeat(2000)}])
	var result2: Dictionary = _creator(case_root).create_or_resume("creation-m2a-invalid-2", oversized)
	_check(not result2.success and String(result2.get("code", "")) == "invalid_composition", "2 oversized profile_text rejected by bounded validation")
	# 123 stringify 后是非空文本；raw type 不是 String 时必须拒绝。
	var non_string_name := _composition(ENTRY_208, LIU_BEI, [], [{"display_name": 123, "profile_text": "合法材料。"}])
	var result3: Dictionary = _creator(case_root).create_or_resume("creation-m2a-invalid-3", non_string_name)
	_check(not result3.success and String(result3.get("code", "")) == "invalid_composition", "2 non-string display_name rejected without coercion")
	var non_string_profile := _composition(ENTRY_208, LIU_BEI, [], [{"display_name": "陈安", "profile_text": 42}])
	var result4: Dictionary = _creator(case_root).create_or_resume("creation-m2a-invalid-4", non_string_profile)
	_check(not result4.success and String(result4.get("code", "")) == "invalid_composition", "2 non-string profile_text rejected without coercion")


## 证明 5：旧 Game 兼容——missing stable_npcs 合法、无 Source lookup、Guaranteed-only 行为精确。
func _test_old_game_compatibility() -> void:
	# 旧 intent（initial_setup 无 stable_npcs 键）仍通过 validate_intent。
	var intent_path := _case_root("retry-c").path_join("creation").path_join("intents").path_join("creation-m2a-c.json")
	var intent := _fixture.read_json(intent_path)
	_check(not intent.is_empty(), "5 frozen intent readable for compatibility check")
	if intent.is_empty():
		return
	(intent["initial_setup"] as Dictionary).erase("stable_npcs")
	_check(CreateRules.validate_intent(intent).success, "5 legacy intent without stable_npcs remains valid")
	# 旧形状 world_state：helper 只读 world_state，任何 Source 对象都不存在于此上下文。
	var legacy_world := {
		"player_character": {"local_character_id": "char-player-legacy", "source_projection": {"display_name": "刘备"}},
		"guaranteed_npcs": [{"local_character_id": "char-npc-legacy", "source_projection": {"display_name": "孙权"}}],
	}
	var legacy_records := Rules.stable_npc_records(legacy_world)
	_check(legacy_records.size() == 1 and String(legacy_records[0].get("local_character_id", "")) == "char-npc-legacy", "5 missing stable_npcs means Guaranteed-only behavior")
	var legacy_roster := Rules.actor_roster(legacy_world)
	_check(legacy_roster.size() == 2 and legacy_roster.has("char-player-legacy") and legacy_roster.has("char-npc-legacy"), "5 legacy roster stays Player + Guaranteed exact")


## 证明 6 + 7：统一 roster/eligibility 与 material family 解析。
func _test_unified_roster_eligibility_and_material() -> void:
	var setup := _read_setup(_created_result("snapshot-d", "creation-m2a-d"))
	if setup.is_empty():
		# 防御：证明 1 已创建；重新打开同一 DB。
		_fail("6 Create D setup unavailable")
		return
	var player_id := String(setup.player_character.local_character_id)
	var guaranteed_id := String((setup.guaranteed_npcs[0] as Dictionary).local_character_id)
	var source_backed: Dictionary = {}
	var authored: Dictionary = {}
	for record: Dictionary in setup.get("stable_npcs", []):
		if String(record.get("origin", {}).get("kind", "")) == "source_character":
			source_backed = record
		elif String(record.get("origin", {}).get("kind", "")) == "creation_authored":
			authored = record
	_check(not source_backed.is_empty() and not authored.is_empty(), "6 registry holds both material families")
	if source_backed.is_empty() or authored.is_empty():
		return
	var source_id := String(source_backed.local_character_id)
	var authored_id := String(authored.local_character_id)

	var runtime := MockRuntime.new()
	runtime.world_state = setup
	runtime.conversation.begin_turn("我查看江防部署。")
	runtime.conversation.append_delta("江防部署已经确认。")
	runtime.conversation.complete_generation()
	# 证明 6：Knowledge roster = Player + Guaranteed + Source-backed stable + creation-authored stable。
	var roster := Rules.actor_roster(runtime.world_state)
	_check(roster.has(player_id) and roster.has(guaranteed_id) and roster.has(source_id) and roster.has(authored_id), "6 Knowledge roster includes Player and every stable NPC family")
	_check(String(roster.get(authored_id, "")) == "陈安", "6 roster display resolves from game_local_material")
	# Agency eligibility 排除 Player，包含全部 stable 家族。
	var scheduler := Scheduler.new(runtime, null)
	root.add_child(scheduler)
	await process_frame
	var validated: Array = scheduler._validate_candidates([player_id, source_id, authored_id, "char-unknown-999"])
	_check(not validated.has(player_id) and not validated.has("char-unknown-999"), "6 Agency pool excludes Player and unknown IDs")
	_check(validated.has(source_id) and validated.has(authored_id), "6 Agency pool includes Source-backed and creation-authored stable NPCs")
	scheduler.shutdown()
	scheduler.queue_free()

	# 证明 7：actor execution 两种 material family 都解析；actor 私有 Knowledge 不泄漏。
	var accepted: Array = runtime.conversation.get_durable_accepted_entries()
	var current_hash := Rules.gm_sha256(String((accepted[0] as Dictionary).gm_text))
	runtime.world_state["living_world"] = {
		"schema_version": "living_world.v0.1",
		"knowledge_turns_by_index": {
			"0": {"knowledge_turn_id": "kt-m2a", "source_turn_index": 0, "source_gm_sha256": current_hash, "materialized_at": "2026-09-04T00:00:00Z", "events": [{"knower_id": authored_id, "fact": "陈安知悉盐引底价", "basis": "told"}]},
		},
	}
	var cycle := Cycle.new(runtime)
	root.add_child(cycle)
	await process_frame
	var source_request := JSON.stringify(cycle._actor_request(source_id))
	var sections: Array = source_backed.get("source_projection", {}).get("semantic_sections", [])
	var section_title := String((sections[-1] as Dictionary).get("title", ""))
	_check(not section_title.is_empty() and source_request.contains(section_title), "7 Source-backed actor execution resolves frozen T0 source_projection")
	_check(not source_request.contains("陈安知悉盐引底价"), "7 Source-backed actor never sees another actor's private Knowledge")
	var authored_request := JSON.stringify(cycle._actor_request(authored_id))
	_check(authored_request.contains("江夏粮商"), "7 no-Card actor execution resolves game_local_material")
	_check(authored_request.contains("陈安知悉盐引底价"), "7 no-Card actor receives own committed Knowledge")
	cycle.shutdown()
	cycle.queue_free()


## 证明 8：runtime_narrative origin 的 currentness 契约预留——
## 只在 accepted_hashes[source_turn_index] == source_gm_sha256 时进入 registry。
func _test_runtime_narrative_currentness_contract() -> void:
	var runtime_record := {
		"local_character_id": "char-runtime-synthetic",
		"role": "stable_npc",
		"origin": {"kind": "runtime_narrative", "source_turn_index": 0, "source_gm_sha256": "a".repeat(64)},
		"game_local_material": {"display_name": "合成", "profile_text": "合成 runtime origin 记录。"},
	}
	var world := {
		"player_character": {"local_character_id": "char-player-x", "source_projection": {"display_name": "玩家"}},
		"guaranteed_npcs": [],
		"stable_npcs": [runtime_record],
	}
	var matching := Rules.stable_npc_records(world, {0: "a".repeat(64)})
	_check(matching.size() == 1, "8 runtime_narrative record current only with matching accepted hash")
	_check(Rules.stable_npc_records(world, {0: "b".repeat(64)}).is_empty(), "8 runtime_narrative record excluded on hash mismatch")
	_check(Rules.stable_npc_records(world, {}).is_empty(), "8 runtime_narrative record excluded without accepted hashes")
	# 空/重复 local ID deterministic fail-soft 丢弃。
	var broken := {
		"guaranteed_npcs": [{"local_character_id": "char-dup", "source_projection": {"display_name": "甲"}}],
		"stable_npcs": [
			{"local_character_id": "", "role": "stable_npc", "origin": {"kind": "creation_authored"}, "game_local_material": {"display_name": "空", "profile_text": "空 ID"}},
			{"local_character_id": "char-dup", "role": "stable_npc", "origin": {"kind": "creation_authored"}, "game_local_material": {"display_name": "重", "profile_text": "重复 ID"}},
		],
	}
	var broken_records := Rules.stable_npc_records(broken)
	_check(broken_records.size() == 1 and String(broken_records[0].get("local_character_id", "")) == "char-dup", "8 empty/duplicate local IDs rejected deterministically")


## 证明 9：Save/reopen/Restore 保留 creation-time registry 记录与 Program-owned ID。
## IR1-F02：必须走 production Restore path——mutation 前进 head 后 Restore 回含 registry 的 Save snapshot。
func _test_persistence_reopen_preserves_registry() -> void:
	var created := _created_result("snapshot-d", "creation-m2a-d")
	var expected: Array = _read_setup(created).get("stable_npcs", [])
	_check(expected.size() == 2, "9 fixture registry present before persistence proof")
	var session := SessionRuntime.new()
	_check(session.open_existing_game(String(created.database_path)).success, "9 production Runtime reopens created Game")
	if not session.is_ready():
		return
	_check(_stable_ids(session.world_state) == _stable_ids({"stable_npcs": expected}), "9 reopen preserves registry Program-owned IDs")
	# 在含 creation-time registry 的 snapshot 上创建 production Save Point。
	var head_at_save := String(session.active_head_id)
	var saved: Dictionary = session.create_save_point("注册表基线")
	_check(bool(saved.get("success", false)) and not String(saved.get("save_id", "")).is_empty(), "9 production Save Point created on registry snapshot")
	var save_id := String(saved.get("save_id", ""))
	# 后续 durable mutation 前进 head。
	var candidate: Dictionary = (session.world_state as Dictionary).duplicate(true)
	candidate["living_world"] = {"schema_version": "living_world.v0.1"}
	var committed: Dictionary = session.commit_world_mutation_durably("m2a-registry-mutation", "m2a-registry-node", candidate)
	_check(bool(committed.get("success", false)), "9 durable mutation commits on top of registry Game")
	_check(String(session.active_head_id) == "m2a-registry-node", "9 durable head advanced normally")
	# production Restore path：回到含 creation-time registry 的 snapshot。
	var restored: Dictionary = session.restore_save_point(save_id)
	_check(bool(restored.get("success", false)), "9 production Restore path succeeds")
	_check(String(session.active_head_id) == head_at_save, "9 Restore returns head to registry snapshot")
	_check(_stable_ids(session.world_state) == _stable_ids({"stable_npcs": expected}), "9 Restore preserves stable_npcs records and Program-owned IDs unchanged")
	session.close()
	var reopened := SessionRuntime.new()
	_check(reopened.open_existing_game(String(created.database_path)).success, "9 Game reopens after Restore")
	if reopened.is_ready():
		_check(_stable_ids(reopened.world_state) == _stable_ids({"stable_npcs": expected}), "9 Restore result survives close/reopen")
		_check(String(reopened.active_head_id) == head_at_save, "9 reopened head stays at restored snapshot")
	reopened.close()


func _stable_ids(world_state: Dictionary) -> Array:
	var ids: Array = []
	for record: Dictionary in world_state.get("stable_npcs", []):
		ids.append(String(record.get("local_character_id", "")))
	ids.sort()
	return ids


func _created_result(case_name: String, creation_id: String) -> Dictionary:
	var case_root := _case_root(case_name)
	var creator := FinalCreate.new(_library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games"))
	var store_path := case_root.path_join("creation").path_join("created").path_join("%s.json" % creation_id)
	var marker := _fixture.read_json(store_path)
	if marker.is_empty():
		return {}
	# 重新 converge 同一 frozen intent（幂等，already_created）。
	var composition := _composition_for_reopen(creation_id)
	var result: Dictionary = creator.create_or_resume(creation_id, composition)
	return result


func _composition_for_reopen(creation_id: String) -> Dictionary:
	# 与首次创建完全一致的 Composition（含 game_local_npcs），保证 fingerprint 匹配。
	match creation_id:
		"creation-m2a-d":
			return _composition(ENTRY_208, LIU_BEI, [SUN_QUAN], [_chen_an_material()])
		"creation-m2a-c":
			var composition := _composition(ENTRY_220, LIU_BEI, [], [])
			composition.erase("game_local_npcs")
			return composition
	return {}


func _chen_an_material() -> Dictionary:
	return {"display_name": "陈安", "profile_text": "江夏粮商；本局建局时已确定的身份、关系或动机材料。"}


func _composition(entry_id: String, player_id: String, npc_ids: Array, local_npcs: Array) -> Dictionary:
	var creation := Creation.new(_library)
	creation.select_world(_generation(WORLD_HAN))
	creation.select_entry(entry_id)
	creation.confirm_expansion_none()
	creation.select_player(_generation(player_id))
	for npc_id: String in npc_ids:
		creation.set_guaranteed_npc(_generation(npc_id), true)
	if not local_npcs.is_empty():
		creation.set_game_local_npcs(local_npcs)
	creation.set_settings("M2A 注册表测试局", "Narrative", "")
	return creation.composition_snapshot()


func _read_setup(result: Dictionary) -> Dictionary:
	if result.is_empty():
		return {}
	var persistence := Persistence.new()
	var opened := persistence.open_database(String(result.database_path))
	if not opened.success:
		return {}
	var root := persistence.get_timeline_node(String(result.game_id), String(result.root_node_id))
	persistence.close_database()
	if not root.success:
		return {}
	return root.get("world_state", {})


func _creator(case_root: String) -> RefCounted:
	return FinalCreate.new(_library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games"))


func _generation(asset_id: String) -> RefCounted:
	return _fixture.find_generation(_generations, asset_id)


func _case_root(name: String) -> String:
	var path := _root.path_join(name)
	DirAccess.make_dir_recursive_absolute(path)
	return path


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G5-03M2A FOCUSED PASS | %s" % label)
	else:
		_failures += 1
		push_error("G5-03M2A FOCUSED FAIL | %s" % label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G5-03M2A FOCUSED FAIL | %s" % label)


func _finish() -> void:
	print("G5-03M2A FOCUSED | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
