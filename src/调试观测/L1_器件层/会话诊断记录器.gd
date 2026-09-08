extends RefCounted

const Contract := preload("res://src/调试观测/L0_公理层/诊断展示契约.gd")
var records: Array = []

## 版本键仅存于内存；snapshot 只返回 row 副本，不能把 opaque token 交给叶 UI。
func put(token: Dictionary, row: Dictionary, replace: bool = true) -> void:
	if row.is_empty(): return
	if replace:
		for i: int in range(records.size() - 1, -1, -1):
			if records[i].token == token and records[i].row.lane == row.lane:
				records.remove_at(i)
				break
	records.append({"token": token.duplicate(), "row": row.duplicate(true)})
	while records.size() > Contract.CAPACITY: records.pop_front()

func retain_current(current: Callable) -> void:
	records = records.filter(func(item: Dictionary) -> bool: return current.call(item.token))

func snapshot() -> Array:
	var rows: Array = []
	for item: Dictionary in records: rows.append(item.row.duplicate(true))
	return rows

func clear() -> void:
	records.clear()
