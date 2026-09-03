# TASK｜G5-02M1C01｜Actor Roster + Recent Knowledge Projection Correction

Type: **focused backend correction / correction-01**  
Owner: **KIMI**  
Reviewer / semantic owner: **GPT**  
Parent: **G5-02M1 Known-Actor Knowledge Provenance Spine**  
Prerequisite: `docs/g5_02/G5-02M1_INDEPENDENT_REVIEW.md`  
Return ceiling: **READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**

## 0. Temporary routing

Through 2026-09-06 23:59 (+08:00), Kimi remains the code-changing implementation owner. Do not wait for Codex quota recovery.

## 1. Outcome

Fix only the three concrete Independent Review findings without redesigning G5-02:

1. the existing semantic-analysis request must provide the exact stable actor roster it expects the model to use;
2. bounded Actor Knowledge Context must project **recent** knowledge rather than freezing on the oldest events;
3. the real-provider harness must require actual committed knowledge provenance before it can ever report a feature-specific PASS.

Protected principle:

> **GM omniscience must not become actor omniscience.**

## 2. Same Provider request — add compact roster, no second call

Keep exactly one auxiliary semantic-analysis request per newly accepted ordinary turn.

Before assembling that request, derive the current roster through the existing Game-local world state / `Rules.actor_roster(...)` seam:

```text
Player Character local_character_id + display name
Guaranteed NPC local_character_id + display name
```

Add a compact machine-facing roster block to the same analysis request, for example:

```text
Allowed Stable Actors
- 刘备 | local-character-...
- 孙权 | local-character-...
```

The exact formatting is implementation-owned, but the model must receive the exact IDs it is allowed to emit.

The analysis instruction must continue to say:

- only emit `knower_id` from the supplied roster;
- do not infer knowledge merely from roster membership;
- do not invent actor IDs;
- output no reasoning.

Do not send the whole Source/Game Context merely to solve ID resolution.

## 3. Recent knowledge projection

Current code sorts oldest → newest and consumes the event cap from the front. Correct this so the bounded working set selects the newest matching knowledge events/turns.

Required deterministic proof:

```text
more than MAX_KNOWLEDGE_EVENTS_PROJECTED committed matching events
→ latest event is projected
→ oldest events beyond the cap are absent
```

Rendered output may be re-sorted into chronological order after selection for readability.

Keep the existing actor/event/character bounds. Do not build G7 retrieval.

## 4. Real-provider harness truthfulness

Update the existing G5-02 real-provider harness so a future feature-specific PASS requires:

- ordinary Narrative accepted;
- semantic analysis terminal success;
- at least one committed valid knowledge event whose `knower_id` belongs to the stable roster;
- later assembled Context contains `Actor Knowledge Provenance` and the committed event/fact.

`no_changes`, an empty `knowledge_turns_by_index`, or merely assembling Context successfully must **not** count as G5-02 feature proof.

## 5. No additional real Provider attempt

**Do not make a real Provider call in this correction.**

The parent G5-02M1 packet allowed at most one task-owned real selected-Provider attempt. That attempt was already consumed and timed out during ordinary Narrative.

Status remains:

```text
G5-02M1 real selected-Provider vertical
PENDING / EXTERNAL PROVIDER UNAVAILABLE
```

Do not switch Provider, add fallback, or make a second attempt.

## 6. Preserve existing semantics

Must remain true:

- free-form Narrative has no JSON/header/sentinel requirement;
- Narrative acceptance is independent of semantic-analysis success;
- no second semantic Provider request;
- bad/absent knowledge does not invalidate valid G5-01 `changes`;
- unknown/non-roster IDs never become durable authority;
- knowledge-only / combined results use at most one atomic world mutation;
- no SQLite schema/table migration;
- no Source migration;
- no generic Knowledge Graph;
- no Faction knowledge;
- no G5-03 NPC/Faction Agency;
- no UI/G6/G7 work.

## 7. Required tests

At minimum add/update deterministic tests proving:

1. emitted semantic-analysis messages contain exact Player + Guaranteed NPC display-name/local-ID roster;
2. no incidental/unknown actor is added to that roster;
3. >8 matching knowledge events selects recent events and evicts bounded-old events;
4. existing G5-02 A–F focused tests remain green;
5. G5-01 focused + Timeline regressions remain green;
6. directly affected continuation Context regression remains green;
7. updated real-provider harness structurally requires non-empty valid knowledge proof, without executing it;
8. `git diff --check` PASS.

## 8. Scope ceiling

Expected production scope is narrow:

- `src/世界回合/L2_流程层/语义物化流程.gd`;
- `src/世界回合/L1_器件层/世界回合上下文投影器.gd`;
- focused G5-02 tests / real-provider harness / evidence.

A tiny L0 helper adjustment is allowed only if necessary.

Protected:

- `src/domain/会话.gd`;
- `src/ui/**`;
- persistence schema/migrations;
- Source schema/generation;
- Runtime Model Settings;
- Public d20;
- G5-03+;
- G6/G7.

If wider changes appear necessary, stop and return the concrete blocker rather than silently expanding scope.

## 9. Evidence / completion

Update/create focused evidence under `docs/g5_02/` recording:

- START_HEAD / IMPLEMENTATION_HEAD / FINAL_HEAD;
- exact changed paths;
- roster-in-request proof;
- recent-event projection proof;
- real-harness truthfulness proof;
- regressions;
- `git diff --check` PASS;
- explicit statement: **no real Provider call was made**;
- parent real vertical remains pending.

Commit and push to `origin/main`, then return:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

Do not declare G5-02 PASS/CLOSED or start G5-03.
