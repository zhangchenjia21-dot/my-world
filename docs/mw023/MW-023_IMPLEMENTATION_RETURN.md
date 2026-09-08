# MW-023｜Gameplay Typography Readability Baseline — Implementation Return

状态：**READY FOR INDEPENDENT REVIEW**。未授予 Product PASS。

## Candidate identity

- Branch：`mw-023-gameplay-typography-readability`
- Worktree：`D:/AI/Projects/.worktrees/my-world/mw-023-gameplay-typography-readability`
- Formal product base / refreshed implementation main：`bfe108cbb1f749307c421517f5380b9eb00a9317`
- Exact Starting HEAD：`ea09d6bc3f032e55c01c162ff34551707cab7658`
- Exact Implementation HEAD：`4ad8d2137f905edc2821d1a09eae8545df055baf`
- Final candidate：包含本文的后续 evidence-only commit；精确 SHA 随交付回复返回，也可用 `git rev-parse mw-023-gameplay-typography-readability` 解析。它与 Implementation HEAD 的 production tree 相同。
- Refreshed governance main：`9a6251bac0b85a029ebe7dba02d09a7a2df41dec`。开始与交付前两次刷新一致。

已读取 Task Packet、repo/governance AGENTS、current status v17.15、Roadmap v4.4、Package 1 Owner UAT U1、Typography Baseline v1.0 Decision。未发现 superseding architecture。

## 实现与 font inventory

修改前审计真实调用链：`main.tscn` 根 Theme → Application Shell / Narrative view →动态 World surfaces / People card / Debug panel。`叙事富文本渲染器.gd` 仅产生既有安全富文本标签，没有额外字号来源。`视觉舒适调色板.gd` 定义样式与颜色，不设置字体大小。没有业务层、Provider、存储改动。

| 来源 / active Game 内容 | 修改前来源 | 最终 effective font |
| --- | --- | --- |
| Root Theme →普通按钮、Player 正文、继承控件 | 18px | 20px |
| TopBar title / 其它按钮及 subtitle | 28px / 18px / 14px | 28px / 20px / 20px |
| Narrative GM normal / bold / italic / mono | normal 20px，其余继承 | 各变体均 20px |
| Narrative Player/GM 标记、public d20、状态/错误 | 13–15px | 20px |
| composer / Send / Cancel | 20px | 20px，132–180px 高度策略不变 |
| Recommendation heading / buttons | 16px / 18px | 20px / 20px |
| World navigation / header / empty | 18px / 20px / 14px | 20px |
| Overview、Character、Important Experiences 动态 Labels | 12–16px | 20px |
| People 折叠按钮 / 展开正文 | 18px / 13px | 20px / 20px |
| Save / Restore labels、输入、选择器、按钮 | 13–18px | 20px |
| Save / Recover / DB recovery 确认框及 Save dropdown | 继承 | 实际查询均 >=20px |
| Debug toggle / rows | 18px / 16px | 20px / 20px |
| Bottom status | 14px | 20px |

保留 Main Menu 40px 与 Game title 28px，未更换字体、配色或新增偏好设置。Main Menu/Wizard 只受到 root Theme 默认字号继承；MW-003 真实窗口 smoke 通过并保存截图，未修改其设计。

为实际字号增长做的局部适配：

- 原五个 World 导航按钮按原顺序自动换行，仍是相同 Surface、信号和选择状态，无 IA 改动。
- 既有 Save VBox 增加纵向 ScrollContainer 包裹；Save/Restore owner、命令和控件不变。
- World/Save 轨道固定占 18px；Debug 14px、Recommendations 12px 轨道改为具有固有宽度的局部 StyleBox，使 ScrollContainer 真正预留空间，避免覆盖放大后的文字。未修改全局 Theme 色彩。
- public d20 标题允许换行。
- 实测 960×540 的 Narrative 曾因字体增长仅剩 64px；局部上下留白从 12px 调至 6px，列及推荐区间距从 8px 调至 4px，恢复到 92px。字体和 composer 高度均未缩小。

## 验证与证据

运行入口：`tests/mw023/运行字号验证.ps1`，PowerShell 7，模式 `Focused` / `Window` / `Regressions`。全部使用 task-owned 隔离 SQLite 与既有模型桩。真实 Provider 调用为 0。

- [focused.log](evidence/focused.log)：949 checks、0 failures。
- [window.log](evidence/window.log)：949 checks、0 failures；真实 Godot 窗口依次 960×540、1280×720、1920×1080。
- [effective-fonts.json](evidence/effective-fonts.json)：789 个实际 visible/inherited 字号采样，均 >=20px；另有确认框和下拉菜单实际字号断言。不是 grep 代替运行时验证。
- Fixture 经真实 accepted Conversation、World identity binding、同一次 Curator 生成非空 Character / Important Experiences / People 投影，推荐行动使用既有五组 label/draft contract。长正文触发真实 overflow。
- 覆盖 TopBar、Narrative/辅助/public d20、composer、Recommendations、全部五个右栏导航与内容、People 展开、Save 成功、Debug、确认框。
- 逐尺寸检查导航和主控件在窗口内；右栏纵向滚动能到达下方内容，960×540 的读取按钮可滚动到完整可操作区域；右栏/Debug 正文不被轨道遮挡。
- Recommendation 点击填入 exact draft。字体检查、切换、滚动和 resize 前后 durable snapshot / Provider request counts 不变。

| 窗口 | Narrative viewport 高 | composer 高 | 结果 |
| --- | --- | --- | --- |
| 960×540 | 92px | 132px | 原导航两行，可切换信息；People / Save 纵向滚动 |
| 1280×720 | 168px | 132px | 全部 Surface 可读、可操作 |
| 1920×1080 | 498px | 162px | 标题层级保留，右栏普通字号与聊天同基线 |

截图：`evidence/<width>x<height>-<Surface>Tab.png`、对应 `-bottom.png`、`debug-<width>x<height>.png`。共 25 张 Game 截图，另附 2 张 Main Menu / Wizard smoke 截图。已目视检查三个尺寸的代表截图及 Save bottom、Debug。

### 直接相关回归

[regressions.json](evidence/regressions.json) 列出全部 22 suites 及日志。21 suites exit 0；G3-03 有一条正式基线已存在的断言失败。

通过：G2-03 / G2-04、MW-003、MW-011、MW-014、MW-015 / R1 / R2 / R2 UI、MW-017、MW-018 / R1、MW-019 lifecycle / pairs / Send-d20 routes、MW-021、MW-022 deterministic / real-window、G3-04 Save、G3-05 Restore、G5-01 timeline。

- MW-019 paired UI：105 checks，0 failures。
- MW-021 overflow / reopen / manual history / follow-latest：101 checks，0 failures。
- MW-022 real-window：52 checks，0 failures。
- MW-003 exit 0，保留既有 ObjectDB/resources exit warnings；未隐藏或修复无关 teardown。
- G3-03：`opaque World JSON is not injected as Game Context` 一条失败；从 `bfe108cbb1f749307c421517f5380b9eb00a9317` 用 `git archive` 提取 production src/addons 和该测试到忽略的 build 副本，重新 import 后复现同一失败。见 [baseline-g3_03.log](evidence/baseline-g3_03.log) 与 [regression-g3_03.log](evidence/regression-g3_03.log)。其余上下文重建、恢复界面、损坏 DB 保护断言通过。此项没有被宣称为通过，也未借本任务修改其语义。

### Final import / fresh Windows export

Godot `4.7.2.stable` final import exit 0；fresh Windows export exit 0。最终 import/export 日志未发现 script / parse / export error。

`run-game.ps1 -ValidateExportOnly` 明确记录 rebuilt、verified、launch skipped，未复用旧 PCK，未启动导出游戏。

- Built UTC：`2026-09-08T08:30:59.8690692Z`
- PCK：`build/windows/my-world.pck`，2,487,428 bytes
- PCK SHA256：`a5b7a84a9e397a2c699b5f03b546ecab4d7dd2219682c0099d0eb975b7d58d40`
- Product input SHA256：`16b8689d0895692b35a669494756e04bac2e1dc3e35bcbc294b745212b6edace`
- EXE / PCK / SQLite DLL 均存在；完整哈希见 [build.json](evidence/build.json)。导出位于 task worktree，未安装到 Owner canonical checkout。

## 边界 / 残余风险

- 改动仅限五个现有 UI 源文件、focused 测试和证据；没有 Provider、Conversation、World、Curator、Recommendation contract、Debug semantics、SQLite、Save/currentness 或其它 Package 功能修改。
- 架构复查：无新增模块或向上依赖，无新跨模块内部引用；现有 leaf UI 继续消费原安全投影。新增注释只说明局部布局原因，与代码一致。
- 960×540 同时显示右栏和推荐行动时聊天约三行，需更频繁纵向滚动；未降低字号追求密度。Owner 长时间阅读舒适度仍需独立审查后确认。
- G3-03 已知基线失败、MW-003 exit warnings 如上保留。
- 本任务工作树创建时 clean。初次 import 的 10 个旧截图 sidecars 和 1 个旧测试 UID 均核对创建时间、SHA 后仅清除本次生成物；13 个 tracked fixture imports 的规范化内容 hash 与 index 一致，仅刷新索引。Owner 原有 modified/untracked 内容未触碰。
- 未 merge main；未安装 Owner build；未宣布 Product PASS。

停止于 **READY FOR INDEPENDENT REVIEW**。
