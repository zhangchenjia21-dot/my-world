# G4-08BC01 Independent Review

Status: **PASS / CLOSED**  
Reviewer: **GPT**  
Reviewed implementation/evidence HEAD: `08287d28a9cacfc7795c7c7a35ef4739ff9faf2c`  
Correction packet: `docs/tasks/G4-08BC01_UI_PROJECTION_FAIL_LOUD_CORRECTION_TASK.md`

## 1. Result

G4-08BC01 is **PASS / CLOSED**.

The correction closes the focused G4-08B UI integration blockers without reopening accepted backend semantics.

Accepted correction results:

- one durable `check_id` now has at most one visible mechanic-card projection;
- duplicate `resolution_narrative` notifications reuse/update the same card node rather than appending another;
- live accepted history is stabilized as `Player action → mechanic card → GM narrative`;
- full redraw / Continue / Load reconstruct the same ordering from durable check truth;
- retry of an existing durable check reuses the same visible projection and still relies on M1 for no-reroll semantics;
- unresolved-on-reopen retry does not require a new check identity or new RNG;
- unknown materialized `action_resolution` capability produces a player-visible gated state and does not fall back to the legacy no-Expansion Provider path;
- explicit Expansion none now has direct Wizard → Review → frozen payload evidence;
- production `PROBE` debug output was removed;
- protected backend paths and SQLite schema v4 remain unchanged.

## 2. Mechanic-card review

`src/ui/叙事对话视图.gd` now uses durable `check_id` as a read-only projection identity.

`_append_mechanic_card()` first searches for an existing card with the same check id. If found, `_update_mechanic_card()` reuses that node. This closes the prior signal + synchronous-return duplication seam.

When the Host eventually calls `Conversation.begin_turn(player_text)`, `_on_turn_started()` appends the Player entry, moves the existing transient card immediately after that Player entry, and only then creates the GM entry. The durable redraw path uses the same Player → card → GM ordering.

This is consistent with the frozen G4-08B projection contract and does not alter Program-owned dice truth.

## 3. Unsupported capability review

`src/应用壳.gd` now treats a Game-local materialized `action_resolution` capability other than `action_check.public_d20.v1` as unsupported instead of silently continuing without a Host.

The View:

- shows a player-readable unsupported-rule message;
- disables Player submit/editing;
- hides legacy Regenerate;
- sends no legacy Narrative request;
- leaves the Game durable and intact.

This closes the selected-Expansion honesty blocker.

## 4. Explicit-none evidence

The previously empty `_test_wizard_expansion_none_projection()` is now implemented.

It directly proves:

```text
Expansion step incomplete
→ explicit 本局不使用拓展
→ step completes
→ back/forward preserves the explicit choice
→ Review shows 拓展 / 无
→ frozen payload has expansions=[]
→ expansion_none_confirmed=true
```

## 5. Evidence note

The correction evidence document describes stronger retry/reopen card-order assertions than are individually obvious in every focused test branch. I do not treat this as a remaining blocker because the actual production projection code now enforces the identity/order invariant directly, the strengthened suite remains green, and no contradictory implementation path remains.

Future evidence should prefer explicit child-order/count assertions over relying on screenshot inspection or prose summaries.

## 6. Boundaries

No semantic changes were made under:

- `src/source/**`
- `src/最终建局/**`
- `src/persistence/**`
- `src/行动判定/L0_公理层/**`
- `src/行动判定/L1_器件层/**`
- `src/行动判定/L2_流程层/**`

Provider message semantics are unchanged. Existing real DeepSeek G4-08B evidence remains applicable.

## 7. Decision

```text
G4-08BC01 UI Projection / Fail-Loud   PASS / CLOSED
G4-08B Public d20 UI Integration      PASS / CLOSED
G4-09 First Playable B                READY TO START
```

G4-08 parent remains active until the real Expansion product vertical / Owner UAT B is completed. This review alone is not G4-08 Product PASS and is not G4-GATE PASS.
