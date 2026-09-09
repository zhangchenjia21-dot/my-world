# MW-026｜Independent Review IR1

Verdict: **ENGINEERING PASS_WITH_NOTES**

## Identity

- Formal Code Base: `b8b5c54eeda95b321c2c8492f3801f30991f89be`
- Task Starting HEAD: `19ac57da2834d62833236458bf239c5232220bf5`
- Implementation HEAD: `fa3452fc15d8f727239f83550098829d770e3d2f`
- Submitted Final Candidate: `e42ea9c284d8407943f5b3c698e6fd9e45ce461c`
- Review scope: exactly the three Package-2 UAT cleanup outcomes; Builder completion claims were not treated as completion evidence by themselves.

## Independent findings

### 1. Public mechanics continuity — PASS

The implementation adds one pure mechanics-owned player-safe history projector and an L3 public seam. It does not introduce a new persistence/currentness owner.

Current CHECK projection reuses the existing accepted-check matcher, which requires an accepted marker, exact accepted turn position, exact Player action text and a unique match. The new projector also refuses a CHECK when a current NO_CHECK occupies the same accepted slot. Current NO_CHECK projection requires accepted marker, exact accepted turn, exact Player text and exact accepted Narrative; ambiguous matches are omitted rather than guessed.

Projected fields are explicitly allowlisted and omit action/check/resolution IDs, control payloads, raw world state, hashes and private actor/world material. Focused evidence independently covers private canaries, unaccepted/ambiguous/replaced/OOC records, Restore before/after the check, displaced future, current NO_CHECK and the fixed latest-12 bound.

The player-safe mechanics section is appended to ordinary continuation/OOC context after factual durable/world-turn material and before the style anchor. Mechanics-owned Narrative also sees prior accepted public mechanics history. No additional Provider call is introduced.

This satisfies the UAT symptom: a disclosed Program-owned roll/outcome/failure stakes can remain factual context for later GM/OOC instead of existing only in the UI card.

### 2. OOC implementation-marker leak — PASS

The request representation no longer emits the internal assistant wrapper `[GM OOC response | input_mode=ooc]`. Historical assistant prose is passed through exactly. Historical/active Player OOC remains identifiable through a human-readable derived `OOC / GM 指导` marker plus the existing active OOC system guidance.

No output regex/post-processing was added. Accepted Player/GM bytes and typed Conversation currentness/persistence remain unchanged. MW-024 contract/vertical regressions pass.

### 3. Compact recommendation layout — PASS

The old full-width two-column Grid is replaced by `HFlowContainer`. Buttons use content-width sizing, 20px text and 40px minimum height instead of expanding to their grid cells. The recommendation viewport follows actual flow height with a small bounded scroll cap; long labels wrap without horizontal overflow.

Measured against the exact Formal Base product tree with the same five labels and information panel visible:

| Window | Rows | Recommendation before → after | Narrative before → after |
| --- | ---: | ---: | ---: |
| 960×540 | 2 / scrollable | 88 → 80 | 136 → 144 |
| 1280×720 | 1 | 192 → 72 | 212 → 332 |
| 1920×1080 | 1 | 192 → 72 | 542 → 662 |

The desktop product purpose is therefore materially achieved: short labels now return 120px of vertical space to Narrative at 720p/1080p. Exact draft prefill, editable free-form input, no-send, keyboard access and zero extra Provider calls remain covered.

## Regression / validation review

- Focused MW-026 evidence: 41 checks / 0 failures.
- Real-window paired/UI evidence: 105 checks / 0 failures across 960×540, 1280×720, 1920×1080.
- Direct regression set: 38/40 pass. The two failures are the known G3-03 and G3-05 Context assertions and are reproduced on the exact Formal Base; no suppression or unrelated repair was introduced.
- Existing teardown/resource warnings remain baseline debt.
- Final Godot 4.7.2 import and fresh Windows export/ValidateExportOnly are recorded successful with no script/parse/export errors.
- Final Candidate is a documentation/evidence-only child of the Implementation HEAD; production bytes are unchanged after `fa3452fc...`.

## Scope / architecture review

No People/general hide preference, Open Threads, System Surface, Inventory, Dynamic UI, Context Orchestrator, consequence engine, d20 balance redesign or broad shell refactor was introduced.

The new cross-module consumption goes through a mechanics L3 public seam. The mechanics internal Narrative path consumes its own mechanics L1 projector. No new SQLite schema/table or Provider lane was added.

## Review notes / retained Product risk

1. No real Provider call was run for MW-026. Deterministic evidence proves the correct public mechanics facts are present in the request, but Owner should do one bounded spot confirmation that a real OOC/GM response no longer denies the visible roll and that the internal OOC marker is absent.
2. At 960×540 the compact recommendation area still scrolls and not all alternatives/long-label lines fit simultaneously; all options remain accessible. This is acceptable for the bounded cleanup and is not a reason to reopen layout work before returning to the core route.
3. This change provides accepted failure stakes as authoritative factual context; it is intentionally not a new consequence engine and therefore does not prove every future model response will narrate consequences perfectly.

## Gate

**ENGINEERING PASS_WITH_NOTES.**

Product closure remains Owner bounded spot confirmation only. After that confirmation, Package 2 should close and the project should return directly to Package 3 Open Threads per Owner instruction; do not open another peripheral cleanup train.