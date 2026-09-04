extends SceneTree

## MW-001 Runtime Narrative Actor Materialization —— focused deterministic 证明。
## 覆盖 task §8 的 1–11；§8-12（M1 dirty/foreground/selector 0..4 保护）由 G5-03 回归套件覆盖。
## 零真实 Provider 调用；ControlledRuntime 不含任何 Source 对象，「无 runtime Source lookup」
## 由结构保证（INV-13），production diff 侧另由 evidence 的 grep 证明。

const Conversation := preload("res://src/domain/会话.gd")
const WorldTurn := preload("res://src/世界回合/L3_外交层/世界回合公开接口.gd")
const Parser := preload("res://src/世界回合/L1_器件层/语义变更响应解析器.gd")
const Rules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")
const Scheduler := preload("res://src/世界回合/L3_外交层/行动代理调度公开接口.gd")
const Cycle := preload("res://src/世界回合/L3_外交层/行动代理循环公开接口.gd")
const SessionRuntime := preload("res://src/runtime/当前游戏会话运行时.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const StubAdapter := preload("res://tests/g5_01/世界回合语义桩适配器.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

const GAME_ID := "game-mw001-controlled"
const PLAYER_ID := "char-player-mw001"
const CHEN_AN_ID := "char-local-chen-an"
const SHEN_NAME := "沈青"
const SHEN_PROFILE := "叙山渡口的摆渡人，受托看守旧船票。"
const SHEN_GM := "摆渡人沈青撑着旧船靠岸，答应每日黄昏等你。"

const WORLD_HAN := "world.han_end.unsettled_realm"
const ENTRY_208 := "t0-208-red-cliffs-eve"
const LIU_BEI := "character.han_end.liu_bei"


## 最小 Runtime 形状：world_state + conversation + durable commit seam；无任何 Source 对象。
class ControlledRuntime:
	extends RefCounted

	var conversation: RefCounted = Conversation.new()
	var game_id := "game-mw001-controlled"
	var active_head_id := "root"
	var world_state: Dictionary = {}
	var commit_count := 0

	func is_ready() -> bool:
		return true

	func commit_world_mutation_durably(_mutation_id: String, node_id: String, candidate: Dictionary) -> Dictionary:
		commit_count += 1
		active_head_id = node_id
		world_state = candidate.duplicate(true)
		return {"success": true, "status": "committed", "head_id": node_id, "world_state": world_state.duplicate(true)}


var _failures := 0
var _fixture := Fixture.new()
var _root := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("g5_03m2b") < 0:
		_fail("必须提供 task-owned --root，且路径包含 g5_03m2b")
		return _finish()
	_fixture.reset_directory(_root)
	_test_parser_contract()
	await _test_valid_actor_materialization()
	await _test_fail_soft_actor_field()
	await _test_current_hash_filtering()
	await _test_same_turn_agency_visibility()
	await _test_production_save_restore()
	_finish()


## 证明 1/3/4 的 parser 级契约：bounded material、字段剥离、fail-soft 隔离、raw type 拒绝。
func _test_parser_contract() -> void:
	var parser := Parser.new()
	var ok: Dictionary = parser.parse('{"changes":["桥断了。"],"new_actor_candidates":[{"display_name":"沈青","profile_text":"摆渡人。","local_character_id":"model-id","asset_id":"x","provenance":{"asset_id":"x"},"origin":{"kind":"source_character"}}]}')
	_check(ok.success and (ok.new_actor_candidates as Array).size() == 1, "1 valid candidate parses alongside valid changes")
	var clean: Dictionary = (ok.new_actor_candidates as Array)[0]
	var keys: Array = clean.keys()
	keys.sort()
	_check(keys == ["display_name", "profile_text"], "1 parser strips every model-provided identity/provenance field")
	_check((ok.changes as Array).size() == 1, "3 actor field never invalidates otherwise valid changes")

	var non_array: Dictionary = parser.parse('{"changes":["桥断了。"],"new_actor_candidates":42}')
	_check(non_array.success and (non_array.new_actor_candidates as Array).is_empty() and int(non_array.actors_dropped) == 1 and (non_array.changes as Array).size() == 1, "3 non-array actor field fail-soft without damaging changes")

	var junk: Dictionary = parser.parse('{"changes":[],"new_actor_candidates":["text",{"display_name":"沈青"}, {"display_name":123,"profile_text":"合法材料。"},{"display_name":"合法名","profile_text":42},{"display_name":"  ","profile_text":"x"}]}')
	_check(junk.success and (junk.new_actor_candidates as Array).is_empty() and int(junk.actors_dropped) == 5, "4 non-string/missing/blank candidate material dropped fail-soft, never coerced")

	var dup: Dictionary = parser.parse('{"changes":[],"new_actor_candidates":[{"display_name":"沈青","profile_text":"摆渡人。"},{"display_name":"沈青","profile_text":"摆渡人。"},{"display_name":"沈青","profile_text":"同名不同人。"}]}')
	_check((dup.new_actor_candidates as Array).size() == 2, "3 exact duplicate material deduped; same name with different profile stays a distinct candidate")

	var absent: Dictionary = parser.parse('{"changes":["桥断了。"]}')
	_check(absent.success and (absent.new_actor_candidates as Array).is_empty() and int(absent.actors_dropped) == 0, "2 absent actor field keeps pre-MW-001 behavior exactly")


## 证明 1 + 2 + 5 + 9：valid runtime actor 物化；actor-only commit 不伪造 changes；
## 同版本 replay/reopen 不重复；materialization 不自动授予 Knowledge。
func _test_valid_actor_materialization() -> void:
	var runtime := ControlledRuntime.new()
	runtime.world_state = _base_world()
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	_accept(runtime, "我在渡口雇船。", SHEN_GM)
	await process_frame
	_check(stub.requests.size() == 1, "1 accepted ordinary turn starts exactly one semantic analysis")
	# 证明 11（前半）：request 带 current roster 与不重复提议指引。
	var request_text := JSON.stringify(stub.requests[0])
	_check(request_text.contains("Allowed Stable Actors") and request_text.contains(CHEN_AN_ID), "11 semantic request carries current exact stable roster")
	_check(request_text.contains("new_actor_candidates") and request_text.contains("不要提议已在"), "11 request instructs bounded actor material and no re-proposal of roster actors")
	stub.simulate_delta('{"changes":[],"knowledge_events":[],"new_actor_candidates":[{"display_name":"沈青","profile_text":"%s","local_character_id":"model-minted-id","provenance":{"asset_id":"fake"}}]}' % SHEN_PROFILE)
	stub.simulate_completed()
	await process_frame
	_check(String(worker.last_result.get("status", "")) == "committed" and int(worker.last_result.get("actor_count", 0)) == 1 and runtime.commit_count == 1, "2 actor-only semantic result still produces exactly one durable mutation")
	var stable: Array = runtime.world_state.get("stable_npcs", [])
	_check(stable.size() == 2, "1 runtime actor appended to stable_npcs registry")
	if stable.size() != 2:
		worker.shutdown()
		worker.queue_free()
		return
	var record: Dictionary = stable[1] as Dictionary
	var gm_hash := Rules.gm_sha256(SHEN_GM)
	var origin: Dictionary = record.get("origin", {})
	_check(String(origin.get("kind", "")) == "runtime_narrative" and int(origin.get("source_turn_index", -1)) == 0 and String(origin.get("source_gm_sha256", "")) == gm_hash, "1 origin pins exact accepted turn + GM hash")
	var local_id := String(record.get("local_character_id", ""))
	var expected_id := String(Rules.runtime_actor_identities(GAME_ID, 0, gm_hash, 0, SHEN_NAME, SHEN_PROFILE).local_character_id)
	_check(local_id == expected_id and local_id.begins_with("character-runtime-") and local_id != "model-minted-id", "1 Program-owned deterministic local ID; model-minted ID ignored")
	_check(String(record.get("role", "")) == "stable_npc" and not record.has("provenance") and not record.has("source_projection"), "1 runtime actor never fabricates Source provenance")
	var material: Dictionary = record.get("game_local_material", {})
	_check(String(material.get("display_name", "")) == SHEN_NAME and String(material.get("profile_text", "")) == SHEN_PROFILE, "1 record keeps bounded honest game_local_material")
	_check(not runtime.world_state.has("living_world"), "2 actor-only commit fabricates no changes record")
	# 证明 9：materialization 本身不产生任何 knowledge record/event。
	_check(not record.has("knowledge") and not record.has("knowledge_events"), "9 materialization alone grants no Knowledge")
	# 证明 5（same worker replay）。
	worker.consider_latest_accepted_turn()
	await process_frame
	_check(String(worker.last_result.get("status", "")) == "already_materialized" and stub.requests.size() == 1 and runtime.commit_count == 1, "5 same-worker replay sends no second request")
	# 证明 5（reopen-like fresh worker：内存 _attempted_versions 为空，靠 durable origin 信号幂等）。
	var stub2 := StubAdapter.new()
	var worker2 := WorldTurn.new(runtime, stub2)
	root.add_child(worker2)
	await process_frame
	var replay: Dictionary = worker2.consider_latest_accepted_turn()
	_check(String(replay.get("status", "")) == "already_materialized" and stub2.requests.is_empty() and runtime.commit_count == 1, "5 reopen replay of actor-only version is durable-idempotent")
	_check((runtime.world_state.get("stable_npcs", []) as Array).size() == 2, "5 replay creates no second actor record or identity")
	worker.shutdown()
	worker.queue_free()
	worker2.shutdown()
	worker2.queue_free()
	# 证明 9（后半）：另一 actor 的私有 Knowledge 不向新 actor 泄漏。
	runtime.world_state["living_world"] = {
		"schema_version": "living_world.v0.1",
		"knowledge_turns_by_index": {
			"0": Rules.build_knowledge_record(GAME_ID, 0, SHEN_GM, [{"knower_id": CHEN_AN_ID, "fact": "陈安知悉盐引底价", "basis": "told"}], "2026-09-04T00:00:00Z"),
		},
	}
	var cycle := Cycle.new(runtime)
	root.add_child(cycle)
	await process_frame
	var new_actor_request := JSON.stringify(cycle._actor_request(local_id))
	_check(not new_actor_request.contains("盐引底价"), "9 another actor's private Knowledge stays private to the new actor")
	_check(JSON.stringify(cycle._actor_request(CHEN_AN_ID)).contains("盐引底价"), "9 pre-existing actor Knowledge itself still resolves (sanity)")
	cycle.shutdown()
	cycle.queue_free()


## 证明 3（流程级）：malformed actor 字段不破坏 otherwise valid changes commit。
func _test_fail_soft_actor_field() -> void:
	var runtime := ControlledRuntime.new()
	runtime.world_state = _base_world()
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	_accept(runtime, "我去查看断桥。", "渡口的旧桥已被洪水冲断。")
	await process_frame
	stub.simulate_delta('{"changes":["渡口的旧桥已被洪水冲断。"],"new_actor_candidates":[{"display_name":777,"profile_text":"x"},"bad-entry"]}')
	stub.simulate_completed()
	await process_frame
	_check(String(worker.last_result.get("status", "")) == "committed" and int(worker.last_result.get("change_count", 0)) == 1, "3 valid changes commit exactly as before despite junk actor entries")
	_check(int(worker.last_result.get("actor_count", -1)) == 0 and int(worker.last_result.get("actors_dropped", 0)) == 2, "3 junk actor entries counted as dropped, no actor materialized")
	_check((runtime.world_state.get("stable_npcs", []) as Array).size() == 1, "3 registry unchanged by malformed actor candidates")
	var records: Dictionary = runtime.world_state.get("living_world", {}).get("semantic_turns_by_index", {})
	_check(records.size() == 1, "3 changes record itself is intact")
	worker.shutdown()
	worker.queue_free()


## 证明 6 + 11（后半）：regenerate 使 origin hash 不再 current——stale runtime actor 物理保留，
## 但从 current roster / Agency eligibility / 后续 semantic request roster 中失效。
func _test_current_hash_filtering() -> void:
	var runtime := ControlledRuntime.new()
	runtime.world_state = _base_world()
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	_accept(runtime, "我在渡口雇船。", SHEN_GM)
	await process_frame
	stub.simulate_delta('{"changes":[],"new_actor_candidates":[{"display_name":"沈青","profile_text":"%s"}]}' % SHEN_PROFILE)
	stub.simulate_completed()
	await process_frame
	var stable: Array = runtime.world_state.get("stable_npcs", [])
	if stable.size() != 2:
		_fail("6 setup: runtime actor materialization failed")
		worker.shutdown()
		worker.queue_free()
		return
	var shen_id := String((stable[1] as Dictionary).get("local_character_id", ""))
	# regenerate 同一 turn：accepted GM hash 改变，origin turn/hash 不再匹配 current truth。
	runtime.conversation.retry_or_regenerate_latest()
	runtime.conversation.append_delta("渡口空无一人，只有一条旧船搁浅在滩上。")
	runtime.conversation.complete_generation()
	await process_frame
	_check(stub.requests.size() == 2, "6 regenerated accepted version triggers a fresh semantic analysis")
	# 物理历史保留。
	_check((runtime.world_state.get("stable_npcs", []) as Array).size() == 2, "6 stale runtime actor stays physically in world history")
	# currentness 过滤。
	var current_hashes := _accepted_hashes(runtime)
	_check(Rules.stable_npc_records(runtime.world_state, current_hashes).size() == 1, "6 stale runtime actor excluded from current registry on hash mismatch")
	_check(not Rules.actor_roster(runtime.world_state, current_hashes).has(shen_id), "6 stale runtime actor absent from current roster")
	# 后续 semantic request roster 不再呈现 stale actor（INV-05/INV-10）。
	var regen_request := JSON.stringify(stub.requests[1])
	_check(regen_request.contains(CHEN_AN_ID) and not regen_request.contains(shen_id), "11 stale runtime actor excluded from later semantic request roster")
	# Agency eligibility 排除 stale actor。
	var scheduler := Scheduler.new(runtime, null)
	root.add_child(scheduler)
	await process_frame
	_check(scheduler._validate_candidates([shen_id]).is_empty(), "6 stale runtime actor loses Agency eligibility")
	_check(not JSON.stringify(scheduler._selector_request()).contains(shen_id), "6 stale runtime actor absent from selector request")
	scheduler.shutdown()
	scheduler.queue_free()
	# 新版本分析应答 no-material，不再产生 mutation。
	stub.simulate_delta('{"changes":[],"new_actor_candidates":[]}')
	stub.simulate_completed()
	await process_frame
	_check(String(worker.last_result.get("status", "")) == "no_changes" and runtime.commit_count == 1, "8 empty new-version analysis keeps no-op behavior")
	worker.shutdown()
	worker.queue_free()


## 证明 8：semantic commit 后，同一 dirty 机会的 selector request/eligibility 即可见可选新 actor；
## actor execution 能解析 game_local_material。
func _test_same_turn_agency_visibility() -> void:
	var runtime := ControlledRuntime.new()
	runtime.world_state = _base_world()
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(runtime, stub)
	root.add_child(worker)
	await process_frame
	_accept(runtime, "我在渡口雇船。", SHEN_GM)
	await process_frame
	stub.simulate_delta('{"changes":[],"new_actor_candidates":[{"display_name":"沈青","profile_text":"%s"}]}' % SHEN_PROFILE)
	stub.simulate_completed()
	await process_frame
	_check(String(worker.last_result.get("status", "")) == "committed", "8 semantic terminal completed with actor commit")
	var stable: Array = runtime.world_state.get("stable_npcs", [])
	if stable.size() != 2:
		_fail("8 setup: runtime actor materialization failed")
		worker.shutdown()
		worker.queue_free()
		return
	var shen_id := String((stable[1] as Dictionary).get("local_character_id", ""))
	# 现有 terminal wake 之后的 selector 输入（scheduler 生产代码零改动）。
	var scheduler := Scheduler.new(runtime, null)
	root.add_child(scheduler)
	await process_frame
	_check(JSON.stringify(scheduler._selector_request()).contains(shen_id), "8 selector request sees the materialized actor in the same dirty opportunity")
	var validated: Array = scheduler._validate_candidates([shen_id])
	_check(validated.size() == 1 and String(validated[0]) == shen_id, "8 selector eligibility accepts the new Program-owned ID")
	scheduler.shutdown()
	scheduler.queue_free()
	var cycle := Cycle.new(runtime)
	root.add_child(cycle)
	await process_frame
	_check(JSON.stringify(cycle._actor_request(shen_id)).contains("叙山渡口的摆渡人"), "8 actor execution resolves runtime actor game_local_material")
	cycle.shutdown()
	cycle.queue_free()
	worker.shutdown()
	worker.queue_free()


## 证明 7：production Save/reopen/Restore 保留 exact runtime actor 记录与 Program-owned ID。
func _test_production_save_restore() -> void:
	var case_root := _case_root("persistence")
	var installed: Dictionary = _fixture.install_real_assets(_root.path_join("source-library"))
	_check(installed.success, "7 fixture installs frozen real Source assets (creation-time only)")
	if not installed.success:
		return
	var creation := Creation.new(installed.library)
	creation.select_world(_find_generation(installed.installed, WORLD_HAN))
	creation.select_entry(ENTRY_208)
	creation.confirm_expansion_none()
	creation.select_player(_find_generation(installed.installed, LIU_BEI))
	creation.set_settings("MW-001 持久化测试局", "Narrative", "")
	var creator := FinalCreate.new(installed.library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games"))
	var created: Dictionary = creator.create_or_resume("creation-mw001-persistence", creation.composition_snapshot())
	_check(created.success, "7 production Game created")
	if not created.success:
		return
	var session := SessionRuntime.new()
	_check(session.open_existing_game(String(created.database_path)).success, "7 production Runtime opens created Game")
	if not session.is_ready():
		return
	# 走 production acceptance seam + 真实 SemanticMaterializationProcess + 真实 durable commit。
	var stub := StubAdapter.new()
	var worker := WorldTurn.new(session, stub)
	root.add_child(worker)
	await process_frame
	session.conversation.begin_turn("我造访渡口。")
	session.conversation.append_delta(SHEN_GM)
	var accepted: Dictionary = session.complete_active_generation_durably()
	_check(bool(accepted.get("success", false)), "7 production durable acceptance succeeds")
	await process_frame
	_check(stub.requests.size() == 1, "7 production semantic lane started")
	stub.simulate_delta('{"changes":[],"new_actor_candidates":[{"display_name":"沈青","profile_text":"%s"}]}' % SHEN_PROFILE)
	stub.simulate_completed()
	await process_frame
	_check(String(worker.last_result.get("status", "")) == "committed", "7 production semantic commit materializes runtime actor")
	var runtime_record := _runtime_record(session.world_state)
	_check(not runtime_record.is_empty(), "7 runtime actor record present in production World")
	if runtime_record.is_empty():
		worker.shutdown()
		worker.queue_free()
		session.close()
		return
	var local_id := String(runtime_record.get("local_character_id", ""))
	# 在含 runtime actor 的 snapshot 上创建 production Save Point。
	var head_at_save := String(session.active_head_id)
	var saved: Dictionary = session.create_save_point("MW-001 基线")
	_check(bool(saved.get("success", false)), "7 production Save Point created")
	var save_id := String(saved.get("save_id", ""))
	# 后续 durable mutation 前进 head。
	var advance: Dictionary = (session.world_state as Dictionary).duplicate(true)
	advance["living_world"] = {"schema_version": "living_world.v0.1"}
	var committed: Dictionary = session.commit_world_mutation_durably("mw001-advance", "mw001-advance-node", advance)
	_check(bool(committed.get("success", false)) and String(session.active_head_id) == "mw001-advance-node", "7 durable head advanced after Save")
	# production Restore path 回到含 runtime actor 的 snapshot。
	var restored: Dictionary = session.restore_save_point(save_id)
	_check(bool(restored.get("success", false)) and String(session.active_head_id) == head_at_save, "7 production Restore returns head to actor snapshot")
	_check(_same_runtime_record(_runtime_record(session.world_state), runtime_record), "7 Restore preserves exact runtime actor record and Program-owned ID")
	worker.shutdown()
	worker.queue_free()
	session.close()
	var reopened := SessionRuntime.new()
	_check(reopened.open_existing_game(String(created.database_path)).success, "7 Game reopens after Restore")
	if reopened.is_ready():
		_check(_same_runtime_record(_runtime_record(reopened.world_state), runtime_record), "7 runtime actor record survives close/reopen after Restore")
		_check(String(reopened.active_head_id) == head_at_save, "7 reopened head stays at restored snapshot")
	reopened.close()


func _base_world() -> Dictionary:
	return {
		"player_character": {"local_character_id": PLAYER_ID, "game_local_material": {"display_name": "玩家", "profile_text": "玩家角色。"}},
		"guaranteed_npcs": [],
		"stable_npcs": [
			{"local_character_id": CHEN_AN_ID, "role": "stable_npc", "origin": {"kind": "creation_authored"}, "game_local_material": {"display_name": "陈安", "profile_text": "江夏粮商。"}},
		],
	}


func _accept(runtime: ControlledRuntime, player: String, gm: String) -> void:
	runtime.conversation.begin_turn(player)
	runtime.conversation.append_delta(gm)
	runtime.conversation.complete_generation()


func _accepted_hashes(runtime: ControlledRuntime) -> Dictionary:
	var accepted_hashes: Dictionary = {}
	for entry_value: Variant in runtime.conversation.get_durable_accepted_entries():
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue
		var entry := entry_value as Dictionary
		accepted_hashes[int(entry.get("turn_index", -1))] = Rules.gm_sha256(String(entry.get("gm_text", "")))
	return accepted_hashes


func _runtime_record(world_state: Dictionary) -> Dictionary:
	var stable_value: Variant = world_state.get("stable_npcs", [])
	if typeof(stable_value) != TYPE_ARRAY:
		return {}
	for record_value: Variant in stable_value as Array:
		if typeof(record_value) != TYPE_DICTIONARY:
			continue
		var record := record_value as Dictionary
		var origin_value: Variant = record.get("origin", {})
		if typeof(origin_value) != TYPE_DICTIONARY:
			continue
		if String((origin_value as Dictionary).get("kind", "")) == "runtime_narrative":
			return record
	return {}


func _same_runtime_record(actual: Dictionary, expected: Dictionary) -> bool:
	if actual.is_empty() or expected.is_empty():
		return false
	var actual_origin: Dictionary = actual.get("origin", {})
	var expected_origin: Dictionary = expected.get("origin", {})
	var actual_material: Dictionary = actual.get("game_local_material", {})
	var expected_material: Dictionary = expected.get("game_local_material", {})
	return String(actual.get("local_character_id", "")) == String(expected.get("local_character_id", "")) \
		and String(actual.get("role", "")) == String(expected.get("role", "")) \
		and String(actual_origin.get("kind", "")) == String(expected_origin.get("kind", "")) \
		and int(actual_origin.get("source_turn_index", -1)) == int(expected_origin.get("source_turn_index", -2)) \
		and String(actual_origin.get("source_gm_sha256", "")) == String(expected_origin.get("source_gm_sha256", "")) \
		and String(actual_material.get("display_name", "")) == String(expected_material.get("display_name", "")) \
		and String(actual_material.get("profile_text", "")) == String(expected_material.get("profile_text", ""))


func _find_generation(installed: Array, asset_id: String) -> RefCounted:
	return _fixture.find_generation(installed, asset_id)


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
		print("MW-001 FOCUSED PASS | %s" % label)
	else:
		_failures += 1
		push_error("MW-001 FOCUSED FAIL | %s" % label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("MW-001 FOCUSED FAIL | %s" % label)


func _finish() -> void:
	print("MW-001 FOCUSED | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
