# TASK｜G4-10M1｜Runtime Asset Resolution Mechanism

Status: **SUPERSEDED / DO NOT EXECUTE**  
Former Owner: **CODEX**  
Superseded: **2026-09-02 by Owner roadmap decision**

## Stop notice

Do not implement this task.

The Owner explicitly decided that portrait / scene / authored-map runtime integration is not part of the current core experience and should be deferred until G6, when real RPG presentation consumers exist.

Canonical current decision:

`Vibe-Coding/my world/architecture/source/G4_VISUAL_ASSET_DEFERRAL_TO_G6_DECISION.md`

Canonical roadmap v3.3 now routes:

```text
G4-09 PASS
→ G4-11 Two Primary Asset Families Reality Test
→ G4-GATE
→ G5
```

Runtime visual asset resolution is no longer a G4-GATE prerequisite.

## Preserved non-execution notes

No code from this packet should be implemented merely because its old engineering design was valid. Future G6 work must re-audit the actual visual consumer before freezing a mechanism.

The following conceptual distinctions remain protected:

```text
authored visual presentation
!= gameplay semantic authority

map image
!= topology / travel / current location / GIS
```

If an Agent has already started local work for this packet but has not pushed it, stop and report the work rather than merging it into `main`.
