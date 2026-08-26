---
title: my world｜G2-02 Provider Adapter v0.1 Task Packet
status: current-task-packet
task_id: G2-02
type: implementation
owner: KimiCode K3
created: 2026-08-26
updated: 2026-08-26
formal_code_base: 019e4538e14a2e9cff91201459a024c6a5724bea
governance_base: de63f585c99ced4821507642c6b4a8555fdc4163
skill_base: a82966b8f07a18b2eb4c633a413dbb39936f2df8
---

# TASK｜G2-02｜Provider Adapter v0.1

Type: `implementation`  
Owner: `KimiCode K3`  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`  
Local project: `D:\AI\Projects\my-world`  
Formal Code Base SHA: `019e4538e14a2e9cff91201459a024c6a5724bea`

## 1. Outcome

建立第一版**正式产品 Provider Adapter**，只产品化一个 concrete Provider：DeepSeek `deepseek-v4-pro`。

完成后，Godot same-process Runtime 中应存在一个小而清晰的 DeepSeek streaming adapter，可从本地 secret/config 启动真实请求，增量输出文本，主动 cancel，并以明确状态结束或失败；该能力可被 G2-03 Narrative Conversation View 直接消费，但本任务**不实现聊天 UI、Turn Domain 或 Context Assembly**。

本任务是支撑性工程任务。若全部 Engineering Acceptance 和真实 Provider evidence 满足，执行 Agent可以报告：`G2-02 ENGINEERING PASS`。不得自行推进或实现 G2-03。

## 2. Why Now

G2-01 已通过 Owner UAT，正式 Game Shell 已成立。G2-03 要把 AI GM Narrative 接入该 Shell，前置需要一个脱离 G1 Spike UI、可被正式产品消费的 Provider seam。

G1-04 已真实证明 Godot `HTTPClient` + non-blocking `poll()` + incremental SSE + cancel 可行，但其实现属于 Foundation Spike 历史，不是当前生产代码。G2-02 应继承**已验证技术经验**，而不是恢复旧测试界面或双 Provider 产品设计。

## 3. Authority / Source Manifest

发生冲突时：

1. 用户当前明确指令。
2. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md` — 产品定义。
3. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md` — 核心产品 / Runtime 原则。
4. `Vibe-Coding/my world/MY_WORLD_G2_CURRENT_STATUS.md` — 当前 G2 Task / PASS / UAT 状态。
5. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` — G2 Task DAG 与阶段 Gate。
6. `Vibe-Coding/my world/MY_WORLD_Foundation架构决策_v1.0_2026-08-26.md` — Godot/GDScript/same-process/Provider/config 技术边界。
7. 本仓库 `AGENTS.md`、当前实现、测试与真实运行证据。
8. `Skill/main/skill/gpt/agent-task-packet/SKILL.md` 与 `skill/gpt/lifecycle-dev-process/SKILL.md`。

Historical implementation evidence allowed when needed:

- `my-world@750d351a1a4397f039e6d95c0ef2e4d7f38e17ee` — first real provider streaming spike;
- `my-world@395fa570ecb20396e06b50cff58e0a28a958ad7c` — final G1-04 DeepSeek/Kimi Code configuration era;
- `my-world@a87d0f36ec0777d5bee8551220841f9dedd5cda0` — G1-04 UAT closeout.

这些 commit 只能提供 proven implementation evidence；不得让旧 Spike UI、Provider selector、G1 labels 或双 Provider 产品边界重新成为 current 设计。

## 4. Read First

依次读取：

1. `AGENTS.md`
2. 本文件
3. `docs/CORE_DESIGN_PRINCIPLES.md`
4. `src/应用壳.gd`
5. `src/main.tscn`
6. `run-local.ps1`
7. `.env.example`
8. 如需参考 proven HTTP/SSE 细节，再读取 G1-04 历史 commit 中相关 provider spike 脚本；只读相关文件，不默认恢复整个旧树。

只有证据不足时才扩大读取范围，并在 Final Report 说明原因。

## 5. Decision Digest / Invariants

### DEC-01｜唯一 product-facing Provider

G2-02 只实现：

```text
Provider = DeepSeek
host = api.deepseek.com
path = /chat/completions
stream = true
default model = deepseek-v4-pro
key env = DEEPSEEK_API_KEY
optional model env = MY_WORLD_DEEPSEEK_MODEL
```

不要同时产品化 Kimi Code，不做 Provider 下拉框，不做 automatic fallback/routing。

`KIMI_CODE_API_KEY` 与旧 `MY_WORLD_G1_04_*` 配置属于 Foundation 历史；当前产品启动路径不应继续要求它们。

### DEC-02｜Adapter seam 必须薄

公开能力只需语义等价于：

```text
start/send streaming request
receive incremental text
cancel active request
observe completion / cancellation / failure
busy state
```

具体 GDScript API 由实现选择，但不要建立：

- Provider registry；
- generic plugin platform；
- routing policy；
- retry orchestration framework；
- account system；
- model marketplace；
- universal request/response schema。

### DEC-03｜消息输入是 provisional adapter contract

G2-02 可以接受当前 DeepSeek/OpenAI-compatible `messages` 形态或一个非常小的 provider-neutral request object，但它**不是 G2-04 Conversation/Turn Domain contract**。

不要在本任务冻结 Player Turn / GM Turn / Conversation Entry / Context Assembly 的正式 DTO。

### DEC-04｜非阻塞网络

继续采用当前已验证的 Godot same-process 非阻塞方式。允许复用 G1-04 的 `HTTPClient + poll() + incremental body reads + SSE data:` 技术经验。

不得使用会阻塞 Godot 主线程直到整段响应完成的同步网络调用。

### INV-PRODUCT-01｜Provider 是支撑能力，不是产品目的

本任务不得为了“Provider 架构完整”扩大范围。最终核心价值仍是高质量、自由的 AI RPG Narrative。

不要在 Provider 层加入 Narrative whitelist、内容审查规则、玩家动作授权 Regex、Confirmation 或 world validator。

### INV-STREAM-01｜增量必须是真增量

真实 Provider 请求必须在响应完成前产生多个可观察 text delta（当 Provider 实际返回多个 chunk 时）。禁止缓存完整回复后再伪装逐字播放。

### INV-CANCEL-01｜Cancel 可恢复

取消 active request 后：

- transport 停止；
- adapter 离开 busy；
- `cancelled` 与 `completed` 不得对同一个 generation 双重终止；
- 后续新请求可以成功启动并完成。

本任务只定义 Provider-request cancellation，不定义最终 Turn / Timeline cancel semantics。

### INV-ERROR-01｜错误明确且可恢复

至少覆盖：

- API key missing：本地配置错误，禁止发网；
- connection / TLS / DNS / transport failure；
- non-2xx HTTP；
- malformed/unexpected stream payload；
- active request 时重复 start。

错误不能导致 permanent busy / silent hang。

UI 如何向玩家展示错误由 G2-03 负责；G2-02 只需提供可消费的错误状态/信息，且必须脱敏。

### INV-SECRET-01｜Secret 硬边界

- `DEEPSEEK_API_KEY` 只从本地环境读取；
- 不提交真实 key；
- 不在 stdout、Godot log、UI、错误详情、截图、Task Report 中打印 key；
- `Authorization` header 不得出现在诊断日志；
- deterministic missing-key / local failure tests 不携带真实 credential。

Model freedom 原则不适用于 Secret / OS / filesystem 权限。

### INV-CONFIG-01｜G2 产品配置收口

更新当前 local-launch config，使正式产品运行只需要：

```text
DEEPSEEK_API_KEY
```

可选：

```text
MY_WORLD_DEEPSEEK_MODEL
```

默认 model = `deepseek-v4-pro`。

应从 `.env.example` 与 `run-local.ps1` 的 current product path 中移除对 `KIMI_CODE_API_KEY`、`MY_WORLD_G1_04_DEEPSEEK_MODEL`、`MY_WORLD_G1_04_KIMI_MODEL` 的强制依赖。不要保留 silent compatibility fallback。

如果本地 `.env.local` 仍含旧 Foundation 变量，迁移/兼容处理必须避免要求 Owner 手工开发；优先由 Agent 安全处理本地开发环境，且绝不读取后把 secret 值写入 Git/报告。

### INV-UI-01｜不要把测试 Harness 重新放进正式主界面

G2-02 不应改变 G2-01 Shell 的主产品视觉结构，也不做 UI 美化。

允许：

- `tests/` 下 focused provider harness；
- CLI/headless test scene/script；
- 必要的内部 diagnostic stdout（不得包含 secret/full prompt）。

禁止在 `main.tscn` 加入：Provider selector、heartbeat、HTTP 状态面板、连接失败测试按钮等 G1 Spike UI。

### INV-SAFETY-01｜GUI / Process Automation 安全

G2-01 验证曾发生窗口标题模糊匹配误杀 Chrome 的事故。自本任务起：

- GUI/process automation 必须先验证 executable path / exact process identity / PID ownership；
- 禁止仅凭窗口标题模糊匹配选择进程；
- 禁止对未确认属于 Godot 或 `my-world.exe` 的进程发送 Kill/Stop-Process/TerminateProcess；
- 若无法安全确认目标进程，停止该自动化步骤并使用更安全的验证方式；
- 不得关闭或杀死浏览器、IDE、终端或其它用户进程作为测试清理手段。

## 6. Scope

### Allowed

- 新增最小 Provider Adapter GDScript；
- 新增直接相关 focused tests/harness；
- 修改 `.env.example`；
- 修改 `run-local.ps1` / `run-local.cmd`（仅当前 product config/launch 需要时）；
- 为 adapter integration 做极小 Bootstrap wiring，但不得把开发测试 UI 暴露给正式 Shell；
- 必要的 README 技术配置同步；
- 移除 current product path 中已 supersede 的 G1-only provider config assumptions。

### Prohibited

- G2-03 Narrative Conversation View；
- 玩家输入 / GM transcript 正式 UI；
- G2-04 Turn / Conversation Domain；
- G2-05 Context Assembly；
- persistence / Save / Timeline；
- World / NPC / Faction；
- Kimi Code product integration；
- generic provider platform / auto fallback；
- UI visual polish；
- C#/.NET、IPC、第二进程、第三方网络依赖；
- 恢复 G1-04 Spike UI；
- destructive/force Git 操作。

## 7. Suggested Minimal Shape（非强制目录模板）

一个合理的小实现可以类似：

```text
src/
  provider/
    deepseek_provider_adapter.gd

tests/
  g2_02_provider_adapter_smoke.gd
```

目录/文件名可调整。只创建立即使用的文件；不要为了 L0/L1/L2/L3 形式完整创建空层。

Adapter 可以使用 signals/callbacks，例如语义等价于：

```text
text_delta(text)
completed()
cancelled()
failed(code, message)
```

以及 `start_stream(...) / cancel() / is_busy()`。

这只是最小语义提示，不是要求逐字照抄接口。

## 8. Deliverables

必须交付：

1. 正式 DeepSeek Provider Adapter v0.1；
2. current local config/launcher 收口为 G2 单 DeepSeek product path；
3. focused automated/offline validation；
4. 真实 DeepSeek streaming evidence；
5. real cancel + post-cancel successful request evidence；
6. explicit failure recovery evidence；
7. clean Git commit/push；
8. Final Report。

## 9. Engineering Acceptance

### AC-01｜Godot parse/load

Godot 4.7.2 Standard 下相关脚本/工程无 parse/missing resource error。

### AC-02｜Missing key

在不提供 `DEEPSEEK_API_KEY` 的测试上下文中：

- 请求不发网；
- 明确失败；
- adapter 不进入永久 busy；
- 日志无 secret。

### AC-03｜Real HTTP + stream

使用本机现有受保护 `DEEPSEEK_API_KEY` 发起真实 DeepSeek 请求：

- HTTP success / valid stream；
- 收到真实增量 delta；
- 最终正常 completed；
- 输出内容非空。

不要在报告复制完整 prompt 或长模型正文；只报告必要 evidence，例如 delta count、字符数、HTTP/result 状态与时间。

### AC-04｜Cancel

对一个真实 active generation 执行 cancel：

- promptly 离开 active/busy；
- 不发生 completed+cancelled 双终止；
- 不冻结 Godot；
- 随后至少一个新真实请求成功完成。

### AC-05｜Failure recovery

至少一个 credential-free deterministic failure path 或安全可控 transport failure：

- 显式 failed；
- 不 silent hang；
- failure 后可再次正常请求；
- 失败测试不得携带 Authorization。

若 production endpoint 不允许安全注入测试 host，可使用专用 test-only harness/constructor/config seam；不得因此建设通用 endpoint platform。

### AC-06｜Concurrent request guard

active request 时第二次 start 必须被明确拒绝或以定义清晰的最小行为处理；不能共享/覆盖 active transport 导致状态混乱。

### AC-07｜Config cleanup

正式 local launch 不再要求 Kimi Code key 或 `G1_04` model env。默认 DeepSeek model 正确，optional override 使用 `MY_WORLD_DEEPSEEK_MODEL`。

### AC-08｜No product UI regression

`src/main.tscn` 仍是已通过 G2-01 的正式 Shell；没有重新出现 G1 Provider/diagnostic UI，也没有无关视觉重做。

### AC-09｜Secret audit

Git diff / tracked files / logs / screenshots / Final Report 无真实 credential 或 Authorization value。

### AC-10｜Repository hygiene

- `git diff --check` PASS；
- exact staging；
- `git status --short` clean after commit；
- `build/`, `.godot/`, `.env.local` 等仍 ignored；
- no force push。

## 10. Validation Order

按成本从低到高：

```text
freshness/status
→ static/diff/secret audit
→ Godot parse
→ offline missing-key + parser/state tests
→ deterministic credential-free failure
→ real short DeepSeek stream
→ real active cancel
→ real post-cancel short request
→ optional GUI/export regression only if implementation touched relevant path
→ git diff --check / status
```

不要在基础 parse/offline failure 未通过时反复消耗真实 Provider 调用。

## 11. Performance Evidence

G1-04 观察到完整长输出约 30 秒，但这不是 G2-02 优化目标。

本任务只需记录最小 evidence：

- request start → first text delta（TTFT，粗粒度即可）；
- generation completion time；
- delta count / output length。

不要为了本任务建设 telemetry platform，也不要根据一次测量优化网络栈。

## 12. Git / Freshness

开始时记录：

```text
git branch --show-current
git status --short
git rev-parse HEAD
git fetch origin
git rev-parse origin/main
```

Task Packet Formal Code Base = `019e4538e14a2e9cff91201459a024c6a5724bea`。

如果开始时 HEAD 已晚于该 SHA：审计增量。若只包含本 Task Packet 等无冲突 docs，继续；若有实现/架构并发变化，先重新计算范围。

authoritative write/push 前再次 fetch/compare。不得覆盖未知 dirty worktree。

使用 exact staging，不使用 `git add .` / `git add -A`。

实现 commit 与纯 Task Packet commit 分开。

## 13. Stop Conditions

停止并报告 BLOCKED，而不是猜测，如果：

- 当前 main 出现改变 G2-02 Provider boundary 的新 decision；
- DeepSeek API/模型真实行为与 current config 明显不兼容，且不是小型 adapter 修复；
- 本机没有可用 DeepSeek key，且无法从现有受保护本地配置获得；
- 需要引入第三方依赖、C#/.NET、IPC 或大架构才能继续；
- 安全验证需要操作无法精确识别的用户进程；
- 发现真实 secret 已进入 tracked history/current diff。

不要因为 UI 不够美观而停止；该项已由 Owner 明确 deferred。

## 14. Final Report

返回：

```markdown
## Result
G2-02 ENGINEERING PASS | BLOCKED

## Changed
- 文件与职责

## Adapter Contract
- start/send
- delta
- completion
- cancel
- failure/busy

## Evidence
- parse/offline
- missing-key
- deterministic failure
- real DeepSeek stream
- cancel
- post-cancel request
- TTFT / completion（粗粒度）

## Config
- current env names
- no secret values

## Scope Check
- 明确未实现 G2-03+

## Git
- start HEAD
- final commit
- push
- final status

## Remaining
- 真实 blocker / 下一步需要的事实
```

不要要求 Owner 执行 routine engineering validation。G2-02 如果按本 Packet 全部通过，不需要 Owner 额外做一次“开发测试”；下一次真正有意义的 Owner 产品体验应在 G2-03/G2-06 的用户路径形成后进行。
