# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / Freshness

For every formal task, resolve current authority from GitHub `main` in this order:

1. User current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`.
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`.
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md` and relevant supporting decisions.
6. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`.
7. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`.
8. Current implementation/tests/HEAD.

Execution-agent routing is governed by:

- `Vibe-Coding/my world/AGENT_EXECUTION_ROUTING_CURRENT.md`.

For current Source semantics also read:

- `Vibe-Coding/my world/architecture/source/G4_SOURCE_SEMANTIC_OWNERSHIP_AND_REAUDIT_DECISION.md`;
- `Vibe-Coding/my world/architecture/source/G4_GAME_LOCAL_EVOLVABLE_SEMANTICS_DECISION.md`;
- `Vibe-Coding/my world/architecture/source/G4_T0_SCOPED_SOURCE_AND_POST_T0_CANON_QUARANTINE_DECISION.md`;
- `Vibe-Coding/my world/architecture/source/G4_OPTIONAL_TEMPORAL_SOURCE_SCOPE_DECISION.md`;
- `Vibe-Coding/my world/architecture/persistence/G4-04_MULTI_GAME_STORAGE_TOPOLOGY_DECISION.md`;
- `docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md`;
- `docs/source/G4-02R1_T0_SCOPED_SOURCE_CONTRACT_ADDENDUM.md`;
- `docs/source/G4-02R1_OPTIONAL_TEMPORAL_SCOPE_CAPABILITY_CLARIFICATION.md`;
- `docs/source/G4-02R1_T0_CHARACTER_INDIVIDUALITY_ADDENDUM.md`;
- `docs/source/G4-02R1_FIXED_T0_MULTI_ENTRY_CHARACTER_BINDING_CLARIFICATION.md`;
- `docs/source/G4-02R1_REAL_ASSET_V0_2_R2_MIGRATION_SPEC.md`;
- `docs/source/G4-02R1_HAN_FAMILY_JOINT_FULL_FIDELITY_AUDIT.md`;
- `docs/source/G4-02R1_AFTERGLOW_FAMILY_JOINT_FULL_FIDELITY_AUDIT.md`;
- `docs/source/G4-02R1_CROSS_FAMILY_PACKAGE_SHAPE_STABILITY_DECISION.md`.

`docs/source/G4-02R1_REAL_ASSET_V0_2_MIGRATION_SPEC.md` is superseded r1 design evidence only.

Before authoritative writes, revalidate `main`; never overwrite unknown dirty/newer work.

---

## 2. Current phase / active task

Completed:

```text
G1 Foundation                         PASS / CLOSED
G2 AI Conversation Spine              PASS / CLOSED
G3 Persistence / Save / Timeline      PASS / CLOSED
G4-01 Application Shell / Lifecycle  PASS / CLOSED
G4-02 original v0.1 engineering       HISTORICAL PASS
G4-02R1 Source semantic re-audit      PASS / CLOSED
G4-03 Managed Local Source Library    PASS / CLOSED
G4-04 Multi-Game / Game Library       PASS / CLOSED
```

Current parent:

> **G4-05 — Asset-only New Game Wizard**

Current active execution task:

> **G4-05R2 — Full-Fidelity New Game Wizard Closure**

Formal packet:

`docs/tasks/G4-05R2_FULL_FIDELITY_WIZARD_CLOSURE_TASK.md`

Packet commit:

`c0d8df812511745119d1e9ac8c14283b4c2bd5de`

Formal Code Base:

`1d8278f9a4bc33a748eb6444873af85d27d5a755`

Governance Base:

`32e7357d2eb86b6788d1a429b0dd97f2ba4a2caa`

Primary execution owner: **Kimi**.  
Task nature: **frontend / UI / interaction integration**.  
Independent Review owner after return: **GPT**.

Return ceiling:

> **READY FOR INDEPENDENT REVIEW**

G4-06 Atomic Final Create and later work remain **HOLD**.

Historical packets:

- `docs/tasks/G4-05R1_REAL_ASSET_FIDELITY_CORRECTION_TASK.md` = **SUPERSEDED / DO NOT EXECUTE**;
- `docs/tasks/G4-05_ASSET_ONLY_NEW_GAME_WIZARD_TASK.md` = historical implementation reference only; its obsolete v0.1 conversion instructions are not a current task.

---

## 3. Execution ownership split

Formal project routing:

```text
GPT        → Meaning / architecture / governance / task shaping / Independent Review
Codex      → backend / mechanism implementation
Kimi       → frontend / UI / interaction implementation
Grok Build → search / external research / evidence discovery
```

Kimi may receive explicit backend fallback scope in a separate packet when appropriate, but **G4-05R2 does not grant that fallback by default**.

For G4-05R2, Kimi owns only the player-facing Wizard integration and related UI tests/evidence.

Primary production scope:

```text
src/ui/新游戏向导.gd
src/ui/新游戏向导.tscn
```

Narrow shell/UI wiring may be changed if required:

```text
src/应用壳.gd
src/main.tscn
```

Backend production areas are protected in this task:

```text
src/source/**
src/建局/**
src/persistence/**
src/runtime/**
src/provider/**
```

If a concrete frontend integration test exposes a real backend defect, do not silently repair or redesign those areas. Return:

> **BLOCKED — BACKEND DEFECT**

with exact reproduction and implicated seam. GPT will route the backend correction to the appropriate agent.

---

## 4. G4-02R1 closure truth

G4-02R1 is closed. Do not reopen it without new P0 evidence or explicit Owner/product decision.

Accepted implementation/evidence chain:

- Source v0.2-r2 mechanism: `eb11655f8ff592ae096915fab50553708c0b79df`;
- mechanism evidence: `3b2c9d5fa0a9756ee670eb42179b5ae8359e0b2b`;
- IR01 tests: `b6f83851758a79dff2a24f621befdebdcc21c940`;
- final IR01 evidence / accepted implementation HEAD: `1d8278f9a4bc33a748eb6444873af85d27d5a755`.

GPT final Independent Review found no blocking production defect.

Confirmed current Source behavior includes:

- real 2 World + 6 Character v0.2 full-fidelity load;
- exact World Entry / Character T0 projection when temporal scope exists;
- no latest / nearest / later / complete-life fallback;
- Han closed temporal coverage including 孙权 280 incompatibility;
- optional temporal scope: ordinary rich Character may omit `t0_profiles`;
- World Entries may be scenario/opening choices without historical partitioning;
- no global temporal/historical mode switch;
- cross-world zero coverage is not an invented family hard block;
- exact fingerprint covers all declared bytes, including unselected/private content;
- missing/tampered rich files fail loud;
- optional portrait absence remains honest.

---

## 5. Frozen Source v0.2-r2 semantics

Core shape:

```text
thin identity / catalog metadata
+ ordered rich semantic_sections
+ disclosure = gm_reference | gm_private
+ package-local UTF-8 Markdown/TXT
+ World Entry-scoped sections only when authored need exists
+ optional Character T0 profiles only when authored need exists
+ exact immutable fingerprint over all declared bytes
```

### Optional temporal capability

> **Temporal Quarantine is an optional Source capability selected by authored need, not a universal asset mode.**

The game supports both:

```text
Temporal-scoped Source
→ multiple authored temporal cuts
→ exact selected projection / future quarantine

Non-temporal Source
→ complete rich top-level starting semantics
→ no artificial T0 profile matrix
```

Do not add a global `historical`, `temporal_mode`, `requires_quarantine`, family classification or equivalent hard switch.

World Entries may exist for scenario/opening/location choice without implying historical quarantine.

When temporal scope is used:

```text
World temporal projection
= top-level always-safe sections
+ exact selected Entry sections

Character temporal projection
= top-level always-safe sections
+ exact matching T0 profile sections
```

Never fallback to latest / nearest / later / complete-life biography.

---

## 6. G4-05R2 product/UI requirements

The existing Wizard mechanics remain provisional accepted backend evidence. G4-05R2 must rebase the player-facing reality path onto the current frozen v0.2 fixtures under:

`tests/fixtures/g4_02r1/full_fidelity/`

Primary required changes/evidence:

- stop using old G4-05 v0.1 conversion fixtures as the primary Wizard reality path;
- show Source v0.2 `catalog_summary` in World/Character chooser surfaces;
- generic player-facing opening UI must not universally say `T0`;
- historical Entry names may naturally show authored years/history;
- Guaranteed NPC wording must not imply opening appearance, same scene, player knowledge or current relationship;
- temporal incompatibility must be explained in plain player language, while backend remains authoritative and no fallback is introduced;
- prove a compatible Han route reaches Review;
- prove a real incompatible Han route fails Review clearly and non-destructively;
- prove Afterglow/non-temporal-compatible behavior is not forced into historical restrictions;
- preserve responsive, keyboard and layout behavior;
- Final Create stays disabled / next-stage only.

Do not turn the Wizard into a Source editor, Creator, historical generation picker or generic settings framework.

---

## 7. Preserved G4-05 backend invariants

These must stay green:

- chooser visibility/focus != selection;
- explicit click selects exact generation;
- composition pins exact generation identity;
- selected X does not drift to newer current Y;
- World change clears dependent Entry;
- Player eligibility;
- exact same Character cannot be Player + Guaranteed NPC;
- Review exact re-resolve + tamper/missing fail-loud;
- no same-family restriction;
- Expansion remains honest none-only;
- Wizard→Review creates no Game SQLite;
- Wizard→Review does not mutate Game Library;
- Wizard→Review makes no Provider call;
- Cancel returns Main Menu / no Session.

If these fail because of a backend production defect, return the boundary finding instead of broadening Kimi's scope.

---

## 8. Multi-Game / creation boundary

G4-04 remains frozen:

> **One Game = One SQLite.**

G4-05 is still composition/review only.

It must not create:

```text
Game identity
per-Game SQLite
Game Library record/current
Source materialization/pins
Game-local canonical World/Characters
Timeline/Save/Conversation
Provider request
Session runtime
```

Those are G4-06+ responsibilities.

---

## 9. First-generation product path

```text
Main Menu
→ New Game
→ exactly 1 World Pack
→ optional opening Entry
→ Expansion none in current vertical
→ exactly 1 Player Character Card
→ 0..N Guaranteed NPC Character Cards
→ minimal settings
→ Compatibility Review
→ Atomic Final Create (G4-06, not current task)
→ Game-local Reality
→ real AI GM Opening
```

G4-07 remains the first complete World+Character product UAT.

---

## 10. Technical baseline

```text
Host              Godot 4.7.2 Standard / non-.NET Windows x64
Language          GDScript
Runtime           same-process Godot Runtime
Provider          DeepSeek deepseek-v4-pro
Persistence       SQLite via godot-sqlite v4.9
Production schema v4
Game topology     One Game = One SQLite
Source Library    managed immutable filesystem generations
```

Routine Git/Godot/build/test/layout/screenshot evidence belongs to the execution agent. Owner handles irreducible product decisions and later real UAT. Engineering PASS does not equal Product PASS.
