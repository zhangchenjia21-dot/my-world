# MW-015 Revision 2｜Initial Character currentness 契约缺口

Status: STOPPED FOR ARCHITECTURE DECISION
Work Item: MW-015
Revision: 2
Review-Round: 0
Implementation base: `d71a970a8c71a591c1daa3bac35afb18c7a728ac`
Governance main: `4bb8ec8b85474ac51f39d57e4f28e7e065470af2`
Branch: `mw-015-r2-model-driven-initial-character-curation`
Worktree: `D:/AI/Projects/.worktrees/my-world/mw-015-r2`

## 1. 停止依据

当前 Task Packet `docs/tasks/MW-015_R2_CHARACTER_INFORMATION_PRESERVATION_TASK.md:108`：

> If the existing MW-014 curation model cannot represent an initial baseline cleanly without an authority/schema change, STOP and return the exact architecture gap before implementing a parallel classifier.

本次只完成 current-source preflight 和最小结构复现，未修改产品实现。不是 READY FOR INDEPENDENT REVIEW，不是 Engineering PASS。

## 2. 已读取的 authority

已 fetch 两个 origin/main，并读取实现仓库/治理仓库 AGENTS、R2 Task Packet、MW-015 R1 Owner UAT、MW-015 R1 Task Packet、MW-014 Task Packet、MW-011 R3 Owner UAT、治理 Current Status 及冻结的 Character/Important Experiences、Model-driven Information Curation decisions。

R2 Task Packet 明确修订旧 UI-only scope，要求模型初始整理；不能继续用 R1 的 UI-only 限制否定 R2。本报告也不因旧文档中 deterministic selection 的措辞去添加 Program classifier。

治理 Current Status 的 R2 branch 仍写 `mw-015-r2-character-information-preservation`；当前明确指定的 executable Task Packet 写 `mw-015-r2-model-driven-initial-character-curation`。隔离工作树按后者建立；未改写治理事实。

## 3. 已证实的存储缺口

缺口在初始 baseline 的 durable identity/currentness 表示，不在模型的语义选择能力，也不是 SQLite 不能存储 JSON。

1. Final Create 当前通过 `src/最终建局/L2_流程层/原子最终建局流程.gd:228` 创建 initial Game。
2. `src/persistence/L2_流程层/世界持久化流程.gd:62` 明确初始化 `accepted_turns_json='[]'`。因此 frozen profile 存在但 accepted 历史为空是合法产品状态。
3. `src/信息整理/L0_公理层/信息整理契约.gd:63` 只接受精确 owner 字段 `{schema, turns}`。
4. 同文件第 68–75 行仅遍历实际 accepted indices，并验证 Player+GM prefix 与前序 curation parent。空历史无可投影的 curation record。
5. `src/信息整理/L2_流程层/回合信息整理流程.gd:103` 跳过无 Player text 的 opening；第 152 行要求实际 accepted prefix 存在；第 162 行再次拒绝扩展 owner keys；第 166 行只写 indexed turn result。
6. `src/信息整理/L1_器件层/角色经历投影器.gd` 只有薄 frozen headline/summary fallback，再折叠 valid current turn records；没有 standalone initial baseline。

所以，给模型增加 initial prompt 本身无法让空历史下的结果成为有效 durable/current Character：
- 写 `turns["0"]`：没有真实 turn 0，projection 不读取；
- 写 `turns["-1"]`：不在合法 accepted index 迭代范围；
- 新增 `initial` / `baseline`：改变现有 exact curation JSON schema，当前 reader/writer 都拒绝；
- 合成一个 accepted Turn：污染真实 Conversation，不能作为 workaround；
- 把模型结果写回 frozen `player_profile`：把 immutable starting source 与 current curation 混为一处；
- 独立 side store：绕过已有 World/Timeline owner。

## 4. 实际 opening 路径：可行范围与待明确之处

探针也证明：**真实 accepted GM-only opening 可以在现有记录结构中承载 Character result**。这不是不可实现声明。

Shell `src/应用壳.gd:914` 会对空历史启动真实 opening；当前 opening 过程异步且允许失败/取消，输入 gate 等待其完成。可以在成功 accepted opening 后触发初始整理并绑定该真实 Turn，无需新增 JSON 字段。

但这把初始 Character 可用性依赖于 opening 成功，无法在仍为空历史的 activation / opening-pending / opening-failed Game 上独立完成初始化。R2 写的是 Game activation 初始化、opening Narrative 仅在有用时作为可选输入，没有明确冻结“必须先成功接受 opening 才能初始化 Character”的产品前提。本次不自行把这个前提加入任务以回避其 schema STOP 条件。

## 5. 建议 GPT 冻结的最小决策

推荐允许在**同一个 World/Timeline curation owner**中加入可选 initial baseline，并明确：

- baseline 只从 Game-local frozen player-safe profile 经模型生成；
- program-owned Game/frozen-material/current-history binding；
- 没有 accepted Turn 时合法的 baseline identity；
- 后续 lived record 的 parent/折叠顺序以及旧 `{schema, turns}` 数据兼容；
- Restore 撤销 baseline、重新打开和初始请求在途失效的规则；
- 已有 lived Character 时不以初始材料覆盖它；
- initial Character 不凭静态 biography 制造 milestone；
- 不新增 SQLite 表或修改 Source generation。

另一种明确决策是：允许 R2 仅在**真实 accepted opening 已存在后**初始化，明确空历史阶段继续薄 fallback，并说明已有非 opening 历史如何选择实际 anchor。此路线可以尽量复用现有 turn-shaped schema，但应先确认其产品覆盖范围符合此次 Owner-UAT correction。

两条路线的语义选择均由模型完成，不需要 title/keyword whitelist、profile-group mapping、importance score 或 named-character special case。

## 6. 复现

脚本：`tests/mw015r2/初始整理契约缺口验证.gd`。
日志：`docs/mw015/r2/initial-curation-contract-probe.log`。

命令：

```powershell
& 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:/AI/Projects/.worktrees/my-world/mw-015-r2' --script 'res://tests/mw015r2/初始整理契约缺口验证.gd'
```

Godot 4.7.2；exit 0；7 项现状观察均复现；无脚本错误。它调用 current main 的真实 L0 contract 与 L1 projector，验证合法结构、空历史、负索引、真实 opening 和扩展字段拒绝行为。没有 Provider 调用、数据库写入或产品逻辑变更。探针成功表示缺口被复现，不表示 R2 实现验收通过。

## 7. 边界与交接

- 未修改任何 src、Source、SQLite schema、场景或 UI。
- 未执行真实 Provider smoke、全量回归、响应式 QA 或 Windows export：产品实现按显式 STOP 条件尚未开始。
- 未 merge main，未安装/导出候选到 Owner 主目录。
- Owner 主目录原有 `.gitignore` 修改保持原样；只刷新远端引用。
- 本分支仅包含此报告、复现脚本和日志。等待上述 baseline 表示/activation 覆盖决策后继续同一 MW-015 Revision 2。
