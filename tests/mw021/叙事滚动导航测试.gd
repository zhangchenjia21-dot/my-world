extends SceneTree

## 只用 task-owned SQLite 和真实 main.tscn；直接提交 accepted fixture，不发 Provider 请求。
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
var failures := 0
var checks := 0
var directory := ""
var visual := false

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="): directory = arg.trim_prefix("--root=")
		if arg == "--visual": visual = true
	if not directory.contains("/build/mw021/") or FileAccess.file_exists(directory.path_join("long.sqlite")):
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(directory)
	root.size = Vector2i(1280, 720)
	var seed := Runtime.new()
	check(seed.open_current_game(directory.path_join("long.sqlite")).success, "isolated durable fixture opens")
	check(seed.commit_world_mutation_durably("fixture", "fixture-node", {"fixture": "unchanged world"}).success, "fixture world and timeline exist")
	for i: int in range(32):
		accept(seed, "历史行动 %02d：沿路观察，记下沿途见闻。" % i, ("第 %02d 段：风穿过街巷，路旁灯火渐次亮起。你停步阅读告示，随后继续前行。\n" % i).repeat(6))
	var saved: Dictionary = seed.create_save_point("长历史恢复点")
	check(saved.success, "durable Save fixture exists")
	seed.close()
	var runtime := Runtime.new()
	check(runtime.open_existing_game(directory.path_join("long.sqlite")).success, "existing Game reopened from disk")
	var before := snapshot(runtime)
	var packed: PackedScene = load("res://src/main.tscn")
	var instance: Node = packed.instantiate()
	instance.session_runtime = runtime
	root.add_child(instance)
	await frames()
	var view: Node = instance.get_node("%NarrativeHost")
	var scroll: ScrollContainer = instance.get_node("%NarrativeScroll")
	var bar := scroll.get_v_scroll_bar()
	check(bar.max_value > bar.page * 4, "accepted long history truly overflows multiple viewports")
	check(bar.is_visible_in_tree() and bar.size.x >= 16, "visible main scrollbar has practical local width >=16px")
	check(bar.mouse_filter != Control.MOUSE_FILTER_IGNORE, "scrollbar accepts mouse input")
	check(bottom(bar), "reopen settles at latest bottom")
	check(scroll.get_h_scroll_bar().max_value <= scroll.get_h_scroll_bar().page, "vertical hit width does not clip text into horizontal overflow")
	if visual:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(directory.path_join("narrative-1280x720.png"))
	print("GEOMETRY initial max=%s page=%s value=%s width=%s" % [bar.max_value, bar.page, bar.value, bar.size.x])
	bar.value = (bar.max_value - bar.page) / 2
	await frames()
	check(not view._follow_scroll and not bottom(bar), "direct scrollbar navigation disables follow")
	check(snapshot(runtime) == before, "reopen and scrolling preserve Conversation/World/Timeline/Save")
	# GUI 输入经 Viewport 命中实际 scrollbar；不是仅调用 value setter 来假装拖拽。
	bar.value = 0
	await frames()
	var start := bar.global_position + Vector2(bar.size.x / 2, 4)
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = start
	root.push_input(press)
	var motion := InputEventMouseMotion.new()
	motion.position = start + Vector2(0, bar.size.y / 2)
	motion.relative = motion.position - start
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	root.push_input(motion)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.position = motion.position
	root.push_input(release)
	await frames()
	check(bar.value > 0, "actual mouse drag moves through history")
	check(snapshot(runtime) == before, "actual drag leaves all durable projections unchanged")
	bar.value = (bar.max_value - bar.page) / 3
	var reading := bar.value
	accept(runtime, "普通新增行动", "普通新增正文。\n".repeat(25))
	await frames()
	check(not view._follow_scroll and absf(bar.value - reading) <= 1, "ordinary accepted append respects manual reading")
	bar.value = bar.max_value - bar.page - 12
	check(view._follow_scroll, "near-bottom restores follow-latest")
	accept(runtime, "跟随行动", "跟随新增正文。\n".repeat(25))
	await frames()
	check(bottom(bar), "ordinary append follows latest after returning near bottom")
	# 已排队的跟随也不能覆盖等待布局期间发生的手动上翻。
	view._follow_scroll_if_needed()
	bar.value = (bar.max_value - bar.page) / 3
	reading = bar.value
	await frames()
	check(not view._follow_scroll and absf(bar.value - reading) <= 1, "manual scroll cancels pending follow while layout settles")
	before = snapshot(runtime)
	view.bind_session_runtime(runtime)
	await frames()
	check(bottom(bar) and view._follow_scroll, "Continue/rebind reconstructs at latest even after manual reading")
	check(snapshot(runtime) == before, "rebind is presentation-only")
	check(runtime.restore_save_point(String(saved.save_id)).success, "explicit Restore fixture succeeds")
	await frames()
	check(runtime.conversation.get_accepted_entries().size() == 32, "Restore current accepted prefix excludes later turns")
	check(instance.get_node("%Entries").get_child_count() == 64 and bottom(bar), "Restore redraw shows current prefix at bottom")
	before = snapshot(runtime)
	bar.value = 0
	view.redraw_from_conversation()
	await frames()
	check(bottom(bar) and snapshot(runtime) == before, "explicit redraw follows current bottom without domain mutation")
	for size: Vector2i in [Vector2i(960, 540), Vector2i(1920, 1080)]:
		root.size = size
		await frames()
		view.bind_session_runtime(runtime)
		await frames()
		check(bottom(bar) and bar.is_visible_in_tree() and bar.size.x >= 16, "overflow reopen at %s" % size)
		check(scroll.get_h_scroll_bar().max_value <= scroll.get_h_scroll_bar().page, "no horizontal overflow at %s" % size)
		if visual:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(directory.path_join("narrative-%dx%d.png" % [size.x, size.y]))
	instance.queue_free()
	await frames()
	runtime.close()
	var short_runtime := Runtime.new()
	check(short_runtime.open_current_game(directory.path_join("short.sqlite")).success, "short fixture opens")
	instance = packed.instantiate()
	instance.session_runtime = short_runtime
	root.add_child(instance)
	await frames()
	scroll = instance.get_node("%NarrativeScroll")
	bar = scroll.get_v_scroll_bar()
	check(bar.value == 0 and bar.max_value <= bar.page, "empty history geometry remains valid")
	accept(short_runtime, "看一眼。", "风停了。")
	await frames()
	check(bar.value == 0 and bar.max_value <= bar.page, "short accepted history remains usable without overflow")
	instance.get_node("%NarrativeHost").bind_session_runtime(short_runtime)
	await frames()
	check(bar.value == 0, "short rebind remains at valid origin")
	instance.queue_free()
	await frames()
	short_runtime.close()
	print("MW-021 FOCUSED checks=%d failures=%d provider_calls=0" % [checks, failures])
	quit(0 if failures == 0 else 1)

func frames() -> void:
	for i: int in range(12): await process_frame

func bottom(bar: VScrollBar) -> bool:
	return absf(bar.value - maxf(0, bar.max_value - bar.page)) <= 1

func accept(runtime: RefCounted, player: String, gm: String) -> void:
	check(runtime.conversation.begin_turn(player) != null, "fixture begin")
	runtime.conversation.append_delta(gm)
	check(runtime.complete_active_generation_durably().success, "fixture accepted durably")

func snapshot(runtime: RefCounted) -> String:
	return JSON.stringify({
		"accepted": runtime.conversation.get_durable_accepted_entries(),
		"durable": runtime.persistence.get_current_conversation(runtime.game_id),
		"world": runtime.world_state,
		"current": runtime.persistence.get_current_game(runtime.game_id),
		"timeline": runtime.persistence.get_timeline_node(runtime.game_id, "fixture-node"),
		"saves": runtime.list_save_points(),
		"recovery": runtime.get_recovery_availability(),
	})

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("MW-021 FAIL | " + label)
	else: print("MW-021 PASS | " + label)
