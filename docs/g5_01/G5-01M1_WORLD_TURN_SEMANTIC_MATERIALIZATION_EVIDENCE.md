# G5-01M1 World Turn / Semantic Materialization Evidence

Status: **READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**

## Heads

- START_HEAD: `d3d4182f3fad450e5dcde1790e0cef86ec2d2900`
- Parent G5-01M1 local-work start: `8769deaaac539f249812399c76afc9e86af43f8d`
- IMPLEMENTATION_HEAD: `eb171a19dd0b4eeb134392128fb8df7fd5b104cb`
- EVIDENCE_HEAD: this evidence commit
- Governance HEAD observed: `19d318fb1be9ab4e8d69315f2fc3c52ed335fa13`

## Architecture and changed paths

The implementation follows:

```text
durable Conversation acceptance
→ one independent best-effort semantic request per accepted ordinary-turn version
→ validated living_world.v0.1 candidate
→ existing commit_world_mutation_durably CAS
→ committed/hash-matching bounded projection in later Context
```

- `src/世界回合/L0_公理层/世界回合规则.gd`: stable IDs, hashes, durable record invariants and immutable candidate construction.
- `src/世界回合/L1_器件层/语义变更响应解析器.gd`: bounded machine-response parser.
- `src/世界回合/L1_器件层/世界回合上下文投影器.gd`: committed/current-hash-matching recent projection.
- `src/世界回合/L2_流程层/语义物化流程.gd`: durable trigger, one-attempt queue, fail-soft Provider lane and atomic mutation orchestration.
- `src/世界回合/L3_外交层/世界回合公开接口.gd`: stateful composition boundary.
- `src/世界回合/L3_外交层/世界回合上下文公开接口.gd`: read-only Context projection boundary.
- `src/首次开场/L2_流程层/首次开场运行流程.gd`: appends only matching committed materialized changes to continuation Game Context.
- `src/应用壳.gd`: owns the Game-session lifetime of the independent worker.
- `tests/g5_01/**`: controlled, real-SQLite and selected-Provider runners.

Dependency audit: module internals follow `L3 → L2 → L1 → L0`; cross-module calls use Provider/World Turn L3 boundaries or composition-root injection. No production UI, Source fixture/contract, Runtime Model Settings, Public d20, persistence schema or G6 path changed.

Narrative acceptance is not gated by semantic analysis. Empty, malformed, transport, missing-credential and persistence failures leave accepted Conversation intact and publish no fake World Turn.

## Offline focused evidence

Godot: `D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe` (`4.7.2.stable`).

Passed:

```powershell
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\AI\Projects\my-world --script res://tests/g5_01/世界回合语义物化测试.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\AI\Projects\my-world --script res://tests/g5_01/世界回合时间线恢复测试.gd -- --root=D:/AI/Projects/my-world/build/test-data/g5_01-timeline-final2-20260903
```

The suites prove:

- provisional/cancelled/failed Narrative never triggers analysis;
- each durable ordinary accepted version triggers exactly one request;
- valid non-empty results commit exactly one World Turn;
- empty/malformed/transport/synchronous start failures commit none and do not retry;
- persistence failure does not publish candidate memory or roll back Conversation;
- same-version replay is idempotent;
- GM-only Opening is skipped;
- a legacy G4 World gains the optional namespace on first success;
- accepted correction immediately quarantines the stale hash record;
- rematerialization replaces the same turn index;
- Save/Restore/reopen returns matching Conversation + semantic World state and excludes restored-away future memory;
- later assembled Context contains the matching committed change and excludes malformed, stale and uncommitted material;
- JSON/SQLite integral-number round-trip remains valid without accepting string/non-integral turn indices.

## Regression evidence

Passed directly affected suites:

```powershell
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\AI\Projects\my-world --script res://tests/g2_04_会话域离线测试.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\AI\Projects\my-world --script res://tests/g2_05_上下文组装离线测试.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\AI\Projects\my-world --script res://tests/g3_02/世界持久化流程测试.gd -- --root=D:/AI/Projects/my-world/build/test-data/g3_02-g5-regression-20260903
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\AI\Projects\my-world --script res://tests/g3_04/存档恢复持久化测试.gd -- --root=D:/AI/Projects/my-world/build/test-data/g3_04-g5-regression-20260903
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\AI\Projects\my-world --script res://tests/g4_07a/首次开场运行时聚焦测试.gd -- --root=D:/AI/Projects/my-world/build/test-data/g4_07a-g5-regression-20260903
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\AI\Projects\my-world --script res://tests/g4_07b/可玩界面整合测试.gd -- --root=D:/AI/Projects/my-world/build/test-data/g4_07b-g5-regression-20260903
```

The editor/check-only scan passed. The known Windows root-certificate warning and ignored `build/**` duplicate-UID scan warnings were non-gating. `git diff --check` passed.

## Real selected-Provider status

**Real Provider vertical status: `PENDING / EXTERNAL PROVIDER UNAVAILABLE`.** This evidence does not claim real Provider PASS.

Owner authorized the task-owned `汉末三国 / 208 赤壁前夕 / 刘备 / Expansion none` Context and at most two named persistent-consequence actions for Kimi K3.

Effective immutable profile on both attempts:

- profile: `kimi_k3`
- provider: `kimi`
- model: `k3-256k`
- reasoning: `high`
- fallback: none

Commands:

```powershell
pwsh -NoProfile -File D:\AI\Projects\my-world\tests\g5_01\运行真实Provider世界回合验证.ps1
pwsh -NoProfile -File D:\AI\Projects\my-world\tests\g5_01\运行真实Provider世界回合验证.ps1 -Root D:\AI\Projects\my-world\build\g501-retry
```

Both independent attempts reached:

```text
task-owned real Source install
→ G4-06 exact Game create
→ existing-only open
→ durable task-owned GM-only Opening
→ first ordinary Kimi K3 Narrative request
→ 420 s without Provider delta or terminal
→ runner cancel / narrative_timeout
```

No ordinary Narrative was accepted, so the real run did not exercise semantic analysis or World mutation. The runner did not fall back, did not make a hidden model switch, did not change model settings and did not perform a third attempt. The mandatory real chain (`Narrative accepted → semantic analysis → commit → reopen → later Context`) remains unproven. Per G5-01M1C01, external Provider availability does not block review of the committed engineering implementation, while product/reality acceptance remains pending.

For both attempts, before/after SHA-256 inventory snapshots were identical for Owner production:

- `settings/provider-runtime.json`
- `source-library`
- `games`
- `game-library`
- `current-game.sqlite`

No credential, full request, full response, reasoning, task-owned SQLite or Owner AppData is committed.

## Schema / scope status

- production SQLite schema remains v4;
- no migration or new table;
- `living_world.v0.1` is an optional World document namespace and turn-level consequence ledger only;
- G5-02+, generic ontology/retrieval, UI and G6 work were not started.
