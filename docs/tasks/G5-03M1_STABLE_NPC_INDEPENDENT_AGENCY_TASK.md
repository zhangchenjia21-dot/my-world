# TASK｜G5-03M1｜Stable Guaranteed-NPC Independent Agency Vertical

Type: **backend mechanism / first autonomous-actor consumer**  
Owner: **KIMI**  
Reviewer / semantic owner: **GPT**  
Parent: **G5-03 NPC / Faction Agency**  
Prerequisite: **G5-02 PASS / CLOSED**  
Code Base SHA: `e3fadc50f06f6174470a68f5e652ec51f3327b1a`  
Governance decision: `Vibe-Coding@e84f8b96573fc082d582981681c9f3fb40631a6a`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 0. Temporary execution routing

Through 2026-09-06 23:59 (+08:00), the Owner's temporary routing applies:

```text
GPT  → semantics / architecture / final Independent Review
Kimi → code-changing implementation owner
Grok → external research/evidence support only when useful
```

This task is assigned to **Kimi**. Do not wait for Codex quota recovery.

## 1. Read first

Refresh both `main`s, then read the minimum authoritative set:

1. repository `AGENTS.md`;
2. this packet;
3. `Vibe-Coding/my world/architecture/world/G5_STABLE_NPC_AGENCY_V0_1_DECISION.md`;
4. `Vibe-Coding/my world/architecture/world/G5_KNOWLEDGE_PROVENANCE_V0_1_DECISION.md`;
5. current `src/世界回合/**` G5-01/G5-02 implementation;
6. current Game Runtime / Application composition seams directly required for lifecycle + atomic world mutation;
7. Guaranteed-NPC durable setup shape and current tests.

Do not redesign G5-04+, UI, Source or persistence.

## 2. Outcome

Implement one real living-world consumer:

> After an ordinary accepted player turn finishes its existing semantic lane, one stable Guaranteed NPC may independently decide to act from **that NPC's own Source + durable knowledge**, without the player explicitly prompting that NPC and without blocking the player's next action.

This is the first autonomous actor vertical. It is not a Faction/society simulator.

## 3. Actor scope

Agency v0.1 evaluates only `world_state.guaranteed_npcs[*]` carrying stable `local_character_id`.

Do not autonomously control the Player Character.

Do not create identity for incidental/emergent NPCs, Factions, groups or arbitrary entities.

If no Guaranteed NPC exists, no agency Provider request occurs.

## 4. Evaluation scheduling

For one eligible accepted ordinary Conversation turn, evaluate **at most one** Guaranteed NPC.

If multiple Guaranteed NPCs exist, select one deterministically and fairly using current durable array order plus source turn index (round-robin or semantically equivalent deterministic selection).

This selects who is *evaluated*, not who must act.

Do not implement pressure/priority scheduling; G5-04 owns that.

Agency evaluation begins only after the existing G5-01/G5-02 semantic lane for that source turn emits a terminal result.

Before starting, require:

- source turn is still the latest accepted ordinary turn;
- Conversation is currently idle / not generating;
- Game session is ready;
- this source version has not already committed an agency action or been attempted in the current session.

## 5. Foreground freedom — mandatory

Agency is background best-effort work, **not a Turn Finalize Barrier**.

The player must remain free to start the next action without waiting for agency.

If a new Conversation attempt starts while agency is queued/active:

```text
cancel/invalidate agency best-effort
→ never delay foreground Narrative
→ late agency callback cannot commit
```

No Narrative retry/failure because agency fails, times out, is cancelled or returns malformed/no-action data.

No automatic agency retry and no Provider fallback.

## 6. Actor-scoped request context

Build the selected actor's agency request from bounded actor-local material only:

1. exact stable actor ID + display name;
2. that Guaranteed NPC's exact Game-local `source_projection` / selected T0 character material;
3. that actor's **own** committed, current-hash-matching G5-02 Knowledge Provenance;
4. that actor's own recent committed agency actions/effects, if any.

Do not pass:

- full omniscient GM/world Context;
- Player Character's private post-T0 knowledge;
- another NPC's private post-T0 knowledge;
- raw unrelated Conversation history as a shortcut.

Starting knowledge authored inside the selected actor's own Character Source is allowed; G5-02 intentionally did not convert all T0 biography into explicit knowledge events.

Add explicit machine guidance:

> Act only from the supplied actor Source, supplied actor knowledge and own prior actions. Do not use facts merely because an omniscient GM could know them.

## 7. Agency machine output

Use a separate non-player-visible machine response, conceptually:

```json
{
  "actor_id": "exact-local-character-id",
  "decision": "hold|act",
  "intent": "concise current aim",
  "action": "concise action the actor now undertakes",
  "effects": ["immediate durable effect already established by undertaking the action"]
}
```

Freeze these semantics:

- `actor_id` must exactly equal the selected actor ID;
- `decision` only `hold` or `act`;
- `hold` creates no durable mutation;
- `act` requires bounded non-empty `intent` + `action`;
- `effects` is bounded and may be empty when the action itself is the durable fact;
- effects must describe immediate established consequences, not guaranteed uncertain future success;
- do not output reasoning;
- malformed/wrong actor/oversized output fails soft.

Choose small explicit limits, e.g. <= 256 chars intent, <= 512 chars action, <= 4 effects of <= 512 chars, or an equally bounded shape documented in evidence.

Do not introduce hidden d20/check logic. G5-05 owns mechanics integration.

## 8. Durable agency record

For valid `decision=act`, store a Program-owned record under existing game-local `living_world`, conceptually:

```text
living_world
  agency_turns_by_source_turn
    <source_turn_index>
      agency_turn_id
      source_turn_index
      source_gm_sha256
      source_head_id
      actor_id
      intent
      action
      effects[]
      materialized_at
```

Stable identity must include at least:

`game_id + source_turn_index + accepted GM hash + source_head_id + actor_id`.

Use the existing atomic `session_runtime.commit_world_mutation_durably(...)` seam.

No SQLite schema/table migration and no second persistence owner.

A `hold` / invalid / cancelled result creates **no fake world mutation**.

Same already-committed source version must not duplicate the action on replay/reopen.

## 9. Agency Context consumers

### 9.1 Later omniscient GM continuation Context

Extend the existing bounded world-context projection so committed/current agency actions can appear as GM world truth, with semantics like:

```text
## Independent Actor Actions
孙权 [local-id]
- intent: ...
- action: ...
- effects: ...
```

This is GM reference only. It is **not** automatic Player disclosure and **not** automatic knowledge for every actor.

### 9.2 Future agency request for the same actor

The selected actor's own recent agency history may be included in that actor's future agency request so it remembers its own actions.

Do not copy agency effects into every actor's `knowledge_turns_by_index`.

Other actors learn about the action only when later accepted Narrative/G5-02 provenance establishes awareness.

Keep projection bounded from v0.1. G7 owns long-session retrieval.

## 10. Stale work / race safety

Because agency is asynchronous, this is a blocking engineering invariant.

At request start capture at least:

- source turn index + accepted GM hash;
- current accepted Conversation count/version;
- current `session_runtime.active_head_id`;
- a local agency epoch/generation token if useful.

Before commit require the request is still current.

A result must not commit if any of these happened after request start:

- new Conversation attempt began;
- accepted Conversation advanced;
- active world head changed;
- Save Restore / Recovery switched current progress;
- source GM hash changed;
- session is closing.

Connect to existing Conversation `attempt_started` and Runtime `restore_completed` (or an equivalently narrow existing seam).

Best-effort transport cancel alone is insufficient: a simulated late callback after invalidation must also be unable to commit.

## 11. Application composition

Wire the new agency runtime into the real Game Session lifecycle, not a test-only mini path.

Expected composition:

```text
current Game Runtime
+ existing WorldTurn semantic runtime
+ new Stable NPC Agency runtime
```

The Application may connect the semantic runtime's terminal `finished` signal to the agency runtime's bounded evaluation seam.

Teardown ordering must cancel agency transport before closing the Game Runtime/writer.

A tiny test-only agency adapter override seam is acceptable following existing Opening/WorldTurn patterns.

Do not change UI interaction flow.

## 12. Deterministic required proofs

Add focused tests covering at least:

### A. Actor-scoped knowledge isolation

Task-owned state contains:

```text
Guaranteed NPC A Source
NPC A knows F
Player knows private P
```

Agency request for NPC A must contain A's Source + F and must **not** contain private P or another actor's knowledge.

### B. Independent act → one atomic mutation

Controlled response returns valid `act`.

Prove:

- one agency request;
- one atomic world mutation;
- durable agency record carries exact stable actor ID/action/effects;
- later GM Context projects the independent actor action.

### C. Hold / malformed / wrong actor fail-soft

Each produces no mutation and never alters accepted Narrative.

### D. No Guaranteed NPC

No agency request.

### E. Fair bounded selection

With multiple Guaranteed NPCs, adjacent eligible source turns select actors deterministically/round-robin without evaluating more than one actor per turn.

### F. Player starts next turn while agency active

```text
agency request active
→ Conversation attempt_started
→ agency invalidated/cancelled
→ simulate late completed callback
→ zero agency mutation
→ foreground Conversation remains usable
```

### G. Restore while agency active

```text
agency request active
→ committed Restore/progress switch
→ simulate late callback
→ zero stale agency mutation in restored timeline
```

### H. Replay / reopen

Committed source version does not duplicate the same agency action; Save/reopen preserves the action in later GM Context.

## 13. Regression gates

At minimum run:

- all new G5-03 focused tests;
- G5-02 focused knowledge tests;
- G5-01 semantic + Timeline tests;
- directly affected G2 Conversation/Context tests;
- directly affected G3 Save/Restore tests;
- directly affected G4 continuation / application composition tests;
- `git diff --check`.

No real Provider call until deterministic/integration gates are green.

## 14. Real Provider validation — pre-authorized, one feature-specific call

Standing authorization applies:

`Vibe-Coding/my world/architecture/foundation/REAL_PROVIDER_VALIDATION_STANDING_AUTHORIZATION.md`

After all offline/integration gates pass, perform at most **one** task-owned real selected-Provider **agency** request.

Prefer stubbing Opening/foreground Narrative/semantic prerequisites so the one bounded real call is spent on the G5-03 feature itself.

Use a task-owned Game with one Guaranteed NPC and durable actor knowledge/pressure sufficient to make an independent action reasonable.

Feature-specific PASS requires:

```text
real agency request
→ valid selected actor ID
→ decision=act
→ one durable agency record/effect
→ later GM Context contains that action/effect
```

A valid `hold` is not Product/feature failure, but it is **INCONCLUSIVE** for the first real action proof. Do not loop until `act`.

If Provider times out/unavailable/malformed/hold within the one bounded attempt:

```text
real G5-03 agency vertical = PENDING / INCONCLUSIVE OR EXTERNAL PROVIDER UNAVAILABLE
→ commit/push reviewable implementation/tests/evidence
→ READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

No second attempt, fallback or hidden provider switch.

## 15. Scope ceiling

Expected production scope:

- a new bounded actor-agency module/layer;
- minimal extension of current world/knowledge context projectors to support actor-scoped input and GM agency projection;
- minimal Application composition/lifecycle wiring;
- existing world mutation seam only.

Protected unless an actual blocker is returned:

- `src/domain/会话.gd` semantics;
- `src/ui/**`;
- persistence schema/migrations;
- Source schema/generation;
- Runtime Model Settings;
- Public d20;
- Faction identity/agency;
- G5-04 priority scheduler;
- G5-05 mechanics;
- G6 visuals/UI;
- G7 retrieval.

Do not build a generic actor/entity simulation platform.

## 16. Evidence

Create:

`docs/g5_03/G5-03M1_STABLE_NPC_INDEPENDENT_AGENCY_EVIDENCE.md`

Record:

- START_HEAD / IMPLEMENTATION_HEAD / FINAL_HEAD;
- exact changed paths;
- actual agency durable shape;
- actor selection rule;
- actor-scoped input proof and cross-actor knowledge exclusion;
- act/hold/malformed/wrong-actor results;
- player-next-turn cancellation + late-callback proof;
- Restore invalidation + late-callback proof;
- replay/reopen/context proof;
- regressions;
- `git diff --check` PASS;
- effective Provider profile without secrets;
- real feature result or honest pending/inconclusive/outage state;
- explicit no Faction/G5-04+/UI/schema scope creep.

## 17. Completion boundary

Commit and push to `origin/main`.

Return one of:

```text
READY FOR INDEPENDENT REVIEW
```

or, if the single real feature proof is pending/inconclusive:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

Do not declare G5-03 PASS/CLOSED or start G5-04. GPT owns Independent Review and the decision whether a Faction slice is required before G5-03 closeout.
