---
title: G4-02R1M1 Source v0.2-r2 Mechanism Implementation Evidence
status: implementation-in-progress
task: G4-02R1M1
formal_code_base: f1950d615864fd0e780764fa1a50cfcbf1a5c507
governance_base: e2423cb50800129fc0bff6d1edc31701023f0f28
start_head: 34c4d80acbdc3eed24cad9d8c9e5552941d1869a
---

# G4-02R1M1 Source v0.2-r2 Mechanism Implementation Evidence

## 1. Pre-implementation responsibility matrix

| Concern | Owner | Mechanism seam | Explicit non-owner |
|---|---|---|---|
| Source meaning, section ownership, T0 bindings | Frozen GPT semantic fixtures | Read exactly as declared | Codex does not rewrite or infer prose/bindings |
| Manifest shape and hard boundary validation | Source L0/L2 | v0.1-preserving v0.2-r2 validator | No literary scoring or closed `section_type` ontology |
| Declared bytes and exact generation | Source L1 | safe reads plus deterministic SHA-256 | Runtime visibility does not narrow fingerprint coverage |
| Selected World projection | Source L2/L3 | top-level plus exact selected Entry | No later/nearest Entry fallback |
| Selected Character projection | Source L2/L3 | top-level plus exact bound T0 profile | No latest/nearest/later/full-life fallback |
| Temporal compatibility | Source L2/L3 | exact / zero-world-coverage / temporal-incompatible | No same-family restriction or location recommendation |
| Immutable managed generations | G4-03 existing Library | copy every contract-owned declared file and revalidate | No Library redesign or Source writeback |
| Wizard review | G4-05 existing Composition | exact re-resolve plus v0.2 temporal state check | No Game DB, Provider, materialization, or G4-06 |

## 2. Pre-implementation state / failure matrix

| Input/state | Required result | Mutation |
|---|---|---|
| valid v0.1 package | historical projection and fingerprint remain stable | none |
| valid v0.2-r2 package | rich validated package with all declared content loaded | none |
| exact World Entry | top-level plus only that Entry sections | none |
| exact Character binding | exact-profile state and only that profile sections | none |
| Character covers World but not Entry | temporal-incompatible state; Wizard review blocks | none |
| Character has zero coverage for World | distinguishable always-safe-only state; no family block | none |
| unselected/private bytes change | fingerprint changes; unrelated selected projection remains excluded | task fixture only |
| missing/unsafe/unreadable declared file | fail loud before publication/projection | none |
| duplicate section/profile/binding | fail loud deterministically | none |
| Library staged copy/restart/tamper | preserve append-only/current/exact fail-loud invariants | task-owned Library only |

## 3. Implementation and execution evidence

To be completed after focused implementation and Windows/Godot validation.
