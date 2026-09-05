# MW-009 Player-Safe Runtime Side Panels — Implementation Evidence

Status: **READY FOR INDEPENDENT REVIEW（候选）**
Implementer: Zcode + GLM-5.3-Flash（Owner weekend routing override）
Reviewer: GPT
Task Packet: `docs/tasks/MW-009_PLAYER_SAFE_RUNTIME_SIDE_PANELS_TASK.md`
Canonical Architecture: `Vibe-Coding/my world/architecture/world/G5_PLAYER_SAFE_RUNTIME_UI_PROJECTION_V0_1_DECISION.md`（FROZEN / CURRENT @ 5b2acb9）
Task Branch: `mw-009-player-safe-runtime-side-panels`
Worktree: `D:/AI/Projects/.worktrees/my-world/mw-009`

## 0. Worktree cleanup report（packet §6）

```text
mw-008 worktree 已移除：MW-008 已过 GPT IR 并合入 main（92b21ae 激活提交）；working tree
clean；唯一提交 9f90e63 已 push 至 origin/mw-008-safe-markdown-lite-rendering；无未知用户工作。
git worktree remove + prune；随后按规定创建 D:/AI/Projects/.worktrees/my-world/mw-009。
```

## 1. Changed files

```text
src/玩家安全投影/L1_器件层/玩家安全投影器.gd        # 新模块：fail-closed 投影设备（identity + bounded facts）
src/玩家安全投影/L3_外交层/玩家安全投影公开接口.gd  # disclosure 边界唯一外交入口（project_session(runtime)）
src/应用壳.gd                                       # 侧栏渲染 + 三个既有 lifecycle 刷新点
tests/mw009/玩家安全侧栏投影测试.gd                 # focused 测试（56 断言）
docs/mw009/MW-009_PLAYER_SAFE_SIDE_PANELS_EVIDENCE.md
```

无新 SQLite table/schema；无 universal Player Knowledge store；无 ViewModel/event bus；
无 Provider 调用；UI widget 从不接收 raw `world_state`。

## 2. Pass A — producer / currentness audit（真实形状）

```text
frozen Game-local setup（原子最终建局流程._setup_envelope）：
  world.source_projection = {display_name, world_instructions, gm_instructions,
                             semantic_sections, selected_entry{entry_id, display_name, opening_seed}}
  player_character = {local_character_id, role, provenance, source_projection =
                             {display_name, selected_profile{profile_id, display_name, …}, …}}
  —— 身份展示字段来源确认（display_name / selected_profile.display_name /
     selected_entry.display_name），全部已在冻结 selected projection 内。
Player local id 解析：world_state.player_character.local_character_id（仅作过滤键，不投影）。
Knowledge：living_world.knowledge_turns_by_index[str(turn)]，record 契约 =
  WorldTurnRules.knowledge_record_is_valid；currentness = record.source_turn_index/
  source_gm_sha256 与 current accepted Conversation hash 精确匹配（与 G5 上下文投影器同一规则）。
semantic-lane 终态顺序：Conversation accept → generation_completed → 语义 request（deferred）
  → commit → WorldTurn.finished → Shell 回调 —— 终态信号即 knowledge 可能变化的最早时点。
Save/reopen/Restore 发布顺序：restore_save_point 单事务切换 world/head/conversation 后
  发 restore_completed —— restore 后 DOM/durable truth 已是新快照，刷新安全。
```

**刷新点结论**：既有 lifecycle seams 足够——(1) 激活/reopen（`_activate_game_surface`）、
(2) semantic lane terminal（`world_turn_runtime.finished` → Shell 回调）、(3) Restore
（`restore_completed`）。**无需新增 Runtime 信号**。Agency opportunity 终态与 World
Evaluation 提交不触发刷新（hidden truth 非披露事件，符合 canonical decision §9）。

## 3. Pass B — disclosure consumer audit（逐 family 分类）

| Truth family | 进入 v0.1 投影 | 实现处理 |
|---|---|---|
| Player Character identity | YES，bounded safe fields | 仅 display_name + selected_profile.display_name；local_character_id 仅作过滤键 |
| World / selected Entry identity | YES，bounded safe fields | 仅 world display_name + selected_entry.display_name |
| Player Character post-T0 Knowledge | YES | knower_id == player id ∧ valid ∧ current-hash 匹配；≤8 条、时间序、重复保留最新 |
| NPC Knowledge Provenance | NO | knower_id 过滤排除（测试 B） |
| semantic_turns_by_index raw consequences | NO | 从不读取（测试 C） |
| agency_cycles_by_source_turn | NO | 从不读取（测试 D） |
| world_evolution_events_by_turn | NO | 从不读取（测试 E） |
| GM/source instructions | NO | 从不读取（投影 JSON 无 gm_instructions 断言） |
| literary_style_reference | NO | 从不读取（投影 JSON 无 literary 断言） |
| internal IDs / hashes / fingerprints | NO | 投影对象仅含白名单展示字段（序列化断言） |
| Public-d20 control/proposal payload | NO | 从不读取 |

关键结构证明：投影对象是**白名单构造**（`EMPTY_PROJECTION` + 显式字段赋值），不是
world_state 的过滤拷贝——raw hidden truth 物理上不在投影对象里，而非“UI 大概不渲染”。

## 4. Exact player-safe projection shape

```gdscript
{
  "success": bool,                  # validate_setup 失败 → false + 全空（fail-closed）
  "player_display_name": String,    # 主角显示名
  "player_profile_name": String,    # 已选档案名（无则 ""）
  "world_display_name": String,     # 世界显示名
  "world_entry_name": String,       # 当前 Entry 显示名（无则 ""）
  "known_facts": Array[String],     # ≤8、时间序（最新在尾）、重复保守保留最新
}
```

UI（既有 PlayerPanelHost / WorldSurfaceHost，占位 Label 保留为空态）：

```text
主角 / 刘备 / 208 人物起点
世界 / 汉末三国：天下未定 / 208｜赤壁前夕 / 主角所知 / • 事实…（或「尚无新的已知事实。」）
```

无工程标签、无 ID/hash/provenance enum。

## 5. Focused proof（tests/mw009/玩家安全侧栏投影测试.gd — 56 断言 0 失败）

真实 Final Create 冻结 Game（汉末三国 + 刘备 + 孙权 guaranteed）+ 真实 Runtime/SQLite +
真实 main.tscn Shell：

1. 身份投影正确且无 internal IDs/fingerprints（投影对象序列化断言，§10.1）；
2. 主角 knowledge 事实 A 展示（经生产 semantic seam 提交）；§10.2
3. NPC-only 事实 B 不展示（同一 record 内、真实 rostered NPC knower）；§10.3
4. 原始 semantic consequence C 不展示；§10.4
5. Agency 行动 D 不展示（生产 commit seam 注入 + 刷新后仍排除）；§10.5
6. World Evolution 事件 E 不展示（同上）；§10.6
7. knowledge 显式携带 C 的实质（事实 F）→ 经 knowledge seam 展示；§10.7
8. regenerate 使 latest turn hash 变化 → stale knowledge 排除；§10.8
9. semantic commit → Shell 侧栏**无 reopen 实时刷新**（world_turn_runtime.finished 钩子）；§10.9
10. Save/close/reopen 重建相同安全投影（投影对象 deep-equal）；§10.10
11. Restore 到已知事实前 → 侧栏事实消失、空态恢复（restore_completed 钩子）；§10.11
12. 无效输入 fail-closed：坏 setup → success=false 全空，raw 内容不进投影对象；§10.12
    legacy/absent setup 同样 fail-closed；
13. bounds = 8 + 去重保留最新 + 时间序（10 turn 注入验证）。

## 6. Regression matrix（Godot 4.7.2 headless，task-owned roots）

```text
tests/mw009/玩家安全侧栏投影测试.gd        failures=0（56 断言）
tests/mw008/安全轻量渲染测试.gd            failures=0（§10.13）
tests/g5_02/已知角色知识溯源测试.gd        failures=0（§10.14）
tests/g5_01/世界回合时间线恢复测试.gd      failures=0（§10.14）
tests/g4_09uatbc01/叙事响应流式关键路径测试.gd failures=0
tests/g4_08b/公开D20界面整合测试.gd        failures=0
tests/g5_04/选择性世界演化评估测试.gd      failures=0
tests/mw005/叙事风格锚点显著性测试.gd      failures=0（未触碰 MW-005 行为）
git diff --check                           clean
Windows export validation                  PASS（--export-release "Windows Desktop"）
Real Provider calls                        0
```

## 7. Remaining risks / notes for GPT

1. 事实列表「最新在尾部」的时间序是 canonical decision 允许的两个方向之一（"chronological
   with newest information visually easy to find"）；若 Owner UAT 偏好最新在顶部，属展示翻转，
   不是语义变更。
2. 去重是精确字符串匹配（保守）；模型在不同 turn 用不同措辞重复同一事实会显示两条——按
   decision 禁止语义聚类，v0.1 接受。
3. 侧栏刷新挂在 semantic lane terminal；若未来 knowledge 的产生路径新增（如 G5-02 扩展），
   需要复核刷新点覆盖——投影本身按 current-hash 过滤，多刷一次无害，漏刷才会延迟展示。
4. legacy（pre-G4-06）world_state 无 game_local_setup schema → 身份/事实均为空态（fail-closed），
   旧局侧栏安静留白，不猜测身份。
