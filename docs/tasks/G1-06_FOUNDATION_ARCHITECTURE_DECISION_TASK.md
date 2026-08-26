# TASK｜G1-06｜Foundation Architecture Decision

Type: planning / architecture / docs
Owner: GPT Sol medium
Repository: `zhangchenjia21-dot/my-world`
Branch: `main`
Formal Code Base SHA: `03be4d859124aaadb148bd3dbc39f159851fcb75`
Governance Base SHA: `zhangchenjia21-dot/Vibe-Coding@0ba35cf2ead5e3644c2a9ea8bbe96075da53ab94`

## Outcome

基于 G1-01～G1-05 的真实 Foundation 证据，冻结 `my world` 第一代最小技术边界，并把决策写回 canonical governance。

本任务不实现 G2 功能。完成后必须明确回答：

1. Godot 是否正式成为第一代 Host；
2. Standard / .NET 选择；
3. GDScript / C# / mixed 的第一代边界；
4. Runtime 与 Godot 同进程，还是 Godot Client + Local Runtime Process；
5. 第一阶段 persistence 技术候选范围；
6. Provider / product configuration 的最小边界；
7. 最小测试、logging / crash diagnostics 与 Windows packaging 路径；
8. G1-GATE 是否可以 PASS。

如果全部 Foundation Gate 条件已经满足且没有新的 blocker，可正式关闭 G1，并把 Current Phase 推进到 G2、Current Task 推进到 G2-01；但不得开始实现 G2-01。

## Why Now

Owner 已完成 G1-05 Windows exported-executable UAT 并明确返回 **PASS**。

因此当前真实阶段事实已经 supersede 仍写着 `G1-05 CURRENT` 的旧治理文本：

```text
G1-01 PASS
G1-02 PASS
G1-03 PASS
G1-04 PASS
G1-05 PASS
Current Phase = G1
Current Task = G1-06
```

G1-06 是 G1 的最后一个任务。它的职责不是再做 Spike，而是把已验证证据转换成足以支撑 G2–G7 的最小、可解释、可推翻的 Foundation Architecture Decision。

## Authority / Source Manifest

按以下顺序使用 current source：

1. 用户当前明确指令与本 Task Packet 中记录的最新 Owner UAT：G1-05 = PASS；
2. `Vibe-Coding/AGENTS.md`；
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md` @ Governance Base；
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` @ Governance Base；
5. `Vibe-Coding/my world/MY_WORLD_独立版Preflight与第一阶段计划_v1.0_2026-08-25.md` @ Governance Base；
6. `my-world/AGENTS.md` 与当前实现 @ Formal Code Base；
7. `my-world/docs/DSH_TEST_CARRY_FORWARD_REQUIREMENTS.md`，用于检查 G3 / G5 / G7 长期架构风险。

执行方法必须遵循最新版：

- `Skill/main/skill/gpt/agent-task-packet/SKILL.md`
- `Skill/main/skill/gpt/lifecycle-dev-process/SKILL.md`

旧聊天、旧 Task Packet、The World / DSH workaround 和模型记忆不构成实现权威。

## Read First

初始工作集只读以下入口：

1. `my-world/AGENTS.md`；
2. 本文件；
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`；
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`；
5. `Vibe-Coding/my world/MY_WORLD_独立版Preflight与第一阶段计划_v1.0_2026-08-25.md`；
6. `my-world/docs/DSH_TEST_CARRY_FORWARD_REQUIREMENTS.md`；
7. 当前 `project.godot`、`export_presets.cfg` 与 `src/g1_05_本地IO图片导出探针.gd`，只提取 Foundation 事实。

只有现有证据不足时才扩大读取范围，并在最终报告说明原因。

## G1 Evidence Digest

`EVID-01` G1-01 已证明普通 Windows 环境下 Godot / Git / `user://` 可正常写入、启动、退出且 Git clean；早期 Codex 权限失败是 sandbox-only。

`EVID-02` G1-02 已证明 Godot `4.7.2.stable.official.ed1daf0bf` Standard / non-.NET Windows x64、Vulkan / Forward+、CLI、Windows export templates 与 ICU Data 可用。当前没有安装 .NET-enabled Godot / .NET SDK，也没有真实证据表明必须引入它们。

`EVID-03` G1-03 Owner UAT 已证明中文长文本、长滚动、持续追加、中文输入、选择 / 复制与 UI responsiveness 可用。

`EVID-04` G1-04 Owner UAT 已证明 DeepSeek + Kimi Code 的真实 HTTP、incremental stream、cancel、cancel 后重试、idle Provider 切换、错误路径和 UI 非冻结。当前 same-process Godot `HTTPClient` 路径是有效 Foundation evidence，但不是自动的最终 Runtime boundary。

`EVID-05` G1-05 已实现并经 Owner UAT PASS：

- `user://` 极小 probe 可写、读回并跨启动保留；
- portrait / scene / map 三类图片可从真实 filesystem 文件重新 decode/load 后显示；
- Windows export 可生成并直接运行 EXE；
- exported executable 中 IO 与三类图片均正常；
- 关闭再打开后 probe 仍持续存在。

`EVID-06` G1-05 probe 只证明 Host IO seam，不是正式 Save / Timeline / persistence schema。

## Product / DSH Constraints

`INV-PRODUCT-01` Primary Purpose 不变：让单个玩家通过自然语言，与优秀 AI GM 在长期持续、可保存、可恢复、会自主演化的 2D RPG 世界中长期游玩。

`INV-DSH-01` 不迁移 DSH host debt：Session workaround、`fs.watch` restore、周期 consolidation、DELTAS + bulk Markdown edit、Markdown authoritative gameplay DB、通用 Agent Workspace ownership 均不得成为新架构模板。

`INV-DSH-02` `Game / World / Timeline / Save / Agent Context / NPC / Faction / World Pack` 是 `my world` 自有 Domain，不得绑定为 Godot Scene / Node / Resource 的同义词。

`INV-DSH-03` UI 只是 authoritative game truth 的 projection。

`INV-DSH-04` Runtime boundary 必须考虑后续真实需要，而不只看短 Demo：

- G3：即时 authoritative mutation、Timeline、Save / Restore、future-memory isolation；
- G5：事件 / 优先级驱动的 NPC / Faction autonomous world evolution；
- G7：bounded context、长局性能、后台工作不阻塞叙事。

`INV-DSH-05` 上述未来需求不得反过来成为现在预造微服务、Universal ECS、通用协议平台或全世界 tick simulator 的理由。

## Required Architecture Decisions

### DEC-A｜Host

明确 `Godot v4.7.2` 是否正式成为第一代 Host。

必须基于 G1-01～G1-05 的真实证据与 Simple Baseline 比较；若仍主张改用 Unity / Desktop Foundation，必须指出已经观察到的 Godot blocker，不能只凭理论偏好。

### DEC-B｜Distribution / Language

明确：

- Standard 还是 .NET；
- GDScript / C# / mixed 的第一代职责边界。

不得仅因为 C# “更适合大型项目”就引入未验证的 .NET 工具链；也不得把所有未来 World semantics 永久塞进 GDScript，只因为 Spike 已经用它跑通。

决策必须包含未来触发重新评估的条件。

### DEC-C｜Runtime Process Boundary

必须在以下两类边界中做出当前第一代明确选择：

```text
A. Godot same-process Runtime
B. Godot Client + Local Runtime Process
```

比较至少覆盖：

- 第一阶段开发 / 调试复杂度；
- Windows packaging 与进程生命周期；
- Provider streaming / cancel；
- authoritative persistence / Timeline；
- background world evolution；
- testability；
- 长局 Context / performance；
- Mod / Local Model 的未来余量；
- engine-native but not engine-semantic-coupled 原则。

必须给出：选择、主要理由、明确代价、最早可能证伪它的 G2/G3 测试、未来提取 / 合并触发器。

禁止用“以后可能需要”直接证明独立进程合理，也禁止用“现在写起来简单”直接证明同进程应永久存在。

### DEC-D｜Persistence Candidate Range

只冻结第一阶段**技术候选与职责边界**，不要设计 G3 正式 schema。

至少比较：

- 普通 JSON / file-based state；
- SQLite 或等价嵌入式事务存储；
- Event Log / Snapshot 等作为语义模式而非独立数据库品牌。

回答：哪些适合 config / small local files，哪些适合未来 authoritative world state / Timeline，哪些明确不应成为主状态数据库。

不得恢复 Markdown authoritative gameplay DB。

### DEC-E｜Provider / Product Configuration Boundary

G1-04 的 DeepSeek + Kimi Code 只属于 Foundation evidence，不能因“已经接通”自动冻结成最终产品 Provider。

决定第一代最小边界：

- Provider adapter 是否仍只保留 `send / stream / cancel` 等小接口；
- endpoint / model / key / user config 如何分离；
- secrets 如何留在本地；
- G2 是否先只运行一个实际 Provider；
- 何种证据出现后才值得增加第二个正式 product-facing Provider。

不得建设 generic routing / fallback mesh / account platform。

### DEC-F｜Testing / Diagnostics / Packaging

冻结第一代最小工程路径：

- Godot parse / headless validation；
- focused automated tests 的最小形态；
- local runtime logs / crash diagnostics 的最低可用边界；
- Windows export / build output / ignored artifacts；
- 哪些必须真人 Owner UAT，哪些必须由 Agent 自动完成。

原则：Owner 负责产品体验与最终裁定，不承担 routine Godot / Git / debug / QA 劳动。

## Decision Method

对每项重大选择使用短 Decision Record：

```text
Decision
Evidence
Alternatives
Why rejected / deferred
Known cost
Failure mode
Earliest falsification test
Revisit trigger
```

不要用“最佳实践”替代本项目证据。

对于 Runtime boundary 与 persistence，必须显式检查：

```text
Does this preserve Core Value?
Does it reduce DSH-proven host debt?
Is complexity justified now?
Can G2/G3 falsify it cheaply?
```

## Scope

Allowed：

- 更新 `Vibe-Coding/my world/` 的 current Product Spec、Roadmap、Preflight、G1 handoff、README；
- 新增一份中文的 current Foundation Architecture Decision 文档，例如 `MY_WORLD_Foundation架构决策_v1.0_2026-08-26.md`；
- 更新 `my-world/AGENTS.md` 与 `README.md` 的阶段 / 架构摘要；
- 必要时归档 / 标记已经完成的 G1-05 Task Packet 状态，但不要删除历史证据；
- 在 G1-GATE PASS 后把 Current Phase / Task 更新到 G2 / G2-01。

Prohibited：

- 修改 GDScript、场景、Godot 配置或开始实现 G2；
- 新增 Runtime service / IPC prototype；
- 正式设计 G3 persistence schema；
- 正式设计 G4 World Pack manifest；
- 建 generic Provider platform；
- 升级 Godot、安装 .NET、切换引擎；
- 以本任务为理由实现未来架构；
- force push 或覆盖未知并行提交。

## Decision Propagation

开始实质分析前，先把 Owner 最新 UAT 视为 superseding decision：

```text
G1-05 = PASS
Current Task = G1-06
```

架构决策完成后，如果 G1-GATE PASS，再统一传播：

```text
G1-01...G1-06 = PASS
G1-GATE = PASS
Current Phase = G2
Current Task = G2-01
```

至少保持以下 current sources 一致：

- `MY_WORLD_项目启动总纲_CURRENT.md`
- `MY_WORLD_总体规划路线图_CURRENT.md`
- `MY_WORLD_独立版Preflight与第一阶段计划_v1.0_2026-08-25.md`
- `MY_WORLD_G1新聊天交接指令_CURRENT.md`
- `Vibe-Coding/my world/README.md`
- `my-world/AGENTS.md`
- `my-world/README.md`

Product Spec / Roadmap 等有版本字段的 current 文档按现行规则递增 minor，不创建并列 `latest/final/new` current 文件。

## Acceptance Gates

`AC-01` G1-05 Owner PASS 已明确记录并传播，旧的 `G1-05 CURRENT / awaiting UAT` 不再作为 active truth。

`AC-02` Host / Distribution / Language / Runtime boundary / Persistence candidate / Provider config / Testing-Diagnostics-Packaging 均有明确决策，不留“以后再说”式关键空洞。

`AC-03` 每个关键决策都有 evidence、alternative、cost、failure mode、falsification path 与 revisit trigger。

`AC-04` 架构没有把 Godot Scene Tree、transcript、Markdown 或 UI 变成 authoritative World / Timeline truth。

`AC-05` 架构显式兼容 G3 Timeline / Restore、G5 autonomous world evolution、G7 long-session context，但没有提前实现它们。

`AC-06` 没有基于 G1 Spike 误建 generic Provider / persistence / service platform。

`AC-07` 所有 current governance sources 与 `my-world` 状态一致。

`AC-08` 若全部 G1-GATE 条件满足，明确宣布 G1-GATE PASS，并推进到 G2-01；若不能 PASS，必须列出真实 blocker 和最小补证据任务，不能模糊停留。

`AC-09` `git diff --check` PASS，目标仓库无意外代码改动、无 secret、无 build artifact commit。

## G1-GATE Evaluation

必须逐项给出证据：

- Godot 4.7.2 稳定运行最小 Windows 工程；
- 中文长文本主路径可用；
- 真实模型 stream / cancel 可用；
- 后台请求不冻结 UI；
- local IO / dynamic image 可用；
- Windows export 后关键 Spike 可用；
- Runtime boundary 已裁定；
- 第一阶段语言 / toolchain 已裁定；
- 没有发现需要放弃 Godot 的 blocker。

只有全部成立才能 G1-GATE PASS。

## Git / Freshness

两个 repo 开始时都记录：

```text
git status --short
git branch --show-current
git fetch origin
git rev-parse HEAD
git rev-parse origin/main
```

不得覆盖未知 dirty worktree。

每次 authoritative `main` write 前重新 fetch；比较 Task Base 与 Current HEAD。若变化影响 Stage、Architecture、Roadmap、Task validity 或目标文件，先重新执行 Decision Propagation。

使用精确 staging；禁止 `git add .` / `git add -A`；禁止 force push。

建议提交按 repo 分离：

```text
Vibe-Coding:
my world: decide G1 foundation architecture

my-world:
G1-06: record foundation architecture decision
```

实际 message 以最终 diff 为准。

## Stop Conditions

以下情况停止并返回，不擅自扩 scope：

- Freshness 发现新的 current 决策与本 Task Packet 冲突；
- G1-05 Owner PASS 与实际 committed implementation 出现无法解释的实质矛盾；
- Runtime boundary 需要新增真实 Spike 才能安全决定；
- 必须安装 .NET / 切换 Godot / 切换引擎才能继续；
- persistence 决策开始进入 G3 schema 设计；
- 需要用户做 Godot / Git / debug 等 routine 开发劳动；
- 存在真正需要 Product Owner 在多个产品方向间选择的不可替代 trade-off。

若只有工程取舍而非产品方向，不要把决定转嫁给 Owner；应给出推荐并据证据裁定。

## Final Report

```markdown
## Result
PASS | PARTIAL | BLOCKED

## G1-05 Closeout
Owner UAT: PASS
Propagation: PASS / FAIL

## Architecture Decisions
Host:
Distribution:
Language boundary:
Runtime boundary:
Persistence candidate:
Provider/config boundary:
Testing/diagnostics/packaging:

## G1-GATE
PASS / BLOCKED
Evidence:

## Governance Git
Base HEAD:
Final HEAD:
Commit:
Push:

## Implementation Repo Git
Base HEAD:
Final HEAD:
Commit:
Push:

## Current State
Phase:
Task:

## Risks / Revisit Triggers
- ...

## Next
只写一个最合理的下一任务；不要开始实现。
```
