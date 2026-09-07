# MW-018 R1 Independent Review IR1

Status: **ENGINEERING PASS_WITH_NOTES**
Date: 2026-09-07
Reviewer: GPT
Work item: MW-018 / Revision 1
Reviewed branch: `mw-018-r1-known-person-eligibility`
Formal code base: `fc308e8ee4347ddb8a67e40360f8ce84222d437b`
Task-packet/start branch HEAD: `3909225d13c8c1de37b9a85d79034ff064d0076c`
Implementation HEAD: `318a0a2a79bb5f45f582605ac6b98d891a368b4c`
Exact submitted candidate: `8f48f3cc96a01b1c132c2ccb583193df9c93511a`

## 1. Independent scope

This review does not treat Builder acceptance claims as proof. I independently inspected:

- `fc308e8... -> 8f48f3c...` complete repository diff;
- the four production files changed by R1;
- the new focused vertical test and existing semantic parser boundary;
- committed validation/regression/real-provider evidence;
- current governance and frozen People correction authority.

Production delta is bounded to:

- `src/世界回合/L0_公理层/人物身份回执规则.gd`
- `src/世界回合/L2_流程层/语义物化流程.gd`
- `src/世界回合/L3_外交层/人物身份桥公开接口.gd`
- `src/信息整理/L2_流程层/回合信息整理流程.gd`

No unrelated product capability, new SQLite owner, extra People Provider lane, generic resolver/framework or UI work was added.

## 2. Findings

### F-01 — UAT root cause is actually addressed

R1 broadens identity evidence from GM-only spans to the current accepted Player+GM pair. Existing stable actors can now be referenced from accepted Player recall/talk while off-screen; GM-established off-screen people can remain eligible. Current physical presence is no longer an eligibility gate.

This directly repairs the architectural mismatch found in Owner UAT rather than adding a display-name workaround.

### F-02 — exact identity protection remains intact

Program still accepts only request-scoped `actor_ref`, or same-response `candidate_ref` for GM-sourced newly established actors. Player-sourced `candidate_ref` is rejected. `resolve_bindings` still validates exact allowed keys, request refs, role, source span, allowed current stable actor IDs and payload ceilings.

No display-name equality, fuzzy lookup, first-match lookup, famous-person table or Program-side importance classifier was introduced.

### F-03 — Player assertion does not mint World Truth

The implementation separates two cases:

- Player reference to an already-existing exact stable actor may bind;
- Player-only unresolved references cannot create a new actor through `candidate_ref`.

New actor materialization remains in the existing GM/world-semantic path. This is the necessary authority boundary, not a Program semantic judge of who is important.

### F-04 — model freedom over People meaning is preserved

R1 does not auto-create cards for bound actors. The Information Curator still decides whether to create/update/remove/retain a People card. The new prompt explicitly states that current-scene presence is neither necessary nor sufficient and that incidental guards/soldiers may remain uncarded.

This is consistent with `Model owns semantic interpretation and curation; Program owns normalized storage, temporal integrity and presentation`.

### F-05 — disclosure boundary remains player-safe

The semantic identity lane continues to own identity resolution. The People Curator receives only request-scoped ref + accepted Player/GM quote/span/source-role and an already player-safe previous card where applicable. It does not receive canonical IDs, raw actor profile, NPC-private Knowledge, Agency, hidden Evolution or Source-current content.

The existing semantic lane already had identity-only actor references; R1 does not introduce raw hidden profile disclosure.

### F-06 — backward compatibility/currentness are credible

`accepted_people_identity.v0.2` is additive. Legacy GM-only v0.1 records retain their original shape/ID algorithm. Current validation accepts both schemas and revalidates source spans against the selected accepted Player/GM bytes. Full Player+GM prefix continues to bind receipt currentness.

Focused coverage includes mixed old/new receipt history, Restore before/after card creation, stale callback rejection, reopen without replay/backfill and Player-only correction with unchanged GM bytes.

### F-07 — evidence is internally consistent

Committed evidence independently inspected shows:

- focused: 81 checks / 0 failures / exit 0;
- all 16 directly affected regression suites exit 0;
- final import exit 0 with no script errors;
- Windows export exit 0 / `export_errors=0`;
- real configured Kimi K3: exactly 1 semantic + 1 curator request, successfully binding an already-stable off-screen old acquaintance from Player recall and producing one card;
- Owner settings/Source/Games/library/current DB fingerprints unchanged.

Known exit-warning families are pre-existing and are not assertion/script failures.

## 3. Non-blocking notes / residual product risk

### N-01 — real Provider evidence covers the most important new seam, not every semantic case

The real Kimi fixture proves Player recall -> exact existing stable actor -> People card. Same-turn GM-established off-screen materialization is covered deterministically rather than by a second paid real call.

This is sufficient for Engineering PASS, but Owner focused re-UAT must still test a natural Zhong Yao-like flow.

### N-02 — no historical backfill remains intentional

If an older accepted mention never produced a stable actor identity, a later Player-only name mention still will not mint one. R1 fixes forward/current exact eligibility; it does not replay old history or make Player belief authoritative.

Therefore focused Owner re-UAT should preferably include a fresh normal-play establishment/reference path, not rely only on a pre-R1 save whose person may never have become stable.

### N-03 — model freedom concern should be explicitly watched in re-UAT

The Program does not add semantic importance rules, which is correct. However, prompt wording still carries necessary identity/world-truth guardrails. Re-UAT should judge whether these guardrails materially suppress legitimate People behavior. If natural, clearly known people still fail because the identity seam is too restrictive, reopen architecture rather than stacking more rules.

## 4. Verdict

**ENGINEERING PASS_WITH_NOTES.**

No Stage blocker found. The implementation addresses the confirmed MW-018 UAT defect within the frozen authority boundary, preserves exact identity/currentness/disclosure invariants, and remains bounded.

This does **not** grant Product PASS. MW-018 remains pending focused Owner re-UAT after the Package 0 correction train is complete.
