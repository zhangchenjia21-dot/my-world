# TASK｜MW-019｜Five Recommended Actions

Type: G6 product-facing Narrative Host vertical implementation  
Work Item: **MW-019**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Product Owner / UAT: **Owner**  
Status: **READY FOR CODEX**  
Task Branch: `mw-019-five-recommended-actions`  
Required Worktree: `D:/AI/Projects/.worktrees/my-world/mw-019`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Formal product-code base: `7aa02cc60aa8a87708d3d23477e11e237bb20123`  
Governance architecture base at shaping: `7671c29dc609d479458ff4ca5d12e0b8a76fea15`

## 1. Product outcome

Implement a real **Five Recommended Actions** experience in the central Narrative Host.

After each durably accepted GM Narrative, the player should receive exactly five model-generated suggested next actions while the existing unrestricted natural-language composer remains fully available.

Required visible interaction:

```text
GM Narrative completes and is durably accepted
↓
推荐行动
[建议 1] [建议 2]
[建议 3] [建议 4]
[建议 5]
↓
player clicks one
↓
existing PlayerInput is PREFILLED
↓
player may edit freely
↓
existing Send / Ctrl+Enter path submits normally
```

Protected product rule:

> **Five recommended actions are inspiration, not a five-choice gate.**

The player must always be able to ignore them and type any natural-language action.

## 2. Why now

MW-018 People cards are already Engineering PASS / integrated, but Owner explicitly chose to defer standalone MW-018 UAT and implement recommended actions first, then test both together in one fresh Owner build.

Canonical route decision:

`Vibe-Coding/my world/architecture/ui/G6_FIVE_RECOMMENDED_ACTIONS_V1_0_DECISION.md`

Roadmap v4.1 now treats MW-019 as a concrete Narrative interaction consumer before later generic Action Intent abstraction.

## 3. Primary Purpose / Core Value

Current product core value remains:

> **长期持续 AI 世界 + 优秀自由 AI GM + 原生 RPG 游戏体验。**

MW-019 should reduce “blank-composer friction” without weakening model/player freedom.

INV-PRODUCT-01:

> The recommendations must make it easier to start a meaningful next action while preserving the feeling that the player can still do anything expressible in natural language.

INV-PRODUCT-02:

> Recommendations are not authoritative actions, world truth, guaranteed outcomes or a replacement for the composer.

## 4. Authority / Source Manifest

Refresh both mains before implementation.

Authority order:

1. Owner current explicit instruction.
2. `Vibe-Coding/AGENTS.md` + Owner collaboration preferences.
3. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`.
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` v4.1+.
5. `Vibe-Coding/my world/architecture/ui/G6_FIVE_RECOMMENDED_ACTIONS_V1_0_DECISION.md`.
6. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`.
7. repository `AGENTS.md`.
8. current production implementation/tests.

Current MW-018 evidence remains relevant regression context:

- `docs/mw018/MW-018_INDEPENDENT_REVIEW_IR1.md`
- `docs/mw018/MW-018_INTEGRATION_VERIFICATION.md`

If a newer current decision conflicts, STOP rather than silently combining them.

## 5. Read first

Initial workset:

1. `AGENTS.md`
2. this Task Packet
3. `src/ui/叙事对话视图.gd`
4. `src/main.tscn`
5. `src/domain/会话.gd`
6. `src/provider/L3_外交层/运行时模型流式适配公开接口.gd`
7. relevant G2/G4-07/Public-d20 Narrative tests

Expand only when concrete evidence requires Shell/runtime/currentness/test owners.

Do not read raw World/Source/actor internals merely to enrich recommendation quality.

## 6. Frozen product semantics

### DEC-01 — exactly five on successful generation

Successful recommendation output contains exactly **5** distinct recommendation strings.

They should be concrete, immediately actionable, natural-language draft actions.

The model prompt should encourage useful variety where context supports it, but Program does not enforce semantic categories or ranking.

### DEC-02 — click PREFILLS, never auto-sends

Clicking a recommendation:

```text
replace PlayerInput text with that recommendation
→ focus PlayerInput
→ place cursor for editing
```

It MUST NOT:

- call `_on_send_pressed()`;
- call `conversation.begin_turn()`;
- invoke Public d20/adjudication directly;
- mutate Game/World/Conversation truth;
- disable later editing.

When the player later sends, the exact existing composer route remains authoritative. If Public d20 is enabled, it continues through the existing adjudication path with no special recommendation bypass.

### DEC-03 — free-form composer remains primary

Recommendation visibility does not disable or constrain manual typing.

The player may:

- type while recommendations are generating;
- ignore all recommendations;
- click one then edit it;
- replace it entirely;
- send their own text before recommendation generation finishes.

Foreground player action always wins.

### DEC-04 — recommendation UI placement

Recommendations live in the **Narrative Host** near the composer, not in World Information and not as durable transcript entries.

Use a compact responsive button layout immediately above/adjacent to the composer.

Requirements:

- all five easy to scan;
- no horizontal overflow at maximized, 1280×720 and 960-class supported layouts;
- recommendation area must not materially displace the Narrative reading area more than necessary;
- long labels wrap or truncate safely; tooltip/full text may be used;
- recommendation controls are not persisted as conversation history.

A small muted `推荐行动` heading/loading/unavailable state is allowed.

No ranking badges, “best” marker, hotkeys or probabilities in v0.1.

## 7. Architecture — dedicated ephemeral Action Recommender

Implement a narrow **dedicated background Action Recommender** using the currently configured Provider/model.

Do not embed recommendations into the authoritative streaming GM Narrative response.

Do not piggyback player-facing recommendation text onto World semantic analysis or Information Curator.

Required concurrency model:

```text
GM Narrative accepted durably
├─ existing semantic / curation / agency lanes continue under their owners
└─ recommendation request starts independently and fail-soft
```

Recommendation work is not a Narrative Finalize Gate.

No hidden Provider switch/fallback.

Avoid placing provider lifecycle/state directly into a leaf button widget. Use the narrowest explicit process/public seam consistent with current repo layering; do not create a generic job scheduler/event bus.

## 8. Player-safe recommendation input

Recommendation input uses only player-visible accepted Conversation material.

Allowed:

- latest durably accepted GM Narrative;
- associated accepted Player action when present;
- bounded recent earlier accepted Player/GM history for continuity.

A simple bounded recent window / byte ceiling is allowed. The latest accepted GM Narrative must always be included when valid.

Do NOT include for recommendation quality:

- raw `world_state`;
- stable actor roster/profiles;
- Source projections/current content;
- NPC-private Knowledge;
- Agency private plan/history;
- hidden World Evolution;
- GM-private semantic sections;
- internal IDs/hashes/receipts;
- raw `information_curation` storage.

Do not call existing omniscient GM Context assembly merely because it is available. The recommender has a stricter player-visible disclosure boundary.

Recommended first implementation bound:

```text
latest accepted GM + bounded recent accepted transcript
≤ 24 KiB model-visible user content
```

An equivalent smaller deterministic recency/byte bound is acceptable if proven sufficient. No semantic retrieval/ranking engine in MW-019.

## 9. Recommendation prompt / response contract

The model should be instructed to:

- propose five distinct plausible next actions;
- phrase them as ready-to-edit player actions, preferably first-person;
- use only information visible in the accepted transcript;
- avoid guaranteed result language;
- avoid revealing hidden identity/state/future knowledge;
- avoid claiming these are the only possible choices;
- output JSON only, no reasoning/Markdown.

Machine response shape:

```json
{
  "actions": [
    "我……",
    "我……",
    "我……",
    "我……",
    "我……"
  ]
}
```

Program structural validation:

- exact top-level object/key shape;
- exactly 5 items;
- each item String, non-empty after trim;
- max 240 characters per item;
- exact duplicate strings rejected;
- whole response bounded (recommended <= 8 KiB);
- malformed/deep/oversized output fails soft.

Program MUST NOT implement semantic diversity scoring, tactic categories, danger ranking or keyword repair.

Do not invent missing actions when the model returns fewer than five.

## 10. Ephemeral state / no authoritative persistence

Recommended actions are derived UI guidance only.

Do not persist them into:

- Conversation accepted entries;
- World state;
- Timeline nodes;
- Save schema;
- `information_curation`;
- Source;
- SQLite tables.

Recommendation text enters Game truth only if the player later submits edited/exact text through the normal Player action path.

Bind in-memory recommendation state to the exact current accepted Conversation prefix/opportunity so stale callbacks cannot publish into a different history.

No new SQLite table/migration.

## 11. Lifecycle / currentness

### 11.1 Successful accepted opening

GM-only opening **does** receive recommendations in MW-019.

After the opening is durably accepted, generate five actions so a newly created Game does not begin with a blank composer experience.

This is independent of People v0.1's decision not to curate People from opening.

### 11.2 Successful normal turn

After each durably accepted ordinary GM Narrative, generate a new set for that accepted state.

### 11.3 New foreground attempt

As soon as a new foreground Player action begins/is submitted:

- hide/clear the previous set;
- invalidate/cancel any in-flight recommendation request for the previous accepted state;
- never delay the Player action.

If the player submits before the recommendation response arrives, the old response must not later reappear.

### 11.4 Regenerate / correction / retry

When replacement/retry generation begins, clear old recommendations.

Only a newly **durably accepted** GM replacement receives a fresh set.

Failed/cancelled GM output does not create recommendations for unaccepted text.

### 11.5 Restore / reopen / activation

Recommendations are ephemeral, so they are not restored from Save.

On Game activation/reopen or a successful Restore, when there is a current latest accepted GM Narrative and no foreground generation is active, the system may issue **at most one** fresh recommendation request for that current accepted prefix.

A pre-Restore/pre-activation request callback must never publish after epoch/history changes.

Repeated render, resize, tab switching or composer editing must not trigger additional recommendation calls.

### 11.6 Empty game

If no accepted GM Narrative exists, show no recommendations and make no recommendation Provider call.

## 12. Failure / cancellation behavior

Recommendation failure is always fail-soft.

It must not block or fail:

- composer typing;
- Send / Ctrl+Enter;
- GM Narrative generation;
- Public d20;
- semantic materialization;
- Information Curator / People;
- Save / Restore;
- reopen.

Allowed UI behavior on failure:

```text
no buttons
or
quiet muted “暂时没有推荐行动，可自由输入”
```

Do not use the main blocking/red Narrative failure path for recommendation-only failure.

A bounded timeout is allowed. Cancel transport on shutdown/history invalidation if current Provider seam supports it safely.

## 13. Relationship to generic G6-G Action Intent

MW-019 implements only one fixed first-party behavior:

```text
Recommendation button → prefill existing composer
```

Do NOT build:

- generic Action Intent schema;
- arbitrary callback registry;
- NodePath action execution;
- generic command bus;
- OS/filesystem actions;
- declarative external action system;
- MW-013 Internal Declarative UI Host.

Later G6-G may abstract `prefill composer` after more real consumers exist.

## 14. Required engineering acceptance

At minimum prove through real production seams:

1. accepted GM opening triggers one recommendation opportunity;
2. accepted ordinary GM turn triggers one recommendation opportunity;
3. successful result renders exactly five distinct recommendation buttons;
4. clicking a recommendation replaces/fills `PlayerInput`, focuses it, and does **not** submit;
5. player can edit the prefilled text before sending;
6. manual free-form input works identically when recommendations are present/absent/generating/failed;
7. eventual Send uses the existing send/d20 route with no bypass;
8. recommendation input contains only bounded accepted player-visible Conversation material;
9. hidden World/actor/Knowledge/Agency/Evolution/Source canaries never enter recommendation request;
10. no recommendation output is persisted into Conversation/World/Timeline/information_curation/SQLite;
11. malformed JSON fails soft;
12. 4 actions / 6 actions / duplicate actions / oversized action / extra keys fail soft without heuristic filling;
13. valid exact bounds pass;
14. recommendation Provider failure/cancel/timeout does not affect Narrative/composer/other background lanes;
15. new Player foreground action clears old recommendations immediately;
16. late callback after the player starts another turn cannot republish stale options;
17. Regenerate/correction clears old options and accepted replacement generates a new current set;
18. cancelled/failed replacement does not publish unaccepted recommendations;
19. Restore clears old options and one fresh current-prefix request may repopulate them;
20. stale pre-Restore callback cannot publish;
21. reopen can regenerate current recommendations with at most one request and no history mutation;
22. repeated render/resize/editing causes zero recommendation calls;
23. no accepted GM Narrative → zero recommendation calls;
24. recommendation failure leaves free-form input usable;
25. G2 streaming/cancel/retry/regenerate tests remain green;
26. G4-07 opening/continuation tests remain green;
27. Public d20 action flow remains green;
28. MW-017/MW-018 and relevant G5 regression suites remain green;
29. maximized / 1280×720 / 960-class layout has no horizontal overflow and Narrative remains the dominant surface;
30. `git diff --check` clean;
31. Windows Desktop export PASS.

## 15. Real Provider vertical

After focused/offline gates pass, perform at least one bounded real configured Provider validation if credentials are available.

Use isolated task-owned Game state.

Prefer validating both:

```text
accepted opening → 5 recommendations
then
click/prefill or a normal accepted turn → fresh 5 recommendations
```

At minimum one real successful recommendation request must show exactly five useful player-visible actions.

Record:

- configured model;
- exact request count;
- sanitized exact request/response or bounded evidence;
- five generated actions;
- malformed/failure honestly if encountered;
- Owner production settings/Source/Games fingerprint unchanged.

Do not retry repeatedly merely to obtain a flattering sample; no silent Provider switch and no heuristic repair.

## 16. Product Value Acceptance / combined Owner UAT

Engineering tests cannot declare product success.

After Engineering PASS + integration + canonical Owner build handoff, Owner will test **MW-018 People + MW-019 Recommendations together**.

MW-019 Owner UAT should verify:

```text
opening / completed GM turn
→ five recommendations appear reasonably quickly
→ suggestions are useful and varied enough to inspire play
→ no hidden/omniscient information is obvious
→ they feel optional, not like a forced five-choice game
→ click fills composer without sending
→ text can be edited freely
→ manual free-form action remains effortless
→ next/regenerated/restored state never shows stale suggestions
```

Owner product question:

> **“这些推荐让我更容易开始行动，同时我仍然觉得自己什么都能做吗？”**

MW-018 People UAT remains pending and is bundled into the same final playable build for convenience; each feature keeps its own PASS/NOT PASS lineage.

## 17. Explicit non-scope

Do not implement:

- recommendation auto-send;
- hard branching/choice-only gameplay;
- recommendation ranking/probability/best-choice UI;
- semantic diversity validators;
- recommendation history/journal;
- persistent recommendation state;
- personalization/training from click history;
- action hotkeys;
- generic Bounded Action Intent platform;
- MW-013 Declarative UI Host;
- new SQLite table/migration;
- hidden Runtime data enrichment;
- unrelated People/UI polish.

## 18. Git / evidence / return

Use required task worktree. Do not modify the Owner canonical checkout as implementation candidate.

Before final evidence:

```text
git rev-parse HEAD
git status --short
git diff --check
```

Return exact:

- candidate SHA;
- refreshed implementation/governance bases;
- changed files;
- recommendation process/public seam design;
- exact player-safe input builder/bounds;
- exact response validator;
- lifecycle/currentness/cancellation design;
- UI/prefill implementation;
- focused/regression/layout/export results;
- real Provider result;
- clean status.

Highest allowed status:

**READY FOR INDEPENDENT REVIEW**

Do not merge main. Do not declare Product PASS. Do not install unreviewed candidate into `D:/AI/Projects/my-world`.
