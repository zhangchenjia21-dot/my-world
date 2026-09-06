extends SceneTree

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const World := preload("res://src/世界回合/L3_外交层/世界回合公开接口.gd")
const Bridge := preload("res://src/世界回合/L3_外交层/人物身份桥公开接口.gd")
const Settings := preload("res://src/运行时设置/L3_外交层/模型运行时设置公开接口.gd")
var directory := ""
var raw_output := ""
var request: Array = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="):
			directory = arg.trim_prefix("--root=")
	if not directory.contains("mw017") or FileAccess.file_exists(directory.path_join("smoke.sqlite")):
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
	var setup := {"player_character": {"local_character_id": "player", "source_projection": {"display_name": "旅人"}},
		"stable_npcs": [{"local_character_id": "npc-li", "role": "stable_npc", "origin": {"kind": "creation_authored"},
			"game_local_material": {"display_name": "李亭", "profile_text": "不向身份桥输出的任务自有材料。"}}]}
	if not runtime.commit_world_mutation_durably("setup", "setup-node", setup).success:
		runtime.close()
		quit(2)
		return
	var worker := World.new(runtime)
	worker.analysis_requested.connect(func(_index: int, messages: Array) -> void: request = messages)
	worker.provider_adapter.text_delta.connect(func(text: String) -> void: raw_output += text)
	root.add_child(worker)
	runtime.conversation.begin_turn("我请摆渡人说明身份，并约定明早渡河。")
	runtime.conversation.append_delta("沈青是渡口的摆渡人。她答应明早带你渡河，并告诉你她住在河边小屋。李亭站在你身旁，听见了这番约定。")
	if not runtime.complete_active_generation_durably().success:
		worker.shutdown()
		worker.queue_free()
		runtime.close()
		quit(2)
		return
	var terminal: Dictionary = await worker.opportunity_terminal
	var receipt := Bridge.current_receipt(runtime, 0)
	var status := "resolved" if not receipt.is_empty() and not receipt.bindings.is_empty() else "unresolved" if terminal.success else "provider_or_semantic_failure"
	var report := {"status": status, "model": settings.request_profile.model_id, "terminal": terminal,
		"request": request, "raw_response": raw_output, "receipt": receipt,
		"evidence": Bridge.request_evidence(runtime, 0), "attempt_count": worker.analysis_attempt_count,
		"accepted_count": runtime.conversation.get_durable_accepted_entries().size()}
	worker.shutdown()
	worker.queue_free()
	runtime.close()
	await process_frame
	write_report(report)
	print("MW-017 REAL status=" + status + " attempts=1 model=" + String(settings.request_profile.model_id))
	quit(0 if status == "resolved" else 1)

func write_report(report: Dictionary) -> void:
	var file := FileAccess.open(directory.path_join("identity-smoke.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
