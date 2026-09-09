extends "res://src/信息整理/L2_流程层/回合信息整理流程.gd"

## 后台整理生命周期入口。Bootstrap 注入 Runtime 与可选 adapter；不持有前台行动锁。
## Bootstrap 注入 World semantic L3 终态屏障；等待当前 lived 身份终态，同一次整理维护角色/经历/人物/事务。
## activation 先初始化 Game/T0 基线；retry_pending 可重试初始或 lived 失败。
## finished 只发布状态，不含模型原文；渲染/有效基线的 reopen 不发起模型请求。


const Provider := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")
const FrozenProfile := preload("res://src/rpg视图模型/L3_外交层/RPG主机视图模型公开接口.gd")

func _init(runtime: Variant = null, adapter: Node = null, world_semantic: Node = null) -> void:
	semantic_barrier = world_semantic
	super(runtime, adapter if adapter != null else Provider.new(), FrozenProfile.project_frozen_profile, _read_initial_node)

# 只读本 Game 的固定节点；流程只提取经绑定验证的 initial，绝不导入该节点的 lived owner。
func _read_initial_node(node_id: String) -> Dictionary:
	return session_runtime.persistence.get_timeline_node(session_runtime.game_id, node_id)
