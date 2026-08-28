---
title: my world｜G3-07 IR-01 Real Provider Marker Evidence Repair
status: current-repair-packet
task_id: G3-07-IR-01
type: repair
owner: KimiCode K3
created: 2026-08-28
repository: zhangchenjia21-dot/my-world
branch: main
repair_base: 4529338728e7db91a2ce73b4dc8eec21c5530d0e
---

# REPAIR｜G3-07 IR-01｜Real Provider B-marker Evidence

## 1. Independent Review result

G3-07 product/persistence implementation has no new blocker. The central disaster-recovery action is correctly moved into the startup-failure overlay, deterministic Save/Load/Recover reality coverage passes, and real DeepSeek continuation after Restore/Recover is present.

Independent Review found one focused evidence defect in `tests/g3_07/真实续玩现实测试.gd`:

```gdscript
const MARKER_R2 := "G307_REAL_LOAD_TURN"
...
var action_r2 := "回到旧塔门口，检查那道划痕旁边是否留下新的脚印。"
...
_check(not recovered_entries.contains(MARKER_R2), ...)
_check(not msgs_r3.contains(MARKER_R2), ...)
```

`MARKER_R2` is never inserted into the R2 alternate-future accepted history. Therefore the two `not contains(MARKER_R2)` assertions are vacuous and cannot prove that the real post-Recover Provider request excludes the displaced alternate future.

This is an evidence/test defect, not a known production persistence defect. The deterministic integrated test already proves A/B marker isolation with `G307_FUTURE_A_ONLY` / `G307_FUTURE_B_ONLY`.

## 2. Required focused repair

Do the smallest change that makes the real-Provider evidence non-vacuous.

Preferred shape:

```text
R2 player input explicitly contains a unique B-only marker
→ R2 becomes accepted/durable
→ Recover Previous Progress returns to Future A
→ recovered accepted Conversation does not contain the B-only marker
→ the next real R3 Provider request does not contain the B-only marker
→ R3 streams successfully, persists, and survives reopen
```

You may reuse `MARKER_R2` by putting it into `action_r2`, or rename it to a clearer `G307_FUTURE_B_REAL_ONLY`; do not add a second artificial persistence mechanism.

Also update `docs/tasks/G3-07_工程验证记录.md` so it only claims evidence actually exercised.

## 3. Validation

Blocking validation for this repair:

1. Run the focused real DeepSeek G3-07 continuation test through the existing product path.
2. R2 must be real Provider accepted and durable with the B-only marker in accepted player history.
3. After Recover, accepted Conversation must contain A truth and exclude that B-only marker.
4. R3 assembled/request messages must contain A truth and exclude that B-only marker.
5. R3 real stream must complete, persist-before-accept, and survive reopen.
6. No API key / Authorization value may be logged or committed.
7. Run the deterministic G3-07 reality test to ensure existing A/B isolation still passes.
8. `git diff --check` and worktree/Git hygiene pass.

Full G3-01..G3-06 regression need not be repeated unless this focused change touches production code or exposes a regression. UI need not be changed.

## 4. Scope

Allowed:

- `tests/g3_07/真实续玩现实测试.gd`
- `docs/tasks/G3-07_工程验证记录.md`
- minimal focused harness adjustment if strictly needed

Prohibited:

- production persistence/schema changes
- UI redesign or further UI polish
- G4 work
- changing Context/Provider semantics to make the test pass
- replacing real Provider evidence with offline-only assertions

## 5. Return contract

After repair, push fast-forward to `origin/main`, ensure worktree clean, and return:

```text
READY FOR INDEPENDENT REVIEW
```

Report start/final HEAD, exact marker insertion, real R2/R3 evidence, reopen evidence, deterministic reality regression, and Git hygiene.
