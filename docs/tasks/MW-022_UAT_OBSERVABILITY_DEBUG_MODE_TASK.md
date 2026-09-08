# TASK｜MW-022｜UAT Observability / Debug Mode v0.1

Type: core UAT leverage implementation  
Work Item: **MW-022**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Product Owner / UAT: **Owner**  
Task Branch: `mw-022-uat-observability-debug-mode`  
Required Worktree: `D:/AI/Projects/.worktrees/my-world/mw-022-uat-observability-debug-mode`  
Formal Code Base: `d81f5f215360780cc50038ccd3bce7cb4163b866`  
Governance Base at shaping: `ef0793449657e50701e155433cb78b851eb714c2`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Product outcome

Implement the first core UAT observability slice so Owner can answer, after a real accepted Turn:

> **后台哪些域真的变了、哪些没变、哪里失败/过期/取消了？**

Debug Mode must make later Core-package UAT cheaper without changing normal gameplay.

Expected first-party experience:

```text
TopBar [调试]  -- OFF by default

OFF
→ normal Game surface unchanged

ON
→ bounded read-only Debug panel
→ recent current-session traces
→ Turn-level rows update as background lanes finish
```

Example direction only:

```text
Turn 12
Narrative        accepted
World            changed · 2
Identity         no-change
Character        changed
Experiences      no-change
People           changed · 1
Recommendations  ready · 5 · 12.4s
```

## 2. Authority / source manifest

Refresh both mains before implementation. If any newer current source supersedes this packet, STOP and report.

Read in order:

1. Owner current explicit instruction (`PASS，继续` closes Package 0 and authorizes Package 1).
2. `Vibe-Coding/AGENTS.md` + Owner collaboration preferences.
3. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md` current.
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` current.
5. `Vibe-Coding/my world/architecture/observability/G6_UAT_OBSERVABILITY_DEBUG_MODE_V0_1_DECISION.md` — **FROZEN / CURRENT**.
6. `Vibe-Coding/my world/docs/uat/G6_PACKAGE0_OWNER_REUAT_U2.md` v1.2 — Package 0 closure evidence.
7. repository `AGENTS.md` stable rules; duplicated stage tables may lag current governance.
8. current implementation/tests.

## 3. Primary purpose / core invariant

Current core value remains:

> **长期持续 AI 世界 + 优秀自由 AI GM + 原生 RPG 游戏体验。**

INV-OBS-01:

> Debug Mode observes Program-known terminal/currentness evidence. It never becomes gameplay truth, never changes model input, and never changes game behavior.

## 4. Current source evidence already established

Task shaping inspected current production seams and found real reusable evidence:

- `Conversation` / Narrative already publishes accepted / failed / cancelled lifecycle signals;
- `WorldTurn` exposes `finished` and current `opportunity_terminal`, with bounded terminal fields including turn index, `change_count`, `knowledge_count`, `actor_count`, receipt/outcome and failure/stale/cancelled states;
- `InformationCurator` exposes `finished(result)` and `status_snapshot()`, while player-safe Character/Experiences/People projections already exist;
- `ActionRecommender` exposes `changed + snapshot()`, but currently collapses materially different failures into generic `unavailable`; this is an explicit Package-1 seam to improve with bounded diagnostics only;
- current Runtime exposes `restore_completed`, Save APIs and stable current Conversation/World/Timeline owners;
- Application Shell already owns composition of WorldTurn, Curator, Recommendations and Save/Restore UI, so it is the correct composition point for one bounded observability owner.

Do not replace these seams with a universal event bus.

## 5. Required architecture

### AC-ARCH-01｜One bounded in-memory diagnostic owner

Add one focused UAT observability owner/module, composed by the Application Shell for an active Game.

It may keep the latest **64 diagnostic entries** in memory.

This number is only a storage bound; it must not affect gameplay semantics.

No new:

- SQLite table;
- World field;
- Save payload;
- Conversation field;
- log database;
- remote telemetry.

The owner may collect while the panel is hidden so enabling Debug shows recent current-session results. Collection must be read-only and bounded.

### AC-ARCH-02｜No giant EventBus

Prefer direct subscriptions/adapters to current public seams.

A small diagnostic normalization contract/projector is allowed. Do not create a speculative cross-project telemetry framework, service locator, generic message broker or arbitrary event schema.

### AC-ARCH-03｜Currentness

Turn-scoped diagnostics bind internally to current accepted version/trace epoch.

At minimum:

- Restore starts a new diagnostic epoch and invalidates/clears pre-Restore current-session turn traces;
- stale callbacks cannot publish as current after Restore or accepted replacement;
- where an existing lane emits `stale`, preserve that result;
- no diagnostic key is persisted into authoritative Game truth.

## 6. UI contract

### AC-UI-01｜Debug toggle

Add a Game TopBar toggle/control labeled `调试` (or equivalently clear Chinese UAT wording).

- OFF by default each Game activation;
- no persistent preference required;
- toggle itself makes zero Provider calls and zero durable mutations.

### AC-UI-02｜Debug panel

When ON, show a compact bounded read-only panel outside the World Information taxonomy.

Recommended implementation direction:

- below TopBar / above main Host layout or another shell-owned local drawer;
- bounded height with its own scroll region;
- recent Turn group(s), newest useful evidence easy to see;
- panel hidden entirely when OFF.

Do not add `调试` to `概览/角色/重要经历/人物/...` mother taxonomy.

### AC-UI-03｜Asynchronous completion

Rows may appear/update independently as background lanes finish. Debug must not delay Narrative or Player input waiting for all rows.

## 7. Diagnostic record vocabulary

Do not invent one fake terminal machine for every domain. Normalize only common UAT dimensions:

```text
terminal:
accepted | committed | ready | unavailable | failed | stale | cancelled | restored | saved

change:
changed | no-change | unknown
```

Each record may additionally contain bounded safe fields:

- source Turn index;
- lane name;
- sanitized status/reason code;
- short human-readable reason;
- elapsed_ms when safely measurable;
- provider/profile/model identifiers from existing validated public seams;
- small player-safe counts.

No raw request/response or reasoning.

## 8. Initial consumers

### AC-NARRATIVE｜Narrative

Use existing Conversation/Narrative lifecycle.

At minimum display:

- accepted;
- failed + safe reason;
- cancelled.

Do not duplicate full Narrative text into diagnostics.

### AC-WORLD｜World semantic

Consume the current WorldTurn terminal seam.

On successful current terminal:

- `change_count > 0` → World `changed`;
- `change_count == 0` → World `no-change`;
- preserve failure/stale/cancelled terminal states.

Allowed supporting counts: durable changes / knowledge events / newly materialized actors.

Do not render hidden world-change prose or Knowledge text.

### AC-IDENTITY｜Actor materialization / identity

Show a distinct structural row derived from the same semantic transaction.

Allowed evidence:

- new stable actor count;
- identity receipt/binding count or equivalent structural terminal;
- changed/no-change/failure/stale.

If current World terminal lacks exactly one small count required to distinguish existing-person binding/no-binding, extend that terminal with a bounded count. Do not expose actor IDs/refs/names/private profiles and do not add another identity/model call.

### AC-CURATION｜Character / Experiences / People

Present three distinct rows, even though one Information Curator call owns them.

Determine legitimate `changed / no-change` from current **player-safe projections** around the curation terminal, not raw curation storage and not model-output parsing in the UI.

At minimum support:

- Character changed/no-change;
- Experiences changed/no-change + bounded added count;
- People changed/no-change + bounded card add/update/remove count where straightforward.

If shared Curator terminal fails/stales/cancels, do not invent separate domain successes; show the shared abnormal terminal for the affected rows.

Counts are sufficient. No rich diff UI required.

### AC-RECOMMENDATIONS｜Recommendations diagnostic seam

This is an explicit production correction within MW-022.

Current `ActionRecommender` must expose a bounded **diagnostic-only terminal** without changing its strict visible recommendation behavior.

Distinguish where applicable:

- ready;
- input/opportunity unavailable;
- malformed/invalid structured response;
- response oversized;
- provider/start failure;
- timeout;
- cancelled;
- stale/currentness discard.

The normal recommendation `snapshot()` remains player-facing and must not leak engineering data.

Allowed pattern: add a diagnostic signal/snapshot/public seam that carries only safe status metadata.

Forbidden:

- fence stripping;
- semantic repair;
- hidden retry;
- Provider fallback;
- relaxing exact 5×`{label,draft}` validation;
- click-time calls.

### AC-SAVE-RESTORE｜Save / Restore

Record bounded Save/Restore results when operations occur.

Restore must:

- invalidate/clear old current-session per-turn diagnostic trace;
- append a Restore terminal result for the new epoch;
- never display displaced-future traces as current.

No database path/raw backup detail in normal Debug UI.

## 9. Safe failure reasons

Provide a bounded mapping from known status codes to Owner-readable reasons, e.g.:

- 模型服务调用失败；
- 模型响应结构无效；
- 请求超时；
- 当前回合已被替换，旧结果已丢弃；
- 持久化失败；
- 当前没有合法推荐机会。

A concise code may accompany the reason.

Never display:

- API keys / Authorization;
- raw Provider payload/request bodies;
- hidden GM/world/NPC semantic values;
- private Source-current material;
- model chain-of-thought;
- unrelated local paths/privacy.

## 10. Provider / Model metadata

Where relevant, diagnostics may show current configured Provider/Profile/Model identifiers using the existing validated runtime settings/provider public seam.

Do not read or display credentials.

No token/cost dashboard in MW-022.

## 11. Engineering acceptance

At minimum independently prove:

1. **Debug OFF:** panel absent/hidden; zero extra Provider calls; zero durable mutation; standard Game path unchanged.
2. **Toggle:** ON/OFF makes zero Provider calls and zero durable mutation.
3. **One real accepted Turn:** trace accumulates Narrative + World + Identity + Character + Experiences + People + Recommendations as existing async lanes finish.
4. **No-change:** a legitimate ordinary turn visibly distinguishes at least World/Character/Experiences/People no-change from failure.
5. **Positive change:** controlled fixtures prove changed rows for World and each player-safe curation domain without hidden-value leakage.
6. **Failure reason:** at least one controlled Provider/structured-response failure shows a concise safe reason, not only generic unavailable.
7. **Recommendation diagnostics:** malformed, timeout/provider failure or equivalent distinct terminal cases remain structurally distinguishable while normal recommendation fallback remains fail-soft.
8. **Currentness:** Restore clears/invalidates pre-Restore traces; stale callback cannot publish as current afterwards.
9. **Replacement:** Regenerate/correction/current accepted replacement cannot leave old-version diagnostics presented as current.
10. **Privacy:** hidden world/NPC/Source/credential canaries do not appear in diagnostic projection/UI.
11. **Save/Restore:** result recorded without changing existing Save/Restore semantics.
12. **Bound:** trace owner never exceeds configured bounded capacity.
13. **No schema/platform creep:** no SQLite migration, generic EventBus, full Consequence Diff, token dashboard or unrelated Package work.

## 12. Real Provider validation

Use real configured Provider only after deterministic gates pass and only if needed to prove one realistic trace with existing actual asynchronous lanes.

Recommended bounded real check:

- one ordinary accepted Player turn in isolated task-owned Game;
- capture Debug trace until the current World/Curator/Recommendations terminals finish or bounded timeout;
- verify no hidden canaries and record actual Provider/model identifiers + elapsed timing;
- do not manipulate prompts/results merely to manufacture an ideal mix of changed/no-change.

One real run is sufficient if deterministic tests already prove all error/currentness cases.

## 13. Direct regressions

At minimum protect:

- G2 Narrative/Conversation Send/retry/cancel;
- current G5 World semantic/identity currentness;
- MW-014/MW-015/MW-018 information curation + safe projections;
- MW-019 recommendation lifecycle + strict pair contract;
- G3 Save/Restore/currentness;
- MW-021 Narrative scroll behavior;
- shell responsive layout / narrow window if Debug panel changes layout.

Do not silently relabel existing baseline failures as new blockers; reproduce and document exact baseline when needed.

## 14. Product Value Acceptance

Engineering/Reviewer may return **READY FOR OWNER UAT**, not Product PASS.

Owner PASS direction:

> After a normal real turn with Debug ON, I can quickly see which key backend domains changed, did nothing, or failed, and the reason for failure is understandable. Turning Debug OFF restores the normal game without affecting gameplay.

## 15. Explicit non-scope

Do not implement in MW-022:

- Open Threads;
- OOC / Character-guided recommendations;
- System/Inventory consumers that do not exist yet;
- full player-facing Consequence Diff;
- raw hidden-world inspector;
- SQL/log/request viewer;
- remote telemetry;
- token/cost/usage dashboard;
- persisted Debug history/preferences;
- giant EventBus / universal observability platform;
- Dynamic UI Host;
- Application Shell general refactor;
- layer-debt cleanup except a truly unavoidable narrow seam directly touched by this task.

## 16. Validation order

Run:

1. focused deterministic observability contract/currentness/privacy tests;
2. focused real UI/window Debug panel tests;
3. directly affected regression suites;
4. optional bounded real Provider trace after deterministic gates;
5. final Godot import;
6. fresh Windows export validation because production runtime/UI scripts change.

## 17. Git / integration

- Work only in required task branch/worktree.
- Record exact starting HEAD/status/worktrees.
- Preserve all unknown Owner/local work; no reset/clean/force.
- Do not modify `main` directly.
- Commit + push implementation/evidence to `mw-022-uat-observability-debug-mode`.
- Refresh both mains before final push for decision propagation.
- Write `docs/mw022/MW-022_IMPLEMENTATION_RETURN.md`.
- Return exact Starting HEAD, Implementation HEAD, Final candidate HEAD, validation results and residual risks.
- Keep worktree through GPT Independent Review + integration.

Highest implementer state: **READY FOR INDEPENDENT REVIEW**.

## 18. Stop conditions

STOP and report rather than broaden scope if:

- current governance supersedes this architecture;
- required diagnostics can only be achieved by exposing private semantic payloads;
- the implementation would require a new persistence schema or giant cross-module event platform;
- an existing terminal seam materially lacks correctness/currentness evidence and fixing it would change gameplay semantics rather than only observability metadata.
