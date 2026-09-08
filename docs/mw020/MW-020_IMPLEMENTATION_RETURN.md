# MW-020 — Core Context Budget Accounting Implementation Return

Status: **READY FOR INDEPENDENT REVIEW**

Date: 2026-09-08

## Exact source identity

- Branch: `mw-020-context-budget-accounting`
- Worktree: `D:/AI/Projects/.worktrees/my-world/mw-020-context-budget-accounting`
- Formal base / refreshed implementation main: `f5dea508be2db5904c2d5ebc726b6f130d8c57fe`
- Starting HEAD: `3eb663b1a348f41c98b8e3be9ac4796e8ebedb9a`, clean. Only the published Task Packet is added above the formal code base.
- Implementation HEAD: `b423a5b3c7cdecd1d836920f1b053e3675a3bb0e`.
- Final candidate: the evidence-only commit containing this return, directly after implementation HEAD. Exact SHA is provided in the final delivery message after commit creation; production/tests are identical to implementation HEAD.
- Governance main at initial and pre-push refresh: `e749710545d391ed0e4f33cc8f00859c1e4a3216` (also the packet shaping base).

Read current implementation/governance AGENTS, Owner collaboration preferences, status v17.8, roadmap v4.3, the frozen Context Budget Accounting correction, development-audit adoption, Task Packet and the relevant constructors/validators/projector/tests. Both mains were refreshed again before push; no authority changed. Current v17.8/Task Packet supersede AGENTS' stale stage tables as explicitly directed.

Owner canonical `D:/AI/Projects/my-world` stays on main at `782daf65348f484d636d46260ac2374559cf554d`; its existing `.gitignore` change and ten untracked screenshot imports remain untouched. Existing worktrees were inspected and retained. No main merge, reset, clean, force, Provider call or Owner installation.

## Root cause and correction

The reproduced root cause matches the frozen decision: `projected_chars` counts world-change bodies, omits heading/block separators in initial selection, omits actual framing before Knowledge, then adds those same bodies again to already assembled text before Agency/Evolution.

Only `src/世界回合/L1_器件层/世界回合上下文投影器.gd` changes in production (28 insertions / 22 deletions):

- Build each candidate initial world-change section with the real heading and joined blocks, and check that complete String's length. Keep existing newest-first selection, break-on-nonfit and chronological rendering.
- Remove the parallel body counter. Pass actual assembled text through Knowledge → Agency → Evolution.
- A small local `_join_section` uses exactly two newlines between two nonempty sections, none before the first section and none for an omitted section. Both budget checks and assembly use it, so framing cannot drift between measured and rendered text.
- A later section is accepted iff the complete proposed joined text is <=16000. Oversized sections still return their existing empty result; no partial section or new truncation policy.

`MAX_PROJECTED_CHARS=16000`, recent turn/event/actor limits, latest matching Agency cycle, existing Agency action display truncation, section ordering, validators/hash filtering and result metadata rules stay unchanged. No prompt, semantic retrieval/ranking/summary, Provider lane, storage/schema or other feature changes. No layer-debt refactor. The helper is inside the existing L1 mechanism; no new imports/dependencies, upward calls or cross-module internal access were introduced. Comments explain the budget/framing invariant.

Bound proof: initial text is empty or a measured candidate <=16000. Each later step either keeps that same text or accepts exactly the joined text it checked against 16000. By induction, returned `context_text.length()` cannot exceed the unchanged ceiling. This also avoids adding spurious leading newlines when the first present section is Knowledge/Agency/Evolution.

## Deterministic evidence

Focused tests use production `Rules.build_*` constructors and record validators. World fixtures contain four accepted turns × eight changes, each <=512 Unicode characters. Knowledge, Agency and Evolution records also pass their real validators. Expected strings independently specify headings/newlines; they do not reuse private projector counters/helpers.

On the unchanged starting production code, the final same-test baseline run yields **178 checks / 21 failures**, without script errors. After the narrow fix, **178 checks / 0 failures**. Committed baseline/current logs and 18-case measurements retain both sides. Text evidence logs normalize line endings/trailing whitespace only; original process logs remain under task `build/`.

| Case | Corrected result |
|---|---|
| World + Knowledge exactly fits | 16000, Knowledge retained |
| Same class would assemble 16001 | Knowledge omitted, returned 15638 |
| World + Knowledge + Agency exactly fits | 16000, Agency retained |
| Same class would assemble 16001 | Agency omitted, returned 15908 |
| World + Knowledge + Agency + Evolution exactly fits | 16000, Evolution retained |
| Same class would assemble 16001 | Evolution omitted, returned 15744 |
| Initial changes including heading/separators =16000 | All four blocks retained |
| Initial changes would be 16001 | Oldest whole block omitted, newest three retained, returned 11861 |
| Knowledge does not fit but Agency exactly fits | Knowledge omitted, Agency retained, returned 16000 |
| Only Knowledge / Agency / Evolution exists | Exact standalone text, no extra leading separator |

The audit-equivalent test uses **real isolated SQLite**, production Runtime mutation commits, Save, close/reopen and actual `Opening.assemble_continuation_messages()`:

```text
10,000 characters of valid current world-change text
+ a durable NPC Agency action
→ baseline: action omitted; later GM assembly lacks it
→ corrected: 10,093 characters; action present in later GM request assembly
→ Restore to pre-Agency Save: 10,000 characters; restored-away action absent
```

Other focused checks prove all four families reject changed accepted hashes and absent/displaced-future turns, projection never mutates its input, absent Agency/Evolution add no fake sections, and empty world / legitimate `hold` remain quiet. G5-04 regression exercises full evaluator hold behavior; this is not merely a parser-only hold claim.

During initial test fixture development, production persistence correctly rejected a new Dictionary key created as `StringName`, and the GM fixture needed full NPC source structure. Both fixtures were corrected before the recorded final baseline; no production validator or storage contract was loosened.

## Directly affected regressions and export

Focused first, then six suites through `tests/mw020/运行上下文预算回归验证.ps1`:

1. G5-01 semantic world-turn materialization.
2. G5-01 replacement / Save / Restore / continuation context.
3. G5-02 actor Knowledge provenance and recency/hash matching.
4. G5-03 multi-actor Agency lifecycle/currentness.
5. G5-04 selective World Evolution, hold, replay/Restore and real GM consumer.
6. MW-007 mechanics/consequence timeline continuity and restored future isolation.

**All six exit 0, no assertion/parse/script errors.** G5-03 retains the known 3 ObjectDB / 1 resource exit diagnostics; G5-04 retains 43 / 20. These match prior reviewed evidence in `docs/mw019/MW-019_IMPLEMENTATION_RETURN.md` and `docs/mw018/MW-018_R1_IMPLEMENTATION_RETURN.md`; not fixed outside scope. New focused and final import/export have no such warnings.

A real Provider call is unnecessary and was not made. The regression runner clears the existing credential variables for child processes; actual GM request assembly uses a stub adapter without invoking it.

Export was **performed**, not silently skipped: this is a runtime script shipped in the Windows PCK, and the existing README/run-game path and recent runtime-change validations use Windows export freshness as the playable-build gate. After the implementation commit, Godot 4.7.2 final import and `run-game.ps1 -ValidateExportOnly` both exit 0 with no errors/warnings. Export rebuilt and verified against this task checkout; launch explicitly skipped. The separate PCK, EXE, console wrapper and SQLite DLL hashes/sizes plus freshness stamp are in `evidence/`. This is task validation, not an Owner UAT handoff.

Reproduce from this worktree with fresh roots:

```powershell
& 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe' --headless --path . --editor --import --quit
& 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script 'res://tests/mw020/上下文预算核算测试.gd' -- --root=build/mw020/new-focused
& 'C:/Program Files/PowerShell/7/pwsh.exe' -NoProfile -File tests/mw020/运行上下文预算回归验证.ps1 -Root "$PWD/build/mw020/new-regressions"
& 'C:/Program Files/PowerShell/7/pwsh.exe' -NoProfile -File ./run-game.ps1 -ValidateExportOnly
```

## Residual risks / return boundary

- Genuine budget pressure still omits complete sections under unchanged priority/windows; this task does not promise complete long-session memory or improve semantic selection.
- Existing G5 exit-resource diagnostics remain as disclosed. No unrelated regressions or Provider reliability claims are inferred from these deterministic tests.
- Import-generated sidecars from this newly created clean worktree were verified by creation time, explicit absolute paths, absent destinations and before/after hashes, then preserved under task `build/mw020/generated-imports/`. EOL-only fixture import noise was verified content-identical before index renormalization. Owner's unknown files were not moved or overwritten.
- Keep the task worktree through GPT Independent Review/integration verification. Only reviewed integration may precede the fresh Package-0 Owner build. MW-020 requires no separate Owner Product verdict, but this implementer does not grant Engineering PASS.

**READY FOR INDEPENDENT REVIEW** only; no merge or Owner installation.
