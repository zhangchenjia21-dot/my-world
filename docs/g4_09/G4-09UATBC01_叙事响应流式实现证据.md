# G4-09UATBC01 叙事响应流式实现证据

Status: implementation complete；等待 GPT Independent Review  
START_HEAD: `d944f3bbac45cfaa1a02bf61baaa8ecd0421064c`  
IMPLEMENTATION_HEAD: `c03bcab9392ec70066f0a900a8718ab6befc0c33`  
Governance HEAD: `79e6c5c257b44afe578745328b4021c4d7551563`

## 1. 实现边界

本轮只修改 Public d20 action adjudication：

- NO_CHECK framing 固定为首个物理行 `{"decision":"NO_CHECK","reason":"..."}`，随后一个 LF，再随后为 raw narrative body；
- CHECK_REQUIRED 仍为单行 compact JSON control，禁止附加非空 body；
- stateful parser 可跨任意 Provider chunk 边界验证 control header；只有完整、合法的 NO_CHECK header 之后才投影正文；
- NO_CHECK 正文写入现有 provisional Conversation draft，并在 Provider completion 后一次 durable finalize；
- CHECK_REQUIRED 先 durable commit Program check，再开始第二次 Provider resolution narrative，并把正文流入同一 provisional Turn；
- failure/cancel 不接受 partial draft；retry 复用相同未接受 Turn、stable action 与既有 durable check；
- timing 只记录 action start 后的 monotonic 微秒点，不记录 prompt、正文、凭据或 Authorization。

没有修改 `src/domain/**`、`src/ui/**`、`src/persistence/**`、`src/runtime/**`、`src/provider/**`、Runtime Settings、Source 或 Final Create。SQLite schema 仍为 v4。

## 2. Framing 与 fail-loud 证据

`tests/g4_09uatbc01/叙事响应流式关键路径测试.gd` 覆盖：

- header 在任意字符位置切块时，在完整 LF 前不暴露正文；
- header 与首段 body 同 chunk 时，只暴露验证后的 body；
- fenced、preamble、非法 JSON、NO_CHECK 缺 LF、空 body 均失败；
- CHECK_REQUIRED 允许 terminal 时无尾 LF 的单行 control，但拒绝任何非空 body；
- 不存在旧 `narrative` JSON 字段 fallback 或整包 JSON 猜测。

## 3. 分支、失败窗口与调用次数

### NO_CHECK

- 成功路径：1 次 selected-provider call；首个正文 delta 在 Provider completion 前进入 provisional draft；completion 后恰好一次 durable accept/marker finalize。
- failure/cancel：每个失败 attempt 各 1 次 call，accepted Conversation 与 durable NO_CHECK marker 均不增加，partial draft 不进入后续 Context。
- same-process retry：复用相同 Turn/action；失败 attempt + retry 合计 2 次 call，不创建重复 Player Turn。
- 已完成 resolution 的 replay/reopen：复用 durable narrative/marker，新增 Provider call 为 0。

### CHECK_REQUIRED

- 首次成功：adjudication 1 次 + result narrative 1 次，共 2 次 selected-provider call。
- Program RNG/roll/outcome 先 durable commit，之后才启动 result narrative；首个可见 result delta 严格晚于 durable check。
- result narrative failure/cancel 后 retry：只追加 1 次 narrative call；累计 3 次 call，RNG invocation 保持 1，raw roll/outcome 不变，Turn 不重复。
- 已 durable check 的 reopen/replay 不 reroll；真实 OS process 回放保持 exact check 与 accepted narrative identity。

Turn Finalize Barrier 在两分支均保持：`turn_ready` 只在 durable finalize 成功后出现，下一行动此前仍被阻止。

## 4. 真实 DeepSeek V4 Pro 证据

Owner 已授权把 task-owned “汉末三国 / 208 赤壁前夕 / 刘备（含孙权 canonical cast）”上下文及两条测试行动发送至 DeepSeek V4 Pro。验证使用 task-owned Source、Game、Game Library 与 Runtime Settings roots；未读取或覆盖 Owner 默认模型设置，未记录 prompt、叙事正文或 key。

命令：

```powershell
& 'tests/g4_08b/运行真实DeepSeek公开D20验证.ps1' -Root 'D:\AI\Projects\my-world\build\g4_08b\g4_09uatbc01-real'
```

最终结果：`failures=0`。

- Opening：真实 DeepSeek Opening accepted。
- “我独自潜入曹军水寨，试图盗取军令。”：模型选择 CHECK_REQUIRED；Program `d20 + modifier` 总值 8、DC 20、outcome failure；durable mechanic card 在 result narrative 完成前可见，GM continuation accepted。
- “我向身边侍从询问今日日期。”：模型选择 NO_CHECK；无骰卡，1 次 Provider call，正文在 completion 前可见并最终 accepted。

非敏感 monotonic timing（微秒，相对各 action start）：

| 分支 | first provider delta | durable check / resolution delta | first visible narrative | provider completed | finalize completed |
|---|---:|---:|---:|---:|---:|
| CHECK_REQUIRED | 18,567,151 | durable check 22,622,259；resolution delta 63,015,987 | 63,016,021 | 95,058,559 | 95,072,314 |
| NO_CHECK | 25,656,860 | 不适用 | 26,261,800 | 33,228,139 | 33,245,509 |

两分支均满足 `first_provider_delta -> first_visible_narrative -> provider_completed -> finalize`；CHECK_REQUIRED 还满足 `durable_check_completed -> first_visible_narrative`。

证据文件位于 gitignored task root：`build/g4_08b/g4_09uatbc01-real/real-vertical-evidence.json`。该 JSON 只含 profile id、结果数值、调用结果和 timing，不含内容或秘密。

真实运行中 Godot HTTPClient 在 CHECK_REQUIRED 的流转阶段输出过一次 `status != STATUS_BODY` engine warning；请求仍到达唯一成功终态，durable check、accepted continuation、timing 与最终 `failures=0` 均成立。此 warning 留给 Independent Review 判断，不作为静默忽略的产品结论。

## 5. 测试与命令

以下成功命令均退出 0：

```powershell
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_09uatbc01/叙事响应流式关键路径测试.gd' -- '--root=D:/AI/Projects/my-world/build/g4_09uatbc01/final-focused'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_08m1/公开D20机制测试.gd' -- '--root=D:/AI/Projects/my-world/build/g4_08m1/g4_09uatbc01-mechanism'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_08m1/NO_CHECK行动幂等修复测试.gd' -- '--root=D:/AI/Projects/my-world/build/g4_08m1/g4_09uatbc01-no-check'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_08b/公开D20界面整合测试.gd' -- '--root=D:/AI/Projects/my-world/build/g4_08b/g4_09uatbc01-ui'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_07a/首次开场运行时聚焦测试.gd' -- '--root=D:/AI/Projects/my-world/build/g4_07a/g4_09uatbc01-opening'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_07b/可玩界面整合测试.gd' -- '--root=D:/AI/Projects/my-world/build/g4_07b/g4_09uatbc01-playable'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_09r1/运行时模型设置机制测试.gd'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g3_02/世界持久化流程测试.gd' -- '--root=D:/AI/Projects/my-world/build/g3_02/g4_09uatbc01-persistence'
& 'tests/g4_08m1/运行真实进程重启验证.ps1' -Root 'D:\AI\Projects\my-world\build\g4_08m1\g4_09uatbc01-check-process'
& 'tests/g4_08m1/运行NO_CHECK真实进程重启验证.ps1' -Root 'D:\AI\Projects\my-world\build\g4_08m1\g4_09uatbc01-no-check-process'
& 'tests/g4_08b/运行真实DeepSeek公开D20验证.ps1' -Root 'D:\AI\Projects\my-world\build\g4_08b\g4_09uatbc01-real'
.\run-game.ps1 -ValidateExportOnly
git diff --check
```

G4-08B UI regression 额外断言：NO_CHECK 与 CHECK_REQUIRED result narrative 均在 stub completion 前逐步出现在既有 narrative view；Player → mechanic card → GM narrative 顺序保持。

## 6. Windows / 架构 / 保护面

- `run-game.ps1 -ValidateExportOnly` 判定 export stale，使用 tracked `Windows Desktop` preset 重建当前 checkout，并输出 `Windows export rebuilt and verified against the current checkout`；显式 validation mode 未启动游戏。
- Godot 导出扫描了已有 gitignored test roots 并报告重复 fixture UID warning；export/verification 成功，未把 `build/` 或 binary 纳入 Git。
- 依赖方向保持 `L3 -> L2 -> L1 -> L0`；L2 对 Conversation/Persistence/Context 仍只经现有 L3 seam。
- `src/domain/**`、`src/ui/**`、`src/persistence/**`、`src/runtime/**`、`src/provider/**` 无 diff。
- SQLite `SCHEMA_VERSION := 4` 未变；无 migration、Source/Game contract、Runtime Settings 或 Provider routing 变更。
- `.env.local`、API key、Owner AppData、真实 prompt/response 与 gitignored evidence 未提交。

## 7. Known limitations

- timing 是 engineering monotonic evidence，不是 Provider benchmark，也不承诺网络延迟上限。
- Product responsiveness 仍需 GPT Independent Review 后由 Owner 做 focused UAT retest；本文不宣布 G4-09UATB、G4-09、G4-08 或 G4-GATE PASS。

READY FOR INDEPENDENT REVIEW
