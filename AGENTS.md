# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / Freshness

Resolve authority in this order:

1. Owner current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. current Product / Principles / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. relevant current architecture decisions.
5. this repository `AGENTS.md` and the current task packet.
6. verifiable implementation/tests/current HEAD.

Before authoritative work, refresh `main`; never overwrite unknown dirty/newer work.

Execution routing:

```text
GPT        → Meaning / architecture / governance / task shaping / Independent Review
Codex      → backend / mechanism / build-launch implementation
Kimi       → frontend / UI / interaction implementation
Grok Build → search / external research / evidence discovery
```

---

## 2. Current state

```text
G1 Foundation                         PASS / CLOSED
G2 AI Conversation Spine              PASS / CLOSED
G3 Persistence / Save / Timeline      PASS / CLOSED
G4-01 Application Shell / Lifecycle  PASS / CLOSED
G4-02R1 Source semantic re-audit      PASS / CLOSED
G4-03 Managed Local Source Library    PASS / CLOSED
G4-04 Multi-Game / Game Library       PASS / CLOSED
G4-05 New Game Wizard                 PASS / CLOSED
G4-06 Atomic Final Create             PASS / CLOSED
G4-07 First Playable A                PASS / CLOSED
G4-07A Opening Runtime                PASS / CLOSED
G4-07B Playable UI Integration        PASS / CLOSED
G4-07UAT01 Owner Launch Freshness     PASS / CLOSED
G4-08 Expansion Pack v0.1             ACTIVE
G4-08S0 Expansion Semantic Freeze     PASS / CLOSED
G4-08M1 Public d20 Mechanism          ACTIVE — CODEX
G4-GATE                               NOT YET
```

G4-07 Owner Product UAT verdict: **PASS**.

---

## 3. Current execution task — G4-08M1

Formal packet:

`docs/tasks/G4-08M1_PUBLIC_D20_EXPANSION_MECHANISM_TASK.md`

Formal Code Base:

`3b5cd80a26091a17d61c5a055637a422a9edb3aa`

Primary owner: **Codex**.  
Reviewer: **GPT**.  
Return ceiling: **READY FOR INDEPENDENT REVIEW**.

Canonical semantic authority:

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

M1 owns backend/mechanism only:

```text
Expansion Source contract/library
→ exact Composition backend
→ compatibility
→ Atomic Final Create materialization/provenance
→ Host capability binding
→ structured Player-action adjudication
→ freeze-before-RNG
→ Program RNG
→ durable check result
→ real Provider continuation
→ retry/restart
→ UI-neutral resolution projection
```

M1 does **not** own Wizard/Narrative visual UI. After M1 IR, GPT will issue a separate Kimi task.

---

## 4. Frozen Public d20 semantics

### Optional

- Expansion selection is explicit `0..N` exact generations.
- No Expansion means current G4-07 behavior; never silently enable Public d20.

### Compatibility

- duplicate exact Expansion → fail closed;
- same exclusive `capability_slot` collision → fail closed;
- no family/genre/year guessing;
- Public d20 must work across Han and Afterglow.

### Three no-roll cases

Do not roll when the attempt is:

1. certainly successful under established facts;
2. certainly impossible under established facts/personality/causality;
3. immediately repeatable with no meaningful failure cost.

> Dice decides uncertainty. Dice does not erase reality.

### Rules

```text
d20 + modifier = total

total >= DC → success
total <  DC → failure
```

No natural-1/natural-20 automatic override in v0.1.

Standard DC guidance: 10 / 15 / 20 / 25 / 30.

```text
normal        1d20
advantage     2d20 take high
disadvantage  2d20 take low
```

No advantage/disadvantage stacking tiers.

### Freeze-before-RNG

Before Program RNG, a strictly parsed Check Proposal freezes at least:

```text
action identity
intent
DC
modifier
stance
modifier reason
situation reason
success intent
failure stakes
```

The model cannot see RNG before freeze and cannot mutate the Proposal after roll.

### Provider turns

No-check turn:

```text
Player action
→ NO_CHECK + normal GM narrative in first Provider response
```

Real check:

```text
Player action
→ CHECK_REQUIRED + Proposal
→ validate/freeze
→ Program RNG + durable result
→ second Provider continuation constrained by result
```

Do not double-call Provider for every ordinary Expansion-enabled turn.

### RNG / retry

- model never owns die face, total or outcome;
- Program computes all three;
- same Player action retry/restart never rerolls;
- Provider failure after durable losing roll must reuse that exact losing result.

### Ownership

Expansion owns action resolution only. Downstream Injury / Relationship / Knowledge / Inventory / World consequences remain with their canonical Game-local owners.

Historical check log is provenance/audit evidence, not a second World truth and not an every-turn Context dump.

---

## 5. Source / runtime boundaries

Expansion v0.1 is a third first-class Source type through the existing Source layers and Managed Library.

Minimal authored package:

```text
source.json
sections/rules.md
```

Source declares authored semantics + Host-known capability binding. It does not contain executable GDScript/plugin code or live Game state.

Final Create pins exact Expansion generation and materializes needed rules/binding into Game-local setup. Runtime never reconstructs semantics from mutable `SourceLibrary.current`.

Unknown Host capability id must fail loud; do not interpret prose as code.

---

## 6. UI boundary

Do not implement in M1:

- Wizard Expansion selector / Review UI;
- mechanic-card rendering;
- player click-to-roll;
- dice animation.

Expose a stable UI-neutral resolution projection only.

If an unavoidable UI-path modification is required, stop and report rather than silently taking Kimi scope.

---

## 7. Accepted G4-07 baseline must remain intact

- successful Final Create opens exact existing-only Game;
- Provider failure never rolls back created Game;
- first Opening accepted exactly once;
- Continue uses same Game and durable continuation;
- Source v0.2-r2 World/Character semantics remain frozen;
- no latest/nearest/later/full-life fallback;
- Guaranteed NPC is canonical cast only;
- no-Expansion route remains current product behavior.

Do not reopen G4-07 absent concrete regression evidence.

---

## 8. Next progression

```text
G4-08M1 mechanism — Codex
→ GPT Independent Review
→ G4-08B UI/integration — Kimi
→ GPT Independent Review
→ G4-09 First Playable B
→ Owner UAT B
```

Do not claim G4-08 PASS from M1 alone and do not start G5 before the remaining G4 route / G4-GATE complete.