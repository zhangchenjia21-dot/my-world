# G4-09UATBC02B — Public d20 Failure Visibility / Recoverable UX

Type: **UI correction-02 follow-up**
Status: **HOLD — KIMI**
Owner: **Kimi**
Reviewer / semantic owner: **GPT**
Parent: **G4-09UATB Owner Product UAT**
Prerequisite: **G4-09UATBC02A PASS / CLOSED**

Return ceiling: **READY FOR INDEPENDENT REVIEW**.

## Goal

After C02A has stabilized the mechanism, make terminal Public d20 failures visible in concise, safe language without exposing raw Provider payloads or turning recoverable control-lane degradation into a blocking error.

Current defect: `叙事对话视图.gd::_handle_adjudication_result()` obtains a failure code, and `_plain_adjudication_failure()` already maps safe categories, but the mapped message is not actually shown. The player therefore sees only generic `行动未完成` recovery state.

## Required behavior

- genuine terminal Provider/network/credential/persistence failures show a concise safe reason;
- stable `重试行动` recovery remains available;
- control-lane fail-soft degradation from C02A is **not** rendered as a terminal failure; at most show a compact non-blocking notice that this action continued without the optional d20 check;
- never show API keys, Authorization, prompt, raw Provider body, hidden reasoning or unbounded error text;
- do not redesign Narrative UI;
- do not change backend semantics or duplicate backend policy.

## Scope

Allowed:

- `src/ui/叙事对话视图.gd`
- directly related UI tests/evidence

Protected:

- Action Adjudication backend
- Provider
- Persistence/Runtime
- Runtime Model Settings
- Source/Final Create
- SQLite schema

## Acceptance

Prove:

1. transport failure shows safe connection message + retry action;
2. missing selected-provider key shows safe credential message + retry path;
3. malformed/unusable terminal mechanic response, if one can still occur after C02A, shows safe mechanic-service message;
4. fail-soft degraded ordinary narrative is not presented as `行动未完成`;
5. no secrets/raw payloads in UI or evidence;
6. existing successful NO_CHECK/CHECK_REQUIRED UI path unchanged;
7. 960×540 and 1280×720 recovery state remains usable;
8. `git diff --check` clean.

Do not start until GPT closes C02A and activates this task.
