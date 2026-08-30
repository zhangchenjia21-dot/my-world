---
title: G4-02R1M1-IR01｜Optional Temporal Scope Evidence Correction
status: ready-for-agent
task_id: G4-02R1M1-IR01
type: independent-review-correction
owner: Codex
created: 2026-08-30
updated: 2026-08-30
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: 74d1fe8d93e527794db33d0280d76d16674ae1d7
governance_base: 14fb4d686c458c2a09a348e54088377f96655d65
parent_task: G4-02R1M1
independent_review_owner: GPT
owner_uat_required: false
---

# TASK｜G4-02R1M1-IR01｜Optional Temporal Scope Evidence Correction

Owner: **Codex**

Formal Code Base: `74d1fe8d93e527794db33d0280d76d16674ae1d7`

Governance Base: `14fb4d686c458c2a09a348e54088377f96655d65`

Return ceiling:

> **READY FOR INDEPENDENT REVIEW**

## 1. Why this correction exists

GPT Independent Review found no current production-mechanism defect in G4-02R1M1, but found one explicit acceptance evidence gap and one newly clarified product boundary that should be regression-proven before closing G4-02R1.

Evidence gap:

- Sun Quan 249 exact binding is proven;
- Sun Quan 263 incompatibility is proven;
- the task explicitly required **Sun Quan 280 incompatibility** as well, but the focused test does not currently assert 280 separately.

Product clarification:

- T0-scoped / post-T0 quarantine is an **optional capability**, not a mandatory mode for every World/Character;
- non-temporal/original assets must be able to use rich top-level semantics without an artificial T0 profile matrix.

Read before work:

- `AGENTS.md`
- `docs/tasks/G4-02R1M1_SOURCE_V0_2_R2_MECHANISM_CORRECTION_TASK.md`
- `docs/source/G4-02R1_T0_SCOPED_SOURCE_CONTRACT_ADDENDUM.md`
- `docs/source/G4-02R1_OPTIONAL_TEMPORAL_SCOPE_CAPABILITY_CLARIFICATION.md`
- `docs/source/G4-02R1_R2_MECHANISM_IMPLEMENTATION_EVIDENCE.md`

Governance authority:

- `Vibe-Coding/my world/architecture/source/G4_OPTIONAL_TEMPORAL_SOURCE_SCOPE_DECISION.md`

## 2. Expected shape

This should be an **evidence/test correction**.

Do not modify production Source behavior unless the new tests expose a real defect. If a production change appears necessary, stop and report the concrete failure before broadening scope.

## 3. Required acceptance

### A. Complete Han closed temporal coverage assertions

Use the unchanged frozen full-fidelity fixtures and production `Source合同公开接口` path.

Explicitly prove at minimum:

```text
刘备
220 -> exact_profile_match
229 -> temporal_incompatible
263 -> temporal_incompatible
280 -> temporal_incompatible

曹操
214 -> exact_profile_match
220 -> temporal_incompatible
229 -> temporal_incompatible
263 -> temporal_incompatible
280 -> temporal_incompatible

孙权
249 -> exact_profile_match
263 -> temporal_incompatible
280 -> temporal_incompatible
```

Do not infer these by year arithmetic. Each result must come from the production exact-binding mechanism against real fixture Entry IDs.

### B. Non-temporal Character capability

Add a **task-owned synthetic v0.2 Character fixture** whose complete reusable starting semantics live in top-level `semantic_sections` and which **omits `t0_profiles` entirely**.

Prove through the production loader/projection seam:

- package validates and loads;
- rich top-level content is preserved;
- no fake profile is created;
- `project_character_t0(...)` returns `no_world_coverage` rather than hard incompatibility;
- projection keeps the top-level semantics;
- no latest/nearest/family/history inference occurs;
- no new `historical`, `temporal_mode`, `requires_quarantine`, or equivalent global flag is introduced.

The synthetic fixture is evidence only; do not modify the frozen 2 World + 6 Character fixtures.

### C. Non-temporal World capability

Add a **task-owned synthetic v0.2 World fixture** with rich top-level `semantic_sections` and authored Entries whose `semantic_sections` are empty (or otherwise contain no temporal partitioning requirement).

Prove:

- package validates and loads;
- exact Entry selection still works for scenario/opening identity;
- selected projection preserves the complete top-level rich semantics;
- no artificial historical/future-quarantine classification is required;
- no new global temporal-mode field is introduced.

This test exists to prove that Entry choice and temporal quarantine are not the same concept.

### D. Existing temporal quarantine still holds

Re-run the existing real-fixture projection assertions and prove the correction did not weaken:

- Han early Entry excludes later World material;
- Han early Character excludes later profile material;
- Afterglow three 1287 Entries still exact-match their authored shared profile bindings;
- cross-world zero coverage remains non-hard-blocking;
- fingerprint coverage remains broader than selected visibility;
- optional portrait behavior remains unchanged.

### E. Regression

At minimum run:

- `tests/g4_02r1/Source_v0_2_r2_机制现实测试.gd`
- `tests/g4_02r1/Source_v0_2_r2_负向测试.gd`
- the new IR01 focused test(s)
- G4-03 Source Library reality/tamper/restart regression
- G4-05 Composition/Application Wizard regression relevant to compatibility review
- Godot editor parse/compile check

If production code remains unchanged, a new full non-headless Windows screenshot pass is not required solely for this evidence correction; record that no GUI code changed and cite the prior G4-02R1M1 Windows evidence. If production/UI code changes, rerun the applicable Windows evidence.

## 4. Forbidden

Do not:

- redesign Source semantics;
- add a universal historical/non-historical enum or boolean;
- require every Character to have `t0_profiles`;
- require every World Entry to have temporal semantic sections;
- change frozen 2 World + 6 Character semantic fixtures;
- add profile fallback;
- add same-family restriction;
- implement G4-06;
- resume/close G4-05;
- broaden into Context/Prompt refactor.

## 5. Return protocol

Return either:

> **READY FOR INDEPENDENT REVIEW**

or

> **BLOCKED**

Include:

- Start HEAD;
- Final HEAD;
- commits;
- files changed;
- exact commands;
- explicit Sun Quan 280 evidence;
- non-temporal Character evidence;
- non-temporal World evidence;
- existing temporal-quarantine regression;
- G4-03/G4-05 regression result;
- whether any production code changed;
- known limitations.

Do not close G4-02R1 yourself. GPT owns the final Independent Review verdict.
