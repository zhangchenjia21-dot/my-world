extends SceneTree

# cbe0f12 保存原 gap 复现；当前探针验证裁定后的兼容性，原日志仍为历史证据。
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
	check(Contract.current_records(world, entries).size() == 1, "optional initial does not invalidate original turn chain")
	check(Contract.owner_valid(world.information_curation), "writer accepts backward-compatible optional initial")
	print("MW-015 R2 ARCHITECTURE GAP RESOLVED failures=%d" % failures)
	quit(0 if failures == 0 else 1)

func check(condition: bool, text: String) -> void:
	if not condition:
		failures += 1
		push_error("FAILED: " + text)
	else:
		print("OBSERVED: " + text)
