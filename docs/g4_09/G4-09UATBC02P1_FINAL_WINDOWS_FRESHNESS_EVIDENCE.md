# G4-09UATBC02P1 — Final Windows Freshness Evidence

Status: **READY FOR INDEPENDENT REVIEW**

Date: 2026-09-02

Task Packet: `docs/tasks/G4-09UATBC02P1_FINAL_WINDOWS_FRESHNESS_TASK.md`

## 1. Freshness

两个仓库开始时均为 clean worktree，并 fast-forward 到最新 `origin/main`：

| Repository | START_HEAD |
|---|---|
| `zhangchenjia21-dot/my-world` | `e8dfcdce26487da0ffd6967eea703b104ca907a2` |
| `zhangchenjia21-dot/Vibe-Coding` | `973ea6c858a9ff409b90996214890f7144ec57c4` |

读取了两个仓库当前 `AGENTS.md`、正式 P1 Task Packet 与 C02BC01 Independent Review。Authority 未发现冲突：本任务为 validation-only，不修改 product behavior，不重跑 Provider benchmark。

## 2. Canonical Windows freshness

执行：

```powershell
.\run-game.ps1 -ValidateExportOnly
```

首次结果：

```text
Windows export is missing or stale; rebuilding preset 'Windows Desktop'.
Windows export rebuilt and verified against the current checkout.
Windows export freshness validation completed; game launch skipped by explicit validation mode.
```

- canonical launcher 识别到旧 export 落后于当前 final correction-02 source head；
- 使用 tracked `Windows Desktop` preset 重建 `build/windows/my-world.exe`；
- export 验证成功，进程退出码为 0；
- validation mode 没有启动游戏；
- `build/` 保持 gitignored，未提交 binary。

紧接着第二次执行同一命令：

```text
Windows export is current; skipping rebuild.
Windows export freshness validation completed; game launch skipped by explicit validation mode.
```

第二次退出码仍为 0，直接证明 current export 不会无意义重复 rebuild。

首次 export 扫描 gitignored 历史 test roots 时输出既有 duplicate fixture UID warnings，并因当前 sandbox 无法保存全局 Godot editor settings 输出 warning；这些不影响 export/verification 的成功终态。

## 3. Focused G4-08B / C02B / C02BC01 integration

执行：

```powershell
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' `
  --headless --path 'D:\AI\Projects\my-world' `
  --script 'res://tests/g4_08b/公开D20界面整合测试.gd' -- `
  '--root=build/g4_08b/g4_09uatbc02p1-focused'
```

结果：**127 PASS / 0 FAIL，退出码 0**。

本次 current-head 运行直接覆盖：

- C02B transport failure 的安全连接类别与 `重试行动`；
- C02B missing-key 安全凭据类别；
- malformed control 的一次 recovery 与 degraded ordinary narrative；
- degraded action 不显示为 `行动未完成`，不产生 d20 card；
- C02BC01 `check_persistence_failed` 的安全保存类别与重试；
- C02BC01 `persistence_failure` 的安全保存类别与重试；
- C02BC01 acceptance-marker failure 的安全保存类别与重试；
- 不暴露 SQL、SQLite、`user://` 或 credential；
- 正常 CHECK_REQUIRED / NO_CHECK、durable-before-narrative、retry/reopen no-reroll；
- no-Expansion legacy route、Game data preservation 与 restored mechanic card。

Godot 在退出时报告既有 ObjectDB/resource cleanup warnings；suite 的业务断言与进程退出码均成功。

## 4. SQLite 与保护面

SQLite 版本仍为 v4：

```text
src/persistence/L2_流程层/世界持久化流程.gd
  SCHEMA_VERSION := 4

src/persistence/L2_流程层/数据库灾难恢复流程.gd
  CURRENT_SCHEMA_VERSION := 4
```

验证前后对 production Owner surfaces 做了只读递归聚合指纹比对：

| Surface | Before / After |
|---|---|
| `user://my-world/source-library` | identical，115 files |
| `user://my-world/game-library` | identical，4 files |
| `user://my-world/games` | identical，12 files |
| `user://my-world/settings/provider-runtime.json` | identical |
| repository `.env.local` | identical |

未读取或打印 credential value。未运行 DeepSeek/Kimi 请求。Focused suite 的 Source、Game Library 与 Games 全部位于 gitignored task-owned `build/g4_08b/g4_09uatbc02p1-focused`。

## 5. Repository scope

- 本任务没有 production code、test、Source fixture、Provider、settings、schema 或 launcher 语义修改。
- changed path 仅为本 evidence 文档。
- Windows export binary 仅位于 gitignored `build/`。
- `git diff --check` 在 evidence 创建前为 clean；本 evidence 自身也通过 whitespace check。
- Vibe-Coding 仓库保持 clean，无治理写回。

## 6. Disposition

当前 final correction-02 source head 已具有 fresh、canonical、可重复验证且不会无意义重建的 Windows Owner export。Owner focused reliability/responsiveness retest 仍需等待 GPT Independent Review；本任务不宣布 G4-09UATB、G4-09、G4-08 或 G4-GATE PASS。

**READY FOR INDEPENDENT REVIEW**
