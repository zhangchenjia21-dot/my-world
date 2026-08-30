# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / Freshness

Resolve current authority in this order:

1. Owner current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. current Product / Principles / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. relevant current supporting architecture decisions.
5. this repository `AGENTS.md` and current formal Task Packet.
6. verifiable current implementation/tests/HEAD.

Execution routing is governed by:

`Vibe-Coding/my world/AGENT_EXECUTION_ROUTING_CURRENT.md`

Current G4-06 semantic decision also requires:

`Vibe-Coding/my world/architecture/creation/G4-06_OPTIONAL_ENTRY_MATERIALIZATION_DECISION.md`

Source semantics remain governed by current G4-02R1 v0.2-r2 decisions/contracts, including optional temporal scope and Game-local evolvable semantics.

Before authoritative writes, refresh `main`; never overwrite unknown dirty/newer work.

---

## 2. Current phase / active task

Completed:

```text
G1 Foundation                         PASS / CLOSED
G2 AI Conversation Spine              PASS / CLOSED
G3 Persistence / Save / Timeline      PASS / CLOSED
G4-01 Application Shell / Lifecycle  PASS / CLOSED
G4-02R1 Source semantic re-audit      PASS / CLOSED
G4-03 Managed Local Source Library    PASS / CLOSED
G4-04 Multi-Game / Game Library       PASS / CLOSED
G4-05 New Game Wizard                 PASS / CLOSED
```

Active task:

> **G4-06 — Atomic Final Create**

Formal packet:

`docs/tasks/G4-06_ATOMIC_FINAL_CREATE_TASK.md`

Packet commit:

`2ad814a6f001c72c57d0616016dc7201dc1258cd`

Formal Code Base:

`d9f58963db26055f6ca1a54c26689baf63263ede`

Governance Base:

`62d7efcf0cad061543eb3c97779b311bf2563240`

Primary execution owner: **Codex**.  
Task nature: **backend creation/persistence mechanism**.  
Semantic + Independent Review owner: **GPT**.

Return ceiling:

> **READY FOR INDEPENDENT REVIEW**

G4-07+ must not start inside this task.

---

## 3. Execution ownership split

Project routing:

```text
GPT        → Meaning / architecture / governance / task shaping / Independent Review
Codex      → backend / mechanism implementation
Kimi       → frontend / UI / interaction implementation
Grok Build → search / external research / evidence discovery
```

Kimi may receive explicit backend fallback scope only when GPT assigns it. Do not infer fallback from historical tasks.

G4-06 is assigned to Codex because its primary risk is durable backend creation/idempotence/recovery, not frontend presentation.

---

## 4. G4-05 closure truth

G4-05R2 implementation/evidence:

- implementation: `ebd5645804334fc2f79cd18543a0571e1587fb14`;
- evidence/current accepted HEAD: `d9f58963db26055f6ca1a54c26689baf63263ede`.

GPT Independent Review: **PASS**.

Confirmed:

- primary Wizard reality path directly consumes frozen v0.2 full-fidelity 2 World + 6 Character;
- old v0.1 conversion packages are regression-only, not primary truth;
- compatible Han path reaches deterministic Review;
- real Han temporal incompatibility comes from production `build_compatibility_review()` / Source projection seam, not UI simulation;
- non-temporal/scenario World/Character path works without artificial historical restriction;
- player-facing summaries and temporal error copy are understandable;
- Guaranteed NPC copy does not claim opening/same-scene/already-known semantics;
- no Game SQLite / Game Library / Provider side effects occur in G4-05;
- Kimi changed frontend/tests/evidence only, not protected backend production seams.

Do not reopen G4-05 absent new P0 evidence or explicit Owner decision.

---

## 5. Frozen Source v0.2-r2 semantics

Core shape:

```text
thin identity / catalog metadata
+ ordered rich semantic_sections
+ disclosure = gm_reference | gm_private
+ package-local UTF-8 Markdown/TXT
+ Entry-scoped World sections only when authored need exists
+ optional Character T0 profiles only when authored need exists
+ exact immutable fingerprint over every declared byte
```

Temporal quarantine is optional authored capability, not a universal asset mode.

When temporal scope is used:

```text
World selected projection
= top-level always-safe sections
+ exact selected Entry sections

Character selected projection
= top-level always-safe sections
+ exact matching T0 profile sections
```

Never fallback to latest / nearest / later / complete-life biography.

If Character has zero profile coverage for selected World, preserve `no_world_coverage` / top-level-only rather than inventing a family hard block.

Fingerprint coverage remains broader than runtime visibility.

> **Source schema is not the possibility ceiling of the Living World.**

---

## 6. G4-06 creation boundary

G4-06 turns an already-valid exact Composition into one durable managed Game.

Required sequence semantics:

```text
Frozen Composition
→ immutable creating intent
→ fixed creation_id / game_id / setup identities
→ exactly one per-Game SQLite
→ selected Source projection materialization + exact provenance pins
→ DB identity verification
→ verified Game Library record
→ current selection
→ created
```

This is a replayable protocol across filesystem metadata + one SQLite + Game Library metadata. Do **not** pretend global ACID exists.

Same creation identity + same payload must converge to the same Game.  
Same creation identity + different payload must conflict/fail loud.

Valid durable Game truth is repaired/replayed forward; do not destructively delete it because a later metadata publish failed.

---

## 7. Optional Entry materialization｜frozen for G4-06

Canonical decision:

`Vibe-Coding/my world/architecture/creation/G4-06_OPTIONAL_ENTRY_MATERIALIZATION_DECISION.md`

Entry remains `0..1`.

### Exact Entry selected

Use the exact selected World Entry projection and exact Character T0 profile where authored/bound. Temporal incompatibility remains hard failure before durable creation publication.

### No Entry selected

Use only top-level World/Character `semantic_sections`.

Do not choose:

- first Entry;
- latest/nearest/default Entry;
- latest/nearest Character profile;
- a year inferred from family/name.

Do not turn “historical” into a hidden mode or universal required-Entry rule.

---

## 8. Game-local materialization invariants

- exact Source generation remains immutable;
- Game stores exact provenance pin: `asset_type / asset_id / version / generation_fingerprint`;
- only selected starting projection is copied into Game-local truth;
- Source asset IDs are provenance, not Game-local World/Character IDs;
- each created Game gets its own stable local Player/NPC identities;
- Guaranteed NPC means canonical cast member only, not opening presence/location/player knowledge/relationship;
- opening supplement/control mode belong to durable setup ancestry for later G4-07 consumption;
- do not create a closed universal Character/World ontology;
- prefer the existing opaque durable World document over speculative physical SQLite schema expansion;
- if a production schema migration is genuinely required, return `BLOCKED` to GPT before implementing it.

---

## 9. Multi-Game / persistence boundaries

G4-04 remains frozen:

> **One Game = One SQLite.**

Managed path derives from safe Game Library identity:

`user://my-world/games/<game_id>/game.sqlite`

Game Library registers only an existing Game whose internal identity has been verified.

Persistence already owns explicit initial Game/root/current World creation. G4-06 may compose or narrowly extend these seams but must not redesign G3 persistence/recovery or G4-04 topology.

No shared SQLite.

---

## 10. No G4-07 leakage

G4-06 must not:

- call Provider;
- create AI Opening prose;
- create accepted AI Conversation turns;
- claim narrative/playability Product PASS;
- start Expansion implementation;
- start Living World evolution platform work.

G4-06 terminal state is `created`.

G4-07 First Playable A will prove real Opening and requires Owner UAT for narrative richness, character individuality, anti-convergence and product value.

---

## 11. Technical baseline

```text
Host              Godot 4.7.2 Standard / non-.NET Windows x64
Language          GDScript
Runtime           same-process Godot Runtime
Provider          DeepSeek deepseek-v4-pro
Persistence       SQLite via godot-sqlite v4.9
Production schema v4
Game topology     One Game = One SQLite
Source Library    managed immutable filesystem generations
```

Routine Git/Godot/build/test/failure-injection work belongs to Codex. Owner handles irreducible product decisions and later real UAT. Engineering PASS does not equal Product PASS.
