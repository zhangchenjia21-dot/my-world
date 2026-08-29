---
title: my world｜G4-02R1 Real Asset v0.2 Migration Specification
status: gpt-owned-content-migration-spec
owner: GPT
created: 2026-08-29
historical_snapshot: zhangchenjia21-dot/sillytavern-assets@4a5364a042e41f4c8a69621fc4467956a78703c0
contract: docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md
---

# G4-02R1｜真实资产 v0.2 迁移规格

## 1. Migration rule

本迁移的默认动作不是 summarize，而是：

> **preserve → re-home → explicitly omit only when owner is wrong.**

对历史 DSH-native Markdown：

- 保留 substantive authored prose、表格、例子、边界与灰度；
- 允许删除 YAML/frontmatter 中旧仓库管理 metadata、Revision Notes、旧宿主路径引用等非游戏语义；
- 允许把一个超长旧章节按自然小节拆成多个 v0.2 section，但不得改变含义；
- 不为了 JSON 简洁重写成几个 bullet；
- 不为了“现代化 Schema”把历史/奇幻不同表达方式强行归一；
- 原文中的 Expansion ownership 提示可以保留为 `asset_coordination` 或所属正文，但不把 Expansion mechanics 复制进 World/Character；
- current live state 不迁移为 Source authoritative state；
- historical research appendices 若不在固定 snapshot 的选定 package scope 内，不假装已经迁移。

### Fidelity test

每个迁移包必须可以回答：

1. 原始每个 major GM-useful section 去了哪里？
2. 是否有 substantive paragraph/table 被无理由丢失？
3. 哪些内容明确因为 owner 属于 Expansion/Game-local/legacy-only 而没有迁移？
4. `gm_private` 是否保持私密，不被 catalog summary 泄漏？
5. 资产缺少视觉时是否诚实缺省，而不是伪造 Source portrait？

---

# 2. World｜汉末三国：天下未定

Source:

```text
path: 世界包/汉末三国_天下未定_World_Pack_v0.2.3.md
blob: 9d05fb2dadad8ea140d611e9f3bab49c0d8f2677
```

Target identity:

```text
asset_id: world.han_end.unsettled_realm
schema: world_pack.v0.2
author version: 0.2.3-converted.2
```

### Top-level

- `catalog_summary`：只使用世界一句话定位 + 玩家可浏览的体验概述，不泄漏 GM-only research arbitration。
- `world_instructions`：保留 T0 过去冻结 / 未来开放、history inertia without correction force、game reality > source future reference。
- `gm_instructions`：保留 causality-first、information-source-first、historical dispute handling、World/Character/Expansion/Game-local ownership。

### Semantic section mapping

| Legacy content | v0.2 section type | disclosure | Action |
|---|---|---|---|
| 这份材料是什么 / 不负责什么 | `asset_coordination` | gm_reference | preserve substantive owner boundaries; omit revision metadata |
| 一、世界定位 | `overview` | gm_reference | preserve |
| 二、世界如何运转 | `world_logic` | gm_reference | preserve in full |
| 三、历史素材来源与可信度 | `knowledge` | gm_reference | preserve in full |
| 历史阶段 / 时代脉络 | `history` | gm_reference | preserve |
| 184–280 各固定入口 | top-level `entries[]` + T0 guidance section | gm_reference | each fixed Entry preserved, not collapsed to four samples |
| 自定义年份规则 | `world_logic` / T0 guidance | gm_reference | preserve as guidance; first-gen UI need not expose arbitrary-year picker |
| 六、地理与空间 | `geography` | gm_reference | preserve |
| 社会身份/阶层/地方社会 | `society` | gm_reference | preserve |
| 官职/政权/合法性 | `institution` | gm_reference | preserve |
| 经济与物质生活 | `material_life` | gm_reference | preserve |
| 军事世界常识 | `society` or `world_logic` | gm_reference | preserve world reality; do not import battle mechanics |
| 技术/交通/通信 | `technology` | gm_reference | preserve |
| 文化/信仰/超自然 | `culture` | gm_reference | preserve |
| 信息边界 | `knowledge` | gm_reference | preserve |
| 历史人物与人物卡边界 | `asset_coordination` | gm_reference | preserve |
| 后续 GM-facing historical/material/cultural chapters | matching broad section type | gm_reference | preserve, no thematic summary |
| Revision Notes / repo housekeeping | omit legacy-only | n/a | omit with reason |

No World-hidden backend truth equivalent to Aetheria chapter 30 is required unless the original chapter itself marks such content private.

---

# 3. World｜埃瑟维亚：诸界余辉

Source:

```text
path: 世界包/埃瑟维亚_诸界余辉_World_Pack_v0.1.3.md
blob: 42924b5c8b18afc7622b8f3c04afc393a69f72e8
```

Target identity:

```text
asset_id: world.aetheria.afterglow
schema: world_pack.v0.2
author version: 0.1.3-converted.2
```

### Top-level

- `catalog_summary`：世界、高魔文明、标准化革命、诸神/大断裂的玩家可浏览描述；不能泄漏升格网络的后台真相。
- `world_instructions`：1287 T0、future open、world causality, source != lived history。
- `gm_instructions`：high-magic but causal、gods not author omniscience、World Truth != Character Knowledge、Expansion mechanics optional。

### Semantic section mapping

| Legacy content | v0.2 section type | disclosure | Action |
|---|---|---|---|
| 这份材料是什么 / 不负责什么 | `asset_coordination` | gm_reference | preserve ownership boundaries |
| 世界定位 / 体验基调 | `overview` | gm_reference | preserve |
| 世界如何运转 / future-open | `world_logic` | gm_reference | preserve |
| 魔法层级的社会理解 | `metaphysics` | gm_reference | preserve as social scale, not numeric rules |
| 术式标准化革命 | `society` | gm_reference | preserve |
| 日常魔法生活 | `material_life` | gm_reference | preserve |
| 维尔萨恩地理 | `geography` | gm_reference | preserve |
| 五大强权及各国制度/派系 | `institution` | gm_reference | preserve all substantive country chapters |
| 奥维斯塔 | `geography` / `institution` | gm_reference | preserve |
| 智慧文明 | `society` | gm_reference | preserve non-stereotype boundaries |
| 五神 / 神性 / 教会 | `metaphysics` | gm_reference | preserve |
| 古代文明 / 现代关系 | `history` | gm_reference | preserve |
| 大断裂公开历史 | `history` | gm_reference | preserve |
| **大断裂后台真相 / 升格网络** | `world_secret` | **gm_private** | preserve in full; never summarize into picker copy |
| 传奇施法者 / 战略魔法 / 国际秩序 | `world_logic` / `institution` | gm_reference | preserve world facts; mechanics remain Expansion |
| world-internal language / information boundaries | `knowledge` | gm_reference | preserve |
| 与拓展包配合 | `asset_coordination` | gm_reference | preserve ownership, not mechanics duplication |
| 本局持久事实 / 因果过程要求 | `gm_guidance` | gm_reference | preserve; semantics informs later Runtime but Source does not store current facts |
| 既定取舍 | `gm_guidance` | gm_reference | preserve |
| Revision Notes / old repo metadata | omit legacy-only | n/a | omit with reason |

---

# 4. Character mapping template｜适用于六张真实卡

每张 Character 的 major sections 默认一一迁移，而不是把八章揉成两个 profile object：

| Legacy major section | v0.2 type | Default disclosure | Preservation |
|---|---|---|---|
| 1. 身份锚点 | `identity` | gm_reference | full |
| 2. 人格核心 | `personality` | gm_reference unless explicitly secret | full |
| 3. 能力与局限 | `capabilities` | gm_reference | full tables/text; mechanics not invented |
| 4. 决策与行为逻辑 | `behavior` | gm_reference | full |
| 5. 关系风格与自主性 | `relationships_autonomy` | gm_reference | full; stable past hooks preserved, current relation excluded |
| 6. 语言与表现 | `expression` | gm_reference | full |
| 7. 知识与信息边界 | `knowledge` | split if needed | public/reference material gm_reference; explicitly private inner facts gm_private |
| 8. 开局状态与历史边界 | `t0_boundary` | gm_reference, private subfacts may split | full T0/future-open/player takeover/deliberate blanks |
| Revision Notes | omit legacy-only | n/a | omit |

若一章内部明确混合“普通 GM reference”和“仅 GM 私密真相”，应拆成两个 content section；不得因为原 Markdown 在同一章就失去 disclosure boundary。

---

# 5. Character｜刘备

Source:

```text
人物卡/汉末三国/CC-BATCH-01/刘备__Character_Card__v0.1.2.md
blob: 20c1ff5d01797bdd619644dba37f5eb7dbc2fa8d
```

Preserve anchors：

- relationship credit / autonomy under dependence / emotional restraint / legitimacy+resources / resilience；
- three core contradictions；
- strengths and limitations；
- decision questions and fail/recover behavior；
- off-screen autonomy / player not auto-trusted / no automatic romance；
- restrained expression; no Romance-of-Three-Kingdoms caricature；
- knowledge only from plausible identity/experience; no future history knowledge；
- selected-year T0 boundary；
- player takeover: post-T0 choices fully player-owned。

Do not migrate as current Source state：current location, current office, current followers, current relation, current health; these depend on selected T0/Game reality.

Portrait：historical snapshot has no Source-authored portrait => **no portrait**. Application placeholder is external UI behavior.

---

# 6. Character｜曹操

Source：fixed v0.1.2 historical card in same batch.

Preserve anchors：

- effectiveness over pedigree；controllable order；high self-efficacy/risk tolerance；conditional tolerance/harshness；not reduced to “奸雄”；
- talent-vs-control, nominal order-vs-real power, pragmatic tolerance-vs-security severity contradictions；
- capabilities and limitations；
- decision questions, cooperation/refusal, response to failure and evidence that changes judgment；
- autonomous off-screen governance/organization；
- expression not fixed “霸气/奸雄腔”；
- intelligence uncertainty / no future knowledge；
- selected-year T0 and player takeover。

Do not back-propagate later historical outcomes into early-year personality/state.

Portrait：none unless historical snapshot provides authored visual bytes.

---

# 7. Character｜孙权

Source：fixed v0.1.2 historical card.

Preserve anchors：

- broad listening + own final decision；complementary talent use；Jiangdong autonomy；policy evolution；personal courage；
- youth/late-life distinction：later political problems cannot become fixed youth personality；
- capabilities/limits；
- decision logic and delegation/intervention conditions；
- relationship autonomy, off-screen governance；
- speech/dialogue style；
- information sources and no future knowledge；
- selected-year T0 and full post-takeover player agency。

Portrait：none unless Source-authored bytes exist.

---

# 8. Character｜莉维娅·塞兰

Source:

```text
人物卡/诸界余辉/CC-01_莉维娅·塞兰_Character_Card_v0.2.md
blob: 78a190e70c6ce7a1ca8f0327734b3eda677632b1
```

Preserve in full：

- value ordering, wants/needs, fear/emotional debt, judgment style, contradictions, bias/blind spots, risk/pressure response, change conditions；
- attributes/skills/evidence tables；
- key experience/specialties/style/creed；
- full authored spell familiarity list and “not a whitelist” boundary；
- limitations and optional Expansion coordination；
- goals/red lines/cooperation/refusal/escalation；
- past relationship hooks + autonomy + player agency boundary；
- expression examples as style calibration, not fixed dialogue；
- public knowledge layer；
- **private accident/inner ambition/private interpretations** split to `gm_private` knowledge/personality section；
- knowledge source/boundary table；
- fixed 1287 past, future open, possible opening entrances, player takeover, deliberate blanks。

No current magic burden is Source live state if it is meant to change in play; “normally stable at opening absent override” is opening guidance, not permanent Source state.

---

# 9. Character｜阿德里安·维尔克

Source:

```text
人物卡/诸界余辉/CC-02_阿德里安·维尔克_Character_Card_v0.3.md
blob: 5ac0daf75ec770555c32c0ca6a48eab31a858489
```

Preserve in full：

- family/name tension, honor/self-mastery, pity sensitivity, blind spots and risk response；
- attributes/skills, sword+magic expertise, explicit narrow-domain limitations；
- full authored spell list and non-whitelist boundary；
- long-term training-method goal / red lines / escalation；
- pre-T0 hooks with 塞芙琳 and 杜恩；
- autonomy + player agency boundary；
- formal/controlled expression；
- public/private knowledge split, including family wound and defeat details；
- 1287 T0 past, future open, entrances, takeover, deliberate blanks。

Do not convert old relationship hooks into current favor/trust.

---

# 10. Character｜杜恩·石痕

Source:

```text
人物卡/诸界余辉/CC-03_杜恩·石痕_Character_Card_v0.3.md
blob: 57407d5e1714a42e11dee418da9ff54ba553b0c9
```

Preserve in full：

- value order, freedom/debt contradiction, experiential judgment, institutional distrust, pressure response；
- attributes/skills, tracking/ranged skills, spell list, non-academic limitations；
- stable old injury-debt as past authored fact, not current relationship score；
- behavior/red lines/cooperation/refusal/escalation；
- pre-T0 hooks with 罗塔/阿德里安；
- off-screen contract/route activity and overprotective tendency；
- colloquial/black-humor expression；
- private ritual habits/debt/institution fear as `gm_private`；
- knowledge source/boundary table；
- fixed 1287 T0, future open, entrances, takeover, deliberate blanks。

---

# 11. Omission audit｜what deliberately does NOT migrate as Source

| Content class | Decision | Reason |
|---|---|---|
| YAML repo workflow metadata, batch/revision housekeeping | omit or convert only needed product identity | repository management, not game meaning |
| old Runtime machine protocol removed by DSH-native versions | omit | legacy host/runtime debt already intentionally removed |
| current location/health/inventory | omit as Source authoritative state | Game-local/Runtime owner |
| current favor/trust/relationship state | omit | Relationship Domain owner |
| current knowledge / player-known state | omit | Knowledge Domain owner |
| guaranteed opening placement | omit | Entry/Runtime consequence, not Character Source |
| Expansion mechanic formulas/state | omit | Expansion/Runtime owner |
| historical/fantasy future outcomes | preserve only as reference/boundary, never fixed future | Source provides inertia, actors create history |
| fake generated/historical portrait placeholder | omit | absence is honest; UI may supply non-Source placeholder |
| arbitrary `source_material` provenance dump | omit | provenance belongs migration evidence/docs, not authored World semantics |

---

# 12. Migration acceptance

A converted package is acceptable only when:

- its manifest uses v0.2 semantics；
- every major original GM-useful section is mapped；
- substantive tables/examples/constraints survive；
- explicit private truth remains private at Source disclosure level；
- there is no summary-only replacement；
- no live Game state becomes Source；
- missing visual stays missing；
- exact generation will include all semantic section bytes；
- a human reviewer can sample original ↔ converted and recognize the same usable World/Character, not a short derivative description。

This specification is content authority for the forthcoming GPT-owned real package migration and the later Codex mechanism correction.
