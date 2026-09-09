# TASK｜MW-027｜Open Threads / 事务

Type: G6 Package-3 core information vertical  
Work Item: **MW-027**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Owner UAT: **may be deferred / combined with a later concentrated Product UAT; implementer must not claim Product PASS**  
Required branch: `mw-027-open-threads`  
Required worktree: `D:/AI/Projects/.worktrees/my-world/mw-027-open-threads`  
Formal Code Base: `5820c20b1150cd998b626e56fce79c023004b5ec`  
Governance Base: `dbc83f67d0bacbf973c00d278fa760089f3152b3`  
Frozen architecture: `Vibe-Coding/my world/architecture/ui/G6_OPEN_THREADS_SURFACE_V1_0_DECISION.md@v1.0`  
Parent route: **G6 Package 3｜Core Information Continuity**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Product outcome

Implement the first real `事务 / Open Threads` vertical.

It answers one player-facing question:

> **“最近有哪些还没有真正结束、但值得我继续记住和跟进的事情？”**

After this task, a normal accepted role-action turn can let the **existing Information Curator** decide that a meaningful unresolved matter should be added, updated, retained or removed; that current snapshot is then durably stored, shown in a new `事务` surface, follows Save / reopen / Restore / Regenerate currentness, and appears in Debug Mode as `threads changed / no-change / failed` evidence.

This is not a Quest system and not a task manager.

## 2. Authority / read first

Refresh both repository mains before implementation. Resolve any newer conflicting Owner/GPT decision before editing.

Read in order:

1. implementation repo `AGENTS.md`;
2. governance `AGENTS.md`;
3. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`;
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md@v4.5`;
5. `Vibe-Coding/my world/architecture/ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`;
6. `Vibe-Coding/my world/architecture/ui/G6_OPEN_THREADS_SURFACE_V1_0_DECISION.md@v1.0`;
7. current implementation seams:
   - `src/信息整理/L0_公理层/信息整理契约.gd`
   - `src/信息整理/L1_器件层/信息整理响应解析器.gd`
   - `src/信息整理/L1_器件层/角色经历投影器.gd`
   - `src/信息整理/L1_器件层/人物认知投影器.gd`
   - `src/信息整理/L2_流程层/回合信息整理流程.gd`
   - `src/信息整理/L3_外交层/信息整理公开接口.gd`
   - `src/信息整理/L3_外交层/角色经历投影公开接口.gd`
   - `src/信息整理/L3_外交层/人物投影公开接口.gd`
   - `src/调试观测/L3_外交层/会话调试观测公开接口.gd`
   - `src/应用壳.gd`
   - `src/main.tscn`;
8. directly affected MW-015 R1 / MW-018 R1 / MW-022 / MW-024 / MW-025 / MW-026 tests and evidence.

STOP only for a genuinely superseding decision or a real currentness/storage blocker that requires architecture beyond the frozen Package-3 boundary.

## 3. Core semantic boundary — Model Freedom First

The model owns all open semantic judgments about Threads:

- whether a current unresolved matter is worth persistent attention;
- whether this turn adds a thread;
- whether an existing thread materially changed;
- whether a thread has been resolved, expired, superseded or is no longer worth occupying the player’s attention;
- how to summarize the current player-known state.

Program owns only bounded structure, persistence, currentness and presentation.

**Do not implement** keyword/regex task detection, Quest types, importance scoring, priority inference, event classifiers, turn thresholds, completion heuristics, fixed semantic categories or other rule forests.

Current scene presence is neither necessary nor sufficient. Off-screen unresolved matters may remain important; incidental current-scene problems may be omitted. Zero current Threads is valid.

## 4. Information Curator integration — one existing semantic call

Extend the existing lived Information Curator response. Do **not** add a dedicated Open Threads Provider request.

The existing post-turn call should maintain:

```text
Character
+ Important Experiences
+ People
+ Open Threads
```

in the same lived curation opportunity.

### 4.1 Curator input

Add only the current **player-safe Open Threads snapshot** to the existing bounded input material.

Preserve current safety boundaries:

- accepted current Player role action + accepted current GM Narrative are valid lived evidence;
- current safe Character / recent Important Experiences / People evidence remain as already authorized;
- OOC remains excluded from lived curation opportunities;
- do not feed raw `world_state`;
- do not feed NPC-private Knowledge / Agency / Evolution;
- do not feed undisclosed background developments to “complete” a thread;
- do not add a second fact source.

The Curator prompt must explain the product distinction clearly but minimally:

- Character = “现在的我是谁”;
- Important Experiences = “哪些过去事件真正塑造了我”;
- People = “我目前对值得持续记住的人最近最新知道什么”;
- Open Threads = “现在还有哪些值得我继续记住的未完事项”.

Long-term identity/direction remains Character. Threads may represent the current unresolved/actionable part without duplicating a second Character truth.

### 4.2 Lived response field

Add:

```json
"open_threads": null
```

or:

```json
"open_threads": [
  {
    "title": "简洁标题",
    "summary": "当前为什么仍然悬而未决，以及玩家现在知道的关键状态",
    "details": ["必要时补充的玩家已知信息"]
  }
]
```

Semantics:

- `null` = keep current Threads snapshot unchanged;
- non-null array = complete replacement of the current Threads snapshot;
- `[]` = clear the current Threads snapshot.

Bounds:

- max 12 threads;
- title <=160 Unicode chars;
- summary <=800 chars;
- details max 4 items, each <=500 chars;
- exact allowed keys only;
- no `type`, `priority`, `progress`, `quest_state`, `deadline` or similar pre-baked semantic fields.

Program validates shape/size only. It must not decide whether text is “important enough” or whether a thread “sounds resolved”.

## 5. Backward-compatible curation storage evolution

Reuse the existing `information_curation` owner. **No new SQLite table or second storage owner.**

Evolve lived records through a backward-readable schema variant, expected direction:

```text
information_curation_lived.v0.2  remains readable
information_curation_lived.v0.3  writes Character + Experiences + People + Open Threads
```

Equivalent naming is allowed only if compatibility/currentness semantics are exactly preserved and clearly reported.

Requirements:

- legacy pre-People records remain readable;
- current v0.2 lived records remain readable and retain their original ID-validation rules;
- new v0.3 IDs bind the exact new normalized result plus the existing identity-receipt dependency where applicable;
- do not rewrite/migrate historical records merely to add an empty Threads field;
- current accepted prefix + parent chain remains authoritative;
- displaced future / stale records remain excluded;
- durable no-change curation receipts continue preventing reopen duplicate calls;
- Save / reopen / Restore / Regenerate currentness remains authoritative.

Old games receive **no historical backfill** and no Source-current task seeding. They begin maintaining Threads only from new accepted lived action opportunities after the feature exists.

The initial Character-curation lane must not create Open Threads from frozen starting profile or world setup.

### 5.1 Parser compatibility

Old structured lived responses without `open_threads` must remain valid and mean **Threads no-op**, not an inferred empty list and not guessed content.

A response explicitly carrying malformed/oversize `open_threads` must fail safely under a machine-structure rule. Preserve existing Character / Experiences / People behavior as far as the current parser’s bounded atomicity allows; do not introduce semantic repair or heuristic reconstruction just to salvage Threads.

## 6. Current Threads fold and player-safe projection

Implement a small pure/current Threads fold over already validated current curation records:

```text
initial current Threads = []
for each current lived record in order:
  open_threads == null → keep prior snapshot
  open_threads is Array → replace prior snapshot completely
```

Expose a bounded L3 player-safe projection containing only:

```text
title
summary
details
```

No persistence IDs, prefix/hash, receipts, raw curation payload or hidden World/NPC material may cross the presentation seam.

Leaf UI must consume this L3 projection; it must not receive omniscient `world_state` and locally filter it.

## 7. Player-facing `事务` surface

Extend the existing bounded World Information Host navigation to:

```text
概览 | 角色 | 重要经历 | 人物 | 事务 | 存档
```

Add a simple, comfortable current list/card presentation for `事务`:

- title;
- summary;
- bounded details when present;
- clear empty state when current Threads is empty.

Keep MW-023 gameplay typography/readability baseline.

v1.0 deliberately has no:

- checkbox / manual complete;
- player editing;
- search/filter/sort/paging;
- priority controls;
- task status dropdown;
- click-to-generate-action behavior;
- generic Action Intent;
- Dynamic UI abstraction.

This task should implement the real consumer directly and leave Package 6 to abstract proven UI vocabulary later.

## 8. Debug Mode integration

Extend the existing read-only curation observability seam with a `threads` lane.

The observer should compare **player-safe before/after Threads projections** and report bounded structural evidence only:

```text
threads
→ committed + changed | committed + no-change
→ failed | stale | cancelled when the shared curation opportunity reaches those terminals
→ safe total count when available
```

Do not display hidden thread source material, raw curation response, provider payload or model reasoning. Debug remains read-only and must not feed data back into the Curator.

Ensure the existing `character`, `experiences` and `people` lanes retain their semantics.

## 9. Fail-soft / lifecycle requirements

Preserve the current background nature of Information Curation:

- accepted Narrative remains accepted even if curation fails;
- next normal Player action is not blocked by a Threads failure;
- timeout/provider failure/malformed response does not create fake Threads;
- stale callback cannot cross Restore/Regenerate/currentness boundaries;
- no loosening of existing identity-receipt safety for People;
- if People identity receipt becomes stale, existing behavior may suppress People writes without incorrectly suppressing valid current Character / Experiences / Threads results;
- reopening/rendering/tab switching does not trigger Provider calls.

## 10. Engineering acceptance

At minimum prove deterministically:

1. valid `open_threads=null`, replacement array and `[]` clear normalize correctly;
2. extra keys, oversize values, too many threads/details and malformed shapes are rejected safely;
3. v0.2 lived history remains readable with identical historical ID/currentness validation;
4. v0.3 lived records validate their new result/ID correctly;
5. sequence `replace → null → replace → []` folds to the expected current snapshot;
6. Restore before/after a Thread-changing record projects the corresponding current snapshot;
7. displaced future and stale callback cannot reappear in Threads;
8. an old response with no `open_threads` preserves the previous snapshot as no-op;
9. Initial Character curation creates no Threads and makes no additional call;
10. one accepted action creates at most the existing one Information Curator call — **no extra Open Threads call**;
11. OOC produces no lived Thread-curation opportunity;
12. request material includes current safe Threads but excludes raw/private canaries;
13. player-safe projection exports only title/summary/details;
14. Debug reports Threads changed/no-change and abnormal terminals without exposing content/private data;
15. `事务` tab renders non-empty and empty states and does not directly read raw world state;
16. Save/reopen/Restore/regenerate regressions remain sound;
17. Character / Important Experiences / People curation and projections do not regress.

Run directly affected regression suites, especially MW-015 R1, MW-018 R1, MW-022, MW-024, MW-025 and MW-026 plus current persistence/currentness tests.

Perform final Godot 4.7.2 import and fresh Windows export / `run-game.ps1 -ValidateExportOnly` before return.

A real Provider call is not required for Engineering PASS if deterministic semantic plumbing is proven. If used, keep it bounded and report it explicitly; it still does not replace Owner Product UAT.

## 11. Product Value Acceptance

Engineering evidence must make the following product behavior plausible and inspectable for later Owner UAT:

- a genuinely meaningful unresolved matter can appear in `事务`;
- an ordinary turn can leave `事务` unchanged;
- a resolved/expired/no-longer-relevant matter can disappear from the current snapshot;
- off-screen but still important matters are not structurally excluded merely because they are absent from the current scene;
- incidental scene details are not Program-forced into task cards;
- Restore changes `事务` to the snapshot belonging to that Timeline;
- Debug gives Owner a low-cost signal that Threads changed/no-changed/failed.

Do **not** encode special fixtures such as “promise always becomes a thread” as production logic. Controlled test responses may prove plumbing, but real semantic choice remains model-owned.

## 12. Protected invariants

Must preserve:

- Model Freedom First;
- Reversibility over prevention;
- World Truth != actor Knowledge != human-player disclosure;
- UI/Debug is projection, never second truth;
- one Post-turn Information Curator semantic call for enabled information surfaces;
- current Character snapshot semantics;
- sparse Important Experiences milestone semantics;
- People latest-known / stable-identity safety;
- OOC typed-mode exclusion from lived action semantics;
- Save / Restore / Regenerate currentness;
- Debug read-only behavior;
- Narrative non-blocking curation;
- >=20px gameplay readability baseline;
- free-form natural-language role action remains primary.

## 13. Explicit non-scope

Do not implement:

- Quest engine / quest giver / quest rewards;
- keyword/regex task detection;
- importance score / task priority inference / rule-based completion;
- manual user task manager or checkbox workflow;
- hidden World objective viewer;
- separate Open Threads model call;
- new SQLite table/storage owner;
- historical Thread backfill / Source-current seeding;
- Organization/Faction surface;
- System Surface;
- Inventory;
- Dynamic UI Host;
- generic Action Intent;
- full Consequence Diff;
- Context Orchestrator / long-session memory platform;
- player hide/edit preferences — still deferred to Package 6 convergence;
- unrelated shell refactor, G3 debt, layer cleanup, warning cleanup or general visual redesign.

## 14. Return requirements

Commit + push only to `mw-027-open-threads`.

Write:

`docs/mw027/MW-027_IMPLEMENTATION_RETURN.md`

Return:

- exact Starting HEAD;
- exact Implementation HEAD;
- exact Final candidate HEAD;
- changed production files;
- lived schema/backward-compatibility evidence;
- focused + regression results;
- explicit Provider call count;
- Debug evidence;
- UI/window evidence sufficient to prove operability/readability;
- import/export/ValidateExportOnly results;
- residual risks or semantic uncertainties.

Do not merge `main`.
Do not install an Owner build unless separately authorized.
Do not announce Product PASS.

Highest state:

**READY FOR INDEPENDENT REVIEW**
