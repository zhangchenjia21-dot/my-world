# G4-08M1 — Public d20 Expansion Mechanism

Status: **ACTIVE — CODEX**  
Parent: **G4-08 Expansion Pack v0.1 + First Real Runtime Vertical**  
Semantic prerequisite: **G4-08S0 PASS / CLOSED**  
Primary owner: **Codex**  
Reviewer: **GPT**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Formal Code Base:

`3b5cd80a26091a17d61c5a055637a422a9edb3aa`

Canonical semantic authority:

`Vibe-Coding/my world/architecture/source/G4_EXPANSION_V0_1_PUBLIC_D20_DECISION.md`

## 1. Purpose

Implement the first real Expansion mechanism without widening G4 into a generic plugin/rules platform.

The selected real Expansion is:

```text
Display Name  判定与检定：公开 d20
asset_id      exp.check_core.public_d20
asset_type    expansion_pack
schema        expansion_pack.v0.1
capability    action_check.public_d20.v1
slot          action_resolution
```

M1 must prove the backend/runtime chain:

```text
exact Expansion Source
→ Managed Source Library
→ exact Composition selection
→ Compatibility
→ Atomic Final Create materialization
→ Program-owned capability binding
→ Player action adjudication
→ freeze before RNG
→ Program RNG
→ durable check resolution
→ real Provider continuation
→ restart / Continue same result
```

M1 does **not** own visual UI. After M1 IR, GPT will issue a separate Kimi integration task for Wizard Expansion selection / Review / mechanic-card rendering.

---

## 2. Frozen semantics — do not redesign

### 2.1 Optional Expansion

- Expansion selection is explicit `0..N` exact generations.
- No Expansion means current G4-07 runtime behavior remains unchanged.
- Never silently enable Public d20.

### 2.2 Exclusive capability slot

Public d20 declares:

```text
capability_id   = action_check.public_d20.v1
capability_slot = action_resolution
```

Rules:

- duplicate exact Expansion selection → fail closed;
- two selected Expansions occupying the same `capability_slot` → fail closed;
- no hidden family/genre/year guessing;
- no dependency/version solver in this task.

### 2.3 Three no-roll cases

Do not roll when the attempt is:

1. certainly successful under established facts;
2. certainly impossible under established facts/personality/causality;
3. repeatable immediately with no meaningful failure cost.

Dice decides uncertainty; it never erases durable reality or Character identity.

### 2.4 Public d20

```text
d20 + modifier = total

total >= DC → success
total <  DC → failure
```

No natural-1/natural-20 override.

Standard DC guidance: 10 / 15 / 20 / 25 / 30.  
Program must enforce a bounded integer range; choose the narrowest range consistent with the semantic decision and record it in evidence.

Suggested Character modifier scale: +0 / +2 / +4 / +6, derived from current Character/Game-local facts. Program may enforce a safety bound but must not invent a generic Attribute system.

Stance:

```text
normal        1d20
advantage     2d20 take high
disadvantage  2d20 take low
```

Advantage + disadvantage cancel to normal. No stacking tiers.

---

## 3. Source contract / Managed Library

Extend the existing Source architecture; do not create a parallel Expansion store.

Current main only supports World/Character in:

- `src/source/L0_公理层/Source合同规则.gd`
- `src/source/L0_公理层/Source库规则.gd`
- `src/source/L3_外交层/Source库公开接口.gd`

Add `expansion_pack.v0.1` as a first-class third type through the same layered contract / publication / exact-generation machinery.

Minimum Expansion v0.1 fields:

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

`capability_binding` must be strictly validated and contain safe tokens for:

```text
capability_id
capability_slot
```

For the first real package these are exactly:

```text
action_check.public_d20.v1
action_resolution
```

Requirements:

- package-local semantic section bytes participate in exact fingerprint;
- current/exact lookup re-validates managed bytes;
- immutable generation/current semantics stay unchanged;
- Source live-state field prohibition remains recursive;
- no executable code/file declaration in Expansion v0.1;
- unknown fields fail closed according to existing Source contract style.

Public API must support equivalent first-class methods, e.g.:

```text
install_expansion_pack
get_current_expansion
get_exact_expansion
list_current_sources includes expansion
```

Naming may follow repository conventions, but do not hide Expansion behind Character/World fallback branches.

### Real package fixture

Create one full-fidelity package for integration evidence under task-owned repo fixtures, using the frozen identity above and a package-local `rules.md` faithfully expressing the canonical Public d20 semantics.

Do not copy executable code from the historical `the-world` repository. Historical material is semantic reference only.

---

## 4. Composition / Compatibility backend

Extend Game Creation Composition backend to represent `0..N` exact Expansion identities.

M1 may exercise this programmatically/headlessly; **do not modify Wizard UI in this task**.

Must prove:

- zero Expansion is valid;
- one Public d20 exact generation is valid;
- duplicate exact generation rejected;
- same capability slot collision rejected;
- ordering is deterministic and does not create identity ambiguity;
- changing selected Expansion set changes the frozen Composition payload / creation intent identity;
- no mutable `SourceLibrary.current` lookup after the Composition has pinned exact generations.

Compatibility errors must be explicit and reviewable, not silently drop one Expansion.

---

## 5. Atomic Final Create / materialization

Extend the existing G4-06 Final Create path; do not create Games from the Wizard or from Expansion code.

For each selected Expansion, Game-local created state must preserve at least:

```text
exact source identity / generation fingerprint
materialized authored rules needed by runtime
capability_id
capability_slot
```

Requirements:

- Provider calls during Final Create remain **0**;
- same `creation_id` + same payload remains replay-safe / same Game;
- same `creation_id` + changed Expansion selection conflicts;
- later Source Library update cannot alter an existing Game;
- no-Expansion Games remain valid and readable;
- Source package receives no runtime writeback.

If persistence schema must change from v4, use the smallest reviewed migration necessary, preserve all prior Games, and include upgrade/open evidence. Do not create an Expansion-specific second database.

---

## 6. Host capability registry

Implement a narrow Program-owned binding seam for selected materialized capabilities.

G4-08 only needs:

```text
action_check.public_d20.v1
```

Unknown capability id must fail loud at the appropriate materialization/open boundary; do not interpret Source prose as arbitrary executable behavior.

Do not build:

- generic scripting runtime;
- dynamic GDScript loading;
- plugin sandbox;
- generic event bus/DI forest;
- universal rules engine.

Keep the seam sufficient for later distinct capabilities, but only one implementation exists now.

---

## 7. Player-turn adjudication protocol

Public d20 changes the Player continuation pipeline only when the Game has the selected capability.

### 7.1 Stable action identity

Every submitted Player action that may reach adjudication needs a stable action identity sufficient to make Provider failure/retry/restart idempotent.

Do not rely on matching raw text alone if the existing Conversation/runtime can provide a stronger stable identity.

### 7.2 Structured adjudication envelope

Provider output for the adjudication stage must be Program-parseable and strictly validated. Do not regex DC/modifier out of prose.

Semantically the envelope has exactly two branches:

```text
NO_CHECK
```

or

```text
CHECK_REQUIRED + Check Proposal
```

#### NO_CHECK

When no roll is required, the same first Provider response must be able to carry the normal GM narrative so a normal turn remains one Provider call.

Do not force every Expansion-enabled turn into two Provider calls.

#### CHECK_REQUIRED

Before RNG, freeze a Proposal containing at least:

```text
action identity
intent
DC
modifier
stance = normal | advantage | disadvantage
modifier reason
situation reason
success intent
failure stakes
```

Validate all required fields/ranges/enums before RNG.

The model must not see the random result before this Proposal is frozen.

After freeze, it is immutable for that check.

---

## 8. Program RNG / computation authority

The model never owns the die face.

Program must generate raw d20 results itself and compute:

```text
selected roll
total
success / failure
```

Required:

- `normal` → one legal d20;
- `advantage` → two legal d20, select high;
- `disadvantage` → two legal d20, select low;
- total computed by Program;
- outcome computed only by Program using frozen DC;
- model-provided fake roll/total/outcome cannot override Program values.

Use an appropriate Godot/OS randomness source. Tests may inject a task-owned deterministic RNG seam for exact assertions, but production authority must not be the model and must not use a constant/test RNG.

---

## 9. Durable check resolution / retry

A real check gets stable `check_id` bound to stable Player action identity.

At minimum durable state/evidence includes:

```text
check_id
action_id
intent
DC
modifier
stance
modifier/situation reasons
success intent
failure stakes
raw_rolls
selected_roll
total
outcome
```

Hard invariant:

> Same Player action retry / process restart must never reroll.

Persistence ordering must ensure the Program-generated resolution is durable **before** the resolution narrative can be accepted as canonical continuation.

Required fault/restart coverage includes at least:

A. Provider fails before a valid proposal → no roll exists; same action can retry adjudication.

B. Proposal frozen, RNG/persist succeeds, second Provider call fails → retry reuses exact Proposal + exact rolls + exact outcome.

C. Process restart after durable resolution but before narrative acceptance → reopen/retry reuses exact result.

D. Duplicate submit/retry cannot create two checks for one stable action.

E. Accepted result narrative must not append the same Player action twice.

Do not create “reroll on network error” behavior.

---

## 10. Resolution continuation / Context

When `CHECK_REQUIRED` is durably resolved, the second Provider call must receive:

```text
current durable Game-local world/character context
+ materialized Public d20 rules needed for adjudication
+ original Player action
+ frozen Check Proposal
+ Program-generated result
```

The GM narrative must be instructed to respect the outcome as already-decided authority.

Do not inject all historical check records every turn.

Historical check events are provenance/audit evidence. Their durable downstream consequences belong to existing/future canonical World/Character/etc. owners.

No-Expansion Game must receive none of the Public d20 rules/protocol/state.

---

## 11. UI-neutral projection seam

M1 does not modify player-facing scenes/styles.

Expose enough stable UI-neutral data for a later Kimi task to render a mechanic card without recomputing truth, including at least:

```text
intent
DC
modifier + reason
stance + reason
raw rolls
selected roll
total
outcome
failure stakes
```

The UI later projects this record; it never rolls, recomputes or edits it.

Do not change `src/ui/**` unless an unavoidable compilation seam requires a tiny non-semantic adaptation; if so, stop and report rather than silently taking UI ownership.

---

## 12. Required evidence

### Evidence A — Source third type

Prove real `expansion_pack.v0.1` load/validate/fingerprint/install/current/exact lookup using the Public d20 fixture.

Also prove semantic section byte change changes fingerprint and old exact generation remains resolvable.

### Evidence B — Compatibility

Prove:

- zero Expansion valid;
- Public d20 valid;
- duplicate exact selection rejected;
- two distinct fixture Expansions claiming `action_resolution` rejected;
- no hidden Han/Afterglow special-case.

The second collision fixture may be minimal/task-only and need not be a product Expansion.

### Evidence C — Final Create

Prove exact Expansion ancestry/capability materializes into the Game and survives fresh-process reopen.

Prove same creation replay behavior remains correct and changed Expansion payload conflicts.

### Evidence D — No-Expansion regression

Run a current G4-07 style Game with no Expansion and prove normal continuation has no adjudication envelope/RNG/check state and remains one normal Provider path.

### Evidence E — Program RNG

With deterministic test RNG only, prove normal/advantage/disadvantage selection, total, outcome and validation boundaries.

Prove model-supplied fake roll/outcome cannot become authority.

### Evidence F — Freeze-before-RNG

Capture exact order/evidence that Proposal validation/freeze occurs before production/test RNG invocation and cannot be changed after roll.

### Evidence G — Retry/restart

Prove fault cases A–E from section 9, especially second Provider failure after a losing roll does not reroll.

### Evidence H — Real DeepSeek / Han

Using real Provider and exact current full-fidelity Han Source, create/open a Game with Public d20 and perform:

1. at least one plausible high-risk Player action that produces `CHECK_REQUIRED`;
2. real Program RNG;
3. real second DeepSeek continuation respecting the Program outcome;
4. a later ordinary action that produces `NO_CHECK` and completes in the single-call path;
5. Save/Main Menu or fresh-process reopen/Continue proving the same check result and resulting reality remain.

Do not force the Provider to roll every action merely to satisfy the test. The risky action should be authored to make uncertainty + stakes naturally present.

### Evidence I — Cross-world Afterglow

Using the same installed Public d20 exact generation, exercise at least one Afterglow/Livia risk action through the same capability seam. It must not contain Han-specific rules in the Host mechanism.

### Evidence J — Regression / security

- existing Source World/Character contract/library tests pass;
- G4-06 Final Create regression passes;
- G4-07A/B focused continuation regression passes;
- no API key/secret output;
- no executable Source code support added;
- no build binary committed;
- `git diff --check` clean.

---

## 13. Non-goals / protected boundaries

Do not implement in M1:

- Wizard Expansion selector / Review UI;
- mechanic-card visual rendering;
- click-to-roll / dice animation;
- natural crits;
- Attributes / Skills / Level / XP;
- HP / damage / initiative / combat turns;
- contested checks;
- hidden checks;
- arbitrary dice expressions;
- NPC autonomous dice simulation;
- generic Mod scripting/plugin system;
- external declarative UI contract;
- Creator/import manager work from G8.

Do not reopen accepted G4-07 semantics absent concrete regression evidence.

---

## 14. Return contract

Codex returns only after implementation/evidence are pushed to `main` and the repository is clean enough for review.

Return:

```text
START_HEAD
IMPLEMENTATION_HEAD
EVIDENCE_HEAD (if separate)
changed paths
schema version before/after (if changed)
exact Expansion package path
exact capability registry/binding seam
exact adjudication envelope shape
exact RNG authority + injectable test seam
exact check persistence identity/idempotency rule
Evidence A–J summary
real Provider Han result
real Provider Afterglow result
no-Expansion regression result
UI paths changed: none (or explicit blocker report)
```

Return ceiling:

> **READY FOR INDEPENDENT REVIEW**

Do not declare G4-08 PASS. Do not activate Kimi yourself. GPT reviews M1 first and then issues the separate UI/integration task.