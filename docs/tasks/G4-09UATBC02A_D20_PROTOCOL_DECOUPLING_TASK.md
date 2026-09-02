# G4-09UATBC02A — Public d20 Protocol Decoupling / Model-Freedom Correction

Type: **implementation / correction-02 redesign**
Status: **ACTIVE — CODEX**
Owner: **Codex**
Reviewer / semantic owner: **GPT**
Parent: **G4-09UATB Owner Product UAT**
Correction budget: **correction-02**

Return ceiling: **READY FOR INDEPENDENT REVIEW**. Do not declare G4-09UATB/G4-09/G4-08/G4-GATE PASS. Do not start G4-10/G5.

## 1. Why this task exists

C01 correctly removed whole-response Public d20 narrative buffering, but its mixed `control JSON + raw narrative` one-call protocol made harmless model formatting variance a blocking gate. Real Owner retest reached `行动未完成` with no narrative.

Do **not** add more parser special cases to that mixed protocol. The protocol itself is the problem.

Canonical authority:

`Vibe-Coding/my world/architecture/foundation/G4_NARRATIVE_RESPONSIVENESS_V0_1_DECISION.md`

Current principle:

```text
Model Freedom First
+
Visible Narrative First
+
Canonical Commit Behind a Turn Finalize Barrier
```

## 2. Required outcome

Decouple Public d20 mechanics control from player-visible GM prose.

### Control lane

Use one short adjudication request whose only job is to produce:

```text
NO_CHECK
or
CHECK_REQUIRED + proposal
```

The control output may be structured because it is mechanic data, not narrative. It must not share a response body with player-visible prose.

Requirements:

- consume the current selected Provider; no provider fallback;
- keep control request small and isolated;
- accept harmless whitespace / pretty-print formatting around a valid structured object;
- one bounded automatic recovery/repair attempt is allowed when control output is malformed;
- no infinite retry loop;
- no generic job/retry framework;
- no raw control payload/prompt/reasoning/credential logging.

### Narrative lane

After control resolution, request ordinary free-form GM narrative through the existing selected Provider seam.

Narrative must have **no** machine-format contract:

- no JSON header;
- no sentinel;
- no exact first line;
- no physical-LF framing;
- no parser gate before visible prose;
- every player-visible `text_delta` streams through the existing provisional Conversation/UI path.

### NO_CHECK normal path

The old one-call requirement is superseded.

```text
control request
→ valid NO_CHECK
→ free-form narrative request
→ progressive visible narrative
→ durable Conversation/finalize
```

Do not create a fake d20 check.

### NO_CHECK fail-soft path

If control output remains unusable after the one bounded recovery attempt:

```text
control unresolved
→ degrade this action to ordinary no-Expansion natural-language narrative behavior
→ no d20 roll
→ no fake durable NO_CHECK adjudication marker claiming successful classification
→ play continues
```

Return a stable non-secret result/status flag so the UI can later display a concise non-blocking notice if desired. The action must not end in a dead-end `行动未完成` solely because control formatting was bad.

### CHECK_REQUIRED

Preserve exact accepted ordering:

```text
valid proposal
→ Program RNG/outcome
→ durable exact check
→ free-form result-narrative request
→ progressive visible narrative
→ durable Conversation acceptance
→ narrative_accepted marker
```

No reroll on fail/cancel/retry/reopen.

## 3. Preserve C01 good work

Keep:

- provisional Conversation streaming;
- no per-token persistence;
- partial visible draft excluded from future Context on fail/cancel;
- same-process provisional Turn reuse;
- durable check/replay/lost-ACK guarantees;
- timing observability;
- Windows export freshness validation.

Delete or retire mixed-protocol assumptions that require `NO_CHECK` narrative to live after a JSON control header in the same Provider response.

## 4. Scope

Allowed:

- `src/行动判定/L0_公理层/**`
- `src/行动判定/L1_器件层/**`
- `src/行动判定/L2_流程层/公开D20行动判定流程.gd`
- `src/行动判定/L3_外交层/行动判定公开接口.gd`
- directly relevant focused tests / real-provider runners / evidence docs

Protected unless a proven blocker is returned first:

- `src/domain/会话.gd`
- `src/ui/**`
- `src/persistence/**`
- `src/runtime/**`
- `src/provider/**`
- Runtime Model Settings
- Source / Final Create / Game Library
- SQLite schema

Do not cross protected seams just to reduce implementation effort.

## 5. Acceptance gates

Engineering must directly prove:

1. player-visible narrative no longer contains or depends on control JSON framing;
2. valid NO_CHECK uses isolated control + free-form narrative and streams before narrative Provider completion;
3. malformed control gets at most one bounded internal recovery attempt;
4. if recovery still fails, action continues through ordinary natural-language narrative degradation instead of terminal unfinished-action state;
5. degraded action creates no d20 check and no fake successful-adjudication marker;
6. CHECK_REQUIRED exact d20 result is durable before free-form result narrative starts;
7. result narrative streams before Provider completion;
8. CHECK_REQUIRED fail/cancel/retry/reopen never rerolls;
9. partial visible narrative is never durable or in next Context after failure/cancel;
10. no per-token SQLite/world/file persistence;
11. no-Expansion G4-07 path remains unchanged;
12. Runtime Model Settings/current provider routing remains green;
13. SQLite schema remains v4;
14. `git diff --check` clean.

## 6. Real-provider proof

Run task-owned real selected-provider verticals without changing Owner Game/default model preference.

Must include:

- at least one real DeepSeek action;
- at least one real Kimi action if local `KIMI_API_KEY` is available;
- at least one normal NO_CHECK completion through decoupled narrative;
- at least one CHECK_REQUIRED completion if branch can be obtained without unbounded retries;
- one controlled malformed-control fixture proving bounded recovery and fail-soft continuation.

Record only non-secret status/timing/model profile identifiers; do not commit prompt, narrative, hidden reasoning or keys.

## 7. Return contract

Return:

```text
START_HEAD
IMPLEMENTATION_HEAD
EVIDENCE_HEAD / FINAL_HEAD
changed paths
old mixed protocol removal summary
control lane shape
bounded recovery behavior
fail-soft degradation behavior
NO_CHECK call count and streaming proof
CHECK_REQUIRED durable-before-narrative proof
real DeepSeek result
real Kimi result or exact non-secret blocker
regression summary
Windows export freshness
SQLite schema unchanged
READY FOR INDEPENDENT REVIEW
```

Do not implement C02B UI failure visibility in this task.
