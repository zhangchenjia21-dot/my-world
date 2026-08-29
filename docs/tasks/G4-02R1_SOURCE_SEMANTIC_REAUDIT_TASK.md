---
title: my world｜G4-02R1 World / Character Source Semantic Re-audit
status: current-task-packet
task_id: G4-02R1
type: semantic-design-correction
owner: GPT
created: 2026-08-29
updated: 2026-08-29
repository: zhangchenjia21-dot/my-world
branch: main
historical_engineering_base: d8405e046ee2134361ec7ab1257f98c7a86c24a8
current_implementation_candidate: 145c3e1192b443f6284da7f36aee74619adad5bf
historical_real_asset_repo: zhangchenjia21-dot/sillytavern-assets
historical_real_asset_sha: 4a5364a042e41f4c8a69621fc4467956a78703c0
codex_active: false
---

# TASK｜G4-02R1｜World / Character Source Semantic Re-audit

Owner: **GPT**

This task reopens the semantic adequacy of the G4-02 Source contract without rolling back verified engineering history.

## Outcome

Using real `汉末三国` and `诸界余辉` assets as primary evidence, determine and freeze the smallest Source contract that can faithfully carry reusable authored World / Character semantics without importing legacy host debt or Game-local live state.

## Why now

G4-05 Independent Review found that real historical assets had been converted into compact summaries. That demonstrated parser/library compatibility, not real content/complexity compatibility. Before rewriting those assets, the semantic contract itself must be audited by the semantic owner.

## Required evidence

Historical snapshot, read-only:

`zhangchenjia21-dot/sillytavern-assets@4a5364a042e41f4c8a69621fc4467956a78703c0`

At minimum audit:

- `世界包/汉末三国_天下未定_World_Pack_v0.2.3.md`
- `世界包/埃瑟维亚_诸界余辉_World_Pack_v0.1.3.md`
- the six G4-05 selected Character Cards: 刘备、曹操、孙权、莉维娅·塞兰、阿德里安·维尔克、杜恩·石痕

## Semantic questions

For each substantive section decide:

```text
legacy semantic section
→ reusable World Source | reusable Character Source | Entry/T0 | Expansion | Game-local/Runtime | omit legacy-only
→ required preservation depth
→ current v0.1 representation
→ natural fit / awkward fit / impossible
```

Specifically test Character semantics such as:

- identity / public positioning
- personality core / values / contradictions / fears / blind spots
- abilities, specialties and limitations as stable authored semantics
- decision / behavior logic
- relationship style / autonomy
- language / expression guidance
- knowledge / information boundary
- T0 / historical-use boundary
- stable authored hooks that are not live state

And World semantics such as:

- world positioning / tone
- T0 / open-future rules
- historical / cosmological baseline
- geography / institutions / society / material culture where authored
- knowledge and evidence boundaries
- GM operational guidance
- Entry seeds
- Expansion-owned vs World-owned material

## Design constraints

- `Narrative richness over artificial brevity.`
- `Model freedom first.`
- `玩法应该拉出 Schema；不要让玩法迁就先写好的万能 Schema。`
- Do not create a universal giant Asset schema.
- Do not move current location/relationship/injury/current knowledge/inventory/player-known/opening placement into Source.
- Do not create a production legacy importer.
- Because the product is unreleased, if current v0.1 is semantically wrong, correct it directly rather than building a compatibility forest.

## Deliverables

1. A semantic ownership/mapping audit under `docs/source/`.
2. A corrected/clarified World + Character Source contract if needed.
3. A clear decision: current v0.1 structurally adequate vs contract correction required.
4. GPT-owned faithful conversion specification/content for the two real asset families after the contract is frozen.
5. Only after semantic freeze, a narrow Codex implementation task if loader/validator/test code must change.

## Preservation / no rollback

Do not revert G4-03, G4-04 or the accepted portions of G4-05. Treat them as preserved engineering that must be regression-tested against any corrected contract.

- G4-03 remains PASS unless a concrete new contract change breaks it.
- G4-04 remains PASS/CLOSED.
- G4-05 Wizard/Composition implementation candidate `145c3e1` remains provisional engineering evidence; G4-05 itself stays REWORK/HOLD.

## Superseded task

`docs/tasks/G4-05R1_REAL_ASSET_FIDELITY_CORRECTION_TASK.md` is **SUPERSEDED / DO NOT EXECUTE** by owner decision. Codex has no active task during this semantic re-audit.

## Exit

G4-02R1 exits only when GPT can answer, from real asset evidence:

> “The current Source contract can faithfully carry the authored semantics we actually need, and the real assets can be migrated without semantic shrinkage or legacy host debt.”

Then proceed to content migration and, only if necessary, a Codex code correction.
