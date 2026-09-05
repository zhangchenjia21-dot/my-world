# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / freshness

Authority order:

1. Owner current explicit instruction.
2. `Vibe-Coding/AGENTS.md`.
3. current Product / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. current architecture decisions.
5. this `AGENTS.md` + current Task Packet / Independent Review evidence.
6. verifiable implementation/tests/current HEAD.

Refresh both `main`s before authoritative work. Never overwrite unknown dirty/newer work.

Repository remotes: `github.com/zhangchenjia21-dot/my-world` and `github.com/zhangchenjia21-dot/Vibe-Coding`.

Long-term routing:

```text
GPT        → meaning / architecture / governance / task shaping / Independent Review
Codex      → backend / mechanism / build-launch / validation implementation
Kimi       → frontend / UI / interaction implementation
Grok Build → search / external research / evidence discovery
Owner      → Product UAT / explicit product verdict
```

Temporary through 2026-09-06 23:59 (+08:00): Kimi normally owns all code-changing implementation tasks; GPT remains semantic owner/reviewer. For **MW-004 only**, Owner explicitly delegated the tiny bounded prompt edit directly to GPT. This does not change general routing, and GPT must not issue an Independent Review verdict on its own implementation.

Gemini review remains CANCELLED / DO NOT EXECUTE.

## 2. Current state

```text
G1-G4                                        PASS / CLOSED
G5-01 World Turn / Semantic Materialization PASS / CLOSED
G5-02 Knowledge Provenance                  PASS / CLOSED
G5-03 NPC / Faction Agency                  ENGINEERING PASS / CLOSED
MW-001 Runtime Narrative Actor Materialization PASS / CLOSED
G5-04 Event / Priority Evolution            ACTIVE — OWNER UAT PAUSED FOR MW-004 CHECK
MW-002 Selective World Evolution Evaluator ENGINEERING PASS / CLOSED
MW-003 Visual Comfort Theme Pass            ENGINEERING PASS — OWNER UAT
MW-004 Minimal Player Agency Principle      IMPLEMENTED — OWNER UAT
G5-GATE                                     NOT YET
```

MW-003 remains a separate early G6 visual-polish slice. Owner has reported the build looks much better; its explicit Product PASS is still not silently inferred.

MW-004 is a distinct Owner-inserted cross-cutting product-semantics outcome anchored to G2 AI Conversation Spine. It does not reopen G2, alter G5-04 architecture, or authorize G5-05.

Current executable packet:

`docs/tasks/MW-004_MINIMAL_PLAYER_AGENCY_PRINCIPLE_TASK.md`

## 3. Current Work Item identity

```text
Work Item: MW-004
Name: Minimal Player Agency Principle
Capability-Anchor: G2 AI Conversation Spine
Inserted-By: Owner
Triggered-By: G5-04 Owner UAT observation of GM making an unexpressed scene-exit choice for the protagonist
Revision: 1
Implementation Base: b9ea5cb3ebe9e91c9c2ab1f4a93daf30b440767d
Implementer: GPT — explicit Owner delegation
Independent Reviewer: not self-assigned
Status: IMPLEMENTED — OWNER UAT
```

This is a new independent Outcome, so it uses a new flat Work Item ID under `Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md`.

## 4. MW-004 protected semantics

Minimal canonical boundary for this Work Item:

> **The GM owns freedom to advance the world; the Player owns new meaningful choices for the protagonist.**

The shared GM instructions may say only what is necessary to preserve this authority boundary:

- GM may freely advance world, NPCs, scenes, consequences of already expressed Player action, and connective behavior that is not itself a meaningful choice;
- if narration would create a new meaningful protagonist choice that the Player did not express and current intent does not clearly imply, leave that choice to the Player;
- `Light` does not expand GM authority to make meaningful protagonist choices; it only permits natural completion of non-decisional detail.

Do **not** broaden this into:

- parser/classifier enforcement;
- Narrative rejection/finalize barrier;
- retry loop;
- keyword blacklist;
- mandatory questions / stop points;
- fixed response format;
- Full/Narrative redesign;
- control-mode platform work.

Model Freedom First remains protected. Narrative still accepts any non-empty GM response under the existing Conversation rules.

Focused test:

`tests/mw004/最小玩家主权原则测试.gd`

GPT's current environment has no Godot runtime; do not claim this test was executed by GPT.

## 5. Owner MW-004 UAT

Owner should continue through the real `run-game.cmd` path and observe a scene with an obvious still-open protagonist choice.

PASS means:

- prose remains natural and unconstrained;
- GM freely advances NPC/world/scene response;
- small connective protagonist behavior is still natural;
- GM does not invent a new meaningful choice such as leaving, agreeing, refusing, revealing, committing or abandoning without Player expression/clear implication;
- GM does not become timid or repeatedly ask permission.

If behavior is satisfactory, resume the existing G5-04 Owner UAT immediately. Do not expand MW-004 without new concrete evidence.

## 6. Protected G5-04 state

G5-04 remains ACTIVE and MW-002 remains ENGINEERING PASS / CLOSED. MW-004 is a brief UAT interruption only.

Frozen product rule remains:

> **The world can move without the Player causing every change, without forcing an event every turn.**

G5-04 Owner UAT still needs both:

1. Quiet / Life Loop — genuine `hold`, no artificial escalation;
2. Genuine ripe pressure — one credible independent world consequence that remains durable and later surfaces naturally.

Do not start G5-05 before Owner closes G5-04.
