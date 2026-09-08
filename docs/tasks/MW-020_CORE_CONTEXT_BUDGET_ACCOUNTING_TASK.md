# TASK｜MW-020｜Core Context Budget Accounting Correction

Type: correctness implementation  
Work Item: **MW-020**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Owner re-UAT: **not separately required; integrated before Package-0 Owner build**  
Task Branch: `mw-020-context-budget-accounting`  
Required Worktree: `D:/AI/Projects/.worktrees/my-world/mw-020-context-budget-accounting`  
Formal Code Base: `f5dea508be2db5904c2d5ebc726b6f130d8c57fe`  
Governance Base at shaping: `e749710545d391ed0e4f33cc8f00859c1e4a3216`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Correct `WorldTurnContextProjector` so the existing 16,000-character GM world-context budget is enforced from the **actual assembled context text exactly once**.

After this task, a durable current NPC Agency action / World Evolution section must not disappear merely because earlier world-change text was double-counted. Conversely, a section that genuinely makes final assembled context exceed the existing limit must still be omitted.

## 2. Why now

The 2026-09-08 development audit reproduced a real accounting defect. GPT independently confirmed the current source has the same flaw.

Current product risk:

```text
NPC action/world evolution already happened durably
→ later GM context physically has room
→ projector double-counts earlier content
→ durable material omitted
→ GM may reason from an incomplete world
```

Package-0 product corrections MW-018 R1 / MW-015 R1 / MW-019 R1 are now Engineering PASS_WITH_NOTES and integrated. MW-020 is the final required correctness fix before preparing the next Owner build.

## 3. Primary purpose / core-value invariant

Current core value remains:

> **长期持续 AI 世界 + 优秀自由 AI GM + 原生 RPG 游戏体验。**

INV-PRODUCT-01:

> Durable current world consequences/actions must be available to the later GM when they fit the explicitly bounded GM context; accounting bugs must not make the living world silently forget things that already happened.

## 4. Authority / Source Manifest

Refresh both mains before implementation. Current governance supersedes stale stage tables in repository docs where they differ.

1. Owner current explicit instruction.
2. `Vibe-Coding/AGENTS.md` + Owner collaboration preferences.
3. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md@v17.8` — current.
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md@v4.3`.
5. `Vibe-Coding/my world/architecture/world/G6_CORE_CONTEXT_BUDGET_ACCOUNTING_CORRECTION_V1_0_DECISION.md` — **FROZEN correction authority**.
6. `Vibe-Coding/my world/architecture/reviews/DEVELOPMENT_AUDIT_2026-09-08_ADOPTION_DECISION.md`.
7. repository `AGENTS.md` for stable repository rules; its duplicated fast-moving stage table may lag current Status and is not authoritative over item 3.
8. current implementation/tests.

No old chat/task packet may override the frozen correction.

## 5. Read first

Initial working set:

1. `AGENTS.md`
2. this Task Packet
3. current `src/世界回合/L1_器件层/世界回合上下文投影器.gd`
4. directly related World semantic / Knowledge / Agency / Evolution record constructors and validators only as tests require them
5. existing context-projection / G5 Agency / World Evolution tests that consume this projector
6. current status + frozen correction decision

Expand only if concrete evidence requires it.

## 6. Frozen accounting semantics

### DEC-01｜Actual assembled text is the budget truth

`MAX_PROJECTED_CHARS` remains exactly `16000`.

For each next non-empty section:

```text
used
= current context_text.length()
+ exact separator length that will actually be inserted before the section

fits
iff used + candidate_section.length() <= MAX_PROJECTED_CHARS
```

Every heading/newline/separator counts exactly once.

Do not maintain an approximate parallel counter that double-counts body text or omits rendered framing.

### DEC-02｜Initial world-change framing counts

The `Materialized World Changes` heading and the actual separators/newlines between selected change blocks are part of the same 16,000-character limit.

World-change selection must be based on the actual rendered section cost, not only the sum of change-block bodies.

### DEC-03｜Existing section order and all-or-nothing behavior remain

Preserve:

```text
Materialized World Changes
→ Actor Knowledge Provenance
→ Independent Actor Actions
→ World Evolution Events
```

Current later-section behavior remains all-or-nothing. If the full section does not fit, omit that section; do not add new line-level truncation, summarization, ranking or semantic retrieval.

### INV-CONTEXT-01｜Final hard ceiling

Every successful non-empty projection must satisfy:

```text
context_text.length() <= MAX_PROJECTED_CHARS
```

### INV-CURRENTNESS-01

Do not change accepted-hash matching, stale/displaced-future isolation or current Timeline semantics.

### INV-DISCLOSURE-01

Do not change the established truth/knowledge boundary:

`World Truth != actor Knowledge != human-player disclosure`.

The projector remains GM-context infrastructure, not player disclosure authority.

## 7. Scope

Allowed:

- narrow accounting changes in `世界回合上下文投影器.gd`;
- the smallest helper/refactor necessary to make actual assembled-length accounting unambiguous and testable;
- focused boundary tests using legitimate production record constructors/validators;
- directly affected G5 regressions;
- implementation return/evidence.

Prohibited:

- increasing `MAX_PROJECTED_CHARS`;
- G7 Context Orchestrator;
- semantic retrieval/ranking;
- summary/recompression/embedding/vector search;
- changing recent-turn/event ceilings;
- changing Agency/Evolution selection policy;
- partial line truncation introduced solely for this task;
- model prompt changes or new Provider calls;
- persistence/SQLite/schema changes;
- general long-session memory redesign;
- broad cleanup of the eight layer-boundary findings;
- Debug Mode / recommendation / People / Important Experiences work.

## 8. Deliverables

1. Production correction with exact assembled-text accounting.
2. Focused deterministic boundary tests.
3. Directly affected regression results.
4. `docs/mw020/MW-020_IMPLEMENTATION_RETURN.md` with exact base/commits/tests/residual risks.
5. Windows export validation only if current repo release policy/tests establish it is needed after this runtime script change; otherwise state why the existing automated import/runtime gates are sufficient. Do not skip an established required export gate silently.

## 9. Engineering Acceptance

At minimum independently provable:

AC-01 — **Audit-equivalent no-double-count case**: substantial valid semantic changes plus a valid durable Agency action whose final actual combined context fits under 16,000 must include the Agency section/action.

AC-02 — **Exact fit**: construct a legitimate case where adding the target section makes final `context_text.length()` exactly `16000`; the section is included and final length is exactly the ceiling.

AC-03 — **One over**: equivalent legitimate case where final text would be `16001`; target section is omitted under current all-or-nothing behavior and returned text remains <=16000.

AC-04 — **Heading/separator accounting**: tests prove rendered headings and actual inter-section separators count once, neither omitted nor duplicated in budget use.

AC-05 — **Initial changes section bound**: world-change heading + joined blocks can never make the returned context exceed the ceiling merely because only bodies were counted during selection.

AC-06 — Knowledge → Agency → Evolution later-section accounting uses the actual current assembled text, not stale/body-only counters.

AC-07 — existing section order remains unchanged.

AC-08 — accepted-hash/currentness filtering remains unchanged; stale records do not re-enter context.

AC-09 — legitimate no-Agency / no-Evolution / hold states remain valid and quiet.

AC-10 — no total-budget increase, semantic ranking, truncation framework, new Provider call or persistence owner.

## 10. Validation order

Run focused first, then directly affected regressions.

At minimum include production-seam tests around:

- semantic world-change context projection;
- Knowledge projection if its section can participate in budget boundaries;
- Agency projection;
- World Evolution projection;
- currentness / replacement / Restore tests that already cover these records.

Use current valid production record constructors/validators. Do not manufacture bypass dictionaries that production would reject merely to hit a character count.

A real Provider call is **not required**: this defect is deterministic accounting and can be fully proven without network/model variability.

## 11. Product / gate acceptance

MW-020 is not a new player-facing feature and requires no standalone Owner Product verdict.

GPT Independent Review may grant Engineering PASS. Only after reviewed integration may the project prepare the fresh Package-0 Owner build.

If the proposed fix changes content selection semantics beyond accounting, STOP rather than silently expanding the task.

## 12. Git / Integration

- Work only from required task branch/worktree.
- Record exact starting HEAD/status/worktrees.
- Preserve unknown dirty/local work; never reset/clean/force.
- Do not modify `main` directly.
- Commit and push implementation/evidence to `mw-020-context-budget-accounting`.
- Before push, refresh both mains for decision propagation.
- Return exact implementation HEAD and final candidate HEAD.
- Keep worktree through GPT Independent Review + integration verification.

## 13. Stop / Return Conditions

STOP and report instead of guessing if:

- current governance supersedes this decision;
- the reproduced omission has a materially different root cause than accounting in current source;
- exact accounting cannot be corrected without changing semantic selection policy;
- a destructive migration/provider/context-architecture redesign would be required.

Otherwise return only after required evidence is committed/pushed with status **READY FOR INDEPENDENT REVIEW**.
