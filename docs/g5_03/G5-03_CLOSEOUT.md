# G5-03 NPC / Faction Agency — Closeout

Status: **ENGINEERING PASS / CLOSED**  
Capability-Anchor: **G5-03**  
Closed by: GPT  
Date: 2026-09-04

## 1. Outcome achieved

G5-03 now has a real independent-actor path instead of NPCs being only Player-triggered narrative props.

The closed capability is:

```text
accepted ordinary player Narrative
→ Agency dirty opportunity
→ post-Narrative semantic lane settles
→ standalone Selector evaluates latest world
→ 0..4 current stable NPCs selected
→ actor-scoped independent requests
→ own material + own Knowledge + own history only
→ optional durable actor actions
→ Player foreground always wins
```

Stable actor eligibility is no longer equivalent to “has a Character Card”. The current Game-local stable actor system covers:

```text
Guaranteed Source NPC
+ automatic Source-backed NPC
+ creation-authored Game-local NPC without Card
+ runtime Narrative-materialized NPC without Card
```

All use Program-owned local identity and participate in the same Knowledge / Agency / persistence boundaries.

## 2. Accepted implementation chain

- G5-03M1 Multi-Actor Agency v0.3 — ENGINEERING PASS / CLOSED.
- G5-03M2A Stable Actor Registry Foundation — IR#2 PASS / CLOSED.
- MW-001 Runtime Narrative Actor Materialization (legacy planning ref G5-03M2B) — IR#1 PASS / CLOSED.

Current review evidence:

- `docs/g5_03/G5-03M2A_INDEPENDENT_REVIEW_IR2.md`
- `docs/g5_03/MW-001_INDEPENDENT_REVIEW_IR1.md`

## 3. Faction decision

**No separate Faction-agency implementation slice is required to close G5-03 now.**

This is a deliberate consumer-first decision, not a claim that Faction semantics will never exist.

Current product/governance evidence already says:

- Faction identity/agency must not be built merely for symmetry with NPCs;
- Faction/shared knowledge was explicitly deferred in G5-02;
- the roadmap delegated the post-M1 decision on a second Faction slice to GPT based on a real consumer;
- no current Game-local Faction identity, private Faction Knowledge, or concrete Faction action consumer exists that would justify a separate platform seam.

Building a Faction actor system now would therefore introduce speculative identity/knowledge/agency architecture before its first consumer, contrary to the project rule:

> Vertical before platform. Consumer before infrastructure.

Faction-level behavior remains available to be pulled out later by a concrete consumer — most plausibly G5-04 pressure/priority-driven world evolution or a later product surface — if that consumer proves that stable NPC agency plus durable world consequences are insufficient.

This deferral must not be interpreted as silently treating every Faction as an NPC or granting shared Faction knowledge.

## 4. Protected behavior after closeout

Do not reopen without concrete regression or a real new consumer:

- Model Freedom First / Visible Narrative First;
- Narrative acceptance independent of semantic/agency extraction;
- standalone Agency Selector after semantic terminal;
- ordinary accepted turn marks dirty, selector start consumes dirty once;
- Player foreground invalidates remaining uncommitted background work;
- committed actor actions remain durable;
- selector fan-out 0..4;
- separate actor-scoped execution requests;
- actor-private material / Knowledge / history;
- display name never authoritative identity;
- Program owns stable actor IDs;
- runtime Narrative actors are current only under exact accepted turn/hash;
- no runtime mutable Source lookup;
- Save/Restore preserves stable actor identity/history;
- no automatic Knowledge from registry membership or actor materialization.

## 5. Product evidence boundary

Engineering closure does **not** manufacture the missing real-provider proof.

Parent real G5-03 Provider proof remains:

`PENDING / EXTERNAL PROVIDER UNAVAILABLE`

No Provider switch is authorized merely to create evidence.

## 6. Next

Proceed to **G5-04 Event / Priority-driven World Evolution architecture shaping**.

Do not start implementation until GPT has shaped the product semantics and smallest first-consumer architecture. G5-04 must not become a universal simulation engine, minute-by-minute NPC simulator, or speculative Faction platform.
