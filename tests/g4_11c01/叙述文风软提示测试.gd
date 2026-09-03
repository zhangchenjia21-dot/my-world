extends SceneTree

## G4-11C01 只验证共享创作提示的投影，不对模型叙事输出设置格式、词汇或风格门槛。

const ContextAssembler := preload("res://src/context/上下文组装器.gd")

const VOICE_GUIDANCE := "让叙述的语言质感自然服从当前 World、Character 与场景"
const ANTI_TEMPLATE_GUIDANCE := "不要为了显得不同而机械堆砌古语、奇幻形容词、固定标签或固定模板"

var _failures := 0


func _init() -> void:
	_run.call_deferred()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("[g4-11c01-voice] PASS: %s" % label)
	else:
		_failures += 1
		printerr("[g4-11c01-voice] FAIL: %s" % label)


func _run() -> void:
	var assembler := ContextAssembler.new()
	var game_context := "当前地点：测试场景\n当前角色：测试角色"
	var continuation: Array = assembler.assemble_messages({
		"accepted_turns": [],
		"active_attempt": {"turn_index": 0, "player_text": "观察四周"},
	}, game_context)
	var opening: Array = assembler.assemble_first_opening_messages(game_context)

	var continuation_system := String((continuation[0] as Dictionary).get("content", ""))
	var opening_system := String((opening[0] as Dictionary).get("content", ""))
	_check(continuation_system.contains(VOICE_GUIDANCE), "ordinary continuation system message 包含共享叙述文风软提示")
	_check(opening_system.contains(VOICE_GUIDANCE), "first Opening system message 包含共享叙述文风软提示")
	_check(continuation_system.count(VOICE_GUIDANCE) == 1 and opening_system.count(VOICE_GUIDANCE) == 1, "两个路径均只投影一次共享软提示")
	_check(continuation_system.contains(ANTI_TEMPLATE_GUIDANCE) and opening_system.contains(ANTI_TEMPLATE_GUIDANCE), "两个路径均保留反机械堆砌与反固定模板边界")
	_check(continuation_system.contains(game_context) and opening_system.contains(game_context), "软提示继续与当前 Game Context 同时投影")
	_check(opening.size() == 1 and String((opening[0] as Dictionary).get("role", "")) == "system", "Opening 仍为单一 GM-only system message")
	_check(not ContextAssembler.GM_INSTRUCTIONS.contains("汉末三国") and not ContextAssembler.GM_INSTRUCTIONS.contains("埃瑟维亚") and not ContextAssembler.GM_INSTRUCTIONS.contains("刘备") and not ContextAssembler.GM_INSTRUCTIONS.contains("莉维娅"), "共享生产提示未硬编码两族名称")

	print("[g4-11c01-voice] done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)
