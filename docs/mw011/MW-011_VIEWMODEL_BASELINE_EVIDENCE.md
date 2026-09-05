# MW-011 G6 RPG Host ViewModel Baseline — Implementation Evidence

Status: **READY FOR INDEPENDENT REVIEW（候选）**
Implementer: Zcode + GLM-5.3-Flash（Owner weekend routing override）
Reviewer: GPT
Task Packet: `docs/tasks/MW-011_G6_RPG_HOST_VIEWMODEL_BASELINE_TASK.md`
Canonical Architecture: `Vibe-Coding/my world/architecture/ui/G6_RPG_HOST_VIEWMODEL_V0_1_DECISION.md`（FROZEN / CURRENT @ a780de3）
Task Branch: `mw-011-g6-rpg-host-viewmodel-baseline`
Worktree: `D:/AI/Projects/.worktrees/my-world/mw-011`

## 0. Worktree hygiene

```text
mw-005-r4 worktree 已移除：R4 已 integrated into main（aacc65e ∈ origin/main）、clean、
已 push 至 origin/mw-005-r4-bounded-style-weight、无未知用户工作（packet §3 授权）。
git worktree remove + prune 后按规定创建 mw-011 worktree。
```

## 1. Changed files

```text
src/rpg视图模型/L1_器件层/RPG主机视图模型.gd          # 新模块：presentation-only ViewModel 设备（确定性/无副作用/非持久化）
src/rpg视图模型/L3_外交层/RPG主机视图模型公开接口.gd  # 唯一外交入口：组合 MW-009 投影输出 + current Conversation
src/main.tscn                                         # World Surface 有界导航（概览/存档）+ Save 控件迁入 SaveSurface
src/应用壳.gd                                         # ViewModel 驱动的双 Host 渲染 + 导航处理 + 刷新点复用
tests/mw011/G6主机视图模型基线测试.gd                 # focused 测试（34 断言）
docs/mw011/MW-011_VIEWMODEL_BASELINE_EVIDENCE.md
```

无 Declarative UI DSL / Mod schema / event bus / 通用 ViewModel platform；无 HP/位置/物品/关系/阵营/任务虚构状态；无新 SQLite schema/table；无 Provider 调用。

## 2. Pass A — current presentation/lifecycle audit（真实 owner）

```text
PlayerPanelHost / WorldSurfaceHost：main.tscn 静态骨架（Header + Empty 占位）+ Shell 动态 body
  （MW-009 `_panel_body`/`_panel_label`，激活/语义终态/Restore 三刷新点全量重建）。
MW-009 投影刷新：`_refresh_player_safe_panels()` ← `_activate_game_surface()`（激活/reopen）、
  `_on_world_turn_finished_for_scheduler`（semantic terminal）、`_on_restore_completed`（Restore）。
accepted Conversation entry shape：{turn_index, player_text, gm_text}（durable pairs，
  turn_index 规范化 0..N-1；GM-only Opening 的 player_text 为空）。
Save 控件 owner：Shell 直连 `session_runtime.create_save_point/list_save_points/restore_save_point`
  与 `save_points_changed`/`restore_completed` 信号；MW-011 仅迁移其场景位置与可见性，
  G3 持久化语义零改动。
响应式：`_update_responsive_layout()`（NARROW_BREAKPOINT 1100px，Player/World toggle 折叠），
  未改动；窄模式回归证明保留。
Theme：MW-003 Palette 集中装配，未改动。
```

**刷新点结论**：现有三个 lifecycle seams 完全覆盖 recent actions / turn count 的更新时机
（每次 accepted turn 必经 semantic terminal），无需新增 Runtime 信号。

## 3. Pass B — safe-data classification

| 候选数据 | 进入 G6 v0.1 ViewModel | 处理 |
|---|---|---|
| Player identity / selected profile | YES | 经 MW-009 投影输出透传 |
| World / selected Entry identity | YES | 同上 |
| accepted Player action texts（current timeline） | YES | 新增：非空 player_text，≤4 条时间序；restore/regenerate-away 自然消失 |
| accepted Player-turn count | YES | 新增：非空 player_text 计数（排除 GM-only Opening），确定性 |
| Player Character known_facts | YES | MW-009 边界原样透传 |
| Save display metadata | YES（Save 表面） | 既有 G3 UI 状态，仅迁移位置 |
| NPC Knowledge | NO | 从不读取（测试 8） |
| raw semantic consequences | NO | 从不读取（测试 8） |
| Agency actions | NO | 从不读取（测试 8） |
| World Evolution | NO | 从不读取（测试 8） |
| GM/source instructions | NO | 从不读取（JSON 断言） |
| Literary Style Reference | NO | 从不读取（JSON 断言） |
| internal IDs/hashes/fingerprints | NO | 从不读取（JSON 断言） |
| Public-d20 control/proposal payload | NO | 从不读取 |

Character `gm_reference` sections 不进入（投影输出本就不含 raw sections）。

## 4. Exact ViewModel shape

```gdscript
{
  "success": bool,                    # MW-009 投影 fail-closed 透传
  "player_display_name": String,
  "player_profile_name": String,      # 无则 ""
  "world_display_name": String,
  "world_entry_name": String,         # 无则 ""
  "known_facts": Array[String],       # MW-009 边界（≤8、时间序、去重）原样
  "recent_actions": Array[String],    # ≤4 条最新非空 Player 行动文本，时间序（最新在尾）
  "player_turn_count": int,           # 非 empty player_text 的 accepted entries 数
}
```

白名单构造：输入 = MW-009 投影结果 + durable accepted entries；确定性 → reopen/Restore 重建一致（测试 9/10）。

## 5. Player Host / World Surface 层级与导航

```text
Player Host：主角 → <display_name> → <profile> → 世界：<world> · <entry>
             → 最近行动 → • 最近 ≤4 条（或「尚无已完成的行动。」）→ 已进行 N 个玩家回合
World Surface：
  WorldHeader → [概览|存档]（有界导航，两个 toggle Button，默认概览）
  Overview（默认）：world name → entry → 主角所知 → facts（或空态）→ 已进行 N 个玩家回合
  Save：既有 SaveHeader/SaveHint + SaveNameInput/CreateSaveButton/SaveSelector/
        LoadSaveButton/SaveResultLabel/Recovery* 原样迁入 SaveSurface；
        G3 owner/回调/校验零改动，仅可见性由导航控制
```

Narrative Host 保持主表面；无 Map/Faction/Relationship/Inventory/Quest 占位 tab；无通用导航框架。

## 6. Focused proof（tests/mw011/G6主机视图模型基线测试.gd — 34 断言 0 失败）

真实 FinalCreate 汉 Game（无 Expansion → 普通续玩路径）+ real Shell + real SQLite：

1. fresh Game 经 ViewModel 渲染 identity/profile + World/Entry 上下文；
2. 2 个 accepted Player turns 后 recent actions 按序出现且**无 reopen 实时更新**；count=2；
3. turn count 排除 GM-only Opening（Opening 后为 0）；
4. Overview 为默认右表面；Save 控件不在默认层级（save_surface 隐藏）；
5. 切换到存档 → 既有 Save UI 暴露（Overview 内容隐藏）；切回概览恢复；
6. 经 UI 创建真实 Save（list_save_points 证实）+ selector 刷新 + load 可用——G3 owner 不变；
7. 主角 knowledge 经正常 semantic seam 出现在 Overview；
8. NPC-only knowledge（生产 commit seam 注入）/ Agency action / Evolution event / 原始后果
   全部不进入 ViewModel JSON 与可见 Host；
9. close/reopen 后 ViewModel deep-equal 重建；
10. Restore 到 UI 建立的存档 → recent actions 清空、count=0、known facts 消失；
11. ViewModel JSON 无 local ID/fingerprint/instructions/style 材料；
12. world_state 无第二 truth store key（ViewModel 非持久化）；
13–14. MW-009 / MW-010 回归绿（见 §7）；
15. 响应式：900×600 窄宽 World toggle 出现、1600×900 隐藏（行为不回归）；
18. Real Provider calls = 0。

## 7. Regression matrix（Godot 4.7.2 headless，task-owned fresh roots）

```text
tests/mw011/G6主机视图模型基线测试.gd     failures=0（34 断言）
tests/mw009/玩家安全侧栏投影测试.gd       failures=0
tests/mw010/生界一体现实矩阵测试.gd       failures=0
tests/g3_04/存档读取界面测试.gd           failures=0（Save UI 迁移直接相关）
tests/g4_09uatbc01/叙事响应流式关键路径测试.gd failures=0
tests/g4_08b/公开D20界面整合测试.gd       failures=0
tests/mw005/叙事风格锚点显著性测试.gd     failures=0
tests/g2_03_会话视图离线测试.gd           failures=2 — PRE-EXISTING（T3 .invalid DNS 环境失败，
    与 MW-008 期间基线复现的完全相同；本任务未触碰 transport）
git diff --check                          clean
Windows export validation                 PASS（--export-release "Windows Desktop"）
Real Provider calls                       0
SQLite schema/table                       unchanged（无 persistence 层改动）
```

## 8. Remaining risks / notes for GPT

1. recent actions 以完整 authored 文本展示（autowrap）；极长行动文本会让 Player Host 变高——
   packet 允许的 disposable 截断留到真实 UI 反馈后再做。
2. recent actions 的刷新复用 semantic-terminal 钩子：极端情况下 semantic worker 故障但 turn
   已 accepted 时，面板会延迟到下一次刷新点更新（投影按 current state 构建，不丢数据）。
3. Save 表面内 Recover（恢复读取前进度）行为与 G3 完全一致，仅位置迁移；Owner UAT 时可一并确认。
4. 概览/存档导航为两个 toggle Button（无 ButtonGroup sub_resource，互斥由 Shell 代码保证）——
   G6 Declarative Host 启动时可被安全替换。
