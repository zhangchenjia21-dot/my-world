extends SceneTree

## G2-05 Context Assembly focused tests（headless、纯内存、不触网）。
## 覆盖 new/retry/regenerate/correction state matrix、recent-12 完整 Turn 边界、
## Game Context material seam、derived copy 不回写，以及 G2-04 empty-generation 不变量。

const Conversation := preload("res://src/domain/会话.gd")
const ContextAssembler := preload("res://src/context/上下文组装器.gd")

var _failures := 0
var _assembler: RefCounted = ContextAssembler.new()


func _init() -> void:
	_run.call_deferred()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("[g2-05-context] PASS: %s" % label)
	else:
		_failures += 1
		printerr("[g2-05-context] FAIL: %s" % label)


func _complete_turn(conversation: RefCounted, player_text: String, gm_text: String) -> void:
	conversation.begin_turn(player_text)
	conversation.append_delta(gm_text)
	conversation.complete_generation()


func _assemble(conversation: RefCounted, game_context_text: String = "") -> Array:
	return _assembler.assemble_messages(conversation.get_context_projection(), game_context_text)


func _roles(messages: Array) -> Array:
	var roles: Array = []
	for message_value: Variant in messages:
		roles.append(String((message_value as Dictionary).get("role", "")))
	return roles


func _count_message(messages: Array, role: String, content: String) -> int:
	var count := 0
	for message_value: Variant in messages:
		var message := message_value as Dictionary
		if String(message.get("role", "")) == role and String(message.get("content", "")) == content:
			count += 1
	return count


func _count_content_fragment(messages: Array, fragment: String) -> int:
	var count := 0
	for message_value: Variant in messages:
		count += String((message_value as Dictionary).get("content", "")).count(fragment)
	return count


func _player_text(index: int) -> String:
	return "P%02d::完整玩家文本::尾" % index


func _gm_text(index: int) -> String:
	return "G%02d::完整GM文本::尾" % index


func _run() -> void:
	# ---- M1：new turn + short history + empty Game Context ----
	var c1: RefCounted = Conversation.new()
	_complete_turn(c1, "历史一", "GM一")
	_complete_turn(c1, "历史二", "GM二")
	c1.begin_turn("当前行动")
	var m1 := _assemble(c1)
	_check(_roles(m1) == ["system", "user", "assistant", "user", "assistant", "user"], "M1 new/short 保留完整历史并以 user 结束")
	_check(_count_message(m1, "user", "当前行动") == 1, "M1 current user 恰好一次")
	_check(not String((m1[0] as Dictionary).get("content", "")).contains("Current Game Context"), "M1 empty Game Context 省略分节")

	# ---- M2：retry unaccepted latest；partial draft 不进入 request ----
	var c2: RefCounted = Conversation.new()
	_complete_turn(c2, "已接受行动", "已接受GM")
	c2.begin_turn("待重试行动")
	c2.append_delta("取消前 partial draft")
	c2.cancel_generation()
	_check(_count_content_fragment(_assemble(c2), "待重试行动") == 0, "M2 cancelled 非 active Turn 不进入 request")
	c2.retry_or_regenerate_latest()
	var m2 := _assemble(c2)
	_check(_roles(m2) == ["system", "user", "assistant", "user"], "M2 retry request shape 正确")
	_check(_count_message(m2, "user", "待重试行动") == 1, "M2 same pending player 恰好一次")
	_check(_count_content_fragment(m2, "partial draft") == 0, "M2 cancelled partial draft 不进入 context")

	# ---- M3：regenerate completed latest；旧 pair 不进 request、Domain truth 稳定 ----
	var c3: RefCounted = Conversation.new()
	_complete_turn(c3, "前一行动", "前一GM")
	_complete_turn(c3, "当前原行动", "当前旧GM")
	c3.retry_or_regenerate_latest()
	var m3 := _assemble(c3)
	_check(_roles(m3) == ["system", "user", "assistant", "user"], "M3 regenerate 仅 previous pair + current user")
	_check(_count_message(m3, "user", "当前原行动") == 1, "M3 current original player 恰好一次")
	_check(_count_message(m3, "assistant", "当前旧GM") == 0, "M3 current old assistant 被排除")
	_check(String(c3.latest_turn().accepted_gm_text) == "当前旧GM", "M3 replacement 成功前 Domain old accepted 稳定")
	c3.append_delta("当前新GM")
	c3.complete_generation()
	_check(String(c3.latest_turn().accepted_gm_text) == "当前新GM", "M3 regenerate 成功后原子替换")

	# ---- M4：correction completed latest；旧 user/assistant 不进 request，失败回滚 ----
	var c4: RefCounted = Conversation.new()
	_complete_turn(c4, "前文", "前文GM")
	_complete_turn(c4, "旧行动", "旧GM")
	c4.correct_latest("修正行动")
	var m4 := _assemble(c4)
	_check(_roles(m4) == ["system", "user", "assistant", "user"], "M4 correction request shape 正确")
	_check(_count_message(m4, "user", "修正行动") == 1, "M4 corrected player 恰好一次")
	_check(_count_message(m4, "user", "旧行动") == 0 and _count_message(m4, "assistant", "旧GM") == 0, "M4 current old pair 全部排除")
	c4.fail_generation("transport")
	_check(String(c4.latest_turn().player_text) == "旧行动" and String(c4.latest_turn().accepted_gm_text) == "旧GM", "M4 correction fail 回滚旧 accepted pair")

	# ---- M5：20 accepted + new；只保留 indices 8..19 的 12 个完整 Turn ----
	var c5: RefCounted = Conversation.new()
	for index: int in range(20):
		_complete_turn(c5, _player_text(index), _gm_text(index))
	c5.begin_turn("P20::当前行动")
	var m5 := _assemble(c5)
	_check(m5.size() == 26, "M5 system + 12 complete pairs + current user == 26 messages")
	_check(String((m5[1] as Dictionary).get("content", "")) == _player_text(8), "M5 oldest retained index == 8")
	_check(String((m5[24] as Dictionary).get("content", "")) == _gm_text(19), "M5 newest retained assistant index == 19")
	_check(String((m5[-1] as Dictionary).get("content", "")) == "P20::当前行动", "M5 current attempt 永不被窗口丢弃")
	var full_window_ok := true
	for index: int in range(20):
		var expected_count := 1 if index >= 8 else 0
		if _count_message(m5, "user", _player_text(index)) != expected_count or _count_message(m5, "assistant", _gm_text(index)) != expected_count:
			full_window_ok = false
	_check(full_window_ok, "M5 dropped 0..7 / retained 8..19，均以完整 pair 取舍")
	var chronological_ok := true
	for offset: int in range(12):
		var retained_index := offset + 8
		if String((m5[1 + offset * 2] as Dictionary).get("content", "")) != _player_text(retained_index):
			chronological_ok = false
		if String((m5[2 + offset * 2] as Dictionary).get("content", "")) != _gm_text(retained_index):
			chronological_ok = false
	_check(chronological_ok, "M5 retained Turns chronological 且文本未截断")

	# ---- M6：20 accepted + regenerate latest；排除 index19 后保留 7..18 ----
	c5.cancel_generation()
	# 上一个 new Turn 从未 accepted；另建无歧义 fixture，避免 abandoned Turn 干扰 identity 说明。
	var c6: RefCounted = Conversation.new()
	for index: int in range(20):
		_complete_turn(c6, _player_text(index), _gm_text(index))
	c6.retry_or_regenerate_latest()
	var m6 := _assemble(c6)
	_check(String((m6[1] as Dictionary).get("content", "")) == _player_text(7), "M6 regenerate full window oldest retained index == 7")
	_check(_count_message(m6, "assistant", _gm_text(19)) == 0, "M6 current old assistant index19 排除")
	_check(_count_message(m6, "user", _player_text(19)) == 1 and String((m6[-1] as Dictionary).get("role", "")) == "user", "M6 current player index19 恰好一次且最后 role=user")

	# ---- M7：non-empty Game Context 只在 system section 出现一次，不改 Conversation ----
	var fixture := "地点：雨夜茶馆后巷\n当前线索：泥地上的半枚铜扣"
	var projection_before: Dictionary = c6.get_context_projection()
	var m7 := _assemble(c6, fixture)
	var system_content := String((m7[0] as Dictionary).get("content", ""))
	_check(system_content.contains("GM Instructions") and system_content.contains("Current Game Context"), "M7 system 含 GM Instructions 与 Game Context 分节")
	_check(_count_content_fragment(m7, fixture) == 1, "M7 non-empty fixture 在全部 messages 中恰好一次")
	_check(m7.filter(func(value: Variant) -> bool: return String((value as Dictionary).get("role", "")) != "system" and String((value as Dictionary).get("content", "")).contains(fixture)).is_empty(), "M7 fixture 不冒充 user/assistant entry")
	_check(c6.get_context_projection() == projection_before, "M7 assembly 不修改 Conversation projection")
	var empty_system := String((_assemble(c6)[0] as Dictionary).get("content", ""))
	_check(not empty_system.contains("Current Game Context") and not empty_system.contains("G2-05"), "M7 empty production 无 Game Context/工程阶段占位")

	# ---- M8：projection/messages 是 derived copy，调用方修改不能回写 Domain ----
	var c8: RefCounted = Conversation.new()
	_complete_turn(c8, "权威玩家", "权威GM")
	c8.begin_turn("权威pending")
	var projection8: Dictionary = c8.get_context_projection()
	var accepted8 := projection8.get("accepted_turns", []) as Array
	var active8 := projection8.get("active_attempt", {}) as Dictionary
	(accepted8[0] as Dictionary)["player_text"] = "恶意改写"
	active8["player_text"] = "恶意pending"
	var messages8: Array = _assembler.assemble_messages(c8.get_context_projection())
	(messages8[-1] as Dictionary)["content"] = "恶意message"
	_check(String(c8.turns[0].player_text) == "权威玩家" and String(c8.turns[0].accepted_gm_text) == "权威GM", "M8 修改 projection 不回写 accepted truth")
	_check(String(c8.latest_turn().pending_player_text) == "权威pending", "M8 修改 projection/messages 不回写 active attempt")

	# ---- M9：Narrative freedom / empty_generation 回归 + adapter payload 无 output cap ----
	var c9: RefCounted = Conversation.new()
	c9.begin_turn("一字符回应测试")
	c9.append_delta("一")
	c9.complete_generation()
	_check(String(c9.latest_turn().accepted_gm_text) == "一", "M9 一字符非空 GM completion 仍 accepted")
	var c9_empty: RefCounted = Conversation.new()
	c9_empty.begin_turn("空回应测试")
	c9_empty.complete_generation()
	_check(c9_empty.generation_state == Conversation.GenerationState.FAILED and not c9_empty.latest_turn().has_accepted_response, "M9 empty_generation 行为保持")
	_check(ContextAssembler.GM_INSTRUCTIONS.contains("不必刻意简短") and ContextAssembler.GM_INSTRUCTIONS.contains("充分展开"), "M9 GM instructions 保留 Narrative richness")
	var adapter_source := FileAccess.get_file_as_string("res://src/provider/deepseek流式适配器.gd")
	_check(not adapter_source.contains("max_tokens"), "M9 Provider payload 未添加 max_tokens")

	print("[g2-05-context] done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)
