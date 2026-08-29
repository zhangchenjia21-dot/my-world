---
title: G4-02R1｜汉末三国 World Full-Fidelity Ownership Mapping
status: current-migration-mapping
owner: GPT
created: 2026-08-29
source: zhangchenjia21-dot/sillytavern-assets@4a5364a042e41f4c8a69621fc4467956a78703c0
source_path: 世界包/汉末三国_天下未定_World_Pack_v0.2.3.md
source_blob: 9d05fb2dadad8ea140d611e9f3bab49c0d8f2677
contract: v0.2-r2
---

# G4-02R1｜汉末三国 World Full-Fidelity Ownership Mapping

## 1. Goal

本文件回答一个问题：

> 原始 53KB `天下未定` 的每个 substantive chapter，在 v0.2-r2 T0 quarantine 下应该去哪里？

默认动作：

> **preserve → re-home → temporal-split only where needed → explicit omission only when current product owner is wrong.**

不是把 World 压成几个 lore bullet，也不是把原文 184—280 全塞进每个 Runtime Context。

---

## 2. Target content layers

```text
A. catalog / selection metadata
   player-facing library / New Game selection
   not automatic model context

B. always-safe World semantic sections
   safe for every supported fixed Entry

C. reusable historical past segments
   referenced only by Entries for which the segment is already past

D. selected Entry current snapshot
   current T0 world condition / pressure

E. explicit migration audit / deferred material
   preserved as governance evidence when current product has no runtime consumer
```

No ordinary Runtime reference-only complete future chronology is retained.

---

## 3. Chapter-by-chapter mapping

| Legacy material | v0.2-r2 owner | Preservation rule |
|---|---|---|
| `这份材料是什么` | B | preserve World purpose / source-vs-game distinction; remove instruction to “通读整包” as Runtime strategy |
| `这份材料不负责什么` | B | preserve domain ownership and optional-expansion boundaries; no machine dependency implied |
| Ch.1 世界定位 | A + B | runtime keeps scale/tone/ordinary-person freedom; player-facing historical Entry-name examples remain catalog/UI only |
| Ch.2 世界如何运转 | B | preserve T0, causality, actor autonomy, player-not-center, Source/Game boundary; remove explicit future-event examples from Runtime prose |
| Ch.3 史料来源与可信度 | B | preserve evidence hierarchy, dispute handling, literary-vs-history distinction, chronology caution |
| Ch.4 184—280 历史范围 / 六阶段 | C | **not always-safe**; split into reusable past segments so early Entry never reads later phase answers |
| Ch.5 12 fixed Entries | C + D | preserve all 12 fixed authored Entries; existing T0 skeleton supplies current snapshots; each Entry references only already-past segments |
| Ch.5.13 自定义年份 | E | current first-gen custom-year picker is Deferred; do not expose as selectable v0.2 fixed Entry. Preserve omission reason here |
| Ch.6 地理与空间 | B | preserve full region/space/navigation meaning; rewrite later-regime labels into time-sensitive neutral descriptions where required |
| Ch.7 社会结构与身份 | B | preserve full social diversity and ordinary-person scale; later selection-system changes stated generically |
| Ch.8 制度与政治文化 | B + C | generic Han institutional grammar / office / legitimacy tension always-safe; concrete dynastic transitions belong past segments |
| Ch.9 经济与物质生活 | B | preserve agriculture, exchange, city/market, migration; no universal game-economy numbers |
| Ch.10 军事世界常识 | B | preserve organization/logistics/geography/ordinary military life; no battle mechanic ownership |
| Ch.11 技术/交通/通信 | B | preserve technology ceiling, travel/communication delay; replace famous future-event communication example with generic distant-event example |
| Ch.12 文化/信仰/超自然 | B | preserve values plurality, religions, no-objective-magic default, traveler/system separation |
| Ch.13 信息边界 | B | preserve World/NPC/Player knowledge split and traveler-knowledge fallibility; remove explicit future-history examples from always-safe Runtime prose |
| Ch.14 历史人物与人物卡 | B + D/Character | preserve World-vs-Character ownership; temporal identity/status references live in Entry snapshots / Character profiles |
| Ch.15 玩家身份 | B | preserve broad identity/social-source constraints and ordinary-life routes |
| Ch.16 开局方式 | B | preserve `T0 + identity + plausible place`; remove famous-event next-scene example; no automatic famous-person access |
| Ch.17 公开事实 / GM facts | B | preserve disclosure logic; rewrite “永远不能预写” examples generically rather than enumerating later canon |
| Ch.18 长期趋势/开放矛盾 | B | preserve central/local, legitimacy/control, talent flow, war/livelihood, regional diversity as **pressures not event targets** |
| Ch.19 语言与叙事风格 | B | preserve modern Chinese readability and era-tone sources; no fixed output format |
| Ch.20 Expansion 配合 | B | preserve optional compatibility prose as authored semantics; does not imply current Expansion runtime exists/enabled |
| Ch.20.3 人物能力时代形态 | B | preserve five-dimension-as-summary-not-truth and three skill meanings; Character T0 profile owns actual current competence |
| Ch.21 本局持久事实 | B | preserve Game-local durability/source immutability boundary; actual storage belongs Runtime architecture |
| Ch.22.1 已核查核心年份 | C | distribute concrete chronology into corresponding past segments; do not keep whole 184—280 chronology in always-safe Runtime |
| Ch.22.2 未完成核查 | B | preserve uncertainty / do-not-fake-precision rule |
| Ch.22.3 参考资料 | B | preserve source/evidence provenance |
| Ch.22.4 既定取舍 | B | preserve wide-window, source priority, no default supernatural, temporal geography, state-centered Entry design |
| Revision Notes / repo housekeeping | omit | legacy repository maintenance, not game semantics |

---

## 4. Always-safe target sections

Current full-fidelity package should carry approximately these rich sections:

```text
01_world_identity_and_ownership.md
02_causality_t0_and_actor_freedom.md
03_evidence_information_and_uncertainty.md
04_geography_and_space.md
05_society_institutions_and_identity.md
06_economy_material_and_military_life.md
07_technology_transport_culture_supernatural.md
08_player_entry_narrative_and_disclosure.md
09_long_term_tensions.md
10_expansion_compatibility_and_game_local_boundary.md
```

These are semantic retrieval units, not a rigid schema tree.

They may be long. Narrative richness is intentional.

---

## 5. Historical past-segment plan

Use the 12 fixed Entry order already restored:

```text
184
189
196
200
208
214
220
229
234
249
263
280
```

Historical content is decomposed into:

```text
history/through-184.md
history/184-to-189.md
history/189-to-196.md
history/196-to-200.md
history/200-to-208.md
history/208-to-214.md
history/214-to-220.md
history/220-to-229.md
history/229-to-234.md
history/234-to-249.md
history/249-to-263.md
history/263-to-280.md
```

An Entry may reference every segment whose end boundary is already part of its starting past.

Example:

```text
208 new Game
= always-safe sections
+ through-184
+ 184-to-189
+ 189-to-196
+ 196-to-200
+ 200-to-208
+ 208 current snapshot
```

An existing 184 Game **never** gains `184-to-189` or later Source segments merely because Game-local time advances.

---

## 6. Geography temporal repair rule

Original geography is highly reusable but contains later-regime shorthand such as:

- a region described through a later dynasty/state role;
- later capital names or political centers;
- a battlefield named because of a later famous battle.

Repair rule:

1. keep physical geography / transport / social-region meaning always-safe;
2. mark names and political meanings as time-sensitive;
3. put current control/capital/state-role in Entry or Game-local Reality;
4. do not use later famous event as the reason a place matters to an early T0.

This preserves spatial richness without canon leakage.

---

## 7. Information-boundary repair rule

Original Ch.13 correctly teaches knowledge separation but sometimes illustrates it by naming future historical outcomes.

v0.2-r2 keeps the principle and removes the future-answer example from ordinary Runtime.

Use generic form:

> A fact outside the selected T0 is not current world truth merely because the model or player knows an external chronology.

Traveler/time-traveler knowledge, if present, is owned by that Character/Expansion knowledge state and loses predictive value as Game-local history diverges.

---

## 8. Expansion prose preservation

Legacy World names several optional expansions.

Current decision:

- preserve those mentions as authored compatibility / ownership guidance where semantically useful;
- do not create hard manifest dependencies;
- do not pretend the Expansion runtime already exists before G4-08;
- if a named legacy expansion is later not adopted by current product, omission/replacement is decided when its real consumer arrives.

This follows `consumer before abstraction`.

---

## 9. Custom-year omission

Legacy `5.13 自定义年份` is useful design evidence, but current first-generation New Game route does not support an arbitrary-year authoring/calculation engine.

Therefore:

```text
12 fixed authored Entries = preserved and active
custom year selector       = intentionally not materialized in v0.2-r2 first-gen package
```

Reason:

- current product deferred arbitrary historical picker;
- a custom year cannot safely be implemented as “change one number”;
- it would require new temporal consumers and compatibility calculation not yet proven.

This is an explicit product-scope omission, not semantic shrinkage by accident.

---

## 10. Full-fidelity acceptance

Han World full-fidelity PASS requires all of:

1. every substantive legacy chapter accounted for by the table above;
2. all 12 fixed Entries retained;
3. geography / society / institution / economy / military / technology / culture / information / ordinary-player depth preserved;
4. historical phase chronology represented through T0-safe past segments, not one complete future timeline in early Runtime;
5. early projection contains no later-regime/event answer cues through explanatory examples;
6. selected later Entry can still inherit deep real past without repeating 12 copies of the whole World;
7. Source/Expansion/Game-local ownership stays intact;
8. manual original ↔ migrated sampling shows no substantive shrinkage;
9. omission ledger contains only explicit wrong-owner / deferred-product material.

Only after this content survives pressure should the package shape be treated as engineering-ready.