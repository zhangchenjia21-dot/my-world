extends RefCounted

## G2-05 Context Assembly v0.1 —— Provider request material 的唯一组装 owner。
##
## 输入只能是 Conversation / Game owner 提供的只读 projection/material；输出 messages 也是
## 一次性 derived request，不是 Conversation、World 或 Timeline truth，不能反向写回。
## 第一代策略只保留最近 12 个完整 accepted Turn，再追加当前 attempt；不截断单条文本、
## 不 summarize/retrieve，也不限制模型输出长度。G7 只有在真实长局证据出现后才重审策略。

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
			messages.append({"role": "user", "content": player_text})
		messages.append({"role": "assistant", "content": String(entry.get("gm_text", ""))})

	if typeof(active_attempt_value) == TYPE_DICTIONARY:
		messages.append({
			"role": "user",
			"content": String((active_attempt_value as Dictionary).get("player_text", "")),
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
