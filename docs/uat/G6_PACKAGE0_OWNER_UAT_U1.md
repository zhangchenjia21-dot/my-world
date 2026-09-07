# G6 Package 0｜Owner UAT U1

Date: 2026-09-07  
Owner: Owner  
Product-code artifact under UAT: `782daf65348f484d636d46260ac2374559cf554d`  
Later main changes during UAT were governance-only and did not alter the tested product bytes.

## Verdict

**PACKAGE 0 OWNER UAT COMPLETE — CORRECTIONS REQUIRED**

- MW-018 People: **PRODUCT FAIL / REVISION REQUIRED**
- MW-019 Five Recommended Actions: **PRODUCT FAIL / REVISION REQUIRED**
- MW-015 Character + Important Experiences: prior Product PASS remains historical evidence, but a **post-PASS semantic finding is reopened for correction before V0 Core Closure**.

No new feature Package is authorized to skip these corrections. After Package 0 corrections + focused Owner re-UAT close, current Roadmap v4.3 places UAT Observability / Debug Mode v0.1 next.

---

## MW-018｜People findings

### UAT-018-01｜Known/off-screen person can be ineligible for People despite explicit player knowledge

Observed real play:

- the accepted game had already established `钟繇` as a person known to the protagonist;
- Owner then submitted a turn explicitly recalling `钟繇`;
- People Surface still did not contain a `钟繇` card;
- meanwhile two incidental soldiers encountered in the current scene did receive People cards.

### Root-cause audit

Current MW-018 packet constrains People updates to:

> `Only current receipt-bound actors are eligible for People update in that turn.`

The current identity receipt is centered on exact current semantic/GM-span actor bindings. Therefore a person who is already player-known but is not a current receipt-bound actor may never be exposed to the People Curator as a legal `actor_ref` candidate. This can prevent the model from even deciding whether that person deserves a card.

This is narrower than frozen People product semantics, which explicitly allow a card for a person the player has actually learned about through accepted play and do not require direct/current physical encounter.

### Required correction direction

Keep exact identity and no-name-guessing, but broaden the **eligible exact person-reference seam** so People can consider player-known/off-screen persons established in the accepted Player+GM history when they are safely resolved to a stable Game-local actor identity.

At minimum, correction architecture must address:

- current accepted Player references to an already-known stable actor;
- current accepted GM references to an off-screen but real person;
- same-turn newly established off-screen person when the GM/world semantics legitimately establish that person's existence;
- no Program display-name matching/fuzzy lookup;
- Player assertion alone must not create World Truth or mint a real actor when identity/existence is unresolved;
- unresolved identity remains no People update rather than a guessed card;
- model still decides persistent memory value; Program does not add encounter-count/name/importance heuristics;
- incidental scene actors must not receive cards merely because they are current receipt candidates.

### Product acceptance for re-UAT

A later player-authored accepted turn that clearly establishes or recalls a player-known off-screen person can produce/update the correct stable People card when exact identity is legitimately available, while incidental low-value actors may remain uncarded if the model judges them not worth persistent memory.

---

## MW-019｜Recommendation findings

### UAT-019-01｜Recommendation chips contain full long-form actions

Current chips are crowded, hard to scan, visually incomplete, and consume too much horizontal space.

Required interaction correction:

```text
short recommendation direction / label
→ click
→ detailed editable action draft placed in PlayerInput
→ never auto-send
```

The recommendation display should answer "what kind of action is this?"; the composer draft can contain the detailed natural-language action.

### UAT-019-02｜Five recommendations can be one plan split into five sentences

Observed set behaved like sequential fragments of one approach rather than five independently selectable next actions.

Required correction:

- five outputs must be five standalone alternative next-action directions;
- do not implement a Program category/diversity rule engine;
- prompt/model semantics should express independent alternatives and allow genuine divergence;
- later Character-guided Recommendations will influence protagonist-consistent tendency, but does not replace this basic independence requirement.

### UAT-019-03｜Recommendation/composer UI is too small and cramped

Owner found the current text/control sizing uncomfortable for long-form play.

Required bounded readability correction:

- increase practical font/control/padding/spacing for recommendation area and composer;
- preserve desktop-first layout and free-form input priority;
- this revision is readability/playability correction, not final visual-polish scope.

### Product acceptance for re-UAT

Owner can scan five concise independent directions quickly, click one to obtain a useful detailed editable draft, freely ignore/edit it, and comfortably read/use the recommendation + composer area.

---

## MW-015｜Post-PASS semantic finding

### UAT-015-01｜Important Experiences over-generates into per-turn recap

During the same real play session, `重要经历` behaved like a rolling/per-turn summary rather than sparse protagonist milestones.

This conflicts with the frozen meaning:

- Character = "现在的我是谁";
- Important Experiences = selected meaningful history explaining "我是怎样走到现在的".

Required semantic correction before V0 Core Closure:

- ordinary turns should very often produce **no Important Experience update**;
- model must reserve milestones for events that materially shape identity/life trajectory/lasting situation;
- no Program turn thresholds, keyword rules or importance scores.

Product follow-up **not yet silently authorized**:

- a separate `简要回顾` / recent recap could be useful;
- whether `重要经历` remains a top-level tab or becomes a Character sub-section remains a product IA decision and is not changed by this UAT record alone.

---

## Next route

```text
Package 0 UAT complete
→ shape + implement bounded MW-018 revision
→ shape + implement bounded MW-019 revision
→ correct MW-015 milestone over-generation before V0 Core Closure
→ Independent Review(s)
→ focused Owner re-UAT
→ Package 0 close
→ UAT Observability / Debug Mode v0.1
```

All correction work must preserve current core invariants: free-form action primary, no omniscient disclosure, exact identity over guessed names, Save/Restore/Regenerate currentness, and no new generic framework merely to fix these findings.
