# G4-09UATBC02A D20 协议解耦实现证据

Status: implementation complete；等待 GPT Independent Review

START_HEAD: `6a50a2c04a244888c58e4eb395226b72539b5364`

IMPLEMENTATION_HEAD: `beecdef`

Governance HEAD: `d6d8b54530194488c775bcdc601fdd1f965b4230`

## 1. 实现边界

Public d20 的 mechanics control 与 player-visible narrative 已分成独立 selected-provider request：

- control response 只拥有 `NO_CHECK` 或 `CHECK_REQUIRED + proposal`；
- isolated control 在 Provider completion 后整体解析，允许外围空白与 pretty-print JSON；
- control response 必须且只能是一个 JSON object；不从 prose、Markdown fence、前言或尾随正文中猜测结构；
- narrative response 是普通自由文本，没有 JSON header、sentinel、首行、物理 LF 或 parser gate；
- narrative `text_delta` 继续进入既有 provisional Conversation/UI，并只在 completion 后跨越 durable finalize barrier；
- malformed control 最多触发一次内部 recovery；第二次仍 malformed 时 fail-soft 到普通 narrative；
- degradation 返回 `status=accepted`、`degraded=true`、`degradation_code=control_unresolved`，但不创建 d20 check 或伪造成功 NO_CHECK marker；
- CHECK_REQUIRED 仍严格执行 Program RNG/outcome durable commit，然后才启动 result narrative。

未修改 `src/domain/**`、`src/ui/**`、`src/persistence/**`、`src/runtime/**`、`src/provider/**`、Source、Final Create、Game Library 或 Runtime Settings production code。SQLite schema 保持 v4。

实现前 ownership/state/failure matrix：

`docs/g4_09/G4-09UATBC02A_实现前状态失败矩阵.md`

## 2. 旧混合协议删除

已从 production parser/process 删除：

- 首个物理 LF framing；
- `control JSON + raw narrative body` 单响应协议；
- incremental header/body parser 状态；
- NO_CHECK one-call 假设；
- narrative 在 control response 内的 validation/persistence 路径。

Focused negative evidence 直接证明 mixed control+narrative、fence 和 preamble 均不被接受；它们不会污染 player-visible narrative。普通 narrative request 中不存在旧 framing contract。

## 3. Control lane、bounded recovery 与 fail-soft

状态链：

```text
control
-> valid NO_CHECK -> no_check_narrative
-> valid CHECK_REQUIRED -> durable Program check -> resolution_narrative
-> malformed -> control_recovery
   -> valid -> normal branch
   -> malformed -> degraded_narrative
```

Focused fixture 证明：

- 第一次 malformed 后只启动一个 `control_recovery`；
- recovery valid 时正常进入独立 narrative lane；
- recovery 仍 malformed 时不存在第三次 control request；
- degraded narrative request 不回显 raw malformed payload；
- degraded narrative progressive visible、最终 accepted；
- `provider_calls=3`，`degradation_code=control_unresolved`；
- durable check 数与 durable NO_CHECK marker 数均不增加。

Transport/service/cancel failure 本身仍 fail loud；本轮只对无法可靠解析的 optional mechanics classification 做 bounded fail-soft。

## 4. NO_CHECK 证据

Normal NO_CHECK 调用次数固定为 2：

```text
isolated control request
-> valid NO_CHECK
-> free-form narrative request
-> progressive provisional draft
-> durable NO_CHECK resolution
-> durable Conversation/final marker
```

Focused/UI/process evidence 证明：

- control delta 永不投影为正文；
- narrative 首个 delta 在 narrative Provider completion 前可见；
- delta 期间 accepted Conversation 与 World 不变，没有 per-token persistence；
- failure/cancel partial draft 不进入 Context；
- same-process retry 复用同一 provisional Turn；
- accepted replay/reopen 使用 0 Provider、0 RNG，不重复 Turn 或 durable marker；
- 真实 OS Process A/B 使用不同 PID，重开后 exact resolution identity、Game identity、accepted count 与 DB hash 不变。

## 5. CHECK_REQUIRED 证据

正常路径调用次数为 2：isolated control + free-form result narrative。若 control recovery 后才成功，则为 3。

Focused/UI/process evidence 证明时序：

```text
control_completed
< durable_check_completed
< resolution_narrative_request_started
< first_visible_narrative_delta
< provider_completed
< finalize_completed
```

Result narrative failure/cancel/retry/reopen 不重新 adjudicate、不再次调用 RNG。真实 OS Process A/B/C 使用三个不同 PID；Process A 留下 durable check 且 accepted Conversation 为 0，Process B 复用 exact proposal/roll/outcome 并接受一次，Process C replay 使用 0 Provider/0 RNG，数据库 hash 不变。

## 6. 真实双 Provider 证据

Owner 明确授权把 task-owned `汉末三国 / 208 赤壁前夕 / 刘备` 上下文及两类 task-owned 行动发送至 DeepSeek V4 Pro 和 Kimi K3。验证使用 gitignored task roots 内的 Runtime Settings、Source Library、Game Library 与 Game；未读取或覆盖 Owner 默认模型偏好。

真实运行：`failure_count=0`。

| Provider profile | 分支 | stages | calls | accepted | degraded |
|---|---|---|---:|---|---|
| `deepseek_v4_pro` / `deepseek-v4-pro` / effective `high` | ordinary NO_CHECK | `control`, `no_check_narrative` | 2 | yes | no |
| `kimi_k3` / `k3-256k` / effective `high` | CHECK_REQUIRED | `control`, `resolution_narrative` | 2 | yes | no |

非敏感 monotonic timing（微秒，相对 action start）：

| Profile | control complete | durable check | narrative request | first visible narrative | provider complete | finalize |
|---|---:|---:|---:|---:|---:|---:|
| DeepSeek V4 Pro | 6,563,583 | n/a | 6,564,348 | 31,700,656 | 37,166,796 | 37,194,879 |
| Kimi K3 | 11,160,023 | 11,178,508 | 11,179,049 | 19,422,863 | 35,743,716 | 35,752,809 |

证据 JSON 位于 gitignored task root：

`build/g4_09uatbc02a/real-provider/real-provider-results.json`

它只包含 profile/model identifiers、status、stages、call count、branch presence bool 与 timing；不包含 prompt、行动原文、模型正文、隐藏推理、credential、endpoint payload 或 Owner AppData。

两条真实链路各输出过一次 Godot `HTTPClient status != STATUS_BODY` engine warning；两者均继续到达唯一 `accepted` 终态，未触发 control recovery、跨 Provider fallback 或重复 action。

## 7. 回归与命令

以下命令均最终退出 0：

```powershell
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_09uatbc02a/公开D20协议解耦测试.gd' -- '--root=build/g4_09uatbc02a/focused'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_08m1/公开D20机制测试.gd' -- '--root=build/g4_08m1/bc02a-mechanism'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_08m1/NO_CHECK行动幂等修复测试.gd' -- '--root=build/g4_08m1/bc02a-no-check'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_08b/公开D20界面整合测试.gd' -- '--root=build/g4_09uatbc02a/g4_08b'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_07a/首次开场运行时聚焦测试.gd' -- '--root=build/g4_07a/bc02a'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_07b/可玩界面整合测试.gd' -- '--root=build/g4_07b/g4_09uatbc02a-playable'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_09r1/运行时模型设置机制测试.gd'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g3_02/世界持久化流程测试.gd' -- '--root=build/g3_02/g4_09uatbc02a-persistence'
& '.\tests\g4_08m1\运行真实进程重启验证.ps1' -Root 'D:\AI\Projects\my-world\build\g4_08m1\g4_09uatbc02a-check-process'
& '.\tests\g4_08m1\运行NO_CHECK真实进程重启验证.ps1' -Root 'D:\AI\Projects\my-world\build\g4_08m1\g4_09uatbc02a-no-check-process'
& '.\build\g4_09uatbc02a\run_real_provider.ps1'
.\run-game.ps1 -ValidateExportOnly
git diff --check
```

覆盖范围包括 G4-08M1、M1C01、G4-08B UI integration、G4-07A/B no-Expansion legacy route、Runtime Model Settings/current selected-provider routing、G3 durable persistence，以及 CHECK/NO_CHECK real process restart/replay。

## 8. Windows、架构与保护面

- `run-game.ps1 -ValidateExportOnly` 检测 stale export，使用 tracked `Windows Desktop` preset 重建并验证当前 checkout；validation mode 未启动游戏。
- Godot export 因 gitignored 历史 test roots 输出已有 duplicate fixture UID warnings，并输出无法保存 sandboxed editor settings 的 warning；export/verification 最终退出 0。
- 依赖方向保持 `L3 -> L2 -> L1 -> L0`：L1 只依赖本模块 L0；L2 依赖本模块 L1/L0，并仅通过其它模块 L3 seam 访问 Context、Game-local projection 与 Provider。
- `src/domain/**`、`src/ui/**`、`src/persistence/**`、`src/runtime/**`、`src/provider/**`、`src/source/**`、`src/最终建局/**`、`src/游戏库/**` 无 production diff。
- `src/persistence/L2_流程层/世界持久化流程.gd` 的 `SCHEMA_VERSION := 4` 与灾难恢复 `CURRENT_SCHEMA_VERSION := 4` 未变；无 migration。
- `build/**`、Windows binary、`.env.local`、credentials、真实 Provider payload/response、Owner AppData 均未纳入 Git。

## 9. Known limitations

- timing 是 engineering monotonic evidence，不是 Provider benchmark，也不承诺网络延迟上限。
- C02A 暴露非秘密 degradation flag，但不实现 C02B UI notice。
- Godot HTTPClient warning 需要 Independent Review 结合唯一成功终态判断；本任务未扩展 Provider transport scope。
- 本证据不宣布 G4-09UATB、G4-09、G4-08 或 G4-GATE PASS，也不替代 Owner focused product retest。

READY FOR INDEPENDENT REVIEW
