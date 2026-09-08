extends "res://tests/mw015/稀疏重要经历纵向测试.gd"

const Recorder := preload("res://tests/mw018/真实整理请求记录器.gd")
const Settings := preload("res://src/运行时设置/L3_外交层/模型运行时设置公开接口.gd")
var raw_response := ""

# 两种已固定场景共用生产 Curator；初始基线与语义屏障使用桩，不额外消费真实调用。
# 场景标签/预期只用于事后验证，绝不进入模型请求或修改模型响应。
func _run() -> void:
	if not await open_fixture():
		quit(2)
		return
	var settings := Settings.new().request_snapshot()
	if not settings.success:
		teardown()
		runtime.close()
		quit(2)
		return
	teardown()
	await frames()
	semantic = Stub.new()
	worker = World.new(runtime, semantic)
	root.add_child(worker)
	curation = Recorder.new()
	curation.text_delta.connect(func(text: String) -> void: raw_response += text)
	curator = Curator.new(runtime, curation, worker)
	root.add_child(curator)
	await frames()
	var cases := [
		{"label": "routine", "player": "我向掌柜道谢，然后沿熟悉的巷道走回书院整理书页。", "gm": "掌柜朝你点点头。你沿原路回到书院，把案上的书页叠齐，继续今天的抄写。", "expected_count": 0},
		{"label": "life_turning", "player": "我决定结束为家族求取官职的道路，把多年学成的医术用于救治乡人。我亲自递交放弃荐举的文书，正式接下乡里医馆的长期职责，愿意以此作为今后的人生事业。", "gm": "你递交的文书已获确认，家族为你保留的仕途荐举正式撤回。你在医馆的任书上签下名字，接过印信，成为承担乡里诊治职责的医者。你亲自选择的新人生方向已正式开始。", "expected_count": 1}
	]
	var outcomes: Array = []
	var prompts: Array = []
	for scenario: Dictionary in cases:
		raw_response = ""
		accept(scenario.player, scenario.gm)
		await frames()
		complete(semantic, {"changes": []})
		var terminal: Dictionary = await curator.finished
		var index: int = runtime.conversation.get_durable_accepted_entries().size() - 1
		var record: Dictionary = runtime.world_state.get("information_curation", {}).get("turns", {}).get(str(index), {})
		var parsed := Parser.parse(raw_response, true)
		var raw_json: Variant = JSON.parse_string(raw_response)
		var exact_output: bool = raw_json is Dictionary and parsed.has("experiences") and record.get("result", {}).get("experiences") == raw_json.get("experiences")
		var success: bool = terminal.success and not parsed.is_empty() and parsed.experiences.size() == scenario.expected_count and exact_output
		var messages: Array = curation.requests[-1]
		prompts.append(messages[0].content)
		outcomes.append({"case": scenario.label, "terminal": terminal, "request": messages, "raw_response": raw_response,
			"normalized_result": record.get("result", {}), "projection": Safe.project_session(runtime), "exact_model_experiences_preserved": exact_output, "success": success})
		check(success, "real " + String(scenario.label) + " model result")
	check(curation.requests.size() == 2 and semantic.requests.size() == 2, "exactly two real Curator calls; World responses stubbed")
	check(prompts.size() == 2 and prompts[0] == prompts[1], "identical production system prompt for both semantic cases")
	var report := {"status": "expected_semantic_outputs" if failures == 0 else "semantic_or_provider_failure", "model": settings.request_profile.model_id,
		"real_curator_calls": curation.requests.size(), "real_world_calls": 0, "same_system_prompt": prompts[0] == prompts[1], "cases": outcomes}
	var file := FileAccess.open(directory.path_join("sparse-real.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	teardown()
	runtime.close()
	await frames()
	print("MW-015 R1 REAL status=" + String(report.status) + " real_curator_calls=" + str(report.real_curator_calls))
	quit(0 if failures == 0 else 1)
