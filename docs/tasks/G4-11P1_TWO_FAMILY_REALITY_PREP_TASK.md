# TASK｜G4-11P1｜Two-Family Reality Prep / Engineering Proof

Type: **validation / UAT-support**  
Owner: **CODEX**  
Reviewer / semantic owner: **GPT**  
Parent: **G4-11 Two Primary Asset Families Reality Test**  
Formal Code Base SHA: `97b9acff2c0e9a6cef82ff0e9d2c12e0893a0f7a`  
Governance decision line: `Vibe-Coding@5f03b4ad9196a1a6aeb1d08dfeff95e081c548ce`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Produce real, task-owned engineering evidence that the current product can create, play, persist, switch and resume **two independent Games from two different full-fidelity Primary Source families** using the same canonical runtime stack and a real selected Provider.

Families:

```text
A — 汉末三国：天下未定
    Entry: 208｜赤壁前夕
    Player: 刘备
    Expansion: none

B — 埃瑟维亚：诸界余辉
    Entry: t0-1287-ovista
    Player: 莉维娅·塞兰
    Expansion: none
```

This task does not decide whether the two worlds are sufficiently different as a product experience. That is the later Owner UAT.

## 2. Why now

Owner explicitly deferred G4-10 visual runtime work to G6 because current art assets are not mature and are not part of the present core experience.

Current route:

```text
G4-09 PASS / CLOSED
→ G4-11 Two Primary Asset Families Reality Test
→ G4-GATE
→ G5
```

G4-10M1 is superseded and must not be executed.

## 3. Authority / Source Manifest

Resolve conflicts in this order:

1. Owner current explicit instruction.
2. `Vibe-Coding/my world/architecture/source/G4_VISUAL_ASSET_DEFERRAL_TO_G6_DECISION.md`.
3. `Vibe-Coding/my world/architecture/source/G4_TWO_FAMILY_REALITY_TEST_V0_1_DECISION.md`.
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` v3.3.
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md` and current Source/T0 decisions.
6. Current implementation/tests from Formal Code Base and newer packet-only docs.
7. Current repository `AGENTS.md`.

Do not use the old G4-10M1 packet as implementation authority. It is explicitly superseded.

## 4. Read First

Start with this bounded set:

1. `AGENTS.md`;
2. this packet;
3. the two current governance decisions named above;
4. `docs/source/G4-02R1_AFTERGLOW_WORLD_FULL_FIDELITY_RESULT.md`;
5. `docs/source/G4-02R1_LIVIA_FULL_FIDELITY_RESULT.md`;
6. existing Han full-fidelity result/fixture entry for `天下未定` + `刘备`;
7. the current Final Create / Game Library / Opening runtime public seams actually used by existing vertical tests.

Expand only when needed to exercise the real product path. Do not read the whole repository by default.

## 5. Fixed test assets

Use the current full-fidelity fixture families as task-owned source inputs:

```text
tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定
tests/fixtures/g4_02r1/full_fidelity/汉末三国/刘备

tests/fixtures/g4_02r1/full_fidelity/诸界余辉/埃瑟维亚
tests/fixtures/g4_02r1/full_fidelity/诸界余辉/莉维娅
```

The fantasy World stable identity is `world.ashtervia.afterglow`; `莉维娅` has one authored fixed-1287 T0 profile covering all three current 1287 entries including `t0-1287-ovista`.

Do not rewrite/compress these semantic fixtures for the test.

## 6. Invariants

### INV-PRODUCT-01 — Core value under test

The same Host must sustain two materially different Source-grounded RPG realities without cross-family contamination. Engineering must preserve enough real evidence for Owner to judge this later.

### INV-11-01 — Same runtime stack

Both Games use the canonical current Source Library → Composition → Final Create → Game Session → Opening/Conversation → Save/Continue path.

Do not build a parallel mini-RPG harness that bypasses production semantics.

### INV-11-02 — Same selected model profile

Use the **same current selected runtime model profile** for both real-provider verticals through the shared runtime adapter.

Do not change the Owner's persisted model preference solely for this task. Record the effective model/context/reasoning profile used, without printing credentials.

If the selected provider credential is unavailable, stop and return the credential blocker rather than silently switching providers.

### INV-11-03 — Expansion none

Both Games use `Expansion = none`.

Public d20 has already passed Owner UAT; adding it here would confound the World/Character family comparison.

### INV-11-04 — Task-owned mutable roots

All mutable Source Library / Game Library / SQLite / Save test state must be under a task-owned root.

Do not mutate Owner production Games, production Source current, runtime model settings, `.env.local`, or credentials.

Read-only fingerprinting of Owner production surfaces for before/after safety evidence is allowed if existing task conventions already support it.

### INV-11-05 — Independent Game truth

A and B must have distinct Game IDs and distinct SQLite files. Session switch A→B→A must release/reopen the correct Game and must not leak Conversation/current Source identity.

### INV-11-06 — Exact semantic Source ancestry

Each Game must preserve exact World/Character generation provenance and materialized starting truth.

Demonstrate Source-update isolation in a task-owned library with a bounded second generation where practical. Do not alter frozen semantic fixtures destructively. If a safe clone/update proof already exists and can be reused, bind it to the two-family Game evidence rather than rebuilding a new framework.

### INV-11-07 — No cross-family Context leakage

Provider-visible Han Context must not contain Afterglow Source identity/content, and vice versa.

Do not log credentials, Authorization, hidden reasoning, or full secret payloads merely to prove this. Use safe context/source identity assertions or bounded evidence.

### INV-11-08 — T0 quarantine

No later/unselected Entry/T0 content is introduced into ordinary Context for convenience.

### INV-11-09 — Model Freedom First

Do not add genre keyword validators, required prose format, mandatory vocabulary, scripted beats, or output classifiers that gate acceptance merely to make the two worlds look different.

### INV-11-10 — No visuals / no G5

No portrait/scene/map runtime work. No NPC agency engine, faction simulation, event system, relationship state machine, knowledge graph, travel system or other G5/G6 implementation.

## 7. Required real vertical

For **each** family, prove at least:

```text
exact Source install/selection
→ explicit Composition
→ atomic Final Create
→ independent Game
→ real Provider Opening accepted
→ continuation turn 1 accepted
→ continuation turn 2 accepted
→ named Save or current supported explicit Save path
→ close/switch Game
→ reopen / Continue
→ one more accepted continuation
```

The continuation prompts should be natural and family-appropriate, not identical artificial benchmark strings. Keep them simple enough that the evidence tests the Source/Character/world texture rather than sophisticated G5 behavior.

## 8. Engineering Acceptance

### AC-01 Source identity

Evidence records exact World/Character asset IDs + exact generation fingerprints for A and B.

### AC-02 Independent Games

A/B Game IDs and SQLite paths are distinct; switching does not cross-contaminate current Session or Conversation.

### AC-03 Real Provider

Both verticals use the same effective selected runtime model profile and make real network calls through the canonical adapter. Opening and required continuations are accepted.

### AC-04 Durable continuation

After Save/close/reopen/Continue, each Game resumes its own accepted Conversation/history and accepts a new continuation.

### AC-05 Context/source isolation

Safe assertions demonstrate A requests are sourced only from A selected/materialized Source + A Game truth, and B requests only from B equivalents. No opposite-family identity/text enters normal Context.

### AC-06 Source update isolation

A bounded task-owned Source current change does not mutate an already-created Game's exact semantic ancestry/materialized starting truth.

### AC-07 No visual dependency

Both Games pass the vertical without authored portrait/scene/map requirements. No visual resolver or placeholder Source mutation is introduced.

### AC-08 No Owner mutation

Owner production Source/Games/settings/credentials remain unchanged.

### AC-09 Regression

Directly affected Source / Final Create / Game Library / Opening / Conversation / Save-Continue regressions are green. `git diff --check` is clean.

## 9. Product Value Acceptance — NOT owned by Codex

Codex may preserve transcripts/evidence, but must not declare:

```text
TWO WORLDS FEEL DIFFERENT PASS
PRODUCT PASS
G4-GATE PASS
```

After GPT Independent Review, Owner will play a short path in each production Game and answer whether the experiences are materially different as RPG worlds.

Owner UAT will not judge visual polish.

## 10. Implementation policy

This is primarily a validation/UAT-prep task. **No production behavior change is expected.**

Allowed:

- task-owned validation scripts/harnesses;
- focused tests;
- evidence docs under `docs/g4_11/`;
- minimal non-product test support needed to run the production seams.

If the real vertical exposes a production blocker that requires changing runtime behavior, **stop and return the blocker**. Do not silently fix it inside this validation task.

## 11. Validation order

1. existing focused offline Source/Final Create/Game Library regressions;
2. task-owned A/B create/switch/save/reopen validation with stub/provider-independent seams where useful;
3. context/source isolation assertions;
4. task-owned Source-update isolation proof;
5. real Provider A vertical;
6. real Provider B vertical with the same effective model profile;
7. canonical Windows export freshness only if the task adds executable/test support affecting export inputs; otherwise record why no rebuild is required;
8. `git diff --check`.

Do not spend real Provider calls before offline gates are green.

## 12. Evidence

Create:

`docs/g4_11/G4-11P1_TWO_FAMILY_REALITY_PREP_EVIDENCE.md`

Include:

- START_HEAD / FINAL_HEAD;
- effective model profile (no secrets);
- exact Source identities/fingerprints;
- Game IDs / independent SQLite proof;
- accepted turn counts and safe timing/request summaries;
- Save/reopen/Continue proof;
- switch A→B→A isolation proof;
- context/source isolation proof;
- Source-update isolation proof;
- directly affected test results;
- Owner production before/after safety proof;
- changed paths;
- `git diff --check`.

Transcript excerpts may be included only as much as needed to inspect Source grounding and cross-family leakage. Do not dump hidden prompts/reasoning or credentials.

## 13. Git / Stop / Return

- Refresh both `main`s and record exact START_HEADs.
- Never overwrite unknown dirty/newer work.
- Re-check Product/Roadmap authority before any production write or push.
- Push completed validation/evidence to `origin/main` under current integration convention.

Stop if:

- either fixed family cannot create through current production semantics;
- selected-provider credentials are unavailable;
- real Provider path requires provider fallback;
- cross-family leakage is observed;
- Save/reopen/switch breaks;
- Source ancestry mutates after current update;
- resolving the issue would require production behavior changes, G5, G6 or visual runtime work.

Return:

```text
START_HEADS
FINAL_HEAD / EVIDENCE_HEAD
changed paths
effective selected model profile
Family A exact Source + Game identity proof
Family B exact Source + Game identity proof
real Provider A result
real Provider B result
accepted continuation counts
Save/reopen/Continue results
A→B→A isolation result
Context/source leakage result
Source-update isolation result
regression results
Owner production surfaces untouched
git diff --check
READY FOR INDEPENDENT REVIEW
```
