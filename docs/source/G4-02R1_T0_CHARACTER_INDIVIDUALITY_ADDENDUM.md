---
title: G4-02R1｜T0 Character Individuality Addendum
status: current-semantic-contract-addendum
owner: GPT
created: 2026-08-29
updated: 2026-08-29
base_contract:
  - docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md
  - docs/source/G4-02R1_T0_SCOPED_SOURCE_CONTRACT_ADDENDUM.md
revision: v0.2-r2-individuality-clarification
owner_instruction: "同年龄/同发展阶段角色不得因 future quarantine 而同质化"
---

# G4-02R1｜T0 Character Individuality Addendum

本文件补充 v0.2-r2 Character T0 语义。

它不新增 JSON 字段；它规定 **T0 profile 的内容最低质量与 fidelity 义务**。

---

## 1. Core invariant

> **Age/development stage is a capability boundary, not a personality template.**

`幼童`、`少年`、`青年`、`成熟统治者` 等标签只能帮助说明当前能力/自主性的现实边界，不能替代角色本身。

因此：

```text
same age
!= same personality
!= same developmental prior
!= same relationships
!= same knowledge
!= same future trajectory
```

Future quarantine 隔离的是 **尚未发生的人生答案**，不是截至 T0 已经存在的个体差异。

---

## 2. T0 individuality floor

每个实际 materialize 的 Character T0 profile 必须提供足够的 **character-specific starting individuality**，使 GM 在不读取 future canon 的情况下仍能回答：

> **“为什么这个人从今天开始生活，会和另一个同龄人不一样？”**

可用材料包括，但不限于：

- 当前家庭位置、阶层、照料结构与生活尺度；
- pre-T0 已经经历的迁徙、丧失、教育、冲突、疾病、贫困、优待、责任或安全感来源；
- 已存在的亲属、伙伴、师长、榜样、依恋与排斥；
- 截至 T0 已可观察的人格/气质、兴趣、习惯、恐惧、价值萌芽与压力反应；
- 当前年龄真实拥有的能力、身体条件、技能、语言、社会经验与局限；
- 当前知识来源、误解、信息盲区与社会期待；
- 尚未解决、可以向多个方向发展的内部张力；
- deliberate blanks。

这些内容可以分布在一个或多个 rich semantic sections 中；不要求建立 rigid machine fields。

---

## 3. Evidence / authored-completion rule

历史或既有 canon 角色的早期材料可能很稀薄。

不得为了区分度把 later-life traits 倒灌成童年事实，例如：

```text
adult trait exists later
→ therefore child already had same trait
```

这是禁止的。

但也不能因为史料稀薄就退化成：

```text
Character A = generic child
Character B = generic child
Character C = generic child
```

当可靠 source 不足以支持具体早期气质时，允许作者做 **reasonable inference / original completion**，前提是：

1. 明确它不是被史料直接证明的事实；
2. 与当前家庭、社会、年龄、教育和已发生经历相容；
3. 不以角色未来成就/失败为倒推依据；
4. 不把它写成成年终点，只是 T0 starting disposition；
5. 开局之后允许 Game-local lived history 强化、改变、反转或消解它。

对于历史严谨模式，应保留来源层级：

```text
attested pre-T0 evidence
reasonable inference
authored completion
deliberate blank
```

不要求为这些层级新增 universal schema enum；可由 authored prose / fidelity notes 表达，直到真实 consumer 需要结构化。

---

## 4. Developmental prior != fate seed

T0 individuality 的作用是提供不同的 **starting priors**，不是偷偷编码未来人物。

禁止：

- “因为后来是名将，所以小时候天生军事奇才”；
- “因为后来多疑，所以儿童时期就固定多疑”；
- “因为后来善于纳谏，所以幼年一定已经表现为成熟政治听取机制”；
- 用童年特质安排一个必然收敛到 canon 的成长路线。

允许：

- 角色在不同家庭/阶层/教育/关系中形成不同注意力与压力来源；
- 已经发生的童年经历留下不同情绪与行为惯性；
- 作者在证据稀薄处给出非预言式、可改变的初始气质；
- 本局后续经历把这些 starting priors 塑造成与原历史相似或完全不同的成年人。

---

## 5. Runtime consequence

Game 创建后：

```text
T0 Character individuality
+ Game-local lived experience
+ current relationships / knowledge / injuries / obligations
+ current World causality
→ evolving Character
```

不能：

```text
T0 generic age template
+ pretrained canon knowledge
→ silently reconstruct historical adult
```

也不能：

```text
T0 authored personality
→ frozen forever
```

Source 只给起点惯性；Game-local Reality 持续拥有成长权。

---

## 6. Cross-character differentiation pressure

G4-02R1 在关闭前必须增加至少一组 **same/similar developmental-stage cross-character pressure**。

测试目的不是做数值差异分数，而是人工确认：

- 两个同龄或相近年龄人物不会只因都属于 `child/adolescent` 而共享同一人格模板；
- 在移除姓名后，profile 仍能通过家庭、经历、关系、气质、兴趣、知识与压力来源体现不同 starting person；
- 差异不是通过 future canon 暗示制造；
- 两者从相同 World T0 继续生活时，GM 有足够不同的起点依据产生不同反应；
- 后续仍允许 lived history 改写这些起点。

汉末三国可优先使用 `189 孙权` 与另一名同阶段历史人物做 pressure；若历史证据不足，可明确使用 authored completion，但必须记录依据层级。

---

## 7. Current Sun Quan verdict

当前 pressure fixture 中：

- 184/189 孙权已经正确避免成年统治者人格倒灌；
- 已有家庭身份、年龄、依赖关系和成长环境；
- **但当前文本尚不足以独立证明“与另一个同阶段儿童相比具有充分人物区分度”。**

因此当前判断拆分为：

```text
Sun Quan temporal isolation          = PASS
Sun Quan early individuality         = NOT YET PROVEN
v0.2-r2 structural expressiveness    = PASS
content/fidelity correction required = YES
```

在继续把刘备/曹操等迁移结果视为 final fidelity evidence 前，必须把这一维加入 review。

---

## 8. Acceptance principle

> **Quarantine future answers; preserve present depth; preserve present individuality.**

一个合格的早期 profile 既不能知道未来，也不能因为不知道未来而变成无个性的年龄壳。