# MW-018｜Integration Verification

Status: **ENGINEERING PASS / INTEGRATED / OWNER UAT PENDING**  
Integrated main tip before this record: `767001fb3e1962a28e77c778d72bb6e2ee0c7406`

## Reviewed lineage

- implementation base: `a1af1ed7aaf2d322b3dfb8659907ba1c8927abf3`
- reviewed candidate: `c8150a2ee9fa79d929cd0bb5f899132d3d2f6563`
- reviewed code commit: `e9157f79860437207b73e894647be9f1278f5a74`
- Independent Review record: `docs/mw018/MW-018_INDEPENDENT_REVIEW_IR1.md`
- review/integration tip: `767001fb3e1962a28e77c778d72bb6e2ee0c7406`

`main` was fast-forwarded to the reviewed lineage. The only commit after the candidate before integration was the GPT Independent Review record; no product code changed after the reviewed candidate.

## Integrated product vertical

```text
accepted player-authored Turn
→ MW-017 exact person identity receipt / same-turn barrier
→ existing Information Curator one call
→ Character + Important Experiences + People updates
→ backward-compatible information_curation currentness
→ player-safe People projection
→ right-side 人物 card Surface
```

Current right navigation:

`概览 | 角色 | 重要经历 | 人物 | 存档`

People cards are rebuilt collapsed by default. Expanded content is the model-curated latest player-known snapshot; UI does not hydrate raw NPC truth.

## Protected result

- model owns card eligibility/content/update/removal;
- Program owns exact identity, structural validation, persistence and Timeline currentness;
- no authoritative display-name matching;
- no third People model call;
- no numeric Relationship Domain;
- no new SQLite table/migration;
- no historical backfill or GM-opening People processing;
- leaf UI receives only `display_name/headline/summary/relationship/details`;
- accepted replacement/Restore/reopen correctly remove or restore People according to current accepted history.

## Evidence inherited from exact reviewed candidate

- focused final: 135 / 0;
- rendered visual checks: 127 / 0 across maximized, 1280×720 and 960×540;
- MW-017 / MW-014 / MW-015 and relevant G5 regressions pass;
- Windows Desktop export passes;
- one bounded Kimi K3 real vertical produced a valid 李亭 card using one World semantic call + one existing Information Curator call;
- Owner production data fingerprints were unchanged.

## UAT risk retained

In the same real Provider run, new actor `沈青` was materialized but the model omitted the candidate's `candidate_ref` while referencing it in `people_bindings`. The identity bridge correctly refused to guess, so no 沈青 card was produced. This is a model-output reliability risk for Owner UAT, not permission to add name matching heuristics.

## Next gate

```text
canonical D:/AI/Projects/my-world sync to exact integrated main
→ fresh Windows export validation
→ Owner UAT
```

Only Owner may declare MW-018 Product PASS.