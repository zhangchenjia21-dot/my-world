# MW-002 Independent Review IR#2

Status: **ENGINEERING PASS / CLOSED**  
Work Item: **MW-002 — Selective World Evolution Evaluator**  
Capability Anchor: **G5-04**  
Reviewed Revision: **2**  
Review Round: **IR#2**  
Triggered-By: **MW-002 IR#1**  
Reviewer: GPT  
Date: 2026-09-04

## 1. Freshness / reviewed range

Authoritative heads refreshed before review:

- `my-world/main`: `001106f2c790e70935ea4e54eb721b4aef9e07b4`
- `Vibe-Coding/main`: `fd7f86d62537ed1a8afc95edcbeae472c647a31f`

Revision-2 reviewer-propagated start head:

- `d4332dd4233fd90a3dbbae382ba199c5fedc2535`

Kimi Revision-2 commits:

- implementation: `5459c4f8a1d92928129c1d3217a40c6622522496`
- evidence: `001106f2c790e70935ea4e54eb721b4aef9e07b4`

Actual compare from `d4332dd4…` to `001106f2…` is exactly 2 commits / 5 files:

1. `src/应用壳.gd`
2. `src/世界回合/L2_流程层/行动代理调度流程.gd`
3. `src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd`
4. `tests/g5_04/选择性世界演化评估测试.gd`
5. `docs/g5_04/MW-002_SELECTIVE_WORLD_EVOLUTION_EVIDENCE.md`

This matches the bounded IR#1 correction scope. No Public-d20 implementation/View edit, UI, SQLite schema/table/migration, Faction platform, pressure/priority platform, random-event engine, offline simulation or G5-05 work was introduced.

## 2. IR#1 correction findings

### F01 — Public-d20 foreground authority gap

**PASS**

Production Application composition now connects the existing Public-d20 adjudication `request_assembled(stage, messages)` signal and invalidates both:

- `agency_scheduler.invalidate_remaining()`;
- `world_evolution_evaluator.invalidate()`.

Direct inspection of `公开D20行动判定流程.gd` confirms `request_assembled` is emitted inside `_start_provider()` **before** `provider_adapter.start_stream(messages)` and, for the initial control stage, before any later Conversation attempt is created. Therefore the Player foreground wins at the actual d20 action-request boundary instead of waiting for `Conversation.attempt_started`.

The change is composition-only. Public-d20 mechanics, control protocol, dice ownership, Narrative acceptance and UI remain untouched.

Focused production proof uses the real Shell + mounted d20 capability: active World Evolution → second Player d20 control starts → evaluator is synchronously cancelled → late evolution completion commits nothing and head remains unchanged.

### F02 — Agency `already_committed` immediate terminal

**PASS**

Scheduler now handles `AgencyCycle.start_cycle()` returning `status=already_committed` as a true immediate terminal:

- clears `agency_cycle_runtime`;
- detaches/frees the cycle node;
- sends no actor request;
- emits terminal `selector_finished`;
- emits exactly one `opportunity_finished` with the frozen turn/hash through the existing helper;
- returns without waiting for a `cycle_finished` signal that will never occur.

The ordinary cycle-completion path remains unchanged. The focused proof pre-seeds all selected actor actions as durable, verifies one World Evolution wake, then verifies a later fresh dirty opportunity starts and terminates normally. No dirty-consumption, selector-cap, actor-concurrency or retry semantics were changed.

### F03 — True World-only T0 baseline

**PASS**

`project_world_only()` no longer reuses the general `_append_game()` block. It now uses a neutral Game-local authority header containing only Game ID + Selected Entry, then projects frozen World material through the existing World projector.

The evaluator baseline therefore excludes:

- `opening_supplement`;
- protagonist `control_mode`;
- Game display-name/settings material;
- Player/Character material;
- Actor Knowledge Provenance.

It retains exact selected Entry material, World identity/provenance, world instructions, GM instructions and World semantic sections. Existing bounded-context fail-soft behavior and no-mutable-Source-current boundary remain unchanged.

Focused privacy proof uses explicit nonempty `PRIVATE_OPENING_SUPPLEMENT_MARKER` / `PRIVATE_CONTROL_MODE_MARKER` and confirms both are absent while World/Entry markers remain present.

### F04 — Active evaluator → production Restore proof

**PASS**

Revision 2 adds the missing production Shell path:

```text
baseline Save
→ ordinary turn reaches active World Evolution request
→ production restore_save_point
→ restore_completed invalidates evaluator
→ restored head/world are authoritative
→ no extra Agency-opportunity/evolution wake appears
→ simulated late evaluator completion
→ zero event commit and restored head remains unchanged
```

The proof also verifies Scheduler is not stranded after Restore.

## 3. Preserved MW-002 architecture

IR#2 found no regression in the Revision-1 behavior already accepted in principle:

- dedicated World Evolution evaluation only after the whole Agency opportunity is terminal;
- `hold` is first-class and creates no fake mutation;
- at most one world event per opportunity;
- model owns open priority judgment, not Program scores/keywords/cadence;
- bounded raw-string response parser and fail-soft invalid/provider outcomes;
- deterministic Program-owned world-event / mutation / node identities;
- additive `living_world.v0.1`, no SQLite schema change;
- committed-event replay idempotence;
- exact accepted turn/hash currentness;
- foreground / Restore / unrelated-head invalidation before commit;
- next GM continuation Context is the first real consumer;
- event truth is omniscient GM world truth, not automatic Player or actor knowledge;
- no automatic G5-02 Knowledge creation;
- no Actor Knowledge Provenance in world-causal evaluator input;
- no mutable Source Library current lookup;
- intentional stable-NPC action remains G5-03 Agency territory;
- no generic Faction platform / universal simulator / event ontology / offline evolution.

## 4. Committed validation evidence

Kimi's Revision-2 evidence reports:

- G5-04 focused: **144 PASS / 0 FAIL**;
- G5-03 Scheduler/Cycle regression: **0 FAIL**;
- G4-08M1 Public-d20 regression: **0 FAIL**;
- G4-07A continuation/context regression: **0 FAIL**;
- G3-04 Save/Restore regression: **PASS**;
- `git diff --check`: clean;
- real Provider calls: **0**.

The reviewed final commit has no external combined CI statuses.

Reviewer environment check found no `godot4` or `godot` executable, so GPT did not independently rerun the Godot commands. IR#2 is based on direct inspection of the actual correction diff, production seams, test source and committed deterministic evidence. This limitation is recorded explicitly and does not alter the verdict.

## 5. Engineering verdict

**MW-002 Revision 2 = ENGINEERING PASS / CLOSED.**

IR#1 F01–F04 are closed. No additional engineering correction is required before Product UAT.

This verdict closes the executable Work Item only. It does **not** close parent capability G5-04.

## 6. Owner UAT handoff

G5-04 remains **ACTIVE — OWNER UAT** because world-evolution pacing is a product-quality claim that deterministic tests cannot prove.

Owner UAT must counterpose at least two situations:

### A. Quiet / Life Loop

Use a situation where no world process is causally ripe.

Expected:

- World Evolution may genuinely `hold`;
- no event is manufactured merely because a turn completed;
- ordinary life / relationships / free activity retain breathing room.

### B. Genuine ripe world pressure

Use a T0 or accumulated world pressure that should mature independently of direct Player causation.

Expected:

- one credible world consequence may advance;
- it is durable;
- subsequent GM Narrative can use/surface it naturally when scene/information/pacing make sense;
- it does not feel like a forced random encounter or constant escalation.

Only the Owner may issue Product PASS and close G5-04. Until then do not enter G5-05.