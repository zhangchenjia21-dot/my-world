---
title: my world｜G4-01 World Pack v0.1 Task Packet
status: superseded-before-execution
task_id: G4-01-old
superseded_by: G4-01 Product Entry Shell / Main Menu
original_created: 2026-08-28
superseded: 2026-08-28
repository: zhangchenjia21-dot/my-world
---

# SUPERSEDED｜旧 G4-01 World Pack v0.1 Task Packet

本任务包**未执行，并已在执行前被 Owner 批准的新 G4 路线取代**。

不要把本文件发送给 Grok Build、KimiCode 或其它实施 Agent，不要基于本文件开始 `src/world_pack/` 实现。

当前权威顺序见：

- `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`
- `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md`
- `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`
- repository `AGENTS.md`

新的 G4 顺序：

```text
G4-01 Product Entry Shell / Main Menu
→ G4-02 World Pack Source v0.1 + Contract Reality Check
→ G4-03 Game Creation Composition v0.1 + New Game Flow
→ G4-04 Source → Game-local Instance
→ G4-05 Local Pack Library + Minimal Game Library
→ G4-06 Asset Resolution
→ G4-07 Two-Pack Playable Reality Test
→ G4-GATE
```

原任务包中的 World Pack Source 思路并非全部废弃，而是顺延到 **G4-02**，并根据历史开发经验增加：

- optional lightweight Entry / T0 Source seed；
- exact Source generation/fingerprint 思路；
- 历史/低魔型 + 高魔型两个 compact Pack 的 Contract Reality Check；
- 明确避免把 Opening Scenario、Character Card、Expansion、Reference Library、G5 Runtime schema 提前冻结。

原始完整任务包仍可通过 Git history 查看：

```text
b72b5ec22a235c6e533197629a05ea76a9510c77
```

需要 G4-02 时必须按当时最新 CURRENT 与最新 Task Packet Skill **重新生成正式任务包**，不得直接恢复本旧包执行。
