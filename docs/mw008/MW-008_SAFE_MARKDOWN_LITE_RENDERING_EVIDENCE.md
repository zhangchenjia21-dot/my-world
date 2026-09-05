# MW-008 Safe Markdown-Lite Narrative Rendering — Implementation Evidence

Status: **READY FOR INDEPENDENT REVIEW（候选）**
Implementer: Zcode + GLM-5.3-Flash（Owner weekend routing override）
Reviewer: GPT
Task Packet: `docs/tasks/MW-008_SAFE_MARKDOWN_LITE_NARRATIVE_RENDERING_TASK.md`
Task Branch: `mw-008-safe-markdown-lite-rendering`
Worktree: `D:/AI/Projects/.worktrees/my-world/mw-008`

## 0. Worktree cleanup report（packet §8）

```text
git worktree list（清理前）：
  D:/AI/Projects/my-world                          main（保留）
  D:/AI/Projects/.worktrees/my-world/mw-005-r3     mw-005-r3-style-salience @ a52236c → 已移除
移除依据：MW-005 R3 已过 GPT IR#3（879bc29 记录于 main）；working tree clean；
唯一提交 a52236c 已 push 至 origin/mw-005-r3-style-salience；无未知用户工作。
git worktree remove + prune；随后按规定路径创建 D:/AI/Projects/.worktrees/my-world/mw-008。
```

## 1. Changed files

```text
src/ui/叙事富文本渲染器.gd      # 新增：whitelist Markdown-lite → 安全 BBCode 的纯静态投影（确定性）
src/ui/叙事对话视图.gd          # GM 块改走 view-only raw 缓冲 + 整体重投影；五个渲染接触点
tests/mw008/安全轻量渲染测试.gd # 新增 focused 测试（43 断言）
docs/mw008/MW-008_SAFE_MARKDOWN_LITE_RENDERING_EVIDENCE.md
```

无 Domain/Persistence/Context 改动；无模型输出协议、parser/gate/retry；无新 Markdown 引擎；Player 输入渲染路径零改动。

## 2. View 渲染路径审计（packet §7）

| 路径 | 修正前 | 修正后 |
|---|---|---|
| live GM streaming | `draft_appended` → `_current_gm_content.add_text(delta)` | delta 追加进 view-only `_current_gm_raw` → `_render_current_gm()` 整体重投影（clear + parse_bbcode） |
| retry/regenerate/correction | `attempt_started` → `clear()` | 同上 + `_current_gm_raw = ""` |
| accepted restore/redraw | `_render_restored_entries` → `add_text(gm_text)` | `_current_gm_raw = gm_text` → `_render_current_gm()`（与 streaming 同一投影函数） |
| GM-only Opening | 同 streaming | 同 streaming（同一 renderer，测试显式覆盖） |
| Player entry | `add_text(player_text)` | **零改动**（不解释 Markdown） |
| Restore 进度切换 / shutdown | `redraw_from_conversation` / `_clear_rendered_entries` | 同左 + raw 缓冲清空 |

`_current_gm_raw` 生命周期：`_begin_gm_entry`（新块）/ `attempt_started`（复用块）/ `_clear_rendered_entries`（重建/拆除）清空；仅服务当前 GM block，不是第二套 history/Conversation 存储，永不回写。

## 3. Renderer 架构（live-stream parser/render architecture）

`NarrativeRichTextRenderer.render(raw) -> String`（纯静态、确定性）：

```text
1. BBCode 转义（单遍逐字符）：[ → [lb]，] → [rb]
   —— 顺序 replace 会把上一步插入的 [lb] 中的 ] 再次替换（开发中实测发现并修正），
      单遍转义后任何模型文本都无法产生可执行的 BBCode。
2. 逐行处理（转义后的纯文本上）：
   - trim 后整行为 "---" → [hr]（Godot 4.7.2 RichTextLabel 原生支持，headless 探测证实）
   - 否则 emphasis 扫描：先 **bold** 后 *italic*，最近闭合配对；
     未闭合 / 空内容 / 交叠歧义（如 ****、*a**b*）整段 fail-soft 保持原文。
3. 超长防御：>200k 字符跳过 markdown-lite，仅转义原样展示（不截断内容）。
```

确定性 ⇒ 流式任意分片拼接后的最终渲染 == 一次性渲染整体 raw（测试断言）。

## 4. Focused proof（tests/mw008/安全轻量渲染测试.gd — 43 断言 0 失败）

真实 main.tscn + NarrativeConversationView + Domain Conversation（隔离模式）+ 桩 adapter：

1. live streaming bold（单 delta）：`get_parsed_text() == "张飞按剑而立。"`（无字面 `**`）；
2. split chunks（`**糜`/`芳、孙`/`乾**拱手。`）：中间帧 `"**糜"` 可读字面（fail-soft），终帧无 `**`；raw 缓冲 == 拼接 raw；renderer 分片==一次性 等价断言；
3. italic chunk boundary：`*低`+`声*道：…` 终帧 `低声道：…` 无 `*`；raw 缓冲精确；
4. standalone `---`：renderer → `[hr]`，parsed 无 `---`，前后文保留；
5. unmatched：`他说：**此事未完` 原样可读（`**` 与尾文零丢失），accepted bytes 不变；
6. BBCode 注入：`[color=red]红字[/color]`、`[url=…]`、`[img]` 在渲染视图中保持字面（含方括号），renderer 输出含 `[lb]…[rb]`——任意 BBCode 解释不可能；
7. raw 真值：accepted `gm_text` 与 model bytes 逐字节相等（bold/split/italic/separator/unmatched/injection 全案例）；
8. redraw / reopen 等价：`redraw_from_conversation()` 与第二 view 实例（fresh Conversation + `restore_accepted_entries` → production reopen 同一 `_render_restored_entries` 路径）渲染结果 == live streaming 终帧，raw durable bytes 不变；
9. retry/regenerate：raw 缓冲清空、新草稿不拼接旧 markup、accepted bytes raw；
10. GM-only Opening：同一 renderer（bold + [hr]）；
11. Player 输入：`**玩家**输入 *不* 解释` 原样渲染（不解释 Markdown）；
12. 结构性：本任务未新增任何 Narrative parser/gate/retry/输出协议（代码 diff 佐证）。

## 5. Regression matrix（Godot 4.7.2 headless，task-owned roots）

```text
tests/mw008/安全轻量渲染测试.gd           failures=0（43 断言）
tests/g2_03_会话视图离线测试.gd           failures=2 — PRE-EXISTING（基线复现证明：stash 本任务改动后同样
    T3 failed code == transport + 网络提示两处失败；T3 依赖对 .invalid 的真实 DNS 解析，
    本环境网络栈行为不同；与 MW-008 渲染改动无关）
tests/g4_07a/首次开场运行时聚焦测试.gd    failures=0
tests/g4_08b/公开D20界面整合测试.gd       failures=0（共享 GM block 的 d20 UI）
tests/g4_09uatbc01/叙事响应流式关键路径测试.gd failures=0
tests/g3_04/存档读取界面测试.gd           failures=0（restore/redraw UI）
tests/mw005/叙事风格锚点显著性测试.gd     failures=0（确认未触碰 Narrative consumer 请求路径）
git diff --check                          clean
Windows export validation                 PASS（--export-release "Windows Desktop"）
Real Provider calls                       0
```

## 6. Remaining risks / notes for GPT

1. 单个 `*` 成对出现且中间非空时按 italic 处理（如 "3 * 4 = 12" 会斜体化 " 4 "）——与 CommonMark 星号行为一致，属 v0.1 既有语义而非缺陷；若 UAT 觉得噪声明显，可后续在 renderer 内收紧为"非空白邻接"规则（属本 Work Item 的 Revision，不是新平台）。
2. 流式期间每个 delta 全量重投影当前 GM block（clear + parse_bbcode）。当前块长度（数 KB）下无性能问题；极长单块（接近 MAX_RENDER_CHARS）会跳过 markdown-lite 仍可读。G7 长局上下文任务若出现真实性能证据再评估。
3. 选区（selection_enabled）在重投影时会复位——流式期间玩家选中文本后继续出字会丢失选区；罕见交互，未处理。
4. `[hr]` 为 Godot 4.7.2 原生 BBCode 标签（headless 探测证实），非自定义协议。
