# G4-08B — Public d20 UI / Interaction Integration

Status: **ACTIVE — KIMI**  
Parent: **G4-08 Expansion Pack v0.1 + First Real Runtime Vertical**  
Prerequisite: **G4-08M1 PASS / CLOSED**  
Primary owner: **Kimi**  
Reviewer: **GPT**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Formal Code Base:

`d646427dfe3c4c6328809384e482cd1fdd2204a0`

Canonical semantic authority:

`Vibe-Coding/my world/architecture/source/G4_EXPANSION_V0_1_PUBLIC_D20_DECISION.md`

Accepted mechanism authority:

- `docs/g4_08m1/G4-08M1_INDEPENDENT_REVIEW.md`
- `src/行动判定/L3_外交层/行动判定公开接口.gd`

## 1. Purpose

Make the accepted Public d20 Expansion a real player-facing product path without moving mechanism ownership into UI.

The UI must prove:

```text
New Game
→ explicitly choose 0..N exact Expansion generations
→ Review shows the exact choice
→ Final Create unchanged
→ created Game opens
→ risky Player action routes through Public d20 Host
→ Program-owned result is visibly public
→ GM continuation respects the result
→ Save / Continue / Load redraw preserves the same mechanic record
```

No-Expansion Games must remain the accepted G4-07 experience.

## 2. Ownership boundaries

Kimi owns:

- New Game Wizard Expansion selection interaction;
- Review projection;
- Application/Narrative routing needed to invoke the already accepted L3 adjudication seam;
- temporary adjudication status / retry interaction;
- mechanic-card rendering from durable Program-owned truth;
- responsive layout and UI-focused evidence.

Kimi does **not** own or redesign:

- Source contract/library;
- Composition semantics or compatibility rules;
- Final Create semantics;
- Public d20 proposal/RNG/result computation;
- check / NO_CHECK durable identity semantics;
- Persistence schema;
- Provider protocol;
- G5 world consequence semantics.

Protected backend paths should not change absent a compilation-only adapter necessity. If the L3 seam is genuinely insufficient, stop and report the exact missing projection rather than reimplementing mechanism in UI.

## 3. New Game Wizard — Expansion step

Current Wizard step 3 is an honest `none only` placeholder. Replace it with real inventory projection from `load_current_inventory().expansions`.

Requirements:

- store the returned Expansion generations separately from World / Character;
- do not auto-select the first Expansion;
- player may explicitly choose `0..N` installed Expansion generations;
- use existing `composition.set_expansion(generation, selected)` as authority;
- use existing `confirm_expansion_none()` for explicit none when no Expansion is selected;
- slot collision / duplicate rejection remains backend authority and must be shown as a player-readable failure; UI must revert any toggle that backend rejected;
- display at least display name, version and catalog summary; do not expose raw fingerprint as primary product copy;
- if no Expansion is installed, show a clear empty state and explicit `本局不使用拓展` confirmation;
- step completion is true only when at least one Expansion is selected or explicit none has been confirmed;
- returning backward/forward through Wizard preserves the current exact selections;
- `discard()` clears Expansion UI state with the rest of the Composition.

No import button in this task. Player-facing Source import remains deferred to G8.

## 4. Review projection

The Compatibility Review must render the frozen Expansion selection honestly.

For none:

```text
拓展
无
```

For selected:

```text
拓展
• 判定与检定：公开 d20（<version>）
```

and similarly for future multiple non-conflicting selections.

Review text is projection only. Compatibility continues to come from `composition.build_compatibility_review()`.

## 5. Runtime capability routing

At current Game bind/open, determine Public d20 activation only from Game-local materialized state:

```text
world_state.expansions
→ capability_slot = action_resolution
→ capability_id = action_check.public_d20.v1
```

Never reread `SourceLibrary.current` during play.

### No Expansion

Preserve the current G4-07 Narrative path exactly:

```text
conversation.begin_turn
→ existing continuation assembly
→ existing Provider adapter / streaming
→ durable acceptance
```

Do not insert adjudication JSON, dice state or mechanic UI.

### Public d20 enabled

Player submit must route through:

`src/行动判定/L3_外交层/行动判定公开接口.gd`

The UI must not call `conversation.begin_turn()` first; the adjudication Host owns acceptance ordering.

Create one stable caller-owned `action_id` before `start_action(action_id, player_text)` and retain it until that action reaches accepted/already-accepted terminal state.

A suitable UI identity is a random opaque token such as `action-<128-bit random hex>`; it is not Game identity and not derived from Player prose.

## 6. Pending action / retry interaction

While Public d20 adjudication is active:

- disable additional Player submits;
- allow Cancel through the adjudication Host;
- show concise state such as `正在判断行动风险…`;
- when the Host begins `resolution_narrative`, the Program result is already durable; show the public mechanic result immediately in a transient mechanic surface while GM continuation completes;
- do not expose adjudication JSON or internal protocol text.

If action generation fails/cancels before accepted terminal:

- retain the same `action_id` + exact Player text for retry when a durable check or durable NO_CHECK resolution exists;
- retry must call the same Host with the same identity/payload so M1's no-reroll / no-replay semantics apply;
- when no durable resolution exists yet, UI may allow the player to edit/replace the action; a changed action receives a new action_id;
- never create a second action_id merely because Provider transport failed after a durable result.

### Reopen recovery

On binding an existing Public d20 Game, inspect the bounded Game-local Public d20 replay state as read-only projection.

If exactly one action has `narrative_accepted = false`:

- do not silently forget it;
- gate new Player input;
- show a player-readable `上一次行动尚未完成` / `重试行动` state;
- retry the exact stored action_id + player_text through the L3 Host.

If more than one unresolved action is present, fail visibly rather than guessing an order.

UI must not mutate these records directly.

## 7. Accepted-turn Regenerate semantics

For Public d20-enabled Sessions, do **not** offer the old generic `Regenerate` action after an accepted Player turn in v0.1.

Reason: the accepted action may already own a durable Program resolution / exact NO_CHECK narrative identity. Re-running the old G2 regenerate path would bypass the stable adjudication action identity.

First-generation behavior:

- unaccepted failed/cancelled action → `重试行动` using the same stable action identity where required;
- accepted Public d20 turn → no generic regenerate button;
- no-Expansion Session → preserve current G4-07 regenerate/retry behavior.

Do not redesign Conversation Domain to support post-accept d20 rewrite in this task.

## 8. Public mechanic card

The UI is a read-only projection of durable check truth. It never rolls, selects a die, computes total, changes DC, changes outcome or edits stakes.

For every accepted `CHECK_REQUIRED` turn, render a lightweight card associated with its `accepted_turn_index`.

Minimum visible fields:

```text
判定｜<intent>
DC <dc>
修正 +<modifier> · <modifier_reason>
<normal / 优势 / 劣势> · <situation_reason>
骰面 <raw_rolls> → <selected_roll>
总计 <total>
成功 / 失败
失败代价：<failure_stakes>
```

Formatting can be product-polished, but values must be exact projections.

### Timing

When `resolution_narrative` begins, the check is already durable. Show the mechanic result immediately in a transient status/card surface so the Player sees the public roll before the GM resolution narrative finishes.

After the turn is accepted, the durable mechanic card belongs in the narrative history between that Player action and its GM narrative (or an equivalently unambiguous association).

### NO_CHECK

Do not render a dice card for NO_CHECK. Ordinary no-roll action should look like ordinary narrative play.

## 9. Redraw / Continue / Load

Cards cannot exist only as transient widget memory.

Whenever Narrative history is rebuilt from durable Conversation — including:

- Game Continue / reopen;
- Save Load / Restore;
- normal full redraw;

rebuild accepted mechanic cards from current durable Game-local Public d20 check records keyed by `accepted_turn_index`.

Requirements:

- only `narrative_accepted = true` checks are historical cards;
- exact raw rolls / total / outcome survive redraw;
- future checks removed by Load/Restore must disappear with the restored future;
- NO_CHECK replay markers are not shown as dice cards;
- UI never injects historical check logs into Provider Context.

## 10. Layout / accessibility

Keep the existing Narrative-first hierarchy.

Mechanic card should be noticeable but subordinate to story text. It must remain readable at:

- 1280×720;
- 960×540;
- maximized desktop.

No click-to-roll, dice animation, modal interruption, or full RPG HUD in this task.

## 11. Required evidence

### A — Wizard Expansion inventory

Using task-owned Managed Source Library with the current real World/Character fixtures plus Public d20 fixture:

- Wizard shows Public d20 Expansion;
- nothing is auto-selected;
- explicit none is valid;
- selecting Public d20 survives back/forward navigation;
- Review shows exact selected Expansion name/version;
- Final Create receives the frozen selected exact identity.

### B — compatibility UI

A task-only second Expansion occupying `action_resolution` must be rejected by existing backend compatibility/selection authority and UI must not visually leave both selected.

### C — no-Expansion regression

Create/open a no-Expansion Game through the actual UI path and prove:

- no adjudication Host path is used;
- no mechanic card appears;
- existing G4-07 streaming / retry behavior remains intact.

### D — checked action UI

In a Public d20 Game, drive a risky action through the actual Narrative UI with deterministic test seams:

- UI provides one stable action_id;
- CHECK_REQUIRED freezes/rolls through M1 Host;
- transient public result appears before resolution narrative completion;
- accepted history displays exact durable mechanic card;
- UI does not recompute truth.

### E — NO_CHECK UI

Drive an ordinary action that returns NO_CHECK:

- one Provider adjudication call;
- no RNG;
- no dice card;
- normal Player/GM narrative accepted once.

### F — retry/no-reroll UI

Drive failure/cancel after durable losing check:

- UI presents retry rather than a fresh action;
- retry reuses same action_id/text;
- no reroll;
- only one accepted Player/GM turn.

Also prove a pre-resolution failure may be replaced by an edited Player action with a new identity.

### G — reopen unfinished action

Close/reopen a Game with exactly one unresolved Public d20 action:

- new Player input is gated;
- UI exposes `重试行动`;
- same durable action resumes with no reroll / no extra adjudication when M1 says replay is sufficient.

### H — Continue / Load card reconstruction

After at least one accepted check:

- Save / Main Menu / Continue preserves exact card;
- Load/Restore to a state before that check removes the future card;
- continuing again uses restored canonical reality.

### I — real Provider UI vertical

Run at least one real DeepSeek Han route through the UI with Public d20 selected:

- risky action naturally reaches CHECK_REQUIRED;
- Program result is shown publicly;
- real GM continuation respects outcome;
- later ordinary action can be NO_CHECK without a dice card.

Do not force all actions to roll merely for evidence.

### J — regressions / boundaries

Keep green:

- G4-07B playable UI integration suite;
- G4-08M1 / M1C01 focused backend suites;
- no-Expansion route;
- Final Create semantics;
- no Source/persistence/provider backend semantic change;
- no secret output;
- `git diff --check`.

## 12. Expected production paths

Likely UI/integration paths include:

- `src/ui/新游戏向导.gd`
- `src/ui/新游戏向导.tscn` only if layout requires it
- `src/ui/叙事对话视图.gd`
- `src/main.tscn` / `src/应用壳.gd` only for bounded composition/wiring
- task-owned tests/evidence

Do not modify `src/source/**`, `src/最终建局/**`, `src/persistence/**`, or `src/行动判定/L0-L2/**` to solve UI behavior. If a missing L3 projection blocks correct UI, report it explicitly for GPT/Codex rather than bypassing ownership.

## 13. Return contract

Return only after implementation/evidence are pushed to `main`:

```text
START_HEAD
IMPLEMENTATION_HEAD
EVIDENCE_HEAD (if separate)
changed paths
exact Wizard Expansion interaction
exact action_id lifecycle / retry behavior
exact capability activation check
exact mechanic-card projection source
Evidence A-J summary
real Provider UI result
screenshots / viewport matrix
protected backend paths unchanged
```

Return ceiling:

> **READY FOR INDEPENDENT REVIEW**

Do not declare G4-08 PASS and do not start G4-09 yourself.
