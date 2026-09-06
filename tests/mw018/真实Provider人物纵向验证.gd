extends SceneTree

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const World := preload("res://src/世界回合/L3_外交层/世界回合公开接口.gd")
const Bridge := preload("res://src/世界回合/L3_外交层/人物身份桥公开接口.gd")
const Settings := preload("res://src/运行时设置/L3_外交层/模型运行时设置公开接口.gd")
const Curator := preload("res://src/信息整理/L3_外交层/信息整理公开接口.gd")
const Safe := preload("res://src/信息整理/L3_外交层/人物投影公开接口.gd")
const Recorder := preload("res://tests/mw018/真实整理请求记录器.gd")
var directory := ""
var raw_world := ""
var raw_curator := ""
var request: Array = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="):
			directory = arg.trim_prefix("--root=")
	if not directory.contains("mw018") or FileAccess.file_exists(directory.path_join("smoke.sqlite")):
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(directory)
	var settings := Settings.new().request_snapshot()
	if not settings.success:
		write_report({"status": "configured_provider_unavailable", "settings_status": settings.status})
		quit(2)
		return
	var runtime := Runtime.new()
	if not runtime.open_current_game(directory.path_join("smoke.sqlite")).success:
		quit(2)
		return
	# 无 frozen profile 的旧局最小夹具，Initial lane 合法 unavailable；只有本轮两次调用。
	var setup := {"player_character": {"local_character_id": "player", "source_projection": {"display_name": "旅人"}},
		"stable_npcs": [{"local_character_id": "npc-li", "role": "stable_npc", "origin": {"kind": "creation_authored"},
			"game_local_material": {"display_name": "李亭", "profile_text": "PRIVATE_NPC_CANARY：从未向玩家透露的计划。"}}]}
	if not runtime.commit_world_mutation_durably("setup", "setup-node", setup).success:
		runtime.close()
		quit(2)
		return
	var worker := World.new(runtime)
	worker.analysis_requested.connect(func(_index: int, messages: Array) -> void: request = messages)
	worker.provider_adapter.text_delta.connect(func(text: String) -> void: raw_world += text)
	root.add_child(worker)
	var recorder := Recorder.new()
	var curator := Curator.new(runtime, recorder, worker)
	recorder.text_delta.connect(func(text: String) -> void: raw_curator += text)
	root.add_child(curator)
	await process_frame
	await process_frame
	runtime.conversation.begin_turn("我请摆渡人说明身份，并约定明早渡河。")
	runtime.conversation.append_delta("沈青是渡口的摆渡人。她答应明早带你渡河，并告诉你她住在河边小屋。李亭站在你身旁，听见了这番约定。")
	if not runtime.complete_active_generation_durably().success:
		quit(2)
		return
	var terminal: Dictionary = await worker.opportunity_terminal
	var curation_terminal: Dictionary = await curator.finished
	var receipt := Bridge.current_receipt(runtime, 0)
	var cards := Safe.project_session(runtime)
	var safe_input: bool = recorder.requests.size() == 1 and not JSON.stringify(recorder.requests).contains("PRIVATE_NPC_CANARY") and not JSON.stringify(recorder.requests).contains("npc-li")
	var success: bool = terminal.success and curation_terminal.success and not receipt.is_empty() and not cards.is_empty() and safe_input and worker.analysis_attempt_count == 1
	var report := {"status": "resolved_card" if success else "unresolved_or_failed", "model": settings.request_profile.model_id,
		"world_terminal": terminal, "curation_terminal": curation_terminal, "world_request": request,
		"world_response": raw_world, "curator_requests": recorder.requests, "curator_response": raw_curator,
		"receipt": receipt, "cards": cards, "safe_input": safe_input,
		"world_attempts": worker.analysis_attempt_count, "curator_attempts": recorder.requests.size(),
		"accepted_count": runtime.conversation.get_durable_accepted_entries().size()}
	curator.shutdown()
	worker.shutdown()
	curator.queue_free()
	worker.queue_free()
	runtime.close()
	await process_frame
	write_report(report)
	print("MW-018 REAL status=" + String(report.status) + " World=" + str(report.world_attempts) + " Curator=" + str(report.curator_attempts))
	quit(0 if success else 1)

func write_report(report: Dictionary) -> void:
	var file := FileAccess.open(directory.path_join("people-smoke.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
