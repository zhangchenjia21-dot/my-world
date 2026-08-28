---
title: my world｜G3-06 Crash / Interrupted Write Recovery Task Packet
status: current-task-packet
task_id: G3-06
type: implementation
owner: Codex
created: 2026-08-28
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: bf8c35fdf76c4ea3b8ad2560d93c89c2f84c07b0
agent_rules_base: 6c3aafabb6566a6f753766aff7c5f0063b38a3e3
local_project: D:\AI\Projects\my-world
---

# TASK｜G3-06｜Crash / Interrupted Write Recovery

Type: `implementation`  
Owner: `Codex`  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`

## 1. Outcome

把 G3-01..G3-05 已经成立的 durable Game / Save / Restore / Recovery 从“正常路径正确”硬化成第一代灾难恢复能力：

```text
healthy current Game
→ only one product writer may own it
→ verified SQLite-native recovery backup(s) exist
→ process/write interruption leaves no half truth
→ next startup validates current DB before trusting/migrating it
→ physical current-DB corruption is detected, not treated as normal absence
→ if a verified backup exists, player may explicitly recover
→ corrupt original remains preserved/quarantined
→ recovery publishes only a staged + verified replacement
→ reopen into one coherent Game/World/Timeline/Save/Recovery/Conversation truth
```

这一步必须走真实 Godot/Windows/product path，不是只做文件工具或 SQLite demo。

Implementation Agent 的最高返回状态：`READY FOR INDEPENDENT REVIEW`。Independent Review 通过后仍需 Owner UAT（使用隔离 recovery fixture）；不得自行宣布 Product PASS，不得开始 G3-07。

---

## 2. Why Now

G3-05 已通过 Independent Review + Owner UAT。当前产品已证明：

```text
resume
+ named Save
+ atomic Load/Restore
+ future-memory isolation
+ automatic Recovery Checkpoint
+ reciprocal Recover
+ internal Timeline branch correctness
```

尚未关闭的 persistence hardening 风险集中在三类：

1. 两个 product processes 同时打开同一个 current Game，可能产生 stale in-memory writer / lost update；
2. whole-DB physical corruption 目前只会 fail-loud，还没有 verified backup + product recovery path；
3. backup refresh / physical restore / migration-prebackup 本身也可能被 crash 打断，必须证明不会摧毁最后一份可恢复材料。

G3-06 不增加 RPG 玩法；它服务的核心产品价值是：

> **长期世界进度应该是基础设施，而不是需要玩家或 Product Owner 经常手工救文件的工程宠物。**

---

## 3. Authority / Source Manifest

冲突时按以下顺序：

1. 用户当前明确指令与 G3-05 Owner UAT PASS。
2. `Vibe-Coding/AGENTS.md`。
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`。
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`。
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md`。
6. `Vibe-Coding/my world/architecture/persistence/时间线存档与可逆性设计.md`。
7. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` / `MY_WORLD_CURRENT_STATUS.md`。
8. 本仓库 current `AGENTS.md`、code/tests/HEAD。
9. `2shady4u/godot-sqlite v4.9` tag `9cbdb225823ee111342ce32fe451e066eb92cc6e` 的 exact API contract；已确认该版本暴露 SQLite online `backup_to` / `restore_from`。
10. Current `agent-task-packet` / `lifecycle-dev-process` Skill 作为执行方法。

Not authoritative：

- DSH / The World 的 Workspace / Markdown backup/session implementation；
- Transcript / UI / Prompt / Context cache；
- 普通文件 copy 一个 open WAL DB 的“经验方案”；
- 裸 PID 文件 / wall-clock lease 作为 single-writer correctness；
- G4/G5/G7 future schema guesses；
- arbitrary Timeline browser / cloud backup ideas；
- old chat/task status。

---

## 4. Read First

开始先 fetch / fast-forward 最新 `origin/main`，记录 start HEAD 与 `git status --short`，确认包含本 Task Packet 与 current `AGENTS.md`。

初始工作集：

```text
AGENTS.md
本 Task Packet
src/persistence/L1_器件层/SQLite数据库连接器.gd
src/persistence/L2_流程层/世界持久化流程.gd
src/persistence/L3_外交层/世界持久化公开接口.gd
src/runtime/当前游戏会话运行时.gd
src/应用壳.gd
src/main.tscn
tests/g3_05/* 中与 crash/reopen/product path 直接相关的 harness
addons/godot-sqlite/THIRD_PARTY.md
```

随后读取 current Persistence supporting design 与 exact godot-sqlite v4.9 backup API documentation/source。只有证据不足时才扩大范围；Final Report 说明扩大原因。不要默认扫描整个仓库。

---

## 5. Pre-implementation State / Failure Matrix

**编码前先完成矩阵。** 使用 task-scoped note，不新建长期 top-level 文档。

至少覆盖：

### Single-writer / startup ownership

```text
first product process acquires writer ownership
second product process starts while first is alive
second process exits/fails before touching gameplay DB
first process normal exit then second starts
first process exact-PID crash then second starts
stale coordination artifact after crash/reboot
isolated --script/test path must not seize real product ownership
lock acquisition internal error
```

### Healthy DB / backup lifecycle

```text
brand-new Game, no backup exists
healthy current DB + valid latest backup
healthy current DB + latest missing + previous valid
latest invalid + previous valid
both backup generations invalid/missing
backup staging creation failure
backup verification failure
process dies after staging created but before publication
process dies during latest/previous rotation boundary
explicit named Save commits but backup refresh fails
normal graceful close backup refresh succeeds/fails
```

### Migration safety

```text
existing schema v3 → v4 open
pre-migration backup success + migration success
pre-migration backup creation failure → migration must not start
pre-migration backup verification failure → migration must not start
backup success + intentional migration failure → current remains old schema + backup valid
unsupported newer schema → no backup auto-restore/downgrade
```

### Current DB physical integrity / disaster recovery

```text
healthy DB quick/integrity check success
openable DB with deliberate page/content corruption
DB open failure caused by physical corruption
corrupt current + valid latest backup
corrupt current + invalid latest + valid previous
corrupt current + no verified backup
logical/domain validation failure with physically healthy DB
explicit recovery cancelled by player
recovery staging copy failure
recovery staging verification failure
process dies while constructing staged replacement
process dies after corrupt original quarantined but before replacement publication
process dies after replacement publication but before Runtime/UI reopen
normal reopen after successful disaster recovery
```

### Interrupted writes

```text
process dies before durable COMMIT during real production write
process dies after COMMIT before caller/UI observes success
reopen quick_check + current truth exact
no false corruption recovery prompt for normal SQLite crash recovery
```

对每个场景回答：

- writer ownership state；
- current DB authoritative status；
- latest/previous/staging backup status；
- corrupt/quarantine artifact status；
- Game/head/World/Conversation/Save/Recovery durable truth；
- player-visible result；
- whether new Game creation is allowed；
- retry/reopen semantics；
- 是否存在 half-write、silent fallback、backup destruction、wrong-version downgrade、double writer。

---

## 6. Decision Digest / Invariants

### DEC-01｜Physical Backup is disaster recovery, not timeline UX

冻结：

```text
Physical Backup != Save Point
Physical Backup != Recovery Checkpoint
Physical Backup != Timeline Node
Physical Backup != live secondary database
```

Backup 是 whole-DB recovery copy，只用于 storage-level disaster recovery。

普通 Save / Recovery UI 不列出 physical backup generations；正常 gameplay 不查询 backup 作为 fallback truth。

### DEC-02｜Single-writer product ownership is blocking

同一个 product current Game 第一代只允许一个写实例。

要求：

```text
process A owns current Game
→ process B starts
→ B is rejected before mutation/migration of gameplay DB
```

必须满足：

- guard 生命周期与 OS/process lifetime 绑定，normal exit / crash 后自动释放；
- 不采用“写一个 PID 文件 + 看时间是否过期”作为 correctness；
- 不采用 wall-clock lease 作为第一代唯一 authority；
- 不在 gameplay DB 上持有整局 `BEGIN IMMEDIATE/EXCLUSIVE` 来锁住自己其它事务；
- 推荐使用 dedicated sibling SQLite coordination DB/connection 持有 process-lifetime lock，或其它具有同等 OS-backed crash-release evidence 的最小方案；
- second instance 的 lock wait 必须 bounded/fail-fast，不能 UI 挂住几十秒；
- exact Windows two-process + crash-release proof 是 blocking acceptance。

Coordination artifact 不是 gameplay truth。

### DEC-03｜Startup classifies before it repairs

启动失败至少区分：

```text
normal_missing
already_running
physical_corruption / integrity_failure
unsupported_newer_schema
migration_failure
logical/current-state invalidity
ordinary storage/path permission failure
```

不得把所有 startup failure 都解释成“从备份恢复”。

尤其：

- newer schema 不能被旧版本用 backup 静默降级；
- logical application/domain bug 不能自动覆盖数据库；
- physical corruption 才进入 disaster-recovery candidate path；
- current file 真不存在且没有旧 Game artifacts 时才允许 existing first-run new Game semantics。

### DEC-04｜Use SQLite-native online backup

`godot-sqlite v4.9` exact contract 提供：

```text
SQLite.backup_to(path)
SQLite.restore_from(path)
```

G3-06 production backup 必须使用 SQLite online backup API 或直接等价的 SQLite consistency primitive。

禁止：

```text
open WAL database
→ FileAccess.copy(current.sqlite)
→ call it a verified backup
```

L1 可以增加最小 `backup_to` / integrity inspection seam，但不得把 Game/Save business semantics 下沉到 connector。

### DEC-05｜Backup publication is staged and verified

第一代允许固定的：

```text
latest verified backup
previous verified backup
staging candidate
```

exact filenames/dirs 可按当前 `user://my-world` shape 最小冻结。

刷新必须等价于：

```text
healthy authoritative current DB
→ SQLite online backup to staging
→ verify staging
→ only then publish/rotate
```

verification 至少包含：

- SQLite open/read success；
- `PRAGMA quick_check`（或 stronger equivalent）明确 `ok`；
- `PRAGMA foreign_key_check` 无 violation，若当前 schema 使用 FK；
- schema version source 可读且属于本产品支持的已知版本；
- one-current-Game identity/current materialization 基本可读；
- JSON materialization/accepted Conversation 至少通过现有 structural read contract；
- backup 文件不是 0-byte/明显失败产物。

如果 staging 验证失败，不发布。

rotation/publish crash 后至少一份先前 verified backup 必须仍然可发现并恢复。不要为了“最新”删除唯一已验证 copy。

### DEC-06｜First-generation backup refresh policy

默认 policy：

1. brand-new/healthy startup 完成后，如果没有 verified backup，必须建立初始 backup 后才能进入正常 READY；
2. **每次明确 player Save Point 成功后**刷新 verified backup，因为玩家已经表达“这个进度重要”；
3. graceful product exit 尽力刷新 latest backup；失败不得破坏旧 backup，也不得反向撤销已经 committed 的 current DB；
4. before any schema-changing migration，verified pre-migration backup 是 blocking prerequisite；
5. 不在 G3-06 为每个普通 AI Turn 做 whole-DB backup；避免把每回合 latency/performance 问题提前引入，后续 G7 再根据 long-session evidence 调整。

Save 已成功、随后 physical backup refresh 失败时，不得把 Save 谎报成“完全失败”；应返回/显示类似：

> 存档已保存，但安全备份刷新失败；当前数据库仍是有效进度，旧安全备份已保留。

exact wording 可优化，但语义必须准确。

### DEC-07｜Migration backup gate

现有 v1→v4 migrations 继续 transactional。

G3-06 必须把 migration pipeline 改成：

```text
inspect current physical DB
→ integrity okay
→ schema change required
→ create + verify pre-migration backup
→ only then begin migration
```

若 backup 失败：migration **不得开始**。

intentional migration failure 后：

- current DB 仍是旧可用 schema（transaction rollback）；
- pre-migration backup 仍有效；
- 不自动创建空 Game；
- 不自动用 backup 覆盖一个本来仍可用的 old-schema current DB。

不要求为 G3-06 人为新增 schema v5。若实现认为需要新 schema 仅用于 backup bookkeeping，先证明不可避免；默认 external recovery metadata/coordination 不应重写 gameplay schema。

### DEC-08｜Corruption recovery is staged and preserves evidence

physical current DB 被判断损坏后：

- runtime 不进入 READY；
- current DB 不被当成 normal absence；
- 如果有 verified backup，UI 暴露明确“恢复最近安全备份”动作；
- 如果无 verified backup，fail-loud 并阻断，不创建空 Game。

用户确认 disaster recovery 后，流程必须等价于：

```text
select latest verified backup, fallback previous if latest invalid
→ preserve/quarantine corrupt current artifact
→ restore/copy backup through staging candidate
→ verify staged replacement completely
→ publish replacement as current
→ reopen or enter explicit reopen_required
```

禁止一开始调用 destructive restore 覆盖唯一 current 文件，然后再祈祷成功。

corrupt original 要保留在 project-owned quarantine path，至少不在同一次 recovery 中删除；它不是 fallback live truth，只供诊断/手工救援。

### DEC-09｜Backup recovery may be older, UX must say so

physical backup 是 last-known-good，不等于每 Turn snapshot。

恢复 UI 必须明确：

- 当前数据库已损坏/无法安全使用；
- 可恢复到最近安全备份；
- 备份之后的进度可能丢失；
- 损坏原件会保留；
- 这是 storage disaster recovery，不是普通 Load Save。

不得用 Timeline Node / SQLite row / WAL 等工程术语做主要玩家文案。

### DEC-10｜Interrupted writes should use SQLite recovery, not false disaster recovery

已证明的 atomic transaction / WAL / FULL synchronous 继续有效。

G3-06 必须再次用 real production path 证明：

```text
kill before COMMIT
→ reopen
→ quick_check okay
→ last committed truth intact
→ no corruption-recovery prompt
```

以及：

```text
COMMIT succeeds then process dies before memory/UI observes it
→ reopen uses committed truth
```

普通 process crash / WAL recovery 不等于 physical corruption。

### DEC-11｜Backup refresh and disaster recovery are themselves crash-safe

至少用 exact-PID harness 证明：

- backup staging 过程中 kill，不破坏 old latest/previous；
- staging verified 但 publish/rotation 前 kill，old verified backup 仍可用；
- physical recovery staging 中 kill，corrupt current + verified backup 至少一方仍完整且可 retry；
- replacement 已 publish 后 kill，next reopen 得到 recovered authoritative current。

测试不得靠“理论上 rename 是原子的”直接 PASS；需要真实 Windows filesystem/process evidence。

### DEC-12｜UI remains a request/projection surface

允许在 startup failure / World Surface 增加最小 recovery UX：

```text
另一个游戏实例正在运行

or

当前游戏数据损坏
最近安全备份：<时间/可理解信息>
[恢复最近安全备份]
```

Recovery 使用明确 confirmation。

UI 不：

- 直接操作 SQLite/file swap；
- 展示 backup browser/history；
- 展示 raw DB path/hash/page；
- 自动替玩家确认 physical restore；
- 从 Transcript 猜回 Game truth。

若恢复完成后 safest path 是重新启动应用，允许进入明确 `reopen_required`；不得让 failed old Runtime 继续游戏。

### DEC-13｜Owner UAT must be safe and isolated

G3-06 Owner UAT 不得要求 Owner 故意破坏真实 `user://my-world/current-game.sqlite`。

Implementation 必须提供 task-owned isolated fixture/launcher，能安全演示至少：

```text
healthy backup exists
→ isolated current DB deliberately corrupted by harness
→ launch real product path against isolated DB
→ player sees recovery UX
→ confirms recovery
→ reopens/continues recovered fixture
```

测试与 UAT helper 只能删除/改写自己创建的明确目录。

### INV-PERSIST-01｜Never silently create blank Game from damaged existing data

只要 path/artifacts 表明这是 existing Game storage，physical failure 不允许转成 first-run blank Game。

### INV-PERSIST-02｜At least one known-good recovery copy survives refresh/recovery interruption

Backup 更新与 physical restore 都必须以“保住最后可恢复材料”为第一原则。

### INV-PERSIST-03｜One live authoritative DB

正常运行时只有 current gameplay DB 是 authoritative live truth。Backup/quarantine/staging 都不是 alternate current state。

### INV-PRODUCT-01｜Recovery reduces maintenance burden

本增量不能要求普通玩家理解 WAL、手工复制数据库、运行 SQL、选择 backup 文件或修 JSON。灾难路径应该是：识别问题 → 明确恢复动作 → 可验证地恢复/重开。

---

## 7. Scope

### Allowed

- `src/persistence/` 下最小 backup/integrity/coordination support；
- `src/runtime/` / Application Shell 的 minimal startup safety/recovery orchestration；
- 当前 `main.tscn` 的最小 recovery UI；
- task-owned tests/harness/PowerShell；
- export/run-game harness 必要扩展；
- exact godot-sqlite v4.9 API/provenance 注释同步；
- repository-local task note；
- 如确有必要，小型 non-authoritative recovery metadata sidecar，但必须说明为何不从 backup 自身验证信息推导。

### Prohibited

- G3-07 full reality test/gate closeout；
- cloud backup/sync/account；
- backup encryption/compression/archive browser；
- generic file versioning platform；
- manual backup import/export manager；
- multi-Game picker；
- Timeline browser/branch picker/arbitrary Turn rewind；
- G4/G5/G7；
- ORM/DI/EventBus/Service Locator；
- external DB server/runtime；
- .NET/C# switch；
- per-Turn whole-DB backup without evidence-backed architecture re-open；
- arbitrary Narrative validators/output length limits；
- destructive test against unknown or real owner data。

---

## 8. Required Deliverables

1. Pre-implementation state/failure matrix。
2. Process-lifetime single-writer guard with real Windows two-process evidence。
3. Minimal L1/L2/L3 SQLite online backup + integrity inspection seams without leaking raw SQLite rows/objects upward。
4. Verified latest/previous/staging backup lifecycle or evidence-backed simpler equivalent meeting the same survival invariant。
5. First-run/healthy startup backup establishment policy。
6. Player Save-triggered backup refresh with truthful partial-warning semantics if only physical backup refresh fails。
7. Graceful-close backup refresh that preserves prior verified backup on failure。
8. Pre-migration verified backup gate for existing schema migration path。
9. Startup classification separating physical corruption / newer schema / normal absence / logical failure / already-running。
10. Explicit physical corruption recovery orchestration preserving/quarantining corrupt original and publishing staged verified replacement。
11. Minimal player-readable corruption/backup recovery UI + confirmation。
12. Crash harness for backup refresh, physical recovery publication and interrupted production write windows。
13. Safe isolated Owner-UAT fixture/launcher; it must not target real product DB。
14. G3-05/G3-04/G3-03/G3-02/G3-01 + G2 regressions。
15. Windows Desktop export + exported product recovery/single-instance smoke evidence。

---

## 9. Engineering Acceptance

Blocking acceptance至少包括：

### AC-01 Single writer

- Product process A starts and owns isolated current Game。
- Product process B starts against same DB and receives deterministic `already_running`/equivalent before gameplay mutation/migration。
- B does not create alternate Game or modify current DB。
- Kill A by exact verified PID；process C can acquire ownership and reopen same Game。

### AC-02 Healthy backup

- SQLite-native online backup succeeds from open healthy WAL DB。
- Published backup passes integrity + schema + basic current-truth validation。
- Explicit Save refreshes backup so backup contains that Save/current truth。
- Backup refresh failure does not damage prior verified backup or current DB。

### AC-03 Rotation interruption

At least two deterministic crash points prove an interrupted refresh cannot leave zero valid recovery copies.

### AC-04 Migration backup gate

- v3 fixture open creates verified pre-migration backup before v3→v4 mutation。
- forced backup failure means schema remains v3 and migration trigger is never reached。
- forced migration failure after backup leaves current v3 usable + backup valid。

### AC-05 Corruption classification

- Deliberately corrupt task-owned current DB is detected as physical integrity/storage failure。
- It is not classified as missing/new Game。
- Unsupported newer schema is not classified as corruption and does not auto-restore old backup。

### AC-06 Disaster recovery

- Corrupt current + valid latest backup → explicit recovery succeeds through staging; corrupt original retained/quarantined。
- Corrupt latest + valid previous → previous can be selected automatically as the newest verified usable generation according to fixed two-slot semantics。
- Both backups invalid/missing → product blocks and does not create blank Game。
- Recovered current reopens with exact backup Game/head/World/Conversation/Save/Recovery truth supported by that backup generation。

### AC-07 Recovery interruption

- Exact-PID kill during staged recovery leaves a retryable state with corrupt original and verified backup preserved。
- Kill after replacement publication/before Runtime apply → reopen sees recovered current coherently。

### AC-08 Normal crash is not corruption

- Kill real production write before COMMIT → reopen quick/integrity check okay, last committed current exact, no disaster-recovery prompt。
- Commit-before-observation crash remains replay/reopen correct。

### AC-09 No fallback truth

Transcript/UI/Prompt/Context/backup are not queried to “merge” or reconstruct partial current DB. Recovery selects one verified whole-DB generation and restores it explicitly.

### AC-10 Regression / export

All current G3/G2 regression suites remain PASS；Windows Desktop export and exact executable/PID launch PASS。

---

## 10. Product Value Acceptance / Owner UAT

Primary product value：

> **长期存档损坏或重复启动时，玩家得到的是清楚、保守、可恢复的行为，而不是空白新局、手工修数据库或两个实例互相覆盖。**

Owner 不测试真实 DB destruction。Agent 必须提供 isolated UAT launcher。

Owner UAT 至少可体验：

```text
launch isolated corrupted-current fixture
→ clear “current data damaged” message
→ shows verified backup availability/time in player language
→ explicit recovery confirmation states newer progress may be lost and corrupt original is preserved
→ recover
→ controlled reopen/continue
→ Narrative / Save / Recovery state matches backup fixture
```

可选再体验 second-instance UX：启动同一 isolated fixture 两次，第二个实例明确提示已有游戏进程，而不是卡死/另开一局。

Product FAIL 条件：

- recovery 文案让玩家以为这是普通 Save/Load；
- 自动覆盖损坏 current 而不保留原件；
- recovery 后出现空白局/半历史/混合两个 backup generations；
- second process 仍能进入可写 gameplay；
- 玩家需要手工找 `.sqlite` 文件才能完成标准 recovery path。

Owner UAT PASS 前不得进入 G3-07。

---

## 11. Validation Order

按成本从低到高：

```text
1. parse / diff-check / focused unit-style scripts
2. isolated integrity + backup lifecycle suite
3. isolated migration-prebackup suite
4. two-process single-writer exact-PID suite
5. backup-refresh crash suite
6. physical-corruption recovery + crash-publication suite
7. G3-05..G3-01 + G2 regressions
8. Windows export
9. exported EXE single-instance/recovery smoke
10. only if needed: real Provider continuation after recovered fixture
11. prepare isolated Owner UAT fixture/launcher
```

真实 DeepSeek 不需要用来证明 SQLite backup；只有为了确认 recovered Conversation → Context → next real Turn product continuity 时才调用，且不得记录 key/Authorization。

所有 destructive filesystem/database tests 必须使用明确 task-owned root，如 `tests/.tmp/g3_06_*` 或等价；cleanup 只删除自身创建路径。

---

## 12. Git / Integration

- 开始记录 `git rev-parse HEAD`、`git status --short`、`git fetch origin`。
- Required formal code base：`bf8c35fdf76c4ea3b8ad2560d93c89c2f84c07b0`；最新 `main` 还应包含 G3-06 `AGENTS.md` 与本 packet。
- 不覆盖 unknown dirty worktree。
- authoritative push 前重新 fetch / compare current `origin/main`；若出现并发代码 commit，先审计是否可 fast-forward/rebase 吸收，不能静默覆盖。
- Implementation commit message 应明确 G3-06 safety/recovery outcome。
- Push 到 `origin/main` 后确认 `HEAD == origin/main`、worktree clean。
- Task packet/document commit 不是 implementation PASS 证据。

---

## 13. Stop / Return Conditions

返回 `BLOCKED`，而不是绕开架构，若：

- godot-sqlite v4.9 `backup_to` 在当前 Godot 4.7.2 Standard / Windows x64 实证不可用或会产生不一致 backup；
- 无法找到具有 process-crash 自动释放语义的 single-writer mechanism，且只能退回裸 PID/time lease；
- recovery publication 在 Windows 上无法做到至少保留 current-corrupt / verified-backup / staged-replacement 三者中的安全可重试组合；
- 必须引入 external service/.NET/C#/DB server 才能完成；
- current authority / main 出现 superseding decision。

不得为赶进度：

- ordinary-copy open WAL DB；
- 自动删除 corrupt original；
- 把 backup 当第二 live truth；
- 在 current DB corruption 时新建空白 Game；
- 用长时间 lease 猜另一个进程是否已死；
- 直接跳到 G3-07。

---

## 14. Final Report Contract

完成后返回：

```text
READY FOR INDEPENDENT REVIEW
```

并报告：

- start/final HEAD、origin/main、worktree；
- pre-implementation matrix path；
- chosen single-writer mechanism + why it has crash-release semantics；
- exact online backup API used；
- backup latest/previous/staging publication semantics；
- backup refresh policy and failure behavior；
- migration-prebackup evidence；
- corruption classification/recovery evidence；
- exact-PID interruption evidence；
- exported EXE evidence；
- regression results；
- safe Owner UAT fixture/launcher path；
- scope check；
- any remaining non-blocking risk for G3-07。

不要宣称 `PRODUCT PASS`、`G3-GATE PASS` 或开始 G3-07。
