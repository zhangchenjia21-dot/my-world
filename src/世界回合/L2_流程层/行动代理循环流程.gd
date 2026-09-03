class_name AgencyCycleRuntimeProcess
extends Node

## G5-03M1 Multi-Actor Agency Cycle —— 每个 selected stable NPC 一个隔离 execution request，
## 并发进行，serialized durable commit；foreground player turn 永远优先。
## 不引入 round-robin、Faction agency 或通用 actor 模拟平台。

const Rules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")
const ProviderAdapter := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")

signal actor_started(actor_id)
signal actor_finished(actor_id, result)
signal cycle_finished(result)

const AGENCY_INSTRUCTIONS := "你是 my world 的后台 actor agency 执行器。只根据该 actor 自己的 Source、知识与历史，判断该 actor 当前是否有合理理由独立行动。只输出一个 JSON 对象：{\"actor_id\":\"exact-stable-id\",\"decision\":\"hold|act\",\"intent\":\"简洁意图\",\"action\":\"简洁行动\",\"effects\":[\"即时已成立后果\"]}；hold 时 intent/action/effects 可为空字符串/空数组。不要输出解释、Markdown 或推理过程。"

var session_runtime: Variant = null
var agency_cycle: Dictionary = {}
var selected_actors: Array = []
var active_requests: Dictionary = {}
var committed_actors: Array = []
var cycle_closed := false
var _provider_adapters: Dictionary = {}
var _cycle_epoch := 0
## 测试 seam：每 actor 一个 stub adapter；production 恒 null。
var test_actor_adapter_factory: Callable = Callable()


func _init(runtime: Variant = null) -> void:
	session_runtime = runtime


func _ready() -> void:
	pass


## 启动一个 Agency Cycle：对 selected actors 各发一个隔离 execution request。
## 调用方负责保证 foreground idle/current；本函数不阻塞 foreground。
func start_cycle(source_turn_index: int, source_gm_sha256: String, cycle_base_head_id: String, actors: Array) -> Dictionary:
	if session_runtime == null or not session_runtime.is_ready():
		return {"success": false, "status": "runtime_not_ready"}
	if actors.is_empty():
		return {"success": true, "status": "no_actors", "cycle_id": ""}
	if cycle_closed:
		return {"success": false, "status": "cycle_closed"}
	_cycle_epoch += 1
	var materialized_at := Time.get_datetime_string_from_system(true, true)
	agency_cycle = Rules.build_agency_cycle(String(session_runtime.game_id), source_turn_index, _gm_text_for(source_turn_index), cycle_base_head_id, materialized_at)
	selected_actors = actors.duplicate(true)
	for actor_id: String in selected_actors:
		_start_actor_execution(actor_id)
	return {"success": true, "status": "started", "cycle_id": String(agency_cycle.agency_cycle_id), "actor_count": selected_actors.size()}


func _gm_text_for(turn_index: int) -> String:
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	if turn_index < 0 or turn_index >= entries.size():
		return ""
	return String((entries[turn_index] as Dictionary).get("gm_text", ""))


## 每个 actor 的 execution request 只含该 actor 的 Source/knowledge/history；
## 不共享其它 actor 或 Player 的私有知识。
func _start_actor_execution(actor_id: String) -> void:
	var adapter: Node = test_actor_adapter_factory.call() if test_actor_adapter_factory.is_valid() else ProviderAdapter.new()
	add_child(adapter)
	var request := _actor_request(actor_id)
	active_requests[actor_id] = {"adapter": adapter, "buffer": "", "terminal": false}
	_provider_adapters[actor_id] = adapter
	adapter.text_delta.connect(func(text: String) -> void:
		if active_requests.has(actor_id):
			(active_requests[actor_id] as Dictionary).buffer = String((active_requests[actor_id] as Dictionary).buffer) + text
	)
	adapter.completed.connect(func() -> void: _on_actor_completed(actor_id))
	adapter.cancelled.connect(func() -> void: _on_actor_cancelled(actor_id))
	adapter.failed.connect(func(code: String, _message: String) -> void: _on_actor_failed(actor_id, code))
	var start_error: Error = adapter.start_stream(request)
	# start_stream 可能同步触发 completed/failed；此时 active_requests 已被清理。
	if active_requests.has(actor_id):
		actor_started.emit(actor_id)
	elif start_error != OK:
		_on_actor_failed(actor_id, "start_failure")


func _actor_request(actor_id: String) -> Array:
	var roster := Rules.actor_roster(session_runtime.world_state)
	var display := String(roster.get(actor_id, actor_id))
	var npc := _npc_for(actor_id)
	var sections := PackedStringArray()
	var source_sections: Array = npc.get("source_projection", {}).get("semantic_sections", [])
	for section_value: Variant in source_sections:
		if typeof(section_value) != TYPE_DICTIONARY:
			continue
		var section := section_value as Dictionary
		sections.append("- %s：%s" % [String(section.get("title", "")), String(section.get("content", "")).left(400)])
	var knowledge := PackedStringArray()
	var knowledge_records_value: Variant = session_runtime.world_state.get("living_world", {}).get("knowledge_turns_by_index", {})
	if typeof(knowledge_records_value) == TYPE_DICTIONARY:
		for record_value: Variant in (knowledge_records_value as Dictionary).values():
			if typeof(record_value) != TYPE_DICTIONARY:
				continue
			var record := record_value as Dictionary
			for event_value: Variant in record.get("events", []):
				if typeof(event_value) != TYPE_DICTIONARY:
					continue
				var event := event_value as Dictionary
				if String(event.get("knower_id", "")) == actor_id:
					knowledge.append("- [%s] %s" % [String(event.get("basis", "")), String(event.get("fact", "")).left(120)])
	var history := PackedStringArray()
	var agency_cycles_value: Variant = session_runtime.world_state.get("living_world", {}).get("agency_cycles_by_source_turn", {})
	if typeof(agency_cycles_value) == TYPE_DICTIONARY:
		for cycle_value: Variant in (agency_cycles_value as Dictionary).values():
			if typeof(cycle_value) != TYPE_DICTIONARY:
				continue
			var cycle := cycle_value as Dictionary
			var actions_value: Variant = cycle.get("actions_by_actor", {})
			if typeof(actions_value) != TYPE_DICTIONARY:
				continue
			var action_value: Variant = (actions_value as Dictionary).get(actor_id, {})
			if typeof(action_value) != TYPE_DICTIONARY:
				continue
			history.append("- %s" % String((action_value as Dictionary).get("action", "")).left(120))
	var material := "Actor: %s | %s\n\nSource\n%s\n\nOwn Knowledge\n%s\n\nOwn Recent Agency History\n%s" % [
		display, actor_id,
		"\n".join(sections) if not sections.is_empty() else "（无）",
		"\n".join(knowledge) if not knowledge.is_empty() else "（无）",
		"\n".join(history) if not history.is_empty() else "（无）",
	]
	return [
		{"role": "system", "content": AGENCY_INSTRUCTIONS},
		{"role": "user", "content": material},
	]


func _npc_for(actor_id: String) -> Dictionary:
	var npcs_value: Variant = session_runtime.world_state.get("guaranteed_npcs", [])
	if typeof(npcs_value) != TYPE_ARRAY:
		return {}
	for npc_value: Variant in npcs_value as Array:
		if typeof(npc_value) != TYPE_DICTIONARY:
			continue
		var npc := npc_value as Dictionary
		if String(npc.get("local_character_id", "")) == actor_id:
			return npc
	return {}


func _on_actor_completed(actor_id: String) -> void:
	if cycle_closed or not active_requests.has(actor_id):
		return
	var request := active_requests[actor_id] as Dictionary
	var buffer := String(request.buffer)
	var parsed := _parse_actor_response(buffer, actor_id)
	if not parsed.success:
		_mark_actor_terminal(actor_id, {"success": false, "status": String(parsed.status)})
		return
	if String(parsed.decision) == "hold":
		_mark_actor_terminal(actor_id, {"success": true, "status": "hold", "actor_id": actor_id})
		return
	var materialized_at := Time.get_datetime_string_from_system(true, true)
	var action := Rules.build_agency_action(String(session_runtime.game_id), String(agency_cycle.agency_cycle_id), actor_id, String(parsed.intent), String(parsed.action), parsed.effects, materialized_at)
	if not Rules.agency_action_is_valid(action):
		_mark_actor_terminal(actor_id, {"success": false, "status": "invalid_action"})
		return
	# Serialized durable commit：cycle-owned head progression 允许 sibling 已提交的 head 前进。
	var candidate := Rules.build_agency_candidate(session_runtime.world_state, agency_cycle, action)
	var identities := Rules.agency_action_identities(String(session_runtime.game_id), String(agency_cycle.agency_cycle_id), actor_id)
	var committed: Dictionary = session_runtime.commit_world_mutation_durably(String(identities.mutation_id), String(identities.node_id), candidate)
	if not committed.success:
		_mark_actor_terminal(actor_id, {"success": false, "status": "persistence_failure"})
		return
	committed_actors.append(actor_id)
	_mark_actor_terminal(actor_id, {"success": true, "status": "committed", "actor_id": actor_id, "action": action.duplicate(true)})


func _on_actor_cancelled(actor_id: String) -> void:
	_mark_actor_terminal(actor_id, {"success": false, "status": "cancelled"})


func _on_actor_failed(actor_id: String, code: String) -> void:
	_mark_actor_terminal(actor_id, {"success": false, "status": "provider_failure", "provider_status": code})


func _mark_actor_terminal(actor_id: String, result: Dictionary) -> void:
	if not active_requests.has(actor_id):
		return
	var adapter: Node = _provider_adapters.get(actor_id, null)
	if adapter != null and is_instance_valid(adapter):
		adapter.queue_free()
	active_requests.erase(actor_id)
	_provider_adapters.erase(actor_id)
	actor_finished.emit(actor_id, result)
	if active_requests.is_empty() and not cycle_closed:
		cycle_closed = true
		cycle_finished.emit({"success": true, "status": "completed", "committed_count": committed_actors.size(), "selected_count": selected_actors.size()})


## Foreground 优先：新 Conversation attempt / Restore / close 使剩余 uncommitted 失效。
func invalidate_remaining() -> void:
	if cycle_closed:
		return
	cycle_closed = true
	for actor_id: String in active_requests.keys():
		var adapter: Node = _provider_adapters.get(actor_id, null)
		if adapter != null and is_instance_valid(adapter) and adapter.is_busy():
			adapter.cancel()
	active_requests.clear()
	_provider_adapters.clear()
	cycle_finished.emit({"success": true, "status": "invalidated", "committed_count": committed_actors.size()})


func shutdown() -> void:
	invalidate_remaining()


func _parse_actor_response(response_text: String, expected_actor_id: String) -> Dictionary:
	var body := response_text.strip_edges()
	if body.is_empty():
		return {"success": false, "status": "empty_response"}
	var json := JSON.new()
	if json.parse(body) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return {"success": false, "status": "malformed_response"}
	var data := json.data as Dictionary
	if String(data.get("actor_id", "")) != expected_actor_id:
		return {"success": false, "status": "actor_mismatch"}
	var decision := String(data.get("decision", ""))
	if decision not in ["hold", "act"]:
		return {"success": false, "status": "invalid_decision"}
	if decision == "hold":
		return {"success": true, "decision": "hold"}
	var intent := String(data.get("intent", "")).strip_edges()
	var action := String(data.get("action", "")).strip_edges()
	var effects_value: Variant = data.get("effects", [])
	if intent.is_empty() or action.is_empty() or typeof(effects_value) != TYPE_ARRAY:
		return {"success": false, "status": "invalid_act_payload"}
	var effects: Array = []
	for effect_value: Variant in effects_value as Array:
		if typeof(effect_value) != TYPE_STRING:
			return {"success": false, "status": "invalid_effect"}
		effects.append(String(effect_value).strip_edges())
	return {"success": true, "decision": "act", "intent": intent, "action": action, "effects": effects}
