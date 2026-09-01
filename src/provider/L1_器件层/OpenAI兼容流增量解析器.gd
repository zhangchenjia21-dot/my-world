class_name OpenAICompatibleStreamDeltaParser
extends RefCounted


## 只返回 assistant content；reasoning_content/thinking 等 Provider 内部增量不会成为玩家叙事。
func parse_data_payload(payload: String) -> Dictionary:
	if payload == "[DONE]":
		return {"success": true, "kind": "done", "content": ""}
	var parser := JSON.new()
	if parser.parse(payload) != OK or typeof(parser.data) != TYPE_DICTIONARY:
		return {"success": false, "status": "malformed_stream", "message": "收到无法解析的 SSE JSON 数据。"}
	var decoded: Variant = parser.data
	var choices_value: Variant = (decoded as Dictionary).get("choices", [])
	if typeof(choices_value) != TYPE_ARRAY or (choices_value as Array).is_empty():
		return {"success": true, "kind": "ignored", "content": ""}
	var choice_value: Variant = (choices_value as Array)[0]
	if typeof(choice_value) != TYPE_DICTIONARY:
		return {"success": true, "kind": "ignored", "content": ""}
	var delta_value: Variant = (choice_value as Dictionary).get("delta", {})
	if typeof(delta_value) != TYPE_DICTIONARY:
		return {"success": true, "kind": "ignored", "content": ""}
	var content_value: Variant = (delta_value as Dictionary).get("content", "")
	if typeof(content_value) != TYPE_STRING or String(content_value).is_empty():
		return {"success": true, "kind": "ignored", "content": ""}
	return {"success": true, "kind": "content", "content": String(content_value)}
