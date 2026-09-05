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

Temporary through 2026-09-06 23:59 (+08:00): Kimi owns all code-changing implementation tasks; GPT remains semantic owner/reviewer. Correct in-flight Kimi work may finish after expiry.

Gemini review remains CANCELLED / DO NOT EXECUTE.

## 2. Current state

```text
G1-G4                                        PASS / CLOSED
G5-01 World Turn / Semantic Materialization PASS / CLOSED
G5-02 Knowledge Provenance                  PASS / CLOSED
G5-03 NPC / Faction Agency                  ENGINEERING PASS / CLOSED
MW-001 Runtime Narrative Actor Materialization PASS / CLOSED
G5-04 Event / Priority Evolution            ACTIVE — OWNER UAT PAUSED
MW-002 Selective World Evolution Evaluator ENGINEERING PASS / CLOSED
MW-003 Visual Comfort Theme Pass            ENGINEERING PASS — OWNER UAT
G5-GATE                                     NOT YET
```

`MW-003` is an Owner-inserted **early G6 visual-polish slice**. It does not advance the project stage to G6, does not reopen MW-002, and does not authorize G5-05.

Current executable packet:

`docs/tasks/MW-003_VISUAL_COMFORT_THEME_PASS_TASK.md`

Independent Review:

`docs/mw003/MW-003_INDEPENDENT_REVIEW_IR1.md` — ENGINEERING PASS / OWNER UAT

After Owner explicit Product PASS on MW-003, resume G5-04 Owner UAT exactly where it was.

## 3. Current Work Item identity

```text
Work Item: MW-003
Name: Visual Comfort Theme Pass
Capability-Anchor: G6 RPG Experience & Internal Declarative UI Host
Inserted-By: Owner
Blocks: resume of G5-04 Owner UAT
Revision: 1
Review-Round: IR#1
Implementation Base: 42006215838c07910ab8b948cac628a4f43dde4e
Implementation: eb13d559092e288506ce280ea01e9ef3c8a62290
Evidence: 561ff0d5ff80ad1224c55d6f7768474da242ebd0
Owner: Owner product verdict
Reviewer: GPT
Status: ENGINEERING PASS — OWNER UAT
```

This is a distinct Owner-inserted Outcome, so it uses a new flat Work Item ID under `Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md`.

## 4. MW-003 engineering result

IR#1 confirms:

- one central semantic palette owns canvas/base/input/raised surfaces, text hierarchy and semantic accent/success/warning/danger colors;
- root Theme assembly covers panels, labels, buttons, inputs, popup menus, focus/selection, separators and scrollbars;
- runtime-created Narrative/mechanic/status controls consume the same palette;
- Main Menu, Settings, Wizard and in-game surfaces are visually covered;
- no layout/typography redesign or G6 theme-settings platform was introduced;
- no G5 gameplay/runtime, Provider, persistence, Timeline, Agency, World Evolution or Public-d20 mechanism change was introduced.

Committed evidence reports focused real-render **30 PASS / 0 FAIL**, directly affected UI regressions green, export freshness PASS, `git diff --check` clean, real Provider calls 0.

No Revision 2 is required absent a concrete new visual defect.

## 5. MW-003 Product UAT

Owner is the final judge of eye comfort. The existing positive observation that the build "looks much better" is meaningful UAT evidence but is not silently converted into Product PASS.

Only continue tuning if a concrete issue remains, such as:

- sustained-reading discomfort after 10–20 minutes;
- muted/disabled text unreadable in a real state;
- focus/hover/selection ambiguity;
- warning/error colors still too harsh or too weak;
- a major reachable surface visibly breaks palette coherence.

Otherwise stop visual iteration and close MW-003 via explicit Owner Product PASS.

## 6. Protected G5-04 state

G5-04 remains ACTIVE and MW-002 remains ENGINEERING PASS / CLOSED. The UAT interruption is scheduling only.

Frozen product rule remains:

> **The world can move without the Player causing every change, without forcing an event every turn.**

Do not modify G5-04 architecture or implementation as part of MW-003.

After MW-003 closes, G5-04 Owner UAT still needs both:

1. Quiet / Life Loop — genuine `hold`, no artificial escalation;
2. Genuine ripe pressure — one credible independent world consequence that remains durable and later surfaces naturally.

Do not start G5-05 before Owner later closes G5-04.
