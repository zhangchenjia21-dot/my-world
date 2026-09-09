# TASK｜MW-031｜V0 Core Reality Gate Build Prep

Type: **UAT-support / build-prep**  
Work Item: **MW-031**  
Primary Implementer: **Codex**  
Reviewer / UAT coordinator: **GPT**  
Owner UAT authority: **Owner**  
Status: **AUTHORIZED FOR CODEX**  
Task Branch: `mw-031-v0-core-reality-gate-prep`  
Required task worktree: `D:/AI/Projects/.worktrees/my-world/mw-031-v0-core-reality-gate-prep`  
Owner canonical checkout: `D:/AI/Projects/my-world`  
Reviewed implementation main / Build Base: `69ac2030b90f4165deb2ecb5302e3743422af585`  
Return ceiling: **OWNER LAUNCH READY**

## 1. Product outcome

Prepare the exact reviewed G6 V0 core build for the Owner's concentrated Package-7 Reality Gate.

After this task, Owner should be able to launch the current reviewed game from the existing path:

`D:/AI/Projects/my-world/run-game.cmd`

The build must contain Packages 2–6 through reviewed MW-030 and must be freshly exported from the exact reviewed implementation main.

This task does **not** change product behavior and cannot declare Product PASS.

## 2. Why now

MW-030 has independently passed Engineering Review and is integrated. G6 has no further planned core implementation package before the Owner Reality Gate.

Package 7 needs one trustworthy Owner build whose exact checkout SHA and PCK hash can be frozen in the UAT record.

## 3. Authority / freshness

Before touching the Owner checkout:

1. fetch implementation `origin/main`;
2. fetch governance `Vibe-Coding/main`;
3. verify implementation `origin/main` is exactly `69ac2030b90f4165deb2ecb5302e3743422af585`;
4. verify current governance still places the project in Package-7 UAT prep and does not contain a superseding product/code decision;
5. if implementation main differs, STOP and report rather than guessing or building a different tree.

The task branch exists only to carry this packet/evidence. **Do not install the task branch into the Owner checkout.** Owner build source is exact reviewed `origin/main`.

## 4. Owner checkout protection — mandatory

The Owner checkout may contain legitimate local modifications and untracked files.

Before sync, record:

- `git rev-parse HEAD`;
- `git status --short`;
- every modified/untracked file path;
- SHA256 of every existing modified/untracked regular file that can be read;
- whether any tracked local change touches files changed between current local HEAD and reviewed `origin/main`.

Protection rules:

- no `git reset --hard`;
- no `git clean`;
- no force checkout/restore over Owner files;
- no automatic deletion/move of unknown files;
- no destructive stash workflow;
- do not overwrite an unknown local file merely because it is generated-looking;
- if a local tracked change conflicts with the required fast-forward, STOP and report the conflict.

If safe, advance the Owner checkout only through a normal non-force fast-forward to exact reviewed `origin/main`.

After sync, re-record status and SHA256 and prove all pre-existing Owner local/untracked files are byte-identical.

## 5. Build prep

From the safely synchronized Owner canonical checkout:

1. run final Godot 4.7.2 import;
2. produce a **fresh Windows export** using the repository's existing build/export path;
3. run `run-game.ps1 -ValidateExportOnly`;
4. verify export freshness corresponds to the current reviewed product inputs;
5. verify at least these exist and are nonempty:
   - `build/windows/my-world.exe`
   - `build/windows/my-world.pck`
   - `build/windows/libgdsqlite.windows.template_debug.x86_64.dll`
6. record byte length, UTC mtime and SHA256 for EXE / PCK / SQLite DLL;
7. verify `run-game.cmd` resolves to the current exported game path.

Do **not** launch the game during build prep.

## 6. Strict non-scope

Do not:

- edit production code;
- repair tests or G3 Context debt;
- change UI/preferences/product settings;
- create or edit real Game/Source data;
- run a real Provider request;
- perform Owner UAT;
- install task-branch docs into the Owner checkout;
- declare G6/Product PASS.

If import/export exposes a real build blocker, report it. Do not opportunistically fix it in this task.

## 7. Evidence integrity

The final evidence must establish all of:

- `origin/main == 69ac2030b90f4165deb2ecb5302e3743422af585`;
- Owner local `HEAD == origin/main` after safe sync;
- pre-existing Owner local/unknown files remain byte-identical;
- final import succeeded;
- fresh Windows export succeeded;
- `ValidateExportOnly` succeeded;
- exported artifacts exist/nonempty;
- PCK is freshly rebuilt from the reviewed checkout;
- game was not launched;
- Provider calls = 0;
- no real Game/Source/settings/preference mutation occurred.

## 8. Optional repository evidence

After successful prep, write a concise evidence return at:

`docs/mw031/MW-031_BUILD_PREP_RETURN.md`

on this task branch and commit/push it.

That file is evidence only. Do not merge the task branch into `main`; the reviewed product main is already the build source.

## 9. Return protocol

Return exactly the status:

**OWNER LAUNCH READY**

and include:

- implementation `origin/main` SHA;
- Owner checkout HEAD before/after;
- Owner `git status --short` before/after;
- local-file preservation result / hashes;
- Godot import result;
- fresh export + ValidateExportOnly result;
- EXE/PCK/DLL size + UTC mtime + SHA256;
- PCK freshness/product-input evidence;
- launch command/path;
- confirmation game not launched;
- confirmation Provider calls = 0;
- confirmation no Owner real Game/Source/settings/preferences were modified.

Do not claim `READY FOR INDEPENDENT REVIEW`, `Product PASS`, or `G6 CLOSED`; this task's only successful ceiling is **OWNER LAUNCH READY**.