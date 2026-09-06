# MW-015 R2 — Initial Character Curation implementation evidence

Status: **READY FOR INDEPENDENT REVIEW**
Work Item: MW-015 / Revision 2 / Review-Round 0
Implementer: Codex / Independent Reviewer: GPT

## Outcome

Game activation schedules a bounded model call from the Game's frozen player-safe starting profile. A successful result fills the existing right-side Character Sheet without any accepted opening or player turn. The empty left Player Status Host stays hidden. Later lived curation replaces current Character normally.

This is an implementation candidate, not Engineering PASS or Owner Product PASS. No merge to main and no Owner checkout installation/export were performed.

## Authority and lineage

- Branch: mw-015-r2-model-driven-initial-character-curation
- Worktree: D:/AI/Projects/.worktrees/my-world/mw-015-r2
- Gap evidence: cbe0f12c411f046cc17318fd1be856dcd2c13e43
- Refreshed implementation main: d4ce553049fcc1a8a67f120e7b7fb86b934f7c49
- Refreshed governance main: af25f3ff306757ebae1ee8215b804f7d03fd4ae6
- Authority update absorbed into task branch at 08aa01d55edfc3a39efb768627ebe2b2cfc820aa.
- Authorities: latest R2 packet, Initial Character Baseline decision, current status, Character/Important Experiences and model-driven curation decisions; prerequisite R1/MW-014/MW-011 Owner evidence.
- Earlier gap report/log remain historical evidence. The executable probe now asserts the approved extension and unchanged turn compatibility.

## Storage, identity and currentness

The schema label remains information_curation.v0.1 with backward-compatible optional initial:

    information_curation = {
      schema,
      initial?: { binding, id, result: { character, experiences: [] } },
      turns
    }

Binding is SHA-256 of sorted-key canonical JSON of the normalized, validated frozen player-safe profile {headline, summary, groups} actually supplied to the model. No authored group/item is semantically filtered by Program. Initial ID is the existing deterministic record hash over ["initial", binding, normalized_result].

The first successful baseline uses node ID initial-character-<binding> within the current Game's existing SQLite timeline namespace. Restore/reopen locates this immutable node through existing Persistence L3 get_timeline_node. Only its validated initial record is copied into the latest current World. No other subtree, turn, milestone or accepted Conversation is imported.

Re-attachment has a new mutation/node identity, avoiding displaced-future submission conflicts. The original fixed node remains the durable lookup anchor. No SQLite schema/table change, new storage owner, Source mutation, synthetic opening or turn 0/-1.

Old {schema, turns} remains accepted. Adding initial does not alter turn prefix, parent or ID; initial never enters the parent chain. Projection folds thin safe fallback → valid initial → current lived records. Non-null lived Character replaces the whole sheet; null retains the preceding sheet. Important Experiences only uses existing valid lived records.

Initial output with null Character or any milestone additions is rejected as a T0 lifecycle violation. Durable lookup is local to the current Game. Changed frozen material rejects the old binding.

## Trigger, failure and model boundary

Bootstrap's existing curator schedules initial work on its deferred activation pump. It owns a separate existing Provider adapter and no foreground action lock. Atomic Final Create remains unchanged and Provider-free. Accepted opening bytes are neither required nor included.

Exact initial request:

    system: concise Character semantics + bounded output protocol
    user: { frozen_starting_profile: { headline, summary, groups } }

The profile comes only from the existing fail-closed RPG profile L3 projection over frozen Game-local material. It excludes raw semantic_sections, GM references, catalog IDs, Source-current, omniscient World and private NPC Knowledge/Agency/Evolution. Starting possessions remain in input so the model decides to omit them.

Existing limits remain: 120-second timeout, 131072-byte input, 65536-byte response, JSON depth/type/field bounds and output-group vocabulary validation. Input binding and T0 milestone rejection are machine/lifecycle checks, not semantic classifiers.

One failed attempt per activation/explicit retry is fail-soft. Accepted Narrative and current projection remain. Successful results are durable and do not re-call on render/reopen/retry. Restore cancels in-flight requests and advances the epoch, then only initializes/re-attaches baseline automatically. It does not automatically re-curate restored missing lived records. Accepted-turn and explicit retry wakes remain for lived repair.

Missing/invalid frozen profiles report initial_profile_unavailable without model call or Source backfill. Invalid storage/read/commit errors are surfaced as curator status. No Owner production Game was altered to test compatibility.

## Verification

Reproducible offline entry: tests/mw015r2/运行初始角色离线验证.ps1

Evidence is under evidence/:

- Initial production Runtime/SQLite lifecycle: **60 checks, 0 failures**.
- Gap contract: **7 assertions, 0 failures**; synthetic indices remain unsupported.
- Real Zhang Chen Shell: opening failure leaves initial busy; seven groups refresh on finished with zero accepted entries; left hidden.
- Rendered **1280x720, 960x540 and maximized (2560x1351)**: viewport/no-horizontal-overflow assertions pass; top/bottom PNGs inspected, groups scroll-accessible.
- Existing MW-015 navigation/lived UI suite: passes.
- MW-014 lived curation: passes. Setup completes new initial lane with exact former thin baseline, preserving original assertions.
- MW-011 / MW-011R2 privacy/profile, MW-012 Zhang Chen, MW-009 safe projection: pass.
- G3 Save/Restore and G5 semantic materialization/timeline: pass.
- G4-07B Narrative critical path: assertions pass / exit 0. Existing exit diagnostics remain: 3 ObjectDB instances and 1 resource, matching counts in R1 evidence. Not represented as warning-free.
- Fresh Windows Desktop release export: passes, task worktree build only.
- No production changes outside information-curation module. No upward dependency or new cross-module internal import. L3 injects frozen-profile and Persistence L3 collaboration into L2. Chinese business test names.
- git diff --check: clean.

Tests cover initial-before-opening, no fabricated Conversation, exact safe input, possessions retained for model selection, successful replay, snapshot replacement/removal, null retention, old turn chains, same-binding durable reattachment after Restore + close + reopen, stale-future exclusion, Regenerate, invalid T0 milestones, Provider/commit failures, foreground availability and incompatible old profiles.

## Real Provider evidence and limits

Provider: existing configured Kimi K3 / k3-256k. Four initial-curation calls across two isolated batches; no Narrative generation or player turns supplied.

- Batch 01 fresh: malformed_response; no baseline committed, fallback retained. Raw response was not captured, so the precise failed structural clause is not claimed.
- Batch 01 existing: initial_committed, seven groups, zero milestones, reopen preserved projection without Provider.
- Batch 02 fresh and existing: both initial_committed, seven groups, zero milestones, reopen preserved projection without Provider. Raw player-safe responses captured.
- Batch 02 repeated both modes; the attempted single-mode launcher option did not restrict that run. Delivered launcher explicitly runs two bounded cases.
- Source lookup occurs only in smoke setup to create isolated Games from real installed Zhang Chen. Existing case closes/reopens a compatible Game with frozen material and no initial. Production curator has no Source lookup.
- Input includes 军用水壶 / 军用多功能刀具 / 手表 / 指南针 / 便携压缩口粮. Successful output retains background, personality/principles, capabilities, limitations and self-direction while omitting those possessions. This is human inspection of output, not a production keyword classifier.
- Owner settings, Source Library, Games, Game Library and current DB fingerprints unchanged in both batches.
- Model wording remains subject to Independent Review / Owner UAT. Malformed responses remain possible; no heuristic repair or fallback model.

Real launcher: tests/mw015r2/运行真实初始角色验证.ps1

It requires a fresh task-owned build/mw015r2 root, injects only configured credentials into the child and records Owner safety fingerprints without printing credentials.

## Changed files / Return Protocol

Production:

- src/信息整理/L0_公理层/信息整理契约.gd — optional owner, input binding, initial validation/fixed node key.
- src/信息整理/L1_器件层/角色经历投影器.gd — baseline fold before lived snapshots.
- src/信息整理/L2_流程层/回合信息整理流程.gd — activation/restore lane and safe latest-World commit.
- src/信息整理/L3_外交层/信息整理公开接口.gd — Persistence L3 node lookup injection.

Tests/evidence:

- tests/mw014/模型信息整理纵向测试.gd — initialize former thin baseline before lived assertions.
- tests/mw015r2/初始整理契约缺口验证.gd — updated compatibility assertions.
- tests/mw015r2/初始角色基线纵向测试.gd — persistence/lifecycle tests.
- tests/mw015r2/初始角色界面纵向测试.gd — Zhang Chen Shell/rendered layout.
- tests/mw015r2/真实Provider初始角色验证.gd — fresh/existing initial smoke.
- tests/mw015r2/运行初始角色离线验证.ps1 and 运行真实初始角色验证.ps1 — bounded launchers.
- Corresponding Godot .uid files, this report and docs/mw015/r2/evidence/*.
- Packet update arrived from main, not an implementer scope change.

Exact pushed candidate SHA and clean branch status are in the completion message, avoiding a self-referential hash. Stop at **READY FOR INDEPENDENT REVIEW**. Integration and Owner-build preparation remain separate and are not performed here.
