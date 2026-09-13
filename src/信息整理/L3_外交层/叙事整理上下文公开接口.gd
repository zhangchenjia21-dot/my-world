extends RefCounted

const Character := preload("res://src/信息整理/L3_外交层/角色经历投影公开接口.gd")
const People := preload("res://src/信息整理/L3_外交层/人物投影公开接口.gd")
const Threads := preload("res://src/信息整理/L3_外交层/事务投影公开接口.gd")

## Narrative-only current read model。复用已验证历史投影，不接收 UI hide 状态或内部身份。
## 每张卡是独立原子块；语义内容与域内顺序原样保留，Context 只能整块选择。
static func project_session(runtime: Variant) -> Array:
	var current := Character.project_session(runtime)
	var result: Array = []
	var character: Dictionary = current.character
	if not String(character.headline).is_empty() or not String(character.summary).is_empty() or not character.groups.is_empty():
		result.append({"family":"character", "tier":1, "text":"Current Character (current curated state)\n" + JSON.stringify(character)})
	for item: Dictionary in Threads.project_session(runtime):
		result.append({"family":"threads", "tier":1, "text":"Current Open Thread (model-curated unresolved matter)\n" + JSON.stringify(item)})
	for item: Dictionary in current.important_experiences:
		result.append({"family":"experiences", "tier":2, "text":"Important Experience (durable protagonist milestone)\n" + JSON.stringify(item)})
	for item: Dictionary in People.project_session(runtime):
		result.append({"family":"people", "tier":2, "text":"Player-known People (knowledge, memory or reputation; preserve uncertainty; this does not establish World actor existence)\n" + JSON.stringify(item)})
	return result
