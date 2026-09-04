class_name WorldEvolutionResponseParser
extends RefCounted

const Rules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")


## 只解析 World Evolution evaluator 的 machine data；任何 shape/size 错误都 fail-soft 为
## no-event，绝不产生 fake mutation，也绝不影响已 accepted 的 Narrative / Agency truth。
## 模型不提供 authoritative event/mutation/node ID、优先级分数、事件分类或 Source 出处；
## 未知额外字段一律忽略。
func parse(response_text: String) -> Dictionary:
	var body := _strip_code_fence(response_text.strip_edges())
	if body.is_empty():
		return _failure("empty_evaluation")
	var json := JSON.new()
	if json.parse(body) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return _failure("malformed_evaluation")
	var decision_value: Variant = (json.data as Dictionary).get("decision", null)
	if typeof(decision_value) != TYPE_STRING:
		return _failure("invalid_decision")
	var decision := String(decision_value).strip_edges()
	if decision != "hold" and decision != "advance":
		return _failure("invalid_decision")
	if decision == "hold":
		return {"success": true, "decision": "hold", "event": "", "effects": []}
	var event_value: Variant = (json.data as Dictionary).get("event", null)
	if typeof(event_value) != TYPE_STRING:
		return _failure("invalid_event")
	var event := String(event_value).strip_edges()
	if event.is_empty() or event.length() > Rules.MAX_EVOLUTION_EVENT_CHARS:
		return _failure("invalid_event")
	var effects_value: Variant = (json.data as Dictionary).get("effects", null)
	if typeof(effects_value) != TYPE_ARRAY:
		return _failure("invalid_effects")
	var raw_effects := effects_value as Array
	if raw_effects.is_empty() or raw_effects.size() > Rules.MAX_EVOLUTION_EFFECTS:
		return _failure("invalid_effects")
	var effects: Array = []
	for effect_value: Variant in raw_effects:
		if typeof(effect_value) != TYPE_STRING:
			return _failure("invalid_effects")
		var effect := String(effect_value).strip_edges()
		if effect.is_empty() or effect.length() > Rules.MAX_EVOLUTION_EFFECT_CHARS:
			return _failure("invalid_effects")
		effects.append(effect)
	return {"success": true, "decision": "advance", "event": event, "effects": effects}


func _strip_code_fence(text: String) -> String:
	if not text.begins_with("```"):
		return text
	var first_newline := text.find("\n")
	if first_newline < 0 or not text.ends_with("```"):
		return text
	return text.substr(first_newline + 1, text.length() - first_newline - 4).strip_edges()


func _failure(status: String) -> Dictionary:
	return {"success": false, "status": status, "decision": "", "event": "", "effects": []}
