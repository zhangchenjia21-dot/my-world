extends SceneTree

# 只执行 current main 的纯结构契约和投影器；不调用 Provider，不创建 Game，不修改生产状态。
const Contract := preload("res://src/信息整理/L0_公理层/信息整理契约.gd")
const View := preload("res://src/信息整理/L1_器件层/角色经历投影器.gd")
var failures := 0

func _initialize() -> void:
	var result := {"character": {"headline": "结构探针", "summary": "仅验证基线存储承载能力", "groups": [{"title": "出身 / 来历", "items": ["有效的有界展示材料"]}]}, "experiences": []}
	check(not Contract.normalize(result).is_empty(), "model-shaped Character result is already valid")
	var record := {"prefix": "", "parent": "", "id": Contract.record_id("", "", result), "result": result}
	var world := {"information_curation": {"schema": Contract.SCHEMA, "turns": {"0": record}}}
	check(Contract.current_records(world, []).is_empty(), "zero accepted turns cannot expose an index-0 baseline")
	world.information_curation.turns = {"-1": record}
	check(Contract.current_records(world, []).is_empty(), "synthetic negative-index baseline is not supported")
	var profile := {"headline": "冻结标题", "summary": "冻结摘要", "groups": [{"title": "原始档案组", "items": ["原始材料"]}]}
	check(View.project(world, [], profile).character.groups.is_empty(), "projection still yields thin fallback for empty history")
	var entries := [{"player_text": "", "gm_text": "真实 opening 示例"}]
	var prefix: String = Contract.prefix_hashes(entries)[0]
	record = {"prefix": prefix, "parent": "", "id": Contract.record_id(prefix, "", result), "result": result}
	world.information_curation.turns = {"0": record}
	check(Contract.current_records(world, entries).size() == 1, "a genuine accepted opening can carry a record structurally")
	world.information_curation["initial"] = record
	check(Contract.current_records(world, entries).is_empty(), "adding initial field requires changing exact owner schema")
	check(not Contract.keys_exact(world.information_curation, ["schema", "turns"]), "existing writer rejects the extended owner shape")
	print("MW-015 R2 ARCHITECTURE GAP REPRODUCED failures=%d" % failures)
	quit(0 if failures == 0 else 1)

func check(condition: bool, text: String) -> void:
	if not condition:
		failures += 1
		push_error("NOT REPRODUCED: " + text)
	else:
		print("OBSERVED: " + text)
