# MW-021 Independent Review IR1

Date: 2026-09-08
Work Item: MW-021 Narrative Scroll Navigation & Reopen Position
Verdict: **ENGINEERING PASS_WITH_NOTES**
Product verdict: **PENDING bounded Owner confirmation**

## 1. Reviewed identity

- Formal product-code base: `5e5fd006fd17683ae811b17138df76a18b0b96aa`
- Starting/task-packet HEAD: `9239fb10539898fd3d98d256214dd02df73696fa`
- Implementation HEAD: `4978341809424ac1be3c12ba59974cc9c5468995`
- Submitted final candidate: `f9452e825e74e27e2cacd500723e87da5aafc592`
- Task: `docs/tasks/MW-021_NARRATIVE_SCROLL_NAVIGATION_TASK.md`

Current implementation main was refreshed before review and was still exactly `9239fb10539898fd3d98d256214dd02df73696fa`, i.e. the reviewed product baseline plus the already-authorized MW-021 Task Packet and no newer production delta.

## 2. Independent diff finding

Starting HEAD -> final candidate is a strict descendant. Production change is confined to:

`src/ui/叙事对话视图.gd`

The implementation does not modify Conversation/domain persistence, World, Timeline, Save, People, Important Experiences, Recommendations, Context Budget, Provider lanes, or global Theme.

The production change is bounded to the accepted outcome:

1. obtain the existing `NarrativeScroll` vertical bar and give it an 18px local practical hit width plus local grabber styling using existing Palette colors;
2. reserve the bar width in readable Narrative content sizing so the new hit target does not create horizontal overflow;
3. change session initialization from direct restored-entry rendering to the already-existing `redraw_from_conversation()` path, which initializes follow-latest and schedules bottom positioning after full history reconstruction;
4. strengthen `_follow_scroll_if_needed()` by waiting for layout settlement and re-checking both `_follow_scroll` and bound Conversation before applying the bottom position.

The existing `_on_narrative_scroll_changed()` near-bottom rule remains the semantic owner of manual reading vs follow-latest. No unconditional continuous auto-scroll was introduced.

## 3. Acceptance review

### AC-01 Visible/draggable main scrollbar — PASS

The main Narrative scrollbar is a real Godot scrollbar, not a simulated extra control. Local minimum width is 18px and the focused test verifies a true overflowing history, visible in-tree range, non-ignored mouse filter, and an actual Viewport mouse drag that changes the bar value.

### AC-02 Continue/reopen defaults to latest — PASS

`_initialize_session()` now routes the rebuilt durable Conversation through `redraw_from_conversation()`. The follow helper waits for layout/rich-text/container settlement and then lands on the current bottom. Focused durable reopen and explicit rebind both prove bottom/latest position.

### AC-03 Manual history reading remains respected — PASS

When the Player moves sufficiently above the near-bottom threshold, `_follow_scroll` becomes false. Normal accepted append does not snap the user to bottom. Returning near bottom re-enables follow-latest. A queued async follow is also cancelled effectively when the Player scrolls during its wait because the helper re-checks `_follow_scroll` immediately before writing the bar position.

### AC-04 Short history remains normal — PASS

Empty/short histories remain at valid origin with no overflow geometry failure.

### AC-05 Presentation-only — PASS

Focused snapshots compare durable accepted Conversation, persistence projection, World, current Game head, Timeline fixture, Saves and Recovery projection across reopen/scroll/drag/rebind/redraw operations. UI scroll operations do not mutate those domains.

## 4. Evidence review

Focused test uses task-owned real SQLite plus the production `main.tscn`, with 32 durable accepted turns and enough text to exceed four viewports.

Reported and inspected final result:

- headless: 101 checks / 0 failures;
- real-window: 101 checks / 0 failures;
- no Provider calls;
- long-history geometry: max `8656`, page `327`, width `18`, reopen value at latest bottom;
- actual mouse drag changes history position;
- manual reading / near-bottom follow / pending-follow cancellation / Continue-rebind / Restore / short history all pass.

Directly affected regression evidence contains 10 suites: 9 exit 0; G3-03 exits 1 for one pre-existing Context assertion. The exact same assertion is present and failing on Starting HEAD before MW-021, while its Narrative recovery/reopen/Regenerate/Send/startup-failure UI checks remain passing. Therefore it is not an MW-021 regression.

MW-003 retains its pre-existing exit resource diagnostics, likewise reproduced at baseline.

Final Godot import and fresh Windows export are reported exit 0 with no new script/parse/export errors.

## 5. Scope / architecture review

No global theme redesign, persisted scroll position, application-shell decomposition, Provider work, Dynamic UI, Debug Mode or unrelated Package-0 reopening was introduced.

No new module dependency or authority seam was added. This remains a local first-party Narrative presentation correction.

## 6. Notes / residual product risk

Non-blocking notes:

1. the 18px hit target and grabber treatment are engineering-validated, but real Owner mouse/system-scale comfort still requires the explicitly planned bounded confirmation;
2. full-history reconstruction intentionally resets to latest/bottom; this revision does not persist a prior reading position across Continue/reopen, by design;
3. G3-03's stale Context assertion and MW-003 resource-exit diagnostic remain separate existing debt and are not authorized fixes here.

## 7. Review verdict

**ENGINEERING PASS_WITH_NOTES**

Integration is authorized if implementation `main` is still the exact reviewed Starting HEAD and the reviewed candidate is a strict descendant. Use non-force fast-forward only. After integration, prepare a fresh Owner build and request only bounded confirmation of:

- visible/draggable main Narrative scrollbar;
- Continue/reopen lands at latest progress;
- manual upward reading is not continuously snapped back, and follow resumes near bottom.

Do not require replay of MW-018 / MW-015 / MW-019 UAT. Product PASS for MW-021 remains Owner-only.
