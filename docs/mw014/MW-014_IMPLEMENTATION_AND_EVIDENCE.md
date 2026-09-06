# MW-014｜角色与重要经历整理后端

Work Item: MW-014 / Revision 1 / Review-Round 0
Status: IMPLEMENTED — REAL PROVIDER SMOKE PENDING APPROVAL
Return ceiling: READY FOR INDEPENDENT REVIEW
Implementation base: `7daa6223a07ff4a2103cc9bd5944ea27028eabce`
Governance main read before implementation: `d9e131cb15cf496e4a856c50367ac5f79c058272`

## Authority

Task Packet: `docs/tasks/MW-014_MODEL_DRIVEN_CHARACTER_AND_MILESTONE_CURATION_V0_1_TASK.md`.

Read the six listed governance authorities (Character/Important Experiences, model curation authority, Shell ownership, Game-local evolvable semantics, player-safe Runtime UI projection, Current Status), governance AGENTS and Task Identity v1.0, implementation AGENTS, and MW-011 R3 Owner UAT result. Current main confirms MW-014 active and MW-013 HOLD.

**Model owns semantic interpretation and curation; Program owns normalized storage, temporal integrity and presentation.**

## Production placement and public seams

`src/应用壳.gd` composes `信息整理/L3_外交层/信息整理公开接口.gd` with the existing Session Runtime. It owns an independent existing Provider adapter and listens to **durably accepted** Conversation `generation_completed`. It does not intercept Narrative completion, acquire a foreground action lock, or wait for G5 semantic/Agency/Evolution lanes.

- `retry_pending()`: explicit repair of missing/failed current-history versions; durable successes are skipped. Failures are not automatically hammered in a retry loop.
- `status_snapshot()` / `finished(result)`: bounded lifecycle status only; no request, response or credentials.
- `角色经历投影公开接口.project_session(runtime)`: deterministic display-only projection; no Provider or Source-current lookup.

Reopen constructs equivalent projection without starting model work. New accepted input or explicit retry wakes missing curation. Restore invalidates the active epoch and cancels transport; it does not automatically rewrite the restored snapshot. Close cancels transport before the Session writer closes.

## Responsibility / dependencies

- L0: known keys/types/counts/string lengths, accepted Player+GM prefix identity, current record lineage validation.
- L1: bounded JSON syntax parsing and display-only projection.
- L2: sequential background request lifecycle, timeout, retry markers, source-version binding and atomic mutation orchestration.
- L3: existing Provider L3 construction, frozen profile L3 collaboration, public lifecycle and projection.
- Bootstrap: existing Shell composition only; no new Surface or UI controls.
- Tests/docs: outside the four layers.

New module dependencies are downward. Cross-module concrete references originate in L3 and target existing L3. The L2 receives the profile reader as a Callable and the transport as a Node; neither is model-provided.

The existing RPG ViewModel L3 gains one read-only method, `project_frozen_profile(world_state)`, exposing the already existing fail-closed MW-011 profile projector without importing its internal file from the new module.

## Exact model contract and bounds

```json
{
  "character": null,
  "experiences": []
}
```

`character=null` means keep current Character. Otherwise it is a full replacement snapshot:

```json
{
  "character": {
    "headline": "张琛",
    "summary": "当前人物摘要",
    "groups": [
      {"title": "能力 / 专长说明", "items": ["由模型整理的当前能力"]}
    ]
  },
  "experiences": [
    {"title": "由模型选择的本轮重要经历", "description": "简洁说明"}
  ]
}
```

Only these seven group titles are allowed as structural target fields: 基本资料、出身 / 来历、当前身份 / 社会角色、性格 / 价值观 / 原则、能力 / 专长说明、局限 / 长期特征、长期目标 / 自我方向. The model chooses the target and content; Program never routes prose to a group.

| Boundary | Limit |
|---|---|
| Serialized user context | 131072 UTF-8 bytes; oversized input fails soft, no partial semantic truncation |
| Response stream | 65536 UTF-8 bytes, checked while accumulating |
| JSON nesting | Maximum 8, lexical quote/escape-aware check before parsing |
| Character headline / summary | 160 / 1600 characters, may be empty |
| Character groups | 0–7 unique known titles |
| Items per group / item length | 0–12 / 600 nonempty characters |
| Added experiences per turn | 0–4 |
| Experience title / description | 160 / 1200 nonempty characters |
| Recent experiences in model context | Latest 8 only; stored history is not truncated |
| Request lifetime | 120 seconds; cancel on timeout |

Exact keys are required at every structure level. Unknown fields, IDs, scores, operation names, wrong types, excessive counts, malformed JSON and oversized payloads fail soft with zero World mutation. No executable expression, callback, model-provided authoritative ID, reasoning or raw model response is stored.

## Durable/currentness representation

Existing opaque World JSON gets:

```text
information_curation:
  schema: information_curation.v0.1
  turns:
    <accepted turn index as string>:
      prefix: hash of accepted Player + GM history through this turn
      parent: preceding valid curation record identity, or empty
      id: deterministic hash of prefix + parent + normalized result
      result:
        character: null or complete bounded snapshot
        experiences: this turn's additions
```

An individual milestone has the internal deterministic identity tuple `(record.id, zero-based addition ordinal)`; neither component enters player output. The containing Game and its Timeline snapshot own all identities.

A successful result, including no-change receipt, is committed through existing `SessionRuntime.commit_world_mutation_durably`. It atomically appends a Timeline node and updates current World. No SQLite schema/table, Persistence code or Source generation changes.

No-change receipts make successful replay/reopen idempotent without fake Character or milestone content. Mutation/node IDs are program-generated per atomic attempt; semantic record identity is deterministic. This avoids a reused global mutation ID colliding with a displaced-future node when the same accepted transcript is curated again after Restore. Current durable record matching prevents successful replay from submitting another mutation.

Before commit, the worker checks the accepted prefix, preceding curation identity and session epoch, then merges its owner into the **latest** World snapshot. Unrelated semantic/Agency/Evolution writes are preserved. Projection validates prefix and parent chain in accepted order. Replacing earlier accepted Player or GM content invalidates dependent later records as well as the replaced turn. Repairing an earlier curation changes the parent identity and requires dependent curation to be reconsidered.

Restore returns both World and Conversation to their saved current state. No physical future history deletion is necessary. Milestone history has no arbitrary maximum deletion limit; each record alone is bounded.

## Input/disclosure and starting state

Model input uses only:
- accepted Player text and accepted GM Narrative;
- current Character projection reconstructed from valid earlier curation;
- latest eight valid earlier milestones;
- frozen `player_character.source_projection.player_profile` via existing MW-011 fail-closed projector.

The dedicated prompt states surface semantics and Player choice ownership. There is no raw all-world snapshot, NPC Knowledge, Agency plan, hidden Evolution, GM-reference prose, source semantic sections, Source-current lookup or model-visible local identity. Optional extra world context was deliberately unnecessary for this first vertical.

Before lived curation, the new Character seam retains frozen `headline` and `summary`, with empty groups. Arbitrary authored profile groups can contain starting possessions: Program does not classify/filter them into a new Character taxonomy. Their complete safe text is given to the curator for semantic organization when it emits a snapshot. Existing accepted MW-011 UI continues to show its original full frozen profile; no UI redistribution is implemented.

Player projection is exactly:

```text
character: {headline, summary, groups: [{title, items}]}
important_experiences: [{title, description, time_label}]
```

`time_label` is empty because there is no current authoritative game-calendar seam to read here. No wall-clock timestamp, turn number, guessed Source era or fabricated date is rendered.

## No Program semantic judge

All production decisions about meaning are inside the model prompt/result. The program:
- never searches Player/Narrative text for an event, faction, relationship or choice keyword;
- never computes significance/importance scores;
- never uses event-type branches or N-turn/day thresholds for long-term meaning;
- never rejects a curation because Program disagrees with the model's choice.

Tests inject structural results independently of input words; notably a generic ordinary input can receive four model-selected milestones, and all are retained. JSON bracket scanning is syntax validation only. Exact allowed group titles are schema fields, not a prose router.

## Validation and known limitations

Reproducible offline entry point: `tests/mw014/运行信息整理离线验证.ps1`. It uses a fresh task-owned build directory, disables Provider credentials in its child process environment, runs focused and required regression scripts, and performs Windows release export.

The focused suite has 103 assertions covering production SQLite/Runtime acceptance, failure/nonblocking behavior, full snapshot replacement, milestones, no-change receipts, malformed/unknown/oversized/deep output, retry, timeout, synchronous transport failure, injected persistence failure, Player-only correction, Regenerate, Restore with identical transcript, in-flight future cancellation, reopen, safe starting material, no Source/private backfill, bounded context vs retained history, and Shell lifecycle composition.

G3-04's old `contains("Current Game Context")` assertion falsely matched a phrase in the current MW-004 GM instruction. The task changes only this assertion to require the exact empty-context system message, preserving future-marker isolation and the other Save/Restore checks. Context/Persistence production files are unchanged.

Required G3, G5 semantic lane, MW-009, MW-011 profile/ViewModel and MW-012 regressions are covered. Expected injected SQLite failure messages in G3 are not unexpected failures; process exit and suite verdict remain authoritative.

Real Provider script: `tests/mw014/真实Provider信息整理验证.gd`; launcher: `tests/mw014/运行真实信息整理验证.ps1`. It reads the real installed World/Zhang Chen Source, creates isolated Games via production Final Create, accepts the three explicit smoke narratives via production acceptance, and calls the real existing selected Provider curator. It does not stub the curation response or claim those prewritten narratives were generated by GM. Owner settings/Source/Games/current DB are fingerprinted before/after; credentials are never written to evidence.

**Real Provider smoke has NOT run.** Automatic approval rejected credential-backed network execution because it required explicit approval of the destination and payload. Current selected profile observed: Kimi K3 (`kimi_k3`), target `https://api.kimi.com/coding/v1/chat/completions`. The exact three scenarios are in the smoke script. User confirmation is pending. No semantic quality verdict or READY FOR INDEPENDENT REVIEW is claimed until that required evidence exists.

## Non-scope

No final Godot Character/Important Experiences Surface, left-panel redistribution, portraits/media resolver, Inventory/Relationship/Thread/Map/system mechanics, MW-013 UI Host, Action Intent, G7 retrieval, external Mod schema, Source mutation, SQLite migration or main merge.
