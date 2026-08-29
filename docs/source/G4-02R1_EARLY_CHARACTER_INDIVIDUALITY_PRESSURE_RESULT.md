---
title: G4-02R1｜Early Character Individuality Pressure Result
status: semantic-content-pressure-pass
owner: GPT
created: 2026-08-29
scope: same-stage cross-character individuality
implementation_pass: false
final_asset_fidelity_pass: false
fixture: tests/fixtures/g4_02r1/t0_pressure/汉末三国
---

# G4-02R1｜Early Character Individuality Pressure Result

## 1. Verdict

> **PASS at semantic/content pressure level — future quarantine can coexist with early-character individuality.**

This closes the specific question:

> Two Characters at the same/similar developmental stage do **not** need to collapse into the same `child/adolescent` template merely because later canon is quarantined.

It does **not** mean the final Han Character set is complete, and it is not a Godot/runtime implementation pass.

---

## 2. Pressure pair

Same World Entry:

```text
189｜洛阳巨变
entry_id = t0-189-luoyang-crisis
```

Characters:

```text
孙权      ~7 years old
诸葛亮    ~8 years old
```

Historical/source basis used for this pressure:

- historical asset snapshot `sillytavern-assets@4a5364a...`;
- 《三国志》卷47 / 孙氏相关材料 for Sun-family military/official context;
- 《三国志》卷35 / 诸葛亮传 for Langya identity, father Zhuge Gui's Taishan office, and the imprecise `早孤` boundary.

Important uncertainty handling:

> `早孤` does not establish a sufficiently precise death date to assert that Zhuge Liang's father was definitely dead before the 189 Entry.

Therefore the pressure profile does not use paternal death as a deterministic differentiator.

---

## 3. What changed in Sun Quan 184 / 189

### 184

The previous profile mainly proved `not adult ruler leakage`.

It now also carries developmentally appropriate individuality through:

- active military/official household rhythm as a lived environment;
- attachment and familiar-caregiver dependence;
- attraction to older siblings/familiar adults' activity;
- response to strangers through familiar caregiver presence;
- sensitivity to disrupted sleep/eating/care routine and familiar people leaving.

The authored completion is intentionally toddler-scale. It does **not** encode political values, mature courage, delegation or future leadership.

### 189

The profile now differentiates Sun Quan through:

- a household affected by military service, office, movement, guests and retainers;
- attention to relational signals such as who obeys whom and which familiar adults remain reliable;
- a tendency to use familiar adults' reactions as the first filter for strangers/new environments;
- frustration when partly understood adult matters are dismissed without explanation;
- stress centered on which familiar people remain and where the household goes next.

These are starting dispositions, not historical claims about the adult Sun Quan.

---

## 4. Zhuge Liang 189 pressure profile

A pressure-only 189 Character package was added under:

`tests/fixtures/g4_02r1/t0_pressure/汉末三国/诸葛亮-pressure/`

Its differentiators are deliberately child-level and non-prophetic:

- official/literati family socialization rather than a military-retainer household center;
- greater dependence on familiar relatives in large unfamiliar adult groups;
- child curiosity around family stories, kinship terms, local origins, writing traces and household learning;
- conflicting adult explanations are taken back to a trusted elder rather than resolved through mature analysis;
- household disruption is felt first as disruption of familiar care/learning routine.

### Anti-retrofit correction performed during pressure

The first authored draft used an overly neat trait:

> attention to whether explanations are internally consistent.

Although not literally post-T0 history, that completion mirrored the famous adult Zhuge Liang's rational/organizational stereotype too cleanly.

It was rejected and rewritten.

This produces a new review principle:

> **No adult-stereotype backfill.** A childhood completion can fail even without explicit future facts if it was selected mainly because it elegantly predicts the known adult.

---

## 5. Blind differentiation review

Formal expectations:

`tests/fixtures/g4_02r1/t0_pressure/汉末三国/individuality_expectations.json`

Blind-review procedure:

1. remove names / aliases / adult titles / future-history references;
2. compare only pre-T0 ecology + authored starting disposition;
3. ask whether the two starting persons are still distinguishable;
4. ask whether each can plausibly grow into several materially different adults.

### Blind result

**PASS.**

Even with names and famous futures removed:

| Dimension | Profile A | Profile B |
|---|---|---|
| household ecology | active military/official movement, guests/retainers | official/literati/clan and household learning |
| primary social cue | familiar adults' reactions, who follows whom, who remains | familiar relatives, household explanation/learning relationships |
| stranger response | watches how trusted family treats the stranger | stays near trusted relations and joins later if comfortable |
| information handling | family reaction is first filter | conflicting reports are carried back to a trusted elder |
| disruption pressure | who is leaving / who still travels with household | who will care/teach / whether familiar routine continues |
| safe-context expression | more active/insistent on being included/explained to | may persist on a small question in familiar small-group context |

The pair is not interchangeable after age labels are removed.

---

## 6. Counterfactual-adult test

A starting disposition is acceptable only if it remains plausible when the reviewer pretends not to know the famous adulthood.

Current pair passes this check.

Neither profile requires its known adult outcome.

Examples of divergent trajectories that remain compatible with the starting seeds:

- Sun-family child can become more cautious, more rebellious, more domestic, more martial, more scholarly or more socially avoidant depending on lived history;
- Zhuge-family child can become a local scholar, conventional official, reclusive adult, practical household manager, risk-seeking traveler, emotionally driven actor or other path depending on lived history.

These are not probability targets; they demonstrate that the T0 seed does not encode a single adult destination.

---

## 7. Developmental-scale clarification

> **Individuality depth scales with developmental capacity and evidence.**

A two-year-old and a twenty-year-old both require individuality, but not the same kind.

For very young children, legitimate individuality may live mostly in:

- attachment;
- sensory/familiarity patterns;
- exploration vs withdrawal;
- response to routine disruption;
- imitation and sibling orientation;
- immediate frustration/comfort behavior;
- age-appropriate language and knowledge.

It is a fidelity failure to manufacture mature values or decision logic merely to make a toddler profile look rich.

Conversely, `generic toddler` is also a fidelity failure when the Source author can provide safe, non-prophetic starting distinctions.

---

## 8. Evidence tiers remain prose-level

Current v0.2-r2 structure remains sufficient.

No new JSON field is required for:

```text
attested pre-T0 evidence
reasonable inference
authored completion
deliberate blank
```

These are authoring/fidelity semantics and can remain in rich sections/notes until a real consumer needs machine structure.

No giant personality schema and no numeric differentiation score are introduced.

---

## 9. New migration/review rules

For every final Character T0 profile:

1. **Future leak check** — no post-T0 facts, later personality or adult stereotype backfill.
2. **Present individuality check** — age label cannot substitute for the person.
3. **Evidence check** — distinguish attested past from authored completion.
4. **Counterfactual-adult check** — completion remains plausible without knowing famous adulthood.
5. **Multi-future check** — starting seed supports materially different later personalities.
6. **Developmental-scale check** — depth is appropriate to age and actual lived evidence.

For sparse historical childhoods, authored completion is permitted and often desirable, but must remain reversible by Game-local lived history.

---

## 10. Current G4-02R1 consequence

```text
Sun Quan temporal isolation          = PASS
Sun Quan early individuality         = PASS for current pressure scope
same-stage cross-character pressure  = PASS
v0.2-r2 structural expressiveness    = PASS; no field expansion needed
Godot/runtime implementation         = NOT YET TESTED
final 2 World + 6 Character fidelity = NOT YET PASS
```

Next semantic/content work may continue to the Han full-fidelity layer and Liu Bei / Cao Cao temporal migration, while applying these individuality rules to every relevant T0 profile.
