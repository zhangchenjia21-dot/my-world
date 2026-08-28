extends SceneTree

## G3-07 确定性集成现实路径测试（headless，不触网、不需要 Provider key）。
##
## 把 G3-01..G3-06 已分别成立的能力串成一条连续产品路径（DEC-01：不新增架构）：
## fresh isolated Game → 14 个 accepted Turn（跨 recent-12）→ exit/reopen → named Save
## → Future A（G307_FUTURE_A_ONLY）→ Load → Future B（G307_FUTURE_B_ONLY）→ Recover
## → reciprocal Recover → exit/reopen → reopen 后 Regenerate/Correction 域语义抽验。
##
## 同时记录 DEC-08 指标：DB size、Save 触发 backup refresh 耗时、graceful close 耗时、
## reopen 耗时。真实 DeepSeek continuation 证据在 tests/g3_07/真实续玩现实测试.gd。

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const ContextAssembler := preload("res://src/context/上下文组装器.gd")

const MARKER_A := "G307_FUTURE_A_ONLY"
const MARKER_B := "G307_FUTURE_B_ONLY"

var _failures := 0
var _assembler: RefCounted = ContextAssembler.new()


func _init() -> void:
	_run.call_deferred()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G3-07 REALITY PASS | %s" % label)
	else:
		_failures += 1
		printerr("G3-07 REALITY FAIL | %s" % label)


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


func _accept(runtime: RefCounted, player: String, gm: String) -> void:
	if runtime.conversation.begin_turn(player) == null:
		_check(false, "seed begin Turn: %s" % player)
		return
	runtime.conversation.append_delta(gm)
	_check(bool(runtime.complete_active_generation_durably().get("success", false)), "seed accepted Turn: %s" % player)


func _messages(runtime: RefCounted) -> Array:
	return _assembler.assemble_messages(runtime.conversation.get_context_projection())


func _user_count(messages: Array, content: String) -> int:
	var count := 0
	for value: Variant in messages:
		var d := value as Dictionary
		if String(d.get("role", "")) == "user" and String(d.get("content", "")) == content:
			count += 1
	return count


func _run() -> void:
	var db_path := _argument_value("--db=")
	if db_path.find("g3_07") < 0:
		_failures += 1
		printerr("G3-07 REALITY FAIL | task-owned --db required")
		quit(1)
		return

	# ---- 1. fresh isolated Game + 14 accepted Turns（跨 recent-12 边界）----
	var runtime := Runtime.new()
	var startup: Dictionary = runtime.open_current_game(db_path)
	_check(startup.success and String(startup.status) == "created", "fresh isolated Game created")
	var original_game_id := String(startup.get("game_id", ""))
	_check(not original_game_id.is_empty(), "game_id 已分配")
	for i: int in range(1, 15):
		_accept(runtime, "G307_SEED_T%02d 行动" % i, "GM_T%02d 回应" % i)
	_check(runtime.conversation.get_durable_accepted_entries().size() == 14, "14 个 accepted Turn durable")

	# ---- 2. recent-12 边界：无 active 时只保留最近 12 对 ----
	var assembled := _messages(runtime)
	_check(assembled.size() == 25, "recent-12：system + 12 对 == 25 条 messages")
	_check(String((assembled[1] as Dictionary).get("content", "")) == "G307_SEED_T03 行动", "recent-12：最老保留 T03")
	_check(JSON.stringify(assembled).contains("G307_SEED_T01") == false, "recent-12：T01 已被裁出 request")

	# current user exactly once and last（active attempt）
	runtime.conversation.begin_turn("G307_CURRENT_PROBE")
	var active_msgs := _messages(runtime)
	_check(active_msgs.size() == 26, "active attempt：system + 12 对 + current user == 26 条")
	_check(String((active_msgs[-1] as Dictionary).get("role", "")) == "user", "current user 在 request 末尾")
	_check(_user_count(active_msgs, "G307_CURRENT_PROBE") == 1, "current user 恰好一次")
	runtime.conversation.cancel_generation()

	# ---- 3. normal exit → reopen 同 Game（AC-02）----
	var close_begin := Time.get_ticks_msec()
	runtime.close()
	var close_ms := Time.get_ticks_msec() - close_begin
	var reopen_begin := Time.get_ticks_msec()
	var runtime2 := Runtime.new()
	var startup2: Dictionary = runtime2.open_current_game(db_path)
	var reopen_ms := Time.get_ticks_msec() - reopen_begin
	_check(startup2.success and String(startup2.status) == "resumed", "normal exit 后 reopen == resumed")
	_check(String(startup2.game_id) == original_game_id, "reopen 保持同一 game_id")
	_check(runtime2.conversation.get_durable_accepted_entries().size() == 14, "reopen 后 14 个 accepted Turn 完整")

	# ---- 4. named Save S（记录 Save 触发 backup refresh 耗时）----
	var save_begin := Time.get_ticks_msec()
	var saved: Dictionary = runtime2.create_save_point("G3-07 现实存档")
	var save_ms := Time.get_ticks_msec() - save_begin
	_check(saved.success and not bool(saved.get("backup_warning", true)), "named Save durable 且 backup refresh 成功")
	var save_id := String(saved.get("save_id", ""))
	_check(not save_id.is_empty(), "Save id 可用")

	# ---- 5. Future A ----
	_accept(runtime2, "%s 行动一" % MARKER_A, "GM_A1 回应")
	_accept(runtime2, "A 行动二", "GM_A2 回应")
	_check(runtime2.conversation.get_durable_accepted_entries().size() == 16, "Future A durable（16 Turns）")
	_check(JSON.stringify(_messages(runtime2)).contains(MARKER_A), "Future A marker 在 assemble context 中")

	# ---- 6. Load S → A 隔离（AC-03）----
	var loaded: Dictionary = runtime2.restore_save_point(save_id)
	_check(loaded.success, "Load S 成功")
	_check(runtime2.conversation.get_durable_accepted_entries().size() == 14, "Load 后 durable 回到 14 Turns")
	_check(not JSON.stringify(_messages(runtime2)).contains(MARKER_A), "Load 后 request 排除 Future A marker")

	# ---- 7. Future B ----
	_accept(runtime2, "%s 行动" % MARKER_B, "GM_B1 回应")
	var msgs_b := _messages(runtime2)
	_check(JSON.stringify(msgs_b).contains(MARKER_B), "Future B marker 在 context 中")
	_check(not JSON.stringify(msgs_b).contains(MARKER_A), "Future B context 仍排除 A marker")

	# ---- 8. Recover → 精确恢复 A（AC-04）----
	var recovered: Dictionary = runtime2.recover_previous_progress()
	_check(recovered.success, "Recover Previous Progress 成功")
	var entries_a: Array = runtime2.conversation.get_durable_accepted_entries()
	_check(entries_a.size() == 16, "Recover 后 A durable 精确恢复（16 Turns）")
	_check(JSON.stringify(entries_a).contains(MARKER_A) and not JSON.stringify(entries_a).contains(MARKER_B),
		"Recover 后 durable 含 A 不含 B")
	var msgs_a := _messages(runtime2)
	_check(JSON.stringify(msgs_a).contains(MARKER_A) and not JSON.stringify(msgs_a).contains(MARKER_B),
		"Recover 后 request 含 A truth、排除 B marker")

	# ---- 9. reciprocal Recover → B；再 Recover → A ----
	_check(runtime2.recover_previous_progress().success, "reciprocal Recover 回 B 成功")
	var entries_b: Array = runtime2.conversation.get_durable_accepted_entries()
	_check(entries_b.size() == 15 and JSON.stringify(entries_b).contains(MARKER_B) and not JSON.stringify(entries_b).contains(MARKER_A),
		"reciprocal Recover：B 精确恢复、无 history 混线")
	_check(runtime2.recover_previous_progress().success, "再次 Recover 回 A 成功")
	_check(runtime2.conversation.get_durable_accepted_entries().size() == 16, "最终状态 == Future A（16 Turns）")

	# ---- 10. Recover 后 normal exit/reopen ----
	runtime2.close()
	var reopen2_begin := Time.get_ticks_msec()
	var runtime3 := Runtime.new()
	var startup3: Dictionary = runtime3.open_current_game(db_path)
	var reopen2_ms := Time.get_ticks_msec() - reopen2_begin
	_check(startup3.success and String(startup3.game_id) == original_game_id, "Recover 后 reopen 同一 Game")
	var entries_final: Array = runtime3.conversation.get_durable_accepted_entries()
	_check(entries_final.size() == 16 and JSON.stringify(entries_final).contains(MARKER_A) and not JSON.stringify(entries_final).contains(MARKER_B),
		"reopen 后 truth == Recover 后的 A")

	# ---- 11. reopen 后 Regenerate 域语义抽验（IR-03 在 rehydrated Conversation 上成立）----
	runtime3.conversation.retry_or_regenerate_latest()
	var regen_msgs := _messages(runtime3)
	_check(String((regen_msgs[-1] as Dictionary).get("role", "")) == "user", "reopen 后 Regenerate：request 以 user 结束")
	_check(not JSON.stringify(regen_msgs).contains("GM_A2 回应"), "reopen 后 Regenerate：当前旧 assistant 不在 request")
	_check(_user_count(regen_msgs, "A 行动二") == 1, "reopen 后 Regenerate：当前 player 恰好一次")
	runtime3.conversation.cancel_generation()
	_check(runtime3.conversation.get_durable_accepted_entries().size() == 16, "Regenerate cancel 回滚后 truth 不动")

	# ---- 12. reopen 后 Correction 域语义抽验（AC-07/08 rollback）----
	runtime3.conversation.correct_latest("G307_CORRECTION_PROBE")
	var corr_msgs := _messages(runtime3)
	_check(_user_count(corr_msgs, "G307_CORRECTION_PROBE") == 1 and String((corr_msgs[-1] as Dictionary).get("content", "")) == "G307_CORRECTION_PROBE",
		"reopen 后 Correction：corrected text 恰好一次且在末尾")
	runtime3.conversation.cancel_generation()
	var entries_corr: Array = runtime3.conversation.get_durable_accepted_entries()
	_check(entries_corr.size() == 16 and not JSON.stringify(entries_corr).contains("G307_CORRECTION_PROBE"),
		"Correction cancel 回滚：corrected text 未部分接受")

	# ---- 13. verified backup 仍可发现（AC-08 补充）----
	var backup: Dictionary = runtime3.database_safety.backup_availability()
	_check(backup.success, "verified backup 仍 discoverable")
	_check(FileAccess.file_exists("%s.recovery/latest.sqlite" % db_path.trim_suffix(".sqlite")), "latest backup 文件存在")

	# ---- 14. DEC-08 指标 ----
	var db_file := FileAccess.open(db_path, FileAccess.READ)
	var db_size := db_file.get_length() if db_file != null else -1
	if db_file != null:
		db_file.close()
	var metrics := {
		"db_size_bytes": db_size,
		"save_with_backup_refresh_ms": save_ms,
		"graceful_close_ms": close_ms,
		"reopen_ms": reopen_ms,
		"reopen_after_recover_ms": reopen2_ms,
	}
	print("G3-07 REALITY METRICS | %s" % JSON.stringify(metrics))

	runtime3.close()
	print("G3-07 REALITY | done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)
