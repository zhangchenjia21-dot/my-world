# MW-010 Independent Review IR#2

Work Item: **MW-010 — G5 Living-World Integrated Reality Matrix**  
Capability-Anchor: **G5-07 World Product Tests**  
Revision: **2**  
Reviewer: **GPT**  
Implementation/Evidence SHA: `91f17a55115cde2de1c2eca19c6f610835deecce`  
Branch: `mw-010-g5-living-world-integrated-reality-matrix`  
Verdict: **ENGINEERING PASS / CLOSED**

## 1. Review basis

Reviewed against:

- `docs/tasks/MW-010_G5_LIVING_WORLD_INTEGRATED_REALITY_MATRIX_TASK.md`
- `docs/tasks/MW-010_REVISION2_COUNTERFACTUAL_KNOWLEDGE_COMPLETION_ADDENDUM.md`
- `Vibe-Coding/my world/architecture/world/G5_WORLD_PRODUCT_TEST_MATRIX_V0_1_DECISION.md`
- IR#1 findings F01/F02
- actual Revision-2 commit/diff and focused test code

Revision 2 is correctly the same MW-010 lineage. It does not mint a new Work Item.

## 2. Diff / scope integrity

The reviewed branch is a fast-forward descendant of the post-IR#1 `main` and contains the reconciled MW-010 test/evidence commit plus Revision 2.

Production code diff remains **zero**. Revision 2 changes only:

- `tests/mw010/生界一体现实矩阵测试.gd`
- `docs/mw010/MW-010_INTEGRATED_REALITY_MATRIX_EVIDENCE.md`

No new Runtime owner, SQLite schema/table, UI state store, branch engine, ViewModel/event bus, mechanics protocol or production behavior was introduced.

## 3. IR#1 F01 — PASS

IR#1 required a post-Save-S Path-A-specific **non-player** truth and proof that Restore makes it non-current while preserving pre-S non-player truth.

Revision 2 now creates:

`PATH_A_EVOLUTION = 沿江烽火台因备战令依次点燃。`

through the existing World Evolution production lane after Path A. Before Restore the test asserts:

- `world_evolution_events_by_turn["4"]` exists/current;
- GM continuation Context contains the Path-A event;
- player-safe projection/panel does not expose it merely because it is World/GM truth.

After Restore S it asserts:

- turn-4 Path-A evolution is absent from the current World snapshot;
- GM continuation Context no longer contains it;
- player-safe UI does not contain it;
- pre-S T2 Agency/Evolution remains current;
- alternate Path B does not resurrect the restored-away Path-A event.

This closes the counterfactual non-player-currentness gap from IR#1.

## 4. IR#1 F02 — PASS

Revision 2 now establishes a real G5-02 Knowledge asymmetry in the same integrated timeline.

Pre-S, the T2 semantic seam durably materializes:

`NPC_ONLY_FACT = 孙权知晓水军密令与船阵部署。`

with `knower_id = 孙权 local_character_id`. The test verifies the NPC provenance record exists/current and that the player-safe projection/panel does not show it.

During Path A after Save S, the Player Character separately receives normal `knowledge_events` provenance for the substantively related fact:

`PATH_A_PLAYER_KNOWLEDGE = 军中来报：孙权已密令水军连夜加固船阵。`

The player-safe panel then shows the Player-known formulation while still excluding the NPC-only formulation.

After Restore S the test verifies:

- the post-S Player disclosure disappears;
- the pre-S NPC provenance remains current;
- the NPC-only fact remains hidden from the human-player-safe projection;
- Path B does not reintroduce the restored-away Player disclosure.

This closes the Knowledge Boundary gap from IR#1 without inferring Player knowledge from Agency, Evolution or omniscient World truth.

## 5. Previously accepted MW-010 composition remains intact

The revised matrix retains the already accepted integrated proofs:

- quiet opportunity may legitimately `hold`;
- a stable NPC can take an independent durable action;
- World Evolution may advance independently of direct Player causation;
- GM omniscient Context and player-safe projection remain distinct;
- Public d20 result is Program-owned and durable before Narrative consequence;
- MW-006 grounding appears exactly once in the normal G5-01 semantic opportunity;
- mechanics-grounded consequence materializes through the existing semantic seam;
- close/reopen reconstructs composed truth families;
- same accepted `action_id` after reopen does not reroll;
- Save S → Path A → Restore S → Path B isolates current truth correctly;
- no second world/mechanics/knowledge/timeline/projection truth store is added.

## 6. Test evidence

Implementer evidence reports the focused MW-010 matrix at **44 assertions / 0 failures**, with the required G5 regressions green, `git diff --check` clean, real Provider calls `0`, and no production schema change.

GitHub exposes no combined CI statuses for this SHA, so the Godot run counts remain implementer execution evidence rather than an independently rerun CI result. Independent Review inspected the actual test implementation and verified that the new assertions exercise the required production seams rather than only checking fixture text.

## 7. Verdict

**ENGINEERING PASS / CLOSED**

MW-010 Revision 2 satisfies the frozen G5-07 engineering matrix. No additional G5-07 implementation vertical is justified by the reviewed evidence.

This verdict is engineering-only. It does not issue the Owner product-feel or final G5-GATE verdict.
