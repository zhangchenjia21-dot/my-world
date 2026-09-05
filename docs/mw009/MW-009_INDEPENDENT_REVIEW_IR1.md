# MW-009 Independent Review — IR#1

Work Item: **MW-009 — Player-Safe Runtime Side Panels**  
Capability Anchor: **G5-06 Runtime → UI Projection**  
Revision: **1**  
Review Round: **IR#1**  
Implementer: **Zcode + GLM-5.3-flash**  
Reviewer: **GPT**  
Implementation / Evidence SHA: `c2805e816d8bcda73b7bc662a2fe091e55daf0af`  
Result: **ENGINEERING PASS / CLOSED**

## 1. Review basis

Reviewed against:

- `docs/tasks/MW-009_PLAYER_SAFE_RUNTIME_SIDE_PANELS_TASK.md`;
- `Vibe-Coding/my world/architecture/world/G5_PLAYER_SAFE_RUNTIME_UI_PROJECTION_V0_1_DECISION.md`;
- actual implementation diff at `c2805e8`;
- actual projection device / public interface / Shell consumer code;
- actual focused test source `tests/mw009/玩家安全侧栏投影测试.gd`;
- implementation evidence committed with the candidate.

No blocker was found.

## 2. Verified authority boundary

The implementation establishes an explicit whitelist disclosure seam rather than passing omniscient `world_state` into presentation code.

The projection object contains only:

```text
success
player_display_name
player_profile_name
world_display_name
world_entry_name
known_facts[]
```

The following are not present in the player-safe projection object:

- other actors' Knowledge Provenance;
- raw `semantic_turns_by_index` consequences;
- Agency actions;
- World Evolution events;
- GM/source instructions;
- Literary Style Reference;
- Source IDs/fingerprints;
- local IDs/hashes/mutation metadata;
- Public-d20 control/proposal material.

This satisfies the frozen rule:

> Disclosure is owned by the projection boundary, not by presentation widgets.

## 3. Verified dynamic knowledge semantics

`known_facts` is derived only from current valid Player Character Knowledge Provenance:

```text
valid living_world schema
+ valid knowledge record
+ source turn/hash matches current accepted Conversation
+ knower_id == current Player Character local_character_id
```

Invalid/stale/ambiguous material fails closed. There is no fallback to raw World truth.

The result is bounded to eight facts, deterministic, chronological, and exact-string de-duplication conservatively keeps the newest occurrence. No Provider summarization or semantic clustering was added.

## 4. Verified lifecycle/currentness

The Shell refreshes the safe projection at the existing lifecycle seams required by the frozen architecture:

1. Game activation / reopen;
2. semantic-lane terminal, after Player Character Knowledge may have changed;
3. Restore / progress switch.

Agency and World Evolution commits do not directly trigger disclosure refresh because those truths are not automatically player-safe.

Restore and regenerate/replacement currentness are enforced by the same accepted-turn/hash principle already used by G5 World Context projection.

## 5. Verified real consumer

The existing `PlayerPanelHost` / `WorldSurfaceHost` are used directly.

The Player panel consumes safe Player identity only. The World panel consumes safe World/Entry identity plus bounded Player Character known facts. The UI receives the already-safe projection object and does not inspect raw Runtime state.

No new Character Sheet, Journal, Map, Inventory, Faction UI, ViewModel framework, event bus, Player Knowledge database, SQLite schema or Provider request was introduced.

## 6. Focused proof inspection

The task-owned focused test exercises a real FinalCreate Game, real Runtime/SQLite structures and the real Shell consumer. It covers:

- safe Player / World / Entry identity;
- Player fact A visible;
- NPC-only fact B hidden;
- raw semantic consequence hidden;
- Agency action hidden;
- World Evolution event hidden;
- later Player knowledge may disclose the substance of previously hidden truth;
- stale hash exclusion after replacement;
- live semantic refresh;
- Save/close/reopen equivalence;
- Restore removal of restored-away knowledge;
- invalid input fail-closed;
- eight-fact bound / exact de-duplication;
- MW-008 / G5-02 / G5-01 and selected G5 regressions.

The evidence reports 56 focused assertions with zero failures, relevant regressions green, Windows export PASS, `git diff --check` clean and zero real Provider calls. This review inspected the actual test code and production paths; the reviewer did not independently execute Godot in this environment.

## 7. Non-blocking advisories

1. The refresh hook currently assumes new Player Character Knowledge continues to be authored by the existing semantic lane. If a future capability adds another legitimate knowledge producer, G5-06 refresh coverage must be re-audited rather than generalized pre-emptively.
2. Exact-string de-duplication intentionally does not merge semantically equivalent paraphrases.
3. Pre-G4-06 / invalid setup falls closed to the quiet empty state. Do not guess identity from legacy/raw material merely to fill the panel.

None is a Revision-1 blocker.

## 8. Capability disposition

MW-009 proves the first real G5-06 consumer and does not reveal a missing abstraction requiring a second implementation vertical.

Therefore:

```text
MW-009 = ENGINEERING PASS / CLOSED
G5-06   = ENGINEERING PASS / CLOSED
```

Owner-facing UX/product judgment for the side panels may be folded into the planned G5-07 combined product test instead of creating another G5-06 implementation task.
