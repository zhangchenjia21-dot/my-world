# MW-017｜People Identity Bridge + Same-turn Barrier

Status: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome / source identity

本轮完成 backend 身份桥与同回合屏障。叙事中的人物先精确关联本局 stable NPC，之后既有 lived Information Curator 才可以启动。没有新增 People UI、People snapshot schema、Relationship、第三次默认模型调用或 SQLite 表。

- Branch: `mw-017-people-identity-bridge`
- Worktree: `D:/AI/Projects/.worktrees/my-world/mw-017`
- Refreshed implementation base: `286f72d78c8470f2d78fa2f3847ace081cae7bd4`
- 初次读取 governance main: `06496689930155b77968cdad2894e44b8b26cb51`
- 最终读取 governance main: `8f38b4998e7b9d77ac731f8248cbc7e7fcc4945d`
- 两次 governance 之间仅 workbench 项目变化；my world、AGENTS、governance authorities 无差异。
- 最终离线/回归/export 所验证的 clean code commit: `2be0c532d89c0fa7ae1d473d408a42785a32c8d9`
- 后续交付提交仅加入本报告和证据；最终 exact candidate SHA 以 Return Protocol 为准。

已读取 Task Packet 全部 Source Manifest、MW-016 audit，以及所需 runtime、persistence、Provider、现有回归 seam。按最新冻结 Decision 的 Scheme A 实现；MW-016 报告中的建议不覆盖正式裁定。

## 2. 文件与职责

精确代码/测试变更列表见 [code-changed-files.txt](evidence/code-changed-files.txt)；证据包清单及哈希见 [manifest.json](evidence/manifest.json)。

| Owner / 层级 | 修改及公开边界 |
|---|---|
| World L0 | 新增 `人物身份回执规则.gd`：完整 accepted prefix、span/ref 机器约束、receipt identity、currentness、owner additive merge |
| World L1 | `语义变更响应解析器.gd`：保留 candidate_ref → normalized ordinal 的独立映射；既有 actor material 不增加身份字段 |
| World L2 | `语义物化流程.gd`：请求内 actor refs、mint 后绑定、actor+receipt 单次提交、当前版本 terminal、120 秒 timeout、Restore epoch |
| World L3 | 新增 `人物身份桥公开接口.gd`；既有 `世界回合公开接口.gd` 补充终态契约 |
| Information L2/L3 | 注入 World L3 barrier；仅新 accepted lived opportunity 等终态；初始 Character lane、提示词、结果 schema、record hash 算法未改 |
| Bootstrap | `应用壳.gd` 只调整 worker 组合和依赖注入；一个 World worker，curator/Agency 共享它 |
| Tests | 新增 MW-017 两个 Godot 验证脚本及两个 PowerShell runner；三处旧回归同步已批准的 empty receipt / 等待时序预期；新增脚本配套 UID |

新增依赖为 World 内部 L3→L0、L2/L1→L0；Information 通过 Bootstrap 注入 World L3 对象调用，未新增跨模块内部层引用、向上依赖或循环。既有 World L2 对 D20 L0 的历史引用未扩展。本轮没有泛化框架或空层。

公开契约注释说明了内部 backend 与 leaf UI 的区别、成功/失败含义、当前性、取消生命周期与只读性。没有剩余待人工解释的注释冲突。

## 3. request-scoped identity contract

既有 World semantic prompt 保留 changes/knowledge/new actor 的职责，追加独立 identity binding 指令。既有内部 Allowed Stable Actors 仍为 Knowledge 提供原有 name/local-ID allowlist；**不会转发给 Information Curator**。

People Actor References 只列当前 source opportunity as-of roster 的 NPC `actor_ref + display_name`。不扩展 raw Source/game-local profile。引用为随机请求 nonce + ordinal，单个 ≤64 字符，Program 私有字典解析到 exact ID。Player 没有 People ref；runtime actor origin 必须在该 source turn 及其前缀内有效。整个请求/响应各最多 131072 UTF-8 bytes，过量 fail-soft，无语义打分或全局人口限制。

模型响应在既有 JSON 中可加：

```json
{
  "changes": [],
  "new_actor_candidates": [
    {"candidate_ref": "new-person-1", "display_name": "沈青", "profile_text": "叙事已确立的摆渡人材料"}
  ],
  "people_bindings": [
    {"actor_ref": "request-scoped-existing-ref", "gm_span": {"start": 32, "length": 2}},
    {"candidate_ref": "new-person-1", "gm_span": {"start": 0, "length": 2}}
  ]
}
```

candidate_ref 非空、无首尾空白、最多64字符，仅响应内关联；不进入 durable actor material 或 receipt。解析器先统计重复 ref，重复 ref 全部失效；无效材料丢弃；完全相同的规范化 name+profile 材料沿用既有去重。不同唯一 ref 指向完全相同材料时映射同一规范化 ordinal；同名不同 profile 仍是不同 actor。过滤/去重不会用移动后的 raw 数组索引猜对应关系。

World flow 先按既有 deterministic actor 算法 mint/reuse ordinal ID，再把 valid candidate_ref 转为该 ID。binding 精确限定 actor_ref/candidate_ref 二选一加 gm_span；未知/canonical ID 冒充 ref、Player、stale actor、自由 cue/额外字段、非整数/越界 span 都丢弃。最多8条 binding、每段1..600个 Godot Unicode 字符；0-based，针对原始 accepted GM 文本，不含标题。

同名歧义由模型返回无 binding；Program 不依据 display_name 选择第一个、不模糊匹配、不姓名去重，也不因歧义另建 actor。exact ID 能证明写入对象，不能数学保证模型共指理解正确；保持正式决策接受的 model-semantic residual risk。

## 4. durable receipt / currentness

位置：

`world.living_world.people_identity_turns_by_index[str(turn_index)]`

```json
{
  "schema": "accepted_people_identity.v0.1",
  "game_id": "program-game-id",
  "turn_index": 0,
  "prefix": "full-accepted-Player-and-GM-prefix",
  "status": "resolved",
  "bindings": [
    {"local_character_id": "program-owned-stable-NPC-id", "gm_span": {"start": 0, "length": 2}}
  ],
  "id": "program-receipt-hash"
}
```

空成功记录使用 `status:empty, bindings:[]`。缺字段/失败不是 empty；不具有“清空 People”语义。空成功与 identity-only 成功也持久化回执，不制造 changes/Knowledge。

实现位置：

- `src/世界回合/L0_公理层/人物身份回执规则.gd:10` `prefix_at`：逐回合 SHA256(JSON([previous, accepted Player, accepted GM]))。
- 同文件 `:74` `build`：receipt ID = SHA256(sorted canonical JSON of schema/Game/index/prefix/status/normalized bindings)，不含临时 ref。
- 同文件 `:81` `current`：exact-key、类型、bounds、Game/prefix、receipt hash、NPC membership/as-of runtime origin 全部验证后返回规范化副本；坏数据返回空。
- 同文件 `:114` `with_receipt`：在既有 living_world additive collection 保存；旧 owner 缺该 collection 继续有效。
- `src/世界回合/L2_流程层/语义物化流程.gd:240` `_on_completed`：用最新 World 合并 actors、changes/Knowledge 与 receipt 后，通过现有 `commit_world_mutation_durably` **一次提交**。

历史 G5 world_turn / knowledge / runtime actor ID 算法未改。新 semantic mutation 使用一次提交级随机 ID，避免 Restore 后与 displaced-future mutation/node 冲突；成功 replay 根据当前 durable receipt 去重，不重新请求或 mint。这是提交身份变化，不重写旧 G5 record IDs。

不新增 SQLite table/migration；runtime/persistence 源文件无 diff。Save/Restore 继续原子保存/切换 World 与 Conversation，receipt 随同一 snapshot。

## 5. barrier / terminal

```mermaid
sequenceDiagram
  participant R as Runtime accepted history
  participant W as Existing World semantic
  participant DB as Existing durable World
  participant C as Existing Information Curator
  R->>W: new player-authored durable acceptance
  R->>C: mark this exact lived opportunity
  C->>W: lived_terminal(index,prefix)
  W-->>C: pending; no lived request
  W->>W: existing model request: material + bindings
  W->>W: normalize candidates, mint IDs, resolve refs
  W->>DB: one actors/facts/receipt mutation
  W-->>C: current opportunity_terminal
  C->>W: validate current terminal
  C->>C: original Character/Experiences request
  Note over W,C: failure/cancel/timeout also releases; receipt unavailable
```

有状态 World L3 继承公开 `opportunity_terminal(result)` 与只读 `lived_terminal(index,prefix)`。终态含 Game、source_turn_index、source_gm_sha256、完整 prefix、epoch、success、status、outcome、receipt_id。

- `resolved / empty`：已持久成功；查询再核对当前 receipt。
- `failure / cancelled / timeout`：无成功 receipt，允许 Character/经历继续。
- `unavailable`：显式旧历史 consideration 只读跳过，不发身份回填调用。
- `already_attempted / queued`：不是 terminal，不可释放屏障。
- Replay 当前 durable receipt：纯读取，不发请求。
- 120 秒 Timer 结束等待；失败/取消/超时没有额外 People repair。
- accepted Narrative 早已 durable，可立即继续前台行动；不是 finalize gate。

`语义物化流程.gd:356` 清除 active、断开请求 callbacks、停止 Timer 后才发布终态；`:369` 只发布仍符合 Game/full-prefix/epoch 的机会。callbacks 绑定 request serial；Restore 先递增 epoch、清空 active/queue/terminals/attempts、断开旧 callbacks，再 cancel transport。旧 callable 即使在新请求已启动后被调用也不能作用到新请求。现有生产 Provider 的 cancel 同步关闭 HTTP 并进入 IDLE，不再发该请求输出。

Information `_pump:123` 仅对本 activation/Restore 之后新 accepted 的 index/prefix 等待 barrier。终态通知只 deferred 唤醒，查询再次验证；无需一般 scheduler/event bus。Initial Character 的 `_ensure_initial` 仍先运行且不检查 barrier。旧独立测试/调用者可不注入 barrier 以保持已有 Character-only API；生产 Shell 始终注入同一个 World L3 worker，MW-018 应沿用这个入口。

## 6. 披露与恢复边界

World L3 `人物身份桥公开接口.gd`：

- `current_receipt(runtime,index)`：内部机器回执副本，无 actor material，失败返回 {}。
- `request_evidence(runtime,index)`：返回分离的私有 bindings 字典和 evidence 数组。evidence 仅 request-scoped ref、span、由当前 accepted GM 重切得到的 quote。调用方仅把 evidence 传给未来 curator，映射留在 Program。
- 两者只读，不触发 Provider、Source lookup 或 backfill；均不是 leaf UI DTO。

本轮未把 People evidence 加入 curator prompt，也未增加 people_updates。未来 consumer 不能将整个 envelope/raw World 发给 leaf。测试通过 secret canaries、hidden-only mutation、tampered durable ID 验证该结构边界。没有通过 Program 关键词来判定叙事含义。

| 场景 | 实现行为 |
|---|---|
| 同 GM、不同 accepted Player | 完整 prefix 变化，旧 receipt 立即不 current |
| Regenerate 尚在生成 | 旧 accepted 仍 authoritative，保留原 receipt |
| replacement durable accepted | 新 prefix 立即排除旧 receipt，之后新语义结果可提交 |
| Restore 到认识人物前 | World/Conversation 同步回退，无该 receipt |
| Restore 到过去有效 binding | 重建相同 receipt，不读未来恢复节点 |
| Restore during request | 旧 epoch 不提交 receipt、不释放旧 curation |
| reopen | 读取已有 receipt、initial 与有效整理记录；不做 render-time Provider 工作 |
| 旧 Game 无 collection | 仍可打开；不重扫 Source、不重跑历史；从新 accepted player turn 开始 |
| GM-only opening | 两条 lived lane 都跳过；T0 Character 不受影响 |
| Agency/Evolution 私有状态变化 | 不进入 bridge evidence；不阻止 otherwise-current source-prefix 提交 |

## 7. 验证结果

最终完整验证从 clean code commit 开始，结果见 [results.json](evidence/results.json)，详细日志随包保存。运行入口：

```powershell
pwsh -NoProfile -File tests/mw017/运行身份桥离线验证.ps1
```

| 检查 | 结果 |
|---|---|
| MW-017 production SQLite / World L3 / Curator L3 专项 | 120 checks，0 failures |
| G5-01 materialization + timeline | 通过 |
| G5-02 Knowledge | 通过 |
| G5-03 Agency / G5-03M2A registry / G5-03M2B runtime actors | 通过 |
| G5-04 World Evolution | 通过 |
| MW-006 mechanical grounding | 通过 |
| MW-014 Character/Experiences | 通过 |
| MW-015 Surface consumer | 通过 |
| MW-015 R2 initial / initial UI / contract | 通过 |
| G4-07B Narrative playable vertical | 通过 |
| Windows Desktop release export | exit 0，0 export/script errors；exe/pck hash 见 export.json |
| 架构/范围 / diff check | 无新增反向或跨内部层依赖；无 runtime/persistence/schema/UI feature diff；git diff --check 通过 |

以上为15个测试 suite + 一次 export。专项覆盖 Task Packet 的 exact existing actor、同名 unresolved、新 actor mint/ref、normalize drift、invalid refs/spans、empty/identity-only、reopen、Player correction、Regenerate、Restore late callbacks、barrier 成功/失败/timeout/cancel、initial 独立、披露、旧 Game，以及8条/600字符上限与损坏 durable receipt。

已有三处退出资源告警，不能报为零告警；在未修改 implementation base 的隔离 archive 对照运行，计数完全相同：

| Suite | 当前 / base ObjectDB leaks | 当前 / base resources in use |
|---|---:|---:|
| G5-03 | 3 / 3 | 1 / 1 |
| G5-04 | 43 / 43 | 20 / 20 |
| G4-07B | 3 / 3 | 1 / 1 |

对照日志见 evidence 的 baseline 三文件；均 exit 0、无 SCRIPT ERROR。未扩大本任务修复历史资源生命周期。MW-017 本身无退出告警。

三处既有测试修改均保留语义断言：空成功改为只保存 receipt、不造事实；actor-only 不以“整个 living_world 缺失”推断无后果；MW-015 在 semantic terminal 后等待 deferred curator。没有删除身份/恢复/内容断言来掩盖失败。

## 8. One real Provider smoke

证据：[real-identity-smoke.json](evidence/real-identity-smoke.json)。

- 读取现有配置：Kimi K3，`k3-256k`，256k/high。
- 目的地：`https://api.kimi.com/coding/v1/chat/completions`。
- 只运行 **1** 次原有 World semantic 请求；task-owned synthetic player turn，隔离 SQLite，无 Owner Source/Game mutation。
- 返回1个新 actor“沈青”和2条有效 binding：candidate_ref → mint 后沈青 ID；actor_ref → existing `npc-li`。
- GM spans 为 `{start:0,length:2}` 与 `{start:32,length:2}`，实际重切分别为“沈青”“李亭”。
- same commit 包含新 actor、1条 change、2条 Knowledge 和 resolved receipt；没有任何语义 heuristic repair。
- Owner settings/Source/Games/current DB 前后指纹一致，见 before/after JSON。凭据未输出/复制/持久化。

真实 smoke 发生于代码提交前；之后仅做格式/契约注释整理、删除无调用 helper、增加 bounds 测试及精简 runner 未使用参数。semantic prompt、actor/ref/receipt 算法未因真实输出而修改。最终 clean code commit 上完整离线/回归/export 重跑通过；没有为取得新 SHA 再消耗一次真实模型调用。

执行审批曾拒绝未说明外发目标/payload 的 smoke；补充 Task §9、已读当前 Kimi 配置和全合成 payload 后批准执行。另一次整目录 fixture 还原被拒绝，未执行；使用保留内容的索引换行刷新和逐文件转存生成物完成收尾。没有绕过拒绝或覆盖未知工作。

## 9. Independent Review entry / stop boundary

Review 建议先看 candidate_ref mapping、同次 mutation、full-prefix/epoch 校验和 Shell 单 worker 注入，再核对 evidence。Program 只做身份/结构/时序；模型仍拥有共指与是否生成 binding 的语义判断。

Owner playable checkout 保持原 HEAD 与既有 dirty work。候选只在指定 worktree 构建；没有 merge main、没有启动 MW-018、没有 People UI、没有安装未审核 Owner build。

**READY FOR INDEPENDENT REVIEW**。不自行宣布 Engineering PASS。
