class_name AgencySchedulerPublicInterface
extends "res://src/世界回合/L2_流程层/行动代理调度流程.gd"

## Agency Scheduler/Selector 模块的唯一有状态外交入口。调用方只注入 current Game Runtime
## 与可选 WorldTurn runtime；Narrative accepted truth、SQLite 与 Timeline 仍分别由既有 owner 持有。
