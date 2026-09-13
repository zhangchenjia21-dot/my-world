extends RefCounted

const Device := preload("res://src/信息整理/L1_器件层/事务快照投影器.gd")

## 当前玩家安全事务快照，仅 title/summary/details；无 ID/回执/hash 或 raw World。
## 纯读取，不调用 Provider、不回扫 Source、不改变任何持久状态。
static func project_session(runtime: Variant) -> Array:
	if runtime == null or not runtime.is_ready() or runtime.conversation == null:
		return []
	return Device.project(runtime.world_state, runtime.conversation.get_durable_accepted_entries())

## 展示键来自已进入 v0.4 的 stable Thread；旧快照只读展示，不凭文本生成 hide 身份。
static func project_presented_threads(runtime: Variant) -> Array:
	if runtime == null or not runtime.is_ready() or runtime.conversation == null: return []
	var result: Array = []
	for item: Dictionary in Device.fold(runtime.world_state, runtime.conversation.get_durable_accepted_entries()):
		var snapshot := {"title": item.title, "summary": item.summary, "details": item.details.duplicate()}
		if item.hide_eligible:
			snapshot["presentation_key"] = JSON.stringify(["thread", String(runtime.game_id), item.thread_id]).sha256_text()
		result.append(snapshot)
	return result
