---
title: my world｜G4-06 Atomic Final Create Task Packet
status: current-task-packet
task_id: G4-06
type: implementation
owner: Codex
created: 2026-08-30
updated: 2026-08-30
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: d9f58963db26055f6ca1a54c26689baf63263ede
governance_base: 62d7efcf0cad061543eb3c97779b311bf2563240
highest_implementation_status: READY FOR INDEPENDENT REVIEW
owner_uat_required: false
---

# TASK｜G4-06｜Atomic Final Create

Type: `implementation`  
Owner: **Codex**  
Semantic / Independent Review owner: **GPT**  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`  
Formal Code Base: `d9f58963db26055f6ca1a54c26689baf63263ede`

> 本任务第一次把 G4-05 已冻结的 exact `GameCreationComposition` 变成一个真正独立、可恢复、不会重复创建的 Game。
>
> **不要调用 Provider，不要生成 AI Opening。** G4-07 才第一次验证可玩 Opening。

---

## 1. Outcome / Product Value

完成后，G4-05 Review 的有效 Composition 可以执行：

```text
Frozen exact Composition
→ creation identity + immutable creating intent
→ exactly one managed Game SQLite
→ exact Source generation pins
→ selected starting Source projections
→ game-local World / Character identities + provenance
→ root Setup Context / Timeline ancestry
→ Game Library verified record + current
→ created
```

核心价值不是“按钮能写一个 DB”，而是：

- 同一次创建不会因为重试或崩溃产生两个 Game；
- 已选 Source generation 不会在创建过程中漂移到 newer current；
- 历史 T0 隔离继续成立；
- 普通 non-temporal Source 不被强迫建立 T0；
- Source 只提供起点，Game-local reality 从创建完成后独立演化；
- 任何中断都有明确、可收敛的恢复路径，而不是伪装成跨 SQLite/filesystem ACID。

Codex 本任务最高只能返回：

> **READY FOR INDEPENDENT REVIEW**

不得宣布 G4-06 closed，不得宣布 First Playable / Product PASS。

---

## 2. Why Now

Current state：

```text
G4-02R1 Source v0.2-r2        PASS / CLOSED
G4-03 Managed Source Library  PASS / CLOSED
G4-04 Game Library            PASS / CLOSED
G4-05 New Game Wizard         PASS / CLOSED
NOW G4-06 Atomic Final Create
NEXT G4-07 First Playable A / Owner UAT
```

G4-05 已经证明玩家可以选出 exact Composition，但仍故意不创建 Game。
G4-06 只补“安全、可重试地把这个 intent 变成 durable Game”的缺口。

---

## 3. Authority / Source Manifest

冲突时按以下顺序：

1. Owner 当前明确指令。
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`。
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`。
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`。
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md`。
6. `Vibe-Coding/my world/architecture/creation/G4-06_OPTIONAL_ENTRY_MATERIALIZATION_DECISION.md`。
7. `Vibe-Coding/my world/architecture/persistence/G4-04_MULTI_GAME_STORAGE_TOPOLOGY_DECISION.md`。
8. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`。
9. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`。
10. repository `AGENTS.md`。
11. current G4-02R1 / G4-03 / G4-04 / G4-05 production code and tests。
12. current G3 Persistence / Save / Recovery contracts and implementation。

Source semantic authority remains the frozen v0.2-r2 contract/addenda. Do not redesign Source inside G4-06.

---

## 4. Freshness Gate

Before implementation：

```powershell
Set-Location 'D:\AI\Projects\my-world'
git status --short
git rev-parse HEAD
git fetch origin
git rev-parse origin/main
git status -sb
```

Requirements：

- fast-forward to current `origin/main` containing this packet and current `AGENTS.md`;
- record `START_HEAD`;
- audit Formal Code Base `d9f58963... → START_HEAD`;
- expected drift is packet/governance projection only;
- do not overwrite unknown dirty work;
- if another implementation has changed Final Create / Game Library / Persistence / Composition seams, audit first;
- if current governance materially supersedes this packet, return `BLOCKED` rather than implementing stale semantics;
- re-fetch/revalidate before push.

---

## 5. Read First｜minimum sufficient set

1. `AGENTS.md`
2. this Task Packet
3. `src/建局/L3_外交层/建局公开接口.gd`
4. `src/建局/L2_流程层/建局兼容性审查流程.gd`
5. `src/source/L3_外交层/Source合同公开接口.gd`
6. `src/source/L3_外交层/Source库公开接口.gd`
7. `src/游戏库/L3_外交层/游戏库公开接口.gd`
8. `src/runtime/当前游戏会话运行时.gd`
9. `src/persistence/L3_外交层/世界持久化公开接口.gd`
10. `src/persistence/L3_外交层/数据库安全公开接口.gd`
11. G4-04 lifecycle/failure tests
12. G4-05R2 full-fidelity Wizard reality tests
13. G4-02R1 projection/fingerprint reality tests
14. current Architecture/Roadmap sections for Final Create / materialization / Game-local semantics
15. `G4-06_OPTIONAL_ENTRY_MATERIALIZATION_DECISION.md`

Only widen reading when evidence requires it.

---

## 6. Pre-implementation matrices｜required before production code

Create:

`docs/tasks/G4-06_创建协议与失败窗口矩阵.md`

At minimum cover：

```text
case
→ immutable creation intent
→ creation_id / composition fingerprint / game_id
→ DB physical state
→ DB internal identity
→ Game Library record
→ current selection
→ creation journal state
→ visible result
→ retry/restart convergence
```

Required cases：

A. first successful Final Create；  
B. exact replay of same creation identity/payload；  
C. same creation identity + different payload conflict；  
D. crash/fault after creating intent publish, before DB creation；  
E. crash/fault after DB creation, before Game Library registration；  
F. crash/fault after Game Library record, before current publish；  
G. crash/fault after current publish, before caller receives success；  
H. selected Source generation missing/tampered before any durable Game side effect；  
I. selected Source X was pinned, newer Y becomes current before create；  
J. temporal Character incompatible with exact Entry；  
K. Character with zero World temporal coverage；  
L. non-temporal Character with no `t0_profiles`；  
M. non-temporal World with scenario Entry；  
N. explicit no-Entry Composition；  
O. DB path already exists with wrong identity；  
P. Game Library registration/current publish failure；  
Q. writer conflict / storage failure；  
R. process restart and explicit reconciliation/retry of durable creating intent；  
S. owner real data isolation；  
T. no Provider / no AI Opening。

Do not start production code before the matrix makes the commit/replay ordering explicit.

---

## 7. Frozen Decision Digest / Invariants

### INV-CREATE-01｜Composition must be valid and exact before durable creation

Final Create accepts only a G4-05 semantic Composition equivalent that has passed deterministic Compatibility Review.

Before publishing creating intent, re-resolve every selected exact Source pin through G4-03 exact lookup and rebuild required G4-02R1 projections.

Missing/tampered selected generation or temporal incompatibility fails loud **before any Game DB/Game Library creation side effect**.

Never silently resolve newer current generation.

### INV-CREATE-02｜Creation identity is not only the composition fingerprint

Users must eventually be able to create two separate Games from identical compositions.

Therefore：

- `composition_fingerprint` = deterministic canonical digest of the frozen creation payload;
- `creation_id` = stable identity for one creation attempt, generated/fixed once;
- immutable creating intent binds `creation_id` → exact payload fingerprint + fixed `game_id` + fixed setup/root/local entity identities required for replay.

Same `creation_id` + same payload → resume/return same Game.  
Same `creation_id` + different payload → conflict / fail-loud.

Do not derive long-term Game uniqueness solely from composition hash.

### INV-CREATE-03｜Persist creating intent before first irreversible Game side effect

A complete immutable creating intent must be published crash-safely before creating the managed Game SQLite.

The intent/journal is Application creation-protocol metadata, not gameplay truth and not Source truth.

Implementation may choose the narrow physical layout, but it must be task-testable with injected roots and use complete-temp + same-volume atomic rename or equivalent safe publication.

Partial pending files are not authoritative intents.

### INV-CREATE-04｜One creation identity → at most one Game

The creating intent fixes exactly one `game_id` and one safe managed DB path.

Retry must never mint a second game_id or second DB for the same creation identity.

If the target path exists：

- matching verified DB identity/state may be resumed;
- mismatched/ambiguous/corrupt identity fails loud;
- never delete/overwrite it to “try again”.

### INV-CREATE-05｜No fake cross-system ACID

G4-06 spans filesystem metadata + one Game SQLite + Game Library metadata.

Do not pretend these form one global transaction.

Use a monotonic, replayable protocol such as：

```text
creating intent
→ DB created + initial truth committed
→ DB identity verified
→ Game Library record registered
→ current committed
→ creation marked/recognized created
```

Exact naming is implementation-owned; semantics are not.

Each crash window must converge by replay/inspection, not destructive rollback of valid durable Game truth.

### INV-CREATE-06｜One Game = One SQLite remains frozen

Managed target path remains derived through G4-04 Game Library safe path semantics：

```text
user://my-world/games/<game_id>/game.sqlite
```

Do not introduce shared SQLite + game_id partitioning.

### INV-CREATE-07｜Initial DB creation uses explicit identity and initial state

The historical `CurrentGameRuntime.open_current_game()` first-run seam generates its own random game identity and empty world state. That is not sufficient authority for Final Create.

G4-06 must create/verify the exact intent-fixed `game_id` and initial materialized setup using the existing Persistence/Safety boundaries or a narrow dedicated creation composition seam.

Do not create an empty Game and patch identity/content later.

### INV-CREATE-08｜Materialize selected Source projection, not total package

Source generation remains immutable and outside the Game.

Game-local starting truth copies only the selected starting projection plus provenance.

For selected Entry：

```text
World = top-level always-safe sections + exact selected Entry sections
Character = top-level always-safe sections + exact selected T0 profile sections when exact binding exists
```

For zero World profile coverage：Character uses top-level always-safe sections only; do not hard-block merely by family.

All ordering/disclosure metadata required to preserve selected rich semantics must survive materialization.

Do not copy unselected future/private Source bytes merely because they participated in fingerprinting.

### INV-CREATE-09｜No Entry means no hidden temporal choice

Canonical decision：

`Vibe-Coding/my world/architecture/creation/G4-06_OPTIONAL_ENTRY_MATERIALIZATION_DECISION.md`

If Composition explicitly contains no Entry：

```text
World initial semantics = top-level semantic_sections only
Character initial semantics = top-level semantic_sections only
```

No Entry-scoped section and no Character T0 profile is selected.

Do not：

- force Entry universally；
- choose first/latest/nearest/default Entry；
- infer a year from family/display text；
- block solely because asset is “historical”。

### INV-CREATE-10｜Game-local identity != Source asset identity

At Final Create, generate stable Game-local identity for：

- the local World definition/root where needed;
- Player Character;
- every Guaranteed NPC.

Source `asset_id`/version/fingerprint remain provenance only.

The same Source generation used in two different Games must yield distinct Game-local Character identities.

The same Character Source cannot be both Player and Guaranteed NPC because G4-05 already forbids that composition.

### INV-CREATE-11｜Guaranteed NPC semantics remain narrow

Guaranteed NPC materialization means：

> this Game has a canonical local Character derived from the selected exact Source generation.

It does **not** mean：

- opening-scene presence;
- same location as Player;
- Player already knows them;
- automatic relationship;
- active Context inclusion;
- scripted future appearance.

Do not seed those facts unless the selected Source projection explicitly authored them as starting truth and the owning game-local semantic path supports them.

### INV-CREATE-12｜Game-local setup envelope is a starting snapshot, not universal ontology

G4-06 may introduce the smallest durable game-local setup/materialization envelope needed to carry：

- creation identity / composition fingerprint;
- display name / control mode / opening supplement;
- exact Source provenance pins;
- explicit Entry or none;
- selected rich World semantics;
- local Player Character identity + selected rich semantics;
- local Guaranteed NPC identities + selected rich semantics;
- setup/root ancestry metadata.

Do not turn this into a closed universal World/Character schema.

> **Source schema is not the possibility ceiling of the Living World.**

After creation, future game-local semantic facets may evolve under later owners/contracts.

Prefer current opaque durable World document capability over speculative production SQLite schema expansion unless a concrete existing owner requires otherwise.

If G4-06 genuinely requires a physical production schema migration, stop and return `BLOCKED` with the exact missing durable ownership requirement before adding it.

### INV-CREATE-13｜Setup Context ancestry exists, but AI Opening does not

Root Timeline/current World created by G4-06 must contain enough durable ancestry for G4-07 to assemble the first Opening from the created Game rather than re-reading mutable Wizard state.

But G4-06 must not：

- call Provider；
- create AI Conversation turns；
- generate opening prose；
- claim the Game is already `playable`。

Creation terminal state for this task is `created`; G4-07 proves `playable`.

### INV-CREATE-14｜Game Library registration only after DB identity verification

Use G4-04 existing semantics：

```text
DB exists
→ verify internal game_id == intended game_id
→ register_verified_managed_game(...)
→ commit_current(...)
```

Game Library does not create DB and must not be asked to trust an unverified intended ID.

### INV-CREATE-15｜Source pins remain exact after creation

The created Game must durably retain provenance for every selected exact Source generation：

```text
asset_type
asset_id
version
generation_fingerprint
```

Future Source updates affect future selection/new Games only. They never rewrite this Game's initial materialization or pin identity.

### INV-CREATE-16｜No destructive rollback

If failure occurs after valid Game DB truth exists, repair/replay forward.

Do not delete a verified Game DB merely because later Game Library/current publication failed.

Quarantine/explicit conflict is preferable to overwriting ambiguous existing truth.

---

## 8. Composition fingerprint canonicalization

Before code, document the exact canonical payload used for `composition_fingerprint`.

It must include at least：

- exact World pin;
- explicit Entry ID or explicit none;
- expansions = current empty set;
- exact Player Character pin;
- exact Guaranteed NPC pins;
- Game display name;
- Protagonist Control Mode;
- opening supplement exact text.

Do not hash transient UI state, list focus/order, Source current pointers or filesystem paths.

For semantically set-like collections such as Guaranteed NPCs, canonicalization must not depend on incidental UI enumeration order unless current Composition explicitly defines order as meaningful. Record the decision in the matrix/tests.

---

## 9. Required real evidence

Primary reality input remains the frozen v0.2 full-fidelity fixtures：

Worlds：
- 汉末三国：天下未定
- 埃瑟维亚：诸界余辉

Characters：
- 刘备 / 曹操 / 孙权
- 莉维娅·塞兰 / 阿德里安·维尔克 / 杜恩·石痕

At minimum prove through production seams：

### Real Create A｜Han temporal path

Example valid composition may use：

- Han exact World generation;
- an exact Entry compatible with Player Character;
- one Player Character;
- 0..N Guaranteed NPCs that pass current deterministic compatibility;
- settings/supplement.

After create：

- exactly one managed Game SQLite exists;
- DB internal game_id matches creation intent;
- Game Library has exactly the matching record/current;
- current World/setup contains only selected Entry/T0 projections, not future/unselected markers;
- local Character IDs differ from Source asset IDs;
- Source provenance pins exact-match frozen generations;
- opening supplement/control mode survive durably;
- no Provider/AI turn exists.

### Real Create B｜Afterglow / ordinary scenario path

Prove exact scenario selection works without historical temporal assumptions.

### No-Entry path

Create a valid Composition with explicit no Entry and prove：

- top-level World/Character semantics materialized;
- no T0 profile/Entry sections were silently selected;
- no default/latest/nearest fallback occurred.

### Negative temporal path

Han incompatible Character/Entry must fail before Game DB/Game Library mutation.

---

## 10. Failure injection / idempotence evidence

Task-owned tests must provide controlled fault points sufficient to prove at least：

1. after creating-intent publish;
2. after initial Game DB commit;
3. after Game Library record publish;
4. after current publish / before normal return.

For each fault：

- capture physical/durable state;
- simulate process restart with fresh objects;
- replay/reconcile using the same creation identity;
- prove exactly one final Game and one matching Game Library record;
- prove no duplicate local identities are minted on retry.

Also prove same creation identity + altered Composition conflicts without mutating the existing Game.

---

## 11. Scope

### Allowed

- a new narrow Final Create / creation-protocol module with L0/L1/L2/L3 layering if warranted;
- minimal additions to Application composition root / Wizard final action to invoke Final Create;
- minimal Game Library seam extension only if replayable creation requires application metadata not currently representable;
- reuse/narrow extension of Persistence/DatabaseSafety for explicit initial Game creation and inspection;
- task-owned creation journal / intent metadata;
- task-owned tests and failure injection;
- current v0.2 projection/materialization adapters;
- minimal created-state UI success/failure handoff needed to prove the action works;
- docs/contracts/evidence directly required by this task.

### Prohibited

- Source semantic redesign;
- changing frozen 2 World + 6 Character content to make tests pass;
- generic Character/World universal ontology;
- physical production SQLite schema expansion without first returning `BLOCKED` as required above;
- shared multi-Game SQLite;
- Provider call / AI Opening;
- G4-07 conversation/context product work;
- Expansion Pack implementation;
- Source Creator/editor;
- cloud/sync/export/import platform work;
- destructive deletion/rollback of verified Game DB on later publication failure;
- treating Game Library metadata as gameplay truth.

---

## 12. Engineering Acceptance Gates

### AC-01｜Valid exact Composition creates one durable Game

Exactly one managed Game SQLite with intended identity and initial setup exists.

### AC-02｜Exact replay is idempotent

Same creation identity + same payload returns/converges to the same Game with no duplicate DB, Game Library record or local Character identities.

### AC-03｜Identity conflict fails loud

Same creation identity + different payload cannot reuse/overwrite the prior result.

### AC-04｜Crash windows converge

All required injected crash windows converge after restart/retry.

### AC-05｜Exact Source pins and projections

No drift to newer Source generation; selected projection only is copied.

### AC-06｜Temporal quarantine survives materialization

Han early start contains no later Entry/profile truth.

### AC-07｜Non-temporal and no-Entry both work

No artificial temporal hard mode; no hidden default Entry/profile.

### AC-08｜Distinct Game-local identities

Source IDs remain provenance, not local Character IDs; identical Source used across two distinct creation identities yields distinct local entities/Games.

### AC-09｜Guaranteed NPC semantics not over-seeded

No invented opening/current-location/player-known/relationship facts.

### AC-10｜Game Library consistency

Verified record/current exactly match DB identity; publish failures are replayable and do not overwrite valid DB truth.

### AC-11｜No Provider / AI Opening

Zero Provider request and zero generated opening Conversation in G4-06.

### AC-12｜Regression

G3 Persistence/Recovery, G4-02R1 Source, G4-03 Source Library, G4-04 Game Library and G4-05R2 Wizard regressions remain green.

### AC-13｜Owner data isolation

Automated tests/fault injection use task-owned roots only; no Owner real Game/Source/Game Library touched.

---

## 13. Product Value Acceptance

G4-06 does **not** claim Product PASS or First Playable.

The product-value ceiling here is：

> “The player-approved exact composition can become one durable, correctly sourced Game without duplication or hidden drift.”

Narrative richness, first AI opening, character individuality in play and actual fun remain G4-07 Owner UAT.

---

## 14. Validation Commands

Agent owns exact commands. Run focused → boundary regressions → full relevant suite.

At minimum include：

- G4-06 focused create/idempotence/conflict tests;
- G4-06 crash-window/restart tests;
- full-fidelity Han/Afterglow/no-Entry materialization tests;
- G4-02R1 reality/negative tests;
- G4-03 reality/restart/tamper tests;
- G4-04 Game Library lifecycle/failure tests;
- G4-05R2 full-fidelity Wizard reality/layout where relevant;
- G3 persistence/recovery tests touched by seams;
- Godot editor parse;
- Windows non-headless real integration if Application Final Create UI is changed;
- `git diff --check`;
- explicit path checks proving frozen full-fidelity fixtures unchanged.

Do not report only test counts; include the semantic evidence rows for critical create/replay/failure cases.

---

## 15. Git / Integration

- implement on current `main` unless repository rules require a task branch;
- keep implementation and evidence commits reviewable;
- no destructive reset to earlier G4;
- do not rewrite unrelated history;
- before final push revalidate `origin/main` and absorb only safe expected drift;
- packet/governance-only commits are not implementation evidence.

---

## 16. Stop / Return Conditions

Return `BLOCKED` to GPT instead of inventing policy if：

- a physical production SQLite schema migration is genuinely required;
- current G4-04 topology cannot support one-Game-one-SQLite Final Create;
- frozen Composition lacks information required to build safe initial truth;
- Source v0.2 projection cannot be represented without losing required semantics;
- optional no-Entry decision conflicts with actual frozen contract;
- safe idempotent recovery would require changing Product semantics;
- concurrent implementation drift changes the same creation/storage seams materially.

If only a narrow ordinary implementation bug appears, fix it within scope and prove regression.

---

## 17. Final Report

Return exactly one of：

- `READY FOR INDEPENDENT REVIEW`
- `BLOCKED`

For `READY FOR INDEPENDENT REVIEW`, include：

- Start HEAD
- Final HEAD
- implementation commit(s)
- evidence commit/doc
- files changed
- creation protocol/state sequence
- composition fingerprint canonicalization
- real Han create proof
- real Afterglow create proof
- no-Entry proof
- temporal negative-before-side-effect proof
- same-identity replay proof
- different-payload conflict proof
- each injected crash-window convergence proof
- exact DB/Game Library identity proof
- local Character ID vs Source ID proof
- exact Source pin/projection proof
- no Provider/Opening proof
- regression commands/results
- Windows/Godot evidence if UI changed
- whether production schema changed (expected: **no**)
- known limitations

Do not claim G4-06 closed. GPT performs Independent Review.
