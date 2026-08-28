---
title: my world｜G4-01 World Pack v0.1 Task Packet
status: current-task-packet
task_id: G4-01
type: implementation
owner: Grok Build
created: 2026-08-28
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: dbc6167598ecbde3578778e638e2494bffc48244
agent_rules_base: 038f21dabeeafd24c108576f80f2ab4f22653605
local_project: D:\AI\Projects\my-world
---

# TASK｜G4-01｜World Pack v0.1

Type: `implementation`  
Owner: **Grok Build**  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`

Implementation Agent 最高状态：`READY FOR INDEPENDENT REVIEW`。本任务默认不需要 Owner UAT；不得自行开始 G4-02。

---

## 1. Outcome

实现第一代 production **World Pack Source contract + explicit local-root loader/validator**，让核心 Runtime 可以在**不创建/修改 Game**的前提下，从一个明确的本地目录读取一个版本化、身份稳定、路径安全、结构可验证的 reusable World Pack definition。

完成后至少可以证明一个完整 fixture pack 表达并被读取：

```text
metadata / stable pack identity
+ world / GM instructions
+ ordered source lore
+ initial character source seeds
+ authored map declaration
+ portrait / scene / map asset declarations
+ mechanic declarations
```

本任务只建立 **Source**。`Source → Game-local Instance` 属于 G4-02。

---

## 2. Why Now

G3-GATE 已 PASS；可靠 Game persistence / Save / Restore / Recovery 已成为基础设施。下一阶段必须回答“游戏世界从哪里来”，但不能把产品重新硬编码成一个内置世界。

G4 的正确顺序是：

```text
G4-01 Source contract
↓
G4-02 Source → game-local materialization
↓
G4-03 discovery / install / load
↓
G4-04 asset resolution
↓
G4-05 second-pack proof
```

如果 G4-01 现在顺手创建 Game rows、Pack browser、NPC runtime schema 或 external UI schema，会把多个后续阶段错误折叠在一起。

---

## 3. Authority / Source Manifest

冲突时按以下顺序：

1. 用户当前明确指令：G3-07 Owner UAT PASS，进入下一步；后续可使用 Grok Build / KimiCode。
2. `Vibe-Coding/AGENTS.md` current。
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md` — current canonical product spec。
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`。
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md`。
6. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`。
7. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md` — G3-GATE PASS / G4-01 current。
8. repository `AGENTS.md` at/after `038f21dabeeafd24c108576f80f2ab4f22653605`。
9. current implementation/tests on `main`。
10. `Skill/skill/gpt/agent-task-packet/SKILL.md` v1.2 and `Skill/skill/gpt/lifecycle-dev-process/SKILL.md` v2.2 as execution method。

Not authoritative unless explicitly referenced：DSH/The World implementation、old chat summaries、future G5 schema ideas、future G8 external UI protocol。

---

## 4. Read First

Start：

```text
git fetch origin
git status --short
git rev-parse HEAD
```

Fast-forward to latest `origin/main`; confirm current HEAD contains:

```text
038f21dabeeafd24c108576f80f2ab4f22653605  G4-01 AGENTS.md
this Task Packet commit
```

Initial working set：

```text
AGENTS.md
this Task Packet
project.godot
export_presets.cfg
src/ current top-level module naming / dependency examples
src/context/上下文组装器.gd (only to preserve "Source != Context" boundary)
src/persistence/ public boundary (only to ensure G4-01 performs no DB mutation)
tests/g3_07/运行现实验证.ps1 and current Windows export/run harness patterns
```

Only expand reading when current evidence is insufficient; explain why in Final Report. Do not scan the entire repository by default.

---

## 5. Pre-implementation Contract / Failure Matrix

**Complete this before production code.** Save under `docs/tasks/G4-01_实现前WorldPack契约矩阵.md` or clearly equivalent task-scoped note.

Cover at least:

```text
valid minimal pack
valid complete v0.1 pack with every supported source category
manifest missing
manifest malformed JSON
unsupported schema version
missing/empty required pack identity or world instructions
ordered lore with stable IDs
duplicate lore_id
duplicate character source_id
duplicate asset_id
duplicate mechanic_id
character portrait reference -> missing asset
character portrait reference -> non-portrait asset
authored map -> missing map asset
safe nested relative path
../ path escape
absolute / drive-qualified / res:// / user:// / URL-like external path
referenced text file missing
referenced asset file missing
UTF-8 source text read
unknown narrative content / long free-form content remains allowed
pack load does not mutate SQLite/current Game/Conversation/Context
same pack loaded twice yields same Source identities/order
external filesystem pack can be read in Windows/export smoke
```

For each case record：input shape → expected status/error → Source read model result → files touched/read → Game/DB side effect (`none`) → evidence.

---

## 6. Decision Digest / Invariants

### DEC-01｜World Pack is reusable Source, not live Game truth

Canonical chain：

```text
World Pack Source
↓ G4-02 materialization (NOT THIS TASK)
Game-local Canonical Reality
↓
Runtime World State
```

G4-01 loader must not create Game, Timeline Node, Save, Conversation entry, World mutation or Context message.

### DEC-02｜First-generation package is a local directory

Use an explicit local directory root. Fixed entry point:

```text
<pack-root>/world_pack.json
```

Use UTF-8 JSON/text/files. Do not invent archive/container/signing/install formats in G4-01.

### DEC-03｜Manifest v1 required fields

First-generation manifest must minimally carry:

```text
schema_version   integer, exactly 1 for G4-01
pack_id          stable non-empty Source identity
pack_version     non-empty author-controlled version label
display_name     player/author-readable name
world_instructions  pack-root-relative UTF-8 text path
```

Optional metadata such as description/author is allowed only if it stays small and does not create a generic metadata platform.

Do not derive pack identity from folder name or display name.

### DEC-04｜Supported Source sections

Manifest v1 must support these optional sections/categories; a pack does not need every category, but the complete fixture must exercise all of them.

#### Source lore

Ordered array of entries with at least:

```text
lore_id
optional title
a pack-root-relative UTF-8 text path
```

Order is authored Source order and must be preserved.

#### Initial character Source seeds

Each seed is intentionally smaller than future NPC runtime schema:

```text
source_id
display_name
authored source text path
optional portrait_asset_id
```

Do **not** add runtime HP/stats/relationship/knowledge/faction/agenda/autonomy schema just to look complete.

#### Authored map declaration

At most one first-generation authored map entry is sufficient:

```text
map_id
display_name
map_asset_id
optional source_data_path/reference
```

G4-01 does not interpret/freeze map topology, roads, geography or gameplay movement semantics. `source_data_path`, if supported, remains authored source material/reference only.

#### Asset declarations

One flat declaration list is preferred over separate subsystems:

```text
asset_id
kind = portrait | scene | map
path = pack-root-relative file path
```

G4-01 validates declaration identity, safe path and referenced-file presence. It does not become the G4-04 runtime Asset Resolution service and does not preload/decode every image into gameplay memory.

#### Mechanic declarations

Minimal data-only declaration:

```text
mechanic_id
optional config_path
```

G4-01 does not execute the mechanic or define its final gameplay schema. A config reference may be validated/read as source material only if necessary; do not create a generic scripting/plugin system.

### DEC-05｜Recommended manifest shape

Equivalent naming is allowed only if it preserves the semantics above. Preferred shape:

```json
{
  "schema_version": 1,
  "pack_id": "fixture.g4_01",
  "pack_version": "0.1.0",
  "display_name": "G4-01 Fixture World",
  "description": "optional",
  "world_instructions": "content/world_instructions.md",
  "source_lore": [
    {"lore_id": "world.overview", "title": "Overview", "text_path": "lore/overview.md"}
  ],
  "initial_characters": [
    {"source_id": "character.guide", "display_name": "Guide", "source_text_path": "characters/guide.md", "portrait_asset_id": "portrait.guide"}
  ],
  "authored_map": {
    "map_id": "map.main",
    "display_name": "Main Map",
    "map_asset_id": "map.main.image"
  },
  "assets": [
    {"asset_id": "portrait.guide", "kind": "portrait", "path": "assets/portraits/guide.png"},
    {"asset_id": "scene.arrival", "kind": "scene", "path": "assets/scenes/arrival.png"},
    {"asset_id": "map.main.image", "kind": "map", "path": "assets/maps/main.png"}
  ],
  "mechanics": [
    {"mechanic_id": "travel.clock", "config_path": "mechanics/travel.json"}
  ]
}
```

This JSON is a semantic reference, not permission to add fields for future G5/G8 needs.

### DEC-06｜Technical validation may be strict; authored content stays free

Fail-loud for technical contract problems：

```text
manifest missing / malformed
unsupported schema
missing required identity/instructions
unsafe filesystem reference
missing referenced required file
duplicate stable identity
broken cross-reference
```

Do **not** validate lore/personality/world instructions with regex, keyword whitelist, arbitrary length caps or genre rules. Non-empty UTF-8 authored content is enough where content is required.

### DEC-07｜Pack-root confinement is a hard boundary

A pack reference may not cause Runtime to read outside the explicit pack root.

Reject at least：

```text
absolute paths
Windows drive-qualified paths
UNC/external roots
.. traversal escaping pack root
res://
user://
http:// / https:// or equivalent URL path substitution
```

Normalize/join and verify the resolved path remains inside the supplied root before opening it. Do not trust string concatenation alone.

Do not add arbitrary shell/script/DLL execution.

### DEC-08｜Stable IDs and cross references

Within one pack, at least `lore_id`, character `source_id`, `asset_id`, and `mechanic_id` must be unique in their category.

Character `portrait_asset_id`, when present, must resolve to a declared `portrait` asset. Authored map `map_asset_id` must resolve to a declared `map` asset.

Do not silently repair typos by matching display names or filenames.

### DEC-09｜Loader result is a read model, not a Godot Resource truth

Production API should return a stable success/failure result and a World Pack Source read model/definition. It must not leak `FileAccess`, open handles or mutable OS resources upward.

Prefer a small module under `src/world_pack/`; do not build ORM/DI/EventBus/Service Locator or empty L0-L3 forests for symmetry.

Source files remain reusable source of the definition; loading them does not make them current World truth.

### DEC-10｜Explicit-root only in G4-01

The production loader API accepts one explicit local pack root.

Do not scan `user://`, repository folders, Steam directories or arbitrary drives for packs. Discovery/install/catalog/selection belongs to G4-03.

### DEC-11｜External filesystem / exported game compatibility

The contract must not depend on pack files being compiled into `res://`/PCK. Prove on Windows that a task-owned pack directory on normal filesystem can be loaded using the same production loader, including an exported Windows Desktop smoke or an evidence-equivalent product binary path.

A narrow test-only launch seam is allowed. Do not build Pack selection UI.

### INV-SOURCE-01

Loading reusable Source never mutates existing Game-local reality.

### INV-SOURCE-02

Source identity is explicit and stable; display strings/folder names are not authority.

### INV-SECURITY-01

World Pack v0.1 is data/content, not an arbitrary-code plugin surface.

### INV-PRODUCT-01

World Pack exists to let different authored worlds feed the same AI RPG Runtime without hardcoding one world. Contract rigor must protect readability/safety without starving creative Source content.

### INV-SCOPE-01

Do not start G4-02/G4-03/G4-04/G4-05 or G5/G6/G8 work.

---

## 7. Scope

### Allowed

- `src/world_pack/` minimal production Source contract/loader/validator/read model;
- `tests/g4_01/` focused tests/harness;
- `tests/fixtures/world_packs/g4_01_*` one complete repository fixture where useful;
- task-scoped contract/failure matrix and engineering evidence note under `docs/tasks/`;
- minimal export/test harness seam strictly necessary to prove external filesystem pack loading;
- tiny task-owned placeholder asset files for fixture evidence;
- current dependency/import configuration only if strictly required.

### Prohibited

- SQLite schema v5 / World Pack persistence rows;
- binding a pack to current Game;
- creating/selecting a new Game from a pack;
- Pack discovery/install/catalog/browser UI;
- generic Asset Resolution service or asset cache;
- NPC/Faction/Knowledge/Relationship/World Event runtime schema;
- map topology/runtime navigation system;
- mechanic execution engine;
- G6 UI redesign;
- G8 external declarative UI schema / arbitrary Mod scripts;
- archive/signing/cloud/store/marketplace;
- output-length restrictions or Narrative validators.

---

## 8. Required Deliverables

1. Pre-implementation World Pack contract/failure matrix.
2. Production World Pack Source definition/read model.
3. Production explicit-root loader + technical validator.
4. Manifest v1 handling for metadata/instructions/lore/character seeds/map/assets/mechanics.
5. Safe root-confined path resolution helper local to this domain or a clearly justified tiny shared seam.
6. Stable duplicate-ID and cross-reference validation.
7. One complete fixture pack exercising every v0.1 Source category.
8. Deterministic invalid-pack tests for malformed/schema/identity/path/missing-file/duplicate/reference failures.
9. Proof ordered lore and stable source identities survive repeated loads.
10. Proof loading does not mutate current Game/SQLite/Conversation/Context.
11. Windows filesystem + exported executable (or evidence-equivalent product binary) pack-load smoke.
12. Relevant G3-07 deterministic regression / normal product startup regression.
13. `git diff --check`, dependency/secret hygiene, clean worktree/fresh push evidence.
14. `docs/tasks/G4-01_工程验证记录.md` or equivalent focused evidence record.

---

## 9. Engineering Acceptance

### AC-01 Valid complete pack

Complete fixture loads successfully and exposes exact stable pack identity/version/display name, world instructions, ordered lore, character Source seeds, authored map declaration, declared assets and mechanics.

### AC-02 Stable/read-only Source behavior

Load the same unchanged pack twice：stable IDs/order/content match. No current Game/SQLite/Conversation/Context mutation occurs as a side effect.

### AC-03 Contract failures are explicit

Missing manifest, malformed JSON, unsupported schema, missing required identity/instructions and invalid type/shape return stable failure statuses/messages; no crash and no partial definition is published as success.

### AC-04 Identity/reference integrity

Duplicate lore/character/asset/mechanic IDs fail. Broken portrait/map references fail. No matching by display-name heuristics.

### AC-05 Path safety

At least safe nested path succeeds while traversal/absolute/drive-qualified/`res://`/`user://`/URL-like escaping references are rejected before external content is read.

Tests must use task-owned roots and a sentinel outside the pack root to demonstrate that an escaping reference cannot cause that sentinel to be consumed as pack content.

### AC-06 Creative content remains open

Long/free-form UTF-8 lore, character description and world instruction fixture content loads without keyword/genre/regex censorship or arbitrary length caps.

### AC-07 No arbitrary code authority

No pack field can cause GDScript/DLL/shell/executable loading or invocation. Mechanic declaration remains data-only and unexecuted.

### AC-08 Exported/local filesystem compatibility

Windows production loader can read a task-owned external pack directory in the Godot 4.7.2 Windows Desktop environment; implementation is not `res://`-only. Export/build remains successful.

### AC-09 Regression / scope

G3 current persistence/product startup remains healthy; no SQLite schema change; no G4-02+ behavior; no new framework/dependency unless explicitly justified and reviewed.

---

## 10. Product Value Acceptance

G4-01 is a contract/foundation task, not yet a player-facing pack browser, so no Owner UAT is required by default.

Independent Review should still ask whether the contract serves the product value:

> **Can a genuinely different authored world be represented as reusable Source without hardcoding current game's NPC/map/runtime semantics into the pack format?**

Product-level failure even if tests are green：

- contract is secretly specific to one world/setting;
- initial character Source seed already freezes G5 NPC runtime schema;
- authored map declaration already freezes a premature world-map engine schema;
- pack requires code execution for ordinary content;
- creative lore/instructions are constrained to make validator implementation convenient;
- loading Source mutates current Game.

G4-05 will later provide the stronger two-pack product proof.

---

## 11. Validation Order

Run cheapest/focused first：

```text
1. freshness / parse / diff-check
2. valid minimal + complete manifest focused tests
3. invalid JSON/schema/required-field tests
4. duplicate ID / cross-reference tests
5. path-confinement + outside sentinel tests
6. repeated-load stability / no-side-effect tests
7. G3-07 deterministic reality / product startup regression
8. Windows Desktop export
9. exported/local-filesystem World Pack smoke
10. final dependency/secret/diff/status audit
```

Real DeepSeek is **not required** for G4-01 unless implementation unexpectedly touches Provider/Context request behavior; if it does, justify the scope expansion and run appropriate regression.

---

## 12. Git / Integration

- Record start HEAD/status after fetch/fast-forward.
- Formal production code base before G4-01 governance/task commits: `dbc6167598ecbde3578778e638e2494bffc48244`.
- Do not overwrite unknown dirty worktree.
- Before push, fetch/revalidate `origin/main`; audit any new commits.
- Implementation commit must clearly name G4-01 outcome.
- Fast-forward push only; no force push/destructive history rewrite.
- Final report must confirm `HEAD == origin/main` and clean worktree.

---

## 13. Stop / Return Conditions

Return `BLOCKED` rather than inventing architecture if：

- existing current product sources conflict on whether Source or game-local reality is authoritative;
- a valid v0.1 contract appears to require freezing G5 NPC/Faction/map runtime semantics;
- exported local filesystem loading is impossible without changing distribution/runtime architecture;
- safe pack-root confinement cannot be proven with current Godot filesystem primitives without a material security compromise;
- completing G4-01 requires SQLite schema changes / G4-02 materialization;
- current `main` gains a superseding decision/task while work is in progress.

Do not solve blockers by starting G4-02+, accepting arbitrary pack scripts, or weakening path safety.

---

## 14. Final Report Contract

Return exactly one top status：

```text
READY FOR INDEPENDENT REVIEW
```

or

```text
BLOCKED
```

Report at least：

- start/final HEAD, origin/main, worktree;
- matrix/evidence-note paths;
- final manifest v1 shape and production module paths;
- valid complete fixture evidence;
- stable IDs/order/repeated-load evidence;
- path-confinement/outside-sentinel evidence;
- invalid schema/duplicate/reference/missing-file evidence;
- no current Game/DB/Conversation/Context side-effect evidence;
- mechanic/data-only/no-code-execution boundary;
- Windows external-filesystem/export evidence;
- relevant G3 regression;
- scope/dependency/secret check;
- any non-blocking contract question deferred to G4-02/G4-04/G5/G8.
