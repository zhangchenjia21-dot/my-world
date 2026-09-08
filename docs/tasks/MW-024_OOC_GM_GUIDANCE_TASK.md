# TASK｜MW-024｜OOC / GM Guidance + Typed Accepted Input Mode

Type: G6 Package 2 core interaction vertical  
Work Item: **MW-024**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Owner UAT: **deferred to combined Package 2 UAT after MW-025**  
Required branch: `mw-024-ooc-gm-guidance`  
Required worktree: `D:/AI/Projects/.worktrees/my-world/mw-024-ooc-gm-guidance`  
Formal Code Base: `a11af1bb922e5d0637a38bcccfdac27a819c9c1c`  
Governance architecture: `Vibe-Coding/my world/architecture/interaction/G6_CORE_INTERACTION_CONTROL_V1_0_DECISION.md`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Product outcome

Implement a real explicit input-mode split:

```text
角色行动 | OOC / GM 指导
```

`角色行动` remains the default/free-form RPG path.

`OOC / GM 指导` lets the Player speak directly to the GM about how the current/recent segment should be played. It receives a durable GM OOC response and survives Save/reopen/Restore, but it is **not** protagonist action and must not mutate World/Character/People/mechanics by itself.

This task establishes the typed accepted-input foundation used by the second Package-2 task. Do not implement Character-guided Recommendations yet beyond the minimum mode-awareness required to keep recommendations safe/useful after OOC.

## 2. Authority / read first

Refresh both mains before implementation. Read:

1. Owner current instruction and MW-023 Product PASS closure;
2. `Vibe-Coding/AGENTS.md` and Owner collaboration preferences;
3. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md` current;
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md@v4.4`;
5. `Vibe-Coding/my world/architecture/interaction/G6_CORE_INTERACTION_CONTROL_V1_0_DECISION.md` — FROZEN/CURRENT;
6. P-13/P-17 discussion records if needed;
7. repo `AGENTS.md` and current implementation/tests.

STOP if current governance supersedes the frozen decision or if Conversation persistence cannot carry a backward-compatible optional mode without a materially broader storage redesign.

## 3. Product invariants

### INV-OOC-01｜Explicit structure, never text inference

Mode is Program-owned. Do not infer OOC using prefixes, `/ooc`, brackets, keywords or regex.

Supported player modes:

- `action`
- `ooc`

Opening remains the existing GM-only special case.

### INV-OOC-02｜OOC is durable Conversation, not World truth

OOC Player text + GM OOC response are accepted Conversation history and must round-trip through reopen/Save/Restore/regenerate.

But OOC itself must not schedule/produce:

- Public d20;
- World semantic materialization;
- identity/materialized actor transaction;
- Agency/Evolution;
- lived Character/Important Experiences/People curation.

This exclusion is structural by mode.

### INV-OOC-03｜Mode participates in currentness

An `action` and an `ooc` turn with identical Player/GM prose are semantically different accepted versions.

Audit every accepted-prefix/currentness owner touched by current G5/G6 flows. At minimum consider:

- Conversation durable/current projection;
- Context Assembly;
- People identity receipt prefix;
- Information Curation prefix chain;
- Recommendation prefix/currentness;
- Debug accepted-token/currentness.

Legacy action histories must remain current. Do **not** invalidate old World/People/curation records merely because historical entries had no mode field.

Preferred compatibility rule:

- missing mode + non-empty player text = legacy `action`;
- missing mode + empty player text = opening;
- explicit `ooc` adds a semantic discriminator;
- legacy/action prefix algorithms must retain existing IDs where practical.

Do not solve this by migrating/recomputing historical World state.

### INV-OOC-04｜Raw accepted text remains authoritative

Mode is metadata. Do not rewrite accepted Player/GM text with `[OOC]` prefixes in durable truth.

Provider request wrappers/labels may be derived from the structural mode.

## 4. Conversation / persistence requirements

Add the minimum accepted-turn mode ownership to Conversation/Turn.

Requirements:

- ordinary existing callers remain `action` by default;
- OOC can start a typed attempt;
- completion candidate carries OOC mode;
- accepted projection exposes normalized mode safely;
- validation accepts legacy entries without mode;
- reopen/replacement/regenerate/correction preserve mode;
- old Game accepted history remains readable;
- no new SQLite table/schema migration unless current persistence implementation proves strictly unavoidable — if so STOP/report.

If current persistence stores accepted entries generically, reuse it.

## 5. Narrative / Context behavior

### AC-NAR-01｜Mode control

Near the composer expose a simple explicit two-mode selector/toggle:

`角色行动 | OOC / GM 指导`

- default on Game activation: `角色行动`;
- switching mode makes zero Provider calls and zero durable writes;
- normal free-form input remains primary;
- respect MW-023 >=20px gameplay typography baseline.

### AC-NAR-02｜OOC request

Submitting OOC:

- uses the existing Narrative Provider lane once;
- bypasses d20/adjudication;
- Context Assembly marks the active input structurally as OOC guidance;
- GM is instructed to reply out of character, acknowledging/clarifying/adapting guidance;
- GM must not narrate new authoritative in-world events or invent a protagonist action merely to answer OOC.

Do not add a second OOC model/provider lane.

### AC-NAR-03｜History display

Accepted OOC is visually distinguishable, e.g.:

- Player header: `OOC / GM 指导`
- response header: `GM · OOC`

Raw accepted bytes remain unchanged.

Restored history preserves these labels from structural mode.

### AC-NAR-04｜Recent guidance

Recent accepted OOC remains in the existing bounded Conversation context, structurally marked so subsequent GM turns can honor it as guidance rather than world fact.

No persistent Narrative Preference/settings owner.

## 6. Downstream gating

### AC-WORLD

World semantic must structurally skip OOC accepted turns. No World/Identity transaction and no historical backfill for OOC.

Agency/Evolution must therefore receive no OOC opportunity.

### AC-CURATOR

Information Curator must structurally skip OOC lived opportunities. OOC cannot mutate Character/Experiences/People merely because its text sounds like a personality statement.

Initial Character lane remains unchanged.

### AC-D20

OOC never enters Public d20 adjudication. Existing unresolved-action blocking semantics remain intact; do not create a new bypass around a pending durable d20 action.

### AC-RECOMMENDER

Action Recommender may still generate the ordinary next-role-action recommendations after an accepted OOC/GM response.

Minimum mode-aware behavior in MW-024:

- recent Conversation material preserves `action` vs `ooc` structurally;
- prompt understands OOC as Player guidance, not protagonist action/world fact;
- recommendation output remains exact existing 5×`{label,draft}`;
- one recommendation call per opportunity only;
- no Character projection input yet — that is MW-025.

Clicking a recommendation always prepares a **角色行动** draft. If UI is currently in OOC mode, recommendation click switches/ensures action mode, prefills exact draft and never sends.

### AC-DEBUG

Debug remains read-only. OOC may produce Narrative and Recommendation rows. Absence of World/Identity/Curator rows is legitimate because those lanes were not scheduled.

Do not expand Debug architecture.

## 7. Currentness / compatibility acceptance

Deterministically prove:

1. legacy Game with accepted entries lacking mode reopens with action/opening semantics;
2. existing legacy World/People/curation current records remain current after the code change;
3. new normal action behaves as before;
4. new OOC round-trips through durable Conversation;
5. same prose encoded as action vs OOC has distinct semantic currentness/version identity where required;
6. Restore from a later action/OOC mix to an earlier save removes displaced mode-specific diagnostics/results;
7. regenerate/replacement preserves the accepted turn mode and stale old callbacks cannot cross version boundaries;
8. no migration/new table is introduced.

## 8. Product vertical acceptance

Use isolated task-owned Game data and controlled adapters to prove:

### Normal action

- existing action Send path still works;
- d20 path still works when applicable;
- World/Curator/Recommendations still run as before.

### OOC

- explicit mode visible and >=20px;
- send exactly one Narrative request;
- request is structurally distinguishable as OOC;
- GM response can be accepted durably;
- zero d20 calls;
- zero World semantic/identity calls;
- zero Agency/Evolution calls;
- zero lived Curator call/mutation;
- ordinary Recommender may run once after accepted OOC;
- recommendation click returns to action mode and exact-draft prefill/no-send behavior remains.

### Reopen/Restore

- OOC labels and mode survive reopen;
- subsequent action request contains recent OOC as guidance, not role action;
- Save/Restore preserves exact mixed-mode history/currentness.

## 9. Bounded real Provider validation

After deterministic gates pass, run a bounded real configured Provider check if available and stable enough:

Preferred:

1. one OOC guidance such as a pacing/style request;
2. verify GM response is genuinely out-of-character and does not invent world consequence/protagonist action;
3. optionally one subsequent normal role action to verify the guidance is naturally respected.

Maximum two Narrative Provider calls for this real check. Do not manipulate model output or add fallback/retry loops to manufacture a pass.

If real Provider is unavailable, report it as retained Owner-UAT risk; do not block deterministic engineering solely for network availability.

## 10. Direct regressions

Protect at minimum:

- G2 Conversation/Narrative Send/retry/regenerate/correction;
- G3 persistence/reopen/Save/Restore;
- current Public d20 lifecycle;
- G5 World semantic/identity/currentness;
- Agency/Evolution scheduling;
- MW-014/015/018 Curator/People;
- MW-019 recommendations strict pair/click lifecycle;
- MW-021 scroll;
- MW-022 Debug;
- MW-023 typography/readability.

Reproduce known G3-03 baseline if encountered; do not fix unrelated Context debt in this task.

## 11. Explicit non-scope

Do not implement:

- Character-guided Recommendations (MW-025);
- personality scores/heuristics;
- Narrative Preference;
- Reality Correction;
- slash commands;
- generic Action Intent;
- OOC direct World/Character mutation;
- Open Threads/System/Inventory/Dynamic UI;
- Context Orchestrator;
- generic structured-output/provider framework;
- new telemetry platform;
- broad Application Shell refactor.

## 12. Validation order

1. Conversation/durable-mode contract + legacy currentness focused tests;
2. OOC vertical with controlled adapters;
3. real-window 960×540 / 1280×720 / 1920×1080;
4. directly affected regressions;
5. bounded real Provider OOC check if available;
6. final Godot import;
7. fresh Windows export validation.

## 13. Git / return

- work only on `mw-024-ooc-gm-guidance` in required worktree;
- preserve unknown Owner/local files; no reset/clean/force;
- do not modify `main` directly;
- commit + push implementation/evidence;
- write `docs/mw024/MW-024_IMPLEMENTATION_RETURN.md`;
- return exact Starting HEAD / Implementation HEAD / Final candidate HEAD, validation and risks;
- do not merge main;
- do not install Owner build;
- do not announce Product PASS.

Highest state: **READY FOR INDEPENDENT REVIEW**.

## 14. Package handoff

After MW-024 Engineering PASS/integration, GPT proceeds directly to MW-025 without requiring Owner UAT. Package 2 gets one combined Owner UAT only after both work items are integrated.
