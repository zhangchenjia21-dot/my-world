# G4-09R1B1C01A — Runtime Settings L3 UI Support

Status: **PASS / CLOSED**  
Parent: **G4-09R1B1 Settings UI correction-01**  
Owner: **Codex**  
Reviewer / semantic owner: **GPT**

Reviewed UI/evidence HEAD: `fcdcec66edad41afbb93f4a5e9cc70174402be5c`  
Accepted implementation/evidence HEAD: `bb3c16b392887a4649f32e23348067c70a3e7a1c`  
Independent Review: `docs/g4_09r1/G4-09R1B1C01A_INDEPENDENT_REVIEW.md`

## Outcome

Add the smallest Runtime Settings L3 support needed for the Settings UI to remain layer-correct and capability-consistent. Do not change the final UI in this task.

## Required backend seam

### 1. Validated editable default

Expose a public non-mutating L3 method:

```text
validated_default_settings()
→ exact validated application default
```

Required exact default:

```text
deepseek_v4_pro / 256k / high
```

It returns a defensive copy, writes no settings file, exposes no credential values, and mutates no Game/Source/SQLite state.

### 2. Partial capability truth on incompatible candidate

For a known profile with an incompatible context, L3 preserves:

```text
success = false
status = incompatible_context_limit
```

while returning safe partial candidate/capability truth sufficient for UI:

```text
profile_id
display_name
provider_id
requested context_limit
allowed_context_limits
reasoning_requested
reasoning_effective
graded_reasoning
fixed_thinking
selected-provider credential_configured bool
```

No endpoint, model id, request path, request payload field, or secret value enters this UI-safe projection. Unknown profile / malformed settings fail without partial identity.

## Accepted proof

```text
validated_default_settings()
→ deepseek_v4_pro / 256k / high
→ defensive copy
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

Existing valid cases remain unchanged:

- DeepSeek/K3 Medium → effective High;
- K2.7 / 256K valid fixed-thinking;
- selected-provider credential bool only;
- no cross-provider fallback.

## Protected scope

C01A changed only Runtime Settings rules/process/public interface plus focused tests/evidence. It did not change:

```text
src/main.tscn
src/应用壳.gd
src/provider/**
src/source/**
src/最终建局/**
src/persistence/**
src/行动判定/**
```

SQLite schema remains v4. Provider wire/model identities remain accepted.

## Closeout

Focused Runtime Settings mechanism tests, B1 UI regression, no-write/no-secret assertions and `git diff --check` are accepted. Real DeepSeek/Kimi calls were not required because Provider/request code was unchanged.

Next task:

`docs/tasks/G4-09R1B1C01B_UI_STATE_CONSISTENCY_CORRECTION_TASK.md` — **ACTIVE — KIMI**.
