extends SceneTree

const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Opening := preload("res://src/首次开场/L3_外交层/首次开场公开接口.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")
const StubAdapter := preload("res://tests/g4_07a/首次开场桩适配器.gd")

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
	if _root.find("g4_07a") < 0:
		return _finish_with_failure("必须提供 task-owned g4_07a root")
	_fixture.reset_directory(_root)
	_source_root = _root.path_join("source-library")
	var installed := _fixture.install_real_assets(_source_root)
	_check(installed.success, "production Source Library installs frozen 2 World + 6 Character")
	if not installed.success:
		return _finish()
	_library = installed.library
	_generations = installed.installed
	await _test_han_success_reopen_and_source_drift()
	await _test_afterglow_distinct_context()
	await _test_no_entry()
	await _test_failure_cancel_retry()
	_test_existing_only_failures()
	_finish()


func _test_han_success_reopen_and_source_drift() -> void:
	var case_root := _case_root("han")
	var composition := _composition("world.han_end.unsettled_realm", "t0-208-red-cliffs-eve", "character.han_end.liu_bei", ["character.han_end.sun_quan"], "赤壁前夕", "Light", "从江夏的雨夜开始。")
	var created: Dictionary = _creator(case_root).create_or_resume("g4-07a-han", composition)
	_check(created.success, "Han Game created through production G4-06")
	if not created.success:
		return

	# Game 已创建后发布一个带唯一 marker 的 newer current；Opening 不得读取它。
	var newer_path := case_root.path_join("newer-current")
	_fixture.copy_package("res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定", newer_path)
	var source := _fixture.read_json(newer_path.path_join("source.json"))
	source.version = "%s-g4-07a-newer" % String(source.version)
	source.catalog_summary = "MUTABLE_SOURCE_CURRENT_MUST_NOT_ENTER_OPENING"
	_fixture.write_json(newer_path.path_join("source.json"), source)
	var newer: Dictionary = _library.install_world_pack(newer_path)
	_check(newer.success, "Source current can change after durable Game creation")

	var runtime := Runtime.new()
	_check(runtime.open_existing_game(String(created.database_path)).success, "Han exact Game existing-only opens")
	var stub := StubAdapter.new()
	var opening := Opening.new(runtime, stub)
	root.add_child(opening)
	await process_frame
	var started: Dictionary = opening.start_first_opening()
	_check(started.success and String(started.status) == "streaming", "Han first GM-only Opening starts")
	var serialized := JSON.stringify(opening.last_request_messages)
	_check(opening.last_request_messages.size() == 1 and String(opening.last_request_messages[0].role) == "system", "first Opening request has no fake Player message")
	_check(serialized.contains("t0-208-red-cliffs-eve") and serialized.contains("e208-snapshot") and serialized.contains("han-208"), "Han Provider-visible context contains exact selected early Entry/profile")
	_check(not serialized.contains("e220-snapshot") and not serialized.contains("liu-bei-220") and not serialized.contains("MUTABLE_SOURCE_CURRENT_MUST_NOT_ENTER_OPENING"), "Han excludes future/unselected semantics and mutable Source current")
	_check(serialized.contains("Membership alone does NOT mean opening presence") and serialized.contains("孙权"), "Guaranteed NPC is canonical context without forced convergence semantics")
	stub.simulate_delta("江夏的雨落在檐瓦上。")
	stub.simulate_delta("军帐之外，江风带来尚未定局的消息。")
	stub.simulate_completed()
	await process_frame
	var accepted: Array = runtime.conversation.get_durable_accepted_entries()
	_check(accepted.size() == 1 and String(accepted[0].player_text).is_empty() and String(accepted[0].gm_text).contains("江夏"), "Han accepts exactly one durable GM-only Opening")
	_check(String(opening.start_first_opening().status) == "already_opened" and stub.requests.size() == 1, "accepted Game cannot auto-generate second first Opening")
	var exact_game_id := runtime.game_id
	opening.queue_free()
	runtime.close()
	await process_frame

	var reopened := Runtime.new()
	var reopen_result: Dictionary = reopened.open_existing_game(String(created.database_path))
	_check(reopen_result.success and reopened.game_id == exact_game_id, "close/reopen restores exact same Game")
	var durable: Array = reopened.conversation.get_durable_accepted_entries()
	_check(durable.size() == 1 and String(durable[0].player_text).is_empty(), "reopen restores one GM-only Opening exactly once")
	reopened.conversation.begin_turn("我走出军帐查看江面。")
	var reopened_opening := Opening.new(reopened, StubAdapter.new())
	root.add_child(reopened_opening)
	var continuation_result: Dictionary = reopened_opening.assemble_continuation_messages()
	var continuation := continuation_result.get("messages", []) as Array
	_check(continuation_result.success and _roles(continuation) == ["system", "assistant", "user"], "next continuation includes durable Opening without empty fake user message")
	_check(JSON.stringify(continuation).contains("e208-snapshot") and JSON.stringify(continuation).contains("我走出军帐查看江面"), "next continuation rebuilds from durable World truth plus durable Conversation")
	reopened.conversation.cancel_generation()
	reopened_opening.queue_free()
	reopened.close()


func _test_afterglow_distinct_context() -> void:
	var case_root := _case_root("afterglow")
	var composition := _composition("world.ashtervia.afterglow", "t0-1287-public-works", "character.ashtervia.livia_selan", ["character.ashtervia.adrian_wilk", "character.ashtervia.duen_stonescar"], "公共工程余波", "Narrative", "保留角色各自的信息边界。")
	var created: Dictionary = _creator(case_root).create_or_resume("g4-07a-afterglow", composition)
	_check(created.success, "Afterglow Game created through production G4-06")
	if not created.success:
		return
	var runtime := Runtime.new()
	_check(runtime.open_existing_game(String(created.database_path)).success, "Afterglow existing-only opens")
	var stub := StubAdapter.new()
	var opening := Opening.new(runtime, stub)
	root.add_child(opening)
	await process_frame
	_check(opening.start_first_opening().success, "Afterglow first Opening starts")
	var serialized := JSON.stringify(opening.last_request_messages)
	_check(serialized.contains("t0-1287-public-works") and serialized.contains("莉维娅") and serialized.contains("阿德里安") and serialized.contains("杜恩"), "Afterglow transports distinct exact World/Player/cast semantics")
	_check(int(opening.last_context_stats.world_sections) > 5 and int(opening.last_context_stats.player_sections) > 0 and int(opening.last_context_stats.npc_sections) > 0, "Afterglow context is bounded but rich, not one-line summaries")
	stub.simulate_delta("奥维斯塔的石渠仍在夜色里低鸣，潮湿的风穿过未完工的拱门。")
	stub.simulate_completed()
	await process_frame
	_check(runtime.conversation.get_durable_accepted_entries().size() == 1, "Afterglow Opening durable exactly once")
	opening.queue_free()
	runtime.close()


func _test_no_entry() -> void:
	var case_root := _case_root("no-entry")
	var composition := _composition("world.han_end.unsettled_realm", "", "character.han_end.liu_bei", [], "无预选年代", "Light", "只使用顶层起始语义。")
	var created: Dictionary = _creator(case_root).create_or_resume("g4-07a-no-entry", composition)
	_check(created.success, "no-Entry Game created through production G4-06")
	if not created.success:
		return
	var runtime := Runtime.new()
	_check(runtime.open_existing_game(String(created.database_path)).success and runtime.world_state.selected_entry_id == null, "durable no-Entry remains explicit null")
	var stub := StubAdapter.new()
	var opening := Opening.new(runtime, stub)
	root.add_child(opening)
	await process_frame
	_check(opening.start_first_opening().success, "no-Entry Opening starts")
	var serialized := JSON.stringify(opening.last_request_messages)
	_check(serialized.contains("Selected Entry: none") and serialized.contains("Exact selected profile: none"), "Provider-visible no-Entry/profile state stays explicit")
	_check(not serialized.contains("t0-208-red-cliffs-eve") and not serialized.contains("han-208"), "runtime does not infer default Entry/profile/year")
	stub.simulate_delta("没有预设年代替玩家作出选择。")
	stub.simulate_completed()
	await process_frame
	_check(runtime.conversation.get_durable_accepted_entries().size() == 1, "no-Entry Opening accepts normally")
	opening.queue_free()
	runtime.close()


func _test_failure_cancel_retry() -> void:
	var failure_root := _case_root("failure-retry")
	var created: Dictionary = _creator(failure_root).create_or_resume("g4-07a-failure", _composition("world.han_end.unsettled_realm", "t0-208-red-cliffs-eve", "character.han_end.liu_bei", [], "失败重试", "Light", ""))
	var runtime := Runtime.new()
	_check(created.success and runtime.open_existing_game(String(created.database_path)).success, "failure/retry Game opens")
	var stub := StubAdapter.new()
	var opening := Opening.new(runtime, stub)
	root.add_child(opening)
	await process_frame
	opening.start_first_opening()
	stub.simulate_delta("不得接受的 partial")
	stub.simulate_failed("transport")
	await process_frame
	_check(runtime.conversation.get_durable_accepted_entries().is_empty(), "Provider failure leaves zero accepted Opening")
	_check(opening.start_first_opening().success, "failure permits clean retry")
	stub.simulate_delta("重试后唯一接受的 Opening")
	stub.simulate_completed()
	await process_frame
	_check(runtime.conversation.get_durable_accepted_entries().size() == 1 and String(runtime.conversation.get_durable_accepted_entries()[0].gm_text) == "重试后唯一接受的 Opening", "retry accepts only successful attempt")
	opening.queue_free()
	runtime.close()

	var cancel_root := _case_root("cancel-retry")
	var cancelled_game: Dictionary = _creator(cancel_root).create_or_resume("g4-07a-cancel", _composition("world.han_end.unsettled_realm", "t0-208-red-cliffs-eve", "character.han_end.liu_bei", [], "取消重试", "Light", ""))
	var cancel_runtime := Runtime.new()
	_check(cancelled_game.success and cancel_runtime.open_existing_game(String(cancelled_game.database_path)).success, "cancel/retry Game opens")
	var cancel_stub := StubAdapter.new()
	var cancel_opening := Opening.new(cancel_runtime, cancel_stub)
	root.add_child(cancel_opening)
	await process_frame
	cancel_opening.start_first_opening()
	cancel_stub.simulate_delta("取消前 partial")
	cancel_opening.cancel()
	await process_frame
	_check(cancel_runtime.conversation.get_durable_accepted_entries().is_empty(), "cancel leaves zero accepted Opening")
	_check(cancel_opening.start_first_opening().success, "cancel permits clean retry")
	cancel_stub.simulate_delta("取消后的唯一 Opening")
	cancel_stub.simulate_completed()
	await process_frame
	_check(cancel_runtime.conversation.get_durable_accepted_entries().size() == 1, "cancel retry accepts exactly once")
	cancel_opening.queue_free()
	cancel_runtime.close()


func _test_existing_only_failures() -> void:
	var missing_path := _case_root("startup-failure").path_join("missing.sqlite")
	var missing := Runtime.new()
	_check(not missing.open_existing_game(missing_path).success and not FileAccess.file_exists(missing_path), "missing DB fails loud without fallback creation")
	var corrupt_path := missing_path.get_base_dir().path_join("corrupt.sqlite")
	var file := FileAccess.open(corrupt_path, FileAccess.WRITE)
	file.store_string("not sqlite")
	file.close()
	var corrupt := Runtime.new()
	_check(not corrupt.open_existing_game(corrupt_path).success, "corrupt existing DB fails loud")


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


func _creator(case_root: String) -> RefCounted:
	return FinalCreate.new(_library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games"))


func _generation(asset_id: String) -> RefCounted:
	return _fixture.find_generation(_generations, asset_id)


func _case_root(name: String) -> String:
	var path := _root.path_join(name)
	DirAccess.make_dir_recursive_absolute(path)
	return path


func _roles(messages: Array) -> Array:
	var result: Array = []
	for message: Dictionary in messages:
		result.append(String(message.get("role", "")))
	return result


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-07A FOCUSED PASS | %s" % label)
	else:
		_failures += 1
		push_error("G4-07A FOCUSED FAIL | %s" % label)


func _finish_with_failure(message: String) -> void:
	_check(false, message)
	_finish()


func _finish() -> void:
	print("G4-07A FOCUSED | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
