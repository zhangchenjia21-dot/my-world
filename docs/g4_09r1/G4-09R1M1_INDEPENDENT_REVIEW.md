# G4-09R1M1 Independent Review

Status: **CORRECTION REQUIRED**  
Reviewer: **GPT**  
Reviewed implementation/evidence HEAD: `7b183d4b5aecd1b4d0e0f80fbfe235ded4c67344`  
Formal task: `docs/tasks/G4-09R1M1_RUNTIME_MODEL_SETTINGS_MECHANISM_TASK.md`

## 1. Result

G4-09R1M1 is **not PASS yet**.

The implementation establishes the intended backend architecture and closes most of the DeepSeek-only routing debt, but two acceptance seams remain before the frontend may start:

1. **UI-facing effective-settings projection is missing.** The L3 settings API exposes `catalog()`, `validate()` and `request_snapshot()` for the already-persisted current setting, but no non-mutating projection for an unsaved candidate. G4-09R1B1 is explicitly forbidden from duplicating backend compatibility/effective-effort policy, and it must preview states such as `Medium → actual High`, `K2.7 fixed thinking`, and `K2.7 + 1M invalid` before Save. Without a backend candidate projection, the UI would have to hard-code policy or mutate persisted settings to preview it.
2. **Real Kimi runtime acceptance is still absent.** The task explicitly says stub evidence is insufficient for final M1 PASS. Current evidence records `credential_unavailable` for both `k3-256k` and `kimi-for-coding` because the Owner environment does not currently expose `KIMI_API_KEY`.

A related wire-semantics check must be closed during correction: current generic payload emits `reasoning_effort` for graded models and no graded field for K2.7, but it does not explicitly encode Kimi Thinking ON. Current Kimi Code documentation states that K3/K2.7 must remain in Thinking mode to avoid routing to an older model. Because no real Kimi call ran, this must be proved against the current API contract and corrected if necessary before Kimi runtime support is accepted.

This is a focused correction, not a redesign.

## 2. Accepted implementation from this review

The following mechanism is accepted and should not be reopened absent a regression:

- application-local settings at `user://my-world/settings/provider-runtime.json`;
- schema `my-world.provider-runtime.v1`;
- validated default `deepseek_v4_pro / 256k / high`;
- closed four-profile catalog and exact model/endpoint derivation;
- K2.7 + 1M fail-closed validation;
- DeepSeek/K3 requested reasoning mapping `low→low`, `medium→high`, `high→high`, `max→max`;
- K2.7 `graded_reasoning=false` / fixed-thinking capability truth;
- atomic/fail-safe settings publish with restart recovery;
- selected-provider-only credential routing via `DEEPSEEK_API_KEY` / `KIMI_API_KEY`;
- missing selected key causes zero network and no provider fallback;
- one shared runtime Provider seam used by Opening, ordinary Narrative, and Public d20 Provider phases;
- request profile snapshot immutability while streaming;
- content-only SSE projection; reasoning-only chunks are not emitted as GM narrative;
- launcher may start to Main Menu with either/both/no Provider credential;
- Source, Final Create, Public d20 semantics and SQLite schema v4 remain unchanged;
- real DeepSeek V4 Pro and V4 Flash calls completed in the recorded evidence;
- focused/regression suites and Windows freshness validation are recorded green.

## 3. UI contract gap

Current L3 API:

```text
load_settings()
save_settings(settings)
request_snapshot()          # current persisted setting only
credential_availability()
context_budget_metadata()
catalog()
validate(settings)
```

The frontend needs a backend-owned non-mutating candidate projection, conceptually:

```text
inspect_candidate(settings)
→ validation result
→ display/capability truth
→ requested/effective reasoning truth
→ compatible context truth
→ fixed-thinking truth
→ non-secret credential status
```

It must not require saving the candidate first and must not expose secret values. The UI may retain display labels, but it must not derive Provider model ids/endpoints/request fields or duplicate `medium→high` / fixed-thinking compatibility rules.

## 4. Kimi wire / real-provider gap

Current request builder sends:

```text
model
messages
stream=true
reasoning_effort   # graded profiles only
```

For K2.7 it omits `reasoning_effort`, which is correct as far as graded effort is concerned, but the review cannot yet establish that the actual Kimi Code request is guaranteed to remain Thinking ON. Current Kimi documentation describes K3/K2.7 as Thinking-capable/always-thinking and warns that disabling Thinking routes to an older model.

Correction must use current official Kimi API behavior to prove the actual wire shape. If explicit `thinking` enablement is required, add the smallest provider-specific field derivation. Do not expose reasoning content to the player and do not add a generic Provider framework.

## 5. Real-provider blocker

Recorded real results:

```text
DeepSeek V4 Pro      completed
DeepSeek V4 Flash    completed
Kimi K3              credential_unavailable
Kimi K2.7            credential_unavailable
```

Therefore M1 cannot claim real Kimi runtime support yet. After the correction code is ready, rerun the existing real-provider runner with a locally configured `KIMI_API_KEY`. Never commit or echo the key.

If Kimi account/model entitlement rejects K3 or K2.7, report the exact non-secret status; do not silently substitute another model.

## 6. Decision

```text
G4-09R1M1 Backend Mechanism           CORRECTION REQUIRED
G4-09R1M1C01 Projection/Kimi Proof    ACTIVE — CODEX
G4-09R1B1 Settings UI                 HOLD — KIMI
G4-09UATB Owner Product UAT           HOLD
```

Correction budget: **correction-01**.

Do not start Kimi UI until M1C01 receives GPT Independent Review PASS.