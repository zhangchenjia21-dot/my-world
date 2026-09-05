# MW-006 — Mechanics-Grounded World Consequence Vertical

> **Governance backfill recorded after implementation.**
>
> This file did **not** exist when Zcode + GLM-5.3-flash implemented Revision 1. Due to a GPT governance-propagation omission, the authoritative executable contract for Revision 1 was the Owner-authorized GPT launch instruction issued in the project conversation on 2026-09-05. IR#1 explicitly accepted that conversation instruction as the contract baseline. This file records that contract for future repository-native lineage and must not be cited as a pre-implementation input.

Work Item: `MW-006`
Name: Mechanics-Grounded World Consequence Vertical
Capability-Anchor: `G5-05 Meaningful Choice / Mechanics Integration`
Authorized-By: Owner
Implementer: Zcode + GLM-5.3-flash (task-local routing override)
Reviewer: GPT
Parallel-With: `MW-005`
Revision: `1`
Review-Round: `IR#1`
Implementation SHA: `adb3ca45c2e869c7685915de18664ee3ce7e6f39`
Status: **ENGINEERING PASS / CLOSED**

## Outcome

Connect the already-authoritative Public d20 resolution to the existing G5-01 semantic-materialization opportunity as bounded causal grounding, so that durable world consequences can respect the mechanical result without turning mechanics into a hardcoded consequence engine.

```text
Player action
→ existing Public d20 adjudication

CHECK_REQUIRED
→ existing frozen Proposal
→ existing Program-owned durable d20 resolution
→ existing free-form final GM Narrative
→ existing G5-01 semantic opportunity
   + bounded authoritative mechanical grounding
→ model authors 0..N newly-established consequences
→ existing World Turn / mutation / Timeline
```

## Authority contract

```text
Mechanical Resolution
= authoritative check fact

!= hardcoded world consequence
!= SUCCESS/FAILURE effect table
!= second mechanics truth
!= Narrative gate
```

Program owns the check fact. Narrative/model reasoning owns what the result concretely means in the scene. G5-01 may only materialize consequences established by the accepted Narrative.

## Required behavior

- Reuse the existing durable CHECK_REQUIRED resolution as the sole mechanics truth.
- Feed it into the **normal existing** G5-01 semantic opportunity as request-time grounding only.
- The grounding must be bounded and must not create a second durable mechanics representation.
- The semantic model remains free to return `0..N` durable consequences supported by the accepted Narrative while respecting the Program-owned result.
- `NO_CHECK` must receive no fake roll/result/mechanics block.
- Ordinary non-Expansion paths must remain unchanged.
- Malformed/failed semantic analysis remains fail-soft:

```text
accepted Narrative remains accepted
+
durable mechanical result remains authoritative
+
no fake world mutation
```

- retry / reopen / Restore / late callbacks / currentness / idempotence keep existing semantics.
- existing Public d20 RNG and reroll-prevention contracts remain unchanged.

## Explicit non-scope / prohibitions

Do **not** add:

- `SUCCESS → X` / `FAILURE → Y` world-effect tables or branches;
- a second mechanics summary/store/source of truth;
- rerolls;
- mandatory checks for all Player actions;
- a new Narrative protocol;
- semantic classifier gates;
- Narrative rejection or retry loops;
- extra semantic replay opportunities;
- a generic rules/mechanics platform;
- UI work;
- SQLite schema/table/migration changes;
- direct raw mechanics injection into G5-04 World Evolution;
- changes to MW-005 `literary_style_reference` authority semantics;
- mutable Source-current reads.

If the production ordering could not safely deliver the existing durable resolution into the normal G5-01 opportunity without Public-d20 redesign, schema migration, extra semantic replay, a second mechanics truth, or a generic platform, implementation was required to STOP and report a blocker.

## Required audit before coding

### Pass A — Producer / lifecycle

Trace actual production code for:

- CHECK_REQUIRED proposal → freeze → RNG → durable resolution → final Narrative → accepted Conversation → semantic wake;
- NO_CHECK lifecycle;
- retry / reopen / Restore;
- the owner and identity of the durable mechanical result;
- exact semantic-context assembly timing;
- whether one accepted Player action maps to one normal semantic opportunity.

### Pass B — Consumer / authority

Audit:

- all Public-d20 resolution consumers;
- all G5-01 semantic-context consumers;
- duplicate mechanics-truth risk;
- G5-04 causal input;
- Actor Knowledge;
- MW-005 literary-style path;
- mutable Source-current access.

## Required focused proof

At minimum:

1. CHECK_REQUIRED existing durable resolution appears exactly once in semantic request/context.
2. Deterministic fake semantic output can materialize a durable consequence through the existing seam.
3. NO_CHECK has no fake mechanics block and stays on its existing path.
4. Same-action retry/reopen does not reroll and does not duplicate semantic mutation.
5. Malformed semantic result does not change accepted Narrative or durable mechanics and creates no fake mutation.
6. Restore/currentness/late-callback behavior remains correct.
7. SQLite schema/table/migration is unchanged.
8. Public d20, G5-01, minimum relevant G5-04 and Save/Restore regressions are run.
9. `git diff --check` is clean.
10. Real Provider calls default to 0.
11. Production GDScript changes receive Windows export validation under project rules.

## Return ceiling

Implementer return ceiling was:

`READY FOR INDEPENDENT REVIEW`

Only GPT Independent Review could issue Engineering PASS. Owner retains Product/UAT authority where applicable.

## Review result

See:

`docs/mw006/MW-006_INDEPENDENT_REVIEW_IR1.md`

IR#1 verdict: **ENGINEERING PASS / CLOSED**.
