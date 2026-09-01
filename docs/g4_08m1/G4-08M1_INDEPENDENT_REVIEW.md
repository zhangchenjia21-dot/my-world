# G4-08M1 Independent Review

Status: **PASS / CLOSED AFTER CORRECTION-01**  
Reviewer: **GPT**  
Initial reviewed implementation HEAD: `31eca597d144c7c1214ddcc114d718a45fabf9dd`  
Final reviewed correction HEAD: `d646427dfe3c4c6328809384e482cd1fdd2204a0`  
Formal task: `docs/tasks/G4-08M1_PUBLIC_D20_EXPANSION_MECHANISM_TASK.md`  
Correction review: `docs/g4_08m1/G4-08M1C01_INDEPENDENT_REVIEW.md`

## 1. Final result

G4-08M1 **PASS / CLOSED**.

The initial review found one blocker: Expansion-enabled `NO_CHECK` actions were not durably replay-safe by caller-owned stable `action_id`. That seam was corrected under G4-08M1C01 and independently re-reviewed PASS.

No correction-02 or redesign was required.

## 2. Accepted M1 mechanism

The final accepted mechanism establishes:

- `expansion_pack.v0.1` as a real third Source type through the existing strict contract / Managed Library / immutable exact-generation machinery;
- explicit `0..N` exact Expansion Composition selection;
- duplicate exact Expansion and exclusive capability-slot collision fail closed;
- exact Expansion Final Create provenance, authored-rule materialization and Host capability binding;
- SQLite schema v4 unchanged;
- no Provider call during Final Create;
- bounded Host capability `action_check.public_d20.v1` in slot `action_resolution`;
- strictly parsed `NO_CHECK` vs `CHECK_REQUIRED` adjudication envelope;
- Proposal validation/freeze before RNG;
- Program-owned d20 faces, selected roll, total and outcome;
- no natural-1/20 override;
- CHECK_REQUIRED durable resolution before second Provider narrative;
- CHECK_REQUIRED retry/restart never rerolls;
- NO_CHECK one-call path with durable stable-action replay identity and exactly-once retry/restart semantics;
- real DeepSeek Han + Afterglow mechanism evidence;
- no-Expansion G4-07 route preserved;
- no executable Source code, generic plugin runtime or UI ownership introduced.

## 3. Correction history

Initial implementation was marked `CORRECTION REQUIRED` because:

```text
NO_CHECK accepted
→ success ACK lost / Game reopened
→ same action_id retried
→ no durable action completion identity
→ Provider could run again
→ duplicate Player/GM turn possible
```

G4-08M1C01 introduced a separate, non-dice durable NO_CHECK resolution:

```text
no-check-SHA256(game_id + U+001F + action_id)
```

and proved both lost-ACK windows plus same-process / fresh-runtime / distinct-process replay without additional Provider, RNG or Conversation turns.

See:

- `docs/tasks/G4-08M1C01_NO_CHECK_ACTION_IDEMPOTENCY_CORRECTION_TASK.md`
- `docs/g4_08m1/G4-08M1C01_NO_CHECK_ACTION_IDEMPOTENCY_CORRECTION_EVIDENCE.md`
- `docs/g4_08m1/G4-08M1C01_INDEPENDENT_REVIEW.md`

## 4. Product boundary

M1 is backend/mechanism PASS only. It does **not** make G4-08 Product PASS.

Still required:

```text
G4-08B UI / interaction integration — Kimi
→ GPT Independent Review
→ G4-09 First Playable B
→ Owner UAT B
```

The first-generation UI must project Program-owned truth; it must not roll, recompute, mutate or invent d20 outcomes.
