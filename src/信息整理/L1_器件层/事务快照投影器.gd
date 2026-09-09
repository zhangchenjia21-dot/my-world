extends RefCounted

const Contract := preload("res://src/信息整理/L0_公理层/信息整理契约.gd")

## 只折叠已验证的 current lived 链；旧记录/缺失/null 保持，数组完整替换，空数组清空。
## initial 不进入此链，Restore 只由输入的当前 World/Conversation 决定，不访问历史存储。
static func project(world: Dictionary, entries: Array) -> Array:
	var current: Array = []
	for record: Dictionary in Contract.current_records(world, entries):
		var threads: Variant = record.result.get("open_threads")
		if threads != null:
			current = threads.duplicate(true)
	return current
