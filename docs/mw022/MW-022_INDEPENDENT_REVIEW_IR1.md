# MW-022｜Independent Review IR1

Status: **ENGINEERING PASS_WITH_NOTES**
Date: 2026-09-08
Reviewer: GPT
Work Item: MW-022 UAT Observability / Debug Mode v0.1

## 1. Reviewed identities

- Formal Code Base: `d81f5f215360780cc50038ccd3bce7cb4163b866`
- Task/Starting HEAD: `8986861c95c31eef5af23ac4d15e5bfe3c0abdfd`
- Implementation HEAD: `7eae9d5ef39d19a917bc28463799807d76d6d92a`
- Submitted Final Candidate: `d3c519a26372bd42cc091d82c00e8f4aeba520ae`
- Governance current at review: `MY_WORLD_CURRENT_STATUS.md@v17.13`, Roadmap `v4.4`

Both implementation and governance mains were refreshed before review. Implementation `main` remained exactly the Formal Code Base. Governance still dispatches MW-022 under the frozen Debug Mode v0.1 architecture; no superseding product/architecture decision was found.

## 2. Review method

Builder completion claims were not treated as completion evidence. Review independently inspected:

- Formal Base → Implementation → Final Candidate compare;
- production diff and new module boundaries;
- frozen observability decision and executable Task Packet;
- bounded recorder / display contract / L3 observer;
- World/identity diagnostic seam changes;
- Information Curator diagnostic lifecycle;
- Action Recommender diagnostic-only changes;
- Shell composition / Save-Restore wiring / Debug panel;
- focused currentness/privacy evidence;
- real-window evidence;
- direct regression inventory and exact baseline failure reproduction;
- final candidate identity showing evidence-only changes after Implementation HEAD.

## 3. Scope / architecture finding

**PASS.**

The implementation remains a bounded UAT observability slice rather than a new gameplay system or telemetry platform.

Production additions are limited to:

- `src/调试观测/L0_公理层/诊断展示契约.gd`
- `src/调试观测/L1_器件层/会话诊断记录器.gd`
- `src/调试观测/L3_外交层/会话调试观测公开接口.gd`
- `src/ui/会话调试面板.gd`
- narrow terminal/diagnostic seams in existing World / Curator / Recommendations flows;
- Shell composition and Save/Restore result wiring.

No SQLite table, World field, Save field, Conversation field, persistent Debug preference/history, remote telemetry, generic EventBus, SQL/log browser, raw-world inspector, full Consequence Diff, token dashboard, Dynamic UI or unrelated Package capability was introduced.

The new observability module consumes existing public/business seams rather than replacing gameplay owners. Shell remains composition owner; the leaf Debug UI consumes only normalized safe rows.

## 4. Debug OFF / side-effect boundary

**PASS.**

Debug collection is in-memory/read-only and may remain active while the panel is hidden, as frozen. Toggle controls presentation only.

The review found no new Provider/model trigger in the observer, recorder or panel. The observer only subscribes to existing terminal/lifecycle signals and reads safe projections. Toggle and render paths do not mutate Runtime, World, Conversation, Timeline or Save.

Focused/window evidence explicitly compares Provider request counts and durable projections across toggle/resize and verifies no change. Normal recommendation click/send paths remain functional with Debug ON.

## 5. Diagnostic data safety

**PASS.**

The closed display contract accepts only:

- known lane;
- known terminal;
- known change state;
- bounded structural counts;
- bounded elapsed time;
- bounded mapped reason codes.

Unknown raw status/message text is converted to a closed safe reason. Snapshot rows do not contain internal currentness token fields.

The L3 owner keeps `epoch/index/prefix` only internally and returns normalized rows. Leaf UI has no Runtime, world state, actor identity/ref or Provider payload reference.

Focused/window privacy evidence covers hidden World/NPC/Source/credential/path canaries. No private canary appears in projection/UI.

## 6. Narrative

**PASS.**

Narrative diagnostics come directly from Conversation lifecycle signals:

- accepted;
- failed;
- cancelled.

No Narrative text is duplicated into Debug records. Non-accepted failure/cancel evidence is session-scoped rather than falsely bound to an accepted version.

## 7. World semantic + identity

**PASS.**

World/Identity consume the existing current `WorldTurn.opportunity_terminal` seam.

World:

- current successful terminal with `change_count > 0` → changed;
- `change_count == 0` → no-change;
- failed/stale/cancelled remain abnormal/unknown;
- safe counts may include durable change / knowledge count.

Identity:

- same semantic transaction is represented as a separate row;
- only actor/binding structural counts are exposed;
- `binding_count` is the only added World terminal metadata and is derived from already-resolved bindings;
- no second identity resolver/model call or actor ID/ref/private profile is exposed.

Historical reuse/skipped results without transaction counts are left `unknown`; implementation does not invent no-change from missing evidence.

## 8. Character / Important Experiences / People

**PASS.**

These remain three distinct diagnostic rows while retaining the real shared Information Curator terminal.

Changed/no-change is calculated from before/after **player-safe L3 projections**, captured around the real Curator opportunity. The observer does not parse Curator model output and does not read hidden storage to infer semantic meaning.

On shared Curator failure/stale/cancelled, all affected rows show the shared abnormal terminal rather than invented per-domain success.

Counts are deliberately conservative:

- Experiences: total / added / removed count;
- People: total count + projection changed/no-change only;
- no display-name matching is used to invent People add/update/remove counts.

This respects the frozen privacy and Model Freedom boundaries.

## 9. Recommendations diagnostic seam

**PASS.**

The player-facing `snapshot()` remains `{status, actions}` and strict 5×`{label,draft}` parsing remains unchanged.

The new diagnostic-only lifecycle distinguishes:

- ready;
- input unavailable;
- malformed structured response;
- response oversized;
- Provider/start failure;
- timeout;
- cancelled;
- stale/currentness discard.

No fence stripping, repair, hidden retry, Provider fallback or click-time model call was added.

The diagnostic callback is emitted separately from player-facing fallback state. Existing fail-soft `unavailable` behavior therefore remains compatible while Owner gains the missing cause.

## 10. Save / Restore / currentness

**PASS.**

Restore is implemented as a true diagnostic epoch boundary:

- increment epoch;
- clear prior trace;
- clear pending Curator/Recommendation tokens;
- append one bounded Restore result;
- old-epoch terminal callbacks are rejected.

Replacement/current accepted prefix is also checked before turn-scoped publication. Old-version records are pruned when current accepted truth changes.

A successful `already_current` operation does not falsely claim that a timeline switch/trace clear happened.

Save/Restore diagnostic recording ignores arbitrary free-form messages/paths and maps only bounded status evidence.

## 11. Buffer bound / lifetime

**PASS.**

Recorder is bounded to the latest 64 entries. This is storage-only and does not influence gameplay.

Snapshot is deep-copied. Game/session teardown clears the recorder and pending tokens; reopening starts with Debug OFF and no persisted trace.

## 12. UI review

**ENGINEERING PASS / PRODUCT UAT REQUIRED.**

The implementation adds a TopBar `调试` toggle and a compact shell-owned overlay panel with its own scroll region.

Real-window evidence covers 1280×720 and 960×540, ON/OFF, overflow, failure/no-change readability, real mouse toggle, free-form Send, recommendation click, Save/Restore and reopen-default-OFF.

The panel intentionally overlays the upper-right portion rather than changing Host allocation. Engineering evidence shows Narrative/composer remain usable and layout returns when OFF.

Owner must still judge practical readability/occlusion during real play.

## 13. Deterministic validation assessment

Evidence supports the reported focused result:

- 146 checks / 0 failures;
- real-window 52 checks / 0 failures;
- controlled asynchronous producer ordering;
- ordinary no-change and positive-change cases;
- shared Curator failure;
- distinct recommendation failures;
- Restore with changed and identical accepted text;
- same-epoch replacement;
- late callback rejection;
- 64-entry bound;
- snapshot isolation;
- shutdown clear;
- privacy canaries.

This evidence materially covers the Engineering Acceptance Matrix.

## 14. Regression assessment

Direct regression inventory is appropriately broad across Narrative, World, identity, curation, People, Recommendations, Save/Restore and MW-021 scroll.

All listed directly affected suites pass except G3-03's existing assertion:

`opaque World JSON is not injected as Game Context`

The exact same failure is committed from an isolated run on Formal Code Base `d81f5f...`; it is therefore a retained baseline defect/assertion drift, not evidence of an MW-022 regression. MW-022 correctly leaves that unrelated Context issue unchanged.

No new regression blocker was found.

## 15. Import / export assessment

Final Godot import and fresh Windows export/`-ValidateExportOnly` evidence report no script/parse/export errors and a newly generated PCK tied to the candidate input hash.

This is sufficient for Engineering review. Owner canonical build installation remains a later handoff step.

## 16. Real Provider note

No real Provider call was executed.

This is **not an Engineering blocker** because MW-022 changes observability, not model prompts/semantic behavior, and deterministic tests exercise the actual producer lifecycle seams with controlled transports, including asynchronous completion and all required failure/currentness branches.

It remains a **Product UAT risk**: real network/model timing may reveal whether rows arrive in a way that is understandable and useful during normal play.

## 17. Notes / retained risks

N-01 — Real Provider timing/terminal behavior has not yet been observed in an Owner build. Validate in Product UAT; do not add synthetic retries merely to make traces look cleaner.

N-02 — Debug ON uses a right-upper overlay. Engineering layout is bounded, but Owner must judge sustained readability and obstruction, especially at smaller windows.

N-03 — People safe projection intentionally lacks stable identity metadata, so v0.1 does not fabricate exact add/update/remove counts. This is correct conservative behavior, not a missing requirement.

N-04 — G3-03's pre-existing Context assertion remains outside MW-022 scope and should stay recorded as existing debt until a relevant Context task addresses it.

## 18. Verdict

**ENGINEERING PASS_WITH_NOTES**

No blocker found against the frozen MW-022 architecture or Task Packet.

Allowed next state:

```text
reviewed integration
→ fresh Owner build
→ focused Owner Debug Mode Product UAT
```

This review does **not** grant Product PASS.
