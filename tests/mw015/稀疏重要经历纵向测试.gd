extends "res://tests/mw018/人物整理卡片纵向测试.gd"

# 真实 Runtime/SQLite 接收同一 accepted 文本的两种模型决定，验证 Program 不判意义。
func _run() -> void:
	if not await open_fixture():
		quit(2)
		return
	var initial := Safe.project_session(runtime)
	var before: Dictionary = runtime.create_save_point("before curation")
	accept("我整理旧日笔记。", "你合上笔记，安静地坐了一会儿。")
	await frames()
	complete(semantic, {"changes": []})
	await frames()
	var first_prompt: String = curation.requests[-1][0].content
	complete(curation, answer([]))
	await frames()
	check(curator.last_result.success and Safe.project_session(runtime) == initial, "ordinary no-op succeeds without invented milestone")
	var no_op_id: String = runtime.world_state.information_curation.turns["0"].id
	curator.retry_pending()
	await frames()
	check(curation.requests.size() == 2 and runtime.world_state.information_curation.turns["0"].id == no_op_id, "successful empty result is durable/idempotent")
	check(runtime.restore_save_point(before.save_id).success, "Restore before decision")
	accept("我整理旧日笔记。", "你合上笔记，安静地坐了一会儿。")
	await frames()
	complete(semantic, {"changes": []})
	await frames()
	check(curation.requests[-1][0].content == first_prompt, "same production prompt, no event-dependent instruction routing")
	var milestone := {"title": "重新选择自己的路", "description": "回望旧日笔记，你确认了今后愿意为之承担责任的人生方向。"}
	complete(curation, {"character": null, "experiences": [milestone], "people_updates": []})
	await frames()
	var projected := Safe.project_session(runtime)
	check(projected.character == initial.character and projected.important_experiences.size() == 1, "same quiet accepted text may retain model-selected milestone with Character unchanged")
	check(projected.important_experiences[0].description == milestone.description, "Program stores model wording without significance rewrite")
	var milestone_save: Dictionary = runtime.create_save_point("milestone")
	var character: Dictionary = initial.character.duplicate(true)
	character.summary = "我在书院抄书，已掌握医术，正更清晰地认识自己的能力。"
	accept("我把掌握的医术重新梳理一遍。", "你清楚了已有的本领，整理好笔记。")
	await frames()
	complete(semantic, {"changes": []})
	await frames()
	complete(curation, {"character": character, "experiences": [], "people_updates": []})
	await frames()
	projected = Safe.project_session(runtime)
	check(projected.character == character and projected.important_experiences.size() == 1, "Character-only change neither requires milestone nor removes prior experience")
	var saved: Dictionary = runtime.create_save_point("character-only")
	var exact_owner: Dictionary = runtime.world_state.information_curation.duplicate(true)
	var db: String = runtime.database_path
	teardown()
	runtime.close()
	runtime = Runtime.new()
	check(runtime.open_existing_game(db).success, "reopen sparse mixed history")
	compose()
	await frames()
	check(curation.requests.is_empty() and semantic.requests.is_empty() and runtime.world_state.information_curation == exact_owner, "reopen keeps historical records byte-equivalent with zero backfill calls")
	check(Safe.project_session(runtime) == projected, "reopen equivalent Character and milestones")
	check(runtime.restore_save_point(milestone_save.save_id).success, "Restore earlier milestone snapshot")
	check(Safe.project_session(runtime).character == initial.character and Safe.project_session(runtime).important_experiences.size() == 1, "Restore separates later Character update from earlier milestone")
	runtime.conversation.retry_or_regenerate_latest()
	check(Safe.project_session(runtime).important_experiences.size() == 1, "provisional regeneration preserves accepted milestone")
	runtime.conversation.append_delta("你只是收好了笔记，随后继续休息。")
	check(runtime.complete_active_generation_durably().success, "regenerated turn accepted")
	check(Safe.project_session(runtime).important_experiences.is_empty(), "accepted replacement invalidates displaced milestone")
	await frames()
	complete(semantic, {"changes": []})
	await frames()
	complete(curation, answer([]))
	await frames()
	check(runtime.restore_save_point(saved.save_id).success and Safe.project_session(runtime) == projected, "Restore returns exact earlier independent outputs")
	# 格式失败仍不变更既有投影；新语义不放宽 parser，也不清洗旧经历。
	accept("我休息。", "灯火渐暗。")
	await frames()
	complete(semantic, {"changes": []})
	await frames()
	complete(curation, {"character": null, "experiences": "not-an-array", "people_updates": []})
	await frames()
	check(not curator.last_result.success and Safe.project_session(runtime) == projected, "malformed response leaves earlier curation intact")
	teardown()
	runtime.close()
	await frames()
	print("MW-015 R1 FOCUSED checks=%d failures=%d" % [checks, failures])
	quit(0 if failures == 0 else 1)

func open_fixture() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="):
			directory = arg.trim_prefix("--root=")
	if not directory.contains("mw015") or FileAccess.file_exists(directory.path_join("sparse.sqlite")):
		return false
	DirAccess.make_dir_recursive_absolute(directory)
	runtime = Runtime.new()
	if not runtime.open_current_game(directory.path_join("sparse.sqlite")).success:
		return false
	check(runtime.commit_world_mutation_durably("setup", "setup-node", setup()).success, "isolated fixture")
	compose()
	await frames()
	complete(curation, {"character": Safe.project_session(runtime).character, "experiences": []})
	await frames()
	return true

func setup() -> Dictionary:
	var world := super.setup()
	world.player_character.source_projection.player_profile.headline = "书院抄书员"
	world.player_character.source_projection.player_profile.summary = "我在书院抄书，原计划考取官职。如今已完成医术学习，但尚未决定是否以行医为一生事业。"
	return world

func check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("MW-015 R1 PASS " + label)
	else:
		failures += 1
		push_error("MW-015 R1 FAIL " + label)
