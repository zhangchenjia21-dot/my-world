# TASK｜G1-05｜本地 IO / 动态图片 / Windows Export Foundation Spike

Type: exploration / implementation / UAT-support  
Owner: KimiCode K3  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`  
Formal Code Base SHA: `ee60f7cebf8d059e125278d8dabed578fd09dcbf`  
Governance Base SHA: `zhangchenjia21-dot/Vibe-Coding@0ba35cf2ead5e3644c2a9ea8bbe96075da53ab94`

## Outcome

在现有 Godot Foundation surface 上完成一个最小、真实、可导出的 G1-05 探针，证明：

```text
local file write/read
+ cross-launch tiny probe
+ portrait / scene / map filesystem image load
+ Windows export
+ exported executable runtime
```

本任务不实现正式游戏 persistence、Save / Restore、World Pack 或最终 asset pipeline。完成实现与自动验证后，Agent 最高返回 `READY FOR OWNER UAT`，不得自行宣布 G1-05 PASS。

## Why Now

G1-01、G1-02、G1-03、G1-04 已 PASS。G1-05 已解除阻塞，是进入 G1-06 Foundation Architecture Decision 前最后一个 Host capability Spike。当前只需证明 Godot 的普通本地文件、动态图片和 Windows 导出 seam 确实可用，不提前冻结后续架构。

## Authority / Source Manifest

按以下顺序使用 current source：

1. 用户在执行聊天中的当前明确指令；
2. 本仓库 `AGENTS.md`；
3. 本 Task Packet；
4. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md` @ `0ba35cf2ead5e3644c2a9ea8bbe96075da53ab94`；
5. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` @ 同一治理 SHA；
6. 本仓库当前代码、配置与测试 @ Formal Code Base；
7. `docs/DSH_TEST_CARRY_FORWARD_REQUIREMENTS.md`，仅作为跨阶段边界参考，不授权提前实现 G2–G9。

归档文档、旧聊天、旧 Task Packet、The World / DSH workaround 和模型记忆不构成当前实现权威。

## Read First

按顺序读取初始工作集：

1. `AGENTS.md`；
2. 本文件；
3. `project.godot` 与 `.gitignore`；
4. `src/main.tscn`；
5. `src/g1_04_provider_stream_spike.gd`，只了解当前 runnable surface，不重构 Provider seam；
6. 上述 Vibe-Coding Product Spec 与 Roadmap 中直接涉及 G1 / G1-05 的部分。

只有现有证据不足时才扩大读取范围；扩大后在最终报告说明原因。

## Decision Digest / Invariants

`DEC-01` G1-05 是 Foundation exploration，不是 canonical persistence architecture 或 production commitment。

`DEC-02` 使用 Godot 原生 `FileAccess` / `DirAccess` 与 `Image` / `ImageTexture`；不引入第三方图片库或持久化依赖。

`DEC-03` 探针目录固定为 `user://g1_05_probe/`。可使用极小 JSON，至少记录 `schema = g1_05_probe_v1`、`launch_count` 和一个可比较的前次 / 当前 marker。

`DEC-04` portrait / scene / map 三类 fixture 可以在运行时生成 synthetic PNG，但必须先写入 filesystem，再从文件重新 decode/load；不得把内存 `Image` 直接赋给 UI 冒充动态文件加载。

`DEC-05` Windows export preset 使用稳定名称 `Windows Desktop`，输出为 `build/windows/my-world-g1-05.exe`；`build/` 不提交，正常可复现所需的 `export_presets.cfg` 可以提交。

`INV-01` Primary Purpose 保持：让单个玩家通过自然语言，与优秀 AI GM 在长期持续、可保存、可恢复、会自主演化的 2D RPG 世界中长期游玩。G1-05 只是支撑该目标的本地运行 proof，不得让支撑能力反客为主。

`INV-02` probe 不是 Game / Timeline / Save Point，也不是正式 Save Schema。文件缺失可以初始化；已有内容损坏或 Schema 不匹配必须清晰 FAIL，不得静默覆盖成“成功”。

`INV-03` 三张图片是 Foundation fixtures，不是最终美术、World Pack asset contract 或正式 asset database。

`INV-04` 不修改、记录、显示或调用任何 Provider API Key；不进行真实 DeepSeek / Kimi 请求。

`INV-05` 不因 G1-05 决定 GDScript/C#/mixed、same-process/local-runtime-process 或正式 persistence 技术；这些属于 G1-06 或后续阶段。

## Scope

Allowed：

- 演进 `src/main.tscn`，把当前 runnable Foundation surface 收敛为 G1-05 测试面；
- 修改或替换当前 G1 Spike 脚本，或新增立即使用的 `src/g1_05_本地IO图片导出探针.gd`；
- 必要时修改 `project.godot`、`.gitignore`；
- 新增并提交 `export_presets.cfg`；
- 添加与本 Spike 直接相关的最小自动检查或说明；
- 新增源码使用简体中文业务命名，代码符号遵循 GDScript 生态，关键契约 / 失败方式使用简体中文语义注释。

Prohibited：

- 正式 Save / Restore、Timeline persistence、SQLite 选型或正式 JSON Schema；
- World Pack manifest、Mod loader、asset database、资源热更新平台；
- G2 Conversation Spine、G1-06 Architecture Decision；
- 重构已通过的 DeepSeek / Kimi Provider seam或做 latency / thinking 优化；
- 升级 Godot、切换 .NET、安装第三方图片 / persistence 库；
- 为形式完整创建空的 L0/L1/L2/L3 层、空类或通用框架；
- 提交 `build/`、`.godot/`、`user://` 数据、真实凭据或本机私有产物；
- force push、覆盖未知 dirty worktree、`git add .` 或 `git add -A`。

## Required Deliverables

1. 一个清晰的 G1-05 UI Surface，至少显示：
   - `Local IO: PASS / FAIL`；
   - probe 的 `user://` 路径与可理解的本机绝对路径；
   - previous / current launch marker 或 counter；
   - `Portrait image: PASS / FAIL`；
   - `Scene image: PASS / FAIL`；
   - `Map image: PASS / FAIL`；
   - 当前运行形态：Editor/engine-run 或 exported executable。
2. 最小 local probe：创建目录、读取旧值、递增 / 更新、写入、关闭、重新打开并读回同一状态。
3. 三类视觉上可区分的 synthetic PNG fixture；每类都经过“写文件 → 从 filesystem 重新 decode/load → `ImageTexture` → UI display”。
4. `Windows Desktop` export preset，以及被 `.gitignore` 排除的 `build/windows/my-world-g1-05.exe` 输出路径。
5. 自动验证证据、准确 export 命令、简短 Owner UAT 指引和精确 Git 报告。

可选按钮仅限当前 proof 确有价值的 `Re-run IO` / `Reload Images`；不要做 RPG UI polish，也不要为打开目录引入额外平台抽象。

## Engineering Acceptance

`AC-01` Godot 4.7.2 工程可 parse/load，无脚本错误。

`AC-02` 本地 probe 成功写入并在同次运行中关闭、重新打开、读回一致内容。

`AC-03` 关闭应用再启动后，可读取前次 probe，并显示递增 counter 或 previous/current marker。

`AC-04` portrait / scene / map 三类图片均从真实 filesystem file decode/load 后显示；代码路径不能绕过 filesystem reload。

`AC-05` Windows export 命令成功并生成预期 EXE。

`AC-06` exported EXE 可直接启动，不依赖 Godot Editor。

`AC-07` exported EXE 中 Local IO 显示 PASS。

`AC-08` exported EXE 中三类动态图片均显示 PASS。

`AC-09` exported EXE 关闭再打开后，probe 跨启动持续存在。

`AC-10` 应用可正常退出。

`AC-11` `git diff --check` PASS。

`AC-12` source commit 后 `git status --short` clean，且 `build/` 生成物保持 ignored / untracked outside Git。

`AC-13` secret audit 无 API Key、token 或其它真实凭据；没有真实 Provider 调用。

## Product Value / Owner UAT Boundary

G1-05 的产品价值仅是证明“本地优先 2D 游戏 Host 可以脱离 Editor 保留极小本地状态并动态呈现图片”。Simple baseline 是 Godot 原生本地文件能力、普通 PNG 文件和标准 Windows export；若必须建设复杂平台才能证明这些 seam，判定为 scope expansion 并停止。

Agent 可以自动证明 parse、写读 seam、export 命令、文件产出、Git 与 secret 状态；但 exported EXE 的真实可见表现和跨启动体验由 Owner 做极短 UAT。Agent 的最高状态为：

```text
READY FOR OWNER UAT
```

Owner UAT 不超过 5 步：

1. 双击 `build/windows/my-world-g1-05.exe`；
2. 确认 `Local IO: PASS`；
3. 确认 portrait / scene / map 三个图片区均正常显示且各自为 PASS；
4. 关闭 EXE 后再次双击，确认 counter / marker 表明状态跨启动保留；
5. 正常关闭。其余 Git、diff、secret 和构建检查由 Agent 负责。

Owner 未明确返回 UAT PASS 前，不得宣布 G1-05 PASS，不得推进 G1-06。

## Validation Strategy / Commands

按以下层次执行，前一层失败时先修复，不要把示意命令冒充成功证据。

### 1. Focused static / parse validation

```powershell
Set-Location 'D:\AI\Projects\my-world'
git diff --check
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --editor --quit
```

如 Godot 4.7.2 对最终工程需要不同的无交互 parse 参数，先用 `--help` 核实并在最终报告给出实际命令与结果。

### 2. Godot local runtime validation

使用 console 或 GUI executable 直接 `--path 'D:\AI\Projects\my-world'` 启动当前工程。记录 UI 的 IO、三图、runtime mode 与跨启动结果；不得把 Codex sandbox 失败误判为 Windows-local blocker。

### 3. Windows export

最终 preset 名固定为 `Windows Desktop`，因此实际命令应为：

```powershell
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --export-debug 'Windows Desktop' 'D:\AI\Projects\my-world\build\windows\my-world-g1-05.exe'
```

若实际选择 `--export-release`，必须说明原因，并保证 preset 与输出路径完全一致。命令成功后检查 EXE 实际存在，且 `git status --short --ignored` 证明 build output 未被提交。

### 4. Exported executable runtime

直接运行 `build/windows/my-world-g1-05.exe`，不通过 Godot Editor。Agent 完成可自动化的启动 / 进程 / 文件证据，Owner 只执行上面的短 UAT。

### 5. Final repository checks

```powershell
git diff --check
git status --short
git ls-files build
```

再执行窄 secret audit，检查 tracked diff / task files 中不存在真实 key、Bearer token 或 `.env.local` 内容。不要输出环境变量值。

## Git / Integration

1. 开始时记录 branch、`git status --short`、HEAD 与 `origin/main`；Formal Code Base 必须是 `ee60f7cebf8d059e125278d8dabed578fd09dcbf`，否则先审计增量。
2. 不覆盖未知 dirty worktree；只修改本任务文件。
3. authoritative `main` write 前重新 `git fetch origin` 并比较 Task Base 与 current `origin/main`。影响 G1-05、目标文件、Stage 或 Task validity 的增量必须先做 Decision Propagation。
4. 精确 stage 本任务文件，不使用宽泛 staging。
5. 使用与实际 diff 一致的 commit message，例如 `G1-05: add local IO image export spike`。
6. 经当前任务授权后 push `main`；禁止 force push。
7. Task Packet commit 是纯文档交付，不是 implementation evidence。执行 Agent 的实现 commit 必须单独记录。

## Stop Conditions

停止并报告，不自行扩大范围：

- current source 与本 Task Packet 实质冲突；
- 未解释的 dirty worktree 或远端增量影响当前任务；
- 基础 seam 必须先冻结正式 persistence / World Pack / asset architecture 才能继续；
- Windows export 暴露真实 Godot blocker；
- 必须升级 Godot、切换 .NET 或引入第三方平台；
- 需要真实 API Key / Provider 调用；
- 实现开始进入 G1-06、G2 或大规模未来架构；
- exported executable 与 Editor/engine-run 行为出现无法解释的关键差异。

## Final Report

```markdown
## Result
READY FOR OWNER UAT | PARTIAL | BLOCKED

## Changed
- 文件与可观察行为

## Engineering Evidence
- parse / local runtime / IO / filesystem images / export / exported EXE
- 每项 PASS / FAIL / NOT VERIFIED

## Product Value Evidence
- Foundation purpose 与 simple baseline
- Owner UAT 状态

## Validation
- 实际命令与结果
- git diff --check
- secret audit

## Git
- branch
- Formal Code Base SHA
- final HEAD
- implementation commit / push
- final status

## Remaining
- 只写真实未完成事项、Owner UAT 或 blocker
```
