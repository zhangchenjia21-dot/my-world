# MW-024｜Independent Review IR1

Status: **ENGINEERING PASS_WITH_NOTES**  
Date: 2026-09-08  
Reviewer: GPT  
Product UAT: deferred to combined Package 2 UAT after MW-025

## 1. Reviewed identity

- Formal product-code base: `a11af1bb922e5d0637a38bcccfdac27a819c9c1c`
- Task/packet starting HEAD: `b9f7f69c6817aacc975d4fbee522fa6bd64be65e`
- Implementation HEAD: `9ca5d49c351f259f9fbf09fb26f4520323ac671d`
- Submitted final candidate: `0bca791724c012ad191fdfaf026349153e080af4`
- Task branch: `mw-024-ooc-gm-guidance`
- Frozen authority: `Vibe-Coding/my world/architecture/interaction/G6_CORE_INTERACTION_CONTROL_V1_0_DECISION.md`
- Task Packet: `docs/tasks/MW-024_OOC_GM_GUIDANCE_TASK.md`

Both implementation and governance mains were refreshed before review. Implementation `main` remained exactly the Formal Code Base and governance remained on the MW-024-authorized Package-2 state; no superseding architecture was found.

## 2. Independent review method

The review did not treat Builder acceptance claims as completion evidence. It independently inspected:

1. Starting → Implementation → Final-candidate commit topology and changed-file set;
2. the new accepted-input compatibility/currentness seam;
3. Conversation pending/accepted/Restore/regenerate/correction mode ownership;
4. Narrative Context Assembly request-only OOC marking;
5. World/identity/Agency/Evolution/player-safe currentness after typed OOC insertion;
6. lived Information Curator gating;
7. recommendation mode-aware input/currentness and recommendation-click behavior;
8. controlled vertical/window evidence, baseline regression evidence and the bounded real Kimi OOC sample;
9. final candidate delta after Implementation, which is evidence/docs only.

## 3. Findings

### IR-01｜Typed input mode is real Program-owned structure — PASS

`src/domain/L3_外交层/已接受输入公开契约.gd` centralizes mode normalization and accepted-version material.

- missing mode + non-empty Player text normalizes as `action`;
- missing mode + empty Player text normalizes as opening;
- explicit `ooc` is structural and never inferred from prose;
- legacy/action/opening prefix material retains the old `[previous, Player, GM]` bytes;
- explicit OOC alone adds a discriminator;
- World current-source hashes exclude OOC while retaining actual accepted turn indices;
- Recommender version material only adds mode metadata for OOC, preserving old action-prefix compatibility.

This satisfies the backward-compatible currentness direction without creating several divergent mode-hash implementations.

### IR-02｜Conversation mode ownership / durable round-trip — PASS

Conversation now owns pending and accepted mode together with Player/GM text.

- `begin_turn(..., input_mode)` only accepts action/ooc;
- GM opening keeps its existing special mode;
- completion atomically publishes pending text + pending mode + GM result;
- regenerate preserves the accepted mode;
- correction can deliberately replace mode and rolls pending mode back on failure;
- validation accepts legacy missing-mode entries and rejects unsupported explicit mode;
- rehydration restores normalized mode;
- durable/current/context projections expose the typed mode.

No SQLite/table/schema migration is introduced. Current generic accepted-Conversation JSON persistence carries the optional dictionary field; old immutable Save material remains readable.

### IR-03｜Raw accepted prose remains authoritative — PASS

OOC labels are not embedded into durable Player/GM text. `ContextAssembler` adds `[GM Guidance ...]` / `[GM OOC response ...]` only to derived Provider request content and adds a bounded active-OOC system directive.

This preserves accepted raw bytes while making OOC structural semantics visible to the model.

### IR-04｜OOC gameplay isolation — PASS

The production paths are structural:

- Narrative UI bypasses Public d20 when the explicit composer mode is OOC;
- unresolved durable d20 still gates Send before the OOC/action branch, so OOC cannot bypass a pending authoritative action;
- World semantic returns `ooc_skipped` before queueing/Provider work;
- lived Information Curator does not create an opportunity for OOC and its pump processes only `action` entries;
- Agency selector rejects a latest OOC opportunity structurally;
- World Evolution remains downstream of real Agency opportunity terminals rather than OOC;
- World/player-safe/actor working sets use the shared non-OOC accepted-hash map.

Controlled vertical evidence independently exercises both free-form and Public-d20 fixtures and records zero OOC adjudication/semantic/identity/Agency/Evolution/lived-curation calls or durable mutation while ordinary action paths continue to schedule their original lanes.

### IR-05｜OOC remains one Narrative request and survives history — PASS

The UI calls the existing Conversation/Narrative request path once. It does not add a separate OOC Provider lane.

OOC is rendered distinctly as `OOC / GM 指导` and `GM · OOC`. Session initialization resets the composer selector to `角色行动`; restored history retains per-entry mode labels.

Controlled evidence covers Save, reopen, Restore, OOC regenerate and same-prose action↔OOC replacement currentness.

### IR-06｜Recommendation behavior is safely mode-aware — PASS

`推荐材料构建器.gd` supplies typed recent accepted Conversation and tells the model OOC is GM guidance, not protagonist action or world fact. Output remains the existing exact five `{label,draft}` contract and the existing single opportunity lane.

Recommendation click explicitly selects `角色行动`, fills the exact already-generated draft, focuses the composer and does not send or make a click-time model call.

No current Character projection is added in MW-024; that remains correctly reserved for MW-025.

### IR-07｜Legacy currentness compatibility — PASS

The review specifically checked the owners that previously used accepted hashes/prefixes:

- People identity receipt prefix now delegates to the shared accepted-input prefix;
- World/Knowledge/Agency/Evolution/player-safe projection use the shared non-OOC world hash map;
- Information Curation delegates to the shared prefix;
- Recommender delegates to the shared version material;
- Debug's identity/currentness path remains backed by the same People accepted-prefix seam.

Old action/opening hash material remains byte-compatible. Explicit OOC changes future accepted prefix identity as required, so same Player/GM prose with a different mode cannot accidentally retain displaced semantic/curation/diagnostic currentness.

### IR-08｜Real Provider evidence — PASS_WITH_NOTE

One bounded production Narrative Provider request used Kimi `k3-256k`, completed in 9047 ms with one network attempt, and returned an out-of-character acknowledgement of the requested pacing style rather than inventing a new in-world event or protagonist action.

This is credible evidence that the derived OOC context is understood by the configured model. It is not sufficient evidence for long-session adherence or for how naturally a later normal action follows recent guidance; that remains appropriate Package-2 Owner-UAT evidence.

### IR-09｜Regression and artifact evidence — PASS_WITH_BASELINE_NOTES

Evidence reports:

- focused compatibility contract: 36 / 36;
- controlled vertical: 67 assertions / 0 failures;
- real-window checks at 960×540, 1280×720 and 1920×1080;
- 35/37 direct regression suites passing;
- two failing G3 Context assertions reproduced independently from an exact Formal-Base archive: G3-03 `opaque World JSON is not injected as Game Context` and G3-05 persistence `raw World/Prompt truth leaked into Context`;
- retained known resource-exit warnings in existing suites;
- final Godot import passed;
- fresh Windows export/ValidateExportOnly passed.

The two Context assertions predate MW-024 and are not introduced by the typed-input implementation. They remain tracked Context debt and are not silently relabeled as passing.

### IR-10｜Scope / architecture control — PASS

No new SQLite schema, Provider framework, OOC preference owner, personality classifier, generic Action Intent, Reality Correction, Open Threads, System, Inventory, Dynamic UI or Context Orchestrator was introduced.

The new cross-consumer compatibility seam is bounded to accepted-input mode/version normalization rather than a speculative framework.

## 4. Review notes / retained Product risks

1. The real Provider proof contains one OOC request only. Combined Package-2 UAT must still verify that a subsequent ordinary role action naturally respects recent GM Guidance without treating OOC as world fact.
2. Two known G3 Context assertions remain baseline debt and should not be attributed to MW-024 unless a later Context task changes their behavior.
3. Existing resource-exit warnings remain baseline teardown debt in the suites recorded by the implementation return.
4. Product acceptance is intentionally deferred until MW-025 is integrated; this review grants Engineering acceptance only.

## 5. Independent verdict

**MW-024 = ENGINEERING PASS_WITH_NOTES.**

The typed `action/ooc` foundation, legacy compatibility, OOC Narrative vertical, downstream isolation and mode-aware currentness are sufficiently established for reviewed integration and continuation to MW-025.

Do not declare Package-2 Product PASS until the combined Owner UAT after MW-025.
