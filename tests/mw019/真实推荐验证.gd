extends "res://tests/mw019/行动推荐纵向测试.gd"

const Recorder := preload("res://tests/mw018/真实整理请求记录器.gd")
var evidence: Dictionary = {"task": "MW-019 R1", "attempts": [], "request_count": 0,
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
	runtime.conversation.append_delta("你想查阅旧渡口的档案，来到城里的档案馆门外。门房告诉你，一般流程是先递交查阅申请，再核对身份、登记，最后等馆员取卷。你尚未递交申请。门旁贴着公开的查阅须知，柜台边有几位访客排队，院中长椅上坐着一位刚出来的旅人。你不知道馆内具体有哪些旧渡口档案，也没有获准入内。")
	check(runtime.complete_active_generation_durably().success, "synthetic opening durably accepted")
	await capture_attempt(recorder, "archive-opening-sequential-plan-trap")
	# 第二个场景预先固定，无论第一份格式是否成功都只运行一次，不修提示、不重试。
	raw_response = ""
	accept("我向门房询问，不递交申请时能看到哪些公开信息？", "门房指着墙上的查阅须知，说公开目录放在门外的小架子上，可以自行翻看。申请表今天仍能领取，但是否准许查阅要由馆员审核。柜台前的队伍缓慢往前移动，长椅上的旅人收起纸笔，抬头看了看天色。")
	await capture_attempt(recorder, "archive-public-directory-turn")
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
