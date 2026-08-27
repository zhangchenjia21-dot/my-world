extends SceneTree

const Conversation := preload("res://src/domain/会话.gd")

var _failures := 0


func _initialize() -> void:
	var conversation := Conversation.new()
	_check(conversation.restore_accepted_entries([
		{"player_text": "行动一", "gm_text": "回应一"},
		{"player_text": "行动二", "gm_text": "回应二"},
	]).ok, "rehydrate accepted pairs")
	_check(conversation.get_accepted_entries().size() == 2, "rehydrate exact count")
	_check(conversation.generation_state == Conversation.GenerationState.COMPLETED and not conversation.is_generating(), "rehydrate has no active generation")
	_check(int(conversation.get_accepted_entries()[1].turn_index) == 1, "rehydrate rebuilds turn_index 0..N-1")

	conversation.begin_turn("行动三")
	conversation.append_delta("回应三")
	var new_candidate: Dictionary = conversation.get_completion_candidate()
	_check(new_candidate.ok and new_candidate.accepted_entries.size() == 3, "new Turn candidate appends")
	_check(conversation.get_accepted_entries().size() == 2, "candidate is non-mutating")
	conversation.complete_generation()

	conversation.retry_or_regenerate_latest()
	conversation.append_delta("回应三新版")
	var regenerate_candidate: Dictionary = conversation.get_completion_candidate()
	_check(regenerate_candidate.ok and regenerate_candidate.accepted_entries.size() == 3, "regenerate candidate keeps Turn count")
	_check(String(regenerate_candidate.accepted_entries[2].gm_text) == "回应三新版", "regenerate candidate replaces latest GM")
	_check(String(conversation.get_accepted_entries()[2].gm_text) == "回应三", "old GM stable before acceptance")
	conversation.complete_generation()

	conversation.correct_latest("行动三修正")
	conversation.append_delta("回应三修正")
	var correction_candidate: Dictionary = conversation.get_completion_candidate()
	_check(correction_candidate.accepted_entries.size() == 3, "correction candidate keeps Turn count")
	_check(String(correction_candidate.accepted_entries[2].player_text) == "行动三修正", "correction candidate replaces player")
	_check(String(conversation.get_accepted_entries()[2].player_text) == "行动三", "old pair stable before correction acceptance")

	var empty := Conversation.new()
	empty.begin_turn("空完成")
	var empty_candidate: Dictionary = empty.get_completion_candidate()
	_check(not empty_candidate.ok and empty_candidate.code == "empty_generation", "whitespace/empty draft has no candidate")
	_check(not empty.restore_accepted_entries([]).ok, "rehydration refuses non-empty active Conversation")

	var invalid := Conversation.new()
	_check(not invalid.restore_accepted_entries([{"player_text": "x", "gm_text": "   "}]).ok, "rehydration rejects empty GM truth")

	print("G3-03 DOMAIN | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G3-03 DOMAIN PASS | %s" % label)
	else:
		_failures += 1
		push_error("G3-03 DOMAIN FAIL | %s" % label)
