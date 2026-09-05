class_name RPGHostViewModelPublicInterface
extends RefCounted

## MW-011：G6 RPG Host ViewModel 的唯一外交入口。组合两个显式安全输入——
## MW-009 player-safe 投影（disclosure 边界输出）+ current durable Conversation——
## 产出 presentation-only ViewModel；叶子 UI 永不直接接收 raw world_state。

const Device := preload("res://src/rpg视图模型/L1_器件层/RPG主机视图模型.gd")
const PlayerSafe := preload("res://src/玩家安全投影/L3_外交层/玩家安全投影公开接口.gd")

var _player_safe: RefCounted = null


func build_from_runtime(runtime: Variant) -> Dictionary:
	if runtime == null or not runtime.is_ready() or runtime.conversation == null:
		return Device.build({}, [])
	if _player_safe == null:
		_player_safe = PlayerSafe.new()
	return Device.build(_player_safe.project_session(runtime), runtime.conversation.get_durable_accepted_entries())
