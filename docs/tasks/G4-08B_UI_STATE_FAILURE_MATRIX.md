# G4-08B — Public d20 UI State / Failure Matrix

Status: **FROZEN — implementation authority for G4-08B UI glue**
Parent packet: `docs/tasks/G4-08B_PUBLIC_D20_UI_INTEGRATION_TASK.md`
Formal Code Base: `d646427dfe3c4c6328809384e482cd1fdd2204a0`
Mechanism authority: `docs/g4_08m1/G4-08M1_INDEPENDENT_REVIEW.md` + `G4-08M1C01_INDEPENDENT_REVIEW.md` + `src/行动判定/L3_外交层/行动判定公开接口.gd`

本矩阵在任何 production 修改之前冻结。它把 G4-08B 的 UI 状态词汇、action identity 生命周期、
失败/取消/重开语义写成可测试的案例清单；backend 机制语义不在此重开。

---

## 1. UI 状态词汇（新增于 G4-07B 词汇之上）

```text
WizardExpansionChoosing   拓展步：展示 installed Expansion generations，0..N 显式选择
WizardExpansionNone       拓展步：explicit none 已确认（等价既有 confirm_expansion_none）
Reviewing / Creating / CreateFailed / CreateSucceeded   （沿用 G4-07B，Expansion 进入 frozen payload）

OpeningPending / OpeningStreaming / OpeningFailed / OpeningCancelled
                          （沿用 G4-07B；与 Expansion 无关）

Idle                      Public d20 Game：无 active adjudication，输入可写
Adjudicating              Host 已受理 stable action；第一次 Provider 判定进行中
Narrating                 CHECK_REQUIRED 已 durable（掷骰完成），resolution_narrative streaming；
                          transient mechanic 结果已公开
ActionFailed              durable resolution 存在但 narrative 未 accepted → 只允许同 action_id 重试
ActionFailedPreResolution 判定未完成/无 durable resolution → 允许编辑替换（新 action_id）或同 id 重试
UnresolvedOnReopen        绑定已存在 Game 时发现恰好一个 narrative_accepted=false 的 durable action
                          → 锁输入 + 「上一次行动尚未完成」+「重试行动」
Playing                   （沿用 G4-07B）
```

状态机不变量：**UI 不拥有判定真相**；Adjudicating/Narrating/ActionFailed 只是 Host `finished`
结果的投影，任何终态后 UI 从 durable `world_state.expansion_runtime` 重建。

## 2. Host 调用形状（冻结的 UI 契约）

```text
start_action(action_id, player_text) 返回：
  streaming{stage=adjudication}           → Adjudicating
  streaming{stage=resolution_narrative}   → Narrating（durable check 已存在，立即渲染 transient 结果）
  accepted{check|resolution}              → 终态 accepted
  already_accepted{check|resolution}      → 终态幂等
  failure{code=cancelled|transport|...}   → ActionFailed / ActionFailedPreResolution
  failure{code=capability_absent}         → 结构性错误（UI 只在 materialized capability 存在时才路由）

retry/cancel 语义由 M1/M1C01 拥有：
  同 action_id + 同 text + durable check 未 accepted → 直接进 resolution_narrative（不重掷、不再判定）
  同 action_id + 同 text + durable NO_CHECK 未 accepted → 直接 accept frozen narrative（零 Provider 调用）
  同 action_id + 不同 text → action_payload_conflict（UI 必须为改过的文本铸新 action_id）
```

## 3. 案例矩阵（A–R 对应 packet Evidence A–J）

| # | 案例 | 前置 | 玩家动作 | 期望 UI 终态 | 关键不变量 |
| --- | --- | --- | --- | --- | --- |
| A1 | Wizard 展示 Expansion | Library 含 Public d20 | 进入拓展步 | 展示名称/版本/简介，未选中 | 无 auto-select |
| A2 | 显式 none | 同上 | 确认「本局不使用拓展」 | step 完成可前进 | `confirm_expansion_none()` 权威 |
| A3 | 选择 Public d20 | 同上 | toggle 选中 | step 完成；往返保留选择 | `set_expansion()` 权威 |
| A4 | Review 投影 | A3 | 到 Review | 显示 `• 判定与检定：公开 d20（0.1.0）` | 无 fingerprint |
| A5 | Review none 投影 | A2 | 到 Review | 显示 `拓展\n无` | 诚实 |
| A6 | Final Create payload | A3 | 创建 | frozen snapshot 含 exact identity | 走既有 G4-06 |
| B1 | slot 冲突 | Library 另装 task-only 冲突 Expansion | 选中两个同 slot | backend 拒绝 + toggle 回滚 + 玩家可读失败 | UI 不留下双选 |
| C1 | 无 Expansion 回归 | none Game | 玩家行动 | 走 G4-07 单次续玩 | 无 adjudication 调用、无卡 |
| D1 | 受检行动 | d20 Game | 风险行动 | 单 stable action_id；Narrating 期间 transient 卡先于 narrative 完成出现 | UI 不重算 |
| D2 | accepted 卡 | D1 完成 | — | 历史中 Player 与 GM 之间渲染 exact durable 卡 | 只读投影 |
| E1 | NO_CHECK | d20 Game | 普通行动 | 一次 Provider 调用、零 RNG、无骰卡、accepted 恰一次 | 同普通叙事 |
| F1 | 败检后 narrative 失败 | durable losing check | Provider failed | ActionFailed：仅「重试行动」，同 action_id/text | 不重掷 |
| F2 | F1 重试 | F1 | 点「重试行动」 | 直接 resolution_narrative，零判定零 RNG，accepted 恰一次 | M1 no-reroll |
| F3 | 判定期失败 | 无 durable resolution | Provider failed | ActionFailedPreResolution：可编辑替换；新文本铸新 action_id | 不泄露旧 id 语义 |
| F4 | 取消 | Adjudicating/Narrating | 取消 | 同 F1/F3 按 durable 状态归类 | Host cancel |
| G1 | 重开未完成行动 | durable losing check 未 accepted | 关闭→重开 | UnresolvedOnReopen：锁输入 + 「上一次行动尚未完成」+「重试行动」 | 不静默遗忘 |
| G2 | G1 重试 | G1 | 点重试 | 同 F2；accepted 后解锁 | 无额外判定 |
| G3 | 多重未完成（防御） | 构造 >1 unresolved | 重开 | 显式失败态，不猜顺序 | fail visibly |
| H1 | Continue 卡重建 | accepted check | 返回主菜单→Continue | 卡随 durable 重建，数值精确 | 非 widget 记忆 |
| H2 | Load 移除未来卡 | 有 Save 在 check 前 | Load 旧 Save | 未来卡消失 | 与 restored future 一致 |
| H3 | Load 后继续 | H2 | 新行动 | 用 restored canonical reality | — |
| I1 | 真实 Provider 垂直 | d20 Game | 风险→普通行动 | CHECK_REQUIRED 公开展示 + 后续 NO_CHECK 无卡 | 不强制每次掷骰 |
| J1 | 回归 | — | — | G4-07B/M1/M1C01 等全绿 | 见 §6 |

## 4. UI 不变量（INV-D20-01..10）

- **INV-D20-01 能力路由只读 Game-local**：`world_state.expansions[]` 中 `capability_slot == action_resolution` 且 `capability_id == action_check.public_d20.v1` 才路由 Host；永不读 `SourceLibrary.current`。
- **INV-D20-02 action_id 由 UI 铸造一次**：`action-<128bit hex>`，与文本解耦；失败/取消/重开重试必须复用；只有玩家编辑文本才铸新 id。
- **INV-D20-03 UI 不先调 `conversation.begin_turn()`**：d20 路由下 acceptance ordering 归 Host。
- **INV-D20-04 无 Expansion 完全走 G4-07 路径**：不插入 adjudication JSON、骰状态或机制 UI。
- **INV-D20-05 卡是只读投影**：值逐字段来自 durable check；UI 不掷、不选骰、不算 total、不改 DC/outcome。
- **INV-D20-06 transient 先行**：`resolution_narrative` stage 开始即展示 durable 结果，不等 narrative 完成。
- **INV-D20-07 NO_CHECK 无骰卡**：普通行动看起来就是普通叙事。
- **INV-D20-08 d20 会话无旧式 Regenerate**：accepted d20 turn 不出现 G2 generic regenerate；失败只有「重试行动」。无 Expansion 保留既有 regenerate/retry。
- **INV-D20-09 重开恢复不猜顺序**：恰好一个 unresolved → 门控 + 重试；>1 → 显式失败。
- **INV-D20-10 历史卡不进 Provider Context**：卡重建只读 durable，不向 request 注入 check log。

## 5. 粘接决策（提请 GPT Independent Review 注意）

1. **能力检测在 Shell 激活时执行一次**并注入 Narrative 视图（`bind_action_adjudication(host)` / 无 host 即 null）；
   与 G4-07B 的 opening runtime 挂载并列。不新增 production 配置面。
2. **测试 seam 复用 G4-07B 形状**：`shell.test_adjudication_adapter_override` + `test_adjudication_rng_override`
   （production 恒 null）；测试注入 deterministic RNG 证明 UI 不重算。
3. **transient 卡与历史卡同源**：两者都从 `world_state.expansion_runtime.public_d20_checks` 的
   durable record 投影；transient 仅在 Narrating 期间额外高亮，accepted 后由 durable 重建接管。
4. **UnresolvedOnReopen 的投影边界**：UI 只读 `narrative_accepted == false` 的记录数与
   action_id/player_text；不读取、不修改其它字段。
5. **玩家可读失败码映射**：`action_payload_conflict` / `durable_action_identity_conflict` /
   `capability_absent` / `unknown_capability` 映射为普通中文提示；原始 code 不进 UI 文本。

## 6. 回归地板（J1 明细）

- `tests/g4_07b/可玩界面整合测试.gd` 61 PASS 保持；
- `tests/g4_08m1/公开D20机制测试.gd` + `NO_CHECK行动幂等修复测试.gd` 0 FAIL 保持；
- G4-05 Wizard 套件（拓展步断言需随真实库存更新）、G4-06、G4-07A、G2/G3/G4-01/G4-04 保持；
- `git diff --check` 干净；证据零 secret。
