# G4-08BC01 — Public d20 UI Projection / Fail-Loud Correction

Status: **ACTIVE — KIMI**  
Parent task: **G4-08B Public d20 UI / Interaction Integration**  
Correction budget: **correction-01**  
Primary owner: **Kimi**  
Reviewer: **GPT**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Formal Code Base:

`3a20234d06c10904c220cd1a49bf29f6ad6769e7`

Independent Review finding:

`docs/g4_08b/G4-08B_INDEPENDENT_REVIEW.md`

## 1. Purpose

Close the bounded UI integration defects found by GPT without changing accepted Public d20 backend semantics.

This correction owns only:

- mechanic-card transient/history lifecycle and ordering;
- duplicate-card prevention across retry/reopen;
- player-visible fail-loud handling for unsupported materialized `action_resolution` capability;
- missing direct explicit-none Wizard/Review evidence;
- removal of task/debug probe output from production UI.

Do not redesign the d20 mechanism.

## 2. Mechanic-card invariant

For one durable `check_id`:

```text
at most one visible mechanic projection at a time
```

During `resolution_narrative`, show one transient projection before GM resolution completion.

After the turn becomes accepted, the transient projection must be replaced/repositioned by the historical projection. Do not leave a transient node stranded in history.

Freeze the accepted historical association as:

```text
Player action
→ mechanic card
→ GM narrative
```

Use the same association for:

- first live acceptance;
- same-action retry after durable result;
- unresolved-on-reopen retry;
- full redraw;
- Continue;
- Load/Restore.

If implementation uses a dedicated transient surface outside `Entries`, that is acceptable and likely simpler. The historical card must still be reconstructed only from durable check truth.

UI must never recompute dice values.

## 3. Retry / reopen deduplication

Current Host can expose `resolution_narrative` through both:

- `request_assembled(stage=resolution_narrative)` signal; and
- synchronous `start_action()` return `streaming{stage=resolution_narrative}` when resuming an existing check.

Do not append twice.

Use stable `check_id` as a read-only projection identity/guard. Repeated stage notification for the same durable check must update/reuse the existing transient projection rather than append another card.

A failed resolution narrative followed by `重试行动` must not accumulate old transient cards.

## 4. Accepted transition

When Host reaches `accepted` / `already_accepted`:

- clear transient UI for that check;
- redraw or otherwise place exactly one historical card in the frozen Player → card → GM position;
- clear pending action identity only after the accepted durable state is visible consistently;
- do not mutate the durable check record.

For NO_CHECK, no card appears at any stage.

## 5. Unknown action-resolution capability must fail loud

A materialized Expansion with:

```text
capability_slot = action_resolution
capability_id != action_check.public_d20.v1
```

must never fall back to the legacy no-Expansion Narrative path.

Required product behavior:

- surface a clear player-readable unsupported-rule/capability state;
- gate Player action input for that Game/session;
- do not call the legacy Narrative Provider path;
- do not interpret authored prose as executable rules;
- keep the created Game durable/intact so future supported builds may open it.

Use bounded Shell/View glue only. Do not modify Source, Final Create, persistence, or d20 L0-L2.

## 6. Explicit-none evidence

Implement the currently empty dedicated test for:

```text
Wizard Expansion step
→ explicit 本局不使用拓展
→ step becomes complete
→ navigate to Review
→ Review contains 拓展 / 无
→ frozen Final Create payload has expansions=[] and explicit none semantics
```

Do not satisfy this only indirectly through a later no-Expansion gameplay test.

## 7. Required tests

Add/strengthen focused assertions for:

### A — first checked action

- transient result visible before GM resolution completion;
- exactly one projection for check_id;
- after acceptance exactly one historical card remains;
- node/order is Player → mechanic card → GM.

### B — durable-check retry

- first narrative attempt fails after durable check;
- retry reuses same action_id and no RNG;
- before/during/after retry, visible projection count for that check never exceeds one;
- accepted final history uses Player → card → GM.

### C — reopen unresolved retry

- close/reopen with one unresolved durable check;
- retry uses exact action_id with no reroll;
- no duplicate transient cards from signal + synchronous streaming return;
- accepted history contains one card.

### D — Continue / Load

- Continue reproduces the exact same Player → card → GM order;
- Load to pre-check state removes the card.

### E — NO_CHECK

- remains zero dice cards.

### F — unsupported capability

Construct a task-owned Game/materialized setup with unknown `action_resolution` capability:

- Player sees unsupported-rule failure state;
- input is gated;
- no legacy Provider request is sent;
- no d20 RNG is invoked;
- Game data remains intact.

### G — explicit none

Direct Wizard/Review assertions described in §6.

### H — regressions

Keep green:

- existing G4-08B suite after strengthening;
- G4-07B;
- G4-08M1 / M1C01;
- G4-05 / G4-06 / G4-07A focused suites affected by UI glue;
- no-Expansion route;
- real DeepSeek Public d20 UI vertical unless Provider-facing message semantics remain unchanged; if unchanged, explain why prior real evidence remains applicable;
- 1280×720 / 960×540 / maximized layout for changed transient/history placement;
- `git diff --check`.

## 8. Protected boundaries

Do not modify:

- `src/source/**`;
- `src/最终建局/**`;
- `src/persistence/**`;
- `src/行动判定/L0_公理层/**`;
- `src/行动判定/L1_器件层/**`;
- `src/行动判定/L2_流程层/**`;
- Provider protocol semantics.

Do not add click-to-roll, dice animation, attributes, combat, or new Expansion semantics.

## 9. Return contract

After pushing to `main`, return:

```text
START_HEAD
IMPLEMENTATION_HEAD
EVIDENCE_HEAD
changed paths
exact transient→historical card lifecycle
exact deduplication rule
exact unsupported-capability fail-loud behavior
explicit-none direct evidence
retry/reopen/Continue/Load card-order evidence
regression summary
real Provider rerun yes/no and why
protected backend paths unchanged
```

Return ceiling:

> **READY FOR INDEPENDENT REVIEW**

Do not declare G4-08B PASS and do not start G4-09.
