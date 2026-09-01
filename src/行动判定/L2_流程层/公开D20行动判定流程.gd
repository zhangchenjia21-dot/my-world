class_name PublicD20ActionAdjudicationProcess
extends Node

const Rules := preload("res://src/行动判定/L0_公理层/公开D20判定规则.gd")
const Parser := preload("res://src/行动判定/L1_器件层/结构化判定响应解析器.gd")
const RandomSource := preload("res://src/行动判定/L1_器件层/程序D20随机源.gd")
const GameLocalContext := preload("res://src/首次开场/L3_外交层/游戏本地上下文公开接口.gd")
const ContextAssembler := preload("res://src/context/L3_外交层/上下文组装公开接口.gd")
const ProviderAdapter := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")

signal request_assembled(stage, messages)
signal finished(result)

var session_runtime: Variant
var provider_adapter: Node
var random_source: RefCounted
var last_result := {"success": false, "status": "not_started"}

var _parser := Parser.new()
var _projector := GameLocalContext.new()
var _assembler := ContextAssembler.new()
var _stage := ""
var _buffer := ""
var _action_id := ""
var _player_text := ""
var _resolution: Dictionary = {}


func _init(runtime: Variant = null, adapter_override: Node = null, rng_override: RefCounted = null) -> void:
	session_runtime = runtime
	provider_adapter = adapter_override if adapter_override != null else ProviderAdapter.new()
	random_source = rng_override if rng_override != null else RandomSource.new()
	_connect_provider()


func _ready() -> void:
	if provider_adapter != null and provider_adapter.get_parent() == null:
		add_child(provider_adapter)


## 只有 Game-local materialized capability 会启用本流程；无 Expansion 调用方继续走既有单次续玩路径。
func start_action(action_id: String, player_text: String) -> Dictionary:
	var action_validation := Rules.validate_action(action_id, player_text)
	if not action_validation.success:
		return _finish(action_validation)
	if session_runtime == null or not session_runtime.is_ready():
		return _finish(Rules.failure("runtime_not_ready", "Game session 尚未安全打开。"))
	if provider_adapter == null or provider_adapter.is_busy():
		return Rules.failure("generation_active", "Provider 已有 active request。")
	var capability := _materialized_capability()
	if not capability.success:
		return _finish(capability)
	_action_id = action_id
	_player_text = player_text
	var existing := _find_check(action_id)
	var existing_no_check := _find_no_check_action(action_id)
	if existing.success and existing_no_check.success:
		return _finish(Rules.failure("durable_action_identity_conflict", "同一 action_id 同时存在 check 与 NO_CHECK durable truth。"))
	if existing.success:
		if String(existing.check.player_text) != player_text:
			return _finish(Rules.failure("action_payload_conflict", "同一 action_id 已绑定不同 Player action。"))
		_resolution = existing.check.duplicate(true)
		if bool(_resolution.get("narrative_accepted", false)):
			return _finish(Rules.success({"status": "already_accepted", "check": _resolution.duplicate(true)}))
		var recovered := _recover_acceptance_marker(_resolution)
		if recovered.success and bool(recovered.get("recovered", false)):
			_resolution = _find_check(action_id).check
			return _finish(Rules.success({"status": "already_accepted", "check": _resolution.duplicate(true)}))
		if not recovered.success:
			return _finish(recovered)
		return _start_resolution_narrative(capability.expansion)
	if existing_no_check.success:
		var resolution: Dictionary = existing_no_check.resolution
		if String(resolution.player_text) != player_text:
			return _finish(Rules.failure("action_payload_conflict", "同一 action_id 已绑定不同 Player action。"))
		_resolution = resolution.duplicate(true)
		if bool(_resolution.get("narrative_accepted", false)):
			return _finish(Rules.success({"status": "already_accepted", "resolution": _resolution.duplicate(true)}))
		var recovered_no_check := _recover_no_check_acceptance(_resolution)
		if not recovered_no_check.success:
			return _finish(recovered_no_check)
		if bool(recovered_no_check.get("recovered", false)):
			_resolution = _find_no_check_action(action_id).resolution
			return _finish(Rules.success({"status": "already_accepted", "resolution": _resolution.duplicate(true)}))
		_accept_narrative(String(_resolution.narrative), {}, _resolution, 0)
		return last_result.duplicate(true)
	return _start_provider("adjudication", _adjudication_messages(capability.expansion))


func cancel() -> void:
	if provider_adapter != null and provider_adapter.is_busy():
		provider_adapter.cancel()


func _on_delta(text: String) -> void:
	_buffer += text


func _on_completed() -> void:
	if _stage == "adjudication":
		var parsed := _parser.parse(_buffer, _action_id)
		if not parsed.success:
			_finish(parsed)
			return
		if String(parsed.decision) == "NO_CHECK":
			var frozen := _freeze_no_check_resolution(parsed)
			if not frozen.success:
				_finish(frozen)
				return
			_resolution = frozen.resolution
			_accept_narrative(String(_resolution.narrative), {}, _resolution)
			return
		var resolved := _roll_and_persist(parsed.proposal)
		if not resolved.success:
			_finish(resolved)
			return
		_resolution = resolved.check
		var capability := _materialized_capability()
		if not capability.success:
			_finish(capability)
			return
		_start_resolution_narrative(capability.expansion)
		return
	if _stage == "resolution_narrative":
		_accept_narrative(_buffer, _resolution)


func _on_cancelled() -> void:
	_finish(Rules.failure("cancelled", "Provider request 已取消；未接受任何 narrative。"))


func _on_failed(code: String, message: String) -> void:
	_finish(Rules.failure(code, message))


func _roll_and_persist(proposal: Dictionary) -> Dictionary:
	# validate/freeze 完成后才第一次触碰 RNG；duplicate/restart 先查 durable record，不会走到这里。
	var frozen := proposal.duplicate(true)
	var raw_rolls: Array = [random_source.roll_d20()]
	if String(frozen.stance) != "normal":
		raw_rolls.append(random_source.roll_d20())
	var computed := Rules.compute_result(frozen, raw_rolls)
	if not computed.success:
		return computed
	var check := frozen.duplicate(true)
	check.merge(computed, true)
	check["check_id"] = Rules.check_id(String(session_runtime.game_id), _action_id)
	check["player_text"] = _player_text
	check["conversation_base_count"] = session_runtime.conversation.get_durable_accepted_entries().size()
	check["narrative_accepted"] = false
	var next: Dictionary = session_runtime.world_state.duplicate(true)
	var runtime_state: Dictionary = next.get("expansion_runtime", {}).duplicate(true)
	var checks: Array = runtime_state.get("public_d20_checks", []).duplicate(true)
	checks.append(check.duplicate(true))
	runtime_state["public_d20_checks"] = checks
	next["expansion_runtime"] = runtime_state
	var committed: Dictionary = session_runtime.commit_world_mutation_durably(
		"public-d20-" + String(check.check_id), "node-" + String(check.check_id), next
	)
	if not committed.success:
		return Rules.failure("check_persistence_failed", String(committed.get("message", committed.get("status", "unknown"))))
	return Rules.success({"check": check})


func _accept_narrative(
	narrative: String, check: Dictionary, no_check_resolution: Dictionary = {}, provider_calls: int = -1
) -> void:
	if narrative.strip_edges().is_empty():
		_finish(Rules.failure("empty_generation", "Provider narrative 为空。"))
		return
	if session_runtime.conversation.begin_turn(_player_text) == null:
		_finish(Rules.failure("generation_active", "Conversation 无法建立 Player turn。"))
		return
	session_runtime.conversation.append_delta(narrative)
	var accepted: Dictionary = session_runtime.complete_active_generation_durably()
	if not accepted.success:
		_finish(Rules.failure("persistence_failure", String(accepted.get("message", "Narrative 未 durable accept。"))))
		return
	if not check.is_empty():
		var marked := _mark_narrative_accepted(String(check.check_id), int((accepted.accepted_entries as Array).size()) - 1)
		if not marked.success:
			_finish(marked)
			return
	if not no_check_resolution.is_empty():
		var no_check_marked := _mark_no_check_accepted(
			String(no_check_resolution.resolution_id), int((accepted.accepted_entries as Array).size()) - 1
		)
		if not no_check_marked.success:
			_finish(no_check_marked)
			return
	_finish(Rules.success({
		"status": "accepted", "provider_calls": provider_calls if provider_calls >= 0 else (1 if check.is_empty() else 2),
		"check": {} if check.is_empty() else _find_check(_action_id).get("check", {}).duplicate(true),
		"resolution": _find_no_check_action(_action_id).get("resolution", {}).duplicate(true) if not no_check_resolution.is_empty() else {},
	}))


## validated NO_CHECK envelope 必须先于 Conversation durable acceptance 冻结；之后的 retry
## 只消费这里保存的 exact narrative，不再次询问 Provider。
func _freeze_no_check_resolution(parsed: Dictionary) -> Dictionary:
	var resolution := {
		"resolution_id": Rules.no_check_resolution_id(String(session_runtime.game_id), _action_id),
		"action_id": _action_id,
		"player_text": _player_text,
		"branch": "NO_CHECK",
		"reason": String(parsed.reason),
		"narrative": String(parsed.narrative),
		"conversation_base_count": session_runtime.conversation.get_durable_accepted_entries().size(),
		"narrative_accepted": false,
	}
	var next: Dictionary = session_runtime.world_state.duplicate(true)
	var runtime_state: Dictionary = next.get("expansion_runtime", {}).duplicate(true)
	var actions: Array = runtime_state.get("public_d20_no_check_actions", []).duplicate(true)
	actions.append(resolution.duplicate(true))
	runtime_state["public_d20_no_check_actions"] = actions
	next["expansion_runtime"] = runtime_state
	var committed: Dictionary = session_runtime.commit_world_mutation_durably(
		"public-d20-no-check-" + String(resolution.resolution_id),
		"node-no-check-" + String(resolution.resolution_id), next
	)
	if not committed.success:
		return Rules.failure("no_check_persistence_failed", String(committed.get("message", committed.get("status", "unknown"))))
	return Rules.success({"resolution": resolution})


func _mark_no_check_accepted(resolution_id: String, turn_index: int) -> Dictionary:
	var next: Dictionary = session_runtime.world_state.duplicate(true)
	var runtime_state: Dictionary = next.get("expansion_runtime", {}).duplicate(true)
	var actions: Array = runtime_state.get("public_d20_no_check_actions", []).duplicate(true)
	var found := false
	for index: int in actions.size():
		var resolution := (actions[index] as Dictionary).duplicate(true)
		if String(resolution.get("resolution_id", "")) == resolution_id:
			resolution["narrative_accepted"] = true
			resolution["accepted_turn_index"] = turn_index
			actions[index] = resolution
			found = true
			break
	if not found:
		return Rules.failure("no_check_resolution_missing", "无法标记不存在的 durable NO_CHECK resolution。")
	runtime_state["public_d20_no_check_actions"] = actions
	next["expansion_runtime"] = runtime_state
	var committed: Dictionary = session_runtime.commit_world_mutation_durably(
		"public-d20-no-check-accepted-" + resolution_id,
		"node-no-check-accepted-" + resolution_id, next
	)
	if not committed.success:
		return Rules.failure("no_check_acceptance_marker_failed", String(committed.get("message", committed.get("status", "unknown"))))
	return Rules.success()


func _mark_narrative_accepted(check_id: String, turn_index: int) -> Dictionary:
	var next: Dictionary = session_runtime.world_state.duplicate(true)
	var runtime_state: Dictionary = next.get("expansion_runtime", {}).duplicate(true)
	var checks: Array = runtime_state.get("public_d20_checks", []).duplicate(true)
	var found := false
	for index: int in checks.size():
		var check := (checks[index] as Dictionary).duplicate(true)
		if String(check.get("check_id", "")) == check_id:
			check["narrative_accepted"] = true
			check["accepted_turn_index"] = turn_index
			checks[index] = check
			found = true
			break
	if not found:
		return Rules.failure("check_missing", "无法标记不存在的 durable check。")
	runtime_state["public_d20_checks"] = checks
	next["expansion_runtime"] = runtime_state
	var committed: Dictionary = session_runtime.commit_world_mutation_durably(
		"public-d20-narrative-" + check_id, "node-narrative-" + check_id, next
	)
	if not committed.success:
		return Rules.failure("check_acceptance_marker_failed", String(committed.get("message", committed.get("status", "unknown"))))
	return Rules.success()


## Conversation COMMIT 成功而 marker CAS 未返回时，stable check 的 base index 恢复 E 窗口，避免重复 Player turn。
func _recover_acceptance_marker(check: Dictionary) -> Dictionary:
	if not check.has("conversation_base_count"):
		return Rules.success({"recovered": false})
	var index := int(check.conversation_base_count)
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	if entries.size() <= index:
		return Rules.success({"recovered": false})
	var entry := entries[index] as Dictionary
	if String(entry.player_text) != String(check.player_text):
		return Rules.failure("conversation_identity_conflict", "durable check 的 expected Conversation slot 已被其它内容占用。")
	var marked := _mark_narrative_accepted(String(check.check_id), index)
	if not marked.success:
		return marked
	return Rules.success({"recovered": true})


## Window B 只能在 expected slot 的 Player 与 GM 都精确相同时补发 accepted marker；
## 仅匹配 Player text 会把不同 Provider narrative 错认成同一 durable action。
func _recover_no_check_acceptance(resolution: Dictionary) -> Dictionary:
	if not resolution.has("conversation_base_count"):
		return Rules.failure("invalid_no_check_resolution", "durable NO_CHECK resolution 缺少 Conversation identity。")
	var index := int(resolution.conversation_base_count)
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	if entries.size() <= index:
		return Rules.success({"recovered": false})
	var entry := entries[index] as Dictionary
	if String(entry.player_text) != String(resolution.player_text) or String(entry.gm_text) != String(resolution.narrative):
		return Rules.failure("conversation_identity_conflict", "durable NO_CHECK 的 expected Conversation slot 已被其它内容占用。")
	var marked := _mark_no_check_accepted(String(resolution.resolution_id), index)
	if not marked.success:
		return marked
	return Rules.success({"recovered": true})


func _materialized_capability() -> Dictionary:
	var expansions: Array = session_runtime.world_state.get("expansions", [])
	for value: Variant in expansions:
		if not value is Dictionary:
			return Rules.failure("invalid_materialized_capability", "Game-local Expansion materialization 无效。")
		var expansion := value as Dictionary
		if String(expansion.get("capability_slot", "")) == Rules.CAPABILITY_SLOT:
			if String(expansion.get("capability_id", "")) != Rules.CAPABILITY_ID:
				return Rules.failure("unknown_capability", "Host 不支持 Game-local capability_id。")
			return Rules.success({"expansion": expansion})
	return Rules.failure("capability_absent", "本局没有启用 Public d20；继续使用既有 G4-07 单次续玩路径。")


func _find_check(action_id: String) -> Dictionary:
	var runtime_state: Dictionary = session_runtime.world_state.get("expansion_runtime", {})
	for value: Variant in runtime_state.get("public_d20_checks", []):
		if value is Dictionary and String(value.get("action_id", "")) == action_id:
			return Rules.success({"check": _normalize_check(value as Dictionary)})
	return Rules.failure("not_found", "stable action 尚无 durable check。")


func _find_no_check_action(action_id: String) -> Dictionary:
	var runtime_state: Dictionary = session_runtime.world_state.get("expansion_runtime", {})
	for value: Variant in runtime_state.get("public_d20_no_check_actions", []):
		if value is Dictionary and String(value.get("action_id", "")) == action_id:
			return Rules.success({"resolution": _normalize_no_check_resolution(value as Dictionary)})
	return Rules.failure("not_found", "stable action 尚无 durable NO_CHECK resolution。")


func _normalize_no_check_resolution(value: Dictionary) -> Dictionary:
	var resolution := value.duplicate(true)
	for field: String in ["accepted_turn_index", "conversation_base_count"]:
		if resolution.has(field):
			resolution[field] = int(resolution[field])
	return resolution


## JSON document reopen 会把 number 表示为 float；UI-neutral projection 恢复合同要求的整数语义。
func _normalize_check(value: Dictionary) -> Dictionary:
	var check := value.duplicate(true)
	for field: String in ["dc", "modifier", "selected_roll", "total", "accepted_turn_index", "conversation_base_count"]:
		if check.has(field):
			check[field] = int(check[field])
	var raw: Array = []
	for face: Variant in check.get("raw_rolls", []):
		raw.append(int(face))
	check["raw_rolls"] = raw
	return check


func _adjudication_messages(expansion: Dictionary) -> Array:
	var projected := _projector.project(session_runtime.world_state)
	var game_context := String(projected.get("context_text", "")) + "\n\n" + _rules_text(expansion) + "\n\n" + _adjudication_contract()
	return _assembler.assemble_messages(session_runtime.conversation.get_context_projection().merged({
		"active_attempt": {"turn_index": session_runtime.conversation.get_durable_accepted_entries().size(), "player_text": _player_text}
	}, true), game_context)


func _resolution_messages(expansion: Dictionary) -> Array:
	var projected := _projector.project(session_runtime.world_state)
	var authority := "Program 已决定本次结果；不得重掷或改写：\n" + JSON.stringify(_resolution)
	var game_context := String(projected.get("context_text", "")) + "\n\n" + _rules_text(expansion) + "\n\n" + authority + "\n只输出尊重既定 outcome 的 GM narrative，不输出 JSON。"
	return _assembler.assemble_messages(session_runtime.conversation.get_context_projection().merged({
		"active_attempt": {"turn_index": session_runtime.conversation.get_durable_accepted_entries().size(), "player_text": _player_text}
	}, true), game_context)


func _rules_text(expansion: Dictionary) -> String:
	var output := "Materialized Expansion rules:\n"
	for section: Dictionary in expansion.get("semantic_sections", []):
		output += String(section.get("content", "")) + "\n"
	return output


func _adjudication_contract() -> String:
	return "先判断行动是否需要检定。只输出一个 JSON object，不要 Markdown。NO_CHECK: {\"decision\":\"NO_CHECK\",\"reason\":\"...\",\"narrative\":\"...\"}。CHECK_REQUIRED: {\"decision\":\"CHECK_REQUIRED\",\"proposal\":{\"intent\":\"...\",\"dc\":10..30整数,\"modifier\":0..6整数,\"stance\":\"normal|advantage|disadvantage\",\"modifier_reason\":\"...\",\"situation_reason\":\"...\",\"success_intent\":\"...\",\"failure_stakes\":\"...\"}}。不要提供 action_id、骰面、total 或 outcome；stable action identity 由 Program 注入。"


func _start_resolution_narrative(expansion: Dictionary) -> Dictionary:
	return _start_provider("resolution_narrative", _resolution_messages(expansion))


func _start_provider(stage: String, messages: Array) -> Dictionary:
	_stage = stage
	_buffer = ""
	request_assembled.emit(stage, messages.duplicate(true))
	last_result = Rules.success({"status": "streaming", "stage": stage})
	var error: Error = provider_adapter.start_stream(messages)
	if error != OK and String(last_result.get("status", "")) == "streaming":
		return _finish(Rules.failure("provider_start_failure", "Provider request 未能启动。"))
	return last_result.duplicate(true)


func _finish(result: Dictionary) -> Dictionary:
	last_result = result.duplicate(true)
	finished.emit(last_result.duplicate(true))
	return last_result.duplicate(true)


func _connect_provider() -> void:
	if provider_adapter == null:
		return
	provider_adapter.text_delta.connect(_on_delta)
	provider_adapter.completed.connect(_on_completed)
	provider_adapter.cancelled.connect(_on_cancelled)
	provider_adapter.failed.connect(_on_failed)
