# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / freshness

Authority order:

1. Owner current explicit instruction.
2. `Vibe-Coding/AGENTS.md`.
3. current Product / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. current architecture decisions.
5. this `AGENTS.md` + current Task Packet.
6. verifiable implementation/tests/current HEAD.

Refresh both `main`s before authoritative work. Never overwrite unknown dirty/newer work.

Repository remotes: `github.com/zhangchenjia21-dot/my-world` and `github.com/zhangchenjia21-dot/Vibe-Coding`.

Long-term routing:

```text
GPT        → meaning / architecture / governance / task shaping / Independent Review
Codex      → backend / mechanism / build-launch / validation implementation
Kimi       → frontend / UI / interaction implementation
Grok Build → search / external research / evidence discovery
Owner      → Product UAT / explicit product verdict
```

Temporary through 2026-09-06 23:59 (+08:00): Kimi owns all code-changing implementation tasks; GPT remains semantic owner/reviewer. Correct in-flight Kimi work may finish after expiry.

Gemini review remains CANCELLED / DO NOT EXECUTE. Review flow: Kimi implementation → GPT actual-code Independent Review.

## 2. Current state

```text
G1-G4                                        PASS / CLOSED
G5-01 World Turn / Semantic Materialization PASS / CLOSED
G5-02 Knowledge Provenance                  PASS / CLOSED
G5-03 NPC / Faction Agency                  ACTIVE
G5-03M1 Multi-Actor Agency v0.3             ENGINEERING PASS / CLOSED
G5-03M2 Stable Actor Registry               ACTIVE
G5-03M2A Registry Foundation                ENGINEERING PASS / CLOSED
MW-001 Runtime Narrative Actor Materialization ACTIVE — KIMI
  Capability Anchor                         G5-03
  Legacy Planning Ref                       G5-03M2B
G5-04 Event / Priority Evolution            NOT YET
```

M2A Independent Review IR#2 = PASS. Evidence:

`docs/g5_03/G5-03M2A_INDEPENDENT_REVIEW_IR2.md`

Parent real G5-03 Provider proof remains `PENDING / EXTERNAL PROVIDER UNAVAILABLE`; do not relabel it PASS and do not switch Provider to manufacture evidence.

## 3. Owner-corrected product rule

A Character Card is **not** required for a character to become a durable NPC.

The Stable Actor Registry must support:

```text
Guaranteed Source NPC
+ automatic Source-backed NPC
+ creation-authored Game-local NPC without a Card
+ runtime Narrative-materialized NPC without a Card
```

All receive Program-owned Game-local identity. Display name is never authoritative identity. Model output never mints final actor IDs.

## 4. Current canonical decision / task

Canonical:

`Vibe-Coding/my world/architecture/world/G5_STABLE_ACTOR_REGISTRY_AND_MATERIALIZATION_V0_2_DECISION.md`

Current executable Work Item:

`docs/tasks/G5-03M2B_RUNTIME_NARRATIVE_ACTOR_MATERIALIZATION_TASK.md`

Identity:

```text
Work Item: MW-001
Name: Runtime Narrative Actor Materialization
Capability-Anchor: G5-03
Legacy Planning Ref: G5-03M2B
Revision: 1
Review-Round: 0
Owner: Kimi
Reviewer: GPT
```

M2A is closed:

`docs/tasks/G5-03M2A_STABLE_ACTOR_REGISTRY_FOUNDATION_TASK.md`

Historical source-only packet is superseded and must not be executed:

`docs/tasks/G5-03M2_STABLE_NPC_CREATION_SNAPSHOT_AND_REGISTRY_EXPANSION_TASK.md`

Agency v0.3 remains protected:

`Vibe-Coding/my world/architecture/world/G5_AGENCY_SCHEDULER_V0_3_DECISION.md`

## 5. Task Identity / Lineage

Use:

`Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md`

Keep separate:

```text
Roadmap / Capability Anchor
!= Executable Work Item ID
!= Revision / Review Lineage
```

Do not create recursive suffix chains for correction/review history. Same-Outcome defects stay on the same Work Item and advance Revision / Review-Round. Mint a new flat Work Item only for a distinct Outcome/seam/prerequisite/Owner-inserted goal.

`MW-001` is the first new flat executable identity after this rule was adopted. `G5-03M2B` remains only a legacy planning reference.

## 6. Frozen M2A foundation

Do not reopen absent a concrete regression:

- first-intent automatic exact-profile Source-backed stable NPC snapshot;
- optional creation-time no-Card `game_local_npcs`;
- strict raw string material validation;
- Program-owned local IDs;
- honest Source-backed vs Game-local material families;
- unified `stable_npc_records` / `stable_actor_material` / `actor_roster`;
- Knowledge / Agency consumption by exact local identity;
- existing Games missing `stable_npcs` stay valid with no Source retrofit;
- runtime-origin currentness helper contract based on accepted turn/hash;
- Save/reopen/Restore preserves the opaque stable registry World document.

## 7. MW-001 protected semantics

MW-001 adds only runtime Narrative ingress through the existing semantic lane.

Protect these rules:

- optional independently fail-soft `new_actor_candidates`;
- no extra mandatory Provider call;
- visible Narrative acceptance never depends on actor extraction;
- candidate contains bounded descriptive material only;
- Program, never model, mints final local ID;
- runtime origin binds exact `source_turn_index + source_gm_sha256`;
- actor materialization shares the existing single semantic durable mutation with changes/knowledge;
- actor-only semantic commit is valid without fake changes;
- same accepted-version replay must not duplicate runtime actors, including actor-only results;
- stale runtime-origin actors remain physically historical but are filtered out of current roster/Agency by accepted hash;
- materialization grants no automatic Knowledge or action;
- semantic request includes current exact stable roster and instructs against reproposing existing stable actors;
- no display-name authoritative dedupe;
- no runtime mutable Source lookup;
- semantic `agency_candidates` must not be reactivated; standalone Agency Scheduler remains authoritative for selection;
- after semantic commit, existing semantic-terminal wake may expose the new actor to same-turn Agency without scheduling redesign.

## 8. Scope ceilings

Do not:

- add UI;
- add SQLite schema/table/migration;
- implement Faction agency or G5-04;
- change Public d20/mechanics;
- introduce a universal entity ontology;
- use display-name identity;
- let models mint IDs;
- fabricate Source provenance;
- change Multi-Actor Agency v0.3 dirty/foreground/concurrency semantics;
- make real Provider calls for deterministic MW-001 acceptance.

## 9. Validation

Use focused-first.

During implementation run only `tests/g5_03m2b/` focused tests.

After focused green, one minimal affected pass only:

- directly affected G5-01/G5-02 semantic/parser tests;
- one relevant G5-03 Scheduler/Cycle regression;
- one G3-04 Save/Restore regression;
- `git diff --check`.

No unrelated UI/G4/Public-d20/full-project matrix absent a concrete reason.

Parent real G5-03 Provider evidence remains pending if external Provider is unavailable.

## 10. Completion

Kimi writes compact evidence at:

`docs/g5_03/MW-001_RUNTIME_NARRATIVE_ACTOR_MATERIALIZATION_EVIDENCE.md`

then commits/pushes and returns at most:

`READY FOR INDEPENDENT REVIEW`

GPT performs actual-code Independent Review. M2 is complete only after MW-001 PASS. G5-04 remains blocked until G5-03 sequencing is explicitly closed.