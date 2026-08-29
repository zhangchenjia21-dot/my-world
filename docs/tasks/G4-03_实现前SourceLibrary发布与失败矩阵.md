# G4-03 实现前 Source Library 发布与失败矩阵

Status: implementation input
Task: G4-03 Managed Local Source Library v0.1

## 1. 冻结的存储形状

Production 默认根为 `user://my-world/source-library`；自动化测试必须显式注入包含 `g4_03` 的 task-owned 根，生产根在测试中不可读写。

```text
<library-root>/
├─ generations/
│  ├─ world_pack/<asset_id>/<generation_fingerprint>/source.json + declared files
│  └─ character_card/<asset_id>/<generation_fingerprint>/source.json + declared files
├─ current/
│  ├─ world_pack/<asset_id>.json
│  └─ character_card/<asset_id>.json
└─ staging/<operation-id>/source.json + declared files
```

- G4-02 已约束 `asset_id` 为安全 ASCII identity；Library 仍只接受不含分隔符、`.` 或 `..` 的 ID，路径片段不能越界。
- generation identity 为 `asset_type + asset_id + version + generation_fingerprint`，物理目录按 type、ID、fingerprint 定址；`version` 是 metadata，不参与“最新”推断。
- current JSON 至少保存 `asset_type`、`asset_id`、`version`、`generation_fingerprint`、`display_name`。它是 current 的唯一 authority。
- inventory 不枚举 generation/staging 来猜 current；reload 只枚举 current JSON，并对其指向的 managed generation 运行 G4-02 production loader 与 fingerprint 校验。
- published generation 不提供删除、覆盖或 pruning。

## 2. 冻结的发布顺序

```text
validate explicit external package through G4-02 L3
→ derive contract-owned file list from returned public projection
→ copy source.json and declared files to same-root staging
→ revalidate staging through the same G4-02 L3
→ require staged fingerprint == external expected fingerprint
→ if final exists, revalidate it; otherwise atomically rename stage to final
→ write complete current JSON to sibling temporary file
→ atomically replace current JSON
→ reload/validate committed current and return
```

任何失败都返回明确 code/message。current 写入发生在 generation 可见之后；current 临时文件失败或替换失败不删除旧 current。发布 final 后 current 失败允许留下尚未 current 的有效 retained generation，重试必须安全收敛。

## 3. Case matrix

| Case | external / G4-02 结果 | staging / managed generation | current / inventory 与持久副作用 | 清理、重试、restart |
|---|---|---|---|---|
| A 第一次安装合法 World | 显式 World 目录；L3 成功并给出 fingerprint | 只复制 `source.json + authored_assets[].path`；stage 复验一致；原子发布 World generation | 原子创建 World current；inventory 出现一个 typed current | stage 删除/移动；相同根新实例可恢复并 exact lookup |
| B 第一次安装合法 Character | 显式 Character 目录；L3 成功 | 只复制 `source.json + portrait.path`；复验后发布 Character generation | 原子创建 Character current；与 World 类型分栏 | 行为同 A，restart 保持 Character metadata |
| C 重复 exact generation | L3 得到相同 type/ID/fingerprint | final 已存在时复验其内容，不复制第二份 | 若已 current，返回 `already_installed=true` 且不重写 current；若非 current，原子切回该 generation | 临时 stage 可清理；任意重试不增加 generation/inventory entry |
| D 同 identity 不同 generation | L3 成功，fingerprint 不同 | 新 fingerprint 新增目录，旧目录不覆盖 | 新 generation 成为 current；旧 generation 仍可 exact lookup | restart 从 current 恢复新 generation，显式 exact lookup 仍验证旧 generation |
| E 同 authored version 不同内容 | version 相同但 fingerprint 不同，视为合法新 generation | 与 D 相同，绝不以 version 合并/覆盖 | 最近一次成功提交的 fingerprint 成为 current | 不做 semver/latest 推断；重试按 exact fingerprint 收敛 |
| F 安装后 external 修改/删除 | 修改发生在成功提交后；external 不再参与读取 | managed bytes 与路径保持不变 | inventory/exact lookup 只读 managed generation，值不变 | restart 不依赖 external path；不自动同步或修复 |
| G invalid package / unsafe reference | G4-02 L3 失败，无 authoritative fingerprint | 不创建 stage/final | current/inventory 不变，无 durable Library 副作用 | 原样返回 contract failure；修复输入后显式重试 |
| H staging copy 中途失败 | 初次验证成功，复制未完成 | incomplete stage 不是 final | current/inventory 不变 | 尽力移除本次 stage；即使残留，reload 也忽略 staging；重试用新 operation |
| I staged fingerprint 不一致 | external 初验成功；stage 复验失败或 fingerprint 改变 | 不发布 stage，不触碰同名 final | current/inventory 不变 | 删除/忽略 stage并返回 `staged_fingerprint_mismatch`；重新读取明确 external 后重试 |
| J final generation 已存在 | external fingerprint 命中现有路径 | 必须用 G4-02 L3 复验 final 且 fingerprint 相同；损坏则 fail-loud，绝不覆盖 | 有效 final 可按明确 install intent 提交 current；损坏 final 不改变 current | 有效时 replay-safe；损坏时返回 invalid/tampered，不能用 external 静默修复 |
| K current metadata publish 失败 | generation 已完成验证并可见 | final 可作为 retained generation 留存 | 旧 current 文件和 inventory 仍有效；新 generation 不成为 current | 删除临时 current；重试复验 final 后原子提交 current；restart 仍看到旧 current |
| L restart / reload | 不访问 external | 对每个 current 指向的 final 运行 G4-02 L3 与 fingerprint 校验 | 从 current JSON 恢复相同 typed inventory；exact lookup按请求验证 | 任一 current invalid 时整体 fail-loud，不选择历史 generation |
| M managed current 被篡改/缺文件 | external 不参与 | G4-02 loader 失败或计算 fingerprint 与 current/path 不同 | list/current/exact lookup 返回明确 invalid，不接受目录名，不 fallback | 人工修复或重新建立可信库前持续失败；restart 同样失败 |
| N stale/incomplete staging | 与 current install 无关 | residue 仅位于 `staging`，不扫描为 generation | inventory 完全不出现 residue | reload 可忽略；task-owned cleanup 可移除，但不能将其 rename/publish |
| O test 与 Owner root 隔离 | tests 必须传入路径含 `g4_03` 的显式根 | 所有复制、fault、tamper、cleanup 仅发生于该根 | 不创建、枚举或修改 production 默认根 | 缺少合格 test root 时测试先失败；fixture cleanup 不越出 task root |

## 4. 失败注入边界

为确定性证明 K，仅保留显式 task-only fault `before_current_publish`：它在 final generation 已发布、current 临时文件写入前返回失败。普通产品调用不传 fault；该 seam 不扩展成通用 chaos framework。

## 5. 架构与范围结论

- Library 组件位于既有 `src/source/` 四层内；安装流程只通过 G4-02 `Source合同公开接口` 读取 package，不引用其 L0/L1/L2。
- Library 公开面仅提供 explicit install、current inventory、get current、get exact generation。
- 不需要 Game Library topology、Game pin、SQLite schema、chooser/Final Create、Expansion 或 Provider，故 G4-03 可以独立实施。
