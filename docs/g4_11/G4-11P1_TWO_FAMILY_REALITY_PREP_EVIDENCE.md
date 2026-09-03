# G4-11P1 Two-Family Reality Prep Evidence

Status: **READY FOR INDEPENDENT REVIEW**

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

## Real selected-Provider vertical

Authorized command:

```powershell
.\tests\g4_11p1\运行双族真实Provider验证.ps1
```

Result:

- generated at: `2026-09-03T01:35:31` (Godot UTC timestamp)
- total duration: `282358 ms`
- provider mode: `real_selected_provider`
- failures: `0`
- effective profile: `kimi_k3` / `kimi` / `k3-256k` / `256k`
- requested/effective reasoning: `high` / `high`
- no provider fallback

### Real Family A result

- Game: `game-d2ae12b01b432adc1e0fe98fae53b849`
- SQLite: task-owned `build/g411/state/games/game-d2ae12b01b432adc1e0fe98fae53b849/game.sqlite`
- real Opening: accepted durable, `19867 ms`, `535` response characters
- real continuations: 3 accepted durable, `22038 / 25347 / 42860 ms`
- continuation response characters: `837 / 1142 / 1382`
- named Save: `save-296a5b3ee29cbaddc149f34d66f2436d`, created after 3 accepted turns
- reopen restored the same Game, SQLite, Save, exact ancestry and 3 accepted turns before accepting continuation 3
- Opening request SHA-256: `883497a6d4d728af617151e337affdb0ba8b601911146d21c8f18f37b8d428e9`
- Opening response SHA-256: `3be91a7119224631f0ea41ba4c3b13b21ea16a7e8a7e802e90a040be30560c60`

### Real Family B result

- Game: `game-6bdb2185aefb6de4bc7e1fa0b5e1fa7f`
- SQLite: task-owned `build/g411/state/games/game-6bdb2185aefb6de4bc7e1fa0b5e1fa7f/game.sqlite`
- real Opening: accepted durable, `26674 ms`, `1547` response characters
- real continuations: 3 accepted durable, `23186 / 49228 / 70686 ms`
- continuation response characters: `1099 / 1451 / 2430`
- named Save: `save-454a7553652ccc1667e58a873ca31b5d`, created after 3 accepted turns
- reopen restored the same Game, SQLite, Save, exact ancestry and 3 accepted turns before accepting continuation 3
- Opening request SHA-256: `19815cbab143cb5fdb289b20e4313b392c766358c5de3a127a70fba1ae4a130f`
- Opening response SHA-256: `c2a6e66bb569f94459c3095f8d647f1ee6adc48a6138f99e74a288510196e217`

### Real isolation and durability result

- A/B Game IDs and SQLite paths are distinct: PASS
- switch sequence `A → B → A → B → A`: PASS
- every real Opening/continuation request contained its exact selected World, Character and Entry/T0 markers: PASS
- every real request excluded opposite-family identities/content and later task-owned Source-current markers: PASS
- bounded second generations became current only in the task-owned Source Library: PASS
- both already-created Games retained their exact original generation ancestry/materialized truth: PASS
- both Games completed Save → close → exact Game Library reopen → Continue: PASS
- both Games used Expansion = none: PASS
- same effective selected profile remained unchanged before, between and after all real requests: PASS

## Owner safety

The wrapper fingerprinted Owner production Runtime Settings, Source Library, Games, Game Library and legacy current DB before and after the real run. The normalized snapshots were exactly equal (`OWNER_SAFETY_EQUAL=True`). It restored whitelisted credential environment variables and printed no credential values. All mutable validation roots remained under `build/g411/`.

Gitignored local evidence:

- `build/g411/two-family-reality.json`
- `build/g411/owner-safety-before.json`
- `build/g411/owner-safety-after.json`
- `build/g411/godot.log`

No hidden prompts, full payloads, credentials, Owner AppData or task-owned SQLite files are committed.

## Scope and verdict boundary

This engineering evidence satisfies the G4-11P1 task packet and is ready for GPT Independent Review. It does not claim that the two worlds feel materially different, G4-11 PASS/CLOSED, G4-GATE PASS, or Product PASS; those remain with Independent Review and Owner UAT.

## Changed paths

- `tests/g4_11p1/双族现实准备验证.gd`
- `tests/g4_11p1/双族现实准备验证.gd.uid`
- `tests/g4_11p1/运行双族真实Provider验证.ps1`
- `docs/g4_11/G4-11P1_TWO_FAMILY_REALITY_PREP_EVIDENCE.md`

No production code, frozen Source fixture, Provider contract, gameplay behavior, visual route, or G5/G6 implementation was changed.
