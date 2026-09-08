extends "res://tests/mw025/角色推荐反馈纵向测试.gd"

const RealProvider := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")
var response := ""
var terminal: Dictionary = {}

# 两个固定 Character 的同场景比较；只供人工观察，无语义评分或期望人格输出。
func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="): directory = arg.trim_prefix("--root=")
	if not directory.contains("mw025"): quit(2); return
	DirAccess.make_dir_recursive_absolute(directory)
	var characters := [
		{"headline": "耐心倾听的行医旅人", "summary": "习惯先理解他人处境，重视照顾与平等交流。对陌生事务较谨慎，也愿意练习主动表达。", "groups": []},
		{"headline": "好奇直率的游学旅人", "summary": "喜欢亲自探索陌生事物，常主动提问和尝试新路线。重视自主，也在学习耐心听取他人意见。", "groups": []}
	]
	var outcomes: Array = []
	for i: int in range(characters.size()):
		runtime = Runtime.new()
		check(runtime.open_current_game(directory.path_join("real-%d.sqlite" % i)).success, "isolated real fixture")
		check(runtime.commit_world_mutation_durably("setup", "setup-node", setup()).success, "same scene setup")
		compose()
		await frames()
		complete(curation, {"character": characters[i], "experiences": []})
		await frames()
		accept("我向船工问候，询问渡口今天的情况。", "船工说雨刚停，下一班渡船还有一阵才出发。小亭里有一位整理草药的老人，岸边一条石阶通向河堤。")
		response = ""
		terminal = {}
		var adapter := RealProvider.new()
		adapter.text_delta.connect(func(text: String) -> void: response += text)
		recommender = Recommender.new(runtime, adapter)
		recommender.diagnostic_terminal.connect(func(value: Dictionary) -> void: terminal = value)
		root.add_child(recommender)
		var started := Time.get_ticks_msec()
		while terminal.is_empty() and Time.get_ticks_msec() - started < 150000:
			await process_frame
		var model: String = adapter.last_request_snapshot.get("model_id", "")
		outcomes.append({"case": i, "current_character": characters[i], "terminal": terminal.get("terminal", "bounded_timeout"), "status": terminal.get("status", ""), "model": model, "network_attempts": adapter.network_attempt_count, "elapsed_ms": Time.get_ticks_msec()-started, "request": adapter.last_request_payload.get("messages", []), "response": response, "actions": recommender.snapshot().actions})
		var success: bool = recommender.snapshot().actions.size() == 5
		detach(); teardown(); runtime.close()
		await frames()
		if not success: break
	var file := FileAccess.open(directory.path_join("real-character-recommendations.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(outcomes, "\t"))
	file.close()
	print("MW025 REAL calls=" + str(outcomes.size()))
	quit(0 if outcomes.size() == 2 and outcomes.all(func(item: Dictionary) -> bool: return item.terminal == "ready") else 1)
