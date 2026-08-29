---
title: my world｜G4-02R1 World / Character Source Semantic Re-audit
status: implementation-pending
task_id: G4-02R1
type: semantic-design-correction
owner: GPT
current_execution_owner: Codex
created: 2026-08-29
updated: 2026-08-29
repository: zhangchenjia21-dot/my-world
branch: main
historical_real_asset_repo: zhangchenjia21-dot/sillytavern-assets
historical_real_asset_sha: 4a5364a042e41f4c8a69621fc4467956a78703c0
codex_active: true
semantic_contract: v0.2-r2-frozen
semantic_phase: pass-frozen-for-mechanism
current_subtask: G4-02R1M1
mechanism_packet: docs/tasks/G4-02R1M1_SOURCE_V0_2_R2_MECHANISM_CORRECTION_TASK.md
mechanism_packet_commit: 238dfecb6bdfc056a4ceb4115b247e8a8f18b674
formal_code_base: f1950d615864fd0e780764fa1a50cfcbf1a5c507
governance_base: 6ac202eca576496e93eb0f4b317ef5b0bffc7399
---

# TASK｜G4-02R1｜World / Character Source Semantic Re-audit

Semantic owner: **GPT**  
Current execution owner: **Codex**

## Outcome

Using real `汉末三国` and `诸界余辉` assets as primary evidence, prove and implement the smallest Source contract that preserves authored richness, separates Source from Game-local live truth, prevents post-T0 canon/personality leakage, preserves Character individuality, and leaves post-T0 development open to the model.

The semantic/full-fidelity phase is complete and frozen. The task is **not closed** until the frozen mechanism is implemented and passes GPT Independent Review.

---

## Current state｜2026-08-29

### Semantic / real-asset phase

> **PASS / FROZEN FOR MECHANISM**

Completed evidence includes:

- real-source semantic audit against 2 World + 6 Character;
- v0.1 semantic adequacy verdict: **FAIL**;
- v0.2 rich-section base contract freeze;
- Game-local evolvable semantics decision;
- T0-scoped Source / Post-T0 Canon Quarantine decision;
- v0.2-r2 addendum;
- early Character individuality addendum;
- fixed-T0 multi-Entry binding clarification;
- full `汉末三国` World + 刘备 / 曹操 / 孙权 packages;
- Han temporal isolation, same-stage differentiation, closed temporal coverage and joint no-shrinkage audit;
- full `诸界余辉` World with 20 `gm_reference` + 4 `gm_private` rich sections and 3 fixed-1287 Entries;
- full 莉维娅 / 阿德里安 / 杜恩 fixed-1287 rich Character packages;
- fantasy-family disclosure / knowledge / complex-ability / no-shrinkage audit;
- cross-family 2 World + 6 Character package-shape stability decision.

Canonical freeze decision:

`docs/source/G4-02R1_CROSS_FAMILY_PACKAGE_SHAPE_STABILITY_DECISION.md`

Freeze commit / Formal Code Base:

`f1950d615864fd0e780764fa1a50cfcbf1a5c507`

### Current implementation phase

> **G4-02R1M1 — Source v0.2-r2 Mechanism Correction**

Packet:

`docs/tasks/G4-02R1M1_SOURCE_V0_2_R2_MECHANISM_CORRECTION_TASK.md`

Packet commit:

`238dfecb6bdfc056a4ceb4115b247e8a8f18b674`

Owner: **Codex**

Return ceiling:

> **READY FOR INDEPENDENT REVIEW**

GPT resumes as Independent Review owner after Codex returns.

---

## Canonical semantic sources

Codex must read current versions of:

- `docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md`
- `docs/source/G4-02R1_T0_SCOPED_SOURCE_CONTRACT_ADDENDUM.md`
- `docs/source/G4-02R1_T0_CHARACTER_INDIVIDUALITY_ADDENDUM.md`
- `docs/source/G4-02R1_FIXED_T0_MULTI_ENTRY_CHARACTER_BINDING_CLARIFICATION.md`
- `docs/source/G4-02R1_REAL_ASSET_V0_2_R2_MIGRATION_SPEC.md`
- `docs/source/G4-02R1_HAN_FAMILY_JOINT_FULL_FIDELITY_AUDIT.md`
- `docs/source/G4-02R1_AFTERGLOW_FAMILY_JOINT_FULL_FIDELITY_AUDIT.md`
- `docs/source/G4-02R1_CROSS_FAMILY_PACKAGE_SHAPE_STABILITY_DECISION.md`
- governance `architecture/source/G4_SOURCE_SEMANTIC_OWNERSHIP_AND_REAUDIT_DECISION.md`
- governance `architecture/source/G4_GAME_LOCAL_EVOLVABLE_SEMANTICS_DECISION.md`
- governance `architecture/source/G4_T0_SCOPED_SOURCE_AND_POST_T0_CANON_QUARANTINE_DECISION.md`

Historical `docs/source/G4-02R1_REAL_ASSET_V0_2_MIGRATION_SPEC.md` remains superseded design evidence only.

---

## Frozen invariants

### Richness

> **Preserve meaning; do not force prose into a schema forest.**

Long authored Markdown/TXT sections are first-class Source bytes. Codex must not compress the real fixtures to fit implementation.

### T0 authority

> **Do not show the model a post-T0 answer and then ask it to forget that answer.**

```text
Source Package Total Content
!= Selected T0 Projection
!= Game-local Reality
!= Runtime Relevant Set
!= Model-visible Working Set
```

World projection:

```text
top-level always-safe semantic_sections
+ exact selected Entry.semantic_sections
```

Character projection:

```text
top-level always-safe semantic_sections
+ exact matching T0 profile.semantic_sections
```

Never fallback to latest / nearest / later / complete-life biography.

### Closed per-World Character coverage

If a Character declares any profile binding to World W:

```text
exact selected Entry binding exists → compatible
missing selected Entry binding      → temporal incompatibility
```

If a Character has zero bindings to selected World W, this rule does **not** create hard incompatibility. Preserve the always-safe-only / no-exact-profile state for later Compatibility policy.

### Binding is compatibility, not location

Same-T0 multi-Entry bindings do not assert current location, opening appearance, current contract, or recommendation score.

### Disclosure != Character knowledge

`gm_reference` is GM-authored reference, not player-known.

`gm_private` is explicit backstage Source truth. Character knowledge still requires a real knowledge source.

### Exact generation

All declared package bytes affect exact fingerprint, including unselected Entry/profile and `gm_private` bytes.

> **Fingerprint coverage != Runtime visibility.**

### Model freedom

No convergence force and no divergence force. Do not add fate scores, anti-history state machines, output quotas, personality transition tables or action whitelists.

### Complex abilities

Rich skill/spell tables remain Source semantics until a real deterministic mechanic consumer requires a narrower Domain contract. Do not invent a universal skill/spell ontology in G4-02R1M1.

### Game-local evolvability

Source schema is not the Living World's possibility ceiling. Post-T0 Game-local semantics may grow while reusable Source/global contract/physical SQLite schema remain protected.

---

## Full-fidelity evidence roots

```text
tests/fixtures/g4_02r1/full_fidelity/汉末三国/
tests/fixtures/g4_02r1/full_fidelity/诸界余辉/
```

Required real packages:

```text
World x2
- 汉末三国：天下未定
- 埃瑟维亚：诸界余辉

Character x6
- 刘备
- 曹操
- 孙权
- 莉维娅·塞兰
- 阿德里安·维尔克
- 杜恩·石痕
```

These packages are frozen semantic evidence and must not be rewritten by Codex to make tests pass.

---

## Current mechanism task requirements

G4-02R1M1 must implement and prove:

- v0.2 World/Character manifest validation/loading;
- nested safe rich-content paths;
- package-wide section/profile/binding uniqueness rules;
- exact fingerprint across all declared bytes;
- exact selected World Entry projection;
- exact Character T0 profile projection;
- no fallback behavior;
- closed temporal coverage incompatibility;
- cross-world zero-coverage distinction;
- disclosure metadata preservation;
- optional portrait absence;
- real full-fidelity fixture loading;
- G4-03 Managed Source Library regressions;
- preserved G4-05 Wizard/Composition regressions;
- Windows/Godot engineering evidence.

Evidence target:

`docs/source/G4-02R1_R2_MECHANISM_IMPLEMENTATION_EVIDENCE.md`

---

## G4-03 / G4-04 / G4-05 disposition

```text
G4-03 Managed Local Source Library   PASS / CLOSED
G4-04 Multi-Game / Game Library      PASS / CLOSED
G4-05 Asset-only New Game Wizard     REWORK / HOLD
G4-05R1                              SUPERSEDED / DO NOT EXECUTE
G4-06+                               HOLD
```

G4-03 remains closed unless G4-02R1M1 exposes a concrete corrected-contract regression; repair forward if needed.

The accepted G4-05 Wizard/Composition mechanics remain provisional engineering evidence and must regress cleanly. G4-05 does not resume or close inside G4-02R1M1.

---

## Remaining exit criteria

G4-02R1 closes only when:

1. semantic/full-fidelity phase remains frozen and unchanged;
2. Codex implements only the frozen v0.2-r2 mechanism;
3. real 2 World + 6 Character fixtures validate/load unchanged;
4. selected Entry/profile projection is exact and no fallback exists;
5. unsupported Han Character/Entry combinations hard-fail by authored closed coverage;
6. zero-coverage cross-world combinations are not converted to a hidden family block;
7. fingerprint-vs-visibility behavior is proved;
8. tamper/missing rich files fail loud;
9. G4-03 regressions pass;
10. preserved G4-05 Wizard/Composition regressions pass;
11. Codex returns `READY FOR INDEPENDENT REVIEW`;
12. GPT Independent Review independently verifies the code, assertions and real evidence.

G4-07 later retains Owner UAT for anti-convergence + Narrative richness + Character individuality. No Owner UAT is required for this mechanism-only subtask.
