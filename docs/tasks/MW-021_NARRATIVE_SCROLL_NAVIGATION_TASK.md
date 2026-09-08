# TASK｜MW-021｜Narrative Scroll Navigation & Reopen Position

Type: bounded product UX correction  
Work Item: **MW-021**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Owner confirmation: **bounded focused confirmation after integration**  
Formal Code Base: `5e5fd006fd17683ae811b17138df76a18b0b96aa`  
Required task branch: `mw-021-narrative-scroll-ux`  
Required worktree: `D:/AI/Projects/.worktrees/my-world/mw-021-narrative-scroll-ux`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Product outcome

Fix the two Narrative Host usability findings from Owner Re-UAT U2:

1. long main chat must expose a visible, directly draggable vertical scrollbar;
2. Continue/reopen of an existing Game must default to the latest/current Narrative position after restored history is laid out.

At the same time preserve the existing behavior that lets a Player deliberately scroll upward and read older history without being continuously snapped to the bottom.

## 2. Authority

Refresh both mains before implementation. Read, in order:

1. current Owner instruction / U2 verdict;
2. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md` current;
3. `Vibe-Coding/my world/docs/uat/G6_PACKAGE0_OWNER_REUAT_U2.md` v1.1;
4. `Vibe-Coding/my world/architecture/ui/G6_NARRATIVE_SCROLL_NAVIGATION_UAT_CORRECTION_V1_0_DECISION.md`;
5. repo `AGENTS.md` stable rules;
6. current code/tests.

Current governance supersedes stale duplicated stage tables.

## 3. Current source evidence to confirm

GPT source inspection on the formal base found:

- `NarrativeScroll` is a `ScrollContainer`, but unlike the recommendation-local scrollbar it has no explicit local practical scrollbar width;
- `_on_narrative_scroll_changed()` already tracks whether the Player is near the bottom;
- `_follow_scroll_if_needed()` already follows the latest content only when `_follow_scroll` is true;
- `redraw_from_conversation()` explicitly sets `_follow_scroll = true` and follows after redraw;
- `_initialize_session()` rebuilds restored entries but currently does not perform the equivalent reopen-to-bottom step.

Codex must verify this remains true before editing. If a materially different root cause is found, stop and report rather than broadening the task silently.

## 4. Required behavior

### AC-01｜Visible draggable main scrollbar

When Narrative history overflows the viewport:

- the main `NarrativeScroll` vertical scrollbar is visibly rendered;
- it has a practical local width/hit target suitable for mouse dragging;
- dragging it can directly move through long history;
- wheel/keyboard behavior is not removed.

Do not globally redesign theme/scrollbars.

### AC-02｜Continue/reopen defaults to latest

For an existing Game with overflow history:

```text
bind/reopen session
→ rebuild accepted Conversation blocks
→ allow layout/scroll range to settle
→ set initial follow state to latest
→ land at bottom/latest accepted progress
```

The Player should not need to manually scroll from the first message after Continue.

### AC-03｜Manual history reading remains respected

During an active session:

- when the Player deliberately scrolls sufficiently upward, `_follow_scroll` becomes false;
- ordinary incremental Narrative rendering must not force the scrollbar back to bottom;
- returning to near-bottom re-enables normal follow-latest behavior.

Do not replace this with unconditional auto-scroll.

### AC-04｜Short history remains normal

A short/non-overflowing conversation remains usable and does not produce broken empty scroll geometry.

### AC-05｜Presentation only

Scroll behavior must not mutate:

- accepted Conversation;
- World state;
- Timeline nodes;
- Save data;
- recommendations;
- Provider/model state.

No scroll-position persistence is required.

## 5. Scope

Allowed:

- narrow `NarrativeScroll` / Narrative view presentation changes;
- local scrollbar width/min-size treatment;
- narrow reopen initialization/follow scheduling needed for layout-settled bottom positioning;
- focused deterministic UI tests;
- directly affected Conversation/Narrative UI regressions;
- Windows export validation under current release policy.

Prohibited:

- global theme redesign;
- persistent scroll-position feature;
- Conversation/domain/persistence changes;
- Recommendation semantics/layout redesign except incidental test compatibility;
- People / Important Experiences / Context Budget changes;
- Debug Mode / Dynamic UI work;
- broad Application Shell decomposition;
- Provider calls for this deterministic UI correction.

## 6. Validation

Focused test must use enough accepted Narrative history to actually overflow.

At minimum prove:

1. vertical bar range exists (`max/page` indicates overflow) and local bar width is practical;
2. a direct scrollbar value change can move away from the bottom;
3. Continue/rebind/reopen of durable history settles at latest/bottom by default;
4. manually scroll upward, then append/render ordinary incremental material: position is not forced to bottom while follow is false;
5. return near bottom and append/render: follow-latest resumes;
6. redraw/Restore paths that intentionally reconstruct current history remain currentness-safe;
7. no accepted-history/world/timeline mutation from UI scroll behavior;
8. short history still works.

Run focused first, then directly affected existing Narrative/Conversation/UI suites, then final import/export if production scene/script changes.

No real Provider call is required.

## 7. Git / return

- Create/use exactly `mw-021-narrative-scroll-ux` from Formal Code Base.
- Work only in required worktree.
- Preserve unknown local files; no reset/clean/force.
- Do not modify `main` directly.
- Commit + push implementation/evidence to task branch.
- Write `docs/mw021/MW-021_IMPLEMENTATION_RETURN.md`.
- Return exact Starting HEAD, Implementation HEAD, Final candidate HEAD, tests, export result and residual risks.
- Do not merge main.
- Highest state: **READY FOR INDEPENDENT REVIEW**.

## 8. Package 0 closure rule

U2 already grants Product PASS to MW-018 R1, MW-015 R1 and MW-019 R1. MW-021 is the only remaining Package-0 product correction.

After MW-021 Engineering PASS/integration, Owner only needs a bounded confirmation of the two scroll behaviors; do not require a full replay of prior Package-0 UAT unless implementation scope materially expands.
