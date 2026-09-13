# MW-033｜Integration Verification

Status: **REVIEWED INTEGRATION COMPLETE**

## Reviewed lineage

```text
Formal Code Base
  e876e217f0220fdc6a577cd0b52143dc8d5b6b5c

Original Task Packet / Starting HEAD
  dc6c46d952ba0b63a8f713e9388896969cd71f7d

Original MW-033 Implementation
  d6ebe8ca2ac23ec589ca266c104470888e6daa4f

Original Submitted Candidate
  32cb5325b251c81ac8d883d5921edababe0d4cbf

IR1 finding / correction lineage
  73253db312c429a62bf610eed10f3a570b20b2d6
  b232063d46d95a75a28979cfbe796608dd1fd9b9
  9697d6398ebbf059a4067205ce935d705ff292c4

R1 Implementation
  03a226396e14baf1ee780d9b145a72e148e6187e

R1 Submitted Candidate
  4bd29c13be6da8e3e8c3b299c76122a1de97ba68

Independent Re-review / Integration Tip
  80fcd17c26758f0e97ba9f9b6580f878aac13ae1
```

Independent re-review verdict:

> **ENGINEERING PASS_WITH_NOTES**

## Integration method

Immediately before integration:

- implementation `main` remained exactly `e876e217f0220fdc6a577cd0b52143dc8d5b6b5c`;
- reviewed task branch tip was exactly `80fcd17c26758f0e97ba9f9b6580f878aac13ae1`;
- governance `Vibe-Coding/main` remained at Current Status v18.2, explicitly requiring MW-033 R1;
- no conflicting implementation-main advance or superseding architecture decision existed.

`my-world/main` was advanced by **non-force fast-forward** to the reviewed MW-033 R1 lineage. No force push, merge rewrite or conflict resolution occurred.

This document is post-integration evidence only and does not change reviewed product behavior.

## Integrated product/architecture outcome

Narrative continuation now has one globally budgeted working-set owner under `src/context`.

For ordinary post-Opening continuation, current canonical owners contribute request material and Context performs only deterministic request composition / structural priority / whole-block selection / budget accounting / safe diagnostics.

The integrated v0.1 working set includes, when current and budgeted:

- minimum durable Game/World/GM source authority;
- current accepted Conversation + current Player attempt;
- current Character;
- current Open Threads;
- current World / Knowledge / Agency / Evolution projection;
- factual Inventory;
- current Public mechanics;
- Important Experiences;
- player-known People;
- T0/source/NPC authored background;
- literary style reference.

Context does not become World/Knowledge/People/Threads/Inventory/Mechanics truth owner.

## Frozen structural tiers

```text
P0 REQUIRED
- system/protocol
- current Player attempt/input mode
- minimum Game/World identity + World/GM instructions

P1 CURRENT CONTINUITY
- latest accepted Conversation
- current Character
- current Open Threads
- current World/Knowledge/Agency/Evolution
- factual Inventory / current mechanics
- remaining recent accepted Conversation under budget

P2 DURABLE BACKGROUND
- Important Experiences
- player-known People
- T0/source/NPC background
- literary style reference
```

The reviewed R1 correction ensures `game.opening_supplement` and selected Entry `opening_seed` are **P2 atomic T0 background**, not inseparable P0.

Selected Entry identity remains P0. First Opening remains on its unchanged full frozen Game-local setup path.

## Budget behavior

Current validated Runtime Settings provide the authoritative model context capacity.

Frozen v0.1 safe input rule:

```text
safe input bytes = floor(context_token_ceiling * 0.80)
```

Reviewed evidence proves:

- 256k ceiling `262144` → safe input `209715` bytes;
- 1m ceiling `1048576` → safe input `838860` bytes;
- final `JSON.stringify(messages).to_utf8_buffer().size()` is the authoritative final accounting;
- exact budget boundary is accepted;
- one-byte-over optional block is omitted whole;
- P0 overflow fails loud before Narrative Provider start;
- accepted Conversation Turns are selected atomically and rendered chronologically;
- no Narrative output `max_tokens` cap was introduced.

## R1 source-tier evidence

Large Opening supplement fixture:

```text
body ~240 KB UTF-8
256k continuation = PASS, body omitted whole
1m continuation   = PASS, body included whole
```

Large selected Entry opening seed fixture:

```text
body ~240 KB UTF-8
256k continuation = PASS, body omitted whole
1m continuation   = PASS, body included whole
```

In both cases:

- P0 Game/Entry/World identity survives;
- current Character / Thread / World survives;
- no partial source fragment is emitted;
- First Opening still receives the complete original full frozen payload.

Small supplement/seed remain usable as P2 when budget permits.

## Currentness / authority evidence

Reviewed tests prove:

- current Character / People / Threads / Experiences survive transcript roll-off through current curation authority;
- People context is explicitly player-known information and does not create World actor truth;
- UI hide/recover preferences change zero model Context bytes;
- stale/nonmatching World records remain excluded by accepted-hash currentness;
- Restore removes displaced future Conversation/curation/World contribution;
- Regenerate replacement invalidates old GM-bound World contribution;
- reopen derives fresh current messages without persisted Provider-message/working-set cache;
- OOC semantics and durable accepted text remain exact;
- G3-03/G3-05 now pass stronger raw/stale-leak boundaries rather than forbidding all legitimate Game Context.

## Test / build evidence

Final R1 focused:

- **206 checks / 0 failures**;
- real Provider calls: **0**.

Final relevant regression manifest:

- **49 / 49 suites pass**;
- no retained failing suite.

Five pre-existing suites retain the same bounded ObjectDB/resource-at-exit warning family; no suppression or new blocking behavior was found.

Final build:

- Godot `4.7.2.stable.official.ed1daf0bf` import PASS;
- fresh Windows export PASS;
- `run-game.ps1 -ValidateExportOnly` PASS;
- final R1 PCK SHA256: `ac6bf6b7d6625a16b84683031b8605141ad16e95b81e68240c04ffd2ec1363f3`.

## Preserved worktree artifacts

The task worktree intentionally retained previously documented Godot import/UID sidecars and tracked fixture normalization noise. R1 recorded before/after hashes for all 24 known artifacts and found them unchanged. They are not a reviewed-product integration blocker and should not be bulk-cleaned merely for status aesthetics.

## Remaining notes

1. **Live long-session quality remains unproven.** Real Provider calls for MW-033/R1 are 0. Structural correctness does not by itself prove a live GM feels coherent over long sessions.
2. **P2 omission is intentionally non-semantic.** Useful background can be omitted under pressure. Whether later G7 needs semantic retrieval/source recall must be decided from evidence, not pre-emptive embeddings/vector-memory work.
3. **Legacy teardown warnings remain non-blocking debt.**

## Post-integration state

MW-033 is now:

> **ENGINEERING PASS_WITH_NOTES / REVIEWED INTEGRATION COMPLETE**

This is not Product PASS and does not close G7 Package 8.

Per the current route, there is no immediate Owner UAT solely for MW-033. The next mainline action is a GPT evidence/architecture audit for the next bounded G7 Package-8 slice, using MW-033 diagnostics and the proven machine-schema failure patterns from G4–G6 rather than pre-committing a universal memory or Structured Output platform.