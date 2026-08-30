---
title: G4-02R1｜Optional Temporal Scope Capability Clarification
status: semantic-clarification-current
owner: GPT
created: 2026-08-30
updated: 2026-08-30
base_contract: docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md
t0_addendum: docs/source/G4-02R1_T0_SCOPED_SOURCE_CONTRACT_ADDENDUM.md
governance_decision: Vibe-Coding/my world/architecture/source/G4_OPTIONAL_TEMPORAL_SOURCE_SCOPE_DECISION.md
---

# G4-02R1｜Optional Temporal Scope Capability Clarification

## 1. Clarification

The v0.2-r2 T0-scoped / post-T0 quarantine mechanism is **optional by authored need**.

It must not be interpreted as a requirement that every World Pack and every Character Card maintain a temporal profile matrix.

## 2. Character shape

`character_card.v0.2` keeps `t0_profiles` optional.

A Character that has no meaningful selectable temporal variants may:

```text
use top-level semantic_sections for its complete reusable starting semantics
+ omit t0_profiles
```

Such a Character must load normally and must not be made hard-incompatible merely because it has no `(world_asset_id, entry_id)` binding.

`no_world_coverage` / always-safe-only remains a distinguishable non-hard-blocking temporal result. It does not by itself grant every other kind of compatibility; it only means the temporal-coverage rule has no basis to block the Character.

## 3. World shape

A World that has no future-information separation need may keep its reusable semantics in top-level `semantic_sections`.

Entries may still exist for authored scenario/opening choices. Entry-scoped `semantic_sections` are only needed when content is genuinely scoped to that selected Entry/T0.

The existence of Entries does not itself mean historical quarantine is required.

## 4. Historical / multi-temporal case

When an asset genuinely has multiple temporal cuts and later authored material would leak future answers into an earlier start, the existing v0.2-r2 rules remain strict:

- exact Entry projection;
- exact Character profile binding;
- no fallback;
- closed per-World coverage after the Character declares any binding to that World;
- full-package fingerprint wider than selected Runtime visibility.

Han-era fixtures remain the primary real example.

## 5. Afterglow interpretation

The current Afterglow fixtures use one 1287 profile bound to all three authored Entries. That is valid authored compatibility evidence, not a universal requirement for fantasy/original settings.

Future Afterglow-like or other non-historical Characters may omit `t0_profiles` entirely when there is no real temporal variation to model.

## 6. No new classification field

Do not add `historical`, `temporal_mode`, `requires_quarantine`, family classification, or another global switch merely to distinguish the two cases.

The contract remains capability-shaped: use Entry/profile temporal structure only when the authored Source actually needs it.
