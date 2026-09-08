# TASK｜MW-025｜Character-guided Recommendations + Accepted-Action Character Evidence

Type: G6 Package 2 core interaction implementation  
Work Item: **MW-025**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Product Owner / UAT: **Owner — one combined Package-2 UAT after this task**  
Task Branch: `mw-025-character-guided-recommendations`  
Required Worktree: `D:/AI/Projects/.worktrees/my-world/mw-025-character-guided-recommendations`  
Formal Code Base: `ad0f3bc7fcd6edc6175121df2cf079efa1c3a493`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Product outcome

Finish Package 2's interaction feedback loop without reducing player freedom:

```text
current player-safe Character
+ recent typed accepted Conversation
+ latest final accepted role action
→ one ordinary Action Recommender call
→ five optional next-role-action inspirations that feel more relevant to who the protagonist currently is

final accepted role action
→ existing Information Curator semantic judgment
→ may update Character when the action is genuinely meaningful evidence
→ later recommendation opportunities naturally see the updated Character
```

Character is **soft tendency/context**, never a whitelist. The Player may always ignore recommendations and type any free-form action.

This task must not add a second recommendation call, a Curator→Recommender blocking barrier, personality scores, keyword classifiers or deterministic personality mutation.

## 2. Why now

MW-024 established reviewed/integrated typed accepted input modes:

- `action` = protagonist action;
- `ooc` = GM Guidance, durable in Conversation but structurally excluded from d20/World/Agency/Evolution/lived Character/Experiences/People mutation.

MW-025 is the second and final implementation work item in Package 2. After Independent Review and integration, prepare **one combined Owner Package-2 UAT** covering MW-024 + MW-025. Do not request a separate Owner test for MW-025 before integration.

## 3. Authority / Source Manifest

Refresh both mains before implementation. Authority order:

1. Owner current explicit direction: continue Package-2 correction train without intermediate UAT.
2. `Vibe-Coding/AGENTS.md` + Owner collaboration preferences.
3. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md` current.
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md@v4.4`.
5. `Vibe-Coding/my world/architecture/interaction/G6_CORE_INTERACTION_CONTROL_V1_0_DECISION.md` — **FROZEN / CURRENT**.
6. `Vibe-Coding/my world/architecture/ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`.
7. `Vibe-Coding/my world/architecture/ui/G6_FIVE_RECOMMENDED_ACTIONS_V1_0_DECISION.md` + `G6_FIVE_RECOMMENDED_ACTIONS_UAT_CORRECTION_V1_0_DECISION.md`.
8. MW-024 reviewed integration: `docs/mw024/MW-024_INDEPENDENT_REVIEW_IR1.md` + `docs/mw024/MW-024_INTEGRATION_VERIFICATION.md`.
9. current implementation/tests.
10. `Vibe-Coding/skill/gpt/agent-task-packet/SKILL.md` for execution discipline.

Historical proposal docs and old route/package numbering are not authority where superseded by the current roadmap/status/interaction decision.

STOP if a newer current governance decision materially supersedes this Package-2 contract.

## 4. Read first — bounded working set

Read initially:

1. repo `AGENTS.md`;
2. current governance status + Package-2 interaction decision;
3. `src/domain/L3_外交层/已接受输入公开契约.gd`;
4. `src/行动推荐/L0_公理层/行动推荐契约.gd`;
5. `src/行动推荐/L1_器件层/推荐材料构建器.gd`;
6. `src/行动推荐/L2_流程层/行动推荐流程.gd` + L3 public interface;
7. `src/信息整理/L3_外交层/角色经历投影公开接口.gd`;
8. `src/信息整理/L2_流程层/回合信息整理流程.gd`;
9. current MW-019/MW-024 focused tests relevant to recommendation lifecycle/currentness.

Only expand the working set when evidence is insufficient; record why.

## 5. Core invariants

### INV-25-01｜Model Freedom First

The model owns behavioral interpretation.

Program must not introduce:

- personality numbers/scores;
- keyword/regex trait detection;
- trait → allowed-action tables;
- fixed category quotas based on personality;
- semantic ranking/diversity classifiers;
- deterministic `accepted action → personality mutation` rules.

A current Character is guidance/context, not a legal-action boundary.

### INV-25-02｜Only player-safe Character enters Recommender

Recommendation input may consume the **existing player-safe Character projection** from:

`信息整理/L3_外交层/角色经历投影公开接口.gd`

Allowed Character material is the public `character` projection only.

Forbidden:

- raw `world_state`;
- raw `information_curation` records/IDs;
- NPC-private data;
- hidden Knowledge/Agency/Evolution;
- Source-current private material;
- model reasoning;
- unaccepted draft/recommendation state.

Keep cross-module dependency through the public L3 seam. Do not make Action-Recommender L1/L2 reach into another module's internal L0/L1/L2 implementation.

### INV-25-03｜One call, no Character barrier

Do **not** wait for same-turn Information Curator before generating recommendations.

At recommendation request time use:

1. current player-safe Character as it exists at that moment;
2. current bounded typed accepted Conversation;
3. latest final accepted `action` Player text as immediate behavioral evidence.

The existing one Action Recommender opportunity remains the only recommendation Provider call.

If Curator later updates Character for the same accepted action:

- do not cancel/retry/regenerate the already-current recommendation solely because Character changed;
- do not issue a second call;
- the newly durable Character influences subsequent recommendation opportunities/reopen requests naturally.

Accepted Conversation currentness remains the request/stale authority. Do not add Character hash as a second currentness owner.

### INV-25-04｜Accepted role action is evidence, not mutation

The existing lived Information Curator already receives `accepted_player` for final accepted `action` turns and MW-024 structurally skips `ooc` turns.

Strengthen the Curator semantic contract so it explicitly understands:

- `accepted_player` is the Player's **final accepted protagonist action** and is legitimate behavioral evidence;
- one unusual/contextual act does not mechanically overwrite established Character;
- ordinary actions may produce `character=null`;
- repeated, meaningful or identity-relevant accepted choices may legitimately shift personality/values/principles/long-term direction;
- current Character and accepted Narrative context must be considered together;
- the model decides whether any update is warranted.

Never treat these as Character evidence merely because they exist:

- recommendation items shown;
- recommendation draft clicked but not accepted;
- OOC guidance;
- cancelled/failed/unaccepted attempts;
- Program heuristic labels.

No new Curator call, table, schema or mutation lane.

### INV-25-05｜OOC semantics remain protected

MW-024 stays intact:

- OOC may affect what next role-action recommendations are useful;
- OOC itself is not protagonist behavioral evidence;
- OOC does not trigger lived Curator;
- typed conversation material tells the Recommender `action` vs `ooc` structurally;
- recommendation click returns composer to `角色行动`, exact draft, never auto-send.

Do not weaken OOC isolation to implement Character feedback.

### INV-25-06｜Strict MW-019 recommendation contract remains intact

Still exactly one valid response:

`{"actions":[{"label":"...","draft":"..."} × 5]}`

Preserve all current bounds, parser strictness, no fence stripping, no semantic repair, no hidden retry/fallback, no click-time call.

The five items remain five independent alternative next steps, not one plan split into steps.

### INV-25-07｜Character fit must not become self-locking

Prompt semantics must explicitly allow:

- actions consistent with established tendencies;
- plausible deviations/experiments;
- growth/change where the scene supports it;
- choices that challenge prior tendencies.

Do not instruct the model to make every recommendation maximally personality-consistent.

The goal is: **“what this protagonist might genuinely consider”**, not **“what this personality is allowed to do.”**

## 6. Recommender input contract

### AC-REC-01｜Combined player-safe payload

Refactor the existing recommendation input builder minimally so the single request can contain a bounded object equivalent to:

```json
{
  "current_character": <player-safe Character object or null>,
  "latest_accepted_role_action": <latest accepted input_mode=action Player text or null>,
  "conversation": [
    {"player":"...", "gm":"...", "input_mode":"action|ooc"}
  ]
}
```

Exact internal field names may differ only if the same semantics and tests remain obvious.

`latest_accepted_role_action` is taken from accepted typed Conversation, never from the current composer or recommendation draft.

### AC-REC-02｜Bounded input without semantic heuristics

Preserve a hard bounded request input.

Preferred deterministic policy:

1. use the complete current player-safe Character object;
2. use the complete latest accepted role-action text if one exists;
3. add recent typed accepted Conversation entries newest→older while the existing input-byte bound permits;
4. preserve each included accepted entry whole; do not truncate Player/GM prose;
5. if the fixed safe material + latest required conversation entry cannot fit, fail-soft with no Provider call rather than inventing semantic truncation/summary.

Dropping older Conversation entries due the existing byte bound is allowed; semantic ranking, keyword selection and model-generated compression are not.

Do not silently increase input capacity unless current tests prove the existing bound cannot carry a normal current Character + one normal latest entry. If a bounded capacity adjustment is truly necessary, keep it minimal, document exact rationale, and preserve fail-soft tests.

### AC-REC-03｜Prompt semantics

The Action Recommender system instruction must state clearly:

- `current_character` is the protagonist's current player-safe self-description;
- it is a soft tendency/context, not an action whitelist;
- `latest_accepted_role_action` is immediate behavioral evidence, not a deterministic personality update;
- `input_mode=ooc` is Player→GM guidance and is not protagonist action/world fact;
- recommendations may include consistent choices, meaningful deviations and growth;
- do not infer hidden traits/world facts;
- output still exactly five independent label/draft pairs.

No personality score or Program-side semantic enforcement.

### AC-REC-04｜Safe composition seam

Prefer composition through the current Action Recommender L3/public boundary so lower Action-Recommender layers receive an already player-safe Character value/reader without importing Information-Curation internals.

A small injected safe-reader seam is allowed. Do not build a generic dependency/service framework.

## 7. Curator accepted-action evidence

Update only the lived Curator semantic instruction needed for INV-25-04.

Do not change:

- Character schema;
- Important Experiences sparse milestone semantics;
- People contract/identity evidence;
- initial Character lane;
- currentness/persistence behavior;
- model-driven ownership.

The accepted Player action remains one piece of evidence among current Character + accepted Narrative/history, not a Program-enforced mutation trigger.

## 8. Timing / lifecycle acceptance

Deterministically prove:

1. after an accepted `action`, Recommender can start before lived Curator completes;
2. the request contains the Character snapshot current **at request start** plus the just-accepted role action;
3. later same-turn Curator Character commit does **not** cause a second recommendation call and does not stale an otherwise-current request;
4. the next accepted opportunity reads the newly current Character;
5. Restore/replacement still invalidates stale recommendation callbacks via accepted-version currentness;
6. OOC opportunity can still generate one next-role-action recommendation using current Character + latest prior accepted role action, while OOC itself is not behavioral evidence;
7. reopen may issue the existing one fresh current-prefix recommendation request and sees the then-current Character;
8. click/pre-fill/free-form Send behavior is unchanged.

## 9. Behavioral evidence acceptance

Use controlled Curator adapters/request capture to prove structurally:

- a final accepted `action` reaches the lived Curator as `accepted_player`;
- the Curator instruction explicitly frames it as non-deterministic behavioral evidence;
- accepted OOC creates no lived Curator request;
- clicked-but-unaccepted recommendation creates no Curator request;
- cancelled/failed Player attempt creates no lived accepted evidence;
- ordinary accepted action may legally return `character=null`;
- existing Character/Experiences/People parser/storage/currentness remains unchanged.

Do **not** build a test that asserts a hard-coded personality outcome from a sentence. Semantic Product quality remains model/Owner territory.

## 10. Player-safe / privacy acceptance

Inject canaries into raw/hidden sources and prove Recommendation request does **not** contain:

- raw world_state;
- hidden World/Agency/Evolution text;
- NPC-private profile/Knowledge;
- Information-Curation IDs/prefix/hash/storage metadata;
- credentials/API keys;
- unaccepted composer/recommendation draft text unless it has actually become accepted `action` history.

Current Character text is expected because it is already player-visible.

## 11. Debug compatibility

MW-022 remains read-only and bounded.

No new Debug taxonomy is required. Existing Recommendations and Curator terminal rows continue to work.

Do not add personality explanations, model reasoning or Character diff internals to Debug.

## 12. Direct regression protection

At minimum protect:

- MW-024 OOC typed mode + legacy compatibility + Save/Restore/currentness;
- MW-019 strict recommendation pairs/lifecycle/Send+d20;
- MW-014/MW-015/MW-018 curation and People behavior;
- MW-015 R1 sparse Important Experiences;
- MW-022 Debug;
- MW-023 typography/readability;
- G2 Narrative/Conversation;
- G3 Save/Restore/reopen;
- Public d20;
- G5 World/identity/Agency/Evolution.

Known G3 Context baseline assertions may remain if reproduced on the exact Formal Base. Do not silently fix or suppress them in MW-025.

## 13. Bounded real Provider validation

After deterministic gates pass, real Provider validation is recommended but must remain bounded and non-authoritative.

Useful maximum: **up to 3 background calls total**.

Suggested evidence:

1. Recommender with a clear but non-extreme current Character + recent scene/action — manually inspect that recommendations plausibly reflect the Character while retaining multiple independent/deviating options;
2. optional controlled comparison using the same scene with a materially different player-safe Character to demonstrate the model actually consumes Character input;
3. optional Curator example where a meaningful accepted action is considered against an existing Character, confirming the model may update or may deliberately keep `character=null` based on context.

Do not turn these into Program-side personality scoring. Record outputs for human review only.

If real Provider is unavailable, report retained Package-2 Owner-UAT risk rather than adding fallback logic.

## 14. Product Value Acceptance

Engineering acceptance is not Product PASS.

After MW-025 review/integration, Owner gets one Package-2 build and judges:

- OOC works as a real GM Guidance channel;
- subsequent normal play respects recent guidance naturally;
- recommendations feel more like things the current protagonist might consider;
- recommendations still offer meaningful deviation/growth rather than self-locking;
- accepted role choices can gradually influence Character when meaningful;
- one-off/unaccepted/OOC text does not mechanically rewrite personality;
- free-form role action remains fully available.

Only explicit Owner verdict closes Package 2.

## 15. Explicit non-scope

Do not implement:

- personality score/trait numbers;
- keyword/regex personality classifier;
- recommendation semantic ranking/category engine;
- Curator→Recommender same-turn barrier;
- second recommendation call after Character changes;
- Narrative Preference;
- Reality Correction;
- generic Action Intent;
- Open Threads;
- System/Inventory;
- Dynamic UI;
- Context Orchestrator;
- Structured Output platform/framework;
- Application Shell general refactor;
- new SQLite schema/table;
- Debug personality reasoning.

## 16. Validation order

Run in order:

1. focused deterministic Recommender input/timing/privacy tests;
2. focused Curator accepted-action evidence tests;
3. real-window regression for recommendation click/free-form/OOC interaction where needed;
4. directly affected regressions;
5. bounded real Provider validation only after deterministic gates;
6. final Godot import;
7. fresh Windows export validation.

## 17. Git / return protocol

- Work only in required task branch/worktree.
- Record exact starting HEAD/status/worktrees.
- Preserve unknown Owner/local files; no reset/clean/force.
- Do not modify `main` directly.
- Commit + push implementation/evidence to `mw-025-character-guided-recommendations`.
- Refresh both mains before final push for decision propagation.
- Write `docs/mw025/MW-025_IMPLEMENTATION_RETURN.md`.
- Return exact Starting HEAD, Implementation HEAD, Final candidate HEAD, validation results and residual risks.
- Do not install Owner build.
- Do not declare Engineering PASS or Product PASS.

Highest implementer state: **READY FOR INDEPENDENT REVIEW**.

## 18. Stop conditions

STOP and report rather than broaden scope if:

- governance supersedes the frozen Package-2 architecture;
- player-safe Character can only be supplied by exposing raw hidden state;
- implementing the loop requires a second recommendation call or blocking Curator barrier contrary to frozen architecture;
- existing input-budget constraints make normal Character+latest-action requests impossible without a materially broader context redesign;
- a persistence/schema change appears necessary;
- a true blocker requires semantic rules/classifiers rather than model-owned interpretation.
