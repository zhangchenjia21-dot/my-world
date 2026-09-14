# TASK｜MW-035｜G7 Public d20 Control Working-Set Currentness v0.1

Type: implementation  
Owner: Codex  
Capability-Anchor: G7 Package 8｜Long-session currentness / latency reality hardening  
Revision: 1  
Review-Round: 0  
Formal Code Base: `0066b587f1d756b55ee18abfa5f473e78a3aeea2`  
Required branch: `mw-035-g7-d20-control-working-set`  
Required worktree: `D:/AI/Projects/.worktrees/my-world/mw-035-g7-d20-control-working-set`  
Frozen architecture: `Vibe-Coding/my world/architecture/G7_PUBLIC_D20_CONTROL_WORKING_SET_V0_1_DECISION.md@v0.1`  
Supporting frozen gate: `Vibe-Coding/my world/architecture/G7_STRUCTURED_OUTPUT_RECOVERY_ABSTRACTION_GATE_V1_0_DECISION.md@v1.0`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Product outcome

Public d20 `control` / `control_recovery` must judge long-session actions from the **current** Character, World, Inventory and Public mechanics instead of depending mainly on full New-Game/T0 context plus an old fixed recent transcript.

The player-facing result is not a new screen. It is that a check many turns into a Game still sees capabilities/world conditions that remain current even after their originating conversation has become old.

Use current model capacity to bound the final control request so large T0 source/NPC material becomes optional background rather than an always-sent monolith.

## 2. Why now

MW-033 fixed Narrative continuation working-set currentness and capacity. MW-034 hardened Information Curator recovery. Post-MW-034 audit rejected a generic retry framework and found the next real Package-8 defect in Public d20 control:

```text
control today
→ full Game-local Opening-era projector
→ Expansion rules + Inventory
→ historical fixed recent Conversation assembly
```

The path keeps broad T0 Character/NPC/source material but does not make current Character or current World/Knowledge/Agency/Evolution first-class control context.

This can produce stale mechanics adjudication in long games and repeatedly sends more source material than current control needs.

## 3. Authority / Source Manifest

Authority order:

1. Owner current explicit instruction.
2. `Vibe-Coding/AGENTS.md` and current Owner collaboration rules.
3. current Product / Principles / Architecture / Roadmap / Current Status under `Vibe-Coding/my world/`.
4. frozen `G7_PUBLIC_D20_CONTROL_WORKING_SET_V0_1_DECISION.md@v0.1`.
5. frozen `G7_STRUCTURED_OUTPUT_RECOVERY_ABSTRACTION_GATE_V1_0_DECISION.md@v1.0`.
6. this Task Packet.
7. implementation/tests at Formal Code Base.

Not authoritative unless explicitly referenced:

- archived/legacy docs;
- stale phase summary in implementation `AGENTS.md` where superseded by current governance;
- historical chat/model memory.

Before edits refresh:

- `my-world/main`;
- `mw-035-g7-d20-control-working-set`;
- `Vibe-Coding/main`.

STOP on relevant implementation/governance drift.

## 4. Read first

Initial working set:

1. repo `AGENTS.md`;
2. this Task Packet;
3. frozen MW-035 architecture decision;
4. `src/行动判定/L2_流程层/公开D20行动判定流程.gd`;
5. `src/context/L3_外交层/上下文组装公开接口.gd` + `src/context/上下文组装器.gd` only as needed for existing selector contract;
6. `src/首次开场/L3_外交层/续玩来源上下文公开接口.gd` / continuation source projector;
7. existing L3 current projections for Character, World-turn, Inventory, Public mechanics plus directly affected d20 tests.

Only expand reading if this evidence is insufficient, and state why.

## 5. Frozen invariants

### INV-01｜Control consumer only

Change context composition for:

- `control`;
- `control_recovery`.

Do not change First Opening or d20 Narrative stage context behavior. `resolution_narrative`, `no_check_narrative`, and `degraded_narrative` continue using MW-033 Narrative working-set assembly.

### INV-02｜No second Context platform

Reuse the existing Context structural selector / capacity accounting where semantically valid.

A narrow mechanics-consumer composition seam is allowed.

Do not build:

- all-agent Context orchestration;
- generic memory/retrieval platform;
- another independent budget engine if the existing selector can express the required tiers.

### INV-03｜P0 required control material

P0 contains whole, required material:

1. mechanics-control schema/protocol;
2. active Player action exactly once;
3. exact materialized Expansion mechanics rules;
4. minimum Game/World identity + World instructions + GM instructions;
5. exact selected Entry identity when present;
6. recovery correction cue only in `control_recovery`.

If final messages containing P0 exceed the current safe input budget, fail loud **before Provider start**.

Do not silently truncate or omit required Expansion rules.

### INV-04｜P1 current continuity

Control should preferentially receive:

1. latest complete accepted Conversation Turn;
2. current Character safe projection;
3. current/hash-bound World / Knowledge / Agency / Evolution projection;
4. factual current Inventory projection;
5. current Public mechanics context/history;
6. remaining recent complete accepted Conversation Turns while budget remains.

Current Character is a derived continuity snapshot, not a new mechanics truth. It cannot overwrite durable Public d20 truth, factual Inventory or accepted/current World facts.

### INV-05｜P2 starting background

Exact frozen Game-local background may enter as whole P2 blocks when capacity permits:

- Opening supplement;
- selected Entry opening seed;
- T0 World source/semantic sections;
- Player Character source sections;
- Guaranteed NPC source sections.

Treat this as starting reference/inertia, not current lived state.

No semantic importance ranking, keyword selection, NPC-name matching, embedding retrieval or model retrieval.

### INV-06｜Style excluded

`literary_style_reference` must never enter `control` or `control_recovery`.

Use explicit style-canary tests.

### INV-07｜Current Character through canonical projection

Do not read raw `information_curation` storage from d20.

Use an existing stable L3 safe/current projection, or create only a narrow reusable projection seam if needed.

UI hide/recover preferences must not affect mechanics context.

Do not include internal IDs/request refs merely to feed mechanics.

If current Character is unavailable, do not fabricate it; continue only from other legitimate current/source material according to the tier policy.

### INV-08｜Current World through canonical projection

Reuse the current/hash-bound World-turn context owner.

No raw whole `world_state` and no stale/displaced branch records.

Restore/Regenerate must exclude superseded World/Knowledge/Agency/Evolution material from later control requests.

### INV-09｜Inventory and mechanics owners remain authoritative

Use factual Inventory and Public mechanics L3 projections.

Context may select their text but does not mutate or reinterpret them.

### INV-10｜Budget is real runtime capacity

Use validated model capacity.

```text
safe control input bytes = floor(context_token_ceiling × 0.80)
```

Known expected values:

- 256k → `209715` bytes;
- 1m → `838860` bytes.

Count final serialized Provider `messages` UTF-8 bytes.

No hardcoded fallback capacity if runtime settings fail validation.

### INV-11｜Whole-block selection

Never partially truncate:

- accepted Turn pair;
- Expansion rule block;
- source semantic section;
- NPC source section/card block;
- Opening supplement;
- Entry opening seed;
- current Character/World/Inventory/mechanics block.

Optional material that cannot fit is omitted whole with safe diagnostics.

### INV-12｜Conversation identity/currentness

- current Player action appears exactly once;
- durable accepted entries only;
- no failed/cancelled attempt;
- no displaced future;
- GM-only Opening keeps no-fake-user-message semantics;
- retained Turns render chronologically even if newest is selected first for fit.

Do not preserve the old fixed recent-12 window as the actual control authority.

### INV-13｜d20 semantics unchanged

Do not change:

- CHECK_REQUIRED / NO_CHECK schema;
- parser strictness;
- DC/modifier/stance contract;
- RNG timing;
- durable check/NO_CHECK identity;
- same-action replay/dedup;
- narrative accepted marker/recovery;
- System/Public mechanics projection;
- semantic grounding from durable Mechanical Resolution.

No second mechanics truth in Context.

### INV-14｜Recovery semantics unchanged

Existing control policy stays:

```text
attempt 1 parse invalid
→ exactly one control_recovery
→ second parse invalid
→ degraded ordinary Narrative, no fake check
```

MW-035 does not add Provider-failure retry or timeout retry.

`control_recovery` must rebuild bounded current request material, not reuse a persisted messages blob.

### INV-15｜No Narrative output limit

Do not add `max_tokens` or any Narrative conciseness limit.

Control input budgeting is independent of later Narrative generation length.

## 6. Recommended implementation direction

Prefer a narrow flow equivalent to:

```text
_d20_control_messages(stage)
→ runtime budget metadata
→ continuation source blocks
→ filter style
→ P0: minimum source identity/instructions + Expansion rules + control contract
→ P1: Character + World-turn + Inventory + Public mechanics
→ P2: remaining source/NPC background
→ existing Context structural selector with active Player attempt
→ final messages + safe context stats
```

Do not blindly call Narrative `assemble_session()` because Narrative intentionally includes families (Threads/Experiences/People/style) that are not part of the frozen mechanics-control v0.1 set.

It is acceptable to add one dedicated `assemble_mechanics_control...` seam in the existing Context L3 owner if that keeps selection/budget logic single-sourced.

Do not create a new general `ContextOrchestratorBase`, DI layer, strategy framework or schema DSL.

## 7. Context family policy

### Include dedicated current families

- `character` — P1;
- `world` — P1;
- `inventory` — P1;
- `mechanics` — P1;
- `conversation` — P1;
- `source` / `npc_source` — P2 except minimum Game/World identity/instructions block which is P0.

### Do not add dedicated mechanics blocks for

- `experiences`;
- `people`;
- `threads`;
- `style`.

Experiences/People/Threads remain available only indirectly if represented in accepted/current causal material. Do not create extra semantic filters to recover them.

## 8. Diagnostics

Expose/store safe request-local control context stats sufficient for Independent Review:

- stage: control / control_recovery;
- profile/context limit/token ceiling;
- safe input byte budget;
- final serialized message bytes;
- considered/included/omitted counts + bytes by family;
- selected accepted Turn count/range;
- whether current Character/World/Inventory/mechanics were included;
- source / npc_source budget omission;
- assembly latency.

Do not expose raw Player/GM prose, source/NPC text, request refs, durable IDs, private actor material, API secrets or full World.

Existing d20 timing evidence remains intact.

## 9. Focused acceptance

Create `tests/mw035/` or equivalent production-path vertical.

At minimum prove:

### AC-01 Long-session Character currentness

Build >12 accepted-turn history where a durable/current Character capability is no longer present in the recent source prose. A new d20 control request still contains the current Character block/capability.

### AC-02 Long-session World currentness

Current accepted-hash World/Knowledge/Agency/Evolution material whose originating prose is old still enters control through the current World owner.

### AC-03 Current Inventory

Current factual Inventory enters control independent of old transcript/source background.

### AC-04 Public mechanics

Current Public mechanics context/history enters control from its owner.

### AC-05 256k large-T0 protection

With large T0 source/NPC/opening background, 256k control still includes P0 + current P1 while optional P2 is omitted whole.

### AC-06 1m admits more P2

Same fixture at 1m admits more whole P2 material than 256k where capacity permits.

### AC-07 Exact final-byte bound

Every successful control and control_recovery request has final serialized message bytes `<= safe_input_bytes`.

### AC-08 P0 overflow

Oversized required Expansion rules or minimum required instructions produce:

- fail-loud control result;
- zero Provider start;
- zero RNG roll;
- zero durable mechanics mutation.

### AC-09 Atomic omission

Prove no partial accepted Turn/source section/NPC section/opening supplement/seed.

### AC-10 Style exclusion

A distinctive literary-style canary is absent from control and control_recovery under both capacity profiles.

### AC-11 Active action once

Current Player action appears exactly once in final messages.

### AC-12 Restore/Regenerate currentness

Displaced Conversation/World material cannot enter a later control request.

### AC-13 Recovery assembly

Attempt-1 malformed control leads to exactly one control_recovery request using the same capacity-aware assembly and current owners.

### AC-14 Second malformed degrades

Second malformed control still starts ordinary degraded Narrative and creates no d20 result.

### AC-15 CHECK path unchanged

Valid CHECK_REQUIRED:

- parser succeeds;
- RNG first touched only after valid control;
- check persists once;
- Narrative stage remains MW-033 working-set consumer;
- replay does not reroll.

### AC-16 NO_CHECK path unchanged

NO_CHECK durable resolution/reopen/replay remains unchanged.

### AC-17 Narrative stages unchanged

Capture `resolution_narrative`, `no_check_narrative`, `degraded_narrative` and prove they still use the existing Narrative working-set path and its context-budget behavior.

### AC-18 Diagnostic safety

Context stats contain no raw source/Player/GM/private payload.

## 10. Regression gate

At minimum rerun current suites covering:

- Public d20 control CHECK / NO_CHECK / degraded path;
- Public mechanics/System projection;
- MW-033 Narrative working-set focused suite;
- MW-034 Curator focused or directly relevant current-Character regressions;
- Inventory;
- World Context / Knowledge / Agency / Evolution;
- G3 Restore/Regenerate/reopen currentness;
- G4 Opening + continuation;
- MW-032 V0 closure regressions where d20/Narrative integration is exercised.

Any retained failure requires exact-base reproduction.

## 11. Build gate

Before return:

- Godot `4.7.2` final import;
- fresh Windows export;
- `run-game.ps1 -ValidateExportOnly`;
- no Owner build install/launch;
- no Owner real Game / Source / settings / preferences mutation.

Real Provider calls are not required for deterministic Engineering acceptance.

## 12. Explicit non-scope

Do not add:

- shared Structured Output retry framework;
- cross-lane retry base class;
- generic all-agent Context platform;
- embeddings/vector DB/semantic retrieval;
- NPC/person semantic ranking;
- new Character stats or skill-number system;
- Expansion rule DSL;
- Provider/model fallback/routing redesign;
- Narrative output cap;
- UI feature/redesign;
- new persistence table/schema;
- World/Knowledge ownership rewrite;
- Package-9 provenance/epistemic correction.

## 13. Git discipline

- work only on `mw-035-g7-d20-control-working-set` in the required worktree;
- do not overwrite or clean unknown local work;
- do not merge `main`;
- do not force push;
- commit implementation and evidence;
- push task branch;
- pre-return refresh both authoritative mains and task branch;
- STOP on relevant drift.

## 14. Return requirements

Highest return: **READY FOR INDEPENDENT REVIEW**.

Return:

- Starting HEAD;
- Implementation HEAD;
- Final Candidate HEAD;
- remote-tip confirmation;
- exact control context composition/tier implementation;
- 256k/1m final-byte and P2-admission evidence;
- long-session Character/World currentness evidence;
- Inventory/mechanics evidence;
- P0-overflow zero-provider/zero-RNG evidence;
- whole-block/style-exclusion evidence;
- control/control_recovery/degraded CHECK/NO_CHECK evidence;
- Restore/Regenerate evidence;
- safe diagnostics evidence;
- focused totals;
- regression manifest;
- import/export/ValidateExportOnly;
- real Provider call count;
- retained failures/warnings/deviations/risks.

Do not claim Product PASS, Package-8 completion or a generic Context/Structured Output platform.
