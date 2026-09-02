# G4-09UATBC02A Independent Review — d20 Protocol Decoupling / Model Freedom

Status: **PASS / CLOSED**

Reviewer / semantic owner: **GPT**

Reviewed implementation range:

- START_HEAD: `6a50a2c04a244888c58e4eb395226b72539b5364`
- IMPLEMENTATION_HEAD: `beecdefc8f3698bb2c5d06b5bf0dd53f6b1ed415`
- EVIDENCE_HEAD: `9b3d4343250cabfe4f58e61db31c7180d0ca13da`

Parent: **G4-09UATB Owner Product UAT**

Correction budget: **correction-02 redesign**

## Verdict

PASS / CLOSED.

C02A removes the fragile C01 mixed `control JSON + narrative body` response protocol rather than adding more framing exceptions. Public d20 mechanics control and player-visible GM prose are now separate Provider requests.

The implementation satisfies the current canonical principle:

```text
Model Freedom First
+
Visible Narrative First
+
Canonical Commit Behind a Turn Finalize Barrier
```

No same-seam failure remains that would require another protocol redesign.

## 1. Model-freedom / no-new-gate review

Accepted:

- player-visible narrative is ordinary free-form Provider content;
- narrative has no JSON header, sentinel, exact first line or physical-LF contract;
- narrative deltas enter the existing provisional Conversation/UI path directly;
- the structured parser is now isolated to the mechanics-control lane;
- harmless outer whitespace and pretty-printed valid JSON are accepted in that isolated control lane;
- malformed control gets at most one bounded internal recovery attempt;
- if control remains unresolved, the action continues through `degraded_narrative` rather than ending in `行动未完成`;
- degraded success creates no d20 check and no fake successful NO_CHECK durable marker;
- no cross-provider fallback is introduced.

The remaining hard failures match the canonical decision: Provider/network/credential unavailability may stop the current request because no model narrative can be produced; persistence/capability integrity remains fail-loud; a valid CHECK_REQUIRED proposal still gates result narrative behind durable Program-owned d20 truth.

## 2. NO_CHECK

Normal NO_CHECK now uses:

```text
isolated control
→ valid NO_CHECK
→ separate free-form narrative request
→ progressive provisional narrative
→ exact durable NO_CHECK resolution
→ durable Conversation acceptance
→ acceptance marker
```

The old one-call optimization is superseded. Focused tests prove the control response is never projected into the narrative view, the first narrative delta is visible before Provider completion, and no per-token Conversation/world persistence occurs.

Failure/cancel leaves visible partial draft provisional and outside future Context. Same-process retry reuses the matching unaccepted Player turn. Existing durable NO_CHECK lost-ACK/reopen recovery remains exact and avoids replacement Provider calls.

## 3. CHECK_REQUIRED

Accepted ordering remains:

```text
valid mechanics proposal
→ Program RNG/outcome
→ durable exact check
→ free-form result-narrative request
→ progressive provisional narrative
→ durable Conversation acceptance
→ narrative_accepted marker
```

Focused/restart evidence preserves stable action identity, exact raw roll/outcome, no reroll, no duplicate Player turn and replay behavior.

## 4. Fail-soft degradation

Controlled malformed-control evidence proves:

```text
initial malformed control
→ one control_recovery request
→ second malformed control
→ degraded_narrative
→ progressive free-form narrative
→ accepted turn
```

The degraded result exposes only stable non-secret metadata (`degraded=true`, `degradation_code=control_unresolved`). It does not persist a fake check or fake NO_CHECK classification marker and does not echo the malformed control payload into the narrative request.

## 5. Real Provider / product integration

Task-owned real selected-provider evidence completed with zero recorded failures:

- DeepSeek V4 Pro: ordinary NO_CHECK, stages `control → no_check_narrative`, 2 calls, accepted, not degraded.
- Kimi K3: CHECK_REQUIRED, stages `control → resolution_narrative`, 2 calls, accepted, not degraded.

Real timing preserves structural ordering. The repeated Godot `HTTPClient status != STATUS_BODY` warning did not create an extra terminal event, retry, fallback or failed action in either real path; Provider transport was not changed in this task.

## 6. Protected boundaries / regressions

Accepted:

- no production changes under Conversation, UI, Persistence, Runtime, Provider, Source, Final Create, Game Library or Runtime Settings;
- action adjudication dependency direction remains L3 → L2 → L1 → L0 and cross-module access remains through existing public seams;
- no per-token canonical write;
- SQLite schema remains v4 with no migration;
- no-Expansion G4-07 path remains unchanged;
- Runtime Model Settings/current selected-provider routing regressions remain green;
- real process restart/replay tests for CHECK_REQUIRED and NO_CHECK remain green;
- canonical Windows export was rebuilt/verified against the corrected checkout;
- `git diff --check` clean.

## 7. Next task

Activate:

`G4-09UATBC02B — Public d20 Failure Visibility / Recoverable UX` — **KIMI**.

C02B is UI-only. It may surface concise safe terminal failure reasons and an optional non-blocking degradation notice. It must not modify backend mechanics, Provider behavior, model policy, protocol structure, fallback behavior or add new blocking gates.

Owner UAT remains HOLD until C02B passes Independent Review. Public d20 gameplay value remains accepted and is not reopened.
