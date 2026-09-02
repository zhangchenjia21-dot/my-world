# my world — Repository Agent Rules

Status: current repository instruction
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / Freshness

Resolve authority in this order:

1. Owner current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. current Product / Principles / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. relevant current architecture decisions.
5. this repository `AGENTS.md` and current task packet.
6. verifiable implementation/tests/current HEAD.

Before authoritative work, refresh `main`; never overwrite unknown dirty/newer work.

Execution routing:

```text
GPT        → Meaning / architecture / governance / task shaping / Independent Review
Codex      → backend / mechanism / build-launch implementation
Kimi       → frontend / UI / interaction implementation
Grok Build → search / external research / evidence discovery
Owner      → Product UAT / explicit product verdict
```

## 2. Current state

```text
G1 Foundation                         PASS / CLOSED
G2 AI Conversation Spine              PASS / CLOSED
G3 Persistence / Save / Timeline      PASS / CLOSED
G4-01 Application Shell / Lifecycle   PASS / CLOSED
G4-02R1 Source semantic re-audit      PASS / CLOSED
G4-03 Managed Local Source Library    PASS / CLOSED
G4-04 Multi-Game / Game Library       PASS / CLOSED
G4-05 New Game Wizard                 PASS / CLOSED
G4-06 Atomic Final Create             PASS / CLOSED
G4-07 First Playable A                PASS / CLOSED
G4-08 Expansion Pack v0.1             PASS / CLOSED
G4-08M1 Public d20 Mechanism          PASS / CLOSED
G4-08B Public d20 UI Integration      PASS / CLOSED
G4-09 First Playable B                PASS / CLOSED
G4-09R1 Runtime Model Settings v0.1   PASS / CLOSED
G4-09UATBC01 Narrative Responsiveness PASS / CLOSED
G4-09UATBC02A d20 Protocol Decoupling PASS / CLOSED
G4-09UATBC02B Failure Visibility      PASS / CLOSED AFTER C01
G4-09UATBC02BC01 Persistence Visibility PASS / CLOSED
G4-09UATBC02P1 Final Windows Freshness PASS / CLOSED
G4-09UATB Owner Product UAT           PASS / CLOSED
G4-10 Runtime Asset Resolution        ACTIVE
G4-10S0 Semantic Freeze               PASS / CLOSED — GPT
G4-10M1 Mechanism                     ACTIVE — CODEX
G4-11 Two Primary Asset Families      NOT YET
G4-GATE                               NOT YET
```

Do not start G4-11 before G4-10M1 passes GPT Independent Review. Do not start G5 before G4-GATE.

## 3. Current execution task — G4-10M1

Formal packet:

`docs/tasks/G4-10M1_RUNTIME_ASSET_RESOLUTION_MECHANISM_TASK.md`

Canonical semantic decision:

`Vibe-Coding/my world/architecture/source/G4_RUNTIME_ASSET_RESOLUTION_V0_1_DECISION.md`

Current owner: **CODEX**. Reviewer / semantic owner: **GPT**.

Primary engineering outcome:

```text
exact immutable Source generation
+ declared portrait / scene / map visual
→ safe runtime resolution
→ real Godot image load
```

Required resolution semantics:

```text
RESOLVED
ABSENT
UNAVAILABLE
```

M1 is an engineering reality gate. Return ceiling: **READY FOR INDEPENDENT REVIEW**. It must not claim G4-10/G4-GATE/Product PASS.

## 4. Protected Runtime Asset Resolution truth

- visual bytes remain owned by immutable Managed Source generations;
- old Games resolve from pinned exact Source generation, never Source current;
- World visual identity uses declared `authored_assets[].asset_id`;
- Character portrait remains the existing optional `portrait` contract; do not invent a universal fake asset id;
- optional visual canonical absence is ABSENT, not corruption;
- missing/tampered/unsafe/un-decodable declared visual is UNAVAILABLE;
- presentation may fail-soft to an application-owned neutral placeholder or omitted visual surface;
- placeholder must never become Source/Game authored truth or change generation identity;
- no current-generation/neighbor/other-package/network fallback;
- safe package-local path boundary remains mandatory;
- real Godot load is required; file existence alone is insufficient;
- `map` is an authored image/reference only, not topology/travel/GIS/current-location truth;
- no SQLite schema expansion or second Game-owned visual byte store merely for display;
- no G6 UI redesign is required for M1.

## 5. Protected Model Freedom / Narrative Responsiveness truth

Core principle remains:

```text
Model Freedom First
+
Visible Narrative First
+
Canonical Commit Behind a Turn Finalize Barrier
```

Protected absent concrete regression:

- player-visible GM narrative is free-form natural language;
- Public d20 mechanics control and narrative are separate selected-provider requests;
- malformed isolated control gets at most one bounded recovery attempt, then fail-soft ordinary narrative;
- valid CHECK_REQUIRED freezes Program RNG/outcome durably before result narrative;
- no per-token canonical persistence;
- stable action/check identity and no-reroll remain protected;
- selected Provider only; no cross-provider fallback;
- legitimate hard failures show concise safe player-readable reasons and retain recovery controls.

G4-10 must not reopen or alter these accepted semantics.

## 6. Owner UAT closure / next gate

Formal Owner result:

`docs/g4_09/G4-09UATB_OWNER_PRODUCT_UAT_RESULT.md`

Owner returned `PASS` on 2026-09-02. This closes G4-09UATB, G4-09 First Playable B and G4-08 Expansion Pack v0.1.

Canonical roadmap still requires:

```text
G4-10 Runtime Asset Resolution
→ G4-11 Two Primary Asset Families Reality Test
→ G4-GATE
```

Do not start G5 before G4-GATE.
