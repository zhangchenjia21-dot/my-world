extends RefCounted

## G2-05 Context Assembly v0.1 —— Provider request material 的唯一组装 owner。
##
## 输入只能是 Conversation / Game owner 提供的只读 projection/material；输出 messages 也是
## 一次性 derived request，不是 Conversation、World 或 Timeline truth，不能反向写回。
## 旧 assemble_messages 保留其它 lane 合同；Narrative 续玩使用下方统一预算工作集。
## 只做结构选择，不 summarize/retrieve，也不限制模型输出长度。

const Accepted := preload("res://src/domain/L3_外交层/已接受输入公开契约.gd")
const OOC_INSTRUCTION := "当前输入模式为 OOC / GM Guidance。请在场外直接回应玩家的节奏、风格或游玩指导，可确认或澄清；不要叙述新世界事件、替主角采取行动或生成检定结果。最近标记为 OOC 的对话是指导而非世界事实；后续角色行动可自然参考这些近期指导。"

const RECENT_ACCEPTED_TURN_LIMIT := 12

const GM_INSTRUCTIONS := "你是 my world 的 AI GM。把玩家输入视为游戏中的自由行动或意图，以自然、沉浸的中文 RPG 叙事回应，自由推进场景、人物与世界。充分展开对当前场景有价值的环境、人物、行动、对话与后果，不必刻意简短；根据场景节奏自然决定叙事篇幅。玩家保有新的、有意义的主角选择：你可以自由推进世界、NPC、场景，以及玩家已表达行动的自然过程与后果，并自然补足不构成选择的细小连接行为；若叙事需要产生一个未被玩家表达、也未由当前意图明确蕴含的新的有意义主角选择，就把这个选择留给玩家。若 Current Game Context 的 Control mode 为 Light，它不扩大你替玩家作出有意义主角选择的权限，只允许更自然地补足不构成选择的非决定性细节。让叙述的语言质感自然服从当前 World、Character 与场景，不要把不同世界统一成同一种通用 RPG 或网文旁白；优先让词汇域、句法节奏、观察重点、人物称谓、对话礼法、制度语言与比喻来源从当前 Game Context 自然长出，同时保持清晰、长期可读。不要为了显得不同而机械堆砌古语、奇幻形容词、固定标签或固定模板。不要输出工程说明，不要解释自己是 AI 或测试程序。"


## 组装 OpenAI-compatible Provider messages。
##
## conversation_projection 必须来自 Conversation.get_context_projection() 的 read model。
## game_context_text 是未来 Game/World owner 提供的非权威请求材料；空值时完全省略分节，
## 不向模型暴露工程阶段占位。函数没有 I/O、副作用或对输入对象的写操作。
func assemble_messages(conversation_projection: Dictionary, game_context_text: String = "") -> Array:
	var messages: Array = [{
		"role": "system",
		"content": _compose_system_content(game_context_text),
	}]

	var active_attempt_value: Variant = conversation_projection.get("active_attempt", null)
	var active_turn_index := -1
	if typeof(active_attempt_value) == TYPE_DICTIONARY:
		active_turn_index = int((active_attempt_value as Dictionary).get("turn_index", -1))

	var eligible_turns: Array = []
	var accepted_value: Variant = conversation_projection.get("accepted_turns", [])
	if typeof(accepted_value) == TYPE_ARRAY:
		var accepted_turns := accepted_value as Array
		for entry_value: Variant in accepted_turns:
			if typeof(entry_value) != TYPE_DICTIONARY:
				continue
			var entry := entry_value as Dictionary
			if int(entry.get("turn_index", -1)) == active_turn_index:
				continue
			eligible_turns.append(entry)

	var first_retained := maxi(0, eligible_turns.size() - RECENT_ACCEPTED_TURN_LIMIT)
	for index: int in range(first_retained, eligible_turns.size()):
		var entry := eligible_turns[index] as Dictionary
		var player_text := String(entry.get("player_text", ""))
		# 首条 GM-only Opening 在 v4 durable pair 中使用空 Player 兼容槽；恢复后不得
		# 把空槽伪装成 Provider-visible user message。
		if not player_text.is_empty():
			messages.append({"role": "user", "content": _mode_content(entry, player_text, false)})
		messages.append({"role": "assistant", "content": _mode_content(entry, String(entry.get("gm_text", "")), true)})

	if typeof(active_attempt_value) == TYPE_DICTIONARY:
		if Accepted.mode(active_attempt_value) == "ooc":
			messages[0].content += "\n\n当前对话：OOC / GM 指导\n" + OOC_INSTRUCTION
		messages.append({
			"role": "user",
			"content": _mode_content(active_attempt_value, String((active_attempt_value as Dictionary).get("player_text", "")), false),
		})

	return messages


## 首次 Opening 不存在 Player action。请求只包含 system-owned setup/context 指令，
## 因此不会为了触发模型而制造或持久化假 Player prompt。
func assemble_first_opening_messages(game_context_text: String) -> Array:
	return [{
		"role": "system",
		"content": _compose_system_content(game_context_text) + "\n\nOpening Directive\n直接以 GM 身份给出本局第一幕。不要声称玩家已经采取了未提供的行动，也不要解释设置或工程过程。",
	}]


func _compose_system_content(game_context_text: String) -> String:
	var content := "GM Instructions\n%s" % GM_INSTRUCTIONS
	if not game_context_text.strip_edges().is_empty():
		content += "\n\nCurrent Game Context\n%s" % game_context_text
	return content

## 仅为 Provider request 派生结构标记，绝不改写 durable accepted 原文。
func _mode_content(entry: Dictionary, text: String, gm: bool) -> String:
	if Accepted.mode(entry) != "ooc": return text
	return text if gm else "OOC / GM 指导\n" + text


## Narrative-only 结构预算：最新一回合 → 各当前域 → 其余近期回合 → 背景。
## 先保障有界当前域，避免任意长 transcript 吃掉所有 P1；域内顺序不重排。
## 所有候选按最终 messages JSON UTF-8 实测，无中途截断、无语义评分、无 I/O。
func assemble_working_set(projection: Dictionary, blocks: Array, metadata: Dictionary) -> Dictionary:
	var started := Time.get_ticks_usec()
	var ceiling := int(metadata.get("token_ceiling", 0))
	if ceiling <= 0:
		return {"success":false, "status":"invalid_context_capacity", "message":"模型上下文容量不可用。"}
	var budget := int(floor(ceiling * 0.80))
	var stats := {"profile_id":metadata.get("profile_id", ""), "context_limit":metadata.get("context_limit", ""), "token_ceiling":ceiling, "safe_input_bytes":budget, "families":{}, "selected_turns":[]}
	var active: Variant = projection.get("active_attempt")
	var required: Array = []
	var optional: Array = []
	for block: Dictionary in blocks:
		if block.tier == 0: required.append(block)
		else: optional.append(block)
	var selected: Array = required.duplicate()
	var turns: Array = []
	var eligible: Array = []
	for entry: Dictionary in projection.get("accepted_turns", []):
		if active is Dictionary and int(entry.turn_index) == int(active.get("turn_index", -1)): continue
		eligible.append(entry)
	var messages := _working_messages(selected, turns, active)
	stats["protocol_and_attempt_bytes"] = _message_bytes(_working_messages([], [], active))
	for block: Dictionary in required: _note_block(stats, block, true)
	if _message_bytes(messages) > budget:
		stats["final_messages_bytes"] = _message_bytes(messages)
		return {"success":false, "status":"required_context_overflow", "message":"必需上下文超出当前模型安全输入预算；未发送模型请求。", "context_stats":stats}
	var candidates: Array = []
	if not eligible.is_empty(): candidates.append({"family":"conversation", "tier":1, "turn":eligible[-1]})
	for block: Dictionary in optional:
		if block.tier == 1: candidates.append(block)
	for index: int in range(eligible.size() - 2, -1, -1):
		candidates.append({"family":"conversation", "tier":1, "turn":eligible[index]})
	for block: Dictionary in optional:
		if block.tier == 2: candidates.append(block)
	for block: Dictionary in candidates:
		var next_blocks := selected.duplicate()
		var next_turns := turns.duplicate()
		if block.has("turn"):
			next_turns.append(block.turn)
			next_turns.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.turn_index) < int(b.turn_index))
		else:
			next_blocks.append(block)
		var candidate := _working_messages(next_blocks, next_turns, active)
		var fits := _message_bytes(candidate) <= budget
		_note_block(stats, block, fits)
		if fits:
			selected = next_blocks
			turns = next_turns
			messages = candidate
	for entry: Dictionary in turns: stats.selected_turns.append(int(entry.turn_index))
	stats["selected_turn_count"] = turns.size()
	stats["selected_turn_range"] = [] if turns.is_empty() else [int(turns[0].turn_index),int(turns[-1].turn_index)]
	stats["final_messages_bytes"] = _message_bytes(messages)
	stats["assembly_usec"] = Time.get_ticks_usec() - started
	return {"success":true, "status":"assembled", "messages":messages, "context_stats":stats}

func _working_messages(blocks: Array, turns: Array, active: Variant) -> Array:
	var texts: Array[String] = []
	for block: Dictionary in blocks:
		if not String(block.text).is_empty(): texts.append(block.text)
	var system := _compose_system_content("\n\n".join(texts))
	if active is Dictionary and Accepted.mode(active) == "ooc":
		system += "\n\n当前对话：OOC / GM 指导\n" + OOC_INSTRUCTION
	var messages: Array = [{"role":"system", "content":system}]
	for entry: Dictionary in turns:
		messages.append_array(_turn_messages(entry))
	if active is Dictionary:
		messages.append({"role":"user", "content":_mode_content(active, String(active.get("player_text", "")), false)})
	return messages

func _turn_messages(entry: Dictionary) -> Array:
	var messages: Array = []
	var player := String(entry.get("player_text", ""))
	if not player.is_empty(): messages.append({"role":"user", "content":_mode_content(entry, player, false)})
	messages.append({"role":"assistant", "content":_mode_content(entry, String(entry.get("gm_text", "")), true)})
	return messages

func _message_bytes(messages: Array) -> int:
	return JSON.stringify(messages).to_utf8_buffer().size()

## 诊断仅统计 family 和容量，不复制正文、ID、ref 或 secret。
func _note_block(stats: Dictionary, block: Dictionary, included: bool) -> void:
	var family: String = block.family
	var counts: Dictionary = stats.families.get(family, {"considered":0,"included":0,"omitted":0,"included_bytes":0,"omitted_bytes":0,"reason":""})
	var bytes := _message_bytes(_turn_messages(block.turn)) if block.has("turn") else JSON.stringify(String(block.text)).to_utf8_buffer().size()
	counts.considered += 1
	counts["included" if included else "omitted"] += 1
	counts["included_bytes" if included else "omitted_bytes"] += bytes
	if not included: counts.reason = "budget"
	stats.families[family] = counts
