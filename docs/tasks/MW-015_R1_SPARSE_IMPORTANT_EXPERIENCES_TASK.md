# TASK｜MW-015 Revision 1｜Sparse Important Experiences Milestone Semantics

Type: product-facing revision implementation  
Work Item: **MW-015**  
Revision: **R1**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Product Owner / focused re-UAT: **Owner**  
Task Branch: `mw-015-r1-sparse-milestones`  
Required Worktree: `D:/AI/Projects/.worktrees/my-world/mw-015-r1-sparse-milestones`  
Formal Code Base: `2680b2616db69987a451c9d1bf53b24339a9c7cb`  
Governance Base at shaping: `43be10f08564f1f82a1ad2028861cf98ed802aaa`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Product outcome

Restore `重要经历 / Important Experiences` to its intended meaning:

> **selected protagonist life milestones, not a recap of every ordinary turn.**

After this revision, ordinary accepted play should very often produce:

```text
experiences = []
```

while genuinely life-shaping events may still add concise milestones when the model judges them meaningful.

## 2. Why now

Package 0 Owner UAT found that Important Experiences over-generated during extended play and behaved like a rolling per-turn summary. MW-015 was historically Product PASS, but this longer-run semantic failure reopens the same outcome as Revision 1.

Formal UAT evidence:

`docs/uat/G6_PACKAGE0_OWNER_UAT_U1.md`

MW-018 R1 is already Engineering PASS_WITH_NOTES and integrated. This task follows it to avoid conflicting edits in the shared Information Curator.

## 3. Primary Purpose / Core Value

Current product value remains:

> **长期持续 AI 世界 + 优秀自由 AI GM + 原生 RPG 游戏体验。**

INV-PRODUCT-01:

> Important Experiences must help the Player understand the protagonist's meaningful life trajectory without turning the right-side information surface into a duplicate transcript/recap stream.

## 4. Authority / Source Manifest

Refresh both mains before implementation. If current sources supersede this packet, STOP.

1. Owner current explicit instruction.
2. `Vibe-Coding/AGENTS.md` + Owner collaboration preferences.
3. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md` — current.
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` — current.
5. `Vibe-Coding/my world/architecture/ui/G6_IMPORTANT_EXPERIENCES_SPARSE_MILESTONE_UAT_CORRECTION_V1_0_DECISION.md` — **FROZEN correction authority**.
6. `Vibe-Coding/my world/architecture/ui/G6_CHARACTER_AND_IMPORTANT_EXPERIENCES_V1_0_DECISION.md`.
7. `Vibe-Coding/my world/architecture/ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`.
8. `docs/uat/G6_PACKAGE0_OWNER_UAT_U1.md`.
9. `docs/mw018/MW-018_R1_INDEPENDENT_REVIEW_IR1.md` + integration verification.
10. repository `AGENTS.md`.
11. current code/tests.

## 5. Read first

Initial workset:

1. `AGENTS.md`
2. this Task Packet
3. `docs/uat/G6_PACKAGE0_OWNER_UAT_U1.md`
4. current `src/信息整理/L2_流程层/回合信息整理流程.gd`
5. current information-curation contract/parser/projection tests
6. current MW-015 and MW-018 regressions

Expand only when concrete evidence requires it.

## 6. Decision Digest / Invariants

### DEC-01｜Sparse by semantic meaning

Important Experiences answers:

> **“我是怎样走到现在的？”**

Most ordinary turns should not append a milestone.

A model-facing semantic orientation may use this test:

> If omitting this event would not materially weaken a future explanation of how the protagonist became who they are, entered/left a major life path, or passed through a truly significant personal turning point, it usually should not become an Important Experience.

This is guidance to the model, not Program logic.

### DEC-02｜No fixed milestone taxonomy

Do not turn examples into a whitelist.

A quiet ordinary-looking event can be life-changing in context; an intense battle or named-person encounter can still be non-milestone.

### INV-MODEL-01｜Model remains semantic owner

Forbidden Program logic:

- keyword/regex classifier;
- importance score;
- event-type whitelist/blacklist;
- every-N-turn threshold;
- minimum elapsed-time rule;
- deterministic “combat/death/marriage/etc = milestone” mapping.

### INV-CHARACTER-01｜Character change != milestone required

A turn may update current Character while `experiences=[]`.

A genuine milestone may also be added without requiring Character text to change in the same turn.

Do not couple the two outputs mechanically.

### INV-PEOPLE-01｜Do not regress MW-018 R1

Current People candidate/evidence semantics from integrated MW-018 R1 remain intact. This revision must not restore GM-only People evidence, remove Player-span identity support, or otherwise change People identity authority.

### INV-IA-01｜No IA change

This revision does **not** authorize:

- adding `简要回顾`;
- moving Important Experiences under Character;
- removing/reordering the existing tab;
- changing navigation structure;
- adding history/timeline UI.

### INV-CURRENTNESS-01

Existing Information Curation persistence, IDs, parent chain, Save/Restore/Regenerate/reopen currentness remain authoritative. No historical rewrite/backfill is required.

## 7. Scope

Allowed:

- narrow Information Curator prompt/semantic wording needed to restore sparse milestone behavior;
- minimal parser/contract adjustment only if current code proves it strictly necessary;
- focused deterministic tests protecting structure/currentness and no Program heuristics;
- bounded real Provider validation of semantic behavior;
- regression updates strictly required by the correction;
- implementation return report.

Prohibited:

- new `简要回顾` surface;
- navigation/IA changes;
- deletion/cleanup of historical over-generated experiences;
- per-turn summary feature;
- Program-side importance classifier/scoring/rules;
- OOC / recommendations / Debug Mode / Dynamic UI work;
- new SQLite table or new Provider lane;
- unrelated Information Curator refactor.

## 8. Deliverables

1. Production correction restoring sparse milestone semantics.
2. Focused tests proving structural/currentness behavior remains intact and no hard-coded Program classifier was added.
3. Direct regressions covering MW-015, MW-018 R1, Character, People and Restore/Regenerate/reopen seams.
4. Bounded real Provider semantic validation.
5. `docs/mw015/MW-015_R1_IMPLEMENTATION_RETURN.md` with exact base/commits/tests/residual risks.

## 9. Engineering Acceptance

At minimum prove:

AC-01 — ordinary lived turn can legitimately return `experiences=[]` without being treated as failure.

AC-02 — clear life-shaping turn can add a concise Important Experience through the same Information Curator.

AC-03 — Program does not classify importance through keywords, event types, scores or thresholds.

AC-04 — Character can change while Experiences no-op, and Experiences can add without forced Character mutation.

AC-05 — People request/evidence/update semantics from MW-018 R1 remain unchanged.

AC-06 — malformed response behavior and existing curation failure isolation remain unchanged unless explicitly required.

AC-07 — Save / Restore / Regenerate / reopen currentness remains correct.

AC-08 — existing old curation records remain readable; no migration/backfill.

AC-09 — no extra Provider call, SQLite owner or new information subsystem.

## 10. Real Provider validation

After deterministic gates pass, use the configured real Provider in isolated test state for a bounded semantic check.

At minimum include:

1. one clearly routine turn (routine movement/conversation/low-stakes progression) where a reasonable successful response has `experiences=[]`;
2. one clearly life-shaping accepted turn where a reasonable response adds one concise milestone;
3. verify Character/People output remains structurally compatible and the model, not Program code, makes the importance distinction.

Do not manipulate prompts/results between attempts merely to manufacture a PASS. Report the exact model, call count and outputs used.

## 11. Product Value Acceptance

Engineering/Reviewer may only return **READY FOR OWNER UAT**, never Product PASS.

Final evaluation happens in the combined focused Package 0 re-UAT after MW-019 R1 is also integrated.

Product failure remains if normal play still causes Important Experiences to read like a turn-by-turn recap, or if the correction achieves sparsity by a rigid Program rule that suppresses model semantic freedom.

## 12. Validation order

Run:

1. focused MW-015 R1 tests;
2. current MW-015 / MW-014 / MW-018 R1 directly affected regressions;
3. Timeline/Restore/Regenerate relevant suites;
4. real Provider bounded validation;
5. Windows export validation if production runtime files changed.

## 13. Git / Integration

- Work only from the required revision branch/worktree.
- Record exact starting HEAD/status/worktrees.
- Preserve unknown dirty/local work; never reset/clean/force.
- Do not modify `main` directly.
- Commit and push implementation/evidence to `mw-015-r1-sparse-milestones`.
- Before push, refresh both mains for decision propagation.
- Return exact implementation HEAD and final candidate HEAD.
- Keep worktree through GPT Independent Review + integration verification.

## 14. Stop / Return Conditions

STOP and return without guessing if:

- current governance supersedes this correction;
- code evidence shows the over-generation is caused by a materially different mechanism than the Information Curator semantic instruction;
- the only proposed fix requires Program semantic classification/thresholds;
- a destructive migration or historical rewrite appears necessary.

Otherwise return only after evidence is committed/pushed and status is **READY FOR INDEPENDENT REVIEW**.
