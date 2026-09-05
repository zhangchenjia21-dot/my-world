# MW-006 Mechanics-Grounded World Consequence Vertical — Implementation Evidence

Status: **READY FOR INDEPENDENT REVIEW（候选）**
Implementation Owner: Zcode + GLM-5.3-Flash（Owner task-local routing override）
Reviewer: GPT
Implementation Base: `5809cf2`（origin/main at task start）
Branch / Worktree: `mw-006-mechanics-grounded-consequence` @ `D:/AI/Projects/my-world-mw006`

## 0. Governance note（must read）

- **MW-006 Task Packet（`docs/tasks/MW-006_MECHANICS_GROUNDED_WORLD_CONSEQUENCE_TASK.md`）在两个仓库的任何分支上都不存在**（fetch 后全量检索确认）。本实现严格以 Owner 会话指令中的范围 / 禁止项 / STOP 条件 / 证明清单为合同，未从聊天自行扩展范围。GPT Independent Review 前应裁定：补发 packet，或接受本会话指令为 task contract。
- `docs/g5_04/G5-04_CLOSEOUT.md` 同样不存在（G5-04 仍为 ACTIVE — OWNER UAT PAUSED FOR MW-005，与 `MY_WORLD_CURRENT_STATUS.md` v13.7 一致），已按 status 文件替代阅读。
- MW-005（Kimi）工作未触碰：主工作区 `D:/AI/Projects/my-world` 的 dirty 文件原样保留；本任务在独立 worktree 进行。

## 1. Changed files（全部改动）

```text
src/行动判定/L0_公理层/公开D20判定规则.gd        # +matching_accepted_check_for_turn / _normalize_durable_check（纯只读取回）
src/世界回合/L2_流程层/语义物化流程.gd           # ANALYSIS_INSTRUCTIONS 有界扩展 + _analysis_messages 追加 grounding block
tests/mw006/机制锚定世界后果垂直测试.gd          # 新增 focused 测试（20 断言）
docs/mw006/MW-006_MECHANICS_GROUNDED_CONSEQUENCE_EVIDENCE.md
```

无 UI、无 SQLite schema/table/migration、无新 Provider 路径、无 reroll、无第二套 mechanics truth、无 G5-04 直灌、无 MW-005 触碰。

## 2. Pass A — Producer / lifecycle audit（真实 seam，非文件名推断）

CHECK_REQUIRED 真实顺序（`src/行动判定/L2_流程层/公开D20行动判定流程.gd`）：

```text
start_action(action_id, player_text)
→ _start_provider("control")           # 结构化判定 envelope；action_id 由 Program 注入
→ Parser.parse（失败时唯一一次 control_recovery，再失败 degraded：无 check 持久化）
→ _roll_and_persist(proposal)          # validate/freeze 之后才触碰 RNG
   · check_id = check-SHA256(game_id + U+001F + action_id)
   · durable：world_state.expansion_runtime.public_d20_checks[]
   · commit_world_mutation_durably("public-d20-"+check_id, "node-"+check_id, …)  ← 先于任何 narrative
→ _start_provider("resolution_narrative")  # authority 注入："Program 已决定本次结果；不得重掷或改写"
→ _accept_narrative
   · complete_active_generation_durably()          # SQLite COMMIT
   · conversation.complete_generation()            # 同步 emit generation_completed
       → SemanticMaterializationProcess._on_generation_completed（同步入队）
       → _drain_queue 为 call_deferred
   · _mark_narrative_accepted(check_id, turn_index)  # accepted_turn_index marker durable CAS
                                                      # （在 deferred drain 之前同步完成）
→ deferred _drain_queue → _analysis_messages(...)   # 语义 request 装配点
```

NO_CHECK 真实顺序：control → `no_check_narrative` → `_freeze_no_check_resolution`（durable：`public_d20_no_check_actions[]`，`no-check-SHA256(game_id+U+001F+action_id)`）→ accept → `_mark_no_check_accepted`。**无骰面、无 check 记录**。

retry / reopen / Restore：`start_action` 先按 `action_id` 查 durable check / no-check（`narrative_accepted` → `already_accepted`；lost-ACK 窗口走 `_recover_acceptance_marker` / `_recover_no_check_acceptance`，只在 expected slot 的 Player/GM 精确匹配时补 marker）。**retry/restart 永不 reroll**（RNG 只在 freeze 后第一次触碰）。Restore 走 `restore_save_point`：durable switch → world_state/Conversation 原子替换；check 数据随 world snapshot 回到存档时点。

semantic wake 时序结论：
- 语义分析发起（deferred `_drain_queue`）时，durable check（含 `accepted_turn_index` marker）**已经** durable 存在 → 可按当前 turn 唯一取得。
- 一个 accepted Player action 恰好一个正常 semantic materialization opportunity：`generation_completed` → `_consider_entry(latest)` 一次；durable replay 信号（`matching_record` / `matching_knowledge_record` / `runtime_actor_ids_for_version` / `_attempted_versions`）保证 reopen/重放不重发。
- grounding 取回合同：`narrative_accepted == true` ∧ `accepted_turn_index == turn_index` ∧ `player_text` 精确相等；命中 0 个或 >1 个一律返回空 → 无 block（fail-soft，不伪造、不猜测）。

## 3. Pass B — Consumer / authority audit

- Public-d20 resolution 的全部 consumers：`公开D20行动判定流程.gd`（retry/replay + foreground resolution narrative authority）、`ui/叙事对话视图.gd`（投影）、既有 g4_08b/g4_08m1/g4_09uatbc01 测试。**无其它 production reader**（全仓 grep 证据）。
- G5-01 semantic context 的全部 consumers：`_analysis_messages`（唯一语义 request 装配点）与 `世界回合上下文投影器.gd`（GM Context：只投影 `living_world` 的 committed+hash-matching changes/knowledge/agency/evolution；**不读 `expansion_runtime`**）。
- Duplicate mechanics truth 风险：无 —— grounding 是 request 时只读派生文本，不持久化、不新增 summary store；durable truth 仍只有 `expansion_runtime.public_d20_checks[]` 一处。
- G5-04：`世界演化评估流程.gd` 未改动；其 baseline 仍为 `project_world_only(world_state)` + `living_world` recent blocks。mechanics 不直灌 evaluator；只有模型 authored 并经既有 semantic mutation 提交的 changes 才可能间接进入（既定 G5-01 路径）。
- Actor Knowledge：grounding 块不含任何 actor 知识授权语句；knowledge_events 仍受 roster/currentness/basis 校验约束（未改动）。
- MW-005 `literary_style_reference`：不接触。grounding 只来自 `expansion_runtime`；Source/World 包 semantic_sections 路径未动。
- mutable Source current：语义/d20 流程不读 SourceLibrary；grounding 只读 `session_runtime.world_state`（Game-local durable）。

## 4. Implementation shape（minimal vertical）

```text
existing authoritative CHECK_REQUIRED durable resolution
→ 公开D20判定规则.matching_accepted_check_for_turn(world_state, turn_index, player_text)   # 只读，0/1/>1 fail-soft
→ 语义物化流程._analysis_messages 附加有界 block：
   "Durable Mechanical Resolution (Program-owned authoritative truth)"
   - check_id/action_id/intent/dc/modifier/stance/raw_rolls/selected_roll/total/outcome/
     modifier_reason/situation_reason/success_intent/failure_stakes
   + 边界语句：权威不可改写/重掷；判定本身不是世界后果清单；仍只提取 accepted 叙事支持的 0..N 条
→ ANALYSIS_INSTRUCTIONS 同步一句有界扩展（尊重既定结果；无固定成功/失败映射）
→ 既有 normal G5-01 semantic opportunity → 模型仍 author 0..N durable consequences
   （同一 semantic mutation seam、同一 world_turn_id/mutation_id/node_id 身份合同）
```

NO_CHECK / 普通无 Expansion / degraded control / marker 缺失 / 数据歧义：不生成任何 mechanics block（程序化保证，非提示词约束）。

## 5. Focused proof（tests/mw006/机制锚定世界后果垂直测试.gd — 20/20 PASS）

- CHECK_REQUIRED durable resolution 在 semantic request 中出现且只出现一次（`count==1`）；携带 exact Program-owned facts（check_id/selected_roll/total/outcome）。
- deterministic fake semantic output 基于该 mechanics fact 经**既有单一 semantic mutation** materialize durable consequence；`expansion_runtime` deep-equal 不变；除 `living_world` 外无新 world schema family。
- NO_CHECK：无 fake mechanics block；语义路径本身不变（请求发出、正常提交）。
- 普通无 Expansion：无 block。
- same-version replay + reopen（fresh worker）：`already_materialized`，零重发、零 duplicate mutation（不 reroll）。
- malformed semantic result：accepted Narrative 保持 accepted；durable check 原样权威；无 fake world mutation。
- marker 缺失 / player_text 不一致（Restore 场景）/ 多重命中：一律无 grounding。

## 6. Regression（Godot 4.7.2 headless，task-owned roots）

```text
tests/mw006/机制锚定世界后果垂直测试.gd        PASS（failures=0）
tests/g4_08m1/公开D20机制测试.gd               PASS（failures=0）
tests/g4_08m1/NO_CHECK行动幂等修复测试.gd      PASS（failures=0）
tests/g5_01/世界回合语义物化测试.gd            PASS（failures=0）
tests/g5_02/已知角色知识溯源测试.gd            PASS（failures=0）
tests/g5_03/多角色行动代理循环测试.gd          PASS（failures=0）
tests/g5_04/选择性世界演化评估测试.gd          PASS（failures=0）
tests/g4_09uatbc01/叙事响应流式关键路径测试.gd PASS（failures=0）
tests/g3_04/会话恢复验证测试.gd                PASS
tests/g3_04/存档恢复持久化测试.gd              FAIL — PRE-EXISTING at base 5809cf2（baseline 复现）：
    断言 "raw World/persisted Context entered Provider messages" 因 MW-004 修改后的
    GM_INSTRUCTIONS 自身含有字面量 "Current Game Context" 而触发；与 MW-006 无关，
    未修复（超范围，涉及 MW-004 文本，留给 GPT/Owner 裁定）。
```

## 7. Export / hygiene / provider

- Windows export validation：`--export-release "Windows Desktop" build/windows/my-world.exe` 成功（my-world.exe + pck + libgdsqlite dll）。
- `git diff --check` clean。
- Real Provider calls：**0**（全部 stub/controlled adapter）。
- SQLite schema/table/migration：未触碰 persistence 层（代码 diff 证据）。

## 8. Remaining risks / notes for GPT

1. Task Packet 缺失（见 §0）——Independent Review 的正式合同基线需补齐。
2. grounding 的取回以 acceptance marker 为唯一权威链接；marker 写入失败的极端窗口（Conversation COMMIT 成功但 marker CAS 失败）下该 turn 无 grounding —— 有意 fail-soft，宁可缺失不可伪造。
3. 若同一 accepted turn 出现多个 durable check 匹配（理论 corrupt/legacy 数据），整块跳过 —— exact-once 优先于覆盖。
4. 预存 G3-04 测试断言失败需另行裁定（非本任务引入）。
