# G4-09R1P1 — Runtime Model Settings Final Integration / Owner UAT Readiness

Status: **PASS / CLOSED**  
Parent: **G4-09R1 Runtime Model Settings v0.1**  
Owner: **Codex**  
Reviewer / semantic owner: **GPT**

Formal reviewed code base: `b6bd6bc8e077bbeccbb8639f6bc0670795e3e36c`  
Implementation/evidence HEAD: `f615cc49748320f346362430383e6ff074668278`  
Independent Review: `docs/g4_09r1/G4-09R1P1_INDEPENDENT_REVIEW.md`

## Outcome

PASS / CLOSED. The accepted Model Settings backend + UI were revalidated on the current Owner launch line immediately before Owner UAT B.

Accepted final path:

```text
actual Main Menu Model Settings
-> DeepSeek V4 Pro selection + Save -> real Opening accepted
-> Kimi K3 selection + Save -> real Opening accepted
-> canonical Windows export freshness rebuilt/validated
-> production World/Character/Public d20 prerequisites intact
-> Owner Games unchanged
-> Owner UAT instructions refreshed and activated
```

## Accepted evidence

- real Provider calls through the actual Main Menu settings surface using task-owned roots;
- no provider fallback/substitution and no secret exposure;
- `.\run-game.ps1 -ValidateExportOnly` rebuilt the stale canonical Windows export and validated it;
- production Source inventory remained World 2 / Character 6 / Expansion 1;
- exact Public d20 remained current with fingerprint `e40bf3cb1059a4952d4230ae624fc3a0ba9bc705e279b13fef8cd1e795ca5ec1`;
- Owner Games modified: no;
- Settings UI / Runtime Settings / Public d20 regression floor green;
- SQLite schema remains v4;
- production code `src/**` unchanged in this task.

## Review note

The implementation evidence described the 208 route informally as `赤壁前夜`. Canonical Source display is `208｜赤壁前夕`. GPT corrected the Owner-facing UAT record during Independent Review closeout. This was documentation-only and did not require a Codex correction task.

## Disposition

```text
G4-09R1P1 Final Integration/Freshness PASS / CLOSED
G4-09R1 Runtime Model Settings v0.1   PASS / CLOSED
G4-09UATB Owner Product UAT           ACTIVE — OWNER
```

Do not close G4-09/G4-08 before Owner Product UAT verdict.