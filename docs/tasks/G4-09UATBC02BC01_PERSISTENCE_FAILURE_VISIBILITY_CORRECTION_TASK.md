# G4-09UATBC02BC01 — Persistence Failure Visibility Completion

Type: **UI correction-01 for C02B**  
Status: **ACTIVE — KIMI**  
Owner: **Kimi**  
Reviewer / semantic owner: **GPT**  
Parent: **G4-09UATBC02B Public d20 Failure Visibility**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## Why this task exists

C02B correctly surfaced transport / credential failures and the non-blocking C02A degraded notice, but Independent Review found one incomplete acceptance seam: legitimate persistence/finalize hard failures still fall through to generic `行动未完成` because `_plain_adjudication_failure()` does not map the Public d20 persistence failure family.

Formal review:

`docs/g4_09/G4-09UATBC02B_INDEPENDENT_REVIEW.md`

## Required outcome

Keep the current C02B implementation and add the smallest UI-only completion.

Map these terminal categories to one concise safe player-facing persistence message:

```text
persistence_failure
check_persistence_failed
no_check_persistence_failed
check_acceptance_marker_failed
no_check_acceptance_marker_failed
```

Conceptual wording:

`本次结果未能安全保存，请重试。`

Exact wording may follow the existing UI language, but it must clearly communicate **safe-save/persistence failure**, not model/network failure and not a generic unknown failure.

## Acceptance

Prove directly:

1. at least one pre-Conversation durable mechanics write failure (`check_persistence_failed` or `no_check_persistence_failed`) shows the safe persistence category + `重试行动`;
2. at least one Conversation/finalize or acceptance-marker failure (`persistence_failure` or `*_acceptance_marker_failed`) shows the safe persistence category + recovery;
3. no raw SQLite/SQL/path/internal storage error text is shown;
4. transport, missing_key and degraded-action behavior from the reviewed C02B delivery remain unchanged;
5. successful NO_CHECK/CHECK_REQUIRED behavior remains unchanged;
6. no backend / Provider / Persistence / Runtime / protocol / retry-policy change;
7. no new parser, model-format gate, fallback or blocking state;
8. `git diff --check` clean.

## Scope

Allowed production path only:

- `src/ui/叙事对话视图.gd`

Plus directly relevant UI tests/evidence.

Protected:

- `src/行动判定/**`
- `src/provider/**`
- `src/persistence/**`
- `src/runtime/**`
- Runtime Model Settings
- Source / Final Create / Game Library
- SQLite schema

No real Provider rerun is required because this task changes only UI projection of already-existing terminal codes.

Do not resume Owner UAT. Do not start G4-10/G5.
