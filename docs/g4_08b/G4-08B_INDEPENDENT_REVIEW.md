# G4-08B Independent Review

Status: **CORRECTION REQUIRED — NOT PASS**  
Reviewer: **GPT**  
Reviewed implementation HEAD: `3a20234d06c10904c220cd1a49bf29f6ad6769e7`  
Formal task: `docs/tasks/G4-08B_PUBLIC_D20_UI_INTEGRATION_TASK.md`

## 1. Result

G4-08B is **not yet PASS**.

The implementation substantially establishes the intended player path:

- Wizard reads real Expansion inventory and uses the accepted Composition authority for exact 0..N selection;
- selected Public d20 is materialized through unchanged Final Create;
- no-Expansion Games preserve the G4-07 Narrative path;
- Public d20 Games route Player actions through the accepted `ActionAdjudication` L3 seam without UI-owned RNG/result computation;
- stable action identity / retry / unresolved-on-reopen behavior is broadly wired correctly;
- accepted check records can be reconstructed from durable Game-local state on Continue / Load;
- protected backend paths and SQLite schema v4 remain unchanged;
- real DeepSeek Han evidence exists.

However, the current UI projection has two blocking integration defects plus one evidence gap.

## 2. Blocking finding A — mechanic-card lifecycle/order is not stable

The frozen UI matrix requires one accepted mechanic card associated with the corresponding Player/GM turn, specifically `Player → mechanic card → GM` (or an equivalently stable unambiguous association), while the transient public result must appear before the resolution narrative finishes.

Current production flow in `src/ui/叙事对话视图.gd` does this:

```text
resolution_narrative starts
→ _on_adjudication_stage_started()
→ _append_mechanic_card(check, true)
→ card is appended directly to Entries

later Provider completes
→ Host calls Conversation.begin_turn(player_text)
→ UI appends Player entry
→ UI appends GM entry
→ accepted terminal only clears _transient_check_id
```

The transient card is neither removed nor moved when the turn becomes accepted.

Therefore first-play live order is effectively:

```text
mechanic card
→ Player action
→ GM narrative
```

But full redraw / Continue currently rebuilds as:

```text
Player action
→ GM narrative
→ mechanic card
```

because `_render_restored_entries()` appends the card after `_begin_gm_entry()` and GM text.

This creates two different visual histories for the same durable truth and fails the frozen D2 state contract.

### Retry/reopen duplication

The same seam can create duplicate transient cards for one durable check:

- retrying an existing durable check calls `start_action()`;
- the Host synchronously emits `request_assembled(stage=resolution_narrative)`, so `_on_adjudication_stage_started()` appends a transient card;
- the same `start_action()` also returns `streaming{stage=resolution_narrative}`, and `_handle_adjudication_result()` appends the same check again;
- any transient card left from the failed prior narrative attempt is also still present.

`_transient_check_id` is assigned but is not used as a deduplication/replacement guard.

The current focused test only asserts card count on the first successful path and does not assert retry/reopen card uniqueness or exact child order.

## 3. Blocking finding B — unsupported action-resolution capability can silently degrade to legacy play

Frozen architecture requires unknown Host capability ids to fail loud rather than silently behave as if no Expansion were selected.

Current `_prepare_action_adjudication_after_activation()` behavior is:

```text
if capability_slot == action_resolution
and capability_id != action_check.public_d20.v1
→ push_error("unknown materialized capability_id")
→ continue
→ no ActionAdjudication Host mounted
```

The Narrative view then has `action_adjudication == null` and uses the legacy G4-07 single-call path.

That means a Game can contain an explicitly selected `action_resolution` Expansion while the product behaves as if no action-resolution Expansion were active. A log error is not a player-visible fail-loud state.

This contradicts the selected-Expansion honesty boundary and the frozen state matrix's structural-error handling.

## 4. Evidence gap — explicit-none Review proof is claimed but not implemented

`tests/g4_08b/公开D20界面整合测试.gd` contains:

```gdscript
func _test_wizard_expansion_none_projection() -> void:
    pass
```

The evidence document claims explicit-none / Review projection coverage, but the dedicated A2/A5 test is empty. The no-Expansion gameplay regression does not replace a direct assertion that the Wizard reaches Review with `拓展 / 无` through explicit `confirm_expansion_none()`.

This is an evidence-quality defect and must be closed in the correction.

## 5. Correction classification

Classification: **correction-01 — focused UI integration correction**.

Do not reopen:

- Expansion Source / Managed Library;
- Composition backend semantics;
- Final Create;
- Public d20 proposal/RNG/result semantics;
- CHECK_REQUIRED / NO_CHECK durable identity;
- persistence schema;
- Provider protocol.

The correction is limited to player-facing projection/routing and its focused tests.

## 6. Required correction evidence

Before G4-08B can PASS, prove at minimum:

1. during `resolution_narrative`, exactly one transient projection exists for the durable `check_id`;
2. retry of the same durable check never creates duplicate mechanic cards;
3. reopen + retry of one unresolved check never creates duplicate mechanic cards;
4. after acceptance, the visible historical association is stable and exactly one card exists for that check;
5. live accepted history and Continue/Load redraw use the same ordering/association;
6. restored historical card is between the corresponding Player action and GM narrative (or another explicitly frozen equivalent association implemented identically live and on redraw);
7. Load to a pre-check Save removes the card as before;
8. an unknown materialized `action_resolution` capability produces a player-visible gated/fail-loud state and never falls back to legacy Narrative routing;
9. explicit none is directly tested through Wizard → Review and shows `拓展 / 无`;
10. existing A–J regression floors, no-Expansion G4-07 route, M1/M1C01, real Public d20 vertical, protected backend paths and schema v4 remain green;
11. remove task/debug probe output such as `PROBE card added` from production UI code.

## 7. Decision

```text
G4-08B Public d20 UI Integration          CORRECTION REQUIRED
G4-08BC01 UI Projection / Fail-Loud Fix   ACTIVE — KIMI
G4-09 First Playable B                    NOT YET
```

Do not start G4-09 until this correction passes GPT Independent Review.
