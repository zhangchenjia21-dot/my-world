class_name SemanticMaterializationProcess
extends Node

const Rules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")
const D20Rules := preload("res://src/行动判定/L0_公理层/公开D20判定规则.gd")
const Parser := preload("res://src/世界回合/L1_器件层/语义变更响应解析器.gd")
const ProviderAdapter := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")

signal analysis_requested(turn_index, messages)
signal finished(result)

const ANALYSIS_INSTRUCTIONS := "你是 my world 的后台语义物化器。只根据已经接受的玩家行动、GM 叙事与（若提供）Durable Mechanical Resolution，提取三类 durable 事实：\n1. changes：叙事中已经明确成立、值得跨句持续的世界后果。若提供 Durable Mechanical Resolution，它是 Program 既定的权威判定结果：提取后果时必须尊重它，不得改写、重掷或虚构判定结果；但判定成功/失败本身不对应任何固定世界后果，仍只提取 accepted 叙事已明确支持的后果，没有则 changes=[]。\n2. knowledge_events：叙事明确建立给特定 stable actor 的 post-T0 新知识。只提取该 accepted turn 新建立的、有明确根据的知识；不要因为事实在叙事中为真就授予知识；不要因为某 NPC 在阵容中就推断其知情；不要编造未知 actor/ID；不要输出推理过程。\n3. new_actor_candidates：叙事明确确立了身份、且有可信持续相关性的独立个体。只提供 bounded material；不要提议已在 Allowed Stable Actors 列表中的人；没有持续相关性的路人保持 ephemeral，以后仍可成为 stable；不要编造 ID 或任何出处。\n只输出一个 JSON 对象：{\"changes\":[\"简洁的持久后果\"],\"knowledge_events\":[{\"knower_id\":\"stable-local-id\",\"fact\":\"简洁事实\",\"basis\":\"witnessed|told|discovered|participated\"}],\"new_actor_candidates\":[{\"display_name\":\"名字\",\"profile_text\":\"仅由该 accepted 叙事确立的 bounded 角色材料\"}]}；没有持久后果时 changes=[]；没有新知识时 knowledge_events=[]；没有新 stable actor 时 new_actor_candidates=[] 或省略。knower_id 必须且只能来自 Allowed Stable Actors 列表；不要输出列表之外的 ID。不要输出解释、Markdown 或推理过程。"

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
	# MW-001：actor-only commit 的 durable replay 信号——同 accepted 版本已物化 runtime actor
	# 时，reopen 后不依赖内存 _attempted_versions 也能识别，绝不重发请求或重 mint 身份。
	if not Rules.runtime_actor_ids_for_version(session_runtime.world_state, turn_index, source_hash).is_empty():
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
	# MW-001 INV-05：roster 必须按 current accepted turn→hash 过滤，stale runtime-origin
	# actor 不作为 current roster 呈现给模型。
	var roster := Rules.actor_roster(session_runtime.world_state, _current_accepted_hashes())
	var roster_lines := PackedStringArray()
	for local_id: String in roster.keys():
		roster_lines.append("- %s | %s" % [String(roster[local_id]), local_id])
	var roster_block := "Allowed Stable Actors\n" + "\n".join(roster_lines) if not roster_lines.is_empty() else "Allowed Stable Actors\n（无）"
	# MW-006：既有 authoritative CHECK_REQUIRED durable resolution 只在此处只读进入语义
	# request 一次；NO_CHECK / 普通路径 / marker 缺失或歧义时不存在该 block，不伪造 mechanics。
	var grounding_block := _mechanical_grounding_block(turn)
	var user_content := "%s\n\nAccepted Player Action\n%s\n\nAccepted GM Narrative\n%s" % [roster_block, String(turn.player_text), String(turn.gm_text)]
	if not grounding_block.is_empty():
		user_content += "\n\n" + grounding_block
	return [
		{"role": "system", "content": ANALYSIS_INSTRUCTIONS},
		{"role": "user", "content": user_content},
	]


## accepted turn 命中唯一 durable CHECK_REQUIRED resolution 时，输出有界权威事实块；
## 0 或多个命中（NO_CHECK / 普通 / degraded / marker 缺失 / 数据歧义）一律返回空串。
func _mechanical_grounding_block(turn: Dictionary) -> String:
	var check := D20Rules.matching_accepted_check_for_turn(
		session_runtime.world_state, int(turn.get("source_turn_index", -1)), String(turn.get("player_text", ""))
	)
	if check.is_empty():
		return ""
	var lines := PackedStringArray([
		"Durable Mechanical Resolution (Program-owned authoritative truth)",
		"本次玩家行动的结果已由 Program 的公开 d20 判定持久决定，权威且不可改写、重掷或质疑：",
	])
	for field: String in ["check_id", "action_id", "intent", "dc", "modifier", "stance", "raw_rolls", "selected_roll", "total", "outcome", "modifier_reason", "situation_reason", "success_intent", "failure_stakes"]:
		if check.has(field):
			lines.append("- %s: %s" % [field, JSON.stringify(check[field])])
	lines.append("该判定结果本身不是世界后果清单；仍只提取 accepted 叙事已明确支持的 0..N 条持久后果。")
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
	var actor_candidates: Array = parsed.get("new_actor_candidates", [])
	var actors_dropped := int(parsed.get("actors_dropped", 0))
	# G5-03M1R01：semantic lane 恢复为纯 accepted source-version 语义；Agency currentness 由
	# standalone scheduler 拥有，semantic 不因 Agency 机会过期而丢弃 otherwise-valid truth。
	if not _accepted_version_still_current(_active):
		_finish_active({"success": false, "status": "stale_analysis", "source_turn_index": int(_active.source_turn_index)})
		return
	# MW-001 INV-08：三类输出全无有效 material 时才保持原 no-op；actor-only 是合法提交。
	if changes.is_empty() and knowledge_events.is_empty() and actor_candidates.is_empty():
		_finish_active({"success": true, "status": "no_changes", "source_turn_index": int(_active.source_turn_index), "change_count": 0, "knowledge_count": 0, "knowledge_dropped": knowledge_dropped, "actor_count": 0, "actors_dropped": actors_dropped})
		return

	var identities := _active.identities as Dictionary
	var existing := Rules.matching_record(session_runtime.world_state, int(_active.source_turn_index), String(_active.source_gm_sha256))
	var existing_knowledge := Rules.matching_knowledge_record(session_runtime.world_state, int(_active.source_turn_index), String(_active.source_gm_sha256))
	if not existing.is_empty() and not existing_knowledge.is_empty():
		_finish_active({"success": true, "status": "already_materialized", "source_turn_index": int(_active.source_turn_index), "world_turn_id": String(identities.world_turn_id)})
		return
	# actor allowlist 只读当前 Game-local durable setup；unknown/non-roster knower_id 被丢弃。
	# MW-001 INV-10：Knowledge targeting 也走 accepted-hash currentness 过滤后的 roster。
	var roster := Rules.actor_roster(session_runtime.world_state, _current_accepted_hashes())
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
	# MW-001 INV-06/09：Program mint deterministic local identity；同 accepted 版本已物化的
	# candidate（相同 ordinal+material 推出相同 ID）deterministic skip，replay 不产生第二身份。
	var existing_actor_ids := Rules.runtime_actor_ids_for_version(session_runtime.world_state, int(_active.source_turn_index), String(_active.source_gm_sha256))
	var actor_records: Array = []
	var actor_ordinal := 0
	for candidate_material: Dictionary in actor_candidates:
		var display_name := String(candidate_material.get("display_name", ""))
		var profile_text := String(candidate_material.get("profile_text", ""))
		var actor_identity := Rules.runtime_actor_identities(String(session_runtime.game_id), int(_active.source_turn_index), String(_active.source_gm_sha256), actor_ordinal, display_name, profile_text)
		actor_ordinal += 1
		var local_id := String(actor_identity.local_character_id)
		if existing_actor_ids.has(local_id):
			continue
		actor_records.append(Rules.build_runtime_actor_record(local_id, int(_active.source_turn_index), String(_active.source_gm_sha256), display_name, profile_text))
		existing_actor_ids.append(local_id)
	if record.is_empty() and knowledge_record.is_empty() and actor_records.is_empty():
		_finish_active({"success": true, "status": "no_changes", "source_turn_index": int(_active.source_turn_index), "change_count": 0, "knowledge_count": 0, "knowledge_dropped": knowledge_dropped, "actor_count": 0, "actors_dropped": actors_dropped})
		return
	# MW-001 INV-07：actor 与 changes/knowledge 走同一 semantic durable mutation。
	var candidate := Rules.build_world_candidate_with_actors(session_runtime.world_state, record, knowledge_record, actor_records)
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
		"actor_count": actor_records.size(),
		"actors_dropped": actors_dropped,
		"head_id": String(committed.head_id),
	})


## 分析期间 latest turn 可能被 regenerate/correct；只有仍匹配 current accepted truth 的
## candidate 才可进入世界 CAS，旧分析不会成为新版本的事实。
## G5-03M1R01：semantic lane 恢复为纯 accepted source-version 语义；Agency currentness 由
## standalone scheduler 拥有，semantic 不因 Agency 机会过期而丢弃 otherwise-valid truth。
func _accepted_version_still_current(candidate: Dictionary) -> bool:
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	var index := int(candidate.source_turn_index)
	if index < 0 or index >= entries.size():
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
