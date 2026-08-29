---
title: G4-02R1｜刘备 / 曹操 Temporal Re-audit
status: current-semantic-audit
owner: GPT
created: 2026-08-29
contract: v0.2-r2
historical_snapshot: zhangchenjia21-dot/sillytavern-assets@4a5364a042e41f4c8a69621fc4467956a78703c0
---

# G4-02R1｜刘备 / 曹操 Temporal Re-audit

## 1. Purpose

在孙权 pressure 已证明 T0 quarantine 结构可行后，本审计检查另外两名首批真实 Character：

- `刘备__Character_Card__v0.1.2.md`
- `曹操__Character_Card__v0.1.2.md`

目标不是把旧完整人物卡按年份复制，而是回答：

> 哪些人格/能力在某个 T0 **已经被人生证据挣得**，哪些只是后来经历总结，必须继续 quarantine？

同时继续执行：

- present individuality；
- no adult-stereotype backfill；
- explicit temporal compatibility；
- no future convergence privilege。

---

## 2. Early evidence is unusually strong for both Characters

### 刘备

《三国志·先主传》对早年已有可直接使用的 pre-T0 evidence：

- 少孤，与母贩履织席；
- 十五岁从卢植学习，与公孙瓒有早期关系；
- 不甚乐读书，喜狗马、音乐、美衣服；
- 少语言、善下人、喜怒不形于色；
- 好交结豪侠，年轻人愿意依附；
- 商人资助后得以合徒众。

因此 early 刘备不需要靠“后来成为昭烈帝”倒推人格，也不应退化成 generic young adult。

### 曹操

《三国志·武帝纪》对青年曹操也已有明确 pre-T0 evidence：

- 少机警，有权数；
- 任侠放荡，不治行业；
- 二十岁举孝廉，历洛阳北部尉、顿丘令、议郎；
- 黄巾起后拜骑都尉讨颍川；
- 任济南相时已有强硬整顿官吏/祭祀秩序的行政实践。

因此 early 曹操可以有明显个体性，但不能把后来北方长期整合、成熟军政体系、魏王级安全心理提前塞进 184。

---

## 3. v0.1 / pre-r2 刘备 leakage

旧卡中下列语义跨越了多个 later lived-history 阶段，不能 top-level always-on：

- `即使多次失去地盘和依附他人，也倾向保存政治主体性`；
- `长期韧性强`，并以连续失败/失地后的恢复为证据；
- `在弱势和流动环境中重新组织力量` 作为成熟能力；
- `联盟、依附与自主之间的灵活切换` 作为已经稳定形成的技巧；
- `面对连续失败后的组织恢复`；
- 对长期追随者的深层关系经营模式；
- “保存人员、关系与未来可能性后重新起势”的成熟失败逻辑。

这些在 200/208/214 later T0 可以逐步获得充分 evidence，但不能全部灌给 184。

### Early-safe 刘备不是空白

184 前后已经可以保留：

- 寒微但有宗室远支身份的社会张力；
- 早孤、母子生计；
- 卢植学习/公孙瓒关系；
- 不甚乐读书但有自己的兴趣；
- 少语言、善下人、喜怒不形；
- 结交豪侠与形成早期青年网络；
- 对名望、身份、伙伴和现实资源之间差距的直接体验。

这些足够构成一个明确的 young Liu Bei starting person，而不需要 later kingdom-building answer。

---

## 4. v0.1 / pre-r2 曹操 leakage

旧卡中下列语义明显依赖 later lived history：

- `极强的现实政治与组织型人物` 作为全年龄固定模板；
- 成熟的多来源人才整合能力；
- 大规模军政资源统筹与指挥体系建设；
- 在多轮大战/失败中形成的快速战略调整；
- `成功经验提高扩大承担范围的意愿`；
- 高度集中权力下的长期安全疑虑；
- 魏王级名义/实际权力协调；
- 对长期部属、宗族、旧交与竞争者的成熟政治角色分离。

这些可以在 196、200、208、214 逐渐合法增加，但 184 不得使用 later evidence 证明。

### Early-safe 曹操也不是空白

184 前后已经可以保留：

- 青年时期机警、权数与任侠放荡的真实记载；
- 早期仕途和洛阳/顿丘/议郎经历；
- 已经出现的强执行倾向；
- 面对制度失序时愿意采取明显行动而非只做姿态；
- 黄巾战争开始带来的实际军事责任；
- 早期名望既有质疑也有少数知人者高度评价的社会张力。

这些足够构成有区分度的 early Cao Cao，而不必提前授予成熟霸主能力。

---

## 5. Temporal compatibility closure

### 刘备

历史寿命与当前 12 Entry skeleton 形成：

```text
184  compatible
189  compatible
196  compatible
200  compatible
208  compatible
214  compatible
220  compatible
229  incompatible
234  incompatible
249  incompatible
263  incompatible
280  incompatible
```

刘备在 223 年去世，因此 `229｜三国鼎立` 及以后不得通过 always-safe fallback materialize。

### 曹操

```text
184  compatible
189  compatible
196  compatible
200  compatible
208  compatible
214  compatible
220  incompatible
229  incompatible
234  incompatible
249  incompatible
263  incompatible
280  incompatible
```

Current World `220｜汉魏鼎革` 已明确以 **曹操已死、曹丕接掌曹氏基础、曹魏建立** 为 starting past，因此曹操不得绑定该 Entry。

这再次验证 closed per-World profile coverage 足够表达 temporal incompatibility，无需 universal `alive/dead` schema。

---

## 6. 刘备 profile ladder

### 184｜young network / first mobilization window

Eligible evidence:

- early family/economic background；
- youth learning and social network；
- early temperament attested by source；
-豪侠/merchant network and initial ability to gather people where the exact Entry cut supports it；
- age-appropriate political ambition may exist as open aspiration, not kingdom destination。

Quarantine:

- repeated-loss resilience as proven mature trait；
- long alliance-switching expertise；
- Xuzhou/Jingzhou/Yizhou lived experience；
- mature ruler identity；
- later relationship consequences。

### 189｜first years of war/office experience

Can add only experiences already completed by this cut, including Yellow Turban-era service / early minor office and movement where chronology is verified.

Still cannot treat long-term political subjectivity after repeated dependence as already fully proven.

### 196｜regional actor under unstable Xuzhou/Lü Bu conditions

By this point the Character has materially more lived evidence about office, armed followers, alliances, loss of position and dependence.

The exact 196 profile requires an event-relative starting cut because Liu Bei's Xuzhou / Lü Bu status changes within this historical window.

### 200｜strong negative-control

By 200, more evidence can support:

- repeated rebuilding after political/military disruption；
- distinguishing temporary dependence from own group continuity；
- stronger earned relationship/network skill。

But the Entry must clarify the exact relation to the 200 Xuzhou/Cao conflict; `year=200` alone is not enough.

### 208｜Jingzhou collapse / southward survival pressure

Mature flexibility, group continuity and current alliance reasoning now have much stronger lived evidence.

Still no future Yizhou state, emperor identity or later eastern campaign personality.

### 214｜Yizhou political base

Can legitimately add experience of building/holding a major territorial base and larger governance obligations.

### 220｜post-Han-Wei transition, pre-later future

Current identity may include a major independent regional regime and established political claims, but later decisions remain open from this Entry.

---

## 7. 曹操 profile ladder

### 184｜young official + first large war responsibility

Eligible:

- `机警 / 权数 / 任侠放荡` as attested youth evidence；
- early office practice；
- concrete enforcement/administrative experience already completed by Entry cut；
- current military responsibility against rebellion where exact cut supports it；
- strong but still developing self-confidence and willingness to act。

Quarantine:

- mature north-China integration skill；
- long-war logistics system；
- large-scale talent bureaucracy；
- later ruler-level security psychology；
- post-196 emperor/court leverage；
- later titles/outcomes。

### 189｜experienced official confronting central collapse

Can add more administrative and military evidence accumulated since 184.

But the Entry must not silently assume the full later anti-Dong path unless the 189 cut explicitly places those actions in the past. His response to the newly transformed central order can remain open at this T0.

### 196｜emperor-at-Xu political center

This is the first Entry where the current World itself gives direct authority for Cao Cao's new court-centered political position. He can now have materially stronger evidence for combining legitimacy, office, military force and administration.

### 200｜northern rivalry

Can add years of organization, personnel integration, war and political survival. This is a materially different Cao Cao from 184, but Guandu outcome remains open.

### 208｜northern advantage / southern pressure

Large-scale command and integrated northern resources are now earned current facts. The upcoming southern outcome remains open.

### 214｜long-running northern regime operator

Can have mature governance, personnel and logistics evidence based on decades already lived. Later final titles/death/posthumous state formation remain future.

### 220+

No binding. Temporal incompatibility.

---

## 8. New ambiguity findings

孙权 pressure showed one same-year ambiguity; 刘备/曹操 show this is a general temporal-authoring issue.

Potential hotspots requiring exact profile cuts before final package:

- Liu Bei 184: before/after initial anti-Yellow-Turban mobilization；
- Liu Bei 189: which early office/movement history is already past；
- Liu Bei 196: exact Xuzhou / Lü Bu status；
- Liu Bei 200: exact Xuzhou defeat / movement relative to the World Entry；
- Cao Cao 184: whether appointment/first campaign is already past at the chosen T0 cut；
- Cao Cao 189: whether escape/raising anti-Dong forces is already past or still open。

Rule:

> Character profile may refine Character-specific current status, but must not contradict the shared World Entry's event ordering. If multiple Character profiles depend on the same world event, the Entry must own the shared cut.

---

## 9. Individuality review consequence

刘备与曹操 both have strong early evidence, but that does not exempt them from the new pressure rules.

Each early profile must still pass:

1. future leak check；
2. adult-stereotype backfill check；
3. present individuality check；
4. counterfactual-adult check；
5. multi-future check。

For example:

- 刘备 early `少语言 / 善下人 / 喜怒不形` is acceptable because it is directly attested early evidence；
- `经历无数失败仍能重建集团` is not acceptable in 184 because its proof lies in later life；
- 曹操 early `机警 / 权数 / 任侠放荡` is acceptable early evidence；
- `成熟整合北方多来源人才与军政系统` is not acceptable in 184 because it requires later lived history。

---

## 10. Structural verdict

> **v0.2-r2 remains structurally adequate. No new field is required by Liu Bei / Cao Cao re-audit.**

Needed work is authored temporal content + exact profile/Entry cuts, not Schema expansion.

Next content step:

1. create pressure/fidelity T0 profiles for Liu Bei and Cao Cao across valid Entries；
2. resolve identified same-year cuts using primary/history evidence；
3. then integrate these profiles into final full-fidelity Character packages rather than retaining a complete-life top-level personality。
