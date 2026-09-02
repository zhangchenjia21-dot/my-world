# G4-09R1P1 — Final Integration / Owner UAT Readiness Evidence

Status: **READY FOR INDEPENDENT REVIEW**
Date: 2026-09-02
Task packet: `docs/tasks/G4-09R1P1_FINAL_INTEGRATION_FRESHNESS_TASK.md`

本轮是 final-head validation / UAT-readiness，不修改 gameplay、Provider、模型设置 UI、Source、公开 d20 或 persistence production code；不声明 G4-09R1、G4-09、G4-08 或 Owner UAT PASS。

## 1. Freshness

| Repository | refreshed `main` |
| --- | --- |
| `my-world` | `239360fa9722f5ef3102bcf7d0d09978ff961e17`（START_HEAD） |
| `Vibe-Coding` | `87bc87ac30b80c47acc0ce4e60f29654e56cc8c9`（执行前及提交前 revalidation HEAD） |

两个仓库执行前均为 clean main，并完整读取各自 `AGENTS.md`、正式 packet、accepted UI review、canonical runtime model settings decision 与现有 Owner UAT B 说明。

## 2. 真实 UI-selected Provider vertical

命令：

```powershell
& 'tests/g4_09r1b1/运行真实模型设置验证.ps1'
```

最终成功证据：`build/g4_09r1b1/real-settings/real-settings-evidence.json`（gitignored，`failures=0`）。runner 只使用 task-owned Game / Source / settings roots，密钥只经本机环境进入 adapter，证据不记录密钥。

| UI selection | persisted profile | 真实结果 |
| --- | --- | --- |
| DeepSeek V4 Pro | `deepseek_v4_pro` | Main Menu 选择并保存；真实 Opening accepted；739 chars |
| Kimi K3 | `kimi_k3` | Main Menu 选择并保存；真实 Opening accepted；370 chars |

两条路径均使用 task-owned `汉末三国 / 208 赤壁前夜 / 刘备`，未 fallback、未替换 Provider，未写 Owner production preference 或 Owner Games。

首次执行中，DeepSeek 已成功后，Kimi case 在 Provider 调用前的 task-owned Source install 阶段一次性 fail-loud：莉维娅 generation 已落盘、current 未发布。全新 Godot/OS process 重跑相同 canonical runner 后，两个 Provider case 均通过且 `failures=0`；该干扰未复现，没有修改 production code 或 runner 来绕过失败。

## 3. Windows export freshness

命令：

```powershell
.\run-game.ps1 -ValidateExportOnly
```

结果：existing export 被判断为 stale，canonical `Windows Desktop` preset 自动 rebuild；`build/windows/my-world.exe` 成功生成并验证 against current checkout，验证模式没有启动游戏。Godot 扫描产生的未跟踪 `.uid/.import` 缓存已按明确路径清理，binary/build 内容未纳入 Git。

## 4. Production UAT prerequisites

支持的 production Source API 检查结果保存在 `build/g4_09p1/r1p1-production-source.json`（gitignored）：

- resolved root：`C:/Users/MRVHREVO/AppData/Roaming/Godot/app_userdata/my world/my-world/source-library`；
- install status：`already_installed`；
- World = 2，Character = 6，Expansion = 1；
- exact Public d20 asset：`exp.check_core.public_d20`；
- fingerprint：`e40bf3cb1059a4952d4230ae624fc3a0ba9bc705e279b13fef8cd1e795ca5ec1`；
- `owner_games_modified=false`。

未手工复制 managed Source，未删除或重写 Owner Games。

## 5. Regression floor

```powershell
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script 'res://tests/g4_09r1/运行时模型设置机制测试.gd'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script 'res://tests/g4_09r1b1/模型设置界面整合测试.gd' -- '--root=res://build/g4_09r1b1/r1p1-settings-ui'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script 'res://tests/g4_09r1b1/模型设置界面窗口布局测试.gd' -- '--root=res://build/g4_09r1b1/r1p1-layout' '--shot-dir=res://build/g4_09r1b1/r1p1-layout/shots'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script 'res://tests/g4_08b/公开D20界面整合测试.gd' -- '--root=res://build/g4_08b/g4_09r1p1-regression'
git diff --check
```

| suite | result |
| --- | --- |
| Runtime Settings mechanism | exit 0 / `failures=0` |
| G4-09R1B1 settings UI integration | exit 0 / `failures=0` |
| G4-09R1B1 layout assertions | exit 0 / 12 viewport-state assertions PASS |
| G4-08B Public d20 UI integration | exit 0 / `failures=0` |
| `git diff --check` | clean |

Headless dummy renderer cannot produce screenshot textures and logs null-texture/save errors; the layout test's actual viewport assertions all passed. Accepted real-window screenshot evidence remains in the reviewed B1 evidence; this task did not claim new headless PNG evidence.

## 6. Owner UAT readiness and protected state

- refreshed instruction：`docs/g4_09/G4-09UATB_Owner产品验收说明.md`；
- route now starts `run-game.cmd -> 模型设置 -> Save -> reopen/effective summary`，then continues Han / 208 / 刘备 / Public d20；
- includes one risky action with a visible d20 card, one ordinary/no-risk action without unnecessary card, and Save -> Main Menu -> Continue durability；
- Owner verdict remains whether Public d20 adds worthwhile gameplay；不是 Provider benchmark；
- status remains **HOLD** pending GPT Independent Review；Codex 未恢复 Owner UAT；
- SQLite production constants remain schema v4；本轮 `src/**` zero diff。

## 7. Changed paths

- `docs/g4_09/G4-09UATB_Owner产品验收说明.md`
- `docs/g4_09r1/G4-09R1P1_FINAL_INTEGRATION_FRESHNESS_EVIDENCE.md`

结论：**READY FOR INDEPENDENT REVIEW**。
