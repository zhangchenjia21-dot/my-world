extends SceneTree

const SourceContract := preload("res://src/source/L3_外交层/Source合同公开接口.gd")
const SourceLibrary := preload("res://src/source/L3_外交层/Source库公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const GameRuntime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Adjudication := preload("res://src/行动判定/L3_外交层/行动判定公开接口.gd")
const Rules := preload("res://src/行动判定/L0_公理层/公开D20判定规则.gd")
const StubAdapter := preload("res://tests/g4_07a/首次开场桩适配器.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

class DeterministicRng:
	extends RefCounted
	var values: Array
	var invocation_count := 0
	func _init(faces: Array) -> void:
		values = faces.duplicate()
	func roll_d20() -> int:
		var value := int(values[invocation_count])
		invocation_count += 1
		return value

var _failures := 0
var _root := ""
var _fixture := Fixture.new()
var _library: RefCounted
var _generations: Array = []
var _expansion: RefCounted


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("g4_08m1") < 0:
		_fail("task-owned --root must contain g4_08m1")
		return _finish()
	_fixture.reset_directory(_root)
	_test_source_third_type()
	if _library == null:
		return _finish()
	_test_compatibility_and_create()
	_test_rng_authority()
	await _test_retry_restart_and_no_check()
	await _test_cross_world_binding()
	_finish()


func _test_source_third_type() -> void:
	var contract := SourceContract.new()
	var loaded := contract.load_expansion_pack("res://tests/fixtures/g4_08m1/判定与检定_公开d20")
	_check(loaded.success and String(loaded.source.identity.asset_id) == "exp.check_core.public_d20", "A load real expansion_pack.v0.1")
	_check(loaded.success and String(loaded.source.capability_binding.capability_id) == Rules.CAPABILITY_ID, "A strict capability binding projected")
	var source_root := _root.path_join("source-library")
	var installed_assets := _fixture.install_real_assets(source_root)
	_check(installed_assets.success, "J real 2 World + 6 Character install regression")
	if not installed_assets.success:
		return
	_library = installed_assets.library
	_generations = installed_assets.installed
	var installed: Dictionary = _library.install_expansion_pack("res://tests/fixtures/g4_08m1/判定与检定_公开d20")
	_check(installed.success, "A expansion install through production Managed Library | %s" % JSON.stringify(installed))
	if not installed.success:
		return
	_expansion = installed.generation
	var current: Dictionary = _library.get_current_expansion("exp.check_core.public_d20")
	var exact: Dictionary = _library.get_exact_expansion("exp.check_core.public_d20", String(_expansion.identity.generation_fingerprint))
	_check(current.success and exact.success, "A current/exact lookup revalidates managed bytes")
	var inventory: Dictionary = _library.list_current_sources()
	_check(inventory.success and inventory.sources.size() == 9, "A list_current_sources includes third Source type")

	var changed_path := _root.path_join("changed-expansion")
	_fixture.copy_package("res://tests/fixtures/g4_08m1/判定与检定_公开d20", changed_path)
	var rules_file := FileAccess.open(changed_path.path_join("rules.md"), FileAccess.WRITE)
	rules_file.store_string(FileAccess.get_file_as_string("res://tests/fixtures/g4_08m1/判定与检定_公开d20/rules.md") + "\n代次变更证据。\n")
	rules_file.close()
	var changed: Dictionary = _library.install_expansion_pack(changed_path)
	_check(changed.success and String(changed.generation.identity.generation_fingerprint) != String(_expansion.identity.generation_fingerprint), "A semantic bytes change fingerprint")
	var old_exact: Dictionary = _library.get_exact_expansion("exp.check_core.public_d20", String(_expansion.identity.generation_fingerprint))
	_check(old_exact.success, "A old exact Expansion remains resolvable after current moves")


func _test_compatibility_and_create() -> void:
	var none := _composition("world.han_end.unsettled_realm", "t0-208-red-cliffs-eve", "character.han_end.liu_bei", false)
	_check(Creation.new(_library).review_frozen_composition(none).success, "B zero Expansion remains valid")
	var selected := _composition("world.han_end.unsettled_realm", "t0-208-red-cliffs-eve", "character.han_end.liu_bei", true)
	_check(Creation.new(_library).review_frozen_composition(selected).success, "B Public d20 valid for Han without family guessing")
	var duplicate := selected.duplicate(true)
	duplicate.expansions.append(duplicate.expansions[0].duplicate(true))
	var duplicate_review := Creation.new(_library).review_frozen_composition(duplicate)
	_check(not duplicate_review.success and String(duplicate_review.code) == "duplicate_expansion", "B duplicate exact generation fails closed")
	var collision_install: Dictionary = _library.install_expansion_pack("res://tests/fixtures/g4_08m1/冲突拓展")
	var collision_state := Creation.new(_library)
	collision_state.select_world(_generation("world.han_end.unsettled_realm"))
	collision_state.select_entry("t0-208-red-cliffs-eve")
	collision_state.set_expansion(_expansion, true)
	var slot_conflict: Dictionary = collision_state.set_expansion(collision_install.generation, true)
	_check(collision_install.success and not slot_conflict.success and String(slot_conflict.code) == "capability_slot_conflict", "B two distinct Expansions claiming action_resolution fail closed")
	var secondary_path := _root.path_join("secondary-expansion")
	_fixture.copy_package("res://tests/fixtures/g4_08m1/冲突拓展", secondary_path)
	var secondary_manifest := _fixture.read_json(secondary_path.path_join("source.json"))
	secondary_manifest.asset_id = "exp.test.secondary_slot"
	secondary_manifest.capability_binding.capability_slot = "secondary_test_slot"
	_fixture.write_json(secondary_path.path_join("source.json"), secondary_manifest)
	var secondary_install: Dictionary = _library.install_expansion_pack(secondary_path)
	var order_a := Creation.new(_library)
	order_a.set_expansion(secondary_install.generation, true)
	order_a.set_expansion(_expansion, true)
	var order_b := Creation.new(_library)
	order_b.set_expansion(_expansion, true)
	order_b.set_expansion(secondary_install.generation, true)
	_check(secondary_install.success and order_a.composition_snapshot().expansions == order_b.composition_snapshot().expansions, "B 0..N Expansion selection ordering is deterministic")

	var case_root := _root.path_join("create")
	var creator := FinalCreate.new(_library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games"))
	var created := creator.create_or_resume("g4-08m1-create", selected)
	_check(created.success, "C Final Create with exact Expansion succeeds")
	if not created.success:
		return
	var runtime := GameRuntime.new()
	var opened := runtime.open_existing_game(String(created.database_path))
	_check(opened.success and runtime.world_state.expansions.size() == 1, "C materialized Expansion survives fresh existing-only open")
	if opened.success:
		var materialized: Dictionary = runtime.world_state.expansions[0]
		_check(String(materialized.provenance.generation_fingerprint) == String(selected.expansions[0].identity.generation_fingerprint), "C exact generation ancestry pinned in Game")
		_check(String(materialized.capability_id) == Rules.CAPABILITY_ID and String(materialized.capability_slot) == Rules.CAPABILITY_SLOT, "C capability binding materialized")
		_check(JSON.stringify(materialized.semantic_sections).contains("提案必须在程序 RNG 前冻结"), "C authored rules materialized from exact package")
		runtime.close()
	var replay := creator.create_or_resume("g4-08m1-create", selected)
	_check(replay.success and String(replay.game_id) == String(created.game_id), "C same creation/payload replays same Game")
	var changed := selected.duplicate(true)
	changed.expansions = []
	changed.expansion_none_confirmed = true
	var conflict := creator.create_or_resume("g4-08m1-create", changed)
	_check(not conflict.success and String(conflict.code) == "creation_payload_conflict", "C changed Expansion payload conflicts")


func _test_rng_authority() -> void:
	var base := {"action_id": "a", "intent": "尝试", "dc": 15, "modifier": 2, "stance": "normal", "modifier_reason": "事实", "situation_reason": "风险", "success_intent": "成功", "failure_stakes": "失败"}
	var normal := Rules.compute_result(base, [13])
	_check(normal.success and normal.selected_roll == 13 and normal.total == 15 and normal.outcome == "success", "E normal Program total/outcome")
	var advantage := base.duplicate(true); advantage.stance = "advantage"
	var advantaged := Rules.compute_result(advantage, [3, 18])
	_check(advantaged.selected_roll == 18, "E advantage selects high")
	var disadvantage := base.duplicate(true); disadvantage.stance = "disadvantage"
	var disadvantaged := Rules.compute_result(disadvantage, [19, 4])
	_check(disadvantaged.selected_roll == 4 and disadvantaged.outcome == "failure", "E disadvantage selects low")
	var provider_proposal := base.duplicate(true)
	provider_proposal.erase("action_id")
	var fake := {"decision": "CHECK_REQUIRED", "proposal": provider_proposal}
	fake.proposal["roll"] = 20
	_check(not Rules.validate_envelope(fake, "a").success, "E model fake roll/outcome cannot enter authority")
	var invalid := base.duplicate(true); invalid.dc = 31
	_check(not Rules.validate_proposal(invalid, "a").success, "E DC boundary fails before RNG")


func _test_retry_restart_and_no_check() -> void:
	var case_root := _root.path_join("runtime-han")
	var created := FinalCreate.new(_library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games")).create_or_resume(
		"han-runtime", _composition("world.han_end.unsettled_realm", "t0-208-red-cliffs-eve", "character.han_end.liu_bei", true)
	)
	_check(created.success, "G Han Expansion Game created")
	if not created.success:
		return
	var runtime := GameRuntime.new()
	_check(runtime.open_existing_game(String(created.database_path)).success, "G Han Game existing-only open")
	var first_failure_stub := StubAdapter.new()
	var first_failure_rng := DeterministicRng.new([20])
	var first_failure := Adjudication.new(runtime, first_failure_stub, first_failure_rng)
	root.add_child(first_failure)
	first_failure.start_action("han-provider-fail", "我尝试冒险渡过激流。")
	first_failure_stub.simulate_failed("transport")
	_check(first_failure_rng.invocation_count == 0 and not _check_record(runtime, "han-provider-fail").success, "G case A first Provider failure creates no roll and remains retryable")
	first_failure.queue_free()
	await first_failure.tree_exited
	var stub := StubAdapter.new()
	var rng := DeterministicRng.new([2])
	var process := Adjudication.new(runtime, stub, rng)
	root.add_child(process)
	var started := process.start_action("han-risk-1", "我独自潜入敌营偷取军令。")
	_check(started.success and stub.requests.size() == 1, "G first adjudication Provider starts")
	stub.simulate_delta(JSON.stringify(_proposal("han-risk-1", 20, 0, "normal")))
	stub.simulate_completed()
	_check(rng.invocation_count == 1 and stub.requests.size() == 2, "F proposal validated/frozen before one RNG invocation and second call")
	var durable := _check_record(runtime, "han-risk-1")
	_check(durable.success and int(durable.check.raw_rolls[0]) == 2 and durable.check.outcome == "failure", "G losing Program result durable before narrative")
	stub.simulate_failed("transport")
	_check(runtime.conversation.get_durable_accepted_entries().is_empty(), "G second Provider failure accepts no Player/narrative")
	process.queue_free()
	await process.tree_exited
	runtime.close()

	var reopened := GameRuntime.new()
	_check(reopened.open_existing_game(String(created.database_path)).success, "G fresh runtime reopen after durable resolution")
	var retry_stub := StubAdapter.new()
	var retry_rng := DeterministicRng.new([20])
	var retry := Adjudication.new(reopened, retry_stub, retry_rng)
	root.add_child(retry)
	retry.start_action("han-risk-1", "我独自潜入敌营偷取军令。")
	_check(retry_stub.requests.size() == 1 and retry_rng.invocation_count == 0, "G restart skips adjudication/RNG and reuses exact result")
	var retry_request := JSON.stringify(retry_stub.requests[0])
	_check(retry_request.contains("raw_rolls") and retry_request.contains("[2]") and retry_request.contains("outcome") and retry_request.contains("failure"), "G second continuation sees exact durable losing result")
	retry_stub.simulate_delta("夜色没有掩护你的脚步，守卫截断退路；失败结果生效。")
	retry_stub.simulate_completed()
	_check(reopened.conversation.get_durable_accepted_entries().size() == 1, "G accepted result appends Player action exactly once")
	var replay_stub := StubAdapter.new()
	var replay := Adjudication.new(reopened, replay_stub, DeterministicRng.new([20]))
	root.add_child(replay)
	var replayed := replay.start_action("han-risk-1", "我独自潜入敌营偷取军令。")
	_check(replayed.success and String(replayed.status) == "already_accepted" and replay_stub.requests.is_empty(), "G duplicate accepted submit creates no second check/turn")

	var no_check_stub := StubAdapter.new()
	var no_check_rng := DeterministicRng.new([20])
	var no_check := Adjudication.new(reopened, no_check_stub, no_check_rng)
	root.add_child(no_check)
	no_check.start_action("han-safe-2", "我向身边侍从询问今日日期。")
	no_check_stub.simulate_delta(JSON.stringify({"decision": "NO_CHECK", "reason": "已知且无风险", "narrative": "侍从立即答出今日日期。"}))
	no_check_stub.simulate_completed()
	_check(no_check_stub.requests.size() == 1 and no_check_rng.invocation_count == 0, "D/G NO_CHECK is one Provider call with no RNG/check")
	_check(reopened.conversation.get_durable_accepted_entries().size() == 2, "G NO_CHECK normal narrative durable")
	reopened.close()

	var no_expansion_root := _root.path_join("runtime-none")
	var no_expansion_created := FinalCreate.new(_library, no_expansion_root.path_join("creation"), no_expansion_root.path_join("library"), no_expansion_root.path_join("games")).create_or_resume(
		"none-runtime", _composition("world.han_end.unsettled_realm", "t0-208-red-cliffs-eve", "character.han_end.liu_bei", false)
	)
	var ordinary := GameRuntime.new()
	ordinary.open_existing_game(String(no_expansion_created.database_path))
	var ordinary_stub := StubAdapter.new()
	var absent := Adjudication.new(ordinary, ordinary_stub, DeterministicRng.new([1]))
	root.add_child(absent)
	var absent_result := absent.start_action("ordinary", "我查看江面。")
	_check(not absent_result.success and String(absent_result.code) == "capability_absent" and ordinary_stub.requests.is_empty(), "D no Expansion never silently enables d20")
	ordinary.close()


func _test_cross_world_binding() -> void:
	var composition := _composition("world.ashtervia.afterglow", "t0-1287-public-works", "character.ashtervia.livia_selan", true)
	var review := Creation.new(_library).review_frozen_composition(composition)
	_check(review.success, "B/I same Public d20 exact generation is compatible with Afterglow/Livia")
	var case_root := _root.path_join("afterglow")
	var created := FinalCreate.new(_library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games")).create_or_resume("afterglow-runtime", composition)
	var runtime := GameRuntime.new()
	_check(created.success and runtime.open_existing_game(String(created.database_path)).success, "I Afterglow Game opens with same Host capability")
	if runtime.is_ready():
		var stub := StubAdapter.new()
		var process := Adjudication.new(runtime, stub, DeterministicRng.new([17, 5]))
		root.add_child(process)
		process.start_action("afterglow-risk", "莉维娅冒险穿越失稳的魔力管线。")
		stub.simulate_delta(JSON.stringify(_proposal("afterglow-risk", 20, 4, "advantage")))
		stub.simulate_completed()
		_check(_check_record(runtime, "afterglow-risk").success and not JSON.stringify(runtime.world_state.expansions).contains("汉末"), "I cross-world mechanism has no Han-specific Host rule")
		stub.simulate_delta("她借助经验穿过了失稳区域。")
		stub.simulate_completed()
		runtime.close()


func _proposal(action_id: String, dc: int, modifier: int, stance: String) -> Dictionary:
	return {"decision": "CHECK_REQUIRED", "proposal": {
		"intent": "完成高风险行动", "dc": dc, "modifier": modifier,
		"stance": stance, "modifier_reason": "来自 Game-local 角色事实", "situation_reason": "存在不确定性与代价",
		"success_intent": "行动达成", "failure_stakes": "暴露并承受后果",
	}}


func _composition(world_id: String, entry_id: String, player_id: String, with_expansion: bool) -> Dictionary:
	var creation := Creation.new(_library)
	creation.select_world(_generation(world_id))
	creation.select_entry(entry_id)
	if with_expansion:
		creation.set_expansion(_expansion, true)
	else:
		creation.confirm_expansion_none()
	creation.select_player(_generation(player_id))
	creation.set_settings("G4-08M1", "Light", "")
	return creation.composition_snapshot()


func _generation(asset_id: String) -> RefCounted:
	return _fixture.find_generation(_generations, asset_id)


func _check_record(runtime: RefCounted, action_id: String) -> Dictionary:
	for value: Variant in runtime.world_state.get("expansion_runtime", {}).get("public_d20_checks", []):
		if value is Dictionary and String(value.get("action_id", "")) == action_id:
			return {"success": true, "check": value}
	return {"success": false}


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-08M1 PASS | " + label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-08M1 FAIL | " + label)


func _finish() -> void:
	print("G4-08M1 | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
