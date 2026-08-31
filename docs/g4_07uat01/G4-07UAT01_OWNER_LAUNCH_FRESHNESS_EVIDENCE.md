# G4-07UAT01 — Owner Launch Freshness Correction Evidence

Status: **READY FOR INDEPENDENT REVIEW**
Date: 2026-08-31
START_HEAD: `09f9537b510b3c30dfc6cee9b10285095af99952`
Formal Code Base: `1bd0d414dfe8ed5a7781d9db6813317d2f20bf91`
Task Packet: `docs/tasks/G4-07UAT01_OWNER_LAUNCH_FRESHNESS_CORRECTION_TASK.md`

> 本证据只证明正式 Owner launcher 对当前 checkout 的 freshness 与失败阻断。它不声明 G4-07 Product PASS；Owner UAT 需在 GPT Independent Review 后恢复。

## 1. 实现边界

生产改动仅为 `run-game.ps1`。`run-game.cmd` 保持正式入口且字节未改；G4-07A/G4-07B gameplay、UI、backend、Source contract、SQLite schema 均未修改。

launcher 在读取并校验现有 `.env.local` 白名单后、注入 Provider 环境之前，先收敛 Windows export。原有白名单、秘密不输出行为以及 `finally` 环境恢复逻辑保持不变。

## 2. Freshness 规则

输入集合：

- `src/**`
- `addons/**`
- `project.godot`
- `export_presets.cfg`

对输入文件按完整路径稳定排序；每项记录规范化相对路径、字节长度与文件 SHA-256，再对 UTF-8 manifest 做聚合 SHA-256。实现使用 .NET `FileStream` + `SHA256`，不依赖 PowerShell module autoload。

ignored stamp：`build/windows/my-world.freshness.json`。只有以下条件同时成立才视为 current：

- `build/windows/my-world.exe` 与 `my-world.pck` 均存在；
- stamp schema 为 `my-world.owner-export-freshness.v1`；
- stamp input hash 与当前 checkout 一致；
- preset 为 `Windows Desktop`；
- target 为 `build/windows/my-world.exe`。

missing/stale 时先撤销精确旧产物（EXE/PCK/stamp）的 launch eligibility，再执行：

```powershell
D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe `
  --headless `
  --path D:\AI\Projects\my-world `
  --log-file D:\AI\Projects\my-world\build\windows\owner-export.log `
  --export-debug "Windows Desktop" `
  D:\AI\Projects\my-world\build\windows\my-world.exe
```

只有 Godot exit 0、非空 EXE/PCK、export 前后输入 hash 未变化且回读 stamp 成功后才允许启动。

## 3. Windows evidence A–G

### A. Missing export → rebuild → launch

将既有 ignored EXE/PCK 移到 task-owned ignored backup 后，通过 canonical：

```text
cmd.exe /d /c D:\AI\Projects\my-world\run-game.cmd
```

真实运行结果：missing 被识别；Godot 4.7.2 使用 tracked `Windows Desktop` preset 完成 export；stdout 出现 `Windows export rebuilt and verified against the current checkout.`；随后启动的进程路径为 `D:\AI\Projects\my-world\build\windows\my-world.exe`。

### B. Current export → no rebuild

命令：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\run-game.ps1 -ValidateExportOnly
```

结果 exit 0，输出 `Windows export is current; skipping rebuild.`。前后时间戳完全相同：

| artifact | before UTC | after UTC |
| --- | --- | --- |
| `my-world.exe` | `2026-08-31 04:56:53` | `2026-08-31 04:56:53` |
| `my-world.pck` | `2026-08-31 04:57:05` | `2026-08-31 04:57:05` |
| freshness stamp | `2026-08-31 04:57:08` | `2026-08-31 04:57:08` |

### C. Product source changes → stale rebuild → launch

在 `src/` 临时增加 task-owned freshness probe 后再次执行 canonical `run-game.cmd`。结果识别 stale、重新 export、验证成功，并启动新的 `my-world.exe`。probe 随后删除；最终 checkout 又执行一次 verified export，确保本地正式产物对应最终无 probe 的输入 hash。临时 probe 未提交。

### D. Export failure → fail loud / zero fallback

将 `src/` probe 改变后，用 task-owned ignored fake exporter 返回 exit 23：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\run-game.ps1 `
  -GodotExecutable .\build\g4_07uat01_fake_export_failure.cmd `
  -ValidateExportOnly
```

结果：launcher exit 1；输出 `Windows export failed (exit 23); the stale executable will not be launched.`；验证前后 `my-world` 进程数均为 0；EXE/PCK/stamp 均不存在。因此失败无法回退旧 EXE。fake exporter 与 probe 均已删除，随后用真实 Godot 恢复 final current export。

### E. Refreshed UI is current G4-07B

使用 computer-use 对 canonical launcher 启动的精确 process-backed window 做真实桌面检查：

1. 主菜单可见并可点击 `新游戏`，不是历史 disabled placeholder；
2. 点击后进入 `选择世界`；
3. 右上显示 `步骤 1 / 7`，底部存在 `返回主菜单` / `下一步`，证明到达当前 G4-07B Wizard path。

首次检查时 Owner production Source Library 尚无 World Pack，因此 Wizard 正确显示 inventory empty；此状态属于 Owner 本机数据，不是 launcher freshness 失败。

### F. Secrets / environment

- 对全部 task-owned launcher stdout/stderr 日志做秘密值内存比对：`SECRET_LOG_MATCH_COUNT=0`，检查过程不输出 secret；
- diff 证明 `.env.local` 仍只接受 `DEEPSEEK_API_KEY` 与 `MY_WORLD_DEEPSEEK_MODEL`；
- export freshness 阶段不把本地值注入 export process；
- game launch 的临时环境注入与 `finally` 恢复代码未改。

### G. Git / binary hygiene

`git check-ignore -v` 证明 EXE、PCK、stamp 均由 `.gitignore` 的 `build/` 规则忽略。提交仅包含 launcher 与本证据文档；无 build binary、Owner AppData、`.env.local` 或 key。

## 4. Regression / static verification

PowerShell 5.1 parse：`POWERSHELL_PARSE_ERRORS=0`。

G4-07B focused suite：

```powershell
D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe `
  --headless --path . `
  --script res://tests/g4_07b/可玩界面整合测试.gd -- `
  --root=D:/AI/Projects/my-world/build/g4_07uat01_regression/g4_07b
```

结果：`G4-07B UI | done failures=0`（61 PASS / 0 FAIL）。

其他检查：

- `git diff --check`：通过；
- 相对 Formal Code Base 的 `src/**` / `addons/**` / `project.godot` / `export_presets.cfg`：零 task diff；
- `run-game.cmd` SHA-256：`6579B6480B6AE59F530FC87B515085EF9136FA24C9162395D617E818B99DA0A1`，未修改；
- production SQLite schema：保持 v4。

## 5. 已知边界

- content hash 每次 launch 会读取 product input bytes；这是为避免 Git 状态、mtime 回拨与旧 ignored binary 误判所付出的确定性成本。
- `-ValidateExportOnly` 是 task-owned 非启动验证入口；Owner canonical path 仍是 `run-game.cmd`。
- export 日志中的历史 ignored `build/` fixture UID duplicate warning 与本 launcher 改动无关；export 已成功产出并验证当前 checkout。

## 6. 结论

G4-07UAT01 launcher freshness correction 已满足 required evidence A–G，返回上限：**READY FOR INDEPENDENT REVIEW**。不声明 G4-07 Product PASS。
