# MW-021 Integration Verification

Date: 2026-09-08
Work Item: MW-021 Narrative Scroll Navigation & Reopen Position
Status: **INTEGRATED / ENGINEERING PASS_WITH_NOTES**

## Integration identity

- Formal product-code base: `5e5fd006fd17683ae811b17138df76a18b0b96aa`
- Pre-integration `main` / task-packet HEAD: `9239fb10539898fd3d98d256214dd02df73696fa`
- Implementation HEAD: `4978341809424ac1be3c12ba59974cc9c5468995`
- Submitted candidate: `f9452e825e74e27e2cacd500723e87da5aafc592`
- Independent Review commit: `8e2c9fa616b11c4a0e086f0cea7d1c450df4c078`
- Review: `docs/mw021/MW-021_INDEPENDENT_REVIEW_IR1.md`
- Integration method: non-force fast-forward of `main` to the reviewed commit

Immediately before integration, `main` was confirmed to be the exact reviewed Starting HEAD, and the reviewed commit was a strict descendant. No conflict, rewrite, merge synthesis, force push or unreviewed production delta was introduced.

## Integrated result

MW-021 now provides the bounded first-party Narrative UX correction:

- long Narrative history exposes a visible/draggable local vertical scrollbar with a practical 18px hit width;
- Continue/reopen/full current-history reconstruction defaults to latest/bottom after layout settles;
- deliberate manual upward reading disables follow-latest for ordinary incremental updates;
- returning near bottom restores follow-latest;
- pending async follow cannot overwrite a manual scroll or a newly bound Conversation;
- scroll/reopen presentation does not mutate Conversation, World, Timeline or Save truth;
- no persistent scroll position, Provider call, global Theme redesign or unrelated product work was introduced.

## Review notes retained

- G3-03 has one pre-existing Context assertion failure that is identical at Starting HEAD and candidate; it is not an MW-021 regression.
- MW-003 retains an existing resource-exit diagnostic reproduced at baseline.
- Real Owner mouse/system-scale comfort and reopen feel still require the planned bounded product confirmation.

## Remaining gate

MW-021 does not receive Product PASS from engineering evidence.

Next and only Package-0 gate:

```text
fresh Owner build from current reviewed main
→ bounded Owner confirmation
  1. scrollbar visible/draggable
  2. Continue/reopen lands at latest
  3. manual upward reading is respected; near-bottom follow resumes
→ explicit Owner PASS
→ Package 0 close
```

Do not replay MW-018 / MW-015 / MW-019 UAT; those already hold Product PASS from U2.
