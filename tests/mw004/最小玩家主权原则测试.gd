extends SceneTree

## MW-004 Minimal Player Agency Principle focused test.
## 纯内存、无 Provider、无 Narrative gate；只验证最小 prompt 原则存在且 Narrative freedom 保留。

const ContextAssembler := preload("res://src/context/上下文组装器.gd")

var _failures := 0


func _init() -> void:
	_run.call_deferred()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("[mw-004-player-agency] PASS: %s" % label)
	else:
		_failures += 1
		printerr("[mw-004-player-agency] FAIL: %s" % label)


func _run() -> void:
	var instructions := String(ContextAssembler.GM_INSTRUCTIONS)

	_check(instructions.contains("玩家保有新的、有意义的主角选择"), "通用 Player Agency 原则进入 GM instructions")
	_check(instructions.contains("未被玩家表达") and instructions.contains("当前意图明确蕴含") and instructions.contains("把这个选择留给玩家"), "只保护新的有意义主角选择，不要求逐动作确认")
	_check(instructions.contains("Control mode 为 Light") and instructions.contains("不扩大你替玩家作出有意义主角选择的权限") and instructions.contains("非决定性细节"), "Light 只解释非决定性补足，不扩大代理权限")

	# 防止这次修正反向收紧 Narrative freedom。
	_check(instructions.contains("自由推进场景、人物与世界"), "保留 GM 对场景人物世界的自由推进")
	_check(instructions.contains("充分展开") and instructions.contains("不必刻意简短"), "保留 Narrative richness")

	var assembler: RefCounted = ContextAssembler.new()
	var messages: Array = assembler.assemble_messages({
		"accepted_turns": [],
		"active_attempt": {"turn_index": 0, "player_text": "我继续和荀彧谈田制，不打算离开。"},
	}, "## Game Setup\nControl mode: Light")
	var system_content := String((messages[0] as Dictionary).get("content", ""))
	_check(system_content.contains("玩家保有新的、有意义的主角选择") and system_content.contains("Control mode: Light"), "普通 Light continuation 同时得到原则与真实 mode context")
	_check(messages.size() == 2 and String((messages[1] as Dictionary).get("role", "")) == "user", "不增加 parser/gate/额外协议 message")

	print("[mw-004-player-agency] done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)
