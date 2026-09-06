# TASK｜MW-017｜People Identity Bridge + Same-turn Barrier

Type: G6 backend identity/currentness implementation  
Work Item: **MW-017**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Status: **READY FOR CODEX**  
Task Branch: `mw-017-people-identity-bridge`  
Required Worktree: `D:/AI/Projects/.worktrees/my-world/mw-017`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Formal implementation base: `4aeff59108bc5f3084b23237f00a34e9252d76dc`  
Governance decision/status base: `06496689930155b77968cdad2894e44b8b26cb51`

## 1. Product outcome

This task does **not** implement the People card UI.

It establishes the identity/currentness seam required so a later People Surface can safely answer:

> “玩家已经看到的叙事中这个人，究竟对应本局哪个 stable NPC？”

Required backend outcome:

```text
accepted player-authored Turn
↓
World semantic lane
→ materialize a new stable actor when appropriate
→ produce exact accepted-person → stable local identity receipt
↓
current-version terminal barrier
↓
existing Information Curator may start that lived-Turn curation
```

The future People curator must never need display-name matching or a raw stable-actor dump.

## 2. Why now

MW-016 architecture audit proved:

- stable local identities already exist;
- runtime-created actors are minted only after the semantic model result returns;
- current World semantic worker and Information Curator independently react to accepted Turns;
- there is no exact safe accepted-person → stable-ID bridge;
- there is no real happens-before barrier guaranteeing actor identity exists before a same-Turn People curation call.

MW-016 audit:

`docs/mw016/MW-016_PEOPLE_ARCHITECTURE_AUDIT.md`

Canonical architecture decision:

`Vibe-Coding/my world/architecture/ui/G6_PEOPLE_IDENTITY_AND_CURATION_V1_0_DECISION.md`

## 3. Authority / Source Manifest

Read latest mains before implementation. Authority order:

1. Owner current explicit instruction.
2. `Vibe-Coding/AGENTS.md` and Owner collaboration preferences.
3. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`.
4. `Vibe-Coding/my world/architecture/ui/G6_PEOPLE_SURFACE_V1_0_DECISION.md`.
5. `Vibe-Coding/my world/architecture/ui/G6_PEOPLE_IDENTITY_AND_CURATION_V1_0_DECISION.md`.
6. `Vibe-Coding/my world/architecture/ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`.
7. `Vibe-Coding/my world/architecture/world/G5_STABLE_ACTOR_REGISTRY_AND_MATERIALIZATION_V0_2_DECISION.md`.
8. `Vibe-Coding/my world/architecture/world/G5_KNOWLEDGE_PROVENANCE_V0_1_DECISION.md`.
9. repository `AGENTS.md`.
10. current implementation/tests/HEAD.

If a newer current decision conflicts, STOP rather than silently merging rules.

## 4. Read first

Initial workset:

- `AGENTS.md`
- this Task Packet
- `docs/mw016/MW-016_PEOPLE_ARCHITECTURE_AUDIT.md`
- `src/世界回合/L0_公理层/世界回合规则.gd`
- `src/世界回合/L1_器件层/语义变更响应解析器.gd`
- `src/世界回合/L2_流程层/语义物化流程.gd`
- `src/信息整理/L2_流程层/回合信息整理流程.gd`
- `src/应用壳.gd`

Expand only when concrete evidence requires persistence/L3/runtime/test owners.

## 5. Frozen decisions

### DEC-01 — Scheme A / same-Turn barrier

Use the approved ordering:

```text
accepted player-authored Turn
→ World semantic terminal
→ Information Curator lived opportunity
```

Do not intentionally defer a resolvable current-Turn person until the next Turn.

The barrier is for **lived player-authored Turns only**. MW-015 Initial Character activation curation remains independent.

### DEC-02 — no third People model call

Do not add a default People-specific resolver/curator Provider call.

Reuse:

- existing World semantic model call for materialization + identity binding;
- existing Information Curator call for later Character/Experiences/People meaning.

MW-017 does not yet add People content to the curator response.

### DEC-03 — exact stable identity

People identity must bind to Program-owned stable NPC `local_character_id`.

Forbidden authoritative methods:

- display-name equality;
- fuzzy name matching;
- first same-name actor;
- name-based dedupe;
- UI-local lookup.

Ambiguous/unresolved identity = no binding, not a guess.

### DEC-04 — request-scoped references

For existing actors, expose a bounded request-scoped `actor_ref` mapped privately by Program to exact current stable local ID.

For same-response new actor candidates, a transient bounded `candidate_ref` may be used only to correlate the model response.

`candidate_ref` is not durable identity.

Program must preserve correlation through candidate parsing/normalization:

```text
raw response candidate_ref
→ validate candidate
→ normalize/dedupe candidate material under existing rules
→ mint/reuse stable actor local ID
→ resolve only valid binding refs
```

A rejected/duplicate/invalid candidate ref must never drift to a different normalized candidate.

### DEC-05 — no resolver material expansion in v0.1

Do not expand the World semantic request to a full dump of raw stable actor profiles merely to solve same-name ambiguity.

Current internal resolver capabilities may be adapted to request-scoped refs, but raw Source projections/game-local private profile material are not authorized as a new People resolution payload.

If exact identity cannot be resolved, leave it unresolved.

### DEC-06 — identity receipt owner

Use the existing World / `living_world` owner.

Authorized additive concept:

```text
people_identity_turns_by_index
```

Each successfully processed player-authored opportunity must be able to durably express:

```text
schema
Game binding
turn index
full accepted Player+GM prefix/version binding
Program-derived receipt ID
status: resolved | empty
bindings[]
  exact stable local_character_id
  accepted GM span provenance
```

Exact naming may differ only if equivalent semantics are proven.

Old `living_world.v0.1` without this collection remains valid.

### DEC-07 — span provenance

A binding must point back to exact accepted GM text using machine-valid provenance such as `{start,length}`.

The Program validates range/version and may re-slice the accepted GM text.

Do not persist/trust free-form hidden actor description as player-visible cue.

Approved structural ceilings:

- max 8 bindings per opportunity;
- max 600 characters for one bound span.

These are machine limits, not semantic importance rules.

### DEC-08 — actor + receipt atomicity

When a runtime actor is materialized and bound in the same semantic response:

```text
normalize candidate
→ mint stable ID
→ resolve candidate_ref
→ actor materialization + receipt
→ one existing semantic durable mutation
```

Do not create a second registration/binding mutation solely for People.

Identity-only/no-change semantic outcomes are legal when a receipt must be persisted. Do not fabricate `changes` or Knowledge.

### DEC-09 — full prefix currentness

People identity receipt validity uses the full accepted Player+GM history prefix/version, not GM bytes alone.

Must prove:

- same GM text + corrected Player input invalidates the old People receipt;
- Regenerate/replacement invalidates stale binding currentness;
- runtime actor origin currentness still applies.

Do not rewrite historical G5 record IDs merely to obtain this People-specific dependency.

### DEC-10 — semantic terminal / Restore epoch

Add only the narrow terminal coordination needed for this barrier.

Terminal outcome must distinguish at least:

- durable success/resolved;
- durable success/empty;
- failure;
- cancellation;
- timeout.

Only current-epoch/current-version terminal may release the corresponding lived curator opportunity.

Restore must invalidate in-flight old-epoch callbacks before receipt publication or barrier release.

A bounded timeout/cancel mechanism is authorized if required. Do not build a general scheduler/event bus.

### DEC-11 — failure behavior

Semantic failure/timeout/cancel remains fail-soft:

```text
accepted Narrative remains valid
→ Character/Important Experiences curator is eventually released
→ People evidence for that opportunity is unavailable/no-op
```

An absent/failed receipt never means “clear People”.

No new People-specific automatic repair Provider call is authorized.

### DEC-12 — no opening / no historical backfill

MW-017 handles **player-authored accepted Turns** only.

Do not extend semantic/curation work to GM-only opening in this task.

Do not retroactively re-analyse old Game history or backfill People from Source/stable registry.

### DEC-13 — disclosure boundary

The identity receipt is an internal machine bridge, not People content.

It must not expose to future People curation/UI:

- raw actor material;
- Source semantic sections;
- private NPC Knowledge;
- Agency plans;
- hidden Evolution;
- hidden current NPC state.

A future People curator receives only accepted player-visible text + safe prior snapshots + bounded receipt-derived request refs/spans.

## 6. Scope

Allowed production areas when required:

- `src/世界回合/` semantic contract/parser/flow/L3;
- narrow `src/信息整理/` scheduling/barrier integration for existing lived curation;
- `src/应用壳.gd` only for narrow worker coordination;
- Runtime/persistence only if an existing public seam is insufficient and no new table is introduced;
- task-owned tests and evidence.

Prohibited:

- People cards/UI/navigation;
- `people_updates` / People snapshot curation schema (MW-018);
- Relationship/affinity Domain;
- numeric relation state;
- People historical backfill;
- GM-opening People processing;
- full roster/raw profile dump to People curator;
- generic event bus/job scheduler;
- new SQLite table;
- MW-013 declarative host;
- Source schema changes.

## 7. Barrier behavior in this task

MW-017 should make the ordering real enough that MW-018 does not need to invent a second scheduler.

For a player-authored lived Turn:

1. accepted history becomes durable;
2. World semantic worker processes that exact current opportunity;
3. semantic terminal becomes current and observable;
4. existing Information Curator lived request may then start;
5. semantic failure/timeout still releases the curator without People identity evidence.

Current Character/Important Experiences semantic meaning must remain unchanged. This task may change only the timing/order of their background call as required by the barrier.

Initial/T0 Character curation remains unaffected.

## 8. Required contract tests

At minimum prove through production seams with deterministic adapters:

1. **existing exact actor** — accepted text binds to an existing stable NPC via request ref and persists exact Program local ID;
2. **same-name actors** — no display-name authoritative selection; ambiguous case produces no binding;
3. **runtime new actor same Turn** — valid candidate is normalized/minted then candidate_ref resolves to that exact new ID in the same durable commit;
4. **candidate normalization drift** — rejected/duplicate candidate cannot shift an index/ref onto another actor;
5. **invalid refs** — unknown, Player, stale runtime actor or malformed ref/span is rejected fail-soft;
6. **empty success receipt** — semantic success with no valid person binding persists a replayable empty receipt;
7. **identity-only commit** — receipt can persist without fabricated changes/Knowledge;
8. **reopen replay** — durable current receipt is recognized without another model call;
9. **same GM / different Player** — full-prefix currentness rejects old receipt;
10. **Regenerate/correction** — stale receipt no longer current;
11. **Restore epoch** — late pre-Restore semantic callback cannot commit receipt or release stale curation;
12. **barrier success** — Information Curator lived request does not start before current semantic terminal;
13. **barrier failure** — semantic provider failure/timeout/cancel releases existing Character/Experiences curator and does not invalidate Narrative;
14. **initial Character unaffected** — MW-015 Game/T0 curation remains opening-independent and does not wait for World semantic;
15. **no disclosure payload** — receipt/public future bridge exposes no raw actor profile/private Knowledge/Agency/Evolution/Source-current material;
16. **old Game compatibility** — missing identity collection remains valid; no retrofit/backfill call;
17. **no new SQLite table/migration**;
18. existing stable actor / Knowledge / Agency / world semantic regression suites remain green;
19. MW-014/MW-015 Character/Important Experiences regressions remain green;
20. Narrative critical path remains playable/fail-soft;
21. `git diff --check` clean;
22. Windows Desktop export PASS.

## 9. Real Provider smoke

After deterministic/focused gates pass, run at least one bounded task-owned real configured Provider smoke if credentials/provider are available.

The smoke should inspect that the actual semantic model can return a valid actor/candidate identity-binding structure for a realistic accepted Turn.

It must:

- use isolated task-owned Game state;
- not alter Owner production Game/Source/settings;
- not print credentials;
- record malformed/unresolved output honestly rather than adding heuristic repair.

If the external Provider is unavailable, report that fact; do not switch Provider silently.

## 10. Evidence integrity

Before final evidence:

```text
git rev-parse HEAD
git status --short
git diff --check
```

Final worktree must be clean.

Return:

- exact candidate SHA;
- refreshed implementation base and governance SHA;
- exact changed files;
- request-scoped actor/candidate ref contract;
- durable receipt shape and identity/currentness algorithm;
- exact barrier/terminal mechanism;
- proof same-name ambiguity never falls back to name matching;
- proof runtime-created same-Turn actor binds after mint;
- proof failure/Restore behavior;
- proof existing Character/Experiences behavior remains semantically unchanged;
- focused/regression/export results;
- real Provider smoke result;
- clean status.

Highest allowed status:

**READY FOR INDEPENDENT REVIEW**

Do not merge `main`. Do not start MW-018. Do not install this backend-only candidate as an Owner UAT build.
