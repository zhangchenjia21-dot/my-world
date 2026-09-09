# MW-030 Implementation Return

Status: **READY FOR INDEPENDENT REVIEW**

## Candidate identity

- Branch: `mw-030-internal-dynamic-ui-host`
- Worktree: `D:/AI/Projects/.worktrees/my-world/mw-030-internal-dynamic-ui-host`
- Starting HEAD / Task Packet: `bd4f2a49f3a44df7aa148d5437e51e90dc18f483`
- Formal Code Base / refreshed implementation main: `396bfcc0c91cdff6e6816795826b95fa0c0d358c`
- Refreshed governance main: `80c2406067b33818481c6b5576a1c2abbf8f8650` (Status v17.25 / Roadmap v4.8).
- Production Implementation HEAD: `2d27860ae2123092d83684523df6a4e0b680c635`
- Final candidate HEAD is the documentation/evidence commit containing this report; its exact SHA, remote equality and clean status are returned with delivery. No self-referential commit hash is embedded here.

Only the new MW-030 Packet and Package-6 frozen decisions were executed; MW-013 remains superseded.

## Common Host and boundaries

Character, Important Experiences, People, Open Threads, Inventory and System now use the same validated definition and renderer through Shell `_render_shared_surface`. Former bespoke People/Threads/Inventory/System renderers were retired. Overview, Save, Narrative, composer, Debug and inline dice remain on their existing paths; eight navigation tabs remain unchanged.

The L3 definition adapter receives existing player-safe DTOs only. Leaf renderer receives a validated definition and opaque visibility keys, never Runtime, raw World, actor private material, Provider, file access or semantic authority. No data-supplied callback, NodePath, resource, expression or mutation command exists. Model curation, currentness, Provider calls and gameplay storage semantics are unchanged.

Closed vocabulary: `section`, `text`, `fact_list`, `field_list`, `card`. Validator rejects unknown kinds/fields, duplicate IDs, invalid roles and non-boolean collapsible flags. Bounds: depth 8; components 4096; children/list 1024; strings 8192 Unicode characters; aggregate text 1048576 characters; nonempty ASCII-token IDs up to 128 characters. Text roles are body/heading/muted. Invalid contributions show a local safe unavailable message. Ordinary text is 20px, headings 22px; long text wraps and scrolls.

Only top-level People and Important Experiences cards may carry unique lowercase hex64 visibility keys. Character, Threads, Inventory and System cannot be hidden through this contract.

## Presentation preference ownership

One sidecar owner uses `user://my-world/presentation-preferences`; filename is SHA256 of `visibility|` plus game ID, with `.json` extension. Schema `ui_visibility.v0.1` stores only `hidden_by_surface` opaque-key arrays for `people` and `important_experiences`. Limits: 4096 keys per surface; file 600000 bytes. Tests override Shell `test_presentation_preference_root` into isolated fixtures.

Missing, corrupt or oversized files default to visible without writes. Only explicit hide/recover writes: temporary sibling file, flush/close, then same-directory atomic rename replacement. Windows replacement is exercised. Failure preserves prior preference/memory and gives a safe error. No new SQLite owner/schema, Save payload or model-input field is introduced.

People keys hash JSON `["people", game_id, exact_actor_id]` from the existing validated projection. Experience keys hash JSON `["experience", game_id, validated_record.id, event_ordinal]`. These are presentation identities, not title/name matching; positional component IDs only identify disposable UI tree nodes. Original model/public projections remain unchanged.

Hide/recover changes presentation only. Hidden drawer starts collapsed and permits recovery of current content. Hidden People updates stay hidden. Reopen retains preference; Restore changes semantic projection but never rewinds preference; invalidated future records disappear normally. Same-name People and same-title experiences remain independently controllable. No preference/key enters Curator context.

## Verification

- Focused deterministic: **422 checks, 0 failures**, exit 0; `evidence/focused-results.json` and full log.
- Real-window: **422 checks, 0 failures**, exit 0; 960x540, 1280x720, 1920x1080. Twenty-four screenshots cover all six surfaces and hidden/recovery states. Actual effective font, overflow/range, reachable recovery, collapsed People/drawer, navigation and composer geometry are asserted. No forced empty Player Status Host.
- Focused evidence includes malformed definitions, literal executable-looking text, cap enforcement, canary exclusion, same-title/name separation, hide/update/recovery, real reopen/Restore/Regenerate, explicit I/O failure and zero Provider/durable Game/Timeline writes during rendering/navigation/preference changes.
- Directly affected regressions: **44 suites, 42 exit 0, 2 exit 1**. Full manifest: `evidence/regressions-results.json`. Includes MW-014/015/018/027/028/029/022/023/021/024/025 and G2/G3, plus additional affected mechanics/identity paths.
- Known failure `g3_03`: `opaque World JSON is not injected as Game Context`.
- Known failure `g3_05-persistence`: `raw World/Prompt truth leaked into Context`.
- Both failures reproduced in an isolated git-archive checkout of exact Formal Base `396bfcc0c91cdff6e6816795826b95fa0c0d358c`, with isolated fixture roots and import. See `formal-base-g3-03.txt`, `formal-base-g3-05.txt`, `formal-base-import.txt`. They were not suppressed or repaired; the regression runner honestly exits 1.
- Exit-0 suites g4_08b, g5_03, g5_04 and mw003 each retain two object/resource exit warnings, recorded in manifest. No unrelated cleanup undertaken.
- Godot `4.7.2.stable.official.ed1daf0bf` final import: exit 0, no script/parse/import errors.
- Fresh Windows export and `run-game.ps1 -ValidateExportOnly`: exit 0, no script/parse/export errors; actual PCK rebuilt, fingerprint validated, launch skipped.
- Real Provider calls: **0**. All active Game fixtures and preferences are isolated.

## Build evidence

Artifacts exist and are nonempty under this task worktree's `build/windows`:

| Artifact | Bytes | SHA256 |
| --- | ---: | --- |
| my-world.exe | 103035904 | `5543ab4b6fb453c5dbe7f4effa0aad7f1cc06d73c12e8436adfc9fb266ac34ee` |
| my-world.pck | 2620176 | `622c2e0c7b64b46d031a458e878ca314b589bce5cdd6fa8f0ce5d0f72546bb09` |
| libgdsqlite.windows.template_debug.x86_64.dll | 3163136 | `e3ae3b46b59eadcd513f8d7d6e7c0c15e173696e145594094d7f4f3cc96c7fe7` |

PCK UTC mtime: `2026-09-09T11:15:58.633919+00:00`. Build stamp: `2026-09-09T11:15:59.8178855Z`. Product input fingerprint: `2778a3dd021aadadf1d4a1fde52211ab14bc52723b2a609c1fcf6f10d9df4c0e`. See build-manifest/export-freshness and import/export logs. Documentation-only final commit does not change product inputs.

## Residual evidence and scope

Independent Review and Owner Product/UAT remain pending. Real-window fixtures prove bounded layout/behavior, not subjective long-session Product acceptance. Two exact-base G3 failures and recorded exit warnings remain visible review risks. No real Provider behavior was exercised or added by this presentation-only task.

No main merge, Owner build installation, Owner game launch, or modification of Owner real Game/Source/settings/presentation preferences was performed. Existing Owner local/unknown files were left untouched. No external UI DSL, generic Action Intent, new domain, semantic filter, per-Thread hide or unrelated debt cleanup was added.
