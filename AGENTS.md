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
MW-003 Visual Comfort Theme Pass            ACTIVE — KIMI
G5-GATE                                     NOT YET
```

`MW-003` is an Owner-inserted **early G6 visual-polish slice**. It does not advance the project stage to G6, does not reopen MW-002, and does not authorize G5-05.

Current executable packet:

`docs/tasks/MW-003_VISUAL_COMFORT_THEME_PASS_TASK.md`

After MW-003 Engineering Review + Owner Product PASS, resume G5-04 Owner UAT exactly where it was.

## 3. Current Work Item identity

```text
Work Item: MW-003
Name: Visual Comfort Theme Pass
Capability-Anchor: G6 RPG Experience & Internal Declarative UI Host
Inserted-By: Owner
Blocks: resume of G5-04 Owner UAT
Revision: 1
Review-Round: 0
Base: 895adb1576e9dd7501a2d07740accc1b05e9a50a
Owner: Kimi
Reviewer: GPT
Status: ACTIVE — KIMI
Return ceiling: READY FOR INDEPENDENT REVIEW
```

This is a distinct Owner-inserted Outcome, so it uses a new flat Work Item ID under `Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md`.

## 4. MW-003 product goal

Owner reported that the current dark palette is visually harsh enough to cause eye strain.

Target experience:

> **Low glare, clear hierarchy, readable narrative, calm surfaces, restrained semantic color.**

The pass must improve sustained reading comfort across Main Menu, Settings/Wizard, the in-game three-column shell, Narrative/composer, controls, Save/Restore states and semantic status/error surfaces.

Narrative remains the visual center of gravity.

## 5. MW-003 implementation boundary

Prefer a small Godot-native central palette/theme ownership seam rather than adding more scattered hard-coded colors.

Protect:

- existing layouts and navigation;
- typography family/hierarchy;
- Main Menu / Settings / New Game / First Opening;
- Narrative send/cancel/regenerate;
- Public d20;
- Save/Load/Restore;
- all G5 semantic/runtime behavior;
- persistence schema.

Explicit non-scope:

- light mode;
- user-selectable themes/accent preferences;
- large design-system platform;
- responsive-layout architecture;
- new visual asset pipeline/images/icons;
- new RPG surfaces;
- G5-04/G5-05 behavior changes;
- Provider/Timeline/Agency/World Evolution changes.

Minor surface/border/hover/focus/pressed/disabled styling required for palette coherence is allowed.

## 6. Preferred visual direction

Starting palette from the Task Packet:

```text
canvas/background      #1B1E24
surface/base           #22262D
surface/raised         #292E36
surface/input          #252A31
border/subtle          #343A44
text/primary           #D8DCE3
text/secondary         #A7AFBA
text/muted             #7F8996
accent                 #8FA9C4
success                #88AD96
warning                #C0A06B
danger                 #C57D78
```

Small tuning is allowed; relative hierarchy is authoritative. Avoid pure/near-black large surfaces, maximum-bright body text, neon accents and large saturated red/orange regions.

## 7. Review route

```text
MW-003 implementation — Kimi
→ GPT actual-code Independent Review
→ if Engineering PASS: Owner visual-comfort UAT via run-game.cmd
→ Owner Product PASS closes MW-003
→ resume G5-04 Owner UAT
```

Kimi must not self-certify Engineering PASS or Product PASS.

## 8. Protected G5-04 state

G5-04 remains ACTIVE and MW-002 remains ENGINEERING PASS / CLOSED. The UAT interruption is scheduling only.

Frozen product rule remains:

> **The world can move without the Player causing every change, without forcing an event every turn.**

Do not modify G5-04 architecture or implementation as part of MW-003.

G5-04 Owner UAT still needs both:

1. Quiet / Life Loop — genuine `hold`, no artificial escalation;
2. Genuine ripe pressure — one credible independent world consequence that remains durable and later surfaces naturally.

Do not start G5-05 before Owner later closes G5-04.