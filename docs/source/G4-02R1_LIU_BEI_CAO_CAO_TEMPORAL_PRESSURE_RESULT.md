---
title: G4-02R1｜刘备 / 曹操 Temporal Pressure Result
status: semantic-content-pressure-pass
owner: GPT
created: 2026-08-29
scope: 184-vs-200 early/earned Character pressure
implementation_pass: false
final_asset_fidelity_pass: false
fixture: tests/fixtures/g4_02r1/t0_pressure/汉末三国
---

# G4-02R1｜刘备 / 曹操 Temporal Pressure Result

## 1. Verdict

> **PASS at semantic/content pressure level.**

The current v0.2-r2 T0 design can represent both:

- strong early individuality from attested pre-T0 evidence;
- later personality/ability growth that becomes legal only after the Character has actually lived the relevant history.

No new schema field is required by this pressure.

This is not a Godot/runtime implementation pass and not final full-fidelity migration for either Character.

---

## 2. Pressure shape

Two T0s were used for each Character:

```text
184  early / pre-mature political career
200  materially later / repeatedly tested political-military actor
```

Pressure fixtures:

- `刘备-pressure/`
- `曹操-pressure/`
- `liu_cao_temporal_expectations.json`

The purpose is to falsify a common failure mode:

> The same full-life Character description is copied into every T0 and only the current title/year is changed.

---

## 3. Liu Bei result

### 184

The profile remains rich without later-life backfill because the historical source already supplies strong early evidence:

- early poverty / maternal livelihood;
- study under Lu Zhi and relationship with Gongsun Zan;
- stated interests in horses, music and clothing;
- taciturn public style, ability to lower himself socially, restrained visible affect;
- youth association with haoxia and an initial network enabled by merchant support.

These create a distinct young Liu Bei without relying on later state formation, repeated territorial loss or mature ruler reputation.

### 200

By 200, multiple additional dimensions become legitimately earned:

- repeated disruption and rebuilding;
- experience entering stronger patrons' political-military networks;
- stronger evidence that personal relationships and reputation can preserve group continuity;
- more mature sensitivity to the difference between temporary dependence and complete loss of own group agency.

The current pressure cut inherits the already-past fact that Cao Cao has defeated Liu Bei in the Xu direction and Liu Bei has entered Yuan Shao's network, while the decisive Cao-Yuan outcome remains open.

### Temporal lesson

`resilience after repeated political/military loss` is not a timeless Liu Bei trait owned by every T0.

It is:

```text
not yet earned in 184
→ increasingly evidenced through later lived history
→ legal in 200
```

---

## 4. Cao Cao result

### 184

The profile remains distinct using early evidence only:

- youthful cleverness / tactical calculation;
- renxia / unconventional and risk-taking behavior;
- prior service as Luoyang Northern Commandant, Dunqiu magistrate and yilang;
- early direct exposure to law enforcement and government execution;
- the new Yellow-Turban-era military responsibility.

The profile explicitly withholds later north-China integration, large-scale logistics/talent systems and ruler-level security psychology.

### 200

By 200, years of war, administration and organization justify materially stronger dimensions:

- large-scale organization and personnel integration;
- combining court legitimacy, administrative machinery and military force;
- multi-front priority judgment;
- increased sensitivity to organizational loss-of-control risk based on actual political/military experience;
- earned ability to revise tactics and resource allocation after repeated campaigns.

The profile inherits the already-past eastern defeat of Liu Bei but does not know the current major northern contest's result.

### Temporal lesson

The mature `control / talent integration / political legitimacy + real power` pattern is not a magical childhood essence.

It is a later structure built on top of real earlier dispositions and then transformed by years of governance and war.

---

## 5. Cross-character 184 differentiation

Blind semantic review also passes.

Even with names and future faction/state identities removed:

### Profile A

- distant royal-line identity but materially limited family resources;
- maternal livelihood and social mobility gap;
- education + haoxia social network;
- restrained public affect;
- people-oriented early network formation.

### Profile B

- high-official family network;
- early entry into formal office;
- direct enforcement/administrative experience;
- youthful opportunism, cleverness and higher risk tolerance;
- institution/action-oriented early experience.

They do not collapse into a generic `ambitious young leader` profile.

This reinforces the current individuality rule:

> Same age / same chaotic world / both future famous leaders still require different present selves.

---

## 6. Same-year cut findings

The pressure also confirms that some Character states cannot be inferred from a year alone.

### 200 is now strong enough for this pressure

The existing World 200 conversion cut already states:

- Sun Ce is dead;
- Sun Quan has just taken over Jiangdong;
- the decisive current northern contest has not yet been decided.

Primary chronology places Cao Cao's eastern defeat of Liu Bei earlier in that year before the decisive Cao-Yuan outcome.

Therefore the current pressure can safely use:

```text
Cao Cao already defeated Liu Bei in Xu direction
Liu Bei already entered Yuan Shao's network
major Cao-Yuan outcome still open
```

### 184 / 189 / 196 still need exact final-package wording

For final profiles, the following must remain conservative until each cut is fully authored:

- whether a first Yellow-Turban campaign result is already past at 184;
- which early Liu Bei offices/movements are already complete by the exact 189 cut;
- Liu Bei's exact Xuzhou / Lü Bu position at the selected 196 cut;
- whether Cao Cao's flight from Dong Zhuo / raising troops is already past or still an open action at 189.

These are content-authoring issues, not schema gaps.

---

## 7. Death / compatibility closure

Current valid Entry coverage remains:

### Liu Bei

```text
184 / 189 / 196 / 200 / 208 / 214 / 220 = compatible candidates
229+ = incompatible
```

### Cao Cao

```text
184 / 189 / 196 / 200 / 208 / 214 = compatible candidates
220+ = incompatible
```

Final packages must explicitly encode only the supported exact bindings; no always-safe resurrection fallback.

---

## 8. Structural verdict

> **v0.2-r2 survives this second Character temporal pressure.**

No new field is needed.

The pressure specifically supports:

- top-level thin identity continuity;
- exact T0 profile material;
- later earned semantics appearing only in later profiles;
- closed per-World temporal coverage;
- present individuality without future canon;
- no adult-stereotype backfill.

---

## 9. Remaining work

Before these Characters count as final fidelity evidence:

1. create profiles for every valid authored Entry, not only 184/200 pressure points;
2. resolve 184/189/196 exact temporal cuts conservatively;
3. preserve full original personality/capability/behavior/relationship/expression/knowledge semantics across the appropriate T0s;
4. compare original card ↔ final v0.2-r2 package for substantive shrinkage;
5. only then freeze the exact implementation-facing package shape.
