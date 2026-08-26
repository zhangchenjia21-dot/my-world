---
title: my world｜G2-03 Narrative Conversation View Task Packet
status: current-task-packet
task_id: G2-03
type: implementation / UAT-support
owner: KimiCode K3
created: 2026-08-26
updated: 2026-08-26
formal_code_base: f05aef0639e886480cd1cf69d902325f873f7347
governance_base: 9661b0e6dea9ae19ccb05aefb4fcad2821271907
skill_base: a82966b8f07a18b2eb4c633a413dbb39936f2df8
---

# TASK｜G2-03｜Narrative Conversation View

Type: `implementation / UAT-support`  
Owner: `KimiCode K3`  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`  
Local project: `D:\AI\Projects\my-world`  
Formal Code Base SHA: `f05aef0639e886480cd1cf69d902325f873f7347`

## 1. Outcome

把当前正式 Game Shell 升级为第一版**真正可玩的 AI Narrative 主界面**。

完成后，Owner 应能从一个可直接双击的 Windows 产品入口启动游戏，在以 Narrative 为中心的三 Host Slot 界面中输入自然语言行动，看到 DeepSeek 真实增量流式生成 GM Narrative，主动 Cancel，针对最近一次 GM generation 执行 `重新生成 / Retry`，在失败后继续使用，并正常退出。

同时建立长期稳定的产品 UI 骨架：

```text
Left   = PlayerPanelHost
Center = NarrativeHost
Right  = WorldSurfaceHost
```

本任务是产品面任务。Engineering Acceptance 全部满足后，执行 Agent最高只能报告：

> **READY FOR OWNER UAT**

不得自行宣布 G2-03 Product PASS，也不得推进 G2-04。

## 2. Primary Purpose / Product Value

`my world` 的核心不是一个 Provider demo，也不是普通 AI 聊天客户端，而是一个自然语言驱动、由 AI GM 主持的长期 RPG。

本增量必须让用户第一次真实感受到：

```text
我在一个游戏里输入行动
→ 世界/GM 用流动的叙事回应我
→ 我可以随时停止不满意的生成
→ 我可以低成本再来一次
```

产品优先级：

```text
Narrative 阅读与玩家行动
>
三栏信息架构
>
工程诊断可见性
>
视觉装饰
```

不要为了测试指标、状态机完整或未来扩展性，把主界面重新做成工程工具。

## 3. Why Now

已完成：

- G2-01 Application / Game Shell：Owner UAT PASS；
- G2-02 Provider Adapter v0.1：ENGINEERING PASS；
- 当前正式 Adapter 已提供真实 DeepSeek `stream / cancel / failure / recovery` seam；
- canonical UI Host 架构已冻结为 `Player Host / Narrative Host / World Surface Host`。

因此 G2-03 的唯一正确下一步是把 Provider 能力接进真正玩家界面，并建立后续 G3–G8 不需要推翻的 Host placement。

## 4. Authority / Source Manifest

冲突时按以下顺序：

1. 用户当前明确指令。
2. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md` — 产品定义。
3. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md` — Model freedom / Reversibility / Timeline 主权等长期原则。
4. `Vibe-Coding/my world/MY_WORLD_声明式UIHost架构_CURRENT.md` — 本任务 UI Host / placement / responsive / reversibility UX 的 canonical supporting architecture。
5. `Vibe-Coding/my world/MY_WORLD_G2_CURRENT_STATUS.md` — 当前 G2-03 execution status。
6. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` — G2 task DAG / G2-03、G2-04、G2-05 边界。
7. 本仓库 `AGENTS.md`、当前实现、测试、HEAD。
8. `Skill/main/skill/gpt/agent-task-packet/SKILL.md` 与 `skill/gpt/lifecycle-dev-process/SKILL.md`。

Historical evidence only：

- SillyTavern / DSH 的中央 Narrative + 侧栏产品经验；
- SillyTavern G8 Runtime-extensible UI Host 的 Host capability / placement 经验；
- G1 Provider Spike 历史。

历史 TypeScript / React / Browser / HTTP / Workspace UI 不构成实现授权，不直接迁移。

## 5. Read First

依次读取：

1. `AGENTS.md`
2. 本文件
3. `docs/CORE_DESIGN_PRINCIPLES.md`
4. `src/main.tscn`
5. `src/应用壳.gd`
6. `src/provider/deepseek流式适配器.gd`
7. `tests/g2_02_适配器冒烟测试.gd`
8. `run-local.ps1` / `run-local.cmd`
9. `export_presets.cfg`

并读取 canonical：

- `Vibe-Coding/my world/MY_WORLD_声明式UIHost架构_CURRENT.md`
- `Vibe-Coding/my world/MY_WORLD_G2_CURRENT_STATUS.md`

只有证据不足时才扩大读取范围；扩大后在 Final Report 说明原因。

## 6. Decision Digest / Invariants

### DEC-01｜三 Host Slot 是本任务正式骨架

必须建立语义明确的：

```text
GameShell
├─ PlayerPanelHost
├─ NarrativeHost
└─ WorldSurfaceHost
```

节点名/文件组织可调整，但 placement 和职责必须清楚。

当前可继续手写 Godot Control / Container。不要为了形式完整创建通用 Host framework。

### DEC-02｜Narrative 是视觉中心

宽窗口：三 Host 可同时出现，但 Center 占主要可用宽度与注意力。

窄窗口：

```text
Narrative remains primary
→ side hosts collapse / hide / drawer / overlay
```

实现不要求动画，也不冻结跨项目 breakpoint 数值；必须用真实 `960x540` 与至少一个宽桌面尺寸（建议 `1440x900`）证明可用。

### DEC-03｜左右 Host 只允许诚实空状态

当前没有正式 Character / World / Timeline Domain 数据。

因此：

PlayerPanelHost 可以表达：

> `主角信息将在新游戏 / 角色状态成立后显示。`

WorldSurfaceHost 可以表达：

> `世界信息将在游戏状态成立后显示。`

允许有区域标题、轻量图标/说明和未来 placement 的视觉空间。

禁止：

- 假生命值、假金币、假人物；
- 假任务、假地图、假关系；
- 无行为的未来 Tab；
- 假 Save / Timeline；
- 为了“看起来完整”制造第二事实源。

### DEC-04｜中央不是普通聊天气泡流

推荐阅读结构：

```text
你的行动
<玩家输入>

GM
<长篇 Narrative>

                 ↻ 重新生成
```

玩家内容应清楚但克制；GM Narrative 应拥有连续、宽松、适合长篇阅读的文本区域。

不要默认复制 ChatGPT/IM 的左右气泡布局。

### DEC-05｜真实 Provider 集成

直接消费当前正式：

`src/provider/deepseek流式适配器.gd`

当前 seam：

```text
start_stream(messages)
text_delta(text)
completed()
cancel() / cancelled()
failed(code, message)
is_busy()
```

G2-03 不应重写 HTTP/SSE transport。

若集成暴露 Adapter 小缺陷，可以做**最小修复**，但必须：

- 保持 G2-02 seam 小而明确；
- 回归 G2-02 focused tests；
- Final Report 明确说明为何改 Adapter。

### DEC-06｜G2-03 临时 Session 是 provisional，不是 Domain Freeze

G2-04 才正式定义 Turn / Conversation Domain；G2-05 才正式定义 Context Assembly。

为了现在真实可玩，G2-03 允许存在一个**明确标注为 provisional / in-memory only** 的 UI session，例如：

```text
provisional system message
+ completed player/GM pairs
+ current player input
```

可使用最小 `Array[Dictionary]` / equivalent 维护当前进程内的 Provider messages。

必须满足：

- 只存在内存；
- 不落盘；
- 不叫 authoritative Conversation / Timeline / Save；
- cancelled / failed 的不完整 GM 输出不加入后续 provider history；
- regenerate 时替换最近 GM generation，而不是制造第二个 player turn；
- G2-04 / G2-05 可自然接管，不需兼容为公开 contract。

### DEC-07｜Provisional GM system message 极小且不限制 Narrative

允许一个明确注释为 `G2-03 provisional` 的最小 system message，只用于让当前 Vertical Proof 像 AI RPG，而不是普通问答助手。

语义目标近似：

> 你是 `my world` 的 AI GM。把玩家输入视为游戏中的自由行动或意图，以自然、沉浸的中文 RPG 叙事回应，并自由推进场景与世界；不要输出工程说明或解释自己是 AI。

实现可微调措辞。

禁止在这里加入：

- Narrative whitelist；
- 玩家动作 Regex；
- Confirmation policy；
- 世界规则大表；
- “只能描述程序已批准事实”的限制；
- 长篇 DSH/旧 FC2 Prompt。

`Model freedom first. Reversibility over prevention.`

### DEC-08｜Send / streaming / completion

最小玩家流程：

1. 输入非空自然语言；
2. 发送；
3. 玩家输入形成一个可读 Player section；
4. 同一 Turn 的 GM section 立即出现；
5. `text_delta` 到达即追加到当前 GM section；
6. completed 后该 GM generation 成为当前 provisional completed history；
7. 输入恢复可继续下一轮。

发送时禁止 accidental double-submit。

active request 时 Provider `ERR_BUSY` 不应转化为 UI 混乱。

### DEC-09｜Cancel 保留可理解状态

active generation 时提供清楚的 `取消`。

Cancel 后：

- Provider 离开 busy；
- 当前 partial Narrative 可以留在屏幕供玩家看到；
- 必须标记为 `已取消` / equivalent，不把它伪装成 completed Turn；
- partial assistant 内容不进入后续 provisional context；
- 用户可以 `重新生成` 同一个玩家输入；
- UI 可继续发送后续请求。

### DEC-10｜Regenerate / Retry 是当前最小可逆性

最近一次 GM generation（completed / cancelled / failed）应有轻量 `重新生成` 或语义等价操作。

行为：

```text
same latest player input
→ discard/replace current GM generation for active provisional history
→ new real Provider request
→ stream into same logical GM turn surface
```

对于 completed generation：旧 GM 输出可以从当前 active UI turn 中被替换，不要求建立历史 Branch。

对于 cancelled / failed generation：直接重试同一个玩家输入。

本任务不做：

- `回到这里`；
- edit-and-retry；
- branch；
- Timeline navigation；
- 历史版本管理。

这些依赖 G3。

### DEC-11｜错误态必须 player-readable

至少 UI 处理：

- missing key；
- transport failure；
- HTTP/API failure；
- malformed stream；
- unexpected local integration failure。

要求：

- 错误显示在 Narrative 主路径附近；
- 不泄露 key / Authorization；
- 不把工程 stack/内部原始 payload 扔给玩家；
- 错误后输入和 retry 可继续；
- 不永久 busy。

### DEC-12｜Streaming 阅读体验

至少保证：

- 增量文本真正进入当前 GM section；
- 中文换行/自动换行可读；
- 长文本可滚动；
- streaming 时 UI 不冻结；
- 新 delta 不制造明显布局抖动。

默认应在用户仍处于底部附近时跟随最新文本；如果实现能低成本识别用户已主动向上阅读，则不要强行把滚动条持续拉到底部。不要为此建设复杂 scroll framework。

### DEC-13｜Owner 直接产品启动路径

Owner UAT 不得要求：

- 打开 Godot Editor；
- 手动运行 PowerShell 命令；
- 手动设置环境变量；
- Git 操作；
- build/export。

必须提供一个可直接双击的 Windows 入口，例如：

```text
run-game.cmd
```

其职责只需：

```text
读取本机 ignored .env.local
→ 临时注入 DEEPSEEK_API_KEY / optional MY_WORLD_DEEPSEEK_MODEL
→ 启动已导出的 build/windows/my-world.exe
→ 不显示/记录 secret
```

允许配套 `run-game.ps1` 或复用当前 launcher 逻辑，但不要把 `run-local.cmd` 的开发者 Editor 路径破坏掉。

若 EXE 不存在，玩家入口应给出清楚错误，而不是静默失败；正式 handoff 前 Agent 必须已经完成 export，所以 Owner 正常不应遇到该错误。

### DEC-14｜GUI 自动化安全

所有窗口自动化 / 截图 / 关闭测试必须按**精确 executable + PID**识别 Godot 或 `my-world.exe`。

禁止：

- 只按包含 `my world` 的模糊窗口标题选进程；
- 对身份不明确的进程发送关闭；
- 对未确认身份的进程 Kill。

之前误杀 Chrome 的事故不得再次发生。

## 7. Implementation Guidance

建议但不强制的最小文件形态：

```text
src/
  main.tscn
  应用壳.gd
  ui/
    叙事对话视图.gd
    [optional small .tscn if useful]
  provider/
    deepseek流式适配器.gd

run-game.cmd
run-game.ps1   # optional / recommended
```

可以让 `叙事对话视图.gd` 在本任务直接消费 Provider Adapter，并明确注释为 G2-03 provisional integration；不要为了避免未来重构而提前创造 Controller/Service/EventBus/DI framework。

若主 scene 直接组合 Adapter Node + View，也是允许的。

### Node / placement guidance

语义上可形成：

```text
Main
├─ TopBar
├─ HostLayout
│  ├─ PlayerPanelHost
│  ├─ NarrativeHost
│  └─ WorldSurfaceHost
└─ minimal product status / exit affordance
```

NarrativeHost 至少需要：

```text
ScrollContainer
→ narrative entries container
Composer / multiline input
Send
Cancel (active only / enabled only when active)
latest generation action footer
```

不要把 debug counters、TTFT 数字、delta count、Task ID 暴露到正式 UI。

## 8. Scope

### IN

- 三 Host Slot 固定产品骨架；
- responsive wide/narrow behavior；
- 中央 Narrative Conversation View；
- 自然语言输入；
- DeepSeek real stream；
- cancel；
- latest regenerate/retry；
- player-readable error state；
- provisional in-memory current-session messages；
- minimal provisional GM system message；
- Owner-direct exported-game launcher；
- Windows export / real product UAT artifact；
- focused tests / real Provider validation；
- README 中仅与新 Owner product launch 直接相关的必要说明。

### OUT

- G2-04 formal Turn / Conversation Domain；
- G2-05 formal Context Assembly / budget / retrieval；
- Persistence / SQLite；
- Save / Restore；
- Timeline / rewind / branch / 回到这里；
- World Pack；
- NPC / Faction / World State；
- Character stats / inventory / relationship real data；
- Map；
- generalized Declarative UI Renderer；
- external World Pack / Mod UI schema；
- arbitrary GDScript extension；
- Provider registry/routing/fallback；
- Kimi Code product integration；
- large visual polish / art direction redesign；
- TTFT optimization platform。

## 9. Deliverables

必须交付：

1. 重构后的正式 `main.tscn` / Game Shell，具备三 Host Slot；
2. 可真实使用的 Narrative Conversation View；
3. G2-02 DeepSeek Adapter 正式 UI 集成；
4. Send / stream / completion；
5. Cancel；
6. latest Regenerate / Retry；
7. readable failure recovery；
8. responsive wide/narrow proof；
9. Owner 可双击的 exported-game launcher；
10. `build/windows/my-world.exe` 最新可运行导出；
11. focused automated/offline tests；
12. real DeepSeek GUI/runtime evidence；
13. clean Git commit + push；
14. Final Report + Owner UAT steps。

## 10. Engineering Acceptance

### AC-01｜Godot parse / scene load

- `--headless --editor --quit` 或等价 parse/load PASS；
- 无 parse error、missing resource、invalid NodePath。

### AC-02｜Stable Host Slots

宽窗口真实运行中存在清晰三 Host：

```text
PlayerPanelHost | NarrativeHost | WorldSurfaceHost
```

Center materially larger / visually primary。

左右当前只显示诚实空状态，不出现假数据或假功能 Tab。

### AC-03｜Narrow responsive

在 `960x540` 或当前最小真实窗口尺寸：

- Narrative 仍有可用阅读宽度；
- composer / send / cancel 不被截断；
- side hosts 不挤压中心到不可用；
- 至少能通过简单 collapse/hide/toggle/drawer/overlay 访问/识别侧 Host；
- 无控件重叠和明显裁切。

### AC-04｜Player input

- multiline 中文输入可用；
- 空输入不会发送；
- 发送操作明确；
- active request 不发生 accidental double submit；
- 当前输入和 Narrative 不因 window resize 丢失。

键盘快捷键可选；若实现，必须不妨碍正常中文输入法。

### AC-05｜Real DeepSeek stream in formal UI

使用当前本机受保护 key：

- 从正式 UI 发起真实请求；
- GM Narrative section 在 completed 前收到并显示多个真实 delta（Provider 实际产生多个时）；
- Narrative 非空；
- UI 主循环保持响应；
- 不显示 debug/Task/secret 信息。

### AC-06｜Cancel in formal UI

对真实 active generation：

- Cancel 控件可发现；
- 点击后 generation promptly 停止；
- 当前 partial Narrative 明确显示为 cancelled / incomplete；
- 不发生 completed + cancelled 双终止；
- adapter/UI 离开 busy；
- 随后可 retry 或新发送成功。

### AC-07｜Regenerate / Retry

至少证明：

- 最近 completed GM generation 可 `重新生成`；
- 重生成复用同一个 player input，不重复制造第二个 player entry；
- 新 generation 替换同一 logical GM block；
- cancelled 或 failed generation 也可以 retry；
- retry 后真实 Provider 成功恢复。

### AC-08｜Provisional history correctness

在同一进程内至少完成两个连续 player/GM 交互或一个 interaction + regenerate，并证明：

- completed GM 才进入 provisional provider history；
- cancelled / failed partial assistant 不进入下一次 context；
- regenerate 不把旧 GM + 新 GM 同时作为 active context；
- 没有任何落盘持久化。

不要把该行为写成 G2-04/G2-05 正式 contract。

### AC-09｜Error UX

至少用安全路径证明一个 player-facing failure：

- 显示可理解错误；
- 不泄露 secret；
- 不永久 busy；
- UI 可 retry / 再发送。

可复用 G2-02 credential-free failure seam 做工程测试，但正式 UI missing-key 也必须有合理显示。

### AC-10｜Long text / scrolling regression

生成或注入足够长的 Narrative，证明：

- 中文自动换行；
- scroll 可用；
- streaming append 不冻结；
- composer 仍可访问；
- resize 后文本区域不崩。

不要求重新跑 G1-03 全套 300 段 benchmark，除非实现暴露回归。

### AC-11｜Owner product launcher

双击 `run-game.cmd` 或最终等价入口：

- 从 `.env.local` 只读取允许的当前 G2 env；
- 启动 `build/windows/my-world.exe`；
- 不打开 Godot Editor；
- 不显示/打印 key；
- 正常退出后 launcher 行为可理解；
- EXE 缺失时明确说明，不静默失败。

### AC-12｜Windows export / direct executable

使用 current `Windows Desktop` preset：

```powershell
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --export-debug 'Windows Desktop' 'D:\AI\Projects\my-world\build\windows\my-world.exe'
```

必须：

- exit 0；
- `build/windows/my-world.exe` 存在；
- 通过 Owner launcher 启动的是这个 exported EXE；
- exported UI 与 engine-run 主路径一致。

### AC-13｜Normal exit

- 界面退出按钮与 Windows X 均能正常关闭；
- active generation 时退出不会让进程长时间挂起；
- 无需 Kill 正常产品进程。

### AC-14｜GUI automation safety

若使用任何自动截图/窗口调整/关闭脚本：

- 记录精确 executable / PID 识别方式；
- 证明未按模糊标题选进程；
- 禁止身份不明 Kill；
- Final Report 明确声明是否使用了自动 GUI 控制。

### AC-15｜Secret / repository hygiene

- tracked files 无真实 key；
- UI / screenshot / Final Report 无 key；
- logs 无 Authorization；
- `git diff --check` PASS；
- exact staging；
- `git status --short` clean after commit；
- `build/`, `.godot/`, `.env.local` remain ignored；
- no force push。

## 11. Product Value Acceptance｜Owner-only

Engineering Acceptance 不能替代这一节。

Owner UAT 重点不是检查 Node 名，而是判断：

### PV-01｜像游戏，而不是 Provider Demo

第一眼是否已经开始像一个 AI RPG 主界面，而不是 G1 测试工具或普通聊天网站。

### PV-02｜Narrative 是主角

AI GM 文本是否拥有足够阅读空间，玩家能自然地连续阅读 streaming Narrative。

### PV-03｜输入 / Cancel / Regenerate 低操作税

玩家是否能自然理解：

```text
我输入行动
我可以停
不满意我可以再来一次
```

而不需要理解 Adapter / request / token / debug 状态。

### PV-04｜三栏方向成立

宽窗口下左主角 / 中 Narrative / 右世界的骨架是否看起来有潜力；窄窗口时是否仍以 Narrative 为主，不显得拥挤。

### PV-05｜Core Value 未因 Guardrail 变差

没有多余 Confirmation、行为白名单、审查提示、机械化建议阻塞自然语言 RPG 体验。

只有 Owner 明确 PASS 才能将 G2-03 记为 Product PASS 并推进 G2-04。

## 12. Validation Order

按成本从低到高：

```text
freshness / status
→ static architecture / secret audit
→ Godot parse
→ offline UI/session state tests
→ scene launch / resize without Provider
→ safe failure UI
→ real short DeepSeek UI stream
→ real active cancel
→ real retry / regenerate
→ long-text / scrolling smoke
→ Windows export
→ run-game.cmd exported-product path
→ exact process/PID GUI evidence if automation used
→ git diff --check / status
```

真实 Provider 调用前先通过离线与 scene 基础测试。

## 13. Suggested Focused Tests

只建立当前真实需要的 focused coverage，例如：

- provisional session：completed / cancelled / failed 是否正确进入/不进入 history；
- regenerate 是否替换 assistant 而不是复制 player turn；
- UI generation state：idle / streaming / cancelled / failed / completed；
- empty input / busy guard；
- side-host responsive state；
- launcher env parsing 如有可测 seam。

不要为了 UI 测试建设通用 mock framework。

## 14. Performance Evidence

G2-02 / G1-04 已观察到 TTFT 波动。

本任务只记录：

- UI send → first visible Narrative delta；
- completed 总耗时；
- cancel click → UI idle 的粗粒度延迟；
- UI 主线程是否可持续交互。

不要为此建立 telemetry platform，也不要因为单次长 TTFT 阻塞 G2-03，只要行为真实、明确且可取消。

## 15. Git / Freshness

开始时记录：

```text
git branch --show-current
git status --short
git rev-parse HEAD
git fetch origin
git rev-parse origin/main
```

Task Packet Formal Code Base = `f05aef0639e886480cd1cf69d902325f873f7347`。

注意：你的上一任务 final implementation commit 是 `ec0617195cbd71ba49e9c3e4ff834aee83e82fd3`，但当前 origin/main 之后新增了**治理/AGENTS 文档传播**。开始 G2-03 前必须 fast-forward / rebase 到最新 main，不得从旧 `ec061719...` 直接覆盖新 `AGENTS.md`。

如果开始时 HEAD 晚于 Formal Code Base：先审计增量；有真实并发实现时重新计算范围。

正式 push 前再次 fetch/compare。不得覆盖未知 dirty worktree。

使用 exact staging，不使用 `git add .` / `git add -A`。

Task Packet 的纯文档 commit 不算实现证据；实现另做 commit。

## 16. Stop Conditions

停止并报告 BLOCKED，而不是猜测，如果：

- current main 出现 superseding G2-03 / UI Host / Narrative decision；
- Provider Adapter seam 已被并发修改且不兼容；
- 需要先冻结 G2-04 Turn Domain 才能完成基本 UI（先报告证据，不自行提前做 G2-04）；
- 需要第三方 UI framework、C#/.NET、IPC 或大架构才能继续；
- Owner product launcher 无法在不泄露 secret 的前提下启动 exported EXE；
- GUI 验证只能通过模糊识别/误杀其他用户进程完成；
- 发现真实 secret 已进入 tracked history/current diff。

以下不是 blocker：

- UI 还不够精美；
- 左右侧当前没有真实 RPG 数据；
- TTFT 偶尔较长；
- G3 Timeline 尚未实现。

## 17. Owner UAT｜最多 5 步

Engineering PASS 后交给 Owner：

1. 双击 Agent 指定的玩家入口（预期 `D:\AI\Projects\my-world\run-game.cmd`），确认打开的是正式 `my world` 游戏而不是 Godot Editor。
2. 在中央输入一条自然语言行动并发送，确认 GM Narrative 会真实逐步流式出现，阅读区域自然。
3. 再发起一次较长生成，在生成过程中点击 `取消`；确认立即停止，然后点击 `重新生成`，确认同一行动重新产生 Narrative。
4. 将窗口从宽屏缩到较小尺寸再放大，确认中央 Narrative 始终可用，左右区域不会把中心挤坏。
5. 正常退出。

Owner 只需要报告产品感受 / PASS / FAIL，不需要运行命令、Git、测试或截图脚本。

## 18. Final Report

返回：

```markdown
## Result
READY FOR OWNER UAT | BLOCKED

## Changed
- 文件与职责

## Product Flow
- player input
- streaming narrative
- cancel
- regenerate/retry
- errors

## Host Layout
- wide behavior
- narrow behavior
- PlayerPanelHost / NarrativeHost / WorldSurfaceHost

## Provisional Session Boundary
- current in-memory behavior
- what is explicitly NOT G2-04/G2-05 contract

## Evidence
- parse
- offline/focused tests
- real DeepSeek GUI stream
- cancel
- regenerate/retry
- resize / long text
- export
- run-game exported-product path
- GUI automation exact process/PID method if used

## Performance Observation
- UI TTFT / completion / cancel latency rough evidence

## Secret / Scope Check
- no secret leakage
- explicit G2-04+ non-implementation

## Git
- start HEAD
- final commit
- push
- final status

## Owner UAT
- exact double-click path
- no more than 5 steps

## Remaining
- real blocker / deferred visual polish / next-stage facts
```

不要把 Engineering PASS 写成 Product PASS。Owner 明确验收前，G2-03 最高状态始终是 `READY FOR OWNER UAT`。
