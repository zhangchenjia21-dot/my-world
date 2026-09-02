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

Before authoritative work, refresh both `main`s; never overwrite unknown dirty/newer work.

Execution routing:

```text
GPT        → Meaning / architecture / governance / task shaping / Independent Review
Codex      → backend / mechanism / build-launch / validation implementation
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
G4-09 First Playable B                PASS / CLOSED
G4-09UATB Owner Product UAT           PASS / CLOSED
G4-10 Runtime Asset Resolution        DEFERRED / MOVED TO G6
G4-10M1 Mechanism                     SUPERSEDED / DO NOT EXECUTE
G4-11 Two Primary Asset Families      ACTIVE
G4-11P1 Engineering Reality Prep      ACTIVE — CODEX
G4-11UAT Owner Reality Test           NOT YET
G4-GATE                               NOT YET
```

Do not start G5 before G4-11P1 Independent Review + G4-11UAT Owner PASS + G4-GATE.

## 3. Current execution task — G4-11P1

Formal packet:

`docs/tasks/G4-11P1_TWO_FAMILY_REALITY_PREP_TASK.md`

Canonical product-test decision:

`Vibe-Coding/my world/architecture/source/G4_TWO_FAMILY_REALITY_TEST_V0_1_DECISION.md`

Current owner: **CODEX**. Reviewer / semantic owner: **GPT**.

Type: **validation / UAT-support**. No production behavior change is expected.

Fixed families:

```text
A
World:      汉末三国：天下未定
Entry:      208｜赤壁前夕
Player:     刘备
Expansion:  none

B
World:      埃瑟维亚：诸界余辉
Entry:      t0-1287-ovista
Player:     莉维娅·塞兰
Expansion:  none
```

Both real-provider engineering verticals must use the same effective current selected runtime model profile through the canonical shared adapter. Do not change Owner persisted model settings merely for the comparison.

Return ceiling: **READY FOR INDEPENDENT REVIEW**.

If validation exposes a production behavior blocker, stop and return it rather than silently fixing it inside P1.

## 4. Visual deferral — protected current route

Owner explicitly deferred visual runtime work on 2026-09-02.

Canonical decision:

`Vibe-Coding/my world/architecture/source/G4_VISUAL_ASSET_DEFERRAL_TO_G6_DECISION.md`

Therefore:

```text
G4-10M1_RUNTIME_ASSET_RESOLUTION_MECHANISM_TASK.md
= SUPERSEDED / DO NOT EXECUTE
```

Do not implement portrait / scene / authored-map loading, visual resolver infrastructure, image pipeline or map presentation during G4-11.

Protected distinction:

```text
authored visual presentation
!= gameplay semantic authority

map image
!= topology / travel / current location / GIS
```

Visual runtime work will be re-audited in G6 from a real presentation consumer.

## 5. G4-11 protected invariants

- exercise real Source Library / Composition / Final Create / Game Session / Opening / Conversation / Save-Continue seams;
- mutable validation Source/Game roots are task-owned;
- Owner production Source/Games/settings/credentials remain untouched;
- A and B have distinct Game identities and SQLite files;
- switch A→B→A must not leak Session/Conversation/Source identity;
- exact World/Character generation ancestry remains stable after task-owned Source current changes;
- Han model-visible Context must not receive Afterglow Source bytes/identity, and vice versa;
- T0 quarantine remains intact;
- Expansion = none for both family comparison verticals;
- no Provider fallback; selected provider only;
- no G5 NPC/faction/event/knowledge/relationship systems;
- no G6 visual/UI work.

Engineering evidence does not prove product-value differentiation. Owner UAT owns that verdict after GPT Independent Review.

## 6. Protected Model Freedom / Narrative Responsiveness truth

Core principle:

```text
Model Freedom First
+
Visible Narrative First
+
Canonical Commit Behind a Turn Finalize Barrier
```

Do not add:

- model-format gates for narrative;
- mandatory prose structure;
- genre keyword validators;
- post-generation classifiers that block acceptance merely to force the worlds to look different;
- cross-provider fallback;
- per-token canonical persistence.

Public d20 semantics and Runtime Model Settings are already PASS/CLOSED and must not be reopened absent a concrete regression.

## 7. After G4-11P1

If GPT Independent Review passes P1:

```text
G4-11UAT Owner Two-Family Reality Test
ACTIVE — OWNER
```

Owner judges whether the two actual play experiences materially feel like different RPG worlds. Visual polish is not part of that UAT.

Only after Owner PASS may GPT close G4-11, pass G4-GATE, close G4, and shape G5.
