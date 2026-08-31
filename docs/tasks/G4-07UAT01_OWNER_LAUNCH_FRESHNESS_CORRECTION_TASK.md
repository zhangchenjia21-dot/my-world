---
title: my world｜G4-07UAT01 Owner Launch Freshness Correction
status: current-task-packet
task_id: G4-07UAT01
type: owner-uat-blocker-correction
owner: Codex
reviewer: GPT
created: 2026-08-31
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: 1bd0d414dfe8ed5a7781d9db6813317d2f20bf91
parent_task: G4-07 First Playable A
owner_uat_required: false
highest_implementation_status: READY FOR INDEPENDENT REVIEW
---

# TASK｜G4-07UAT01｜Owner Launch Freshness Correction

## 1. Why this task exists

G4-07A and G4-07B have both passed GPT Independent Review and G4-07 is at Owner UAT.

Owner launched the product through the repository-native `run-game.cmd` path and observed the old UI (`New Game` still unavailable).

Root cause verified from current `main`:

- `run-game.cmd` delegates to `run-game.ps1`;
- `run-game.ps1` launches `build/windows/my-world.exe`;
- `build/` is intentionally gitignored;
- the launcher only checks whether the EXE exists, not whether it is older than the current checkout;
- therefore a previously exported executable can silently remain stale after source changes.

This is an Owner UAT launch-path freshness defect, not a G4-07 product-semantic defect.

## 2. Outcome

Make the normal Owner launch path converge to the **current checkout** without requiring the Owner to remember a manual export step.

Target:

```text
run-game.cmd
→ run-game.ps1
→ determine whether Windows Desktop export is missing/stale
→ when missing/stale, export current checkout with Godot using preset `Windows Desktop`
→ verify export succeeded and executable exists
→ launch that executable with existing provider environment handling
```

A stale local binary must never be silently treated as current.

## 3. Ownership / scope

Primary owner: **Codex** (build/launch mechanism).

Expected production/tooling scope:

- `run-game.ps1`
- `run-game.cmd` only if genuinely needed
- narrow task-owned tests/docs

Do not modify G4-07A/G4-07B gameplay/UI semantics merely to solve this launcher issue.

## 4. Frozen behavior

### Freshness inputs

At minimum, Windows export freshness must account for product-build inputs that can change the executable/PCK:

- `src/**`
- `addons/**`
- `project.godot`
- `export_presets.cfg`

Do not make docs/tests alone force a rebuild unless they are product export inputs.

A robust alternative is allowed if it is simpler and more reliable (for example a deterministic build stamp tied to current checkout), but do not rely on Git-tracked build binaries because `build/` remains intentionally ignored.

### Export mechanism

Use the installed Godot 4.7.2 Windows executable already established by repository tooling. Reuse existing local path conventions where possible; do not introduce a second engine installation contract.

Use the tracked `Windows Desktop` export preset and target `build/windows/my-world.exe`.

Do not print or expose `DEEPSEEK_API_KEY`.

### Failure semantics

If Godot is missing, export fails, or the expected executable is not produced:

- fail loud;
- do not fall back to launching a stale executable;
- show a concise actionable message.

### Normal launch

If export is current, do not rebuild unnecessarily.

After export/current verification, preserve the existing `.env.local` whitelist and environment restore behavior, then launch `build/windows/my-world.exe` as before.

## 5. Required evidence

At minimum prove on Windows/local repository path:

A. No export exists → `run-game` builds current Windows Desktop export and launches it.

B. Export exists and is current → `run-game` does not unnecessarily rebuild.

C. A product source file becomes newer/changes after export → next `run-game` detects stale state, rebuilds, and launches refreshed product.

D. Export command fails → launcher fails loud and does not launch stale executable.

E. The refreshed launched UI exposes the G4-07B New Game path (i.e. no historical disabled-placeholder behavior).

F. Provider secrets remain unprinted and environment is restored after exit.

G. `build/` remains gitignored; no binary should be committed.

## 6. Regression floor

- `run-game.cmd` remains the canonical Owner product launch path.
- existing `run-local.*` developer/editor path need not change unless a shared helper is clearly justified.
- G4-07B production UI/backend files should remain unchanged unless a concrete launcher-driven defect proves otherwise.

## 7. Return

Return only:

> READY FOR INDEPENDENT REVIEW

Include:

- START_HEAD
- implementation/evidence SHA
- changed paths
- exact freshness rule
- exact export command/preset
- evidence A–G
- confirmation that no product gameplay/backend semantics changed
- confirmation that no build binary was committed

Do not declare G4-07 Product PASS. Owner UAT resumes only after GPT reviews this correction.
