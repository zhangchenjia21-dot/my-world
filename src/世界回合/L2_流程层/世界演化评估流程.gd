class_name WorldEvolutionEvaluatorProcess
extends Node

## MW-002 Selective World Evolution Evaluator —— 只在 Agency opportunity 真正终态后获得
## 一次 best-effort 评估机会；hold 是一等正确结果，不产生 fake mutation，不自动重试；
## 一次评估至多推进一个不归属于单一 stable NPC intentional 决策的世界事件。
## 不引入 numeric priority / pressure queue / every-N-turn cadence / random-event engine。

const Rules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")
const Parser := preload("res://src/世界回合/L1_器件层/世界演化响应解析器.gd")
const WorldOnlyProjector := preload("res://src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd")
const ProviderAdapter := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")

signal evaluation_requested(turn_index, messages)
signal finished(result)

const EVALUATOR_INSTRUCTIONS := "你是 my world 的后台 World Evolution Evaluator。根据 bounded 的 GM 级世界因果材料，判断是否有任何已经被既有材料支持的世界过程在此刻因果成熟、值得推进一步。这不是随机事件生成器；不要因为收到了评估请求就制造事件；要为生活流/日常/安静场景留白；不要重复已经 durable 成立的事实；最多选择一个最有意义的发展，否则 hold。事件必须是世界层面的过程：环境/天气/自然过程、aggregate 冲突或前线移动、制度/经济/社会过程、期限成熟、灾害/事故、既有后果的连锁反应等；不要输出某个 stable NPC 的个人 intentional 行动。只输出一个 JSON 对象：{\"decision\":\"hold\"}，或 {\"decision\":\"advance\",\"event\":\"简洁的世界事件摘要\",\"effects\":[\"具体 durable 影响\",\"……1 到 4 条\"]}；不要输出 ID、优先级分数、事件分类或任何 Source 出处；不要输出解释、Markdown 或推理过程。"

var session_runtime: Variant = null
var world_turn_runtime: Variant = null
var provider_adapter: Node = null
var last_result: Dictionary = {"success": true, "status": "idle"}
var evaluation_attempt_count := 0

var _parser := Parser.new()
var _world_projector := WorldOnlyProjector.new()
var _active: Dictionary = {}
var _response_text := ""
var _attempted_opportunities: Dictionary = {}
var _shutting_down := false


func _init(runtime: Variant = null, world_turn: Variant = null, adapter_override: Node = null) -> void:
	session_runtime = runtime
	world_turn_runtime = world_turn
	provider_adapter = adapter_override if adapter_override != null else ProviderAdapter.new()
	_connect_provider()


func _ready() -> void:
	if provider_adapter != null and provider_adapter.get_parent() == null:
		add_child(provider_adapter)


## 测试/未来 observability 可读取稳定终态；不返回 raw request、response 或 credential。
func status_snapshot() -> Dictionary:
	return {
		"last_result": last_result.duplicate(true),
		"evaluation_attempt_count": evaluation_attempt_count,
		"busy": not _active.is_empty(),
	}


## 唯一 wake 入口：Agency opportunity terminal 后由 Application 以 frozen turn/hash 调用。
## 晚到的旧机会终端不能为更新的 turn 唤醒评估；Opening-only turn 不产生机会。
func consider_opportunity(opportunity_turn_index: int, opportunity_gm_sha256: String) -> Dictionary:
	if _shutting_down or session_runtime == null or session_runtime.conversation == null or not session_runtime.is_ready():
		return _publish({"success": false, "status": "runtime_not_ready"})
	if not _active.is_empty() or (provider_adapter != null and provider_adapter.is_busy()):
		return _publish({"success": true, "status": "evaluation_busy"})
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	if entries.is_empty():
		return _publish({"success": true, "status": "no_accepted_turn"})
	var latest := entries[-1] as Dictionary
	if int(latest.get("turn_index", -1)) != opportunity_turn_index or Rules.gm_sha256(String(latest.get("gm_text", ""))) != opportunity_gm_sha256:
		return _publish({"success": true, "status": "stale_opportunity"})
	if String(latest.get("player_text", "")).is_empty():
		return _publish({"success": true, "status": "opening_skipped"})
	if session_runtime.conversation.is_generating():
		return _publish({"success": true, "status": "foreground_busy"})
	if world_turn_runtime != null:
		var snapshot: Dictionary = world_turn_runtime.status_snapshot()
		if bool(snapshot.get("busy", false)) or int(snapshot.get("queued_count", 0)) > 0:
			return _publish({"success": true, "status": "semantic_busy"})
	# durable replay 信号：同 accepted 机会已提交 current event 时，reopen/fresh worker
	# 不得重发评估请求或追加重复事件。
	if not Rules.matching_world_evolution_event(session_runtime.world_state, opportunity_turn_index, opportunity_gm_sha256).is_empty():
		_attempted_opportunities[_opportunity_key(opportunity_turn_index, opportunity_gm_sha256)] = true
		return _publish({"success": true, "status": "already_evaluated", "source_turn_index": opportunity_turn_index})
	# 内存 attempted：hold/failure/cancel 在同一 runtime 机会内不自动重试。
	if bool(_attempted_opportunities.get(_opportunity_key(opportunity_turn_index, opportunity_gm_sha256), false)):
		return _publish({"success": true, "status": "already_attempted", "source_turn_index": opportunity_turn_index})
	_attempted_opportunities[_opportunity_key(opportunity_turn_index, opportunity_gm_sha256)] = true
	# frozen Game-local World-only T0 baseline；超限/无效则 fail-soft 为 hold——
	# 不查询 mutable Source current，也不静默截断成误导性的 partial authority。
	var baseline := _world_projector.project_world_only(session_runtime.world_state)
	if not baseline.success:
		return _publish({"success": true, "status": "hold", "hold_reason": String(baseline.get("status", "baseline_unavailable")), "source_turn_index": opportunity_turn_index})
	# INV-10：评估启动时冻结 opportunity turn/hash + accepted count + current active head。
	_active = {
		"source_turn_index": opportunity_turn_index,
		"source_gm_sha256": opportunity_gm_sha256,
		"accepted_count": entries.size(),
		"evolution_base_head_id": String(session_runtime.active_head_id),
		"baseline_text": String(baseline.context_text),
	}
	_response_text = ""
	evaluation_attempt_count += 1
	var messages := _evaluation_messages(_active)
	evaluation_requested.emit(opportunity_turn_index, messages.duplicate(true))
	var start_error: Error = provider_adapter.start_stream(messages)
	# missing-key 等同步 failed signal 可能已清空 active；只在仍是同一请求时补发 start failure。
	if start_error != OK and not _active.is_empty():
		_finish_active({"success": false, "status": "evaluation_start_failure", "provider_error": start_error})
	return {"success": true, "status": "evaluation_started", "source_turn_index": opportunity_turn_index}


## Evaluator 输入是 bounded GM 级世界因果视图：frozen World-only T0 baseline +
## latest accepted 行动/叙事 + recent current-hash semantic changes / Agency actions /
## prior evolution events。不含 Actor Knowledge Provenance 或 Character 私有材料。
func _evaluation_messages(opportunity: Dictionary) -> Array:
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	var latest := entries[-1] as Dictionary
	var accepted_hashes := _current_accepted_hashes()
	var material := "%s\n\nLatest Accepted Player Action\n%s\n\nLatest Accepted GM Narrative\n%s\n\n%s\n\n%s\n\n%s" % [
		String(opportunity.baseline_text),
		String(latest.get("player_text", "")),
		String(latest.get("gm_text", "")),
		_recent_changes_block(accepted_hashes),
		_recent_agency_block(accepted_hashes),
		_recent_evolution_block(accepted_hashes),
	]
	return [
		{"role": "system", "content": EVALUATOR_INSTRUCTIONS},
		{"role": "user", "content": material},
	]


## recent current-hash semantic world changes（最多最近 4 个 turn 的 committed consequences）。
func _recent_changes_block(accepted_hashes: Dictionary) -> String:
	var living_world_value: Variant = session_runtime.world_state.get("living_world", {})
	if typeof(living_world_value) != TYPE_DICTIONARY:
		return "## Recent World Changes\n（无）"
	var records_value: Variant = (living_world_value as Dictionary).get("semantic_turns_by_index", {})
	if typeof(records_value) != TYPE_DICTIONARY:
		return "## Recent World Changes\n（无）"
	var matching: Array = []
	for record_value: Variant in (records_value as Dictionary).values():
		if typeof(record_value) != TYPE_DICTIONARY:
			continue
		var record := record_value as Dictionary
		if not Rules.record_is_valid(record):
			continue
		var record_turn := int(record.get("source_turn_index", -1))
		if not accepted_hashes.has(record_turn) or String(record.get("source_gm_sha256", "")) != String(accepted_hashes[record_turn]):
			continue
		matching.append(record)
	matching.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.source_turn_index) < int(b.source_turn_index))
	if matching.size() > 4:
		matching = matching.slice(matching.size() - 4)
	var lines := PackedStringArray()
	for record: Dictionary in matching:
		for change: String in record.get("changes", []):
			lines.append("- %s" % change.left(200))
	return "## Recent World Changes\n" + ("\n".join(lines) if not lines.is_empty() else "（无）")


## recent current-hash Agency actions/effects（最近一个 matching cycle 的 committed actions）。
func _recent_agency_block(accepted_hashes: Dictionary) -> String:
	var living_world_value: Variant = session_runtime.world_state.get("living_world", {})
	if typeof(living_world_value) != TYPE_DICTIONARY:
		return "## Recent Independent Actor Actions\n（无）"
	var cycles_value: Variant = (living_world_value as Dictionary).get("agency_cycles_by_source_turn", {})
	if typeof(cycles_value) != TYPE_DICTIONARY:
		return "## Recent Independent Actor Actions\n（无）"
	var matching: Array = []
	for cycle_value: Variant in (cycles_value as Dictionary).values():
		if typeof(cycle_value) != TYPE_DICTIONARY:
			continue
		var cycle := cycle_value as Dictionary
		if not Rules.agency_cycle_is_valid(cycle):
			continue
		var cycle_turn := int(cycle.get("source_turn_index", -1))
		if not accepted_hashes.has(cycle_turn) or String(cycle.get("source_gm_sha256", "")) != String(accepted_hashes[cycle_turn]):
			continue
		matching.append(cycle)
	if matching.is_empty():
		return "## Recent Independent Actor Actions\n（无）"
	matching.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.source_turn_index) < int(b.source_turn_index))
	var latest := matching[-1] as Dictionary
	var lines := PackedStringArray()
	var actions_value: Variant = latest.get("actions_by_actor", {})
	if typeof(actions_value) == TYPE_DICTIONARY:
		var actor_ids := (actions_value as Dictionary).keys()
		actor_ids.sort()
		for actor_id: String in actor_ids:
			var action := (actions_value as Dictionary)[actor_id] as Dictionary
			if not Rules.agency_action_is_valid(action):
				continue
			lines.append("- %s: %s" % [actor_id, String(action.action).left(200)])
			for effect: String in action.get("effects", []):
				lines.append("  - %s" % effect.left(200))
	return "## Recent Independent Actor Actions\n" + ("\n".join(lines) if not lines.is_empty() else "（无）")


## recent current-hash prior World Evolution events（最多最近 RECENT_EVOLUTION_EVENTS_LIMIT 条）。
func _recent_evolution_block(accepted_hashes: Dictionary) -> String:
	var living_world_value: Variant = session_runtime.world_state.get("living_world", {})
	if typeof(living_world_value) != TYPE_DICTIONARY:
		return "## Recent World Evolution Events\n（无）"
	var events_value: Variant = (living_world_value as Dictionary).get("world_evolution_events_by_turn", {})
	if typeof(events_value) != TYPE_DICTIONARY:
		return "## Recent World Evolution Events\n（无）"
	var matching: Array = []
	for record_value: Variant in (events_value as Dictionary).values():
		if typeof(record_value) != TYPE_DICTIONARY:
			continue
		var record := record_value as Dictionary
		if not Rules.world_evolution_event_is_valid(record):
			continue
		var record_turn := int(record.get("opportunity_turn_index", -1))
		if not accepted_hashes.has(record_turn) or String(record.get("opportunity_gm_sha256", "")) != String(accepted_hashes[record_turn]):
			continue
		matching.append(record)
	matching.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.opportunity_turn_index) < int(b.opportunity_turn_index))
	if matching.size() > Rules.RECENT_EVOLUTION_EVENTS_LIMIT:
		matching = matching.slice(matching.size() - Rules.RECENT_EVOLUTION_EVENTS_LIMIT)
	var lines := PackedStringArray()
	for record: Dictionary in matching:
		lines.append("- %s" % String(record.event).left(200))
		for effect: String in record.get("effects", []):
			lines.append("  - %s" % effect.left(200))
	return "## Recent World Evolution Events\n" + ("\n".join(lines) if not lines.is_empty() else "（无）")


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
	# malformed/invalid/provider 侧异常一律 fail-soft 为 no event；不自动重试本机会。
	if not parsed.success:
		_finish_active({"success": false, "status": String(parsed.status)})
		return
	if String(parsed.decision) == "hold":
		_finish_active({"success": true, "status": "hold"})
		return
	# INV-10：commit 前冻结快照仍须全部成立；foreground/Restore/head change 使工作失效。
	if not _opportunity_still_current():
		_finish_active({"success": false, "status": "stale_evaluation"})
		return
	var materialized_at := Time.get_datetime_string_from_system(true, true)
	var record := Rules.build_world_evolution_event(
		String(session_runtime.game_id),
		int(_active.source_turn_index),
		String(_active.source_gm_sha256),
		String(_active.evolution_base_head_id),
		String(parsed.event),
		parsed.effects as Array,
		materialized_at
	)
	var identities := Rules.world_evolution_identities(String(session_runtime.game_id), int(_active.source_turn_index), String(_active.source_gm_sha256), String(_active.evolution_base_head_id))
	var candidate := Rules.build_world_candidate_with_evolution(session_runtime.world_state, record)
	var committed: Dictionary = session_runtime.commit_world_mutation_durably(String(identities.mutation_id), String(identities.node_id), candidate)
	if not committed.success:
		_finish_active({
			"success": false,
			"status": "persistence_failure",
			"storage_status": String(committed.get("status", "unknown")),
		})
		return
	_finish_active({
		"success": true,
		"status": "committed" if String(committed.status) == "committed" else String(committed.status),
		"world_evolution_id": String(record.world_evolution_id),
		"event": String(record.event),
		"effect_count": (record.effects as Array).size(),
		"head_id": String(committed.head_id),
	})


## INV-10：同一机会仍是 latest accepted ordinary turn、GM hash 未变、accepted count 未变、
## active head 仍等于 evolution_base_head_id、foreground 空闲——全部成立才允许 commit。
func _opportunity_still_current() -> bool:
	if session_runtime == null or not session_runtime.is_ready():
		return false
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	if entries.is_empty():
		return false
	var latest := entries[-1] as Dictionary
	if int(latest.get("turn_index", -1)) != int(_active.source_turn_index):
		return false
	if Rules.gm_sha256(String(latest.get("gm_text", ""))) != String(_active.source_gm_sha256):
		return false
	if entries.size() != int(_active.accepted_count):
		return false
	if String(session_runtime.active_head_id) != String(_active.evolution_base_head_id):
		return false
	if session_runtime.conversation.is_generating():
		return false
	return true


## Foreground 永远优先：新 Player attempt / Restore / progress switch 立即使 uncommitted
## 评估失效；late callback 不能 commit（commit 前还有完整 currentness 校验兜底）。
func invalidate() -> void:
	if provider_adapter != null and provider_adapter.is_busy():
		provider_adapter.cancel()
	elif not _active.is_empty():
		_finish_active({"success": false, "status": "invalidated"})


## Session teardown：取消 active transport；已 committed 的 durable event 不受影响。
func shutdown() -> void:
	if _shutting_down:
		return
	_shutting_down = true
	invalidate()


func _on_cancelled() -> void:
	if not _active.is_empty():
		_finish_active({"success": false, "status": "evaluation_cancelled"})


func _on_failed(code: String, _message: String) -> void:
	if not _active.is_empty():
		_finish_active({"success": false, "status": "evaluation_provider_failure", "provider_status": code})


func _finish_active(result: Dictionary) -> void:
	if not _active.is_empty() and not result.has("source_turn_index"):
		result["source_turn_index"] = int(_active.source_turn_index)
	_active = {}
	_response_text = ""
	_publish(result)


func _publish(result: Dictionary) -> Dictionary:
	last_result = result.duplicate(true)
	finished.emit(last_result.duplicate(true))
	return last_result.duplicate(true)


func _opportunity_key(opportunity_turn_index: int, opportunity_gm_sha256: String) -> String:
	return "%d|%s" % [opportunity_turn_index, opportunity_gm_sha256]


func _connect_provider() -> void:
	if provider_adapter == null:
		return
	provider_adapter.text_delta.connect(_on_text_delta)
	provider_adapter.completed.connect(_on_completed)
	provider_adapter.cancelled.connect(_on_cancelled)
	provider_adapter.failed.connect(_on_failed)
