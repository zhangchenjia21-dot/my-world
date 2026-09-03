# G4-11P1 Two-Family Reality Prep Evidence

Status: **BLOCKED — real Provider execution requires explicit Owner authorization**

## Git identity

- START_HEAD (`my-world`): `f1e9c2429ba0f2582532e3215254453eaed9caec`
- START_HEAD (`Vibe-Coding`): `0a724515d4e588c9d01c125f4403f3063cdd9645`
- IMPLEMENTATION_HEAD: `NONE` (no production files changed)
- EVIDENCE_HEAD / FINAL_HEAD: this evidence commit

Both repositories were fetched and revalidated against `origin/main` before packaging this evidence.

## Completed offline gate

Command:

```powershell
D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe --path D:\AI\Projects\my-world --log-file build/g4_11p1/g411-offline.log --script res://tests/g4_11p1/双族现实准备验证.gd -- --root=D:/AI/Projects/my-world/build/g411-offline --evidence=D:/AI/Projects/my-world/build/g4_11p1/g411-offline.json --offline-stub
```

Result: `failures=0`.

The offline gate exercised the production Source Library → Composition → Final Create → Game Session → Opening/Conversation → Save/Continue seams with only the Provider transport replaced by a deterministic stub.

### Effective selected model profile

- profile: `kimi_k3`
- provider: `kimi`
- model: `k3-256k`
- context limit: `256k`
- requested/effective reasoning: `high` / `high`

No persisted Runtime Model Settings were changed.

### Family A

- World: `world.han_end.unsettled_realm`
- World fingerprint: `acea0b2afbaf5305f40456cb93b60c94d536066cee794d75bf5e4b44eebe8a47`
- Entry: `t0-208-red-cliffs-eve`
- Player: `character.han_end.liu_bei`
- Character fingerprint: `d327be7d43ef93511109ac05a853d7c8c1087fb002e6b1b85bab370bd364b406`
- Game: `game-f1ca2f0b0852b977fe786887c0d93bf0`
- accepted durable turns: Opening + 3 continuations
- named Save: created and recovered after reopen

### Family B

- World: `world.ashtervia.afterglow`
- World fingerprint: `9a129587ffbd03db0c380d2a45cbc79aa0d8c05c6e934c15f612967144c46d28`
- Entry: `t0-1287-ovista`
- Player: `character.ashtervia.livia_selan`
- Character fingerprint: `17f20faf4d6d7f749b064b0cae3a480685f1a854490015fd84efea919f7e4501`
- Game: `game-603077c2abd52627f2ef38b74826f75e`
- accepted durable turns: Opening + 3 continuations
- named Save: created and recovered after reopen

### Offline invariant evidence

- distinct Game IDs and distinct SQLite paths: PASS
- Expansion = none for both Games: PASS
- switch sequence `A → B → A → B → A`: PASS
- exact Source ancestry after task-owned current-generation changes: PASS
- opposite-family identity/content negative assertions for every assembled request: PASS
- later task-owned Source-current markers excluded from existing Games: PASS
- no visual dependency and no G5/G6 production work: PASS

## Focused regressions

Existing task-owned logs record these final green reruns at the same START_HEAD:

- G4-03 Source Library reality: `done failures=0`
- G4-05 Wizard: `done failures=0`
- G4-06 Final Create focused rerun: `done failures=0`
- G4-04 Game Library focused: `done failures=0`
- G4-07A Opening focused: `done failures=0`
- G3-04 Save/Restore focused: PASS

An earlier G4-06 log failed because the fixture install state was stale; the bounded fresh-root rerun in `final-create-short.log` passed with `failures=0`. Build logs are gitignored and are not committed.

## Owner safety

The committed real-Provider wrapper fingerprints Owner production Runtime Settings, Source Library, Games, Game Library and legacy current DB before and after execution. It fails if any fingerprint changes, restores whitelisted credential environment variables, and never prints credential values. All mutable validation roots are under `build/g411/`.

## Blocking real-Provider gate

No real Provider call has been made for G4-11P1. The attempted execution was blocked before launch because explicit authorization is required to send the two concrete task-owned family payloads to Kimi. Therefore this document does **not** claim AC-03, `READY FOR INDEPENDENT REVIEW`, product differentiation, G4-11 PASS, or G4-GATE PASS.

After explicit authorization, run:

```powershell
.\tests\g4_11p1\运行双族真实Provider验证.ps1
```

Expected gitignored outputs:

- `build/g411/two-family-reality.json`
- `build/g411/owner-safety-before.json`
- `build/g411/owner-safety-after.json`
- `build/g411/godot.log`

If the real run passes, replace this blocking section with the safe real-call summaries, Owner before/after equality proof, exact accepted turn counts/timings/hashes, and final `git diff --check` result.

## Changed paths

- `tests/g4_11p1/双族现实准备验证.gd`
- `tests/g4_11p1/双族现实准备验证.gd.uid`
- `tests/g4_11p1/运行双族真实Provider验证.ps1`
- `docs/g4_11/G4-11P1_TWO_FAMILY_REALITY_PREP_EVIDENCE.md`

No production code, frozen Source fixture, Provider contract, gameplay behavior, visual route, or G5/G6 implementation was changed.
