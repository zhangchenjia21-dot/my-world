# MW-001 Runtime Narrative Actor Materialization — Independent Review IR#1

Status: **PASS / CLOSED**  
Work Item: **MW-001**  
Capability-Anchor: **G5-03**  
Legacy Planning Ref: **G5-03M2B**  
Revision: **1**  
Review-Round: **IR#1**  
Reviewer: GPT  
Reviewed implementation head: `306fe2e9b69b20dc916014583d924e73b16186c0`  
Reviewed evidence head: `7464b7f4d0d87b394dfe59aee84c3bcc9c31374a`

Canonical: `Vibe-Coding/my world/architecture/world/G5_STABLE_ACTOR_REGISTRY_AND_MATERIALIZATION_V0_2_DECISION.md`  
Task: `docs/tasks/G5-03M2B_RUNTIME_NARRATIVE_ACTOR_MATERIALIZATION_TASK.md`  
Implementation evidence: `docs/g5_03/MW-001_RUNTIME_NARRATIVE_ACTOR_MATERIALIZATION_EVIDENCE.md`

## Verdict

**MW-001 Revision 1 = ENGINEERING PASS / CLOSED.**

The implementation satisfies the required runtime Narrative actor ingress without reopening Narrative acceptance, Agency scheduling, Source authority, or persistence architecture.

## 1. Existing semantic lane / failure isolation

PASS.

`new_actor_candidates` is added only to the existing post-Narrative semantic-analysis response. No additional mandatory Provider call or Narrative finalize gate is introduced.

The parser treats actor candidates as an optional independently fail-soft field. Invalid/non-array/bad candidate entries do not invalidate otherwise-valid `changes` / `knowledge_events`. Raw `display_name` and `profile_text` values must be strings before trim/bounds validation. Model-provided identity/provenance/role fields are discarded and only clean bounded Game-local material survives.

Exact duplicate candidate material may be fail-soft deduped; display-name equality is not used as authoritative identity.

## 2. Program-owned identity / actor record

PASS.

Program logic mints deterministic `character-runtime-*` IDs from Game identity + exact accepted turn/hash + stable candidate ordinal + canonical candidate material. Runtime records use:

```text
role = stable_npc
origin.kind = runtime_narrative
origin.source_turn_index = exact accepted turn
origin.source_gm_sha256 = exact accepted GM hash
game_local_material = { display_name, profile_text }
```

No fake Source provenance / Source projection / model-minted local ID is accepted.

## 3. Atomic semantic commit / actor-only commit

PASS.

Actors are appended into the same semantic World candidate used by valid changes/knowledge and cross the existing single `commit_world_mutation_durably` seam. Actor-only semantic results are valid and do not fabricate a `changes` record or a second actor-registration mutation.

The implementation therefore supports all required combinations of changes / knowledge / actors through one semantic mutation boundary.

## 4. Replay / idempotence

PASS.

Creation of a runtime actor leaves a durable replay signal in the actor's exact `origin.source_turn_index + origin.source_gm_sha256`. `runtime_actor_ids_for_version` allows a fresh worker/reopen re-entry to recognize an already materialized actor-only semantic version without relying on in-memory `_attempted_versions`.

For mixed semantic results, the existing matching semantic/knowledge record continues to provide the same-version durable replay guard. The same accepted version does not mint or append a second runtime actor.

No arbitrary historical turn retrofit is introduced.

## 5. Regenerate / correction currentness

PASS.

Stale runtime actor records remain physically durable, but current actor enumeration continues to require the exact accepted turn→GM-hash match. The semantic request roster, Knowledge allowlist, Agency selector eligibility, and actor execution all consume the current filtered registry where applicable.

A corrected/regenerated Narrative therefore makes the old runtime actor inert without deleting history.

## 6. Knowledge boundary

PASS.

Actor materialization does not create Knowledge Provenance. Pre-commit Knowledge validation uses the existing current roster and does not guess/backfill the just-minted actor ID. Existing actor-private Knowledge remains private during actor execution.

## 7. Same-turn Agency visibility / M1 protection

PASS.

No Scheduler/Cycle production code changed.

Reviewer inspected the existing production wake ownership in `src/应用壳.gd` together with the MW-001 semantic terminal order:

```text
ordinary accepted turn
→ Application marks Agency dirty
→ WorldTurn semantic lane runs
→ semantic durable commit publishes new world_state
→ semantic _active is cleared
→ WorldTurn finished signal
→ Application calls AgencyScheduler.consider_agency()
→ selector builds roster from the latest committed world_state
```

Thus a newly materialized runtime actor is visible to the selector in the same dirty opportunity without changing dirty consumption, foreground priority, selector cap, concurrency, or actor-private execution semantics.

The focused suite additionally verifies selector request/eligibility and actor-material resolution for the new exact local ID, while the directly affected G5-03 regression protects the established dirty/wake/selector behavior.

## 8. Save / reopen / Restore

PASS.

The focused persistence proof uses the production path:

```text
production Game + accepted Narrative
→ real SemanticMaterializationProcess with deterministic Provider stub
→ durable runtime actor semantic mutation
→ create_save_point
→ later durable head advance
→ restore_save_point
→ close / reopen
```

and asserts the exact runtime actor record and Program-owned ID survive unchanged.

No SQLite schema/table/migration or registry-specific persistence path was added.

## 9. Scope / evidence review

Diff from the MW-001 activation base `c3f17803e4039226249b454ba3fa4e44b17b9d4d` to evidence head contains only:

- `src/世界回合/L0_公理层/世界回合规则.gd`;
- `src/世界回合/L1_器件层/语义变更响应解析器.gd`;
- `src/世界回合/L2_流程层/语义物化流程.gd`;
- `tests/g5_03m2b/运行时叙事演员物化测试.gd`;
- implementation evidence.

No Agency Scheduler/Cycle, UI, SQLite schema, Public d20, Source runtime, Faction, or G5-04 production code changed.

Committed evidence reports:

- MW-001 focused: **53 PASS / 0 FAIL**;
- affected G5-01 semantic + timeline regressions: **0 FAIL**;
- affected G5-02 Knowledge regression: **0 FAIL**;
- affected G5-03 multi-actor Agency regression: **0 FAIL**;
- G3-04 Save/Restore regression: **PASS**;
- `git diff --check`: clean;
- real Provider calls: **0**.

The reviewed implementation commit has no external CI status checks attached. The reviewer environment also does not expose a Godot executable, so test commands were not independently re-executed; review inspected the committed production diff, focused test source, production scheduling/persistence seams, and committed evidence directly.

## 10. Non-blocking advisory

`parse_new_actor_candidates` increments `actors_dropped` when the candidate collection reaches the safety ceiling, so an input containing exactly eight valid unique candidates reports one dropped candidate even though all eight are retained. This is an observability off-by-one only: it does not alter accepted candidates, actor identities, mutation content, currentness, or any task acceptance invariant, and no production authority depends on the count.

Do not reopen MW-001 solely for this advisory. Correct it opportunistically if this parser is next touched.

## Closeout

MW-001 is closed. Together with G5-03M2A IR#2, **G5-03M2 Stable Actor Registry + Materialization is complete**:

```text
Guaranteed Source NPC
+ automatic Source-backed NPC
+ creation-authored Game-local NPC
+ runtime Narrative-materialized NPC
→ Program-owned stable actor registry
→ Knowledge / Agency / Save-Restore consumption
```

Parent G5-03 real Provider proof remains honestly `PENDING / EXTERNAL PROVIDER UNAVAILABLE`; no Provider was switched to manufacture evidence.
