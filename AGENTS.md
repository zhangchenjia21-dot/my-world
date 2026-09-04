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

Repository remotes (Owner GitHub account): this repo is `github.com/zhangchenjia21-dot/my-world`; the companion governance repo is `github.com/zhangchenjia21-dot/Vibe-Coding`. "Refresh main / read doc X" instructions resolve against these two origins — fetch the local clones (`D:\AI\Projects\my-world`, `D:\AI\Projects\Vibe-Coding`) from `origin` first, then read the in-repo path.

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
G5-03M2A Registry Foundation                ACTIVE — KIMI
G5-03M2B Runtime Narrative Materialization  PLANNED / MUST FOLLOW M2A PASS
G5-04 Event / Priority Evolution            NOT YET
```

Parent real G5-03 Provider proof remains `PENDING / EXTERNAL PROVIDER UNAVAILABLE`; do not relabel it PASS and do not switch Provider to manufacture evidence.

## 3. Owner-corrected product rule

A Character Card is **not** required for a character to become a durable NPC.

The Stable Actor Registry must ultimately support:

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

Current task:

`docs/tasks/G5-03M2A_STABLE_ACTOR_REGISTRY_FOUNDATION_TASK.md`

Mandatory next after M2A Independent Review PASS:

`docs/tasks/G5-03M2B_RUNTIME_NARRATIVE_ACTOR_MATERIALIZATION_TASK.md`

Historical source-only packet is superseded and must not be executed:

`docs/tasks/G5-03M2_STABLE_NPC_CREATION_SNAPSHOT_AND_REGISTRY_EXPANSION_TASK.md`

Agency v0.3 remains protected:

`Vibe-Coding/my world/architecture/world/G5_AGENCY_SCHEDULER_V0_3_DECISION.md`

## 5. Frozen M2A behavior

M2A builds the registry foundation only:

- automatic exact-profile Source-backed NPC snapshot at first creation intent;
- optional `game_local_npcs` creation input for no-Card Game-local NPCs; missing means `[]` and existing callers remain valid;
- Program-owned local IDs for both families;
- Source-backed actors keep exact provenance + frozen T0 projection;
- no-Card actors keep honest `game_local_material`, never fake Source provenance;
- unified stable-NPC/actor-material/actor-roster helpers;
- G5-02/G5-03 consumers can use both material families;
- existing Games missing `stable_npcs` remain valid with no Source retrofit;
- helper currentness contract is prepared for future `runtime_narrative` origin records.

Do **not** implement runtime `new_actor_candidates` in M2A. That is M2B immediately after review.

## 6. Protected boundaries

Do not:

- require Character Cards for all stable NPCs;
- use display-name matching as authoritative identity;
- let models mint authoritative actor IDs;
- invent fake Source provenance for Game-local actors;
- read mutable Source current during ordinary gameplay/Continue/Save/Restore/Agency;
- alter Multi-Actor Agency v0.3 scheduling;
- add UI or SQLite migration/table;
- implement Faction agency or G5-04;
- change Public d20/mechanics;
- make real Provider calls for M2A.

## 7. Slim validation rule

During M2A implementation: run M2A focused tests only.

After focused green, one final affected pass only:

- G4-06 Final Create / creation integration;
- G5-02 focused;
- G5-03 focused;
- one directly relevant G3 Save/Restore suite;
- `git diff --check`.

Do not rerun unrelated full project/UI/Public-d20 suites absent a concrete reason.

## 8. Completion

Kimi writes compact evidence, commits/pushes, and returns:

`READY FOR INDEPENDENT REVIEW`
