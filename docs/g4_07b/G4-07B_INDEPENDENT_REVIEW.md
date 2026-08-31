# G4-07B Independent Review

Status: **PASS / CLOSED**
Reviewer: GPT
Reviewed implementation HEAD: `2f45614baa0a3c38dac3439934122084817d4602`
Implementation commit: `e13099384c12090197822d1d504089decc1f893b`
Evidence commit: `2f45614baa0a3c38dac3439934122084817d4602`
Parent gate: `G4-07 First Playable A — Owner UAT required`

## Verdict

> **PASS. No blocking frontend/application integration defect found.**

This review closes G4-07B engineering work only. It does **not** declare G4-07 Product PASS.

## Independently confirmed

- Production diff stayed inside the allowed application/UI boundary: `src/应用壳.gd`, `src/main.tscn`, `src/ui/**`; protected G4-06/G4-07A/persistence/provider/runtime/domain/context/source/game-library/creation production modules were unchanged.
- One frozen Review submission owns one stable `creation_id`; duplicate submit is guarded by `_create_in_progress` plus button disable, failed create retries reuse the same identity, materially changed payload starts a new attempt, and a completed Wizard cannot create a second Game.
- Final Create success transitions through the existing registered/existing-only Game open path; open failure preserves the durable Game and directs the player back to Continue rather than creating a replacement.
- `accepted Conversation == 0` is treated as a legal opening-pending Game. Opening failure/cancel preserves the Game, keeps Player input gated, and retries the G4-07A first-Opening seam on the same Game.
- Closing after durable create but before accepted Opening and rebuilding the Shell returns through Continue to the exact same Game and retries Opening; it does not rerun Final Create.
- Accepted first Opening is rendered as `GM · 开场`; the v4 empty Player compatibility slot is not rendered as an empty/fake Player bubble and does not expose Player-side Regenerate.
- The first real Player action after Opening uses the reviewed G4-07A durable continuation assembler. The tested request roles are `[system, assistant, user]` and include durable Game-local World truth, accepted Opening, and the new Player action.
- Save → Main Menu → Continue restores the same Game and durable Conversation and does not generate a second first Opening.
- no-Entry remains explicit and does not receive a hidden Entry/profile/year.
- Real non-headless DeepSeek integration drives the actual `main.tscn` application path for Han and Afterglow. Han additionally performs a real Player continuation and Continue restore; Afterglow uses the same family-agnostic UI path with distinct semantics.
- Layout tests exercise Review, Opening streaming, Opening failure/retry, and Playing at 1280×720, 960×540, and maximized windows. Screenshot binaries remain task-owned build evidence per repository policy; the test source contains geometric reachability assertions for the new primary controls.
- G2/G3/G4-01/G4-04/G4-05/G4-06/G4-07A regression floors are reported passing; production SQLite schema remains v4 and frozen full-fidelity fixtures are unchanged.

## Non-blocking notes

- `game_local_setup.v0.1` routing in the Application Shell is appropriate for the current G4 First Playable vertical; future G5 world evolution may require a broader runtime-state ownership seam once current World ceases to be only the initial setup document. This is not a G4-07B defect.
- Narrative quality, Character individuality, anti-convergence, and whether Context feels sufficiently rich are intentionally unresolved by engineering evidence. They are the next Owner UAT gate.

## Next state

```text
G4-07A Opening Runtime          PASS / CLOSED
G4-07B Playable UI Integration PASS / CLOSED
G4-07 First Playable A         READY FOR OWNER UAT
```
