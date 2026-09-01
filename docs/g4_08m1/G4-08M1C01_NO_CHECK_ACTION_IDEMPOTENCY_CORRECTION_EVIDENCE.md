# G4-08M1C01 NO_CHECK Action Idempotency Correction Evidence

Status: `READY FOR INDEPENDENT REVIEW`

Start HEAD: `e0312d9cd7987f35891d988e4b1d573cc7d7be27`

Implementation commit: `361508497a4b1344f9326984749bb10a8c47306c`

## Correction boundary

This correction changes only the Public d20 action-resolution mechanism and task-owned tests. It adds no UI path, Source semantics, generic command framework, Provider envelope/message change, or SQLite schema migration.

The durable replay identity is:

```text
no-check-SHA256(game_id + U+001F + caller-owned action_id)
```

It is stored separately from real checks at:

```text
expansion_runtime.public_d20_no_check_actions
```

Each frozen record owns `resolution_id`, `action_id`, exact `player_text`, `branch = NO_CHECK`, validated `reason`, validated `narrative`, `conversation_base_count`, and acceptance state/index. It contains no dice fields and is not projected into Provider Context.

Durable ordering is:

```text
strictly validated NO_CHECK envelope
→ v4 World CAS freezes exact NO_CHECK resolution
→ durable Conversation accepts exact Player/GM pair
→ v4 World CAS publishes accepted marker
```

Replay checks both real checks and NO_CHECK records before calling Provider. The same action identity in both stores fails loud. Same identity plus changed Player text returns `action_payload_conflict`. Window-B recovery requires both exact `player_text` and exact stored GM `narrative` at the frozen Conversation slot before publishing the final marker.

## Evidence A–F

The task-owned focused suite `tests/g4_08m1/NO_CHECK行动幂等修复测试.gd` completed with `failures=0` and proved:

- A: first NO_CHECK execution used exactly one Provider request, zero RNG, one durable Conversation turn, one independent replay marker, and zero fake checks;
- B: same-process replay returned `already_accepted` with zero Provider/RNG/new Conversation;
- C: close plus fresh runtime existing-only reopen returned the same accepted action with zero Provider/RNG/duplicate Conversation. A separate controller also ran Process A accept and Process B replay in distinct Godot/OS PIDs `31256` / `31736`, preserved the exact Game and `resolution_id`, kept one Conversation turn, and proved the accepted replay did not change the SQLite file hash;
- D: same `action_id` plus changed Player text failed with `action_payload_conflict` before side effects;
- E: Provider transport failure and invalid envelope created no false marker; the same action remained retryable;
- F1: task-only lost-ACK proxy committed the frozen marker but left Conversation unchanged; fresh-runtime retry accepted the stored narrative once with `provider_calls = 0` and zero RNG;
- F2: task-only lost-ACK proxy left exact Conversation accepted while final marker remained false; fresh-runtime retry matched the exact Player/GM slot, published the marker, and created no Provider/RNG/duplicate turn.

## Evidence G — neighboring regressions

All commands ran on Windows with Godot `4.7.2-stable` and exited `0`:

```powershell
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --log-file 'D:\AI\Projects\my-world\build\g4_08m1\c01-focused.log' --script 'res://tests/g4_08m1/NO_CHECK行动幂等修复测试.gd' -- '--root=D:/AI/Projects/my-world/build/g4_08m1/c01-focused'

& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --log-file 'D:\AI\Projects\my-world\build\g4_08m1\c01-existing.log' --script 'res://tests/g4_08m1/公开D20机制测试.gd' -- '--root=D:/AI/Projects/my-world/build/g4_08m1/c01-existing-final'

& 'D:\AI\Projects\my-world\tests\g4_08m1\运行真实进程重启验证.ps1' -Root 'D:\AI\Projects\my-world\build\g4_08m1\c01-process-regression'

& 'D:\AI\Projects\my-world\tests\g4_08m1\运行NO_CHECK真实进程重启验证.ps1' -Root 'D:\AI\Projects\my-world\build\g4_08m1\c01-no-check-process'

& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --log-file 'D:\AI\Projects\my-world\build\g4_07a\c01-regression.log' --script 'res://tests/g4_07a/首次开场运行时聚焦测试.gd' -- '--root=D:/AI/Projects/my-world/build/g4_07a/c01-regression'

& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --log-file 'D:\AI\Projects\my-world\build\g4_07b\c01-regression.log' --script 'res://tests/g4_07b/可玩界面整合测试.gd' -- '--root=D:/AI/Projects/my-world/build/g4_07b/c01-regression'

git diff --check
```

The existing G4-08M1 suite preserved CHECK_REQUIRED proposal freeze, Program RNG, Provider-failure restart, exact losing-result reuse, accepted replay, Afterglow cross-world capability, and no-Expansion routing. The three-process suite preserved exact `check_id`, roll `2`, failure outcome, and one accepted Conversation with no reroll. G4-07A and G4-07B both completed with `failures=0`.

## Schema, Provider, UI, and limitations

- SQLite schema remains `v4 → v4`; no persistence schema file or migration changed.
- Real DeepSeek was not rerun because neither adjudication envelope nor Provider message construction changed. Existing real Provider evidence remains applicable.
- UI paths changed: none.
- The new marker is bounded Game-local World audit/replay state. It is deliberately not a generic idempotency framework and is not appended to ordinary Provider Context.
- Lost-ACK Window A/B injection remains task-only and uses close/fresh-runtime reopen over the same durable SQLite; production code contains no fault-injection flags. Accepted NO_CHECK replay additionally has a two-distinct-Godot-process proof, and neighboring CHECK_REQUIRED retains its three-distinct-Godot-process proof.
