class_name WorldEvolutionEvaluatorPublicInterface
extends "res://src/世界回合/L2_流程层/世界演化评估流程.gd"

## World Evolution 模块的唯一有状态外交入口。调用方只注入 current Game Runtime、
## 既有 WorldTurn runtime 引用与可选测试 adapter；durable mutation 仍由 SessionRuntime 持有。
