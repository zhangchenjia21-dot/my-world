# TASK｜G5-03M1C02｜Semantic-vs-Agency Currentness Separation

Status: **SUPERSEDED / DO NOT EXECUTE**  
Superseded by: `G5-03M1R01_AGENCY_SCHEDULER_V0_3_SIMPLIFICATION_REDESIGN_TASK.md`  
Reason: the same semantic/Agency-currentness seam required a second correction. Per correction budget, the project chose redesign rather than another patch.

Historical intent only:

- separate semantic source-version validity from Agency handoff validity;
- preserve older accepted G5-01/G5-02 truth while suppressing stale Agency.

The current canonical solution no longer carries Agency Selection in the semantic-analysis result. See:

`Vibe-Coding/my world/architecture/world/G5_AGENCY_SCHEDULER_V0_3_DECISION.md`

Do not implement this packet. Do not partially merge its proposed predicate split into production unless the current v0.3 redesign packet explicitly requires the same semantic behavior.
