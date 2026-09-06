extends SceneTree
const Library := preload("res://src/source/L3_外交层/Source库公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Curator := preload("res://src/信息整理/L3_外交层/信息整理公开接口.gd")
const SafeView := preload("res://src/信息整理/L3_外交层/角色经历投影公开接口.gd")
const Settings := preload("res://src/运行时设置/L3_外交层/模型运行时设置公开接口.gd")
const Stub := preload("res://tests/g5_01/世界回合语义桩适配器.gd")
var task_root := ""
var raw_output := ""
var modes: Array = ["fresh", "existing"]

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="):
			task_root = arg.trim_prefix("--root=")
	if not task_root.contains("mw015r2"):
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(task_root)
	var library := Library.new()
	var world := library.get_current_world("world.han_end.unsettled_realm")
	var player := library.get_current_character("character.han_end.zhang_chen")
	if not world.success or not player.success:
		push_error("Real installed Source unavailable")
		quit(2)
		return
	var settings := Settings.new().request_snapshot()
	if not settings.success:
		quit(2)
		return
	var report: Array = []
	var success := true
	for mode: String in modes:
		var creation := Creation.new(library)
		creation.select_world(world.generation)
		creation.select_entry("t0-208-red-cliffs-eve")
		creation.confirm_expansion_none()
		creation.select_player(player.generation)
		creation.set_settings("MW-015 R2 isolated " + mode, "Narrative", "")
		var created := FinalCreate.new(library, task_root.path_join("creation"), task_root.path_join("library"), task_root.path_join("games")).create_or_resume("mw015r2-" + mode, creation.composition_snapshot())
		if not created.success:
			quit(2)
			return
		var runtime := Runtime.new()
		if not runtime.open_existing_game(created.database_path).success:
			quit(2)
			return
		if mode == "existing":
			runtime.close()
			runtime = Runtime.new()
			if not runtime.open_existing_game(created.database_path).success:
				quit(2)
				return
		raw_output = ""
		var worker := Curator.new(runtime)
		worker.provider_adapter.text_delta.connect(func(delta: String) -> void: raw_output += delta)
		var input := worker._profile()
		root.add_child(worker)
		var terminal: Dictionary = await worker.finished
		var projection := SafeView.project_session(runtime)
		success = success and terminal.success and not projection.character.groups.is_empty() and runtime.conversation.get_durable_accepted_entries().is_empty()
		report.append({"mode": mode, "raw_response": raw_output, "status": terminal, "input": input, "projection": projection, "model": settings.request_profile.model_id, "accepted_count": runtime.conversation.get_durable_accepted_entries().size()})
		print("MW-015 R2 REAL " + mode + " " + JSON.stringify(terminal))
		worker.shutdown()
		worker.queue_free()
		runtime.close()
		await process_frame
		runtime = Runtime.new()
		if not runtime.open_existing_game(created.database_path).success:
			quit(2)
			return
		var stub := Stub.new()
		var reopened := Curator.new(runtime, stub)
		root.add_child(reopened)
		await process_frame
		await process_frame
		var reused: bool = stub.requests.is_empty() and SafeView.project_session(runtime) == projection
		report[-1]["reopen_no_call_same_projection"] = reused
		success = success and reused
		reopened.shutdown()
		reopened.queue_free()
		runtime.close()
		await process_frame
	var output := FileAccess.open(task_root.path_join("initial-semantic-smoke.json"), FileAccess.WRITE)
	output.store_string(JSON.stringify(report, "\t"))
	output.close()
	quit(0 if success else 1)
