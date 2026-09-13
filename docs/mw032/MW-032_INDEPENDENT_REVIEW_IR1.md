# MW-032｜Independent Review IR1

Status: **ENGINEERING PASS_WITH_NOTES**

Reviewer: GPT  
Work Item: **MW-032｜G6 Reality Gate U1 Correction Train**  
Formal Code Base: `69ac2030b90f4165deb2ecb5302e3743422af585`  
Task Packet / Starting HEAD: `30ca29f90300e876efefd083c4ef50c25d7fa4b8`  
Production Implementation HEAD: `41cf4dfb87f12d9d99b9985e4e0dcf6e7f202b25`  
Submitted Final Candidate: `dd51c5daef1db6f8a012f05148e49f6912bf6bd4`  
Frozen architecture: `Vibe-Coding/my world/architecture/G6_REALITY_GATE_U1_CORRECTION_TRAIN_V1_0_DECISION.md@v1.0`

## 1. Freshness / lineage

Independent Review refreshed both authoritative repositories before verdict:

- implementation `my-world/main` remains exactly the Formal Code Base `69ac2030b90f4165deb2ecb5302e3743422af585`;
- task branch remote tip is exactly submitted candidate `dd51c5daef1db6f8a012f05148e49f6912bf6bd4`;
- `30ca29f... → dd51c5d...` is two commits ahead with no divergent main history;
- production bytes are commit `41cf4df...`; `dd51c5d...` adds implementation-return/evidence only;
- governance `Vibe-Coding/main` is `eb58654568d31d96ea1ee50f100e1ef6b927daa0`; its post-task advances concern Minecraft planner material and do not supersede `my world` Status v17.29 / Roadmap v5.0 / G6 U1 Correction Train v1.0;
- current governance still requires MW-032 Independent Review, reviewed non-force integration, no immediate Owner build/re-UAT, then direct G7 Package 8 activation.

No unknown implementation-main advance or conflicting current product/architecture decision was found.

## 2. F01 — Opening semantic / information bootstrap — PASS

Production World semantic flow no longer rejects accepted GM-only Opening merely because `player_text` is empty. It still requires a valid accepted GM Narrative/current Game, reuses the existing semantic Provider lane, suppresses mechanical grounding when there is no Player action, and tells the model not to invent d20/Agency or promote memory/rumor/hypothesis into actor truth.

Identity receipt currentness is evolved compatibly so an accepted Opening with GM text can own the same bounded terminal evidence needed downstream. Reopen/historical protection remains in the existing semantic flow; current durable receipts are reused and historical activation does not become an automatic Provider backfill loop.

Information Curation now admits `opening` as a lived opportunity only when the current accepted opportunity was observed and the semantic barrier has reached terminal. Opening context carries empty Player action and explicit `input_mode=opening`; it reuses the same Curator owner/lane rather than creating a second Opening database or Provider.

Focused production-path evidence proves:

- sealed-letter possession becomes factual Inventory before any Player-authored turn;
- an environment sword does not become Inventory;
- an unresolved debt becomes Open Threads before first Player action;
- an Opening with no pending matter produces no fake Thread;
- a remembered person can become People without actor materialization;
- a genuinely present continuing NPC can still materialize/bind through the existing World semantic actor path;
- Restore removes displaced Opening Inventory/People/Thread material;
- reopen of durable current Opening state performs no semantic/curation Provider replay.

No synthetic Player action, Public d20 or duplicate semantic owner was found.

## 3. F02 — People subject / referent identity — PASS

MW-032 introduces a small Program-owned People-domain subject identity that is structurally separate from authoritative World actor identity.

The new request-scoped reference layer:

- exposes only player-safe current snapshots plus opaque `person_ref` / `actor_ref` values to the model;
- keeps durable `subject_id`, actor IDs and Thread IDs inside Program state;
- validates new referents against exact accepted Player/GM source role + source span;
- derives durable new-subject identity from Game + accepted prefix + exact source coordinates + bounded proposal ordinal, not display name;
- updates/deletes existing subjects through exact request refs;
- permits a later exact actor link only after validating the current request actor ref;
- preserves the People subject/presentation identity when such a link is added;
- rejects unknown refs, duplicate subject operations and ambiguous multi-subject actor links without fuzzy/name matching.

Projection keeps referent-only People as player-information truth only. Production code does not write a World actor, Knowledge or Agency record from a referent-only People proposal.

Backward compatibility is preserved: old actor-keyed v0.2 People records retain their original normalization/hash validation, actor ID continues as that legacy People subject identity, and the existing People presentation-key formula therefore remains stable.

Focused evidence includes same-name distinct referents, deterministic replay identity, invalid/fractional source-span rejection, unknown actor-ref rejection, ambiguous two-subject link rejection, referent-only People with unchanged Stable Actor Registry, exact later actor link with stable presentation identity, and legacy bytes unchanged on read.

No fame/name allowlist, importance score, encounter threshold, current-scene priority or display-name authority was found. Semantic card worth remains model-owned.

## 4. F03 — Recommendation bounded recovery — PASS

Recommendation flow now tracks attempts per current accepted prefix and allows exactly one deferred recovery after a recoverable malformed / timeout / Provider failure.

The reviewed state machine preserves:

- maximum two starts for one unchanged prefix;
- strict existing exact-five `{label,draft}` success parsing;
- free-form input primacy and never-auto-send behavior;
- no hard-coded fallback actions;
- no generalized retry framework.

Recovery eligibility is frozen before the old transport is disconnected. Recovery advances the serial, starts only after rechecking current prefix/foreground/runtime state, and old callbacks are isolated by serial + active request prefix. Foreground attempt, Restore, replacement/currentness change and explicit cancellation invalidate pending recovery.

Known configuration errors reported through the Provider failure signal (`missing_key`, credential/profile/settings/context-limit families) terminate without recovery.

Focused evidence proves malformed→one recovery→ready, timeout→one recovery, transient Provider failure→one recovery, second failure→final unavailable/no third start, missing credential→no retry, foreground interruption→no obsolete retry, and old pre-recovery/pre-Restore callbacks cannot publish.

## 5. F04 — Open Threads lifecycle / stable identity / hide-recover — PASS

New lived curation records use `information_curation_lived.v0.4`. For new Opening/action opportunities the model must return a full explicitly reviewed current Thread array; null/missing review is invalid, `[]` is legitimate no-current-threads, valid existing `thread_ref` keeps/updates identity, omission removes, and null ref proposes a new stable Thread.

Program-owned new Thread identity derives from current Game + accepted prefix + bounded proposal ordinal. Existing stable Thread refs retain exact IDs across semantic updates.

Legacy v0.3 records remain byte/hash compatible and are not rewritten. Their transition refs derive from validated legacy record identity + item ordinal, not title/text equality. Legacy-only items remain readable but are not hideable until retained into a v0.4 stable record.

Thread presentation now reuses the existing Host-level visibility-preference owner. `ui_visibility.v0.2` adds `threads` while continuing to read v0.1 People/Important-Experiences sidecars without write-on-read. Explicit first Thread hide/recover upgrades the sidecar while preserving existing keys.

Focused/window evidence proves:

- active review omission removes a Thread;
- stable semantic update preserves Thread/presentation identity;
- same-title legacy Threads remain distinct by record+ordinal transition ref;
- null review and unknown Thread refs are rejected;
- Thread hide causes zero gameplay/Provider mutation;
- hidden semantic update remains hidden and does not rewrite preference bytes;
- Restore rewinds semantic content but not the presentation preference;
- reopen retains Thread hide;
- recover shows current content;
- System and Inventory remain non-hideable.

No Quest engine, Program completion heuristic, turn-age expiry, keyword rule, priority score or manual completion/delete/edit control was introduced.

## 6. Currentness / disclosure / ownership — PASS

Reviewed code preserves the frozen authority boundaries:

- raw accepted Conversation remains the historical source;
- World semantic lane remains the owner for factual Inventory/runtime actor materialization;
- Information Curator remains the single Character/Experiences/People/Threads semantic lane;
- Dynamic UI remains presentation-only;
- visibility preferences remain Game-local sidecar state outside Timeline;
- Restore/Regenerate currentness removes displaced future semantic state;
- request-only People/Thread maps are released after completion;
- model-visible curation input excludes durable subject/thread IDs and tested private canaries.

No new SQLite gameplay table, Provider lane, universal entity graph, G7 Context platform, generic Action Intent, external UI contract, Visual Runtime/Map, Inventory/System hide or broad Shell refactor was found.

## 7. Test-quality audit — PASS

MW-032 focused suite runs production Runtime, SQLite, World semantic flow, Information Curator, People/Threads/Inventory public projections, visibility preference owner and Recommendation flow with deterministic Provider stubs. It is not a helper-only or parser-only suite.

The suite reports **98 checks / 0 failures** and directly covers the four correction findings plus compatibility/currentness boundaries.

Older affected suites use a test-only response adapter where their historical fixtures still emit the pre-v0.4 protocol. That adapter does not exist in production and can translate exact fixture intent using current request refs. This is acceptable because:

1. production parsing does not retain an old-response repair path;
2. the adapter is confined to tests;
3. the dedicated MW-032 suite uses the new protocol directly and independently proves the corrected production paths.

The adapter therefore does not substitute for the MW-032 acceptance evidence.

## 8. Real-window / build audit — PASS

The MW-032 window suite extends the production MW-030 `main.tscn` six-surface path and adds actual Thread Host hide/recovery controls.

Recorded real-window result: **484 checks / 0 failures** at 960×540, 1280×720 and 1920×1080. Assertions cover >=20px recovery/composer/recommendation typography, horizontal reachability, long-Thread vertical overflow, actual Host hide/recover, and zero gameplay/provider mutation from those presentation actions.

Final Godot version is `4.7.2.stable.official.ed1daf0bf`. Final import succeeds. Fresh Windows export and `run-game.ps1 -ValidateExportOnly` succeed and report that the Windows export was rebuilt against the current checkout; validation mode explicitly skipped game launch.

Reported task-local PCK SHA256: `63386adf4aae645b7587f7ee2b08f6174e6c1141d30b907fe976a9185d303214`.

Real Provider calls: **0**. This is acceptable for deterministic engineering review but does not constitute semantic/product-quality proof.

## 9. Regression audit — PASS_WITH_BASELINE_NOTES

Direct regression manifest contains **45 suites: 43 pass, 2 fail**.

Retained failures:

1. G3-03: `opaque World JSON is not injected as Game Context`;
2. G3-05 persistence: `raw World/Prompt truth leaked into Context`.

The G3-03 candidate and exact Formal Base logs are byte-identical Git blobs, independently proving that failure is unchanged by MW-032. G3-05 was also rerun against an isolated `git archive` of exact Formal Base and records the same retained Context assertion. MW-032 does not touch the reserved G3/G7 Context debt and does not suppress/relabel either assertion.

Four passing legacy suites retain two known ObjectDB/resource-at-exit warning lines each. No evidence shows MW-032 expanded them into a new blocking defect.

## 10. Findings

No blocking engineering defect found.

No frozen-scope rollback found:

- no fake Opening Inventory/Threads;
- no Player-memory → World-actor implication;
- no People stable-actor prerequisite;
- no name/fame/score identity policy;
- no unbounded recommendation retry/fallback;
- no passive/null new Thread review;
- no title/text Thread identity;
- no Thread hide → delete/complete/model-feedback coupling;
- no second preference owner;
- no Inventory/System hide;
- no G7 platform work smuggled into G6 correction.

## 11. Notes / remaining evidence

### N-01｜Live-model semantic quality remains unproven here

All Provider behavior in this task is deterministic-stubbed. Engineering proves contracts, currentness, durability, failure handling and UI behavior; it does not prove a live model will consistently choose useful People/Thread content or produce ideal semantic curation.

Per Owner instruction, immediate re-UAT is explicitly deferred. The next concentrated Product test must cover MW-032 together with G7 work.

### N-02｜Known G3 Context debt remains out of scope

The two exact-baseline Context assertions remain retained debt. They align with the next-stage long-session/Context hardening route and must not be misrepresented as new MW-032 failures.

### N-03｜Legacy teardown/resource warnings remain non-blocking debt

The existing warnings are recorded rather than silently removed. They should not interrupt the Core-first route unless later evidence shows growth, corruption or product impact.

## 12. Verdict

**ENGINEERING PASS_WITH_NOTES**

MW-032 is safe for reviewed non-force fast-forward integration from exact implementation main `69ac2030b90f4165deb2ecb5302e3743422af585` through this reviewed task lineage.

This verdict does **not** claim Product PASS or final G6 Product confirmation.

Proper post-integration state:

> **G6 = ENGINEERING CORE COMPLETE / PRODUCT CONFIRMATION DEFERRED**

Per current Owner-approved route, there is **no immediate Owner build and no immediate MW-032 re-UAT**. After reviewed integration, activate **G7 Package 8｜Long-session Core**; the next concentrated Product test will validate MW-032 together with G7.