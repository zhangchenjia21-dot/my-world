extends SceneTree

## G2-04 会话域离线测试（headless，纯 Domain，不加载场景、不触网、不需要 Provider key）。
##
## 覆盖 Task Packet AC-01..AC-08 与 build_provider_messages 临时适配规则：
## - T01 AC-01：正常 completed turn（信号顺序、accepted 原子生效、streaming context）；
## - T02 AC-02：cancel → retry（同一 turn identity，draft 保留展示，不进 context）；
## - T03 AC-03：fail → retry；
## - T04 AC-04 + IR-03：completed → regenerate 成功（同一 identity、player 恰好一次、
##   replacement request 以 user 结束且不含旧 assistant、Domain accepted 稳定、原子替换）；
## - T05 AC-05：regenerate → cancel / fail 回滚 → 直接新 Turn 不错位（IR-02 语义域化）；
## - T06 AC-06：≥3 turns 顺序与 identity；
## - T07 AC-07：latest-turn correction 成功（原子替换 player text + GM）；
## - T08 AC-08：correction cancel / fail 回滚，随后新 Turn 不错位；
## - T09 防御：非法调用（STREAMING 中 begin_turn、空 correction 等）不破坏状态；
## - T10 correction 作用于从未 completed 的 latest：同一 identity 换文本 retry；
## - T11 IR-03 多 Turn：regenerate 最新 completed Turn 的 request == previous accepted pairs
##   + current user（当前旧 assistant 不在 request，previous assistant 保留）。

const Conversation := preload("res://src/domain/会话.gd")

var _failures := 0


func _init() -> void:
	_run.call_deferred()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("[g2-04-domain] PASS: %s" % label)
	else:
		_failures += 1
		printerr("[g2-04-domain] FAIL: %s" % label)


## messages 中指定 role + content 的出现次数。
func _count_msg(messages: Array, role: String, content: String) -> int:
	var n := 0
	for m: Variant in messages:
		var d := m as Dictionary
		if d != null and String(d.get("role", "")) == role and String(d.get("content", "")) == content:
			n += 1
	return n


func _roles(messages: Array) -> Array:
	var out: Array = []
	for m: Variant in messages:
		out.append(String((m as Dictionary).get("role", "")))
	return out


func _run() -> void:
	# ---- T01（AC-01）：正常 completed turn ----
	var c: RefCounted = Conversation.new()
	var events: Array = []
	c.turn_started.connect(func(_t: RefCounted) -> void: events.append("turn_started"))
	c.attempt_started.connect(func(_t: RefCounted) -> void: events.append("attempt_started"))
	c.draft_appended.connect(func(d: String) -> void: events.append("draft:%s" % d))
	c.generation_completed.connect(func(_t: RefCounted) -> void: events.append("completed"))
	c.generation_cancelled.connect(func(_t: RefCounted) -> void: events.append("cancelled"))
	c.generation_failed.connect(func(_t: RefCounted, code: String) -> void: events.append("failed:%s" % code))

	_check(c.generation_state == Conversation.GenerationState.IDLE, "T01 初始 IDLE")
	_check(c.latest_turn() == null, "T01 初始无 turn")
	var t1: RefCounted = c.begin_turn("行动一")
	_check(t1 != null and t1.turn_index == 0, "T01 begin_turn 返回 turn_index == 0")
	_check(c.is_generating(), "T01 begin 后 STREAMING")
	_check(_roles(c.build_provider_messages("SYS")) == ["system", "user"], "T01 streaming context == [system, user]")
	_check(_count_msg(c.build_provider_messages("SYS"), "user", "行动一") == 1, "T01 streaming 中 player input 恰好一次")
	c.append_delta("GM")
	c.append_delta("甲")
	_check(String(t1.draft_text) == "GM甲", "T01 draft 累积")
	c.complete_generation()
	_check(c.generation_state == Conversation.GenerationState.COMPLETED, "T01 complete 后 COMPLETED")
	_check(t1.has_accepted_response, "T01 accepted 生效")
	_check(String(t1.player_text) == "行动一" and String(t1.accepted_gm_text) == "GM甲", "T01 accepted 内容正确")
	_check(c.get_accepted_entries().size() == 1, "T01 accepted entries == 1")
	_check(events == ["turn_started", "attempt_started", "draft:GM", "draft:甲", "completed"], "T01 信号顺序正确")

	# ---- T02（AC-02）：cancel → retry ----
	var c2: RefCounted = Conversation.new()
	var t2: RefCounted = c2.begin_turn("行动A")
	c2.append_delta("半路")
	c2.cancel_generation()
	_check(c2.generation_state == Conversation.GenerationState.CANCELLED, "T02 cancel 后 CANCELLED")
	_check(not t2.has_accepted_response, "T02 cancel 后无 accepted")
	_check(String(t2.draft_text) == "半路", "T02 cancel 后 draft 保留展示")
	_check(c2.build_provider_messages("SYS").size() == 1, "T02 未完成的 turn 不进后续 context（仅 system）")
	var t2r: RefCounted = c2.retry_or_regenerate_latest()
	_check(t2r == t2, "T02 retry 复用同一 turn identity")
	_check(c2.is_generating(), "T02 retry 后 STREAMING")
	_check(_count_msg(c2.build_provider_messages("SYS"), "user", "行动A") == 1, "T02 retry context player 恰好一次")
	c2.append_delta("GM-A")
	c2.complete_generation()
	_check(String(t2.player_text) == "行动A" and String(t2.accepted_gm_text) == "GM-A", "T02 retry 成功 accepted 正确")

	# ---- T03（AC-03）：fail → retry ----
	var c3: RefCounted = Conversation.new()
	var fail_events: Array = []
	c3.generation_failed.connect(func(_t: RefCounted, code: String) -> void: fail_events.append(code))
	var t3: RefCounted = c3.begin_turn("行动B")
	c3.append_delta("半截")
	c3.fail_generation("transport")
	_check(c3.generation_state == Conversation.GenerationState.FAILED, "T03 fail 后 FAILED")
	_check(fail_events == ["transport"], "T03 failed 信号带 code")
	_check(not t3.has_accepted_response and String(t3.draft_text) == "半截", "T03 fail 后无 accepted、draft 保留")
	var t3r: RefCounted = c3.retry_or_regenerate_latest()
	_check(t3r == t3 and c3.is_generating(), "T03 retry 同一 identity 重新 STREAMING")
	c3.append_delta("GM-B")
	c3.complete_generation()
	_check(String(t3.accepted_gm_text) == "GM-B", "T03 fail→retry 成功")

	# ---- T04（AC-04）：completed → regenerate 成功 ----
	var c4: RefCounted = Conversation.new()
	var t4: RefCounted = c4.begin_turn("第一行动")
	c4.append_delta("GM 甲")
	c4.complete_generation()
	var t4r: RefCounted = c4.retry_or_regenerate_latest()
	_check(t4r == t4 and t4.turn_index == 0, "T04 regenerate 同一 turn identity")
	# 替换成功前：旧 accepted 在 Domain 内保持稳定，但不进入 replacement request（IR-03）。
	var regen_msgs: Array = c4.build_provider_messages("SYS")
	_check(_roles(regen_msgs) == ["system", "user"], "T04(IR-03) 单 Turn regenerate request == [system, user]")
	_check(_count_msg(regen_msgs, "assistant", "GM 甲") == 0, "T04(IR-03) 旧 accepted assistant 不在 request")
	_check(_count_msg(regen_msgs, "user", "第一行动") == 1, "T04 regenerate 期间 player input 恰好一次")
	_check(String((regen_msgs[-1] as Dictionary).get("role", "")) == "user", "T04(IR-03) request 以 user 结束")
	_check(String(t4.accepted_gm_text) == "GM 甲", "T04 替换成功前旧 accepted 未被破坏")
	c4.append_delta("GM 甲改")
	c4.complete_generation()
	_check(String(t4.player_text) == "第一行动" and String(t4.accepted_gm_text) == "GM 甲改", "T04 原子替换为新输出")
	_check(c4.get_accepted_entries().size() == 1, "T04 仍是一条 accepted entry（无第二个 player turn）")

	# ---- T05（AC-05）：regenerate → cancel / fail → 直接新 Turn 不错位 ----
	# cancel 变体
	var c5: RefCounted = Conversation.new()
	c5.begin_turn("回合一")
	c5.append_delta("GM一")
	c5.complete_generation()
	c5.retry_or_regenerate_latest()
	c5.append_delta("GM一改-半路")
	c5.cancel_generation()
	_check(c5.generation_state == Conversation.GenerationState.CANCELLED, "T05a regenerate cancel 后 CANCELLED")
	var t5: RefCounted = c5.latest_turn()
	_check(String(t5.accepted_gm_text) == "GM一" and t5.has_accepted_response, "T05a cancel 回滚后旧 accepted 完整")
	c5.begin_turn("回合二")
	var msgs5: Array = c5.build_provider_messages("SYS")
	_check(_roles(msgs5) == ["system", "user", "assistant", "user"], "T05a 直接新发送 context 合法交错")
	_check(_count_msg(msgs5, "user", "回合一") == 1 and _count_msg(msgs5, "user", "回合二") == 1, "T05a 两 player input 各恰好一次")
	c5.append_delta("GM二")
	c5.complete_generation()
	var entries5: Array = c5.get_accepted_entries()
	_check(entries5.size() == 2, "T05a 完成后两条 accepted entries")
	_check(String(entries5[0].get("gm_text", "")) == "GM一" and String(entries5[1].get("gm_text", "")) == "GM二", "T05a accepted 内容不错位")
	# fail 变体
	var c5b: RefCounted = Conversation.new()
	c5b.begin_turn("回合一")
	c5b.append_delta("GM一")
	c5b.complete_generation()
	c5b.retry_or_regenerate_latest()
	c5b.fail_generation("transport")
	_check(String(c5b.latest_turn().accepted_gm_text) == "GM一", "T05b regenerate fail 回滚后旧 accepted 完整")
	c5b.begin_turn("回合二")
	var msgs5b: Array = c5b.build_provider_messages("SYS")
	_check(_roles(msgs5b) == ["system", "user", "assistant", "user"], "T05b fail 后直接新发送 context 合法交错")
	c5b.append_delta("GM二")
	c5b.complete_generation()
	_check(c5b.get_accepted_entries().size() == 2, "T05b 完成后两条 accepted entries")

	# ---- T06（AC-06）：≥3 turns 顺序与 identity ----
	var c6: RefCounted = Conversation.new()
	for i: int in 3:
		var ti: RefCounted = c6.begin_turn("行动%d" % i)
		c6.append_delta("GM%d" % i)
		c6.complete_generation()
		_check(ti.turn_index == i, "T06 turn_index == %d" % i)
	_check(c6.turns.size() == 3, "T06 三个 turns")
	var entries6: Array = c6.get_accepted_entries()
	_check(entries6.size() == 3, "T06 三条 accepted entries")
	var order_ok := true
	for i: int in 3:
		if int(entries6[i].get("turn_index", -1)) != i or String(entries6[i].get("player_text", "")) != "行动%d" % i:
			order_ok = false
	_check(order_ok, "T06 entries 顺序与 identity 稳定")
	_check(_roles(c6.build_provider_messages("SYS")) == ["system", "user", "assistant", "user", "assistant", "user", "assistant"], "T06 三对完整 context 顺序")

	# ---- T07（AC-07）：latest-turn correction 成功 ----
	var c7: RefCounted = Conversation.new()
	var t7: RefCounted = c7.begin_turn("旧行动")
	c7.append_delta("GM旧")
	c7.complete_generation()
	var t7c: RefCounted = c7.correct_latest("新行动")
	_check(t7c == t7, "T07 correction 复用同一 turn identity")
	_check(c7.is_generating(), "T07 correction 后 STREAMING")
	var msgs7: Array = c7.build_provider_messages("SYS")
	_check(_roles(msgs7) == ["system", "user"], "T07 correction context 只发新 player text（不附带旧 assistant）")
	_check(_count_msg(msgs7, "user", "新行动") == 1, "T07 新文本恰好一次")
	_check(String(t7.player_text) == "旧行动", "T07 成功前 accepted 未被破坏")
	c7.append_delta("GM新")
	c7.complete_generation()
	_check(String(t7.player_text) == "新行动" and String(t7.accepted_gm_text) == "GM新", "T07 成功原子替换 player text + GM")
	_check(c7.get_accepted_entries().size() == 1, "T07 仍一条 accepted entry")

	# ---- T08（AC-08）：correction cancel / fail 回滚，随后新 Turn 不错位 ----
	var c8: RefCounted = Conversation.new()
	var t8: RefCounted = c8.begin_turn("原行动")
	c8.append_delta("GM原")
	c8.complete_generation()
	c8.correct_latest("改过的行动")
	c8.cancel_generation()
	_check(c8.generation_state == Conversation.GenerationState.CANCELLED, "T08a correction cancel 后 CANCELLED")
	_check(String(t8.player_text) == "原行动" and String(t8.accepted_gm_text) == "GM原", "T08a 回滚后 accepted 原对完整")
	c8.begin_turn("下一条行动")
	var msgs8: Array = c8.build_provider_messages("SYS")
	_check(_roles(msgs8) == ["system", "user", "assistant", "user"], "T08a 回滚后新 Turn context 合法交错")
	_check(_count_msg(msgs8, "user", "原行动") == 1 and _count_msg(msgs8, "user", "下一条行动") == 1, "T08a 两 input 各一次")
	c8.append_delta("GM下")
	c8.complete_generation()
	_check(c8.get_accepted_entries().size() == 2, "T08a 新 Turn completed 后两条 entries")
	# fail 变体
	var c8b: RefCounted = Conversation.new()
	var t8b: RefCounted = c8b.begin_turn("原行动")
	c8b.append_delta("GM原")
	c8b.complete_generation()
	c8b.correct_latest("改过的行动")
	c8b.fail_generation("http_500")
	_check(String(t8b.player_text) == "原行动" and String(t8b.accepted_gm_text) == "GM原", "T08b correction fail 回滚后 accepted 完整")
	_check(c8b.generation_state == Conversation.GenerationState.FAILED, "T08b FAILED")

	# ---- T09：防御性非法调用不破坏状态 ----
	var c9: RefCounted = Conversation.new()
	_check(c9.retry_or_regenerate_latest() == null, "T09 无 turn 时 retry 返回 null")
	_check(c9.correct_latest("x") == null, "T09 无 turn 时 correction 返回 null")
	c9.begin_turn("防御行动")
	_check(c9.begin_turn("第二条") == null, "T09 STREAMING 中 begin_turn 拒绝")
	_check(c9.retry_or_regenerate_latest() == null, "T09 STREAMING 中 retry 拒绝")
	_check(c9.turns.size() == 1, "T09 未制造多余 turn")
	c9.complete_generation()
	_check(c9.get_accepted_entries().size() == 1, "T09 complete 后仍只有一条 accepted")
	c9.complete_generation()
	_check(String(c9.latest_turn().accepted_gm_text) == "", "T09 非 STREAMING complete 为空操作")
	c9.append_delta("孤儿delta")
	_check(String(c9.latest_turn().draft_text) == "", "T09 非 STREAMING delta 被忽略")

	# ---- T10：correction 作用于从未 completed 的 latest（同一 identity 换文本 retry）----
	var c10: RefCounted = Conversation.new()
	var t10: RefCounted = c10.begin_turn("错字行动")
	c10.cancel_generation()
	var t10c: RefCounted = c10.correct_latest("改正行动")
	_check(t10c == t10, "T10 未 completed latest 的 correction 同一 identity")
	_check(_count_msg(c10.build_provider_messages("SYS"), "user", "改正行动") == 1, "T10 改正文本进入 context 恰好一次")
	_check(_count_msg(c10.build_provider_messages("SYS"), "user", "错字行动") == 0, "T10 旧文本不进 context")
	c10.append_delta("GM改")
	c10.complete_generation()
	_check(String(t10.player_text) == "改正行动" and String(t10.accepted_gm_text) == "GM改", "T10 同一 identity 完成 accepted")

	# ---- T11（IR-03 多 Turn）：regenerate 最新 completed Turn 的 request == previous pairs + current user ----
	var c11: RefCounted = Conversation.new()
	c11.begin_turn("行动一")
	c11.append_delta("GM一")
	c11.complete_generation()
	c11.begin_turn("行动二")
	c11.append_delta("GM二")
	c11.complete_generation()
	c11.retry_or_regenerate_latest()
	var msgs11: Array = c11.build_provider_messages("SYS")
	_check(_roles(msgs11) == ["system", "user", "assistant", "user"], "T11(IR-03) previous pairs 保留且 request 以 current user 结束")
	_check(_count_msg(msgs11, "user", "行动二") == 1, "T11 current player input 恰好一次")
	_check(_count_msg(msgs11, "assistant", "GM二") == 0, "T11 当前 Turn 旧 accepted assistant 不在 request")
	_check(_count_msg(msgs11, "assistant", "GM一") == 1, "T11 previous accepted assistant 正常保留")
	_check(String(c11.latest_turn().accepted_gm_text) == "GM二", "T11 Domain accepted 替换前仍稳定")
	c11.append_delta("GM二改")
	c11.complete_generation()
	_check(String(c11.latest_turn().accepted_gm_text) == "GM二改" and c11.latest_turn().turn_index == 1, "T11 同 identity 原子替换为新 GM")

	print("[g2-04-domain] done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)
