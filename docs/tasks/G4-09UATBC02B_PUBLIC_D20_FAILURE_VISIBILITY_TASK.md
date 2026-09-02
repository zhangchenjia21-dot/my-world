# G4-09UATBC02B — Public d20 Failure Visibility / Recoverable UX

Type: **UI correction-02 follow-up**
Status: **CORRECTION REQUIRED — C01 ACTIVE**
Owner: **Kimi**
Reviewer / semantic owner: **GPT**
Parent: **G4-09UATB Owner Product UAT**
Prerequisite: **G4-09UATBC02A PASS / CLOSED**

Return ceiling: **READY FOR INDEPENDENT REVIEW**.

## Goal

After C02A has stabilized the mechanism, make terminal Public d20 failures visible in concise, safe language without exposing raw Provider payloads or turning recoverable control-lane degradation into a blocking error.

Current implementation delivery reviewed at `c8d8de6c0c773169bbaa4dabb92df063b8a51f10` correctly surfaces transport / missing-key failures and the non-blocking degraded-action notice, but Independent Review found persistence/finalize failure categories still fall through to generic text.

Formal review:

`docs/g4_09/G4-09UATBC02B_INDEPENDENT_REVIEW.md`

Active correction:

`docs/tasks/G4-09UATBC02BC01_PERSISTENCE_FAILURE_VISIBILITY_CORRECTION_TASK.md`

## Required behavior

- genuine terminal Provider/network/credential/persistence failures show a concise safe reason;
- stable `重试行动` recovery remains available;
- control-lane fail-soft degradation from C02A is **not** rendered as a terminal failure; at most show a compact non-blocking notice that this action continued without the optional d20 check;
- never show API keys, Authorization, prompt, raw Provider body, hidden reasoning or unbounded error text;
- do not redesign Narrative UI;
- do not change backend semantics or duplicate backend policy;
- **do not add any new model-format gate, parser requirement, provider fallback, retry policy, or blocking state**.

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

## Current correction acceptance

C01 must directly prove safe persistence/finalize failure visibility for the Public d20 failure-code family while preserving all already accepted C02B behavior. See the active correction packet for exact codes and assertions.

G4-09UATB remains HOLD until C02B and C02BC01 pass GPT Independent Review.
