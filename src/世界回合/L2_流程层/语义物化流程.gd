class_name SemanticMaterializationProcess
extends Node

const Rules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")
const Parser := preload("res://src/世界回合/L1_器件层/语义变更响应解析器.gd")
const ProviderAdapter := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")

signal analysis_requested(turn_index, messages)
signal finished(result)

const ANALYSIS_INSTRUCTIONS := "你是 my world 的后台语义物化器。只根据已经接受的玩家行动与 GM 叙事，提取三类 durable 事实：\n1. changes：叙事中已经明确成立、值得跨句持续的世界后果。\n2. knowledge_events：叙事明确建立给特定 stable actor 的 post-T0 新知识。只提取该 accepted turn 新建立的、有明确根据的知识；不要因为事实在叙事中为真就授予知识；不要因为某 NPC 在阵容中就推断其知情；不要编造未知 actor/ID；不要输出推理过程。\n3. agency_candidates：当前叙事后，哪些 Eligible Agency Actors 有合理理由立即独立行动。只从 Eligible Agency Actors 列表选择；只根据该 actor 自己的 Source、知识与历史判断；不要因为 GM 知道某事实就推断该 actor 知情；不要选择 Player；不要编造列表之外的 ID。\n只输出一个 JSON 对象：{\"changes\":[\"简洁的持久后果\"],\"knowledge_events\":[{\"knower_id\":\"stable-local-id\",\"fact\":\"简洁事实\",\"basis\":\"witnessed|told|discovered|participated\"}],\"agency_candidates\":[\"stable-npc-id\"]}；没有持久后果时 changes=[]；没有新知识时 knowledge_events=[]；没有 actor 需要行动时 agency_candidates=[]。knower_id 与 agency_candidates 必须且只能来自各自 Allowed 列表。不要输出解释、Markdown 或推理过程。"

var session_runtime: Variant = null
var provider_adapter: Node = null
var last_result: Dictionary = {"success": true, "status": "idle"}
var analysis_attempt_count := 0

var _parser := Parser.new()
var _queue: Array = []
var _attempted_versions: Dictionary = {}
var _active: Dictionary = {}
var _response_text := ""
var _shutting_down := false


func _init(runtime: Variant = null, adapter_override: Node = null) -> void:
	session_runtime = runtime
	provider_adapter = adapter_override if adapter_override != null else ProviderAdapter.new()
	_connect_provider()
	_connect_conversation()


func _ready() -> void:
	if provider_adapter != null and provider_adapter.get_parent() == null:
		add_child(provider_adapter)


## 测试/未来 observability 可读取稳定终态；不返回 raw request、response 或 credential。
func status_snapshot() -> Dictionary:
	return {
		"last_result": last_result.duplicate(true),
		"analysis_attempt_count": analysis_attempt_count,
		"queued_count": _queue.size(),
		"busy": not _active.is_empty(),
	}


## 显式 replay seam 只重新考虑当前 latest accepted 版本；同内容已尝试或已提交时
## 不会再发 Provider 请求。Production 正常路径由 durable completion signal 触发。
func consider_latest_accepted_turn() -> Dictionary:
	if session_runtime == null or session_runtime.conversation == null:
		return _publish({"success": false, "status": "runtime_not_ready"})
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	if entries.is_empty():
		return _publish({"success": true, "status": "no_accepted_turn"})
	return _consider_entry(entries[-1] as Dictionary)


## Session teardown 必须先终止独立分析 transport，再释放 Game writer；取消只结束
## semantic lane，不改变已经 durable accepted 的 Conversation。
func shutdown() -> void:
	if _shutting_down:
		return
	_shutting_down = true
	_queue.clear()
	_disconnect_conversation()
	if provider_adapter != null and provider_adapter.is_busy():
		provider_adapter.cancel()


func _on_generation_completed(_turn: RefCounted) -> void:
	if _shutting_down or session_runtime == null:
		return
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	if entries.is_empty():
		return
	_consider_entry(entries[-1] as Dictionary)


func _consider_entry(entry: Dictionary) -> Dictionary:
	var player_text := String(entry.get("player_text", ""))
	var gm_text := String(entry.get("gm_text", ""))
	var turn_index := int(entry.get("turn_index", -1))
	if player_text.is_empty():
		return _publish({"success": true, "status": "opening_skipped", "source_turn_index": turn_index})
	if turn_index < 0 or gm_text.strip_edges().is_empty() or session_runtime == null or not session_runtime.is_ready():
		return _publish({"success": false, "status": "invalid_accepted_turn", "source_turn_index": turn_index})
	var source_hash := Rules.gm_sha256(gm_text)
	var stable := Rules.identities(String(session_runtime.game_id), turn_index, source_hash)
	var version_key := String(stable.world_turn_id)
	var existing := Rules.matching_record(session_runtime.world_state, turn_index, source_hash)
	var existing_knowledge := Rules.matching_knowledge_record(session_runtime.world_state, turn_index, source_hash)
	if not existing.is_empty() and not existing_knowledge.is_empty():
		_attempted_versions[version_key] = true
		return _publish({"success": true, "status": "already_materialized", "source_turn_index": turn_index, "world_turn_id": version_key})
	if not existing.is_empty() and existing_knowledge.is_empty():
		# changes 已提交但 knowledge 未提交：允许 knowledge-only 补交（同一 accepted 版本）。
		_attempted_versions[version_key] = true
		return _publish({"success": true, "status": "already_materialized", "source_turn_index": turn_index, "world_turn_id": version_key})
	if existing.is_empty() and not existing_knowledge.is_empty():
		_attempted_versions[version_key] = true
		return _publish({"success": true, "status": "already_materialized", "source_turn_index": turn_index, "world_turn_id": version_key})
	if _attempted_versions.has(version_key):
		return _publish({"success": true, "status": "already_attempted", "source_turn_index": turn_index, "world_turn_id": version_key})
	_attempted_versions[version_key] = true
	_queue.append({
		"source_turn_index": turn_index,
		"player_text": player_text,
		"gm_text": gm_text,
		"source_gm_sha256": source_hash,
		"identities": stable,
	})
	_drain_queue.call_deferred()
	return {"success": true, "status": "queued", "source_turn_index": turn_index, "world_turn_id": version_key}


func _drain_queue() -> void:
	if _shutting_down or not _active.is_empty() or _queue.is_empty():
		return
	if provider_adapter == null or provider_adapter.is_busy():
		return
	_active = (_queue.pop_front() as Dictionary).duplicate(true)
	_response_text = ""
	analysis_attempt_count += 1
	var messages := _analysis_messages(_active)
	analysis_requested.emit(int(_active.source_turn_index), messages.duplicate(true))
	var active_world_turn_id := String((_active.identities as Dictionary).world_turn_id)
	var start_error: Error = provider_adapter.start_stream(messages)
	# missing-key 等同步 failed signal 可能已清空 active；只在仍是同一请求时补发 start failure。
	if start_error != OK and not _active.is_empty() and String((_active.identities as Dictionary).world_turn_id) == active_world_turn_id:
		_finish_active({"success": false, "status": "analysis_start_failure", "provider_error": start_error})


func _analysis_messages(turn: Dictionary) -> Array:
	var roster := Rules.actor_roster(session_runtime.world_state)
	var roster_lines := PackedStringArray()
	for local_id: String in roster.keys():
		roster_lines.append("- %s | %s" % [String(roster[local_id]), local_id])
	var roster_block := "Allowed Stable Actors\n" + "\n".join(roster_lines) if not roster_lines.is_empty() else "Allowed Stable Actors\n（无）"
	var agency_block := _agency_selection_block()
	return [
		{"role": "system", "content": ANALYSIS_INSTRUCTIONS},
		{"role": "user", "content": "%s\n\n%s\n\nAccepted Player Action\n%s\n\nAccepted GM Narrative\n%s" % [roster_block, agency_block, String(turn.player_text), String(turn.gm_text)]},
	]


## Agency Selection 材料：只给 selector 每个 eligible NPC 的 bounded actor-local 材料，
## Agency Selection 材料：只给 selector 每个 eligible NPC 的 bounded actor-local 材料，
## 不 dump 全知 GM Context；Player 永不进入 eligible roster。
## C01 修正 D：Knowledge/Agency History 只含 current-hash matching 的 durable 记录。
func _agency_selection_block() -> String:
	var npcs_value: Variant = session_runtime.world_state.get("guaranteed_npcs", [])
	if typeof(npcs_value) != TYPE_ARRAY or (npcs_value as Array).is_empty():
		return "Eligible Agency Actors\n（无）"
	var accepted_hashes := _current_accepted_hashes()
	var knowledge_records_value: Variant = session_runtime.world_state.get("living_world", {}).get("knowledge_turns_by_index", {})
	var knowledge_records := knowledge_records_value as Dictionary if typeof(knowledge_records_value) == TYPE_DICTIONARY else {}
	var agency_cycles_value: Variant = session_runtime.world_state.get("living_world", {}).get("agency_cycles_by_source_turn", {})
	var agency_cycles := agency_cycles_value as Dictionary if typeof(agency_cycles_value) == TYPE_DICTIONARY else {}
	var lines := PackedStringArray(["Eligible Agency Actors", "Judge each candidate from that candidate's own supplied Source, own knowledge and own history. Do not use one actor's private knowledge to justify another actor's selection."])
	for npc_value: Variant in npcs_value as Array:
		if typeof(npc_value) != TYPE_DICTIONARY:
			continue
		var npc := npc_value as Dictionary
		var local_id := String(npc.get("local_character_id", ""))
		if local_id.is_empty():
			continue
		var display := String(npc.get("source_projection", {}).get("display_name", local_id))
		lines.append("## %s | %s" % [display, local_id])
		var sections: Array = npc.get("source_projection", {}).get("semantic_sections", [])
		for section_value: Variant in sections:
			if typeof(section_value) != TYPE_DICTIONARY:
				continue
			var section := section_value as Dictionary
			lines.append("- %s：%s" % [String(section.get("title", "")), String(section.get("content", "")).left(300)])
		var knowledge_facts := PackedStringArray()
		for record_value: Variant in knowledge_records.values():
			if typeof(record_value) != TYPE_DICTIONARY:
				continue
			var record := record_value as Dictionary
			# C01 修正 D：stale Knowledge 按 current accepted hash 过滤。
			var record_turn := int(record.get("source_turn_index", -1))
			if not accepted_hashes.has(record_turn) or String(record.get("source_gm_sha256", "")) != String(accepted_hashes[record_turn]):
				continue
			for event_value: Variant in record.get("events", []):
				if typeof(event_value) != TYPE_DICTIONARY:
					continue
				var event := event_value as Dictionary
				if String(event.get("knower_id", "")) == local_id:
					knowledge_facts.append("- [%s] %s" % [String(event.get("basis", "")), String(event.get("fact", "")).left(120)])
		if not knowledge_facts.is_empty():
			lines.append("Own Knowledge Provenance\n" + "\n".join(knowledge_facts))
		var agency_history := PackedStringArray()
		for cycle_value: Variant in agency_cycles.values():
			if typeof(cycle_value) != TYPE_DICTIONARY:
				continue
			var cycle := cycle_value as Dictionary
			# C01 修正 D：stale Agency History 按 current accepted hash 过滤。
			var cycle_turn := int(cycle.get("source_turn_index", -1))
			if not accepted_hashes.has(cycle_turn) or String(cycle.get("source_gm_sha256", "")) != String(accepted_hashes[cycle_turn]):
				continue
			var actions_value: Variant = cycle.get("actions_by_actor", {})
			if typeof(actions_value) != TYPE_DICTIONARY:
				continue
			var action_value: Variant = (actions_value as Dictionary).get(local_id, {})
			if typeof(action_value) != TYPE_DICTIONARY:
				continue
			var action := action_value as Dictionary
			agency_history.append("- %s" % String(action.get("action", "")).left(120))
		if not agency_history.is_empty():
			lines.append("Own Recent Agency History\n" + "\n".join(agency_history))
	return "\n".join(lines)


## 当前 accepted Conversation 的 turn_index → GM hash 映射；只读。
func _current_accepted_hashes() -> Dictionary:
	var accepted_hashes: Dictionary = {}
	if session_runtime == null or session_runtime.conversation == null:
		return accepted_hashes
	for entry_value: Variant in session_runtime.conversation.get_durable_accepted_entries():
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue
		var entry := entry_value as Dictionary
		var turn_index := int(entry.get("turn_index", -1))
		var gm_text_value: Variant = entry.get("gm_text", null)
		if turn_index >= 0 and typeof(gm_text_value) == TYPE_STRING:
			accepted_hashes[turn_index] = Rules.gm_sha256(String(gm_text_value))
	return accepted_hashes


func _on_text_delta(text: String) -> void:
	if not _active.is_empty():
		_response_text += text


func _on_completed() -> void:
	if _active.is_empty():
		return
	var parsed := _parser.parse(_response_text)
	_response_text = ""
	if not parsed.success:
		_finish_active({"success": false, "status": String(parsed.status)})
		return
	var changes: Array = parsed.changes
	var knowledge_events: Array = parsed.get("knowledge_events", [])
	var knowledge_dropped := int(parsed.get("knowledge_dropped", 0))
	var agency_candidates := validated_agency_candidates(_active, parsed)
	var agency_dropped := int(parsed.get("agency_dropped", 0))
	# C01 修正 A：stale 检测先于 no_changes 分支——agency_candidates 存在时也检查 currentness。
	if not _accepted_version_still_current(_active):
		_finish_active({"success": false, "status": "stale_analysis", "source_turn_index": int(_active.source_turn_index), "agency_candidates": [], "agency_dropped": agency_dropped})
		return
	if changes.is_empty() and knowledge_events.is_empty():
		_finish_active({"success": true, "status": "no_changes", "source_turn_index": int(_active.source_turn_index), "change_count": 0, "knowledge_count": 0, "knowledge_dropped": knowledge_dropped, "agency_candidates": agency_candidates, "agency_dropped": agency_dropped})
		return

	var identities := _active.identities as Dictionary
	var existing := Rules.matching_record(session_runtime.world_state, int(_active.source_turn_index), String(_active.source_gm_sha256))
	var existing_knowledge := Rules.matching_knowledge_record(session_runtime.world_state, int(_active.source_turn_index), String(_active.source_gm_sha256))
	if not existing.is_empty() and not existing_knowledge.is_empty():
		_finish_active({"success": true, "status": "already_materialized", "source_turn_index": int(_active.source_turn_index), "world_turn_id": String(identities.world_turn_id)})
		return
	# actor allowlist 只读当前 Game-local durable setup；unknown/non-roster knower_id 被丢弃。
	var roster := Rules.actor_roster(session_runtime.world_state)
	var validated_events: Array = []
	var roster_dropped := 0
	for event: Dictionary in knowledge_events:
		if roster.has(String(event.knower_id)):
			validated_events.append(event)
		else:
			roster_dropped += 1
	knowledge_dropped += roster_dropped
	var materialized_at := Time.get_datetime_string_from_system(true, true)
	var record := Rules.build_record(String(session_runtime.game_id), int(_active.source_turn_index), String(_active.gm_text), changes, materialized_at) if not changes.is_empty() else {}
	var knowledge_record := Rules.build_knowledge_record(String(session_runtime.game_id), int(_active.source_turn_index), String(_active.gm_text), validated_events, materialized_at) if not validated_events.is_empty() else {}
	if record.is_empty() and knowledge_record.is_empty():
		_finish_active({"success": true, "status": "no_changes", "source_turn_index": int(_active.source_turn_index), "change_count": 0, "knowledge_count": 0, "knowledge_dropped": knowledge_dropped})
		return
	var candidate := Rules.build_world_candidate_with_knowledge(session_runtime.world_state, record, knowledge_record)
	var committed: Dictionary = session_runtime.commit_world_mutation_durably(String(identities.mutation_id), String(identities.node_id), candidate)
	if not committed.success:
		_finish_active({
			"success": false,
			"status": "persistence_failure",
			"storage_status": String(committed.get("status", "unknown")),
			"source_turn_index": int(_active.source_turn_index),
		})
		return
	_finish_active({
		"success": true,
		"status": "committed" if String(committed.status) == "committed" else String(committed.status),
		"source_turn_index": int(_active.source_turn_index),
		"source_gm_sha256": String(_active.source_gm_sha256),
		"world_turn_id": String(identities.world_turn_id),
		"change_count": changes.size(),
		"knowledge_count": validated_events.size(),
		"knowledge_dropped": knowledge_dropped,
		"agency_candidates": agency_candidates,
		"agency_dropped": agency_dropped,
		"head_id": String(committed.head_id),
	})


## Agency Selection 验证：只保留 eligible stable NPC roster 中的 ID；deduplicate；cap 4；
## unknown/Player/empty 丢弃。selection 失败绝不 invalidate 已有效的 changes/knowledge。
func validated_agency_candidates(turn: Dictionary, parsed: Dictionary) -> Array:
	var candidates: Array = parsed.get("agency_candidates", [])
	if candidates.is_empty():
		return []
	var npcs_value: Variant = session_runtime.world_state.get("guaranteed_npcs", [])
	if typeof(npcs_value) != TYPE_ARRAY:
		return []
	var eligible: Array = []
	for npc_value: Variant in npcs_value as Array:
		if typeof(npc_value) != TYPE_DICTIONARY:
			continue
		var npc := npc_value as Dictionary
		var local_id := String(npc.get("local_character_id", ""))
		if not local_id.is_empty():
			eligible.append(local_id)
	var validated: Array = []
	for candidate_value: Variant in candidates:
		var candidate := String(candidate_value)
		if eligible.has(candidate) and not validated.has(candidate):
			validated.append(candidate)
		if validated.size() >= Rules.AGENCY_CYCLE_MAX_ACTORS:
			break
	return validated


## 分析期间 latest turn 可能被 regenerate/correct 或 foreground 已开始新 attempt；
## 只有仍匹配 current accepted truth 且 foreground 未前进的 candidate 才可进入世界 CAS。
func _accepted_version_still_current(candidate: Dictionary) -> bool:
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	var index := int(candidate.source_turn_index)
	if index < 0 or index >= entries.size():
		return false
	# C01 修正 A：foreground 已开始新 attempt（latest turn 已前进或正在生成）时，
	# 旧 semantic 结果不得启动 Agency。
	if index != entries.size() - 1 or session_runtime.conversation.is_generating():
		return false
	var current := entries[index] as Dictionary
	return Rules.gm_sha256(String(current.get("gm_text", ""))) == String(candidate.source_gm_sha256)


func _on_cancelled() -> void:
	if not _active.is_empty():
		_finish_active({"success": false, "status": "analysis_cancelled"})


func _on_failed(code: String, _message: String) -> void:
	if not _active.is_empty():
		_finish_active({"success": false, "status": "analysis_provider_failure", "provider_status": code})


func _finish_active(result: Dictionary) -> void:
	if not _active.is_empty() and not result.has("source_turn_index"):
		result["source_turn_index"] = int(_active.source_turn_index)
	_active = {}
	_response_text = ""
	_publish(result)
	if not _shutting_down:
		_drain_queue.call_deferred()


func _publish(result: Dictionary) -> Dictionary:
	last_result = result.duplicate(true)
	finished.emit(last_result.duplicate(true))
	return last_result.duplicate(true)


func _connect_conversation() -> void:
	if session_runtime == null or session_runtime.conversation == null:
		return
	var callback := Callable(self, "_on_generation_completed")
	if not session_runtime.conversation.generation_completed.is_connected(callback):
		session_runtime.conversation.generation_completed.connect(callback)


func _disconnect_conversation() -> void:
	if session_runtime == null or session_runtime.conversation == null:
		return
	var callback := Callable(self, "_on_generation_completed")
	if session_runtime.conversation.generation_completed.is_connected(callback):
		session_runtime.conversation.generation_completed.disconnect(callback)


func _connect_provider() -> void:
	if provider_adapter == null:
		return
	provider_adapter.text_delta.connect(_on_text_delta)
	provider_adapter.completed.connect(_on_completed)
	provider_adapter.cancelled.connect(_on_cancelled)
	provider_adapter.failed.connect(_on_failed)
