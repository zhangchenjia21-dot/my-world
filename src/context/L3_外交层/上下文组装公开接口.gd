## Context 模块的稳定公开入口；调用方只依赖组装合同，不接触其历史根级实现路径。
class_name ContextAssemblyPublicInterface
extends "res://src/context/上下文组装器.gd"

const RuntimeSettings := preload("res://src/运行时设置/L3_外交层/模型运行时设置公开接口.gd")


## 上下文上限是 request planning metadata；当前保守 recent-turn 策略允许少用，但不得越过 validated ceiling。
func runtime_budget_metadata() -> Dictionary:
	return RuntimeSettings.new().context_budget_metadata()
