# MW-018 R1 Integration Verification

Date: 2026-09-07
Work item: MW-018 / Revision 1
Status: **INTEGRATED / ENGINEERING PASS_WITH_NOTES**

## Integration identity

- Pre-integration `main`: `fc308e8ee4347ddb8a67e40360f8ce84222d437b`
- Submitted candidate: `8f48f3cc96a01b1c132c2ccb583193df9c93511a`
- Independent Review commit: `97c1862f3e0c9809e8b8879130b0aade2a848681`
- Integration method: non-force fast-forward of `main` to the reviewed commit
- Review: `docs/mw018/MW-018_R1_INDEPENDENT_REVIEW_IR1.md`

`main` was confirmed to be the exact reviewed base before integration, and the reviewed branch was a strict descendant. No merge conflict, rewrite, force push or unreviewed production delta was introduced.

## Result

MW-018 R1 is now integrated into `main` with the following bounded correction:

- accepted Player and GM person references may both form exact identity evidence;
- an already-existing stable off-screen actor may become a People candidate through Player recall/reference;
- legitimate GM/world-semantic off-screen person establishment may materialize and bind through the existing actor path;
- Player-only unresolved assertions cannot mint actor existence;
- no display-name/fuzzy/first-match identity authority;
- card worth remains model-curated;
- v0.1 receipt history remains readable; v0.2 is additive;
- no new People Provider call, SQLite table or historical backfill.

## Remaining product gate

Integration does **not** grant Product PASS. MW-018 remains pending the focused Owner re-UAT that will occur after the current Package 0 correction train (MW-015 R1 + MW-019 R1) is complete.

Re-UAT must explicitly watch for over-restriction: if naturally known/off-screen people are still systematically suppressed by identity guardrails, reopen the architecture rather than stacking additional rules.
