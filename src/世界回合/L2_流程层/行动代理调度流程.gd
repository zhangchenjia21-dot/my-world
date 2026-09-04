class_name AgencySchedulerProcess
extends Node

## G5-03M1R01 standalone Agency Scheduler/Selector —— accepted ordinary turn 只标记 dirty；
## foreground idle 且 semantic queue 清空后，基于最新 current world snapshot 发一次轻量 selector；
## validated 0..4 stable actors 后复用现有 AgencyCycleRuntimeProcess。
## 不引入 round-robin、Faction agency 或通用 actor 模拟平台。

const Rules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")
const AgencyCycle := preload("res://src/世界回合/L3_外交层/行动代理循环公开接口.gd")
const ProviderAdapter := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")

signal selector_started()
signal selector_finished(result)
signal cycle_started(cycle_id, actor_count)
## MW-002：整个 dirty opportunity 真正到达终态的 observability-only 信号（含 no actors /
## selector terminal / actor cycle terminal）。携带 frozen opportunity turn/hash；
## 不改变 dirty/foreground/selector cap/concurrency/retry 任何语义。
signal opportunity_finished(result)

const SELECTOR_INSTRUCTIONS := "你是 my world 的后台 Agency Selector。只根据当前最新世界状态，判断哪些 Eligible Stable Actors 有合理理由立即独立行动。只输出一个 JSON 对象：{\"actors\":[\"stable-id-a\",\"stable-id-b\"]}；没有 actor 需要行动时输出 {\"actors\":[]}。只从 Eligible Stable Actors 列表选择；不要选择 Player；不要编造列表之外的 ID；不要输出解释、Markdown 或推理过程。"

var session_runtime: Variant = null
var world_turn_runtime: Variant = null
var agency_cycle_runtime: Node = null
var dirty := false
var selector_active := false
var selector_adapter: Node = null
var _selector_buffer := ""
var _selector_snapshot: Dictionary = {}
var _selector_cancelled := false
## 测试 seam：selector/actor adapter 注入；production 恒 null。
var test_selector_adapter_override: Node = null
var test_actor_adapter_factory: Callable = Callable()


func _init(runtime: Variant = null, world_turn: Variant = null) -> void:
	session_runtime = runtime
	world_turn_runtime = world_turn


func _ready() -> void:
	pass


## accepted ordinary player turn 只标记 dirty；不立即启动 selector。
func mark_dirty() -> void:
	if session_runtime == null or not session_runtime.is_ready():
		return
	dirty = true


## 安全后台机会：dirty + foreground idle + semantic worker 无 active/queued + 无 selector/cycle active。
func consider_agency() -> Dictionary:
	if session_runtime == null or not session_runtime.is_ready():
		return {"success": false, "status": "runtime_not_ready"}
	if not dirty or selector_active or agency_cycle_runtime != null:
		return {"success": true, "status": "not_ready"}
	if session_runtime.conversation.is_generating():
		return {"success": true, "status": "foreground_busy"}
	if world_turn_runtime != null:
		var snapshot: Dictionary = world_turn_runtime.status_snapshot()
		if bool(snapshot.get("busy", false)) or int(snapshot.get("queued_count", 0)) > 0:
			return {"success": true, "status": "semantic_busy"}
	return _start_selector()


func _start_selector() -> Dictionary:
	# 冻结 selector snapshot：latest accepted turn/hash + current world head。
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	if entries.is_empty():
		return {"success": true, "status": "no_accepted_turn"}
	# R01C02：selector 真正启动时消费该 dirty opportunity；terminal 后不自动重试。
	dirty = false
	var latest := entries[-1] as Dictionary
	_selector_snapshot = {
		"source_turn_index": int(latest.get("turn_index", -1)),
		"source_gm_sha256": Rules.gm_sha256(String(latest.get("gm_text", ""))),
		"cycle_base_head_id": String(session_runtime.active_head_id),
		"accepted_count": entries.size(),
	}
	selector_active = true
	_selector_cancelled = false
	_selector_buffer = ""
	selector_adapter = test_selector_adapter_override if test_selector_adapter_override != null else ProviderAdapter.new()
	add_child(selector_adapter)
	var request := _selector_request()
	selector_adapter.text_delta.connect(func(text: String) -> void: _selector_buffer += text)
	selector_adapter.completed.connect(_on_selector_completed)
	selector_adapter.cancelled.connect(_on_selector_cancelled)
	selector_adapter.failed.connect(_on_selector_failed)
	selector_adapter.start_stream(request)
	selector_started.emit()
	return {"success": true, "status": "selector_started"}


## Selector 输入：bounded GM-level current-world 信息；不授予 actor 知识。
func _selector_request() -> Array:
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	var latest := entries[-1] as Dictionary
	# G5-03M2A：eligible roster 走统一 registry helper（Guaranteed + Source-backed stable + creation-authored）。
	var accepted_hashes := _current_accepted_hashes()
	var roster_lines := PackedStringArray()
	for record: Dictionary in Rules.stable_npc_records(session_runtime.world_state, accepted_hashes):
		var local_id := String(record.get("local_character_id", ""))
		var display := String(Rules.stable_actor_material(record).get("display_name", local_id))
		roster_lines.append("- %s | %s" % [display, local_id])
	var changes_text := ""
	var living_world_value: Variant = session_runtime.world_state.get("living_world", {})
	if typeof(living_world_value) == TYPE_DICTIONARY:
		var records_value: Variant = (living_world_value as Dictionary).get("semantic_turns_by_index", {})
		if typeof(records_value) == TYPE_DICTIONARY:
			# R01C01 修正 C：selector 只读 current accepted-hash-matching semantic consequences。
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
			var change_lines := PackedStringArray()
			for record: Dictionary in matching:
				for change: String in record.get("changes", []):
					change_lines.append("- %s" % change.left(200))
			if not change_lines.is_empty():
				changes_text = "## Recent World Changes\n" + "\n".join(change_lines)
	var material := "Latest Accepted Player Action\n%s\n\nLatest Accepted GM Narrative\n%s\n\nEligible Stable Actors\n%s\n\n%s" % [
		String(latest.get("player_text", "")),
		String(latest.get("gm_text", "")),
		"\n".join(roster_lines) if not roster_lines.is_empty() else "（无）",
		changes_text if not changes_text.is_empty() else "（无持久世界变化）",
	]
	return [
		{"role": "system", "content": SELECTOR_INSTRUCTIONS},
		{"role": "user", "content": material},
	]


func _on_selector_completed() -> void:
	if _selector_cancelled or not selector_active:
		return
	selector_active = false
	var parsed := _parse_selector_response(_selector_buffer)
	_selector_buffer = ""
	_cleanup_selector_adapter()
	if not parsed.success:
		var failure_result := {"success": false, "status": String(parsed.status)}
		selector_finished.emit(failure_result)
		_emit_opportunity_finished(failure_result)
		return
	var validated := _validate_candidates(parsed.actors)
	# C01 修正 A：selector output 启动 cycle 前校验 currentness。
	if not _selector_still_current():
		var stale_result := {"success": false, "status": "stale_selector"}
		selector_finished.emit(stale_result)
		_emit_opportunity_finished(stale_result)
		return
	if validated.is_empty():
		var no_actors_result := {"success": true, "status": "no_actors", "actor_count": 0}
		selector_finished.emit(no_actors_result)
		_emit_opportunity_finished(no_actors_result)
		return
	agency_cycle_runtime = AgencyCycle.new(session_runtime)
	add_child(agency_cycle_runtime)
	# R01C01 修正 B：Scheduler 拥有 cycle 生命周期；terminal 后安全 detach/free 并 re-arm。
	agency_cycle_runtime.cycle_finished.connect(_on_agency_cycle_finished)
	if test_actor_adapter_factory.is_valid():
		agency_cycle_runtime.test_actor_adapter_factory = test_actor_adapter_factory
	var started: Dictionary = agency_cycle_runtime.start_cycle(
		int(_selector_snapshot.source_turn_index),
		String(_selector_snapshot.source_gm_sha256),
		String(_selector_snapshot.cycle_base_head_id),
		validated
	)
	cycle_started.emit(String(started.get("cycle_id", "")), int(started.get("actor_count", 0)))
	selector_finished.emit({"success": true, "status": "started", "actor_count": int(started.get("actor_count", 0)), "actors": validated})


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


## R01C01 修正 B：cycle terminal 后安全 detach/free 并 re-arm；late callback 不影响新 cycle。
func _on_agency_cycle_finished(result: Dictionary) -> void:
	if agency_cycle_runtime == null:
		return
	# 只清理仍引用该 cycle 的 scheduler；late callback 不影响新 cycle。
	var finished_cycle := agency_cycle_runtime
	agency_cycle_runtime = null
	if is_instance_valid(finished_cycle):
		remove_child(finished_cycle)
		finished_cycle.queue_free()
	# 已 committed 的 durable actions 保持；Scheduler 可处理后续新 dirty 机会。
	# R01C02：不自动 retry 同一机会；后续新 accepted turn 才会再次 mark_dirty。
	# MW-002：actor cycle terminal = 整个 opportunity 的终态。
	_emit_opportunity_finished(result)


## R01C01 修正 D：selector terminal 后清理 adapter；不 strand、不 auto-retry。
func _cleanup_selector_adapter() -> void:
	if selector_adapter != null and is_instance_valid(selector_adapter):
		remove_child(selector_adapter)
		selector_adapter.queue_free()
		selector_adapter = null


func _on_selector_cancelled() -> void:
	if selector_active:
		selector_active = false
		_selector_buffer = ""
		_cleanup_selector_adapter()
		var cancelled_result := {"success": false, "status": "cancelled"}
		selector_finished.emit(cancelled_result)
		_emit_opportunity_finished(cancelled_result)


func _on_selector_failed(code: String, _message: String) -> void:
	if selector_active:
		selector_active = false
		_selector_buffer = ""
		_cleanup_selector_adapter()
		var failure_result := {"success": false, "status": "provider_failure", "provider_status": code}
		selector_finished.emit(failure_result)
		_emit_opportunity_finished(failure_result)


## C01 修正 A：selector output 启动 cycle 前校验：latest turn/hash + world head + foreground idle。
func _selector_still_current() -> bool:
	if session_runtime == null or not session_runtime.is_ready():
		return false
	var entries: Array = session_runtime.conversation.get_durable_accepted_entries()
	if entries.is_empty():
		return false
	var latest := entries[-1] as Dictionary
	if int(latest.get("turn_index", -1)) != int(_selector_snapshot.source_turn_index):
		return false
	if Rules.gm_sha256(String(latest.get("gm_text", ""))) != String(_selector_snapshot.source_gm_sha256):
		return false
	if String(session_runtime.active_head_id) != String(_selector_snapshot.cycle_base_head_id):
		return false
	if entries.size() != int(_selector_snapshot.accepted_count):
		return false
	if session_runtime.conversation.is_generating():
		return false
	return true


## Selector 验证：只保留 current eligible stable NPC roster 中的 ID；deduplicate；cap 4；
## unknown/Player/empty 丢弃；无 round-robin fallback。
func _validate_candidates(candidates: Array) -> Array:
	if candidates.is_empty():
		return []
	# G5-03M2A：eligibility = 统一 stable_npc_records（含 no-Card Game-local actor）；Player 不在此列。
	var eligible: Array = []
	for record: Dictionary in Rules.stable_npc_records(session_runtime.world_state, _current_accepted_hashes()):
		var local_id := String(record.get("local_character_id", ""))
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


## MW-002：observability-only——把 frozen opportunity turn/hash 附到 terminal result 上发出；
## 只在 selector/cycle 已经真正到达终态的路径调用，每个 started 机会恰好一次。
func _emit_opportunity_finished(result: Dictionary) -> void:
	if _selector_snapshot.is_empty():
		return
	var terminal := result.duplicate()
	terminal["source_turn_index"] = int(_selector_snapshot.source_turn_index)
	terminal["source_gm_sha256"] = String(_selector_snapshot.source_gm_sha256)
	opportunity_finished.emit(terminal)


## Foreground 优先：新 Conversation attempt 取消 selector 与剩余 uncommitted actor work。
func invalidate_remaining() -> void:
	dirty = false
	if selector_active:
		_selector_cancelled = true
		if selector_adapter != null and is_instance_valid(selector_adapter) and selector_adapter.is_busy():
			selector_adapter.cancel()
		selector_active = false
		_selector_buffer = ""
	if agency_cycle_runtime != null:
		agency_cycle_runtime.invalidate_remaining()


## Restore/Recovery/session close：取消 selector 与剩余 uncommitted actor work，清除 obsolete dirty。
func shutdown() -> void:
	invalidate_remaining()
	if agency_cycle_runtime != null:
		agency_cycle_runtime.shutdown()
		if is_instance_valid(agency_cycle_runtime):
			remove_child(agency_cycle_runtime)
			agency_cycle_runtime.queue_free()
		agency_cycle_runtime = null
	if selector_adapter != null and is_instance_valid(selector_adapter):
		remove_child(selector_adapter)
		selector_adapter.queue_free()
		selector_adapter = null


func _parse_selector_response(response_text: String) -> Dictionary:
	var body := response_text.strip_edges()
	if body.is_empty():
		return {"success": false, "status": "empty_response"}
	var json := JSON.new()
	if json.parse(body) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return {"success": false, "status": "malformed_response"}
	var actors_value: Variant = (json.data as Dictionary).get("actors", null)
	if typeof(actors_value) != TYPE_ARRAY:
		return {"success": false, "status": "invalid_actors"}
	return {"success": true, "actors": actors_value as Array}
