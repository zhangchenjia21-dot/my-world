# MW-019 R1 Independent Review — IR1

Date: 2026-09-08  
Work Item: MW-019 / Revision 1  
Reviewer: GPT  
Verdict: **ENGINEERING PASS_WITH_NOTES**  
Product verdict: **NOT GRANTED — OWNER RE-UAT REQUIRED**

## 1. Review identity

- Formal reviewed base: `5168893109ef7d22ad3ef6b392988d602304e54c`
- Task branch start / packet HEAD: `3f71d1017ebf037b8e221784069568a4943dd675`
- Implementation HEAD: `23ba847169f901497a36fabe0514704969452d9e`
- Submitted final candidate: `5fbb946e4841fc24fcff463e36603443db1664a6`
- Current governance main at review start: `bfe1bce64ab919b17c94aa292b6969f84e6e3779`

Both mains were refreshed before review. The submitted branch is a strict descendant of the formal reviewed base. No newer governance decision supersedes MW-019 R1.

## 2. Independent scope review

Base → implementation → final candidate was reviewed rather than accepting Builder claims.

Production changes are bounded to:

- `src/main.tscn`
- `src/ui/叙事对话视图.gd`
- existing Action Recommendation L0–L3 files

No Character/personality/OOC/Debug Mode/Context Budget/Dynamic UI framework work was pulled into this revision. MW-018 R1 and MW-015 R1 production semantics remain outside the implementation delta.

## 3. Contract and semantic authority

PASS.

The old five-string contract becomes exactly five objects with exactly two string fields:

```json
{"label":"...","draft":"..."}
```

Program validation remains structural only:

- exactly five items;
- exact item shape;
- label <= 48 characters;
- draft <= 400 characters;
- nonempty normalized strings;
- exact duplicate labels invalid;
- exact duplicate drafts invalid;
- bounded response bytes / nesting.

No semantic diversity score, category quota, ranking, plan-step detector, keyword classifier or post-hoc semantic repair exists.

The model prompt now directly asks for five independently selectable next actions and explicitly says not to split one plan into five steps/sentences. It also says there are no fixed categories or quotas. This preserves Model Freedom First while correcting the Owner-UAT product target.

## 4. One-call label + draft flow

PASS.

The Action Recommender still issues one Provider request per accepted recommendation opportunity. The model returns all five labels and drafts in that response. Snapshot returns a deep copy of those pairs.

UI renders `label` only. Button press passes the already-current normalized pair to `_prefill_recommendation`, which writes `action.draft` into `PlayerInput`, focuses the composer and moves the caret to the end.

Click/render/resize/edit do not call the Provider and do not submit a turn. Existing Send/Ctrl+Enter/d20 paths remain authoritative.

## 5. Currentness / fail-soft review

PASS.

The existing full accepted-prefix binding, foreground interruption, correction/Regenerate, Restore, reopen, timeout/failure/cancel/malformed/oversize fail-soft lifecycle remains intact. The implementation changes nested snapshot copying only as required for `{label,draft}` pairs.

No recommendation persistence, World mutation, Conversation mutation, Timeline write or SQLite owner was added.

## 6. Player-safe input review

PASS.

The recommendation request still derives from the bounded player-visible accepted Conversation window. Character/personality, raw World state, private Knowledge/Agency/Evolution, Source-current, information_curation, IDs/hashes/receipts are not added.

This is important because Package 2 Character-guided Recommendations remains future work rather than being silently implemented here.

## 7. UI/readability correction review

ENGINEERING PASS; Product comfort remains Owner-owned.

The revision materially increases local recommendation/composer readability:

- heading 16px;
- recommendation labels 18px, >=48px button height, larger padding, wrapping rather than clipping;
- PlayerInput 20px, responsive 132–180px height;
- Send/Cancel 20px and >=72×48;
- one/two-column adaptation;
- dedicated bounded vertical scroll for the recommendation area.

The focused UI tests exercise 1600×900, 1280×720 and 960×540 plus maximized presentation, label-only rendering, no horizontal overflow, fifth-option scroll/focus reachability, composer visibility and zero additional Provider calls.

A 960×540 window intentionally exposes about one recommendation row and requires scrolling. This is not an Engineering blocker because all five remain reachable while Narrative/composer stay visible, but Owner must judge whether the small-window tradeoff feels acceptable.

## 8. Independent evidence assessment

The Builder reported 105 focused/UI checks and 13 affected regressions. Review inspected the actual test/evidence artifacts rather than treating the counts as proof.

The focused vertical independently covers:

- exact paired contract;
- deep-copy snapshot isolation;
- no gameplay mutation;
- player-safe input canaries;
- foreground cancellation and stale callbacks;
- correction/Regenerate/Restore/reopen;
- failure/cancel/timeout/sync/malformed/oversize fail-soft;
- UI click-prefill/edit/no-send/no-extra-call;
- responsive layout/readability bounds.

Committed regression results show all 13 suites exit 0 with no assertion/script/parse errors. The only recorded exit warnings are the already-known G4-08B and G4-07B diagnostic families.

Windows export/import evidence is present and the candidate contains no production changes after the implementation HEAD.

## 9. Real Provider evidence

PASS as bounded evidence, not Product proof.

Two configured Kimi K3 calls returned strict unfenced paired outputs without retry/fallback.

The first fixed scene deliberately presented a sequential procedure. Returned alternatives were independently selectable: submit application, read public notice, ask the doorkeeper, talk to the traveler, observe surroundings. This directly addresses the Owner finding that five recommendations could behave like one paragraph split into five pieces.

The second scene again returned separately selectable directions around public catalogue/application/counter/traveler/notice.

The raw evidence also exposes a real residual semantic risk: some drafts add plausible but not explicitly established scene detail (for example treating a traveler as having just finished archive consultation, or anticipating document/fee/rule details). This is not a private-data leak or World mutation, but it is recommendation grounding quality that Owner should watch.

Observed recommendation latency was roughly 10.5–23.5 seconds in the two real calls. Because recommendation generation remains parallel/fail-soft and free-form input is never blocked, this is not an Engineering blocker; sustained-play usefulness is a Product/UAT question.

## 10. Findings

### Blocking findings

None.

### Non-blocking notes

N-01 — **Grounding quality remains model-dependent.** Owner re-UAT should watch for recommendations that introduce unsupported scene specifics. Do not add Program semantic filters merely to suppress this; improve model context/prompt/structured-output seam only if normal play proves a recurring problem.

N-02 — **Latency remains observable.** 10.5–23.5s is acceptable for a non-blocking optional assistant at Engineering Gate, but Owner should judge whether options arrive early enough to be useful in normal pacing.

N-03 — **Small-window recommendation scrolling needs product judgment.** At 960×540 all options remain reachable, but the compact viewport shows limited rows.

N-04 — **Strict structured output retained.** Previous fenced/malformed real-output risk remains. This revision correctly did not sneak in fence stripping/retries/fallbacks; broader Structured Output Reliability stays later unless real UAT makes availability a blocker.

## 11. Acceptance matrix

- Short visible labels: PASS
- Exact detailed paired draft on click: PASS
- Click never sends: PASS
- Click triggers zero Provider calls: PASS
- Five independently selectable alternatives are model-owned: PASS
- No Program semantic diversity enforcement: PASS
- Free-form input remains primary: PASS
- Player-safe input boundary preserved: PASS
- Foreground/currentness/fail-soft lifecycle preserved: PASS
- Readability materially increased within bounded Narrative/composer scope: PASS
- Character-guided recommendation personalization not pulled forward: PASS
- No Debug/Context Budget/Generic UI framework expansion: PASS
- Owner product comfort / sustained recommendation quality: PENDING OWNER RE-UAT

## 12. Verdict

**ENGINEERING PASS_WITH_NOTES**.

MW-019 R1 is suitable for integration. It does not receive Product PASS. After integration, the already-proven Core Context Budget Accounting defect must be corrected before preparing the next combined Owner build.
