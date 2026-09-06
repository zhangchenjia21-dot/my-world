extends "res://src/信息整理/L2_流程层/回合信息整理流程.gd"

## 后台整理生命周期入口。Bootstrap 注入 Runtime 与可选 adapter；不持有前台行动锁。
## retry_pending 显式重试当前历史中尚未成功的版本；finished 只发布状态，不含模型原文。


const Provider := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")
const FrozenProfile := preload("res://src/rpg视图模型/L3_外交层/RPG主机视图模型公开接口.gd")

func _init(runtime: Variant = null, adapter: Node = null) -> void:
	super(runtime, adapter if adapter != null else Provider.new(), FrozenProfile.project_frozen_profile)
