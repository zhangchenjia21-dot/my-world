# G4-08S0 — Expansion Pack v0.1 Semantic / Product Freeze

Status: **ACTIVE — GPT**  
Parent: **G4-08 Expansion Pack v0.1 + First Real Runtime Vertical**  
Owner: **GPT**  
Execution agents: **none yet**

## 1. Purpose

G4-07 proved that World + Character alone is a worthwhile playable vertical. G4-08 now introduces the third Primary Source type: Expansion Pack.

Before Codex implements mechanism, GPT must freeze what Expansion means and what one real Expansion must prove.

## 2. Existing authority

Frozen before this task:

- Expansion Pack is a reusable Primary Source Asset, distinct from World Pack and Character Card.
- Game Creation Composition allows `0..N` Expansion selections.
- Source Library uses exact immutable generations.
- Final Create materializes selected Source into Game-local reality/provenance.
- Existing Games must not be silently rewritten by later Source updates.
- G4-08 requires a **real observable Runtime / Context / mechanic effect**; manifest/binding existence alone is insufficient.
- arbitrary code plugins, generic external UI contribution schema, and large feature-toggle forests remain deferred.

## 3. Semantic questions to freeze

GPT must define, at minimum:

1. **Expansion identity and scope**
   - what is authored Source versus Program-owned capability;
   - what minimal fields/sections belong to Expansion v0.1;
   - what is intentionally *not* generalized yet.

2. **Composition / compatibility semantics**
   - how one or more exact Expansion generations are selected;
   - whether duplicate/overlapping capability selections are allowed;
   - how incompatibility is represented without hidden family guessing.

3. **Final Create / provenance**
   - what exact Expansion data is pinned/materialized;
   - what durable Game-local state is created from an Expansion;
   - how Source ancestry remains distinct from lived Runtime state.

4. **Runtime effect contract**
   - one bounded Program-owned capability must consume the selected Expansion;
   - the effect must be observable in actual play, not only in DB rows or prompt text;
   - Save / Main Menu / Continue must preserve the effect and its state.

5. **Context boundary**
   - what Expansion-authored material enters model-visible Context;
   - what runtime state enters Context;
   - no full-Source dump and no second live truth.

6. **First real Expansion**
   - choose exactly one concrete Expansion for the first vertical;
   - keep it intentionally small, cross-cutting, and easy to distinguish from the same Game without the Expansion;
   - define Product UAT evidence for G4-09.

## 4. Anti-scope

Do not use G4-08 to build:

- arbitrary GDScript/plugin execution from Source;
- generic mod sandbox;
- external declarative UI contribution schema;
- Creator/authoring suite;
- online store/workshop;
- generic rules engine;
- full G5 world simulation;
- full G6 RPG UI host;
- giant universal asset schema shared by World/Character/Expansion.

## 5. Required outputs

Before any Codex/Kimi implementation task becomes active:

1. canonical G4-08 Expansion v0.1 semantic decision in Governance;
2. one named real Expansion and exact acceptance story;
3. minimal package shape / compatibility rules;
4. runtime capability ownership and persistence boundary;
5. mechanism Task Packet routed to Codex;
6. UI task only if the first capability genuinely requires player-facing interaction, routed separately to Kimi.

## 6. Exit

This task ends when GPT can issue a bounded mechanism packet whose acceptance is:

```text
same playable World + Character route
+ exact selected real Expansion
→ Final Create pins/materializes it
→ real Runtime consumes it
→ player can observe a gameplay difference
→ real DeepSeek Context reflects the correct Expansion state
→ Save / Continue preserves it
→ no Expansion route remains unchanged
```

Return state after semantic freeze:

```text
G4-08M1 ACTIVE — CODEX
```

Do not claim G4-08 PASS until mechanism, integration evidence, Independent Review, and the G4-09 product vertical have been completed as required by the roadmap.
