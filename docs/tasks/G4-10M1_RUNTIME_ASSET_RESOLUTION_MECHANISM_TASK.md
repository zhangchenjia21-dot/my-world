# TASK｜G4-10M1｜Runtime Asset Resolution Mechanism

Type: **implementation**  
Owner: **CODEX**  
Reviewer / semantic owner: **GPT**  
Parent: **G4-10 Runtime Asset Resolution**  
Formal Code Base SHA: `f4fd3953a844d139e6acffeacd235d9dcaecd1e5`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Implement the smallest production runtime seam that can resolve and real-load Source-authored portrait / scene / map visuals from an **exact immutable Managed Source generation**, while preserving Source update isolation and safe package-path rules.

The observable engineering result must distinguish:

```text
RESOLVED
ABSENT
UNAVAILABLE
```

and must never silently substitute Source current, a neighboring file, another Source package, or a network replacement.

This task does **not** redesign the RPG UI. G4-11 is the later two-family product reality test.

## 2. Why now

Owner Product UAT for Public d20 returned `PASS` on 2026-09-02. Therefore:

```text
G4-08 Expansion Pack v0.1   PASS / CLOSED
G4-09 First Playable B      PASS / CLOSED
G4-09UATB                   PASS / CLOSED
```

The canonical roadmap now requires:

```text
G4-10 Runtime Asset Resolution
→ G4-11 Two Primary Asset Families Reality Test
→ G4-GATE
```

G5 must not start before G4-GATE.

## 3. Authority / Source Manifest

Resolve conflicts in this order:

1. Owner current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/my world/architecture/source/G4_RUNTIME_ASSET_RESOLUTION_V0_1_DECISION.md` — current canonical G4-10 semantic decision, created 2026-09-02; decision commit `8563f6623ed19603b2287791224948e8c067a1cc`.
3. `zhangchenjia21-dot/Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` — canonical roadmap v3.2, blob `cd07e64fbf6610e795f473d277154e7431fcc860`.
4. `zhangchenjia21-dot/Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md` — architecture map v2.1, blob `dce97ee0736021001a9d0340b36375312b1bccc6`.
5. `docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md` — Source semantic contract; blob `ac317d2898380d7dbd37a0d61c0f93b51912e4fc`, subject to later T0 amendments where relevant.
6. Current implementation / tests at and after Formal Code Base SHA.
7. `Vibe-Coding/skill/gpt/agent-task-packet/SKILL.md` for execution packaging/governance.

Historical/archived packets and chat summaries are not authoritative unless a current source explicitly references them.

## 4. Read First

Start with this bounded set:

1. repository `AGENTS.md`;
2. this Task Packet;
3. canonical `G4_RUNTIME_ASSET_RESOLUTION_V0_1_DECISION.md`;
4. `docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md` — especially World `authored_assets` and Character optional `portrait`;
5. `src/source/L0_公理层/Source合同规则.gd`;
6. `src/source/L1_器件层/Source包文件读取器.gd`;
7. `src/source/L3_外交层/Source库公开接口.gd`.

Only expand reading when required by an actual integration seam. Likely expansion candidates include `Source选定投影流程.gd`, World/Character public types, Source Library storage, and Final Create/Game provenance. Do not read the entire repository by default.

## 5. Decision Digest / Invariants

### INV-PRODUCT-01 — Exact authored identity

An old Game must keep resolving the visual from its pinned exact Source generation. Source current updates must not change that visual.

### INV-ASSET-01 — Source owns authored bytes

Visual bytes remain in immutable Managed Source generations. Do not copy them into SQLite or create a second Game-owned canonical visual store merely for display.

### INV-ASSET-02 — Exact resolution key

Resolution must semantically bind:

```text
Source identity/type
+ exact generation fingerprint/record
+ declared visual identity
```

World visuals use declared `authored_assets[].asset_id`. Character portrait uses the canonical portrait role plus exact Character generation; do not modify the Character Source contract just to invent a fake universal asset id.

### INV-ASSET-03 — Three states

- `RESOLVED`: exact generation/declaration/path/integrity are valid and real Godot image load succeeds.
- `ABSENT`: optional authored visual is canonically absent, e.g. no Character `portrait` field.
- `UNAVAILABLE`: exact generation/declaration/file/integrity/decode cannot safely resolve.

Use bounded safe reason codes/diagnostics for UNAVAILABLE.

### INV-ASSET-04 — Fail-soft presentation, never identity fallback

ABSENT/UNAVAILABLE may allow an application-owned neutral placeholder or omitted visual surface. They must not fall back to current generation, another asset/package, neighboring filename, network download, or altered bytes.

Visual presentation failure must not by itself dead-end Narrative gameplay.

### INV-ASSET-05 — Safe package path

Reuse or preserve existing Source safe-path guarantees. Reject absolute/drive/URI/traversal/symlink-escape behavior. Consumers must not gain arbitrary filesystem browsing authority.

### INV-ASSET-06 — Real Godot load

File existence is insufficient. At least the required portrait and World visual fixture must be decoded/loaded by real Godot 4.7.2 image facilities from the managed Source generation.

Do not require Source visuals to become `res://` imported Resources.

### INV-ASSET-07 — Map is presentation only

`kind = map` is authored image/reference presentation. Do not implement topology, current-location truth, travel/pathfinding, fog of war, POI interaction, GIS, procedural maps, or a spatial simulation owner.

`scene` visual is not SceneTree gameplay state.

### INV-ASSET-08 — No schema/persistence expansion by convenience

No SQLite schema change is authorized. No generic media/plugin framework is authorized. Do not add Source fields unless a concrete contradiction with the frozen Source contract is found; stop and return that contradiction rather than silently redesigning semantics.

### INV-ASSET-09 — G4-10 consumer set

Consume:

- Character optional Source-authored portrait;
- World `authored_assets` with `kind = portrait | scene | map`.

Do not build a document viewer. Do not invent an Expansion visual schema unless an existing current contract already supplies one.

## 6. Scope

### Allowed

- localized `src/source/**` changes needed to expose exact-generation visual declarations/resolution;
- a new small runtime/asset adapter module if that is cleaner than overloading Source code;
- minimal public L3 seam for controlled resolution;
- focused tests / task-owned Source fixtures / failure injection;
- test/evidence support needed to prove real Godot image load and Windows export compatibility;
- documentation evidence for this task.

### Protected / prohibited

- no Narrative / Provider / Runtime Model Settings behavior change;
- no Public d20 changes;
- no Game Library / Save / Timeline semantic change;
- no SQLite schema change;
- no Source current fallback for old Games;
- no copying authored visual bytes into Game canonical storage merely for display;
- no UI redesign or G6 three-column RPG experience work;
- no image generation/editing pipeline;
- no asset authoring UI;
- no map topology/travel/GIS/procedural system;
- no Reference Library / online store / external media/plugin protocol;
- no G5 World Semantics.

## 7. Deliverables

1. production exact-generation visual resolver with a bounded public seam;
2. support for Character portrait and World portrait/scene/map declarations within frozen contract;
3. deterministic `RESOLVED / ABSENT / UNAVAILABLE` behavior plus safe reason codes;
4. real Godot image decoding/loading from managed package-local bytes;
5. focused fixture set proving exact-generation isolation, path safety, absence and breakage;
6. Windows/export compatibility evidence;
7. repository-native evidence document under `docs/g4_10/`.

Do not add a product-facing visual redesign solely to prove M1. The real two-family presentation/product pressure belongs to G4-11.

## 8. Engineering Acceptance Gates

Prove all of the following:

### AC-01 Exact Character portrait

A task-owned Character exact generation with a declared portrait resolves and real-loads successfully.

### AC-02 Exact World visual

A task-owned World exact generation with at least one declared `scene` or `map` visual resolves and real-loads successfully. If fixtures cheaply cover both, do so, but do not inflate architecture just to satisfy fixture count.

### AC-03 Canonical absence

Character with no `portrait` field returns ABSENT. No placeholder is written into Source or generation fingerprint.

### AC-04 Unsafe path rejection

Traversal / absolute / external-path attempts cannot escape the package root and return safe UNAVAILABLE/rejection behavior.

### AC-05 Broken/missing/tampered visual

Declared but missing/tampered/un-decodable visual is never loaded as authored truth and never silently replaced by current/neighbor/network data. It yields UNAVAILABLE with bounded safe diagnostics.

### AC-06 Source update isolation

Create/publish two generations of the same stable Source identity with different visual bytes. A consumer pinned to generation A must continue resolving A after generation B becomes current; a consumer explicitly pinned to B resolves B.

### AC-07 No writeback

Resolution/loading performs no Source mutation, Game canonical mutation, SQLite migration, Provider call, or model-setting change.

### AC-08 Real Godot / Windows reality

Use real Godot 4.7.2 to decode/load the managed external visual. Validate the canonical Windows export (`run-game.ps1 -ValidateExportOnly`), rebuilding if stale. Provide evidence that the resolver is compatible with the exported Windows product path and does not rely on editor-only `res://` import behavior.

### AC-09 Regression

Relevant Source Library / Source contract / Final Create / Game Library regressions remain green. `git diff --check` must be clean.

## 9. Product Value Acceptance

G4-10M1 is an **Engineering Reality Gate**, not a standalone Owner visual-polish UAT.

Core value protected here:

> exact authored visual identity survives Source updates and can be safely loaded in the real product runtime.

Do **not** claim that the product now visually differentiates both worlds. That belongs to G4-11 Two Primary Asset Families Reality Test and its Owner UAT.

Highest return state for M1:

```text
READY FOR INDEPENDENT REVIEW
```

not `G4-10 PASS`, `G4-GATE PASS`, or `PRODUCT PASS`.

## 10. Validation Order

Run focused/cheap checks before expensive/export checks:

1. resolver unit/focused tests;
2. path-escape / missing / tamper / decode-failure injection;
3. two-generation isolation test;
4. real Godot 4.7.2 managed-file image load integration;
5. directly affected Source / Final Create / Game Library regressions;
6. `run-game.ps1 -ValidateExportOnly`;
7. `git diff --check`.

No real DeepSeek/Kimi call is required for G4-10M1; this task does not change Provider semantics.

All mutable test Source/Game roots must be task-owned. Do not modify Owner production Sources/Games/settings/credentials.

## 11. Git / Integration

- Start by refreshing both repository `main` branches and recording exact START_HEADs/status.
- Never overwrite unknown dirty/newer work.
- Re-check current HEAD before authoritative writes and before push.
- Keep implementation and evidence commits distinguishable where practical.
- Push completed work to `origin/main` under the repository's current integration convention.
- If current Product/Architecture/Roadmap/Task authority changes after START_HEAD, stop and reconcile before continuing.

## 12. Stop / Return Conditions

Stop and return a blocker instead of inventing policy if:

- exact Game provenance cannot currently identify the pinned Source generation needed for resolution;
- frozen Source contract cannot represent the required visual without semantic redesign;
- a Windows-export constraint requires changing product architecture rather than a localized mechanism;
- implementation would require map gameplay/topology, G5 semantics, or a generic media framework;
- tests reveal an integrity conflict where visual fail-soft would incorrectly hide corruption of authoritative non-visual Source truth.

Otherwise complete the bounded mechanism and return:

```text
START_HEAD(s)
IMPLEMENTATION_HEAD
EVIDENCE_HEAD / FINAL_HEAD
changed paths
resolver public seam
exact-generation identity proof
RESOLVED / ABSENT / UNAVAILABLE proof
path-safety/failure-injection results
source-update isolation result
real Godot load result
Windows ValidateExportOnly result
regression results
Owner production surfaces untouched
git diff --check
READY FOR INDEPENDENT REVIEW
```
