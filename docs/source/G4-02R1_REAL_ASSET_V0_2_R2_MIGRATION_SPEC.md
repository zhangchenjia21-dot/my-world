---
title: my world｜G4-02R1 Real Asset v0.2-r2 Migration Specification
status: current-gpt-owned-content-migration-spec
owner: GPT
created: 2026-08-29
historical_snapshot: zhangchenjia21-dot/sillytavern-assets@4a5364a042e41f4c8a69621fc4467956a78703c0
base_contract: docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md
t0_addendum: docs/source/G4-02R1_T0_SCOPED_SOURCE_CONTRACT_ADDENDUM.md
supersedes: docs/source/G4-02R1_REAL_ASSET_V0_2_MIGRATION_SPEC.md
---

# G4-02R1｜真实资产 v0.2-r2 迁移规格

## 1. Migration rule

默认动作：

> **preserve → re-home → T0-scope → explicitly omit only when owner is wrong.**

迁移目标不是把旧 Markdown 变短，也不是把整个人生/整段历史交给 Runtime。

必须同时满足：

1. **Fidelity**：真实 authored meaning 不缩水；
2. **Ownership**：live Game truth 不进入 Source；
3. **Temporal authority**：post-T0 canon 不进入 earlier T0 ordinary Runtime；
4. **Model freedom**：隔离未来答案，不限制未来创作。

---

## 2. Stable identity｜不得重新命名

v0.2-r2 是合同/内容升级，不是创建新 logical assets。

当前稳定 ID：

```text
World
world.han_end.unsettled_realm
world.ashtervia.afterglow

Character
character.han_end.liu_bei
character.han_end.cao_cao
character.han_end.sun_quan
character.ashtervia.livia_selan
character.ashtervia.adrian_wilk
character.ashtervia.duen_stonescar
```

`ashtervia` 命名即使不理想，也不得在本迁移中静默改成新的拼写。若未来要重命名，必须单独做 identity migration decision。

---

## 3. Common fidelity rules

对历史 DSH-native Markdown：

- 保留 substantive authored prose、表格、例子、边界与灰度；
- YAML/frontmatter 中 repo housekeeping / Revision Notes 可省略；
- 一个旧章节可以按自然小节拆分，但不得压成几个 bullet；
- World/Character/Expansion/Game-local owner 必须继续分离；
- `gm_private` 不得泄漏到 catalog summary；
- 缺少 authored visual 时 portrait 直接缺省；
- 不把技能/法术表提前升级成 universal machine mechanic schema；
- 不把“完整 Source package 被 fingerprint”误解成“整个 package 每回合都可进入 Context”。

### Per-asset audit

每个最终 package 必须能回答：

1. 原始 major GM-useful section 去了哪里？
2. 哪些内容是 always-safe？
3. 哪些内容只属于某个 Entry/T0 profile？
4. 是否存在 post-T0 future leakage？
5. 哪些内容因 wrong owner / legacy-only 被明确省略？
6. 是否有 gm_private 泄漏？
7. stable identity / eligibility 是否保持 current product decision？

---

## 4. Temporal rule｜最重要新增

> **Do not show the model a post-T0 answer and then ask it to forget that answer.**

### World

```text
top-level semantic_sections
= only always-safe material

selected Entry.semantic_sections
= world truth valid at selected T0

unselected Entry content
= installed/fingerprinted but Runtime-ineligible
```

### Character

```text
top-level semantic_sections
= only always-safe material

selected matching t0_profile.semantic_sections
= character truth valid at selected T0

later/unmatched profile
= Runtime-ineligible
```

No fallback to latest/nearest/later profile.

No complete-life biography fallback.

No canon probability / divergence score.

---

# 5. World｜汉末三国：天下未定

Source:

```text
世界包/汉末三国_天下未定_World_Pack_v0.2.3.md
blob: 9d05fb2dadad8ea140d611e9f3bab49c0d8f2677
asset_id: world.han_end.unsettled_realm
```

## 5.1 Always-safe candidates

只保留真正跨支持 T0 安全的内容，例如：

- T0 之前是既定过去、T0 之后未来开放；
- history inertia without correction force；
- game reality > source future reference；
- causality-first / knowledge-source-first；
- 史料来源分层规则本身；
- World / Character / Expansion / Game-local ownership；
- 真正稳定的时代社会/地理/文化基础，前提是内容没有偷带 later outcome。

“184–280 历史脉络”不能因为它是 lore 就整体放入 always-safe Runtime section。

## 5.2 Entry preservation

原资产中真正 authored 的固定 Entry 必须全部保留，不能再次只取四个样例。

**不得为了迁移方便发明原资产没有的 Entry。**

每个 Entry 应得到自己的 T0-scoped material，至少覆盖该时点已经成立且对开局有价值的：

- 已发生关键历史；
- 当前政权/势力/制度状态；
- 当前地缘与交通压力；
- 当前社会/军事/经济背景；
- 与 Opening 相关的局势；
- relevant GM-private/reference material when authored。

Entry 后面的原历史结果不能进入该 Entry ordinary Runtime projection。

## 5.3 First temporal pressure test

优先选择：

- 原 World 中最早的真实 fixed Entry；
- 另一个明显更晚、且世界状态已经发生重要变化的真实 fixed Entry。

证明：

```text
early Entry projection
does not contain
later Entry-only markers/outcomes
```

同时检查 early Entry 仍然足够丰富，不因 quarantine 变成空壳背景。

---

# 6. Character｜孙权｜FIRST CHARACTER TEMPORAL PRESSURE

Source：固定 v0.1.2 historical card。

```text
asset_id: character.han_end.sun_quan
player_character_supported: true
```

孙权用于先证明：

> **late-life authored evidence must not become early-life personality authority.**

## 6.1 Always-safe

只允许真正跨 T0 稳定且不会偷带后期证据的 continuity material。

不要因为“孙权最终是怎样的人”而写一个覆盖全部年龄的成人政治人格模板。

## 6.2 T0 profiles

只为**真实 World fixed Entries**建立 profile，不按每一年机械生成。

每个 profile 只包含截至该 Entry 已真实形成的：

- 年龄与身份；
- 已发生家庭/政治经历；
- 该时点已有能力/局限；
- 有证据支持的人格惯性/矛盾；
- 已存在关系与知识；
- 当时开放的未来。

若某个早期 Entry 时孙权尚年幼，则 profile 应诚实表达年幼状态；不能为了“角色卡完整”提前灌入成年统治者的决策逻辑。

## 6.3 Forbidden leakage

Earlier profile 不得因为旧完整人物卡提到这些 later facts 就暴露：

- 后来接掌江东后的成熟治理经验；
- 后来形成的长期政治疑虑；
- 晚年继承斗争；
- 称帝/后世评价；
- 只有 later lived history 才能证明的人格结论。

## 6.4 Test markers

设计至少一个 later-only semantic anchor；验证它：

- 存在于 later profile；
- 不存在于 early T0 projection；
- 不进入 early Setup/Context material。

测试不能只做字数比较。

---

# 7. Character｜刘备

```text
asset_id: character.han_end.liu_bei
player_character_supported: true
```

原有主要语义仍需保留：关系信用、自主性、韧性、能力/局限、决策逻辑、关系风格、表达、知识边界、玩家接管。

但必须按真实 World Entry 重审时间归属：

- later 形成的组织经验不能倒灌 earlier profile；
- later 关系/追随者/政治位置不是 earlier fact；
- 建立蜀汉、称帝、夷陵等 post-T0 outcome 永远不是 earlier Runtime truth。

No portrait unless authored bytes exist.

---

# 8. Character｜曹操

```text
asset_id: character.han_end.cao_cao
player_character_supported: true
```

保留真实人格复杂度，但 profile 证据必须截至对应 T0。

尤其：

- 不能用后来长期掌权后的治理/控制经验证明 earlier 曹操已经拥有完全相同的成熟形态；
- “奸雄”等后世总结不能作为跨 T0 固定人格；
- later political position/resources/relationships 不得倒灌；
- current causality 可以让本局曹操后来变得更像或更不像原历史，两者都必须由 lived history 支撑。

No portrait unless authored bytes exist.

---

# 9. Character｜莉维娅·塞兰

Source fixed historical snapshot card.

```text
asset_id: character.ashtervia.livia_selan
player_character_supported: true
```

当前 authored T0 为断界历 1287；第一代没有多年份 consumer，因此不人为制造多 profile。

可把完整 1287 starting Character material放入一个 matching 1287 profile：

- personality/value/fear/contradiction；
- attributes/skills/evidence/spells/limitations；
- behavior/goals/red lines；
- past relationship hooks/autonomy；
- expression；
- public/private knowledge；
- pre-1287 history；
- deliberate blanks。

`gm_private` accident/inner ambition 继续隔离为 private section。

1287 之后作者若有 future outcome，不进入当前 profile。

---

# 10. Character｜阿德里安·维尔克

```text
asset_id: character.ashtervia.adrian_wilk
player_character_supported: true
```

固定 1287 profile 保留：

- family/name tension；
- honor/self-mastery / pity sensitivity；
- full authored attributes/skills/sword+magic/spell familiarity；
- explicit narrow-domain limits；
- goals/red lines；
- pre-T0 hooks with 塞芙琳 / 杜恩；
- autonomy/player agency；
- expression；
- public/private knowledge；
- pre-1287 past and deliberate blanks。

No fabricated portrait.

---

# 11. Character｜杜恩·石痕

```text
asset_id: character.ashtervia.duen_stonescar
player_character_supported: false
```

`false` 是 current product conversion decision；不要从旧“世界绑定 NPC”标签重新推导其它角色资格。

固定 1287 profile 保留：

- freedom/debt contradiction；
- experience-based judgment and blind spots；
- full attributes/skills/spells/limits；
- old injury/debt event as pre-T0 private history；
- behavior/autonomy；
- relationship hooks；
- expression；
- knowledge provenance；
- pre-1287 past/open future。

No fabricated portrait.

---

# 12. World｜埃瑟维亚：诸界余辉

Source:

```text
世界包/埃瑟维亚_诸界余辉_World_Pack_v0.1.3.md
blob: 42924b5c8b18afc7622b8f3c04afc393a69f72e8
asset_id: world.ashtervia.afterglow
```

当前 first-generation authored T0 是断界历 1287，因此 temporal pressure 比三国低，但仍必须遵守相同 contract。

保留真实丰富章节：

- overview/world logic；
- magic civilization / standardization；
- material life；
- geography；
- nations/institutions；
- Ovista；
- civilizations；
- gods/metaphysics；
- ancient/public history；
- knowledge boundary；
- expansion coordination；
- GM causality guidance。

大断裂后台真相/升格网络继续为 `gm_private`。

若原资产有 1287 之后的 future authored outcome，则不得作为 1287 Runtime future truth。

---

# 13. Cross-family / unmatched profile rule

当前 G4-05 不恢复 same-family hard restriction。

若 Character 没有 selected World/Entry exact T0 profile：

```text
allowed source material
= always-safe only
```

禁止：

- latest/nearest profile fallback；
- later profile fallback；
- complete-life biography fallback；
- 根据 display name 猜一个 profile。

Compatibility Review / G4-06 再从真实 consumer 决定该情况是 warning 还是更强 policy。

---

# 14. No convergence / no divergence force

本迁移不得在 Source 中写：

```text
follow_canon_probability
historical_divergence_score
fate_correction
replacement_event
must_be_different
```

Source 提供当前因果惯性。

未来由 Game-local actors/world reality 产生。

相似历史结果可以自然发生；原历史没有特殊优先权。

---

# 15. Evidence before Codex

在发任何 v0.2-r2 Codex implementation packet 前，GPT 必须至少完成：

1. 孙权 early/later real T0 profile pressure；
2. 三国 World early/later real Entry pressure；
3. manual source ↔ profile fidelity sample；
4. later-only marker exclusion proof at package/spec level；
5. stable identity audit for all 8 packages；
6. no fake portrait audit；
7. no gm_private picker leak audit；
8. confirm profile shape has stopped changing under these real pressures。

只有之后才允许 Codex实现 loader/validator/fingerprint/T0 projection mechanism。
