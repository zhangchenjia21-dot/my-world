# MW-033 R1｜Independent Review IR2

Status: **ENGINEERING PASS_WITH_NOTES**

Reviewer: GPT  
Parent Work Item: **MW-033｜G7 Narrative Working-Set Orchestrator v0.1**  
Correction Revision: **R1｜P0 Source Tier Correction**  
Formal Code Base: `e876e217f0220fdc6a577cd0b52143dc8d5b6b5c`  
Original MW-033 Starting HEAD: `dc6c46d952ba0b63a8f713e9388896969cd71f7d`  
Original submitted candidate: `32cb5325b251c81ac8d883d5921edababe0d4cbf`  
IR1 / correction lineage tip before R1 implementation: `9697d6398ebbf059a4067205ce935d705ff292c4`  
R1 Implementation HEAD: `03a226396e14baf1ee780d9b145a72e148e6187e`  
R1 Submitted Final Candidate: `4bd29c13be6da8e3e8c3b299c76122a1de97ba68`  
Frozen architecture: `Vibe-Coding/my world/architecture/G7_NARRATIVE_WORKING_SET_ORCHESTRATOR_V0_1_DECISION.md@v1.0`

## 1. Freshness / lineage

Independent re-review refreshed all authoritative refs before verdict:

- implementation `my-world/main` remains exactly `e876e217f0220fdc6a577cd0b52143dc8d5b6b5c`;
- task branch remote tip is exactly submitted R1 candidate `4bd29c13be6da8e3e8c3b299c76122a1de97ba68`;
- governance `Vibe-Coding/main` remains `886a8f3c4a06c9292080a0642636f31b90849a3b`, Current Status v18.2 requiring this R1 correction;
- `9697d639... → 4bd29c13...` is two linear commits: one production/test correction (`03a226...`) followed by evidence/return (`4bd29c...`);
- no implementation-main advance, governance supersession, force rewrite or branch divergence was found.

The submitted R1 therefore remains reviewable against the exact authorized correction lineage.

## 2. IR1 blocking finding — CLOSED

IR1 found that continuation P0 incorrectly reused Opening helpers and therefore promoted:

- `game.opening_supplement`;
- selected Entry `opening_seed`;

into inseparable required continuation material.

R1 fixes exactly that boundary.

`project_continuation()` now builds a continuation-specific P0 containing the durable Game-local authority framing plus:

- Game ID / display identity;
- control mode;
- selected Entry identity;
- World identity/name;
- exact source provenance;
- World instructions;
- GM instructions.

The Opening supplement and selected Entry opening seed are emitted separately as `tier=2`, `family=source` atomic T0 background blocks explicitly labeled as starting/background material rather than current lived truth.

The full First Opening projector path is untouched.

This matches the frozen architecture:

```text
P0 = minimum Game/World identity + instructions
P1 = current continuity
P2 = durable T0/source background
```

No semantic ranking or new Context owner was introduced.

## 3. Large Opening supplement pressure — PASS

The new focused fixture uses an 80,000-Chinese-character Opening supplement (~240 KB UTF-8) which remains valid under the existing full Opening character guard but is too large for the 256k profile's frozen safe input budget.

Reviewed evidence:

- 256k token ceiling = `262144`;
- safe input budget = `209715` bytes;
- supplement body = `240030` bytes;
- continuation **succeeds** rather than `required_context_overflow`;
- required Entry/Game/World identity and current Character/Thread/World contributions remain present;
- source diagnostics show 2 source units considered, 1 included, 1 omitted by `budget`;
- final messages = `3382 / 209715` bytes;
- large supplement is omitted as a whole unit;
- the small companion Entry seed remains included;
- at 1m (`838860` safe input bytes), both exact source units are included and final messages are `243489` bytes.

The original IR1 failure mode is therefore directly falsified by production-path evidence.

## 4. Large selected Entry opening seed pressure — PASS

A symmetric valid fixture makes selected Entry `opening_seed` the ~240 KB background body.

Reviewed focused evidence proves:

- selected Entry ID/name remain in required P0;
- seed body is absent from P0;
- 256k continuation succeeds and retains current P1 material;
- the seed is omitted as one whole P2 source unit;
- no prefix/suffix fragment is emitted;
- 1m admits the full exact seed while remaining within final request budget.

This closes the second half of IR1 F01 without weakening selected Entry identity continuity.

## 5. Small supplement / seed behavior — PASS

R1 is a reclassification, not silent deletion.

The small-source fixture proves that when budget permits:

- non-empty Opening supplement remains available to continuation;
- selected Entry opening seed remains available to continuation;
- both are selected as P2 source blocks in 256k and 1m profiles;
- final payload stays under the exact serialized-message budget.

Therefore R1 preserves useful T0 inertia while making it budget-optional.

## 6. First Opening exactness — PASS

For each R1 fixture, including non-empty supplement + selected Entry seed, the real `start_first_opening()` stub request is compared against the unchanged full `GameLocalOpeningContextProjector.project()` + `assemble_first_opening_messages()` path.

Evidence proves:

- First Opening still receives both complete bodies;
- First Opening remains under its existing full frozen Game-local setup semantics;
- long-session P2 omission logic is not used by First Opening.

No regression of the frozen first-scene grounding contract was found.

## 7. Original MW-033 architecture remains intact — PASS

R1 production change is limited to continuation source classification. The independently reviewed-good MW-033 design remains unchanged:

- one `src/context` Narrative continuation owner;
- validated runtime 256k / 1m capacity source;
- `floor(context_token_ceiling * 0.80)` safe input-byte policy;
- exact final serialized `messages` UTF-8 accounting;
- whole-block / whole-Turn omission only;
- current Character / Threads / Experiences / People working-set contributions;
- People remains player-known information, not actor truth;
- World/Knowledge/Agency/Evolution accepted-hash currentness remains domain-owned;
- Inventory/mechanics remain domain-owned;
- Restore / Regenerate / reopen derive fresh current working sets;
- UI hide preferences do not affect model Context;
- repaired G3 raw/stale leakage boundary remains green;
- no durable Context cache, embeddings, retrieval, semantic ranking or universal all-agent Context platform.

No scope expansion was found in R1.

## 8. MW-028 fixture correction audit — PASS

R1 also changes `tests/mw028/系统机制纵向验证.gd` by adding empty `semantic_sections` arrays to its World and Player source fixtures.

This is accepted as a test-fixture correction, not regression masking, because independent evidence records the pre-R1 projector returning the same `invalid_game_setup` on that inherited fixture before the source-tier fix. Production validation was not relaxed.

The changed fixture now conforms to the already-current frozen source shape while preserving all MW-028 existing mechanics assertions. Final MW-028 evidence reports **377 / 377** passing checks.

No product behavior was altered to make MW-028 green.

## 9. Focused / regression evidence — PASS_WITH_NOTES

R1 complete MW-033 focused suite:

- **206 checks / 0 failures**;
- real Provider calls: **0**.

The focused suite includes the original MW-033 working-set/currentness/budget tests plus the explicit R1 supplement/seed pressure cases.

Final relevant regression manifest:

- **49 / 49 suites pass**;
- G3-03 and G3-05 remain passing with the stronger raw/stale-leak assertions;
- G4 first Opening/continuation pass;
- Public d20 CHECK / NO_CHECK / degraded Narrative pass;
- G5 World/Knowledge/Agency/Evolution/currentness pass;
- MW-032 passes;
- no retained failing suite.

Five previously known suites continue to emit the same bounded ObjectDB/resource-at-exit warning family (two warning lines each): G4-07B, G4-08B, G5-03, G5-04, MW-003. No warning suppression or evidence of R1 amplification was found.

## 10. Build / export — PASS

Final evidence records:

- Godot `4.7.2.stable.official.ed1daf0bf` final import exit 0;
- fresh Windows export exit 0;
- `run-game.ps1 -ValidateExportOnly` exit 0;
- game launch skipped;
- final PCK SHA256 `ac6bf6b7d6625a16b84683031b8605141ad16e95b81e68240c04ffd2ec1363f3`;
- export built from the R1 Implementation HEAD product inputs;
- evidence commit changes no product input bytes.

No Owner build installation or Owner real-data mutation occurred.

## 11. Preserved worktree artifacts — NON-BLOCKING NOTE

The worktree remains intentionally not fully clean because of the previously documented import/UID sidecars and tracked fixture import normalization noise.

R1 records before/after preservation evidence for all 24 known artifacts and reports them byte-identical across implementation, testing and export. None are part of the deliberate R1 production/test commit except the explicit task files already reviewed.

This is not a reason to bulk clean or delete local files and is not an integration blocker because reviewed Git lineage/product bytes are fully identified.

## 12. Remaining notes / Product evidence

### N-01｜Live long-session model quality remains unproven

Real Provider calls remain `0`. Engineering proves the structural working-set contract, budget/currentness behavior and deterministic omission; it does not prove that a live GM feels coherent after long play.

### N-02｜P2 omission is intentionally structural

Under pressure, useful source/People/Experience background may be omitted because v0.1 deliberately avoids semantic ranking/retrieval. Diagnostics expose the omission. Whether a later G7 slice needs semantic retrieval/source recall must be decided from actual long-session evidence rather than pre-emptive platform work.

### N-03｜Existing teardown warnings remain debt

The five bounded warning suites remain non-blocking unless later evidence shows growth, corruption or product impact.

## 13. Verdict

**ENGINEERING PASS_WITH_NOTES**

IR1's only blocking architecture defect is closed. No new blocking defect was found in R1.

The full reviewed MW-033 lineage is safe for **reviewed non-force fast-forward integration** from implementation `main@e876e217f0220fdc6a577cd0b52143dc8d5b6b5c` through the final R1 review commit, provided pre-integration freshness remains unchanged.

This verdict is **not Product PASS** and does not declare G7 Package 8 complete.

After integration, the correct next action is to inspect MW-033 production-shaped diagnostics/evidence and shape the next bounded G7 slice rather than immediately requesting Owner UAT.