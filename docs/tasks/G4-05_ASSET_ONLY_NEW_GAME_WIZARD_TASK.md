---
title: my world｜G4-05 Asset-only New Game Wizard v0.1 Task Packet
status: current-task-packet
task_id: G4-05
type: implementation
owner: Codex
created: 2026-08-29
updated: 2026-08-29
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: 67decaa23903803d34d97e6ea04adeeab0d7fe53
governance_base: 07e59ad54732bc70fd59c33f5caab8bdd1334b68
legacy_real_asset_reference_repo: zhangchenjia21-dot/sillytavern-assets
legacy_real_asset_reference_sha: 4a5364a042e41f4c8a69621fc4467956a78703c0
highest_implementation_status: READY FOR INDEPENDENT REVIEW
owner_uat_required: false
---

# TASK｜G4-05｜Asset-only New Game Wizard v0.1

Type: `implementation`  
Owner: `Codex`  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`  
Formal Code Base: `67decaa23903803d34d97e6ea04adeeab0d7fe53`

> 本任务第一次把 **Managed Source Library → 玩家 New Game 选择 → exact Game Creation Composition → Compatibility Review** 接成真实产品路径。它必须使用历史真实资产内容作为主要 Reality pressure，但 **不得创建 Game**；Atomic Final Create 属于 G4-06。

---

## 1. Outcome / Product Value

完成后：

```text
Application Launch
→ Main Menu
→ New Game
→ World Pack: exactly 1 exact managed generation
→ Entry/T0: 0..1 from selected World
→ Expansion: explicit none in this vertical
→ Player Character Card: exactly 1 exact managed generation
→ Guaranteed NPC Character Cards: 0..N exact managed generations
→ Minimal Settings
→ Compatibility Review
```

玩家看到和确认的是一次明确的**建局意图**，而不是 UI mode、当前列表状态或 mutable Source folder。

本任务服务产品核心价值中的“可安装、可组合的 World Pack / Character Card”以及“多个长期独立世界”，但 end-to-end 真正建局与 AI GM Opening 还未成立。因此：

- Engineering / Independent Review 可以关闭 G4-05；
- 本任务不单独要求 Owner UAT；
- 第一次完整 World+Character 产品 UAT 仍按 Roadmap 在 **G4-07 First Playable A** 执行。

---

## 2. Authority / Source Manifest

冲突时按以下顺序：

1. 用户当前明确指令。
2. `zhangchenjia21-dot/Vibe-Coding/main/AGENTS.md`。
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md` — Primary Purpose / first-generation creation path。
4. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md` — Source Library / Composition / Final Create boundary。
5. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` — G4-05 / G4-06 / G4-07 sequencing。
6. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md` — G4-04 CLOSED / G4-05 current / real-asset policy。
7. repository `AGENTS.md`。
8. G4-02 Source contract implementation/docs/tests。
9. G4-03 Managed Source Library implementation/docs/tests。
10. G4-04 Game Library/Application implementation/docs/tests。
11. `Vibe-Coding/skill/gpt/agent-task-packet/SKILL.md` and current coding/architecture skills referenced by repository rules。

Historical real-asset evidence source, **read-only / non-authoritative for new schema**:

```text
repo: zhangchenjia21-dot/sillytavern-assets
snapshot: 4a5364a042e41f4c8a69621fc4467956a78703c0
```

Relevant historical content:

```text
世界包/汉末三国_天下未定_World_Pack_v0.2.3.md
人物卡/汉末三国/...

世界包/埃瑟维亚_诸界余辉_World_Pack_v0.1.3.md
人物卡/诸界余辉/...
```

These files are **semantic pressure sources only**. Their old Markdown/schema/storage conventions do not become current production contracts.

Principle:

> **Migrate real content/complexity, not legacy schema debt.**

---

## 3. Start / Freshness Gate

Before implementation:

```powershell
Set-Location 'D:\AI\Projects\my-world'
git status --short
git rev-parse HEAD
git fetch origin
git rev-parse origin/main
git status -sb
```

Requirements:

- do not overwrite unknown dirty work;
- fast-forward to current `origin/main` containing this Task Packet / AGENTS projection;
- record `START_HEAD`;
- audit `67decaa... → START_HEAD`; expected increment is task/governance projection only;
- re-read current governance before changing Application/New Game behavior;
- before final push fetch/revalidate again;
- if another implementation already changes Wizard/Composition/Source-selection seams, audit first; if unsafe to absorb, return `BLOCKED`.

For historical asset source, verify the reference snapshot or a descendant with no semantic replacement of the specified assets. If local clone is unavailable, use Git/GitHub read-only retrieval; do not modify the historical repo.

---

## 4. Read First｜minimum sufficient set

1. `AGENTS.md`
2. this Task Packet
3. `src/应用壳.gd` + `src/main.tscn`
4. `src/source/L3_外交层/Source库公开接口.gd`
5. `src/source/L3_外交层/Source合同公开接口.gd` and public Source projection types needed by the Wizard
6. `docs/source/World Pack与Character Card合同v0.1.md`
7. `docs/source/Managed Local Source Library合同v0.1.md`
8. G4-03 reality/restart/tamper tests
9. G4-04 Application/Game Library tests relevant to Main Menu lifecycle
10. current Product / Architecture / Roadmap sections for New Game / Composition / G4-05–07

For real-asset conversion, read only the selected historical World/Character source files and directly referenced asset bytes needed to create current packages. Do not broadly port legacy implementation.

---

## 5. Pre-implementation matrices｜required before production code

Create:

`docs/tasks/G4-05_建局Composition与真实资产转换矩阵.md`

It must contain two sections.

### A. Wizard / Composition matrix

At minimum:

```text
Step / intent
→ visible choices
→ exact authoritative selection state
→ validation/cardinality
→ state cleared by upstream change?
→ review projection
→ durable side effect (must be NONE in G4-05)
→ back/cancel behavior
```

Cover:

- World selection;
- Entry selection;
- Expansion none;
- Player Character;
- Guaranteed NPCs;
- display name;
- control mode;
- opening supplement;
- Compatibility Review;
- cancel/back/reselect;
- Source current-generation changes after a selection has already been made.

### B. Historical real-asset conversion matrix

For every converted historical asset record:

```text
legacy repo/path + blob SHA
→ source family
→ current package path
→ legacy semantic material preserved
→ current v0.1 field mapping
→ legacy-only material intentionally omitted / carried as source_material
→ current-only metadata added for contract completeness
→ referenced visual/file bytes provenance
→ G4-02 validation result
→ G4-03 managed install result / fingerprint
```

Rules:

- do not rewrite historical lore into a synthetic summary merely to make conversion easy;
- preserve substantive real content and complexity;
- do not treat old field names as new schema authority;
- if an important real-content concept cannot be represented without abusing a catch-all field, report a **contract pressure finding**; fix current v0.1 only if clearly within G4-02 semantics and no compatibility forest is required;
- if the correct response would require a generic legacy importer/framework, return `BLOCKED` instead of building one.

---

## 6. Frozen first-generation Wizard semantics

### INV-WIZ-01｜Composition is intent, not Game truth

G4-05 may create an Application-owned in-memory `GameCreationComposition` or semantic equivalent.

It owns only the current Wizard intent:

```text
selected World exact generation
selected Entry id / none
selected Expansion exact generations = [] in this vertical
selected Player Character exact generation
selected Guaranteed NPC exact generations
Game display name
Protagonist Control Mode
opening supplement
```

It does **not** own or create:

```text
Game identity
SQLite database
Game Library record/current
World materialization
Character game-local identity
Timeline/Save/Conversation
Provider request
```

No durable draft persistence is required in v0.1. Returning to Main Menu may discard the composition after an explicit cancel/back path.

### INV-WIZ-02｜Exact generation is selected at click time

Source lists show **current installed** World/Character entries from G4-03.

When the player clicks a concrete Source item, Composition records at least:

```text
asset_type
asset_id
version
generation_fingerprint
```

plus stable display projection needed by the Review.

Do not store only `asset_id` and later silently resolve whatever is current.

If Source A generation X is selected, then Source A generation Y becomes current before Review, the composition remains pinned to X until the player explicitly reselects. G4-03 retained exact lookup must make this verifiable.

No historical generation picker is exposed.

### INV-WIZ-03｜Chooser visibility is not selection

Opening New Game, entering a step, highlighting a row, opening a chooser, first-row focus, list ordering, or default index must **not** create authoritative selection.

Only explicit interaction on a concrete asset item selects it.

Tests must catch the classic bug:

```text
list appears
→ first item looks selected/focused
→ Next becomes enabled without player click
```

This must fail.

### INV-WIZ-04｜World / Entry dependency

- exactly one World is required before leaving the World step;
- Entry is `0..1` and must belong to the selected exact World generation;
- `none` is valid if the World contract exposes zero or more Entries;
- changing the selected World clears any prior Entry selection;
- do not build Scenario/Beat DSL.

### INV-WIZ-05｜Expansion step is honest none-only in this vertical

Expansion is part of the frozen first-generation product flow, but Expansion Pack v0.1 is not implemented until G4-08.

Therefore G4-05 must present an honest optional Expansion step/state that can proceed with:

```text
selected expansions = []
```

Do not implement Expansion contract, inventory, fake packages, feature toggles, dependency resolution, or claim Expansion works.

Player-facing copy may state that no Expansion is selected/available in the current vertical; it must not pretend the feature is complete.

### INV-WIZ-06｜Character roles

Player Character:

```text
exactly 1
must have player_character_supported == true
```

Guaranteed NPCs:

```text
0..N
reusable Character Sources
not automatically opening / same-scene / player-known
```

The exact same Character generation must not simultaneously occupy Player Character and Guaranteed NPC roles in one Composition; treat that as invalid intent, not two copies of one person.

Changing Player selection must keep/remove NPC selections only according to this overlap invariant; it must not infer relationships or placement.

Do not invent same-family-only restrictions. Current contracts do not define automatic World↔Character compatibility by asset family.

### INV-WIZ-07｜Minimal Settings

Required:

- non-empty Game display name;
- `Protagonist Control Mode = Full | Light | Narrative`;
- default = `Light`;
- optional opening supplement.

Do not add a generic Settings framework.

### INV-WIZ-08｜Compatibility Review is deterministic projection

Review must display the actual composition that G4-06 would receive, including at least:

- exact World display identity/version;
- Entry / none;
- Expansion none;
- exact Player Character;
- Guaranteed NPC set;
- Game display name;
- control mode;
- opening supplement presence/content in a safe readable form.

Before showing a valid-ready review, re-resolve selected exact generations through G4-03 exact lookup. Missing/tampered managed generation fails loud; do not fallback to a newer current generation.

Review may compute validation/warnings from current deterministic contract facts. Do **not** add AI compatibility scoring or Provider calls.

### INV-WIZ-09｜G4-05 ends before creation

The review surface must not create a Game.

Any final action must be honest, e.g. disabled/placeholder “创建游戏（下一阶段接入）”, or stop at Review with clear copy. It must not:

- create per-Game SQLite;
- call `open_current_game()` creation seam;
- register Game Library record;
- mutate Game Library current;
- write Source pins/materializations;
- call Provider.

All of those belong to G4-06+.

### INV-WIZ-10｜Do not scan Source Library at Application boot

G4-01 remains true:

```text
Launch → Main Menu READY
```

Source inventory may be read when the player explicitly enters New Game / relevant step. Main Menu boot must not open Game DB or turn Source Library scanning into a hidden startup dependency.

---

## 7. Historical real-asset reality input｜mandatory

Synthetic G4-02 fixtures remain useful for failure tests, but **the primary G4-05 product/reality path must use converted historical real assets**.

Reference snapshot:

`zhangchenjia21-dot/sillytavern-assets@4a5364a042e41f4c8a69621fc4467956a78703c0`

Required real families:

### Family A｜汉末三国

World source:

`世界包/汉末三国_天下未定_World_Pack_v0.2.3.md`

Character source pool:

`人物卡/汉末三国/`

At least **three** substantive Character Cards from the existing pool must be converted, with at least one usable as Player Character and at least one usable as Guaranteed NPC. Prefer existing mature cards such as those already present under `CC-BATCH-01`; do not invent a synthetic replacement cast.

### Family B｜诸界余辉

World source:

`世界包/埃瑟维亚_诸界余辉_World_Pack_v0.1.3.md`

Character source pool:

`人物卡/诸界余辉/`

At least **three** substantive Character Cards must be converted, again covering Player-eligible and Guaranteed-NPC use.

### Conversion artifact location

Create current-format task-owned packages under a clearly isolated path, e.g.:

`tests/fixtures/g4_05/历史真实资产转换/<family>/<asset>/`

Each must be a **real current v0.1 Source package** loadable by G4-02 production contract and installable by G4-03 production Library.

No production legacy parser/importer may be introduced.

For current-only fields absent from legacy source (for example explicit `player_character_supported`), document the conversion decision in the matrix. Do not present such metadata as a historical fact.

Use actual historical referenced asset bytes where available. If a contract-required visual byte is genuinely absent from the historical snapshot, document that gap explicitly; do not fabricate new lore or pretend a missing historical visual existed.

---

## 8. Scope

### Allowed

- real New Game Wizard surfaces/state in existing Application scene or minimal dedicated scenes/components;
- minimal Application-owned Composition model/validator;
- G4-03 current inventory + exact lookup consumption;
- deterministic Compatibility Review;
- task-owned converted historical Source packages and provenance/mapping docs;
- task-owned Source Library preparation for tests;
- responsive/keyboard-safe UI adaptations directly needed by Wizard;
- tests under `tests/g4_05/`;
- narrow changes to existing G4-01 New Game placeholder surface;
- necessary current contract correction only if historical real-content pressure proves a genuine v0.1 expressiveness defect and the correction remains within existing World/Character semantics.

### Prohibited

- per-Game SQLite creation for a new Game;
- Game Library registration/current mutation from Wizard;
- G4-06 Final Create / Source pin / World or Character materialization;
- Provider call / AI compatibility judge / AI world generation;
- Expansion Pack contract/loader/runtime;
- Runtime Asset Resolution/cache;
- historical Source version picker;
- generic legacy importer/migration framework;
- Source Creator/editor/publishing UI;
- generic wizard framework / form DSL / dependency resolver;
- production SQLite schema change;
- cloud/store/network dependency.

---

## 9. Acceptance Criteria

### AC-01｜Real New Game entry

Main Menu `新游戏` enters the real Wizard, not the old placeholder. Application has no active Game Session and does not create/open any Game DB merely by entering the Wizard.

### AC-02｜World current inventory + explicit exact selection

World step lists current installed managed World Sources. Nothing is selected by list appearance/focus. Explicit click records exact generation identity and enables progression only after a valid World selection.

### AC-03｜Entry semantics

The Wizard exposes `0..1` Entry from the selected exact World. World change clears old Entry. `none` is valid. No Scenario/Beat DSL.

### AC-04｜Expansion none

The flow contains an honest Expansion step/state and can proceed with an explicit empty set. No Expansion contract/runtime is added.

### AC-05｜Character roles

Player step requires exactly one `player_character_supported` Character. Guaranteed NPC step supports 0..N exact Character generations. Same exact Character cannot occupy both Player and Guaranteed NPC roles.

### AC-06｜Minimal Settings

Display name required; Full/Light/Narrative available; Light default; optional opening supplement works. No Settings framework.

### AC-07｜Exact pin survives current update

Test sequence:

```text
select Source A generation X
→ install/publish A generation Y as new current
→ without explicit reselection, Composition/Review still references X
→ exact lookup validates X
```

No silent drift to Y.

### AC-08｜Review truth

Compatibility Review deterministically displays the exact selected intent and revalidates exact managed generations. Tampered/missing exact generation fails loud; no latest/current fallback.

### AC-09｜No G4-06 side effects

After full Wizard → Review:

- no new Game SQLite exists;
- Game Library inventory/current unchanged;
- no Source pin/materialization exists;
- no Provider request occurred.

### AC-10｜Historical real-asset conversion reality

Both historical families are represented by current-format converted packages. At least two real Worlds and at least six substantive real Character conversions pass G4-02 production validation and G4-03 managed installation. Wizard can list/select/review both families.

This is not satisfied by renaming the G4-02 synthetic fixtures.

### AC-11｜Responsive Windows UI

Real GUI evidence on Godot 4.7.2 Windows at least:

- maximized;
- 1280×720;
- 960×540.

All Wizard steps and Review remain usable: navigation controls reachable, no critical clipping/overlap, text fields usable, multi-select Character list usable.

### AC-12｜Navigation / reset correctness

Back preserves still-valid upstream selections; changing an upstream selection clears only dependent invalid state; cancel/back to Main Menu cleanly discards the draft and returns Application to `MENU_READY / Session ABSENT`.

### AC-13｜Regression

At minimum rerun relevant:

- G4-01 lifecycle/layout;
- G4-03 Source Library reality/restart/tamper;
- G4-04 multi-Game/legacy/recovery lifecycle;
- Main Menu boot isolation.

### AC-14｜Scope integrity

No G4-06+, SQLite schema, Provider, Expansion, runtime image resolution, legacy importer, Creator, or generic wizard framework leakage.

---

## 10. Required Evidence

Return observable evidence, not only code claims:

1. Base/Start/Final HEAD + `origin/main` revalidation + clean tree.
2. Changed-file summary.
3. Composition/real-asset conversion matrix path.
4. Historical source snapshot and exact legacy paths/cards chosen.
5. G4-02 validation + G4-03 install evidence for converted real assets.
6. Headless deterministic Wizard/Composition tests.
7. Exact-generation-drift test X→Y.
8. Negative tests: no implicit selection, wrong player eligibility, role overlap, missing/tampered exact generation, empty required settings.
9. Real GUI screenshots/evidence for maximized/1280×720/960×540.
10. Proof no Game DB/Game Library/Provider side effects from full Wizard→Review.
11. Relevant G4-01/G4-03/G4-04 regression results.
12. Scope check explicitly answering whether G4-06, SQLite schema, Provider, Expansion, legacy importer started.

Do not claim a Windows GUI/export result without actually running it.

---

## 11. Return Contract

Return exactly these sections:

```text
## Result
READY FOR INDEPENDENT REVIEW | BLOCKED

## Base / Freshness
...

## Wizard / Composition Shape
...

## Historical Real-Asset Conversion
...

## Changed
...

## Evidence
...

## Product Path Now
...

## Git
...

## Scope Check
...

## Remaining / Risks
...
```

Implementation Agent must not declare Independent Review PASS, Owner UAT PASS, G4-05 CLOSED, or start G4-06.

Highest allowed implementation state:

`READY FOR INDEPENDENT REVIEW`
