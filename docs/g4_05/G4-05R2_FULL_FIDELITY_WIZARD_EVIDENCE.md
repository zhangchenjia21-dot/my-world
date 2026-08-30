---
title: G4-05R2｜Full-Fidelity New Game Wizard Closure Evidence
status: ready-for-independent-review
task: G4-05R2
owner: Kimi
independent_review_owner: GPT
created: 2026-08-30
updated: 2026-08-30
packet: docs/tasks/G4-05R2_FULL_FIDELITY_WIZARD_CLOSURE_TASK.md
packet_commit: c0d8df812511745119d1e9ac8c14283b4c2bd5de
formal_code_base: 1d8278f9a4bc33a748eb6444873af85d27d5a755
governance_base: 32e7357d2eb86b6788d1a429b0dd97f2ba4a2caa
start_head: 8a6fd9ccc27a2005482aa65205a0b2083176c4a2
return_ceiling: READY FOR INDEPENDENT REVIEW
---

# G4-05R2｜Full-Fidelity New Game Wizard Closure Evidence

Return state: **READY FOR INDEPENDENT REVIEW**。本文不宣布 G4-05 CLOSED；closure 由 GPT Independent Review 决定。

## 1. Baseline and drift check

- Start HEAD: `8a6fd9ccc27a2005482aa65205a0b2083176c4a2`（`origin/main`，含 Packet commit `c0d8df8` 与 AGENTS 激活 commit）。
- 开始时 `git status` 干净；local main 以 `--ff-only` 从 `1d8278f` 快进到 `8a6fd9c`，无未知 dirty/newer work。
- Governance repo `Vibe-Coding` 同步到 `7c48708e4f50a3e86c88670d075af639eb3fa7fb`（G4-05R2 handoff），并通读 `MY_WORLD_CURRENT_STATUS.md` 与 `AGENT_EXECUTION_ROUTING_CURRENT.md`。

## 2. Changed paths

Production（仅 Packet 允许范围）：

| Path | Change |
|---|---|
| `src/ui/新游戏向导.gd` | Chooser 展示 `catalog_summary`；通用步骤/开局/Review 文案去除泛化 `T0` 与后端黑话；Guaranteed NPC 文案改为“保证加入本局的 NPC”语义；Review 失败把 `character_temporal_incompatible` 翻译成玩家可行动说明；Review 正文改用中文小标题、不再以 fingerprint 为主要展示。 |
| `src/ui/新游戏向导.tscn` | Final Create 占位按钮文案 `创建游戏（G4-06 接入）` → `创建游戏（下一阶段开放）`，仍 disabled。 |

`src/应用壳.gd` / `src/main.tscn` 未改动（现有 wiring 已满足需求）。

Tests / evidence：

| Path | Change |
|---|---|
| `tests/g4_05/G4_05测试夹具.gd` | `PACKAGES` 重基到 `tests/fixtures/g4_02r1/full_fidelity/` 冻结 v0.2 资产；新增 `IR01_NON_TEMPORAL_PACKAGES` 引用与 `install_packages()` 泛化。 |
| `tests/g4_05/应用新游戏向导现实测试.gd` | 新增 v0.2 schema、catalog_summary 可见性、非 T0 通用文案、NPC 文案、Review 开局名断言。 |
| `tests/g4_05/建局Composition测试.gd` | “install newer current Y” 步骤的复制源改为 v0.2 埃瑟维亚 fixture。 |
| `tests/g4_05/历史真实资产转换现实测试.gd` | 显式钉住旧 v0.1 转换包清单，保留为纯历史回归锚点，不再承担主现实路径。 |
| `tests/g4_05/新游戏向导窗口布局测试.gd` | 新增主角选择页截图、1280×720 真实不兼容 Review 失败可读性证据。 |
| `tests/g4_05/新游戏向导全保真现实测试.gd`（新增） | 聚焦真实 Application/Wizard 路径：不兼容三国路线、埃瑟维亚路线、IR01 非时态场景型路线。 |

Backend production code changed: **no**。`git diff --name-only -- src/source src/建局 src/persistence src/runtime src/provider` 为空。
Frozen full-fidelity fixtures changed: **no**。`git diff --name-only -- tests/fixtures/g4_02r1/full_fidelity` 为空。
Old v0.1 conversion fixtures unchanged：仅新增过 editor import 副作用 `.import` 文件，已删除，未提交。

## 3. AC evidence map

### AC-05R2-01｜Current v0.2 inventory reaches Wizard

`G4_05测试夹具.PACKAGES` 现在只指向 8 个冻结 v0.2 full-fidelity package 根目录。`应用新游戏向导现实测试.gd` 断言：Wizard 打开后 `worlds == 2`、`characters == 6`，且全部 8 个 `generation.source.identity.schema_version` 以 `.v0.2` 结尾（`all eight loaded generations are schema v0.2 through generation.source` PASS）。旧 v0.1 转换包不再能满足该门禁（它已被移出 `PACKAGES`）。

### AC-05R2-02｜Chooser presents meaningful current Source summaries

世界/主角/NPC 三个 chooser 的条目文本均包含该 generation 的 `source.catalog_summary`；测试直接断言真实 UI 按钮文本包含从 loaded generation 对象取出的 summary 原文，而非仅断言字段存在：

- `World chooser visibly shows current Source catalog_summary`
- `Player Character chooser visibly shows current Source catalog_summary`
- `Guaranteed NPC chooser visibly shows current Source catalog_summary`
- `non-temporal World chooser shows its catalog_summary`

截图：`build/g4_05r2_windows/shots/world_1280x720.png`、`player_1280x720.png`。指纹不再是玩家主展示信息；version 以 `名称（version）` 形式低调展示，exact identity 由测试程序化断言。

### AC-05R2-03｜Generic UI does not impose T0 on every World

通用步骤标签改为 `世界 / 开局 / 拓展 / 主角 / 保证加入的角色 / 设置 / 兼容性审查`；开局步标题为 `选择开局`，Review 小节为 `开局`。断言：

- `generic opening-step UI does not impose T0 wording`（title/hint/step label 均不含 `T0`）；
- `Review shows authored opening name without generic T0 wording`；
- `scenario opening step never mentions T0`（IR01 非时态世界）；
- `scenario Entries show authored names without any historical framing`（`港市晨潮` / `外海灯塔`）。

历史 Entry 的 authored 名称（如 `208｜赤壁前夕`）正常显示：`historical Entry keeps its authored year display name`。世界资产自己的 catalog_summary 中出现的 “T0” 字样属于冻结资产内容，未改动。

### AC-05R2-04｜Compatible Han route reaches valid Review

真实 Application 路径（`main.tscn` → New Game → 7 步）：世界 `汉末三国：天下未定` → 开局 `208｜赤壁前夕` → 拓展确认 none → 主角 `刘备` → NPC `曹操` + 零覆盖跨世界 `杜恩·石痕` → 设置 → Review 成功，显示所选世界、开局名、主角、NPC 集合与设置；`创建游戏` 保持 disabled。见 `应用新游戏向导现实测试.gd` 全部 PASS 与 `review_1280x720.png`。

### AC-05R2-05｜Temporal incompatibility is clear and non-destructive

真实路线 `229｜三国鼎立` + `刘备`（`新游戏向导全保真现实测试.gd`）：

- 后端仍权威：同一 Composition 直接调用 `build_compatibility_review()` 返回 `character_temporal_incompatible`，无 profile 替换；
- UI 主信息为白话：`无法继续创建：阵容中有角色没有适用于开局「229｜三国鼎立」的起始资料（该角色的资料未覆盖这个时间点或场景）。可返回更换开局，或调整主角与保证加入的角色。`，不含 `T0`/`coverage`/`封闭` 等后端术语；
- 不产生 Game/Session/SQLite/Game Library；
- 玩家可从失败 Review 逐级返回开局步，改选 `208｜赤壁前夕` 后同一 Composition 到达有效 Review。

截图：`review_error_1280x720.png`。

### AC-05R2-06｜Afterglow is not treated as historical restriction

埃瑟维亚路线：世界 `埃瑟维亚：诸界余辉` → 开局 `1287｜断裂遗迹公共工程` → 主角 `莉维娅·塞兰` → NPC `杜恩·石痕` + `阿德里安·维尔克` → Review 成功，完整显示所选内容；无 Game 副作用。未发明任何家族/时间限制（断言 Review 不含失败信息且正常到达）。

### AC-05R2-07｜Guaranteed NPC wording is semantically accurate

步骤名 `保证加入的角色`，页标题 `保证加入本局的 NPC`，hint：`可选 0..N。表示要求该角色在创建后属于本局阵容；不代表开场就出现、同场或已经认识主角。` 断言 `Guaranteed NPC wording does not imply opening appearance`（title/hint 不含 `登场`）。

### AC-05R2-08｜Existing G4-05 mechanics stay green

全部 `failures=0`：

```text
建局Composition测试.gd            22 PASS（含 exact pinning / drift / tamper fail-loud / 角色约束）
应用新游戏向导现实测试.gd          27 PASS
新游戏向导窗口布局测试.gd          42 PASS（headless 与非 headless 各一轮）
历史真实资产转换现实测试.gd        v0.1 历史回归锚点 PASS
新游戏向导全保真现实测试.gd        25 PASS
```

后端抽查（本任务未改 backend，验证无连带影响）：`Source_v0_2_r2_机制现实测试.gd`、`Source可选时态范围证据测试.gd`、`Source库现实测试.gd` 均 `failures=0`。

### AC-05R2-09｜Windows visual evidence

非 headless（Godot 4.7.2.stable，Vulkan 1.4.341，NVIDIA RTX 4070 Laptop）：

```powershell
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_05/新游戏向导窗口布局测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_05r2_windows' --shot-dir='D:/AI/Projects/my-world/build/g4_05r2_windows/shots'
```

1280×720 / maximized / 960×540 三种尺寸全部断言 PASS。截图（`build/g4_05r2_windows/shots/`）：

```text
world_1280x720.png   player_1280x720.png   review_1280x720.png
world_maximized.png  player_maximized.png  review_maximized.png
world_960x540.png    player_960x540.png    review_960x540.png
review_error_1280x720.png
```

人工目检结论：summary 可读；按钮/标签无重叠；长中文 Entry/简介文本在 960×540 下安全换行；超长列表由滚动区承载（滚动条可见）；返回/下一步/取消导航始终可达；Review 成功与失败两种状态均清晰可读。键盘/focus 不产生隐式选择（`World requires explicit click` 等断言在三种尺寸均 PASS）。

### AC-05R2-10｜No G4-06 side effects

成功 Review、失败 Review、非时态路线与全部 GUI 运行均断言：

```text
no Game SQLite（current-game.sqlite 不存在）
no Game Library mutation（game-library 目录不存在）
session_runtime == null / Session ABSENT
Final Create 按钮可见但 disabled（成功与失败 Review 皆然）
```

Wizard/Composition 路径不含任何 Provider 调用 seam；本任务未新增任何调用。

## 4. Exact validation commands

```powershell
$godot = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_05/新游戏向导全保真现实测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_05r2_wizard_focused'
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_05/应用新游戏向导现实测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_05r2_application'
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_05/建局Composition测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_05r2_composition'
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_05/历史真实资产转换现实测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_05r2_legacy_v01'
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_05/新游戏向导窗口布局测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_05r2_gui_headless' --shot-dir='D:/AI/Projects/my-world/build/g4_05r2_gui_headless/shots'
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_02r1/Source_v0_2_r2_机制现实测试.gd' -- --work-root='D:/AI/Projects/my-world/build/g4_02r1_r2_regress'
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_02r1/Source可选时态范围证据测试.gd'
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_03/Source库现实测试.gd' -- --work-root='D:/AI/Projects/my-world/build/g4_03_r2_regress'
& $godot --headless --path 'D:\AI\Projects\my-world' --editor --quit
```

Editor parse：无脚本 parse/compile 错误。仅出现既有环境噪音：`build/` 历史测试产物 SVG 的 UID duplicate 警告、Windows 证书存储/编辑器设置持久化沙箱警告；不影响断言与退出码。Editor import 在 fixture 目录生成的 `.import` 副作用文件已删除，未提交。

## 5. Known limitations

- Chooser 条目展示完整 authored version 字符串（如 `0.2.3-converted.2-full-fidelity-candidate`），技术上偏长但保持诚实；是否需要更柔和的版本展示留待 GPT/Product 判断。
- 主角选择页在 960×540 下 6 个角色条目超出可视高度，由滚动承载（截图可见滚动条）；无重叠。
- Review 失败白话信息不点名具体是哪位角色不兼容（后端失败结果不含该字段；UI 未跨层直查 Source）。当前措辞引导玩家更换开局或调整阵容，足够行动；若产品需要点名，需要后端失败负载扩展，属另一任务。
- 本证据为工程级产品整合证据，不等于 G4-07 Owner UAT，也不声称整体可玩性 PASS。
