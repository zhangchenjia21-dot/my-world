extends RefCounted

const Device := preload("res://src/信息整理/L1_器件层/角色经历投影器.gd")
const Profile := preload("res://src/rpg视图模型/L3_外交层/RPG主机视图模型公开接口.gd")

## 只读 current Runtime，返回纯展示 Character 与按因果顺序排列的经历，无 ID/出处元数据。
## 不查询 Source Library、不调用 Provider；未就绪时返回安全空值。
static func project_session(runtime: Variant) -> Dictionary:
	if runtime == null or not runtime.is_ready() or runtime.conversation == null:
		return Device.project({}, [], {})
	return Device.project(runtime.world_state, runtime.conversation.get_durable_accepted_entries(), Profile.project_frozen_profile(runtime.world_state))
