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
## build_provider_messages 只是 G2-04 临时适配 seam：顺序拼接 system + accepted pairs +
## 当前 attempt user；不做 G2-05 retrieval / summarization / selection。
##
## 不是 Save / Timeline / Persistence；进程内存即全部生命周期。

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
func complete_generation() -> void:
	if not is_generating() or _active_turn == null:
		return
	var turn: RefCounted = _active_turn
	turn.player_text = turn.pending_player_text
	turn.accepted_gm_text = turn.draft_text
	turn.has_accepted_response = true
	_active_turn = null
	_correction_pending = false
	generation_state = GenerationState.COMPLETED
	generation_completed.emit(turn)


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


## G2-04 临时适配：system + accepted pairs + 当前 attempt user。
## - 当前 attempt（STREAMING）：只发 pending_player_text 的 user，request 以 user 结束（IR-03）。
##   旧 accepted assistant 留在 Domain 内作为稳定 accepted truth（cancel / fail 回滚依据），
##   但不进入 replacement request —— 它不应条件化同一 player action 的新 GM generation；
## - 已 accepted 的非 active turn：user + assistant 对；
## - 从未 completed 且非 active 的 turn（被放弃的 cancelled / failed）：完全不进 context。
func build_provider_messages(system_prompt: String) -> Array:
	var messages: Array = [{"role": "system", "content": system_prompt}]
	for turn: RefCounted in turns:
		if turn == _active_turn:
			messages.append({"role": "user", "content": turn.pending_player_text})
		elif turn.has_accepted_response:
			messages.append({"role": "user", "content": turn.player_text})
			messages.append({"role": "assistant", "content": turn.accepted_gm_text})
	return messages
