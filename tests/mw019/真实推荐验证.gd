extends "res://tests/mw019/行动推荐纵向测试.gd"

const Recorder := preload("res://tests/mw018/真实整理请求记录器.gd")
var evidence: Dictionary = {"task": "MW-019", "attempts": [], "request_count": 0,
	"fixture": "Task-owned synthetic accepted player-visible conversation; only recommendations call the real configured model."}
var raw_response := ""

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="):
			directory = arg.trim_prefix("--root=")
	if not directory.contains("mw019"):
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(directory)
	runtime = Runtime.new()
	check(runtime.open_current_game(directory.path_join("real-recommendation.sqlite")).success, "isolated runtime")
	var recorder := Recorder.new()
	var settings: Dictionary = recorder.runtime_settings.request_snapshot()
	if not settings.success:
		quit(2)
		return
	evidence["request_profile"] = settings.request_profile
	recommender = Recommender.new(runtime, recorder)
	recorder.text_delta.connect(func(text: String) -> void: raw_response += text)
	root.add_child(recommender)
	await frames()
	runtime.conversation.begin_gm_opening()
	runtime.conversation.append_delta("雨刚停，你来到一座河畔小城的南门。城门旁的守卫正收起蓑衣，河边的小亭里坐着一位粮商。粮商自称陈安，说他明早要去渡口接货，愿意给你指路。河堤上有积水，远处的渡口亮着一盏灯。你还不知道今晚是否有船过河。")
	check(runtime.complete_active_generation_durably().success, "synthetic opening durably accepted")
	await capture_attempt(recorder, "opening")
	if recommender.snapshot().actions.size() == 5:
		raw_response = ""
		accept("我向守卫询问今晚渡口是否还开船。", "守卫告诉你，最后一班渡船通常在入夜后开出，但今天的雨耽搁了船期。他指着河边的灯，说那是渡口的候船棚，你可以到那里问问。陈安还坐在小亭里擦拭鞋上的泥。")
		await capture_attempt(recorder, "normal-turn")
	evidence.request_count = recorder.requests.size()
	evidence["successful_requests"] = evidence.attempts.filter(func(a: Dictionary) -> bool: return a.actions.size() == 5).size()
	var accepted: Array = runtime.conversation.get_durable_accepted_entries()
	evidence["accepted_entries_after"] = accepted
	var latest_result: Dictionary = recommender.snapshot()
	evidence["final_status"] = latest_result.status
	FileAccess.open(directory.path_join("real-evidence.json"), FileAccess.WRITE).store_string(JSON.stringify(evidence, "  ") + "\n")
	recommender.shutdown()
	recommender.queue_free()
	runtime.close()
	await frames()
	print("MW-019 REAL requests=%d successes=%d" % [evidence.request_count, evidence.successful_requests])
	quit(0 if evidence.successful_requests > 0 and evidence.request_count <= 2 else 1)

func capture_attempt(recorder: Node, label: String) -> void:
	var started := Time.get_ticks_msec()
	await frames()
	while recommender.snapshot().status == "loading" and Time.get_ticks_msec() - started < 125000:
		await create_timer(0.1).timeout
	var snapshot: Dictionary = recommender.snapshot()
	evidence.attempts.append({"label": label, "request": recorder.requests[-1], "raw_response": raw_response,
		"status": snapshot.status, "actions": snapshot.actions, "elapsed_ms": Time.get_ticks_msec() - started})
	print("MW-019 REAL %s status=%s count=%d" % [label, snapshot.status, snapshot.actions.size()])
