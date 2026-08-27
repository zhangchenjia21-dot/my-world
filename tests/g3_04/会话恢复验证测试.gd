extends SceneTree

const Conversation := preload("res://src/domain/会话.gd")


func _initialize() -> void:
	var conversation := Conversation.new()
	var entries := [
		{"turn_index": 99, "player_text": "行动甲", "gm_text": "回应甲"},
		{"player_text": "行动乙", "gm_text": "回应乙"},
	]
	var validation: Dictionary = conversation.validate_accepted_entries(entries)
	if not validation.ok or validation.accepted_entries.size() != 2 or int(validation.accepted_entries[0].turn_index) != 0:
		return _fail("non-mutating validation/normalization failed: %s" % validation)
	if not conversation.turns.is_empty() or conversation.is_generating():
		return _fail("validation mutated live Conversation")
	if conversation.validate_accepted_entries([{"player_text": "x", "gm_text": "   "}]).ok:
		return _fail("whitespace GM accepted")
	if conversation.validate_accepted_entries([{"player_text": 1, "gm_text": "x"}]).ok:
		return _fail("non-String player accepted")
	if not conversation.restore_accepted_entries(entries).ok:
		return _fail("initial rehydration failed")
	var replacement := [{"player_text": "恢复行动", "gm_text": "恢复回应"}]
	if not conversation.replace_accepted_entries(replacement).ok:
		return _fail("accepted replacement failed")
	var restored: Array = conversation.get_durable_accepted_entries()
	if restored.size() != 1 or String(restored[0].player_text) != "恢复行动":
		return _fail("replacement not exact")
	conversation.begin_turn("生成中")
	if conversation.replace_accepted_entries([]).ok:
		return _fail("active generation replacement was allowed")
	if conversation.get_durable_accepted_entries().size() != 1:
		return _fail("rejected replacement mutated accepted truth")
	print("G3-04 PASS | Conversation validation is non-mutating and replacement is exact/generation-gated")
	quit(0)


func _fail(message: String) -> void:
	push_error("G3-04 DOMAIN FAIL | %s" % message)
	quit(1)
