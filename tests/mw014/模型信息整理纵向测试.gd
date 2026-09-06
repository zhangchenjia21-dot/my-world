extends SceneTree

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Curator := preload("res://src/信息整理/L3_外交层/信息整理公开接口.gd")
const SafeView := preload("res://src/信息整理/L3_外交层/角色经历投影公开接口.gd")
const Stub := preload("res://tests/g5_01/世界回合语义桩适配器.gd")
const Shell := preload("res://src/应用壳.gd")
const NO_CHANGE := {"character": null, "experiences": []}
var failures := 0
var checks := 0
var directory := ""

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="):
			directory = arg.trim_prefix("--root=")
	if not directory.contains("mw014"):
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(directory)
	var runtime := Runtime.new()
	check(runtime.open_current_game(directory.path_join("test.sqlite")).success, "open isolated production SQLite")
	check(runtime.commit_world_mutation_durably("setup", "setup-node", setup()).success, "freeze starting profile")
	var initial := SafeView.project_session(runtime)
	check(initial.character.headline == "24岁 · 现代穿越者" and not initial.character.summary.is_empty(), "starting profile remains useful without model")
	check(not JSON.stringify(initial).contains("水壶"), "starting possessions do not become Character groups")
	var stub := Stub.new()
	var worker := Curator.new(runtime, stub)
	root.add_child(worker)
	await frames()
	accept(runtime, "曹操这人确实比我想象中有意思。", "你们继续闲谈，并未作出任何承诺。")
	await frames()
	var request_text := JSON.stringify(stub.requests[-1])
	for forbidden: String in ["NPC_PRIVATE", "GM_PRIVATE", "HIDDEN_EVOLUTION", "PRIVATE_PLAN", "SOURCE_CURRENT", "raw-secret"]:
		check(not request_text.contains(forbidden), "request excludes " + forbidden)
	stub.simulate_failed()
	await frames()
	check(runtime.conversation.get_durable_accepted_entries().size() == 1 and SafeView.project_session(runtime) == initial, "curator failure preserves accepted narrative and initial view")
	check(runtime.conversation.begin_turn("下一行动") != null, "failure does not gate next action")
	runtime.conversation.cancel_generation()
	worker.retry_pending()
	await frames()
	complete(stub, NO_CHANGE)
	await frames()
	check(SafeView.project_session(runtime) == initial, "no-change result creates no fake material")
	var request_count := stub.requests.size()
	worker.retry_pending()
	await frames()
	check(stub.requests.size() == request_count, "same-version successful replay does not call model")
	var save := runtime.create_save_point("整理之前")
	check(save.success, "save before lived change")
	accept(runtime, "我读完这份文书。", "经过持续学习，你现在可以独立阅读常见隶书文书。")
	await frames()
	complete(stub, changed("能独立阅读常见隶书文书", "第一次独立读完文书"))
	await frames()
	var learned := SafeView.project_session(runtime)
	check(learned.character.groups[0].items[0] == "能独立阅读常见隶书文书", "model snapshot updates current Character")
	check(learned.important_experiences.size() == 1, "model addition produces milestone")
	worker.retry_pending()
	await frames()
	check(SafeView.project_session(runtime) == learned, "identical replay cannot duplicate milestones")
	var changed_save := runtime.create_save_point("学习之后")
	check(changed_save.success, "save captures curation atomically")
	runtime.conversation.retry_or_regenerate_latest()
	runtime.conversation.append_delta("你仍不能独立阅读这份文书。")
	check(runtime.complete_active_generation_durably().success, "regenerate replaces accepted version")
	check(SafeView.project_session(runtime) == initial, "superseded curation disappears immediately")
	await frames()
	complete(stub, NO_CHANGE)
	await frames()
	check(SafeView.project_session(runtime) == initial, "replacement no-change does not revive stale material")
	check(runtime.restore_save_point(changed_save.save_id).success, "restore learned timeline")
	check(SafeView.project_session(runtime) == learned, "restore reconstructs matching learned state")
	check(runtime.restore_save_point(save.save_id).success, "restore pre-change")
	check(SafeView.project_session(runtime) == initial, "restored-away Character and milestone disappear")

	# 同 accepted 原文的 Restore 也必须取消旧在途写入。
	accept(runtime, "我再次学习。", "你逐渐熟悉了笔画。")
	await frames()
	var pending_save := runtime.create_save_point("在途之前")
	complete(stub, changed("新能力", "新经历"))
	await frames()
	check(runtime.restore_save_point(pending_save.save_id).success, "restore same transcript pre-curation snapshot")
	check(SafeView.project_session(runtime).important_experiences.is_empty(), "same-transcript pre-curation snapshot stays empty")
	worker.retry_pending()
	await frames()
	check(stub.busy, "explicit retry repairs restored missing curation")
	check(runtime.restore_save_point(save.save_id).success, "restore while curator active")
	stub.simulate_delta(JSON.stringify(changed("未来泄露", "未来经历")))
	stub.simulate_completed()
	await frames()
	check(SafeView.project_session(runtime) == initial, "in-flight future response cannot cross Restore epoch")
	accept(runtime, "我再次学习。", "你逐渐熟悉了笔画。")
	await frames()
	complete(stub, changed("新能力", "新经历"))
	await frames()
	check(SafeView.project_session(runtime).important_experiences.size() == 1, "same-version recuration after Restore has no displaced-future mutation conflict")
	# 非语义无效响应：每次使用同一真实 accepted 版本显式修复。
	accept(runtime, "我歇息。", "你平静地度过傍晚。")
	await frames()
	var protected_world: Dictionary = runtime.world_state.duplicate(true)
	var protected_entries: Array = runtime.conversation.get_durable_accepted_entries()
	var malformed := [
		"not json",
		JSON.stringify({"character": null, "experiences": [], "importance_score": 99}),
		JSON.stringify({"character": null, "experiences": [{"title": "x", "description": "y", "id": "model-id"}]}),
		JSON.stringify({"character": {"headline": "", "summary": "", "groups": [{"title": "未知", "items": []}]}, "experiences": []}),
		JSON.stringify({"character": null, "experiences": [{"title": "x".repeat(161), "description": "y"}]}),
		"[".repeat(100) + "]".repeat(100),
		"x".repeat(65537),
	]
	for text: String in malformed:
		if not stub.busy:
			worker.retry_pending()
			await frames()
		stub.simulate_delta(text)
		stub.simulate_completed()
		await frames()
		check(runtime.world_state == protected_world and runtime.conversation.get_durable_accepted_entries() == protected_entries, "malformed/unknown/deep/oversized payload is zero-mutation")
	worker.retry_pending()
	await frames()
	complete(stub, NO_CHANGE)
	await frames()
	var final_view := SafeView.project_session(runtime)
	var serialized := JSON.stringify(final_view)
	for forbidden: String in ["prefix", "schema", "source_", "NPC_PRIVATE", "GM_PRIVATE", "HIDDEN_EVOLUTION", "PRIVATE_PLAN", "hash", "mutation", "game_id"]:
		check(not serialized.contains(forbidden), "projection contains no " + forbidden)
	check(final_view.important_experiences[0].time_label == "", "no invented calendar precision")
	worker.shutdown()
	worker.queue_free()
	runtime.close()
	await frames()
	var reopened := Runtime.new()
	check(reopened.open_existing_game(directory.path_join("test.sqlite")).success, "reopen existing database")
	check(SafeView.project_session(reopened) == final_view, "reopen reconstructs equivalent projection without provider")
	var reopen_stub := Stub.new()
	var reopen_worker := Curator.new(reopened, reopen_stub)
	root.add_child(reopen_worker)
	await frames()
	reopen_worker.retry_pending()
	await frames()
	check(reopen_stub.requests.is_empty(), "durable no-change and success receipts survive reopen")
	reopen_worker.shutdown()
	reopen_worker.queue_free()
	reopened.close()
	await frames()
	# 真实 Bootstrap lifecycle 使用相同 worker；没有搭建 detached parser-only seam。
	var shell := Shell.new()
	var shell_runtime := Runtime.new()
	check(shell_runtime.open_current_game(directory.path_join("shell.sqlite")).success, "shell runtime opens")
	shell.session_runtime = shell_runtime
	shell.test_information_curator_adapter_override = Stub.new()
	shell.test_world_turn_adapter_override = Stub.new()
	shell.test_world_evolution_adapter_override = Stub.new()
	shell._prepare_world_turn_after_activation()
	check(shell.information_curator != null, "production Shell composes curator")
	# 本测试只调用未入树的 Bootstrap；显式释放尚未被 _ready 收养的 transport。
	for lane: Node in [shell.information_curator, shell.world_turn_runtime, shell.world_evolution_evaluator]:
		if lane.provider_adapter.get_parent() == null:
			lane.add_child(lane.provider_adapter)
	shell._teardown_world_evolution_evaluator()
	shell._teardown_agency_scheduler()
	shell._teardown_world_turn_runtime()
	shell.free()
	shell_runtime.close()
	await frames()
	await test_edges()
	print("MW-014 FOCUSED checks=%d failures=%d" % [checks, failures])
	quit(0 if failures == 0 else 1)

func setup() -> Dictionary:
	return {
		"player_character": {"local_character_id": "private-player-id", "source_projection": {
			"semantic_sections": [{"content": "GM_PRIVATE raw-secret"}],
			"gm_reference": "GM_PRIVATE", "catalog_summary": "SOURCE_CURRENT",
			"player_profile": {"headline": "24岁 · 现代穿越者", "summary": "张辰来自现代，正在学习适应汉末生活。", "groups": [
				{"group_id": "abilities", "title": "能力", "items": ["现代常识与学习能力"]},
				{"group_id": "possessions", "title": "随身物品", "items": ["水壶"]}
			]}
		}},
		"living_world": {"knowledge_turns_by_index": {"npc": "NPC_PRIVATE"}, "agency_cycles_by_source_turn": {"plan": "PRIVATE_PLAN"}, "world_evolution_events_by_turn": {"hidden": "HIDDEN_EVOLUTION"}}
	}

func changed(item: String, title: String) -> Dictionary:
	return {"character": {"headline": "张辰", "summary": "逐渐适应汉末生活。", "groups": [{"title": "能力 / 专长说明", "items": [item]}]}, "experiences": [{"title": title, "description": "这是一次由模型判断的主角经历。"}]}

func accept(runtime: RefCounted, player: String, gm: String) -> void:
	check(runtime.conversation.begin_turn(player) != null, "begin ordinary turn")
	runtime.conversation.append_delta(gm)
	check(runtime.complete_active_generation_durably().success, "accept narrative before curation")

func complete(stub: Node, value: Dictionary) -> void:
	check(stub.busy, "production curator request active")
	stub.simulate_delta(JSON.stringify(value))
	stub.simulate_completed()

func frames() -> void:
	await process_frame
	await process_frame

func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("MW-014 FAIL " + label)
	else:
		print("MW-014 PASS " + label)



func test_edges() -> void:
	var runtime := RejectingRuntime.new()
	check(runtime.open_current_game(directory.path_join("edges.sqlite")).success, "edge Runtime opens")
	check(runtime.commit_world_mutation_durably("setup", "setup-node", setup()).success, "edge setup")
	var stub := Stub.new()
	var worker := Curator.new(runtime, stub)
	root.add_child(worker)
	await frames()
	accept(runtime, "任意甲", "语义由模型理解甲")
	await frames()
	check(runtime.conversation.begin_turn("前台继续") != null, "foreground starts while curator is still busy")
	runtime.conversation.cancel_generation()
	var before: Dictionary = runtime.world_state.duplicate(true)
	runtime.reject_curation = true
	complete(stub, changed("原子候选", "未提交经历"))
	await frames()
	check(runtime.world_state == before and not worker.last_result.success, "persistence failure does not publish candidate")
	runtime.reject_curation = false
	worker.retry_pending()
	await frames()
	complete(stub, changed("成功修复", "第一条"))
	await frames()
	check(SafeView.project_session(runtime).important_experiences.size() == 1, "persistence failure retry recovers through production seam")
	accept(runtime, "任意乙", "语义由模型理解乙")
	await frames()
	worker._timer.timeout.emit()
	await frames()
	check(not stub.busy and worker.last_result.status == "timeout", "bounded timeout cancels transport without touching foreground")
	stub.synchronous_failure = true
	worker.retry_pending()
	await frames()
	check(worker.last_result.status == "provider_failure", "synchronous provider failure terminates cleanly")
	stub.synchronous_failure = false
	worker.retry_pending()
	await frames()
	# 同 GM，不同 Player text 仍必须使旧请求失效。
	runtime.conversation.correct_latest("修改后的乙")
	runtime.conversation.append_delta("语义由模型理解乙")
	check(runtime.complete_active_generation_durably().success, "Player-only correction accepted")
	complete(stub, changed("旧玩家版本", "不应保留"))
	await frames()
	check(not JSON.stringify(SafeView.project_session(runtime)).contains("旧玩家版本"), "Player-only version replacement rejects stale response")
	complete(stub, NO_CHANGE)
	await frames()
	# 不依赖事件类别、措辞或分数：无语义分类的程序接受模型直接选择的 4 条经历。
	for index: int in range(3):
		accept(runtime, "普通输入", "普通叙事")
		await frames()
		var additions: Array = []
		for ordinal: int in range(4):
			additions.append({"title": "经历 %d-%d" % [index, ordinal], "description": "模型按具体上下文选择的重要经历"})
		complete(stub, {"character": null, "experiences": additions})
		await frames()
	check(SafeView.project_session(runtime).important_experiences.size() == 13, "history retains more than context window with no content deletion cap")
	accept(runtime, "又一轮", "叙事继续")
	await frames()
	var request: Dictionary = JSON.parse_string(stub.requests[-1][1].content)
	check(request.recent_experiences.size() == 8, "only recent model context is bounded to eight milestones")
	complete(stub, NO_CHANGE)
	await frames()
	# 无 frozen profile 的旧局不能从 raw Source prose 偷填；invalid owner 也 fail closed。
	var frozen: Dictionary = runtime.world_state.duplicate(true)
	runtime.world_state.erase("information_curation")
	runtime.world_state.player_character.source_projection.erase("player_profile")
	check(SafeView.project_session(runtime).character.summary.is_empty(), "old Game never backfills from raw Source or Source current")
	runtime.world_state = frozen
	worker.shutdown()
	worker.queue_free()
	runtime.close()
	await frames()

class RejectingRuntime:
	extends "res://src/runtime/当前游戏会话运行时.gd"
	var reject_curation := false
	func commit_world_mutation_durably(mutation_id: String, node_id: String, next_world_state: Dictionary) -> Dictionary:
		if reject_curation and mutation_id.begins_with("curation-"):
			return {"success": false, "status": "controlled_storage_failure"}
		return super(mutation_id, node_id, next_world_state)
