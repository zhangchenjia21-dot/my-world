---
title: G4-02R1｜2 World + 6 Character Package-Shape Stability Decision
status: semantic-package-shape-frozen-for-mechanism
owner: GPT
created: 2026-08-29
contract: v0.2-r2
han_audit: docs/source/G4-02R1_HAN_FAMILY_JOINT_FULL_FIDELITY_AUDIT.md
afterglow_audit: docs/source/G4-02R1_AFTERGLOW_FAMILY_JOINT_FULL_FIDELITY_AUDIT.md
---

# G4-02R1｜2 World + 6 Character Package-Shape Stability Decision

## Decision

> **PASS — v0.2-r2 Source package shape is semantically stable enough to freeze for Codex mechanism implementation.**

This is a **semantic/contract freeze**, not Godot implementation PASS and not final G4-02R1 closure.

Codex may now implement the frozen mechanism. Codex does not own further semantic compression or redesign of these assets.

---

## 1. Evidence actually exercised

The contract has now survived two intentionally different real asset families.

### Family A｜汉末三国

Pressure exercised:

- one rich historical World;
- 12 authored Entries across a long time range;
- post-T0 pretrained canon risk;
- exact event-relative T0 cuts;
- three Characters with different valid lifetimes;
- early-childhood / young-adult / mature-ruler profiles;
- same-year differentiation;
- earned personality/capability growth;
- hard incompatibility after death through closed profile coverage;
- no canon convergence privilege.

Result:

```text
World
= top-level always-safe semantic_sections
+ selected Entry semantic_sections

Character
= thin identity continuity
+ exact matching T0 profile semantic_sections
```

No universal birth/death ontology, fate state machine or giant historical schema was required.

### Family B｜诸界余辉

Pressure exercised:

- one large fixed-1287 fantasy World;
- magic/metaphysics/gods/planes/laws/institutions/material life;
- explicit GM-only backstage truth;
- three same-T0 Entries representing different situations rather than different histories;
- three detailed Characters at the same T0;
- attributes/skills/spell familiarity tables;
- elite-but-fallible knowledge;
- relationship hooks and private history;
- open fantasy future without a pretrained canon route.

Result:

The same package primitives remained sufficient:

```text
semantic_sections
section_id / section_type / disclosure / content_path
entries[].semantic_sections
t0_profiles[].bindings
t0_profiles[].semantic_sections
optional portrait
player_character_supported
```

No universal nation/god/spell/skill/personality ontology was required.

---

## 2. What changed under real pressure

The pressure process did cause corrections, but the distinction matters.

### Structural correction before final freeze

Han temporal pressure required the v0.2-r2 addendum:

- Entry-scoped World sections;
- Character `t0_profiles`;
- explicit `(world_asset_id, entry_id)` bindings;
- closed per-World profile coverage;
- no fallback to later/nearest/latest profile.

That **was** a legitimate package-shape change because the first real historical consumer proved the need.

### Semantic clarification after shape existed

Fantasy pressure clarified:

> same-T0 multi-Entry binding means starting compatibility, not recommended location/scene fit.

No new manifest field was required.

### Content fidelity correction after shape existed

Fantasy no-shrinkage audit found observable appearance and explicit change conditions had been summarized too aggressively in the first migrated profiles.

The fix was richer Markdown content, not schema expansion.

This is positive stability evidence:

> **later pressure is now producing content corrections and semantic clarifications, not new global fields.**

---

## 3. Frozen v0.2-r2 World shape

Canonical semantic shape:

```json
{
  "schema_version": "world_pack.v0.2",
  "asset_id": "...",
  "asset_type": "world_pack",
  "version": "...",
  "display_name": "...",
  "catalog_summary": "...",
  "world_instructions": "...",
  "gm_instructions": "...",
  "semantic_sections": [
    {
      "section_id": "...",
      "section_type": "open semantic hint",
      "title": "...",
      "disclosure": "gm_reference | gm_private",
      "content_path": "...md|txt"
    }
  ],
  "entries": [
    {
      "entry_id": "...",
      "display_name": "...",
      "opening_seed": "...",
      "semantic_sections": []
    }
  ],
  "authored_assets": []
}
```

Rules frozen with it:

- `source_material` remains deleted;
- section content is UTF-8 Markdown/TXT first-class Source bytes;
- `section_type` is open vocabulary, not a closed ontology;
- package-local `section_id` must be unique;
- `gm_reference != player-known`;
- `gm_private` is explicit backstage truth;
- all declared bytes enter exact generation fingerprint;
- selected World Source projection uses top-level + selected Entry sections only;
- unselected Entry content remains fingerprinted but ordinary-Runtime-ineligible.

---

## 4. Frozen v0.2-r2 Character shape

Canonical semantic shape:

```json
{
  "schema_version": "character_card.v0.2",
  "asset_id": "...",
  "asset_type": "character_card",
  "version": "...",
  "display_name": "...",
  "catalog_summary": "...",
  "semantic_sections": [
    {
      "section_id": "...",
      "section_type": "identity | open semantic hint",
      "title": "...",
      "disclosure": "gm_reference | gm_private",
      "content_path": "...md|txt"
    }
  ],
  "t0_profiles": [
    {
      "profile_id": "...",
      "display_name": "...",
      "bindings": [
        {"world_asset_id": "...", "entry_id": "..."}
      ],
      "semantic_sections": []
    }
  ],
  "player_character_supported": true
}
```

Optional authored portrait appears only when real Source bytes exist.

Rules frozen with it:

- stable Character identity is not duplicated per T0;
- top-level material must be safe across supported T0s;
- exact matching T0 profile supplies time-specific rich meaning;
- no latest/nearest/later/full-life fallback;
- if any profile binds World W, missing selected Entry binding inside W = hard incompatibility;
- no binding to World W at all preserves the cross-world always-safe-only route for later Compatibility policy;
- same-T0 multiple Entries may share one profile when all are genuinely compatible;
- binding is not current location, opening appearance or recommendation score;
- relationship hooks may preserve pre-T0 past, never current relationship state;
- Character knowledge boundary is not live Game knowledge state;
- complex skill/spell tables may remain prose/table semantics until a real deterministic consumer pulls out a narrower Domain contract.

---

## 5. Frozen ownership boundary

### Source owns

- reusable authored starting meaning;
- stable logical identity;
- exact Source generation;
- authored T0 compatibility;
- authored reference/private disclosure;
- pre-T0 history and reusable relationship hooks;
- starting capability/personality/knowledge boundaries.

### Game-local Reality owns

- current location;
- current relationship/trust/favor;
- current injury/condition/magic load;
- current inventory/equipment;
- current knowledge and misinformation;
- opening appearance / current scene participation;
- new learned magic;
- new personality dimensions, beliefs, institutions or other lived semantic growth;
- post-T0 history.

### Program owns

- stable IDs and references;
- safe path and manifest integrity;
- exact fingerprinting;
- deterministic selected projection;
- closed-coverage incompatibility;
- atomic/durable persistence and later materialization mechanics.

### Model owns within Game-local semantic freedom

- open-ended meaning and development produced by lived history;
- new semantic dimensions not exhaustively enumerated by Source;
- interpretation and narrative generation within current authority/evidence.

The model does **not** mutate reusable Source, global contract or physical SQLite schema during play.

---

## 6. Explicitly rejected architecture

Do not implement:

- giant universal Character schema;
- universal skill/spell ontology merely to parse current tables;
- nation/god/relationship/faction schema without a real deterministic consumer;
- `source_material` dumping ground;
- same-family automatic compatibility;
- binding-as-location/recommendation;
- historical fate/convergence score;
- future outcome whitelist/blacklist;
- complete manifest dump into Prompt;
- required placeholder portraits;
- auto-import/compression of legacy prose by Codex.

---

## 7. Mechanism handoff threshold

The following semantic questions are now sufficiently frozen for implementation:

1. manifest parsing/validation;
2. rich content-file path safety;
3. exact fingerprint coverage;
4. World selected Entry projection;
5. Character exact T0 profile selection;
6. explicit binding lookup;
7. closed per-World coverage incompatibility;
8. disclosure metadata preservation;
9. optional portrait absence;
10. stable identity / eligibility preservation.

Codex may implement these as mechanism.

Codex must **not** infer or redesign:

- which prose belongs to which section;
- which Character should bind which Entry;
- whether a private fact should become reference;
- which spell/skill deserves a machine enum;
- how historical personality should be summarized.

Those remain Meaning-owner decisions.

---

## 8. G4-02R1 status consequence

Semantic design and real-asset pressure phase:

> **PASS / FROZEN FOR MECHANISM.**

Overall G4-02R1:

> **IMPLEMENTATION PENDING — NOT CLOSED.**

Next owner:

> **Codex for narrow v0.2-r2 loader/validator/fingerprint/projection/compatibility mechanism correction.**

After Codex returns `READY FOR INDEPENDENT REVIEW`, GPT must verify:

- assertions prove selected projection rather than fixture existence;
- private/unselected bytes remain fingerprinted but do not leak into wrong projection;
- no fallback behavior exists;
- real full-fidelity fixtures load without semantic compression;
- G4-03 library/version/tamper invariants still hold;
- G4-05 preserved Wizard/Composition mechanics regress cleanly;
- Compatibility Review surfaces temporal incompatibility correctly;
- no hidden same-family restriction was introduced.

Only then may G4-02R1 close and G4-05 resume.
