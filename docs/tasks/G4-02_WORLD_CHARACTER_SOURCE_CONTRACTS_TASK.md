---
title: my world｜G4-02 World Pack + Character Card Source Contracts v0.1 Task Packet
status: current-task-packet
task_id: G4-02
type: implementation
owner: Codex
created: 2026-08-28
updated: 2026-08-28
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: 3add8fa250c251ad6916c1bb1bf5806df2a97595
governance_base: a208f4b116121668842bd1220f79a2c0ca9a399f
local_project: D:\AI\Projects\my-world
highest_implementation_status: READY FOR INDEPENDENT REVIEW
owner_uat_required: false
---

# TASK｜G4-02｜World Pack + Character Card Source Contracts v0.1

Type: `implementation`  
Owner: `Codex`  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`  
Formal Code Base: `3add8fa250c251ad6916c1bb1bf5806df2a97595`

> 本任务只建立 World Pack / Character Card 两类 Primary Source 的 v0.1 contract、最小读取/验证 seam 与真实 Contract Reality Check。不要提前实现 Managed Source Library、New Game selection、Game materialization 或 Expansion Pack。

## 1. Outcome

完成后，项目应拥有两类可由 Program 确定性读取、验证和识别 exact generation 的正式 Source contract：

```text
World Pack v0.1
Character Card v0.1
```

并用 materially different 的真实 compact Source fixtures 证明：

```text
contract
→ real files
→ deterministic load / validation
→ exact generation identity
→ typed Source projection
```

不是只写文档或只验证单一示例。

实现 Agent 最高返回状态：

```text
READY FOR INDEPENDENT REVIEW
```

不得开始 G4-03。

---

## 2. Why Now

G4-01 已完成 Engineering、Independent Review、Owner UAT，并正式 **PASS / CLOSED**。

当前 G4 DAG：

```text
G4-01 CLOSED
→ G4-02 Source Contracts
→ G4-03 Managed Source Library
→ G4-04 Multi-Game
→ G4-05 New Game Wizard
```

G4-03 的 Library 只能管理正式、可验证、可 fingerprint 的 Source；因此必须先冻结 World / Character 两类 contract 的最小真实边界。

本任务服务产品核心价值中的“可安装、可组合的 World Pack / Character Card”，但当前增量仍是 source-definition foundation，不要求 Owner UAT 或真实 Provider。

---

## 3. Authority / Source Manifest

冲突时按以下顺序：

1. 用户当前明确指令。
2. `zhangchenjia21-dot/Vibe-Coding/main/AGENTS.md`。
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md` — current product spec。
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`。
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md` — Primary Source / Source Library / Source→Game boundaries。
6. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` — G4-02 definition / DAG。
7. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md` — current task state。
8. repository `AGENTS.md`。
9. repository current implementation/tests/HEAD。
10. `Vibe-Coding/skill/gpt/lifecycle-dev-process/SKILL.md`。
11. `Vibe-Coding/skill/gpt/agent-task-packet/SKILL.md`。

Governance base at issuance:

`a208f4b116121668842bd1220f79a2c0ca9a399f`

Implementation formal code base:

`3add8fa250c251ad6916c1bb1bf5806df2a97595`

Not authoritative unless explicitly used as historical evidence:

- superseded G4 World Pack packets；
- old handoffs；
- archived SillyTavern / The World / DSH implementation shapes；
- chat summaries；
- model memory。

---

## 4. Start / Freshness Gate

开始前：

```powershell
Set-Location 'D:\AI\Projects\my-world'
git status --short
git rev-parse HEAD
git fetch origin
git rev-parse origin/main
git status -sb
```

要求：

- 不覆盖未知 dirty worktree；
- fast-forward 到包含本 Task Packet 的最新 `origin/main`；
- 记录 `START_HEAD`；
- audit `Formal Code Base → START_HEAD`，确认增量只是 G4-01 closeout / G4-02 packet / governance projection；
- 若出现未知 production Source implementation 或改变 contract/owner/DAG 的新决策，先 audit，无法安全吸收则 `BLOCKED`；
- authoritative write 前再次 fetch/revalidate HEAD。

---

## 5. Read First｜最小充分工作集

按顺序读取：

1. `AGENTS.md`
2. `docs/tasks/G4-02_WORLD_CHARACTER_SOURCE_CONTRACTS_TASK.md`
3. current `MY_WORLD_项目启动总纲_CURRENT.md` 中 Primary Source / Asset-only New Game 部分
4. current `MY_WORLD_架构_CURRENT.md` 中 Primary Source Architecture / Immutable Generation / Source→Game boundaries
5. current Roadmap 中 G4-02 / G4-03 部分
6. repository 当前 `src/` 与 `tests/` 顶层结构，只确定最小集成位置

只有证据不足时才扩大读取范围；Final Report 说明原因。不要默认阅读整个仓库或旧 packet 全文。

---

## 6. Pre-implementation Contract Matrix｜编码前必须完成

在 production contract code 前，先形成 task-scoped evidence：

`docs/tasks/G4-02_实现前Source合同矩阵.md`

至少明确：

```text
Fact / field
→ authored or program-derived
→ required / optional / cardinality
→ validation rule
→ canonical owner
→ mutable at Source authoring time?
→ allowed in Game-local Runtime state? NO/YES with reason
→ fingerprint impact
```

矩阵必须覆盖：

- shared identity seam；
- World Pack fields；
- Entry/T0；
- authored visual/file references；
- Character public/private fields；
- player-character eligibility；
- path / file validation；
- exact generation fingerprint；
- unknown/invalid schema behavior；
- Source vs Game-local/Runtime forbidden fields。

如果必须先决定 Managed Source Library storage/install topology 才能定义 contract，返回 `BLOCKED`；不要偷做 G4-03。

---

## 7. Decision Digest / Invariants

### INV-SOURCE-01｜Primary Source Trio 只共享最薄 identity seam

第一代三类 Source：

```text
World Pack
Character Card
Expansion Pack
```

本任务只做前两类。

允许共享的稳定概念：

```text
asset_id
asset_type
version
exact immutable generation / content fingerprint
```

不得为了复用创建 universal giant `AssetV1` content schema。

### INV-SOURCE-02｜Stable identity != exact generation

`asset_id + version` 不能替代 exact immutable generation。

Program 必须能够从实际 package contents 得到 deterministic generation fingerprint。至少满足：

- 同一 package content → 同一 fingerprint；
- 任一 contract-owned text/material 改变 → fingerprint 改变；
- 任一被 contract 声明并纳入 generation 的 portrait/scene/map/file bytes 改变 → fingerprint 改变；
- 文件枚举顺序、OS directory iteration 顺序不得导致 fingerprint 漂移；
- fingerprint 不信任作者手写值作为唯一 authority。

具体 canonicalization / hashing 方案由实现前矩阵冻结，优先简单、可解释、可重放；不得依赖 Provider。

### INV-WORLD-01｜World Pack 是 T0 前 Source，不是 live World State

World Pack v0.1 至少能表达：

- stable Source identity / display metadata / schema version；
- world / GM instructions；
- ordered Source Lore；
- `0..N` lightweight Entry / T0 seed；
- authored portrait / scene / map declarations；
- 必要的 pre-game World Source material。

不得把以下内容定义成 World Source 的 live truth：

- 当前 Timeline head；
- 当前 NPC location / injury / knowledge；
- current player-known set；
- Save / Recovery state；
- current Conversation；
- runtime-generated history。

### INV-WORLD-02｜Entry/T0 不是 Scenario/Beat DSL

Entry 是 lightweight opening seed/reference。

可以表达启动前必要的 Source opening material，但不得在 G4-02 建：

- beat graph；
- quest scripting platform；
- arbitrary branching scenario DSL；
- event engine。

### INV-CHAR-01｜Character Card 是 reusable Character Source

Character Card 不是 player-only card。

v0.1 至少能表达：

- stable identity；
- display identity；
- public profile；
- GM/private Source profile；
- portrait reference；
- `player_character_supported` 或语义等价 eligibility。

第一代 later creation roles 是：

```text
Exactly 1 Player Character
0..N Guaranteed NPC Characters
```

角色用途不应硬编码成旧的 `bound_only | opening_character | player_character` taxonomy。

### INV-CHAR-02｜Character Source 不拥有 live runtime state

Character Card 不得携带并权威化：

- current live location；
- current relationship；
- current injury/condition；
- current knowledge；
- current inventory；
- player-known flag；
- opening appearance guarantee；
- current Context membership。

Source 可以描述稳定设定/背景/倾向；Game-local Runtime 后续拥有实时现实。

### INV-ASSETREF-01｜Referenced files 必须安全且可验证

Source contract 的 authored file references 必须：

- 使用 package-local relative path 或语义等价安全引用；
- 禁止 path traversal / absolute escape；
- 缺失文件 fail-loud；
- 不把任意 executable/script 当作 v0.1 Source content；
- visual bytes 若属于 exact Source generation，必须影响 generation fingerprint。

不要在本任务实现 runtime image resolution/cache；这里只证明 Source declaration 与 file integrity。

### INV-VALIDATE-01｜Validation fail-loud，不自动修复作者意图

至少拒绝：

- malformed JSON / invalid encoding；
- unsupported asset_type / schema version；
- missing required identity；
- invalid cardinality；
- duplicate IDs where uniqueness is required；
- unsafe/missing referenced files；
- Character Card 明显混入 contract 禁止的 live-state fields（若 contract 采用显式禁止策略）；
- contract-defined structurally invalid Source。

不得 silent default 成另一种资产、自动生成新 identity 或改写 Source package。

### INV-BOUNDARY-01｜G4-02 不发布/安装 Source

本任务的 loader/validator 可以对**显式 task-owned/source fixture path**读取真实 package，用于 contract proof。

它不是 Managed Source Library，不得实现：

```text
install
publish
inventory
current installed version
historical generation retention
Game pin registry
```

这些属于 G4-03+。

### INV-PRODUCT-01｜Contract 必须服务真实未来建局，而非抽象漂亮

本任务的 Source projection 必须足以让后续 G4-03/G4-05/G4-06 消费真实 World/Character content，同时不提前拥有 Game-local truth。

如果两个 materially different World fixtures 无法自然表达，contract 应在 G4-02 内修正，而不是先建立兼容层。

---

## 8. Scope

### Allowed

- 新增最小 `src/source/` 或语义等价 Source contract/loader/validator 目录；
- World Pack / Character Card v0.1 typed projection / validation；
- deterministic generation fingerprint helper；
- package-local safe file reference validation；
- task-owned `tests/g4_02/`；
- compact reality fixtures，包括文本与必要的小型 authored image/file fixture；
- machine/human-readable contract docs，放在实现仓库既有合理子目录；
- `docs/tasks/G4-02_实现前Source合同矩阵.md`；
- 必要的 README/navigation 小修。

### Prohibited

- Managed Source Library / install / publish / inventory；
- multi-Game / Game Library；
- New Game UI selector / selection state；
- Game Creation Composition；
- Final Create / game-local materialization；
- Expansion Pack contract/loader；
- Runtime Asset Resolution / image cache；
- G5 World/NPC semantics；
- G6/G8 declarative UI / Mod/Creator protocol；
- production SQLite schema change；
- Provider calls；
- generic plugin/package framework；
- arbitrary executable Source content。

---

## 9. Contract Reality Check｜必须是真实内容

至少建立两个 materially different compact World Pack fixtures，例如：

```text
A. historical / low-magic / social-political world
B. high-magic / fantastical / different lore + visual declarations
```

具体内容由 Agent 编写测试 fixture，不构成产品 canonical lore。

同时建立足以覆盖 Character contract 的 Character Cards，至少证明：

- 一个可作为 Player Character 的 Source；
- 一个可作为 Guaranteed NPC 的 reusable Source；
- public profile 与 GM/private profile 分离；
- portrait reference 被实际读取/验证；
- Character 不需要 live location / relationship / knowledge 才能成为有效 Source。

Reality Check 必须通过生产 loader/validator seam 读取真实 files；不得只 construct Dictionary 绕过 filesystem contract。

---

## 10. Required Deliverables

1. World Pack v0.1 formal implementation contract；
2. Character Card v0.1 formal implementation contract；
3. minimal shared identity representation without giant schema；
4. deterministic exact generation fingerprint；
5. safe referenced-file validation；
6. explicit-path production loader/validator seam；
7. two materially different World fixtures；
8. Character fixtures covering Player eligibility + reusable NPC use；
9. `docs/tasks/G4-02_实现前Source合同矩阵.md`；
10. focused positive/negative tests；
11. real Windows-local Godot filesystem execution evidence；
12. implementation commit(s) + push `main`；
13. Final Report with highest state `READY FOR INDEPENDENT REVIEW`。

---

## 11. Acceptance Gates

### AC-01｜Two real World contracts load

两个 materially different World packages 通过同一 production loader/validator 成功读取，并保留各自 ordered lore、Entry/T0、instructions 与 authored declarations；不得通过 world-specific hardcode。

### AC-02｜Character roles remain source-neutral

Character Card loader 能读取 reusable character definition，并通过 eligibility 表达是否可作为 Player Character；同一 contract 不强迫 Character 成为 player-only 或 opening NPC。

### AC-03｜Public/private separation

Character public profile 与 GM/private Source profile 在 loaded projection 中可区分；测试证明 private material 不被误当 display/public identity 字段。

### AC-04｜No live runtime truth in Source

contract/tests 明确证明有效 Character Source 不依赖 live location/current relationship/current knowledge/current injury 等字段；World Source 不包含 current Timeline/Save/Conversation truth。

### AC-05｜Exact generation is content-sensitive

真实 filesystem test 证明：

- unchanged package → fingerprint stable；
- text content change → fingerprint changes；
- declared visual/file bytes change → fingerprint changes；
- file discovery order change不改变结果。

### AC-06｜Path safety

absolute/path traversal/missing referenced file 被拒绝，package root 之外文件不能进入 contract-owned generation。

### AC-07｜Negative validation

focused tests 至少覆盖 malformed content、wrong asset_type/schema、missing identity、bad cardinality/reference，以及 Source/Game-local boundary 的关键 invalid case。

### AC-08｜No Source Library leakage

实现中不存在 install/publish/inventory/current-version/history-retention/Game-pin registry；loader 只消费明确输入 path/package。

### AC-09｜No giant universal schema

共享层不承载 World/Character 具体语义字段。World-specific 与 Character-specific validator/projection 清楚分开。

### AC-10｜Real filesystem / Windows-local proof

至少一轮在真实 Godot 4.7.2 Windows-local 环境中从磁盘读取完整 fixtures 并运行 focused suite；不能只用静态 JSON parse 或 mock filesystem 宣称 PASS。

### AC-11｜Regression / scope

现有 G4-01 Application lifecycle 不因 Source contract 新增而退化；不改 production SQLite schema；不要求 Provider；不启动 G4-03。

---

## 12. Validation Plan

先确认 repository current runner，按 focused → relevant regression 顺序执行。

至少需要：

```text
parse/load positive fixtures
negative contract validation
generation fingerprint stability/change tests
path safety tests
World A + World B reality check
Character reality fixtures
```

然后做必要的轻量 regression：

- project parses / main scene can load；
- G4-01 focused lifecycle smoke 或等价最小 regression，证明 Source code 没有被 Application boot 隐式调用；
- Main Menu boot 仍不触碰 Source fixture/library 或 Game DB。

G4-02 不要求新的 exported EXE Gate，也不要求 Provider call；若实现改到 product boot path，则必须额外证明没有 boot-time Source scanning。

Final Report 列 exact commands、exit codes、fixture paths 与 observable evidence。

---

## 13. Independent Review Readiness

Independent Reviewer 后续重点检查：

```text
giant shared Asset schema?                         NO
fingerprint ignores visual bytes?                  NO
fingerprint trusts mutable author field only?      NO
fixture loader bypasses production path?           NO
World/Character schema mixed with live state?      NO
path traversal / external file escape?             NO
Source Library secretly implemented?               NO
single-example overfit?                            NO
```

不要让“JSON 能 parse”冒充 contract reality proof。

---

## 14. Git / Integration

Codex 负责 routine Git：

1. fetch / fast-forward；
2. record start HEAD/status；
3. matrix → implementation → tests；
4. focused + reality + relevant regression；
5. pre-push freshness revalidation；
6. 若 `origin/main` 只有无关 doc/task 增量，安全吸收并重跑受影响 Gate；
7. 若 current contract/DAG/target seam 被并行修改，返回 `BLOCKED`；
8. commit + push `main`；
9. final tracked worktree clean。

禁止：

```text
git reset --hard
git clean -fd
force push
覆盖未知 dirty worktree
提交 local secret / DB / build / cache / logs
```

---

## 15. Stop / Return Conditions

返回 `BLOCKED` 如果：

- current governance 与 packet 发生实质冲突；
- contract 必须依赖 G4-03 Library topology 才能成立；
- exact generation 无法在不引入未批准 package/platform architecture 的情况下定义；
- 需要 production persistence/schema migration；
- 需要 Product Owner 对 World/Character 核心语义做新的不可推导裁定；
- 出现未知并行 production Source implementation；
- Windows-local filesystem reality 无法验证。

以下不是 blocker：

- 新建窄 `src/source/` 目录；
- 为 v0.1 选择简单 JSON package shape；
- 在未发布 v0.1 中根据 Reality Check 直接修 contract；
- 增加 small fixture images/files 用于 fingerprint/reference proof。

---

## 16. Final Report Format

```markdown
## Result
READY FOR INDEPENDENT REVIEW | BLOCKED

## Base / Freshness
- Formal Code Base:
- Start HEAD:
- Final HEAD:
- origin/main revalidation:

## Contract Shape
- shared identity:
- World Pack:
- Character Card:
- exact generation:

## Changed
- file → behavior

## Contract Matrix
- path:
- key decisions:

## Reality Fixtures
- World A:
- World B:
- Characters:

## Evidence
- focused positive:
- negative validation:
- fingerprint/path safety:
- real filesystem:
- relevant regression:

## Git
- commits:
- pushed:
- final status:

## Scope Check
- G4-03 started? NO
- SQLite schema changed? NO
- Provider called? NO
- Expansion implemented? NO

## Remaining / Risks
- ...
```

不要只回复“完成”。

---

## 17. Handoff Boundary

G4-02 完成后：

```text
Implementation
→ Independent Review
→ G4-02 CLOSE
→ G4-03 Managed Local Source Library v0.1
```

G4-02 默认不要求 Owner UAT；若 Contract Reality Check 暴露新的产品语义分歧，则停止并提交 Owner 裁定，而不是自行扩展 contract。