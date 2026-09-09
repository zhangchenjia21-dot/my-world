# MW-030｜Independent Review IR1

Status: **ENGINEERING PASS_WITH_NOTES**

Reviewer: GPT  
Work Item: **MW-030｜Internal Dynamic UI Host v0.1 + Model-curated Visibility Preference**  
Formal Code Base: `396bfcc0c91cdff6e6816795826b95fa0c0d358c`  
Task Packet / Starting HEAD: `bd4f2a49f3a44df7aa148d5437e51e90dc18f483`  
Production Implementation HEAD: `2d27860ae2123092d83684523df6a4e0b680c635`  
Submitted Final Candidate: `b1dd4ee9884aaabb0bcd5a702206bde93643f406`  
Frozen architecture: `Vibe-Coding/my world/architecture/ui/G6_INTERNAL_DYNAMIC_UI_HOST_V0_1_DECISION.md@v1.0`

## 1. Freshness / lineage

Independent Review refreshed both current repositories before verdict:

- implementation `my-world/main` remained exactly the Formal Code Base `396bfcc0c91cdff6e6816795826b95fa0c0d358c`;
- governance `Vibe-Coding/main` remained `80c2406067b33818481c6b5576a1c2abbf8f8650`, Status v17.25 / Roadmap v4.8, with MW-030 current and no superseding `my world` product/architecture decision;
- task branch tip was exactly `b1dd4ee9884aaabb0bcd5a702206bde93643f406` and matched the Owner/Codex return;
- `2d27860... → b1dd4ee...` is documentation/evidence only, so reviewed production bytes are the implementation commit.

The historical MW-013 packet/decision remains superseded and was not treated as executable authority.

## 2. Shared Host convergence — PASS

Production Shell now routes all six targeted real information surfaces through the same path:

`safe domain L3 DTO → first-party SurfaceDefinition adapter → validated DynamicHost → Godot Controls`.

Covered production surfaces:

- Character;
- Important Experiences;
- People;
- Open Threads;
- factual Inventory;
- System/Public d20.

The former bespoke People / Threads / Inventory / System renderer files are retired, while Character/Experiences bespoke Shell rendering is replaced by the same shared Host path. This is real renderer convergence, not six wrappers over six independent leaf implementations.

Overview remains imperative, as allowed by the frozen decision. Save, Narrative/composer, Debug and inline d20 remain imperative and their ownership is not absorbed into the Host.

## 3. Definition safety / no second truth — PASS

The internal definition contract is closed to:

- `section`;
- `text`;
- `fact_list`;
- `field_list`;
- `card`.

Validation requires exact fields, safe component tokens, unique component IDs, bounded recursion/component/list/text totals, closed text roles, boolean collapse flags and restricted visibility keys. Unknown kind/field or malformed/oversized contribution fails locally.

No definition field can name or execute arbitrary GDScript callbacks, NodePaths, expressions, SQL/runtime queries, filesystem/OS commands, Provider calls, resource paths or gameplay mutations.

The renderer receives only the already-built definition plus hidden opaque keys. It has no Runtime/world_state/Source/Provider/file-access semantic capability and therefore cannot become a second disclosure/currentness owner.

The fixed `visibility_requested(surface,key,hidden)` signal is Host-owned first-party behavior; definition data cannot supply method names or arbitrary intents.

## 4. Surface semantic preservation — PASS

Independent code/test audit found no semantic redesign in the migration:

- Character keeps current headline/summary/groups and quiet empty states;
- Important Experiences remains sparse milestone history with no Brief Recap/date/turn invention;
- People keeps the current five-field player-known snapshot and default-collapsed cards;
- Threads remains read-only model-curated unresolved matters with no Quest/task controls;
- Inventory remains exact factual possession projection with no item mutation/equipment/stats UI;
- System preserves exact accepted/current Public d20 CHECK facts and does not add NO_CHECK history cards.

The focused vertical independently asserts representative existing content after the migration, including exact System arithmetic, Inventory possession prose, Thread detail, Character groups and People collapse state.

System and Inventory cannot receive visibility keys under the definition contract, so the generic Host cannot accidentally expose hide actions for authoritative mechanics/factual state.

## 5. Presentation identity — PASS

### People

The presentation-specific People projection folds by exact stable Game-local actor identity and derives an opaque key from `[people, game_id, exact_actor_id]`. Raw actor/local ID is not emitted in the presentation DTO or preference sidecar.

Two same-display-name actors receive distinct keys. A later semantic update to the same actor preserves the same key.

### Important Experiences

The presentation-specific experience projection derives its opaque key from `[experience, game_id, validated_curation_record_id, event_ordinal]`.

This uses legitimate validated record identity; it does not use event title equality, rendered text hash or the current visible-list position. Two same-title milestones in one record remain independently controllable.

Original non-presentation model/public projections remain unchanged; presentation keys are not inserted into Curator requests.

## 6. Visibility preference ownership / persistence — PASS

The single presentation-preference owner is a Game-keyed sidecar under `user://my-world/presentation-preferences`, outside SQLite Timeline truth.

Persisted material is limited to schema metadata plus opaque key arrays for `people` and `important_experiences`; semantic card text and raw actor IDs are not stored.

Behavior proven in production wiring / focused tests:

- missing preference file performs no write and defaults visible;
- hide changes only presentation and causes zero Provider/Game/Timeline mutation;
- same-name People and same-title Experiences can be hidden independently;
- hidden People may update semantically while staying hidden;
- hidden drawer renders the then-current safe DTO, not a stored stale copy;
- recover returns current content;
- reopen preserves hide state;
- Restore does not rewind preference bytes;
- a noncurrent underlying item simply disappears, while the same legitimate identity becomes hidden again if it later returns current;
- render/tab navigation causes no preference writes;
- unsupported surfaces/raw invalid keys are rejected;
- existing-file replacement is exercised on Windows.

This satisfies `Hide != delete` and `visibility preference != Timeline truth`.

## 7. Currentness / lifecycle — PASS

The Host stores no currentness state. Every refresh rebuilds from the existing domain-owned player-safe projections.

Focused evidence exercises:

- real Save points;
- Restore before/after current model-curated items;
- accepted Regenerate replacement removing stale People/Experiences/Threads/Inventory material;
- actual session close/reopen;
- preference persistence across reopen independently of Timeline state.

No new SQLite gameplay table/schema or gameplay persistence owner is introduced.

## 8. Test-quality / real-window audit — PASS

The MW-030 focused suite uses production Runtime, SQLite, Shell, domain projections, shared Host and preference owner with controlled existing Provider adapters. It does not replace the feature with a test-only renderer.

High-value assertions include:

- all six production surfaces have the shared Host script and accepted definitions;
- private/raw identifiers and hidden canaries are absent from leaf definitions;
- unknown fields/kinds, duplicate IDs/visibility keys, malformed caps and executable-looking literal text are handled safely;
- People default collapse remains;
- non-hideable domains expose no hide control;
- same-name/same-title identity separation;
- hidden semantic update / recovery currentness;
- zero semantic/provider/durable mutation on hide/recover/render/navigation;
- preference file contains no raw identity/prose;
- Restore, Regenerate and reopen behavior;
- 960×540 / 1280×720 / 1920×1080 effective >=20px text, horizontal bounds, vertical reachability, eight-tab navigation and composer access.

Recorded focused and real-window suites each report **422 checks / 0 failures**. Twenty-four task screenshots support the window evidence; subjective visual quality remains Owner Product evidence rather than an Engineering PASS prerequisite.

## 9. Regression / build audit — PASS_WITH_BASELINE_NOTES

Direct regression batch: **44 suites; 42 pass; 2 fail**.

Retained failures:

- G3-03: `opaque World JSON is not injected as Game Context`;
- G3-05 persistence: `raw World/Prompt truth leaked into Context`.

Both are independently recorded as reproduced on an isolated archive of exact Formal Base `396bfcc0...`; MW-030 does not touch the Context debt and did not suppress/relabel these assertions.

Known teardown/resource warnings remain in the same existing suites and were not expanded into unrelated cleanup.

Godot 4.7.2 final import passes. Fresh Windows export and `run-game.ps1 -ValidateExportOnly` pass. Task-local PCK was freshly rebuilt; reported SHA256 is `622c2e0c7b64b46d031a458e878ca314b589bce5cdd6fa8f0ce5d0f72546bb09`.

Real Provider calls: **0**, appropriate for a presentation-convergence task. No new Provider call is introduced by production code.

## 10. Findings

No blocking engineering defect found.

No frozen-architecture rollback found:

- no second UI/gameplay truth;
- no raw Runtime/world_state leaf filtering;
- no executable UI DSL;
- no external Source/Mod UI contract;
- no generic Action Intent;
- no new semantic domain or Provider lane;
- no text/name/array-position hide identity;
- no Timeline-owned visibility preference;
- no generic hide leaking into System/Inventory;
- no Narrative/Save/Debug/inline-d20 ownership migration.

## 11. Notes / remaining Product evidence

### N-01｜Package-7 Owner Product confirmation is still required

Engineering evidence proves convergence, safety, persistence/currentness and bounded real-window operability. It does not prove that the shared presentation feels equally good across a 20–30 turn real game, or that the hide/recovery UX is subjectively useful rather than cumbersome.

Per current Owner instruction, this Product evidence belongs in the concentrated Package-7 V0 Core Closure Reality Gate.

### N-02｜Validator caps are defensive engineering bounds, not product density targets

The v0.1 maximum component/list/text limits are finite but intentionally generous. They must not be interpreted as a license for first-party adapters to fill the information host to those maxima. Narrative primacy and existing domain bounds remain the effective product-density controls.

### N-03｜Known G3 Context debt remains out of scope

The two exact-baseline Context assertions remain retained debt for later Context work. Do not interrupt the current Core-first closure route with unrelated repair.

## 12. Verdict

**ENGINEERING PASS_WITH_NOTES**

MW-030 is safe to integrate by non-force fast-forward from the exact Formal Code Base through this reviewed branch lineage.

This verdict does **not** claim Product PASS. Proper post-integration state:

> **Package 6 / MW-030 = ENGINEERING PASS_WITH_NOTES / INTEGRATED / PRODUCT CONFIRMATION DEFERRED TO PACKAGE 7**

Next route item after reviewed integration: **Package 7｜V0 Core Closure Reality Gate**.