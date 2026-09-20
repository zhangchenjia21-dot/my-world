# MW-035 Independent Review — IR1

Verdict: **ENGINEERING PASS_WITH_NOTES**

Review scope: `MW-035 — G7 Public d20 Control Working-Set Currentness v0.1`

## 1. Reviewed lineage

- Formal Code Base / current implementation main: `0066b587f1d756b55ee18abfa5f473e78a3aeea2`
- Task Packet / Starting HEAD: `120062661ad419d52c36fc339cee6f226b09a78d`
- Implementation HEAD: `cc530f2844e51dc7a071c80f857f206f9dea0673`
- Codex Final Candidate: `d8b19d39bef075b9d69a76a0e9532212b021c99a`
- Task branch: `mw-035-g7-d20-control-working-set`
- Governance reviewed at latest main; my-world Current Status remains v18.6 / MW-035 and no relevant governance drift superseded the task.
- Frozen architecture: `G7_PUBLIC_D20_CONTROL_WORKING_SET_V0_1_DECISION.md@v0.1`

Candidate is a linear descendant of the Task Packet. The evidence commit is one child of the implementation commit and changes documentation/evidence only. Implementation `main` remained at the exact Formal Code Base during review.

## 2. Production review conclusion

No blocking defect found.

Production changes are narrow:

- existing Context L3 receives one mechanics-control composition seam;
- Public d20 `control/control_recovery` call that seam;
- existing working-set selector/budget engine remains the only structural selection implementation;
- d20 Narrative stages remain on the existing MW-033 Narrative assembly path.

No parser/schema, RNG, durable mechanics identity, Provider routing, persistence schema, UI, retrieval, World ownership or generic retry framework was introduced.

## 3. Mechanics working-set composition

PASS.

The control consumer now composes:

### P0

- continuation source owner's minimum Game/World identity + World/GM instructions + selected Entry identity;
- exact materialized Expansion rules;
- exact control / recovery contract;
- current Player action through the active-attempt message.

### P1

- newest complete accepted Turn first;
- current Character safe projection;
- current/hash-bound World / Knowledge / Agency / Evolution projection;
- factual Inventory;
- Public mechanics context/history;
- remaining complete accepted Turns while capacity remains.

### P2

- Opening supplement;
- Entry opening seed;
- T0 World source sections;
- T0 Player Character source sections;
- Guaranteed NPC source sections.

`literary_style_reference` is excluded from control source blocks. Dedicated Experiences / People / Open Threads mechanics blocks were not added, matching the frozen boundary.

## 4. Budget / atomicity

PASS.

MW-035 reuses the existing `assemble_working_set` selector and current validated runtime capacity.

Recorded successful requests:

| Request | Safe bytes | Final serialized bytes | Selected Turns |
|---|---:|---:|---:|
| 256k control | 209715 | 200198 | 10 |
| 256k recovery | 209715 | 200267 | 10 |
| 1m control | 838860 | 655604 | 21 |
| 1m recovery | 838860 | 655673 | 21 |
| live-in-fixture recovery after capacity/current-owner change | 838860 | 656187 | 23 |

At 256k, Character / World / Inventory / mechanics remain included while all oversized source/NPC P2 bodies are omitted whole. At 1m, all 21 accepted Turns fit and an additional complete P2 source block is admitted.

No mid-block or partial-Turn truncation was added. Small P2 fixtures remain eligible when they fit.

Required Expansion or required World-instruction overflow returns `required_context_overflow` before Provider start, before RNG, and before durable mechanics mutation.

## 5. Long-session currentness

PASS for the frozen owner boundaries.

Focused evidence proves that a current Character capability and current accepted-hash World / Knowledge / Agency / Evolution, factual Inventory, and Public mechanics remain visible to control even when the originating GM-only Opening is outside the selected 256k transcript.

Restore removes displaced Conversation/World material. Reopen reconstructs the same control request from durable owners rather than a message cache. Regenerate removes the replaced Conversation pair and old hash-bound World record.

Control recovery rebuilds from current owners and re-reads validated capacity rather than reusing attempt-1 messages.

## 6. d20 authority / lifecycle preservation

PASS.

- CHECK_REQUIRED / NO_CHECK parser and schema unchanged.
- RNG remains untouched until valid CHECK control parse.
- CHECK persists once and replay neither re-requests Provider nor rerolls.
- NO_CHECK durable resolution/replay remains intact.
- exactly one malformed control recovery remains.
- second malformed control still degrades to ordinary Narrative with zero RNG/fake d20 result.
- resolution / no-check / degraded Narrative stages continue through MW-033 Narrative working-set assembly and retain style behavior there.
- Provider-failure/timeout recovery semantics were not broadened.

## 7. Diagnostics

PASS.

Control context stats expose capacity, final bytes, family include/omit counts/bytes, selected Turn indexes/range, stage and assembly timing. Evidence verifies raw current markers / active action / private material are absent from the stats object.

No final messages or Context cache are persisted as truth.

## 8. Focused / regression evidence

PASS.

- MW-035 focused: **324 / 324**, real Provider calls **0**.
- MW-033 focused: **206 / 206**.
- MW-034 focused: **441 / 441**.
- relevant regression manifest: **49 / 49** suites, no script/parse/assertion failures.
- five known suites retain the same two-line ObjectDB/resource-at-exit warning family: G4-07B, G4-08B, G5-03, G5-04, MW-003; all exit 0.

The focused vertical uses the production d20 process + production Context owner + isolated Runtime/SQLite with deterministic stubs. It exercises actual `start_action` for overflow/CHECK/NO_CHECK/degraded paths, not helper-only acceptance.

## 9. Build evidence

PASS.

- Godot 4.7.2 final import: exit 0.
- fresh Windows export + `run-game.ps1 -ValidateExportOnly`: exit 0.
- PCK SHA-256: `0470ca8831cae0dfd0f89e2e798664b2ca4cdbb0f6363485ac538691795d5265`.
- evidence commit changes no product inputs after Implementation HEAD.
- no Owner build install/launch or Owner real Game/Source/settings/preferences mutation.

## 10. Notes / residual risk

1. **Live-model adjudication quality remains unproven.** Deterministic Engineering evidence uses zero real Provider calls. This remains for the planned concentrated Product test.
2. **Current World quality inherits the existing World-turn Context owner.** That owner intentionally uses bounded recent matching World changes/events plus current hash filtering. MW-035 correctly consumes that canonical owner; it does not prove that every very old but still persistent world condition should remain in that owner's future working set. If long-play evidence shows a gap, it is a World/current-state representation problem, not a reason to bypass the owner in d20.
3. **Large optional P2 can remain omitted even at 1m.** This is intended structural budgeting, not semantic retrieval. No evidence currently justifies embeddings/ranking.
4. Existing bounded teardown warnings remain nonblocking and unchanged.

## 11. Review verdict

> **MW-035 = ENGINEERING PASS_WITH_NOTES**

No Product PASS is claimed. No Package-8 completion is claimed. No generic Context or Structured Output platform is claimed.

Reviewed candidate is acceptable for reviewed non-force integration.
