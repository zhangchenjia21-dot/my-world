# TASK｜MW-032｜G6 Reality Gate U1 Correction Train

Type: G6 Package-7 bounded correction train  
Work Item: **MW-032**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Owner UAT: **DEFERRED after this correction by explicit Owner instruction; implementer must not prepare/install Owner build or claim Product PASS**  
Required branch: `mw-032-g6-reality-gate-u1-corrections`  
Required worktree: `D:/AI/Projects/.worktrees/my-world/mw-032-g6-reality-gate-u1-corrections`  
Formal Code Base: `69ac2030b90f4165deb2ecb5302e3743422af585`  
Governance Base at Task Shape: `Vibe-Coding/main@32b55c0d0d27515d07d8b7bb70f0a1301cf9a22c`  
Frozen architecture: `Vibe-Coding/my world/architecture/G6_REALITY_GATE_U1_CORRECTION_TRAIN_V1_0_DECISION.md@v1.0`  
UAT evidence: `Vibe-Coding/my world/docs/uat/G6_V0_CORE_CLOSURE_REALITY_GATE_U1.md@v1.2` + findings `@v1.1`  
Roadmap: `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md@v5.0`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Owner outcome

Owner ended Package-7 U1 and explicitly instructed:

> **“我不想继续测试了，你修吧，修完了直接继续主线等下一次测试”**

This task therefore fixes all and only the four final U1 findings in one bounded lineage:

```text
U1-F01 Opening semantic/bootstrap gap
U1-F02 People eligibility blocked by prior World actor identity
U1-F03 Recommended Actions one-shot availability failure
U1-F04 Open Threads lifecycle accumulation + no hide
```

After Engineering Review/integration there is no immediate Owner re-UAT. GPT will advance to G7 Package 8. Do not install the task build into `D:/AI/Projects/my-world`.

## 2. User-visible outcome

After MW-032:

1. an accepted GM Opening is semantically processed immediately, so opening-established factual possessions / unresolved matters / legitimate People information need not wait for an artificial first player action;
2. People can remember a concrete person the protagonist knows by reputation/history/memory even if no Character Card or verified World actor exists yet;
3. if that People referent is later proven to be an exact World actor, the same People subject can be linked without name matching or card replacement churn;
4. one transient/malformed recommendation response may recover once automatically for the same still-current turn instead of leaving recommendations missing for the whole turn;
5. every legitimate Information Curator opportunity actively rechecks which Open Threads remain unresolved, and Threads have stable identity;
6. the Player can hide/recover individual Threads without completing/deleting them or teaching the model that they are unimportant.

## 3. Authority / freshness gate

Before editing production code:

1. fetch implementation `origin/main` and governance `Vibe-Coding/main`;
2. verify implementation `main` still contains Formal Base `69ac2030...` as the exact intended correction base and no newer reviewed product implementation supersedes it;
3. read current governance Status/Roadmap/new frozen correction architecture;
4. treat Owner current explicit instruction and the new correction decision as authority over conflicting older G6 People/Threads assumptions;
5. keep all non-conflicting repository `AGENTS.md` safety/architecture rules;
6. STOP only for a real new superseding Owner/GPT decision, incompatible implementation-main advance, or unresolvable currentness/authority conflict.

Do not silently merge unrelated work into this branch.

## 4. Read first

### Governance

- `Vibe-Coding/AGENTS.md`
- `my world/MY_WORLD_CURRENT_STATUS.md`
- `my world/MY_WORLD_总体规划路线图_CURRENT.md@v5.0`
- `my world/architecture/G6_REALITY_GATE_U1_CORRECTION_TRAIN_V1_0_DECISION.md@v1.0`
- `my world/docs/uat/G6_V0_CORE_CLOSURE_REALITY_GATE_U1.md@v1.2`
- `my world/docs/uat/G6_V0_CORE_CLOSURE_REALITY_GATE_U1_FINDINGS.md@v1.1`
- `architecture/ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`
- `architecture/ui/G6_PEOPLE_SURFACE_V1_0_DECISION.md`
- `architecture/ui/G6_PEOPLE_KNOWN_PERSON_ELIGIBILITY_UAT_CORRECTION_V1_0_DECISION.md`
- `architecture/ui/G6_OPEN_THREADS_SURFACE_V1_0_DECISION.md`
- `architecture/ui/G6_MODEL_CURATED_SURFACE_VISIBILITY_PREFERENCE_DEFERRED_DECISION.md`
- `architecture/ui/G6_INTERNAL_DYNAMIC_UI_HOST_V0_1_DECISION.md`
- `architecture/ui/G6_FACTUAL_INVENTORY_VERTICAL_V1_0_DECISION.md`
- `architecture/ui/G6_FIVE_RECOMMENDED_ACTIONS_UAT_CORRECTION_V1_0_DECISION.md`

### Implementation

At minimum inspect:

- repo `AGENTS.md`;
- `src/世界回合/L2_流程层/语义物化流程.gd`;
- `src/世界回合/L1_器件层/语义变更响应解析器.gd`;
- `src/世界回合/L0_公理层/人物身份回执规则.gd`;
- `src/世界回合/L3_外交层/人物身份桥公开接口.gd`;
- `src/信息整理/L0_公理层/信息整理契约.gd`;
- `src/信息整理/L1_器件层/人物认知投影器.gd`;
- `src/信息整理/L1_器件层/事务快照投影器.gd`;
- People/Threads L3 projection interfaces;
- `src/信息整理/L2_流程层/回合信息整理流程.gd`;
- `src/行动推荐/L0_公理层/行动推荐契约.gd`;
- `src/行动推荐/L1_器件层/推荐材料构建器.gd`;
- `src/行动推荐/L2_流程层/行动推荐流程.gd`;
- `src/动态展示/L0_公理层/展示定义契约.gd`;
- `src/动态展示/L1_器件层/展示可见偏好存储.gd`;
- `src/动态展示/L3_外交层/信息表面定义公开接口.gd`;
- `src/应用壳.gd` and refresh/debug wiring only where needed;
- affected MW-018/019/024-030 and G3/G5 tests.

Expand reads only when needed by concrete evidence.

## 5. Cross-cutting invariants

### INV-01｜Model semantic authority

Model decides:

- whether a player-known person is worth a People card;
- whether a historical/reputation referent is important enough to retain;
- whether a Thread is new / still unresolved / changed / completed / stale / superseded / no longer worth attention;
- the text of People/Threads snapshots.

Program does not implement historical-name tables, keyword completion rules, importance scores, inactivity expiry, event classifiers or name dedupe.

### INV-02｜World truth remains separate

A People subject may exist because the protagonist knows/remembers/heard of a person. That does not establish a World actor.

`People subject != Stable Actor Registry record`.

Only existing World semantic actor materialization rules may create authoritative runtime actors from accepted GM/world evidence.

### INV-03｜Identity is Program-owned, refs are model-visible

No model output may mint durable People subject IDs, Thread IDs, actor IDs or presentation keys.

Use request-scoped opaque refs + Program validation/minting.

Display name/title/text equality is never authoritative identity.

### INV-04｜Timeline/currentness

All semantic People/Thread/Inventory material remains bound to current accepted history. Restore/Regenerate remove stale future semantic state.

Visibility preferences remain Game-local presentation state outside Timeline and therefore do not rewind with Restore.

### INV-05｜No Provider proliferation

Reuse existing lanes:

- World semantic lane for opening world/inventory/runtime-actor materialization;
- Information Curator for Character/Experiences/People/Threads;
- Action Recommender for recommendations.

Do not add a People Provider, Thread Provider, Opening Inventory Provider or polling worker.

## 6. F01 implementation contract — Opening semantic/bootstrap

### 6.1 World semantic lane

Current `player_text.is_empty() → opening_skipped` is the root defect. Evolve the lane so a **newly accepted GM-only Opening** with nonempty accepted GM Narrative can become a semantic opportunity.

Opening semantic request must clearly distinguish the mode and state:

- there is no Player action;
- GM Narrative is accepted/player-visible;
- extract only world consequences/runtime actors/Inventory facts that the Opening actually establishes;
- do not treat historical memory, rumors or hypothetical persons as proven World actors merely because names occur;
- no Public d20/mechanical resolution is synthesized for Opening.

Use the same parser/commit/currentness seam where practical.

### 6.2 Identity receipt / barrier

Existing receipt/currentness code currently assumes nonempty Player text. Evolve it compatibly so a valid GM-only Opening can have the bounded identity/terminal evidence needed by downstream curation.

Requirements:

- legacy receipts remain valid/readable;
- Opening binding may only use accepted GM source spans because Player text is empty;
- current Game + accepted prefix/version remains authoritative;
- empty/resolved receipt is legitimate;
- same accepted Opening reopens without repeated semantic Provider call;
- stale/Restore/Regenerate callbacks cannot publish current receipt/world/inventory material.

### 6.3 Information Curator opening opportunity

Current Curator only processes `Accepted.mode == action` lived records. Add a bounded Opening curation opportunity after the opening semantic terminal (success or safe terminal release as appropriate).

Opening curation uses:

- accepted GM Narrative;
- empty/no Player action evidence;
- current Character baseline;
- current safe People/Threads;
- exact safe identity evidence where available.

It may update/create:

- Character only when accepted Opening facts legitimately change current state, never by fabricating player choice;
- Important Experiences if Opening itself establishes a genuine lived milestone (model decides; still sparse);
- People;
- Open Threads.

It must not create Inventory itself; Inventory remains World semantic factual owner.

Opening/lived curation should retain one shared curation contract/owner, not a second curation database.

### 6.4 Opening acceptance tests

Prove at least:

- opening says protagonist is carrying a sealed letter → Inventory visible before any player-authored turn;
- opening merely shows a sword in environment → Inventory remains empty;
- opening establishes an unresolved pursuit/debt/route decision → Thread exists before first player action;
- opening has no unresolved matter → no fake Thread;
- opening mentions an unverified remembered historical person → People may remember them, but Stable Actor Registry is unchanged;
- opening establishes a genuinely present new continuing NPC → existing World actor materialization may create/bind it;
- reopen/Restore/Regenerate currentness is safe and no automatic historical backfill loop appears.

## 7. F02 implementation contract — People subject/referent identity

### 7.1 New People-domain subject identity

Evolve People curation/storage so current People subjects are not structurally synonymous with `local_character_id`.

A current People subject needs internally:

- stable Program-owned `subject_id` (exact name implementation-owned);
- player-safe snapshot (`display_name/headline/summary/relationship/details`);
- optional exact actor link when validated;
- accepted-history currentness via existing curation record chain.

Two families:

```text
actor-linked subject
referent-only subject
```

A referent-only subject is legal and remains player-information only.

### 7.2 Backward compatibility

Old People curation records keyed by `local_character_id` must remain readable.

Preferred compatibility direction:

- treat the old exact actor ID as the People-domain subject identity for that legacy actor-backed subject;
- this allows the existing actor-backed presentation key formula to remain stable and avoids invalidating existing People hide preferences;
- do not destructively migrate old Timeline records.

If a different internal representation is chosen, independently prove existing actor-backed People cards and current hidden preferences retain stable identity.

### 7.3 Model-visible current People refs

Information Curator needs enough safe current People material to avoid creating duplicates and to update/link referents without name matching.

Provide bounded current subject snapshots with request-only `person_ref` values. Do not expose raw subject IDs/actor IDs.

Do not silently select People by a semantic score. Stay under the existing total request bound; fail soft rather than invent Program importance ranking. Long-session selection belongs to G7.

### 7.4 New referent creation

Allow the model to propose a new People subject from an exact accepted Player or GM source span even without actor identity.

A new referent proposal must include:

- request-visible exact source role/span (or equivalent exact source evidence);
- People snapshot;
- optional exact actor_ref only if the current request actually has a validated actor reference.

Program validates the span against the exact accepted current text and mints deterministic/stable subject identity from Game + accepted version/evidence + bounded proposal position/material as needed. Never derive identity from display name equality.

Player statements/memory are allowed to create a **People referent** because that is player-known information, but they do not create World truth. Snapshot wording should preserve uncertainty where the accepted evidence is uncertain.

### 7.5 Existing subject update/delete/link

Model uses `person_ref` to update/delete an existing People subject.

If accepted evidence now identifies the referent with an exact actor, the model may request an exact link using both `person_ref` and `actor_ref`; Program validates both refs.

Rules:

- link does not rename/merge by display name;
- subject/presentation identity should remain stable when adding an actor link;
- if one actor would ambiguously map to multiple current subjects, fail soft rather than auto-merge;
- same-name People remain distinct;
- no raw actor material/private knowledge is injected merely for linking.

### 7.6 Model prompt direction

Explicitly tell Curator:

- People answers whom the protagonist currently knows/remembers/heard enough about to keep in mind;
- physical meeting is not required;
- pre-authored Character Card is irrelevant to card worth;
- historically/socially/politically prominent known people are usually strong persistent-memory candidates even with sparse information;
- this is a semantic tendency, not a hard category rule;
- if current-world existence/identity is unverified, say so rather than filling omniscient biography.

## 8. F03 implementation contract — recommendation bounded recovery

Preserve `ACTION_COUNT=5`, `{label,draft}`, duplicate rejection and current input/currentness semantics.

Replace one-shot `_attempted_prefix` behavior with bounded attempt tracking per current accepted prefix.

Required behavior:

```text
attempt 1
→ ready: stop
→ recoverable failure: schedule/perform one retry after rechecking currentness
→ attempt 2
→ ready or unavailable: stop
```

Maximum 2 Provider starts per unchanged prefix.

At minimum recover from:

- malformed exact-five response;
- timeout;
- transient Provider/transport failure when not known to be permanently misconfigured.

Do not auto-retry:

- stale response/currentness mismatch;
- foreground player action/d20 interruption;
- lifecycle cancellation caused by foreground invalidation;
- empty/oversized/unavailable input that repeating cannot fix;
- known missing credential/configuration if safely distinguishable.

Any retry must be cancelled/invalidated by the same foreground/currentness protections as the original request.

Diagnostics should make initial vs recovery attempt understandable without exposing Provider payload. No new user-facing retry button is required.

## 9. F04 implementation contract — stable Threads + active review + hide

### 9.1 Lived curation schema evolution

Evolve `information_curation_lived.v0.3` backward-compatibly to a new schema/version that can persist stable Thread identity.

Every new Opening/lived curation opportunity must **actively review** current Threads. Do not retain a nullable semantic shortcut that means “skip reviewing all Threads”.

Recommended model-visible full reviewed shape:

```json
"open_threads": [
  {"thread_ref":"existing-request-ref-or-null", "title":"...", "summary":"...", "details":["..."]}
]
```

Meaning:

- valid existing `thread_ref`: keep/update same stable Thread;
- current Thread omitted: model semantically removes it;
- null/new: model proposes new Thread; Program mints stable ID;
- empty list: no current unresolved matters.

Exact syntax may differ if smaller, but must make the per-opportunity lifecycle review explicit and stable-ID based.

### 9.2 Stable identity / legacy transition

Thread identity is Program-owned, not model-authored.

For existing v0.3 no-ID Threads, first transition may use deterministic bridge identity based on exact **validated source curation record ID + ordinal**, never title/text equality. Once retained into the new schema, the stable ID persists across later updates.

Do not rewrite historical v0.3 records.

Do not require legacy restored history that predates stable Thread identity to fabricate hide identity. Hide eligibility starts when a stable current Thread identity legitimately exists.

### 9.3 Active cleanup prompt

Curator must explicitly re-evaluate each current Thread every eligible opportunity and remove it when, by accepted player-visible evidence, it is:

- completed/resolved;
- invalidated;
- superseded;
- no longer pending;
- stale or no longer worth continued attention.

This list is semantic guidance to the model, not Program event categories. Program must not parse text or elapsed turns to decide completion.

### 9.4 Thread player-safe/presentation projection

Ordinary Thread DTO remains player-safe `title/summary/details`. Presentation-specific DTO may add only an opaque presentation key derived from stable Thread identity.

Raw `thread_id` must not reach leaf renderer or preference file.

### 9.5 Visibility preferences v0.2

Extend Dynamic UI Host hideable set to `threads` only after stable presentation identity is present.

Evolve existing sidecar owner backward-compatibly:

```text
ui_visibility.v0.1 people + important_experiences
→ readable by new code
→ next successful explicit preference write may publish v0.2
→ people + important_experiences + threads
```

Requirements:

- an existing valid v0.1 file loads with its exact People/Experience hides preserved;
- no write-on-read migration;
- only explicit hide/recover writes;
- corrupt/oversized file remains fail-safe visible as before;
- hidden Thread updates remain hidden;
- Restore does not rewind preference;
- recover shows current Thread content;
- hide/recover generates zero Provider calls and zero gameplay/Timeline mutation;
- Character/System/Inventory remain non-hideable.

## 10. Atomicity / currentness expectations

### World semantic opening

Opening actor receipt, World changes and Inventory events should stay in the existing single World semantic mutation candidate where valid.

### Information curation

People subject updates + Thread snapshot + Character/Experiences from one curation response remain one curation mutation/record. Partial invalid People identity should not corrupt otherwise-valid unrelated fields; use the narrow fail-soft pattern already established where compatible.

### Restore/Regenerate

Must independently prove:

- restored-away Opening semantic material disappears;
- restored-away People referents/actor links disappear;
- restored-away Thread updates/removals disappear;
- presentation hide preference bytes do not rewind;
- displaced future semantic records do not rehydrate;
- reopening current history performs zero unnecessary Provider replay when durable current records exist.

## 11. Debug / observability

Reuse existing Debug lanes. Extend only as needed so Engineering/UAT can see safe terminal evidence such as:

- opening semantic attempted/committed/no-change/failed;
- People subject/reference update counts without raw IDs;
- Thread total/change or reviewed/no-change terminal;
- recommendation attempt/recovery terminal.

No universal telemetry/event bus and no model reasoning/payload output.

## 12. Testing requirements

Create a dedicated `tests/mw032/` focused vertical (or equivalent repository-native location) using isolated task-owned roots/stub Providers.

Focused tests must cover all acceptance points from the frozen architecture, especially:

### Opening

- opening Inventory ADD before first player turn;
- no false Inventory from merely mentioned environment object;
- opening Thread creation and legitimate empty case;
- opening referent-only People subject;
- opening actual new stable NPC actor materialization where GM establishes existence;
- reopen no replay; Restore/Regenerate currentness.

### People

- no Character Card/stable actor needed for referent-only People;
- referent does not enter actor roster/Agency/Knowledge authority;
- historical/public-figure sparse snapshot can be accepted from player-visible evidence;
- same-name referents remain distinct;
- legacy actor-backed People remains readable;
- existing People hide key compatibility;
- later exact actor linking via refs preserves subject/presentation identity;
- ambiguous link rejected/fail-soft;
- no raw IDs/private actor material in model/UI definitions.

### Recommendations

- first malformed → one recovery → valid five ready;
- first Provider failure/timeout → one recovery path;
- two failures → unavailable and no third start;
- foreground starts before retry → no old retry;
- stale/Restore changes prefix → no obsolete publish;
- strict five paired contract unchanged.

### Threads

- current Thread kept with stable ID;
- summary/details update preserves ID;
- omission/removal removes semantically;
- new Thread gets stable Program identity;
- model receives refs, not IDs;
- legacy v0.3 read + first stable transition without text/title identity;
- hide/recover with current content;
- hidden update does not unhide;
- reopen preserves hide;
- Restore does not rewind preference while semantic currentness does rewind;
- old v0.1 preference file loads People/Experience hides and gains Threads only on explicit write;
- System/Inventory no hide controls.

### Cross-regression

Run directly affected suites for at least:

- MW-018 / MW-018R1 People;
- MW-019 recommendation lifecycle/pairs/routes;
- MW-024/025/026 Package2;
- MW-027 Threads;
- MW-029 Inventory;
- MW-030 Dynamic UI/preferences;
- G5 stable actors/identity/knowledge/currentness;
- G3 Save/Restore/Regenerate/currentness;
- MW-022 Debug;
- MW-023 real-window typography.

Known exact-baseline G3-03/G3-05 failures may remain only if independently reproduced on Formal Base exactly as previous tasks did. Do not suppress them.

## 13. Real-window / build validation

After focused tests:

- run 960×540, 1280×720, 1920×1080 real-window validation for changed info surfaces and recommendation area;
- ordinary visible text >=20px;
- Thread hide drawer/recovery reachable;
- Narrative/composer remain usable;
- no new horizontal overflow from Thread controls;
- final Godot 4.7.2 import;
- fresh Windows export in task worktree;
- `run-game.ps1 -ValidateExportOnly`;
- record EXE/PCK/SQLite DLL sizes/hash/freshness.

Do **not** install/copy this build into Owner canonical checkout.

## 14. Explicit non-scope

Do not implement or clean up:

- G7 Context Orchestrator;
- generalized structured-output repair/fallback platform;
- retry frameworks for every Provider lane;
- G3 Context debt;
- Quest engine/status/progress/reward/priority/deadline;
- Player manual Thread completion/delete/edit;
- universal entity graph/resolver;
- People Shared History;
- Organization/Faction/World Chronicle;
- Inventory/System hide;
- external UI/Source/Creator protocol;
- Visual Runtime/Map;
- generic Action Intent;
- Shell-wide refactor/layer-debt cleanup.

A no-change outcome for unrelated code is desirable.

## 15. Completion report / return

Write:

`docs/mw032/MW-032_IMPLEMENTATION_RETURN.md`

Include:

- refreshed implementation/governance refs;
- exact Starting HEAD / production Implementation HEAD / Final candidate HEAD;
- changed-file summary by F01-F04;
- precise schema/backward-compatibility choices;
- People subject identity/link behavior;
- Thread identity/migration/hide behavior;
- recommendation retry state-machine behavior and maximum attempts;
- focused/real-window/regression counts and exact-baseline debt evidence;
- import/export/ValidateExportOnly evidence + PCK hash;
- Provider calls used by automated tests (must use stubs; no real production Provider call required);
- residual risks / Product evidence deferred;
- confirmation no main merge / no Owner build install / no Owner real Game/Source/settings/preference mutation.

Commit + push the candidate branch and return only up to:

**READY FOR INDEPENDENT REVIEW**

Do not merge `main`. Do not update Owner checkout. Do not claim G6 Product PASS or G6 closure.