# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / Freshness

For every formal task, resolve current authority from GitHub `main` in this order:

1. User's current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`.
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`.
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md` and relevant supporting architecture.
6. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`.
7. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`.
8. This repository's current implementation/tests/HEAD.

If a current decision changes stage, task, prerequisite, architecture boundary, owner or Task DAG, perform Decision Propagation before continuing old work. Before authoritative writes/pushes, fetch/re-check HEAD and audit any Task Base → Current HEAD increment. Never overwrite unknown dirty or newer work.

## 2. Documentation shape

Project governance follows **Root is map; subfolders are depth.** Current state stays in the fixed governance status file; repository-native execution packets stay under `docs/tasks/`. Do not create new top-level `*_CURRENT.md` files for every task.

## 3. Current stage

Completed:

- G1 Foundation & Project Bootstrap — **PASS / CLOSED**
- G2 AI Conversation Spine — **PASS / CLOSED**
- G2-GATE — **PASS**
- G3 Persistent Game / Save / Timeline Foundation — **PASS / CLOSED**
- G3-GATE — **PASS**

G3 closeout line:

```text
7e2e622f03782a1d66f5f8837d739f900615b775  G3-06 crash / interrupted-write recovery
4529338728e7db91a2ce73b4dc8eec21c5530d0e  G3-07 persistence reality test + central recovery action
dbc6167598ecbde3578778e638e2494bffc48244  G3-07 IR-01 real Provider B-marker evidence repair
```

Current phase:

> **G4 — World Pack & Local Content Foundation**

Current task:

> **G4-01 — World Pack v0.1**

G4-02 is not authorized until G4-01 Independent Review PASS.

Current implementation owner for G4-01: **Grok Build**. User authorized Grok Build or KimiCode because current Codex quota is exhausted. Do not lower acceptance standards because the agent changes.

## 4. Core product/runtime invariants

- **Commodity Foundation, Owned Game Semantics.**
- **Engine-native, not engine-semantic-coupled.**
- UI projects authoritative game truth; it is not a second durable truth.
- **Model freedom first. Reversibility over prevention.**
- **Narrative richness over artificial brevity.** No arbitrary output-length caps or convenience `max_tokens` limits.
- **Model authors the world; Runtime makes it durable; Player owns the timeline.**
- **Source provides inertia; actors create history.**
- **Off-screen != Inactive.**
- **World Truth != NPC Knowledge != Player Knowledge.**
- **Context stays bounded, not starved.**

Hard boundaries remain: secrets/OS/filesystem authority, physical save corruption, non-atomic authoritative writes, unsafe concurrent writer ambiguity, arbitrary Mod execution and unrecoverable external side effects.

## 5. Accepted technical / persistence baseline

```text
Host                         Godot 4.7.2
Distribution                 Standard / non-.NET Windows x64
Language                     GDScript
Runtime                      same-process Godot Runtime
Provider                     DeepSeek deepseek-v4-pro
Persistence                  SQLite — ACCEPTED
SQLite binding               2shady4u/godot-sqlite v4.9
Production schema            v4
Product DB                    user://my-world/current-game.sqlite
```

G3 is closed. Established production capabilities include atomic durable mutation, accepted Conversation durability, reopen/resume, named Save, atomic Load/Restore, future-memory isolation, Recovery Checkpoints, single-writer process safety, SQLite-native verified backup and staged physical-corruption recovery.

Do not modify G3 persistence semantics/schema in G4-01 merely to store World Pack Source. G4-02 will decide the minimal Source → game-local provenance/materialization boundary using current evidence.

## 6. Canonical ownership / Source boundary

```text
Reusable Source
World Pack / Character / Expansion
↓ new-game materialization
Game-local Canonical Reality
↓ Runtime
Current World State
```

Formal rule:

> **World Pack Source != Game-local Instance != Runtime World State.**
>
> **Source defines the pre-game reference/inertia; after creation, game-local reality is authoritative.**

A World Pack is reusable read-only source content. It is not a mutable current Game database, not a Save, not a Timeline, and not automatically model-visible Context.

## 7. G4-01 specific boundary

G4-01 freezes and implements the first production **World Pack Source contract + explicit-root loader/validator**. It does **not** materialize Source into the current Game.

The v0.1 contract must support only the presently needed source categories:

```text
pack metadata / stable pack identity / schema version / author version
world / GM instructions
ordered Source lore entries
initial character Source seeds
authored map declaration
portrait / scene / map asset declarations
necessary mechanic declarations
```

### Minimal semantic limits

- Pack metadata must have stable `pack_id`, human display name, contract/schema version, and author-controlled pack version label.
- World instructions and Source lore are authored UTF-8 content. Structural validation must not become Narrative censorship.
- Initial character entries are **Source seeds**, not the G5 NPC schema. Keep them minimal: stable source identity, display identity, authored source text/reference, optional declared portrait reference. Do not freeze runtime stats, relationships, knowledge, faction state or autonomous-agent schema.
- Authored map is a Source declaration/reference only. Do not freeze full geographic/topology/runtime map semantics in G4-01.
- Asset declarations provide stable `asset_id`, a small source kind (`portrait` / `scene` / `map` where needed), and pack-root-relative file reference. G4-04 owns runtime Asset Resolution; G4-01 only proves declaration readability/root confinement and referenced-file existence where required.
- Mechanic declarations are data/content declarations only. They do not grant executable code, arbitrary GDScript, shell, DLL or OS authority.
- G4-01 defines no external declarative UI schema. World Pack / Mod UI contract remains G8.

### File / package shape

- First generation uses an explicit local directory root and UTF-8 JSON/text/files.
- One manifest/index file is the contract entry point; do not build a package archive format yet.
- The loader receives an **explicit pack root path**. No global discovery/catalog/install in G4-01; that is G4-03.
- All manifest file references must resolve within the supplied pack root. Reject absolute paths, drive-qualified paths and traversal escaping the root. Do not read arbitrary filesystem paths on behalf of pack content.
- Unsupported newer contract/schema version fails explicitly; malformed/missing required contract material fails explicitly. Do not silently invent defaults that change pack identity.
- Stable IDs within one pack must be unambiguous; duplicate source/asset identities are invalid.
- Unknown authored narrative text is allowed. Validation is for contract integrity/path safety/version/readability, not lore correctness.

### Scope exclusions

G4-01 must not implement:

- G4-02 Source → Game-local Instance / persistence binding;
- G4-03 Pack discovery/install/catalog/selection UX;
- G4-04 runtime Asset Resolution service;
- G4-05 second-pack proof;
- G5 NPC/Faction/Knowledge/Relationship/World Event gameplay schema;
- G6 UI redesign or G8 external declarative UI contract;
- arbitrary scripts/plugins from a World Pack;
- archive signing/store/cloud/mod marketplace.

A repository-owned task fixture is allowed to prove the complete v0.1 contract. It is evidence, not a second built-in product world.

## 8. Implementation shape / dependency discipline

Prefer a small production module under `src/world_pack/` (or the repository's clearly equivalent naming) with:

- immutable/read-oriented World Pack definition DTO/read model;
- explicit-root loader + structural/path validator;
- stable error/status results that do not leak Godot FileAccess objects upward.

Do not create ORM/DI/EventBus/Service Locator or empty L0-L3 forests for formal symmetry. Domain/read-model code must not depend on SceneTree/UI lifetime.

Pack loading must not mutate current Game, SQLite, Conversation or Context.

## 9. G4 Gate direction

G4 sequence:

```text
G4-01 World Pack v0.1
→ G4-02 Source → Game-local Instance
→ G4-03 Pack Discovery / Install / Load
→ G4-04 Asset Resolution
→ G4-05 Second Pack Fixture
→ G4-GATE
```

G4-GATE ultimately requires at least two World Packs to establish independent Games, while later changes to reusable Source cannot silently rewrite already-created game-local reality.

## 10. Evidence / execution discipline

Never claim Windows-local, Godot, filesystem, pack-path safety, parsing, export or runtime compatibility without real execution evidence.

Separate implementation, validation action, observable evidence and PASS/FAIL/NOT VERIFIED.

Routine Git/Godot/build/debug/QA is Agent work. Owner is only asked for genuine product UAT, secrets and irreducible product/architecture decisions.
