# TASK｜MW-008｜Safe Markdown-Lite Narrative Rendering

Type: implementation / UI presentation / rendering correctness  
Work Item: **MW-008**  
Name: **Safe Markdown-Lite Narrative Rendering**  
Capability-Anchor: **G2 Narrative Conversation View / presentation**  
Inserted-By: **Owner UAT observation during G5**  
Triggered-By: visible literal Markdown such as `**张飞**` and standalone `---` in GM Narrative UI  
Implementer: **Zcode + GLM-5.3-flash**（Owner weekend routing override）  
Reviewer: **GPT**  
Formal Code Base: `my-world/main@879bc29b2a096f223ae27f780597fd194f9568f4`  
Governance Base: `Vibe-Coding/main@4f6ae53d2970d5890a47cee62b0a344815d813a3`  
Task Branch: `mw-008-safe-markdown-lite-rendering`  
Required worktree path: `D:/AI/Projects/.worktrees/my-world/mw-008`  
Status: **ACTIVE — ZCODE**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Natural lightweight Markdown emitted by the GM should render as presentation rather than leaking syntax characters into the Narrative UI, while the **raw model Narrative remains unchanged** in Domain Conversation, persistence, Timeline and future model context.

The first vertical is deliberately small and safe:

```text
raw GM Narrative
→ durable/raw truth unchanged
→ UI-only Markdown-lite projection
→ readable rendered Narrative
```

This task is not a new Narrative protocol and must not constrain what the model may write.

## 2. Why now

Owner UAT visibly reproduced literal Markdown in normal play, including names shown as `**张飞**`, `**糜芳、孙乾**` and standalone `---` separators. The current `NarrativeConversationView` streams GM deltas directly into `RichTextLabel.add_text()` and restores accepted GM text the same way, so Markdown syntax is displayed literally.

This presentation defect is independent from MW-005 literary-style semantics. Do not treat Markdown rendering as evidence that the Style Primer succeeded or failed.

## 3. Primary product rule

> **Render presentation semantics at the UI boundary; preserve Narrative bytes as authored everywhere else.**

Therefore:

```text
GM raw text in Conversation / persistence / context
= authoritative authored Narrative

rendered rich text
= disposable UI projection only
```

Never rewrite accepted `gm_text` into Markdown-stripped or BBCode-formatted text.

## 4. Markdown-lite v0.1 scope

Support only the syntax needed to remove the current high-value presentation defect:

1. `**text**` → bold emphasis;
2. `*text*` → italic emphasis;
3. a line whose trimmed content is exactly `---` → visual thematic separator.

Everything else remains literal text in v0.1. In particular, do **not** expand this task into CommonMark/GFM, headings, links, tables, code blocks, images, nested lists, HTML, plugins or a generic Markdown engine.

Malformed/unclosed markers must fail soft: preserve readable literal text rather than dropping content or rejecting Narrative.

## 5. Security / authority boundary

Do not feed raw model text into unrestricted Godot BBCode parsing.

Required invariant:

```text
model text containing [color=red], [url], [img], [font], etc.
→ must remain literal text
→ must never become executable/styled BBCode merely because RichTextLabel supports BBCode
```

Prefer a small whitelist renderer that emits styled runs through safe `RichTextLabel` APIs. If BBCode is used internally, raw brackets/content must be escaped before the Markdown-lite transformation and the test suite must prove no arbitrary BBCode interpretation is possible.

No HTML or remote-resource rendering is authorized.

## 6. Streaming semantics

The current UI receives arbitrary provider deltas, so Markdown delimiters may split across chunks:

```text
chunk 1: "**张"
chunk 2: "飞**"
```

The displayed final result must equal rendering the concatenated raw Narrative once. Do not parse each delta as an independent Markdown document.

Choose the smallest safe implementation. A transient **view-only current-GM raw buffer** is allowed if necessary to re-render the current RichTextLabel; it must:

- exist only for the currently rendered GM block;
- never become a second durable Conversation/history store;
- reset correctly on retry/regenerate/restore/session shutdown;
- never alter `Conversation` raw text;
- produce the same rendering after restore/redraw as during live streaming.

A compact stateful parser is also acceptable if simpler and demonstrably correct. Do not create a general streaming markup framework.

## 7. Read First / audit

1. `AGENTS.md`
2. `Vibe-Coding/AGENTS.md`
3. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`
4. this Task Packet
5. `src/ui/叙事对话视图.gd`
6. directly relevant G2 Narrative View tests
7. Domain Conversation projection/accepted-text seams only as needed to prove raw-truth preservation

Before coding, trace these actual production paths:

- live GM streaming: `draft_appended` → UI;
- retry/regenerate current GM block reuse;
- accepted-history restore/redraw;
- GM-only Opening rendering;
- player-entry rendering (must remain unchanged unless a concrete dependency requires otherwise).

Record the audit in evidence.

## 8. Mandatory worktree hygiene

Owner rule remains:

```text
all new my-world task worktrees
→ D:/AI/Projects/.worktrees/my-world/<task>
```

Before creating MW-008:

1. inspect `git worktree list --porcelain` from the main repo;
2. MW-005 Revision 3 has now passed GPT Engineering IR#3, so its worktree may be removed **only if** clean, pushed/reachable, and free of unknown user work;
3. use `git worktree remove`, then `git worktree prune`;
4. never manually delete a registered worktree;
5. create this task at exactly:

`D:/AI/Projects/.worktrees/my-world/mw-008`

Do not create another `D:/AI/Projects/my-world-*` directory.

Keep the MW-008 worktree through GPT Independent Review unless explicitly told otherwise.

## 9. Required implementation semantics

Presentation must be consistent for both live streaming and restored accepted history.

At minimum:

```text
raw:  "**张飞**按剑而立。"
display: 张飞 visually bold; no literal **
raw durable text: unchanged

raw:  "*低声道*：不可声张。"
display: 低声道 visually italic; no literal * delimiters
raw durable text: unchanged

raw line: "---"
display: thematic separator; no literal three-hyphen line
raw durable text: unchanged
```

Adjacent ordinary punctuation/Chinese text must render naturally.

Unmatched syntax example:

```text
"他说：**此事未完"
```

must remain readable and must not lose `**` or trailing text.

Nested/ambiguous constructs are outside v0.1; fail-soft to literal text rather than inventing complex Markdown precedence.

## 10. Required focused proof

Add task-owned proof that exercises the actual UI projection, not only a standalone string helper.

At minimum prove:

1. live streaming bold where delimiters arrive in one delta;
2. live streaming bold where `**` pair/content is split across multiple arbitrary deltas;
3. italic rendering and chunk-boundary behavior;
4. standalone `---` becomes a visual separator rather than literal Markdown;
5. unmatched/malformed emphasis remains readable literal text with no content loss;
6. arbitrary Godot BBCode-like input such as `[color=red]红字[/color]` remains literal and cannot style/inject;
7. raw `Conversation` draft/accepted `gm_text` exactly preserves the model-authored Markdown bytes;
8. after accept → close/reopen or redraw/restore projection, visual rendering is equivalent to the live final rendering while raw durable bytes remain unchanged;
9. retry/regenerate clears/replaces the view-only rendering state correctly and does not concatenate old draft markup;
10. GM-only first Opening uses the same safe renderer;
11. Player input rendering remains unchanged and is not accidentally interpreted as Markdown;
12. no Narrative parser/gate/retry/model-output protocol was added outside presentation;
13. `git diff --check` clean;
14. Windows export validation PASS if production GDScript changes;
15. real Provider calls may remain 0.

If direct visual property inspection is awkward in headless Godot, expose a minimal test-only/readable projection seam or inspect RichTextLabel structured content/state; do not weaken the proof to string `contains()` on the raw input alone.

## 11. Regressions

Run directly affected Narrative View / restore / Opening tests plus a bounded set covering:

- G2 Conversation UI;
- first-opening UI integration;
- persistence restore/redraw;
- Public-d20 Narrative UI if it shares the same GM block;
- MW-005 focused test only if the change touches its Narrative consumer path rather than presentation only.

Do not modify mechanics, Source, semantic materialization or MW-005 style authority to make UI tests pass.

## 12. Explicit non-scope

Do not add:

- full Markdown/CommonMark/GFM parser;
- links/images/HTML/remote resources;
- user-authored Markdown editor;
- Markdown transformation in Domain/Persistence/Context;
- model prompt instructions forcing Markdown;
- Narrative acceptance parser/classifier/gate/retry;
- typography redesign beyond what the three supported constructs require;
- G5-06 Runtime→UI world-state projection;
- MW-005 Primer/content changes;
- generic rendering/plugin framework.

## 13. Product Value Acceptance

Engineering PASS proves safe and consistent rendering. Owner UAT should simply confirm in normal play that:

- `**name**` no longer shows literal asterisks;
- standalone `---` does not look like raw markup;
- emphasis feels natural and not visually noisy;
- streaming does not flicker/corrupt obvious text;
- save/reopen looks the same;
- no authored text disappears.

## 14. Git / return contract

Before final push, fetch latest `main`, reconcile non-destructively and rerun focused regressions.

Return:

- implementation SHA;
- evidence SHA;
- remote branch;
- base/final head;
- worktree path + cleanup report;
- changed files;
- live-stream parser/render architecture;
- raw-truth preservation proof;
- chunk-boundary proof;
- BBCode-injection safety proof;
- restore/redraw equivalence proof;
- regression commands/results;
- export result;
- real Provider call count;
- remaining risks.

Return ceiling:

`READY FOR INDEPENDENT REVIEW`

Only GPT may issue Engineering PASS. Only Owner may issue Product PASS / CLOSED.
