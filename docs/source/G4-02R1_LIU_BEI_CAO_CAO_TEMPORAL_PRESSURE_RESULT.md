---
title: G4-02R1｜刘备 / 曹操 Temporal Pressure Result
status: temporal-skeleton-semantic-pass
owner: GPT
created: 2026-08-29
updated: 2026-08-29
scope: all valid Han fixed Entries at temporal-skeleton level
implementation_pass: false
final_asset_fidelity_pass: false
fixture: tests/fixtures/g4_02r1/t0_pressure/汉末三国
---

# G4-02R1｜刘备 / 曹操 Temporal Pressure Result

## 1. Verdict

> **PASS — 刘备 / 曹操已完成当前 12 个汉末三国固定 Entry 下的完整合法 temporal skeleton，v0.2-r2 继续通过语义/内容压力。**

No new Source field is required.

This is still **NOT** Godot/runtime implementation PASS and **NOT** final full-fidelity Character migration PASS.

---

## 2. Current exact coverage

### 刘备

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

Manifest:

`tests/fixtures/g4_02r1/t0_pressure/汉末三国/刘备-pressure/source.json`

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

Manifest:

`tests/fixtures/g4_02r1/t0_pressure/汉末三国/曹操-pressure/source.json`

Missing bindings inside this declared Han-World coverage are temporally incompatible; no top-level identity fallback may materialize the Character.

---

## 3. Shared World cuts now own same-year ordering

### 189

Current World cut freezes only:

- Han Lingdi already dead;
- central struggle already damaged court order;
- Dong Zhuo already controls emperor / central politics.

It **does not** pre-author individual Characters' next response.

This allows Cao Cao 189 to start as an experienced official/military actor under a newly transformed center without Source deciding his specific next action.

### 196

Current World cut freezes:

- Emperor already moved to Xu under Cao Cao's political-military protection/control environment;
- Lü Bu already seized Xiapi during the Xu-region rupture;
- Liu Bei already lost this core base and is in a fragile Xiaopei arrangement.

The World does not freeze the next conflict/result/affiliation chain.

### 200

Existing pressure cut remains:

- Sun Ce already dead;
- Sun Quan just took over Jiangdong;
- Cao Cao's eastern defeat of Liu Bei is already past for the Liu/Cao profiles;
- Liu Bei has entered Yuan Shao's network;
- the decisive current Cao-Yuan contest result is not yet past.

Principle reinforced:

> **Shared event ordering belongs to World Entry when multiple Characters depend on it. Character profiles consume that cut; they do not invent parallel timelines.**

---

## 4. Liu Bei earned-development ladder

### 184｜early person, not future ruler template

Current evidence can already make him distinctive through:

- low-resource family reality despite distant royal-line identity;
- maternal livelihood;
- study / early social network;
- attested interests;
- `少语言、善下人、喜怒不形于色`;
- youth haoxia association / early follower network.

Not yet earned:

- mature repeated-rebuild resilience;
- mature dependency/autonomy political technique;
- large territorial governance;
- ruler-level institutional reputation system.

### 189｜first military / office reality

Adds lived evidence from early war/office experience and direct friction between formal position and actual resources.

Still not a mature wandering political leader template.

### 196｜first major territorial-loss pressure

Current World reality now supports stronger semantics around:

- relationship credit as survival resource;
- group continuity after losing a core base;
- difference between political identity and actual military/resource control;
- preserving people/action space under fragile conditions.

This is still earlier than the later repeated-disruption pattern.

### 200｜repeated disruption / reaggregation now strongly evidenced

The Character can legitimately have stronger experience in:

- rebuilding after political/military disruption;
- entering stronger groups without automatically dissolving all own relationships;
- using long-lived credit and reputation as organizational continuity.

### 208｜mature mobile-group continuity

Long years of movement, dependence, loss and reorganization now justify a mature relational/organizational survival skill set.

Current southern pressure remains open; stable later territorial outcomes are not assumed.

### 214｜large regional base becomes current evidence

The key new lived dimension is no longer merely survival:

> **old network + new regional society + governance/institutional responsibility**

Large-area administration and integration can now legitimately enter the current profile.

### 220｜latest supported mature start

Han-Wei transition is already current reality. Liu Bei now has a large regional political organization and decades of earned experience.

But Source still does not pre-author his formal response, later war, or end-of-life personality.

---

## 5. Cao Cao earned-development ladder

### 184｜young official / early military actor

Current evidence supports:

- youthful cleverness / tactical calculation;
- renxia / unconventional risk-taking;
- early office and enforcement experience;
- current transition into larger military responsibility.

Not yet earned:

- mature north-wide organization;
- long-war logistics/talent systems;
- ruler-scale security psychology.

### 189｜experienced actor under central rupture

Adds more actual office/military experience and a higher real cost of action.

The World freezes the central rupture, not Cao Cao's specific response path.

### 196｜court + military + territorial organization

Emperor-at-Xu reality now makes it legitimate for Cao Cao to have materially stronger semantics around:

- political legitimacy + practical control;
- larger talent organization;
- territorial/military administration;
- internal control risk based on real prior conflict.

### 200｜mature large organization

Years of campaigns and political organization justify stronger personnel/resource integration and repeated adjustment under conflict.

The current major northern result remains open.

### 208｜large northern system under new regional pressure

Large-scale organization, logistics and talent systems are fully current evidence.

The negative control is important:

> **northern-scale success does not automatically transfer into perfect judgment under different geography, disease, transport, local society and coalition conditions.**

Current advantage is inertia, not result privilege.

### 214｜latest supported mature start

Long-running institutional regime operation, large-scale governance, personnel systems and cumulative age/war costs are all current evidence.

Later political forms and post-T0 transitions remain outside authority.

---

## 6. Cross-character early individuality

184 刘备 and 184 曹操 also pass blind semantic differentiation.

Without names or future state/faction labels:

```text
Profile A
= materially limited family resources
+ maternal livelihood
+ education / haoxia network
+ restrained visible affect
+ people-oriented early network

Profile B
= high-official family network
+ early formal office
+ enforcement/administrative experience
+ youthful tactical cleverness / risk-taking
+ institution/action-oriented experience
```

They do not collapse into `ambitious young leader`.

This is a second validation of:

> **same age / same historical crisis != same starting person**

---

## 7. Future-cue lint findings

During expansion from 184/200 pressure points to the full skeleton, several Runtime-visible negative explanations were found to contain overly specific future cues.

Examples included:

- naming a later response path merely to say it was not yet current;
- using later years as maturity comparisons inside an earlier profile;
- listing a highly history-shaped next affiliation/action while calling it optional.

These were repaired forward.

Current rule is stricter:

> **Runtime material should freeze past facts and current pressures; it should not enumerate canon-shaped next actions merely to demonstrate that the future is open.**

Repository searches confirm the specifically identified stale cue strings were removed.

---

## 8. Formal expectation evidence

`tests/fixtures/g4_02r1/t0_pressure/汉末三国/liu_cao_temporal_expectations.json`

The expectation matrix now records:

- exact valid bindings;
- unsupported Entry non-bindings;
- earned-development ladder for both Characters;
- 184 cross-character blind differentiation;
- no future-answer enumeration acceptance rule.

---

## 9. Structural verdict

> **v0.2-r2 remains structurally adequate after three historical Character pressures: 孙权, 刘备, 曹操.**

No r3 field expansion is required.

The design continues to support:

- thin top-level identity continuity;
- exact Entry-bound T0 profiles;
- later-earned semantics appearing only after lived evidence exists;
- closed temporal coverage;
- early individuality;
- no adult-stereotype backfill;
- no post-T0 canon/action cue leakage;
- Game-local future freedom after Final Create.

---

## 10. What remains before final Character fidelity PASS

Temporal ownership is now proven for the three Han Characters, but the current profile files are still **temporal skeleton / pressure content**, not the final faithful replacement for the original 7–10KB cards.

Remaining Han Character work:

1. map every substantive original Character chapter into the appropriate T0 profile(s):
   - personality;
   - capabilities / limitations;
   - behavior / decision logic;
   - relationships / autonomy;
   - expression;
   - knowledge / information boundary;
   - player takeover / T0 boundary;
2. preserve chapter depth without copy-pasting later evidence into early T0;
3. manual original ↔ migrated semantic sampling;
4. verify no substantive shrinkage;
5. only then count 刘备 / 曹操 / 孙权 as final v0.2-r2 fidelity evidence.
