# MW-021｜Narrative Scroll Navigation & Reopen Position

Status: **READY FOR INDEPENDENT REVIEW**  
Date: 2026-09-08

## Exact source identity

- Branch: `mw-021-narrative-scroll-ux`
- Worktree: `D:/AI/Projects/.worktrees/my-world/mw-021-narrative-scroll-ux`
- Formal Product Code Base: `5e5fd006fd17683ae811b17138df76a18b0b96aa`
- Starting HEAD / refreshed implementation main: `9239fb10539898fd3d98d256214dd02df73696fa`
- Implementation HEAD: `4978341809424ac1be3c12ba59974cc9c5468995`
- Final candidate: 紧接 Implementation HEAD、包含本 Return 的 evidence-only commit；精确 SHA 在创建提交后的最终交付消息中返回。生产代码与测试均精确等于 Implementation HEAD。
- Governance main（开始 fetch 和提交前远端复核）: `ce4c627880edef8927eaa09f8e5df0500b2438c6`

读取两个 current main 的 AGENTS、Owner collaboration preferences、Task Identity、current status v17.11、U2 v1.1、Narrative Scroll frozen decision，以及任务分支上的 Task Packet。Starting HEAD 相对于 formal product base 只增加 MW-021 Task Packet，未改变产品代码。当前 status/packet 优先于旧 AGENTS stage table。

检查已有 worktrees 后从发布的 task branch 创建指定独立 worktree。Owner canonical checkout 保留在 `5e5fd006fd17683ae811b17138df76a18b0b96aa`；其 `.gitignore` 和十个未跟踪 screenshot sidecar 未被触碰。未 merge main、未安装 Owner 版本、未访问真实 Game/Source/settings、未调用真实 Provider。

## Root cause / final change

实测根因与冻结判断一致，未触发 materially-different STOP 条件：

- 长历史的主 scrollbar 实际宽度为 **0px**，max=8656、page=327，鼠标拖动无效。
- `_initialize_session()` 只重建 entries，初次重开稳定后 value=0。
- 既有异步 follow 只在等待前检查 `_follow_scroll`，已排队操作会覆盖等待期间的手动上翻。

唯一修改的 production file 为 `src/ui/叙事对话视图.gd`（24 insertions / 3 deletions）：

1. 主 Narrative 垂直条局部宽度 18px；局部滑块使用既有 Palette 的 muted/secondary 颜色，最小高度 28px。保留 Godot 原生拖动、wheel/keyboard 行为，不改变全局 Theme。
2. 正文可读列为该滚动条预留实际最小宽度，避免窄窗口横向溢出/裁切。
3. 初始化复用既有 `redraw_from_conversation()`，重建历史后初始化 follow-latest。
4. follow 等待两帧完成富文本/嵌套 Container 布局，然后重新检查手动 follow 状态与绑定 Conversation；等待期间主动上翻或 Session 切换时不执行旧定位。

`_on_narrative_scroll_changed()` 的 near-bottom 24px 判定保持原样。普通增量没有强制开启 follow。Continue/rebind/Restore 的明确完整历史重建仍初始化 latest 定位。

没有新持久化状态、Provider call、schema/table、Conversation/World/Timeline/Save mutation、模块依赖或层级变化。People、Experiences、Recommendations、Context Budget 和全局 Theme 代码无变化。中文注释补充了局部命中宽度、布局时序、手动阅读优先和非持久化契约。

## Focused evidence

`tests/mw021/叙事滚动导航测试.gd` 使用真实 `main.tscn` 和 task-owned SQLite。先持久化 32 个 accepted Player/GM 回合，再关闭并从磁盘重新打开；每个 GM 回合含六段文本，实际 overflow 超过四个 viewport。没有通过模型生成夹具。

同一最终 focused suite：

| 运行 | 结果 |
| --- | --- |
| Starting product baseline | 101 checks / 6 failures |
| Final product headless | 101 checks / 0 failures |
| Final product real-window rendering | 101 checks / 0 failures |

证据：`evidence/focused-baseline.log`、`focused.log`、`focused-visual.log`。

覆盖实际 range、可见 18px bar、Viewport 输入事件触发的真实 scrollbar 鼠标拖动、初次 reopen bottom、手动上翻后的 accepted append 不 snap-back、near-bottom 恢复 follow、排队 follow 等待期间手动上翻、Continue/rebind、Save/Restore current-prefix redraw、short/empty history 和无横向溢出。

比较 accepted bytes、durable Conversation、World、current head、Timeline fixture、Save 列表和 Recovery projection，证明 reopen/scroll/drag/rebind/redraw 自身不写领域数据。测试中显式 accepted fixture/Restore 操作是被测场景准备，区别于滚动动作。

窗口证据：`evidence/narrative-1280x720.png`、`narrative-960x540.png`、`narrative-1920x1080.png`。三个尺寸可见滑块、底部最新内容与 composer；窄/宽布局无横向 overflow。截图为隔离 fixture，非 Owner UAT。

## Directly affected regressions

Runner: `tests/mw021/运行叙事滚动验证.ps1`（PowerShell 7）。最终结果保存在 `evidence/regressions.json` 与同名日志。

| Suite | 结果 |
| --- | --- |
| G2-03 Narrative view / Send / Ctrl+Enter / cancel / retry | exit 0，无断言或 script error |
| G2-04 Conversation domain | exit 0，无断言或 script error |
| MW-008 Markdown-lite Narrative rendering | exit 0，无断言或 script error |
| G3-03 Context/recovered Narrative UI | exit 1，唯一旧 Context 文案断言失败，见下文 |
| G3-05 Restore/recovery UI/currentness | exit 0，无断言或 script error |
| G4-09UATBC01 streaming Narrative critical path | exit 0，无断言或 script error |
| MW-003 real-window theme/UI smoke | exit 0，无断言或 script error；既有 3 objects / 1 resource 退出诊断 |
| MW-011 host/viewmodel UI | exit 0，无断言或 script error |
| MW-019 paired recommendation/composer UI | exit 0，无断言或 script error |
| MW-019 Send/d20 lifecycle | exit 0，无断言或 script error |

**没有将全部回归包装成绿色。** G3-03 的 `opaque World JSON is not injected as Game Context` 断言检查 system 文本不含 `Current Game Context`，在 Starting HEAD 同样失败；当前 prompt 已有该文字，与滚动无关。该套件内所有 recovered Narrative、Regenerate、Send、durable reopen、startup-failure UI 检查均通过。保留原测试和产品 Context 不变；证据为 `evidence/g3-03-baseline.log` 与 `g3-03.log`。Runner 如实因该失败退出 1。

MW-003 在 Starting HEAD 也有完全相同的 3 objects / 1 resource 退出诊断，见 `evidence/mw003-baseline.log`；focused/import/export 无该诊断。无关资源清理未扩入本任务。

执行修正：最初把必须截图的 MW-003 用 headless 运行导致空纹理错误，已改为真实渲染；最初长证据路径中两项 Source fixture 安装失败，缩短 task-owned 路径后通过。最终测试未修改 Source fixture/production validator。早期执行日志留在 ignored `build/mw021/`，提交的 regression logs 为最终有效运行。

## Final import / Windows export

Implementation HEAD 提交后执行：

- Godot `4.7.2.stable.official.ed1daf0bf` final import：exit 0，无 warning/error。
- Windows PowerShell `run-game.ps1 -ValidateExportOnly`：exit 0，**重新导出**，freshness verified，launch skipped。
- EXE、PCK、SQLite DLL 全部存在；hash/size 在 `evidence/build-artifacts.json`。
- Freshness input hash: `8c37d405108a6afb63bebbb094bb3f75898d251ddaa5fd6009010afc9e2fd54e`。
- Build time UTC: `2026-09-08T04:37:07.8764856Z`。
- PCK SHA-256: `631541f4a667439911547f50650f5bb85324e9e60d21a9011fad7fa6cbeb55d0`。

导出路径仅在 task worktree 的 `build/windows/`，没有复制到 canonical Owner 目录。证据目录 `.gdignore` 防止截图成为产品导入资源；ignored build `.gdignore` 隔离测试副本。仅移除本次新建 task worktree import 生成的已知 sidecars，并核实其他 tracked fixture sidecars 只有 CRLF/LF 差异后刷新 Git stat；没有操作 Owner 的同名未知文件。

## Reproduce

在指定 task worktree，使用新的 fixture 路径：

```powershell
& 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe' --headless --path . --editor --import
& 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/mw021/叙事滚动导航测试.gd -- --root=D:/AI/Projects/.worktrees/my-world/mw-021-narrative-scroll-ux/build/mw021/review
& 'C:/Program Files/PowerShell/7/pwsh.exe' -NoProfile -File tests/mw021/运行叙事滚动验证.ps1
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./run-game.ps1 -ValidateExportOnly
```

## Residual risks / stop

- G3-03 旧 Context assertion 与 MW-003 退出资源诊断保留，均有精确起点对照；本次没有修复或隐藏它们。
- 18px 滚动条与 reopen 定位已经工程验证，Owner 的实际鼠标、系统缩放和长时间阅读体验仍待集成后的 bounded confirmation。
- 本次只准备独立审查候选。未宣布 Engineering PASS / Product PASS，未 merge main，未启动下一 Package 或安装 Owner 试玩版本。

**READY FOR INDEPENDENT REVIEW**
