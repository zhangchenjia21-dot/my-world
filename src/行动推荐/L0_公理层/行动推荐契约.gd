extends RefCounted

## 推荐只具有草稿权；这些界限仅约束机器载荷，不判断策略或语义多样性。
const ACTION_COUNT := 5
const LABEL_CHARACTERS := 48
const DRAFT_CHARACTERS := 400
# 五组 Unicode label/draft 连同 JSON 转义仍有界；输入窗口保持不变。
const RESPONSE_BYTES := 32 * 1024
const INPUT_BYTES := 24 * 1024
const RECENT_TURNS := 4

static func normalize(value: Variant) -> Array:
	if not value is Dictionary or value.size() != 1 or not value.has("actions"):
		return []
	if not value.actions is Array or value.actions.size() != ACTION_COUNT:
		return []
	var actions: Array = []
	var labels: Array[String] = []
	var drafts: Array[String] = []
	for item: Variant in value.actions:
		if not item is Dictionary or item.size() != 2 or not item.has("label") or not item.has("draft"):
			return []
		if not item.label is String or not item.draft is String:
			return []
		var label: String = item.label.strip_edges()
		var draft: String = item.draft.strip_edges()
		if label.is_empty() or label.length() > LABEL_CHARACTERS or labels.has(label):
			return []
		if draft.is_empty() or draft.length() > DRAFT_CHARACTERS or drafts.has(draft):
			return []
		labels.append(label)
		drafts.append(draft)
		# 只规范化首尾空白；内部换行及措辞原样保留，点击使用这一份 exact draft。
		actions.append({"label": label, "draft": draft})
	return actions
