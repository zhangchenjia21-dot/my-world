# MW-012 Zhang Chen Player Character Card — Implementation Evidence

Status: **READY FOR INDEPENDENT REVIEW（候选）**
Implementer: Zcode + GLM-5.3-Flash（Owner weekend routing override）
Reviewer: GPT
Task Packet: `docs/tasks/MW-012_ZHANG_CHEN_PLAYER_CHARACTER_CARD_TASK.md`
Owner-approved content input: `docs/tasks/inputs/MW-012_ZHANG_CHEN_CHARACTER_CARD_V0_1.md`
Task Branch: `mw-012-zhang-chen-player-character-card`
Worktree: `D:/AI/Projects/.worktrees/my-world/mw-012`

## 0. Worktree hygiene

```text
按 packet §7：git worktree list 检查后未清理任何 worktree（MW-011 保持活跃，本任务未触碰）；
新建 D:/AI/Projects/.worktrees/my-world/mw-012 @ 分支 mw-012-zhang-chen-player-character-card（origin/main @ 048185e）。
```

## 1. Changed files（零 production 代码改动——全部为新增内容/脚本/测试）

```text
tests/fixtures/mw012/汉末三国/张琛/source.json                # character_card.v0.2 合同（真实 Source 包）
tests/fixtures/mw012/汉末三国/张琛/sections/01..05_*.md       # 5 个可复用 rich sections（内容来自 Owner 输入）
tests/fixtures/mw012/汉末三国/张琛/t0/han_t0_transport.md     # 单一 T0 profile section
scripts/MW-012_张琛角色卡生产Source发布.gd                    # Owner opt-in production Source 发布入口（G4-09P1 先例）
tests/mw012/张琛角色卡集成测试.gd                             # acceptance 测试（28 断言）
docs/mw012/MW-012_ZHANG_CHEN_CARD_EVIDENCE.md
```

无新 Character schema / Inventory platform / Creator / UI redesign / Expansion / G6 declarative UI；
无 hardcoded picker；无未来历史 scheduler；SQLite schema 不变。

## 2. Real first-party Source ingress（packet §3 audit 结论）

```text
第一方 Character 包（repo 内 package 目录）        # 现存可选卡（刘备等）同样以 repo 包形态存在
→ SourceLibrary.install_character_card(package_path)   # 严格 v0.2 合同校验 + immutable exact fingerprint
                                                       #   + managed publish + current metadata
→ New Game Wizard：Composition.load_current_inventory()  # = SourceLibrary.list_current_sources()
    （src/ui/新游戏向导.gd：characters = inventory.characters；
      主角资格 = 卡上 player_character_supported 布尔，UI 不硬编码任何名字）
→ select_player(generation) → 建局兼容审查（project_character_t0 exact_profile_match）
→ Final Create 冻结 Game-local projection
→ Opening/continuation GM 上下文经游戏本地开场上下文投影器
```

结论：**产品已有的 first-party ingress 完整存在**（repo 包 + Managed Library install + Wizard
inventory 发现 + `scripts/G4-09P1_*.gd` 式 Owner production 发布入口先例），不需要新的
asset-distribution architecture seam，不触发 STOP 条款。张琛包走完全相同的路径。

Owner 上架操作（一条命令，显式 opt-in，additive-only，不触碰既有代次与任何 Game）：

```text
godot --headless --path . --script scripts/MW-012_张琛角色卡生产Source发布.gd -- --confirm-owner-production-source-prep
```

## 3. Zhang Chen identity / fingerprint / T0 binding matrix

```text
asset_id:      character.han_end.zhang_chen
asset_type:    character_card
schema:        character_card.v0.2（无 schema 变更）
version:       0.1.0
display_name:  张琛
generation:    6a55ecdaf965851a72bd8cc61bced9c6f91a53ed5ee862a7210d93c058d288bf
player_character_supported: true

T0 binding matrix（单 profile "han-t0-transport"「现代来客起点」× 7 bindings，
                     避免七份传记复制；文本 entry-agnostic——穿越进所选开局的当下）：
  t0-184-yellow-turban / t0-189-luoyang-crisis / t0-196-emperor-xu /
  t0-200-guandu-eve / t0-208-red-cliffs-eve / t0-214-yizhou-transition /
  t0-220-han-wei-transition   → 全部 exact_profile_match（7/7 断言）
  world.ashtervia.afterglow   → no_world_coverage（跨世界不合资格，5 断言）
```

## 4. 历史知识边界与 Player Agency（packet §2.2/2.3 落地）

卡片内容以独立 section（`04_historical_memory_boundary.md`）承载硬边界，并经测试断言其进入 GM 上下文：

```text
张琛记得历史事件 X ≠ X 必须发生 ≠ NPC 必须按记忆轨迹行事 ≠ GM/世界演化必须维护原时间线
分岔后记忆可能不完整/误导/过时；记忆只是假设与优势来源，无运行时权威。
知道名字 ≠ 能凭外貌识别陌生同名者（需要游戏内证据）。
```

初始目标只有生存 + 寻找归途；辅佐/独立/自立、效忠、揭露未来、留下或归途、处决宽恕等
重大选择**未被预设**（MW-004 语义保持）。道德边界写成 strong character values 而非禁止层。
随身物品仅 Owner 批准的五件有限实物，无现代补给/弹药/通讯/电力。

## 5. Focused proof（tests/mw012/张琛角色卡集成测试.gd — 28 断言 0 失败）

真实 Character Card v0.2 合同 + Managed Source Library + 建局 Composition + Final Create +
真实 Runtime/SQLite + 冻结 projection + GM 上下文投影 + player-safe 投影：

1. 包在既有 v0.2 合同下校验通过；identity/version/player_supported/fingerprint 符合（§6.1）；
2. 经正常 Managed Source 路径发布 immutable generation，current/exact lookup 收敛（§6.2）；
3. `load_current_inventory()`（产品 New Game 同一 seam）发现张琛为可选主角，无 picker 硬编码（§6.3）；
4. 7 个汉末 Entry 兼容矩阵全 exact_profile_match（§6.4）；无关世界 no_world_coverage（§6.5）；
5. **208 赤壁前夕 + 张琛真实 Final Create 成功**，runtime existing-only 打开（§6.6）；
6. 冻结 projection：display_name 张琛 + selected_profile "han-t0-transport"（§6.7）；
7. GM 上下文含穿越 premise、目标与道德边界、隶书/物品限制、历史记忆非 canon 边界（§6.8）；
   player-safe 投影识别张琛 + 档案名，且内部 local id 不进 player-safe（MW-009 边界）；
8. 刘备 208 Final Create 与冻结 projection 不回归（§6.9）；
9. 新 Source generation 不触碰任何既有 Game（library-level additive，§6.10）；
10. 安装/发现验证无 schema migration、无 Provider call（§6.11）；prep 脚本编译与契约常量冒烟。

## 6. Regression matrix（Godot 4.7.2 headless，task-owned roots）

```text
tests/mw012/张琛角色卡集成测试.gd         failures=0（28 断言）
tests/g4_02r1/Source_v0_2_r2_机制现实测试.gd  failures=0
tests/g4_05/建局Composition测试.gd        failures=0
tests/g4_06/原子最终建局现实测试.gd       failures=0
tests/mw011/G6主机视图模型基线测试.gd（mw-011 worktree）failures=0（G6 主线不回归）
tests/mw010/生界一体现实矩阵测试.gd（mw-010 worktree）  failures=0
git diff --check                          clean
Windows export validation                 PASS（--export-release；新包进入 pck）
Real Provider calls                       0
Production 代码 diff                      0（全部为新增内容/脚本/测试文件）
```

## 7. Residual product caveats / notes for GPT

1. 张琛包目前位于 `tests/fixtures/mw012/…`（沿用现存可选卡与 G4-09P1 先例的 repo 包位置约定）；
   发布到 Owner 真实 library 由 `scripts/MW-012_张琛角色卡生产Source发布.gd` 完成（Owner 执行
   opt-in 命令，additive-only）。若未来希望包位置产品化（如 res://source/），那是独立的
   asset-distribution 修订，不属于 MW-012。
2. 单 profile × 7 bindings 的结构由既有 `project_character_t0` 语义直接支持（bindings 数组合法）；
   若未来某个 Entry 需要不同的 T0 开场材料，可拆分为多 profile——现有合同无需变更。
3. GM 上下文含 `Local Character ID` 行为既有投影设计（G4-06 起），player-safe 侧无此材料
   （MW-009 边界已断言）；本任务未改变该分工。
4. 卡片未携带 portrait（G6 Runtime Asset Resolution 属后续真实消费者任务）。
