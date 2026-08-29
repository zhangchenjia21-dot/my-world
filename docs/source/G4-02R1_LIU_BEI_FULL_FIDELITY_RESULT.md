---
title: G4-02R1｜刘备 Full-Fidelity Character Result
status: semantic-content-pass-candidate
owner: GPT
created: 2026-08-29
source: zhangchenjia21-dot/sillytavern-assets@4a5364a042e41f4c8a69621fc4467956a78703c0
source_blob: 20c1ff5d01797bdd619644dba37f5eb7dbc2fa8d
contract: v0.2-r2
fixture: tests/fixtures/g4_02r1/full_fidelity/汉末三国/刘备
---

# G4-02R1｜刘备 Full-Fidelity Character Result

## Verdict

> **PASS at semantic/content candidate level.**

The full candidate covers all seven valid Han Entries and preserves the original Character Card's major semantic categories while preventing later-life backfill.

This is not loader/runtime implementation PASS and not final G4-02R1 PASS.

## Original semantic coverage

Original major sections are preserved/re-expressed across exact T0 profiles:

- identity anchor → top-level continuity + each T0 current identity;
- personality core / contradictions → each profile's evidence-backed current personality;
- abilities / limitations → only abilities earned by current T0;
- decision / behavior logic → current-scale choices, not timeless adult policy;
- relationship style / autonomy → trust, shared experience, dependency and boundaries remain explicit;
- language / expression → restrained public style retained without literary stereotype;
- knowledge / information boundary → current contacts/experience only, no future canon;
- opening/T0/history boundary → exact World Entry bindings + open future.

No category was reduced to `summary + traits + drives`.

## Temporal growth result

The candidate demonstrates a genuine ladder:

```text
184
= early poverty / study / haoxia network / restrained affect

189
= early public/military responsibility tests relationship credit

196
= first major loss of political base; relationship credit becomes survival resource

200
= repeated disruption/rebuilding evidence; mature dependence-vs-agency judgment emerges

208
= long-lived group continuity + mature alliance/weak-position adaptation

214
= large-region governance and old-group/new-region integration become real

220
= mature political identity under a new legitimacy environment
```

Later capabilities do not appear in 184 merely because external history knows Liu Bei eventually develops them.

## Individuality result

184 remains a specific young Liu Bei through:

- limited material family resources despite distant royal-line identity;
- maternal livelihood;
- study/social background;
- recorded interests;
- early `少语言、善下人、喜怒不形于色` evidence;
- haoxia social network.

This preserves individuality without relying on later state formation.

## Relationship / expression / knowledge preservation

The migration explicitly retains three categories that the old v0.1 conversion had mostly lost:

1. relationship autonomy — followers/partners remain independent actors, not automatic loyalty;
2. expression — restrained/face-preserving style without forcing literary crying or moral slogans;
3. knowledge boundary — other groups' plans remain inference; external future history has no authority.

## Closed coverage

Bindings exist only for:

`184 / 189 / 196 / 200 / 208 / 214 / 220`.

Within `world.han_end.unsettled_realm`, any later Entry therefore resolves to temporal incompatibility under the frozen closed-coverage rule. There is no identity-only resurrection fallback.

## Remaining caution

The current rich profiles are faithful semantic reconstructions, not verbatim duplication of every sentence in the old card. Final joint Han audit must still sample original prose against current profiles and verify that no nuance was lost while distributing meaning across time.

Next Han work: full rich 曹操, then full rich 孙权, then joint original↔migrated audit.