# G4-06IR01 Real Process Restart Evidence

Status: READY FOR INDEPENDENT REVIEW candidate  
Task: G4-06IR01 Process Restart Evidence Correction  
Start HEAD: `ee71794204f6a163a7a8dd38ad19ed3d892b2eab`  
Formal Code Base: `383481631cd3de3c4b9fd2cc47eef911961d8373`  
Production paths changed: **none**

## Correction

The original `创建失败窗口重启测试.gd` remains a useful same-process fresh-object test, but it is not process-restart evidence.

IR01 adds:

- `tests/g4_06/真实进程重启阶段.gd`: one phase per Godot invocation;
- `tests/g4_06/运行真实进程重启验证.ps1`: launches Process A, Process B and Process C separately for every fault point, then verifies their durable proof JSON.

Each phase records `OS.get_process_id()`. The controller requires three distinct PIDs, so no RefCounted object, GDScript static state or Godot process memory crosses the fault/resume/replay boundaries.

## Exact command

```powershell
& 'D:\AI\Projects\my-world\tests\g4_06\运行真实进程重启验证.ps1' `
  -TestRoot 'D:\AI\Projects\my-world\build\g4_06_ir01_process_restart_final'
```

Result: exit `0`, `G4-06 IR01 PROCESS | done failures=0`.

## Per-fault process-boundary matrix

| Fault | Process A PID / durable state | Process B PID / resume | Process C PID / replay | Fixed Game |
|---|---|---|---|---|
| `after_intent_publish` | `25072`; intent only, DB=0, record=0, no current | `30288`; DB=1, record=1, current exact | `22308`; same IDs, DB=1, record=1 | `game-e61e4be2b994eea7774f1d3377dfc9c7` |
| `after_database_commit` | `30756`; DB=1, record=0, no current | `35452`; same DB, record/current published | `7732`; same IDs and DB hash | `game-6317cafa72cb14c13822f5f026313f9e` |
| `after_library_record_publish` | `20032`; DB=1, record=1, no current | `33800`; same DB/record, current published | `39284`; same IDs and DB hash | `game-242c50c829b14a1bde32d4c824bcea6e` |
| `after_current_publish` | `22480`; DB=1, record=1, current exact | `34148`; created marker completed | `19304`; same IDs and DB hash | `game-54be32982bbae6d31c30347c22aa46ad` |

For every row, Process B and Process C prove:

- `game_id`, root ID, local Player ID and local NPC IDs equal the immutable intent values from Process A;
- exactly one managed SQLite, one inventory record and one matching current selection;
- root Timeline snapshot exact-matches `intent.initial_setup`;
- accepted Conversation count is zero, therefore no AI Opening turn exists;
- Process B → C database SHA-256 is unchanged;
- where Process A already had a valid DB, Process A → B database SHA-256 is also unchanged, proving retry did not replace or destructively rebuild it.

No Provider proof is two-part and non-simulated:

1. the controller fails if the production `src/最终建局/**/*.gd` module contains a Provider/AI Opening dependency or call reference;
2. each reopened database has an empty durable accepted Conversation.

## Focused regression

After the real process suite, the three existing G4-06 focused suites were rerun:

```powershell
& $godot --headless --path $project --script 'res://tests/g4_06/原子最终建局现实测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_06_ir01_existing_create'
& $godot --headless --path $project --script 'res://tests/g4_06/创建失败窗口重启测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_06_ir01_existing_object_restart'
& $godot --headless --path $project --script 'res://tests/g4_06/创建冲突与发布失败测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_06_ir01_existing_failure'
```

All three exited `0` with `failures=0`.

## Scope / finding outcome

- No production defect was exposed by actual process restart.
- No production code, Source fixture or production schema was changed.
- G4-06 is not declared CLOSED; G4-07 was not started.
