---
title: G4-02R1｜埃瑟维亚：诸界余辉 World Full-Fidelity Mapping
status: gpt-owned-migration-map
owner: GPT
created: 2026-08-29
source: zhangchenjia21-dot/sillytavern-assets@4a5364a042e41f4c8a69621fc4467956a78703c0
source_path: 世界包/埃瑟维亚_诸界余辉_World_Pack_v0.1.3.md
source_blob: 42924b5c8b18afc7622b8f3c04afc393a69f72e8
asset_id: world.ashtervia.afterglow
contract: v0.2-r2
---

# G4-02R1｜埃瑟维亚：诸界余辉 World Full-Fidelity Mapping

## 1. Purpose

本文件不是 World 摘要，而是迁移 ownership / disclosure / preservation map。

目标：把约 84KB 的固定 1287 authored World 保留为 rich Source，同时证明：

- 不再压缩成 G4-05 的四条 lore；
- 不因为内容复杂就发明 universal World schema；
- `gm_reference` 与 `gm_private` 有真实区别；
- World Truth / Character Knowledge / Player Knowledge 继续分离；
- 1287 之后的趋势不成为未来剧本；
- 技能、法术、神术、战斗、关系等 mechanics 仍由各自 Expansion / Domain owner 负责；
- existing stable identity 与三个 1287 Entry ID 保持不变。

迁移默认：

> **preserve → re-home → disclose correctly → explicitly omit only wrong-owner / legacy-only material.**

---

## 2. Fixed-T0 shape decision

本 World 第一代 authored T0 固定为断界历 1287。三个 Entry 只是同一时点下不同空间/问题入口：

```text
t0-1287-ovista
t0-1287-border-route
t0-1287-public-works
```

因此本族不照搬汉末的历史 segment ladder。

目标 shape：

```text
world.ashtervia.afterglow
├─ top-level rich semantic_sections
│  ├─ 1287 world/reference facts
│  ├─ knowledge/disclosure rules
│  └─ gm_private backstage truths
└─ entries
   ├─ ovista current/opening snapshot
   ├─ border-route current/opening snapshot
   └─ public-works current/opening snapshot
```

三个 Entry 共享同一 1287 世界事实。Entry-scoped内容只负责入口附近的当前空间、参与者类型、可见压力与 opening seed，不复制整本 World。

若未来产品增加其它年份，必须重新做 temporal ownership；不能假定当前全部 top-level sections 永远跨年份安全。

---

## 3. Disclosure rule

### `gm_reference`

GM 可作为普通 authored world reference 使用。

它**不等于**：

- 玩家角色知道；
- 所有 NPC 知道；
- 可以直接向玩家展示；
- 当前场景一定 relevant。

例如：一个国家制度、公开历史、神学学说、专业上可查证的灵魂理论，都可属于 `gm_reference`，但角色是否知道取决于身份、教育、位置、文献和经历。

### `gm_private`

明确设计成后台真相 / 秘密 reference。角色必须通过本局合理途径获得。

典型：

- 大断裂升格网络完整真相；
- 四神与第五神在升格工程中的隐藏参与边界；
- 第五神当前分裂状态的完整解释；
- 至少部分灵造民已被灵魂体系确认拥有完整灵魂这一仍未公开解决的 world truth；
- 某些现代研究已经再次接近古代升格关键问题的秘密进展。

`gm_private` 仍是 World Truth，不是 Game-local Player Knowledge。发现秘密时，应由 Game-local Knowledge / history 记录“谁通过什么途径知道了什么”。

---

# 4. Legacy → v0.2-r2 mapping

## A. World purpose / ownership / 1287 authority

Legacy:

- “这份材料是什么 / 不负责什么”；
- Ch.1 世界定位；
- Ch.2 canon / future-open / causality / world-growth principles；
- World / Character / Expansion / Game-local ownership boundaries。

Target:

`sections/01_world_identity_ownership_and_1287_authority.md`

Type: `overview`
Disclosure: `gm_reference`
Preservation: **rich**

Must preserve:

- mature high-magic civilization premise;
- fixed now = 断界历 1287;
- ordinary-person scale remains complete;
- no mandatory hero / demon king / main quest;
- source is reference, not script;
- Game-local reality outranks default future trajectory after T0;
- optional Expansion boundaries;
- Character full persona belongs to Character Card;
- current location/relationship/plan/new spell/divine connection belongs to Game-local reality.

Do not preserve repo frontmatter tags as Runtime prose.

---

## B. Magic ontology / capability scale

Legacy:

- world magic ontology and magical civilization principles;
- everyday magic vs trained caster distinction;
- spell-scale / legendary / divine-authority boundary (incl. Ch.4);
- magic != god-given monopoly;
- high magic still has causality, expertise and limits.

Target:

`sections/02_magic_ontology_and_power_scale.md`

Type: `metaphysics`
Disclosure: `gm_reference`
Preservation: **rich**

Must preserve qualitative scale and examples, but do **not** turn them into a universal combat/spell mechanic schema.

The World owns facts such as “legendary city-scale magic exists” and “divine authority is not simply one more spell tier”. Actual learning/casting/adjudication remains Expansion/Runtime mechanic ownership.

---

## C. Standardization revolution

Legacy: Ch.5.

Target:

`sections/03_standardization_revolution.md`

Type: `world_logic`
Disclosure: `gm_reference`
Preservation: **rich**

Keep:

- standard runes/material grades/interfaces/certification/curricula/repair specs;
- effects on old mage families, guilds, commerce, public regulation and patents;
- explicit boundary that 1287 is **not yet** a fully industrialized magic economy;
- “late pre-industrial + magic industrial revolution eve” texture.

This is a current structural pressure, not a guaranteed future industrial outcome.

---

## D. Daily material life / communication / transport / medicine / education

Legacy: Ch.6 + relevant Ch.34 social/economic material.

Target:

`sections/04_material_life_economy_education.md`

Type: `material_life`
Disclosure: `gm_reference`
Preservation: **rich**

Keep:

- household magic examples;
- non-global/non-free instantaneous communication boundary;
- ordinary letters/travel/public nodes still matter;
- travel and transmission costs;
- medicine combines mundane, alchemy, magic and divine healing, with access limits;
- education vs formal caster training distinction;
- stable currency/credit and magic-crystal-as-material, not universal coin;
- class/access/occupation consequences.

This section is critical positive richness control: high magic must still produce a believable ordinary society.

---

## E. Geography / continent / open world scale

Legacy: Ch.7.

Target:

`sections/05_geography_and_world_scale.md`

Type: `geography`
Disclosure: `gm_reference`
Preservation: **rich**

Keep:

- Vilsarn/维尔萨恩 as detailed core continent;
- overseas continents/islands/poles/planes exist but are intentionally coarse until play reaches them;
- major regions: 圣约西原、晶塔湖区、王冠山脉与瓦尔河谷、弥拉泽海湾、卡尔德隆北境、中央断界带;
- “outside five powers != empty map edge”.

Do not create fake global completeness.

---

## F. Five powers / institutions / internal tensions

Legacy: Ch.8–13.

Target:

`sections/06_five_powers_and_institutions.md`

Type: `institution`
Disclosure: `gm_reference`
Preservation: **very rich**

Keep all five political systems, advantages, real internal factions/tensions and cross-country differences:

- 阿尔瑟恩圣约国;
- 塞勒汀学院联邦;
- 瓦尔瑟兰王国;
- 弥拉泽自由共和国;
- 卡尔德隆统合国.

No country becomes a single-color alignment. Political/public-power mechanics, office assignment and live faction state remain Game-local / optional Domain concerns after T0.

---

## G. Ovista international city

Legacy: Ch.14.

Target:

`sections/07_ovista_international_city.md`

Type: `geography`
Disclosure: `gm_reference`
Preservation: **rich**

Keep:

- why five powers recognize autonomy;
- upper-city governance/diplomacy;
- joint academic district;
- five-temple district;
- magic-tool market;
- lower ruins;
- constructed-person autonomous quarter;
- why it supports many entry identities without becoming the world's protagonist.

Entry `t0-1287-ovista` gets a local current/opening snapshot that references this texture without copying the whole section.

---

## H. Intelligent civilizations / species

Legacy: Ch.15.

Target split:

1. `sections/08_intelligent_civilizations.md` — `gm_reference`
2. `sections/private/01_constructed_soul_truth.md` — `gm_private`

Preserve in reference:

- humans are diverse, not “default average species”;
- Selin long life and social consequences without moral superiority;
- Hemra material/ley affinity and occupational diversity;
- planar-descended peoples as multiple stable local civilizations, not monsters;
- constructed people as a legal/ethical civilization category with ongoing rights disputes.

Private truth:

> at least some constructed people demonstrably possess complete souls recognizable by soul magic/death-order systems.

Public/social dispute must remain separate from hidden answer.

---

## I. Gods / divine authority / church distinction

Legacy: Ch.16–22.

Target:

`sections/09_gods_divine_authority_and_churches.md`

Type: `metaphysics`
Disclosure: `gm_reference`
Preservation: **very rich**

Keep:

- divine authority != merely large energy;
- magic exists independently of gods;
- magic/divine magic share deep substrate but different access route;
- divine connection is reciprocal anchoring relationship;
- church != god;
- each major god's authority, personality direction, social/religious relationship, typical divine expression, and encounter weight;
- gods are not omniscient;
- divine connection authorization is bounded, not “god approves every cast”.

Mechanics for connecting, authorizing, breaking covenant remain Expansion ownership.

### Fifth-god split

Public/reference layer may include:

- modern contradictory records;
- absence of a unified church;
- fragments/echoes/unstable cultic contact are believed/observed;
- contact claims are hard to authenticate.

Full explanation that Viator's divinity/personhood was literally torn apart and coupled to planar boundaries belongs to:

`sections/private/02_viator_full_state.md`

Disclosure: `gm_private`.

---

## J. Soul / death / resurrection

Legacy: Ch.23.

Target:

`sections/10_soul_death_and_resurrection.md`

Type: `metaphysics`
Disclosure: `gm_reference`
Preservation: **rich**

Keep:

- soul objective existence;
- three death stages;
- once fully in the Final Court/终庭, ordinary mortal magic cannot simply force resurrection;
- deep resurrection requires touching death authority / Morrgan response / returned-person consent plus material conditions;
- no universal resurrection price list;
- practical resource inequality without implying ordinary life has lower moral value.

Do not turn this into a resurrection mechanic table.

---

## K. Undead / black magic / legal-danger taxonomy

Legacy: Ch.24–25 + relevant Ch.33.

Target:

`sections/11_undead_black_magic_and_law.md`

Type: `institution`
Disclosure: `gm_reference`
Preservation: **rich**

Keep:

- different undead ontologies;
- corpse use != automatic soul slavery;
- “black magic” is a social/legal category, not cosmic color coding;
- ontological / ethical / public-safety / political-legal danger dimensions;
- high-risk magic law differences across five powers;
- mind alteration remains real intervention, not retroactive proof of hidden love/loyalty;
- teleport/prophecy regulation distinctions.

Actual criminal cases and current law-enforcement state are Game-local.

---

## L. Planes

Legacy: Ch.26.

Target:

`sections/12_planes_and_boundaries.md`

Type: `metaphysics`
Disclosure: `gm_reference`
Preservation: **rich**

Keep known planes, uncertain academic interpretations, boundary/ruin facts, unknown-plane openness, and explicit rejection of casual infinite-parallel-Aetheria multiverse.

Travel adjudication remains mechanic/GM action ownership.

---

## M. Prophecy / open causality

Legacy: Ch.27.

Target:

`sections/13_prophecy_and_open_future.md`

Type: `world_logic`
Disclosure: `gm_reference`
Preservation: **rich**

Keep:

- prophecy can be real;
- future is probability/condition/convergence, not fixed object;
- observation changes causality;
- high-convergence future can still change at sufficient causal cost;
- GM must label epistemic status.

This section supports model freedom; it must never be converted into a future event schedule.

---

## N. Old Radiance civilization / Great Fracture public history

Legacy: Ch.28–29.

Target:

`sections/14_old_radiance_and_public_fracture_history.md`

Type: `history`
Disclosure: `gm_reference`
Preservation: **rich**

Keep:

- ancient civilization was plural, not one magic empire;
- ancient strengths and modern strengths differ;
- Great Fracture public consequences;
- competing public explanations;
- churches and academics do not possess a single public answer.

Do not leak Ch.30 truth into title/catalog/opening summary.

---

## O. Great Fracture / Ascension Network full truth

Legacy: Ch.30.

Target:

`sections/private/03_ascension_network_truth.md`

Type: `world_secret`
Disclosure: `gm_private`
Preservation: **near-verbatim semantic depth**

Must preserve:

- actual network objectives;
- incentives for gods and mortals;
- project was not doomed by definition;
- unresolved individual-soul-boundary problem;
- memory/personhood merging evidence and faction split;
- Viator as both early supporter and eventual cutter;
- why forced shutdown caused disaster;
- no single villain;
- nuanced participation of all five gods;
- modern possibility that the project could theoretically resume if soul-boundary problem were solved;
- modern institutional interests around the secret.

This is the main disclosure pressure test.

Do not summarize it into “ancient experiment failed”.

---

## P. Legendary casters / strategic magic / international order

Legacy: Ch.31–32.

Target:

`sections/15_legendary_magic_and_international_order.md`

Type: `world_logic`
Disclosure: `gm_reference`
Preservation: **rich**

Keep:

- master / archmage / strategic-caster / near-divine mortal distinctions as social/semantic scale, not mechanic levels;
- title != objective capability;
- legendary destruction is genuinely catastrophic;
- preparation/detection/defense/retaliation/political cost explain why it does not trivialize states and war;
- Ovista anti-destruction treaty and its political rather than cosmic nature;
- ordinary military logistics and administration still matter.

---

## Q. Economy / education / society / knowledge provenance

Legacy: Ch.34–35.

Target:

`sections/16_society_and_knowledge_provenance.md`

Type: `knowledge`
Disclosure: `gm_reference`
Preservation: **rich**

Keep social access/class/education/professional knowledge distinctions and especially:

```text
World/GM truth
!= public knowledge
!= institutional knowledge
!= specialist knowledge
!= Character knowledge
```

Keep:

- gods not omniscient;
- a god knowing something != clergy automatically knowing it;
- professional background shapes what a Character can plausibly know;
- distant current events require transmission;
- source of knowledge must be explainable.

This section does not itself write current Game-local NPC knowledge records.

---

## R. Current trends / open tensions

Legacy: Ch.36.

Target split:

1. `sections/17_current_trends_and_open_tensions.md` — `gm_reference`
2. `sections/private/04_current_hidden_research_pressure.md` — `gm_private`

Reference keeps current 1287 “gravity directions”:

- standard competition;
- Holy Covenant reform debate;
- constructed-person rights;
- planar exploration revival;
- strategic-magic arms race;
- increased fifth-god echoes;
- long-term structural conflicts.

Private keeps current non-public information such as multiple institutions discovering that parts of the ancient ascension system remain technically active / unusually close to reactivation-level research, where the legacy text marks this as not ordinary public knowledge.

No trend becomes guaranteed post-1287 event.

---

## S. Player identity space / opening / agency

Legacy: Ch.37–38.

Target:

`sections/18_player_identity_and_agency.md`

Type: `gm_guidance`
Disclosure: `gm_reference`
Preservation: **rich**

Keep:

- ordinary → high-status → legendary identity range;
- high power requires matching past, responsibilities, relationships and knowledge;
- player is not automatic center;
- social access follows identity/cause;
- god oracle cannot decide player action;
- prophecy cannot decide player goal;
- mental magic cannot retroactively rewrite player-authored past.

Current first-gen Character chooser still selects reusable Character Source; this World guidance does not force a blank/custom-character product path into G4-05.

---

## T. Character ownership / gods as world-level subjects / narrative style

Legacy: Ch.39–40.

Target:

`sections/19_character_ownership_and_narrative_style.md`

Type: `gm_guidance`
Disclosure: `gm_reference`
Preservation: **rich**

Keep:

- one important person → one Character Card;
- World stores only minimal public/world-role references;
- no-card people still have independent interests/information/emotion;
- five major gods are World-owned divine subjects, not ordinary NPC cards;
- modern Chinese narration;
- world feel comes from institution/material/religious/legal vocabulary rather than faux-archaic prose;
- in-world people do not speak UI/game-stat jargon by default.

---

## U. Expansion coordination

Legacy: Ch.41 + opening ownership list.

Target:

`sections/20_expansion_coordination.md`

Type: `asset_coordination`
Disclosure: `gm_reference`
Preservation: **rich but ownership-focused**

Keep:

- all listed expansions optional;
- absent expansion => narrate with world common sense, do not fake a mechanic;
- World owns metaphysical/social premises;
- Expansion owns actual mechanics;
- no duplicate five-god canon between World and divine Expansion;
- no automatic enabling.

Do not preserve repository-specific wiki link syntax if it has no product/runtime meaning.

---

# 5. Entry mapping

Existing stable Entries remain:

## `t0-1287-ovista`

Target: `entries/ovista/snapshot.md`

Scope:

- 1287 Ovista current spatial/social condition;
- international city / joint academy / diplomacy / market / ruins context;
- opening pressure around a basic-spell accident sample, standards and public risk;
- multiple plausible identity entry routes;
- no preselected relationship or guaranteed named-character appearance.

## `t0-1287-border-route`

Target: `entries/border-route/snapshot.md`

Scope:

- border transport / caravan / local knowledge / state jurisdictions;
- abnormal magical traces and competing risk interpretations;
- institutional vs independent professional knowledge tension;
- no prewritten culprit or future resolution.

## `t0-1287-public-works`

Target: `entries/public-works/snapshot.md`

Scope:

- community ↔ ruin-edge infrastructure project;
- research/material/escort/political coordination;
- restricted-zone knowledge remains bounded;
- no disclosure of Great Fracture private truth merely because the project touches ruins.

Entry snapshots are rich current opening contexts, not quest scripts.

---

# 6. Explicit omissions / non-owners

May omit from production candidate:

- YAML repository housekeeping tags/status dates;
- Revision Notes / changelog text;
- wiki-link syntax whose only function was old repository navigation;
- instructions that belong only to a legacy host UI/protocol if any.

Must **not** omit merely because content is large:

- country subfactions;
- everyday magic/material examples;
- social access distinctions;
- full god personality/authority differences;
- soul/death/undead ethical nuance;
- strategic magic political constraints;
- prophecy uncertainty model;
- full Great Fracture secret;
- knowledge provenance rules;
- expansion ownership boundaries.

---

# 7. Structural adequacy finding

Current v0.2-r2 Source shape remains adequate under this World pressure.

The asset requires:

```text
ordered rich Markdown sections
+ disclosure
+ three fixed 1287 Entry snapshots
```

It does **not** currently require:

- universal nation schema;
- universal god schema;
- universal magic/spell schema;
- universal law schema;
- future-event graph;
- world-state relational database at Source level.

This is the desired result:

> **The schema preserves authored meaning and retrieval/disclosure boundaries; prose preserves the world's actual complexity.**

The remaining proof is content migration itself. If preserving the full source forces a new structural need that this map missed, stop and revise before giving Codex implementation work.
