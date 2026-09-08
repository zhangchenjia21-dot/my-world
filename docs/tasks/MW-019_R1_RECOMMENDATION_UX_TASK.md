# TASK｜MW-019 Revision 1｜Concise Recommendation Labels + Detailed Drafts + Readability

Type: product-facing revision implementation  
Work Item: **MW-019**  
Revision: **R1**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Product Owner / focused re-UAT: **Owner**  
Task Branch: `mw-019-r1-recommendation-ux`  
Required Worktree: `D:/AI/Projects/.worktrees/my-world/mw-019-r1-recommendation-ux`  
Formal Code Base: `5168893109ef7d22ad3ef6b392988d602304e54c`  
Governance Base at shaping: `3f971103099e4b2d025704ec6f76a7371477002f`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Product outcome

Fix the confirmed Owner-UAT problems in the first Five Recommended Actions implementation.

After R1, the player should experience:

```text
GM Narrative accepted
→ five concise, easy-to-scan recommendation labels
→ each label represents one standalone alternative next action
→ click one label
→ its detailed editable natural-language action draft fills PlayerInput
→ click never sends
→ Player may edit / ignore / replace freely
```

The recommendation/composer area must also be materially larger and more comfortable to read than the current compact implementation.

## 2. Why now

Package 0 Owner UAT found four product defects in MW-019:

1. full action prose is squeezed into the recommendation controls;
2. the player wants broad action direction first, detailed wording only after click;
3. five outputs can behave like one plan split into five sequential sentences/steps;
4. recommendation/composer controls are too small/cramped for comfortable play.

Formal UAT evidence:

`docs/uat/G6_PACKAGE0_OWNER_UAT_U1.md`

MW-018 R1 and MW-015 R1 are already reviewed/integrated before this branch base. This is the final product revision in the Package 0 correction train; a separate context-budget correctness task follows before Owner re-UAT.

## 3. Primary Purpose / Core Value

Current product core value remains:

> **长期持续 AI 世界 + 优秀自由 AI GM + 原生 RPG 游戏体验。**

Protected product rule:

> **Five recommended actions != five allowed actions.**

INV-PRODUCT-01:

> Recommendations must lower the friction of deciding what to do next without turning natural-language play into a cramped branching-choice UI.

## 4. Authority / Source Manifest

Refresh both mains before implementation. If current sources supersede this packet, STOP.

1. Owner current explicit instruction.
2. `Vibe-Coding/AGENTS.md` + Owner collaboration preferences.
3. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md` — current.
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` — current.
5. `Vibe-Coding/my world/architecture/ui/G6_FIVE_RECOMMENDED_ACTIONS_UAT_CORRECTION_V1_0_DECISION.md` — **FROZEN correction authority**.
6. `Vibe-Coding/my world/architecture/ui/G6_FIVE_RECOMMENDED_ACTIONS_V1_0_DECISION.md`, except where superseded by item 5.
7. `docs/uat/G6_PACKAGE0_OWNER_UAT_U1.md`.
8. `docs/mw019/MW-019_INDEPENDENT_REVIEW_IR1.md` + current implementation.
9. repository `AGENTS.md`.
10. current code/tests.

Do not treat the queued Context Budget correction or future Package 1 Debug Mode as part of this task.

## 5. Read first

Initial workset:

1. `AGENTS.md`
2. this Task Packet
3. `docs/uat/G6_PACKAGE0_OWNER_UAT_U1.md`
4. current `src/行动推荐/` L0-L3 files
5. current recommendation rendering/prefill logic in `src/ui/叙事对话视图.gd`
6. recommendation nodes in `src/main.tscn`
7. current MW-019 tests including Send/d20/currentness coverage
8. current Windows/export smoke path if needed

Expand only when concrete implementation evidence requires it.

## 6. Decision Digest / Invariants

### DEC-01｜One recommendation call returns paired label + draft

Keep the current one-call architecture.

One successful Action Recommender response produces exactly five paired items:

```text
label
→ concise scan-level action direction

draft
→ detailed editable natural-language action text
```

Clicking a recommendation does **not** trigger a second Provider call.

### DEC-02｜Revised response shape

Use the frozen corrected first-party shape conceptually:

```json
{
  "actions": [
    {"label":"简短方向","draft":"详细可编辑草稿"},
    {"label":"简短方向","draft":"详细可编辑草稿"},
    {"label":"简短方向","draft":"详细可编辑草稿"},
    {"label":"简短方向","draft":"详细可编辑草稿"},
    {"label":"简短方向","draft":"详细可编辑草稿"}
  ]
}
```

Machine limits:

- exact one-key top-level object;
- exactly five items;
- each item exact `label` + `draft` keys;
- both strings non-empty after trim;
- label <= 48 Unicode chars;
- draft <= 400 Unicode chars;
- exact duplicate labels invalid;
- exact duplicate drafts invalid;
- bounded response ceiling may increase narrowly from the old 8 KiB only as needed for five drafts;
- parser depth may increase only as needed for this exact shallow nested object structure.

Do not add semantic repair, missing-item filling, fence stripping, hidden retry or Provider fallback.

### DEC-03｜Visible recommendation control shows label only

The recommendation area must display only `label` as the primary control text.

Do not put full `draft` prose inside the recommendation button/chip.

Do not Program-generate the label by truncating or summarizing the draft. Both are model outputs.

### DEC-04｜Click fills detailed draft only

On click:

```text
selected recommendation.draft
→ replaces existing PlayerInput text
→ PlayerInput receives focus
→ caret moves to editable end position
→ no send / no d20 / no accepted Conversation mutation
```

Existing Send / Ctrl+Enter / Public d20 path remains authoritative.

### DEC-05｜Five standalone alternatives are model-owned semantics

Prompt must orient the model to produce:

> **five independently selectable alternative next actions, not one plan split into five steps/sentences.**

Each item should be usable as the player's next submitted action on its own.

The model may naturally offer different approaches when the scene supports them, but there are no fixed categories or quotas.

Program must not implement:

- semantic similarity/diversity score;
- category classifier;
- social/combat/exploration quotas;
- ranking/best-choice logic;
- plan-step detector;
- aggressiveness/style balancing.

Exact duplicate structure checks are allowed.

### INV-FREEDOM-01｜Free-form remains primary

Player can always ignore all recommendations and type arbitrary natural-language action.

Five recommendations do not define the legal action set.

### INV-SAFETY-01｜Player-safe input unchanged

R1 keeps the current bounded accepted Conversation input/currentness seam.

Do not add raw World, private actor material, NPC-private Knowledge, Agency/Evolution private state, Source-current hidden data, curation storage, IDs/hashes/receipts merely to improve recommendations.

### INV-PERSONALIZATION-01｜Character-guided recommendations remain later

Do **not** add Character/personality context or accepted-action personality feedback in this revision.

Those remain Package 2 after Debug Mode.

### INV-LIFECYCLE-01

Preserve current lifecycle/currentness behavior:

- only accepted GM Narrative creates opportunity;
- foreground action/d20 clears/cancels stale recommendation state;
- Regenerate/correction clears old guidance;
- Restore/reopen may request one current fresh set;
- stale callbacks cannot publish;
- render/resize/tab/click/input editing trigger zero Provider calls;
- recommendation failure never blocks free-form play.

## 7. Bounded readability correction

Current Owner feedback is not final-art polish; it is a usability defect.

R1 must make the recommendation/composer area materially easier to read and click.

Required direction:

- recommendation heading/control fonts larger than the current compact 12/13px treatment;
- recommendation controls visibly taller with more internal padding than the current ~28px compact buttons;
- do not force tiny three-column recommendation controls merely to conserve vertical space;
- ordinary desktop widths should use a comfortable one/two-column layout;
- narrow widths may wrap to one column rather than shrinking text;
- short labels should wrap/read naturally rather than hide essential meaning behind aggressive clipping;
- PlayerInput/composer typography and related primary control sizing receive the minimum bounded increase needed for comfortable long-form editing;
- no horizontal overflow at supported widths.

Prefer existing theme/layout mechanisms. Do not introduce a global design system/refactor solely for this revision.

Exact pixel/font choices may be tuned by current scene evidence, but automated UI tests should assert a meaningful increase over the old compact baseline rather than only checking node existence.

## 8. Scope

Allowed:

- Action Recommendation L0 contract update for paired objects;
- shallow parser adaptation;
- recommendation prompt/material wording needed for label+draft and standalone-alternative semantics;
- L2/L3 ephemeral state adaptation;
- Narrative Host recommendation rendering/prefill adaptation;
- bounded recommendation/composer size/layout changes in existing UI/scene/theme seams;
- focused tests/regressions;
- bounded real Provider validation;
- Windows export validation;
- implementation return report.

Prohibited:

- Character/personality-guided recommendations;
- OOC / GM Guidance;
- accepted action → Character feedback;
- Context Budget bug fix;
- Debug Mode/failure diagnostics expansion;
- general Structured Output framework;
- response fence stripping or parser repair heuristics;
- extra click-time Provider call;
- recommendation persistence/history;
- semantic diversity classifier/ranker;
- global UI redesign;
- Dynamic UI Host;
- new SQLite tables;
- unrelated shell refactor.

## 9. Deliverables

1. Production paired `label + draft` recommendation contract/path.
2. Updated player-safe recommender prompt for five standalone alternatives.
3. Recommendation UI showing short labels only.
4. Click-to-detailed-draft prefill with no auto-send.
5. Bounded readability sizing/layout correction in recommendation/composer area.
6. Focused automated tests.
7. Existing MW-019 lifecycle + Send/d20 regression coverage.
8. Bounded real Provider validation evidence.
9. Windows export validation.
10. `docs/mw019/MW-019_R1_IMPLEMENTATION_RETURN.md`.

## 10. Engineering Acceptance

At minimum prove:

AC-01 — strict successful response requires exactly five `{label,draft}` items.

AC-02 — malformed/extra/missing/type-invalid/oversized/duplicate label/draft output fails soft and does not block composer.

AC-03 — old five-string response is no longer silently interpreted as the new paired contract.

AC-04 — only label text is rendered in the recommendation control; full draft is not displayed as the control body.

AC-05 — clicking a label fills its exact paired draft, not the label, and never sends.

AC-06 — Player can edit filled draft and submit through the unchanged normal Send/Ctrl+Enter path.

AC-07 — Public d20 path remains unchanged and recommendation click does not invoke it.

AC-08 — free-form input without clicking recommendations remains effortless and authoritative.

AC-09 — foreground action, Regenerate/correction, Restore and stale callbacks preserve currentness exactly.

AC-10 — clicking/rendering/resizing/editing triggers zero additional Provider calls.

AC-11 — recommendation input remains bounded player-visible accepted Conversation only.

AC-12 — Program contains no semantic diversity/ranking/category classifier.

AC-13 — responsive UI tests prove recommendation controls/composer are materially larger/more readable than the old compact baseline and do not overflow supported widths.

AC-14 — no recommendation persistence/new SQLite table/new Provider lane.

AC-15 — MW-018 R1 and MW-015 R1 directly affected regressions remain green.

## 11. Real Provider validation

After deterministic gates pass, run a small configured Provider validation in isolated state.

Use one or at most two fixed player-visible scenes, including at least one scene where a weak model instruction could plausibly split one plan into sequential steps.

Record the exact raw response and normalized five pairs.

Validation goal:

- five concise labels;
- each label meaningfully summarizes its paired detailed draft;
- each draft is immediately usable/editable;
- the five outputs read as selectable next-action alternatives rather than obvious sequential fragments;
- no hidden information/guaranteed outcomes.

Do **not** implement a Program semantic checker to make this test pass. The test/report may record semantic observations for GPT/Owner review.

Do not retry or mutate the prompt/result invisibly after a poor response. If the configured model returns malformed/fenced JSON under the existing strict policy, report that fact rather than weakening the parser in this task.

## 12. Product Value Acceptance

Engineering/Reviewer may only return **READY FOR OWNER UAT**, never Product PASS.

Focused Owner re-UAT occurs only after:

```text
MW-018 R1 integrated
+ MW-015 R1 integrated
+ MW-019 R1 integrated
+ Core Context Budget Accounting Correction integrated
→ fresh Owner build
```

Owner must judge:

- short labels are genuinely easy to scan;
- clicking produces useful detailed editable text;
- five recommendations feel like five choices of direction, not one paragraph chopped up;
- free-form play still feels primary;
- sizing/spacing is comfortable enough for sustained play.

## 13. Validation order

Run in order:

1. focused contract/parser/UI tests;
2. current MW-019 recommendation vertical;
3. Send/Ctrl+Enter/Public d20 regressions;
4. lifecycle/currentness Restore/Regenerate tests;
5. directly affected MW-018 R1 / MW-015 R1 regressions;
6. bounded real Provider validation;
7. final Godot import + Windows export.

## 14. Git / Integration

- Work only from the required branch/worktree.
- Record exact starting HEAD/status/worktrees.
- Preserve unknown dirty/local work; never reset/clean/force.
- Do not modify `main` directly.
- Commit and push implementation + evidence to `mw-019-r1-recommendation-ux`.
- Refresh both mains before final push; absorb only compatible governance changes.
- Return exact implementation HEAD and final candidate HEAD.
- Keep worktree through GPT Independent Review + integration verification.

## 15. Stop / Return Conditions

STOP and report instead of guessing if:

- current governance supersedes the frozen correction;
- implementation requires a second click-time model call to satisfy the requested UX;
- the only way to create independent alternatives appears to require Program semantic classification/ranking;
- a broad UI/shell rewrite becomes necessary rather than a bounded recommendation/composer correction;
- the queued Context Budget/Debug work becomes entangled with this revision.

Otherwise return only after evidence is committed/pushed and status is **READY FOR INDEPENDENT REVIEW**.
