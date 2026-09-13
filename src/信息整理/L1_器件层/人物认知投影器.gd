extends RefCounted

const Contract := preload("res://src/信息整理/L0_公理层/信息整理契约.gd")
const Bridge := preload("res://src/世界回合/L3_外交层/人物身份桥公开接口.gd")

# 内部按精确身份折叠已验证链；Dictionary 保持首次建卡顺序，更新不重排。
# 回执依赖失效仅跳过该 People 部分，不改写 Character/Experiences 的历史父链。
static func fold(world: Dictionary, game: String, entries: Array) -> Dictionary:
	var snapshots := {}
	var current := subjects(world, game, entries)
	for id: String in current:
		snapshots[id] = current[id].snapshot.duplicate(true)
	return snapshots

## 内部 subject 与 actor link 分离；只有旧记录依赖 actor-bound 建卡前提。
static func subjects(world: Dictionary, game: String, entries: Array) -> Dictionary:
	var people := {}
	var applicable := Bridge.applicable_npc_ids(world, entries)
	for record: Dictionary in Contract.current_records(world, entries):
		var dependency := String(record.get("identity_receipt_id", ""))
		var modern: bool = record.get("schema", "") == Contract.CURRENT_LIVED_SCHEMA
		var receipt := Bridge.receipt_for_history(world, game, entries, record.index)
		var receipt_valid: bool = not receipt.is_empty() and receipt.id == dependency
		if not modern and not receipt_valid: continue
		var bound := {}
		for binding: Dictionary in receipt.get("bindings", []) if receipt_valid else []:
			bound[binding.local_character_id] = true
		for update: Dictionary in record.result.people_updates:
			var id: String = update.subject_id if modern else update.local_character_id
			var actor: String = update.actor_id if modern else id
			var prior_actor: String = people.get(id, {}).get("actor_id", "")
			if not actor.is_empty() and actor != prior_actor and (not bound.has(actor) or not applicable.has(actor)):
				continue
			if update.snapshot == null:
				people.erase(id)
			else:
				people[id] = {"snapshot": update.snapshot.duplicate(true), "actor_id": actor}
	return people
