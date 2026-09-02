# G4-09R1B1 — Model Settings UI State / Failure Matrix

Status: **FROZEN — implementation authority for G4-09R1B1 UI glue**
Parent packet: `docs/tasks/G4-09R1B1_MODEL_SETTINGS_UI_TASK.md`
Backend authority: `docs/g4_09r1/G4-09R1M1C01_INDEPENDENT_REVIEW.md` + `src/运行时设置/L3_外交层/模型运行时设置公开接口.gd`
Canonical decision: `Vibe-Coding/my world/architecture/foundation/G4_RUNTIME_MODEL_SETTINGS_V0_1_DECISION.md`

本矩阵在任何 production 修改之前冻结：设置 UI 的状态词汇、inspect_candidate 消费形状、
失败/凭证/持久化语义。backend 政策不在此复制。

---

## 1. UI 状态词汇

```text
MenuReady                 Main Menu 正常态；新增「模型设置」入口
SettingsOpen              设置面板可见；已加载 persisted validated selection
SettingsEditing           玩家改了候选（未保存）；inspect_candidate 只读投影刷新
SettingsInvalid           backend inspect 拒绝当前候选（如 K2.7 + 1M）→ 禁 Save，玩家可读说明
SettingsUnsavedWarning    候选所选 provider 凭证未配置 → 可保存但显示「生成将失败」警告
SettingsSaving            Save 进行中（同步调用，防御性状态）
SettingsSaved             保存成功 → 回 Main Menu；重开展示 saved values
SettingsPersistedInvalid  load_settings 报告 invalid/corrupt → 可恢复玩家可读状态 + 引导重存
```

## 2. inspect_candidate 消费形状（UI 唯一真相来源）

```text
inspect_candidate({profile_id, context_limit, reasoning_request}) →
  success: candidate{
    display_name          → 模型行标题
    provider_id           → 凭证状态行归属
    context_limit         → 当前选中上下文
    allowed_context_limits → 上下文可选集（K2.7 = ["256k"]）
    reasoning_requested   → 当前选中思考强度
    reasoning_effective   → null（K2.7）或 low/high/max；medium → high 披露
    graded_reasoning      → 思考强度控件是否可选
    fixed_thinking        → K2.7 固定思考说明
    credential_configured → 选中 provider 凭证警告
  }
  failure: status=incompatible_context_limit / unknown_* → SettingsInvalid，禁 Save
```

UI **不**自行推导：endpoint / model_id / request payload / 兼容性 / requested→effective 映射。

## 3. 案例矩阵（对应 packet §10 必需断言 1–14）

| # | 案例 | 期望 |
| --- | --- | --- |
| S1 | Main Menu 有「模型设置」，打开/关闭正确 | 面板显隐 + Cancel 无副作用 |
| S2 | 四个精确模型名可见 | DeepSeek V4 Pro / V4 Flash / Kimi K3 / Kimi K2.7 |
| S3 | save/cancel 行为 | Cancel 不写文件；Save 调 backend 持久化 |
| S4 | 重开/重启反映 persisted 选择 | save → 关面板 → 重开 = saved values；新进程同样 |
| S5 | K2.7 从 backend 投影禁 1M | allowed_context_limits = ["256k"]；1M 不可选/选则 Invalid |
| S6 | K2.7 固定思考 UX | 思考强度控件禁用 + 「固定思考」说明；reasoning_effective = null |
| S7 | Medium→High 披露 | DeepSeek/K3 选 Medium 时摘要显示「实际 High」 |
| S8 | 凭证状态无秘密 | DeepSeek/Kimi 已配置/未配置；不显示 key 值 |
| S9 | 非法组合不可保存 | K2.7+1M 等 → Save 禁用 |
| S10 | 设置不改 Game/Source | save 前后 Game DB / Source Library sentinel 不变 |
| S11 | 设置后 Continue/New Game 可用 | 回 Main Menu 后两路径正常 |
| S12 | G4-08B Public d20 UI 在 backend 选定 profile 下正常 | d20 路由/卡/重试回归 |
| S13 | 1280×720 / 960×540 / maximized 可用 | 面板不超视口、文案换行 |
| S14 | git diff --check | 干净 |

## 4. UI 不变量（INV-SET-01..08）

- **INV-SET-01 设置只进 Main Menu**：无游戏内抽屉/热键。
- **INV-SET-02 预览只用 inspect_candidate**：未保存候选绝不写文件、不复制 backend 政策。
- **INV-SET-03 非法候选禁 Save**：backend 拒绝即禁保存，不做 UI 侧二次猜测。
- **INV-SET-04 凭证只显示布尔**：DeepSeek/Kimi 已配置/未配置；key 值不进任何 UI 节点。
- **INV-SET-05 缺失凭证可保存但警告**：backend 允许保存时，UI 显示「配置前生成将失败」；不发明 fallback。
- **INV-SET-06 K2.7 固定思考可见**：思考强度控件禁用 + 说明文案；不伪造 graded effective。
- **INV-SET-07 Medium 必披露实际 High**：摘要写「Medium（实际 High）」。
- **INV-SET-08 设置不写 Game/Source**：持久化只触 `provider-runtime.json`。

## 5. 粘接决策（提请 GPT Independent Review 注意）

1. **设置面板是 main.tscn 的常驻隐藏面板**（与 StartupFailureOverlay 同层），Shell 控制显隐；
   不新增场景文件，保持 shell 视觉语言。
2. **backend 接口实例化**：Shell 用 `ModelRuntimeSettingsPublicInterface.new()`（默认路径）；
   测试用 `MY_WORLD_TEST_SETTINGS_PATH` env + `--settings-path=` 注入 task-owned 路径
   （与既有 test-root 约定一致；接口本身已支持 `path_override`）。
3. **设置变更生效时机**：Provider adapter 每次请求经 `request_snapshot()` 读当前持久化设置——
   保存后下一次生成即生效，无需重启，也无需通知活跃请求（active request 冻结 profile）。
4. **invalid persisted 恢复**：load 失败时面板显示可恢复状态 + 当前候选项回落到冻结默认
   （仅作编辑起点，不静默保存）；玩家显式 Save 后才覆盖。

## 6. 回归地板

- G4-07B 可玩界面整合（61 PASS）；G4-08B 公开D20界面整合（96 PASS）；
- G4-08M1/M1C01；G4-09R1M1 机制测试；G4-05/06/07A；G2/G3/G4-01/G4-04；
- `git diff --check` 干净；证据零 secret。
