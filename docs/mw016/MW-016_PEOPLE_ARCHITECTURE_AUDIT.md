# MW-016｜People Surface Architecture Audit

Status: **READY FOR GPT ARCHITECTURE DECISION**
Type: architecture audit / documentation only
Executor: Codex
Production changes / People UI / real Provider calls: **none**

## 1. 基线、权限与结论

本报告审查的 implementation main：`c3c4c54bb32d9d3a57f4f309b6d26cda8c176bf9`。
本报告审查的 governance main：`9641a7cf2623c6efbabff7c8c0cac5d6e88e57bf`。
Task：`docs/tasks/MW-016_PEOPLE_SURFACE_ARCHITECTURE_AUDIT_TASK.md`。
Branch：`mw-016-people-surface-architecture-audit`。
Worktree：`D:/AI/Projects/.worktrees/my-world/mw-016-audit`。

已读取两库最新 main 的 AGENTS、当前 Status、People v1.0 decision、Information Curation authority、Stable Actor Registry v0.2、Knowledge Provenance v0.1、Player-safe Runtime UI Projection v0.1。以下源码位置均相对于上述 implementation main；治理文件位于 Vibe-Coding 的 `my world/architecture/`：

- `ui/G6_PEOPLE_SURFACE_V1_0_DECISION.md`
- `ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`
- `world/G5_STABLE_ACTOR_REGISTRY_AND_MATERIALIZATION_V0_2_DECISION.md`
- `world/G5_KNOWLEDGE_PROVENANCE_V0_1_DECISION.md`
- `world/G5_PLAYER_SAFE_RUNTIME_UI_PROJECTION_V0_1_DECISION.md`

**结论：现有 stable identity 和 Timeline storage 可复用，但尚无安全、精确的 accepted-person → stable-ID 桥，也没有保证先物化、后整理的调度契约。不能直接向现有 curator 增加姓名列表就开始 People UI。** 推荐先批准并实现一个窄的身份绑定回执与顺序屏障，再扩展现有一次 Information Curator；People latest-known 内容仍归 `information_curation`，不写回 NPC truth。

该建议涉及 G5 semantic lane 的窄契约扩展，需要 GPT 正式裁定；本报告不将其视为已授权实现。Owner checkout 存在既有 dirty work，本轮未同步、清理或安装该 checkout；独立 worktree 用于报告。

## 2. 当前实现事实与证据

| 事实 | 精确源码位置 / 函数 | 对 People 的意义 |
|---|---|---|
| stable registry 合并 Guaranteed 与 stable_npcs，按 local ID 去重；runtime origin 需匹配 accepted GM hash | `src/世界回合/L0_公理层/世界回合规则.gd:115` `stable_npc_records` | 有 Program-owned 身份，但记录是原始材料，不能作为安全 DTO |
| 原始 material helper 返回 source_projection / game_local_material | 同文件 `:143` `stable_actor_material` | 不是玩家披露边界 |
| roster 是 local ID → name，包含 Player；无披露筛选或有界候选契约 | 同文件 `:155` `actor_roster` | 同名合法；全 roster 不能交给 People curator |
| runtime ID 由 Game、turn、GM hash、规范化 ordinal、name/profile 材料共同生成 | 同文件 `:183` `runtime_actor_identities`，`:193` `build_runtime_actor_record` | 姓名参与材料哈希不等于姓名匹配；模型没有铸造 authoritative ID 的权力 |
| Knowledge 是 knower_id、fact、basis | 同文件 `:242` `knowledge_event_is_valid`，`:285` `build_knowledge_record` | knower 是知情者，不是 fact 所描述的 NPC；不能据此精确归卡 |
| 新 actor 字段独立 fail-soft，跳过无效项、材料完全相同去重、最多 8 项 | `src/世界回合/L1_器件层/语义变更响应解析器.gd:55` `parse_new_actor_candidates` | 原始候选数组索引会因规范化位移；未来 binding 不能简单 zip |
| semantic worker 和 curator 独立监听 accepted，独立队列/Provider | `src/世界回合/L2_流程层/语义物化流程.gd:27` `_init`、`:72` `_on_generation_completed`；`src/信息整理/L2_流程层/回合信息整理流程.gd:47` `_ready`、`:88` `_on_accepted` | 当前无 happens-before 保证 |
| Shell 先创建 curator，后创建 semantic worker；semantic finished 主要触发刷新/Agency | `src/应用壳.gd:553` `_prepare_world_turn_after_activation`、`:577` `_on_world_turn_finished_for_scheduler` | 实例创建顺序不能证明 actor ID 已可用 |
| semantic prompt 只列所有 roster name/ID，再给 accepted 文本；使用当前整体 accepted roster | `src/世界回合/L2_流程层/语义物化流程.gd:140` `_analysis_messages` | 内部 semantic 已见 registry name，但没有面向 People 的安全引用输出；backlog 还需 as-of prefix 限制 |
| 模型返回后才生成新 actor ID，与 changes/knowledge 原子提交 | 同文件 `:200` `_on_completed`，尤其 `:231`、`:245`、`:262` | 同次请求中的新候选 ID 尚不存在；知识 allowlist 验证还发生在新 actor mint 前 |
| finished 返回计数，不返回 bindings；部分结果缺 hash；already_attempted 也发布结果 | 同文件 `:81` `_consider_entry`、`:310` `_finish_active`、`:320` `_publish` | finished 不是完整 durable terminal receipt |
| semantic 当前有效性只核验单个 GM hash；无本地超时 Timer、无 Restore epoch listener | 同文件 `:291` `_accepted_version_still_current`；Shell `:1200` `_on_restore_completed` | 不能直接把所有 curation 永久挂在这个信号后；需取消、终态和完整版本约束 |
| curator 当前输入只有安全 Player profile、accepted Player/GM、此前 Character/经历 | `src/信息整理/L2_流程层/回合信息整理流程.gd:107` `_pump` | 无 NPC safe identity seam，也无 People 既有快照 |
| curator 已有 timeout、Restore epoch、完整前缀/parent 校验和最新 World 合并提交 | 同文件 `:92` `_on_restore`、`:143` `_pump` 内的请求边界、`:162` `_on_completed` | 可复用一次调用及 durable lane；新增依赖仍需显式验证 |
| curation schema/result/record 均 exact-key；记录 ID 哈希包括规范化 result | `src/信息整理/L0_公理层/信息整理契约.gd:19` `normalize`、`:50` `prefix_hashes`、`:58` `record_id`、`:61` `current_records`、`:82` `owner_valid` | 无兼容设计地加默认字段会使旧 ID/parent 链失效 |
| 现有 projection 从有效记录折叠 Character、经历 | `src/信息整理/L1_器件层/角色经历投影器.gd:7` `project`；L3 `角色经历投影公开接口.gd` | 可新增同模块 People 安全 L3，不需 generic Surface framework |
| 泛用玩家投影只返回当前 Player 已知的最近 8 条去重事实文本 | `src/玩家安全投影/L1_器件层/玩家安全投影器.gd:33` `project`、`:62` `_current_player_facts` | 既无 subject ID，也不是完整人物记忆；不能用来重建 People |
| accepted 信号在 durable completion 后发出，World mutation 先 CAS 后发布 | `src/runtime/当前游戏会话运行时.gd:128` `complete_active_generation_durably`、`:157` `commit_world_mutation_durably` | 可在同一现有 World snapshot 中保存新增 owner 数据 |
| Save 同时保存 World head 与 Conversation checkpoint，Restore 原子切换二者 | `src/persistence/L2_流程层/世界持久化流程.gd:137` `create_save_point`、`:218` `restore`、`:390` `commit_world_mutation` | 无需新 SQLite 表 |
| Restore 完成后先替换 World/accepted，再发 restore_completed | `src/runtime/当前游戏会话运行时.gd:224` `restore_save_point`、`:284` `_apply_committed_progress_switch` | 恢复时可纯投影过去的玩家认知，无需 Provider |

为回答四类 actor ingress，额外读取最终建局模块；为证明 owner 和回滚原子性，额外读取 persistence。没有扩大到无关生产模块。

测试源码交叉证据（**只读，未在本轮执行**）：

- `tests/g5_03m2a/稳定演员注册表基础测试.gd:126` `_test_no_card_and_same_name_actors` 明确两个“陈安”获得不同 local ID。
- `tests/g5_03m2b/运行时叙事演员物化测试.gd:77` `_test_parser_contract` 保留同名不同 profile；`:102` `_test_valid_actor_materialization` 断言模型 ID 被忽略、物化不授予 Knowledge、actor-only reopen replay 不产生第二身份。
- 这些现有断言支持身份设计意图，不构成尚未实现 People 的验证结果。

## 3. Q1：精确身份绑定

四类身份来源：

| Actor family | 当前 ID 出现时机 | People 可用条件 |
|---|---|---|
| Guaranteed | `src/最终建局/L2_流程层/原子最终建局流程.gd:122` 首次 intent 分配；`:307` `_setup_envelope` 冻结 | 已存在仍不等于玩家知道；需 accepted 披露及模型整理 |
| Source-backed | 同文件 `:350` `_source_backed_stable_npcs`；`:383` Program 分配 | 首次 intent 自动 Source inventory、exact_profile 兼容，按 asset ID 排除 Player/Guaranteed，冻结 provenance/projection；玩法时不能重扫 Source current |
| creation-authored | 同文件 `:393` `_creation_authored_stable_npcs` | Program 分配 ID，bounded game-local material；静态存在不自动出卡 |
| runtime-narrative | semantic `_on_completed` 校验响应后 mint，durable commit 后可引用 | 先完成当前版本物化，再允许 People 使用 ID |

现有 World L3 没有 bounded player-safe actor-binding getter。`世界回合上下文公开接口.gd.project` 是 GM 上下文，不可冒充 People disclosure seam。新消费方不能直连 World L0 helper。

建议新增 World L3 **accepted identity binding receipt**：模型在既有 semantic 请求中选择某段 accepted GM 文本指向哪个已存在 actor_ref，或指向同响应新 actor candidate_ref。Program 将请求内 ref 精确解析为本 Game 的 stable NPC local ID；新 actor 先规范化、mint，再解析 candidate_ref，并同次提交回执。candidate_ref 只是临时关联，不能成为第二套持久身份。

必须保留 raw candidate → normalized candidate 的关联；被丢弃候选对应的 binding 无效，重复候选映射到同一规范化结果，不能让后续索引错指他人。未知 ref、Player ID、未来/失效 runtime actor 均拒绝。**不做 name equality、模糊匹配、第一命中或姓名去重。**

精确 ref 能证明存储指向哪个 ID，不能证明模型的自然语言共指一定正确。现有 names-only roster 无法保证区分未披露且同名的两个 NPC。若 accepted 文本和既有安全绑定没有足够区分证据，应保持 unresolved，不建立该卡；不能让 Program 猜，也不能静默新建重复 actor。是否向内部 resolver 提供更丰富的私有区分上下文，是独立 GPT STOP 决策，不能因方便而全量扩展。

## 4. Q2：同回合顺序、可行方案与终态

### 方案 A（推荐）：既有 semantic 产出身份回执，再运行既有 curator

复用既有两条模型职责：World semantic 做 actor materialization/共指绑定；Information Curator 做 Character + Experiences + People 的语义整理。没有新增默认第三次调用，没有把出卡判断挪到 World lane。绑定仅建立文本与身份关联，不决定重要性、关系或是否建卡。

```mermaid
sequenceDiagram
    participant R as Runtime / accepted history
    participant S as Existing World semantic lane
    participant W as Durable World + identity receipt
    participant C as Existing Information Curator
    participant P as Player-safe projection
    R->>R: durable accept at Game / epoch / prefix i
    R->>S: consider exact opportunity i
    S->>S: model returns actor candidates + text identity bindings
    S->>S: normalize candidates, mint IDs, resolve refs
    S->>W: atomic actors + semantic result + bounded receipt
    W-->>C: exact-version terminal / durable receipt available
    C->>C: one request: existing curation + safe People evidence
    C->>W: latest-World CAS: curation record + receipt dependency
    W-->>P: refresh through information L3
    Note over S,C: failure/timeout: bounded terminal, People no-op; accepted Narrative remains valid
```

需要新增的终态契约：`game_id + turn_index + accepted_prefix + attempt epoch + status + receipt_id`。`already_attempted` 不是完成；只有能读到当前 durable receipt 的 replay 才算成功。`no_changes` 也要持久空回执，否则 reopen 无法区分“处理完无 binding”和“尚未处理”。失败/取消/超时需有明确终态；读投影不触发重试。

不能为了 People 改变 G5 Narrative acceptance 或让 Agency head 变化废弃全部合法 semantic truth。桥与 curator 使用完整 Player+GM prefix、当前 Game/Restore epoch、actor origin applicability；提交从最新 World 合并并 CAS。依赖版本有效不要求整个 World head 从调用开始一直不变。旧 epoch 回调不得写回桥或 People。具体对既有 semantic mutation 的取消边界应由 GPT 批准，避免无意扩大 G5 行为变更。

若 semantic 超时/失败，建议同一 curator 仍可完成 Character/Experiences，而 People 分量 no-op，保留此前快照；不得以空数组解释为清空卡片。该机会是否允许后续 People repair、如何避免重做已成功的其它分量须先裁定；最小方案不自动 repair，也不增加后台调用。成功绑定但部分 actor unresolved 时，仅有证据的候选可以进入整理。

### 方案 B：保留并行、延后新 actor 的卡片

curator 只消费此前已持久、仍有效的安全 bindings；本回合尚未 mint / unresolved 的人物不更新，等下一次有安全机会再处理。仍需身份桥，仍不允许完整 roster。优点是对现有调度耦合较小；代价是即使本回合物化成功也可能没有卡片，若之后没有提及则可能一直缺失。仅在 GPT/Owner 接受延迟与不自动补齐语义后可用，**不能宣称满足同回合同步可见**。

另设默认 People resolver/curator 调用会增加延迟、费用和第二套 currentness，还不能自动解决同名歧义；不推荐。仅未解决身份时增加专项模型请求亦需另行授权。

两方案共同缺口：当前 semantic 与 lived curator 都跳过空 player_text opening（semantic `_consider_entry:85`，curator `_pump:123`）。People 是否覆盖 accepted opening，必须明确选择。推荐覆盖实际 accepted 开场中的披露，但这需要纳入未来任务；不可通过 Character T0 静态 profile 偷渡 People 初始化。

## 5. Q3：curator 最小安全输入

建议单次请求仅传：

1. 当前机会 accepted Player/GM 原文、当前有效安全 Character/Experiences。
2. 当前有效 People 的玩家可见快照及请求内 opaque actor_ref。
3. 当前机会模型建立的 bounded binding 候选：`actor_ref + accepted GM quote/span`。如需 cue/name，必须由 accepted span 或先前安全快照提供，不能从 registry name/profile 补齐。

Program 在请求侧持有 `actor_ref → exact local_character_id` 映射、receipt ID、完整 prefix；这些内部元数据不进入叶 UI。canonical ID 可直接作为模型引用而仍属于内部数据，但 request-scoped ref 更容易限制其用途。对新人物无需另外传 hidden canonical name；模型可从可见原文决定“蒙面客”等玩家已知称呼。

**不允许给 People curator 完整 stable roster 的名字。** 名字本身可能揭示暗中 actor 的存在、真名、身份；名单还会诱导模型把注册当披露。不能通过“prompt 告诉它别泄露”来替代输入隔离。

窄候选集合由模型在既有 semantic lane 关联 accepted 文本产生；Program 只核验 quote/span 属于该回合原文、ref 在允许集合、数量/类型/来源版本，不用关键词筛人。既有 semantic 内部全 roster name 不能直接转发到 People。

所有 prior snapshots 与当前候选需要有请求字节上限。不能用 Program importance score 截选卡片或因超限静默删除世界中的人。建议保留现有总输入/响应上限，超限时本次 People 不更新并记内部状态；较大规模的上下文选择策略留给单独决策，而非发明总人口上限。

## 6. Q4 / Q5：durable owner 与最小 schema 建议

下列是供 GPT 裁定的精确候选契约，不是已经生效的生产 schema。

### 6.1 身份桥由 World 所有

建议在现有 `living_world` 增加 `people_identity_turns_by_index`，按当前 accepted turn 存储回执。即使 actor-only / no-change，也需要允许合法的 identity-only owner 状态；必须同步调整现有 living_world 的 exact/schema 校验，不能顺手造假 changes/knowledge。

```json
{
  "people_identity_turns_by_index": {
    "3": {
      "schema": "accepted_people_identity.v0.1",
      "game_id": "game-local-id",
      "prefix": "full-player-and-gm-prefix-hash",
      "id": "program-canonical-receipt-hash",
      "status": "resolved",
      "bindings": [
        {"local_character_id": "existing-program-owned-id", "gm_span": {"start": 12, "length": 6}}
      ]
    }
  }
}
```

候选规则：status 只允许 resolved / empty；失败不伪装成成功回执。span 使用 Godot String 字符索引、相对于原始 accepted gm_text；L3 从该文本重新切片，不能信任模型提交的自由 cue 字段。最多 8 bindings，每段最多 600 字；这些是机器容量建议，不是重要性门槛。receipt ID 哈希 schema、Game、index、prefix、规范化 bindings；epoch 只做运行时取消，不进入持久语义身份。as-of prefix 过滤 runtime origins，receipt 不授予 actor Knowledge 或 People eligibility。

World L3 提供两件事：当前机会已完成回执的读取；内部 ref/ID 的当前性验证。返回副本和白名单结构，不返回 raw material。actor 物化与回执需同一 durable mutation；成功重放复用回执，不再次生成身份。

### 6.2 People 内容由 information_curation 所有

推荐沿用 owner 的 turns，增加新结果变体。旧 owner schema 和历史结果保持合法，新的 exact record 变体携带版本及 bridge dependency：

```json
{
  "schema": "information_curation_record.v0.2",
  "prefix": "accepted-prefix",
  "parent": "prior-valid-curation-record-id",
  "identity_receipt_id": "current-receipt-id-or-empty-for-people-no-op",
  "id": "program-record-hash",
  "result": {
    "character": null,
    "experiences": [],
    "people_updates": [
      {
        "local_character_id": "program-resolved-id",
        "snapshot": {
          "display_name": "玩家知道的称呼",
          "headline": "简短身份和近况",
          "summary": "最新已知摘要",
          "relationship": "玩家已知的自然语言关系",
          "details": ["玩家已知的详情"]
        }
      }
    ]
  }
}
```

模型输出对应结构用 `actor_ref` 替代 durable `local_character_id`；其余 Character/Experiences 沿用当前形状。Program 查请求映射后再形成 durable normalized result。`snapshot:null` 表示删除；缺少 People 字段的旧结果或新结果 `people_updates:[]` 表示 no-op；full snapshot replacement 不逐字段推导保留/删除。移除也只能引用当前精确 ID，可来自此前有效安全卡片。

候选容量：每轮最多 8 个不同 actor 的更新；display_name ≤64，headline ≤160，summary ≤400，relationship ≤600，details ≤8 条、每条 ≤600 字；summary/relationship/details 可以为空，不制造未知内容。现有 response 65536 bytes 和 input 131072 bytes 仍是整体硬上限。拒绝重复 actor 更新以避免隐式顺序语义；无 relationship 数值、标签机或通用 field-op DSL。

新 record ID 将 schema、prefix、parent、identity_receipt_id、normalized result 一起哈希。读取时验证 receipt 属于相同 Game/prefix 且仍存在；People no-op 可以使用空 receipt ID。旧四字段 record 继续用现有哈希算法，**不得先给旧 result 注入 people_updates 默认值再验 ID**，否则全部旧 parent 链可能失效。新旧 mixed chain 用各自已验证的 record ID 衔接。initial 保持现有独立规则，不含 People。

派生 People map 从当前有效记录按 accepted 顺序折叠：exact ID 的 snapshot 替换，null 删除。投影结果只显示最后一次有效快照，不展示内部更新日志；内部每回合记录是恢复机制，不是 People history 产品。未知或失效 runtime 身份不能投影为卡片。

另一存储选项是 owner 内单独 latest map + source provenance：读取便宜，但仅存最新条目无法在 Regenerate 后恢复先前快照，仍需旧版本/补算。因此不推荐增加这个第二权威；未来 cache 必须可从 turns 重建。现有 Knowledge fact 列表也不能替代此 owner。无需新 SQLite 表或成熟 Relationship truth owner。

## 7. Q6：出卡、替换、纠正和移除的权限

模型依据 accepted play 与已有玩家认知决定是否建卡、什么值得保留、是否纠正/移除，以及 headline/detail/关系文字。间接获知可以建卡；不强制见面次数，也不自动收录 registry / Source / 主角静态历史。

Program 只负责合法 ref、NPC 身份、绑定版本、payload 上限、原子提交、幂等、投影。叙述中人物是否重要、Player 的猜测是否已被证实、旧关系是否改变，都属于模型判断；不使用 encounter counter、affinity、name regex、semantic routing、关系状态机或 Player-choice evidence heuristic。

actor materialization 不创建卡；People remove 不删除 stable actor 或其 Knowledge。后台 actor 状态变化也不能触发卡片刷新内容，直到 accepted 信息整理产生新的安全 snapshot。

## 8. 披露威胁分析与可证明边界

| 威胁 | 必须建立的边界 | 验证方式 / 限制 |
|---|---|---|
| hidden Source/profile 被姓名查询自动补齐 | People L3 / curator builder 禁止调用 raw material helper；仅 exact ref 映射 | 在 raw material 放置 secret canary，检查 curator payload 和最终 DTO 均无该字段/文本 |
| 全 roster 泄露真名或幕后存在 | 候选只含 accepted span 或已安全保存的旧快照 | 隐藏 actor 新增/改名时，不直接出现新的 cue/card；不能声称模型选择完全不受内部 resolver 名单影响 |
| Agency/Evolution 私下改变 NPC 后，UI 展示新状态 | 只折叠 information_curation；不把 canonical actor 再 hydrate 进卡 | 固定 accepted/curation records，修改 hidden World 后玩家卡片内容不变 |
| 字段名安全但 cue 携带私有文字 | span 从原始 accepted GM 重新切片；无自由 registry cue | 校验索引/长度和版本属于 Program provenance，不是语义筛选 |
| 模型引用另一个同名 NPC | 精确 ID/ref 防止 Program name matching；歧义 unresolved | quote 存在不能证明共指正确；模型可能选错，必须保留本项风险，不能宣称 schema 已证明语义安全 |
| 旧未来 / Restore 后回调复活秘密 | prefix + receipt + parent + epoch；投影只读 current | 迟到回调、相同 GM 但不同 Player prefix、restore 到学习前测试 |
| 将 Player 愿望或怀疑当事实 | 提示契约区分 accepted GM 与 Player 输入及未知/传闻 | 语义验收案例；禁止用程序关键词做证据判官 |
| UI 能拿 World 自行过滤 | L3 返回单独安全快照 DTO，leaf 不接收 world_state | 接口负例/序列化检查；无内部 ID、receipt、origin、GM-private 字段下发 leaf |

这里能提出并测试的是**结构性数据流不泄露**：给定相同 accepted 文本、安全回执及旧 People snapshots，改变原始 NPC 私有材料不会改变 curator 输入或卡片投影。当前代码尚无这条新桥，因此本轮没有“People 已实现安全”的证明。

更强的“任意模型输出永远不会包含错误秘密”不能由 schema、span 或 exact ID 数学保证。内部 semantic resolver 当前能看到 hidden registry names，它输出的 ID 选择可能受其影响；span 只证明文字公开，不能证明对应某个隐藏身份。信息隔离限制原始秘密的直接流入，却不能消除模型幻觉、错误共指或独立推断。若 GPT 要求更强端到端非干扰，必须进一步限制/重构 resolver 的输入或提供已有可信叙事身份引用；不能把私有 resolver 文本转成玩家事实。这是明确 STOP，而非靠 prompt 保证。

若上游 accepted GM 已直接把秘密呈现给玩家，People 边界不能撤回该披露；这属于上游 Narrative authority 的问题。People 不增加第二套 Program semantic judge 来审判原文。

## 9. Save / Restore / Regenerate / reopen

| 场景 | 所需行为与机制 |
|---|---|
| 学习前 Save → 学习后出卡 → Restore | World 与 Conversation 原子切回，turns/receipt 不含未来学习；卡片不存在 |
| A 快照 → B 更新 → Restore 到 A | 从恢复的有效 turns 重折叠，显示 A，不读 NPC 当前私有状态 |
| Regenerate 替换一次更新 | 完整 Player+GM prefix 使更新与后续依赖链不再 current；保留此前有效 snapshot。即使 GM bytes 相同而 Player 不同也失效 |
| runtime actor 出生被替换 | actor origin currentness + receipt prefix 双重验证；旧 ID 不投影。新叙述物化得到的身份必须重新绑定 |
| 卡片移除后 Restore | tombstone 随 turns 回滚；恢复移除前卡片，无需模型反推 |
| reopen | 从持久 World/accepted 读取并折叠，不在 render 发 Provider 请求；重开不从 Source current 补 People |
| actor commit 后、curator 前崩溃 | 读取 durable receipt 与 actor；可在明确授权的运行机会补缺失 curation，不能将页面渲染等同于调用授权 |
| curator commit 成功、通知前崩溃 | replay 用有效 receipt/record ID 识别已完成，不重复 append/出卡 |
| Restore 后同文本重新 accepted / 旧请求迟到 | runtime epoch 阻止旧请求发布；新机会使用恢复后的 parent 和绑定依赖 |
| 后台 Agency 更新同一 World | 不因无关 head 变化使卡片漂移；从最新 World 合并 curation，CAS 保护不覆盖并发内容 |

当前 initial Character 在 Restore 后有特殊固定节点复用机制；**不得把该 T0 例外应用于 People**，不能从 displaced future recovery 节点捞回玩家尚未知的卡片。

老 Game 的既有成功 curation records 没有 People/binding；不能静默重跑全部历史、重写旧哈希链或从现有 registry 回填。推荐默认保留旧记录，未来新 accepted 机会逐步建立卡片。是否允许有界历史 backfill 是 GPT/Owner 的独立产品/调用成本决定。

## 10. Q7：最小刷新与 UI seam

未来增加信息整理模块的 People L3 投影入口，复用 existing session/accepted currentness，并返回已安全规范化的卡片内容；叶 UI 不接收 World/raw ID lookup 能力。Shell 可继续通过 `_refresh_player_safe_panels` 组合，不需 event bus 或 MW-013。

现有 `_on_information_curator_finished`（`src/应用壳.gd:587`）刷新角色/经历，可在成功提交后一并刷新 People。`_on_restore_completed:1200` 已刷新安全面板，可在新 L3 接入后同步显示历史快照。Regenerate/accepted 变更也必须立即重新投影，先撤掉失效未来内容，不能等新模型结果；当前 `_on_generation_state_changed:1284` 仅处理 controls，需要补窄的 currentness refresh。

semantic finished 本身不代表可显示新人物；先有当前安全 curation commit，才改变 People 内容。展开状态可作为本地 UI 状态，但不得保留已失效卡片内容。卡片默认折叠，collapsed/expanded 内容规则沿用 People decision，本轮不实现任何 scene、导航、搜索、排序或 portraits。

## 11. 后续任务边界与必须裁定的 STOP

建议拆为两个可独立审查的实现任务：

1. **身份桥与版本化协调 backend**：World L3、安全 accepted binding、candidate normalization 关联、durable terminal、超时/恢复取消、as-of roster。只扩窄接口，不造 People UI，不扩展 Relationship truth；验证同名、actor-only/no-op、错误 ref、回调与 Restore。
2. **统一 curation + People consumer**：在已审查桥上新增结果/record 变体、mixed history 兼容、安全投影与最小固定 UI，验证最新已知快照、删除、Save/Restore/Regenerate、旧 Game、披露负例。继续一次 Information Curator，不加默认新模型调用。

拆分理由是第一项触碰 G5 稳定身份与异步 currentness，第二项触碰已审核 MW-014/015 的 hash/storage seam 和新玩家消费。一个大任务也可覆盖功能，但会把身份安全与 UI 验收耦合；不建议在未裁定第一项前直接派 UI 实现。任务编号和正式验收由 GPT 另行 shaping，本报告不自行分配新 Work ID。

GPT/Owner 必须明确：

- **STOP-1 身份语义与披露边界**：批准方案 A 的窄 World identity bridge 吗？接受 unresolved 同名人物暂不出卡吗？如果需要更强共指/非干扰保证，批准什么额外内部输入或可信叙事绑定机制？禁止以完整 roster dump 解决。
- **STOP-2 机会与失败政策**：选择同回合 barrier 或延后方案 B；批准 semantic terminal/timeout/epoch 的最小扩展范围。推荐失败时 People no-op、其它整理继续，无自动额外 repair call；是否需要补偿由 GPT 明定。
- **STOP-3 opening / legacy**：accepted opening 是否进入 People；旧 Game 是否只从下一次 accepted 机会建立卡片，还是授权有界 backfill。T0 Character 静态资料不得初始化 People。
- **STOP-4 owner / compatibility**：批准 World receipt + information_curation per-turn full replacement/tombstone，以及保留旧哈希算法的新 record 变体；确定具体机器上限和超限行为。
- **STOP-5 dispatch**：确认两任务拆分及第一项审查门槛。批准前不得修改 production code 或实现 People UI。

## 12. 本轮验证与交付限制

本轮完成 current-source 路径审查、相关测试源码交叉检查和报告范围检查。没有执行 Godot/export/Provider，没有生产实现，也没有声称 Engineering PASS、Audit PASS 或 Product PASS。代码静态路径足以证明当前缺少顺序屏障、safe identity bridge 和 People owner，运行现有无 People 测试不能替代未来契约验收。

交付仅此 Markdown 报告；提交前执行 `git diff --check`，核对 changed path 仅报告，重新 fetch 两库 main 核对来源未漂移。最终状态与 audit commit SHA 由提交后的 Return Protocol 返回。

**READY FOR GPT ARCHITECTURE DECISION**
