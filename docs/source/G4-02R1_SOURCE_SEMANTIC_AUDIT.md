---
title: my world｜G4-02R1 Source Semantic Audit
status: semantic-audit-complete
owner: GPT
created: 2026-08-29
historical_snapshot: zhangchenjia21-dot/sillytavern-assets@4a5364a042e41f4c8a69621fc4467956a78703c0
---

# G4-02R1｜World / Character Source Semantic Audit

## 1. 结论

G4-02 v0.1 的工程实现曾正确证明 filesystem validation、safe path、exact generation fingerprint 与 Source/Game live-state 边界；这些 engineering facts 保留。

但真实资产压力测试后的语义结论是：

- **Character Card v0.1：结构性不足，必须修正。** `summary + traits + background + drives` 会把真实人物的稳定 GM-useful semantics 压扁成摘要；required portrait 还会迫使纯文本资产伪造占位视觉。
- **World Pack v0.1：有原始承载容量，但合同语义不足，必须修正。** `source_lore` 可以装长文本，`source_material` 可以装任意 object；但前者没有 section-level disclosure/semantic ownership，后者是无真实 consumer 的 catch-all，既容易成为第二套隐藏 Schema，也容易像 G4-05 一样退化成 provenance-only 逃生口。
- **不能用“给 Character 再加几十个固定字段”修复。** 两个 World、六个 Character 已经证明内容内部形态差异很大；字段森林会让 Source 迁就 Schema，并增加 Context/Creator/Runtime 长期债务。
- 正确修正方向是：**薄 identity + 少量稳定产品字段 + ordered rich semantic sections + explicit GM disclosure + exact content files + Game-local evolvable semantics**。

因此：

> **G4-02R1 decision: contract correction required.**

v0.2 语义冻结见 `docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md`。

---

## 2. Reference Audit｜Pass 1：真实资产反向审计

### 2.1 汉末三国 World pressure

固定证据：

`世界包/汉末三国_天下未定_World_Pack_v0.2.3.md`

该资产不是一份“历史简介”。它同时包含：

- 世界定位、体验基调与尺度；
- T0：过去冻结 / 未来开放；
- 历史是参照而非剧本；
- 世界因果先于历史结果；
- autonomous historical actors；
- 来源/史料可信度分层；
- 184/189/196/200/208/214/220/229/234/249/263/280 等多组 Entry/T0；
- 地理、地区、地点与场景尺度；
- 政治制度、官职、合法性；
- 经济、物质生活与迁徙；
- 军事世界常识；
- 技术、交通、通信；
- 文化、宗教、超自然默认边界；
- World Truth / Character Knowledge / Player-visible Narrative 的信息边界；
- World / Character / Expansion / Game-local ownership 分工。

关键压力不是“文字很多”，而是这些章节拥有不同的 GM 使用语义。把它们压成 4 个 lore summary 会丢失可操作深度。

### 2.2 埃瑟维亚 World pressure

固定证据：

`世界包/埃瑟维亚_诸界余辉_World_Pack_v0.1.3.md`

除普通世界资料外，还出现当前 v0.1 最缺少的压力：

- 高魔社会尺度与技术革命；
- 多国制度、派系、城市与种族文明；
- 魔法 / 神术 / 神权的本体边界；
- 大断裂公开历史；
- **仅 GM 掌握的隐藏世界真相**；
- 公开学说与真实后台真相并存；
- 战略魔法与国际秩序；
- Expansion ownership 协作；
- 哪些局内变化必须 durable；
- 重大变化必须有因果过程，而不是一句话宣告成立。

这证明 World content 需要 section-level `gm_reference` / `gm_private` 区分，但这种区分仍然**不是 Player Knowledge state**。

### 2.3 六张 Character 的共同稳定语义

刘备、曹操、孙权、莉维娅、阿德里安、杜恩在完全不同世界与写法中，反复出现以下稳定 GM-useful categories：

1. identity / public positioning；
2. personality / values / contradictions / fears / blind spots；
3. capabilities + limitations；
4. decision / behavior logic；
5. relationship style + autonomy + player agency boundary；
6. language / expression guidance；
7. knowledge / information boundary；
8. T0 / history boundary + player takeover / deliberate blanks。

这八类是**真实语义重复出现**，不是为了 Schema 对称而发明。

但内部表达差异很大：

- 三国人物的能力主要是叙事性的政治、组织、军事语义；
- 莉维娅包含 attributes、skills、能力证据、法术表、研究经历、私密事故；
- 阿德里安包含血统身份、魔剑训练、战斗术式、旧败绩与既往关系；
- 杜恩包含非学院知识、经验规则、职业技能、迷信习惯与边境信息来源；
- 历史人物的 T0 随所选年份变化；幻想人物则有固定 1287 T0；
- relationship hooks 可以是既往历史事实，但 current favor/trust/location 不属于 Source。

因此：

> 这些 category 适合作为 section vocabulary / retrieval hint；不适合作为几十个刚性 nested fields。

### 2.4 六张 Character 的差异压力

| Asset | 对合同的独特压力 | 语义结论 |
|---|---|---|
| 刘备 | 多年份 T0；原历史未来不能倒灌；组织韧性与关系信用不能压成 trait 标签 | `t0_boundary` 必须能保留富文本规则，未来仍由局内事实决定 |
| 曹操 | 宽纵/严酷依赖现实威胁；信息不足会改变判断 | Personality 必须允许条件性与矛盾，而不是枚举标签 |
| 孙权 | 后期政治问题不能倒灌为青年固定人格 | Source 必须表达 life-stage/history boundary，而不是静态 caricature |
| 莉维娅 | skill/spell tables、private accident、knowledge source table | Rich section content 必须容纳表格；GM private 必须显式 |
| 阿德里安 | family identity、narrow expertise、Expansion coordination、past relationship hooks | 既往关系事实可 Source-owned；current relationship 不可 Source-owned |
| 杜恩 | experiential knowledge、非学院技能、个人仪式习惯、职业信息边界 | Schema 不能假设所有能力都来自统一技能系统或学院 ontology |

---

## 3. Semantic Ownership Mapping

### 3.1 Character

| Historical authored semantic | Owner | Preservation depth | v0.1 fit | v0.2 decision |
|---|---|---:|---|---|
| 身份锚点 / public positioning | Character Source | full | awkward | semantic section `identity` |
| 人格 / 价值 / 欲望 / 恐惧 / 矛盾 | Character Source | full | awkward | rich `personality` section |
| 稳定能力、专长、限制 | Character Source | full | poor | rich `capabilities` section；不提前机器化全部技能 |
| 决策 / 行为逻辑 | Character Source | full | poor | rich `behavior` section |
| 关系风格 / 自主性 | Character Source | full | poor | rich `relationships_autonomy` section |
| 开局前既往关系事实 / hooks | Character Source | full when stable | poor | section content；不是 current relation state |
| 语言 / 表现 | Character Source | full | poor | rich `expression` section |
| 知识来源 / 信息边界 | Character Source | full | poor | rich `knowledge` section；可 `gm_private` |
| T0 前既定人生 / future-open / player takeover | Character Source + Entry/T0 interpretation | full | poor | rich `t0_boundary` section |
| current location / health / inventory / favor / trust | Game-local / Runtime | none in Source | correctly forbidden | continue forbidden |
| opening appearance / current Context membership | Game-local / Runtime | none in Source | correctly forbidden | continue forbidden |
| gameplay mechanics for skill growth/combat/spells | Expansion/Runtime | reference only in Character | v0.1 unclear | Character may state authored competence; mechanics remain Expansion |
| portrait | optional presentation Source | exact if present | **wrongly mandatory** | optional |

### 3.2 World

| Historical authored semantic | Owner | Preservation depth | v0.1 fit | v0.2 decision |
|---|---|---:|---|---|
| 世界定位 / tone / scale | World Source | full | awkward | rich semantic section |
| World causal / future-open rules | World Source | full | natural-ish | compact instructions + rich section |
| 历史 / cosmology baseline | World Source | full | awkward | semantic sections |
| geography / institutions / society / material / culture | World Source | full | awkward | semantic sections |
| public theory vs GM hidden truth | World Source | full | **insufficient** | per-section disclosure |
| knowledge/evidence boundaries | World Source | full | awkward | semantic section |
| Entry/T0 seeds | World Source Entry | full enough to open | natural | retain `entries` |
| Expansion mechanics | Expansion | no mechanism in World | correctly separable | keep ownership boundary |
| local war result / death / treaty / knowledge diffusion | Game-local/Runtime | none in Source | correctly forbidden conceptually | continue forbidden |
| arbitrary structured `source_material` | no proven canonical owner | n/a | dangerous catch-all | remove from v0.2 |

---

## 4. Reference Audit｜Pass 2：历史教训与反事实审计

本轮不问“v0.2 能不能装下两个 fixture”，而问“如果用到 60+ Character、17+ Expansion、几十小时长局，会不会重现历史失败”。

| Failure mode / 反事实 | 如果设计错误会怎样 | v0.2 guardrail |
|---|---|---|
| Compact-summary self proof | Agent 把真实资产压成自己 Schema 最容易通过的摘要，再证明 parser PASS | fidelity 以 source-derived section/anchor 人工审查为准，package count/length 不够 |
| Giant schema forest | 每看一张新卡就增加字段，Creator/Context/Runtime 被 schema 拖死 | rich semantic sections；section type 是 broad vocabulary，不把内部表格全部字段化 |
| Universal asset protocol too early | World/Character/Expansion 为了“统一”被迫共享不真实字段 | 只共享最薄 identity/file-section primitive；三类 owner 仍分开 |
| Public == player-known leak | UI 或模型把角色公开资料自动当成玩家已知事实 | `catalog_summary` 只为资产选择；`gm_reference` 也不等于 Character/Player Knowledge |
| Source becomes future script | canon/history/default trend 强迫局内重演 | T0/future-open 作为 Source semantic rule；Game-local lived history 高于 Source future reference |
| Paper personality == agency | 写了 autonomy 但离屏 NPC 实际不行动 | Source 只提供 authored inertia；Runtime agency 仍须由后续真实 consumer/UAT 证明 |
| Total state dumped into prompt | 富资产越多，模型越被无关资料挤压 | semantic section 是 retrieval unit；Context 只选择 relevant working set |
| `source_material` catch-all | 任意 JSON 逐步变成第二隐藏 schema / legacy dumping ground | v0.2 移除 generic arbitrary object；新机器结构必须由真实 consumer 拉出 |
| Forced visual placeholder | 没画像的真实卡为了 validator 被迫伪造“历史图片” | Character portrait optional；应用占位图不是 Source bytes |
| Structured skills too early | 还没有真实 mechanic consumer 就冻结一套通用技能/法术 ontology | 先保留 authored table/text；G4-08+ 真实 Expansion consumer 再拉出 machine semantics |
| Local evolution blocked | Source schema 变成世界可能性的上限 | Game-local semantic objects explicitly evolvable |
| Local evolution bypasses durability | 模型自由增加字段但 Save/Restore/Timeline 不知道 | evolution 是 Game-local canonical mutation，必须 durable + timeline-reversible |
| Generic facet duplicates real domains | Location/Relationship/Injury 同时存在 dedicated state 与 generic facet 两份 truth | existing canonical domain wins；facet 只承载尚无正式 owner 的开放语义 |
| Binding proof without gameplay proof | Source 已装、Context 已绑定，但世界仍是空壳 | G4-06/07 仍必须真实 materialize + First Playable；contract PASS 不替代 product proof |
| Historic/fantasy overfitting | 只适配三国或只适配高魔技能表 | 两个明显不同 World + 六张不同 Character 共同压力后才冻结 |

---

## 5. 为什么不把技能/法术/关系全部机器化

莉维娅、阿德里安、杜恩的表格证明“这些 authored semantics 值得保留”，但没有证明 G4 当前已经存在一个需要逐项读取这些字段的 machine consumer。

若现在直接发明：

```text
attributes schema
skills schema
spell ownership schema
relationship hook graph
knowledge source graph
...
```

就会重复过去的 platform-before-product 错误。

v0.2 因此只要求：

- 这些信息不能丢；
- 它们必须拥有稳定 section identity/disclosure；
- exact generation 必须覆盖其字节；
- Context 以后可以按 section 检索；
- 当一个真实 mechanic/UI consumer 需要机器字段时，由那个 consumer 拉出最小正式 Domain contract。

> **Preserve semantics now; formalize mechanics when consumed.**

---

## 6. 为什么 rich semantic section 不会削弱模型

Source Total Content 可以很大，但不等于每 Turn 全量注入模型。

正式区分：

```text
Source Total Content
!= Game-local Total State
!= Runtime Relevant Set
!= Model-visible Working Set
```

`semantic_sections` 的一个关键目的就是提供天然 retrieval unit：当前场景只取相关人物、相关 section、相关局内 facts/facets，而不是让模型每回合“背完整资产 + 填完整表格”。

Section type/disclosure 是 Runtime/Context 的索引线索，不是 Narrative output schema。模型不需要每回合返回这些 section，也不需要照表填值。

---

## 7. Game-local evolvability pressure

真实资产已经明确：Source 只定义开局前 reference；游戏中新发生的战争、死亡、关系、知识、能力、研究、神性事实等属于本局。

Owner 进一步裁定：本局语义不能被 Source schema 封顶。

因此：

- Source exact generation immutable；
- Final Create 产生 Game-local canonical objects；
- Program-owned identity/provenance/lifecycle kernel 稳定；
- model/runtime 可以在 Game-local 层增加、更新、删除此前 Source 没预见的 semantic facets；
- 不修改原始 Source，不 ALTER physical SQLite schema；
- 若已有 canonical Domain owner（Location/Relationship/Knowledge/Injury/Inventory/Faction 等），必须写该 Domain，不建立重复 generic truth；
- 新 facet 只有在长期真实使用并出现 mechanic/UI consumer 后，才考虑晋升为正式 Domain；
- facet mutation 必须跟 Timeline 一起 Save/Restore，回到创建 facet 之前时该 facet 也必须消失。

Canonical architecture decision 由 governance repo 单独持有。

---

## 8. G4-02R1 Exit Decision

### Semantic verdict

**Current v0.1 is NOT semantically adequate.**

原因不是它不能储存长字符串，而是它没有给真实 authored semantics 一个自然、可审计、可按需检索、能区分 GM hidden truth、又不会逼出 giant schema 的正式表达方式。

### Corrective direction

**Adopt v0.2 semantic contract.**

核心变化：

1. `catalog_summary` 取代“public profile 作为资产 UI 的暗示”；
2. World / Character 都使用 ordered `semantic_sections`；
3. section content 使用 package-local `.md/.txt`，保留丰富可读资产而不是把 80KB prose 塞成 JSON 摘要；
4. `disclosure = gm_reference | gm_private`；
5. section type 使用 broad, asset-specific vocabulary，内部不是强制 machine schema；
6. Character portrait optional；
7. World 删除 generic required `source_material` catch-all；
8. exact generation 必须包含全部 section content bytes；
9. live Game state 继续禁止进入 Source；
10. Game-local semantic structure explicitly evolvable。

### What this audit does NOT claim

- 不声称 v0.2 已由 Godot loader 支持；那属于后续 Codex mechanism correction。
- 不声称 real assets 已完成 v0.2 package conversion；那由 GPT 在 semantic freeze 后完成。
- 不声称 rich Source 自动产生 NPC Agency / Living World；必须在 G4-06/G4-07 真实 materialization / First Playable 证明。

