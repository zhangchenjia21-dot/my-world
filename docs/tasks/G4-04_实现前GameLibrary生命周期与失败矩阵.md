# G4-04 实现前 Game Library 生命周期与失败矩阵

Status: implementation input
Task: G4-04 Multi-Game Lifecycle / Game Library Foundation

## 1. 冻结的所有权与存储形状

```text
Game Library metadata root（production: user://my-world/game-library）
├─ records/<game_id>.json
└─ current.json

managed Game root（production: user://my-world/games）
└─ <game_id>/game.sqlite

legacy G3 special case
└─ user://my-world/current-game.sqlite（原位、不移动）
```

`records/<game_id>.json` 只包含：

```text
schema_version: game_library_record.v0.1
game_id
display_name
storage_kind: managed | legacy_g3
```

`current.json` 只包含：

```text
schema_version: game_library_current.v0.1
game_id
```

- managed record 的 DB path 只能由受校验的 `game_id` 与 injected managed root 推导，不能记录任意 absolute path。
- legacy record 是唯一 special case；DB path 来自 injected legacy path，production 固定为 G3 `current-game.sqlite`。
- record filename、record `game_id`、current `game_id`、Runtime 从 DB 恢复的 internal `game_id` 必须一致。
- Game Library metadata 不含 World、Timeline、Save、Conversation、Recovery 或 Source binding。
- inventory 只读 record JSON，不打开所有 Game DB；真正 open 前才检查 DB 存在并交叉验证 internal identity。

## 2. 冻结的提交与 Session 顺序

Metadata publication：

```text
complete JSON → same-directory pending sibling → flush → atomic rename
```

Record/current 任一 publish 失败不改 Game DB。current 只在 DB 已存在、Runtime READY 且 `runtime.game_id == record.game_id` 后提交。

Application open/switch：

```text
Continue current
→ read explicit current
→ resolve exact existing record/path
→ Runtime.open_existing_game(path)
→ verify runtime.game_id == record.game_id
→ commit current intent（idempotent）
→ bind Session

Switch A → B
→ cancel Provider/view work
→ close A SQLite + release A writer
→ resolve/open/verify B
→ commit B current
→ bind B Session
```

无 current record 时，Continue 只允许显式 legacy adoption：legacy 文件必须已存在，走正常 G3 open/recovery，成功取得 internal identity 后才创建 legacy record/current。无 DB 时绝不调用历史 creation seam。

## 3. State / Failure Matrix

| Case | Library metadata / resolved path | DB physical / Session / writer | visible result与 durable side effects | retry / restart |
|---|---|---|---|---|
| A fresh Application，无 record/legacy | 无 records/current；legacy path 缺失 | boot 不开 DB；Session ABSENT，无 writer | Main Menu READY；Continue 返回 `no_existing_game`，不创建 DB/metadata | 重启仍为空；只有 G4-06 后续创建或真实 legacy 出现才可继续 |
| B 无 record，legacy 存在 | Continue 选择唯一 legacy special case，但 adoption 前无 record | existing DB 走 `open_existing_game`；writer 仅由显式 Continue 取得 | boot 不读 DB；Continue 验证成功后才进入 C | 失败不预登记；重试重新走 G3 inspection |
| C healthy legacy Continue/adopt | 写 `legacy_g3` record，resolved path 保持原 legacy path；成功后 current=legacy game_id | Runtime 恢复原 game_id/head/Conversation；同一 legacy writer | 进入 Game；DB、WAL、recovery artifacts 不移动/复制/重写为 managed path | record/current publish 可重试；restart 从 metadata 指向原位 DB |
| D legacy corruption/recovery required | corruption 时不先创建 legacy record/current | G3 physical classification 持有 legacy writer；verified backup recovery 保留 quarantine，要求 reopen | 显示原 G3 recovery；绝不 mint blank Game | recovery 后 reopen 成功再 adoption；无 backup 持续 fail-loud |
| E 两个 managed records/DB | A/B 各自 record；path 分别为 `<games>/<id>/game.sqlite` | 两个 SQLite 拥有不同 internal game_id/head/Conversation/recovery root | inventory 两条，互不覆盖；登记不创建 Game | restart 只恢复 metadata；exact open 时验证各自 DB |
| F Continue current A | current=A，resolve 只取 A record，不按 mtime/目录猜 | A existing DB → one writable Session | A READY；current idempotent，无其它 DB side effect | close/reopen 恢复 A exact truth |
| G A→Menu→select/open B | 先关闭 A；随后 resolve B；成功后 current=B | A Provider/View/SQLite/writer 全释放后才取得 B writer | B READY；A truth 不变；切回 A 仍恢复 A | B open 失败时 Application 回 Main Menu，无双 Session |
| H selected DB missing | record 保留但 resolve 返回 `game_database_missing`；current 不切换 | Runtime 不调用，missing path 不创建 SQLite/lock/recovery | fail-loud；既有 active Session 已按 switch 顺序关闭 | 文件恢复后显式重试；不 fallback 其它 Game/legacy |
| I record game_id 与 DB identity mismatch | path 由 record 推导；current 仍为旧值 | Runtime 暂时打开后发现 mismatch，立即 close/release | 返回 `game_identity_mismatch`；不修 record、不切 current | 每次重试仍失败，直到 authoritative storage/record 被明确修复 |
| J B corrupt / A healthy | records/current 独立；B path 损坏不污染 A record | B 走自身 `.recovery`；A DB/backup/writer 不变且仍可独立打开 | B 显示 recovery failure/option；A 可继续 | B recovery 只替换 B；restart A 不受影响 |
| K same Game writer owned elsewhere | record/path 有效 | `open_existing_game` 在该 DB writer lock 返回 `already_running` | fail-loud，不切 current；其它 Game writer 不受影响 | owner release 后重试可成功 |
| L Application restart | records + current 从 JSON 恢复，current 指向同 game_id | Main Menu boot 不打开任何 Game DB/取得 writer | inventory/current metadata 可显示；Session ABSENT | 显式 Continue 时才 open/verify exact DB |
| M record/current publish failure | record fault：旧 record/current 不变；current fault：record/DB 保持，旧 current 保持 | 已验证 Runtime 在 current commit 失败时关闭，writer 释放 | fail-loud；pending 不进 inventory，不把打开但未提交的 Game 当 current | retry 重验 DB identity并原子收敛 |
| N current 指向 missing/invalid record | current JSON 存在但 record 缺失/invalid/ID 不一致 | Runtime 不调用 | `current_selection_invalid`，不猜目录、mtime、legacy | 修复 metadata 后重试；restart 同样 fail-loud |
| O Windows close while active | current metadata已在 open 后提交 | WM close 走 G4-01 close：cancel View/Provider→close SQLite→release writer | Application 退出；accepted truth已逐 Turn durable | 下次启动 current仍指同 Game，可 exact Continue |
| P Continue no Game | 无 current，legacy missing | `open_existing_game` guard 在 Runtime 前阻止历史 first-run mint | Main Menu显示没有可继续 Game；无 SQLite、lock、backup、record | 重试仍无副作用 |
| Q adopted legacy Save/backup/recovery | record只指原位 DB | Save/backup/recovery 继续按 legacy DB path 派生 | 原 game_id/head/Conversation/Save/Recovery 保留 | close/restart/recover不改变 storage_kind/path |
| R task-owned isolation | tests显式注入包含 `g4_04` 的 metadata/games/legacy roots | fixtures只在 `build/g4_04_*` 创建/损坏/恢复 SQLite | 不读取/注册/移动 Owner Game 或 Source Library | 缺少合格 root 时测试先失败；cleanup不越界 |

## 4. 最小实现归层

- `L0_公理层`：record/current schema、safe ID、storage kind、metadata invariants；纯规则无 I/O。
- `L1_器件层`：JSON complete-temp + atomic rename、record/current 文件读取与枚举；只依赖 L0。
- `L2_流程层`：record 注册、inventory/current resolution、显式 current commit；只编排 metadata，不打开 SQLite。
- `L3_外交层`：公开 record projection 与 Game Library API；Application Shell 通过该边界协作。
- `当前游戏会话运行时`：只新增 `open_existing_game(path)` missing guard，保留历史 `open_current_game` 供 test fixture/G3 first-run compatibility。
- `应用壳`：作为 composition root 负责 Runtime identity cross-check、legacy adoption、A-close-before-B-open；不把 gameplay truth写入 Library。

不需要 shared SQLite、production schema migration、Source chooser、Final Create 或 Game pin，故 G4-04 可在当前 scope 独立实施。
