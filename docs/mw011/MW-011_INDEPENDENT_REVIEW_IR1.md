# MW-011 Independent Review IR#1 — G6 RPG Host ViewModel Baseline

Status: **ENGINEERING PASS — READY TO INTEGRATE / OWNER FOCUSED UAT AFTER INTEGRATION**  
Work Item: **MW-011**  
Revision: **1**  
Review-Round: **IR#1**  
Reviewer: **GPT**  
Reviewed candidate: `066aff2487cd1059af1943eb5282bf5cfe2c89fb`  
Candidate parent: `a0e26a676cbd09658e7ee2a0a522b19efa2330ef`  
Task: `docs/tasks/MW-011_G6_RPG_HOST_VIEWMODEL_BASELINE_TASK.md`  
Architecture: `Vibe-Coding/my world/architecture/ui/G6_RPG_HOST_VIEWMODEL_V0_1_DECISION.md`

## 1. Verdict

**ENGINEERING PASS.**

The candidate satisfies the frozen first-G6 vertical:

```text
existing authoritative/safe data
→ presentation-only ViewModel
→ real Player Host + World Surface consumers
```

It does not fabricate new RPG domain truth and does not prematurely introduce a generic Declarative UI Host, event bus, reactive store, persistence schema or Provider-owned presentation summary.

Because `main` advanced after the candidate was cut only to register the Owner-inserted MW-012 task/content packet, this review does **not** move `main` to the candidate SHA. The implementation branch must first reconcile/rebase onto refreshed current `main`; no semantic code change is requested by this review.

## 2. Actual code reviewed

Candidate production diff is limited to the intended seam:

- `src/rpg视图模型/L1_器件层/RPG主机视图模型.gd`
- `src/rpg视图模型/L3_外交层/RPG主机视图模型公开接口.gd`
- `src/应用壳.gd`
- `src/main.tscn`

plus focused test/evidence files and Godot `.uid` files.

No persistence/domain/provider files were modified.

## 3. ViewModel boundary — PASS

The new device is deterministic, side-effect free and presentation-only. It consumes:

1. the existing MW-009 player-safe projection output; and
2. current durable accepted Conversation entries.

Its bounded output contains only:

- player display name;
- selected profile label;
- world display name;
- selected Entry label;
- current player-known facts;
- latest four non-empty Player-authored actions;
- deterministic Player-turn count excluding GM-only Opening.

The ViewModel does not expose raw omniscient `world_state`, NPC Knowledge, raw semantic consequences, Agency, World Evolution, instructions, style material, IDs/hashes/fingerprints or Public-d20 control payload.

The L3 facade obtains the MW-009 safe projection first and then derives only Conversation-owned presentation data. Leaf Host rendering consumes the resulting ViewModel fields rather than filtering omniscient truth itself.

## 4. Player Host — PASS

The Player Host now materially answers the frozen v0.1 questions:

- who the protagonist is;
- which World / Entry the session belongs to;
- what the Player recently did;
- how many accepted Player turns have occurred.

Recent actions are bounded to four and retain current authored text. No HP/location/inventory/relationship/faction/quest/status values are fabricated merely to fill space.

## 5. World Surface / Save ownership — PASS

The World Surface now has exactly two bounded surfaces:

```text
概览
存档
```

Overview is the default and displays safe World/Entry identity, existing MW-009 Player-known facts and turn count. Existing G3 Save controls were moved under the Save surface without changing their domain/persistence owner or callback semantics.

No speculative Map/Faction/Relationship/Inventory/Quest tabs or generic navigation platform were added.

## 6. Currentness / Restore / reopen — PASS

The ViewModel is rebuilt from current Runtime + current durable Conversation rather than persisted separately.

The focused test uses real FinalCreate + real CurrentGameRuntime + real SQLite + real Shell and checks visible Host text/state. It covers:

- Opening excluded from Player-turn count;
- live update after accepted Player turns;
- Save creation through the existing UI/domain owner;
- normal Player Knowledge disclosure;
- hidden NPC Knowledge / Agency / Evolution / raw consequence exclusion;
- close/reopen deep-equal ViewModel reconstruction;
- Restore removing restored-away recent actions and Player-known facts;
- narrow/wide responsive behavior.

This is sufficient evidence that the new presentation data respects current timeline truth rather than forming a second durable store.

## 7. Regression / evidence assessment

Implementer reports:

- MW-011 focused test: 34 assertions, 0 failures;
- MW-009 regression: green;
- MW-010 integrated matrix: green;
- G3 Save UI regression: green;
- Narrative/d20/MW-005 related regressions: green;
- `git diff --check`: clean;
- Windows export validation: PASS;
- real Provider calls: 0;
- SQLite schema/table changes: none.

GitHub exposes no CI status for the candidate, so these runtime execution counts remain implementer evidence. GPT independently inspected the actual candidate diff, production ViewModel seam, Shell rendering/navigation code, scene migration and focused test assertions.

The two reported failures in `tests/g2_03_会话视图离线测试.gd` are documented as the pre-existing `.invalid` DNS-environment baseline and are outside the MW-011 transport-neutral diff.

## 8. Non-blocking advisories

### A. Toggle visual state

`OverviewTab` / `SaveTab` are independent `toggle_mode` buttons with code-enforced mutual exclusion when a tab becomes pressed. Clicking the already-selected tab can still toggle that button off while the current surface remains displayed. This does not corrupt `_world_surface_mode` or presentation truth, but may leave both tab buttons visually unselected. Treat as a small G6 UI polish item if Owner UAT notices it; it is not an IR blocker for this baseline.

### B. Long Player action text

Recent actions currently display full authored Player text with wrapping. Extremely long actions can make the Player Host vertically heavy. The task explicitly allows disposable presentation truncation later; do not alter authoritative Conversation bytes. Let real UAT determine whether a bounded visual excerpt is needed.

### C. Responsive proof granularity

The focused suite explicitly probes 900×600 and 1600×900 while the responsive implementation itself is unchanged. The packet also named 1280×720 as a regression target. Existing responsive behavior and related regressions remain green, so absence of a new dedicated 1280 assertion is non-blocking; include 1280 in focused Owner UAT/build smoke if convenient.

## 9. Integration instruction

No Revision 2 is required.

Reconcile the existing branch onto refreshed current `main` (which now also contains MW-012 governance/task files) without semantic changes to the reviewed MW-011 implementation. Keep the MW-011 worktree until the rebased/integrated SHA is verified. If rebase/merge produces a real code conflict, stop and report rather than resolving by changing frozen behavior silently.

After integration, MW-011 status becomes:

**ENGINEERING PASS — OWNER FOCUSED G6 UI UAT**.

Owner UAT should judge whether the new left/right information hierarchy is materially more useful than the final G5 screenshot; that product judgment is intentionally not self-certified by Engineering Review.
