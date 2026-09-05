# MW-005 Revision 4 — Bounded Narrative Style Weight Polish — Implementation Evidence

Status: **READY FOR INDEPENDENT REVIEW（候选）**
Implementer: Zcode + GLM-5.3-Flash（Owner weekend routing override）
Reviewer: GPT（IR#4）
Task Addendum: `docs/tasks/MW-005_REVISION4_BOUNDED_STYLE_WEIGHT_POLISH_ADDENDUM.md`
Task Branch: `mw-005-r4-bounded-style-weight`
Worktree: `D:/AI/Projects/.worktrees/my-world/mw-005-r4`

## 0. Worktree hygiene

```text
mw-010 worktree 已移除：MW-010 IR#2 ENGINEERING PASS / CLOSED 且已合入 main（a53318b）；
working tree clean；91f17a5 已 push 至 origin/mw-010-g5-living-world-integrated-reality-matrix；
无未知用户工作。git worktree remove + prune 后按规定创建 mw-005-r4 worktree。
```

## 1. Changed files

```text
src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd   # 唯一改动：STYLE_NARRATIVE_ANCHOR_CUE 措辞加权（含注释更新）
docs/mw005/MW-005_REVISION4_STYLE_WEIGHT_EVIDENCE.md
```

Primer bytes / Primer input / World section bytes / Source generation
`58966f73dfade50b0aa7536aad38a8840e614016975e8beba0735f7dd14ab443` 不变（focused 测试 fingerprint 断言）。无新示例/重复 style block/评分器/重试/章回强制/半文言规则/parser/协议/global platform；style placement 与 consumer routing 未动（R3 的 late-anchor 结构原样）。

## 2. R4 cue wording（唯一改动）

修正前（R3）："表达锚点：……是本局中文 GM 叙事的**默认声音锚点**。让句法节奏、称谓礼法、对白方式、信息传递方式与叙事距离自然向它靠拢；军事、政治与政务信息优先作为场景、信使/塘报、问答或文书……保持清晰可读，不机械堆砌章回套语或古语标签。"

修正后（R4，addendum §3 语义优先级的完整落实）：

> 表达锚点：当存在以上 Literary Style Reference 时，它不是可有可无的古代词汇点缀，而是本局中文 GM 叙事的主要表达偏好之一。在不牺牲清晰、自然与当前 Game 事实准确性的前提下，让整段叙事持续体现其句法节奏、人物称谓与礼法、人物说话方式与叙事距离，并让消息与军政信息经由人物、使者、塘报、文书、问答与场景进入故事，而不是现代战略简报式的罗列。当通用现代叙述习惯与参考语体发生冲突时，在保持长期可读的前提下优先参考语体；不要只把现代通用 RPG / 网文骨架换上几个古代名词。仍不要机械模仿章回套语、强行半文言或照抄范例。

加权要点：默认锚点 → 主要表达偏好之一；新增「不是可有可无的古代词汇点缀」「整段叙事持续体现」「现代叙述习惯与参考语体冲突时优先参考语体」「不要只换古代名词」；保留全部既有负面边界（章回套语/半文言/照抄）与「不牺牲清晰自然与事实准确性」前置条件。仍为单一有界 const cue（约 240 字），无新增示例、无黑名单、无协议。`表达锚点：` 前缀保留，消费者零改动。

## 3. Validation（packet §5 全项）

```text
tests/mw005/叙事风格锚点显著性测试.gd     failures=0（81 断言：ordinary continuation/Opening cue 恰一次且
                                          位于事实/World-Turn 材料之后；d20 resolution/NO_CHECK/degraded
                                          恰一次；control/control_recovery 无 Primer/boundary/cue；
                                          G5-01 semantic 与 G5-04 world-only 无 style；fingerprint 不变）
tests/mw005/三国文风Primer接线测试.gd     failures=0
tests/mw005/公开D20控制文风排除测试.gd    failures=0
tests/mw010/生界一体现实矩阵测试.gd       failures=0（44 断言；MW-010 R2 F01/F02 不回归）
tests/g4_08m1/公开D20机制测试.gd          failures=0
git diff --check                          clean
Windows export validation                 PASS（--export-release "Windows Desktop"）
Real Provider calls                       0
```

## 4. Remaining risks / notes

1. 文风加权是 prompt 措辞变化，效果只能由 combined G5 Owner product checkpoint 判定（本任务无独立 UAT，按 addendum §1/§5）。
2. 若 Owner 在 combined checkpoint 后认为权重仍不足或过头，下一步分别是 Primer 内容修订（Primer v0.2 决策）或回调本 cue 措辞——都是 MW-005 Revision lineage，不是新平台。
3. cue 长度约 240 字（R3 约 160 字），仍远小于 Primer 本体（~2.6k）；`MAX_CONTEXT_CHARS` 安全上限不变且断言覆盖。
