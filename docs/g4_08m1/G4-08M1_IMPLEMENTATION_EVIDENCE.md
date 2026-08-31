# G4-08M1 Implementation Evidence

Status: implementation complete; pending Independent Review
Start HEAD: `3508cf1`
Formal Code Base: `3b5cd80a26091a17d61c5a055637a422a9edb3aa`
Schema before/after: SQLite `v4 -> v4`
UI paths changed: none

Pre-implementation responsibility/state/failure freeze is in `docs/g4_08m1/G4-08M1_责任状态失败矩阵.md`.

## Implemented seams

- Exact Expansion package: `tests/fixtures/g4_08m1/判定与检定_公开d20`.
- Source identity: `exp.check_core.public_d20`, `expansion_pack.v0.1`.
- Binding: `action_check.public_d20.v1` in exclusive slot `action_resolution`.
- Source contract/library: explicit `load/install/get_current/get_exact_expansion`; inventory includes the third type.
- Composition: explicit `0..N` exact generations, deterministic pin order, duplicate and slot conflict fail closed.
- Final Create: exact pins enter the existing immutable canonical `expansions` field (so legacy empty-selection payload/fingerprint does not drift); authored semantic sections and binding materialize under Game-local `expansions` before DB creation; Provider calls remain zero.
- Host public seam: `src/行动判定/L3_外交层/行动判定公开接口.gd`.
- Envelope:
  - `NO_CHECK`: exactly `decision/reason/narrative`;
  - `CHECK_REQUIRED`: exactly `decision/proposal`; Provider proposal has `intent/dc/modifier/stance/modifier_reason/situation_reason/success_intent/failure_stakes`. Program then injects the caller-owned stable `action_id` before validation/freeze; model-supplied identity is rejected as an unknown field.
- Program RNG: `src/行动判定/L1_器件层/程序D20随机源.gd`; production uses randomized Godot `RandomNumberGenerator`, tests inject a deterministic `roll_d20` seam.
- Bounds: integer DC `10..30`, modifier `0..6`; stance exactly normal/advantage/disadvantage; no natural-1/20 override.
- Durable identity: `check_id = check- + SHA-256(game_id + U+001F + action_id)`; first mutation id is `public-d20-<check_id>`.
- Idempotency: durable resolution is inspected before Provider/RNG. Retry/restart skips adjudication and reuses exact Proposal/roll/outcome. `conversation_base_count` recovers the Conversation-committed / acceptance-marker window without duplicating the Player action.
- Persistence: existing v4 World CAS stores `expansion_runtime.public_d20_checks`; no new table, database, transcript or migration.
- Game-local context crosses the existing Opening module through `L3_外交层/游戏本地上下文公开接口.gd`; runtime never rereads mutable Source current.

## Evidence A-J

### A — Source third type

Focused suite proves strict load, real package bytes, fingerprint, install, inventory, current/exact revalidation, semantic-byte fingerprint change and old exact generation retention.

### B — Compatibility

Focused suite proves explicit zero Expansion, Public d20 for Han and Afterglow, duplicate exact rejection, and a distinct task fixture collision in `action_resolution`. No family/genre/year branch exists.

### C — Final Create

Focused suite proves exact generation provenance, rules and binding survive fresh existing-only open; same creation/payload returns the same Game; removing the Expansion under the same creation identity conflicts. Existing G4-06 regression remains green.

### D — No-Expansion

A G4-06-created no-Expansion Game returns `capability_absent` without Provider/RNG/check side effects, leaving the accepted G4-07 single-call path authoritative. G4-07A/B focused regressions remain green.

### E/F — Program RNG and freeze order

Deterministic tests cover normal/high/low selection, total/outcome, ranges, and fake model roll rejection. The test observes proposal validation completion before the first RNG invocation and durable commit before the second Provider request.

### G — retry/restart

- A: first Provider failure leaves zero roll/check and permits retry;
- B: second Provider failure after a losing roll leaves the exact durable result;
- C: three distinct Godot/OS processes prove interruption after durable resolution, restart continuation without RNG, and accepted replay without DB mutation;
- D: duplicate accepted submit creates no second request/check/turn;
- E: accepted result appends one Player action; durable marker and base-index recovery prevent duplication.

Real process run: Process A/B/C PIDs `36960 / 23944 / 25896`; all reopened Game
`game-bc69e51a7dbdea277345550c59e5bbcc` and check
`check-9121f1d7a11e7a113280dc6fe301bb2b7e60b85256ab63e75d77c6d2815dd401`.
Process B reused roll `2` / `failure` without RNG; Process C made no Provider call,
kept one accepted turn, and left the closed SQLite SHA-256 unchanged.

### H — real DeepSeek / Han

Real `deepseek-v4-pro` evidence is tracked in `G4-08M1_REAL_PROVIDER_EVIDENCE.json`:

- high-risk infiltration naturally returned `CHECK_REQUIRED`;
- Program rolls `[16,11]`, disadvantage selected `11`; `11 + 2 = 13 < DC 20`, outcome `failure`;
- second real Provider continuation accepted the Program-decided failure;
- later date-inquiry attempt returned `NO_CHECK` under the established post-failure reality and completed in one Provider stage with no new check;
- close/reopen retained the exact check and two accepted Conversation turns.

### I — real DeepSeek / Afterglow

The same exact Expansion and Host seam handled Livia's unstable magic-pipeline action:

- stages `adjudication -> resolution_narrative`;
- Program roll `[11]`, normal selected `11`; `11 + 3 = 14 < DC 16`, outcome `failure`;
- accepted narrative was durable; Host/materialized rules contained no Han-specific mechanism.

### J — regression/security

- World/Character contract and full-fidelity Source regressions pass.
- Managed Library G4-03 regression passes.
- G4-06 reality/conflict/restart suites pass.
- G4-07A focused and G4-07B integration suites pass.
- no Source executable declaration/loading was added;
- no API key, Owner AppData, managed production library or build binary is tracked;
- `src/ui/**` unchanged;
- `git diff --check` clean.

## Commands

```powershell
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_08m1/公开D20机制测试.gd' -- '--root=D:/AI/Projects/my-world/build/g4_08m1/focused-final'
& 'D:\AI\Projects\my-world\tests\g4_08m1\运行真实进程重启验证.ps1'
& 'D:\AI\Projects\my-world\tests\g4_08m1\运行真实DeepSeek验证.ps1'
```

Regression scripts executed:

```text
tests/g4_02/Source合同现实测试.gd
tests/g4_02r1/Source_v0_2_r2_机制现实测试.gd
tests/g4_03/Source库现实测试.gd
tests/g4_06/原子最终建局现实测试.gd
tests/g4_06/创建冲突与发布失败测试.gd
tests/g4_06/创建失败窗口重启测试.gd
tests/g4_07a/首次开场运行时聚焦测试.gd
tests/g4_07b/可玩界面整合测试.gd
```

## Known limitations

- Only `action_check.public_d20.v1` is implemented; unknown capability ids fail loud.
- M1 is UI-neutral: no Wizard Expansion selector or mechanic-card rendering.
- Historical checks are bounded audit/provenance in World document; downstream fictional consequences remain owned by existing World/Character/Conversation flows.
- No Attributes, skills, crits, combat, arbitrary dice, scripting/plugin runtime or G5 system is introduced.
