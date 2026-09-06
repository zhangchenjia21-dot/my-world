extends SceneTree

const Library := preload("res://src/source/L3_外交层/Source库公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Curator := preload("res://src/信息整理/L3_外交层/信息整理公开接口.gd")
const SafeView := preload("res://src/信息整理/L3_外交层/角色经历投影公开接口.gd")
const Settings := preload("res://src/运行时设置/L3_外交层/模型运行时设置公开接口.gd")

const SCENARIOS := [
	{"name": "A", "player": "曹操这人确实比我想象中有意思。", "narrative": "曹操听后笑了笑，继续谈起地方风物。你们只是闲聊，你没有许下承诺，也没有决定加入他的阵营。"},
	{"name": "B", "player": "我拿过那份常见的仓储文书，试着不靠旁人帮助把它读完。", "narrative": "此前持续向书吏请教并练习隶书的功夫终于有了结果。你独立读出了这份常见文书，核对后主要内容无误。如今你已能阅读日常常见隶书文书，但生僻字和复杂公文仍需要请教，尚不能说已通晓汉代文书。"},
	{"name": "C", "player": "我已经想清楚了。我决定长期留下来为刘备做事，承担文书整理的职责，认真学习这个时代，而不再只是暂时借宿。", "narrative": "刘备接受了你的明确请求，准你长期留下协助文书整理。你的职责从临时寄居者转为受接纳的办事成员，具体事务仍由上级逐件交代。这是你自己作出的长期方向选择，并不意味着你已获得高官厚禄，也不预先决定未来的一切。"},
]
var task_root := ""
var report: Array = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="):
			task_root = arg.trim_prefix("--root=")
	if not task_root.contains("mw014"):
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(task_root)
	# 只读真实已安装 Source 代次，非桩输出/合成 Character fixture；新 Game 全部隔离。
	var library := Library.new()
	var world := library.get_current_world("world.han_end.unsettled_realm")
	var player := library.get_current_character("character.han_end.zhang_chen")
	if not world.success or not player.success:
		push_error("Real installed World/Zhang Chen Source unavailable")
		quit(2)
		return
	var profile := Settings.new().request_snapshot()
	if not profile.success:
		quit(2)
		return
	print("MW-014 REAL selected_model=" + String(profile.request_profile.model_id))
	for scenario: Dictionary in SCENARIOS:
		var creation := Creation.new(library)
		creation.select_world(world.generation)
		creation.select_entry("t0-208-red-cliffs-eve")
		creation.confirm_expansion_none()
		creation.select_player(player.generation)
		creation.set_settings("MW-014 real " + scenario.name, "Narrative", "")
		var created := FinalCreate.new(library, task_root.path_join("creation"), task_root.path_join("library"), task_root.path_join("games")).create_or_resume("mw014-" + scenario.name, creation.composition_snapshot())
		if not created.success:
			push_error("isolated Final Create failed")
			quit(2)
			return
		var runtime := Runtime.new()
		if not runtime.open_existing_game(created.database_path).success:
			quit(2)
			return
		var worker := Curator.new(runtime)
		root.add_child(worker)
		await process_frame
		# 明示 smoke 示例写入真实 accepted-turn seam；本脚本不冒充 GM Narrative 生成 UAT。
		runtime.conversation.begin_turn(scenario.player)
		runtime.conversation.append_delta(scenario.narrative)
		if not runtime.complete_active_generation_durably().success:
			quit(2)
			return
		var terminal: Dictionary = await worker.finished
		var projection := SafeView.project_session(runtime)
		report.append({"scenario": scenario, "status": terminal, "projection": projection, "model": profile.request_profile.model_id})
		print("MW-014 REAL " + scenario.name + " " + JSON.stringify(terminal))
		worker.shutdown()
		worker.queue_free()
		runtime.close()
		await process_frame
	var output := FileAccess.open(task_root.path_join("semantic-smoke.json"), FileAccess.WRITE)
	output.store_string(JSON.stringify(report, "\t"))
	output.close()
	var success := true
	for result: Dictionary in report:
		success = success and result.status.success
	quit(0 if success else 1)
