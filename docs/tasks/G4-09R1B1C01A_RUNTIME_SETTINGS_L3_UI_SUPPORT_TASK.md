# G4-09R1B1C01A — Runtime Settings L3 UI Support

Status: **ACTIVE — CODEX**  
Parent: **G4-09R1B1 Settings UI correction-01**  
Owner: **Codex**  
Reviewer / semantic owner: **GPT**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Reviewed UI/evidence HEAD: `fcdcec66edad41afbb93f4a5e9cc70174402be5c`  
Independent Review: `docs/g4_09r1/G4-09R1B1_INDEPENDENT_REVIEW.md`

## Outcome

Add the smallest Runtime Settings L3 support needed for the Settings UI to remain layer-correct and capability-consistent. Do not change the final UI in this task.

## Required backend seam

### 1. Validated editable default

Expose a public non-mutating L3 method, name may vary, conceptually:

```text
validated_default_settings()
→ exact validated application default
```

Required exact default remains:

```text
deepseek_v4_pro / 256k / high
```

It must return a defensive copy, write no settings file, expose no credential values, and mutate no Game/Source/SQLite state.

### 2. Partial capability truth on incompatible candidate

Current `inspect_candidate(settings)` returns a failure before UI can recover model capability truth for `kimi_k27 + 1m`.

Extend the L3-facing result so a **known profile with an incompatible context** still returns a safe partial candidate/capability projection while preserving:

```text
success = false
status = incompatible_context_limit
```

The partial projection must be sufficient for UI to render, without provider-policy duplication:

```text
profile_id
display_name
provider_id
requested context_limit
allowed_context_limits
reasoning_requested
reasoning_effective      # null for fixed-thinking model
graded_reasoning
fixed_thinking
selected-provider credential_configured bool
```

No endpoint, model id, request path, request payload field, or secret value may enter this UI-safe projection.

Unknown profile / malformed settings may remain failure without partial projection when capability identity cannot be established safely.

## Acceptance examples

Directly prove:

```text
validated_default_settings()
→ deepseek_v4_pro / 256k / high
→ no write side effect

inspect_candidate(kimi_k27 / 1m / high)
→ success=false
→ status=incompatible_context_limit
→ candidate.allowed_context_limits=[256k]
→ candidate.fixed_thinking=true
→ candidate.graded_reasoning=false
→ candidate.reasoning_effective=null
→ no transport/secret fields
```

Existing valid cases must remain unchanged:

- DeepSeek/K3 Medium → effective High;
- K2.7 / 256K valid fixed-thinking;
- selected-provider credential bool only;
- no cross-provider fallback.

## Scope

Expected changes only under:

```text
src/运行时设置/**
tests/g4_09r1/** or task-owned correction tests
docs/g4_09r1/** evidence
```

Do **not** change:

```text
src/main.tscn
src/应用壳.gd
src/provider/**
src/source/**
src/最终建局/**
src/persistence/**
src/行动判定/**
```

SQLite schema remains v4. Provider wire/model identities are already PASS and must not be reopened.

## Required validation

At minimum:

- focused Runtime Settings mechanism tests including the two new seams;
- existing G4-09R1M1 mechanism suite green;
- no settings/Game/Source write from default/candidate inspection;
- secret/transport-field absence assertions;
- `git diff --check`.

Real DeepSeek/Kimi calls are **not required** unless Provider/request code is changed. If Provider code changes unexpectedly, stop and report why.

## Return contract

Return:

```text
START_HEAD
IMPLEMENTATION_HEAD
EVIDENCE_HEAD
changed paths
exact L3 default API shape
exact incompatible-candidate projection shape
no-write / no-secret proof
regression summary
SQLite schema unchanged
READY FOR INDEPENDENT REVIEW
```

Do not implement the UI correction and do not resume Owner UAT.