---
title: G4-02R1｜Fixed-T0 Multi-Entry Character Binding Clarification
status: current-semantic-contract-clarification
owner: GPT
created: 2026-08-29
contract: v0.2-r2
applies_to: world.ashtervia.afterglow
---

# G4-02R1｜Fixed-T0 Multi-Entry Character Binding Clarification

## Decision

For a World that exposes multiple Entries at the **same authored T0**, Character `t0_profiles[].bindings` express **authored starting compatibility at that T0**, not “recommended scene”, “likely location”, or “best narrative fit”.

Therefore, when one fixed-T0 Character profile is valid at all same-T0 Entries, it binds all of them even if the legacy Character Card names only one or two natural opening situations.

For `world.ashtervia.afterglow`, all three current Entries are断界历 1287 starting cuts:

```text
t0-1287-ovista
t0-1287-border-route
t0-1287-public-works
```

莉维娅·塞兰、阿德里安·维尔克、杜恩·石痕 all exist as valid 1287 Character Sources and have no authored existence/temporal contradiction with any of these three cuts. Their single 1287 profile therefore binds all three Entries.

## Why this clarification is necessary

The v0.2-r2 closed-coverage rule says:

```text
Character declares any binding to World W
→ exact selected Entry binding required
→ missing binding = hard temporal incompatibility
```

If a migration used a legacy “natural opening” suggestion as the binding set, a harmless recommendation would accidentally become a hard Compatibility Review prohibition.

Example:

- 莉维娅 naturally fits the 奥维斯塔联合学宫 Entry especially well;
- this does **not** mean a Game beginning on a border route or public-works site cannot select her as the Player Character or Guaranteed NPC;
- the Game-local creation/opening process may establish why she is there, so long as it does not rewrite her pre-1287 Source past without authority.

## Binding is not location ownership

A profile binding does not assert:

- the Character is physically present at that Entry location before Final Create;
- the Character must appear in the opening scene;
- the Character has accepted a specific contract;
- the Character already knows the Player;
- the Character is currently healthy, equipped, employed, trusted, allied, or hostile.

Those are Game-local starting-composition / materialization / opening facts, not reusable Source truth.

## Where recommendations belong

Natural opening fit stays in rich prose as non-binding GM guidance, for example:

- 莉维娅: 联合学宫访学 / 公共术式异常 / research-review situations;
- 阿德里安: 护卫、外交、遗迹队伍 / combat-training or honor conflicts;
- 杜恩: 边境商路 / dangerous-route guidance / public-works survey and escort.

These suggestions may influence Compatibility Review explanation or opening composition later, but they do not create hard incompatibility by themselves.

## Guardrail

Do not generalize this into “all Characters bind all Entries”.

A missing binding remains correct when there is a real authored incompatibility, such as:

- Character not yet born / already dead at that Entry;
- Entry cut predates a required identity or lived-history state;
- mutually exclusive world-state premise;
- explicit Source incompatibility.

The rule is only:

> **Do not misuse temporal/source compatibility bindings as a recommendation or location-preference system.**
