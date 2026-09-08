# MW-025｜Independent Review IR1

Status: **ENGINEERING PASS_WITH_NOTES**  
Reviewer: GPT  
Date: 2026-09-08

## Reviewed identity

- Formal Code Base: `ad0f3bc7fcd6edc6175121df2cf079efa1c3a493`
- Task Starting HEAD: `4d2a5042bb0234fa093e0d33f88ba6797b0fc12e`
- Implementation HEAD: `0be20d7e39f061a390fb56598a61990d1495a353`
- Submitted Final Candidate: `adb8bccab3709357ce1de69edb7af3bd345d9f1c`
- Frozen authority: `G6_CORE_INTERACTION_CONTROL_V1_0_DECISION.md`
- Task Packet: `docs/tasks/MW-025_CHARACTER_GUIDED_RECOMMENDATIONS_TASK.md`

Implementation `main` was refreshed before review and remained exactly the Formal Code Base. Governance `main` remained current at status v17.17 with no superseding Package-2 decision.

Builder completion claims were not treated as completion evidence; review inspected Base → Implementation → Candidate diff, production seams, task acceptance, deterministic evidence, regression evidence and bounded real-provider outputs.

## Verdict

**ENGINEERING PASS_WITH_NOTES**.

No blocker was found against MW-025 scope or frozen Package-2 architecture.

Engineering PASS does not grant Product PASS. MW-024 + MW-025 still require the single combined Owner Package-2 UAT.

## Independent findings

### 1. Production scope is bounded

Base → Implementation production changes are limited to:

- `src/行动推荐/L1_器件层/推荐材料构建器.gd`
- `src/行动推荐/L2_流程层/行动推荐流程.gd`
- `src/行动推荐/L3_外交层/行动推荐公开接口.gd`
- `src/信息整理/L2_流程层/回合信息整理流程.gd`

No production UI, Conversation persistence/currentness owner, SQLite/schema, People/Experiences contract, Debug architecture, World/Identity/Agency/Evolution owner, or MW-024 input-mode contract was changed.

### 2. Character input is player-safe and model-owned

The Recommender L3 composes Character only through the existing public player-safe `角色经历投影公开接口.gd`, then injects the resulting `.character` into the lower Recommender layer.

The L1 request payload contains:

- `current_character`
- `latest_accepted_role_action`
- bounded typed accepted `conversation`

It does not receive raw `world_state`, Information-Curation IDs/hashes, NPC-private state, hidden Knowledge/Agency/Evolution, credentials, or unaccepted composer/recommendation drafts.

No Program personality score, keyword/regex classifier, trait weighting, allowed-action table, semantic ranking engine or category quota was added.

### 3. Character is a soft tendency, not a whitelist

The production Recommender instruction explicitly states that Character is a soft tendency/context and permits:

- behavior consistent with established tendencies;
- reasonable deviation;
- experiment;
- challenge to prior tendencies;
- growth/change.

This preserves Model Freedom First and avoids a self-locking protagonist policy.

### 4. One-call timing remains intact

The existing Recommender opportunity remains one Provider request.

At request preparation it reads the Character snapshot that is current at that moment. It does not subscribe to Character changes and does not wait for same-turn Curator completion.

Accepted Conversation prefix/serial/Restore remain the only stale/currentness authority. Character does not become a second currentness key.

Focused evidence covers:

- recommendation starts while same-turn Curator is still unfinished;
- request contains request-time Character + just-accepted role action;
- later same-turn Character commit produces no second recommendation call;
- that commit does not stale the already-current recommendation;
- the next accepted opportunity consumes the newly current Character;
- reopen uses the then-current Character in the existing one fresh current-prefix request.

### 5. Accepted action is evidence, not deterministic mutation

The lived Curator production instruction now explicitly frames `accepted_player` as final accepted protagonist behavioral evidence rather than a Character mutation command.

It explicitly allows:

- ordinary accepted actions to keep `character=null`;
- one unusual/contextual action not to overwrite established personality;
- repeated/meaningful/identity-relevant accepted choices to influence Character when the model judges that warranted.

No new Curator call, schema, parser, storage or mutation lane was added.

MW-024 structural gating remains: accepted OOC does not create a lived Curator opportunity. Controlled evidence also confirms clicked-but-unsent recommendations and cancelled/failed attempts do not become accepted Character evidence.

### 6. Bounds and strict recommendation contract remain intact

The existing 24 KiB input bound and four-entry recent Conversation bound remain.

Complete safe Character and latest accepted role action are fixed material; recent accepted entries are added whole. If fixed material plus the latest required Conversation entry does not fit, the opportunity fails soft with zero Provider call. No semantic truncation, summary, capacity inflation, repair, hidden retry or fallback was introduced.

The existing exact five `{label,draft}` output contract/parser remains unchanged.

### 7. Real-provider evidence is supportive, not Product PASS

Two bounded Kimi K3 Recommender requests were run for the same scene/action with two materially different player-safe Character snapshots.

Both returned valid five-pair outputs with one network attempt each and no retry/fallback. The outputs visibly differed in direction in ways consistent with the supplied Character snapshots, which supports that the model consumes Character input.

This does not prove long-session Product quality or optimal deviation/growth behavior.

## Validation assessment

Reviewed evidence reports:

- focused deterministic: 54 / 54;
- real-window: three supported sizes, no failure;
- direct regressions: 37 / 39 suites pass;
- two failures are the same pre-existing G3 Context assertions reproduced from exact Formal Base;
- final Godot 4.7.2 import passes;
- fresh Windows export validation passes.

The two retained G3 failures are not suppressed or relabeled as pass.

## Notes / retained Product risks

1. **Character fit and freedom balance:** Owner must judge whether recommendations feel meaningfully informed by the protagonist without becoming repetitive or self-locking.
2. **Scene-detail extrapolation:** bounded real outputs occasionally introduced small details not explicitly established by the scene. Do not fix this by adding Program heuristics unless real UAT shows a recurring product defect.
3. **Accepted-action Character evolution:** deterministic tests prove the correct evidence seam, but a live long-session sample was not used to claim semantic Character quality.
4. Existing G3 Context baseline assertions and known teardown/resource warnings remain retained debt outside MW-025.

## Integration decision

Approved for reviewed integration by **non-force fast-forward** only if implementation `main` is still exactly `ad0f3bc7fcd6edc6175121df2cf079efa1c3a493` at integration time.

After integration: prepare one fresh Owner build for **combined Package-2 UAT**. Do not request separate MW-025 UAT and do not declare Package-2 Product PASS before explicit Owner verdict.
