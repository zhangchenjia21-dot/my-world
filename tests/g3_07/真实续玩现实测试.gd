extends SceneTree

## G3-07 真实 DeepSeek 产品连续性测试（真实窗口运行，blocking Gate，DEC-02）。
##
## 真实产品路径：CurrentGameRuntime + Application Shell + Narrative View + Provider Adapter。
## 老 history 用 deterministic durable seed 控制成本（DEC-03）；真实 Provider 只用于关键 Turn：
##   R1 pre-Save（跨 recent-12 边界）
##   R2 post-Restore（Load 后真实续玩，request 排除 Future A marker）
##   R3 post-Recover（Recover 后真实续玩，request 含 A truth、排除 displaced B marker）
## 每个真实 Turn 必须 stream 到合法终态、persist-before-accept durable、reopen 后存活。
##
## transport 有限重试：每个真实 Turn 最多 3 次 attempt（经 Regenerate/Retry 同 identity），
## 每次结果打印；持续不可用则 FAIL（由上层报告 BLOCKED，不用离线替代）。

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")

const MARKER_A := "G307_FUTURE_A_ONLY"
## IR-01：B-only marker 必须真实进入 R2 accepted player history，
## 否则 Recover 后"排除 B marker"的断言是空证据。
const MARKER_R2 := "G307_FUTURE_B_REAL_ONLY"
const MAX_REAL_ATTEMPTS := 3

var _failures := 0
var _captured_messages: Array = []
var _failure_code := ""
var _real_attempts := 0


func _init() -> void:
	_run.call_deferred()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G3-07 REAL PASS | %s" % label)
	else:
		_failures += 1
		printerr("G3-07 REAL FAIL | %s" % label)


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


func _accept(runtime: RefCounted, player: String, gm: String) -> void:
	if runtime.conversation.begin_turn(player) == null:
		_check(false, "seed begin Turn")
		return
	runtime.conversation.append_delta(gm)
	_check(bool(runtime.complete_active_generation_durably().get("success", false)), "seed accepted Turn: %s" % player)


func _count_user(content: String) -> int:
	var count := 0
	for value: Variant in _captured_messages:
		var d := value as Dictionary
		if String(d.get("role", "")) == "user" and String(d.get("content", "")) == content:
			count += 1
	return count


## 真实 Turn：经正式 UI 发送并等待终态；transport 失败时同 identity 有限重试。
## 返回 true == 该 Turn 被真实 accepted。
func _send_real_turn(instance: Node, runtime: RefCounted, action: String, label: String) -> bool:
	var player_input: TextEdit = instance.get_node("%PlayerInput")
	var send_button: Button = instance.get_node("%SendButton")
	var regenerate_button: Button = instance.get_node("%RegenerateButton")
	var attempt := 0
	while attempt < MAX_REAL_ATTEMPTS:
		attempt += 1
		_real_attempts += 1
		_failure_code = ""
		if attempt == 1:
			player_input.text = action
			send_button.pressed.emit()
		else:
			regenerate_button.pressed.emit()
		_check(runtime.conversation.is_generating(), "%s attempt %d stream begins" % [label, attempt])
		var deadline := Time.get_ticks_msec() + 240000
		while runtime.conversation.is_generating() and Time.get_ticks_msec() < deadline:
			await process_frame
		print("G3-07 REAL ATTEMPT | %s attempt=%d terminal_code=%s" % [label, attempt, _failure_code if not _failure_code.is_empty() else "accepted"])
		if _failure_code.is_empty():
			return true
		if _failure_code != "transport":
			return false
		printerr("G3-07 REAL RETRY | %s transport failure, attempt %d/%d" % [label, attempt, MAX_REAL_ATTEMPTS])
	return false


func _run() -> void:
	var db_path := _argument_value("--db=")
	if db_path.find("g3_07") < 0 or OS.get_environment("DEEPSEEK_API_KEY").strip_edges().is_empty():
		printerr("G3-07 REAL FAIL | missing task-owned --db or Provider credential")
		quit(1)
		return

	# ---- 1. fresh isolated Game + 12 deterministic seed Turns（控制成本，DEC-03）----
	var runtime := Runtime.new()
	var startup: Dictionary = runtime.open_current_game(db_path)
	_check(startup.success and String(startup.status) == "created", "isolated real-Provider Game created")
	var game_id := String(startup.game_id)
	for i: int in range(1, 13):
		_accept(runtime, "G307_SEED_R%02d 行动" % i, "GM_R%02d 回应" % i)
	_check(runtime.conversation.get_durable_accepted_entries().size() == 12, "12 个 seed Turn durable")

	# ---- 2. 真实 Turn R1（pre-Save，跨 recent-12 边界的关键请求）----
	var packed: PackedScene = load("res://src/main.tscn")
	var instance: Node = packed.instantiate()
	instance.session_runtime = runtime
	root.add_child(instance)
	await process_frame
	await process_frame
	var view: Node = instance.get_node("%NarrativeHost")
	view.request_messages_assembled.connect(func(messages: Array) -> void: _captured_messages = messages)
	runtime.conversation.generation_failed.connect(func(_turn: RefCounted, code: String) -> void: _failure_code = code)

	var action_r1 := "我推开旧塔的大门，借着月光看清大厅里的摆设，记住墙上挂着的星图。"
	if not await _send_real_turn(instance, runtime, action_r1, "R1"):
		_check(false, "R1 真实 Turn 在有限重试后仍未 accepted（code=%s）" % _failure_code)
		_finish(instance, runtime)
		return
	_check(runtime.conversation.get_durable_accepted_entries().size() == 13, "R1 persist-before-accept durable（13 Turns）")
	_check(_captured_messages.size() == 26, "R1 request == system + 12 对 + current（跨 recent-12 临界）")
	_check(String((_captured_messages[-1] as Dictionary).get("role", "")) == "user" and _count_user(action_r1) == 1, "R1 current user 恰好一次且在末尾")

	# ---- 3. exit/reopen：真实 Turn 存活 ----
	instance.queue_free()
	await process_frame
	runtime.close()
	var runtime2 := Runtime.new()
	var startup2: Dictionary = runtime2.open_current_game(db_path)
	_check(startup2.success and String(startup2.status) == "resumed" and String(startup2.game_id) == game_id, "R1 后 reopen 同一 Game")
	_check(runtime2.conversation.get_durable_accepted_entries().size() == 13, "R1 真实 Turn 在 reopen 后仍存在")

	# ---- 4. named Save + Future A ----
	var saved: Dictionary = runtime2.create_save_point("G3-07 真实存档")
	_check(saved.success, "named Save durable")
	_accept(runtime2, "%s 行动" % MARKER_A, "GM_A 回应 %s" % MARKER_A)
	_check(runtime2.conversation.get_durable_accepted_entries().size() == 14, "Future A durable")

	# ---- 5. Load S → 真实 Turn R2（post-Restore，AC-05）----
	_check(runtime2.restore_save_point(String(saved.save_id)).success, "Load S 成功")
	_check(runtime2.conversation.get_durable_accepted_entries().size() == 13, "Load 后回到 13 Turns")
	instance = packed.instantiate()
	instance.session_runtime = runtime2
	root.add_child(instance)
	await process_frame
	await process_frame
	view = instance.get_node("%NarrativeHost")
	view.request_messages_assembled.connect(func(messages: Array) -> void: _captured_messages = messages)

	var action_r2 := "%s 行动：回到旧塔门口，检查那道划痕旁边是否留下新的脚印。" % MARKER_R2
	if not await _send_real_turn(instance, runtime2, action_r2, "R2"):
		_check(false, "R2 post-Restore 真实 Turn 未 accepted（code=%s）" % _failure_code)
		_finish(instance, runtime2)
		return
	var msgs_r2 := JSON.stringify(_captured_messages)
	_check(not msgs_r2.contains(MARKER_A), "R2 post-Restore request 排除 Future A marker")
	_check(msgs_r2.contains("G307_SEED_R12"), "R2 request 保留 restored accepted history")
	_check(runtime2.conversation.get_durable_accepted_entries().size() == 14, "R2 durable（14 Turns）")
	# IR-01：先证明 B-only marker 真实存在于 R2 accepted player history，排除断言才非空。
	var r2_entries := JSON.stringify(runtime2.conversation.get_durable_accepted_entries())
	_check(r2_entries.contains(MARKER_R2), "R2 accepted player history 实际包含 B-only marker")

	# ---- 6. Recover → 真实 Turn R3（post-Recover，AC-05）----
	_check(runtime2.recover_previous_progress().success, "Recover Previous Progress 成功")
	var recovered_entries := JSON.stringify(runtime2.conversation.get_durable_accepted_entries())
	_check(recovered_entries.contains(MARKER_A) and not recovered_entries.contains(MARKER_R2), "Recover 精确恢复 A、置换 R2 future")
	var action_r3 := "顺着 Future A 星图的指向，继续向旧塔深处探索。"
	if not await _send_real_turn(instance, runtime2, action_r3, "R3"):
		_check(false, "R3 post-Recover 真实 Turn 未 accepted（code=%s）" % _failure_code)
		_finish(instance, runtime2)
		return
	var msgs_r3 := JSON.stringify(_captured_messages)
	_check(msgs_r3.contains(MARKER_A), "R3 post-Recover request 含 A truth")
	_check(not msgs_r3.contains(MARKER_R2), "R3 post-Recover request 排除 displaced B marker")
	_check(runtime2.conversation.get_durable_accepted_entries().size() == 15, "R3 durable（15 Turns）")

	# ---- 7. 最终 exit/reopen：组合路径后仍同一 Game、同一 truth ----
	instance.queue_free()
	await process_frame
	runtime2.close()
	var runtime3 := Runtime.new()
	var startup3: Dictionary = runtime3.open_current_game(db_path)
	_check(startup3.success and String(startup3.game_id) == game_id, "组合路径后 reopen 同一 Game")
	var final_entries := JSON.stringify(runtime3.conversation.get_durable_accepted_entries())
	_check(final_entries.contains(MARKER_A) and not final_entries.contains(MARKER_R2), "reopen 后 truth == post-Recover A 线")
	_check(runtime3.get_recovery_availability().get("available", false), "reciprocal Recovery 仍可用")
	runtime3.close()
	print("G3-07 REAL | real_attempts=%d failures=%d" % [_real_attempts, _failures])
	quit(1 if _failures > 0 else 0)


func _finish(instance: Node, runtime: RefCounted) -> void:
	if is_instance_valid(instance):
		instance.queue_free()
	if runtime != null:
		runtime.close()
	print("G3-07 REAL | real_attempts=%d failures=%d" % [_real_attempts, _failures])
	quit(1)
