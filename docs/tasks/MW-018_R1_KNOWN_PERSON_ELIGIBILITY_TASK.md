# TASK｜MW-018 Revision 1｜Known / Off-screen People Eligibility Correction

Type: product-facing revision implementation  
Work Item: **MW-018**  
Revision: **R1**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Product Owner / Re-UAT: **Owner**  
Task Branch: `mw-018-r1-known-person-eligibility`  
Required Worktree: `D:/AI/Projects/.worktrees/my-world/mw-018-r1-known-person-eligibility`  
Formal Code Base: `fc308e8ee4347ddb8a67e40360f8ce84222d437b`  
Governance Base at shaping: `8376ea1d528ef49529b69a9aabab0616bb781805`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Fix the real Owner-UAT failure where a person already known to the protagonist and explicitly recalled in a Player turn can remain impossible to create/update in `人物 / People` merely because that person is not a current GM-span / scene receipt candidate.

After this revision:

```text
accepted Player+GM pair
→ bounded exact person-reference evidence from Player and/or GM
→ exact stable actor resolution/materialization only when legitimate
→ current People Curator candidate
→ model decides whether that person is worth persistent memory
→ correct latest-known People card may appear/update
```

Current physical scene presence is neither required nor sufficient for a People card.

## 2. Why now

Owner UAT U1 is complete and MW-018 is Product FAIL / Revision Required.

Observed real failure:

- `钟繇` had already been established as known to the protagonist;
- Owner submitted a turn explicitly recalling `钟繇`;
- no `钟繇` People card appeared;
- two incidental current-scene soldiers did receive cards.

Current MW-018 implementation packet constrained eligibility to current receipt-bound actors, which is narrower than frozen People product semantics.

Formal UAT evidence:

`docs/uat/G6_PACKAGE0_OWNER_UAT_U1.md`

## 3. Primary Purpose / Core Value

Current product core value remains:

> **长期持续 AI 世界 + 优秀自由 AI GM + 原生 RPG 游戏体验。**

INV-PRODUCT-01:

> People must help the Player remember the socially meaningful world they actually know, without turning names, Player beliefs or backend actor data into guessed World Truth.

## 4. Authority / Source Manifest

Refresh both mains before implementation. If current sources supersede this packet, STOP.

1. Owner current explicit instruction.
2. `Vibe-Coding/AGENTS.md` + Owner collaboration preferences.
3. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md` — current.
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` — current.
5. `Vibe-Coding/my world/architecture/ui/G6_PEOPLE_KNOWN_PERSON_ELIGIBILITY_UAT_CORRECTION_V1_0_DECISION.md` — **FROZEN correction authority**.
6. `Vibe-Coding/my world/architecture/ui/G6_PEOPLE_SURFACE_V1_0_DECISION.md`.
7. `Vibe-Coding/my world/architecture/ui/G6_PEOPLE_IDENTITY_AND_CURATION_V1_0_DECISION.md`, except where explicitly superseded in part by item 5.
8. `docs/uat/G6_PACKAGE0_OWNER_UAT_U1.md`.
9. repository `AGENTS.md`.
10. current code/tests.

Legacy/old task packets are evidence only where not superseded.

## 5. Read first

Initial workset:

1. `AGENTS.md`
2. this packet
3. `docs/uat/G6_PACKAGE0_OWNER_UAT_U1.md`
4. current People identity bridge / semantic receipt production paths
5. current Information Curator request construction + People candidate construction
6. current People curation parser/persistence/projection tests
7. current stable actor materialization tests

Likely starting implementation entries include the current equivalents of:

- `src/世界回合/L3_外交层/人物身份桥公开接口.gd`
- World semantic / actor materialization flow
- `src/信息整理/L2_流程层/回合信息整理流程.gd`
- People request/response contract/parser paths

Expand only when concrete evidence requires it.

## 6. Decision Digest / Invariants

### DEC-01｜Accepted pair person-reference evidence

People identity eligibility may use bounded exact person references from the current accepted **Player input and GM Narrative**, not only current GM/scene spans.

A request-scoped candidate may carry:

```text
actor_ref
source_role = player | gm
verbatim accepted span / quote
```

Program privately maps `actor_ref` to exact stable local actor identity.

### DEC-02｜Existing stable actor referenced by Player

A current Player-span reference may become a People candidate when the existing semantic identity lane can exactly resolve it to an already-existing stable actor.

No display-name authoritative lookup is allowed.

### DEC-03｜Off-screen GM-established person

A real person referenced/established by accepted GM Narrative may be bound even when not physically present in the current scene.

### DEC-04｜Same-turn newly established off-screen person

If accepted GM/world semantics legitimately establish a new distinct person as part of current Game reality, existing stable-actor materialization may mint/bind them in the same turn even when off-screen.

### INV-IDENTITY-01｜Player assertion != World Truth

Player text alone must not mint a new real actor or confirm existence.

```text
exact existing stable actor resolved
→ valid Player-span binding

identity/existence unresolved
→ no authoritative binding
→ no People update
```

### INV-IDENTITY-02｜No guessed names

Forbidden:

- display-name equality;
- fuzzy name matching;
- first same-name match;
- name allowlist;
- fame table;
- Program-side semantic dedupe.

### DEC-05｜Current scene presence != card worth

The model decides persistent memory value.

Prompt semantics must make clear:

```text
current scene presence != automatically important
off-screen != automatically unimportant
```

Incidental soldiers/guards/passers-by may remain uncarded. A socially/historically meaningful off-screen known person may be carded.

Do not implement importance thresholds, encounter counts, fixed categories or named-character rules.

### INV-DISCLOSURE-01

Do not expose raw stable actor material, NPC-private Knowledge, Agency, hidden Evolution, Source-current hidden material or canonical local IDs to the People Curator/UI.

### INV-CURRENTNESS-01

Save / Restore / Regenerate / correction / reopen currentness remains authoritative. Old receipts/curation data remain readable.

## 7. Scope

Allowed:

- narrow additive/backward-compatible identity receipt evidence needed for Player/GM source-role spans;
- narrow semantic/materialization changes required to support legitimate off-screen person bindings;
- People Curator candidate construction and prompt wording;
- parser/currentness/persistence/projection adaptations strictly required by the new receipt variant;
- focused tests and regression updates;
- revision completion report.

Prohibited:

- universal entity graph/resolver;
- historical People backfill;
- new SQLite table solely for this correction;
- separate default People Provider call;
- player-only false/imaginary person card identity system;
- numeric Relationship Domain;
- Provenance/Epistemic Status product expansion;
- Dynamic UI / Debug Mode / OOC / recommendation work;
- broad refactor unrelated to this UAT failure.

## 8. Deliverables

1. Production correction implementing the frozen known-person eligibility decision.
2. Backward-compatible receipt/currentness handling.
3. People Curator input allowing valid Player/GM exact candidates while preserving safe boundaries.
4. Prompt semantics separating eligibility from persistent card worth.
5. Focused automated tests.
6. Regression coverage for MW-017/MW-018 + Character/Important Experiences non-corruption.
7. `docs/mw018/MW-018_R1_IMPLEMENTATION_RETURN.md` with exact base, commits, tests and residual risks.

## 9. Engineering Acceptance

At minimum prove:

AC-01 — current Player-span reference to an exact existing stable actor can become a legal People candidate.

AC-02 — accepted GM reference to a real off-screen person can become a legal People candidate without requiring scene presence.

AC-03 — same-turn newly established off-screen person can be materialized + exactly bound when GM/world semantics legitimately establish existence.

AC-04 — Player-only unresolved name/reference does not mint or guess an actor.

AC-05 — same-name actors remain distinct; no display-name authority exists.

AC-06 — People Curator sees bounded player-visible span evidence + request-scoped ref, not raw hidden actor material.

AC-07 — incidental current-scene person is not automatically carded by Program; model remains semantic owner.

AC-08 — off-screen known person can be carded/updated when model judges persistent value.

AC-09 — semantic failure/cancel/timeout remains fail-soft and cannot clear existing People.

AC-10 — Restore / Regenerate / correction / reopen currentness remains correct.

AC-11 — old identity receipts / curation history remain readable.

AC-12 — no new People-specific default Provider call / no new SQLite table.

AC-13 — existing MW-017/MW-018 focused regressions stay green.

## 10. Product Value Acceptance｜Owner re-UAT required

Agent/Reviewer may only return **READY FOR OWNER UAT**, never Product PASS.

Owner re-UAT target:

```text
a legitimately established off-screen person is already known
→ Player explicitly recalls/refers to that person in a new accepted turn
→ if exact stable identity is legitimately resolvable and model judges persistent value
→ correct People card appears/updates
```

Also verify that incidental scene NPCs are not promoted simply because they are current identity candidates.

Product failure remains if the implementation merely adds name heuristics, or if meaningful off-screen known persons still cannot become legal candidates.

## 11. Validation

Run focused tests first, then directly affected regression suites, then export validation if production files affecting export/runtime changed.

Include at least deterministic cases for:

- Player existing-actor reference;
- GM off-screen actor reference;
- same-turn off-screen materialization;
- unresolved Player-only reference;
- same-name ambiguity;
- stale/Restore epoch rejection;
- no raw private material in Curator input;
- incidental candidate may receive model no-op;
- historical backward compatibility.

Do not spend real Provider calls until deterministic gates are green. A bounded real Provider validation is welcome only if it can materially test the exact UAT seam without contaminating production credentials/data.

## 12. Git / Integration

- Work only from the required revision branch/worktree.
- Record exact starting HEAD/status/worktrees.
- Preserve unknown dirty/local work; never reset/clean/force.
- Do not modify `main` directly.
- Commit and push implementation + evidence to `mw-018-r1-known-person-eligibility`.
- Before push, re-check both mains for decision propagation.
- Return exact implementation HEAD and final review candidate HEAD.
- Keep worktree until GPT Independent Review + integration verification.

## 13. Stop / Return Conditions

STOP and return without guessing if:

- current governance supersedes this correction;
- exact identity cannot be broadened without introducing Player-belief → World-Truth mutation beyond the frozen decision;
- a required backward-compatible receipt variant would actually need destructive migration;
- current code proves the UAT symptom has a materially different root cause than this packet and the frozen correction decision.

Otherwise return only after all required evidence is committed/pushed and status is **READY FOR INDEPENDENT REVIEW**.
