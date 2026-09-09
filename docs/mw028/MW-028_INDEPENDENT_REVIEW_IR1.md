# MW-028｜Independent Review IR1

Status: **ENGINEERING PASS_WITH_NOTES**

Reviewer: GPT  
Work Item: **MW-028｜System / Public d20 Surface**  
Formal Code Base: `5a336d0a993fd7e91b05b98f9b0cc14d2bb47b21`  
Task Packet / Starting HEAD: `bf640238bedfbea50aba9362a6068e70366b3852`  
Production Implementation HEAD: `b62554f7d2bb623ce213328a48bb3b01fe191d15`  
Submitted Final Candidate: `6f7fa9096215a59a35c61a2bcf59ca52f7f4056d`  
Frozen architecture: `Vibe-Coding/my world/architecture/ui/G6_SYSTEM_PUBLIC_MECHANICS_SURFACE_V1_0_DECISION.md@v1.0`

## 1. Freshness / lineage

Independent Review refreshed both canonical repositories before verdict:

- implementation `my-world/main` remained exactly the Formal Code Base `5a336d0a993fd7e91b05b98f9b0cc14d2bb47b21`;
- governance `Vibe-Coding/main` had advanced to `5cce69a97352c5e20a2df131707b37897ae932a9`, but the newer change is unrelated Minecraft Skill work. The current `my world` status remains v17.23, roadmap v4.6, with MW-028 current and the System/Public d20 decision still `FROZEN / CURRENT` v1.0.

The submitted branch tip is exactly `6f7fa9096215a59a35c61a2bcf59ca52f7f4056d`. It is three commits ahead of the Formal Base, and the production implementation is the single implementation commit `b62554f7d2bb623ce213328a48bb3b01fe191d15`; the later candidate commit is documentation/evidence only.

## 2. Independent architecture / product audit

### 2.1 Truth ownership and shared currentness seam — PASS

The implementation does not create a second mechanics owner. Existing Public d20 durable CHECK/NO_CHECK records remain authoritative.

`公开机制历史投影器.gd` extracts one `_current_records(world_state, entries)` selection seam. Both:

- existing GM continuity text (`project()`), and
- new player structural System projection (`project_checks()`)

are derived from that same selected record set.

The selector still requires accepted role-action Conversation pairing and rejects CHECK/NO_CHECK conflict at the same accepted slot by omission. OOC and empty-player opening entries are excluded. No Narrative prose inference or new System-specific currentness owner was introduced.

The existing GM projection deliberately erases the three newly carried structural-only fields before serialization, preserving the pre-MW-028 field set/order and recent-12 CHECK+NO_CHECK continuity behavior.

### 2.2 Player-safe System DTO — PASS

The dedicated L3 projection exposes only the frozen structural CHECK allowlist:

`accepted_turn, intent, dc, modifier, modifier_reason, stance, situation_reason, raw_rolls, selected_roll, total, outcome, success_intent, failure_stakes`.

It returns detached copies, newest-first, maximum 12 CHECKs. Internal `action_id`, `check_id`, resolution/control payloads, hashes, raw World and private material are not projected.

Routine accepted NO_CHECK remains valid durable mechanics truth and remains available to GM continuity, but is excluded from the persistent player System list exactly as frozen.

### 2.3 Existing d20 semantics — PASS

The implementation does not alter:

- CHECK/NO_CHECK decision semantics;
- DC / modifier / stance validation;
- Program RNG;
- stable action identity;
- no-reroll / replay behavior;
- durable acceptance markers;
- existing inline Narrative dice cards.

The only adjudication-process production addition is a payload-free `action_started` observation signal used by Debug, emitted after basic capability/provider readiness and before durable replay lookup. It introduces no extra Provider call, RNG use or persistence mutation.

### 2.4 Refresh timing / one-turn-lag risk — PASS

The frozen timing risk is handled correctly. Shell subscribes to adjudication `finished` and re-projects System after the durable mechanics acceptance marker has completed.

The focused proof is non-vacuous: it explicitly observes that Conversation `generation_completed` still sees no eligible new CHECK, then verifies the subsequent adjudication terminal makes the just-finished CHECK visible without another turn, tab cycle or reopen.

Activation/reopen and Restore continue to pass through the existing safe-panel refresh path; System tab navigation may re-project but performs no write or semantic call.

### 2.5 System Surface / navigation — PASS

World Information navigation becomes:

`概览 | 角色 | 重要经历 | 人物 | 事务 | 系统 | 存档`.

The new first-party System leaf presents `近期公开判定`, empty state `暂无公开判定记录。`, and exact CHECK facts including Program rolls/math, DC, modifier/stance reasons, outcome and stakes. It does not introduce HP/MP/Mana/Hunger/Money/Level/Buff/attributes or reactivate the empty Player Status Host.

The leaf consumes only the mechanics L3 array. No Runtime/world_state is passed into the leaf for local filtering.

### 2.6 Debug mechanics lane — PASS

The existing bounded Debug observer is extended rather than replaced. It observes the current adjudication owner and records safe structural mechanics terminals for:

- accepted CHECK → changed;
- accepted NO_CHECK → changed;
- already accepted replay → no-change;
- degraded accepted no-check path → no-change;
- failure;
- cancellation.

Rows contain only closed terminal/change/reason vocabulary and bounded `checks` / `no_checks` counts. Provider messages, control payloads, IDs/hashes, intent/stakes prose and private material are not emitted. Restore clears the pending mechanics token/diagnostic epoch; the focused test proves a late terminal cannot cross Restore.

### 2.7 Persistence / Restore / reopen — PASS

The structural projection uses current durable World + current accepted Conversation directly and adds no cache/table/second store.

Focused evidence covers:

- accepted CHECK appears;
- Save before/after;
- Restore before removes the CHECK immediately;
- Restore after restores the exact integer projection;
- session close/reopen preserves the exact projection;
- replaced/unaccepted/OOC records are absent;
- CHECK + NO_CHECK conflict fails soft;
- JSON number round-trip is normalized to integer semantics.

## 3. Independent test-quality audit

The MW-028 focused suite exercises production Runtime, SQLite, Shell, action adjudication, Debug observer and the real L3 projection with controlled Provider stubs. It does not replace the feature with a test-only implementation.

High-value assertions include:

- exact thirteen-field safe DTO and canary exclusion;
- detached nested `raw_rolls`;
- exact pre-existing GM context payload shape/values;
- actual controlled advantage roll `[7,18] → 18 + 2 = 20`;
- exactly two existing Provider requests for CHECK (control + narrative), with no System/Debug calls;
- inline Narrative mechanic card still present;
- actual Conversation-complete-before-marker ordering and post-terminal System refresh;
- CHECK / NO_CHECK / replay / degraded / failure / cancellation Debug wiring;
- Restore epoch isolation;
- 12-record bound and newest-first order;
- tab/render zero Provider calls and zero durable mutation;
- session close/reopen round-trip.

Recorded focused and real-window suites each report **377 checks / 0 failures**.

## 4. Regression / build audit

The direct regression batch contains 42 suites:

- **40 pass**;
- G3-03 still fails `opaque World JSON is not injected as Game Context`;
- G3-05 persistence still fails `raw World/Prompt truth leaked into Context`.

Both failures were reproduced on an isolated archive of the exact Formal Code Base `5a336d0a...`; MW-028 does not touch that Context debt and did not suppress or relabel it.

Existing teardown/resource warnings remain in the same known suites and are not new MW-028 blockers.

Final Godot 4.7.2 import passes. Fresh Windows export and `run-game.ps1 -ValidateExportOnly` pass; EXE/PCK/SQLite DLL are present and non-empty. The task-local PCK is freshly rebuilt and recorded as SHA256 `85E795598198A77975F7EFECFF3B2434C3C2C5A177FFD32FCB077FC0313C756B`.

## 5. Findings

No blocking engineering defect found.

No frozen-architecture rollback found:

- no second mechanics truth;
- no duplicated System currentness selector;
- no Narrative inference;
- no extra Provider call;
- no new persistence owner;
- no NO_CHECK player-list spam;
- no fake RPG state;
- no loss of inline dice card / no-reroll semantics;
- no privacy/currentness regression found in reviewed code/evidence.

## 6. Notes / remaining Product evidence

### N-01｜Product confirmation remains deferred

MW-028 intentionally used zero real Provider calls, which is appropriate because System is deterministic projection of Program-owned mechanics truth and the Task Packet did not require model-semantic sampling.

What remains Owner-owned Product evidence is primarily experiential: whether the System history is useful and readable during real play, and whether the combined mechanics experience feels coherent alongside inline dice feedback. Per current Owner instruction, this may be folded into the later concentrated UAT / Package 7 Reality Gate.

### N-02｜Known G3 Context debt remains

The two exact-baseline Context failures remain retained debt for later relevant Context work. Do not interrupt the Core-first route with unrelated G3 cleanup.

## 7. Verdict

**ENGINEERING PASS_WITH_NOTES**

MW-028 is safe to integrate by non-force fast-forward from the exact Formal Code Base through this reviewed branch lineage.

This verdict does **not** claim Product PASS. Proper post-integration status:

> **Package 4 / MW-028 = ENGINEERING PASS_WITH_NOTES / INTEGRATED / PRODUCT CONFIRMATION DEFERRED**

Per the current Core-first route, continue directly to Package 5 factual Inventory architecture/task shaping rather than requesting standalone Owner UAT now.
