# G4-06 Atomic Final Create Implementation Evidence

Status: READY FOR INDEPENDENT REVIEW candidate  
Start HEAD: `7eec660fa67fd4715b090290ca174efe59f39b58`  
Implementation commit: `1457ca18c4ef19fd5757844820630649ea85fe6b`  
Production SQLite schema changed: **no**

## Implemented protocol

```text
exact frozen Composition re-review + exact Source projections (no durable side effect)
→ immutable creating intent / fixed creation, Game, root and local entity IDs
→ schema-v4 initial Game transaction with setup envelope as root World snapshot
→ DB internal game_id + immutable root snapshot verification
→ verified Game Library record
→ current selection
→ created marker
```

Intent and marker publication use complete sibling temp files plus same-volume rename. Retry inspects durable steps and moves forward; it never deletes a verified Game DB. The existing opaque World document owns the initial setup envelope, so no physical production schema migration was required.

The composition SHA-256 canonical payload includes exact World pin, explicit Entry ID or JSON `null`, empty expansions, exact Player pin, canonically sorted Guaranteed NPC pin set, display name, control mode and exact opening supplement. It excludes UI ordering/focus, current pointers and filesystem paths.

## Focused production-seam proof

Commands:

```powershell
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_06/原子最终建局现实测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_06_create_final2'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_06/创建失败窗口重启测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_06_restart_final2'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_06/创建冲突与发布失败测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_06_failure_final2'
```

All three exited `0`.

Critical evidence rows:

- Han 208: exact World Entry, 刘备 `han-208`, 孙权 `han-208`, exact pins and settings survived; `liu-bei-220` / `e220-snapshot` were absent.
- Afterglow: exact `t0-1287-public-works` scenario and exact three-character canonical cast materialized without a global historical mode.
- Non-temporal IR01: `opening-harbor-market` materialized; profile-free Character remained always-safe-only and no fake profile appeared.
- Explicit no Entry: durable `selected_entry_id=null`; World `selected_entry={}` and Character `selected_profile={}`; section counts equal top-level counts.
- Han 229 + 刘备: `character_temporal_incompatible` before intent, Game DB or Game Library side effects.
- Source X/current Y: durable provenance fingerprint remained the selected X.
- Same identity/same payload: same Game and local IDs, one SQLite and one record. Same identity/changed payload: `creation_payload_conflict`, zero mutation.
- Distinct creation identities with identical payload: distinct Games and distinct local Character IDs.
- Wrong internal DB identity: `database_identity_conflict`; foreign DB remained present and unmodified.
- Selected Source tamper: `exact_generation_unavailable` before intent/DB/Library.
- Game Library record/current injected publication failures replayed forward without deleting the valid DB.
- single-writer conflict failed loud as `already_running`, then converged after release.
- Initial accepted Conversation count was `0`; no Provider request and no AI Opening were produced.

## Crash-window restart convergence

Fresh-object retry passed for all four required injected windows:

| Fault point | Durable state at interruption | Retry result |
|---|---|---|
| after intent publish | immutable intent only | one fixed DB / record / current |
| after DB commit | intent + verified initial SQLite | same DB reused; record/current published |
| after Library record | intent + DB + record | same record reused; current published |
| after current publish | intent + DB + record + current | created marker completed |

Every row also proved a subsequent exact replay preserved the same Game/local identities and inventory remained one DB + one record + matching current.

## Regression evidence

All commands used Godot `4.7.2.stable.official` and exited `0` unless explicitly noted as expected injected SQL failure output inside a passing suite.

- G3: `持久化离线测试.gd`, `世界持久化流程测试.gd`, `查询失败传播测试.gd`, `持久化迁移与生命周期测试.gd`, `存档恢复持久化测试.gd`, `恢复时间线持久化测试.gd`, `数据库安全流程测试.gd`.
- G4-02R1: v0.2-r2 reality, negative and optional-temporal evidence suites.
- G4-03: reality, failure/tamper and fresh-process restart suites.
- G4-04: metadata, fresh-process restart, multi-Game lifecycle and Legacy/recovery isolation suites.
- G4-05R2: Composition, Application Wizard, full-fidelity Wizard and Windows layout suites.
- Godot editor parse: `--headless --editor --quit`, exit `0`.
- `git diff --check`: pass.
- `git diff --name-only -- tests/fixtures/g4_02r1/full_fidelity`: empty; frozen 2 World + 6 Character fixtures unchanged.

The layout regression was also run non-headless on Windows and exited `0` using Vulkan 1.4.341 / NVIDIA GeForce RTX 4070 Laptop GPU. Screenshots are task-owned build evidence under `build/g4_06_regress_g4_05_layout_windows/shots/`. G4-06 changed no UI production files.

## Known limitations / scope boundary

- Terminal state is `created`, not playable; no Provider call, AI Opening, G4-07 context/conversation work or Product PASS is claimed.
- This backend packet exposes Final Create through `原子最终建局公开接口.gd`; the preserved G4-05 Wizard regression still shows its historical disabled placeholder because no G4-06 UI wiring was requested from the backend owner.
- Journal reconciliation occurs on explicit `create_or_resume` retry. A background scanner/repair platform, backup browser, cloud sync and destructive cleanup are out of scope.
- The setup envelope is deliberately an evolvable starting snapshot, not a frozen universal World/Character ontology.
