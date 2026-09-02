## UI-neutral Host seam：调用方提供 stable action_id；Host 把 mechanics control 与 free-form
## narrative 分成独立 Provider request。Control 最多一次内部 recovery；仍不可用时以非秘密
## degradation flag fail-soft 到普通 narrative，不伪造 check/NO_CHECK truth。成功终态跨过 durable
## finalize barrier；失败/取消不接受 partial draft。timing_snapshot() 只返回无内容 monotonic 时序。
class_name ActionAdjudicationPublicInterface
extends "res://src/行动判定/L2_流程层/公开D20行动判定流程.gd"
