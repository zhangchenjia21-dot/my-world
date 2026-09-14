# TASK｜MW-034｜G7 Information Curator Bounded Recovery

Type: implementation  
Owner: Codex  
Capability-Anchor: G7 Package 8｜Structured Output Reliability — proven consumer slice  
Revision: 1  
Review-Round: 0  
Formal Code Base: `651362305a7d4a2872a2da9293b9a2a77e33b7f4`  
Required branch: `mw-034-g7-information-curator-recovery`  
Required worktree: `D:/AI/Projects/.worktrees/my-world/mw-034-g7-information-curator-recovery`  
Frozen architecture: `Vibe-Coding/my world/architecture/G7_INFORMATION_CURATOR_BOUNDED_RECOVERY_V1_0_DECISION.md@v1.0`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Add one bounded automatic recovery attempt to the existing Information Curator process for recoverable machine-response failures, covering both:

1. initial Character baseline curation;
2. lived Opening/action Character / Important Experiences / People / Open Threads curation.

For one still-current logical Curator opportunity:

```text
initial Provider start
+
at most one recovery Provider start
=
maximum 2 starts
```

Do not create a generic Structured Output framework. This is the third real consumer slice used to collect evidence before any common abstraction is considered.

## 2. Why this task

Current `回合信息整理流程.gd` already has strict parsing, 120s timeout, Restore epoch invalidation, prefix/parent currentness and explicit `retry_pending()`, but malformed/timeout/provider failure terminates the opportunity immediately and `_attempted` prevents normal same-runtime automatic replay.

A transient formatting/transport failure can therefore leave the current Character/People/Threads state stale or leave the pre-action Character baseline absent even though gameplay continues.

The Product goal is reliability, not semantic repair:

> retry the same current curation opportunity once; never fabricate or rewrite the model response into truth.

## 3. Authority / Source Manifest

Read authority in this order:

1. Owner current explicit instruction.
2. Current `Vibe-Coding/AGENTS.md` / collaboration rules.
3. current Product / Core Principles / Architecture / Roadmap / Current Status.
4. frozen `G7_INFORMATION_CURATOR_BOUNDED_RECOVERY_V1_0_DECISION.md@v1.0`.
5. current implementation at Formal Code Base.
6. historical task/evidence only when not superseded.

Before edits refresh:

- `my-world/main`;
- `mw-034-g7-information-curator-recovery`;
- `Vibe-Coding/main`.

STOP on relevant governance/main drift rather than implementing a stale packet.

## 4. Read first

Minimal initial set:

1. repo `AGENTS.md`;
2. this Task Packet;
3. frozen MW-034 architecture;
4. `src/信息整理/L2_流程层/回合信息整理流程.gd`;
5. `src/信息整理/L1_器件层/信息整理响应解析器.gd`;
6. Information Curation contract + Subjects/People/Threads helpers only where required;
7. current Recommendations bounded-recovery flow only as lifecycle reference, not as code to generalize;
8. Provider adapter failure/status contract only as required for failure classification.

Do not read/rewrite the whole repository by default.

## 5. Frozen invariants

### INV-01｜Curator only

Modify Information Curator reliability only.

Do not change recovery semantics for Recommendations, Public d20, World semantic, Agency, Evolution or Narrative.

### INV-02｜No semantic/parser repair

Keep the Curator parser strict.

Do not add:

- Markdown fence stripping;
- regex JSON extraction;
- prefix/suffix cleanup;
- missing-key/default-field fabrication;
- semantic coercion;
- fallback Character/People/Threads;
- relaxed schema.

A malformed attempt commits zero state; recovery is a new model request.

### INV-03｜Max two starts

One logical opportunity gets maximum two Provider starts.

No backoff loop, third attempt, recursive retry or Provider/model fallback.

### INV-04｜Recoverable failures only

Eligible first-attempt terminal classes:

- strict parser returns malformed/unusable response;
- Curator-owned timeout;
- transient Provider/transport failure.

Not eligible:

- known permanent credential/settings/profile/config failure;
- deterministic input oversize;
- deterministic response oversize;
- invalid initial/profile/storage prerequisite;
- stale history / stale parent / Restore invalidation;
- explicit cancellation / shutdown;
- persistence failure after a valid candidate reaches storage.

Preserve Provider failure code/status long enough to classify it instead of collapsing every failure to `provider_failure`.

Use a small lane-local classifier. Do not invent a global Provider error framework.

### INV-05｜Initial identity

Initial opportunity remains bound to:

- current Game;
- current initial profile binding;
- current Restore/runtime epoch.

Recovery must not create a second logical initial baseline opportunity.

### INV-06｜Lived identity

Lived opportunity remains bound to:

- Game;
- accepted index;
- exact prefix at that index;
- current curation parent;
- current Restore/runtime epoch.

Recovery cannot bypass `_attempted`, durable-success dedupe, parent/currentness or semantic-barrier requirements.

### INV-07｜Fresh request-scoped refs

For lived recovery, rebuild the bounded request material from current owners.

People/Thread/actor request refs may be regenerated and must be validated against the refs for **that recovery request**.

Do not reuse display-name matching or durable internal IDs.

Do not send the malformed raw response back to the model.

### INV-08｜Recovery cue is bounded

Attempt 2 may add one small system-owned cue equivalent to:

> Previous machine response was unusable. Return only the exact required JSON schema, without Markdown or explanation.

No raw malformed content, parser stack, internal IDs/hashes or private bindings in the recovery prompt.

### INV-09｜Callback isolation

This is mandatory.

The current worker-lifetime Provider signal connections are insufficient once attempt 2 can start after attempt 1 timeout/cancel.

Introduce a monotonic request serial / attempt token or equivalent isolation so:

- callbacks are associated with the exact attempt;
- late delta/completed/failed/cancelled from attempt 1 cannot mutate/terminate/commit attempt 2;
- Restore/shutdown invalidates all old callbacks;
- old transport is disconnected/terminal before recovery begins;
- synchronous cancel/failure cannot overwrite the intended root terminal.

Do not rely only on `_active` being non-empty.

### INV-10｜Atomic durable commit

Only a successfully parsed, still-current result can enter the existing single curation commit.

No partial attempt-1 mutation; no duplicate record/experience/person/thread identity from attempt 2; no schema migration.

Persistence failure is terminal and not auto-retried.

### INV-11｜Narrative never waits

Curator remains a fail-soft background lane. Recovery must not become a Narrative Finalize Gate or block free-form Player interaction.

### INV-12｜Existing explicit retry remains

`retry_pending()` remains an explicit later repair seam. Automatic two-start budget and later explicit repair are distinct.

## 6. Failure classification

Use existing Provider statuses as evidence. At minimum known permanent configuration statuses equivalent to the Recommendation lane must not retry:

```text
missing_key
missing_credential
invalid_profile
invalid_persisted_settings
invalid_settings
unknown_profile
unknown_context_limit
unknown_reasoning_request
incompatible_context_limit
```

If current Provider code exposes a clearer transient/permanent classification, use that existing contract rather than duplicating lists unnecessarily.

Do not assume every unknown error is transient.

Document the exact classifier in implementation return.

## 7. Request lifecycle direction

Prefer a narrow internal refactor that makes one Curator opportunity own:

- mode: `initial` / `lived`;
- logical opportunity identity;
- attempt number;
- request serial;
- request-scoped refs/material;
- recovery eligibility;
- current terminal diagnostics.

Do not create a general retry base class or shared cross-lane framework.

Malformed completion:

```text
attempt 1 completed
→ strict parse fails
→ confirm opportunity still current
→ old attempt terminal
→ schedule attempt 2
```

Timeout:

```text
attempt 1 timeout
→ freeze recovery eligibility
→ safely disconnect/cancel attempt 1
→ ignore any late attempt-1 terminal
→ start attempt 2 only after isolation is established
```

Transient Provider failure follows the same max-one recovery rule.

## 8. Initial baseline requirements

Test and preserve:

- initial success record and durable node semantics;
- no Important Experience from initial baseline;
- no dependency on GM Opening;
- no fake Character when both attempts fail;
- reopen does not regenerate an already durable initial baseline;
- explicit retry can later recover after final failed automatic attempt.

## 9. Lived curation requirements

Test and preserve:

- active Opening/action curation reviews Threads as current full set;
- Character / Experiences / People / Threads semantics unchanged;
- People exact refs / subject identity unchanged;
- Thread stable identity unchanged;
- identity receipt dependency behavior unchanged;
- malformed attempt 1 writes nothing;
- valid attempt 2 writes exactly one current record;
- later lived opportunity is still processed after a final two-attempt failure.

## 10. Required diagnostics

Extend existing `diagnostic_started` / `diagnostic_terminal` safely.

Evidence must let review determine:

- initial vs lived;
- logical request/opportunity version;
- attempt number 1/2;
- terminal class/status;
- recovery scheduled/started;
- elapsed time if existing diagnostic timing already supports it.

Do not expose raw Player/GM text, model response, Character/People/Thread payloads, request refs, durable IDs/hashes, API keys or private bindings.

## 11. Focused test requirements

Create `tests/mw034/` or equivalent focused vertical using production Curator process + deterministic Provider stub.

At minimum prove:

### AC-01 Initial malformed recovery
Attempt 1 malformed; attempt 2 exact valid baseline; 2 starts; one durable initial baseline.

### AC-02 Lived malformed recovery
Attempt 1 malformed; attempt 2 valid lived Character/People/Threads response; 2 starts; exactly one durable curation record.

### AC-03 Timeout isolation
Attempt 1 times out; recovery starts once; late cancelled/completed/delta from attempt 1 cannot terminate or contaminate attempt 2.

### AC-04 Transient provider failure
Recognized transient failure gets exactly one recovery and can succeed.

### AC-05 Second failure ceiling
Any eligible second-attempt failure ends fail-soft; total starts = 2; no third start.

### AC-06 Permanent configuration failure
Known permanent config/credential failure gets no recovery; starts = 1.

### AC-07 Deterministic size failures
Input oversize and response oversize do not retry.

### AC-08 Explicit cancel/shutdown
No recovery; late callbacks ignored.

### AC-09 Restore
Restore during attempt 1, while recovery is pending, and during attempt 2 invalidates old work; displaced future content never commits.

### AC-10 Currentness
Prefix/parent mismatch prevents stale recovery/commit; no current-state corruption.

### AC-11 Fresh request refs
Recovery request can use fresh People/Thread refs; valid response using attempt-2 refs commits; attempt-1 refs are rejected/no authority in attempt 2.

### AC-12 Raw malformed response exclusion
Attempt-2 request contains the bounded correction cue but not attempt-1 malformed text/private request refs.

### AC-13 Later opportunity continuity
After final failure of one lived opportunity, a later accepted turn still receives and can commit curation.

### AC-14 Explicit retry seam
After automatic recovery is exhausted, `retry_pending()` can establish a later explicit repair attempt according to existing semantics.

### AC-15 Gameplay independence
Narrative/Conversation acceptance is not blocked by Curator retry or failure.

### AC-16 Reopen/dedup
Successful recovered initial/lived record is not regenerated on reopen.

### AC-17 Diagnostic safety
Attempt/recovery evidence is observable without raw semantic/private payload leakage.

## 12. Regression gate

At minimum rerun current suites covering:

- initial Character baseline;
- Important Experiences;
- People + People R1;
- Open Threads + MW-032 lifecycle correction;
- Information Curation integration/currentness;
- Opening semantic/bootstrap;
- Restore / Regenerate / reopen;
- Recommendations bounded recovery (unchanged behavior);
- Public d20 control recovery (unchanged behavior);
- World semantic/Knowledge/Agency/Evolution (unchanged behavior);
- MW-033 working-set Context, because Curator current projections feed Narrative Context.

Use the repository's directly affected/broad relevant manifest; any retained failure requires exact-base reproduction.

## 13. Real-window / build gate

No UI redesign is authorized. If Curator diagnostic/UI integration is untouched, focused headless evidence may carry the main acceptance burden, but run existing relevant real-window/product smoke if required by repository harness/regression discipline.

Before return:

- Godot 4.7.2 final import;
- fresh Windows export;
- `run-game.ps1 -ValidateExportOnly`;
- no Owner build installation/launch;
- no Owner real Game/Source/settings/preferences mutation.

## 14. Explicit non-scope

Do not add:

- generic Structured Output middleware;
- cross-lane retry helper/base class;
- JSON repair or fence stripping;
- schema DSL;
- Provider/model fallback;
- more than one auto recovery;
- semantic retrieval/vector memory;
- Context Orchestrator changes;
- World semantic retry;
- Agency/Evolution retry;
- UI feature work;
- new persistence table/schema;
- Package 9 provenance/epistemic features.

## 15. Git discipline

- work only on `mw-034-g7-information-curator-recovery` in required worktree;
- do not overwrite unknown dirty work;
- do not merge `main`;
- do not force push;
- commit implementation and evidence;
- push branch;
- pre-return refresh both authoritative mains and task branch;
- STOP on relevant drift.

## 16. Return requirements

Highest return: **READY FOR INDEPENDENT REVIEW**.

Return:

- Starting HEAD;
- Implementation HEAD;
- Final Candidate HEAD;
- remote-tip confirmation;
- exact failure classifier;
- callback-isolation design;
- initial/lived malformed recovery evidence;
- timeout + late-callback evidence;
- transient vs permanent Provider failure evidence;
- second-failure ceiling;
- Restore/currentness/fresh-ref evidence;
- explicit retry evidence;
- focused total;
- regression manifest;
- import/export/ValidateExportOnly evidence;
- real Provider call count;
- retained failures/warnings with baseline proof if any;
- deviations/risks.

Do not claim Product PASS, Package-8 completion or shared reliability-platform completion.