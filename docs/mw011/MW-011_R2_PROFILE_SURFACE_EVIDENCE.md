# MW-011 Revision 2 — Player Character Profile Projection + Player Host Surface — Implementation Evidence

Status: **READY FOR INDEPENDENT REVIEW（候选）**
Implementer: Zcode + GLM-5.3-flash（Owner weekend routing override）
Reviewer: GPT（IR#2）
Addendum: `docs/tasks/MW-011_REVISION2_PLAYER_CHARACTER_PROFILE_SURFACE_ADDENDUM.md`
Canonical Architecture: `Vibe-Coding/my world/architecture/ui/G6_PLAYER_CHARACTER_PROFILE_PROJECTION_V0_1_DECISION.md`
Task Branch: `mw-011-r2-player-character-profile-surface`
Worktree: `D:/AI/Projects/.worktrees/my-world/mw-011-r2`

## 0. Hygiene / audit

```text
worktree：全新创建于 .worktrees/my-world/mw-011-r2（origin/main @ 6968e13）；MW-011 旧 worktree 不受影响。
Pass A（owner 链）：character_card.v0.2 字段/校验 = Source合同规则.CHARACTER_FIELDS_V2 +
  角色卡加载流程._validate_v2/_project_v2；T0 投影 = Source选定投影流程.project_character_t0；
  冻结 = 原子最终建局._setup_envelope 的 player_character.source_projection（无需改 FinalCreate——
  projection 携带 player_profile 后自动随冻结落库）；MW-009 投影 = 玩家安全投影 模块（不动）；
  MW-011 ViewModel = rpg视图模型 模块；Player Host 场景 = PlayerPanelHost→Margin→Column
  （R2 插入 PlayerPanelScroll 于 Margin 与 Column 之间，Column 内层级不变）；响应式 = NARROW_BREAKPOINT 机制不变。
Pass B（披露分类）：player_profile = authored presentation-only（Character 级、非 entry 级）；
  semantic_sections/gm_reference/gm_private/catalog_summary/内部 ID 一律不进入新投影与 ViewModel。
```

## 1. Changed files

```text
src/source/L0_公理层/Source合同规则.gd           # CHARACTER_FIELDS_V2 + player_profile bounded validator（optional，存在即 fail-loud）
src/source/L2_流程层/角色卡加载流程.gd           # _validate_v2 接入校验；_project_v2 携带 player_profile
src/source/L3_外交层/角色卡公开类型.gd           # CharacterCardSourceProjection 增加 player_profile 属性
src/source/L2_流程层/Source选定投影流程.gd       # project_character_t0 输出携带 player_profile
src/rpg视图模型/L1_器件层/玩家角色档案投影器.gd  # 新：fail-closed 档案投影（只读冻结 source_projection.player_profile）
src/rpg视图模型/L1_器件层/RPG主机视图模型.gd     # build() 增加第三输入；输出 player_profile payload（title/items only）
src/rpg视图模型/L3_外交层/RPG主机视图模型公开接口.gd  # 组合档案投影器
src/main.tscn                                    # PlayerPanelMargin→PlayerScroll→Column（左栏垂直滚动）
src/应用壳.gd                                    # Player Host 渲染 profile block（headline/summary/7 组，authored order）
scripts/MW-012_张琛角色卡生产Source发布.gd       # VERSION 0.1.1
tests/fixtures/mw012/汉末三国/张琛/source.json   # +player_profile（7 groups），version 0.1.1
tests/mw011r2/玩家档案表面测试.gd                # 新 focused 测试（45 断言）
tests/mw011/G6主机视图模型基线测试.gd            # _panel_text player 路径机械适配（断言不变）
tests/mw009/玩家安全侧栏投影测试.gd              # 同上
docs/mw011/MW-011_R2_PROFILE_SURFACE_EVIDENCE.md
```

无 stat system / inventory mechanics / 通用 DSL / Player tabs / portrait / Mod schema / Provider summarization；
MW-009 契约、MW-012 人物语义、GM context 内容均不变。

## 2. 关键语义

```text
loader：player_profile optional；存在则整体 fail-loud（exact fields headline/summary/groups；
        headline ≤120、summary ≤360、groups 1..8、group_id safe-token 唯一、title ≤60、
        items 1..8 × ≤160）；拒绝未知字段与任何嵌套对象。
T0 投影：project_character_t0 输出携带 player_profile（Character 级材料）。
冻结：Final Create 冻结 source_projection 时自动携带 → 旧 Game（旧 generation）冻结无此字段
      且永不 backfill；新 Game（v0.1.1）冻结完整 profile。
档案投影器：只读 frozen player_character.source_projection.player_profile；再次 fail-closed 校验
      （篡改→空）；无 semantic/catalog/Source current/omniscient fallback。
ViewModel：player_profile payload 只含 headline/summary/groups[{title,items}]——group_id 不外泄。
Player Host：profile block（headline→summary→每组 title+items）置于世界/行动/会话材料之前；
      authored group order；PlayerPanelScroll 使左栏垂直滚动，Narrative Host 拉伸比不变。
```

## 3. Focused proof（tests/mw011r2/玩家档案表面测试.gd — 45 断言 0 失败）

- 2：有效 profile 通过；11 种 malformed/oversized/未知字段/重复 group_id 形状全部 fail-loud；
- 1/12：legacy 刘备卡（无 player_profile）install/select/Final Create 全绿；legacy Game profile 空（无 backfill）；
- 3：张琛 208 Final Create 冻结完整 player_profile（headline + 7 groups）；
- 4：投影器对缺失/篡改输入 fail-closed；frozen profile 无 GM prose（sentinel 断言）；
- 5：新张琛 Game 第一幕前 Player Host 显示 headline/summary + 全部 7 组标题与代表 items；
- 6：GM-reference 哨兵文本（“权威边界（硬性要求）”）在 ViewModel 与可见 Host 均不存在；
- 7/8：recent actions/count 正常更新；MW-009 known facts 正常更新；
- 9：reopen 后 profile + R1 ViewModel deep-equal 重建；
- 10：Restore 后动态 actions/count 回退、frozen profile 保留并继续渲染；
- 18：PlayerScroll 存在；Narrative Host 拉伸比不变。

## 4. Regression matrix（Godot 4.7.2 headless，task-owned fresh roots）

```text
tests/mw011r2/玩家档案表面测试.gd         failures=0（45 断言）
tests/mw011/G6主机视图模型基线测试.gd     failures=0（R1 全覆盖，路径机械适配）
tests/mw009/玩家安全侧栏投影测试.gd       failures=0（路径机械适配，断言不变）
tests/mw010/生界一体现实矩阵测试.gd       failures=0
tests/mw012/张琛角色卡集成测试.gd         failures=0
tests/g3_04/存档读取界面测试.gd           failures=0
tests/g4_08b/公开D20界面整合测试.gd       failures=0
tests/g4_09uatbc01/叙事响应流式关键路径测试.gd failures=0
tests/g4_02r1/Source_v0_2_r2_机制现实测试.gd  failures=0
tests/g4_05/建局Composition测试.gd        failures=0
tests/g4_06/原子最终建局现实测试.gd       failures=0
tests/mw005/叙事风格锚点显著性测试.gd     failures=0
git diff --check                          clean
Windows export validation                 PASS（--export-release "Windows Desktop"）
Real Provider calls                       0
SQLite schema/table                       unchanged
```

## 5. Production publication proof（addendum §10）

```json
{"success": true, "status": "installed",
 "character": {"asset_id": "character.han_end.zhang_chen", "version": "0.1.1",
               "player_character_supported": true,
               "generation_fingerprint": "0b6cb72af535ef6147f71cb7592fe6ba048626dd997acf54c4e6893c848b59e4"},
 "inventory": {"zhang_chen_present": true},
 "owner_games_modified": false}
```

pre-R2 Game（Owner 的 v0.1.0 局）保留旧冻结 generation、仍可游玩（视觉上保持紧凑）；Owner UAT 应从 v0.1.1 新建张琛 Game 以看到完整 profile。

## 5b. Revision 3 — committed profile source + reproducible evidence

R2 缺陷（IR2）：candidate `09de33c` 未包含修改后的 `tests/fixtures/mw012/汉末三国/张琛/source.json`
（仍为 0.1.0、无 player_profile），导致 publish script VERSION(0.1.1) 与 committed package 不一致、
45/0 证据不可由 clean candidate 复现，且已报告的 production fingerprint 不能作为候选证据。

R3 修复（bounded）：真正提交 `source.json`——version 0.1.1 + player_profile（headline/summary +
7 groups：背景/性格/能力/局限/初始目标/行为原则/随身物品，与 R2 报告逐字一致）；package version
与 publish script `VERSION := "0.1.1"` 常量一致（R2 candidate 已含）。

**Reproducible evidence from exact clean HEAD `16c42d5`（`git status --short` 为空后执行）**：

```text
tests/mw011r2/玩家档案表面测试.gd         failures=0（45 断言，含张琛 profile 渲染）
tests/mw011/G6主机视图模型基线测试.gd     failures=0
tests/mw009/玩家安全侧栏投影测试.gd       failures=0
tests/mw010/生界一体现实矩阵测试.gd       failures=0
tests/mw012/张琛角色卡集成测试.gd         failures=0
tests/g4_02r1 / g4_05 / g4_06 / g3_04 / g4_08b / g4_09uatbc01   全部 failures=0
git diff --check                          clean
Windows export validation                 PASS（0 errors）
production publish（同 HEAD）：
  status = "already_installed"
  version = "0.1.1"
  generation_fingerprint = 0b6cb72af535ef6147f71cb7592fe6ba048626dd997acf54c4e6893c848b59e4
  zhang_chen_present = true；owner_games_modified = false
```

R2 报告的 production fingerprint `0b6cb72a…` 由本 exact clean HEAD 复现确认为真实候选证据。
相关回归中 tests/mw011 与 tests/mw009 的 `_panel_text` helper 路径做了机械适配（Player Host
移入 PlayerPanelScroll 的场景变更所致），断言语义不变。

## 6. Remaining risks / notes

1. 已知 G4-03 fingerprint 行尾稳定性问题（autocrlf）仍在裁定中：本次 production 发布指纹 `0b6cb72a…` 从本 worktree（LF）计算；若 Owner 侧 checkout 为 CRLF，重装会生成不同指纹代次。该修复（.gitattributes）属 G4-03 裁定范围。
2. profile 与 semantic sections 的内容一致性由 authoring 保证（decision §4）；Runtime 不裁决矛盾。
3. Player Host 富内容高度可滚动（PlayerScroll）；Narrative 拉伸比未动（Owner UAT 确认观感）。
