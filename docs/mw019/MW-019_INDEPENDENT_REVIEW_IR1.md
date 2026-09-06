# MW-019｜Independent Review IR1

Status: **ENGINEERING PASS**  
Work Item: **MW-019 Five Recommended Actions**  
Review Round: **IR1**  
Reviewer: **GPT**  
Product UAT: **Owner — PENDING, combined with MW-018**

## 1. Exact review identity / freshness

Reviewed branch:

`mw-019-five-recommended-actions`

Reviewed final candidate:

`5a06f636e332c600d9a5bb327a92792ec7c42c17`

Implementation commit:

`bf9996e67d267871e918f82bd9ad6d2fb539ff0b`

Implementation base / current main at review start:

`b83865c6c4e7bdccf6c40341789e03502baa78a3`

Candidate is a clean two-commit fast-forward from that base: production implementation followed by evidence-only documentation.

Current Vibe-Coding main at review:

`787cb62276963524a238b28dad544ac46d530243`

Codex's final governance refresh was `9b23507bbe4d45f55f42deab1534726f3d2540ef`. The later governance delta was independently compared and contains only the Owner-requested non-canonical SillyTavern functional reference audit plus README/index links. It does not modify `MY_WORLD_CURRENT_STATUS.md`, Five Recommended Actions semantics, architecture, Roadmap authority, Task Packet or agent routing. No Decision Propagation blocker exists.

## 2. Verdict

**ENGINEERING PASS.**

No blocking product-contract, architecture, currentness, disclosure, persistence, send-route, test or export defect was found in the reviewed candidate.

This is **not Product PASS**. MW-019 remains player-facing and must be judged by Owner in the planned combined MW-018 + MW-019 real-build UAT.

## 3. Independent findings

### F01 — recommendation work is correctly isolated from authoritative Narrative

PASS.

The implementation adds a dedicated activation-scoped Action Recommender rather than changing the streaming GM Narrative into a structured response or coupling player-facing suggestions to World semantic / Information Curator output.

The module boundary is narrow:

```text
Shell
→ ActionRecommender L3
→ L2 process
→ player-safe transcript builder + response parser/contract
→ existing runtime-configured Provider L3
```

Recommendation failure therefore does not become a Narrative Finalize Gate.

### F02 — input disclosure boundary is materially correct

PASS.

`推荐材料构建器.gd` receives only durable accepted Conversation entries and reconstructs an allowlisted model request containing only `player` / `gm` text.

It does not call the omniscient GM Context assembler and does not consume World state, Source, stable actor material, private Knowledge, Agency, hidden Evolution, information_curation objects, receipts or IDs.

The latest accepted GM text remains intact when valid; up to four recent accepted pairs are retained under a deterministic 24 KiB UTF-8 JSON user-content bound. If the latest pair alone exceeds the bound, the optional recommendation request is skipped rather than truncating authoritative Narrative.

The request's currentness fingerprint is computed from the whole accepted prefix but is never exposed to the model or UI.

### F03 — model owns recommendation semantics; Program only owns machine structure

PASS.

The prompt asks for concrete, varied, player-visible next-action drafts without guaranteed outcomes or hidden information.

The Program validator only enforces structural bounds:

- exact top-level `{actions}` shape;
- exactly 5 Strings;
- non-empty after trim;
- <= 240 characters per action;
- exact duplicate rejection;
- <= 8 KiB response;
- shallow bounded JSON structure.

There is no tactic-category quota, danger score, "best action" rank, keyword diversity repair, missing-option fabrication or semantic classifier.

### F04 — recommendation click remains draft-only and preserves Player authority

PASS.

The Narrative Host renders the five suggestions next to the existing composer. A click only:

```text
replace PlayerInput with the selected draft
→ focus the composer
→ put the caret at the editable end
```

It does not call Send, `Conversation.begin_turn()`, Public d20, World mutation or persistence.

The existing Send / Ctrl+Enter path remains authoritative. If Public d20 is present, the edited recommendation travels through the existing adjudication route exactly like manually typed text.

### F05 — foreground currentness / stale callback handling is sound

PASS.

A new foreground attempt invalidates current recommendation state, cancels active transport when applicable, increments a monotonic serial and clears previous suggestions.

Publication requires:

- same serial;
- same full accepted-prefix fingerprint;
- Runtime ready;
- no foreground/generation conflict;
- current request still active.

The implementation covers ordinary Send, d20 starting before Conversation attempt creation, retry/regenerate/correction, Restore and shutdown. Old callbacks are disconnected before cancellation so synchronous cancellation cannot republish stale UI.

Failed/cancelled GM attempts create no recommendation opportunity for unaccepted text.

### F06 — Restore / reopen / opening behavior matches the Task Packet

PASS.

- Empty accepted history → zero calls.
- Successfully durably accepted GM-only opening → one recommendation opportunity.
- Ordinary/replacement accepted GM Narrative → one fresh opportunity.
- Reopen/activation or successful Restore may generate one fresh ephemeral set for the current accepted prefix.
- repeated render / resize / tab switching / composer editing / recommendation click → zero calls.

Recommendations are regenerated derived UI, not restored durable state.

### F07 — no second truth or new persistence owner was created

PASS.

No recommendation field/table/migration was added. The feature does not write recommendation output into Conversation, World, Timeline, Save, Source or `information_curation`.

A recommendation becomes authoritative only if the Player explicitly submits the resulting composer text through the pre-existing Player action route.

### F08 — presentation satisfies the engineering-level v0.1 envelope

PASS on available evidence.

Focused rendered checks cover maximized, 1280×720 and 960×540 layouts with no horizontal overflow. Recommendation controls remain compact relative to Narrative, preserve the existing composer-height policy, keep full long/multiline draft text in tooltip/prefill and render button labels compactly.

This does not replace Owner visual/product judgment.

## 4. Test / regression evidence reviewed

Reviewed final focused evidence:

- **122 checks / 0 failures**;
- opening opportunity;
- ordinary accepted turn;
- exact five display;
- player-safe canaries excluded;
- no Conversation / World / Timeline / SQLite mutation;
- new foreground cancellation / stale callback isolation;
- correction / regenerate / Restore / reopen;
- Provider failure / cancel / timeout / malformed / oversize fail-soft;
- click/prefill/edit / manual free-form route;
- d20 route preservation;
- structural exact-bound tests;
- responsive layout.

The aggregate regression manifest reports all 26 named suites with exit code 0, covering MW-019 plus relevant G2, G4 opening/Public-d20, G5, MW-014, MW-015, MW-017 and MW-018 regressions.

Windows Desktop export completed with exit 0. `git diff --check` is reported clean.

Existing exit-warning families are disclosed rather than hidden. Codex also reproduced the Public d20 warning family against unmodified main. They are not introduced by MW-019 and are not expanded inside this task.

## 5. Review of task-only edits to legacy tests

PASS.

Two pre-existing tests were adjusted without altering production behavior:

1. G2-03 now gives its offline Provider fixture a task-local absent settings path, avoiding accidental dependence on the Owner's currently selected Kimi profile while the test deliberately manipulates `DEEPSEEK_API_KEY`.
2. G2-05 now checks the actual `\n\nCurrent Game Context\n` section delimiter instead of treating a prose mention of that phrase inside GM instructions as evidence that the section exists.

Codex preserved baseline logs showing the old assertions fail on an archive of unmodified current main for the stated environmental/string-matching reasons. These are legitimate test isolation/correctness repairs, not production regression masking.

## 6. Real configured Provider evidence

Reviewed bounded real configured Kimi K3 evidence:

```text
Request 1 — opening
→ ready
→ exactly 5 accepted recommendations
→ ~3.9 s

Request 2 — ordinary turn
→ unavailable
→ raw model output was Markdown-fenced JSON
→ strict parser rejected it
→ ~4.9 s
```

The successful five actions are concrete and grounded in the synthetic player-visible scene. The request contains only accepted Player/GM transcript material.

Owner production fingerprints are unchanged before/after.

### Retained Product/UAT risk — formatting reliability

The sample is intentionally not mass-retried to manufacture a flattering success rate. One of two real calls failed solely because the model wrapped otherwise valid JSON in a Markdown fence.

Under the frozen MW-019 contract this is correct engineering behavior:

- malformed/fenced JSON fails soft;
- Program does not strip fences or repair semantics;
- there is no hidden retry or Provider fallback.

Therefore this is **not an Engineering blocker**, but it is a real **Product/UAT reliability risk**. Owner UAT must judge whether recommendation availability is sufficiently reliable in normal play. If repeated real play frequently shows `暂时没有推荐行动`, the correction should remain in MW-019 lineage and should address the model/structured-output seam deliberately rather than adding heuristic text repair.

## 7. Non-blocking observation

A reopened Game with an existing unresolved durable d20 action is not a MW-019 acceptance case explicitly called out by the packet. The existing d20 UI already gates composer editing/requires retry. The recommender's activation path is based on accepted Conversation currentness and may still have an accepted prefix available.

No evidence currently shows data corruption, bypass or stale publication, and recommendation click itself refuses when the composer is non-editable. This is not a release blocker for MW-019 IR1; if combined Owner UAT encounters confusing recommendations while an old d20 action must be retried, treat it as a concrete UX finding rather than inventing a pre-emptive architecture change.

## 8. Integration authorization

Candidate `5a06f636e332c600d9a5bb327a92792ec7c42c17` is approved for fast-forward integration to implementation `main` together with this Independent Review record.

After integration:

```text
MW-018 People      = Engineering PASS / integrated / Owner UAT deferred
MW-019 Suggestions = Engineering PASS / integrated / Owner UAT pending
↓
canonical Owner checkout safe-sync
↓
fresh Windows export validation
↓
combined Owner UAT
```

Owner must issue independent Product verdicts for MW-018 and MW-019 even if both are tested in the same session.
