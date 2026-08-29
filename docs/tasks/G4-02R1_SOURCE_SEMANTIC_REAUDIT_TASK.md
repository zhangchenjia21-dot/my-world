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
mechanism_packet_commit: 540d2fd6ecd9d01257848398dfa40e7f7b769727
formal_code_base: f1950d615864fd0e780764fa1a50cfcbf1a5c507
governance_base: e2423cb50800129fc0bff6d1edc31701023f0f28
---

# TASK｜G4-02R1｜World / Character Source Semantic Re-audit

Semantic owner: **GPT**  
Current execution owner: **Codex**

## Outcome

Use real `汉末三国` and `诸界余辉` assets to prove and implement the smallest Source contract that preserves authored richness, separates Source from Game-local live truth, prevents post-T0 canon/personality leakage, preserves Character individuality, and leaves post-T0 development open to the model.

The semantic/full-fidelity phase is complete and frozen. G4-02R1 is **not closed** until the frozen mechanism is implemented and passes GPT Independent Review.

---

## Current state｜2026-08-29

### Semantic / real-asset phase

> **PASS / FROZEN FOR MECHANISM**

Completed evidence:

- v0.1 semantic adequacy: **FAIL**;
- v0.2 rich-section base contract frozen;
- T0-scoped Source / Post-T0 Canon Quarantine frozen as v0.2-r2;
- Game-local evolvable semantics frozen;
- early Character individuality addendum frozen;
- fixed-T0 multi-Entry Character binding clarified;
- full `汉末三国` World + 刘备 / 曹操 / 孙权 packages and joint temporal/no-shrinkage audit;
- full `诸界余辉` World + 莉维娅 / 阿德里安 / 杜恩 packages and joint disclosure/knowledge/complex-ability/no-shrinkage audit;
- final cross-family 2 World + 6 Character package-shape stability decision.

Canonical freeze decision:

`docs/source/G4-02R1_CROSS_FAMILY_PACKAGE_SHAPE_STABILITY_DECISION.md`

Formal Code Base / semantic freeze commit:

`f1950d615864fd0e780764fa1a50cfcbf1a5c507`

### Current implementation phase

> **G4-02R1M1 — Source v0.2-r2 Mechanism Correction**

Formal packet:

`docs/tasks/G4-02R1M1_SOURCE_V0_2_R2_MECHANISM_CORRECTION_TASK.md`

Packet commit:

`540d2fd6ecd9d01257848398dfa40e7f7b769727`

Governance Base:

`e2423cb50800129fc0bff6d1edc31701023f0f28`

Owner: **Codex**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

GPT resumes as Independent Review owner after Codex returns.

---

## Canonical semantic authority

Read current versions of:

- `docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md`
- `docs/source/G4-02R1_T0_SCOPED_SOURCE_CONTRACT_ADDENDUM.md`
- `docs/source/G4-02R1_T0_CHARACTER_INDIVIDUALITY_ADDENDUM.md`
- `docs/source/G4-02R1_FIXED_T0_MULTI_ENTRY_CHARACTER_BINDING_CLARIFICATION.md`
- `docs/source/G4-02R1_REAL_ASSET_V0_2_R2_MIGRATION_SPEC.md`
- `docs/source/G4-02R1_HAN_FAMILY_JOINT_FULL_FIDELITY_AUDIT.md`
- `docs/source/G4-02R1_AFTERGLOW_FAMILY_JOINT_FULL_FIDELITY_AUDIT.md`
- `docs/source/G4-02R1_CROSS_FAMILY_PACKAGE_SHAPE_STABILITY_DECISION.md`
- governance `MY_WORLD_架构_CURRENT.md`
- governance `MY_WORLD_总体规划路线图_CURRENT.md`
- governance `MY_WORLD_CURRENT_STATUS.md`
- governance Source supporting decisions under `architecture/source/`.

Historical `docs/source/G4-02R1_REAL_ASSET_V0_2_MIGRATION_SPEC.md` is superseded design evidence only.

---

## Frozen invariants

### Richness

> **Preserve meaning; do not force prose into a schema forest.**

Long authored Markdown/TXT sections and rich tables remain first-class Source bytes. Do not compress them to fit implementation.

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
top-level always-safe sections
+ exact selected Entry sections
```

Character projection:

```text
top-level always-safe sections
+ exact matching T0 profile sections
```

Never fallback to latest / nearest / later / complete-life biography.

### Temporal compatibility

If a Character declares any profile coverage for selected World W:

```text
exact Entry binding exists → compatible
missing selected Entry binding → temporal incompatibility
```

If the Character has zero coverage for W, do not invent a same-family hard block; preserve a distinguishable no-exact-profile / always-safe-only state.

### Disclosure != knowledge

`gm_reference` and `gm_private` are GM-facing Source disclosure classes, not automatic player-known or Character-known state.

### Fixed-T0 multi-Entry binding

One profile may bind multiple same-T0 Entries. Binding means authored starting compatibility, not current location, opening appearance, relationship or recommendation score.

### Exact generation

Fingerprint covers all declared bytes even when a file is unselected/private and excluded from the selected Runtime projection.

> **Fingerprint coverage != Runtime visibility.**

### Game-local evolvability

> **Source schema is not the possibility ceiling of the Living World.**

Post-T0 Game-local semantics may evolve while Source/global contract/physical SQLite schema remain protected. Existing canonical Domains win over duplicate generic truth. Local semantic evolution must be durable and Timeline/Save/Restore reversible.

---

## Real full-fidelity evidence

```text
World x2
- tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定/
- tests/fixtures/g4_02r1/full_fidelity/诸界余辉/埃瑟维亚/

Character x6
- 刘备
- 曹操
- 孙权
- 莉维娅
- 阿德里安
- 杜恩
```

These are the primary acceptance consumers for G4-02R1M1. Their frozen semantic Markdown/TXT content must not be edited merely to make code pass.

---

## Remaining exit criteria

G4-02R1 closes only when:

1. Codex implements the frozen v0.2-r2 mechanism without semantic redesign;
2. all 2 World + 6 Character full-fidelity packages validate/load unchanged;
3. exact World Entry and Character T0 profile projection is proven by content/inventory assertions, not counts only;
4. unsupported temporal combinations fail by explicit authored coverage, not fallback;
5. zero-coverage cross-world combinations are not converted into hidden family restrictions;
6. fingerprint-vs-visibility behavior is proven, including unselected/private mutations;
7. missing/tampered rich files fail loud;
8. optional portrait behavior is correct without fake Source assets;
9. G4-03 immutable-library invariants remain green;
10. provisionally accepted G4-05 Wizard/Composition invariants remain green;
11. GPT Independent Review inspects the real implementation/assertions and returns PASS.

G4-05 remains **REWORK / HOLD** until this gate passes.  
`G4-05R1_REAL_ASSET_FIDELITY_CORRECTION_TASK.md` remains **SUPERSEDED / DO NOT EXECUTE**.  
G4-06+ remains **HOLD**.
