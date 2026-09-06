# MW-015 R2 Independent Review — IR1

Work Item: **MW-015**  
Revision: **2**  
Review-Round: **1**  
Reviewer: **GPT**  
Reviewed candidate: `c8618ad9c802d5e0d5c2de5db62e9e88aabdb698`  
Implementation base/current main reviewed: `d4ce553049fcc1a8a67f120e7b7fb86b934f7c49`  
Governance main reviewed: `af25f3ff306757ebae1ee8215b804f7d03fd4ae6`  
Verdict: **ENGINEERING PASS**

## 1. Review scope

This review inspected the pushed candidate and evidence rather than relying on the implementer completion summary. Review focus was the frozen R2 outcome:

```text
Game activation
+ frozen Game-local player-safe protagonist material
↓
model-driven Initial Character Curation
↓
durable Game/T0 Character baseline
↓
right 角色 Surface becomes materially useful
```

The accepted architecture remains:

- initial Character curation is Game/T0-scoped, not a synthetic Turn;
- opening success is not a prerequisite;
- model owns semantic selection/curation;
- Program owns bounded structure, durability, currentness and presentation;
- no new SQLite table;
- left Player Status Host remains hidden while it has no real HUD contribution.

## 2. Actual implementation findings

### PASS — backward-compatible owner extension

`information_curation.v0.1` now accepts either the historical `{schema, turns}` shape or the additive `{schema, initial, turns}` shape. Existing turn records continue to use the original prefix/parent/ID chain. The initial record is outside that parent chain.

### PASS — Program-owned Game/T0 binding

The initial record is bound to the normalized frozen player-safe profile actually supplied to the model. Identity is Program-derived; the model does not mint authoritative IDs/hashes. Changed frozen material invalidates the prior baseline.

### PASS — no opening/synthetic-Turn dependency

Activation schedules the initial lane independently. No accepted Turn 0/-1 or synthetic Conversation entry is created. Atomic Final Create remains Provider-free. The focused shell evidence proves initial and opening can be independently in flight and that opening failure does not invalidate initial eligibility.

### PASS — model semantic authority preserved

The complete frozen player-safe starting profile, including starting possessions, is passed to the model. Production code does not inspect title/content keywords to decide what belongs in Character. The model receives the Character Surface semantics and returns the bounded Character snapshot. Program validation is limited to shape/type/size/output vocabulary and T0 lifecycle rules.

No Zhang-Chen-specific production path, keyword/regex classifier, importance score or per-domain semantic rule tree was introduced.

### PASS — safe projection and currentness

Projection order is:

```text
thin safe fallback
→ valid Initial Character baseline
→ valid lived Character snapshots in existing causal order
```

A lived `character = null` retains the preceding Character state. Initial curation never contributes Important Experiences. Regenerate leaves the Game/T0 baseline valid while lived currentness still follows accepted history.

### PASS — Restore/reopen displaced-future isolation

When a restored snapshot lacks the initial record, the Runtime may locate the fixed Game-local baseline node by binding. It validates and extracts **only** the `initial` record, then commits that record into the latest current World. Future turn records/world subtrees from the historical node are not copied. Focused tests prove future lived records remain absent after reattachment.

### PASS — existing Game and privacy boundaries

Existing Games with a valid frozen player-facing profile can initialize without recreation and without Source-current lookup. Missing/invalid frozen profiles fail closed. Initial input excludes raw semantic sections, GM-private/source-current material, NPC-private Knowledge/Agency and hidden Evolution material.

## 3. Evidence reviewed

Candidate evidence reports and logs were inspected at the exact pushed SHA. Relevant results include:

- Initial Runtime/SQLite lifecycle: **60 checks / 0 failures**.
- Real Zhang Chen shell/UI path: initial and opening independently in flight; opening failure leaves initial eligible; seven Character groups refresh; zero accepted turns; left Host remains hidden.
- Existing MW-015 navigation/lived UI regressions: PASS.
- MW-014 lived curation regressions: PASS.
- MW-011 / MW-011R2 privacy/profile, MW-012 Zhang Chen, MW-009 safe projection: PASS.
- G3 Save/Restore and G5 semantic/timeline regressions: PASS.
- Narrative critical path: assertions PASS; pre-existing exit diagnostics are not represented as warning-free.
- Windows Desktop release export: PASS.
- `git diff --check`: reported clean.
- GitHub candidate is ahead of current implementation main and not behind it; no CI status checks are configured on the candidate.

## 4. Real Provider semantic evidence

Four bounded initial-curation calls were recorded across fresh/existing isolated Games:

- 3 successful commits with seven-group Character output;
- successful output retained supported background/personality/principles/capabilities/limitations/self-direction;
- starting possessions were present in model input but omitted from Character output by the model rather than Program filtering;
- reopen preserved successful projection without another Provider call;
- 1 fresh call returned `malformed_response`, produced no baseline mutation, and retained the safe fallback.

The malformed call is **not an Engineering blocker** because R2 explicitly requires model curation to fail soft rather than adding Program semantic repair heuristics. It remains a Product/UAT reliability risk to observe in the real Owner build.

## 5. Non-blocking residual risks

1. **Provider output variability:** a structurally malformed initial response can temporarily leave the thin fallback until retry/reopen/later repair. Owner UAT should verify real-world reliability and perceived latency.
2. **Semantic quality remains Product-owned:** the successful smoke output is materially richer, but whether wording/grouping is actually good enough is an Owner product judgment, not an Engineering PASS claim.
3. **No GitHub CI checks are configured:** review therefore relies on exact pushed source + committed task-local runtime/test/export evidence.

## 6. Verdict

**ENGINEERING PASS.**

No blocking architecture, privacy, persistence, currentness, scope or regression defect was found in the reviewed candidate.

Authorized next route:

```text
record IR1
→ integrate reviewed branch to main
→ post-integration verification
→ safely synchronize D:/AI/Projects/my-world to exact integrated main
→ fresh Windows export validation
→ Owner UAT
```

This review does **not** declare Product PASS. MW-015 R2 remains open until Owner UAT accepts the real application experience.
