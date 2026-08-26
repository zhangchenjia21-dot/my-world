extends RefCounted

## G2-05 Context Assembly v0.1 —— Provider request material 的唯一组装 owner。
##
## 输入只能是 Conversation / Game owner 提供的只读 projection/material；输出 messages 也是
## 一次性 derived request，不是 Conversation、World 或 Timeline truth，不能反向写回。
## 第一代策略只保留最近 12 个完整 accepted Turn，再追加当前 attempt；不截断单条文本、
## 不 summarize/retrieve，也不限制模型输出长度。G7 只有在真实长局证据出现后才重审策略。

const RECENT_ACCEPTED_TURN_LIMIT := 12

const GM_INSTRUCTIONS := "你是 my world 的 AI GM。把玩家输入视为游戏中的自由行动或意图，以自然、沉浸的中文 RPG 叙事回应，自由推进场景、人物与世界。充分展开对当前场景有价值的环境、人物、行动、对话与后果，不必刻意简短；根据场景节奏自然决定叙事篇幅。不要输出工程说明，不要解释自己是 AI 或测试程序。"


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
		messages.append({"role": "user", "content": String(entry.get("player_text", ""))})
		messages.append({"role": "assistant", "content": String(entry.get("gm_text", ""))})

	if typeof(active_attempt_value) == TYPE_DICTIONARY:
		messages.append({
			"role": "user",
			"content": String((active_attempt_value as Dictionary).get("player_text", "")),
		})

	return messages


func _compose_system_content(game_context_text: String) -> String:
	var content := "GM Instructions\n%s" % GM_INSTRUCTIONS
	if not game_context_text.strip_edges().is_empty():
		content += "\n\nCurrent Game Context\n%s" % game_context_text
	return content
