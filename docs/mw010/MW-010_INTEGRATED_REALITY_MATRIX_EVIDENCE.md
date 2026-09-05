# MW-010 G5 Living-World Integrated Reality Matrix — Implementation Evidence

Status: **READY FOR INDEPENDENT REVIEW（候选）**
Implementer: Zcode + GLM-5.3-Flash（Owner weekend routing override）
Reviewer: GPT
Task Packet: `docs/tasks/MW-010_G5_LIVING_WORLD_INTEGRATED_REALITY_MATRIX_TASK.md`
Canonical Architecture: `Vibe-Coding/my world/architecture/world/G5_WORLD_PRODUCT_TEST_MATRIX_V0_1_DECISION.md`（FROZEN / CURRENT @ 1019440）
Task Branch: `mw-010-g5-living-world-integrated-reality-matrix`
Worktree: `D:/AI/Projects/.worktrees/my-world/mw-010`

## 0. Hygiene / diff status

```text
mw-009 worktree 已移除（IR 已过并合入 main；clean；c2805e8 已 push 可达；无未知用户工作）；
git worktree remove + prune 后按规定创建 mw-010 worktree。
production code diff = 0（唯一改动：tests/mw010/ + 本证据文档）。
SQLite schema/table set：unchanged（零 production diff 即证明；matrix 运行使用既有 v4 schema）。
Windows export validation：未执行（packet §9——production 代码无变化时可选）。
Real Provider calls：0（opening/d20/semantic/selector/actor/evolution 全部确定性 stub）。
git diff --check：clean。
```

## 1. Pass A — production composition/lifecycle audit（真实函数/信号）

```text
accepted Narrative
→ conversation.complete_generation() 同步 emit generation_completed
  → SemanticMaterializationProcess._on_generation_completed → _consider_entry（durable
    world_turn_id/mutation_id 身份；durable replay 信号防重发）→ deferred _drain_queue
→ semantic commit（commit_world_mutation_durably，CAS head）→ WorldTurn.finished
  → Shell._on_world_turn_finished_for_scheduler（player-safe 面板刷新 + AgencyScheduler.consider_agency）
→ AgencyScheduler._start_selector（消费 dirty；冻结 source turn/hash/head snapshot；
  test_selector_adapter_override；终态后 queue_free override adapter —— 测试必须每次机会注入新 stub）
→ selector validate（stable_npc_records roster、cap 4、Player 不可选）→ AgencyCycleRuntimeProcess.start_cycle
  → per-actor test_actor_adapter_factory.call() → act JSON → Rules.build_agency_action → durable cycle commit
  → cycle_finished → opportunity_finished（frozen turn/hash）
→ WorldEvolutionEvaluatorProcess.consider_opportunity（latest/hash/semantic-idle/foreground 校验；
  durable replay 信号；hold 为一等正确结果）→ advance → world_evolution_events_by_turn commit
→ 后续 GM Context：世界回合上下文投影器（current-hash matching 的 changes/knowledge/agency/evolution 四族）
→ Player-safe：PlayerSafeProjection.project_session（白名单 + current-hash + knower==player 过滤）
Public-d20：view send → Adjudication.start_action → control → freeze→RNG→durable check →
  resolution narrative → accept → marker（accepted_turn_index）→ MW-006 grounding（deferred drain 前
  同步 durable）→ semantic consequence。
Save/close/reopen：create_save_point 锚定 head；reopen 读 current head 的 world snapshot + conversation。
Restore：restore_save_point 单事务从 anchor node 的 world snapshot 整体回滚 World（含全部
  living_world/expansion_runtime family）+ Conversation，同事务 recovery capture。
```

## 2. Pass B — cross-capability authority/currentness matrix

| Truth family | Durable owner | Currentness key | GM consumer | Actor-private | Player-safe | Restore 行为 |
|---|---|---|---|---|---|---|
| semantic consequences | living_world.semantic_turns_by_index（World snapshot） | source_turn_index + source_gm_sha256 | 上下文投影器 ✓ | — | ✗（测试 C 证明） | 随 world snapshot 回滚（B 证明） |
| Knowledge Provenance | living_world.knowledge_turns_by_index | 同上 + knower_id | 上下文投影器（软引导） | knower actor | 仅 knower==player（MW-009） | 随 snapshot 回滚（B 证明） |
| stable/actor identity | guaranteed_npcs / stable_npcs（setup + runtime ingress） | origin turn/hash（runtime 类） | roster/context | — | 仅安全身份 | 随 snapshot |
| Agency actions | living_world.agency_cycles_by_source_turn | source turn/hash + cycle identity | 上下文投影器 ✓（omniscient） | actor 自身 | ✗（测试 2/5 证明） | 随 snapshot 回滚 |
| World Evolution events | living_world.world_evolution_events_by_turn | opportunity turn/hash + base head | 上下文投影器 ✓（omniscient） | — | ✗（测试 2/5 证明） | 随 snapshot 回滚 |
| Public-d20 resolution + grounded consequence | expansion_runtime.public_d20_checks + semantic family | check_id（game+action_id）+ accepted_turn_index | narrative authority + 上下文投影器 | — | 仅 narrative/知识面（D 证明） | 随 snapshot（MW-007 已证；B 组合中保持 current） |
| player-safe projection | 无 durable owner（request-time 派生） | current accepted hashes | — | — | UI 面板 | 随 current 状态即时重建（B 证明） |

无任何 family 需要新 owner；矩阵完全用既有生产 owner 表达。

## 3. Scenario topology（tests/mw010/生界一体现实矩阵测试.gd — 33 断言 0 失败）

单个真实 durable Game（real FinalCreate：汉末三国/天下未定 t0-208 + 刘备 + 孙权 guaranteed + 公开d20 Expansion）
+ real Shell（语义/agency/evolution/adjudication/opening 全部确定性 stub）+ real SQLite：

```text
T1（场景 A-hold）：NO_CHECK 普通回合 → semantic consequence → selector {"actors":[]} →
   evolution hold ⇒ 无 agency cycle、无 evolution event —— 安静是合法结果（不每回合强制升级）
T2（场景 A-advance + C）：普通回合（仅调度机会）→ selector 选孙权 → actor act（"孙权密令水军连夜
   加固船阵"，玩家未选择该行动）→ durable agency cycle → evolution advance（"江面大雾…"）→ durable event
   ⇒ GM Context 含两者（omniscient current world reference）；player-safe 面板两者皆不显示
T3（场景 D）：风险行动 → CHECK_REQUIRED → Program RNG [6]（总 7 失败）先于 narrative durable →
   MW-006 grounding 恰一次进入正常语义机会（outcome/total 断言）→ 语义提交与 mechanics 一致的后果 +
   主角 witnessed 知识 ⇒ 面板出现该知识（仅因真实 Player knowledge）；无 hardcoded 成败映射
E（reopen）：close → reopen ⇒ 六 family + projection + head deep-equal 重建；同 action_id 重新提交
   → already_accepted、零 Provider/零 RNG（no reroll）
B（counterfactual）：Save S → Path A（不同 Narrative → 不同 semantic consequence + 主角知识，
   context/panel 均可见）→ Restore S → Path A 从 durable current、GM Context、面板全部消失；
   pre-S 的 agency/evolution/d20/consequence 保持 current（currentness 而非删除）→ Path B 建立
   自身 current truth（context/记录），Path A 不再回流
12/13：world_state 无任何第二 truth store key；schema 由零 production diff 证明不变
```

## 4. Regression matrix（Godot 4.7.2 headless，task-owned fresh roots）

```text
tests/mw010/生界一体现实矩阵测试.gd        failures=0（33 断言）
tests/mw009/玩家安全侧栏投影测试.gd        failures=0
tests/mw008/安全轻量渲染测试.gd            failures=0（Shell 被 matrix 使用）
tests/mw007/机制后果时间线连续性测试.gd    failures=0
tests/mw006/机制锚定世界后果垂直测试.gd    failures=0
tests/g5_01/世界回合语义物化测试.gd        failures=0
tests/g5_01/世界回合时间线恢复测试.gd      failures=0
tests/g5_02/已知角色知识溯源测试.gd        failures=0
tests/g5_03/多角色行动代理循环测试.gd      failures=0
tests/g5_04/选择性世界演化评估测试.gd      failures=0
tests/g4_08m1/公开D20机制测试.gd           failures=0（no-reroll/reopen 覆盖）
tests/g4_08m1/NO_CHECK行动幂等修复测试.gd  failures=0
tests/g3_04/会话恢复验证测试.gd            failures=0
tests/g3_04/存档读取界面测试.gd            failures=0
git diff --check                           clean
```

## 5. Discovered prior-capability blockers

**无。** 全部五个场景在既有 closed capabilities 组合下通过；未发现需要 STOP 报告的真实
production defect。开发期遇到的两个测试侧问题（Agency scheduler 终态后 queue_free 其
test adapter override——测试须每机会注入新 stub；GDScript 同作用域不可重复声明）均为
测试编写问题，不是 production 缺陷，production diff 保持为 0。

## 6. Remaining risks / notes for GPT

1. 本矩阵的 Agency/Evolution 行为由确定性 stub 驱动（canonical decision 允许）；真实模型
   在 selector/actor/evaluator 的判断质量属于 Owner combined UAT（decision §7），非本任务范围。
2. Matrix 依赖 Agency scheduler 的测试 seam 语义（override adapter 在终态后被释放）——这是
   既有 lifecycle 设计；若未来测试需要跨机会复用 adapter，需要单独的 seam 修订，本任务未改。
3. counterfactual 场景刻意未触碰 MW-007 已知 advisory（restored-away action_id 重放冲突），
   按 packet 要求排除。
4. `MW-005 R4 style-weight polish` 已排队为独立任务（af0b8cd），未在本矩阵混入。
