# MW-008 Independent Review — IR#1

Status: **ENGINEERING PASS / CLOSED**  
Work Item: **MW-008 — Safe Markdown-Lite Narrative Rendering**  
Revision: **1**  
Reviewer: **GPT**  
Reviewed implementation: `9f90e634d6d0302e9905f131410f7a33611e8d41`

## 1. Verdict

MW-008 passes Engineering Review for its product outcome: the current GM Narrative UI now treats the approved Markdown-lite syntax as disposable presentation while preserving authored Narrative bytes in Conversation/persistence/context.

The implementation is accepted because the actual production paths satisfy the required authority boundary:

```text
raw GM Narrative
→ Conversation / persistence / future model context unchanged
→ UI-only deterministic projection
→ safe RichTextLabel rendering
```

No Narrative acceptance protocol, parser gate, retry loop, model-output contract, Domain transformation or persistence rewrite was introduced.

## 2. Actual-code findings

### PASS — raw truth remains untouched

`NarrativeConversationView` continues to append provider deltas into the existing Conversation first. The new `_current_gm_raw` is view-only state used only to re-project the currently visible GM block. Accepted/reopened history reads the original `gm_text` and sends it through the same renderer without modifying the durable bytes.

### PASS — chunk-boundary correctness

Live streaming no longer parses each delta independently. The view appends deltas to `_current_gm_raw` and re-renders the whole current block, so a delimiter split such as `**张` + `飞**` converges to the same final projection as one-shot rendering.

### PASS — BBCode injection boundary

Raw model brackets are escaped before Markdown-lite transformation. The renderer itself emits only the bounded tags required for bold, italic and separator projection. Model-authored `[color]`, `[url]`, `[img]` and similar text remains literal.

### PASS — restore/redraw consistency

`_render_restored_entries()` rebuilds the same `_current_gm_raw` from durable `gm_text` and calls the same projection function used during live streaming. Restore/reopen therefore does not create a second presentation interpretation.

### PASS — player input remains literal

The Player entry path still uses `add_text(player_text)` and does not interpret Markdown.

## 3. Evidence inspected

Actual production diff was reviewed for:

- `src/ui/叙事富文本渲染器.gd`
- `src/ui/叙事对话视图.gd`
- `tests/mw008/安全轻量渲染测试.gd`
- `docs/mw008/MW-008_SAFE_MARKDOWN_LITE_RENDERING_EVIDENCE.md`

The focused test exercises the real NarrativeConversationView and verifies live rendering, arbitrary chunk boundaries, raw Conversation byte preservation, redraw/reopen equivalence, retry/regenerate reset, GM-only Opening, player-input non-interpretation and BBCode-like input safety.

Zcode reports 43 focused assertions passing, affected UI regressions green except the documented pre-existing G2-03 environment-sensitive network assertion, Windows export PASS, `git diff --check` clean and real Provider calls = 0.

## 4. Non-blocking advisory A01 — ambiguous mixed emphasis

The v0.1 whitelist does not support nested/ambiguous emphasis. The current two-pass implementation can interpret some mixed-marker inputs such as `***x***` or `*a**b*` instead of preserving the entire construct literally. This is outside the supported syntax and does **not** affect raw Narrative truth or the BBCode security boundary, so it is not a blocker for the reproduced `**text**`, `*text*`, and standalone `---` defect.

If normal UAT later shows visible noise from mixed markers, correct this inside MW-008 with a small fail-soft ambiguity guard. Do not expand into a general Markdown engine.

## 5. Closure

```text
MW-008 Revision 1 / IR#1
= ENGINEERING PASS / CLOSED
```

Owner may validate the visible presentation opportunistically during later combined product testing; no separate progression gate is required before returning to the G5 mainline.
