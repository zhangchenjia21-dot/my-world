# G4-09R1M1 — Runtime Model Settings / Multi-Provider Mechanism

Status: **ACTIVE — CODEX**  
Parent: **G4-09R1 Runtime Model Settings v0.1**  
Primary owner: **Codex**  
Reviewer / semantic owner: **GPT**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Formal Code Base:

`0692b51efde05fad3e7ead2d52ba26507e0d3f92`

Canonical semantic decision:

`Vibe-Coding/my world/architecture/foundation/G4_RUNTIME_MODEL_SETTINGS_V0_1_DECISION.md`

## 1. Purpose

Replace the current DeepSeek-only runtime seam with the smallest closed multi-provider mechanism needed for Owner-selected model/runtime settings before G4-09UATB resumes.

This task owns backend/mechanism only. Do not implement the final Main Menu settings UX beyond minimal test seams required to prove the contract.

## 2. Exact frozen catalog

Support only these profiles:

```text
deepseek_v4_pro   → DeepSeek V4 Pro   → deepseek-v4-pro
deepseek_v4_flash → DeepSeek V4 Flash → deepseek-v4-flash
kimi_k3           → Kimi K3            → k3-256k at 256K / k3 at 1M
kimi_k27          → Kimi K2.7          → kimi-for-coding
```

Fixed endpoints:

```text
DeepSeek https://api.deepseek.com/chat/completions
Kimi     https://api.kimi.com/coding/v1/chat/completions
```

Do not add arbitrary custom model ids, custom base URLs, model discovery, fallback routing, plugin registries, or per-Game provider pinning.

## 3. Runtime settings domain

Create one Program-owned application settings seam with validated fields conceptually equivalent to:

```text
profile_id
context_limit = 256k | 1m
reasoning_request = low | medium | high | max
```

Persistence is application-local, outside Game DB and Source. Use a small durable settings record under `user://my-world/settings/` or equivalent.

Required:

- missing file → validated default `deepseek_v4_pro / 256k / high`;
- atomic/fail-safe write;
- restart persistence;
- no unknown values reach Provider;
- invalid combinations fail visibly/return structured validation failure;
- settings changes never mutate existing Games/Source/SQLite;
- expose non-secret credential availability for UI (`configured: bool`) without exposing values.

Do not change SQLite schema v4.

## 4. Compatibility validation

Freeze:

### Context

```text
DeepSeek V4 Pro     256K / 1M
DeepSeek V4 Flash   256K / 1M
Kimi K3             256K / 1M
Kimi K2.7           256K only
```

For K3:

```text
256K → k3-256k
1M   → k3
```

The context choice is application runtime ceiling/capability metadata. Pass it through the request/context seam so Context Assembly can respect the selected ceiling, but do not redesign G2-05 into G7. Existing conservative recent-turn behavior may use less than the ceiling.

### Reasoning

DeepSeek V4 Pro/Flash and Kimi K3:

```text
low    → provider low
medium → provider high
high   → provider high
max    → provider max
```

Kimi K2.7:

- fixed Thinking ON;
- graded reasoning is unsupported;
- Program exposes this capability truth to UI;
- do not send a fake effort value and do not route to another model.

## 5. Provider mechanism

Current `src/provider/deepseek流式适配器.gd` is explicitly DeepSeek-only. Refactor/generalize only as much as necessary to support the frozen two-provider catalog.

A thin OpenAI-compatible streaming adapter/factory is expected. Preserve the externally important lifecycle:

```text
start stream
busy protection
cancel
text delta
completed / cancelled / failed exactly once
```

Provider-specific request material is Program-derived from the validated profile.

Required security:

```text
DEEPSEEK_API_KEY
KIMI_API_KEY
```

- selected DeepSeek profile reads only DeepSeek key;
- selected Kimi profile reads only Kimi key;
- missing selected key sends no network request;
- no key value enters log/error/settings/Game;
- no automatic fallback to the other Provider.

Update `.env.example` and canonical `run-game.ps1` secret allowlist as needed. The product must still launch to Main Menu without forcing one specific provider key at launcher startup; missing credential is handled when the selected Provider is actually needed.

Do not create another launcher.

## 6. Request payload / stream parsing

Implement provider-specific request body fields according to the frozen semantics and current official API behavior.

At minimum verify:

- exact model id;
- streaming enabled;
- reasoning mapping;
- thinking remains enabled for the models that require it;
- K2.7 remains K2.7 and Thinking ON;
- Provider reasoning/thinking chunks are not emitted as player-visible GM `text_delta` and are not persisted as narrative;
- normal content streaming remains compatible with existing Conversation/Openings/Public d20 consumers.

Do not expose chain-of-thought.

## 7. One routing seam for every model call

Eliminate hidden hard-coded DeepSeek selection from all real product Provider call sites.

Prove the current validated runtime profile is consumed by:

1. First Opening;
2. ordinary Narrative continuation;
3. Public d20 adjudication phase;
4. Public d20 resolution narrative phase;
5. retry/reopen Provider calls.

A profile is snapshotted for one active Provider request and cannot change mid-stream.

No Provider selection belongs to Source or Game canonical state.

## 8. Context boundary

Do not pull G7 forward.

Allowed:

- expose selected context ceiling to Context Assembly/request planning;
- add a conservative request-size guard or budget metadata if needed;
- deterministic validation that K2.7 cannot request 1M.

Forbidden:

- summarization architecture;
- vector retrieval;
- memory compression;
- universal tokenizer subsystem;
- new long-session truth model;
- changing durable Conversation semantics solely to fill 1M.

## 9. Required automated evidence

Add focused tests for:

### A — settings persistence

- default;
- save/reopen exact values;
- malformed/unknown profile fail-safe;
- invalid K2.7 + 1M rejected;
- no Game DB mutation.

### B — exact profile derivation

Assert exact endpoint/model id for every valid profile/context combination.

### C — reasoning capability

- DeepSeek/K3 medium normalizes to high;
- low/high/max exact mappings;
- K2.7 reports fixed-thinking and sends no unsupported graded field.

### D — credential routing

- missing selected key → zero network;
- DeepSeek request never reads/uses Kimi key;
- Kimi request never reads/uses DeepSeek key;
- secret values absent from errors/loggable result objects.

### E — lifecycle / parsing

Preserve existing stream cancellation, malformed stream, HTTP error, exactly-one terminal, TTFT instrumentation and content delta behavior for both provider configurations.

### F — call-site routing

Use stubs/recording adapters to prove Opening, ordinary continuation, d20 adjudication and d20 resolution narrative all obtain the same selected runtime profile seam rather than a hard-coded DeepSeek model.

### G — regressions

Keep green at minimum:

- G2 Provider / Conversation / Context focused suites;
- G4-07A Opening;
- G4-07B Narrative UI backend-facing seam;
- G4-08M1/M1C01;
- G4-08B/BC01;
- no-Expansion route;
- `git diff --check`.

## 10. Real Provider evidence

Because this task adds a real second Provider, stub evidence alone is insufficient for final M1 PASS.

Run small real requests using local credentials where available:

- at least one DeepSeek V4 profile;
- at least one Kimi profile;
- preferably all four model selections with small prompts, without manufacturing huge 256K/1M payloads.

Record exact selected model id and successful content completion, never keys.

If `KIMI_API_KEY` or account/model entitlement is unavailable, do **not** fake a Kimi PASS. Return the implementation/test status plus a clear credential/entitlement blocker. GPT will decide whether the mechanism can be provisionally accepted or whether Owner credential setup is required before UI/UAT progression.

## 11. Protected boundaries

Do not redesign:

- Source schema/Managed Library;
- Composition/Final Create;
- Game/Timeline persistence schema;
- Public d20 semantics/RNG/action identity;
- Wizard/Narrative UI product design;
- G7 long-session architecture;
- G8 mod/provider plugin architecture.

Do not change G4-09UATB to PASS.

## 12. Return contract

After pushing to `main`, return:

```text
START_HEAD
IMPLEMENTATION_HEAD
EVIDENCE_HEAD
changed paths
settings persistence path/schema/default
exact profile catalog and valid matrix
exact provider endpoint/model derivation
reasoning requested→effective mapping
K2.7 fixed-thinking behavior
credential routing / launcher behavior
Opening/Narrative/d20 routing evidence
real DeepSeek result
real Kimi result or explicit credential/entitlement blocker
regression summary
SQLite schema unchanged
READY FOR INDEPENDENT REVIEW
```

Do not start G4-09R1B1. Kimi UI remains HOLD until GPT Independent Review passes M1.