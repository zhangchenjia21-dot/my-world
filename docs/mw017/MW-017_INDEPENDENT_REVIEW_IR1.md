# MW-017｜Independent Review IR1

Status: **ENGINEERING PASS**  
Work Item: **MW-017 People Identity Bridge + Same-turn Barrier**  
Reviewer: GPT  
Reviewed candidate: `dd7b56fb030085b5c74dbe221bf8b5741bef3724`  
Reviewed code commit: `2be0c532d89c0fa7ae1d473d408a42785a32c8d9`  
Implementation base: `286f72d78c8470f2d78fa2f3847ace081cae7bd4`  
Governance refreshed through: `8f38b4998e7b9d77ac731f8248cbc7e7fcc4945d`

## 1. Verdict

**ENGINEERING PASS.**

The candidate satisfies the frozen MW-017 outcome:

```text
accepted player-authored Turn
→ existing World semantic lane
→ materialize/reuse stable actor identity
→ persist exact accepted-person → stable-NPC identity receipt
→ publish current-version semantic terminal
→ existing Information Curator lived opportunity may proceed
```

No People content schema or People UI was implemented. MW-018 remains separate.

## 2. Independent evidence reviewed

Review used the actual candidate diff and implementation/evidence files, not the implementer summary alone.

Reviewed production seams:

- `src/世界回合/L0_公理层/人物身份回执规则.gd`
- `src/世界回合/L1_器件层/语义变更响应解析器.gd`
- `src/世界回合/L2_流程层/语义物化流程.gd`
- `src/世界回合/L3_外交层/世界回合公开接口.gd`
- `src/世界回合/L3_外交层/人物身份桥公开接口.gd`
- `src/信息整理/L2_流程层/回合信息整理流程.gd`
- `src/信息整理/L3_外交层/信息整理公开接口.gd`
- `src/应用壳.gd`

Reviewed verification evidence:

- `docs/mw017/evidence/results.json`
- `docs/mw017/evidence/real-identity-smoke.json`
- `tests/mw017/人物身份桥屏障纵向测试.gd`
- implementation report and changed-file manifest
- relevant current architecture and Task Packet

## 3. Identity binding findings

### PASS — no authoritative display-name matching

Existing stable NPCs are exposed to the semantic request using request-scoped opaque `actor_ref` values privately mapped to exact Program-owned local IDs.

The Program never resolves a People binding by display-name equality, fuzzy matching, first-name match or name-based dedupe.

If the semantic model cannot resolve same-name/ambiguous people, an empty binding is valid. The Program does not guess.

### PASS — same-response new actor correlation

`candidate_ref` remains transient response-local correlation metadata.

Parser behavior preserves candidate-ref correlation through validation/deduplication rather than zipping raw array positions. Program mints/reuses the stable runtime actor ID first, then resolves a valid candidate ref to that exact ID.

Rejected/duplicate/invalid refs cannot shift onto another normalized candidate.

### PASS — actor + receipt atomicity

A same-turn runtime actor and its identity receipt are written in one existing World semantic durable mutation. No second registration/binding mutation or SQLite table was introduced.

Identity-only / no-change opportunities can persist a receipt without fabricating World changes or Knowledge.

## 4. Receipt/currentness findings

### PASS — full accepted Player+GM prefix

Receipt currentness is bound to the complete accepted Player+GM prefix, not GM bytes alone.

This provides the required behavior for:

- same GM + corrected Player input;
- Regenerate/correction replacement;
- earlier-prefix changes;
- current accepted history validation.

Existing G5 GM-hash identities are not rewritten merely for People.

### PASS — Program-owned receipt integrity

Receipt schema, bounds, stable NPC applicability, span validity, Game/turn/prefix binding and receipt hash are validated before a receipt becomes current.

A malformed or stale receipt fails closed.

### PASS — old Game compatibility

Missing `people_identity_turns_by_index` is valid. Historical pre-feature turns are not silently re-analysed and Source/stable-registry history is not used to fabricate People receipts.

## 5. Same-turn barrier findings

### PASS — real barrier, not construction-order assumption

The Information Curator records only newly accepted lived opportunities and, in production, waits for the exact World semantic `lived_terminal(index,prefix)` before starting that turn's lived curation request.

`queued` / `already_attempted` are not terminal states.

A durable current receipt is revalidated before a successful terminal releases the barrier.

### PASS — fail-soft terminal policy

World semantic failure, cancellation, malformed response or timeout releases existing Character/Important Experiences curation without creating People evidence and without invalidating accepted Narrative.

An absent/failed receipt is not interpreted as an empty/clear-People result.

### PASS — Initial Character unaffected

MW-015 Game/T0 Initial Character curation remains independent and runs before the lived barrier. GM-only opening remains outside People v0.1 as frozen.

## 6. Restore / callback isolation

### PASS — Restore epoch

Restore advances the semantic epoch, clears active/queued/terminal attempt state, disconnects old provider callbacks, cancels the old transport, and captures the restored activation baseline.

Information Curator independently clears its in-flight and lived-opportunity state.

Late pre-Restore callbacks cannot commit a receipt or release stale curation, including after a new request has started.

### PASS — displaced future isolation

People identity receipts follow current World + accepted history. No MW-015 Initial Character fixed-node recovery exception is introduced for People.

## 7. Disclosure boundary findings

### PASS — internal bridge is not player DTO

`人物身份桥公开接口.gd` exposes an internal request-evidence seam containing only:

- request-scoped actor refs;
- exact accepted GM spans/quotes;
- private Program ref→local-ID mapping kept outside future model-visible evidence.

It does not hydrate raw `source_projection`, `game_local_material`, NPC-private Knowledge, Agency plans, hidden World Evolution or Source-current material.

Changing hidden actor profile material does not change the current receipt/evidence.

The existing World semantic model continues to receive its pre-existing stable actor allowlist for World/Knowledge semantics; that internal resolver context is not forwarded to the future People curator or leaf UI.

Residual model coreference error remains possible and is accepted by the frozen architecture under Model Freedom / Reversibility. This is not grounds for a Program semantic judge.

## 8. Regression / evidence assessment

Task-owned evidence reports:

- MW-017 focused vertical: **120 checks / 0 failures**;
- G5-01 materialization + timeline: PASS;
- G5-02 Knowledge: PASS;
- G5-03 / M2A / M2B: PASS;
- G5-04: PASS;
- MW-006 mechanics: PASS;
- MW-014 Character/Important Experiences: PASS;
- MW-015 + MW-015 R2: PASS;
- G4-07B Narrative vertical: PASS;
- Windows Desktop export: PASS;
- `git diff --check`: clean.

The three reported ObjectDB/resource exit-warning families were reproduced at the implementation base with the same counts and are not introduced by MW-017. MW-017's focused suite reports no exit warning.

One bounded real configured Kimi K3 smoke successfully produced:

- one new runtime actor bound through `candidate_ref` after Program ID mint;
- one existing actor bound through request-scoped `actor_ref`;
- exact accepted GM spans re-sliced as the expected public names;
- actor + World change + Knowledge + resolved identity receipt in one semantic commit;
- unchanged Owner production fingerprints.

No heuristic repair was added based on the smoke.

## 9. Reviewed scope / non-scope

PASS:

- no People card UI;
- no `people_updates` curation result;
- no numeric Relationship system;
- no GM-opening People processing;
- no historical People backfill;
- no generic event bus/scheduler;
- no new SQLite table/migration;
- no MW-013 work.

## 10. Integration disposition

MW-017 may integrate to `main`.

This is a backend prerequisite and does **not** require Owner Product UAT by itself.

After integration:

```text
MW-017 ENGINEERING PASS / INTEGRATED
→ shape MW-018 People Curation + Card Surface against this proven bridge
→ Codex implementation
→ GPT Independent Review
→ Owner-build handoff
→ Owner UAT
```

MW-018 must preserve the reviewed separation:

```text
World identity receipt
!= People disclosure content

Program exact identity/currentness
!= Program semantic People judge
```
