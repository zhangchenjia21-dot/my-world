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
G4-11P1 Engineering Reality Prep      PASS / CLOSED
G4-11UAT Owner Reality Test           ACTIVE — OWNER
G4-GATE                               NOT YET
```

Do not start G5 before G4-11UAT Owner PASS + G4-GATE. Do not start a new implementation task while this Owner product gate is active unless the Owner reports a concrete blocker.

## 3. Current task — G4-11UAT Owner Reality Test

Formal Owner packet:

`docs/tasks/G4-11UAT_OWNER_TWO_FAMILY_REALITY_TASK.md`

P1 Independent Review:

`docs/g4_11/G4-11P1_INDEPENDENT_REVIEW.md`

Current owner: **OWNER**. GPT owns interpretation / closeout.

Fixed comparison:

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

Owner judges whether ordinary play materially feels like two different Source-grounded RPG realities rather than one generic AI chat with swapped names.

Visual polish is explicitly not part of this UAT.

## 4. G4-11P1 accepted engineering truth

P1 passed GPT Independent Review at implementation evidence head:

`8a8426b17906f06582ea6503aa7854eaa0ed04de`

Accepted evidence:

- no production code change; only task-owned test harness / wrapper / evidence;
- both families used real current selected Provider through the shared production path;
- effective profile was `kimi_k3 / kimi / k3-256k / 256k / high` for both verticals;
- each family completed real Opening + 3 durable continuations;
- each family completed named Save → close → exact Game Library reopen / Continue;
- A/B Game IDs and SQLite files are distinct;
- same Host completed `A → B → A → B → A` without Game/Conversation identity crossover;
- assembled requests contained exact selected family/T0 markers and excluded opposite-family/new-current markers;
- bounded task-owned newer Source generations did not mutate already-created Game ancestry/materialized truth;
- Owner production Source/Games/settings/current DB fingerprints were unchanged;
- no output-side genre keyword validator, mandatory prose format, classifier or scripted beat was introduced;
- no visual runtime or G5 semantics were implemented.

P1 Engineering PASS does not itself prove product-value differentiation.

## 5. Visual deferral — protected current route

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

## 7. Owner verdict routing

If Owner returns `PASS`:

```text
G4-11UAT PASS / CLOSED
→ G4-11 PASS / CLOSED
→ G4-GATE PASS
→ G4 CLOSED
→ GPT refreshes roadmap and shapes G5
```

If Owner returns `FAIL`, capture the concrete Source / Context / Game symptom and correct only that seam. Do not reintroduce visual work or model-output gates as a substitute for world differentiation.
