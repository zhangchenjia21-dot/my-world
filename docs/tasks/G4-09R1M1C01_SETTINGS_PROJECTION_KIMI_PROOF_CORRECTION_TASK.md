# G4-09R1M1C01 — Settings Projection + Kimi Wire/Reality Correction

Status: **ACTIVE — CODEX**  
Parent: **G4-09R1M1 Runtime Model Settings / Multi-Provider Mechanism**  
Correction budget: **correction-01**  
Primary owner: **Codex**  
Reviewer / semantic owner: **GPT**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Reviewed implementation/evidence HEAD:

`7b183d4b5aecd1b4d0e0f80fbfe235ded4c67344`

Independent Review:

`docs/g4_09r1/G4-09R1M1_INDEPENDENT_REVIEW.md`

Canonical decision:

`Vibe-Coding/my world/architecture/foundation/G4_RUNTIME_MODEL_SETTINGS_V0_1_DECISION.md`

## 1. Purpose

Close the two focused acceptance gaps found by GPT review without redesigning the accepted runtime-settings/provider architecture:

1. expose backend-owned, non-mutating effective/capability projection for an unsaved settings candidate so Kimi UI does not duplicate policy;
2. prove/correct Kimi Thinking wire semantics and obtain real Kimi runtime evidence when local credential/entitlement is available.

Do not implement the final Settings UI.

## 2. Candidate projection seam

Add the smallest L3 public API needed by the future Main Menu settings UI, conceptually:

```text
inspect_candidate(settings)
```

It must validate an unsaved candidate without persisting it and return enough **non-secret** truth for UI to render compatibility/effective state.

At minimum return conceptually:

```text
success / status / message
profile_id
display_name
provider_id
selected context_limit
allowed context_limits
requested reasoning
reasoning_effective   # null for fixed-thinking model
graded_reasoning
fixed_thinking
credential configured bool for the selected provider
```

A structured equivalent is acceptable.

Requirements:

- no save/write side effect;
- no Game/Source/SQLite mutation;
- K2.7 + 1M returns invalid/incompatible;
- DeepSeek/K3 Medium reports effective High;
- K2.7 reports fixed thinking and no fake effective effort;
- no API key value is returned;
- frontend does not need to inspect L0/L1/L2 or duplicate compatibility/reasoning mapping;
- UI must not need to derive endpoint/model id/request payload fields.

You may retain existing backend catalog/request-profile APIs for mechanism tests, but provide a UI-safe projection rather than requiring UI to consume transport internals.

## 3. Kimi Thinking wire semantics

Current official Kimi Code behavior must be treated as authority for the actual OpenAI-compatible request.

Frozen product requirement remains:

```text
Kimi K3    → Thinking ON + graded effort low/high/max
Kimi K2.7  → Thinking ON fixed; no graded effort selector
```

Current implementation only emits `reasoning_effort` for graded profiles and omits it for K2.7. Determine the exact current API wire required to guarantee Thinking ON.

Required acceptance:

- K3 request cannot accidentally disable thinking or route to an older model;
- K2.7 request cannot accidentally run with Thinking off / older-model fallback;
- K2.7 still sends no fake graded effort;
- DeepSeek current reasoning behavior remains unchanged;
- reasoning/thinking response chunks remain hidden from player-visible narrative.

If current Kimi API requires an explicit `thinking` object, add the smallest provider-specific payload derivation. Do not generalize into arbitrary Provider plugins.

Add direct payload assertions for K3 and K2.7, not only profile metadata assertions.

## 4. Real Kimi proof

The original M1 task explicitly forbids final Kimi PASS from stubs only.

Use the existing local secret channel only:

```text
KIMI_API_KEY
```

Never commit, print or persist the key.

When credential is available, rerun small real calls for at least:

```text
kimi_k3 / 256k
kimi_k27 / 256k
```

Prefer also `kimi_k3 / 1m` if account entitlement allows the model/context profile, but do not manufacture a huge prompt merely to fill 1M.

Record only non-secret evidence:

```text
profile_id
model_id
endpoint/status
reasoning/fixed-thinking profile
completion success/output char count
non-secret HTTP/error code if rejected
```

If K3/K2.7 entitlement is unavailable, fail loud and report the exact entitlement blocker. Never substitute another Kimi model.

If `KIMI_API_KEY` is still absent, return that exact blocker; M1 remains not PASS and Kimi UI remains HOLD.

## 5. Regression scope

Keep green:

- existing G4-09R1M1 mechanism suite;
- settings persistence/default/invalid-combo tests;
- selected credential zero-network behavior;
- DeepSeek real smoke already supported by local credential;
- G2 Provider/Conversation/Context regressions;
- G4-07A/B;
- G4-08M1/M1C01;
- G4-08B/BC01;
- Windows export freshness validation;
- `git diff --check`.

Do not change SQLite schema v4, Source, Composition, Final Create or Public d20 semantics.

## 6. Return contract

Return:

```text
START_HEAD
IMPLEMENTATION_HEAD
EVIDENCE_HEAD
changed paths
candidate projection API shape
K2.7 invalid-context projection proof
Medium→High projection proof
K2.7 fixed-thinking projection proof
exact Kimi K3 wire shape
exact Kimi K2.7 wire shape
real Kimi K3 result or exact blocker
real Kimi K2.7 result or exact blocker
regression summary
SQLite schema unchanged
READY FOR INDEPENDENT REVIEW
```

Do not start `G4-09R1B1` and do not resume Owner UAT.