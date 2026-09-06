# MW-017｜Integration Verification

Status: **ENGINEERING PASS / INTEGRATED**  
Work Item: **MW-017 People Identity Bridge + Same-turn Barrier**

## Integrated lineage

- Implementation base: `286f72d78c8470f2d78fa2f3847ace081cae7bd4`
- Reviewed code commit: `2be0c532d89c0fa7ae1d473d408a42785a32c8d9`
- Implementer evidence candidate: `dd7b56fb030085b5c74dbe221bf8b5741bef3724`
- Independent Review record: `docs/mw017/MW-017_INDEPENDENT_REVIEW_IR1.md`
- Review/integration tip: `27519c0e11ff995df4c584e835dc0be39ee3f4d5`

`main` was fast-forwarded from the exact implementation base to the reviewed tip; no merge conflict or unrelated implementation delta was introduced.

## Integrated outcome

```text
accepted player-authored Turn
→ World semantic lane
→ stable actor materialization when needed
→ exact accepted-person → stable-NPC identity receipt
→ current-version terminal barrier
→ existing Information Curator lived opportunity may proceed
```

Integrated guarantees:

- exact Program-owned stable identity; no display-name authoritative matching;
- same-response runtime actor is minted before transient candidate ref is resolved;
- actor + identity receipt commit atomically through the existing World mutation seam;
- receipt currentness uses full accepted Player+GM prefix;
- semantic failure/cancel/timeout remains fail-soft and releases Character/Important Experiences curation without People evidence;
- Restore epoch blocks stale callbacks/receipts;
- old Games with no receipt collection remain valid and are not historically backfilled;
- GM-only opening remains outside People v0.1;
- no People UI / `people_updates` / Relationship Domain / SQLite table / MW-013 work.

## Review evidence

Independent Review accepted:

- 120 focused MW-017 checks / 0 failures;
- G5 actor/Knowledge/Agency/World Evolution regressions;
- MW-014/MW-015 regressions;
- Narrative playable vertical;
- Windows Desktop export;
- one bounded real configured Kimi K3 identity-binding smoke with unchanged Owner production fingerprints.

The reported legacy ObjectDB/resource exit warnings reproduce at the pre-task implementation base with equal counts and are not MW-017 regressions.

## Stage effect

MW-017 is a backend prerequisite and requires no Owner Product UAT by itself.

It unblocks shaping/implementation of:

```text
MW-018 People Curation + Card Surface
```

MW-018 must consume this bridge without exposing raw stable actor material or internal local IDs to leaf UI.
