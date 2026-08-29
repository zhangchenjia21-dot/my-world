# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / Freshness

For every formal task, resolve current authority from GitHub `main` in this order:

1. User current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`.
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`.
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md` and relevant supporting decisions.
6. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`.
7. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`.
8. Current implementation/tests/HEAD.

For current Source semantics also read:

- `Vibe-Coding/my world/architecture/source/G4_SOURCE_SEMANTIC_OWNERSHIP_AND_REAUDIT_DECISION.md`;
- `Vibe-Coding/my world/architecture/source/G4_GAME_LOCAL_EVOLVABLE_SEMANTICS_DECISION.md`;
- `docs/source/G4-02R1_SOURCE_SEMANTIC_AUDIT.md`;
- `docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md`;
- `docs/source/G4-02R1_REAL_ASSET_V0_2_MIGRATION_SPEC.md`.

Before authoritative writes, revalidate `main`; never overwrite unknown dirty/newer work.

## 2. Current phase / task

Completed engineering foundation:

- G1 Foundation — PASS / CLOSED
- G2 AI Conversation Spine — PASS / CLOSED
- G3 Persistence / Save / Timeline — PASS / CLOSED
- G4-01 Application Shell / Lifecycle — PASS / CLOSED
- G4-02 original v0.1 engineering implementation — HISTORICAL PASS
- G4-03 Managed Local Source Library — PASS / CLOSED
- G4-04 Multi-Game / Game Library — PASS / CLOSED

Current task:

> **G4-02R1 — World / Character Source Semantic Re-audit**

Current substate:

```text
semantic audit                COMPLETE
v0.2 semantic contract        FROZEN / implementation pending
real v0.2 asset migration     ACTIVE — GPT owned
```

Task record:

`docs/tasks/G4-02R1_SOURCE_SEMANTIC_REAUDIT_TASK.md`

Owner: **GPT**.

**Codex has no active implementation task.**

Previous `docs/tasks/G4-05R1_REAL_ASSET_FIDELITY_CORRECTION_TASK.md` is **SUPERSEDED / DO NOT EXECUTE**.

G4-05 remains **REWORK / HOLD**. G4-06+ must not start.

## 3. Ownership decision

Formal working split:

> **GPT owns Meaning; Codex owns Mechanism.**

GPT owns:

- World Pack / Character Card / Expansion Pack semantic design;
- authored content ownership and Source → Game-local → Runtime boundaries;
- real historical asset semantic migration;
- GM instructions, personality, autonomy, behavior, knowledge-boundary semantics;
- semantic fidelity review and schema-need decisions.

Codex may be used only after the real v0.2 package shape/content is frozen for:

- GDScript / validator / loader / fingerprint implementation;
- filesystem / Managed Source Library;
- SQLite / Runtime / lifecycle;
- UI wiring;
- tests, failure injection, build/export/Windows evidence.

Do not let an implementation Agent independently compress, paraphrase or redesign complex narrative assets merely to make them easier to parse.

## 4. No destructive rollback

Do not reset Git to pre-G4-02.

Preserve verified engineering and correct forward:

```text
verified engineering history
→ semantic correction
→ faithful content migration
→ affected-code repair only
→ regression
```

G4-03 remains PASS unless a concrete corrected-contract regression is found. G4-04 remains PASS/CLOSED. G4-05 implementation candidate `145c3e1192b443f6284da7f36aee74619adad5bf` is preserved as provisional Wizard/Composition engineering evidence.

## 5. G4-02R1 semantic result

Historical evidence remains pinned read-only:

```text
repo: zhangchenjia21-dot/sillytavern-assets
snapshot: 4a5364a042e41f4c8a69621fc4467956a78703c0
```

Audited primary assets:

- World: `世界包/汉末三国_天下未定_World_Pack_v0.2.3.md`
- World: `世界包/埃瑟维亚_诸界余辉_World_Pack_v0.1.3.md`
- Characters: 刘备、曹操、孙权、莉维娅·塞兰、阿德里安·维尔克、杜恩·石痕

Verdict:

> **v0.1 semantic adequacy FAIL — v0.2 contract correction required.**

Reasons:

- Character `summary/traits/background/drives` collapses real authored depth;
- required portrait forces dishonest Source placeholder behavior when no authored visual exists;
- World lacks section-level disclosure/retrieval semantics;
- arbitrary mandatory `source_material` is an unproven catch-all / hidden-schema risk;
- replacing this with dozens of fixed Character fields would recreate the giant-schema failure mode.

## 6. Source v0.2 semantic freeze

`docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md` is semantic authority while loader implementation remains pending.

Core design:

```text
thin identity
+ catalog_summary
+ compact always-on instructions where appropriate
+ ordered semantic_sections
+ disclosure = gm_reference | gm_private
+ package-local UTF-8 Markdown/TXT content files
+ exact fingerprint over all declared bytes
```

### World

- retain `world_instructions`, `gm_instructions`, `entries[]`, `authored_assets[]`;
- replace compact `source_lore` with rich semantic sections;
- remove arbitrary mandatory `source_material`;
- GM-only World truth is an explicit `gm_private` section.

### Character

- replace `public_profile` / `gm_private_profile` with rich semantic sections;
- broad recommended types: identity, personality, capabilities, behavior, relationships_autonomy, expression, knowledge, t0_boundary, etc.; vocabulary is not a universal closed ontology;
- internal skill/spell/table structure remains authored content until a real mechanic consumer pulls out a machine contract;
- portrait is optional;
- `player_character_supported` remains explicit.

Important:

> **`catalog_summary` / `gm_reference` != Player Knowledge != Character Knowledge.**

Semantic section is a retrieval unit, not a requirement to dump the whole asset into every model prompt.

## 7. Game-local evolvable semantics

Canonical decision:

`Vibe-Coding/my world/architecture/source/G4_GAME_LOCAL_EVOLVABLE_SEMANTICS_DECISION.md`

Invariant:

> **Source schema is not the possibility ceiling of the Living World. Game-local semantic structure is evolvable.**

After Final Create:

- exact Source generation stays immutable;
- Game-local canonical object owns lived history;
- Program-owned identity/provenance/lifecycle kernel stays stable;
- model/runtime may evolve previously unanticipated local semantics;
- model must not rewrite Source/global Source contract or physical SQLite schema;
- if Location/Relationship/Knowledge/Injury/Inventory/Faction/etc. already owns a concept, use that Domain instead of duplicate generic truth;
- local semantic evolution must be durable and Timeline/Save/Restore reversible;
- repeated open facets become formal Domains only after real consumers appear.

## 8. Current GPT-owned real asset migration

Migration specification:

`docs/source/G4-02R1_REAL_ASSET_V0_2_MIGRATION_SPEC.md`

Rule:

> **preserve → re-home → explicitly omit only when owner is wrong.**

Required packages:

```text
World x2
- 汉末三国：天下未定
- 埃瑟维亚：诸界余辉

Character x6
- 刘备
- 曹操
- 孙权
- 莉维娅·塞兰
- 阿德里安·维尔克
- 杜恩·石痕
```

Do not replace original major sections/tables/private truth with short summaries. Missing authored visual remains absent; Application placeholder is not Source-authored content.

## 9. Source / Game boundaries

Formal separation:

```text
Reusable Source Assets
↓ explicit exact selection
Game Creation Composition
↓ Final Create
Game-local Canonical Reality
↓ current execution
Runtime State
```

Source may own stable authored starting reference, pre-T0 history and guidance. Source must not own current live facts such as:

- current location;
- current relationship/favor/trust;
- current injury/condition;
- current knowledge/inventory;
- player-known state;
- opening placement guarantee;
- current Timeline/Save/Conversation/runtime history.

Source prose may discuss these concepts as boundaries or pre-T0 authored history. Do not keyword-police prose; prohibit authoritative structured live-state ownership.

Character Card remains reusable Character Source, not player-only. Guaranteed NPC means selected exact Character becomes part of Game canonical cast at Final Create; it does not imply opening appearance, same scene, player knowledge, relationship or automatic Context inclusion.

## 10. Exact generation / library invariants

Keep:

```text
Source stable identity != exact immutable generation
Managed Source Library != Game Library
One Game = One SQLite
Game Library metadata != gameplay truth
```

For v0.2, exact generation must include canonical manifest + every semantic section content file + every declared authored asset + optional Character portrait when present.

Existing Game must pin exact immutable Source generation. Source update must not silently change old Game content.

## 11. G4-05 preserved engineering

The G4-05 Independent Review accepted these mechanics as provisional evidence:

- chooser visibility/focus != selection;
- only explicit click selects exact generation;
- composition stores exact generation fingerprint;
- World change clears dependent Entry;
- Player eligibility enforced;
- same exact Character cannot be Player + Guaranteed NPC;
- selected X does not drift to newer current Y;
- Review performs exact lookup and tamper/missing fail-loud;
- Wizard→Review creates no Game SQLite, Game Library mutation or Provider call;
- Cancel discards composition and returns Main Menu / no Session.

Do not rewrite these seams during semantic work unless v0.2 creates a concrete incompatibility.

## 12. First-generation product path

```text
Main Menu
→ New Game
→ exactly 1 World Pack
→ Entry/T0 0..1
→ Expansion 0..N (none currently honest/allowed)
→ exactly 1 Player Character Card
→ 0..N Guaranteed NPC Character Cards
→ Game display name
→ Protagonist Control Mode: Full | Light | Narrative
→ optional opening supplement
→ Compatibility Review
→ Atomic Final Create (G4-06)
```

Do not add no-World/no-Character/blank-world direct creation, historical Source picker, Creator path, complex Expansion chooser or generic form framework in current G4.

## 13. Technical baseline

```text
Host             Godot 4.7.2 Standard / non-.NET Windows x64
Language         GDScript
Runtime          same-process Godot Runtime
Provider         DeepSeek deepseek-v4-pro
Persistence      SQLite via godot-sqlite v4.9
Schema           production v4
Game topology    One Game = One SQLite
Source Library   managed immutable filesystem generations
```

Engineering evidence must distinguish implementation, validation action and observable proof. Owner handles genuine product UAT/irreducible decisions; routine Git/Godot/build/debug/QA remains engineering work.
