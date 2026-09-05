# MW-005 Independent Review — IR#1

Status: **CORRECTION REQUIRED**  
Work Item: **MW-005 — Three Kingdoms Literary Style Primer v0.1**  
Revision reviewed: **1**  
Review round: **IR#1**  
Reviewer: **GPT**  
Reviewed main: `f7e347ed3b97bed8a036ad9c225aaa28f7e249fe`  
Implementation SHA: `97dbbbc36288129b4b21ac5556e5dd9378be5850`

## Verdict

Revision 1 is **not Engineering PASS yet**. The Source-generation/freeze/world-only separation work is materially sound, but one production consumer violates the frozen v0.1 authority boundary.

Per task identity rules, this is the **same MW-005 outcome**. Continue as **MW-005 Revision 2 / IR#2 after correction**; do not mint a new Work ID.

## What passed review

- The approved Primer is carried as `section_type=literary_style_reference`, `disclosure=gm_reference` in `world_pack.v0.2`; no schema v0.3/platform was introduced.
- The committed style section is byte-identical to the approved bounded Primer input.
- The new generation is fingerprint-distinct while the stripped package reproduces the pre-MW-005 generation contract.
- New Games freeze the exact Source generation; old Games do not silently read mutable Source current.
- Opening and ordinary continuation use the frozen Game-local projector and see the style reference under an explicit non-factual literary boundary.
- `project_world_only()` excludes the literary section completely, protecting G5-04 causal baseline.
- No Narrative output gate/parser/retry protocol, SQLite migration, RAG/retrieval platform, or full-book runtime corpus was added.
- Kimi's focused/regression evidence is coherent; tests were not independently rerun by GPT in this review environment.

## Blocking finding F01 — Literary Style Reference leaks into Public d20 control adjudication

The task contract states that **normal first-opening + ordinary GM Narrative are the intended/only v0.1 consumers** of the literary reference. It is expression reference, not mechanics/causal authority.

Current shared projector behavior breaks that boundary:

1. `GameLocalOpeningContextProjector.project()` now includes `literary_style_reference` by default.
2. `PublicD20ActionAdjudicationProcess._control_messages()` calls that same `project(session_runtime.world_state)`.
3. Therefore the structured **control** request that decides `NO_CHECK` vs `CHECK_REQUIRED` and proposes DC/modifier/stance/stakes receives the literary Primer.

The boundary notice tells the model not to use the reference causally, but the packet requires an architectural consumer boundary, not prompt-only discipline. The Primer contains military, political, diplomatic and social exemplars; allowing those examples into mechanics adjudication can bias whether a check is required or how difficulty/stakes are framed.

This is a behavior change to Public d20 even though the Public-d20 source file itself was not edited in Revision 1.

### Required correction

Keep the current Source generation/content unchanged. Make the smallest request-projection change so that:

```text
first opening                    -> style included
ordinary GM narrative            -> style included
Public d20 resolution narrative  -> style included
Public d20 NO_CHECK/degraded narrative -> style included
Public d20 control/control_recovery     -> style EXCLUDED
G5-04 project_world_only()              -> style EXCLUDED
```

Do **not** use `project_world_only()` for d20 control: the control lane may still require normal Game/Player/Character factual context. Add only the smallest explicit style-exclusion seam needed for the control request.

No new Source generation or production republish is required for this correction because the Source bytes are not defective; only a consumer boundary is.

### Required focused proof for Revision 2

Using a frozen Game containing the Primer, capture Public-d20 `request_assembled(stage, messages)` and prove:

- `control` contains neither the Primer marker, `literary_style_reference`, nor the literary boundary header;
- `control_recovery` also excludes them if exercised;
- subsequent `no_check_narrative` or `resolution_narrative` includes the Primer exactly once under the literary boundary;
- existing d20 decision/result semantics, retry/no-reroll behavior and MW-006 grounding behavior remain unchanged;
- existing MW-005 `project_world_only()` and old/new generation-freeze proofs remain green.

## Non-blocking notes

- The production Source current was already advanced to the new immutable generation during implementation. That does not require rollback: after the consumer correction, the same generation is valid. Owner prose UAT should wait for IR#2.
- Existing G2-05 baseline failures reported by Kimi are not attributed to MW-005 by this review.

## Next review gate

Kimi may return Revision 2 at most as `READY FOR INDEPENDENT REVIEW`. GPT then performs IR#2 from the actual diff/tests/evidence. Only after Engineering PASS should Owner perform the Three Kingdoms prose A/B UAT.
