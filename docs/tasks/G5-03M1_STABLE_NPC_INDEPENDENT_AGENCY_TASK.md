# TASK｜G5-03M1｜Stable Guaranteed-NPC Independent Agency Vertical

Status: **SUPERSEDED / DO NOT EXECUTE**  
Superseded by: `docs/tasks/G5-03M1_MULTI_ACTOR_AGENCY_CYCLE_TASK.md`  
Reason: Owner explicitly rejected the one-NPC-per-turn / round-robin scheduling constraint.

Do not implement this packet from its historical Git version.

Current canonical decision:

`Vibe-Coding/my world/architecture/world/G5_MULTI_ACTOR_AGENCY_CYCLE_V0_2_DECISION.md`

Current design:

```text
accepted turn
→ one Agency Selection phase
→ 0..N selected stable actors
→ separate actor-scoped executions
→ several NPCs may act during the same Agency Cycle
```

All useful v0.1 principles that remain valid (actor-scoped knowledge, foreground freedom, fail-soft background work, timeline safety, no hidden mechanics) are inherited by the v0.2 decision and replacement task.
