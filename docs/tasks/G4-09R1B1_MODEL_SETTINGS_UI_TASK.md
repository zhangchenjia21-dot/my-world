# G4-09R1B1 — Model Settings UI / Interaction

Status: **ACTIVE — KIMI**  
Parent: **G4-09R1 Runtime Model Settings v0.1**  
Primary owner: **Kimi**  
Reviewer / semantic owner: **GPT**

Canonical semantic decision:

`Vibe-Coding/my world/architecture/foundation/G4_RUNTIME_MODEL_SETTINGS_V0_1_DECISION.md`

Accepted backend prerequisite:

`docs/g4_09r1/G4-09R1M1C01_INDEPENDENT_REVIEW.md`

Reviewed backend/evidence HEAD:

`6ea825ba0ea0d5a57728c55789f437ff9626b6cb`

## 1. Purpose

Add the player-facing Main Menu model settings surface on top of the accepted runtime-settings / multi-provider mechanism.

Kimi owns presentation and interaction only. Backend capability truth, model ids, endpoints, credential status, validation and persistence remain Program/domain-owned.

The backend now exposes `inspect_candidate(settings)` specifically so UI can preview unsaved compatibility/effective state without duplicating policy or saving first.

## 2. Main Menu entry

Add a visible `模型设置` action to Main Menu.

v0.1 settings are Main-Menu-only. Do not add an in-game settings drawer or settings hotkey. Owner can return to Main Menu, change settings, then Continue the same Game.

## 3. Required controls

Present exactly these logical controls:

```text
模型
上下文上限
思考强度
```

Model display options:

```text
DeepSeek V4 Pro
DeepSeek V4 Flash
Kimi K3
Kimi K2.7
```

Context display options:

```text
256K
1M
```

Reasoning display options:

```text
Low
Medium
High
Max
```

Do not provide arbitrary text fields for model id, base URL or API keys.

## 4. Compatibility UX

UI consumes backend `inspect_candidate()` / validation truth; it must not reproduce a separate hard-coded provider policy.

### Kimi K2.7

- 1M is unavailable/disabled based on backend projection;
- concise explanation: K2.7 currently supports 256K only;
- graded effort control is disabled/unavailable;
- show concise explanation: K2.7 uses fixed Thinking ON and does not expose Low/Medium/High/Max control.

### DeepSeek V4 Pro / Flash and Kimi K3

Low/Medium/High/Max remain selectable.

When Medium is chosen, the effective configuration summary must make clear that the Provider maps it to High. Do not silently present Medium as a distinct effective Provider effort.

### Invalid saved state

If backend reports invalid/corrupt persisted settings, surface a recoverable player-readable state and let the player restore/save a valid selection. Do not silently choose a different model without telling the player.

## 5. Credential status

Show non-secret status for both provider families, for example:

```text
DeepSeek：已配置 / 未配置
Kimi：已配置 / 未配置
```

Never display, bind, log or copy API key values into UI nodes.

No API-key editing in v0.1.

Selecting a model whose provider credential is missing may still be allowed to save if backend contract permits it, but the UI must visibly warn that generation will fail until the credential is configured. Do not invent a fallback provider.

## 6. Save / Cancel behavior

- opening settings loads the current persisted validated selection;
- unsaved edits use backend candidate inspection only;
- Cancel changes nothing;
- Save calls the backend validation/persistence seam;
- invalid combinations cannot be saved;
- success returns to Main Menu and reopening shows the saved values;
- settings survive application restart through backend persistence;
- no Game or Source is rewritten.

## 7. Effective summary

Provide a concise read-only summary derived from backend projection, e.g.:

```text
DeepSeek V4 Pro · 256K · High
Kimi K3 · 1M · Medium（实际 High）
Kimi K2.7 · 256K · 固定思考
```

Do not expose raw internal profile ids unless needed only in tests/debug builds.

## 8. Layout / visual requirements

Keep the existing shell visual language and hierarchy. This is a small settings panel, not a new design system.

Must remain usable at:

```text
1280×720
960×540
maximized desktop
```

No modal should become taller than the viewport; labels/explanations must wrap cleanly.

Keyboard focus/tab order and Escape/Cancel should be sensible. Existing Chinese IME behavior in gameplay input must not regress.

## 9. Interaction boundaries

UI must never:

- construct Provider model ids;
- choose endpoint/base URL;
- construct request-body reasoning/thinking fields;
- read environment secret values;
- calculate context compatibility or requested→effective effort independently of backend projection;
- mutate a running Provider request;
- add automatic provider fallback.

Settings are not part of New Game Composition and do not appear in Source Review.

## 10. Required tests

Add/strengthen UI/integration tests for:

1. Main Menu has 模型设置 and opens/closes correctly;
2. four exact model names visible;
3. save/cancel behavior;
4. reopen/restart reflects backend-persisted selection;
5. K2.7 disables 1M from backend projection;
6. K2.7 fixed-thinking UX from backend projection;
7. Medium effective→High disclosure for DeepSeek/K3 from backend projection;
8. missing DeepSeek/Kimi credential status without secret exposure;
9. invalid combination cannot save;
10. no Game/Source mutation from settings;
11. Continue/New Game remain usable after settings interaction;
12. G4-08B Public d20 UI still behaves correctly when Provider profile is selected by backend;
13. 1280×720 / 960×540 / maximized layout;
14. `git diff --check`.

## 11. Real integration

Backend Independent Review has real successful calls for DeepSeek V4 Pro/Flash and Kimi `k3-256k`, `k3`, and `kimi-for-coding`.

After UI wiring, run real selected-provider product paths through the actual Main Menu settings surface. Since both Provider credentials are now available in the accepted backend evidence, prove at minimum:

- one DeepSeek selection from UI → real generation;
- one Kimi selection from UI → real generation.

Do not expose secrets or substitute another provider/model.

## 12. Return contract

Return only after pushing to `main`:

```text
START_HEAD
IMPLEMENTATION_HEAD
EVIDENCE_HEAD
changed paths
exact settings surface behavior
backend inspect_candidate consumption evidence
compatibility/disabled-state behavior
credential-status behavior
save/cancel/restart evidence
layout evidence
real DeepSeek UI integration result
real Kimi UI integration result
regression summary
READY FOR INDEPENDENT REVIEW
```

Do not resume G4-09UATB or declare G4-09/G4-08 PASS.