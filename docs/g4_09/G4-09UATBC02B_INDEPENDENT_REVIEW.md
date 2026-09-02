# G4-09UATBC02B Independent Review

Status: **CORRECTION REQUIRED**  
Date: 2026-09-02  
Reviewer / semantic owner: **GPT**

## Reviewed delivery

- START_HEAD: `f3348871f0b34ef2ddd1f045b067df7bfb580468`
- IMPLEMENTATION_HEAD: `6c47387e6b6e2cafeb40ef4e371c433d64ae7045`
- EVIDENCE_HEAD: `c8d8de6c0c773169bbaa4dabb92df063b8a51f10`

## Accepted pieces

The delivery correctly keeps C02B UI-only. Production changes are limited to `src/ui/叙事对话视图.gd`; Action Adjudication, Provider, Persistence/Runtime, Runtime Model Settings, Source/Final Create and SQLite are unchanged.

Accepted behavior:

- `transport` failure now shows a concise safe connection reason and keeps `重试行动` available;
- `missing_key` now shows a concise safe credential reason and keeps recovery available;
- C02A `degraded=true` accepted actions are not rendered as terminal `行动未完成`; they show a compact non-blocking notice and remain accepted ordinary narrative;
- no new parser, model-format contract, provider fallback, retry policy or blocking state was added;
- existing success paths and layout regressions are reported green.

These pieces are protected from generic reopening absent a concrete regression.

## Blocking gap — persistence hard failures still collapse to generic text

The C02B packet explicitly requires **genuine terminal Provider/network/credential/persistence failures** to show a concise safe reason.

Current `_handle_adjudication_result()` now calls `_plain_adjudication_failure(code)`, but that mapper still has no safe mapping for Public d20 durable/finalize failure codes such as:

- `persistence_failure`
- `check_persistence_failed`
- `no_check_persistence_failed`
- `check_acceptance_marker_failed`
- `no_check_acceptance_marker_failed`

Those codes therefore fall through to an empty string and the UI still shows only:

`行动未完成；可点击「重试行动」继续。`

This is not sufficient. Persistence is intentionally allowed to remain a hard gate because accepting a turn without durable truth would corrupt history. Precisely because it is a legitimate hard gate, the player must be told a safe category such as **“本次结果未能安全保存”** rather than being returned to the same opaque generic state that triggered C02B.

The submitted C02B tests cover transport, missing key and degraded control, but do not directly assert persistence/finalize failure visibility.

## Required correction

A narrow UI-only correction is required:

1. map the Public d20 persistence/finalize failure family to one concise safe player-facing category, conceptually `本次结果未能安全保存，请重试。`;
2. preserve stable `重试行动` behavior and existing resolution/no-reroll semantics;
3. add direct focused tests for at least:
   - one pre-Conversation durable write failure (`check_persistence_failed` or `no_check_persistence_failed`), and
   - one finalize/acceptance failure (`persistence_failure` or `*_acceptance_marker_failed`);
4. never surface raw storage error text, paths, SQL, payloads or secrets;
5. do not modify backend, persistence behavior, protocol, provider behavior, retry policy or any blocking condition.

## Verdict

**G4-09UATBC02B: CORRECTION REQUIRED.**

This is a narrow failure-visibility completeness issue. C02A Model Freedom / protocol decoupling remains PASS / CLOSED. Owner UAT remains HOLD.
