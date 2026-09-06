class_name WorldTurnPublicInterface
extends "res://src/世界回合/L2_流程层/语义物化流程.gd"

## 世界回合模块的唯一有状态外交入口。调用方只注入 current Game Runtime 与可选测试
## adapter；Narrative accepted truth、SQLite 与 Timeline 仍分别由既有 owner 持有。

## MW-017：opportunity_terminal 是带 Game / source_turn_index / prefix / epoch / outcome
## 的真终态；只有当前版本发布。lived_terminal 为纯查询，成功依赖 durable receipt，
## failure/cancelled/timeout 只释放旧信息整理，不代表 empty receipt 或清空人物。
## 同步取消 transport 后旧请求 callable 失效；Bootstrap 应先关闭 curator，再关闭本 worker。
