---
title: my world｜G4-07A First Playable Opening Runtime Task Packet
status: current-task-packet
task_id: G4-07A
type: implementation
owner: Codex
created: 2026-08-30
updated: 2026-08-30
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: 39d7300790b2b067b12630f4d1efd4fd51b6d126
parent_task: G4-07 First Playable A
highest_implementation_status: READY FOR INDEPENDENT REVIEW
owner_uat_required: false
parent_owner_uat_required: true
---

# TASK｜G4-07A｜First Playable Opening Runtime

Type: `implementation`  
Owner: **Codex**  
Semantic / Independent Review owner: **GPT**  
Parent product gate: **G4-07 First Playable A — Owner UAT required**  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`  
Formal Code Base: `39d7300790b2b067b12630f4d1efd4fd51b6d126`

> G4-06 已证明一个 exact Composition 可以安全变成 durable `created` Game。
> G4-07A 第一次让这个 durable Game 自己成为 AI GM Opening 的唯一事实来源。
>
> **不要从 Wizard state 或 mutable Source current 重新拼 Opening。**
> 第一次真实 Provider Opening 必须由 G4-06 已持久化的 Game-local setup/root truth 驱动。

Codex 本任务最高只能返回：

> **READY FOR INDEPENDENT REVIEW**

不得宣布 G4-07 Product PASS；Owner UAT 在后续完整 UI vertical 后进行。

---

## 1. Outcome

建立最小 backend/runtime vertical：

```text
G4-06 created Game
→ open existing exact Game
→ read durable current/root/setup truth
→ assemble bounded-but-rich first Opening Context
→ real DeepSeek GM Opening request
→ stream/accept one GM Opening
→ persist accepted Conversation
→ close session
→ reopen exact same Game
→ continue from durable Conversation + World truth
```

本任务证明的是 **created → opening-capable runtime seam**，不是完整玩家 UI。

---

## 2. Why split from G4-07 UI

G4-07 是产品 gate，但当前仍有两个不同风险：

1. backend/runtime/context/provider：durable Game 能否正确产生第一条真实 Opening；
2. frontend/application：Wizard Final Create 能否无缝进入可玩的 Narrative UI，并正确呈现 loading/error/retry/continue。

先冻结 G4-07A runtime seam，再交给 Kimi 做 G4-07B UI integration，最后 Owner UAT。

---

## 3. Authority / Read First

Read minimum sufficient set before implementation：

1. `AGENTS.md`
2. this packet
3. `docs/g4_06/G4-06_ATOMIC_FINAL_CREATE_IMPLEMENTATION_EVIDENCE.md`
4. `docs/g4_06/G4-06IR01_PROCESS_RESTART_EVIDENCE.md`
5. `src/最终建局/L3_外交层/原子最终建局公开接口.gd`
6. `src/runtime/当前游戏会话运行时.gd`
7. `src/context/上下文组装器.gd`
8. current Provider public/request seams under `src/provider/**`
9. `src/persistence/L3_外交层/世界持久化公开接口.gd`
10. G2 real Provider conversation tests
11. G3 reopen/Conversation durability tests
12. G4-04 existing-only Game open / session lifecycle tests
13. frozen G4-02R1 Source semantics only as provenance background; **do not reread mutable Source to reconstruct created setup**

Governance authority remains current Product / Principles / Architecture / Roadmap / Status in `Vibe-Coding/my world/`.

---

## 4. Pre-implementation alignment matrix

Before production code, create:

`docs/tasks/G4-07A_OPENING_RUNTIME_STATE_FAILURE_MATRIX.md`

Cover at minimum：

```text
case
→ durable Game state before call
→ Context source
→ Provider request state
→ accepted Conversation state
→ retry/reopen behavior
→ visible/runtime result
```

Required cases：

A. newly created Game, Conversation empty → first Opening success；
B. Provider transport/auth/rate/server failure before accepted response；
C. cancel during streaming before acceptance；
D. successful streamed Opening accepted exactly once；
E. retry after failed/cancelled attempt does not create duplicate accepted Opening；
F. reopen after accepted Opening does not auto-generate a second Opening；
G. existing Game with accepted Conversation continues from durable history；
H. Game DB missing/wrong identity/corrupt → fail loud, no fallback Game creation；
I. Source current changes after Game creation → Opening context remains Game-local pinned setup；
J. Han early-start setup → no future/unselected temporal material in Provider-visible first context；
K. no-Entry Game → no hidden Entry/profile introduced by runtime；
L. Guaranteed NPC exists canonically but is not automatically opening-present/player-known unless durable setup explicitly says so；
M. Context bounded but not starved；
N. real Provider request/response evidence is task-owned and secrets are not committed；
O. close/reopen exact Game and continue from durable Conversation.

---

## 5. Frozen invariants

### INV-PLAY-A01｜Game-local truth is the Opening source of authority

Opening Context must be assembled from the opened Game's durable state: current World/root setup ancestry + accepted Conversation + other already-owned runtime state.

Forbidden:

- Wizard memory/state as runtime truth;
- `SourceLibrary.current` re-resolution as Opening truth;
- re-running Final Create materialization to reconstruct context;
- using newer Source generation after create.

Source provenance may be displayed/debugged, but runtime semantic content comes from the Game-local materialized projection.

### INV-PLAY-A02｜Existing-only open

G4-07A must use an existing-only Game/session open path.

Never use a historical first-run seam that silently creates a missing Game or invents a new random `game_id`.

Missing/wrong/corrupt DB fails loud.

### INV-PLAY-A03｜Exactly one accepted Opening

A new Game whose accepted Conversation is empty may request its first AI GM Opening.

Once a valid Opening is accepted and durable, reopen/resume must not auto-create another first Opening.

Failed/cancelled/unaccepted attempts are not durable accepted turns.

Do not solve idempotence by suppressing legitimate explicit later player turns.

### INV-PLAY-A04｜Opening is a GM turn, not a fake player prompt

The first generated narrative is authored by the GM from setup context without inventing a synthetic player action merely to trigger generation.

If an internal request envelope needs a directive, keep it system/runtime-owned and do not persist it as if the player said it.

### INV-PLAY-A05｜Context richness and quarantine both survive

First Opening Context must include enough selected World/Player semantics to produce a distinctive scene, while preserving G4-02R1/G4-06 temporal isolation.

For early Han, no later Entry/profile/future markers may enter Provider-visible context.

For no-Entry, do not infer a default year/Entry/profile.

### INV-PLAY-A06｜Guaranteed NPC remains narrow

A Guaranteed NPC's canonical local Character definition may be available to the GM as world/cast knowledge when context policy selects it, but its mere existence must not force:

- same opening scene;
- same location;
- player familiarity;
- pre-existing relationship;
- mandatory dialogue appearance.

Opening quality tests should specifically reject systematic forced convergence of all guaranteed NPCs into scene one.

### INV-PLAY-A07｜Bounded but not starved Context

Do not respond to token pressure by collapsing rich Source-derived semantics back into one-line summaries.

Reuse/extend current Context Assembly ownership narrowly. Record what semantic categories and approximate payload size entered the real Provider call.

Do not build G7 long-session context architecture here.

### INV-PLAY-A08｜Provider contract remains G2-owned

Reuse the existing Provider adapter/streaming/cancel/failure semantics. Do not introduce a second Provider stack.

Do not commit secrets, API keys, raw auth headers, or private environment files.

### INV-PLAY-A09｜Durability remains G3-owned

Accepted Opening must use existing Conversation/persistence ownership and survive close/reopen.

Do not add a parallel transcript store.

Physical SQLite schema remains v4 unless a genuine missing ownership requirement forces `BLOCKED` before migration.

### INV-PLAY-A10｜No product-UAT claims

Automated/provider evidence may prove mechanism and semantic transport. It cannot prove narrative value.

Terminal task state is `opening-runtime-ready`, not `G4-07 PASS`.

---

## 6. Minimum implementation shape

Prefer a narrow orchestration seam rather than enlarging `当前游戏会话运行时.gd` into a god object.

Acceptable ownership shape, if current code supports it:

```text
existing Game session/runtime
→ first-opening eligibility inspector
→ Game-local opening context assembler
→ existing Provider adapter
→ existing streaming conversation mechanism
→ existing durable accepted Conversation write
```

Exact names are implementation-owned.

Do not introduce universal Living World ontology or G5 GM runtime architecture merely to generate the first Opening.

---

## 7. Real evidence required

Use task-owned Game/Source/Library roots and at least the frozen full-fidelity families.

### Real Han route

Create a real Han Game through **production G4-06**, then open it through G4-07A and issue a real Provider Opening.

Evidence must prove Provider-visible context contains selected early material and excludes known future/unselected markers.

The resulting prose must be stored as real accepted Conversation and survive reopen.

### Real Afterglow route

Create a real Afterglow Game, run a real Opening, and preserve distinct authored fantasy semantics.

This is an engineering-semantic transport check, not Owner judgment of prose quality.

### No-Entry route

At least deterministic context-assembly evidence must prove the no-Entry Game remains no-Entry with top-level-only selected semantics and no runtime default Entry/profile.

If real Provider execution is cheap/stable enough, include it; otherwise real Provider proof may use Han + Afterglow while no-Entry remains deterministic integration proof.

### Provider failure/cancel

Use existing controlled seams/fault injection where available. Prove zero accepted Opening on failure/cancel and clean retry.

### Reopen

Fresh runtime/process where practical:

```text
accepted Opening
→ close session/process
→ reopen exact same managed Game
→ accepted Opening present once
→ no automatic second Opening
→ context for next continuation includes durable history
```

---

## 8. Acceptance checklist

Independent Review will check at least：

- G4-06 production create is used to make the test Game;
- existing-only session open is used;
- context derives from durable Game-local setup, not mutable Wizard/Source current;
- exact Source provenance remains pinned but Source is not re-materialized;
- Han future leakage remains absent;
- no-Entry remains no-Entry;
- Guaranteed NPC semantics do not collapse into forced opening presence;
- real DeepSeek request actually occurs for at least Han + Afterglow;
- streaming/cancel/failure use existing Provider semantics;
- first accepted GM Opening is durable exactly once;
- reopen does not auto-generate duplicate Opening;
- Conversation durability and existing G2/G3/G4 regressions remain intact;
- production SQLite schema remains v4 unless task returned BLOCKED first;
- secrets are absent from repo/evidence;
- no G4-07B UI work is smuggled into this backend task.

---

## 9. Scope exclusions

Do not implement：

- Wizard/Final Create button UI wiring;
- Narrative UI redesign;
- Expansion;
- G5 Living World/GM runtime broad architecture;
- G7 long-session summarization/performance system;
- external declarative UI/mod system;
- autonomous background NPC simulation;
- map/travel systems;
- product-level prose tuning by hardcoded family-specific scripts.

If meaningful play requires a new semantic/product decision rather than a narrow mechanism, return `BLOCKED` with evidence instead of inventing policy.

---

## 10. Required return

Return exactly one of：

### READY FOR INDEPENDENT REVIEW

Include：

- START_HEAD
- implementation/evidence commit SHAs
- production paths changed
- matrix path
- real Provider evidence summary
- Han / Afterglow / no-Entry results
- failure/cancel/retry results
- reopen/durability results
- regression results
- schema status
- explicit statement that G4-07 Product PASS is **not** claimed

### BLOCKED

Include exact missing ownership/semantic decision and smallest evidence reproducing the block.
