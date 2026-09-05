# MW-012 Independent Review IR#2 — Zhang Chen Player Character Card

Status: **ENGINEERING PASS — INTEGRATION READY / OWNER PRODUCT UAT**  
Work Item: **MW-012**  
Revision: **2**  
Review-Round: **IR#2**  
Reviewer: **GPT**  
Reviewed candidate: `f91e23ac8fe76c3b16bd486d419461cdf70d5a1f`  
R2 repair commit: `7bef22ce181fab3d7165911ff95c81d9fa63f64f`  
R2 evidence commit: `f91e23ac8fe76c3b16bd486d419461cdf70d5a1f`  
Task: `docs/tasks/MW-012_ZHANG_CHEN_PLAYER_CHARACTER_CARD_TASK.md`  
R2 addendum: `docs/tasks/MW-012_REVISION2_CONTENT_AND_PUBLISH_PROOF_ADDENDUM.md`

## 1. Verdict

**ENGINEERING PASS.**

Revision 2 resolves all three IR#1 findings without broadening the task or changing the accepted Character Source architecture.

The accepted result remains:

```text
Owner-approved 张琛 concept
→ existing character_card.v0.2 Source contract
→ normal Managed Source Library ingress
→ selectable Player Character for supported Han-end Entries
→ Final Create frozen Game-local projection/context
```

No new Character schema, Creator, inventory platform, picker hardcoding, language simulator, mechanic Expansion, declarative UI platform or future-history scheduler was introduced.

## 2. F01 — literacy-only wording: RESOLVED

The T0 profile no longer says Zhang Chen lacks local `语言文字能力`.

It now states only that he lacks local written-script literacy: he has not learned clerical script, initially cannot read the era's written material, and may learn through play. It explicitly avoids adding an extra spoken-language barrier.

This matches the Owner-approved limitation and keeps language simulation out of scope.

## 3. F02 — publish-script proof / production publication: RESOLVED

The focused test's publish-script smoke is no longer dead code. The script load and contract-constant assertion now execute before `_finish()` / termination.

The reviewed production publish script remains bounded:

- fixed package path for the Zhang Chen card;
- fixed asset identity;
- explicit Owner opt-in flag;
- normal `SourceLibrary.install_character_card(...)` ingress;
- no arbitrary path scanning;
- no Game mutation path.

Revision evidence records execution of the Owner-approved production publication command with:

```text
status: installed
asset_id: character.han_end.zhang_chen
version: 0.1.0
generation_fingerprint: b1a1e5d58fe1383ff41b1f9745199aafe97fed8a1015299cf21dfb6f02091553
production inventory character_count: 7
zhang_chen_present: true
owner_games_modified: false
```

It also records a normal production `Composition.load_current_inventory()` discovery probe resolving the same current generation as a Player-supported Character.

GitHub cannot independently read the Owner machine's production AppData state, so the exact local publication command result remains environment-side implementation evidence. GPT independently inspected the script, the repaired reachable test assertion, the Source package, the normal discovery path and the candidate diff. Final Owner product UAT remains the authoritative visible confirmation.

## 4. F03 — unrelated MW-004 uid: RESOLVED

The unrelated file:

`tests/mw004/最小玩家主权原则测试.gd.uid`

was removed from the R2 candidate. The final compare from the refreshed base to `f91e23ac...` no longer contains that file.

## 5. Accepted Source semantics preserved

The final card keeps the accepted identity and behavior:

```text
asset_id: character.han_end.zhang_chen
schema: character_card.v0.2
version: 0.1.0
display_name: 张琛
player_character_supported: true
profile: han-t0-transport / 现代来客起点
```

The single reusable T0 profile remains bound to all seven supported Han-end Entries:

- 184 Yellow Turban;
- 189 Luoyang crisis;
- 196 Emperor Xu;
- 200 Guandu eve;
- 208 Red Cliffs eve;
- 214 Yizhou transition;
- 220 Han–Wei transition.

Unrelated worlds remain `no_world_coverage`.

The Character content continues to preserve these authority boundaries:

- physical body transport at selected T0;
- age 24 and no prior local identity/network/history;
- modern historical memory is protagonist memory/belief, not current World Truth or guaranteed future canon;
- no NPC destiny is forced by remembered history;
- famous-person knowledge does not grant automatic visual identification;
- future allegiance, self-rule, disclosure of future knowledge, staying/returning and other meaningful protagonist choices remain Player-owned;
- starting possessions are finite and bounded to the Owner-approved list.

## 6. Test / evidence assessment

The focused suite itself exercises the real Character Source contract, Managed Source Library, Composition inventory, seven-entry compatibility projection, unrelated-world rejection, Final Create, Runtime open, frozen projection, GM context projection, Player-safe projection and Liu Bei regression.

Revision evidence reports:

- MW-012 focused integration suite: green;
- reachable publish-script smoke: green;
- Source v0.2 mechanism regression: green;
- G4-05 Composition regression: green;
- G4-06 Final Create regression: green;
- Liu Bei discovery/create regression: green;
- `git diff --check`: clean;
- Windows export validation: PASS;
- Provider calls: 0;
- production code diff: 0.

GitHub exposes no CI status for the reviewed candidate, so runtime execution counts remain implementer evidence; the actual candidate code/diff/test assertions were independently inspected.

## 7. Integration note

The reviewed MW-012 branch was prepared from the then-current implementation base and is currently separate from the verified MW-011 integration branch. Integrate both reviewed results without semantic edits. If branch reconciliation introduces a real content/code conflict or changes the reviewed bytes, stop and review that delta.

After integration, MW-012 becomes:

**ENGINEERING PASS — OWNER PRODUCT UAT**

Owner UAT should confirm that a normal current New Game flow can visibly discover and select `张琛`, create a Han-end game with him, and produce an opening consistent with the physical-transport premise and bounded historical-memory semantics.
