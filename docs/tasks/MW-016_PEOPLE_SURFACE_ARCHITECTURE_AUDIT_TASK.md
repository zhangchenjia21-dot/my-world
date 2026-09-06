# TASK｜MW-016｜People Surface Architecture Audit

Type: planning / architecture audit — **NO PRODUCTION IMPLEMENTATION**  
Work Item: **MW-016**  
Name: **People Surface v0.1 — Identity / Disclosure / Curation Architecture Audit**  
Primary Executor: **Codex**  
Architecture / Semantic Owner: **GPT**  
Status: **READY FOR CODEX AUDIT**  
Suggested Branch: `mw-016-people-surface-architecture-audit`  
Suggested Worktree: `D:/AI/Projects/.worktrees/my-world/mw-016-audit`  
Return ceiling: **READY FOR GPT ARCHITECTURE DECISION**

## 1. Product outcome being protected

This audit exists so the future `人物 / People` Surface can become a real RPG人物志 without becoming an omniscient actor/debug browser.

Frozen product result:

```text
人物
→ card list
→ cards collapsed by default
→ collapsed card shows only key identity / brief latest-known summary
→ expand card for relationship and detailed player-known information
→ each card stores only the player's current latest-known snapshot of that person
→ off-screen NPC changes remain invisible until the player actually learns them
```

No player-visible feature is implemented in this audit.

## 2. Authority / Read First

Refresh both repository mains first.

Read:

1. repository `AGENTS.md`
2. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`
3. `Vibe-Coding/my world/architecture/ui/G6_PEOPLE_SURFACE_V1_0_DECISION.md`
4. `Vibe-Coding/my world/architecture/ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`
5. `Vibe-Coding/my world/architecture/world/G5_STABLE_ACTOR_REGISTRY_AND_MATERIALIZATION_V0_2_DECISION.md`
6. `Vibe-Coding/my world/architecture/world/G5_KNOWLEDGE_PROVENANCE_V0_1_DECISION.md`
7. `Vibe-Coding/my world/architecture/world/G5_PLAYER_SAFE_RUNTIME_UI_PROJECTION_V0_1_DECISION.md`
8. current implementation seams under:
   - `src/世界回合/`
   - `src/信息整理/`
   - `src/玩家安全投影/`
   - `src/runtime/`
   - gameplay Shell refresh/navigation code only as needed

Expand reading only when evidence is insufficient; report why.

## 3. Frozen semantic invariants

### INV-01 Model-driven curation

Model decides:

- whether the player has materially learned/encountered a person worth maintaining;
- whether a People card should be created/updated;
- what the player's latest-known information about that person is;
- current player-known relationship summary;
- collapsed headline vs expanded detail;
- whether new knowledge corrects/removes old knowledge.

Program must not implement name keywords, encounter counters, affinity scores, relationship state machine, semantic field routing, or actor-importance scores.

### INV-02 Stable identity

Every durable People card must bind to an existing Program-owned stable NPC local identity.

Display name is never authoritative identity and cannot be used as the final dedupe/matching key.

Model must not mint authoritative local IDs.

### INV-03 Player-known snapshot only

People stores/presents the **latest current player-known snapshot**, not omniscient NPC current state and not a history log.

NPC Agency / hidden World Evolution / NPC-private Knowledge / raw actor material must not update a card unless accepted player-visible history actually gives the player that information.

### INV-04 Timeline currentness

Restore / Regenerate / correction must make People cards match the current accepted history:

- restore before learning a person → card absent;
- restore before a later update → older player-known snapshot;
- regenerate superseding an update → stale People material not current;
- reopen → equivalent current snapshot without render-time Provider work.

### INV-05 One curation direction

Prefer extending the existing bounded Information Curator so Character + Important Experiences + People can be maintained through one semantic curation lane rather than adding a default new Provider call per Surface.

This is a direction, not permission to force unsafe sequencing. If stable-actor materialization ordering makes that impossible, prove the exact issue and propose the narrowest alternative.

## 4. Audit questions — must answer with code evidence

### Q1. Exact identity resolution

How can a People curation update refer to the exact existing `local_character_id` of a stable NPC without authoritative display-name matching?

Audit:

- current stable actor registry helpers;
- runtime-narrative actor materialization identity timing;
- Source-backed / Guaranteed / creation-authored / runtime-narrative actor families;
- whether an existing public seam can provide bounded identity-resolution metadata.

### Q2. Same-turn runtime actor race

When accepted Narrative establishes a new persistent person and the existing semantic lane materializes that actor in the same turn, can the Information Curator safely see/use the new Program-owned identity in that same semantic opportunity?

Determine current ordering/signals and whether People curation must:

- run after actor materialization terminal;
- reuse a structured result from the semantic lane;
- defer that person's card until a later safe point;
- or use another narrower mechanism.

Do not implement yet.

### Q3. Safe curator identity metadata

What is the minimum metadata the People curator may receive for identity resolution?

Candidate direction to evaluate:

```text
actor_ref / local_character_id
+ display_name or another bounded identity cue
```

This metadata is only identity resolution support. It must not smuggle raw Source projection, NPC-private Knowledge, hidden Agency plans, or omniscient current actor state into player-facing curation evidence.

Assess whether exposing the complete stable roster's names to the curator creates an unacceptable disclosure risk and whether a narrower current-turn candidate set is feasible without Program semantic classification.

### Q4. Durable owner shape

Should People current snapshots extend the existing `information_curation` owner, e.g. a bounded mapping keyed by stable local actor identity, or is there a smaller already-authoritative owner that better fits the frozen semantics?

Constraints:

- no new SQLite table unless architecture proves unavoidable;
- People snapshot is player-known presentation material, not canonical NPC world truth;
- must support currentness / idempotence / Restore / Regenerate;
- must coexist with Character initial baseline + lived curation + Important Experiences.

### Q5. Structured curation shape

Propose the smallest bounded model output needed for People.

Conceptually it may need operations such as:

```text
people_updates[]:
  actor_ref
  replace current player-known snapshot | remove card
```

A snapshot may need:

```text
collapsed headline / short latest-known summary
expanded groups or bounded details
player-known relationship summary
```

Do not freeze a giant universal Surface schema. Explain whether full snapshot replacement or field operations produce lower semantic/currentness complexity.

### Q6. Card eligibility and removal

How can the model establish/remove a card while Program remains structural only?

Program may validate actor identity/currentness and payload bounds, but must not decide semantic significance through rules.

### Q7. Refresh / UI seam impact

Identify the smallest future refresh seam needed so People cards update after successful curation and Restore/Regenerate, without building a generic event bus or MW-013 Declarative Host.

Do not implement the UI in this audit.

## 5. Required output

Create one report under:

`docs/mw016/MW-016_PEOPLE_ARCHITECTURE_AUDIT.md`

It must contain:

1. implementation facts with exact file/function references;
2. answer to Q1–Q7;
3. at least two viable architecture options where a real trade-off exists;
4. recommended minimum architecture and why;
5. exact schema/owner changes it would require, if any;
6. ordering/signal diagram for same-turn new actor materialization + People curation;
7. disclosure threat analysis proving hidden actor material cannot become People content by accident;
8. Save/Restore/Regenerate/reopen currentness design;
9. whether the next step can be one bounded implementation Task or should be split;
10. explicit STOP findings requiring GPT/Owner decision.

Optional bounded probes/tests may be added only if they materially prove current behavior. Do not change production code.

## 6. Acceptance

Audit PASS means GPT can answer, with evidence:

- where People player-known snapshot should live;
- how a card binds exact stable actor identity;
- how a newly materialized actor becomes safely addressable;
- what data can enter the curator without leaking hidden NPC truth;
- how one Information Curator can or cannot continue to serve all enabled Surfaces;
- how Timeline currentness works;
- what the implementation task should change and what it must not change.

No amount of prose counts as PASS if the current code paths were not inspected.

## 7. Non-scope

Do not implement:

- People UI/card scene;
- production curation contract changes;
- relationship system / scores;
- actor registry changes;
- new persistence tables;
- portraits;
- search/filter/sort;
- People history;
- MW-013;
- unrelated refactors.

## 8. Git / return

Use a task-specific branch/worktree if writing the audit report.

Do not merge main.

Return:

- audit commit SHA;
- implementation main SHA read;
- governance main SHA read;
- report path;
- recommended architecture in 5–10 lines;
- unresolved GPT/Owner decisions;
- clean status.

Highest allowed status: **READY FOR GPT ARCHITECTURE DECISION**.
