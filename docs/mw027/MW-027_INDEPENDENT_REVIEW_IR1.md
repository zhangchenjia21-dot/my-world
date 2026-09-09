# MW-027｜Independent Review IR1

Status: **ENGINEERING PASS_WITH_NOTES**

Reviewer: GPT  
Work Item: **MW-027｜Open Threads / 事务**  
Formal Code Base: `5820c20b1150cd998b626e56fce79c023004b5ec`  
Task Packet / Starting HEAD: `b687cfc29f65637424e8b05bbba6c50e332e0999`  
Production Implementation HEAD: `bc12dbd318b3375110dc4d867cfd118d55b92477`  
Submitted Final Candidate: `ef6d09583bef15edfba41dfd53412002c96e001f`  
Frozen architecture: `Vibe-Coding/my world/architecture/ui/G6_OPEN_THREADS_SURFACE_V1_0_DECISION.md@v1.0`

## 1. Freshness / lineage

Independent Review re-read both canonical mains before verdict:

- implementation `my-world/main` remained exactly `5820c20b1150cd998b626e56fce79c023004b5ec`;
- governance `Vibe-Coding/main` was `ba0c3bcd115c40d0673f6b4af04d20eabd04ceb4`, with Package 3 / MW-027 current and Package 2 Product confirmation explicitly deferred.

Branch inspection confirmed submitted HEAD `ef6d095...` descends from production implementation `bc12dbd...`, which descends from the Task Packet starting commit `b687cfc...`. The final candidate adds evidence/documentation after the production implementation; no later unreviewed production mutation was found.

## 2. Independent product / architecture audit

### 2.1 Semantic authority — PASS

The implementation preserves the frozen rule:

> Model owns semantic interpretation and curation; Program owns normalized storage, temporal integrity and presentation.

Open Threads semantic choice is kept in the existing Information Curator prompt. Production code adds no Quest classifier, keyword/regex routing, importance score, priority inference, fixed task category, completion heuristic or turn threshold.

The model is explicitly told that current-scene presence is neither necessary nor sufficient, ordinary turns may produce no change, and resolved/expired/no-longer-relevant matters may disappear. This matches the frozen `事务` semantics rather than converting the feature into a task manager.

### 2.2 One existing Curator call — PASS

Open Threads is maintained in the same lived Information Curator request as Character / Important Experiences / People. `current_open_threads` is added to that existing bounded request; there is no dedicated Threads Provider lane or second semantic call.

Initial Character curation remains separate and does not receive/create Threads. OOC continues to be structurally excluded from lived curation opportunities.

### 2.3 Player-safe information boundary — PASS

The Curator receives the current Threads snapshot through the Threads fold, while the leaf UI and Debug consumer use the dedicated L3 projection. The public projection exposes only `title / summary / details` and no persistence IDs, receipt IDs, hashes or raw curation payload.

Focused tests use explicit private canaries and verify they do not enter the Threads request. The UI leaf receives only the projected array, not Runtime or raw `world_state`.

### 2.4 Persistence / backward compatibility / currentness — PASS

The lived schema evolves from `information_curation_lived.v0.2` to `v0.3` without rewriting old records. `current_records()` validates each persisted record with its own recorded schema and computes the ID with that exact schema/result shape.

The focused suite independently constructs the old v0.2 ID using the frozen old hash formula rather than the new helper, then proves the old record remains readable and that injecting a new field invalidates it. New v0.3 records bind the exact normalized result, parent chain and existing identity-receipt dependency.

The current Threads projection folds only validated current curation records. Missing/null means keep, Array means complete replacement, and `[]` clears. Restore, displaced future, corrected/replaced accepted history and stale callbacks are explicitly exercised.

A stale People identity receipt suppresses only People writes; valid Character / Experiences / Threads output remains commit-eligible, which preserves the frozen cross-surface ownership boundary.

### 2.5 Fail-soft behavior — PASS

Malformed Threads, Provider failure, cancellation and timeout do not invalidate accepted Narrative and do not fabricate replacement Threads. Curator remains background/non-blocking. Reopen and tab/render operations do not trigger semantic calls or durable mutation.

### 2.6 Player-facing `事务` surface — PASS

World Information navigation is now:

`概览 | 角色 | 重要经历 | 人物 | 事务 | 存档`

The new leaf view renders title, current summary and bounded details, with a clear empty state. It remains read-only and does not add checkbox/edit/search/sort/priority/action-generation behaviors or Dynamic UI abstraction.

The existing World Information scroll host is reused. Real-window automated checks at 960×540, 1280×720 and 1920×1080 verify >=20px effective text, no horizontal overflow, usable composer, scrollability for the 12-thread bound and reachable final content.

### 2.7 Debug integration — PASS

Debug adds the closed `threads` lane and computes changed/no-change from player-safe before/after projection only. Success exposes a bounded total count; abnormal shared-curation terminals propagate failed/stale/cancelled without exposing Thread prose, raw Provider payload or private material.

Initial Character curation does not incorrectly emit a lived Threads row.

## 3. Independent test-quality audit

The focused suite is materially non-vacuous. In particular it proves:

- manually constructed v0.2 historical ID compatibility rather than self-validating through the new helper;
- v0.3 tamper rejection;
- exact parent chaining across v0.2 → v0.3;
- replace → null/keep → replace → clear semantics;
- missing old response field as no-op;
- explicit malformed/oversize/extra-key rejection;
- private-canary exclusion;
- detached safe projection;
- OOC zero lived opportunity;
- stale corrected-history callback rejection;
- Restore before/after behavior and displaced-future isolation;
- reopen with zero historical backfill;
- real production Shell consumption, Debug wiring and tab behavior;
- zero extra curation/recommendation calls from rendering/navigation.

This uses controlled Provider stubs for deterministic structured output, but the production Runtime / Curator / currentness / persistence / Shell seams are actually exercised rather than replaced by a separate test-only implementation.

Recorded focused and real-window runs each report **152 checks / 0 failures**.

## 4. Regression / import / export evidence

The directly affected regression set reports **39 passing suites**. Two G3 Context assertions still fail and were independently reproduced on an isolated checkout of the exact Formal Code Base:

- `opaque World JSON is not injected as Game Context`;
- `raw World/Prompt truth leaked into Context`.

They are pre-existing Context debt, not introduced by MW-027. MW-027 does not alter that ownership seam and correctly leaves the debt untouched.

Final Godot 4.7.2 import and fresh Windows export / `ValidateExportOnly` both completed successfully. Existing teardown/resource warnings remain baseline non-blockers.

## 5. Findings

No blocking defect found.

No architecture rollback found:

- no Program-owned semantic task engine;
- no second Open Threads truth owner / SQLite table;
- no extra Provider call;
- no raw hidden World/NPC feed into the leaf surface;
- no loss of v0.2 currentness/ID semantics;
- no OOC lived-curration regression;
- no Character / Important Experiences / People ownership regression found in reviewed code/evidence.

## 6. Notes / remaining Product evidence

### N-01｜Real model semantic quality not yet proven

MW-027 intentionally used **0 real Provider calls**. Engineering proves that the model has the correct bounded authority and plumbing, but does not prove by itself that a real model will consistently choose useful unresolved matters, remain quiet on ordinary turns, retain meaningful off-screen matters and remove resolved matters naturally.

This is Product evidence, not an Engineering blocker under the Task Packet. Owner Product confirmation is already explicitly permitted to be deferred / combined with the later concentrated UAT / Package 7 Reality Gate.

### N-02｜Known G3 Context debt remains

The two reproduced exact-baseline G3 Context failures remain retained debt for relevant later Context work. Do not insert an unrelated repair between Package 3 and the next core package.

## 7. Verdict

**ENGINEERING PASS_WITH_NOTES**

MW-027 is safe to integrate by non-force fast-forward from the exact Formal Code Base to this reviewed branch lineage.

This verdict does **not** claim Product PASS. The proper post-integration state is:

> **Package 3 / MW-027 = ENGINEERING PASS_WITH_NOTES / INTEGRATED / PRODUCT CONFIRMATION DEFERRED**

Per the current Core-first route, after reviewed integration proceed directly to Package 4 `System / Public d20` rather than requesting a standalone Owner UAT now.
