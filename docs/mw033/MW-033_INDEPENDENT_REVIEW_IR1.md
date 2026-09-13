# MW-033｜Independent Review IR1

Status: **ENGINEERING CORRECTION REQUIRED**  
Work Item: **MW-033｜G7 Narrative Working-Set Orchestrator v0.1**  
Review Round: **IR1**  
Reviewer: **GPT**  
Product UAT: **DEFERRED — later concentrated MW-032 + G7 long-session test**

## 1. Exact review identity / freshness

Reviewed task branch:

`mw-033-g7-narrative-working-set`

Reviewed submitted candidate:

`32cb5325b251c81ac8d883d5921edababe0d4cbf`

Production implementation commit:

`d6ebe8ca2ac23ec589ca266c104470888e6daa4f`

Task Packet / Starting HEAD:

`dc6c46d952ba0b63a8f713e9388896969cd71f7d`

Formal implementation base / current `my-world/main` at review:

`e876e217f0220fdc6a577cd0b52143dc8d5b6b5c`

Current governance `Vibe-Coding/main` at review:

`fc27679efee3988e2352e52664b2b46139a9223a`

Freshness check independently confirms:

- implementation `main` has not advanced beyond MW-033 Formal Base;
- remote task branch tip is exactly the submitted candidate;
- candidate is a clean two-commit lineage from Task Packet: implementation + evidence/report;
- frozen `G7_NARRATIVE_WORKING_SET_ORCHESTRATOR_V0_1_DECISION.md@v1.0` remains current;
- Current Status v18.1 still authorizes MW-033 and no conflicting Decision Propagation exists.

No freshness/integration-lineage blocker exists.

## 2. Verdict

**ENGINEERING CORRECTION REQUIRED.**

The central MW-033 architecture is materially present and most engineering evidence is strong, but one frozen structural-priority invariant is violated in the production source projection.

The candidate is **not approved for integration yet**.

Required correction is narrow and remains inside MW-033 lineage. There is no reason to redesign the Orchestrator, reopen G6, add retrieval, or broaden Package 8.

## 3. Blocking finding

### F01｜Opening-only source material is incorrectly classified as required P0 continuation context

**BLOCKING — correction required.**

Frozen MW-033 architecture defines:

```text
P0 REQUIRED
→ GM/system protocol
→ current Player attempt/input mode
→ minimum current Game/World identity + instructions needed to interpret the Game

P2 DURABLE BACKGROUND
→ Important Experiences
→ current People
→ selected T0 semantic/source background
→ Guaranteed NPC authored source background
→ literary style reference
```

The Task Packet repeats the same boundary: P0 is the **minimum Game/World identity + World/GM instructions**; broad T0/source background belongs to P2 and may be omitted whole under pressure.

Production `GameLocalOpeningContextProjector.project_continuation()` does correctly split semantic sections into P2 blocks, but builds its P0 block by reusing:

```gdscript
_append_runtime_contract(required, setup)
_append_game(required, setup.game, setup.get("selected_entry_id"))
...
_append_world(required, [], world_without_semantic_sections, false)
```

Those existing Opening helpers carry more than the frozen P0 minimum:

- `_append_game()` always includes `Opening supplement`;
- `_append_world()` includes the selected Entry `Opening seed` when an Entry exists.

Therefore these two pieces of **Opening/T0 background** become inseparable required P0 continuation material.

That is not only a naming concern.

### Product/currentness consequence

`opening_supplement` and selected Entry `opening_seed` describe starting/opening material. Forcing them into every future Narrative request gives first-scene inertia higher authority than the frozen long-session policy intended.

A long Game can therefore keep re-injecting opening-specific material even after current Character / Threads / World consequences have moved well beyond it.

This directly cuts against MW-033's purpose:

> current continuity should take priority over broad starting-source inertia.

### Budget/failure consequence

`FirstOpeningRules.validate_setup()` validates structure but does not impose a small byte bound on either field. The full first-Opening projector has a 180,000-character aggregate guard, while MW-033 continuation uses the deliberately conservative 256k safe input limit of 209,715 UTF-8 bytes.

A legitimate frozen Game can therefore contain a Chinese opening supplement or opening seed that:

- was valid as first-Opening source material;
- is not needed as P0 identity/instruction material for every future Turn;
- alone exceeds the conservative continuation P0 byte budget;
- causes `required_context_overflow` and **zero Narrative Provider start**;
- would have been safely handled by the frozen design if classified as an omittable P2 atomic block.

In other words, the candidate can fail a continuation because optional T0 background was accidentally promoted to mandatory authority.

### Why 107/107 did not catch this

The dedicated production-shaped fixture uses:

```text
selected_entry_id = null
opening_supplement = empty/default
```

Its 100,000-character T0 pressure is placed in a World semantic section, which the implementation correctly classifies as P2. That proves the P2 selection machinery, but does not exercise the two Opening-helper fields still leaking into P0.

The focused P0 overflow tests use an oversized **current attempt** and an artificial **required World instruction**, both of which are legitimately P0. Those tests therefore cannot detect this classification error.

## 4. Required correction

Keep the existing Context Orchestrator and selection algorithm.

Correct only the continuation source decomposition so P0 contains the frozen minimum, while Opening/T0 content is budgetable P2.

Required direction:

### P0 minimum

Keep only structurally necessary current Game/source interpretation material such as:

- durable Game-local / selected Entry **identity**;
- Game identity / control mode where the existing Narrative contract needs it;
- World identity;
- World instructions;
- GM instructions;
- minimal provenance/authority framing required to keep the frozen Game-local source exact.

Do not require a broad T0 narrative payload merely because an existing Opening helper prints it.

### P2 source background

At minimum move these out of P0:

1. `game.opening_supplement` when non-empty;
2. selected Entry `opening_seed` when non-empty.

Represent them as whole, clearly labelled T0/source background blocks so they:

- remain exact when selected;
- can be omitted atomically under budget pressure;
- do not get truncated;
- do not become current World truth;
- do not alter first Opening behavior.

Existing semantic source sections, authored NPC background and literary style remain under the already-reviewed P2 policy.

Do **not** solve F01 by deleting these fields from first Opening or by making them current semantic truth.

## 5. Required correction evidence

Add focused evidence that specifically fails on submitted candidate semantics and passes after correction.

At minimum:

### AC-R1-01｜Large opening supplement is not P0

Create a structurally valid Game-local setup whose first Opening projection is valid but whose non-empty Chinese `opening_supplement`, if forced into P0, would exceed the 256k safe input byte budget.

For continuation:

- assembly must succeed;
- P0 must remain under budget;
- current P1 Character / Thread / World material must remain eligible/present;
- opening supplement must be recorded as P2/source and omitted whole under 256k pressure rather than causing `required_context_overflow`.

### AC-R1-02｜Large selected Entry opening seed is not P0

Use a valid selected Entry fixture with an analogous large `opening_seed`.

Continuation must likewise succeed with the seed treated as atomic P2 background.

Selected Entry identity must remain in P0 without requiring its opening seed body.

### AC-R1-03｜Capacity expansion remains deterministic

Where the fixture fits a supported 1m budget, the same P2 supplement/seed may be admitted whole according to stable source order. No semantic ranking is required.

### AC-R1-04｜First Opening unchanged

Re-prove first Opening still receives the full exact frozen material, including opening supplement / selected Entry opening seed when present.

The fix must affect continuation decomposition only.

### AC-R1-05｜No collateral regression

Re-run MW-033 focused evidence, directly affected G4 created-Game/Opening + d20 Narrative paths, G3 repaired Context tests, current MW-032 regression, broad relevant manifest, final Godot import, fresh Windows export and `ValidateExportOnly`.

No live Provider call is required.

## 6. Areas independently reviewed as PASS

Subject to F01 correction, the following parts of the submitted candidate are sound.

### F02｜Single production Narrative working-set owner — PASS

Ordinary created-Game continuation delegates through `ContextAssemblyPublicInterface.assemble_session()`.

The Context family owns request composition/budget/selection only. Source, Curation, World, Inventory and Mechanics contribute through public/domain-owned seams; no second durable Context database or semantic truth owner was introduced.

The Public d20 CHECK/NO_CHECK/degraded **Narrative stages** also delegate to the same Narrative Context owner while control/control-recovery remains on its pre-existing mechanics protocol. This is a justified narrow compatibility hook, not a universal all-agent Context framework.

### F03｜Current Curation contribution — PASS

The new Information Curation Narrative projection uses existing current projections for:

- Character;
- Important Experiences;
- People;
- Open Threads.

It does not consume UI hide/recover preferences, presentation keys, subject/thread IDs or request refs.

People is explicitly labelled as player-known memory/reputation and does not create World actor truth.

### F04｜Working-set budget / atomic selection — PASS

The Orchestrator uses validated runtime model capacity and computes:

```text
safe input bytes = floor(context_token_ceiling × 0.80)
```

Candidate evaluation measures the actual serialized `messages` array with UTF-8 JSON accounting.

Independent code review confirms:

- P0 is checked before Provider use;
- P1/P2 candidates are added only when the resulting complete message payload fits;
- accepted Turns are selected as complete units;
- selected Turns are rendered chronological;
- no partial card/Turn/section slicing or Program semantic score is introduced.

Evidence demonstrates an exact 209,715-byte boundary and whole-card omission at +1 byte.

### F05｜Current continuity priority — PASS apart from F01 source classification

The actual selection sequence is:

```text
latest complete accepted Turn
→ current P1 domain blocks
→ remaining accepted Turns newest-first
→ P2 background
```

This prevents transcript or ordinary P2 semantic sections from starving all current Character/Threads/World material.

The 256k fixture keeps current P1 material while omitting a 300,147-byte source block; 1m admits the broader background and all 21 accepted Turns.

### F06｜Restore / Regenerate / reopen currentness — PASS

Focused production-shaped evidence proves:

- displaced future transcript / Curation / World contribution enters before Restore, then disappears afterward;
- reopen reconstructs the same current request without a persisted Context/Provider-message cache;
- accepted Regenerate replacement invalidates the old GM-hash-bound World contribution.

No displaced-future Context cache was found.

### F07｜G3 assertion repair — PASS

G3-03 and G3-05 no longer prohibit legitimate derived Game Context.

They retain stronger coverage for:

- `provider_messages` / `accepted_turns_json` / `materialization_json` exclusion;
- opaque canary exclusion;
- displaced Recovery branch exclusion;
- current accepted Conversation isolation;
- fresh request derivation after reopen/recovery.

The tests are green for the intended raw/stale-leak boundary rather than being deleted or expected-failed.

### F08｜First Opening implementation path — PASS, correction must preserve it

The original first Opening method remains on the existing full frozen Game-local projector and `assemble_first_opening_messages()` path. MW-033 continuation routing does not replace first Opening with working-set omission logic.

### F09｜Scope discipline — PASS

No vector DB, embeddings, semantic similarity retrieval, durable Context cache/table, universal memory platform, generalized JSON repair/retry middleware, Package-9 epistemic system, Provider routing redesign, output `max_tokens` cap, Creator protocol or UI redesign was introduced.

## 7. Test / build evidence reviewed

Submitted evidence is internally consistent apart from the uncovered F01 case:

- MW-033 focused: **107 checks / 0 failures**;
- direct relevant regression manifest: **49 / 49 suites exit 0**;
- G3-03/G3-05 repaired assertions pass;
- real-window gate: **484 / 484** at 960×540 / 1280×720 / 1920×1080;
- 256k working set: `198976 / 209715` bytes;
- 1m working set: `714501 / 838860` bytes;
- exact safe-bound test: `209715 / 209715` bytes;
- +1-byte optional card: whole block omitted;
- Godot `4.7.2.stable.official.ed1daf0bf` final import: exit 0;
- fresh Windows export + `run-game.ps1 -ValidateExportOnly`: exit 0;
- real Provider calls: **0**.

The five disclosed ObjectDB/resource-at-exit warning suites all exit 0 with no failing checks. They remain non-blocking known engineering debt.

## 8. Local worktree / preserved sidecars

**NON-BLOCKING NOTE.**

The local task worktree was not reported completely clean because an automatic bulk-cleanup command was rejected and therefore never executed.

The committed evidence enumerates:

- 11 untracked Godot import/UID sidecars;
- 13 fixture `.import` files whose Git-normalized content equals HEAD.

None appears in the candidate diff from Task Packet to `32cb5325...`; no uncommitted production change is part of the reviewed candidate.

Independent integration must continue to operate on committed remote lineage. Do not clean, delete, normalize or commit those unknown local artifacts merely to make `git status` cosmetically clean.

This note does not authorize overwriting the task worktree.

## 9. Product evidence boundary

Real Provider calls remain **0**. Therefore this review does not claim that a live model's long-session coherence, salience or latency is Product PASS.

After MW-033 engineering correction/re-review/integration, collect production-shaped diagnostics and continue the frozen G7 route. Owner Product validation remains deferred to the planned concentrated MW-032 + G7 test boundary.

## 10. Integration authorization

**NOT AUTHORIZED in IR1.**

Do not fast-forward `main` to submitted candidate `32cb5325b251c81ac8d883d5921edababe0d4cbf`.

Required route:

```text
MW-033 R1 narrow P0 source-tier correction
→ Codex READY FOR INDEPENDENT REVIEW
→ GPT re-review
→ reviewed non-force integration only if the corrected candidate passes
```

No Owner build/UAT is required between IR1 and the narrow engineering correction.