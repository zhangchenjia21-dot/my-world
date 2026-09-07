# MW-018 R1 — Known / Off-screen People Eligibility Implementation Return

Status: **READY FOR INDEPENDENT REVIEW**
Date: 2026-09-07
Work item: MW-018 / Revision 1
Branch: `mw-018-r1-known-person-eligibility`
Worktree: `D:/AI/Projects/.worktrees/my-world/mw-018-r1-known-person-eligibility`

## Exact source / Git identity

- Formal implementation main/code base: `fc308e8ee4347ddb8a67e40360f8ce84222d437b`.
- Exact starting HEAD: `3909225d13c8c1de37b9a85d79034ff064d0076c`, clean. This published task branch adds only the Task Packet to the formal code base; the packet is not present on main.
- Implementation HEAD: `318a0a2a79bb5f45f582605ac6b98d891a368b4c`.
- Governance main: `ef13a7df0edaea72c4d1fd920e2323610b486743`; packet shaping base remains `8376ea1d528ef49529b69a9aabab0616bb781805`.
- Both mains were fetched before implementation and refreshed before delivery; neither moved or superseded the correction. Remote R1 branch was still the exact starting HEAD before push.
- Final review candidate is the evidence-only commit containing this report, directly after implementation HEAD. Its exact SHA is returned in the delivery message after this commit exists; source/tests are identical to implementation HEAD.
- All existing worktrees retained. Owner canonical checkout stayed at `782daf65348f484d636d46260ac2374559cf554d` on main, with its pre-existing `.gitignore` modification and ten screenshot import sidecars preserved. No candidate installed, no main merge/reset/clean/force.

Read authorities: current repo/governance AGENTS, Owner preferences, Task Packet, current status v17.4 and roadmap, People Surface decision, People Identity and Curation decision, the frozen Known-person Eligibility UAT Correction decision, and `docs/uat/G6_PACKAGE0_OWNER_UAT_U1.md`. The newer correction supersedes the older GM-only eligibility constraint.

## Root cause and delivered behavior

Code confirms the frozen finding: the existing stable actor roster already includes applicable off-screen NPCs, but identity response validation and Curator evidence slicing only accepted GM spans. A Player-only recall could never supply its own exact reference evidence. No materially different root cause was found.

The existing semantic lane now asks the model to resolve exact references in either accepted Player or GM text. Program accepts only request-scoped `actor_ref`, or a same-response `candidate_ref` for a GM-sourced newly materialized person. Player-sourced `candidate_ref` is rejected. No names, canonical IDs supplied as refs, fuzzy matches, first-match lookup, historical-person lists or semantic score/tree gain authority.

The semantic prompt explicitly separates existing-person recall from new actor existence: a Player assertion alone must not create `new_actor_candidates` or World Truth; legitimate GM/world-semantic establishment can still materialize an off-screen person using the unchanged stable actor path. Actor materialization precedes exact candidate binding in the same atomic commit and existing terminal barrier.

People card worth stays with the same Information Curator: current scene presence is neither required nor sufficient; an incidental present person may receive a no-op. Player beliefs are not automatically facts. Character/Experiences prompt semantics, UI, actor materialization ID algorithm and database schema are unchanged.

## Receipt and disclosure contract

- Original `accepted_people_identity.v0.1` GM-only responses/receipts remain readable with unchanged valid historical IDs and curation dependencies. No migration/backfill.
- `accepted_people_identity.v0.2` stores `{local_character_id, source_role: player|gm, source_span: {start,length}}`. A response containing the new form normalizes all its bindings to v0.2; legacy-only/empty outcomes retain v0.1. Mixed equivalent GM evidence is deduplicated structurally.
- Existing limits remain: 8 bindings, 1..600 Unicode characters per span, exact allowed fields and in-bounds integer coordinates.
- Game, accepted turn and full Player+GM prefix remain hashed; epoch/request/currentness/Restore checks are unchanged. Source role/span participates in the receipt ID and existing Curator dependency.
- L3 slices verbatim accepted text by source role and returns only request ref, role/span, quote and the already-safe previous card when applicable. Private canonical mapping stays in Program. Legacy evidence shape is unchanged.
- No raw actor profile, private Knowledge, Agency, hidden Evolution or Source-current material is added to Curator/UI. No third People call or SQLite table.

Production scope: four files only — receipt rules (L0), existing semantic flow (L2), identity bridge (L3), People instructions in existing Curator flow (L2). No new production module, dependency or cross-module internal import. New tests are engineering perimeter files, use Chinese responsibility names and include a tracked Godot UID. Contract comments explain source provenance and legacy identity preservation.

## Validation and evidence

[Machine summary](r1/evidence/validation.json), [focused log](r1/evidence/focused.log), [direct regression results](r1/evidence/regression-results.json), [real Provider transcript](r1/evidence/real-known-person.json), [Owner data fingerprints](r1/evidence/owner-safety.json), [final export log](r1/evidence/windows-export.log).

| Gate | Result |
| --- | --- |
| New R1 Runtime/SQLite focused | **81 checks, 0 failures**, exit 0 |
| Existing MW-017 | 120 checks, 0 failures, exit 0 |
| Existing MW-018 | 135 checks, 0 failures, exit 0 |
| MW-014 | 105 checks, 0 failures, exit 0 |
| All 16 directly affected regression suites | exit 0, no assertion/script/parse failures |
| Final Godot editor import | exit 0, no script/parse errors |
| Windows Desktop export against implementation HEAD | exit 0, **export_errors=0** |
| Configured real Kimi K3 (`k3-256k`) | one World + one Curator call, `resolved_card` |
| Owner settings/Source/Games/library/current DB fingerprints | unchanged |
| Git whitespace / scope / dependency inspection | clean; four narrowly scoped production files |

R1 focused proves Player existing-person refs, distinct same-name exact refs, GM off-screen refs, same-turn off-screen actor materialization, rejection of Player candidate refs and unresolved name/ID guesses, Unicode spans, bounded evidence, private canaries, previous safe snapshot update, new incidental soldier no-op, mixed historical receipts/curation parents, Character/Experiences noncorruption, stale Restore callbacks, Restore/reopen without replay, Player-only correction with unchanged GM bytes, and corrupt persisted receipt rejection.

Direct regressions: MW-018, MW-017, G5-01 semantic and timeline, G5-02 Knowledge, G5-03 Agency, G5-03M2A stable registry, G5-03M2B runtime materialization, G5-04 Evolution, MW-006 mechanical grounding, MW-014, MW-015, MW-015 R2 initial baseline/UI/contract, G4-07B Shell. These preserve semantic failure/cancel/timeout fail-soft behavior, Regenerate currentness and old curation chains.

Committed logs only strip trailing whitespace for Git hygiene; raw originals remain under the task build directory.

Existing exit-warning families remain: G5-03 3 objects/1 resource, G5-04 43/20, G4-07B 3/1. These match the reviewed baseline families recorded in `docs/mw019/MW-019_IMPLEMENTATION_RETURN.md`; they are disclosed separately from assertion/script failures. New R1 focused, MW-017/18 and final export have none. An initial import found one inferred boolean type error during implementation; it was corrected before the successful gates.

The real fixture uses an already-existing unique stable NPC “顾衡”, referenced only by accepted Player recall; GM does not name or place him in the scene. K3 returned `source_role=player`, exact span `[8,2]`, no new actors, and a useful card through the existing Curator. The unresolved hypothetical “杜闻” stayed unbound/unmaterialized. No retry, Provider change or fallback. Credentials were injected through the existing whitelist and never recorded; only synthetic fixture requests/responses are committed. The test used independent SQLite state under task build, with Owner fingerprints checked before/after.

Reproduce from the required worktree with Godot `D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe` and PowerShell 7:

```powershell
$Godot = 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe'
& $Godot --headless --editor --path . --import --quit
& $Godot --headless --path . --script 'res://tests/mw018/已知场外人物资格纵向测试.gd' -- '--root=res://build/mw018/r1/review-focused'
& 'tests/mw018/运行人物整理离线验证.ps1' -Godot $Godot
# Optional paid/network check; exactly the R1 two-call scenario, fresh isolated root:
& 'tests/mw018/运行真实人物验证.ps1' -Godot $Godot -KnownPersonR1
```

## Residual risks / review handoff

1. Model resolution, actor-existence interpretation and card worth remain semantic responsibilities. Program rejects malformed/unknown refs and Player candidate binding; it does not adjudicate whether a structurally valid model-proposed actor or span is semantically true. No semantic judge was added.
2. Same-name/disputed references may remain unresolved because the existing identity-only metadata cannot always distinguish them. The correct result remains no binding, never a guessed name match. Deterministic tests prove exact mapping, not universal model disambiguation.
3. One real, intentionally clear recall fixture proves this seam can work; it does not establish success frequency across normal Owner play, same-name ambiguities or all off-screen materialization wording. Re-UAT remains required, including ordinary recall and incidental NPC behavior.
4. No historical People backfill: existing Games need a new accepted reference to an exact legitimate stable actor. Old mentions without stable identity do not acquire one merely by recalling a name.
5. No Product/Engineering PASS is declared. Stop here for GPT Independent Review; Owner installation/integration is not performed.
