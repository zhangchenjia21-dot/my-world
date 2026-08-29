---
title: G4-02R1｜孙权 + 汉末三国 T0 Pressure Result
status: semantic-data-pressure-pass
owner: GPT
created: 2026-08-29
scope: semantic/data pressure only
implementation_pass: false
final_asset_fidelity_pass: false
pressure_fixture: tests/fixtures/g4_02r1/t0_pressure/汉末三国
---

# G4-02R1｜孙权 + 汉末三国 T0 Pressure Result

## 1. Verdict

> **PASS — v0.2-r2 survives the first real temporal pressure at semantic/data level.**

No r3 field expansion is required by this pressure pair.

This is **NOT** Godot/loader implementation PASS and **NOT** final 2 World + 6 Character fidelity PASS. Current production loader remains v0.1. The pressure fixture is intentionally partial and exists to falsify the temporal design before full migration.

---

## 2. Evidence set

Historical source:

```text
zhangchenjia21-dot/sillytavern-assets
@ 4a5364a042e41f4c8a69621fc4467956a78703c0

World
世界包/汉末三国_天下未定_World_Pack_v0.2.3.md
blob 9d05fb2dadad8ea140d611e9f3bab49c0d8f2677

Character
人物卡/汉末三国/CC-BATCH-01/孙权__Character_Card__v0.1.2.md
blob 285599304931cb422f69a5507558c235214e56ad
```

Pressure package:

```text
tests/fixtures/g4_02r1/t0_pressure/汉末三国/
├─ projection_expectations.json
├─ 天下未定/
│  ├─ source.json
│  ├─ sections/
│  └─ entries/184|200|208|229|263/
└─ 孙权/
   ├─ source.json
   ├─ sections/
   └─ t0/184|200|208|229/
```

Formal expectations:

`tests/fixtures/g4_02r1/t0_pressure/汉末三国/projection_expectations.json`

---

## 3. What the pressure found and corrected

### 3.1 Adult-personality backward leakage｜FOUND → CORRECTED

pre-r2 孙权 fixture 把：

- long-term regime management；
- mature ruler delegation；
- long-rule security concerns；
- later succession pressure；

放在 top-level Character sections。

这意味着 184 幼童孙权也会得到成年统治者模板。

r2 pressure fixture 已改为：

```text
top-level
= thin identity continuity only

184 profile
= child reality

200 profile
= newly succeeded young ruler

208 profile
= years of actually earned ruling experience

229 profile
= decades of actually earned ruling experience + current emperor identity
```

人物复杂度随着 **pre-T0 lived history** 增长，而不是从人生结局反推。

### 3.2 Same-year Entry ambiguity｜FOUND → CLARIFIED

`200｜官渡前夕` 不能只靠 `year=200` 推断孙策死亡/孙权继承是在 T0 前还是后。

Pressure conversion cut：

> **孙策已经身亡，孙权刚接掌江东；当前北方主战决定性胜负尚未成为过去。**

因此 `entry_id` / year label 不再被当成充分 temporal evidence。

### 3.3 Dead-character fallback｜FOUND → CORRECTED BY CLOSED COVERAGE

如果 no-match 永远 fallback 到 always-safe，263/280 可以错误 materialize 已经不属于该 T0 的孙权。

r2 clarification：

```text
Character has any profile binding to World W
→ temporal coverage for W is closed

exact Entry binding exists
→ compatible

missing Entry binding
→ temporally incompatible
```

Pressure World 实际加入 263 Entry；孙权故意没有 263 binding，因此预期结果是：

> **TEMPORALLY_INCOMPATIBLE — no Character fallback materialization.**

不需要 universal `alive/dead/not_born` schema。

### 3.4 Future canon in negative instructions｜FOUND → CORRECTED

第一版 pressure prose 仍出现：

```text
“不要参考未来事件 X / 后期人格 Y”
```

这仍会把 X/Y 作为 prompt cue 暴露给模型。

已改为：

> **Runtime-visible negative rule 使用泛化 authority language，不枚举 post-T0 answers。**

例如写：

```text
任何只能由当前 T0 之后经历证明的人格/能力/结果都没有当前 authority
```

而不是逐条告诉模型后来发生了什么。

### 3.5 Future canon in always-safe examples｜FOUND → CORRECTED

第一版 always-safe World rule 曾用 later Entry 的历史标签举例，即使只是解释 quarantine，也会向 early Game 暴露 future cue。

已删除具体 later label，改为 generic `other later Entry`。

---

## 4. Model-visible metadata clarification

Pressure 进一步证明：

> **Selection/index metadata != automatic model-visible context.**

特别是：

```text
catalog_summary
asset_id / profile_id / entry_id
Entry.display_name
T0 profile.display_name
```

主要服务 Source Library / New Game / exact selection / diagnostics。

例如玩家可以在 New Game UI 中看到熟悉的 `208｜赤壁前夕` 标签来选择历史窗口；但普通 GM Setup Context 不应因为 `display_name` 存在就自动注入这个字符串。

Runtime model material应来自：

```text
explicitly eligible semantic content
+ selected opening material
+ deliberately chosen temporally-safe metadata
+ Game-local Reality
```

不能把完整 manifest 直接 dump 进 Prompt。

这不是新增 Source field；它是既有 Context architecture 的明确消费规则。

---

## 5. Projection pressure matrix

### Case A｜184 + 孙权

Eligible：

```text
World always-safe
+ 184 World snapshot
+ 孙权 identity continuity
+ 孙权 184 profile
```

Must exclude：200/208/229/263 World snapshots and 200/208/229 Character profiles。

Positive richness evidence includes：

- central/local order tension；
- local militarization；
- commoner livelihood / transport / requisition；
- child family identity；
- dependency on care/family network。

Forbidden later markers are absent from eligible semantic files.

Verdict：**PASS at semantic/data level.**

### Case B｜200 + 孙权

Eligible profile has：

- Sun Ce death / Sun Quan just succeeded as current past；
- succession fragility；
- dependence on senior retainers/clan/local forces；
- young ruler responsibility；
- incomplete experience；
- current information boundary。

It does not require later-life outcomes to make the Character interesting.

Verdict：**PASS at semantic/data level.**

### Case C｜208 + 孙权

Eligible profile has richer, earned evidence：

- years of actual ruling responsibility；
- multi-center consultation/delegation；
- realistic diplomatic judgment；
- system-level risk responsibility；
- current northern/southern pressure；
- logistics/disease/information uncertainty。

Later political/personality answers remain excluded.

Verdict：**PASS at semantic/data level.**

### Case D｜229 + 孙权

Current past legitimately includes：

- Wei/Shu-Han/Wu as current political reality；
- Sun Quan emperor identity；
- decades of actual ruling experience；
- long-term regime management as earned capability evidence。

Post-229 outcomes remain generic/open rather than enumerated into Runtime.

Verdict：**PASS at semantic/data level.**

### Case E｜263 + 孙权

World 263 snapshot exists in the same Source package.

Character has declared Han-World profile coverage but no exact 263 binding.

Expected compatibility result：

```text
TEMPORALLY_INCOMPATIBLE
```

No always-safe fallback may resurrect/materialize the Character.

Verdict：**PASS as contract/data expectation; executable proof waits for r2 loader/Compatibility Review implementation.**

---

## 6. Richness vs quarantine result

The pressure does **not** show a forced trade-off between anti-convergence and Narrative capability.

Observed shape：

```text
184
rich child/family/social reality
but no adult ruler answer

200
rich succession crisis / young authority reality
but no decades-long ruler answer

208
richer earned political competence
but no later-life answer

229
richer again because more life has actually happened
```

Therefore：

> **T0 quarantine can remove future-answer shortcuts without flattening present character/world depth.**

The model remains free to create new behavior, relationships, events and semantic evolution after T0.

---

## 7. Contract result

Current v0.2-r2 remains sufficient with clarifications already written into the T0 Addendum：

1. Entry temporal sufficiency；
2. per-World closed profile coverage；
3. no fallback to later/nearest/complete-life profile；
4. future answers must not be reintroduced through negative examples；
5. selection/index metadata is not automatic model-visible content。

No evidence from this pressure requires：

- r3 schema；
- universal calendar engine；
- lifecycle enum；
- anti-history state machine；
- canon/divergence probability；
- giant temporal ontology。

---

## 8. What is still NOT proven

Do not over-claim this result.

Still unproven：

- current Godot loader/validator can parse r2；
- exact fingerprint implementation includes nested Entry/profile bytes；
- Compatibility Review actually blocks closed-coverage no-match；
- Context Assembly actually excludes unselected later material / unsafe display metadata；
- full 12-entry Han World fidelity；
- full Sun Quan supported-entry fidelity；
- Liu Bei / Cao Cao temporal profiles；
- Aetheria fixed-1287 family under the same contract；
- real Provider long-play anti-convergence behavior；
- Owner Narrative/UAT quality。

---

## 9. Next semantic migration order

Because the first pressure pair passed without new schema needs：

```text
1. expand 汉末三国 World to all 12 authored fixed Entries
2. expand 孙权 to all temporally compatible authored Entries
3. re-audit / migrate 刘备 and 曹操 across those Entries
4. complete fixed-1287 诸界余辉 World/Characters
5. manual fidelity + temporal leakage review
6. only then issue narrow Codex r2 mechanism task
```

G4-06 remains HOLD.
