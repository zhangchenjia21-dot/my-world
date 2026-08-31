# G4-08S0 — Expansion Pack v0.1 Semantic / Product Freeze

Status: **PASS / CLOSED**  
Parent: **G4-08 Expansion Pack v0.1 + First Real Runtime Vertical**  
Owner: **GPT**

## 1. Result

G4-08S0 is complete.

Canonical semantic decision:

`Vibe-Coding/my world/architecture/source/G4_EXPANSION_V0_1_PUBLIC_D20_DECISION.md`

First real Expansion:

```text
Display Name  判定与检定：公开 d20
asset_id      exp.check_core.public_d20
asset_type    expansion_pack
schema        expansion_pack.v0.1
capability    action_check.public_d20.v1
slot          action_resolution
```

The decision was informed by the historical `the-world` implementation of `判定与检定_Expansion_Pack_v0.1.md`, but only product semantics were carried forward. Historical Node/plugin mechanics are not implementation authority for the current Godot architecture.

## 2. Frozen product semantics

G4-08S0 froze:

- Expansion is optional and selected as `0..N` exact immutable generations;
- Public d20 occupies exclusive `action_resolution` capability slot;
- duplicate exact Expansion / capability-slot conflict fail closed;
- no hidden family/genre/year compatibility guessing;
- three no-roll cases: certainly succeeds / certainly impossible / no meaningful failure cost;
- no natural-1/natural-20 override in v0.1;
- Program owns RNG, total and outcome; model never owns die face;
- Check Proposal risk structure freezes before RNG;
- no-check ordinary turn does not require a second Provider call;
- real check uses conditional second Provider continuation after durable Program result;
- same action retry/restart never rerolls;
- Expansion owns resolution, not downstream World/Character/etc. consequences;
- no-Expansion route remains the accepted G4-07 behavior.

## 3. Minimal Expansion v0.1 package

```text
<package-root>/
├─ source.json
└─ sections/
   └─ rules.md
```

Minimum semantic fields:

```text
schema_version
asset_id
asset_type
version
display_name
catalog_summary
capability_binding
semantic_sections
```

Expansion Source declares authored semantics and a Host-known capability binding. It does not contain executable GDScript/plugin code or live Game state.

## 4. Runtime boundary

The first Program-owned capability is:

`action_check.public_d20.v1`

Required flow:

```text
Player action
→ structured adjudication
→ NO_CHECK + normal narrative

or

Player action
→ CHECK_REQUIRED + frozen Proposal
→ Program RNG
→ durable result
→ second Provider continuation constrained by result
```

The model cannot see the random result before Proposal freeze.

## 5. Persistence / Context

Each real check has stable `check_id` bound to stable Player action identity and durably records Proposal + Program result.

Provider/network failure after a roll must reuse the exact prior roll and outcome.

Historical check records are audit/provenance evidence. Normal future Context should primarily carry resulting canonical world consequences rather than dump all prior check logs.

## 6. UI decision

G4-08 first generation uses automatic Program rolling; no player click-to-roll interaction is required.

A later Kimi task will render player-visible Expansion selection/Review and a lightweight mechanic card from UI-neutral Program-owned resolution data. UI does not own or recompute dice truth.

## 7. Next task

Active mechanism packet:

`docs/tasks/G4-08M1_PUBLIC_D20_EXPANSION_MECHANISM_TASK.md`

Owner: **Codex**  
Reviewer: **GPT**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

G4-08S0 itself does not declare G4-08 PASS.