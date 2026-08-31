# G4-07A｜Opening Runtime State / Failure Matrix

Status: pre-implementation alignment  
Task: `G4-07A`  
Start HEAD: `0a8c8aa0477b92be85634bea833824502ed12a97`

## 1. Ownership and ordering

The runtime accepts only an already-opened `当前游戏会话运行时` whose database was opened through `open_existing_game()`. The durable current/root `world_state` is the only setup authority. The Opening flow never receives Wizard state, a Source Library, or a Source package path.

```text
existing-only open and rehydrate
→ validate game_local_setup.v0.1 and empty accepted Conversation
→ derive bounded rich context from the durable setup copy
→ begin a GM-only Conversation attempt (empty compatibility player slot)
→ start the existing DeepSeek stream
→ stream deltas into the existing Conversation draft
→ Provider completed
→ build non-mutating accepted candidate
→ SQLite write_current_conversation COMMIT
→ publish accepted Conversation in memory
```

The empty `player_text` compatibility slot is not a Player prompt and is never sent as a request message. It permits the existing v4 Conversation materialization to represent the first GM-only Opening without a schema migration or a parallel transcript store.

Failure/cancel before the SQLite commit terminates the active attempt and leaves durable accepted Conversation at zero. Persistence failure also fails the in-memory attempt. A retry starts a fresh non-durable attempt. Once one Opening is accepted, eligibility closes permanently for this first-Opening seam; normal later Player turns remain owned by the existing Conversation runtime.

## 2. Context policy and schema gate

- Schema gate: **no migration expected or permitted**. Production SQLite stays v4; selected setup already exists as the opaque durable root/current World document and Conversation v4 accepts an empty Player string with non-empty GM truth.
- Included setup categories: Game display/control/opening supplement, explicit selected Entry state, World identity/instructions/exact selected Entry metadata/all already-materialized selected semantic sections, Player identity/all already-materialized selected semantic sections, and canonical Guaranteed NPC identities/all already-materialized selected semantic sections.
- Provenance: exact pins may be included as identity metadata, but no Source generation is opened or re-resolved.
- Guaranteed NPC directive: canonical cast membership alone does not establish Opening presence, location, familiarity, relationship, or mandatory dialogue.
- Temporal directive: only durable selected projections are authoritative; external/pretrained later canon must not be treated as this Game's future.
- No-Entry directive: explicit `null` remains no Entry; no Entry/profile/year may be inferred.
- Bound: retain complete semantic sections in stable order and reject an oversized setup above a task-local character ceiling; do not truncate individual sections, summarize, retrieve, or impose model output limits. The ceiling protects the Provider call from unbounded malformed input while real full-fidelity Han and Afterglow must fit beneath it.

## 3. State / failure matrix

| Case | Durable Game state before call | Context source | Provider request state | Accepted Conversation | Retry / reopen behavior | Visible/runtime result |
|---|---|---|---|---|---|---|
| A new Game success | Existing verified G4-06 DB; setup v0.1; accepted = 0 | Durable `runtime.world_state` only | One system-owned GM Opening request; streaming then completed | Persist exactly one entry with empty Player compatibility slot and non-empty GM text | Reopen restores one; first-Opening no longer eligible | `accepted` |
| B Provider auth/transport/rate/server failure | Valid setup; accepted = 0 | Same derived setup; no mutation | Start failure or failed signal before acceptance | Remains 0 durable and 0 accepted | Explicit retry allowed with same durable setup | Provider failure code, fail loud |
| C cancel during streaming | Valid setup; accepted = 0 | Same derived setup | Existing adapter cancel; partial draft discarded from truth | Remains 0 durable and 0 accepted | Explicit retry allowed | `cancelled`; partial is non-authoritative |
| D streamed success accepted once | Valid setup; accepted = 0 | Same derived setup | Deltas accumulate only as Conversation draft | SQLite COMMIT precedes in-memory acceptance; count = 1 | Duplicate first start rejected | `accepted` with one durable Opening |
| E retry after failure/cancel | Same DB and setup; accepted = 0 | Re-derived from unchanged durable Game-local truth | New adapter attempt; no prior partial included | Exactly the successful retry becomes count = 1 | Later retry rejected as already opened | Clean convergence, no duplicate |
| F reopen after accepted Opening | Existing verified DB; accepted = 1 | Durable setup + restored history available for later play | No automatic Provider request | Remains exactly 1 | First-Opening call returns `already_opened` | No second first Opening |
| G existing Game continuation | Existing verified DB; accepted >= 1 | Durable Game-local setup plus accepted history through current Context owner | Normal later Player-turn path, outside first-Opening call | Existing history preserved | Reopen/continue uses recent accepted history | First-Opening seam reports ineligible |
| H missing/wrong/corrupt DB | No DB, bad identity count/identity, or corrupt SQLite | None | Never started | No new Game or Conversation created | Fix/select a valid existing Game, then reopen | Existing-only startup failure, fail loud |
| I mutable Source current drift | Created DB pins/materialization X; Source current may be Y | Durable X materialization only | Request contains X; no Source Library access | Normal acceptance | Reopen remains X | Source current has no runtime effect |
| J Han early start | Exact early Entry/profile already materialized; accepted = 0 | Top-level + exact selected early sections in durable setup | Contains early markers; excludes later/unselected/future markers | Normal acceptance | Durable result reopens once | Temporal quarantine preserved |
| K no Entry | `selected_entry_id = null`; selected Entry/profile objects empty | Top-level materialized sections only | Explicit no-Entry directive; no inferred year/default | Normal acceptance | Reopen remains no-Entry | No hidden Entry/profile |
| L Guaranteed NPC | Canonical local NPC definitions exist without placement/knowledge/relationship facts | Canonical definition plus narrow non-convergence directive | No claim of presence, co-location, familiarity, relationship, or mandatory dialogue | Normal acceptance | Later world causality may introduce NPC independently | Canonical cast does not force scene-one convergence |
| M bounded but rich | Valid full-fidelity setup under ceiling | Complete already-selected sections, stable order | Request records category/character counts; no per-section truncation | Normal acceptance | Oversized malformed input fails before Provider | Rich context or explicit `context_too_large`, never silent starvation |
| N real Provider evidence | Task-owned G4-06 Han/Afterglow DBs | Provider-visible messages captured with secrets excluded | Real DeepSeek adapter/network path | Real non-empty GM result committed | Close/reopen validates one accepted result | Evidence records model/timing/counts, not key/header/full secret |
| O close/reopen exact Game | One accepted Opening in exact managed SQLite | Fresh runtime rehydrates root/current + Conversation | No automatic request on reopen; later context includes durable GM history | Exactly one restored | Same Game ID/path; first-Opening blocked, continuation context valid | Durable continuation-ready seam |

## 4. Fail-closed decisions

- Invalid setup schema/shape, missing runtime readiness, active generation, already accepted Conversation, empty Provider completion, oversized context, and persistence failure all fail without publishing accepted truth.
- A valid verified Game DB is never deleted or replaced by this runtime.
- If implementation proves a physical SQLite field/table is required, production work stops and returns `BLOCKED` before any migration.
