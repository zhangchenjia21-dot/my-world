class_name PublicD20AdjudicationRules
extends RefCounted

const CAPABILITY_ID := "action_check.public_d20.v1"
const CAPABILITY_SLOT := "action_resolution"
const STANCES := ["normal", "advantage", "disadvantage"]
const PROPOSAL_FIELDS := [
	"action_id", "intent", "dc", "modifier", "stance", "modifier_reason",
	"situation_reason", "success_intent", "failure_stakes",
]
const PROVIDER_PROPOSAL_FIELDS := [
	"intent", "dc", "modifier", "stance", "modifier_reason", "situation_reason",
	"success_intent", "failure_stakes",
]


static func success(values: Dictionary = {}) -> Dictionary:
	var result := {"success": true}
	result.merge(values, true)
	return result


static func failure(code: String, message: String) -> Dictionary:
	return {"success": false, "code": code, "message": message}


static func validate_action(action_id: String, player_text: String) -> Dictionary:
	if action_id.strip_edges().is_empty() or action_id.length() > 128:
		return failure("invalid_action_id", "action_id 必须是长度不超过 128 的稳定非空 identity。")
	if player_text.strip_edges().is_empty():
		return failure("invalid_player_action", "Player action 不能为空。")
	return success()


## Control lane 只拥有分支与提案；player-visible narrative 永远不属于此 structured object。
static func validate_envelope(value: Variant, expected_action_id: String) -> Dictionary:
	if not value is Dictionary:
		return failure("invalid_adjudication_envelope", "判定 control 必须是 JSON object。")
	var envelope := value as Dictionary
	var decision := String(envelope.get("decision", ""))
	if decision == "NO_CHECK":
		if not _exact_fields(envelope, ["decision", "reason"]):
			return failure("invalid_adjudication_envelope", "NO_CHECK control 只允许 decision/reason。")
		if not envelope.reason is String or String(envelope.reason).strip_edges().is_empty():
			return failure("invalid_adjudication_envelope", "NO_CHECK reason 不能为空。")
		return success({"decision": decision, "reason": String(envelope.reason)})
	if decision != "CHECK_REQUIRED" or not _exact_fields(envelope, ["decision", "proposal"]):
		return failure("invalid_adjudication_envelope", "decision 必须是 NO_CHECK 或 CHECK_REQUIRED。")
	if not envelope.proposal is Dictionary or not _exact_fields(envelope.proposal, PROVIDER_PROPOSAL_FIELDS):
		return failure("invalid_check_proposal", "Provider Check Proposal 字段集无效；action_id 由 Program 拥有。")
	var program_bound := (envelope.proposal as Dictionary).duplicate(true)
	program_bound["action_id"] = expected_action_id
	var validated := validate_proposal(program_bound, expected_action_id)
	if not validated.success:
		return validated
	return success({"decision": decision, "proposal": validated.proposal})


static func validate_proposal(value: Variant, expected_action_id: String) -> Dictionary:
	if not value is Dictionary or not _exact_fields(value, PROPOSAL_FIELDS):
		return failure("invalid_check_proposal", "Check Proposal 字段集无效。")
	var proposal := value as Dictionary
	if String(proposal.action_id) != expected_action_id:
		return failure("action_identity_mismatch", "Proposal action_id 与 stable action identity 不一致。")
	for field: String in ["intent", "modifier_reason", "situation_reason", "success_intent", "failure_stakes"]:
		if not proposal[field] is String or String(proposal[field]).strip_edges().is_empty():
			return failure("invalid_check_proposal", "Proposal 文本字段不能为空：%s" % field)
	if not _is_json_integer(proposal.dc) or int(proposal.dc) < 10 or int(proposal.dc) > 30:
		return failure("invalid_check_proposal", "DC 必须是 10..30 的整数。")
	if not _is_json_integer(proposal.modifier) or int(proposal.modifier) < 0 or int(proposal.modifier) > 6:
		return failure("invalid_check_proposal", "modifier 必须是 0..6 的整数。")
	if not String(proposal.stance) in STANCES:
		return failure("invalid_check_proposal", "stance 必须是 normal/advantage/disadvantage。")
	var normalized := proposal.duplicate(true)
	normalized.dc = int(proposal.dc)
	normalized.modifier = int(proposal.modifier)
	return success({"proposal": normalized})


static func compute_result(proposal: Dictionary, raw_rolls: Array) -> Dictionary:
	var count := 1 if String(proposal.stance) == "normal" else 2
	if raw_rolls.size() != count:
		return failure("invalid_program_roll", "Program RNG 骰面数量与 stance 不一致。")
	for face: Variant in raw_rolls:
		if not face is int or int(face) < 1 or int(face) > 20:
			return failure("invalid_program_roll", "Program RNG 骰面必须是 1..20 整数。")
	var selected := int(raw_rolls[0])
	if String(proposal.stance) == "advantage":
		selected = maxi(int(raw_rolls[0]), int(raw_rolls[1]))
	elif String(proposal.stance) == "disadvantage":
		selected = mini(int(raw_rolls[0]), int(raw_rolls[1]))
	var total := selected + int(proposal.modifier)
	return success({
		"raw_rolls": raw_rolls.duplicate(), "selected_roll": selected, "total": total,
		"outcome": "success" if total >= int(proposal.dc) else "failure",
	})


static func check_id(game_id: String, action_id: String) -> String:
	return _stable_action_identity("check", game_id, action_id)


## MW-006：accepted Conversation turn → durable CHECK_REQUIRED resolution 的只读取回。
## 只有 acceptance marker 完整建立（narrative_accepted + accepted_turn_index + player_text
## 全部一致）的 check 才是该 turn 的权威 mechanical resolution；命中 0 个或多个都返回空
## 字典——调用方据此 fail-soft 跳过 grounding，不伪造、不猜测 mechanics truth。
static func matching_accepted_check_for_turn(world_state: Dictionary, turn_index: int, player_text: String) -> Dictionary:
	if turn_index < 0 or player_text.strip_edges().is_empty():
		return {}
	var runtime_state_value: Variant = world_state.get("expansion_runtime", {})
	if typeof(runtime_state_value) != TYPE_DICTIONARY:
		return {}
	var checks_value: Variant = (runtime_state_value as Dictionary).get("public_d20_checks", [])
	if typeof(checks_value) != TYPE_ARRAY:
		return {}
	var matched := {}
	for value: Variant in checks_value as Array:
		if not value is Dictionary:
			continue
		var check := value as Dictionary
		if not bool(check.get("narrative_accepted", false)):
			continue
		var index_value: Variant = check.get("accepted_turn_index", -1)
		if typeof(index_value) not in [TYPE_INT, TYPE_FLOAT] or float(index_value) != float(int(index_value)):
			continue
		if int(index_value) != turn_index or String(check.get("player_text", "")) != player_text:
			continue
		if not matched.is_empty():
			return {}
		matched = _normalize_durable_check(check)
	return matched


## durable check 的 UI-neutral 整数投影；SQLite JSON round-trip 会把 number 恢复为 float。
static func _normalize_durable_check(value: Dictionary) -> Dictionary:
	var check := value.duplicate(true)
	for field: String in ["dc", "modifier", "selected_roll", "total", "accepted_turn_index", "conversation_base_count"]:
		if check.has(field) and typeof(check[field]) in [TYPE_INT, TYPE_FLOAT]:
			check[field] = int(check[field])
	var raw: Array = []
	for face: Variant in check.get("raw_rolls", []):
		if typeof(face) in [TYPE_INT, TYPE_FLOAT]:
			raw.append(int(face))
	check["raw_rolls"] = raw
	return check


## NO_CHECK 与真实检定共享 caller-owned action identity，但保留独立 durable 类型，
## 避免用虚构骰面把非检定行动伪装成 check。
static func no_check_resolution_id(game_id: String, action_id: String) -> String:
	return _stable_action_identity("no-check", game_id, action_id)


static func _stable_action_identity(prefix: String, game_id: String, action_id: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update((game_id + "\u001f" + action_id).to_utf8_buffer())
	return prefix + "-" + context.finish().hex_encode()


static func _exact_fields(value: Dictionary, fields: Array) -> bool:
	if value.size() != fields.size():
		return false
	for field: String in fields:
		if not value.has(field):
			return false
	return true


## Godot JSON 按 float 解析数字；只接受数值上无小数的 JSON number，并规范化为 int。
static func _is_json_integer(value: Variant) -> bool:
	return value is int or (value is float and is_equal_approx(float(value), floorf(float(value))))
