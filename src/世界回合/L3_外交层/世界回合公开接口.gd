class_name WorldTurnPublicInterface
extends "res://src/世界回合/L2_流程层/语义物化流程.gd"

## 世界回合模块的唯一有状态外交入口。调用方只注入 current Game Runtime 与可选测试
## adapter；Narrative accepted truth、SQLite 与 Timeline 仍分别由既有 owner 持有。
