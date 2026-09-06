extends RefCounted

const Contract := preload("res://src/信息整理/L0_公理层/信息整理契约.gd")
const Bridge := preload("res://src/世界回合/L3_外交层/人物身份桥公开接口.gd")

# 内部按精确身份折叠已验证链；Dictionary 保持首次建卡顺序，更新不重排。
# 回执依赖失效仅跳过该 People 部分，不改写 Character/Experiences 的历史父链。
static func fold(world: Dictionary, game: String, entries: Array) -> Dictionary:
	var people := {}
	var applicable := Bridge.applicable_npc_ids(world, entries)
	for record: Dictionary in Contract.current_records(world, entries):
		var dependency := String(record.get("identity_receipt_id", ""))
		if dependency.is_empty():
			continue
		var receipt := Bridge.receipt_for_history(world, game, entries, record.index)
		if receipt.is_empty() or receipt.id != dependency:
			continue
		var bound := {}
		for binding: Dictionary in receipt.bindings:
			bound[binding.local_character_id] = true
		for update: Dictionary in record.result.people_updates:
			var id: String = update.local_character_id
			if not bound.has(id) or not applicable.has(id):
				continue
			if update.snapshot == null:
				people.erase(id)
			else:
				people[id] = update.snapshot.duplicate(true)
	return people
