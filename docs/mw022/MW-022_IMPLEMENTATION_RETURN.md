# MW-022｜UAT Observability / Debug Mode v0.1

Status: **READY FOR INDEPENDENT REVIEW**
Date: 2026-09-08

## Exact source identity

- Branch: `mw-022-uat-observability-debug-mode`
- Worktree: `D:/AI/Projects/.worktrees/my-world/mw-022-uat-observability-debug-mode`
- Formal Code Base / refreshed implementation `origin/main`: `d81f5f215360780cc50038ccd3bce7cb4163b866`
- Starting HEAD: `8986861c95c31eef5af23ac4d15e5bfe3c0abdfd`
- Implementation HEAD: `7eae9d5ef39d19a917bc28463799807d76d6d92a`
- Final candidate: Implementation HEAD 之后包含本 Return 和 evidence 的文档提交；精确 SHA 在提交后的最终交付消息返回。候选的 production/test tree 精确等于 Implementation HEAD。
- Governance main（开始与最终 fetch 均一致）: `87451a4dc2ed12728c1150ec9c066a4fa92a9eb1`

已刷新两仓 main，读取 governance AGENTS/Owner preferences、current status v17.13、roadmap v4.4、frozen observability decision、U2 v1.2 closure、repository AGENTS 和本 Task Packet。旧 AGENTS stage table 不覆盖 current governance。没有 superseding architecture；Starting HEAD 相对 formal base 只增加 Task Packet，生产基线有效。

任务开始检查 branch/status/worktrees，指定 worktree 起始无 tracked/untracked 改动。未修改、合并 main，未安装 Owner build。Owner canonical checkout 仍为 `d81f5f215360780cc50038ccd3bce7cb4163b866`，其 `.gitignore` 本地修改和原有十个 screenshot/import sidecar 均保留。未启动 Owner 真人 UAT，未打开 Owner Game/Source 数据。

## Implemented result

Game TopBar 增加 `调试` toggle。每次 activation OFF；关闭 Game 丢弃记录，reopen 不恢复 Debug 偏好或历史。ON 显示右上局部浮层抽屉，高 156px、宽不超过 660px，有独立垂直 scrollbar；OFF 不显示面板。浮层不参与主 Host 高度分配，切换不挤压 Narrative/composer，不改变 World Information taxonomy。

一个 Shell-owned `src/调试观测` owner 订阅现有 L3/lifecycle seam，最多保留 64 **entries**（不是 64 Turns）。同版本同 lane 更新最近记录。隐藏时继续只读收集；无轮询模型、无新 Provider call、无 durable diagnostic state。

| Domain | Evidence and behavior |
| --- | --- |
| Narrative | 原 Conversation accepted/failed/cancelled；未被接受的失败/取消归本次会话，不冒充 accepted version |
| World | 原 WorldTurn current terminal；明确 change_count > 0 / == 0 区分 changed/no-change，失败 unknown；只有现成结构计数 |
| Identity | 同一 World 事务独立显示新 actor 数与 binding 数；只在既有成功 terminal 增加 binding_count，无第二次解析/identity call |
| Character | 同一次 Curator 前后安全 L3 Character projection 精确比较 |
| Important Experiences | 安全 L3 experiences 前后比较，显示 total/added/removed 数 |
| People | 安全 L3 People projection 前后比较，显示 changed/no-change 与当前卡片 total；投影不含 stable ID，因此不按姓名配对推算 add/update/remove 数 |
| Recommendations | 新 diagnostic-only started/terminal signal；正常 snapshot 仍只有 status/actions。区分 ready、input unavailable、malformed、oversized、provider/start failure、timeout、cancelled、stale，并显示有界耗时 |
| Save / Restore | 原 Shell 操作返回结果的只读观测；真正 Restore 清 epoch 后记录 restored。already_current 不伪称清除了历史；失败只显示安全持久化原因 |

Curator 新信号仅携带内部 request serial / source index / prefix / epoch / success / status。三个 curation domain 共用真实 terminal，失败时同时显示 shared abnormal result，绝不伪造各自成功。before/after 内容停留在观测 owner，叶 UI 仅收到闭集展示行与计数。

历史 `already_materialized` / `historical_skipped` 没有本次计数字段时显示 unknown，不把缺失证据默认为零变化。保存的旧结果可以显示结构性复用/跳过原因，不重新运行历史语义。

## Currentness and privacy

观测内部按 accepted prefix + source index + diagnostic epoch 绑定。Restore 无论 accepted 原文是否相同，都递增 epoch、清除记录和 pending tokens。accepted replacement 当下剔除旧 prefix 记录。不同版本 callback 不能覆盖当前行；仍收到的同 epoch stale 终态只显示为“本次会话已过期”，不伪装当前 Turn 的成功。旧 epoch 的 World/Curator/Recommendation terminal 全部丢弃。

叶 UI 不接收 Runtime、world_state、actor ID/ref、hash/prefix/epoch、原始 Provider 文本或任意错误 message。reason/code 经闭集映射，未知错误使用安全通用原因；计数和耗时有界。World/NPC profile/Agency/Evolution/Source/Authorization/key/path canary 不进入 diagnostic projection/UI。

没有读取凭据来构造 Debug 元数据。Provider/Profile/Model 是 packet 的可选字段，本版本未增加这类 settings 读取或 dashboard。

没有新增表/schema/World/Conversation/Save 字段、持久化 Debug 偏好、Provider retry/fallback、parser repair/fence stripping、semantic judge、EventBus/remote telemetry。原严格 5×{label,draft}、click exact draft/never auto-send、free-form 主路径、模型语义权威均保持。

## Validation

顺序：focused deterministic → real-window → affected regressions → 不需要真实 Provider → final import → fresh Windows export。之后补充的最终鼠标/Send 断言再次按 focused → window 顺序通过；production rename/契约注释没有改变已验证的 lane 或 gameplay 行为。

| Gate | Result | Evidence |
| --- | --- | --- |
| Focused real Runtime + controlled async lanes | 146 checks / 0 failures | `evidence/focused.log` |
| Real Godot window, 1280×720 / 960×540 | 52 checks / 0 failures | `evidence/window.log`、五张 ON/OFF/failure PNG |
| Direct regressions | 18 suites passed；1 retained baseline assertion | `evidence/regressions.json` + 逐套日志 |
| Exact formal-base reproduction | 同一 G3-03 断言失败，其他断言通过 | `evidence/baseline-g3_03.log` |
| Real Provider | 未执行，0 次 | 实际 Runtime/producer 异步 seam 已由受控 transport 覆盖，无需额外真实请求 |
| Godot 4.7.2 final import | exit 0；0 script/parse errors | `evidence/final-import.log` |
| Fresh Windows export + ValidateExportOnly | exit 0；0 script/parse/export errors | `evidence/final-export.log`、`evidence/build.json` |

Focused 通过真实 SQLite accepted 事务证明：Narrative 先到、World/Identity 到达后 Curator 三行再到、Recommendations 独立完成；普通 no-change 和三个 curation positive change；World new actor/binding count；shared Curator failure；推荐全部规定的 failure/input/currentness 分支；真实 Save/Restore；相同 accepted 文本 Restore；同 epoch replacement；late callback；64 entry eviction；snapshot 副本隔离；shutdown 清空。安全 trace 样本：`ordinary.json`、`positive.json`、`failures.json`、`restored.json`。

Real-window 包含实际 Viewport 鼠标命中 TopBar toggle；ON/OFF/resize 前后 Provider request counts、World、accepted Conversation、head、Timeline node count 不变。Debug ON 时点击推荐填入 exact draft、零自动发送/调用/持久写；修改为自由输入后经原 Send 路由接受叙事；Shell Save/Restore 和 reopen 默认 OFF 均验证。正常 Host geometry 在 toggle 前后相同；浮层有真实 overflow range，失败行使用现有 LabelDanger，安全原因在窗口中可读。

通过的直接回归：G2-03/G2-04、G5-01 semantic/timeline、MW-017 identity barrier、MW-014 curation、MW-015 R2 initial/UI、MW-015 surface/R1 sparse、MW-018 cards/R1 known-offscreen、MW-019 lifecycle/strict-pairs/Send-d20、G3-04 Save、G3-05 Restore、MW-021 scroll（101 checks，Provider calls=0）。这些 suite 均无 script/parse error 或 exit resource warning。

唯一保留断言：G3-03 `opaque World JSON is not injected as Game Context`。候选与从 **d81f5f215360780cc50038ccd3bce7cb4163b866** 导出的隔离 baseline 都是同一处失败（exit 1 / failures=1）；原 UI resume、Regenerate、new Send、durable round-trip、损坏 DB 保护通过。未将它标为通过，也未扩范围修改 Context。

PowerShell 7 可重跑（从本 task worktree）：

```powershell
pwsh -NoProfile -File tests/mw022/运行调试观测验证.ps1 -Mode Focused
pwsh -NoProfile -File tests/mw022/运行调试观测验证.ps1 -Mode Window
pwsh -NoProfile -File tests/mw022/运行调试观测验证.ps1 -Mode Regressions
```

Regressions runner 如实以非零退出报告保留基线失败。每次使用新 task-owned build fixture；未执行真实 Provider。证据日志仅规范化换行和行尾空白；原运行日志保留在 ignored build 路径。

## Windows candidate artifact

只在 task worktree 下构建。导出前 `build/windows/my-world.pck` 不存在，本次确实重新导出，没有复用旧 PCK。Godot `4.7.2.stable.official.ed1daf0bf`，Windows Desktop debug preset。

- EXE: `build/windows/my-world.exe`，103035904 bytes。
- PCK: `build/windows/my-world.pck`，2477996 bytes。
- SQLite DLL: `build/windows/libgdsqlite.windows.template_debug.x86_64.dll`，3163136 bytes。
- PCK SHA-256: `2677beaa13920f556f2a274e8f33a1102eab1b38dcd0aa6acaa9d6383646ab96`
- Product input hash: `793e1f14cc730b431a315eb6174dce474562ef364c0cafd30adb6bea147d6a86`
- Freshness stamp UTC: `2026-09-08T07:26:15.9681523Z`

EXE/DLL SHA-256 和时间见 `evidence/build.json`。`run-game.ps1 -ValidateExportOnly` 明确跳过游戏启动。未复制到 `D:/AI/Projects/my-world`，不构成 Owner build handoff。

## Architecture check / remaining risks

新增模块只有 L0 closed display contract、L1 bounded recorder、L3 public owner；无空 L2。依赖向下，跨业务模块经公开 L3；Shell 只做 composition/Save result wiring，UI 只消费结构投影。已补充中文契约、currentness/隐私/生命周期注释。没有新增向上或跨模块内部依赖；没有执行已有 layer debt cleanup。

残余风险与审查边界：

1. 真实 Provider 网络/服务表现未在本次验证；本次只证明实际 producer 的受控异步 terminal/currentness 与 UI 映射。
2. Debug ON 的浮层会遮挡右上部分 Host 内容，这是可关闭的局部 drawer；不改变布局尺寸，最终 Owner 可读性判断仍需 UAT。
3. People 无 stable ID 的安全投影只给 total 和 change，不用 display-name 配对编造精确卡片更新数量。
4. 保留上述 G3-03 历史断言失败。

自动审批曾拒绝广泛 import 清理，操作未执行。随后逐项检查证明 13 个 tracked import 的 normalized blob 与 index 完全一致，只刷新相同 blob 的 index stat，没有改写这些文件；11 个 untracked sidecar/UID 以 exact SHA-256 + 初次 import 生成时间保护，仅清理本 task 新生成物。Owner 同名未知文件完全未触碰。

候选只提交到指定 task branch，等待 GPT Independent Review。无 main merge、Owner installation 或 Product PASS 声明。
