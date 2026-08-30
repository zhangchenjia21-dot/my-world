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
- `Vibe-Coding/my world/architecture/source/G4_OPTIONAL_TEMPORAL_SOURCE_SCOPE_DECISION.md`;
- `Vibe-Coding/my world/architecture/persistence/G4-04_MULTI_GAME_STORAGE_TOPOLOGY_DECISION.md`;
- `docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md`;
- `docs/source/G4-02R1_T0_SCOPED_SOURCE_CONTRACT_ADDENDUM.md`;
- `docs/source/G4-02R1_OPTIONAL_TEMPORAL_SCOPE_CAPABILITY_CLARIFICATION.md`;
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

Current parent state:

```text
semantic/full-fidelity phase        PASS / FROZEN
G4-02R1M1 production mechanism      READY FOR IR
GPT first Independent Review        CORRECTION REQUIRED — EVIDENCE GAP ONLY
overall G4-02R1                     IMPLEMENTATION / IR PENDING
semantic owner                      GPT
```

Active correction task:

> **G4-02R1M1-IR01 — Optional Temporal Scope Evidence Correction**

Formal packet:

`docs/tasks/G4-02R1M1-IR01_OPTIONAL_TEMPORAL_SCOPE_EVIDENCE_CORRECTION_TASK.md`

Packet commit:

`f020848f23464c6022358acf2aa9b82bc940fd83`

Formal Code Base:

`74d1fe8d93e527794db33d0280d76d16674ae1d7`

Governance Base:

`14fb4d686c458c2a09a348e54088377f96655d65`

Active owner: **Codex**.

Return ceiling:

> **READY FOR INDEPENDENT REVIEW**

Expected shape: **test/evidence correction only**. Do not modify production Source behavior unless the new tests expose a real defect. If a production change appears necessary, stop and report the concrete failure before broadening scope.

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
- temporal scope / T0 / post-T0 authority rules;
- authored content migration and fidelity;
- Character personality/autonomy/knowledge semantics;
- Source bindings/disclosure meaning;
- semantic schema-need decisions;
- Independent Review after Codex implementation.

Codex currently owns only the IR01 evidence correction:

- complete direct Han temporal-coverage assertions, including Sun Quan 280;
- task-owned synthetic proof for non-temporal Character without `t0_profiles`;
- task-owned synthetic proof for non-temporal World without artificial temporal partitioning;
- preservation of existing Source projection/fingerprint behavior;
- G4-03/G4-05 regressions and editor parse evidence.

Do not independently redesign semantics or modify/compress/paraphrase the frozen 2 World + 6 Character full-fidelity fixtures.

---

## 4. No destructive rollback

Do not reset Git to pre-G4-02.

Repair forward:

```text
verified engineering history
→ frozen semantic correction
→ affected-code repair only when proven necessary
→ regression
→ GPT Independent Review
```

G4-03 remains PASS unless a concrete corrected-contract regression is found. G4-04 remains PASS/CLOSED. G4-05 candidate `145c3e1192b443f6284da7f36aee74619adad5bf` remains provisional accepted Wizard/Composition engineering evidence.

---

## 5. Frozen Source v0.2-r2 semantics

Core shape:

```text
thin identity / catalog metadata
+ ordered rich semantic_sections
+ disclosure = gm_reference | gm_private
+ package-local UTF-8 Markdown/TXT
+ World Entry-scoped sections when authored need exists
+ optional Character T0-profile-scoped sections when authored need exists
+ exact immutable fingerprint over all declared bytes
```

Do not restore compact v0.1 `summary/traits/background/drives` as the semantic target. Do not create a giant universal ontology to replace rich authored prose/tables.

### Optional temporal capability

T0-scoped / post-T0 quarantine is **not mandatory for every Source asset**.

The game must support both:

```text
Temporal-scoped Source
→ multiple authored temporal cuts
→ exact selected projection / future quarantine

Non-temporal Source
→ complete rich top-level starting semantics
→ no artificial T0 profile matrix
```

Do not add a global `historical`, `temporal_mode`, `requires_quarantine`, family classification or equivalent hard switch.

`character_card.v0.2` keeps `t0_profiles` optional. A Character with no real temporal variation may omit profiles entirely and use top-level `semantic_sections` as its complete reusable starting semantics.

World Entries may exist for scenario/opening/location choice without implying historical quarantine. Entry-scoped semantic sections are used only when authored content actually differs by Entry/T0.

Current Afterglow fixtures with one 1287 profile bound to all three Entries remain valid, but future fantasy/original assets are not required to use that pattern.

### T0 authority when temporal scope is used

> **Do not show the model a post-T0 answer and then ask it to forget that answer.**

```text
Source Package Total Content
!= Selected T0 Source Projection
!= Game-local Reality
!= Runtime Relevant Set
!= Model-visible Working Set
```

World temporal projection:

```text
top-level always-safe sections
+ exact selected Entry sections
```

Character temporal projection:

```text
top-level always-safe sections
+ exact matching T0 profile sections
```

Never fallback to latest / nearest / later / complete-life biography.

### Temporal coverage

If Character declares any profile coverage for World W:

```text
exact Entry binding exists -> compatible
selected Entry binding missing -> temporal incompatibility
```

If Character has zero profile coverage for W, do not invent a same-family hard block; preserve a distinguishable `no_world_coverage` / always-safe-only result.

This state only means the temporal-coverage rule has no basis to hard-block. It does not decide every future Compatibility policy.

### Fixed-T0 multiple Entry bindings

One profile may bind multiple same-T0 Entries. Binding means authored starting compatibility only; it does not mean current location, opening appearance, relationship or recommended-scene score.

### Disclosure

`gm_reference` / `gm_private` are Source disclosure classes, not automatic Player/Character knowledge.

### Fingerprint vs visibility

All declared bytes participate in exact generation fingerprint, including unselected/private files.

> **Fingerprint coverage != Runtime visibility.**

---

## 6. Current IR01 required evidence

IR01 must directly prove through production seams:

```text
刘备: 220 exact; 229/263/280 incompatible
曹操: 214 exact; 220/229/263/280 incompatible
孙权: 249 exact; 263/280 incompatible
```

Do not derive these by year arithmetic; use real Entry IDs and exact binding production behavior.

Also prove:

- synthetic non-temporal Character with no `t0_profiles` loads normally;
- its rich top-level semantics survive projection;
- it returns `no_world_coverage`, not hard incompatibility;
- synthetic non-temporal World can have Entries for scenario choice with no temporal section matrix;
- no global temporal/historical mode field is introduced;
- existing Han future-quarantine tests remain strict;
- current Afterglow bindings still work;
- cross-world zero coverage remains non-hard-blocking;
- G4-03 and preserved G4-05 regressions remain green.

---

## 7. Game-local evolvable semantics

Formal invariant:

> **Source schema is not the possibility ceiling of the Living World. Game-local semantic structure is evolvable.**

After Final Create:

- exact Source generation stays immutable;
- Game-local canonical object owns lived history;
- stable Program-owned identity/provenance/lifecycle kernel remains protected;
- model/runtime may evolve previously unanticipated local semantics;
- model must not rewrite Source/global contract or physical SQLite schema;
- existing canonical Domains such as Location/Relationship/Knowledge/Injury/Inventory/Faction/Timeline win over duplicate generic truth;
- local semantic evolution must be durable and Timeline/Save/Restore reversible.

---

## 8. Multi-Game topology｜G4-04 frozen

> **One Game = One SQLite.**

Managed path:

`user://my-world/games/<game_id>/game.sqlite`

Historical G3 path:

`user://my-world/current-game.sqlite`

Application index metadata != gameplay truth. Existing-only open, identity cross-check, A-close-before-B-open, independent DBs and legacy adoption must remain intact.

Do not reopen G4-04 topology during Source evidence correction.

---

## 9. Preserved G4-05 engineering

G4-05 is still REWORK/HOLD, but these seams remain provisional accepted evidence and must stay green:

- chooser visibility/focus != selection;
- explicit click selects exact generation;
- composition stores exact generation identity;
- World change clears dependent Entry;
- Player eligibility;
- same exact Character cannot be Player + Guaranteed NPC;
- selected X does not drift to newer current Y;
- Review exact re-resolve + tamper/missing fail-loud;
- Wizard→Review creates no Game SQLite / Game Library mutation / Provider call;
- Cancel returns Main Menu/no Session;
- Expansion remains honest none-only in current G4-05.

Do not resume/close G4-05 inside G4-02R1M1-IR01.

---

## 10. First-generation product path

```text
Main Menu
→ New Game
→ exactly 1 World Pack
→ Entry/T0 0..1
→ Expansion 0..N (current G4-05 honest path: none)
→ exactly 1 Player Character Card
→ 0..N Guaranteed NPC Character Cards
→ minimal settings
→ Compatibility Review
→ Atomic Final Create (G4-06)
→ Game-local Reality
→ real AI GM Opening
```

Do not add no-World/no-Character/blank-world direct creation, historical Source picker, Creator path, complex Expansion chooser or generic form framework in current G4.

---

## 11. Technical baseline

```text
Host              Godot 4.7.2 Standard / non-.NET Windows x64
Language          GDScript
Runtime           same-process Godot Runtime
Provider          DeepSeek deepseek-v4-pro
Persistence       SQLite via godot-sqlite v4.9
Production schema v4
Game topology     One Game = One SQLite
Source Library    managed immutable filesystem generations
```

Routine Git/Godot/build/test/debug/failure-injection work belongs to the implementation Agent. Owner handles real product UAT, irreducible product decisions and secrets. Engineering PASS does not equal Product PASS.
