extends RefCounted

const Rules := preload("res://src/行动判定/L0_公理层/公开D20判定规则.gd")
const RECENT_LIMIT := 12

## 只读当前 durable World + accepted Conversation；沿用既有检定接受身份，不创建新 currentness owner。
## 输出白名单字段，不携带原记录、身份或控制材料。Restore 的成对状态由调用方提供。
static func _current_records(world_state: Dictionary, entries: Array) -> Array:
	var records: Array = []
	var no_checks: Array = world_state.get("expansion_runtime", {}).get("public_d20_no_check_actions", [])
	for index: int in entries.size():
		var entry: Dictionary = entries[index]
		if String(entry.get("input_mode", "action")) != "action" or String(entry.get("player_text", "")).is_empty():
			continue
		var check := Rules.matching_accepted_check_for_turn(world_state, index, String(entry.player_text))
		var matches: Array = []
		for value: Dictionary in no_checks:
			if bool(value.get("narrative_accepted", false)) and int(value.get("accepted_turn_index", -1)) == index and String(value.get("player_text", "")) == String(entry.player_text) and String(value.get("narrative", "")) == String(entry.gm_text):
				matches.append(value)
		# 同一位置出现冲突分支时不猜；未接受、被替换、OOC 记录不成为上下文事实。
		if not check.is_empty() and matches.is_empty():
			var public := {"accepted_turn": index + 1, "branch": "CHECK"}
			for field: String in ["intent", "dc", "modifier", "stance", "selected_roll", "total", "outcome", "success_intent", "failure_stakes", "raw_rolls", "modifier_reason", "situation_reason"]:
				if check.has(field): public[field] = check[field]
			records.append(public)
		elif check.is_empty() and matches.size() == 1:
			records.append({"accepted_turn": index + 1, "branch": "NO_CHECK", "reason": String(matches[0].get("reason", ""))})
	return records

## GM continuity 保持原字段、顺序与最近12条（包含 NO_CHECK），与 System 共用唯一筛选。
static func project(world_state: Dictionary, entries: Array) -> String:
	var records := _current_records(world_state, entries)
	for record: Dictionary in records:
		for field: String in ["raw_rolls", "modifier_reason", "situation_reason"]:
			record.erase(field)
	if records.is_empty():
		return ""
	return "Public Mechanics — 已接受的公开机制事实\n以下是已向玩家公开的 Program 结果，不得否认、重掷或忽略既定结果与风险。失败后可以通过新行动获得转机，但必须作为失败之后的发展。\n" + JSON.stringify(records.slice(maxi(0, records.size() - RECENT_LIMIT)))

## 玩家只看真实 CHECK，最近优先；白名单副本不含 owner identity/control 或 NO_CHECK。
static func project_checks(world_state: Dictionary, entries: Array) -> Array:
	var checks: Array = []
	var records := _current_records(world_state, entries)
	records.reverse()
	for record: Dictionary in records:
		if record.branch != "CHECK": continue
		record.erase("branch")
		checks.append(record.duplicate(true))
		if checks.size() == RECENT_LIMIT: break
	return checks
