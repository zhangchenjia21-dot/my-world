# MW-005 Revision 3 — Narrative Style Salience / Late Style Anchor — Implementation Evidence

Status: **READY FOR INDEPENDENT REVIEW（候选）**
Implementer: Zcode + GLM-5.3-Flash（Owner weekend routing override）
Reviewer: GPT（IR#3）
Task Packet: `docs/tasks/MW-005_REVISION3_NARRATIVE_STYLE_SALIENCE_TASK.md`
Task Branch: `mw-005-r3-style-salience` @ `D:/AI/Projects/.worktrees/my-world/mw-005-r3`

## 0. Worktree hygiene report（packet §6）

```text
git worktree list（清理前）：
  D:/AI/Projects/my-world            main（保留，主工作区）
  D:/AI/Projects/my-world-baseline   detached @ 5809cf2   → 已移除
  D:/AI/Projects/my-world-mw006      mw-006-… @ adb3ca4   → 已移除
  D:/AI/Projects/my-world-mw007      mw-007-… @ 9494c92   → 已移除
移除依据：三个均为本周末 Agent 自建任务 worktree；任务已关闭/已过 IR；
working tree clean（baseline 中唯一 dirty 为 Agent 运行 Godot --import 产生的
.import churn 与 .uid 生成物，已还原/删除，无未知用户工作）；
全部独有提交均已 push 且 remote 可达（origin/mw-006-…、origin/mw-007-…、5809cf2 ∈ origin/main）。
使用 git worktree remove + prune；prune 后仅剩主工作区。
R3 worktree 按规定创建于 D:/AI/Projects/.worktrees/my-world/mw-005-r3。
```

## 1. Changed files

```text
src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd   # 事实 context_text 与派生 style_reference_text 分离；新增 STYLE_NARRATIVE_ANCHOR_CUE 常量
src/首次开场/L2_流程层/首次开场运行流程.gd           # opening 与 continuation 在事实/World-Turn 材料之后追加 anchor
src/行动判定/L2_流程层/公开D20行动判定流程.gd        # resolution/no_check/degraded narrative 经 _append_style_anchor 末尾追加；control lane 不调用
tests/mw005/叙事风格锚点显著性测试.gd                # 新增 R3 focused 测试（81 断言）
tests/mw005/三国文风Primer接线测试.gd                # R1 投影断言更新到 R3 分离合同（语义不变）
docs/mw005/MW-005_REVISION3_STYLE_SALIENCE_EVIDENCE.md
```

Primer bytes / Primer input / World section bytes / Source generation
`58966f73dfade50b0aa7536aad38a8840e614016975e8beba0735f7dd14ab443` 全部不变（测试断言 fingerprint）。未 republish Source；未新增任何 gate/parser/classifier/retry/黑名单/模板/平台。

## 2. Pass A — request placement / dilution 实测（真实冻结 Three Kingdoms Game，实际最终 system content）

before（base `c678dfd`，临时审计脚本实测后删除；numbers = system content 总长 / boundary 位置 / boundary 之后剩余字符 / boundary 之后是否仍有事实或 mechanics 材料）：

```text
first_opening          total=29598  boundary_at=84%  chars_after=4553  tail: Player/NPC 事实
ordinary_continuation  total=29682  boundary_at=84%  chars_after=4637  tail: Player 事实 + materialized World Turn
control                total=27311  boundary=ABSENT（R2 已排除）
resolution_narrative   total=30324  boundary_at=82%  chars_after=5279  tail: Player 事实 + mechanics rules + d20 authority
control_recovery       total=27340  boundary=ABSENT（R2 已排除）
degraded_narrative     total=29639  boundary_at=84%  chars_after=4594  tail: Player 事实
no_check_narrative     total=29625  boundary_at=84%  chars_after=4580  tail: Player 事实
（各 narrative stage Primer 恰好一次）
```

结论：Primer 被埋在 ~82–84% 处，其后仍有 4.5k–5.3k 字符事实/mechanics 材料——salience 不足与 Owner UAT 观察一致。

after（R3 实测，同样方法）：

```text
first_opening          total=29773  anchor_at=89%  chars_after_anchor=3186（= anchor 自身：boundary+Primer+cue）tail: 零事实/mechanics 材料
ordinary_continuation  total=29857  anchor_at=89%  chars_after=3118  tail: 零（World Turn 材料现位于 anchor 之前）
control                total=27311  ABSENT（不变）
resolution_narrative   total=30499  anchor_at=89%  chars_after=3118  tail: 零（mechanics rules + authority 现位于 anchor 之前）
control_recovery       total=27340  ABSENT（不变）
degraded_narrative     total=29814  anchor_at=89%  chars_after=3118  tail: 零
no_check_narrative     total=29800  anchor_at=89%  chars_after=3118  tail: 零
（各 narrative stage Primer 恰好一次；Primer 不在任何 stage 出现第二次）
```

## 3. Pass B — positive steering audit

修正前 request 中的风格材料只有**负面** authority 免责（boundary header 说明"不构成世界事实/未来/Knowledge/因果"），全局 GM_INSTRUCTIONS 同样以负面约束为主（"不要把不同世界统一成…""不要机械堆砌古语…"）。模型缺少一个明确的**正向表达目标**，解释了"词汇在、句法节奏/信息传递方式不变"的 UAT 观察。

修正：新增单一有界 `STYLE_NARRATIVE_ANCHOR_CUE`（const，不随内容增长）：

> 表达锚点：当存在以上 Literary Style Reference 时，它是本局中文 GM 叙事的默认声音锚点。让句法节奏、称谓礼法、对白方式、信息传递方式与叙事距离自然向它靠拢；军事、政治与政务信息优先作为场景、信使/塘报、问答或文书等当时之人自然获知的方式进入叙事，而不是现代战略简报式的罗列。保持清晰可读，不机械堆砌章回套语或古语标签。

只命名一次 packet 指定的已知失败形态（modern strategy-dashboard），非黑名单；无输出协议/门禁/评分。

## 4. Implementation shape（frozen direction 落地）

```text
projector.project(setup, include_style)
  context_text         = 纯事实 Game/World/Player/Character 材料（不再含任何 style block）
  style_reference_text = 派生 request-only anchor：STYLE_BOUNDARY_HEADER + Primer + 正向 cue
                         （include_style=false → 恒为 ""；project_world_only() 不变，恒无 style）

narrative consumers 在自身 game_context 构造的**末尾**追加 anchor：
  start_first_opening            → 事实材料之后（assemble_first_opening_messages 前）
  assemble_continuation_messages → 事实 + materialized World Turn 之后
  _resolution_messages           → mechanics rules + Program authority 指令之后
  _ordinary_narrative_messages   → instruction/control reason 之后（no_check + degraded）
  _control_messages / control_recovery → 不调用 anchor（include_style=false，恒空）

G5-04 project_world_only()、G5-01 semantic analysis、Actor Knowledge：不接触 anchor（语义请求本就不含 Game-local context；R3 测试显式断言）。
```

无第二份 Primer 拷贝（anchor 是同一 durable section 的单一投影）；无持久化 style 派生物。

## 5. Focused proof（tests/mw005/叙事风格锚点显著性测试.gd — 81 PASS / 0 FAIL）

捕获**实际最终 request messages**（非 projector 返回值）：

1. ordinary continuation（含 materialized World Turn）：Primer 恰好一次、cue 恰好一次、boundary→Primer→cue 次序、anchor 晚于 world/Player/World-Turn 全部材料、anchor 之后零事实/mechanics 材料；
2. first opening：同上（anchor 晚于 world/Player 材料）；
3. resolution / no_check / degraded narrative：Primer 恰好一次 + cue 恰好一次；resolution anchor 晚于 "Materialized Expansion rules" 与 "Program 已决定本次结果"；
4. control / control_recovery：无 Primer、无 style token、无 boundary、无 cue；仍保留事实 World/Player 材料；
5. G5-04 `project_world_only()`：无任何 style 材料、无 anchor 字段内容；G5-01 semantic request：无 boundary/Primer/cue；
6. Source generation fingerprint 不变断言；三个 d20 行动 + 一个普通回合各自恰好一次 accepted（no reroll / no duplicate）；
7. R1 接线测试同步更新：`context_text` 不含 Primer/boundary；`style_reference_text` 恰好一次 + boundary + cue 次序；旧 Game（pre-MW-005 generation）`style_reference_text` 为空。

## 6. Regression matrix（Godot 4.7.2 headless，task-owned fresh roots）

```text
tests/mw005/叙事风格锚点显著性测试.gd     failures=0（81 断言）
tests/mw005/三国文风Primer接线测试.gd     failures=0
tests/mw005/公开D20控制文风排除测试.gd    failures=0（R2 合同不回归）
tests/g4_07a/首次开场运行时聚焦测试.gd    failures=0
tests/g4_08m1/公开D20机制测试.gd          failures=0
tests/g4_08m1/NO_CHECK行动幂等修复测试.gd failures=0
tests/mw006/机制锚定世界后果垂直测试.gd   failures=0
tests/mw007/机制后果时间线连续性测试.gd   failures=0
tests/g5_01/世界回合语义物化测试.gd       failures=0
tests/g5_01/世界回合时间线恢复测试.gd     failures=0
tests/g5_04/选择性世界演化评估测试.gd     failures=0
git diff --check                          clean
Windows export validation                 PASS（--export-release "Windows Desktop"）
Real Provider calls                       0
```

## 7. Remaining risks / notes for GPT

1. 本修正改变的是**表达材料的投放位置与正向引导强度**；能否达到 Owner 可感知的 prose 变化只能由 Owner UAT（新 Three Kingdoms Game）判定。若仍不可感知，按 packet §10：下一步应回头审视 Primer 内容本身（Primer v0.2 决策），而不是继续加 prompt 权重。
2. `_append_character` 的 style 收集路径保留（character-carried literary section 目前不存在）；control lane 对 character style 的排除沿用 IR2 A01 的"不做投机泛化"裁定——若未来出现 character-carried style，需要单独裁定。
3. cue 为中文固定 const（与 GM_INSTRUCTIONS 同语言域）；不影响任何非中文 Game 的既有行为（无 style section 时 anchor 恒为空，行为与 R2 完全一致）。
```
