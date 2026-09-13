extends RefCounted

const Contract := preload("res://src/信息整理/L0_公理层/信息整理契约.gd")

## 公共语义投影保持三个字段；身份只留在内部请求映射和展示专用键。
static func project(world: Dictionary, entries: Array) -> Array:
	var result: Array = []
	for item: Dictionary in fold(world, entries):
		result.append({"title": item.title, "summary": item.summary, "details": item.details.duplicate()})
	return result

## 旧记录的 record+ordinal 仅供首次 transition；未进入新记录前不授予 hide。
static func fold(world: Dictionary, entries: Array) -> Array:
	var current: Array = []
	for record: Dictionary in Contract.current_records(world, entries):
		var threads: Variant = record.result.get("open_threads")
		if threads == null: continue
		current = []
		for index: int in threads.size():
			var item: Dictionary = threads[index].duplicate(true)
			var stable: bool = record.get("schema", "") == Contract.CURRENT_LIVED_SCHEMA
			if not stable:
				item["thread_id"] = JSON.stringify(["legacy-thread", record.id, index]).sha256_text()
			item["hide_eligible"] = stable
			current.append(item)
	return current
