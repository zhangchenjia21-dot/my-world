# G4-09UATB Owner Finding — Streaming Protocol Robustness

Status: **OPEN — correction-02 required**
Date: 2026-09-02
Parent: **G4-09UATB Owner Product UAT**
Semantic owner: **GPT**

## Owner observation

During the focused responsiveness retest after `G4-09UATBC01`, the Owner submitted a normal action and the product returned to an unfinished-action state instead of producing/accepting narrative. The UI showed only:

```text
行动未完成；可修改后重新提交，或点击「重试行动」。
```

No concrete safe failure reason was visible.

The Owner's previously accepted product finding remains unchanged: Public d20 gameplay/mechanics themselves are worthwhile and are not being reopened here.

## Independent diagnosis

Two adjacent seams introduced/exposed by C01 are implicated.

### 1. Framing is too brittle for real model formatting variance

Current incremental adjudication parsing requires the control JSON to be exactly the first physical line and additionally rejects any leading/trailing whitespace around that line. `NO_CHECK` also requires a physical LF separator before narrative body.

That is stronger than the actual semantic requirement. Real models may harmlessly emit leading whitespace or pretty-print a JSON object across multiple physical lines. Treating those variants as business-invalid makes the runtime fragile even though a unique complete control JSON object can still be parsed safely.

### 2. Public d20 failure code is swallowed by the UI

`叙事对话视图.gd::_handle_adjudication_result()` extracts the failure `code`, and a safe `_plain_adjudication_failure()` mapper already exists, but the result is not sent to `_show_error(...)`. Therefore the player sees only the generic unfinished-action panel and cannot distinguish transport, credential, malformed control, empty narrative, or service failure.

## Correction direction

Preserve C01's accepted progressive streaming and durable ordering, but replace physical-line framing with semantic JSON-object framing:

```text
optional leading whitespace
→ first complete JSON object, found incrementally across arbitrary chunks / physical lines
→ validate exact Public d20 control semantics
→ NO_CHECK: optional framing whitespace, then raw narrative body streams progressively
→ CHECK_REQUIRED: only trailing whitespace allowed after control object
```

The incremental parser must track JSON object depth while respecting quoted strings and escapes. It may tolerate whitespace and pretty-printed JSON, but must still fail loud on Markdown fences, natural-language preamble, malformed/ambiguous JSON, or CHECK_REQUIRED narrative body. It must not guess an object from arbitrary prose.

Separately, the UI must surface a safe user-facing Public d20 failure message while preserving the stable-action retry flow and never exposing raw Provider payloads, prompts, keys, or Authorization.

## Gate effect

```text
G4-09UATBC01 Narrative Responsiveness      PASS / CLOSED
G4-09UATB Owner Product UAT               HOLD — correction-02
G4-09UATBC02A Framing Robustness           ACTIVE — CODEX
G4-09UATBC02B Failure Visibility           HOLD — KIMI
```

This is correction-02 for an adjacent seam. If the same real-model framing seam still fails after C02A, stop patching special cases and redesign the control protocol under the project correction-budget rule.
