extends RefCounted

## G2-04 Conversation v0.1 —— Turn 序列与 Generation State 的唯一 authoritative owner。
##
## Domain 边界（DEC）：plain GDScript / RefCounted；不依赖 Control / HTTP / secret /
## persistence / SceneTree 生命周期。UI（叙事对话视图）只是本对象的 projection，
## 不再持有第二套 history / generation flags。
##
## 拥有的不变量：
## - Turn ordering / identity：turns 顺序即回合顺序，turn_index 进程内稳定，只增不减；
## - accepted truth 原子替换：只有 generation 成功 completed 才把 pending -> accepted；
##   regenerate / correction 成功前旧 accepted 在 Domain 内保持稳定（不再进入 Provider
##   replacement request，IR-03），cancel / fail 自动回滚（G2-03 IR-02 语义域化）；
## - latest-turn correction 只限最新 Turn；
## - 从未 completed 的 turn（被放弃的 cancelled / failed attempt）不进入后续 Provider context。
##
## 本对象不执行 Persistence I/O。G3-03 只增加 accepted truth 的 rehydration 与
## prospective completion read seam；durable ordering 由 application runtime 编排。

const Turn := preload("res://src/domain/对话回合.gd")

enum GenerationState {
	IDLE,
	STREAMING,
	COMPLETED,
	CANCELLED,
	FAILED,
}

## 新 player turn 建立（begin_turn）。
signal turn_started(turn)
## 一次 generation attempt 开始（begin_turn / retry / regenerate / correction 都触发）；
## UI 据此重置当前 GM block 的展示。
signal attempt_started(turn)
signal draft_appended(text)
signal generation_completed(turn)
signal generation_cancelled(turn)
signal generation_failed(turn, code)

## 全部 turns，顺序即回合顺序。只增不减。
var turns: Array = []
var generation_state: GenerationState = GenerationState.IDLE

var _active_turn: RefCounted = null
## correction attempt 进行中标记：cancel / fail 时把 pending_player_text 回滚为 accepted player_text。
var _correction_pending: bool = false


## 新玩家行动开启新 Turn。STREAMING 中拒绝（UI 已防止，此处仅防御）。
func begin_turn(text: String) -> RefCounted:
	if is_generating():
		push_warning("G2-04: begin_turn during active generation")
		return null
	var turn: RefCounted = Turn.new()
	turn.turn_index = turns.size()
	turn.pending_player_text = text
	turns.append(turn)
	_active_turn = turn
	_correction_pending = false
	generation_state = GenerationState.STREAMING
	turn_started.emit(turn)
	attempt_started.emit(turn)
	return turn


## 对最新 Turn 发起 retry（从未 completed）或 regenerate（已有 accepted）。
## regenerate 成功前旧 accepted 保持不变；成功时由 complete_generation() 原子替换。
func retry_or_regenerate_latest() -> RefCounted:
	var turn := latest_turn()
	if turn == null or is_generating():
		return null
	# regenerate：attempt 复用 accepted 玩家文本；retry：沿用上次 attempt 文本。
	if turn.has_accepted_response:
		turn.pending_player_text = turn.player_text
	turn.draft_text = ""
	_active_turn = turn
	_correction_pending = false
	generation_state = GenerationState.STREAMING
	attempt_started.emit(turn)
	return turn


## 修改最新 Turn 的玩家文本并重新生成（latest-turn correction，只限最新 Turn）。
## - completed latest：成功才原子替换 player_text + accepted_gm_text；
##   cancel / fail 只回滚 pending，accepted 不动；
## - cancelled / failed 且从未 completed 的 latest：同一 identity 换文本重试。
func correct_latest(new_text: String) -> RefCounted:
	var turn := latest_turn()
	if turn == null or is_generating() or new_text.strip_edges().is_empty():
		return null
	turn.pending_player_text = new_text
	turn.draft_text = ""
	_active_turn = turn
	_correction_pending = turn.has_accepted_response
	generation_state = GenerationState.STREAMING
	attempt_started.emit(turn)
	return turn


## Provider text_delta 的 Domain 入口：只有 STREAMING 中接受草稿。
func append_delta(text: String) -> void:
	if not is_generating() or _active_turn == null:
		return
	_active_turn.draft_text += text
	draft_appended.emit(text)


## 当前 attempt 成功：原子生效 accepted truth。
## 新 turn：pending -> player_text，draft -> accepted_gm_text；
## regenerate：同一 turn identity 上原子替换 GM 回应，player 不产生第二条；
## correction：原子替换玩家文本 + GM 回应。
## IR-04：zero-length / whitespace-only draft 不产生可接受的 GM Narrative ——
## 转为 failed-equivalent（code == empty_generation），accepted truth 不动、可 retry；
## 任何非空白内容（哪怕 1 个字符）都允许成为模型输出，不设最小字数。
func complete_generation() -> void:
	if not is_generating() or _active_turn == null:
		return
	if String(_active_turn.draft_text).strip_edges().is_empty():
		_end_attempt(GenerationState.FAILED, "empty_generation")
		return
	var turn: RefCounted = _active_turn
	turn.player_text = turn.pending_player_text
	turn.accepted_gm_text = turn.draft_text
	turn.has_accepted_response = true
	_active_turn = null
	_correction_pending = false
	generation_state = GenerationState.COMPLETED
	generation_completed.emit(turn)


## 返回当前 completion 成功后将形成的 accepted materialization，但不修改 Domain truth。
## new / regenerate / correction 继续复用本对象既有 replacement 语义，Runtime 只能先持久化
## 此 candidate，再调用 complete_generation()；空白 draft 不产生 candidate。
func get_completion_candidate() -> Dictionary:
	if not is_generating() or _active_turn == null:
		return {"ok": false, "code": "no_active_generation", "accepted_entries": []}
	if String(_active_turn.draft_text).strip_edges().is_empty():
		return {"ok": false, "code": "empty_generation", "accepted_entries": []}
	var candidate: Array = get_durable_accepted_entries()
	var replacement := {
		"turn_index": 0,
		"player_text": String(_active_turn.pending_player_text),
		"gm_text": String(_active_turn.draft_text),
	}
	if _active_turn.has_accepted_response:
		if candidate.is_empty():
			return {"ok": false, "code": "invalid_accepted_state", "accepted_entries": []}
		replacement.turn_index = candidate.size() - 1
		candidate[candidate.size() - 1] = replacement
	else:
		replacement.turn_index = candidate.size()
		candidate.append(replacement)
	return {"ok": true, "code": "", "accepted_entries": candidate}


## current resume 的唯一 rehydration seam。输入必须是完整、有序的 accepted pairs；
## streaming/cancelled/failed material 不在此契约中。成功后没有 active generation，
## turn_index 按 durable order 重新建立为 0..N-1。
func restore_accepted_entries(entries: Array) -> Dictionary:
	if not turns.is_empty() or is_generating():
		return {"ok": false, "error": "Conversation must be empty before rehydration"}
	return _apply_validated_entries(entries)


## Save/Restore 的 non-mutating validation seam。它与 rehydration/replace 共用同一规则，
## 但不触碰 live turns、generation state 或 active attempt。
func validate_accepted_entries(entries: Variant) -> Dictionary:
	if typeof(entries) != TYPE_ARRAY:
		return {"ok": false, "error": "accepted entries must be an Array", "accepted_entries": []}
	var validated: Array = []
	for index: int in range((entries as Array).size()):
		var value: Variant = (entries as Array)[index]
		if typeof(value) != TYPE_DICTIONARY:
			return {"ok": false, "error": "accepted entry %d must be a Dictionary" % index, "accepted_entries": []}
		var entry := value as Dictionary
		if typeof(entry.get("player_text")) != TYPE_STRING or typeof(entry.get("gm_text")) != TYPE_STRING:
			return {"ok": false, "error": "accepted entry %d must contain String player_text/gm_text" % index, "accepted_entries": []}
		if String(entry.gm_text).strip_edges().is_empty():
			return {"ok": false, "error": "accepted entry %d contains empty GM truth" % index, "accepted_entries": []}
		validated.append({
			"turn_index": index,
			"player_text": String(entry.player_text),
			"gm_text": String(entry.gm_text),
		})
	return {"ok": true, "error": "", "accepted_entries": validated}


## Durable Restore COMMIT 后替换 current accepted truth。调用前必须已用
## validate_accepted_entries() 预检；active generation 期间拒绝替换，避免旧 callback 回写。
func replace_accepted_entries(entries: Array) -> Dictionary:
	if is_generating():
		return {"ok": false, "error": "Conversation cannot be replaced during active generation"}
	return _apply_validated_entries(entries)


func _apply_validated_entries(entries: Array) -> Dictionary:
	var validation := validate_accepted_entries(entries)
	if not validation.ok:
		return validation
	var restored: Array = []
	for index: int in range(validation.accepted_entries.size()):
		var entry := validation.accepted_entries[index] as Dictionary
		var turn: RefCounted = Turn.new()
		turn.turn_index = index
		turn.player_text = String(entry.player_text)
		turn.pending_player_text = turn.player_text
		turn.accepted_gm_text = String(entry.gm_text)
		turn.has_accepted_response = true
		restored.append(turn)
	turns = restored
	_active_turn = null
	_correction_pending = false
	generation_state = GenerationState.COMPLETED if not turns.is_empty() else GenerationState.IDLE
	return {"ok": true, "accepted_count": turns.size()}


## 当前 attempt 取消：accepted truth 不动；correction 回滚 pending。
func cancel_generation() -> void:
	_end_attempt(GenerationState.CANCELLED)


## 当前 attempt 失败：语义同 cancel。
func fail_generation(code: String) -> void:
	_end_attempt(GenerationState.FAILED, code)


func _end_attempt(end_state: GenerationState, code: String = "") -> void:
	if not is_generating() or _active_turn == null:
		return
	var turn: RefCounted = _active_turn
	if _correction_pending:
		turn.pending_player_text = turn.player_text
	_correction_pending = false
	_active_turn = null
	generation_state = end_state
	if end_state == GenerationState.CANCELLED:
		generation_cancelled.emit(turn)
	else:
		generation_failed.emit(turn, code)


func latest_turn() -> RefCounted:
	if turns.is_empty():
		return null
	return turns[-1]


func is_generating() -> bool:
	return generation_state == GenerationState.STREAMING


## 每条 accepted 回合一条 {turn_index, player_text, gm_text} 的只读 projection。
func get_accepted_entries() -> Array:
	var entries_out: Array = []
	for turn: RefCounted in turns:
		if turn.has_accepted_response:
			entries_out.append({
				"turn_index": turn.turn_index,
				"player_text": turn.player_text,
				"gm_text": turn.accepted_gm_text,
			})
	return entries_out


## Durable current Conversation projection 只包含有序 accepted pair；turn_index 在输出中
## 规范化为 0..N-1，因此进程内被放弃的未 accepted Turn 不会制造重启后的 identity gap。
func get_durable_accepted_entries() -> Array:
	var output: Array = []
	for turn: RefCounted in turns:
		if turn.has_accepted_response:
			output.append({
				"turn_index": output.size(),
				"player_text": turn.player_text,
				"gm_text": turn.accepted_gm_text,
			})
	return output


## Context Assembly 的只读输入契约。
##
## 返回值是从 authoritative Turn truth 派生的新 Dictionary/Array；调用方可以裁剪、排序或
## 修改该 read model，但不能借此反向改写 Conversation。active_attempt 只暴露当前实际将发给
## Provider 的 pending player text；replacement 期间旧 accepted pair 仍留在 accepted_turns，
## 由 Context Assembly 按相同 turn_index 排除，维持 G2-04 的原子替换/回滚不变量。
func get_context_projection() -> Dictionary:
	var accepted_turns: Array = []
	for turn: RefCounted in turns:
		if turn.has_accepted_response:
			accepted_turns.append({
				"turn_index": turn.turn_index,
				"player_text": turn.player_text,
				"gm_text": turn.accepted_gm_text,
			})

	var active_attempt: Variant = null
	if _active_turn != null:
		active_attempt = {
			"turn_index": _active_turn.turn_index,
			"player_text": _active_turn.pending_player_text,
		}

	return {
		"accepted_turns": accepted_turns,
		"active_attempt": active_attempt,
	}
