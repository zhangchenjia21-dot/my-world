# TASK｜G5-02M1｜Known-Actor Knowledge Provenance Spine

Type: **backend mechanism / semantic consumer implementation**  
Owner: **KIMI**  
Reviewer / semantic owner: **GPT**  
Parent: **G5-02 Knowledge Provenance**  
Prerequisite: **G5-01 PASS / CLOSED**  
Code Base SHA: `1de7082d85a659e3f01fad3c946ccfe0b56b1592`  
Governance decision: `Vibe-Coding@48c2c8b48e67b657bf30ffb1c237f7370b3e1aff`  
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

Refresh both `main`s, then read only the minimum set:

1. repository `AGENTS.md`;
2. this packet;
3. `Vibe-Coding/my world/architecture/world/G5_KNOWLEDGE_PROVENANCE_V0_1_DECISION.md`;
4. `Vibe-Coding/my world/architecture/world/G5_WORLD_TURN_SEMANTIC_MATERIALIZATION_V0_1_DECISION.md`;
5. current `src/世界回合/**` implementation;
6. current Game-local setup/context projector and Game Runtime seams directly required by the task;
7. current G5-01 focused/SQLite tests.

Do not read or redesign unrelated G5-03+ depth by default.

## 2. Outcome

Implement the minimum durable boundary:

> The GM may know broad world truth, but stable Game-local actors must not automatically inherit every post-T0 fact merely because it exists in GM/world Context.

v0.1 tracks post-T0 knowledge acquisition only for actors already carrying stable Game-local identity:

- Player Character;
- Guaranteed NPCs.

No general Knowledge Graph, emergent NPC identity or Faction knowledge.

## 3. Preserve the G5-01 foreground contract

Protected ordering remains:

```text
free-form visible GM Narrative
→ durable Conversation acceptance
→ one separate best-effort semantic-analysis request
→ optional world/knowledge semantic materialization
→ at most one atomic world mutation
```

Must remain true:

- Narrative carries no JSON/header/sentinel requirement;
- semantic-analysis failure never turns an accepted player action into a failed action;
- no automatic repair loop;
- no cross-provider fallback;
- GM-only Opening remains excluded unless existing G5-01 semantics explicitly say otherwise.

## 4. Reuse one semantic-analysis request

Do **not** add a second Provider call per ordinary accepted turn.

Extend the existing G5-01 machine response so it can carry bounded post-T0 knowledge acquisition adjacent to `changes`.

Conceptual target:

```json
{
  "changes": ["..."],
  "knowledge_events": [
    {
      "knower_id": "local-character-id",
      "fact": "concise fact",
      "basis": "witnessed"
    }
  ]
}
```

Allowed `basis` v0.1:

```text
witnessed
told
discovered
participated
```

Equivalent internal names are acceptable only if semantics stay exact and evidence documents them.

The semantic instruction must tell the model:

- extract only knowledge newly established for listed stable actors by the accepted turn;
- do not grant knowledge just because a fact is true or present in GM context;
- do not infer awareness from Guaranteed NPC membership;
- do not invent unknown actors/IDs;
- do not output reasoning.

## 5. G5-01 backward compatibility is mandatory

Knowledge parsing must be isolated from existing consequence parsing.

Required acceptance behavior:

```text
valid G5-01 changes
+ absent/invalid knowledge_events
→ changes remain eligible to commit
→ knowledge is dropped/fail-soft
```

Do not make knowledge-field mistakes invalidate an otherwise valid `changes` result.

Existing historical turns must not be retroactively re-analysed.

## 6. Stable actor roster

Build a read-only allowlist from current Game-local durable setup:

```text
player_character.local_character_id
+
guaranteed_npcs[*].local_character_id
```

Where useful, pair those IDs with display names for the analysis prompt/context projection.

Durable knowledge events must use local IDs, not display-name matching.

Any returned `knower_id` not in the current allowlist must be discarded and must never become authority.

Do not create IDs for incidental/emergent NPCs in this task.

## 7. Durable shape

Store knowledge provenance inside the existing game-local world document under `living_world`, adjacent to G5-01 records.

Conceptual shape:

```text
living_world
  schema_version = living_world.v0.1
  semantic_turns_by_index
    ... existing ...
  knowledge_turns_by_index
    <turn_index>
      knowledge_turn_id
      source_turn_index
      source_gm_sha256
      events[]
        knower_id
        fact
        basis
```

Requirements:

- Program-owned stable knowledge record identity tied at minimum to `game_id + turn_index + accepted GM hash`;
- bounded event count and fact length;
- source GM hash must match current accepted Conversation truth for projection;
- malformed/unknown actor events are excluded;
- no raw machine response/reasoning persisted.

Do not add SQLite schema/tables. This is part of the existing world snapshot.

## 8. Atomic mutation behavior

A valid analysis may produce:

- `changes` only;
- `knowledge_events` only;
- both;
- neither.

If at least one durable semantic payload exists, produce **at most one** atomic `commit_world_mutation_durably(...)` call for that accepted turn version.

If both are present, they must enter the same candidate world snapshot/mutation.

If neither exists, no world mutation.

Replay/reopen must not duplicate already-materialized knowledge for the same accepted version.

Do not weaken existing G5-01 stable mutation identity merely to add knowledge.

## 9. Context consumer

Add a bounded read-only projection for later ordinary GM Context, conceptually:

```text
## Actor Knowledge Provenance
GM has broader world reference; actors do not automatically share GM knowledge.

刘备 [local-id]
- [witnessed] 南门已关闭。

关羽 [local-id]
- [told] 曹军斥候已在东岸出现。
```

Only committed records matching current accepted Conversation hash may project.

The projection should tell the GM semantically:

> A post-T0 fact in World/GM context is not automatically actor knowledge. Let an actor speak/plan/react from it only when durable provenance below or the current accepted scene supports awareness.

This is **soft model guidance**, not a Narrative output gate. Do not inspect the resulting prose for forbidden/required knowledge keywords, and do not reject/retry the Narrative based on a classifier.

Keep projection bounded from v0.1; a small recent-turn/event/character cap is sufficient. G7 owns long-session retrieval.

## 10. Starting Source semantics

Do not reinterpret Source `disclosure: gm_reference` as actor knowledge.

Do not migrate or rewrite Source packages.

G5-02M1 does not convert all T0 biography/history into explicit knowledge records. It only makes post-T0 knowledge acquisition durable. Existing Source remains GM grounding for authored starting identity/background.

## 11. Required deterministic proofs

Add focused controlled tests covering at least:

### A. Private acquisition asymmetry

```text
Game has Player Character + Guaranteed NPC A
→ accepted Narrative explicitly establishes Player Character discovers private fact F
→ combined semantic response returns knowledge event only for Player Character
→ one durable knowledge record commits
→ later Context shows Player Character knows F
→ NPC A does not
```

### B. Later disclosure to NPC

```text
later accepted Narrative explicitly tells NPC A fact F
→ knowledge event for NPC A commits
→ later Context now shows NPC A has provenance for F
```

### C. Unknown actor rejection

A machine response containing a non-roster `knower_id` cannot create durable knowledge authority.

### D. Knowledge parse failure isolation

```text
valid changes
+ invalid/oversized/malformed knowledge_events
→ valid changes still commit
→ no invalid knowledge record
→ accepted Narrative unaffected
```

### E. Knowledge-only mutation

A turn with no durable world `changes` but a valid post-T0 knowledge acquisition can produce one atomic world mutation containing the knowledge record.

### F. Replay / reopen / hash matching

- same accepted version does not duplicate knowledge;
- Save/reopen preserves knowledge record;
- stale knowledge record whose source GM hash no longer matches current accepted Conversation is excluded from Context.

## 12. Directly affected regression gates

At minimum run:

- existing `tests/g5_01/世界回合语义物化测试.gd`;
- existing `tests/g5_01/世界回合时间线恢复测试.gd`;
- new/updated G5-02 focused tests;
- directly affected G2 Context/Conversation tests if context assembly is touched;
- directly affected G3 Save/Restore tests;
- directly affected G4 continuation tests;
- `git diff --check`.

No real Provider calls until all offline/integration gates are green.

## 13. Real Provider validation — pre-authorized and bounded

Standing authorization applies:

`Vibe-Coding/my world/architecture/foundation/REAL_PROVIDER_VALIDATION_STANDING_AUTHORIZATION.md`

After offline/integration gates are green, perform **at most one** task-owned real selected-Provider attempt using the current approved Runtime Model Settings profile.

Suggested proof uses a task-owned Game with Player Character + one Guaranteed NPC and one short private-information action. Verify safe summaries only:

```text
ordinary Narrative accepted
→ one combined semantic request
→ knowledge event identifies only the supported stable actor(s)
→ durable knowledge provenance commits if valid
→ later Context contains actor-knowledge boundary
```

Do not change Owner persisted model settings solely for the test. No fallback, hidden provider switch or second attempt.

If the selected Provider times out/is unavailable, follow the standing outage rule:

```text
real G5-02 vertical = PENDING / EXTERNAL PROVIDER UNAVAILABLE
→ commit/push reviewable implementation/tests/evidence
→ READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

External availability does not block engineering reviewability.

## 14. Scope ceiling

Expected production scope is bounded around:

- `src/世界回合/**` semantic analysis / durable rules / Context projection;
- existing continuation Context assembly seam only as required to append actor knowledge projection;
- minimal Application composition only if existing world-turn object already owns the required seam.

Protected unless an actual blocker is returned first:

- `src/domain/会话.gd` acceptance semantics;
- `src/ui/**`;
- persistence schema/migrations;
- Source schema/generation;
- Runtime Model Settings;
- Public d20;
- G5-03 NPC/Faction Agency;
- G5-04 Event evolution;
- G6 visuals;
- G7 retrieval platform.

Do not build a generic Entity/Knowledge Graph.

## 15. Evidence

Create:

`docs/g5_02/G5-02M1_KNOWN_ACTOR_KNOWLEDGE_PROVENANCE_EVIDENCE.md`

Record:

- START_HEAD / IMPLEMENTATION_HEAD / FINAL_HEAD;
- exact changed paths;
- durable shape actually implemented;
- actor allowlist proof;
- private acquisition asymmetry proof;
- later disclosure proof;
- unknown actor rejection;
- G5-01 change-parse isolation proof;
- knowledge-only atomic mutation proof;
- Save/reopen/hash-match projection proof;
- regressions;
- `git diff --check` PASS;
- effective selected Provider profile without secrets;
- real Provider result or honest outage-pending state;
- Owner production safety/fingerprint statement if real validation touches task-owned Source/Game infrastructure.

## 16. Completion boundary

Commit and push to `origin/main`.

Return one of:

```text
READY FOR INDEPENDENT REVIEW
```

or, if only the bounded real Provider proof is unavailable:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

Do not declare G5-02 PASS/CLOSED or start G5-03. GPT owns Independent Review and stage transition.
