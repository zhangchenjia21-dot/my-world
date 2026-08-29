---
title: G4-02R1｜孙权 + 汉末三国 T0 Temporal Pressure Audit
status: current-pressure-audit
owner: GPT
created: 2026-08-29
contract: v0.2-r2
historical_snapshot: zhangchenjia21-dot/sillytavern-assets@4a5364a042e41f4c8a69621fc4467956a78703c0
---

# G4-02R1｜孙权 + 汉末三国 T0 Temporal Pressure Audit

## 1. Purpose

本审计不是验证 JSON 能否装下内容，而是用最容易发生历史收敛的真实组合证明：

> **earlier T0 ordinary Runtime 不获得 later canon / later personality answer，同时仍保留足够丰富的当前人物与世界因果。**

压力对象：

```text
World
世界包/汉末三国_天下未定_World_Pack_v0.2.3.md
blob 9d05fb2dadad8ea140d611e9f3bab49c0d8f2677

Character
人物卡/汉末三国/CC-BATCH-01/孙权__Character_Card__v0.1.2.md
blob 285599304931cb422f69a5507558c235214e56ad
```

Current contract：

- `docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md`
- `docs/source/G4-02R1_T0_SCOPED_SOURCE_CONTRACT_ADDENDUM.md`
- `docs/source/G4-02R1_REAL_ASSET_V0_2_R2_MIGRATION_SPEC.md`

---

## 2. Pressure finding A｜pre-r2 孙权确实发生 temporal leakage

pre-r2 fixture 把完整 `personality / capabilities / behavior / relationships / knowledge / t0_boundary` 全部放在 Character top-level，因此任何 Entry 都会得到同一套成年统治者材料。

具体 later-evidence leakage 包括：

- `能长期调整政策`，论据直接来自“长期统治”；
- `信任人才 ↔ 长期统治下的安全疑虑`；
- `长期政权经营`；
- `长期继承与内部权力压力上升时，可能增加对忠诚和派系安全的敏感`；
- 统治者级的派系协调、最终裁决与系统性风险语义。

这些内容对 208、229 等 later T0 可能有足够 pre-T0 evidence，但不能成为 184/189/196 的普通 Runtime starting authority。

结论：

> **“一句话说明后期问题不能倒灌”不足以修复。pre-r2 fixture 必须废除 top-level complete-life political personality。**

---

## 3. Pressure finding B｜同一年不等于同一个 T0

旧 World 固定 Entry `200｜官渡前夕` 只明确：袁绍与曹操是北方主要竞争者，北方结果仍开放；它没有明确孙策身亡 / 孙权接掌江东是在 T0 之前还是之后。

而历史材料显示：孙策之死与孙权接掌发生在建安五年，且处于曹袁已经在官渡相拒的同一历史窗口。

因此：

```text
year = 200
```

不能自动推出：

```text
孙权已经接掌江东
```

正式结论：

> **Entry identity 比 year 更重要；即使 Entry 已绑定年份，Entry 自身仍必须 temporal-sufficient。**

如果一个高影响边界事件会改变 Character 的身份、权力、关系或能力，而 Entry 没有说明该事件属于 past 还是 open future，则 Character profile 不得自行猜测。

### 3.1 当前转换裁定｜不新增 Entry，只澄清既有 `200｜官渡前夕`

v0.2-r2 迁移将保留同一个 Entry identity / display concept，不新增第二个 200 Entry；但其 Entry-scoped T0 material 必须增加 event-relative cut：

> **孙策已经身亡，孙权刚接掌江东；官渡主战胜负尚未决定。**

这是一项 conversion clarification，用来把旧“官渡前夕”的宽泛年份锚点变成 deterministic starting snapshot；不伪造现代公历月日，也不把官渡结果写入未来。

如果后续原始史料审计推翻这个 cut，必须显式修订 Entry；不得用 nearest-year fallback 掩盖。

---

## 4. Pressure finding C｜no profile 有两种完全不同的含义

当前 r2 基础规则说：若没有 exact matching profile，只用 always-safe material，warning vs hard incompatibility 留给后续 consumer。

孙权把这个模糊点压出来了：

- 对另一个完全不同 World：没有 profile 可能只是“没有 authored special snapshot”；
- 对 `汉末三国` 263/280 Entry：孙权已经不再是该 T0 可 materialize 的活人物，不能通过 always-safe fallback 复活。

### 4.1 最小闭包规则｜无需新增 Schema 字段

正式采用：

> **Per-World Temporal Profile Coverage is closed once declared.**

规则：

```text
若 Character.t0_profiles 中
存在任意 binding 指向 World W

则对于 World W：
matching Entry binding = authored compatible
missing Entry binding  = temporally incompatible
```

因此：

- 不是 same-family 推断；
- 不是根据年份猜出生/死亡；
- 是 Character Source 对某个 World 的 explicit authored temporal compatibility；
- cross-world 若该 Character 从未对那个 World 声明任何 profile，仍保持 r2 的 always-safe-only / Compatibility Review 路线。

这让孙权可以：

```text
184..249  若有 authored profile → compatible
263/280   no binding → incompatible in 汉末三国
```

而不会引入 `alive/dead/not_born/...` 的通用生命周期枚举。

### 4.2 为什么不增加通用 temporal lifecycle schema

当前真实 consumer 只需要回答：

> 这个 exact Character Source 是否明确支持这个 exact World/Entry T0？

不需要现在冻结 universal birth/death/calendar ontology。

---

## 5. Pressure finding D｜World chapter 不能按“章节类型”粗暴判定 always-safe

旧 World 的 `184—280 六个历史阶段` 是非常好的作者/GM历史理解材料，但对 184 Runtime 而言，它同时包含：

- 官渡结果；
- 赤壁；
- 汉魏鼎革；
- 孙权称帝；
- 蜀汉灭亡；
- 司马氏权力转移；
- 晋灭吴。

所以：

> `section_type = history` 不是 temporal authority。

同样，地理、制度、人物、社会章节里若一句话用 later regime / later outcome 解释某地或制度，也不能因为章节整体“稳定”就直接放 top-level。

正式迁移单位因此必须是：

> **semantic meaning + temporal validity，必要时细于 legacy chapter。**

---

## 6. World migration strategy｜segment once, reuse safely

为了既保持 fidelity 又不复制 12 份完整世界，采用可共享的 pre-T0 history segments：

```text
history/through-184.md
history/184-to-189.md
history/189-to-196.md
history/196-to-200.md
history/200-to-208.md
...
```

每个 Entry 的 `semantic_sections` 可以引用一个或多个已经声明的 package-local content file；只要这些内容在该 Entry 已经成为 past。

例如概念上：

```text
184 Entry
→ stable world foundation
→ through-184

208 Entry
→ stable world foundation
→ through-184
→ 184-to-189
→ 189-to-196
→ 196-to-200
→ 200-to-208
```

注意：这不是事件 scheduler，也不是“按原历史自动推进”。这些 segment 只在**新建一个 later-T0 Game**时作为 starting past 使用。一个从 184 已经开始运行的 Game 永远不会因为年份前进到 208 而自动加载 `200-to-208` 原历史 segment。

这条区别是 Post-T0 Canon Quarantine 的核心。

---

## 7. 孙权 T0 profile strategy

### 7.1 Top-level always-safe 只保留连续身份

孙权 top-level 不保留成年统治者通用人格模板。

可保留的 always-safe 仅限类似：

- stable `asset_id / display_name`；
- 出生与家族身份这种不会因 later outcome 改变的 continuity；
- “不得使用 post-T0 pretrained canon 作为未来事实”这类 authority boundary。

完整 personality/capabilities/behavior/relationships/knowledge 进入 exact T0 profile。

### 7.2 Early child profiles must be honest

184 / 189 孙权尚年幼：

- 不灌入成年统治者的派系协调能力；
- 不灌入成熟外交策略；
- 不灌入长期统治形成的疑虑；
- 不为了“人物卡丰富”伪造成人 decision logic。

丰富度应来自当时真实存在的家庭位置、成长环境、可观察气质、知识范围、依赖关系与开放发展，而不是未来履历。

### 7.3 200 is first major succession pressure profile

按本次 conversion clarification：

```text
200｜官渡前夕
孙策已死
孙权刚接掌江东
官渡主战结果开放
```

因此 200 profile 可以拥有：

- 新继承权力的脆弱性；
- 江东并非自动稳固的现实；
- 张昭/周瑜等支持形成的当前政治条件；
- 初次承担最终权力后的判断压力；

但不能倒灌：

- 赤壁后的联盟/战争经验；
- 219/220 以后荆州与魏吴关系结果；
- 229 称帝；
- 晚年继承斗争形成的政治心理。

### 7.4 208 / 229 negative-control profiles

208 profile 应能证明：隔离未来并没有让孙权失去人物深度。此时已有约八年的实际统治经验，足以支持更成熟的用人、授权、江东自主、压力决策，但赤壁结果仍是 open future。

229 profile 可以拥有更长统治经验与已经发生的政权变化；`孙权称帝` 若 Entry cut 定义为已经发生，则可以成为 229 starting past。晚年继承问题仍不得提前成为 229 fixed personality，除非该问题在 229 前已有独立证据。

---

## 8. Required pressure assertions

### World early projection negative markers

184 projection 必须不含 later-only事实性材料，例如：

```text
曹魏建立
孙权称帝
蜀汉灭亡
司马氏掌权
晋灭吴
```

这些词可以存在于 package 其它 quarantined bytes；测试的是 selected projection，不是 package grep 必须为零。

### Character early projection negative markers

184/189/196 孙权 projection 不得出现 later-authority anchors，例如：

```text
长期政权经营
长期统治下的安全疑虑
晚年继承斗争
称帝后的统治身份
```

### Positive richness controls

不能只证明“没有 later marker”。至少还要证明：

- early World projection 有真实社会/地理/制度/危机材料；
- 200 Sun Quan 有 succession fragility / current support network / current knowledge；
- 208 Sun Quan 有已经获得的统治经验与现实压力；
- 229 Sun Quan 与 208 有真实 pre-T0 evidence 差异。

> **Leakage test + richness negative-control 必须同时 PASS。**

---

## 9. Contract verdict

### v0.2-r2 structural verdict

**PASS WITH CLARIFICATIONS — no r3 field expansion required.**

现有：

```text
World Entry.semantic_sections
Character t0_profiles + explicit bindings
```

足以表达本次压力发现。

需要冻结的只是两条语义澄清：

1. **Entry temporal sufficiency**：高影响 cut 未明确时，profile 不得猜；
2. **Per-World profile coverage closure**：Character 一旦对某 World 声明 temporal profiles，该 World 内 missing Entry binding = temporally incompatible。

不新增：

- universal calendar engine；
- birth/death lifecycle enum；
- anti-history state machine；
- canon probability；
- giant temporal schema。

---

## 10. Next action

```text
1. 将上述两条 clarification 写回 r2 Addendum / migration spec
2. 重做孙权 r2 fixture：top-level thin + exact T0 profiles
3. 建立汉末三国 r2 World pressure package：至少 184 / 200 / 208 / 229 first
4. 做 projection-level leakage + richness assertions
5. 若 first pressure pair PASS，再扩展全部 12 World Entries 与其余历史人物
```

在 1–4 完成之前，不发 Codex implementation task。
