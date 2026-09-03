# TASK｜G5-03M1C02｜Semantic-vs-Agency Currentness Separation

Type: **focused correction-02 / currentness-handoff seam**  
Owner: **KIMI**  
Reviewer / semantic owner: **GPT**  
Parent: **G5-03M1 Multi-Actor Agency Cycle**  
Prerequisite: `G5-03M1C01_INDEPENDENT_REVIEW.md`  
Return ceiling: **READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**

## 0. Temporary execution routing

Through 2026-09-06 23:59 (+08:00), Kimi remains the code-changing implementation owner under the Owner's temporary routing.

No real Provider call in this correction.

## 1. Read first

Refresh both `main`s and read:

1. `AGENTS.md`;
2. this packet;
3. `docs/g5_03/G5-03M1C01_INDEPENDENT_REVIEW.md`;
4. current `G5_MULTI_ACTOR_AGENCY_CYCLE_V0_2_DECISION.md`;
5. current G5-01/G5-02 semantic flow and G5-03 Application handoff.

Preserve all accepted M1/C01 behavior not explicitly corrected here.

## 2. Problem statement

C01 correctly stopped stale Agency from starting after foreground/timeline advancement, but it made the semantic materialization predicate too strict.

Current bad coupling:

```text
source turn is not latest OR foreground is generating
→ whole semantic result becomes stale_analysis
→ valid G5-01 changes / G5-02 knowledge are lost
```

Required distinction:

```text
A. source accepted version still exists + same GM hash
→ valid changes / knowledge remain eligible to materialize

B. source is latest + same GM hash + foreground idle
→ agency_candidates may be handed to Application
```

Foreground freedom must suppress stale Agency without erasing accepted world truth.

A second defect: successful selection-only/no-record semantic results do not consistently publish `source_gm_sha256`, so Application cannot authenticate and start Agency.

## 3. Required implementation

### 3.1 Split currentness predicates

Introduce two semantically distinct checks (names may vary):

```text
semantic_source_version_still_accepted(candidate)
agency_handoff_is_current(candidate)
```

Semantic source-version validity requires at minimum:

- source turn index still exists in durable accepted Conversation;
- current accepted GM text at that index hashes to the candidate's `source_gm_sha256`.

It must **not** require source turn to be latest.
It must **not** require `conversation.is_generating() == false`.

Agency handoff eligibility additionally requires:

- source turn is the latest accepted ordinary turn;
- Conversation is not currently generating;
- same source GM hash still matches.

### 3.2 Preserve valid older semantic materialization

If Turn A semantic analysis finishes after Turn B has started or been accepted, but Turn A's accepted GM version itself is unchanged:

- valid `changes` may still commit;
- valid `knowledge_events` may still commit;
- `agency_candidates` from Turn A must be suppressed to `[]`;
- Turn B foreground remains unaffected.

If Turn A was regenerate/corrected/replaced so its GM hash no longer matches:

- no changes commit;
- no knowledge commit;
- no Agency handoff.

### 3.3 Make selection-only handoff complete

Every successful semantic terminal result that may legally expose Agency Selection must carry:

- `source_turn_index`;
- `source_gm_sha256`;
- validated/suppressed `agency_candidates`;
- `agency_dropped` where applicable.

This includes at minimum:

1. `changes=[]`, `knowledge_events=[]`, valid candidates;
2. parsed knowledge exists but all events are later dropped by stable actor allowlist, leaving no semantic/knowledge mutation;
3. other successful no-record paths that preserve a valid current Agency Selection.

Do not create fake world mutation merely to transport Agency Selection.

### 3.4 Application remains defensive

Keep Application's own latest/hash/foreground-idle validation before `start_cycle()`.

Do not weaken it merely because semantic flow now publishes complete identity.

## 4. Deterministic required proofs

Extend focused tests to prove at least:

### A. Fast player does not erase accepted semantic truth

```text
Turn A accepted
→ semantic A request active
→ player starts Turn B foreground
→ semantic A returns valid change + knowledge + candidates
```

Expected:

- A change/knowledge still materialize if A hash is unchanged;
- A candidates are suppressed / no A Agency starts;
- foreground Turn B remains usable and unblocked.

Also cover Turn B already accepted before A semantic completion if practical in the existing queue seam.

### B. Selection-only current turn starts Agency

```text
latest accepted Turn A, foreground idle
→ semantic response changes=[] / knowledge_events=[] / valid candidates
```

Expected:

- no semantic world mutation merely for empty changes/knowledge;
- result includes exact `source_gm_sha256`;
- Application validation accepts the handoff;
- Agency Cycle starts for the selected actor(s).

Use stubbed actor execution; no real Provider.

### C. All knowledge dropped does not erase valid selection

```text
changes=[]
knowledge_events=[unknown/non-roster actor]
agency_candidates=[valid stable NPC]
```

Expected:

- invalid knowledge dropped;
- no fake semantic mutation;
- source identity + valid candidates survive;
- current Agency can start.

### D. Actual source replacement still fails closed

```text
semantic A active
→ regenerate/correction replaces A GM text/hash
→ old semantic A completes
```

Expected zero old changes/knowledge/Agency.

### E. C01 race protections remain green

Re-run all M1/C01 focused tests, including Restore, unrelated-head invalidation, stale history filtering, same-turn cycle replacement, replay no-duplicate, and multi-actor concurrency.

## 5. Regression floor

At minimum:

- full G5-03 focused suite;
- G5-02 focused knowledge suite;
- G5-01 semantic materialization + timeline tests;
- directly affected G2 Conversation/Context tests;
- directly affected G3 Save/Restore tests;
- directly affected G4 continuation/application tests;
- `git diff --check`.

## 6. Real Provider

**DO NOT CALL A REAL PROVIDER.**

The parent M1 bounded real attempt is already exhausted/pending. This correction is deterministic orchestration semantics only.

## 7. Scope ceiling

Expected production changes should remain narrow, primarily:

- `src/世界回合/L2_流程层/语义物化流程.gd`;
- minimal Application/test changes only if required to prove the handoff.

Do not redesign Agency Cycle, actor execution, persistence, UI, Source, G5-03M2, Faction, G5-04 or mechanics.

## 8. Evidence

Create:

`docs/g5_03/G5-03M1C02_SEMANTIC_AGENCY_CURRENTNESS_SEPARATION_EVIDENCE.md`

Record:

- START_HEAD / FINAL_HEAD;
- changed paths;
- exact split predicates;
- proof that valid older accepted semantic truth still commits;
- proof that stale Agency selection is suppressed;
- proof selection-only current turn starts Agency with no fake semantic mutation;
- all-knowledge-dropped selection proof;
- actual replacement stale proof;
- regression results;
- `git diff --check` PASS;
- explicit no real Provider call.

## 9. Completion

Commit/push `origin/main` and return:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

Do not start G5-03M2 until GPT Independent Review passes M1.
