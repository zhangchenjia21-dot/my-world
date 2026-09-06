extends RefCounted

## 推荐只具有草稿权；这些界限仅约束机器载荷，不判断策略或语义多样性。
const ACTION_COUNT := 5
const ACTION_CHARACTERS := 240
const RESPONSE_BYTES := 8 * 1024
const INPUT_BYTES := 24 * 1024
const RECENT_TURNS := 4

static func normalize(value: Variant) -> Array:
	if not value is Dictionary or value.size() != 1 or not value.has("actions"):
		return []
	if not value.actions is Array or value.actions.size() != ACTION_COUNT:
		return []
	var actions: Array = []
	for item: Variant in value.actions:
		if not item is String:
			return []
		var action: String = item.strip_edges()
		if action.is_empty() or action.length() > ACTION_CHARACTERS or actions.has(action):
			return []
		actions.append(action)
	return actions
