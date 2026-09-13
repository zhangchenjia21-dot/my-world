# TASK｜MW-033｜G7 Narrative Working-Set Orchestrator v0.1

Type: implementation  
Owner: Codex  
Capability-Anchor: G7 Package 8｜Long-session Core  
Revision: 1  
Review-Round: 0  
Base: `zhangchenjia21-dot/my-world@e876e217f0220fdc6a577cd0b52143dc8d5b6b5c`  
Required branch: `mw-033-g7-narrative-working-set`  
Required worktree: `D:/AI/Projects/.worktrees/my-world/mw-033-g7-narrative-working-set`  
Governance architecture: `Vibe-Coding/my world/architecture/G7_NARRATIVE_WORKING_SET_ORCHESTRATOR_V0_1_DECISION.md@v1.0`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Evolve the existing Narrative Context assembly responsibility into one bounded **Narrative Working-Set Orchestrator v0.1** for ordinary post-Opening continuation.

After this task, a long-running Game's Narrative request must be assembled from current canonical-owner contributions under the active model's validated context capacity instead of blindly concatenating a full frozen T0 monolith plus a fixed recent-12 transcript.

The first slice must make current Character / Important Experiences / People / Open Threads first-class Narrative continuity material, preserve current World/Knowledge/Agency/Evolution + Inventory + mechanics authority, keep recent accepted Conversation current/atomic, and omit lower-tier background deterministically when the request budget is pressured.

## 2. Why now

G6 Core engineering is complete and Package-7 corrections are reviewed/integrated. G7 Package 8 is now the mainline.

Production evidence shows two real long-session problems at the same seam:

1. current Narrative continuation concatenates several independently bounded sources but has no cross-domain working-set owner or global model-capacity budget;
2. model-curated current Character / People / Threads / Experiences exist durably, but Narrative continuity still depends heavily on the most recent 12 transcript Turns plus broad T0 source material.

Two retained G3 Context failures also expose an obsolete assertion: they correctly intended to prohibit raw/stale persisted World/Provider blobs, but now incorrectly reject any legitimate derived `Current Game Context`. MW-033 must replace that stale assertion with the true authority/currentness boundary.

## 3. Product value

Primary Purpose remains:

> let one player keep playing a durable, evolving AI RPG world for long sessions with a GM that remembers the current situation without turning the prompt into an ever-growing database dump.

Core-value invariant:

**INV-PRODUCT-01** — A longer Game must not make the GM forget current protagonist identity, current unresolved matters, player-known people, or current durable world consequences merely because the supporting Turn fell outside a fixed recent transcript window.

**INV-PRODUCT-02** — Context hardening must not achieve boundedness by starving the GM of useful current material or artificially shortening Narrative output.

This task is infrastructure-facing; Product Value PASS remains deferred to the later concentrated G7 Owner long-session test.

## 4. Authority / Source Manifest

Authority order for this task:

1. Owner current explicit instruction.
2. `Vibe-Coding/AGENTS.md` + Owner collaboration preferences.
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`.
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`.
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md` + Roadmap v5.1 + Current Status v18.0 or newer current versions.
6. **Frozen task architecture:** `Vibe-Coding/my world/architecture/G7_NARRATIVE_WORKING_SET_ORCHESTRATOR_V0_1_DECISION.md@v1.0`.
7. Implementation code/tests at Formal Base `e876e217f0220fdc6a577cd0b52143dc8d5b6b5c`.
8. Current `Vibe-Coding/skill/gpt/lifecycle-dev-process/SKILL.md` and `agent-task-packet/SKILL.md` for execution discipline.

Historical G2/G3 task packets and old Context assertions are evidence, not authority when they conflict with current frozen architecture.

`my-world/AGENTS.md` has a stale phase/status summary; its stable repository rules still apply, but current governance wins on phase/route facts.

## 5. Freshness gate before edits

Before modifying production code:

1. fetch `my-world/main`, this task branch, and `Vibe-Coding/main`;
2. verify implementation `main` is still compatible with Formal Base `e876e217...` and no newer reviewed product implementation supersedes this task;
3. verify the G7 v0.1 architecture remains current/unsuperseded;
4. inspect worktrees and do not overwrite unknown local work;
5. if Product/Architecture/Status materially changed, STOP and return the conflict rather than implementing the old packet.

## 6. Read first — minimal initial set

Read these first, then expand only for concrete evidence:

1. repo `AGENTS.md`;
2. this Task Packet;
3. frozen G7 architecture decision;
4. `src/context/上下文组装器.gd` + its L3 public interface;
5. `src/首次开场/L2_流程层/首次开场运行流程.gd` and `src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd`;
6. `src/世界回合/L3_外交层/世界回合上下文公开接口.gd` + its projector;
7. `src/运行时设置/L3_外交层/模型运行时设置公开接口.gd`, Information Curation current projection L3 seams, and the two failing G3 Context tests only as needed by the implementation.

Do not read the whole repository by default.

## 7. Frozen architecture / invariants

### INV-01｜One Context request owner

Evolve the existing `src/context` request-assembly responsibility. Do not add a parallel Context/Memory owner.

Context working set is request-derived material, not durable truth.

### INV-02｜Canonical owners contribute; Orchestrator does not reinterpret truth

The Orchestrator must not receive raw `world_state` and invent semantic filtering.

Each non-Conversation contribution must come from the current domain's L3/public projection seam or a narrow new domain-owned model-context projection.

Context may decide **whether a whole authorized block fits the Narrative request**. It may not decide whether the underlying fact is true, whether a People referent is a real World actor, or whether an Open Thread is semantically important.

### INV-03｜First Opening unchanged

MW-033 targets ordinary continuation **after** Opening/current history exists.

First Opening must keep its current exact frozen Game-local source path. Do not weaken first-scene grounding to make continuation architecture symmetrical.

### INV-04｜Current curation becomes Narrative material

Add/extend an Information Curation L3 request-context projection that can provide current validated:

- Character;
- Important Experiences;
- People;
- Open Threads.

It must be request/model material, not UI presentation state.

UI hide/recover preferences MUST NOT affect model Context eligibility.

Do not expose presentation keys, durable subject/thread IDs or model request refs just because they exist internally.

People material must be explicitly framed as **player-known information** and preserve uncertainty; injection into Narrative Context does not prove World actor existence.

### INV-05｜Current World / Knowledge / Agency / Evolution authority stays intact

Reuse the current accepted-history/hash-bound World Turn Context projection. Do not weaken currentness, provenance or disclosure rules to make orchestration easier.

### INV-06｜Inventory / mechanics remain owned by their domains

Consume bounded projections only. No second inventory/mechanics state in Context.

### INV-07｜Conversation remains raw accepted transcript

Current Player attempt is mandatory and appears exactly once.

Accepted Player/GM text selected for transcript must remain exact bytes/text semantics; Program must not summarize/rewrite accepted turns.

Select complete Turn units only. Newest eligible turns may be chosen first under pressure, then rendered in chronological order.

Cancelled/failed drafts and displaced future history never enter Context.

OOC mode semantics remain preserved.

### INV-08｜Structural priority only

Frozen tiers:

```text
P0 REQUIRED
- GM/system protocol
- current Player attempt/input mode
- minimum Game/World identity + World/GM instructions needed to interpret the current Game

P1 CURRENT CONTINUITY
- latest complete accepted Conversation turns
- current Character
- current Open Threads
- current World/Knowledge/Agency/Evolution
- factual Inventory / current public mechanics

P2 DURABLE BACKGROUND
- Important Experiences
- current People
- selected T0 semantic/source background
- Guaranteed NPC authored source background
- literary style reference
```

These tiers express consumer structure, not story importance.

Do not introduce keywords, fame tables, person/thread scores, quest priority, embedding similarity or hidden semantic ranking.

Within one domain, preserve its own bounded/current order unless its public seam explicitly owns a narrower order.

### INV-09｜Budget comes from current model settings

Use `ModelRuntimeSettingsPublicInterface.context_budget_metadata()` / validated request profile as the authoritative context capacity source.

Supported profiles currently expose `context_token_ceiling` for 256k/1m where valid.

Frozen v0.1 accounting:

```text
Narrative safe input byte budget = floor(context_token_ceiling * 0.80)
```

Use final UTF-8 request/message serialization size as conservative accounting. The exact internal calculation may include fixed deterministic envelope overhead, but evidence must prove the actual final `messages` payload being handed to the Provider remains within the derived budget.

The >=20% remainder is reserve for generated Narrative + request/Provider overhead. It is NOT a Narrative `max_tokens` cap.

No mid-block truncation.

If P0 cannot fit: assembly fails loud and **zero Provider start** occurs.

If P1/P2 does not fit: omit the whole block and record a safe diagnostic reason.

### INV-10｜No durable Context cache

Do not persist final Provider messages or selected working-set snapshots as truth.

Reopen / Restore / Regenerate rebuild from current owners.

## 8. Contribution design constraints

A small internal Narrative-only contribution shape is allowed if useful, for example fields equivalent to:

```text
family / stable request-local key
priority tier
text or message unit
atomic selection unit
diagnostic-safe size/currentness metadata
```

This is an **internal consumer contract**, not an external plugin/Creator protocol.

Do not over-generalize into arbitrary callbacks, entity graphs, external schemas or universal model-message DSLs.

### 8.1 Game/T0 continuation projection

Current `GameLocalOpeningContextProjector.project()` is a full Opening/T0 view and may remain so for first Opening.

For continuation, add a bounded/block form or equivalent narrow projection so broad T0 material is separable rather than one monolithic string.

Must retain stable Game/World/GM instructions and exact source inertia, but full frozen Player Character + every Guaranteed NPC semantic section should no longer be inseparable mandatory continuation input.

Do not query mutable Source current.

### 8.2 Information Curation request-context projection

Prefer one narrow L3 aggregate specifically for model Context rather than having `src/context` reach into several L1 devices or UI surfaces.

It must use the same validated/current curation semantics and preserve Restore/Regenerate accepted-history binding.

Hidden UI presentation state is not an input.

## 9. Selection behavior

Selection order is structurally:

```text
P0 required
→ P1 current continuity
→ P2 durable background while budget remains
```

Implementation may interleave P1 subfamilies only to prevent one bounded P1 family from starving every other P1 family, but any such policy must be simple, deterministic, documented and structural. Do not create a semantic score.

At minimum prove that a large T0 background block cannot crowd out all current Character/Threads/World continuity merely because it was authored first.

If a listed P1/P2 family cannot safely be selected without semantic ranking, STOP with evidence rather than silently inventing importance logic.

## 10. Safe diagnostics

Expose request-local read-only diagnostics sufficient for engineering review:

- profile/context limit/token ceiling;
- derived safe input byte budget;
- final messages byte count;
- considered/included/omitted blocks by family;
- included/omitted bytes by family;
- omission reason (`budget`, `empty`, `not_current`, etc.);
- accepted Conversation turn count/range selected;
- whether Character / Experiences / People / Threads were present;
- local assembly latency if practical.

Do not dump secrets, raw omniscient `world_state`, raw private material merely for logs, or internal durable IDs.

Use existing Debug/UAT seams where helpful, but no new polished diagnostics UI is required.

## 11. G3 regression correction

Update:

- `tests/g3_03/上下文恢复与界面测试.gd`;
- `tests/g3_05/恢复时间线持久化测试.gd`.

Do not delete their Context safety coverage and do not mark them expected-fail.

Replace the obsolete “no `Current Game Context` at all” premise with stronger assertions proving:

- no persisted Provider/context request blob reuse;
- no raw whole `world_state` serialization;
- no `accepted_turns_json`, `materialization_json` or persistence-internal payload leakage;
- Restore/Recovery excludes displaced-future branch marker;
- only current accepted Conversation enters transcript;
- legitimate owner-projected Game/World Context is allowed/current;
- reopening builds a fresh derived working set rather than restoring old messages.

These two suites should become green for the right reason.

## 12. Explicit non-scope

Do NOT implement in MW-033:

- embeddings / vector DB;
- semantic similarity retrieval;
- model-generated memory summary as new truth;
- universal Context protocol for every AI lane;
- Structured Output Reliability middleware;
- generalized retry/JSON repair layer;
- Knowledge Provenance/Epistemic/Reality Correction Package 9;
- new durable Context tables/caches;
- Provider routing/model split redesign;
- output `max_tokens` cap or “be concise” Narrative instruction;
- external Source/Expansion/Creator Context protocol;
- UI redesign;
- People/Threads semantic reranking;
- broad World/Knowledge ownership rewrite.

## 13. Required implementation evidence

Create a focused `tests/mw033/` vertical (or equivalent repository-native test group) that uses production Context/continuation paths with deterministic domain fixtures/stubs.

At minimum prove:

### AC-01｜Single continuation owner
Ordinary created-Game Narrative continuation reaches one `src/context` working-set owner and final Provider messages come from it.

### AC-02｜First Opening unchanged
First Opening still receives exact frozen Game-local material and is not routed through long-session omission logic.

### AC-03｜Model capacity source
256k and supported 1m runtime settings produce different correct token ceiling / safe byte budget metadata without hardcoding one universal context size.

### AC-04｜Final payload budget
Actual final serialized `messages` payload handed toward Provider is <= derived safe input byte budget.

### AC-05｜P0 fail-loud
An intentionally oversized required instruction/current-attempt fixture fails Context assembly and starts Provider zero times.

### AC-06｜Atomic omission
Budget pressure omits whole non-P0 blocks / complete Turns; no partial Turn, source section, People/Thread card or arbitrary byte slice appears.

### AC-07｜Current curation survives transcript roll-off
After >12 accepted Turns, a current Character / Thread / People item whose originating Turn is no longer in recent transcript can still be present through current curation projection.

### AC-08｜Epistemic boundary
Referent-only People is labelled/player-known context and does not materialize a World actor or gain authoritative actor semantics because Narrative sees it.

### AC-09｜Hide preference independence
Hiding a People / Experience / Thread card changes zero model Context eligibility/content apart from unrelated current semantic updates.

### AC-10｜Current World contribution
Stale/nonmatching World/Knowledge/Agency/Evolution records remain excluded by existing hash/currentness rules.

### AC-11｜Restore / Regenerate / reopen
Displaced future transcript + curation + World contribution disappears after Restore; replacement current history is used after Regenerate; reopen reconstructs current derived messages without stored request bytes.

### AC-12｜Conversation ordering
Under pressure newest complete eligible Turns are retained according to the chosen deterministic policy, rendered chronological, and current attempt appears exactly once.

### AC-13｜T0 background does not crowd current state
A large low-tier authored/T0 fixture can be omitted while current P1 continuity survives; 1m may admit more background than 256k where the deterministic fixture allows it.

### AC-14｜G3 safety tests repaired
The two prior G3 failing suites pass with new raw/stale-leak assertions, not by deleting coverage.

### AC-15｜Diagnostics
Focused evidence can show exactly which families were included/omitted and why without secrets/private raw-state dumps.

### AC-16｜No Provider dependence for deterministic proof
Focused correctness must not require paid/live Provider calls.

## 14. Regression gate

Run focused → directly affected → broad relevant regressions.

At minimum include current tests for:

- G2 Conversation/Context/Regenerate/OOC;
- G3-03 and G3-05 Restore/Recovery Context;
- G4 created Game first Opening + continuation;
- G5 World Context/Knowledge/Agency/Evolution currentness;
- G6 Character/Experiences/People/Threads/Inventory/System and MW-032 Opening/currentness paths;
- recommendations only where Context changes can affect shared lifecycle/bootstrap behavior.

Any retained failure must be reproduced against exact Formal Base and explained. The two old G3 Context assertions are expected to become **PASS**, not retained known failures.

## 15. Real-window / product-path validation

This task should not redesign UI, but the final candidate must still prove ordinary Game activation/continuation remains operable at existing supported product sizes if touched by integration.

At minimum run the directly affected real-window/product continuation smoke path and existing current 960×540 / 1280×720 / 1920×1080 gate if the repository harness makes it practical.

No visual-polish work is authorized.

## 16. Build gate

Before return:

- Godot 4.7.2 final import;
- fresh Windows export;
- `run-game.ps1 -ValidateExportOnly`;
- no Owner build installation;
- do not launch/mutate Owner's real Game data.

## 17. Git / integration discipline

- work only in `mw-033-g7-narrative-working-set` / required worktree;
- do not merge `main`;
- do not force push/rewrite shared history;
- do not overwrite unknown dirty work;
- commit implementation + evidence;
- push branch;
- before final push re-fetch implementation/governance current and perform Decision Propagation check;
- if `main` advanced with relevant product/architecture work, reconcile/STOP rather than silently returning an old-base candidate.

## 18. Stop conditions

STOP and return evidence if:

- current Product/Architecture/Status supersedes this Context design;
- a current domain cannot expose safe Narrative material without changing its semantic owner;
- a P0 requirement cannot be represented without raw/private authority leakage;
- selected runtime context capacity cannot be read safely from the existing settings seam;
- meeting the task would require embeddings/semantic ranking/general memory platform;
- first Opening cannot remain behaviorally intact without a broader architecture change;
- unknown newer/dirty work would be overwritten.

Do not STOP for normal implementation choices within the frozen boundary.

## 19. Return requirements

Highest status: **READY FOR INDEPENDENT REVIEW**.

Return:

- Starting HEAD;
- production implementation HEAD;
- final candidate HEAD;
- push confirmation / remote tip;
- changed-file summary;
- architecture mapping (which owner contributes what);
- focused test results and evidence paths;
- repaired G3-03/G3-05 results;
- relevant regression manifest;
- 256k/1m budget evidence;
- Restore/Regenerate/reopen evidence;
- import/export/ValidateExportOnly evidence;
- real Provider call count;
- any retained known failures with exact-baseline proof;
- deviations/risks.

Do not claim Product PASS or G7 completion.