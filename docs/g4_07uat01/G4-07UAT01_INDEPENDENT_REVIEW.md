# G4-07UAT01 — Owner Launch Freshness Correction Independent Review

Status: **PASS / CLOSED**
Reviewer: GPT
Date: 2026-08-31
Reviewed implementation/evidence commit: `a250c60fa13043ed129dc68ed69048fea6abad5d`

## Verdict

> **G4-07UAT01 Owner Launch Freshness Correction — Independent Review PASS / CLOSED.**

The canonical Owner launch path now refuses stale Windows exports. `run-game.cmd` continues to invoke `run-game.ps1`; the PowerShell launcher hashes the required tracked product-build inputs (`src/**`, `addons/**`, `project.godot`, `export_presets.cfg`), validates a task-owned freshness stamp, rebuilds the tracked `Windows Desktop` export when missing/stale, and launches only after the refreshed EXE/PCK are verified.

## Reviewed properties

- Production diff is limited to `run-game.ps1`; gameplay/UI/backend/Source contracts are unchanged.
- Missing/stale export triggers current-checkout rebuild.
- Current export skips unnecessary rebuild.
- Export failure invalidates stale launch eligibility and fails loud; no stale fallback is possible.
- Input mutation during export is detected and launch is refused.
- `.env.local` whitelist remains limited to `DEEPSEEK_API_KEY` and `MY_WORLD_DEEPSEEK_MODEL`.
- Provider secrets are not injected into the export process and are restored after game exit.
- `build/` remains ignored; no binaries or Owner AppData are committed.
- Canonical `run-game.cmd` desktop evidence reaches the current G4-07B seven-step New Game Wizard rather than the historical disabled placeholder.
- Focused G4-07B regression remains green; production schema remains v4.

## Owner local-data boundary

The Independent Review can validate the launcher and repository state, but the Owner production Source Library lives outside Git. UAT resumes only when the Owner's normal product UI can actually enumerate installed Source packages. The immediate field check is:

- New Game shows World `天下未定`;
- New Game shows World `埃瑟维亚`.

If the inventory is still empty, that is an Owner-local Source installation/bootstrap issue, not a reason to reopen G4-07UAT01.

## Gate transition

`G4-07UAT01` is closed. Parent `G4-07 First Playable A` returns to **OWNER UAT ACTIVE**. Engineering PASS still does not constitute G4-07 Product PASS.
