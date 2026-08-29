---
title: World Pack 与 Character Card Source 合同 v0.2｜Semantic Freeze
status: semantic-contract-frozen-implementation-pending
owner: GPT
created: 2026-08-29
updated: 2026-08-29
freeze_revision: 1
supersedes_semantics: v0.1
implementation_status: pending-codex-correction
---

# World Pack 与 Character Card Source 合同 v0.2｜Semantic Freeze

> 本文件冻结 **Source semantic contract**。当前 Godot loader/validator 仍是 v0.1；在 Codex 完成后续窄工程修正前，不得把本文件误称为 implementation PASS。

## 0. 核心目的

v0.2 不是要把丰富资产“数据库化”，而是给真实 authored content 一个不会丢语义、不会污染 Game-local truth、以后又能按需进入 Context 的稳定包装。

原则：

> **Preserve meaning; do not force prose into a schema forest.**
>
> **Source is a starting reference, not the ceiling of the living world.**
>
> **Rich storage != full prompt injection.**

---

# 1. Shared Source identity

World Pack 与 Character Card 继续共享最薄 identity：

```json
{
  "schema_version": "world_pack.v0.2 | character_card.v0.2",
  "asset_id": "stable.ascii.identity",
  "asset_type": "world_pack | character_card",
  "version": "author-version",
  "display_name": "author-facing/product-facing name",
  "catalog_summary": "short asset-library/new-game description"
}
```

规则：

- `asset_id` 是 stable logical identity；
- `version` 是作者版本；
- `generation_fingerprint` 不由作者填写；
- exact generation 由 canonical manifest + 所有正式声明的 content/reference bytes 派生；
- same identity/version 内容不同 => generation 必须不同；
- `catalog_summary` 只服务 Source Library / New Game 浏览，不建立任何 in-game Player Knowledge；
- 资产选择 UI 能看见某段文字，不等于玩家角色知道这段文字；
- `catalog_summary` 的“short”是作者/UI 语义指导，不用人工极短 max length 逼迫内容；UI 可在 projection 层截断显示，不改 Source。

---

# 2. Rich Semantic Section primitive

World 与 Character 都使用 ordered `semantic_sections` 作为 authored prose 的正式承载单元。

每项：

```json
{
  "section_id": "stable-within-generation",
  "section_type": "broad.semantic.hint",
  "title": "human readable title",
  "disclosure": "gm_reference | gm_private",
  "content_path": "sections/example.md"
}
```

## 2.1 `section_id`

- package 内唯一；
- 用于 exact lookup / retrieval / diagnostics；
- 不要求跨不同 Source version 永久不变，但同一 authored semantic section 若只是内容修订，建议保持稳定。

## 2.2 `section_type`

它是**广义语义索引提示**，不是 closed machine ontology。

- 必须为非空、安全 token；
- v0.2 提供推荐 vocabulary，但 validator 不因为出现合理的新 type 就拒绝整个资产；
- 不允许把 `section_type` 当作“模型必须填的字段集合”；
- 当真实 mechanic/UI consumer 需要精确结构时，由该 consumer 另行拉出 Domain contract。

这避免：

```text
新角色出现新内容
→ 修改全局 Character schema
→ 所有旧资产升级
```

## 2.3 `disclosure`

只有两个 v0.2 值：

```text
gm_reference
gm_private
```

含义：

- `gm_reference`：GM 可以把它作为普通 authored reference 使用；**不等于玩家知道，不等于任何 NPC 知道，不等于允许直接展示给玩家**；
- `gm_private`：明确属于 GM-only authored truth / secret reference；玩家或角色必须通过本局合理途径才能获得对应 knowledge。

这里描述的是 Source authoring disclosure，不是 Game-local Knowledge state。

## 2.4 `content_path`

- package-local relative path；
- v0.2 semantic content 只接受 UTF-8 `.md` / `.txt`；
- 禁止 absolute path / drive / URI / `.` / `..` / symlink escape；
- file 必须存在；
- bytes 必须进入 exact generation fingerprint；
- 不允许在 semantic section 中使用任意 `.json` object 作为“隐藏第二 Schema”。

选择 content file 而不是把所有 prose 内嵌到 `source.json` 的原因：

- 真实 World 已有 50–80KB；
- Character 常有表格、长段落与引用；
- Markdown 对作者、diff、审查、迁移更友好；
- manifest 负责 identity/ownership/index，content file 负责丰富 authored meaning。

---

# 3. World Pack v0.2

Manifest：

```json
{
  "schema_version": "world_pack.v0.2",
  "asset_id": "world.example",
  "asset_type": "world_pack",
  "version": "1.0",
  "display_name": "Example World",
  "catalog_summary": "short chooser description",
  "world_instructions": "compact always-on world invariants",
  "gm_instructions": "compact always-on GM operational guidance",
  "semantic_sections": [],
  "entries": [],
  "authored_assets": []
}
```

## 3.1 `world_instructions`

拥有：

- 世界最重要的因果 / ontology / future-open invariant；
- 适合在相关 Runtime Context 中高频出现的少量规则。

不应该成为整个 World Pack 的 80KB 摘要，也不应该重复所有 lore。

## 3.2 `gm_instructions`

拥有：

- GM 使用这个 World 的稳定操作原则；
- 例如 T0 后未来开放、信息来源要合理、不要把默认历史当剧本。

它不是隐藏世界百科，也不是每 Turn 的格式要求。

## 3.3 `semantic_sections`

至少一项。

推荐但非 closed vocabulary：

```text
overview
world_logic
history
geography
society
institution
material_life
technology
culture
metaphysics
knowledge
world_secret
gm_guidance
asset_coordination
other
```

实际 section type 由真实 World 内容决定；不要为了“填齐类型”制造空章节。

典型：

```json
{
  "section_id": "great-fracture-public-history",
  "section_type": "history",
  "title": "大断裂：公开历史",
  "disclosure": "gm_reference",
  "content_path": "sections/29_great_fracture_public.md"
}
```

```json
{
  "section_id": "great-fracture-hidden-truth",
  "section_type": "world_secret",
  "title": "大断裂：仅 GM 掌握的真相",
  "disclosure": "gm_private",
  "content_path": "sections/30_great_fracture_truth.md"
}
```

## 3.4 `entries`

继续是 `0..N`：

```json
{
  "entry_id": "t0-208-red-cliffs-eve",
  "display_name": "208｜赤壁前夕",
  "opening_seed": "rich enough authored T0/opening reference"
}
```

规则：

- Entry 是 T0 / opening seed，不是 beat graph、quest script、branch DSL；
- `opening_seed` 可以是较长文本，用于表达定位、已成为过去、仍开放、适合身份等；
- World 可在 semantic section 中另行解释 custom-T0 规则；第一代 Wizard 不因此必须支持任意年份 picker；
- Entry 不保证某个 Character 开场出现。

## 3.5 `authored_assets`

继续 `0..N`：

```json
{
  "asset_id": "world-map-main",
  "kind": "portrait | scene | map | document",
  "path": "assets/world-map.webp"
}
```

全部正式 bytes 纳入 exact generation。

## 3.6 v0.2 删除 `source_material`

v0.1 的 mandatory arbitrary `source_material: {}` 不进入 v0.2。

原因：

- 没有真实 machine consumer；
- 容易成为任意旧数据的 dumping ground；
- 容易变成第二套 hidden schema；
- G4-05 实际已经出现“只放 provenance metadata、正文仍被摘要”的误用。

若未来有真实结构化 World consumer，再由该 consumer 拉出明确 owner/contract。

---

# 4. Character Card v0.2

没有 portrait 的 canonical manifest：

```json
{
  "schema_version": "character_card.v0.2",
  "asset_id": "character.example",
  "asset_type": "character_card",
  "version": "1.0",
  "display_name": "Example Character",
  "catalog_summary": "short chooser description",
  "semantic_sections": [],
  "player_character_supported": true
}
```

有 Source-authored portrait 时才额外出现：

```json
{
  "portrait": {
    "path": "portrait.webp",
    "alt_text": "authored portrait description"
  }
}
```

## 4.1 Character 是 reusable source

Character Card 不等于 Player Character，也不默认等于 current NPC。

第一代建局角色用途仍是：

```text
Exactly 1 Player Character
0..N Guaranteed NPC Characters
```

Guaranteed NPC 只保证 Final Create 后属于本局 canonical cast，不保证：

- opening appearance；
- same scene；
- player-known；
- current relationship；
- automatic Context membership。

## 4.2 `semantic_sections`

至少一项，并且必须存在一个 `section_type = identity` 的 section。

推荐但非 closed vocabulary：

```text
identity
personality
capabilities
behavior
relationships_autonomy
expression
knowledge
t0_boundary
hooks
asset_coordination
other
```

这套 vocabulary 来自两种真实 World family、六张 Character 的重复结构；但不要求每张简单 Character 为了形式完整而强行拥有每一种 section。

### 为什么不把内部继续拆成几十个字段

例如 `personality` 内可以自然包含：

- values；
- desire/need；
- fears/emotional debt；
- judgment style；
- contradictions；
- blind spots；
- pressure response；
- change conditions。

`capabilities` 可以自然包含：

- narrative strengths/limits；
- attributes table；
- skill table；
- spell list；
- evidence；
- specialties。

v0.2 的职责是**不丢这些 meaning**，不是在还没有 mechanical consumer 时替未来战斗/技能系统冻结 ontology。

## 4.3 Knowledge semantics

Character 的 `knowledge` section 可以表达：

- what this person can reasonably know；
- knowledge source；
- uncertainty / stale information；
- authored GM-private background；
- what they explicitly do not know。

但：

```text
Character Source knowledge boundary
!= current Game knowledge state
!= player-known state
```

游戏中后来学到/忘掉/误信/传播的知识属于 Game-local Knowledge Domain。

## 4.4 Relationship hooks

开局前已经发生的相识、共同经历、历史债务可以属于 Character Source authored past。

例如：

> “阿德里安曾在公开联合演练中败于塞芙琳。”

可以保留。

但 Source 不得保存：

- current favor；
- current trust；
- current relationship status；
- 当前是否同队 / 同地。

同一个 past hook 不要求双方 Source 用完全对称的字段表示。

## 4.5 T0 / history boundary

`t0_boundary` section 可以表达：

- T0 前既定人生；
- 随 World Entry/年份解释的历史状态；
- 原始历史未来只是参照；
- player takeover 后代理权属于玩家；
- deliberate blanks。

v0.2 **不**为了三国的动态年份提前发明 universal `character_t0_overlay_schema`。

原因：目前还没有一个 deterministic program consumer 证明所有 Character 都需要同样的机器化 T0 overlay。G4-06/G4-07 若真实 materialization 证明需要，再从 actual consumer 拉出最小结构；不能现在以未来猜测制造 platform。

## 4.6 Portrait optional｜canonical absence rule

`portrait` 是 optional field，只有 Source package 真正提供 authored portrait 时才出现。

- 若存在：必须为 `{"path": "...", "alt_text": "..."}`；
- 若不存在：**直接省略 `portrait` 字段**；v0.2 不接受用 `null` 表达 canonical absence；
- 若存在，portrait bytes 纳入 exact generation；
- Application 可以显示自己的 placeholder，但 placeholder 不得写进 Source manifest、不得伪装成 historical/authored visual、不得改变 Source generation。

这条规则由 semantic owner 冻结，工程实现不得自行改成“required placeholder”或另一套 absence representation。

## 4.7 `player_character_supported`

boolean，语义不变：

- true：允许后续 New Game 显式选择为 Player Character；
- false：不可作为 Player Character；
- 不代表该卡 NPC-only，也不建立 opening placement。

---

# 5. Source / Game-local / Runtime hard boundary

v0.2 Source 永远不拥有某局当前 live truth。

结构化 machine state 禁止包括：

```text
current timeline / save / conversation / runtime history
current location
current relationship / favor / trust
current injury / condition
current inventory
current knowledge
player-known state
opening appearance
current context membership
current faction membership/state when it is a lived-game fact
current quest/thread/mechanic state
```

注意：Source prose 可以讨论这些概念的**规则、既定过去或边界**；Program 不应用关键词扫描去审查 prose。禁止的是把 current live truth 当成 Source authoritative structured state。

---

# 6. Game-local semantic evolution｜必须兼容

v0.2 Source contract 不是 Living World 的可能性上限。

Final Create 后：

```text
Exact immutable Source generation
→ Game-local canonical object
→ lived history / Runtime evolution
```

本局对象必须允许模型在游戏过程中产生 Source 没预见的新 semantic facets，例如：

- 某次长期失败形成的独特心理创伤；
- 新形成的政治伦理；
- 新学术派别；
- 新制度或社会概念；
- 一种本局独有的长期人格结构。

但这不是：

- 修改 global Source schema；
- 回写 original Source；
- `ALTER TABLE` by model；
- 绕过已有 Domain owner。

如果已经存在正式 canonical Domain，例如 Location / Relationship / Injury / Inventory / Knowledge / Faction，则变化必须进入那个 Domain，而不是在 generic facet 再存一份第二 truth。

Game-local evolvability 的 canonical architecture decision 由 governance repo 持有。

---

# 7. Context contract｜Richness without model burden

Semantic sections 是 retrieval unit，不是 prompt dump unit。

未来 Context Assembly 必须保持：

```text
Source Total Content
!= Game-local Total State
!= Runtime Relevant Set
!= Model-visible Working Set
```

典型当前场景可能只需要：

```text
Character: identity + personality + relevant capability + current local facts
World: relevant geography/institution/knowledge section
Recent game history
```

不需要把整张 15KB Character + 80KB World 每 Turn 全部注入。

`section_type` / `section_id` / `disclosure` 是 Context selection 的索引信息，不是模型回复格式。

---

# 8. Exact generation rules

Generation fingerprint 至少覆盖：

- canonical manifest；
- every semantic section content file；
- every declared authored asset；
- Character portrait when present。

规则：

- 未声明文件不影响 generation；
- 声明文件缺失 fail-loud；
- path escape / symlink fail-loud；
- exact generation 安装后 immutable；
- Existing Game pin exact generation；
- Source update 不静默改变 existing Game。

---

# 9. Validation philosophy

Validator 负责结构完整性与真正的硬边界，不负责文学质量审查。

应验证：

- identity / schema / type；
- required cardinality；
- unique IDs；
- disclosure enum；
- safe file path / file existence；
- content file type；
- exact fingerprint；
- structured live-state boundary；
- optional portrait/reference safety。

不应验证：

- Personality 是否“足够复杂”；
- 每张 Character 是否必须有八章；
- prose 是否出现“关系”“伤势”等词；
- 世界设定是否符合某个统一 ontology；
- 模型未来是否只能产生现有 section types。

内容 fidelity / semantic quality 必须由 real-asset review + later product UAT 证明，而不是无限扩大 validator。

---

# 10. v0.1 → v0.2 semantic differences

| v0.1 | v0.2 |
|---|---|
| Character `public_profile.summary/traits` | `catalog_summary` + rich sections |
| Character `gm_private_profile.background/drives` | explicit section-level authored semantics/disclosure |
| required portrait | optional; field omitted when absent |
| World `source_lore[]` inline only | rich semantic content files |
| mandatory arbitrary `source_material` | removed |
| no explicit GM hidden section | `disclosure=gm_private` |
| prose largely forced into compact manifest | long Markdown/TXT content is first-class exact Source bytes |
| Source schema can appear to define all character dimensions | explicit Game-local evolvability |

---

# 11. Implementation boundary

This semantic freeze does **not** authorize GPT to improvise GDScript changes in place of Codex.

Next order:

```text
GPT semantic freeze
→ GPT faithful real-asset v0.2 content/packages
→ narrow Codex loader/validator/fingerprint correction
→ automated + filesystem + Windows regression
→ GPT Independent Review + content fidelity review
→ resume G4-05 closure
```

Do not start G4-06 until G4-05 is formally revalidated and closed.
