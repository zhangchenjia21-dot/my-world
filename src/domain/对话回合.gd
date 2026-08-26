extends RefCounted

## G2-04 Turn —— 一次玩家行动与（可能经历多次 attempt 的）GM 回应的逻辑回合。
##
## Domain 纯数据结构（DEC：plain GDScript / RefCounted）：不依赖 Control / HTTP / secret /
## persistence / SceneTree 生命周期。Turn ordering 与 identity 由 Conversation 拥有的
## turns 顺序与 turn_index 保证，进程内稳定。
##
## 状态约定：
## - player_text / accepted_gm_text 是 accepted truth，只在 generation 成功 completed 时原子写入；
## - pending_player_text 是当前 attempt 实际发给 Provider 的玩家文本（retry / regenerate /
##   correction 期间可与 accepted 不同）；
## - draft_text 是 streaming 临时草稿；cancel / fail 后保留供 UI 展示，但永不进入 Provider context。

## 进程内稳定 identity（== 在 Conversation.turns 中的下标）。
var turn_index: int = -1

## accepted 玩家行动文本；从未 completed 的 turn 为空串。
var player_text: String = ""

## accepted GM 回应；从未 completed 的 turn 为空串。
var accepted_gm_text: String = ""

## 本 turn 是否已有 accepted GM 回应。
var has_accepted_response: bool = false

## 当前 / 最近一次 attempt 使用的玩家文本。
var pending_player_text: String = ""

## streaming 草稿（cancel / fail 后保留展示用，不进 context）。
var draft_text: String = ""
