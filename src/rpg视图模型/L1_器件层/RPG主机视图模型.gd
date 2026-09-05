class_name RPGHostViewModelDevice
extends RefCounted

## MW-011 / G6 RPG Host ViewModel v0.1（canonical decision §3–§5）。
##
## presentation-only、确定性、无副作用、非持久化、无 Provider 调用、非第二状态存储。
## 输入是显式安全材料：MW-009 player-safe 投影结果（disclosure 边界的输出）+
## current durable accepted Conversation 派生的 recent actions / turn count。
## 叶子 widget 只消费本 ViewModel 字段，永不接收 raw world_state。
##
## 不虚构 HP / 位置 / 物品 / 关系 / 阵营 / 任务等不存在的领域状态；
## 不包含 NPC Knowledge / 原始后果 / Agency / Evolution / 指令 / Style / 内部 ID。

## 玩家最近行动的展示上限（canonical decision §3 建议 3–4 条）。
const MAX_RECENT_ACTIONS := 4


## player_safe：既有 MW-009 投影结果；accepted_entries：current durable accepted pairs。
## 确定性：同一输入恒产出同一 ViewModel（Restore/reopen 后重建结果一致）。
static func build(player_safe: Dictionary, accepted_entries: Array) -> Dictionary:
	var recent_all: Array = []
	var player_turn_count := 0
	for entry_value: Variant in accepted_entries:
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue
		var entry := entry_value as Dictionary
		var action_text := String(entry.get("player_text", "")).strip_edges()
		# GM-only Opening（empty player_text）不计入玩家回合与最近行动。
		if action_text.is_empty():
			continue
		player_turn_count += 1
		recent_all.append(action_text)
	var recent_actions: Array = recent_all.slice(maxi(0, recent_all.size() - MAX_RECENT_ACTIONS))
	return {
		"success": bool(player_safe.get("success", false)),
		"player_display_name": String(player_safe.get("player_display_name", "")),
		"player_profile_name": String(player_safe.get("player_profile_name", "")),
		"world_display_name": String(player_safe.get("world_display_name", "")),
		"world_entry_name": String(player_safe.get("world_entry_name", "")),
		"known_facts": (player_safe.get("known_facts", []) as Array).duplicate(true),
		"recent_actions": recent_actions,
		"player_turn_count": player_turn_count,
	}
