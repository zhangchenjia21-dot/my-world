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

Long-term routing:

```text
GPT        → meaning / architecture / governance / task shaping / Independent Review
Codex      → backend / mechanism / build-launch / validation implementation
Kimi       → frontend / UI / interaction implementation
Grok Build → search / external research / evidence discovery
Owner      → Product UAT / explicit product verdict
```

Temporary through 2026-09-06 23:59 (+08:00): Kimi owns all code-changing implementation tasks; GPT remains semantic owner/reviewer. Correct in-flight Kimi work may finish after expiry.

Gemini review remains CANCELLED / DO NOT EXECUTE. Review flow: Kimi implementation → GPT Independent Review.

## 2. Current state

```text
G1-G4                                        PASS / CLOSED
G5-01 World Turn / Semantic Materialization PASS / CLOSED
G5-02 Knowledge Provenance                  PASS / CLOSED
G5-03 NPC / Faction Agency                  ACTIVE
G5-03M1 Multi-Actor Agency v0.3             ENGINEERING PASS / CLOSED
G5-03M1R01C02 Dirty Opportunity             PASS / CLOSED
G5-03M1R02 Semantic-Terminal Wake Ownership PASS / CLOSED
G5-03M2 Stable NPC Materialization          ACTIVE — KIMI
G5-04 Event / Priority Evolution            NOT YET
```

Parent real G5-03 Provider proof remains `PENDING / EXTERNAL PROVIDER UNAVAILABLE`; do not relabel it PASS and do not switch Provider to manufacture evidence.

## 3. Current task

R02 review / M1 closeout:

- `docs/g5_03/G5-03M1R02_INDEPENDENT_REVIEW.md`
- `docs/g5_03/G5-03M1_CLOSEOUT.md`

Execute:

`docs/tasks/G5-03M2_STABLE_NPC_CREATION_SNAPSHOT_AND_REGISTRY_EXPANSION_TASK.md`

Canonical M2 decision:

`Vibe-Coding/my world/architecture/world/G5_STABLE_NPC_MATERIALIZATION_V0_1_DECISION.md`

Agency v0.3 remains protected:

`Vibe-Coding/my world/architecture/world/G5_AGENCY_SCHEDULER_V0_3_DECISION.md`

## 4. Frozen M2 behavior

New Game creation may expand the stable NPC pool beyond explicit Guaranteed NPCs, but identity/material authority remains Program-owned and Game-local:

```text
first creation-intent build
→ validated current Source inventory
→ Character Cards with exact_profile for selected World+Entry only
→ exclude Player + explicit Guaranteed asset IDs
→ deterministic stable_npcs snapshot
→ Program-owned local_character_id
→ exact provenance + frozen T0 source_projection
→ creation intent owns exact initial_setup
```

Same `creation_id` retry/resume must reuse the frozen intent and must not rescan Source current.

Existing Game with no `stable_npcs`:

```text
missing → []
no retrofit
no Source lookup
Guaranteed-only behavior remains valid
```

Runtime consumers use one unified stable-NPC helper:

- G5-02 actor roster = Player + Guaranteed + automatic stable NPCs;
- Agency eligible actor pool = Guaranteed + automatic stable NPCs, Player excluded;
- actor execution resolves frozen Source by exact local ID.

Registry membership grants identity/material only, not knowledge or an automatic action.

## 5. Protected boundaries

Do not:

- use display-name matching as authoritative identity;
- let models mint authoritative actor IDs;
- read mutable Source current during ordinary gameplay/Continue/Save/Restore/Agency;
- merge automatic stable NPCs into `guaranteed_npcs`;
- build a universal entity registry/simulator;
- implement Faction agency or G5-04;
- add SQLite schema/table/migration;
- change Source schema/UI/Public d20/mechanics;
- make real Provider calls for M2.

## 6. Slim validation rule

Keep focused work focused.

During implementation: run the M2 focused suite only.

After focused green, one final affected pass only:

- G4-06 Final Create / creation integration;
- G5-03 focused;
- G5-02 focused;
- one directly relevant G3 Save/Restore suite;
- `git diff --check`.

Do not rerun unrelated full G2/UI/Public-d20/project suites absent a concrete failure reason.

## 7. Completion

Kimi writes compact evidence, commits/pushes, and returns:

`READY FOR INDEPENDENT REVIEW`
