extends "res://tests/mw019/行动推荐纵向测试.gd"

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="):
			directory = arg.trim_prefix("--root=")
		if arg == "--visual":
			visual = true
	if not directory.contains("mw019"):
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(directory)
	validator_checks()
	runtime = Runtime.new()
	check(runtime.open_current_game(directory.path_join("paired-ui.sqlite")).success, "isolated paired UI runtime")
	check(runtime.commit_world_mutation_durably("setup", "setup-node", setup()).success, "UI fixture")
	runtime.conversation.begin_gm_opening()
	runtime.conversation.append_delta("雨停了。陈安坐在河边小亭里，守门人在城门旁值守，远处渡口亮着一盏灯。")
	check(runtime.complete_active_generation_durably().success, "accepted opening for UI")
	await ui_checks()
	await frames()
	print("MW-019 R1 PAIRED/UI checks=%d failures=%d" % [checks, failures])
	quit(0 if failures == 0 else 1)
