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

Gemini review remains CANCELLED / DO NOT EXECUTE.

## 2. Current state

```text
G1-G4                                        PASS / CLOSED
G5-01 World Turn / Semantic Materialization PASS / CLOSED
G5-02 Knowledge Provenance                  PASS / CLOSED
G5-03 NPC / Faction Agency                  ENGINEERING PASS / CLOSED
G5-03M1 Multi-Actor Agency v0.3             ENGINEERING PASS / CLOSED
G5-03M2 Stable Actor Registry               ENGINEERING PASS / CLOSED
G5-03M2A Registry Foundation                ENGINEERING PASS / CLOSED
MW-001 Runtime Narrative Actor Materialization PASS / CLOSED
G5-04 Event / Priority Evolution            ARCHITECTURE SHAPING — GPT
```

Current closeout evidence:

- `docs/g5_03/G5-03M2A_INDEPENDENT_REVIEW_IR2.md`
- `docs/g5_03/MW-001_INDEPENDENT_REVIEW_IR1.md`
- `docs/g5_03/G5-03_CLOSEOUT.md`

Parent real G5-03 Provider proof remains `PENDING / EXTERNAL PROVIDER UNAVAILABLE`; do not relabel it PASS and do not switch Provider to manufacture evidence.

## 3. Stable actor / Agency product rule

A Character Card is **not** required for a character to become a durable NPC.

The closed G5-03 stable actor system supports:

```text
Guaranteed Source NPC
+ automatic Source-backed NPC
+ creation-authored Game-local NPC without a Card
+ runtime Narrative-materialized NPC without a Card
```

All receive Program-owned Game-local identity. Display name is never authoritative identity. Model output never mints final actor IDs.

Agency v0.3 remains:

```text
ordinary accepted player Narrative
→ mark Agency dirty
→ semantic lane terminal
→ standalone Selector on latest world
→ 0..4 current stable NPCs
→ independent actor-scoped requests
→ optional durable actor actions
```

Player foreground always wins. Actor-private material / Knowledge / history remain isolated.

## 4. G5-03 closeout / Faction decision

G5-03 is closed after MW-001 PASS.

Do **not** add a separate Faction-agency slice merely for symmetry. Current architecture has no concrete stable Faction identity / private Faction Knowledge / Faction action consumer that justifies a new platform seam. Faction/shared knowledge was explicitly deferred earlier.

Faction-level capability may be pulled out later only by a real consumer, most plausibly G5-04 pressure/priority world evolution or a later product surface.

This deferral does not mean:

- treating Factions as NPCs;
- granting shared Faction knowledge;
- inventing Faction identity now;
- silently claiming Faction agency is already implemented.

Read `docs/g5_03/G5-03_CLOSEOUT.md` for the decision.

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

`MW-001` is closed and remains the first flat Work Item under this rule. `G5-03M2B` remains only its legacy planning reference.

## 6. Protected G5-03 behavior

Do not reopen absent concrete regression or a real new consumer:

- Model Freedom First / Visible Narrative First;
- Narrative acceptance independent of semantic/agency extraction;
- standalone Agency Selector after semantic terminal;
- ordinary accepted turn marks dirty, selector start consumes dirty once;
- Player foreground invalidates remaining uncommitted background work;
- committed actor actions remain durable;
- selector fan-out 0..4;
- separate actor-scoped execution requests;
- actor-private material / Knowledge / history;
- first-intent automatic exact-profile Source-backed stable NPC snapshot;
- optional creation-time no-Card `game_local_npcs`;
- Program-owned local IDs;
- honest Source-backed vs Game-local material families;
- unified `stable_npc_records` / `stable_actor_material` / `actor_roster`;
- optional fail-soft runtime `new_actor_candidates` in the existing semantic lane only;
- no extra mandatory Provider call;
- actor-only semantic commit without fake changes;
- runtime actor origin bound to exact accepted turn/hash;
- stale runtime actors retained physically but filtered from current roster/Agency;
- no automatic Knowledge from registry membership or actor materialization;
- no runtime mutable Source lookup;
- Save/reopen/Restore preserves stable actor identity/history;
- semantic `agency_candidates` remains non-authoritative/dead; do not reactivate it.

MW-001 IR#1 recorded one non-blocking advisory: `actors_dropped` over-reports by one when exactly eight valid unique actor candidates reach the safety ceiling. No production authority depends on this count; correct opportunistically if that parser is next touched.

## 7. Current next work: G5-04 shaping only

G5-04 Event / Priority-driven World Evolution is now the current capability, but **implementation is not yet authorized**.

GPT must first shape the smallest product semantics / architecture for a real pressure/priority/event consumer.

Do not prebuild:

- a universal simulation engine;
- minute-by-minute NPC simulation;
- a generic Faction platform;
- universal entity/relationship ontology;
- new UI;
- new SQLite schema merely for symmetry;
- mechanics/Public-d20 redesign.

Until a G5-04 canonical decision + Task Packet exists, Kimi/Codex should not start G5-04 code changes.

## 8. Validation / evidence discipline

Independent Review must inspect actual code/diff/tests/evidence, not Agent self-report.

Focused-first validation remains the default. Do not restore broad project matrices without a concrete cross-system reason.

Real Provider evidence must remain honest. External-provider unavailability is not permission to switch Provider or relabel deterministic proof as real integration proof.