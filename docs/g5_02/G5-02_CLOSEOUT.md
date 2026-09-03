# G5-02 Knowledge Provenance Closeout

Status: **PASS / CLOSED**  
Date: 2026-09-03

## Accepted chain

```text
G5-02M1 Known-Actor Knowledge Provenance Spine
→ initial implementation `492815aefd127c20bd17fbda892aad8d41279dcb`
→ GPT Independent Review correction finding
→ G5-02M1C01 Actor Roster + Recent Knowledge Projection
→ correction `4de236907934830404b805642e5d407887abd5be`
→ GPT final Independent Review PASS
```

Formal final review:

`docs/g5_02/G5-02M1C01_INDEPENDENT_REVIEW.md`

## Accepted semantics

```text
Game / World Truth
!= actor knowledge
!= human-player disclosure
!= omniscient GM model context
```

v0.1 makes post-T0 knowledge acquisition durable only for stable Game-local Player Character / Guaranteed NPC IDs.

The existing one-per-turn semantic-analysis request may return bounded `knowledge_events` adjacent to G5-01 `changes`; bad knowledge data fails soft and does not invalidate valid world changes or accepted Narrative.

Knowledge provenance lives inside the existing game-local `living_world` snapshot and reuses the existing atomic world-mutation/Timeline owner. No SQLite schema/table or second persistence owner was added.

Later GM Context receives a bounded, current-hash-matching `Actor Knowledge Provenance` projection. This is soft semantic guidance; no Narrative keyword/classifier/retry gate exists.

## Historical real-provider gap

The task's single bounded real selected-Provider attempt timed out during ordinary Narrative before the semantic lane executed.

Therefore:

```text
G5-02 real selected-Provider feature vertical
PENDING / HISTORICAL EXTERNAL PROVIDER GAP
```

This is not rewritten as PASS. It also does not block G5-02 closeout because the first materially player-visible consumer is G5-03 actor agency, where knowledge isolation will be exercised directly.

## Deferred

Not implemented in G5-02:

- false belief / lies / confidence;
- rumor propagation;
- inference closure;
- Faction/shared knowledge;
- emergent/incidental NPC identity;
- separate human-player knowledge UI;
- G7 retrieval platform.

## Next

`G5-03 NPC / Faction Agency` becomes active, beginning with one real consumer: a stable Guaranteed NPC acting from its own Source + durable Knowledge Provenance rather than GM omniscience.
