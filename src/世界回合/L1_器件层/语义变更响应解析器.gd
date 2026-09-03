class_name SemanticChangeResponseParser
extends RefCounted

const Rules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")


## 这里只解析独立分析 lane 的 machine data，不接触或评判玩家可见 Narrative。
## 任一 shape/size 错误均返回 fail-soft 结果，上层不会把部分数据提交为世界事实。
func parse(response_text: String) -> Dictionary:
	var body := _strip_code_fence(response_text.strip_edges())
	if body.is_empty():
		return _failure("empty_analysis")
	var json := JSON.new()
	if json.parse(body) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return _failure("malformed_analysis")
	var changes_value: Variant = (json.data as Dictionary).get("changes", null)
	if typeof(changes_value) != TYPE_ARRAY:
		return _failure("invalid_changes")
	if (changes_value as Array).size() > Rules.MAX_CHANGES_PER_TURN:
		return _failure("too_many_changes")
	var changes: Array = []
	for value: Variant in changes_value as Array:
		if typeof(value) != TYPE_STRING:
			return _failure("invalid_change")
		var change := String(value).strip_edges()
		if change.is_empty() or change.length() > Rules.MAX_CHANGE_CHARS:
			return _failure("invalid_change")
		if not changes.has(change):
			changes.append(change)
	var result := {
		"success": true,
		"status": "no_changes" if changes.is_empty() else "changes_ready",
		"changes": changes,
	}
	# G5-02M1：knowledge_events 是独立可选字段；其解析失败绝不 invalidate 已有效的 changes。
	var knowledge := parse_knowledge_events((json.data as Dictionary).get("knowledge_events", null))
	result["knowledge_events"] = knowledge.events
	result["knowledge_dropped"] = knowledge.dropped
	# G5-03M1：agency_candidates 是独立可选字段；其解析失败绝不 invalidate 已有效的 changes/knowledge。
	var agency := parse_agency_candidates((json.data as Dictionary).get("agency_candidates", null))
	result["agency_candidates"] = agency.candidates
	result["agency_dropped"] = agency.dropped
	return result


## agency_candidates 解析与 changes/knowledge 完全隔离：absent/invalid/oversized 均 fail-soft 为空，
## 绝不让 agency 字段错误破坏 otherwise valid 的 G5-01/G5-02 结果。
func parse_agency_candidates(value: Variant) -> Dictionary:
	if value == null:
		return {"candidates": [], "dropped": 0}
	if typeof(value) != TYPE_ARRAY:
		return {"candidates": [], "dropped": 1}
	var candidates: Array = []
	var dropped := 0
	for candidate_value: Variant in value as Array:
		if typeof(candidate_value) != TYPE_STRING:
			dropped += 1
			continue
		var candidate := String(candidate_value).strip_edges()
		if candidate.is_empty() or candidate.length() > 128:
			dropped += 1
			continue
		if not candidates.has(candidate):
			candidates.append(candidate)
	return {"candidates": candidates, "dropped": dropped}


## knowledge_events 解析与 changes 完全隔离：absent/invalid/oversized 均 fail-soft 为空，
## 绝不让 knowledge 字段错误破坏 otherwise valid 的 G5-01 changes 结果。
func parse_knowledge_events(value: Variant) -> Dictionary:
	if value == null:
		return {"events": [], "dropped": 0}
	if typeof(value) != TYPE_ARRAY:
		return {"events": [], "dropped": 1}
	var events: Array = []
	var dropped := 0
	for event_value: Variant in value as Array:
		if typeof(event_value) != TYPE_DICTIONARY:
			dropped += 1
			continue
		var event := (event_value as Dictionary).duplicate(true)
		if not Rules.knowledge_event_is_valid(event):
			dropped += 1
			continue
		event["knower_id"] = String(event.knower_id).strip_edges()
		event["fact"] = String(event.fact).strip_edges()
		events.append(event)
		if events.size() >= Rules.MAX_KNOWLEDGE_EVENTS_PER_TURN:
			dropped += 1
			break
	return {"events": events, "dropped": dropped}


func _strip_code_fence(text: String) -> String:
	if not text.begins_with("```"):
		return text
	var first_newline := text.find("\n")
	if first_newline < 0 or not text.ends_with("```"):
		return text
	return text.substr(first_newline + 1, text.length() - first_newline - 4).strip_edges()


func _failure(status: String) -> Dictionary:
	return {"success": false, "status": status, "changes": []}
