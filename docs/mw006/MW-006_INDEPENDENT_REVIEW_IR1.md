# MW-006 — Independent Review IR#1

Work Item: `MW-006`
Name: Mechanics-Grounded World Consequence Vertical
Capability-Anchor: `G5-05 Meaningful Choice / Mechanics Integration`
Revision: `1`
Review-Round: `IR#1`
Implementer: Zcode + GLM-5.3-flash (Owner task-local routing override)
Reviewer: GPT
Implementation SHA: `adb3ca45c2e869c7685915de18664ee3ce7e6f39`
Implementation Base: `5809cf2c3f03556acd388117b8e2079658a92629`
Date: 2026-09-05
Verdict: **ENGINEERING PASS / CLOSED**

## 1. Contract basis

The intended repository Task Packet was not present when implementation began because GPT failed to propagate it into the repository. This is a governance propagation omission, not an implementation defect.

For Revision 1, the authoritative executable contract is the Owner-authorized GPT launch instruction issued in the project conversation on 2026-09-05. IR#1 explicitly accepts that instruction as the contract baseline. A repository-native backfill is recorded separately and must not be misread as a pre-existing implementation input.

The core contract was:

```text
existing authoritative CHECK_REQUIRED durable resolution
→ bounded causal grounding context
→ existing normal G5-01 semantic opportunity
→ model still authors 0..N durable world consequences
```

Protected boundaries:

```text
Mechanical Resolution
= authoritative check fact

!= hardcoded world consequence
!= SUCCESS/FAILURE effect table
!= second mechanics truth
!= Narrative gate
```

`NO_CHECK` must remain the ordinary no-fake-mechanics path. Narrative acceptance must remain free-form and independent from semantic success.

## 2. Independent inspection performed

IR#1 inspected the actual pushed commit/diff and production files, rather than relying on the implementer handoff alone:

- `src/行动判定/L0_公理层/公开D20判定规则.gd`
- `src/世界回合/L2_流程层/语义物化流程.gd`
- existing `src/行动判定/L2_流程层/公开D20行动判定流程.gd`
- existing Application/WorldTurn signal wiring
- `tests/mw006/机制锚定世界后果垂直测试.gd`
- `docs/mw006/MW-006_MECHANICS_GROUNDED_CONSEQUENCE_EVIDENCE.md`
- the pre-existing G3-04 persistence test and MW-004 GM instruction relevant to the reported baseline failure

Remote commit status/workflow inspection found no independent GitHub CI run for this commit. Therefore test/export execution results below are accepted as implementation evidence after code/test inspection, but were not independently rerun by GPT.

## 3. Findings

### F01 — Existing Public d20 remains the single mechanics truth — PASS

`matching_accepted_check_for_turn()` is a read-only projection over the existing durable `world_state.expansion_runtime.public_d20_checks[]` record. It creates no second store, summary object, table, mutation family, or alternate resolution.

A candidate is eligible only when:

- `narrative_accepted == true`;
- `accepted_turn_index` equals the semantic source turn;
- `player_text` exactly equals the accepted Player action.

Zero or multiple matches return an empty object. Ambiguity therefore loses optional grounding rather than guessing mechanics authority.

### F02 — CHECK_REQUIRED lifecycle ordering is safe — PASS

The existing Public d20 process persists the Program-owned roll/result before starting the resolution Narrative. After the Narrative is durably accepted, `generation_completed` synchronously wakes WorldTurn, but WorldTurn only queues the semantic version and invokes `_drain_queue.call_deferred()`.

The Public d20 process then synchronously writes `narrative_accepted` and `accepted_turn_index` onto the durable check before the deferred semantic request is assembled. Therefore the normal semantic request sees the accepted marker when grounding is available.

If the marker write fails, the semantic request deliberately receives no mechanical block. This is correct fail-soft behavior: accepted Narrative and durable mechanics are not fabricated or rewritten merely to improve grounding coverage.

### F03 — Mechanical grounding is request-only and bounded to the existing semantic lane — PASS

`_analysis_messages()` conditionally appends one derived block titled `Durable Mechanical Resolution (Program-owned authoritative truth)` using the unique matched durable check. The block is not persisted as a second mechanics truth.

The semantic instruction explicitly says the Program result may not be changed, rerolled, or invented, while also stating that success/failure itself does not map to a fixed world consequence. Consequences remain limited to facts supported by the accepted Narrative.

No additional semantic opportunity, replay protocol, parser gate, Narrative rejection, or retry mechanism was introduced.

### F04 — No hardcoded outcome → world-effect mapping — PASS

The production diff contains no branch or table that turns `success` or `failure` directly into a world mutation. The only durable consequence path remains the existing G5-01 semantic materialization seam.

This preserves the intended authority split:

```text
Program owns the check result.
Model/Narrative owns what that result concretely meant in this scene.
G5-01 materializes only accepted, supported consequences.
```

### F05 — NO_CHECK and ordinary non-mechanics paths remain clean — PASS

The grounding lookup reads only `public_d20_checks[]`. Existing `public_d20_no_check_actions[]` records are not converted into fake rolls or mechanical facts. Ordinary turns without the Expansion similarly receive no grounding block.

### F06 — Replay / reopen / malformed semantic handling remains fail-soft — PASS

Focused tests cover same-version replay and fresh-worker reopen without a second semantic mutation, as well as malformed semantic output leaving the accepted Narrative and durable check untouched.

The existing Public d20 durable action identity and recovery path remain responsible for reroll prevention; MW-006 adds no RNG path.

### F07 — G5-04, Actor Knowledge, MW-005 and persistence authority boundaries remain intact — PASS

The implementation changes neither the World Evolution evaluator nor its `project_world_only()` input, and does not route the raw mechanical block directly into G5-04.

It also does not create Player/Actor Knowledge, read mutable Source current, modify the Three Kingdoms literary-style path, or change SQLite schema/tables/migrations.

Any later World Evolution visibility occurs only through an ordinary G5-01 committed world consequence, which is the intended causal chain.

### F08 — Focused proof is materially aligned with the contract — PASS

The focused test verifies:

- one CHECK_REQUIRED grounding block per semantic request;
- exact durable check facts in the request;
- model-authored semantic output committing through the existing living-world mutation seam;
- `expansion_runtime` mechanics truth remaining unchanged;
- NO_CHECK and ordinary paths receiving no fake block;
- replay/reopen idempotence;
- malformed semantic output creating no fake mutation;
- missing acceptance marker, text mismatch, and duplicate matches failing closed.

The implementer reports 20/20 focused assertions PASS plus the relevant d20/G5 regressions and Windows export validation PASS. Real Provider calls were 0.

## 4. Baseline regression finding

`tests/g3_04/存档恢复持久化测试.gd` contains an old assertion that fails if the first system message contains the literal text `Current Game Context`.

The current baseline `src/context/上下文组装器.gd` already contains that literal inside MW-004's legitimate Light control-mode explanation, so the failure is pre-existing at `5809cf2` and unrelated to MW-006. MW-006 does not modify either file.

This is a stale regression assertion and should be repaired separately; it is not a MW-006 blocker.

## 5. Non-blocking advisories

### A01 — accepted turn + exact Player text is intentionally fail-closed, but somewhat lossy

The new reader links semantics to mechanics using `accepted_turn_index + exact player_text` plus the accepted marker. This is safe for Revision 1 because ambiguity returns no block. If a later durable contract exposes a stronger explicit semantic-turn/action binding without redesigning Public d20, that stronger key would be preferable. No follow-up platform work is authorized by this advisory.

### A02 — governance artifacts were missing

The missing MW-006 Task Packet and G5-04 closeout are governance debt caused by GPT propagation, not by Zcode. They should be backfilled with explicit historical provenance rather than pretending they existed before implementation.

### A03 — no independent CI/Godot rerun in IR environment

GitHub exposes no CI status/workflow run for `adb3ca45...`. IR#1 therefore distinguishes actual code/diff inspection from implementer-executed Godot/export evidence. This does not invalidate the engineering verdict because the focused test logic and affected production seams were independently inspected and no blocking discrepancy was found.

## 6. Verdict

```text
Work Item: MW-006
Revision: 1
Review-Round: IR#1
Verdict: ENGINEERING PASS / CLOSED
```

MW-006 successfully establishes the first G5-05 vertical: existing authoritative Public d20 facts can ground the normal semantic materialization lane without becoming a second mechanics truth, hardcoded consequence engine, Narrative gate, G5-04 shortcut, or fake NO_CHECK mechanics.

This closes **MW-006**, not the whole G5-05 capability. `G5-05 Meaningful Choice / Mechanics Integration` remains active for subsequent product/architecture work.
