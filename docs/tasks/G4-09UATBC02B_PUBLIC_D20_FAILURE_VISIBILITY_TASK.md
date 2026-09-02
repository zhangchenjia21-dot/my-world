# G4-09UATBC02B — Public d20 Failure Visibility / Recoverable UX

Type: **UI correction-02 follow-up**
Status: **PASS / CLOSED AFTER C01 — GPT**
Owner: **Kimi**
Reviewer / semantic owner: **GPT**
Parent: **G4-09UATB Owner Product UAT**

Formal reviews:

- first delivery: `docs/g4_09/G4-09UATBC02B_INDEPENDENT_REVIEW.md` — correction required;
- completion: `docs/g4_09/G4-09UATBC02BC01_INDEPENDENT_REVIEW.md` — PASS / CLOSED.

Accepted final behavior:

- genuine terminal transport/network failure shows a concise safe connection reason;
- missing selected-provider credential shows a concise safe credential reason;
- Public d20 persistence/finalize hard failures show a concise safe-save reason;
- stable `重试行动` recovery remains available;
- C02A fail-soft degraded ordinary narrative is never rendered as terminal `行动未完成`; at most a compact non-blocking notice is shown;
- successful NO_CHECK/CHECK_REQUIRED UI behavior remains unchanged;
- no keys, Authorization, prompts, raw Provider bodies, hidden reasoning, SQL/SQLite/path details are exposed;
- no backend mechanics, Provider behavior, model policy, parser contract, fallback, retry policy, persistence semantics or blocking state was added or changed.

Correction child:

`G4-09UATBC02BC01 Persistence Failure Visibility` — **PASS / CLOSED**.

C02B is closed. Final Owner retest remains gated only by current-head Windows/product freshness.
