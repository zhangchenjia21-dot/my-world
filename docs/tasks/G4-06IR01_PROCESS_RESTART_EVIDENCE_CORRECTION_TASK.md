---
title: my world｜G4-06IR01 Process Restart Evidence Correction
status: current-task-packet
task_id: G4-06IR01
type: independent-review-correction
owner: Codex
created: 2026-08-30
updated: 2026-08-30
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: 383481631cd3de3c4b9fd2cc47eef911961d8373
highest_implementation_status: READY FOR INDEPENDENT REVIEW
owner_uat_required: false
---

# TASK｜G4-06IR01｜Process Restart Evidence Correction

Owner: **Codex**  
Independent Review owner: **GPT**  
Formal Code Base: `383481631cd3de3c4b9fd2cc47eef911961d8373`

## 1. Finding

G4-06 production mechanism is provisionally sound, but the submitted crash-window evidence does not yet prove the Task Packet's required **process restart** behavior.

Current `tests/g4_06/创建失败窗口重启测试.gd` injects each failure and then constructs a fresh `FinalCreate` object inside the **same Godot process**. This proves durable intent reread / object reconstruction, but it is not equivalent to terminating the process and starting a new one.

Do not redesign production code merely to satisfy this correction unless a real defect is exposed by the new proof.

## 2. Required correction

Add focused evidence that crosses an actual OS/Godot process boundary for all four required durable interruption points:

- `after_intent_publish`
- `after_database_commit`
- `after_library_record_publish`
- `after_current_publish`

For each case, prove:

```text
process A
→ run create_or_resume(..., injected fault)
→ exit process A

process B
→ start with the same task-owned roots
→ reinstall/reopen the same managed Source Library state as needed without deleting creation/Game/Library roots
→ call create_or_resume with the same creation_id + exact same Composition
→ converge to the intent-fixed Game

process C or a second fresh process replay
→ exact replay returns the same Game/local IDs
```

Final assertions per fault point:

- exactly one managed SQLite exists;
- exactly one matching Game Library record exists;
- current points to that same Game;
- `game_id`, root ID, local Player/NPC IDs equal the fixed durable intent identities;
- no second Game is minted;
- valid DB is not deleted/replaced;
- no Provider request / AI Opening occurs.

The test harness may use a controller script that launches phase scripts as separate Godot processes, or equivalent real process-boundary evidence. Do not label fresh-object reconstruction as process restart.

## 3. Scope

Expected scope is tests/evidence only:

```text
tests/g4_06/**
docs/g4_06/**
```

Production changes are **not expected**. If real process restart exposes a production defect, make only the smallest root fix and explain it explicitly; do not broaden architecture.

Do not modify frozen Source fixtures.
Do not start G4-07.

## 4. Regression

After the process-boundary proof, rerun the three existing G4-06 focused suites plus the new process-restart suite. Preserve the existing G3/G4-02R1/G4-03/G4-04/G4-05 regression evidence unless production code changes; if production code changes, rerun affected regression seams.

## 5. Return

Push implementation/evidence to `origin/main` and return:

```text
READY FOR INDEPENDENT REVIEW
START_HEAD
correction commit SHA
evidence/final HEAD
exact process-boundary commands
per-fault result matrix
changed production paths (expected: none)
```

Do not declare G4-06 CLOSED or G4-07 active.
