# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / Freshness

For every formal task, resolve current authority from GitHub `main` in this order:

1. User current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`.
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`.
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md` and relevant supporting decisions.
6. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`.
7. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`.
8. Current implementation/tests/HEAD.

For current Source semantics also read:

- `Vibe-Coding/my world/architecture/source/G4_SOURCE_SEMANTIC_OWNERSHIP_AND_REAUDIT_DECISION.md`;
- `Vibe-Coding/my world/architecture/source/G4_GAME_LOCAL_EVOLVABLE_SEMANTICS_DECISION.md`;
- `Vibe-Coding/my world/architecture/source/G4_T0_SCOPED_SOURCE_AND_POST_T0_CANON_QUARANTINE_DECISION.md`;
- `docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md`;
- `docs/source/G4-02R1_T0_SCOPED_SOURCE_CONTRACT_ADDENDUM.md`;
- `docs/source/G4-02R1_T0_CHARACTER_INDIVIDUALITY_ADDENDUM.md`;
- `docs/source/G4-02R1_FIXED_T0_MULTI_ENTRY_CHARACTER_BINDING_CLARIFICATION.md`;
- `docs/source/G4-02R1_REAL_ASSET_V0_2_R2_MIGRATION_SPEC.md`;
- `docs/source/G4-02R1_HAN_FAMILY_JOINT_FULL_FIDELITY_AUDIT.md`;
- `docs/source/G4-02R1_AFTERGLOW_FAMILY_JOINT_FULL_FIDELITY_AUDIT.md`;
- `docs/source/G4-02R1_CROSS_FAMILY_PACKAGE_SHAPE_STABILITY_DECISION.md`.

`docs/source/G4-02R1_REAL_ASSET_V0_2_MIGRATION_SPEC.md` is superseded r1 design evidence only.

Before authoritative writes, revalidate `main`; never overwrite unknown dirty/newer work.

---

## 2. Current phase / active task

Completed foundation:

```text
G1 Foundation                        PASS / CLOSED
G2 AI Conversation Spine             PASS / CLOSED
G3 Persistence / Save / Timeline     PASS / CLOSED
G4-01 Application Shell / Lifecycle PASS / CLOSED
G4-02 original v0.1 engineering      HISTORICAL PASS
G4-03 Managed Local Source Library   PASS / CLOSED
G4-04 Multi-Game / Game Library      PASS / CLOSED
```

Parent task:

> **G4-02R1 — World / Character Source Semantic Re-audit**

Parent state:

```text
semantic/full-fidelity phase   PASS / FROZEN FOR MECHANISM
overall G4-02R1                IMPLEMENTATION PENDING
semantic owner                 GPT
```

Active implementation task:

> **G4-02R1M1 — Source v0.2-r2 Mechanism Correction**

Formal packet:

`docs/tasks/G4-02R1M1_SOURCE_V0_2_R2_MECHANISM_CORRECTION_TASK.md`

Packet commit:

`238dfecb6bdfc056a4ceb4115b247e8a8f18b674`

Formal Code Base:

`f1950d615864fd0e780764fa1a50cfcbf1a5c507`

Governance Base:

`6ac202eca576496e93eb0f4b317ef5b0bffc7399`

Active owner: **Codex**.

Return ceiling:

> **READY FOR INDEPENDENT REVIEW**

If the frozen semantics are genuinely ambiguous or impossible to implement without redesign, return **BLOCKED to GPT** with evidence. Do not invent semantic rules.

G4-05 remains **REWORK / HOLD**.  
`docs/tasks/G4-05R1_REAL_ASSET_FIDELITY_CORRECTION_TASK.md` remains **SUPERSEDED / DO NOT EXECUTE**.  
G4-06+ must not start.

---

## 3. Ownership split

Formal rule:

> **GPT owns Meaning; Codex owns Mechanism.**

GPT owns:

- World / Character / Expansion semantic design;
- Source → Game-local → Runtime ownership boundaries;
- T0/post-T0 authority rules;
- authored content migration and fidelity;
- Character personality/autonomy/knowledge semantics;
- Source bindings/disclosure meaning;
- semantic schema-need decisions;
- Independent Review after Codex implementation.

Codex currently owns only the frozen mechanism:

- GDScript validator/loader/fingerprint changes;
- exact selected Source projection;
- compatibility-state mechanism;
- localized Managed Source Library repair if real regression requires it;
- regression tests/failure injection;
- Godot/Windows engineering evidence.

Codex must not independently compress, paraphrase, rename or redesign the frozen 2 World + 6 Character full-fidelity fixtures.

---

## 4. No destructive rollback

Do not reset Git to pre-G4-02.

Repair forward:

```text
verified engineering history
→ frozen semantic correction
→ affected-code repair only
→ regression
→ GPT Independent Review
```

G4-03 remains PASS unless a concrete v0.2-r2 regression is demonstrated. G4-04 remains PASS/CLOSED. Preserve G4-05 candidate `145c3e1192b443f6284da7f36aee74619adad5bf` as provisional Wizard/Composition engineering evidence.

---

## 5. Frozen Source v0.2-r2 semantics

### Rich Source

Long package-local UTF-8 Markdown/TXT sections are first-class Source bytes.

Do not recreate v0.1 compression or a giant universal schema.

### World projection

```text
top-level always-safe semantic_sections
+
exact selected Entry.semantic_sections
```

Unselected Entry bytes remain in exact fingerprint but are ordinary-Runtime-ineligible.

### Character projection

```text
top-level always-safe semantic_sections
+
exact matching T0 profile.semantic_sections
```

Never fallback to latest, nearest, later or complete-life biography.

### Closed per-World profile coverage

If a Character declares any binding to World W:

```text
exact selected Entry binding exists → compatible
missing selected Entry binding      → hard temporal incompatibility
```

If it declares zero bindings to selected World W, do not manufacture a hard block; preserve a distinguishable no-exact-profile / always-safe-only route for later Compatibility policy.

### Same-T0 multi-Entry

Bindings express authored starting compatibility, not current location, opening appearance, current contract or recommended scene.

### Disclosure

`gm_reference != player-known`.

`gm_private` is explicit backstage Source truth; Character knowledge still requires real in-game provenance.

### Exact generation

Canonical manifest + all declared semantic files + all Entry/profile files + authored assets + optional portrait when present must affect exact fingerprint.

> **Fingerprint coverage != Runtime visibility.**

### Model freedom

No convergence force and no divergence force. Do not add canon probabilities, divergence scores, fate state machines, personality transition tables, fixed narrative quotas or action whitelists.

### Game-local evolvability

Source schema is not the possibility ceiling of the Living World. Post-T0 local meaning may evolve while reusable Source/global contract/physical SQLite schema remain protected. Existing canonical Domains own their facts.

---

## 6. Frozen full-fidelity real fixtures

Primary consumer roots:

```text
tests/fixtures/g4_02r1/full_fidelity/汉末三国/
tests/fixtures/g4_02r1/full_fidelity/诸界余辉/
```

Frozen evidence set:

```text
World x2
- 汉末三国：天下未定
- 埃瑟维亚：诸界余辉

Character x6
- 刘备
- 曹操
- 孙权
- 莉维娅·塞兰
- 阿德里安·维尔克
- 杜恩·石痕
```

These must validate/load **unchanged** in G4-02R1M1.

No authored portrait bytes exist for the converted text-only Character packages; absence is valid. Do not add placeholders.

---

## 7. G4-02R1M1 required mechanism

Implement the packet exactly enough to prove:

- `world_pack.v0.2` / `character_card.v0.2` parsing and validation;
- safe nested rich-content paths;
- package-wide section ID uniqueness;
- Character profile/binding validation;
- deterministic exact fingerprint over all declared bytes;
- exact World selected-Entry projection;
- exact Character selected-profile projection;
- no fallback;
- authored closed temporal incompatibility;
- cross-world zero-coverage distinction;
- disclosure metadata preservation;
- optional portrait absence;
- tamper/missing fail-loud.

Prefer extending current Source layers:

```text
src/source/L0_公理层/Source契约验证器.gd
src/source/L1_器件层/Generation内容指纹器.gd
src/source/L1_器件层/Generation验证加载器.gd
src/source/L2_流程层/Source选择服务.gd
src/source/L3_外交层/Source合同公开接口.gd
```

and other existing Source Library seams where actually required. Do not create a parallel Source framework.

---

## 8. Required regressions

### G4-03

Keep managed Library invariants:

- staged verified publish;
- append-only immutable generations;
- explicit current;
- restart truth;
- exact generation identity;
- tamper/missing fail-loud;
- old exact generation remains resolvable.

### G4-05 preserved mechanics

Re-prove without resuming G4-05:

- list focus/visibility != selection;
- explicit click selects exact generation;
- X does not drift to newer Y;
- changing World clears Entry;
- Player eligibility and Player/NPC overlap rules;
- Review exact lookup/tamper failure;
- Wizard→Review creates no Game DB/Game Library mutation/Provider call;
- Cancel returns Main Menu/no Session;
- no same-family restriction;
- Expansion remains honest none-only.

---

## 9. Forbidden scope

G4-02R1M1 must not:

- rewrite semantic fixtures;
- invent universal skill/spell/nation/god/personality ontology;
- restore `source_material`;
- add same-family hard restriction;
- implement Expansion runtime semantics;
- implement G4-06 Final Create;
- create Creator/platform/importer framework;
- build generic legacy compressor;
- broadly refactor Prompt/Context beyond the selected-projection seam;
- rename stable `ashtervia` IDs;
- fabricate portraits;
- destructively roll back verified stages.

---

## 10. Evidence / return protocol

Codex evidence target:

`docs/source/G4-02R1_R2_MECHANISM_IMPLEMENTATION_EVIDENCE.md`

Evidence must identify what each important assertion proves; “tests pass” alone is insufficient.

Final return must include:

```text
Task: G4-02R1M1
State: READY FOR INDEPENDENT REVIEW | BLOCKED
Formal Code Base: f1950d615864fd0e780764fa1a50cfcbf1a5c507
Start HEAD:
Final HEAD:
Implementation commits:
Evidence doc:
Tests/commands:
Real-fixture proof:
G4-03 regression:
G4-05 regression:
Known limitations:
```

Codex must not declare G4-02R1 closed or G4-05 resumed/closed. GPT owns the following Independent Review.

---

## 11. Technical baseline

```text
Host             Godot 4.7.2 Standard / non-.NET Windows x64
Language         GDScript
Runtime          same-process Godot Runtime
Provider         DeepSeek deepseek-v4-pro
Persistence      SQLite via godot-sqlite v4.9
Schema           production v4
Game topology    One Game = One SQLite
Source Library   managed immutable filesystem generations
```
