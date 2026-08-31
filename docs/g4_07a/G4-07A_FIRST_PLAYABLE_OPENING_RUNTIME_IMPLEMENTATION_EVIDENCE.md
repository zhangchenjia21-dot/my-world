# G4-07A｜First Playable Opening Runtime Implementation Evidence

Status: implementation complete; pending Independent Review  
Start HEAD: `0a8c8aa0477b92be85634bea833824502ed12a97`  
Implementation commits: `dac0e8e4bf655a234ca5b8d0952f6a199373b4af`, `221710941950198c4fced9c30991bd295fea39ef`  
Engine: Godot `4.7.2.stable.official`, Standard/non-.NET Windows x64

## 1. Implemented boundary

The production seam is `src/首次开场/L3_外交层/首次开场公开接口.gd`.

It accepts an already-opened `当前游戏会话运行时`, validates a durable `game_local_setup.v0.1`, projects rich selected Game-local material, starts the existing DeepSeek streaming adapter, streams into the existing Conversation draft, and calls the existing persist-before-accept runtime seam after Provider completion.

The first request has one `system` message and no Player message. SQLite v4 stores the accepted GM Opening in the existing pair envelope with an empty `player_text` compatibility slot. The Context assembler suppresses that empty slot on later requests, so it never becomes fake Player speech.

No Source Library, Wizard state, Final Create replay, second Provider stack, second transcript store, UI, Expansion, G5, or G7 mechanism was added.

## 2. State/failure alignment

Pre-implementation matrix:

`docs/tasks/G4-07A_OPENING_RUNTIME_STATE_FAILURE_MATRIX.md`

The matrix covers A–O, fixes the request/commit/accept ordering, sets the first-Opening eligibility rule, records bounded-rich context ownership, and closes the schema gate as no migration.

## 3. Real DeepSeek evidence

Runner:

```powershell
& 'D:\AI\Projects\my-world\tests\g4_07a\运行真实DeepSeek验证.ps1'
```

The runner reads only the allowlisted local `DEEPSEEK_API_KEY` and optional model name into process environment, never prints them, and restores prior process environment in `finally`. The tracked repository contains no key, auth header, or private environment file.

Both routes used production G4-06 creation, an existing-only open, the production G4-07A interface, the real `deepseek-v4-pro` adapter/network path, durable acceptance, close, and fresh-runtime reopen.

| Route | Provider-visible selected context | Context | Provider result | Durable result |
|---|---|---:|---:|---|
| Han / 208 | exact `t0-208-red-cliffs-eve`, `e208-snapshot`, Liu Bei `han-208`; excludes `e220-snapshot` and `liu-bei-220` | 28,491 chars; World 16 sections, Player 2, NPC 2 | TTFT 10,110 ms; 569 deltas; 791 chars; SHA-256 `b5533f25a656b992c57400ebc091de8d8add6acb1ec2d3d31dc23ea1bf75492c` | one GM-only accepted entry; reopen exact |
| Afterglow / public works | exact `t0-1287-public-works`; distinct Livia, Adrian, Duen material | 56,322 chars; World 25 sections, Player 3, NPC 6 | TTFT 17,939 ms; 591 deltas; 855 chars; SHA-256 `5615a6a35d2e107b886c3d0ac59594584a8aa3d6dcd5e0b9e6b67d3a3d4a73f1` | one GM-only accepted entry; reopen exact |

The real Han response began from rainy Jiangxia before the unresolved Red Cliffs situation. The real Afterglow response began in 1287 at Ovista's public-works edge with Livia. These excerpts are semantic-transport evidence only, not a narrative-quality or Product PASS judgment.

The first sandboxed network attempt ended before any delta with `transport / HTTPClient.poll() error 25`; accepted Conversation remained zero. The authorized out-of-sandbox rerun succeeded for both routes. This is also a real failure-before-accept observation, but deterministic failure coverage remains the formal assertion source.

## 4. Han, no-Entry, Source isolation, and Guaranteed NPC

Focused command:

```powershell
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_07a/首次开场运行时聚焦测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_07a_focused_final'
```

Exit `0`, failures `0`.

- Han Provider messages contained the exact 208 Entry/profile section IDs and excluded known 220 future markers.
- A newer mutable Source current carrying `MUTABLE_SOURCE_CURRENT_MUST_NOT_ENTER_OPENING` was installed after create; the marker did not enter Opening Context.
- no-Entry remained durable `null`, rendered `Selected Entry: none` and `Exact selected profile: none`, and contained no inferred 208 Entry/profile.
- Guaranteed Sun Quan remained available as canonical cast material while the runtime directive explicitly denied automatic Opening presence, co-location, familiarity, relationship, or mandatory dialogue.
- Complete already-selected semantic sections were retained in stable order. No section was truncated or summarized. Context above 180,000 characters fails before Provider rather than silently starving the request.

## 5. Failure, cancel, retry, and exactly-once

The same focused suite proved:

- controlled Provider failure after partial streaming leaves durable accepted count `0`;
- cancel after partial streaming leaves durable accepted count `0`;
- each state can retry cleanly;
- only the successful retry becomes accepted;
- accepted Opening count becomes exactly `1`;
- another first-Opening call returns `already_opened` and creates no second Provider request;
- missing DB does not create a replacement, and corrupt SQLite fails loud.

Persistence failure ordering remains the existing G3 contract: non-mutating candidate → `write_current_conversation` commit → in-memory `complete_generation`. The G3 candidate/context regressions below pass unchanged.

## 6. Fresh OS process reopen

Command, run after the real Provider suite in a distinct Godot process:

```powershell
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_07a/真实开场跨进程重开验证.gd' -- --evidence='D:/AI/Projects/my-world/build/g4_07a_real_provider/real-provider-evidence.json' --output='D:/AI/Projects/my-world/build/g4_07a_real_provider/process-reopen-evidence.json'
```

Exit `0`, process PID `17128`, failures `0`.

- Han reopened `game-a0fa968f31cf4a247cec2722f1325930`, head `root-6cd25a56484cae4d85f14732783ad92e`, accepted count `1`, exact response hash, and `already_opened` on second-first-Opening attempt.
- Afterglow reopened `game-753e54eae8cd3090dd32f1da72d366c8`, head `root-047f22c46f90083478e9fe0d9846249d`, accepted count `1`, exact response hash, and `already_opened` on second-first-Opening attempt.
- Each next continuation request was assembled through the same G4-07A public interface from the freshly reopened durable World + Conversation. Roles were `[system, assistant, user]`: rich durable Game-local setup, durable GM Opening, then a real Player action, with no empty fake `user` message. Han retained `e208-snapshot`; Afterglow retained `t0-1287-public-works`.

## 7. Regression commands

All commands exited `0`:

```powershell
# G2 Conversation and Context
--script res://tests/g2_04_会话域离线测试.gd
--script res://tests/g2_05_上下文组装离线测试.gd

# G3 rehydration, candidate, persistence, and Context
--script res://tests/g3_03/会话恢复与候选测试.gd
--script res://tests/g3_03/上下文恢复与界面测试.gd -- --root=.../build/g4_07a_regress_g3_context

# G4 Source semantics/library/lifecycle/Wizard
--script res://tests/g4_02r1/Source_v0_2_r2_机制现实测试.gd -- --work-root=.../build/g4_07a_regress_g4_02r1_mechanism
--script res://tests/g4_02r1/Source可选时态范围证据测试.gd
--script res://tests/g4_03/Source库现实测试.gd -- --work-root=.../build/g4_07a_regress_g4_03
--script res://tests/g4_04/多游戏生命周期现实测试.gd -- --root=.../build/g4_07a_regress_g4_04
--script res://tests/g4_05/新游戏向导全保真现实测试.gd -- --root=.../build/g4_07a_regress_g4_05

# G4-06 production creation and failure/retry seams
--script res://tests/g4_06/原子最终建局现实测试.gd -- --root=.../build/g4_07a_regress_g4_06_create
--script res://tests/g4_06/创建失败窗口重启测试.gd -- --root=.../build/g4_07a_regress_g4_06_restart
--script res://tests/g4_06/创建冲突与发布失败测试.gd -- --root=.../build/g4_07a_regress_g4_06_failure
```

Godot editor parse (`--headless --editor --quit`) and `git diff --check` also exit `0`. Expected focused logs include deliberate corrupt-SQLite and writer-lock errors inside passing fail-loud assertions.

## 8. Architecture and schema status

- New business module follows `L3 → L2 → L1 → L0`; no upward dependency was introduced.
- Cross-module runtime dependencies reuse current public/application seams; no Source internals are referenced.
- Production SQLite constants remain schema v4. No migration, table, column, or SQL statement changed.
- Frozen 2 World + 6 Character fixtures are unchanged.
- Provider payload still contains no `max_tokens` or other output-length limit.

## 9. Known limitations

- G4-07B UI wiring is intentionally absent.
- Context policy is a G4-07A full-section setup projection with a hard malformed-input ceiling, not a G7 long-session relevance/retrieval/summarization platform.
- Guaranteed NPC definitions are presently included as canonical GM knowledge with an explicit non-convergence rule; later placement/knowledge/relationship truth remains future Game-local work.
- Automated and real Provider evidence proves mechanism and semantic transport only. G4-07 Product PASS and narrative value are not claimed; the parent gate still requires later Owner UAT.
