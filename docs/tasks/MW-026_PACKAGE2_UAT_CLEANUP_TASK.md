# TASK｜MW-026｜Package 2 UAT Cleanup

Type: bounded G6 Package-2 closure cleanup  
Work Item: **MW-026**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Owner UAT: **bounded spot confirmation only after reviewed integration**  
Required branch: `mw-026-package2-uat-cleanup`  
Required worktree: `D:/AI/Projects/.worktrees/my-world/mw-026-package2-uat-cleanup`  
Formal Code Base: `b8b5c54eeda95b321c2c8492f3801f30991f89be`  
Tested Package-2 Product Code: `716d8dbfadaad07d992baef531912b6ce1078e2d`  
Note: `716d8dbf... -> b8b5c54e...` is four documentation-only no-net-tree-change commits; compare has zero changed files.  
Governance correction: `Vibe-Coding/my world/architecture/interaction/G6_PACKAGE2_UAT_CLEANUP_V1_0_DECISION.md`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Product outcome

Owner ended Package-2 exploratory UAT, judged the remaining findings small, and explicitly asked that they be solved **once** so the project can return to the main core route quickly.

Implement exactly three bounded corrections:

1. **Public d20 truth continuity** — a check/result already shown to the Player must remain available as player-safe GM/OOC context, so later GM cannot deny it happened and accepted failure stakes are not silently forgotten;
2. **OOC request-marker presentation leak** — preserve typed OOC semantics while preventing internal implementation wrappers from surfacing as ordinary GM prose;
3. **Compact recommendation layout** — short recommendation labels must actually reclaim Narrative space instead of living inside old full-width bars.

Do not reopen Package-2 architecture. Do not add unrelated polish.

## 2. Authority / read first

Refresh both mains before implementation. Read in order:

1. repo `AGENTS.md`;
2. current governance `MY_WORLD_CURRENT_STATUS.md`;
3. `Vibe-Coding/my world/docs/uat/G6_PACKAGE2_OWNER_UAT_U1.md@v1.4`;
4. `Vibe-Coding/my world/architecture/interaction/G6_PACKAGE2_UAT_CLEANUP_V1_0_DECISION.md`;
5. `Vibe-Coding/my world/architecture/interaction/G6_CORE_INTERACTION_CONTROL_V1_0_DECISION.md`;
6. current implementation entries:
   - `src/首次开场/L2_流程层/首次开场运行流程.gd`
   - `src/context/上下文组装器.gd`
   - `src/行动判定/L2_流程层/公开D20行动判定流程.gd`
   - `src/行动判定/L3_外交层/行动判定公开接口.gd`
   - `src/ui/叙事对话视图.gd`
   - `src/main.tscn`
7. directly affected MW-019/MW-021/MW-023/MW-024/MW-025 and Public d20 tests.

STOP only for a genuinely superseding current decision or a real storage/currentness blocker that requires broader architecture.

## 3. Correction A — Player-safe Public Mechanics continuity

### 3.1 Required behavior

A Public d20 / NO_CHECK record that is:

- durable in current Game state;
- accepted / player-visible;
- still current for the current Timeline;

may be projected as bounded **player-safe Program truth** into later continuation/OOC GM context.

The GM must not be left in a state where the UI knows a disclosed check occurred but later OOC/Narrative does not.

### 3.2 Minimal architecture

Create/reuse a small pure player-safe mechanics-history projector under the mechanics module, exposed through an L3/public seam.

Do not make FirstOpening/Context reach into mechanics L0/L1/L2 internals.

The projection should use existing current durable mechanics truth and accepted Conversation to validate/render only recent current public records. Keep it bounded; a small fixed recent count is sufficient.

Allowed request material only if already public to Player:

- accepted turn position/order;
- branch `CHECK` / `NO_CHECK`;
- check intent;
- DC / modifier / stance / selected roll / total;
- success/failure outcome;
- public success intent / failure stakes;
- public NO_CHECK reason.

Do not put into model context:

- action_id / check_id / resolution_id;
- raw control request/response;
- control proposal envelope beyond the public fields above;
- model control reasoning;
- raw world_state;
- NPC/private Knowledge/Agency/Evolution;
- hashes/prefixes/credentials/debug-only payload.

### 3.3 Continuation placement

In the existing production continuation assembly (`FirstOpeningRuntimeProcess.assemble_continuation_messages()` or the equivalent current seam), compose:

`durable setup/context`
→ `materialized World/Knowledge/Agency/Evolution context`
→ **player-safe Public Mechanics context**
→ `Literary Style Reference anchor`

The mechanics section is factual player-safe context, not style material.

Do not add a new Provider call.

Do not add SQLite/schema/storage/currentness owners.

Do not implement the future full `系统 / System Surface`.

### 3.4 Causal fidelity

Do not add a new consequence engine.

The correction only makes accepted mechanics truth available to the GM. Prompt/context wording may clearly state that disclosed Program outcomes are authoritative prior facts and must not be denied/re-rolled/ignored.

A failure may later be overcome by new actions; the GM is not required to make failure permanent. But new opportunity must be narrated as a development after the accepted failure, not as though the failure never happened.

### 3.5 Deterministic proof

Use a controlled fixture with an accepted failed Public d20 record and failure stakes. Prove:

- next ordinary continuation request contains the bounded public mechanics truth;
- next OOC request contains the same public mechanics truth;
- request contains failure outcome/stakes but not internal IDs/control/private canaries;
- Restore to before the check removes it from later request context;
- Restore to after the check restores it;
- stale/displaced-future mechanics records do not enter the context;
- zero extra Provider calls are introduced.

Include a NO_CHECK fixture as well so the GM can know a specific accepted action intentionally had no roll.

## 4. Correction B — OOC marker leak

Current implementation uses internal-looking request wrappers such as:

`[GM OOC response | input_mode=ooc]`

Owner observed that exact implementation syntax in player-visible output.

Preserve:

- explicit Program-owned `action/ooc` mode;
- OOC currentness/persistence;
- durable raw Player/GM prose bytes;
- structural OOC exclusion from d20/World/Curator;
- one Narrative Provider lane.

Change only derived Provider request representation.

Preferred minimal direction:

- active OOC stays explicitly declared via system guidance;
- historical OOC Player text may use a human-readable non-implementation label such as `OOC / GM 指导` in derived request material;
- historical OOC assistant response does not need an internal bracketed implementation marker if the typed pair is already structurally clear;
- do not use broad regex/output post-processing to rewrite arbitrary model prose.

Acceptance:

- fresh OOC request material contains no `[GM OOC response | input_mode=ooc]` or similar internal implementation token;
- model still sees enough explicit structure to distinguish OOC from role action;
- raw accepted bytes remain unchanged;
- Save/reopen/Restore/regenerate/correction mode behavior remains unchanged.

A bounded real Provider OOC check is allowed after deterministic gates to confirm the internal marker no longer leaks. Maximum one real OOC call for this cleanup.

## 5. Correction C — Compact recommendation layout

The model-side short-label contract is already correct. Do **not** shorten labels further or change the recommendation Provider contract.

Current UI problem:

- short labels render inside `SIZE_EXPAND_FILL` buttons;
- ordinary layout is a two-column full-width Grid;
- fixed 48px button minimum + up-to-168px recommendation scroll keeps old long-copy footprint.

Required product result:

> At ordinary desktop widths, five normal short labels should render as compact content-width choices, usually in about one or two rows, materially returning vertical space to Narrative.

Implementation may use `HFlowContainer` / wrapping compact controls or an equivalent simple Godot layout.

Requirements:

- content-width / compact rather than full-cell stretch;
- natural wrap when width is insufficient;
- recommendation region height follows actual rows;
- bounded vertical scroll only when truly needed;
- >=20px font remains;
- practical click target remains;
- detailed draft remains out of button;
- click still ensures `角色行动`, exact-prefills draft, never sends;
- free-form input remains primary;
- no horizontal overflow at 960×540;
- do not shrink Narrative font;
- do not redesign the whole composer/host.

Composer height is not in scope unless a minimal local adjustment is strictly necessary to make the compact recommendation surface function; if touched, explain why and keep it bounded.

Real-window acceptance at:

- 960×540
- 1280×720
- 1920×1080

Measure/report at least:

- recommendation area actual height;
- number of visible wrapped rows;
- Narrative viewport height before/after or equivalent evidence that space was materially returned;
- no inaccessible controls / horizontal overflow.

## 6. Protected invariants

Must preserve:

- MW-024 typed OOC/currentness/persistence;
- OOC zero d20/World/Identity/Agency/Evolution/lived Curator;
- MW-025 Character-guided recommendation soft-tendency semantics;
- one recommendation call per opportunity;
- no Character→Recommender blocking barrier;
- strict five `{label,draft}` parser/contract;
- recommendation exact prefill/no-send;
- accepted-action Character evidence semantics;
- Public d20 durable/no-reroll semantics;
- Save/Restore/Regenerate currentness;
- Debug read-only behavior;
- MW-023 >=20px gameplay typography;
- MW-021 Narrative scrolling;
- free-form natural-language action as primary path.

## 7. Explicit non-scope

Do not implement:

- People/general information hide preferences — deferred Package 6;
- Open Threads — next Package 3;
- System surface;
- Inventory;
- Dynamic UI;
- Context Orchestrator;
- d20 balance redesign;
- new consequence engine;
- Relationship/Faction;
- Narrative Preference;
- Reality Correction;
- general shell/UI refactor;
- G3 Context debt cleanup;
- layer-boundary cleanup;
- unrelated warning cleanup.

## 8. Validation order

1. focused deterministic mechanics-context/currentness/privacy tests;
2. focused OOC request-representation/currentness tests;
3. real-window compact recommendation tests at three sizes;
4. directly affected regressions including Public d20, G2/G3 context/persistence, MW-019, MW-021, MW-023, MW-024, MW-025, MW-022;
5. optional maximum one real OOC Provider call after deterministic gates;
6. final Godot 4.7.2 import;
7. fresh Windows export / `run-game.ps1 -ValidateExportOnly`.

Known exact-baseline G3 Context assertions may remain only if reproduced on the exact Formal Base. Do not suppress or silently fix unrelated debt.

## 9. Return requirements

Commit + push to `mw-026-package2-uat-cleanup`.

Write:

`docs/mw026/MW-026_IMPLEMENTATION_RETURN.md`

Return:

- exact Starting HEAD;
- exact Implementation HEAD;
- exact Final candidate HEAD;
- changed production files;
- focused/window/regression results;
- real Provider result if used;
- import/export results;
- residual risks.

Do not merge `main`.
Do not install Owner build.
Do not announce Product PASS.

Highest state:

**READY FOR INDEPENDENT REVIEW**
