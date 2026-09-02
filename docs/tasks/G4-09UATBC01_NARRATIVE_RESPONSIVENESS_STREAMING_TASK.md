# G4-09UATBC01 — Narrative Responsiveness / Public d20 Streaming Critical Path

Type: **implementation / UAT correction**  
Status: **ACTIVE — CODEX**  
Owner: **Codex**  
Reviewer / semantic owner: **GPT**  
Parent: **G4-09UATB Owner Product UAT**  
Formal implementation base before packet: `367a43a6afe1e72af4662535f101a6922f1bf3d4`  
Owner-observed code base: `fe59020124e143347cc10de701d3f82d6d378eef`  
Governance decision commit: `7904b8978f6dd563338034e2d8c30e65fce1d202`

Return ceiling: **READY FOR INDEPENDENT REVIEW**. Do not declare G4-09UATB/G4-09/G4-08/G4-GATE PASS and do not start G4-10/G5.

## 1. Outcome

Restore progressive player-visible narrative under the Public d20 Expansion path without weakening the already accepted durable d20/no-reroll semantics.

After this task:

- NO_CHECK remains one Provider call, but its narrative body becomes visible progressively after a short validated control header instead of after whole-response completion;
- CHECK_REQUIRED still persists the exact Program-owned d20 result before result narrative begins, then streams that second-call narrative progressively through the existing Conversation/UI draft path;
- Provider/persistence timing can prove where latency occurs without logging secrets/content;
- ordinary no-Expansion / Opening / Narrative streaming remains unchanged.

## 2. Why now

Real Owner UAT accepted the d20 gameplay itself but found visible GM narrative too slow. Inspection proves ordinary Narrative is already delta-streamed and only persists after completion, while `公开D20行动判定流程.gd` currently buffers both adjudication and resolution narrative in `_buffer` until terminal completion.

This is a bounded correction to the current G4 product path, not G5 implementation.

## 3. Authority / Source Manifest

1. Owner current instruction / finding.
2. `Vibe-Coding/my world/architecture/foundation/G4_NARRATIVE_RESPONSIVENESS_V0_1_DECISION.md` — **FROZEN / OWNER-REQUESTED**, governance commit `7904b897...`.
3. `docs/g4_09/G4-09UATB_OWNER_FINDING_NARRATIVE_RESPONSIVENESS.md`.
4. Existing accepted Public d20 decision and M1/M1C01 evidence; preserve stable action/no-reroll semantics.
5. Current implementation/tests on refreshed `origin/main`.
6. Repository `AGENTS.md`.

Historical chat text and generated `.uid/.import` files are not performance authority.

## 4. Read first

1. `AGENTS.md`
2. this packet
3. `docs/g4_09/G4-09UATB_OWNER_FINDING_NARRATIVE_RESPONSIVENESS.md`
4. `src/行动判定/L0_公理层/公开D20判定规则.gd`
5. `src/行动判定/L1_器件层/结构化判定响应解析器.gd`
6. `src/行动判定/L2_流程层/公开D20行动判定流程.gd`
7. `src/domain/会话.gd` and `src/ui/叙事对话视图.gd` as **read-only behavior references** unless a proven blocker is found
8. directly relevant G4-08M1/M1C01/B tests

Only expand reading when evidence is insufficient; explain why in return evidence.

## 5. Decision Digest / Invariants

### INV-PRODUCT-01 — visible narrative first

Do not make the player wait for full narrative completion merely because bookkeeping/validation will happen later. Once a narrative body is semantically safe to expose, feed it through the existing provisional Conversation/UI path incrementally.

### INV-C01-01 — no per-token persistence

Provider deltas stay in memory. Do not introduce SQLite/world/file writes per token/chunk.

### INV-C01-02 — Turn Finalize Barrier

Visible draft may precede durable acceptance, but the next player action must remain blocked until required current-turn durable acceptance/markers finish.

### INV-C01-03 — CHECK_REQUIRED durable-before-narrative

Exact ordering remains:

```text
validated proposal
→ Program RNG/outcome
→ durable exact check
→ result narrative request
→ visible narrative deltas
→ durable Conversation acceptance
→ narrative_accepted marker
```

Never stream result narrative before the durable exact check exists.

### INV-C01-04 — NO_CHECK remains one Provider call

Adjudication wire contract becomes:

```text
single compact JSON first physical line:
{"decision":"NO_CHECK","reason":"..."}
<LF>
raw narrative body...
```

CHECK_REQUIRED remains only a compact one-line JSON control response:

```text
{"decision":"CHECK_REQUIRED","proposal":{...}}
```

No Markdown fences/preamble. Arbitrary HTTP/SSE chunk boundaries must be supported.

For NO_CHECK:

- validate the complete first-line control header before exposing body;
- after header validation, begin/retry the provisional Conversation action turn and append subsequent body text as Provider deltas arrive;
- accumulate the same body in memory for exact final persistence;
- on Provider completion require non-empty narrative;
- persist the exact NO_CHECK resolution once, then durable Conversation accept, then acceptance marker;
- a mid-stream Provider fail/cancel leaves no accepted Conversation and no completed NO_CHECK resolution;
- if a completed exact NO_CHECK resolution is already durable but downstream acknowledgement/acceptance failed, retry/reopen reuses exact durable narrative without another Provider call.

### INV-C01-05 — provisional turn reuse

Because d20 narrative now streams before terminal completion, the Host must own correct provisional Conversation attempt lifecycle:

- first narrative attempt creates one Player turn;
- same-process retry after fail/cancel reuses the latest unaccepted matching turn/attempt rather than appending a duplicate Player turn;
- restart/reopen reconstructs only durable truth and resumes from durable check/NO_CHECK records;
- accepted order remains Player → mechanic card when applicable → GM.

Prefer consuming existing Conversation APIs (`begin_turn`, `retry_or_regenerate_latest`, append/fail/cancel/complete seams) rather than changing Conversation ownership.

### INV-C01-06 — existing UI projection

The Narrative View already renders Conversation draft deltas. Do not redesign the UI. Preserve existing d20 mechanic-card ordering by sequencing Host signals/Conversation start correctly.

### INV-C01-07 — timing observability

Add non-secret, non-persistent monotonic timing evidence sufficient to observe at least:

```text
request_started
first_provider_content_delta
first_visible_narrative_delta
provider_completed
finalize_completed / turn_ready
```

For CHECK_REQUIRED also observe control completion, durable check completion and resolution-narrative request start.

Telemetry must not contain API keys, Authorization, hidden reasoning, prompts, or full player/GM narrative.

No absolute latency SLA is frozen. Structural acceptance requires delayed-chunk tests where first visible narrative occurs **before** Provider completion.

## 6. Scope

### Allowed

- `src/行动判定/L0_公理层/**` only as needed for the revised exact control contract/validation.
- `src/行动判定/L1_器件层/**` for an incremental framed adjudication parser.
- `src/行动判定/L2_流程层/公开D20行动判定流程.gd`.
- directly related G4-08/G4-09 focused tests, fixtures and evidence docs.
- minimal non-secret instrumentation in the d20 Host / parser.

### Protected / do not change without returning a blocker first

- `src/domain/会话.gd`
- `src/ui/**`
- `src/persistence/**`
- `src/runtime/当前游戏会话运行时.gd`
- `src/provider/**`
- Runtime Model Settings
- Source / Final Create / Game Library
- SQLite schema

The intended implementation should be possible by orchestrating existing Conversation/UI/Runtime seams. If a protected seam is genuinely insufficient, stop and return exact evidence rather than silently crossing ownership.

### Explicit non-scope

- character/event/relationship/location/world semantic mutation systems;
- generic background worker/job queue;
- G5/G6 implementation;
- G7 context/summarization/retrieval;
- Provider timeout/watchdog redesign;
- model/profile changes;
- UI redesign.

## 7. Required implementation behavior

### 7.1 Incremental adjudication framing

Replace whole-text JSON parsing for the active d20 Provider stage with an incremental parser/state machine that:

- accepts arbitrary split points within UTF-8/provider content deltas;
- buffers only until the first physical LF for the control header;
- validates exact header fields/branch semantics;
- for NO_CHECK emits/returns later body text incrementally after header validation;
- for CHECK_REQUIRED rejects non-whitespace body/trailing narrative;
- fails loud on malformed/preamble/fenced/multi-line control data rather than guessing.

Do not expose control JSON to Narrative UI.

### 7.2 NO_CHECK streaming lifecycle

Once NO_CHECK header is valid:

- establish or reuse the provisional Conversation attempt for `_player_text`;
- stream body into `conversation.append_delta(...)` as it arrives;
- keep input/action gate active until finalize;
- on terminal completion, create the exact durable NO_CHECK resolution using the complete body and existing stable action identity;
- then durable-accept Conversation and mark the durable NO_CHECK record accepted;
- failures/cancellation must call the corresponding Conversation attempt failure/cancel seam and leave durable accepted history unchanged.

### 7.3 CHECK_REQUIRED result narrative streaming

After Program roll/result is durably committed:

- preserve the current mechanic-card publication point;
- establish/reuse the provisional Conversation attempt before sending/receiving result narrative;
- stream every player-visible resolution narrative delta directly into Conversation draft;
- on completion durable-accept Conversation then mark check narrative accepted;
- on failure/cancel keep exact durable check and fail/cancel only the provisional narrative attempt;
- retry uses the same durable check and never rerolls.

### 7.4 Existing completed/recovery windows

Re-audit M1C01 lost-ACK/restart windows for both branches. The streaming change must not create duplicate Player turns, duplicate checks, duplicate NO_CHECK resolutions, rerolls, or replacement narratives after an exact completed durable result already exists.

## 8. Acceptance Gates

### Engineering Acceptance

Must prove all of the following:

1. **NO_CHECK progressive visibility**: controlled delayed Provider chunks deliver valid one-line header then narrative chunks; first narrative chunk reaches Conversation/UI projection while Provider is still active, before `completed`.
2. **NO_CHECK one call**: successful path uses exactly one Provider call.
3. **NO_CHECK no per-token persistence**: durable world/Conversation writes occur only at completion/finalize boundaries.
4. **NO_CHECK mid-stream failure/cancel**: partial visible draft is not durable and next Context excludes it; retry has no duplicate Player turn.
5. **NO_CHECK post-completion recovery**: if exact resolution is durable and later acceptance/marker fails, retry/reopen reuses exact narrative with zero additional Provider call for that completed resolution.
6. **CHECK_REQUIRED progressive result narrative**: exact check is durable before the first visible result-narrative delta, and at least one visible delta occurs before Provider completion.
7. **CHECK_REQUIRED no reroll**: failure/cancel/retry/reopen of narrative phase reuses the exact same durable check/raw rolls/outcome.
8. **Ordering**: Player → mechanic card → streaming GM narrative remains correct.
9. **Turn barrier**: next action remains blocked until durable finalize succeeds.
10. **No Expansion regression**: ordinary G4-07 path still streams as before and uses one ordinary Provider call.
11. **Opening regression**: First Opening behavior remains unchanged.
12. **Model/provider regression**: current Runtime Model Settings/provider routing tests stay green.
13. **Persistence/schema**: SQLite remains v4; Source/Game semantics outside d20 runtime unchanged.
14. **Telemetry safety**: timing evidence contains no secrets/content and distinguishes provider delta vs visible delta vs finalize.
15. `git diff --check` clean.

### Real integration evidence

After focused/stub suites are green, run at least one small real selected-provider d20 product vertical on task-owned Game/Source/settings roots. Capture non-secret timings and prove progressive visible narrative on the branch reached. Controlled delayed-SSE tests must cover **both** NO_CHECK and CHECK_REQUIRED even if real-model branch choice varies.

Do not overwrite Owner production Game/model preference.

### Windows readiness

Because product code changes, run canonical Windows export freshness validation before return:

```powershell
.\run-game.ps1 -ValidateExportOnly
```

Record whether export was rebuilt/current and success result. Do not introduce a second launcher.

### Product Value Acceptance

Codex cannot close the product gate. The Owner already accepted Public d20 gameplay semantics; after GPT Independent Review, Owner will perform a focused responsiveness retest. Return only `READY FOR INDEPENDENT REVIEW`.

## 9. Regression floor

At minimum run directly relevant suites for:

- G4-08M1 + M1C01
- G4-08B
- G4-07A/B
- G4-09R1 provider/settings integration affected by common Provider routing
- persistence tests touched by d20 durable windows

If a broader existing regression command is standard and affordable, run it after focused suites.

## 10. Git / evidence discipline

- Start by refreshing both repositories and record actual `START_HEAD`; the Owner has pushed generated `.uid/.import` files after the previous UAT handoff. Preserve them; do not clean/rewrite unrelated Owner commits.
- Do not commit `.env.local`, keys, raw Authorization, or secret-bearing logs.
- Do not use destructive reset/checkout against unknown work.
- Commit implementation and evidence, push `origin/main`, and return exact heads/changed paths.

## 11. Return contract

Return:

```text
START_HEAD
IMPLEMENTATION_HEAD
EVIDENCE_HEAD / FINAL_HEAD
changed paths
exact new adjudication framing contract
NO_CHECK one-call progressive streaming evidence
CHECK_REQUIRED durable-check-before-visible-narrative evidence
same-process retry / reopen replay evidence
provider call counts by branch/window
first_provider_delta -> first_visible_narrative -> provider_completed -> finalize timings
real selected-provider result
Windows export freshness result
regression summary
SQLite schema unchanged
protected paths unchanged (or explicit blocker if not)
READY FOR INDEPENDENT REVIEW
```
