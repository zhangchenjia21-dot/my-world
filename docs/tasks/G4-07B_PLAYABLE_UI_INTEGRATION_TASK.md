---
title: my world｜G4-07B Playable UI Integration Task Packet
status: current-task-packet
task_id: G4-07B
type: implementation
owner: Kimi
created: 2026-08-31
updated: 2026-08-31
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: fdb6a30ad138c332837f17af1d8c74b5643db44b
parent_task: G4-07 First Playable A
highest_implementation_status: READY FOR INDEPENDENT REVIEW
owner_uat_required: false
parent_owner_uat_required: true
---

# TASK｜G4-07B｜Playable UI Integration

Type: `implementation`  
Primary owner: **Kimi**  
Semantic / Independent Review owner: **GPT**  
Parent Product gate: **G4-07 First Playable A — Owner UAT required**  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`  
Formal Code Base: `fdb6a30ad138c332837f17af1d8c74b5643db44b`

> G4-07A 已经证明：一个 G4-06-created durable Game 可以 existing-only 打开，从 Game-local truth 生成真实 DeepSeek GM Opening，durable exactly once，并在重开后从持久 Conversation + World truth 继续。
>
> G4-07B 不重做这些 backend 机制。它把已经通过审查的 G4-05 Wizard、G4-06 Final Create、G4-07A Opening Runtime 串成玩家真正能操作的 Windows UI vertical。

Kimi 本任务最高只能返回：

> **READY FOR INDEPENDENT REVIEW**

不得宣布 G4-07 Product PASS；完整产品价值必须由 Owner UAT 判断。

---

## 1. Outcome

建立第一条真实可玩 UI 路径：

```text
Main Menu
→ New Game Wizard
→ Review
→ Final Create
→ exact created Game existing-only open
→ first GM Opening streaming in Narrative UI
→ accepted Opening shown once
→ Player sends real free-form action
→ normal continuation uses durable Game-local Context + Conversation
→ AI GM response streams and becomes durable
→ Save / exit / reopen / Continue
→ same Game + same durable history
```

同时支持创建后 Opening 失败/取消、应用在 create 后 Opening 前退出、以及 Continue 进入一个“created but no accepted Opening yet”的 Game。

---

## 2. Ownership / allowed production scope

Primary task nature: frontend / application interaction wiring.

Expected production scope:

- `src/应用壳.gd`
- `src/main.tscn`
- `src/ui/**`
- narrow application-facing presentation/glue files if current structure clearly requires them

Read-only backend authority unless a concrete blocking defect is found:

- `src/最终建局/**`
- `src/首次开场/**`
- `src/persistence/**`
- `src/runtime/**`
- `src/provider/**`
- `src/source/**`
- `src/domain/**`
- `src/context/**`
- `src/游戏库/**`
- `src/建局/**`

If a backend seam is genuinely insufficient, **return `BLOCKED` with the exact missing seam**. Do not silently redesign G4-06/G4-07A inside a UI task.

Tests/evidence/docs may be added under task-owned paths.

---

## 3. Read First

1. `AGENTS.md`
2. this packet
3. `docs/g4_07a/G4-07A_FIRST_PLAYABLE_OPENING_RUNTIME_IMPLEMENTATION_EVIDENCE.md`
4. `src/应用壳.gd`
5. `src/main.tscn`
6. current Narrative Conversation UI under `src/ui/**`
7. `src/最终建局/L3_外交层/原子最终建局公开接口.gd`
8. `src/首次开场/L3_外交层/首次开场公开接口.gd`
9. `src/runtime/当前游戏会话运行时.gd`
10. `src/游戏库/L3_外交层/游戏库公开接口.gd`
11. G4-05 Wizard full-fidelity tests/evidence
12. G4-04 Main Menu / Continue / Switch lifecycle tests
13. G2/G3 Narrative UI + streaming/cancel/save/load tests

Do not reread mutable Source to reconstruct a created Game.

---

## 4. Required UI/application state matrix

Before production edits, create:

`docs/tasks/G4-07B_UI_STATE_FAILURE_MATRIX.md`

At minimum cover:

```text
state / event
→ frozen Review payload
→ creation_id ownership
→ Game existence/current selection
→ Game session state
→ Opening state
→ Narrative UI state
→ retry/back/continue behavior
```

Required cases:

A. Review → first Final Create success → Opening success → Playing；  
B. double-click / repeated Final Create while creating；  
C. transient Final Create failure before Game exists → retry same attempt safely；  
D. Final Create succeeded but UI transition/opening start fails；  
E. app exits after Game created but before accepted Opening；  
F. Continue opens created Game with accepted Conversation = 0；  
G. Opening Provider failure after partial stream；  
H. Opening cancel after partial stream；  
I. retry Opening after failure/cancel；  
J. accepted Opening already exists → Continue must not generate another first Opening；  
K. first real Player action after Opening → real continuation；  
L. Save / exit / reopen / Continue after at least one Player turn；  
M. no-Entry route；  
N. Han temporal early-start route；  
O. Afterglow route；  
P. missing/corrupt Game on Continue；  
Q. back navigation before durable create；  
R. Windows layout / keyboard / mouse / focus states。

---

## 5. Frozen integration invariants

### INV-UI-01｜Final Create identity is one UI attempt, not one click

When the player first commits a frozen Review payload, the application must create/fix one `creation_id` for that create attempt.

- repeated click / UI retry for the same frozen payload reuses the same `creation_id`;
- disable/debounce Final Create while a create call is active;
- do not mint another Game merely because a callback/UI transition repeats;
- if the player returns to edit Composition before a successful durable create and later confirms a materially new Review payload, start a **new** creation attempt identity;
- once create succeeds, the Wizard is complete and must not create a second Game from the same Review screen.

Do not derive Game uniqueness from composition fingerprint.

### INV-UI-02｜Created Game transition uses existing-only open

After Final Create returns success/replay success, open the exact returned managed DB through the existing-only runtime seam.

Never use historical first-run `open_current_game()` behavior to fill a missing path.

Missing/corrupt/wrong Game state must produce an understandable error without creating a replacement Game.

### INV-UI-03｜Opening is a resumable state of the created Game

A Game can validly exist with accepted Conversation = 0.

That includes:

- immediately after Final Create;
- after Provider failure/cancel;
- after app exit/crash between create and accepted Opening.

Entering that exact Game through New Game transition or Continue must route to the reviewed G4-07A first-Opening seam, not create another Game.

### INV-UI-04｜Opening failure/cancel does not roll back Game creation

Once G4-06 created the Game, Provider failure/cancel must not delete/unregister the Game or rerun Final Create under a new identity.

UI must clearly offer a safe Opening retry and allow returning to Main Menu while preserving the created Game for Continue.

### INV-UI-05｜GM-only Opening has no fake Player bubble

The first durable accepted entry has an empty compatibility `player_text` by design.

Narrative UI must render it as a GM Opening, not as:

- an empty Player bubble;
- a fake player action;
- an engineering/system message.

Later accepted Player turns retain normal Player → GM presentation.

### INV-UI-06｜Normal continuation must use reviewed durable context

After the Opening is accepted, the next free-form Player action must go through the existing Conversation/Provider pipeline using the reviewed G4-07A durable continuation context.

Do not send a continuation using Wizard state or mutable Source current.

Do not introduce a second transcript or Provider stack.

### INV-UI-07｜Continue semantics

On application restart / Main Menu Continue:

```text
accepted Conversation = 0 + valid G4-06 setup
→ opening-pending / retryable Opening flow

accepted Conversation >= 1
→ render durable history
→ ordinary Playing state
```

Never auto-create a second first Opening after one has been accepted.

### INV-UI-08｜Player-facing copy stays semantic, not debug-oriented

Do not foreground fingerprints, internal IDs, schema names, task IDs or engineering error codes.

Keep Guaranteed NPC wording narrow: canonical member of this Game, not guaranteed first-scene presence or pre-existing relationship.

No-Entry must remain an intentional “no preset Entry” state; UI must not silently select a year/profile.

### INV-UI-09｜Windows interaction quality

The First Playable path must be operable by mouse and keyboard at least at:

- 1280×720;
- 960×540;
- maximized desktop.

No clipped primary actions, trapped focus, invisible streaming state, accidental double-submit, or modal dead-end.

### INV-UI-10｜No product PASS before Owner UAT

Automated tests, real Provider transport, screenshots and Independent Review only establish a UAT-ready vertical.

They do not prove narrative richness, individuality or product value.

---

## 6. Minimum presentation requirements

The player should be able to distinguish these states without engineering knowledge:

- Reviewing game setup;
- Creating game;
- Game created / preparing first scene;
- GM Opening streaming;
- Opening failed with retry available;
- Opening cancelled with retry available;
- Playing / ready for Player input;
- Saving / saved;
- Returning to Main Menu;
- Continue / resume exact Game;
- Game unavailable/corrupt.

Do not add a large new visual design system. Reuse the existing application shell and Narrative Conversation View.

---

## 7. Real integration evidence required

Use the frozen full-fidelity families and production seams.

### Han vertical

Through the real application UI:

```text
New Game
→ Han World
→ exact early Entry
→ Liu Bei Player
→ optional Sun Quan Guaranteed NPC
→ Review
→ Final Create
→ real DeepSeek Opening
→ one real Player action
→ real GM continuation
→ Save
→ Main Menu / application reopen
→ Continue same Game
```

Evidence must show no later/future markers leak into Provider-visible context and no forced guaranteed-NPC convergence is introduced by UI logic.

### Afterglow vertical

Repeat enough of the real UI route to prove the same frontend is family-agnostic and preserves distinct fantasy semantics.

### no-Entry

Deterministic UI/integration proof must show no hidden default Entry/profile appears before or after Final Create.

### Failure/retry

At least controlled application-level proof for:

- Opening Provider failure after create;
- Opening cancel;
- retry on the same created Game;
- restart/Continue with accepted Conversation still 0;
- no duplicate Game and no duplicate first Opening.

---

## 8. Required evidence artifacts

Create task-owned evidence under:

`docs/g4_07b/`

At minimum record:

- implementation commit(s);
- changed production paths;
- UI state/failure matrix result;
- real Han flow result;
- real Afterglow flow result;
- no-Entry result;
- create/opening retry identity result;
- Continue-after-zero-Opening result;
- first Player continuation result;
- Save/reopen/Continue result;
- Windows layout/interaction evidence;
- regressions;
- explicit statement that G4-07 Product PASS is not claimed.

Screenshots may remain task-owned build evidence if repository policy excludes binaries; evidence doc must identify exact run/path and what each screenshot proves.

---

## 9. Regression floor

Do not regress:

- G2 streaming/cancel/retry/Context behavior;
- G3 Conversation durability / Save / Load / Restore;
- G4-01 Application Shell session lifecycle;
- G4-04 Game Library Continue/Switch;
- G4-05 full-fidelity Wizard semantics/layout;
- G4-06 Final Create idempotence/recovery;
- G4-07A Opening runtime / source isolation / failure / reopen evidence.

Production SQLite schema remains v4.

Frozen full-fidelity fixtures remain unchanged.

---

## 10. Prohibited scope

Do not:

- redesign Source contracts;
- modify frozen full-fidelity fixtures to pass UI tests;
- redesign G4-06 creation protocol;
- redesign G4-07A backend/context/provider ownership;
- build Expansion;
- start G5 Living World broad semantics;
- start G7 context retrieval/summarization platform;
- hardcode family-specific narrative scripts;
- declare G4-07 Product PASS.

If a protected backend seam must change, return `BLOCKED` with evidence and let GPT route the backend correction to the right owner.

---

## 11. Required return

Return exactly one of:

### READY FOR INDEPENDENT REVIEW

Include:

- START_HEAD
- implementation/evidence commit SHAs
- production paths changed
- UI state/failure matrix path
- Han / Afterglow / no-Entry results
- stable creation identity / duplicate prevention result
- Opening failure/cancel/retry result
- Continue-after-zero-Opening result
- first Player continuation result
- Save/reopen/Continue result
- Windows layout/interaction evidence
- regression results
- schema status
- explicit statement that G4-07 Product PASS is **not** claimed

### BLOCKED

Include the exact missing backend/application ownership seam, reproduction evidence, and why it cannot be solved inside the allowed frontend/application scope.
