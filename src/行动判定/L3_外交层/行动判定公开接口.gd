## UI-neutral Host seam：调用方提供 stable action_id；Host 先保护 Program-owned durable result，
## 再把安全 narrative body 投影到既有 provisional Conversation draft。成功终态跨过 durable
## finalize barrier；失败/取消不接受 partial draft。timing_snapshot() 只返回当前 action 的无内容
## monotonic 相对时序，不持久化 prompt、正文或凭据。
class_name ActionAdjudicationPublicInterface
extends "res://src/行动判定/L2_流程层/公开D20行动判定流程.gd"
