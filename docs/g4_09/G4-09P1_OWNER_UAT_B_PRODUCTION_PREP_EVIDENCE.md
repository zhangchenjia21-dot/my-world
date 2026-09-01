# G4-09P1 Owner UAT B Production Preparation Evidence

Status: `READY FOR INDEPENDENT REVIEW`

Start HEAD: `472d6877b0f368d60ec859d437866c64213771c0`

Formal Code Base: `08287d28a9cacfc7795c7c7a35ef4739ff9faf2c`

## Production Source preparation

The explicit opt-in utility is:

`scripts/G4-09P1_Owner生产Source准备.gd`

It constructs `SourceLibrary.new()` with no root override and invokes only:

```gdscript
install_expansion_pack("res://tests/fixtures/g4_08m1/判定与检定_公开d20")
list_current_sources()
get_current_expansion("exp.check_core.public_d20")
get_exact_expansion("exp.check_core.public_d20", fingerprint)
```

The package/root are fixed; the utility does not scan directories, import arbitrary Source, access Game APIs, or accept a managed-library root argument. Without `--confirm-owner-production-source-prep` it fails before constructing the production library.

Resolved production root:

```text
C:/Users/MRVHREVO/AppData/Roaming/Godot/app_userdata/my world/my-world/source-library
```

First run returned `installed`; exact replay returned `already_installed` with the same inventory and fingerprint.

Verified Public d20 identity:

```text
display_name            判定与检定：公开 d20
asset_id                exp.check_core.public_d20
asset_type              expansion_pack
version                 0.1.0
generation_fingerprint  e40bf3cb1059a4952d4230ae624fc3a0ba9bc705e279b13fef8cd1e795ca5ec1
capability_id            action_check.public_d20.v1
capability_slot          action_resolution
current lookup          exact match
exact lookup            exact match
```

Public inventory verification returned:

```text
World current generations      2
Character current generations  6
Expansion current generations  1
Public d20 present             true
```

The two World currents are `汉末三国：天下未定` and `埃瑟维亚：诸界余辉`; the six Character currents include `刘备`, `曹操`, `孙权`, `莉维娅·塞兰`, `阿德里安·维尔克`, and `杜恩·石痕`. These are observed production facts, not normalized task expectations.

Owner games modified: **no**. The utility neither imports nor calls Game Library, Final Create, runtime, persistence, or SQLite code.

## Owner launch freshness

Command:

```powershell
& '.\run-game.ps1' -ValidateExportOnly
```

The first invocation detected a stale/missing export, rebuilt tracked preset `Windows Desktop`, and published freshness stamp input hash:

```text
be06ab84d9b07ed69fe4bb83df685f665562f1421619cb6452aeec38b1cee8c5
```

The second invocation returned:

```text
Windows export is current; skipping rebuild.
Windows export freshness validation completed; game launch skipped by explicit validation mode.
```

No `.env.local` value or API key was printed. The ignored export therefore contains the current checkout, including accepted G4-08B/BC01 UI code, without introducing a competing launcher.

The export scan reported duplicate UID warnings from older ignored `build/` test artifacts. Export and freshness verification succeeded; the second validation cleanly reused the current artifact.

## Pre-UAT smoke

Command:

```powershell
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --log-file 'D:\AI\Projects\my-world\build\g4_09p1\g4_08b-smoke.log' --script 'res://tests/g4_08b/公开D20界面整合测试.gd' -- '--root=D:/AI/Projects/my-world/build/g4_09p1/g4_08b-smoke'
```

Result: exit `0`, `failures=0`.

The accepted task-owned vertical proves:

- Wizard exact Public d20 selection and Review projection;
- `CHECK_REQUIRED` → Program RNG/result → visible card → GM continuation;
- `NO_CHECK` → one Provider call, zero RNG, no mechanic card;
- retry/reopen no-reroll;
- Save/Continue/Load card reconstruction;
- no-Expansion and unsupported-capability fail-loud regressions.

Real Provider rerun: **no**. G4-09P1 changes only an Owner preparation script and UAT/evidence documentation; Provider messages, envelope semantics, gameplay, and UI code are unchanged from the accepted real DeepSeek evidence.

## Owner UAT handoff

Product-only instructions:

`docs/g4_09/G4-09UATB_Owner产品验收说明.md`

This preparation does not declare G4-09 PASS, G4-08 Product PASS, Owner UAT PASS, or G4-GATE PASS.
