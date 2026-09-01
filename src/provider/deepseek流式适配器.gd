extends "res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd"

const Rules := preload("res://src/运行时设置/L0_公理层/模型运行时设置规则.gd")


## 仅保留给已验收 G2 focused harness 的 DeepSeek compatibility seam；产品调用点使用运行时模型公开接口。
func _init() -> void:
	var derived := Rules.derive_request_profile(Rules.validated_default())
	request_profile_override = (derived.request_profile as Dictionary).duplicate(true)
