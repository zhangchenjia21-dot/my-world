extends RefCounted

const Device := preload("res://src/信息整理/L1_器件层/人物认知投影器.gd")

## 只读当前玩家认知，按首次建卡顺序返回五个展示字段；无身份、出处、存储对象。
## 不访问 Source 或 Provider，Restore/reopen 仅重建当前历史，不找回未来卡片。
static func project_session(runtime: Variant) -> Array:
	if runtime == null or not runtime.is_ready() or runtime.conversation == null:
		return []
	var cards: Array = []
	for snapshot: Dictionary in Device.fold(runtime.world_state, String(runtime.game_id), runtime.conversation.get_durable_accepted_entries()).values():
		cards.append({"display_name": snapshot.display_name, "headline": snapshot.headline,
			"summary": snapshot.summary, "relationship": snapshot.relationship, "details": snapshot.details.duplicate()})
	return cards

## 展示专用键按精确 actor identity + Game 派生；不返回 raw actor ID，不改变既有模型 DTO。
static func project_presented_people(runtime: Variant) -> Array:
	if runtime == null or not runtime.is_ready() or runtime.conversation == null: return []
	var people:=Device.fold(runtime.world_state,String(runtime.game_id),runtime.conversation.get_durable_accepted_entries())
	var cards: Array=[]
	for id: String in people:
		var snapshot: Dictionary=people[id].duplicate(true)
		snapshot["presentation_key"]=JSON.stringify(["people",String(runtime.game_id),id]).sha256_text()
		cards.append(snapshot)
	return cards
