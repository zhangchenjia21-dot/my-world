# G4-09R1M1C01 Independent Review

Status: **PASS / CLOSED**  
Reviewer: **GPT**  
Reviewed implementation/evidence HEAD: `6ea825ba0ea0d5a57728c55789f437ff9626b6cb`  
Correction packet: `docs/tasks/G4-09R1M1C01_SETTINGS_PROJECTION_KIMI_PROOF_CORRECTION_TASK.md`

## 1. Result

G4-09R1M1C01 is **PASS / CLOSED**.

The focused correction closes both blockers from the prior M1 review without reopening the accepted runtime-settings/provider architecture.

Therefore the parent task is also closed:

```text
G4-09R1M1C01 Projection/Kimi Proof    PASS / CLOSED
G4-09R1M1 Backend Mechanism           PASS / CLOSED
```

No correction-02 is required.

## 2. Candidate projection acceptance

`ModelRuntimeSettingsPublicInterface.inspect_candidate(settings)` now provides a non-mutating UI-safe projection for an unsaved candidate.

Accepted projection truth includes:

```text
profile_id
display_name
provider_id
context_limit
allowed_context_limits
reasoning_requested
reasoning_effective
graded_reasoning
fixed_thinking
selected-provider credential configured bool
```

Verified properties:

- Kimi K2.7 + 1M fails with `incompatible_context_limit` before Provider use;
- DeepSeek V4 / Kimi K3 Medium projects effective High;
- Kimi K2.7 projects fixed thinking with `reasoning_effective = null`;
- no endpoint, model id, request path, payload field, API key value or secret marker is returned;
- candidate inspection does not create the candidate settings file;
- task-owned Game/SQLite sentinel remains unchanged.

This is sufficient for G4-09R1B1 to render compatibility/effective state without duplicating backend policy or persisting a preview.

## 3. Kimi Thinking wire acceptance

Current official Kimi Code model documentation was rechecked during Independent Review.

Accepted wire semantics:

```text
Kimi K3:
model = k3-256k | k3
reasoning_effort = low | high | max
never reasoning_effort = none

Kimi K2.7:
model = kimi-for-coding
reasoning_effort omitted
thinking object omitted
fixed Thinking ON behavior retained
```

The current Kimi documentation states that K3 supports `low/high/max`, with undefined/default mapping to High and `none` disabling Thinking; K2.7 is presented as fixed Thinking ON. Disabling Thinking routes K3/K2.7 requests to K2.6. The production payload never emits the disabling `none` value for K3 and does not fabricate graded effort for K2.7.

No production Provider payload code change was necessary.

## 4. Real Provider reality proof

Recorded real calls now cover both Provider families and all required Kimi identities:

```text
DeepSeek V4 Pro / deepseek-v4-pro       completed
DeepSeek V4 Flash / deepseek-v4-flash   completed
Kimi K3 256K / k3-256k                  completed
Kimi K3 1M / k3                         completed
Kimi K2.7 / kimi-for-coding             completed
```

The runner uses only the selected Provider credential, records no key or model body, and retains the no-fallback contract.

This closes the prior `credential_unavailable` blocker; Kimi runtime support is no longer based on stubs alone.

## 5. Regression / protected boundaries

Recorded green:

- G4-09R1 mechanism suite;
- candidate projection and exact payload assertions;
- G2 Conversation / Context regressions;
- G4-07A/B;
- G4-08M1/M1C01;
- G4-08B/BC01;
- Windows export freshness validation;
- `git diff --check`.

No diff to Source, Composition, Final Create, Public d20 semantics/RNG/action identity or persistence schema. SQLite remains schema v4.

## 6. Progression

Backend prerequisite is now satisfied. Activate:

`docs/tasks/G4-09R1B1_MODEL_SETTINGS_UI_TASK.md`

Owner: **Kimi**.

G4-09UATB remains HOLD until UI Independent Review plus final real Provider / Windows freshness integration are complete.
