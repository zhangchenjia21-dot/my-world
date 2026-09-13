# TASK｜MW-033 R1｜P0 Source Tier Correction

Type: engineering correction  
Parent Work Item: **MW-033｜G7 Narrative Working-Set Orchestrator v0.1**  
Owner: Codex  
Revision: R1  
Review trigger: `docs/mw033/MW-033_INDEPENDENT_REVIEW_IR1.md`  
Formal implementation base: `e876e217f0220fdc6a577cd0b52143dc8d5b6b5c`  
Submitted candidate under review: `32cb5325b251c81ac8d883d5921edababe0d4cbf`  
R1 Starting HEAD: `73253db312c429a62bf610eed10f3a570b20b2d6`  
Required branch: `mw-033-g7-narrative-working-set`  
Required worktree: `D:/AI/Projects/.worktrees/my-world/mw-033-g7-narrative-working-set`  
Frozen architecture: `Vibe-Coding/my world/architecture/G7_NARRATIVE_WORKING_SET_ORCHESTRATOR_V0_1_DECISION.md@v1.0`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Correction outcome

Fix the single blocking MW-033 IR1 finding without redesigning the working-set Orchestrator:

> `game.opening_supplement` and selected Entry `opening_seed` are Opening/T0 background and must not remain inseparable required P0 continuation material.

After R1, ordinary Narrative continuation must still retain the frozen minimum Game/World identity + World/GM instructions as P0, while Opening-only/background bodies are separate atomic P2 source contributions that can be omitted under budget pressure.

## 2. Do not reopen already-passing MW-033 architecture

R1 must preserve the submitted candidate's reviewed-good behavior:

- one `src/context` Narrative continuation owner;
- validated 256k/1m runtime capacity metadata;
- `floor(context_token_ceiling * 0.80)` safe input byte budget;
- actual final serialized `messages` UTF-8 accounting;
- whole-block / whole-Turn selection only;
- latest Turn → current P1 domains → remaining Turns → P2 structural order;
- current Character / Threads / Experiences / People contributions;
- People player-known epistemic boundary;
- World/Knowledge/Agency/Evolution accepted-hash currentness;
- Inventory/mechanics ownership;
- Restore / Regenerate / reopen derivation;
- UI hide preference independence;
- repaired G3-03/G3-05 raw/stale leakage coverage;
- first Opening full frozen setup path;
- d20 Narrative-stage delegation;
- no durable Context cache / retrieval / embeddings / semantic ranking.

Do not turn R1 into a second implementation of MW-033.

## 3. Blocking defect to correct

Submitted `GameLocalOpeningContextProjector.project_continuation()` currently builds required P0 by calling existing Opening helpers:

```gdscript
_append_runtime_contract(required, setup)
_append_game(required, setup.game, setup.get("selected_entry_id"))
...
_append_world(required, [], world_without_semantic_sections, false)
```

Those helpers include:

- `Opening supplement` through `_append_game()`;
- selected Entry `Opening seed` through `_append_world()`.

That promotes P2 T0/Opening background into P0 and can make continuation fail `required_context_overflow` for background that the frozen design should simply omit.

## 4. Required production correction

Implement a **continuation-specific minimal P0 projection** inside the source/Opening domain owner.

Do not modify first Opening's existing `project()` semantics.

### 4.1 P0 may contain

Only the minimum source authority needed for continuation, including equivalent information for:

- durable Game-local authority framing;
- Game identity;
- selected Entry **identity** where one exists;
- control mode where required by current Narrative GM contract;
- World identity/name;
- World instructions;
- GM instructions;
- minimal exact-source provenance needed to preserve Game-local rather than mutable Source authority.

Keep this narrow. Do not reuse a helper merely because it already prints extra Opening fields.

### 4.2 P2 must contain Opening/T0 bodies

At minimum expose separate whole P2 source blocks for:

1. non-empty `game.opening_supplement`;
2. non-empty selected Entry `opening_seed`.

They must be clearly framed as starting/background material, not current lived truth.

Selected Entry ID/name can remain in required identity material; its `opening_seed` body cannot.

Existing P2 semantic sections / authored NPC source / style behavior should remain structurally unchanged unless a tiny refactor is required to share safe formatting.

### 4.3 Atomicity

Supplement/seed must be indivisible budget units:

- selected whole when they fit;
- omitted whole when they do not;
- never byte/character-truncated;
- diagnostics record their source family inclusion/omission through the existing safe family counters.

A new family name is not required. Prefer existing `source` unless there is a strong reason otherwise.

## 5. Focused correction tests

Extend `tests/mw033/` with explicit fixtures for the uncovered boundary.

### AC-R1-01｜Large opening supplement

Use a structurally valid exact frozen setup where:

- first Opening projector still succeeds;
- `opening_supplement` contains enough multi-byte Chinese text that forcing it into P0 would exceed the 256k safe input byte budget;
- minimal P0 itself is safely below budget.

Assert ordinary continuation:

- succeeds under 256k;
- does not return `required_context_overflow`;
- retains required P0 identity/instructions;
- retains current P1 Character / Thread / World fixture material;
- records the supplement as a considered P2/source unit;
- omits it whole under 256k pressure;
- contains no partial supplement prefix/suffix fragment.

If a supported 1m profile can fit the exact supplement, assert it is admitted whole there.

### AC-R1-02｜Large selected Entry opening seed

Use a valid selected Entry setup with a similarly large Chinese `opening_seed`.

Assert:

- selected Entry identity remains P0/current source identity;
- continuation succeeds under 256k;
- opening seed is P2 and is omitted whole when it cannot fit;
- current P1 continuity remains available;
- no partial seed is emitted;
- 1m admits it whole when deterministic fixture capacity permits.

### AC-R1-03｜First Opening exactness

For fixtures containing non-empty opening supplement and selected Entry seed, assert `start_first_opening()` still produces the existing full frozen first-Opening payload exactly.

No long-session omission logic may enter first Opening.

### AC-R1-04｜Small source background remains usable

A normal small opening supplement/seed should remain available to continuation as P2 when budget permits. R1 is reclassification, not silent deletion.

## 6. Regression / build gate

After focused R1 passes, rerun at minimum:

- complete MW-033 focused suite;
- G3-03 repaired Context suite;
- G3-05 repaired Recovery Context suite;
- G4 first Opening / created-Game continuation;
- Public d20 CHECK + NO_CHECK/degraded Narrative paths;
- current World Context/Knowledge/Agency/Evolution suites;
- MW-032 focused regression;
- the prior MW-033 relevant regression manifest (or a superset).

Then:

- Godot 4.7.2 final import;
- fresh Windows export;
- `run-game.ps1 -ValidateExportOnly`.

No real Provider call is required.

## 7. Worktree preservation

The R1 starting worktree is known to contain preserved import/UID sidecars and fixture import line-ending noise documented in:

`docs/mw033/evidence/preserved-import-artifacts.json`

Do not bulk clean, delete, normalize, stage or commit those files merely to obtain a clean status.

Before R1 changes, inspect status and distinguish known preserved artifacts from new work. R1 must commit only deliberate task files/product/test/evidence changes.

If a new unknown dirty product file appears, STOP rather than overwrite it.

## 8. Git discipline

- stay on `mw-033-g7-narrative-working-set`;
- no merge to `main`;
- no force push;
- commit R1 implementation and evidence;
- push remote branch;
- final candidate must descend from R1 Starting HEAD `73253db312c429a62bf610eed10f3a570b20b2d6`;
- refresh `my-world/main` + `Vibe-Coding/main` before final return and STOP on relevant governance/main drift.

## 9. Return requirements

Return highest status **READY FOR INDEPENDENT REVIEW** only after all required evidence passes.

Include:

- R1 Starting HEAD;
- R1 Implementation HEAD;
- R1 Final Candidate HEAD;
- remote tip confirmation;
- exact source-projection change summary;
- large opening supplement 256k/1m evidence;
- large selected Entry opening-seed 256k/1m evidence;
- first Opening exact-payload evidence;
- focused total;
- G3-03/G3-05 results;
- regression manifest;
- import/export/ValidateExportOnly results;
- real Provider call count;
- preserved-sidecar status / any new dirty files;
- deviations/risks.

Do not claim Product PASS, G7 completion, or integration approval.