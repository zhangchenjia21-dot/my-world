class_name SemanticMaterializationProcess
extends Node

const Accepted := preload("res://src/domain/L3_外交层/已接受输入公开契约.gd")


const Rules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")
const D20Rules := preload("res://src/行动判定/L0_公理层/公开D20判定规则.gd")
const Receipt := preload("res://src/世界回合/L0_公理层/人物身份回执规则.gd")
const Parser := preload("res://src/世界回合/L1_器件层/语义变更响应解析器.gd")
const ProviderAdapter := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")

signal analysis_requested(turn_index, messages)
signal finished(result)
signal opportunity_terminal(result)

const ANALYSIS_INSTRUCTIONS := "你是 my world 的后台语义物化器。只根据已经接受的玩家行动、GM 叙事与（若提供）Durable Mechanical Resolution，提取三类 durable 事实：\n1. changes：叙事中已经明确成立、值得跨句持续的世界后果。若提供 Durable Mechanical Resolution，它是 Program 既定的权威判定结果：提取后果时必须尊重它，不得改写、重掷或虚构判定结果；但判定成功/失败本身不对应任何固定世界后果，仍只提取 accepted 叙事已明确支持的后果，没有则 changes=[]。\n2. knowledge_events：叙事明确建立给特定 stable actor 的 post-T0 新知识。只提取该 accepted turn 新建立的、有明确根据的知识；不要因为事实在叙事中为真就授予知识；不要因为某 NPC 在阵容中就推断其知情；不要编造未知 actor/ID；不要输出推理过程。\n3. new_actor_candidates：叙事明确确立了身份、且有可信持续相关性的独立个体。只提供 bounded material；不要提议已在 Allowed Stable Actors 列表中的人；没有持续相关性的路人保持 ephemeral，以后仍可成为 stable；不要编造 ID 或任何出处。\n只输出一个 JSON 对象：{\"changes\":[\"简洁的持久后果\"],\"knowledge_events\":[{\"knower_id\":\"stable-local-id\",\"fact\":\"简洁事实\",\"basis\":\"witnessed|told|discovered|participated\"}],\"new_actor_candidates\":[{\"display_name\":\"名字\",\"profile_text\":\"仅由该 accepted 叙事确立的 bounded 角色材料\"}]}；没有持久后果时 changes=[]；没有新知识时 knowledge_events=[]；没有新 stable actor 时 new_actor_candidates=[] 或省略。knower_id 必须且只能来自 Allowed Stable Actors 列表；不要输出列表之外的 ID。不要输出解释、Markdown 或推理过程。"

# identity resolution 不决定人物卡意义；内部 resolver 不增加 raw profile 输入。
const IDENTITY_INSTRUCTIONS := """
同时输出可选 people_bindings 数组，最多8项。已有 NPC 只使用 People Actor References 的 actor_ref。
当前 accepted Player / GM 原文中对已有稳定人物的合法引用都可解析，包括回忆、谈论及不在当前现场的人；不要求人物出场。
每项精确形状为 {"actor_ref":"请求引用","source_role":"player或gm","source_span":{"start":0,"length":2}}。
start 为 source_role 指定的 Accepted Player Action 或 Accepted GM Narrative 原文零基 Unicode 字符位置，length 为1..600字符，不计算标题。
只有 accepted GM/world semantics 明确确立真实存在、独立身份且有持续相关性的新人物，才可按既有 new_actor_candidates 规则建立；合法的场外人物同样适用。
Player 仅提名字、猜测、愿望、假设或声称存在，不得据此创建 new_actor_candidates 或确立 World Truth。未解析的 Player 引用保持无绑定。
同响应合法新候选可附唯一 candidate_ref（非空字符串，最多64字符），并用 {"candidate_ref":"候选引用","source_role":"gm","source_span":{"start":0,"length":2}} 绑定 GM 确立该人的原文；candidate_ref 禁止绑定 Player 来源。
只绑定原文真正对应的稳定人物；存在同名或其它歧义而无法确定时不输出该 binding，不猜第一个，不凭姓名相等，也不另造重复 actor。
玩家主角自身不是 People NPC，不允许绑定。引用不是姓名、local ID 或 durable identity；不得输出自由 cue、私密 profile 或隐藏状态。
绑定只是精确身份候选，不自动授予 Knowledge 或建卡；是否值得记忆由 Information Curator 判断。
"""
const TIMEOUT_SECONDS := 120.0
const MAX_PAYLOAD_BYTES := 131072

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
var _epoch := 0
var _request_serial := 0
var _provider_callbacks: Dictionary = {}
var _terminals: Dictionary = {}
var _activation_prefixes: Dictionary = {}
var _timer: Timer


func _init(runtime: Variant = null, adapter_override: Node = null) -> void:
	session_runtime = runtime
	provider_adapter = adapter_override if adapter_override != null else ProviderAdapter.new()
	_connect_conversation()
	if session_runtime != null and session_runtime.conversation != null:
		_capture_activation()
	if session_runtime != null and session_runtime.has_signal("restore_completed"):
		session_runtime.restore_completed.connect(_on_restore)


func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.wait_time = TIMEOUT_SECONDS
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)
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
	_epoch += 1
	_queue.clear()
	_active = {}
	_disconnect_provider()
	if _timer != null:
		_timer.stop()
	_disconnect_conversation()
	if session_runtime != null and session_runtime.has_signal("restore_completed") and session_runtime.restore_completed.is_connected(_on_restore):
		session_runtime.restore_completed.disconnect(_on_restore)
	if provider_adapter != null and provider_adapter.is_busy():
		provider_adapter.cancel()


func _on_generation_completed(_turn: RefCounted) -> void:
	if _shutting_down or session_runtime == null:
		return
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	if entries.is_empty():
		return
	_consider_entry(entries[-1] as Dictionary, true)


func _consider_entry(entry: Dictionary, newly_accepted: bool = false) -> Dictionary:
	if Accepted.mode(entry) == "ooc":
		return {"success": true, "status": "ooc_skipped"}
	var player_text := String(entry.get("player_text", ""))
	var gm_text := String(entry.get("gm_text", ""))
	var turn_index := int(entry.get("turn_index", -1))
	if player_text.is_empty():
		return _publish({"success": true, "status": "opening_skipped", "source_turn_index": turn_index})
	if turn_index < 0 or gm_text.strip_edges().is_empty() or session_runtime == null or not session_runtime.is_ready():
		return _publish({"success": false, "status": "invalid_accepted_turn", "source_turn_index": turn_index})
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	var prefix := Receipt.prefix_at(entries, turn_index)
	var source_hash := Rules.gm_sha256(gm_text)
	var stable := Rules.identities(String(session_runtime.game_id), turn_index, source_hash)
	var opportunity := {"game_id": String(session_runtime.game_id), "source_turn_index": turn_index,
		"prefix": prefix, "epoch": _epoch, "source_gm_sha256": source_hash,
		"player_text": player_text, "gm_text": gm_text, "identities": stable}
	var receipt := Receipt.current(session_runtime.world_state, String(session_runtime.game_id), entries, turn_index)
	if not receipt.is_empty():
		return _publish_terminal(opportunity, {"success": true, "status": "already_materialized", "receipt_id": receipt.id, "outcome": receipt.status})
	# 旧 Game / reopen 没有回执时，不启动新身份历史回填。既有 G5 记录也只读复用。
	var historical: bool = _activation_prefixes.get(turn_index, "") == prefix
	var legacy := (
		not Rules.matching_record(session_runtime.world_state, turn_index, source_hash).is_empty()
		or not Rules.matching_knowledge_record(session_runtime.world_state, turn_index, source_hash).is_empty()
		or not Rules.runtime_actor_ids_for_version(session_runtime.world_state, turn_index, source_hash).is_empty()
	)
	var had_receipt: bool = session_runtime.world_state.get("living_world", {}).get(Receipt.COLLECTION, {}).has(str(turn_index))
	if not newly_accepted and (historical or (legacy and not had_receipt)):
		return _publish_terminal(opportunity, {"success": true, "status": "already_materialized" if legacy else "historical_skipped", "outcome": "unavailable", "receipt_id": ""})
	if _attempted_versions.has(prefix):
		return {"success": true, "status": "already_attempted", "source_turn_index": turn_index}
	_attempted_versions[prefix] = true
	_queue.append(opportunity)
	_drain_queue.call_deferred()
	return {"success": true, "status": "queued", "source_turn_index": turn_index, "world_turn_id": stable.world_turn_id}


func _drain_queue() -> void:
	if _shutting_down or not _active.is_empty() or _queue.is_empty():
		return
	if provider_adapter == null or provider_adapter.is_busy():
		return
	_active = (_queue.pop_front() as Dictionary).duplicate(true)
	if not _accepted_version_still_current(_active):
		_finish_active({"success": false, "status": "stale_analysis"})
		return
	_response_text = ""
	_request_serial += 1
	_active["request_serial"] = _request_serial
	_connect_provider(_request_serial)
	analysis_attempt_count += 1
	var messages := _analysis_messages(_active)
	if JSON.stringify(messages).to_utf8_buffer().size() > MAX_PAYLOAD_BYTES:
		_finish_active({"success": false, "status": "input_oversized"})
		return
	_timer.start()
	analysis_requested.emit(int(_active.source_turn_index), messages.duplicate(true))
	var active_world_turn_id := String((_active.identities as Dictionary).world_turn_id)
	var start_error: Error = provider_adapter.start_stream(messages)
	# missing-key 等同步 failed signal 可能已清空 active；只在仍是同一请求时补发 start failure。
	if start_error != OK and not _active.is_empty() and String((_active.identities as Dictionary).world_turn_id) == active_world_turn_id:
		_finish_active({"success": false, "status": "analysis_start_failure", "provider_error": start_error})


func _analysis_messages(turn: Dictionary) -> Array:
	# MW-001 INV-05：roster 必须按 current accepted turn→hash 过滤，stale runtime-origin
	# actor 不作为 current roster 呈现给模型。
	var roster := Rules.actor_roster(session_runtime.world_state, Receipt.accepted_hashes(session_runtime.conversation.get_durable_accepted_entries(), int(turn.source_turn_index)))
	var roster_lines := PackedStringArray()
	for local_id: String in roster.keys():
		roster_lines.append("- %s | %s" % [String(roster[local_id]), local_id])
	var actor_refs := {}
	var ref_lines := PackedStringArray()
	var nonce := Crypto.new().generate_random_bytes(12).hex_encode()
	var ids := Receipt.npc_ids(session_runtime.world_state, session_runtime.conversation.get_durable_accepted_entries(), int(turn.source_turn_index))
	for local_id: String in ids:
		var ref := "actor-" + nonce + "-" + str(actor_refs.size())
		actor_refs[ref] = local_id
		ref_lines.append(JSON.stringify({"actor_ref": ref, "display_name": String(roster.get(local_id, "")).left(64)}))
	turn["actor_refs"] = actor_refs
	var roster_block := "Allowed Stable Actors\n" + "\n".join(roster_lines) if not roster_lines.is_empty() else "Allowed Stable Actors\n（无）"
	# MW-006：既有 authoritative CHECK_REQUIRED durable resolution 只在此处只读进入语义
	# request 一次；NO_CHECK / 普通路径 / marker 缺失或歧义时不存在该 block，不伪造 mechanics。
	var grounding_block := _mechanical_grounding_block(turn)
	var user_content := "%s\n\nAccepted Player Action\n%s\n\nAccepted GM Narrative\n%s" % [roster_block, String(turn.player_text), String(turn.gm_text)]
	user_content += "\n\nPeople Actor References (identity only)\n" + "\n".join(ref_lines)
	if not grounding_block.is_empty():
		user_content += "\n\n" + grounding_block
	return [
		{"role": "system", "content": ANALYSIS_INSTRUCTIONS + "\n" + IDENTITY_INSTRUCTIONS},
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


func _on_text_delta(text: String, serial: int) -> void:
	if not _callback_current(serial):
		return
	if _response_text.to_utf8_buffer().size() + text.to_utf8_buffer().size() > MAX_PAYLOAD_BYTES:
		_finish_active({"success": false, "status": "response_oversized"})
		provider_adapter.cancel()
		return
	_response_text += text


func _on_completed(serial: int) -> void:
	if not _callback_current(serial):
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
	var identities := _active.identities as Dictionary
	# actor allowlist 只读当前 Game-local durable setup；unknown/non-roster knower_id 被丢弃。
	# MW-001 INV-10：Knowledge targeting 也走 accepted-hash currentness 过滤后的 roster。
	var roster := Rules.actor_roster(session_runtime.world_state, Receipt.accepted_hashes(session_runtime.conversation.get_durable_accepted_entries(), int(_active.source_turn_index)))
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
	var ordinal_ids: Array = []
	for candidate_material: Dictionary in actor_candidates:
		var display_name := String(candidate_material.get("display_name", ""))
		var profile_text := String(candidate_material.get("profile_text", ""))
		var actor_identity := Rules.runtime_actor_identities(String(session_runtime.game_id), int(_active.source_turn_index), String(_active.source_gm_sha256), actor_ordinal, display_name, profile_text)
		actor_ordinal += 1
		var local_id := String(actor_identity.local_character_id)
		ordinal_ids.append(local_id)
		if existing_actor_ids.has(local_id):
			continue
		actor_records.append(Rules.build_runtime_actor_record(local_id, int(_active.source_turn_index), String(_active.source_gm_sha256), display_name, profile_text))
		existing_actor_ids.append(local_id)
	# 相同响应的候选先 mint，ref 再按规范化关联解析；actor 与回执只有一次原子提交。
	var candidate := Rules.build_world_candidate_with_actors(session_runtime.world_state, record, knowledge_record, actor_records)
	var candidate_refs := {}
	for ref: String in parsed.candidate_ordinals:
		candidate_refs[ref] = ordinal_ids[int(parsed.candidate_ordinals[ref])]
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	var bindings := Receipt.resolve_bindings(parsed.people_bindings, _active.get("actor_refs", {}), candidate_refs,
		Receipt.npc_ids(candidate, entries, int(_active.source_turn_index)), String(_active.gm_text), String(_active.player_text))
	var receipt := Receipt.build(String(session_runtime.game_id), int(_active.source_turn_index), String(_active.prefix), bindings)
	candidate = Receipt.with_receipt(candidate, receipt)
	# G5 record IDs 保持原算法；mutation 属于本次提交，防止 Restore 后撞到 displaced-future 节点。
	var mutation := "semantic-turn-" + Crypto.new().generate_random_bytes(16).hex_encode()
	var committed: Dictionary = session_runtime.commit_world_mutation_durably(mutation, mutation + "-node", candidate)
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
		"receipt_id": receipt.id,
		"outcome": receipt.status,
		"source_turn_index": int(_active.source_turn_index),
		"source_gm_sha256": String(_active.source_gm_sha256),
		"world_turn_id": String(identities.world_turn_id),
		"change_count": changes.size(),
		"knowledge_count": validated_events.size(),
		"knowledge_dropped": knowledge_dropped,
		"actor_count": actor_records.size(),
		"binding_count": bindings.size(),
		"actors_dropped": actors_dropped,
		"head_id": String(committed.head_id),
	})


## 分析期间 latest turn 可能被 regenerate/correct；只有仍匹配 current accepted truth 的
## candidate 才可进入世界 CAS，旧分析不会成为新版本的事实。
## G5-03M1R01：semantic lane 恢复为纯 accepted source-version 语义；Agency currentness 由
## standalone scheduler 拥有，semantic 不因 Agency 机会过期而丢弃 otherwise-valid truth。
func _accepted_version_still_current(candidate: Dictionary) -> bool:
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	return (
		candidate.get("epoch", -1) == _epoch and candidate.get("game_id") == session_runtime.game_id
		and Receipt.prefix_at(entries, int(candidate.source_turn_index)) == candidate.get("prefix", "")
	)

func _callback_current(serial: int) -> bool:
	return not _active.is_empty() and int(_active.get("request_serial", -1)) == serial and _active.epoch == _epoch

func _on_cancelled(serial: int) -> void:
	if _callback_current(serial):
		_finish_active({"success": false, "status": "analysis_cancelled", "outcome": "cancelled"})

func _on_failed(code: String, _message: String, serial: int) -> void:
	if _callback_current(serial):
		_finish_active({"success": false, "status": "analysis_provider_failure", "provider_status": code, "outcome": "failure"})

func _on_timeout() -> void:
	if _active.is_empty():
		return
	_finish_active({"success": false, "status": "analysis_timeout", "outcome": "timeout"})
	provider_adapter.cancel()

func _finish_active(result: Dictionary) -> void:
	var opportunity := _active
	_active = {}
	_response_text = ""
	_disconnect_provider()
	if _timer != null:
		_timer.stop()
	if not opportunity.is_empty():
		_publish_terminal(opportunity, result)
	if not _shutting_down:
		_drain_queue.call_deferred()

# 仅当前 epoch/current prefix 的真终态唤醒 barrier；排队/重复尝试不是终态。
func _publish_terminal(opportunity: Dictionary, result: Dictionary) -> Dictionary:
	if not _accepted_version_still_current(opportunity):
		return {"success": false, "status": "stale_analysis"}
	var terminal := result.duplicate(true)
	for key: String in ["game_id", "source_turn_index", "source_gm_sha256", "prefix", "epoch"]:
		terminal[key] = opportunity[key]
	terminal["world_turn_id"] = opportunity.identities.world_turn_id
	if not terminal.has("outcome"):
		terminal["outcome"] = "failure"
	if not terminal.has("receipt_id"):
		terminal["receipt_id"] = ""
	_terminals[opportunity.prefix] = terminal
	opportunity_terminal.emit(terminal.duplicate(true))
	return _publish(terminal)

## 纯查询屏障：返回当前版本终态或 {}（仍待处理）；不触发 Provider/历史 backfill。
## 成功必须有当前 durable receipt；失败可释放 Character/经历但没有 People evidence。
func lived_terminal(index: int, prefix: String) -> Dictionary:
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	if Receipt.prefix_at(entries, index) != prefix:
		return {}
	var current := Receipt.current(session_runtime.world_state, String(session_runtime.game_id), entries, index)
	if not current.is_empty():
		return {"game_id": session_runtime.game_id, "source_turn_index": index, "prefix": prefix,
			"epoch": _epoch, "success": true, "outcome": current.status, "receipt_id": current.id}
	var terminal: Dictionary = _terminals.get(prefix, {})
	if not terminal.is_empty() and terminal.epoch == _epoch:
		if not String(terminal.receipt_id).is_empty():
			var receipt := Receipt.current(session_runtime.world_state, String(session_runtime.game_id), entries, index)
			if receipt.is_empty() or receipt.id != terminal.receipt_id:
				return {}
		return terminal.duplicate(true)
	return {}

func _capture_activation() -> void:
	_activation_prefixes.clear()
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	for index: int in range(entries.size()):
		_activation_prefixes[index] = Receipt.prefix_at(entries, index)

func _on_restore(_result: Dictionary) -> void:
	_epoch += 1
	_active = {}
	_queue.clear()
	_response_text = ""
	_terminals.clear()
	_attempted_versions.clear()
	_disconnect_provider()
	if _timer != null:
		_timer.stop()
	if provider_adapter.is_busy():
		provider_adapter.cancel()
	_capture_activation()


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


func _connect_provider(serial: int) -> void:
	_provider_callbacks = {
		"text_delta": _on_text_delta.bind(serial), "completed": _on_completed.bind(serial),
		"cancelled": _on_cancelled.bind(serial), "failed": _on_failed.bind(serial)}
	for signal_name: String in _provider_callbacks:
		provider_adapter.connect(signal_name, _provider_callbacks[signal_name])

func _disconnect_provider() -> void:
	for signal_name: String in _provider_callbacks:
		if provider_adapter.is_connected(signal_name, _provider_callbacks[signal_name]):
			provider_adapter.disconnect(signal_name, _provider_callbacks[signal_name])
	_provider_callbacks.clear()
