extends Node

const Contract := preload("res://src/调试观测/L0_公理层/诊断展示契约.gd")
const Recorder := preload("res://src/调试观测/L1_器件层/会话诊断记录器.gd")
const Identity := preload("res://src/世界回合/L3_外交层/人物身份桥公开接口.gd")
const Character := preload("res://src/信息整理/L3_外交层/角色经历投影公开接口.gd")
const Threads := preload("res://src/信息整理/L3_外交层/事务投影公开接口.gd")
const People := preload("res://src/信息整理/L3_外交层/人物投影公开接口.gd")
signal changed
var _runtime: RefCounted
var _records := Recorder.new()
var _epoch := 0
var _closed := false
var _subscriptions: Array = []
var _curation: Dictionary = {}
var _recommendations: Dictionary = {}

## Shell 每次 Game activation 创建；只订阅现有终态，不发请求、不写 Runtime/持久层。
func _init(runtime: RefCounted) -> void:
	_runtime = runtime

func _ready() -> void:
	_listen(_runtime.conversation.generation_completed, _accepted)
	_listen(_runtime.conversation.generation_failed, _failed)
	_listen(_runtime.conversation.generation_cancelled, _cancelled)
	_listen(_runtime.restore_completed, _restored)

func _listen(source: Signal, callback: Callable) -> void:
	source.connect(callback)
	_subscriptions.append([source, callback])

## 连接同一 activation 的 World L3 终态；必须先创建观测 owner，再创建各 producer。
func observe_world(world: Node) -> void:
	_listen(world.opportunity_terminal, _world_terminal)

## Curator 的 before/after 只经安全 L3 投影；版本 context 留在本 owner。
func observe_curator(curator: Node) -> void:
	_listen(curator.diagnostic_started, _curation_started)
	_listen(curator.diagnostic_terminal, _curation_terminal)

## 只订阅推荐的诊断信号，不改 player-facing snapshot 或机会调度。
func observe_recommender(recommender: Node) -> void:
	_listen(recommender.diagnostic_started, _recommendation_started)
	_listen(recommender.diagnostic_terminal, _recommendation_terminal)

func _entries() -> Array:
	return _runtime.conversation.get_durable_accepted_entries()

func _token(index: int) -> Dictionary:
	return {"epoch": _epoch, "index": index, "prefix": Identity.accepted_prefix(_entries(), index)}

func _current(token: Dictionary) -> bool:
	return not _closed and token.epoch == _epoch and (token.index < 0 or (token.index < _entries().size() and token.prefix == Identity.accepted_prefix(_entries(), token.index)))

func _put(token: Dictionary, lane: String, terminal: String, change: String, code: String, counts: Dictionary = {}, elapsed: int = -1) -> void:
	if not _current(token): return
	_records.put(token, Contract.row(lane, token.index, terminal, change, code, counts, elapsed), lane not in ["save", "restore"])
	changed.emit()

## 返回最多64条纯结构展示行，无 epoch/hash/actor ID/ref/原始 payload。
func snapshot() -> Array:
	_records.retain_current(_current)
	return _records.snapshot()

func _accepted(turn: RefCounted) -> void:
	_records.retain_current(_current)
	_put(_token(turn.turn_index), "narrative", "accepted", "unknown", "accepted")

func _failed(_turn: RefCounted, code: String) -> void:
	_put(_token(-1), "narrative", "failed", "unknown", code)

func _cancelled(_turn: RefCounted) -> void:
	_put(_token(-1), "narrative", "cancelled", "unknown", "cancelled")

func _world_terminal(result: Dictionary) -> void:
	var token := {"epoch": int(result.get("epoch", -1)), "index": int(result.get("source_turn_index", -1)), "prefix": String(result.get("prefix", ""))}
	if not _current(token): return
	var ok := bool(result.get("success", false))
	var code := Contract.reason(String(result.get("status", "")))
	var terminal := "committed" if ok else (code if code in ["stale", "cancelled"] else "failed")
	# 历史复用/跳过不是新事务；缺失计数时不把未知伪装成 no-change。
	var world_counts := {}
	for pair: Array in [["change_count", "changes"], ["knowledge_count", "knowledge"]]:
		if ok and result.has(pair[0]): world_counts[pair[1]] = result[pair[0]]
	var world_change := "unknown"
	if ok and result.has("change_count"): world_change = "changed" if int(result.change_count) > 0 else "no-change"
	var success_code := "historical_skipped" if result.get("status") == "historical_skipped" else ("already_materialized" if result.get("status") == "already_materialized" else "committed")
	_put(token, "world", "unavailable" if success_code == "historical_skipped" and ok else terminal, world_change, success_code if ok else code, world_counts)
	var identity_counts := {}
	for pair: Array in [["actor_count", "actors"], ["binding_count", "bindings"]]:
		if ok and result.has(pair[0]): identity_counts[pair[1]] = result[pair[0]]
	var identity_change := "unknown"
	if identity_counts.size() == 2: identity_change = "changed" if int(identity_counts.actors) + int(identity_counts.bindings) > 0 else "no-change"
	_put(token, "identity", "unavailable" if success_code == "historical_skipped" and ok else terminal, identity_change, success_code if ok else code, identity_counts)

func _safe_information() -> Dictionary:
	var projection := Character.project_session(_runtime)
	return {"character": projection.character, "experiences": projection.important_experiences, "people": People.project_session(_runtime), "threads": Threads.project_session(_runtime)}

func _curation_started(context: Dictionary) -> void:
	# before/after 均来自安全 L3；只在 owner 内比较，叶 UI 不接收任何内容文本。
	_curation[context.request] = {"token": _token(int(context.source_turn_index)), "context": context.duplicate(), "before": _safe_information()}
	while _curation.size() > Contract.CAPACITY: _curation.erase(_curation.keys()[0])

func _curation_terminal(result: Dictionary) -> void:
	var request: int = int(result.get("request", -1))
	if not _curation.has(request): return
	var pending: Dictionary = _curation[request]
	_curation.erase(request)
	if result.get("epoch", -1) != pending.context.epoch or result.get("prefix", "") != pending.context.prefix or result.get("source_turn_index", -2) != pending.context.source_turn_index: return
	var lanes := ["character", "experiences", "people"]
	if int(pending.token.index) >= 0: lanes.append("threads")
	var code := Contract.reason(String(result.get("status", "")))
	if not _current(pending.token):
		if pending.token.epoch != _epoch: return
		for lane: String in lanes: _put(_token(-1), lane, "stale", "unknown", "stale")
		return
	if not bool(result.get("success", false)):
		for lane: String in lanes:
			_put(pending.token, lane, code if code in ["stale", "cancelled"] else "failed", "unknown", code)
		return
	var after := _safe_information()
	for lane: String in lanes:
		var changed_value: bool = pending.before[lane] != after[lane]
		var counts := {}
		# People 安全投影故意没有 stable ID；不靠姓名配对推算 add/update/remove。
		if lane in ["people", "threads"]: counts = {"total": after[lane].size()}
		if lane == "experiences":
			counts = {"total": after[lane].size(), "added": maxi(0, after[lane].size() - pending.before[lane].size()), "removed": maxi(0, pending.before[lane].size() - after[lane].size())}
		_put(pending.token, lane, "committed", "changed" if changed_value else "no-change", "committed", counts)

func _recommendation_started(context: Dictionary) -> void:
	_recommendations[context.request] = {"token": _token(int(context.source_turn_index)), "context": context.duplicate()}
	while _recommendations.size() > Contract.CAPACITY: _recommendations.erase(_recommendations.keys()[0])

func _recommendation_terminal(result: Dictionary) -> void:
	var request := int(result.get("request", -1))
	if not _recommendations.has(request): return
	var pending: Dictionary = _recommendations[request]
	_recommendations.erase(request)
	if result.get("prefix", "") != pending.context.prefix or result.get("source_turn_index", -2) != pending.context.source_turn_index: return
	var token: Dictionary = pending.token
	if not _current(token):
		if token.epoch == _epoch: _put(_token(-1), "recommendations", "stale", "unknown", "stale")
		return
	_put(token, "recommendations", String(result.get("terminal", "failed")), "unknown", String(result.get("status", "")), {"total": 5 if result.get("terminal") == "ready" else 0}, int(result.get("elapsed_ms", -1)))

func _restored(_result: Dictionary) -> void:
	_epoch += 1
	_records.clear()
	_curation.clear()
	_recommendations.clear()
	_put(_token(-1), "restore", "restored", "unknown", "restored")

## Shell 在既有 Save/Restore 操作返回后调用；忽略 message、路径、display label 等自由文本。
## 成功的实际 Restore 由 restore_completed 清 epoch；already_current 只记录结果。
func record_operation(lane: String, result: Dictionary) -> void:
	if lane not in ["save", "restore"] or _closed: return
	if lane == "restore" and result.get("success", false) and result.get("status") != "already_current": return
	var terminal: String = ("saved" if lane == "save" else "restored") if result.get("success", false) else "failed"
	_put(_token(-1), lane, terminal, "unknown", ("backup_warning" if result.get("backup_warning", false) else ("already_current" if result.get("status") == "already_current" else terminal)) if result.get("success", false) else "persistence_failure")

## 必须在 producer/Runtime 释放前调用；本 activation 的订阅与所有记录一起丢弃。
func shutdown() -> void:
	if _closed: return
	_closed = true
	for subscription: Array in _subscriptions:
		if subscription[0].is_connected(subscription[1]): subscription[0].disconnect(subscription[1])
	_subscriptions.clear()
	_records.clear()
	_curation.clear()
	_recommendations.clear()
	_runtime = null

func _exit_tree() -> void:
	shutdown()
