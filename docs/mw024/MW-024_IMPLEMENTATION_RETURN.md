# MW-024 Implementation Return

Status: **READY FOR INDEPENDENT REVIEW**
No main merge, Owner installation, or Product PASS declaration.

## Identity and authority

- Branch: `mw-024-ooc-gm-guidance`
- Worktree: `D:/AI/Projects/.worktrees/my-world/mw-024-ooc-gm-guidance`
- Formal product base / refreshed implementation main: `a11af1bb922e5d0637a38bcccfdac27a819c9c1c`
- Starting HEAD: `b9f7f69c6817aacc975d4fbee522fa6bd64be65e`
- Implementation HEAD: `9ca5d49c351f259f9fbf09fb26f4520323ac671d`
- Final candidate HEAD: the documentation-only child containing this return; exact SHA is supplied in the delivery message and verified against the pushed branch. This file cannot embed its own Git object hash.
- Governance main: `15071fcc7a86010adb122553962bac7dc9a47c8f` (refreshed again before submission; unchanged).
- Read repo/governance AGENTS, current status v17.16, roadmap v4.4, frozen G6 Core Interaction Control decision and MW-024 packet. No superseding architecture found.

## Implemented outcome

Composer provides explicit `角色行动` / `OOC / GM 指导`, defaulting to action on activation. The selector is grouped with Send/Cancel to preserve narrow-window Narrative space; all new ordinary text inherits 20px. Recommendation clicks select action, insert the exact draft and never send.

Conversation owns accepted and pending modes. Completion accepts mode and raw prose atomically; failed correction retains accepted truth, regenerate retains mode, and generic persistence carries optional metadata without schema changes. Missing-mode storage remains valid and is not rewritten merely by validation: this is necessary for old immutable Save JSON equality. Read projections normalize missing mode to action/opening.

OOC uses the existing Narrative lane once. Request-only structural wrappers distinguish guidance and GM OOC responses; stored Player/GM bytes are unchanged. Recent OOC uses the existing bounded Conversation context. There is no persisted Narrative Preference.

OOC structurally skips d20, World/Identity, Agency, Evolution and lived Information Curator. Existing initial Character behavior is untouched. Durable unresolved d20 still blocks OOC. The ordinary Recommender can run once after OOC with typed recent context; its output contract remains five label/draft pairs.

## Accepted-version audit

| Owner | Compatibility/currentness behavior |
|---|---|
| Conversation | Optional mode validation, normalized read projection, pending/accepted atomic replacement; legacy immutable Save restoration preserved |
| Context Assembly | Request-only OOC markers; recent12 and ordinary action system behavior preserved |
| World/Knowledge/Agency/Evolution/player-safe projection | Shared non-OOC index-to-GM-hash map; old action hashes unchanged; OOC cannot supply a World source |
| People identity | Shared historical prefix bytes unchanged for legacy/action/opening; explicit OOC discriminator changes prefix |
| Information Curation | Same shared prefix; no lived OOC scheduling |
| Recommendations | Old complete-prefix material unchanged for actions; explicit OOC discriminator; typed bounded model window |
| Debug | Existing identity-prefix token consumes shared seam; no new diagnostic architecture/storage |

The shared pure public seam is `src/domain/L3_外交层/已接受输入公开契约.gd`. Callers use the domain public boundary; no cross-module internal access was added. No SQLite/schema/Provider framework change, keyword router, semantic heuristic or MW-025 context was introduced.

## Validation

Reproducible entry: `pwsh -NoProfile -File tests/mw024/运行场外指导验证.ps1 -Mode Focused|Window|Regressions`.

- Focused contract: **36 checks / 0 failures** (`evidence/mw024-contract.txt`). Covers no-mode reopen and immutable Save, actual legacy World/People/Curator record validity, same-prose action/OOC version difference, raw bytes, retry/correction/failure, mixed durable Save/Restore/reopen.
- Controlled vertical: **67 assertions / 0 failures**, no script error or exit leak (`evidence/mw024-vertical.txt`). Real main/Wizard/Game fixture with both free-form and d20; exact one Narrative request, zero OOC background calls/mutations, recommendation opportunity/click, unresolved durable d20 block, ordinary action continuation, actual Continue, Restore and same-prose mode-replacement stale World/Curator/Recommendation callbacks, displaced Debug lanes.
- Real windows: **960×540, 1280×720, 1920×1080**, both fixture variants; zero failures (`evidence/mw024-window.txt`, six PNGs). Inspected all three free-form screenshots. Mode control >=20px; composer, mode, Send/Cancel and regenerated OOC labels remain usable. Existing MW-023 typography suite also passes.
- Direct regressions: **35 of 37 suites pass**; exact suite results/logs under `evidence/regressions/`. Covers G2, G3, d20, G5 World/identity/Agency/Evolution, MW-003/011/014/015/017/018/019/021/022/023. The runner remains nonzero for the two baseline failures; they were not suppressed.
- Baseline exceptions reproduced from a fresh `git archive` of formal base `a11af1b...` with Godot import: G3-03 `opaque World JSON is not injected as Game Context`; G3-05 persistence `raw World/Prompt truth leaked into Context`. Exact identical assertions: `evidence/baseline-g3_03.txt`, `evidence/baseline-g3_05.txt`. No unrelated Context-debt fix.
- Existing exit resource warnings in g4_08b, g5_03, g5_04 and mw003 are retained in logs (each reports two warning matches); no focused/window leak. Not claimed as newly fixed.
- MW-019 expected model-input dictionaries/24KiB overhead tests now include explicit input_mode; output strictness and exact byte-boundary tests remain intact. A real narrow-layout regression discovered during validation was fixed by composer-local arrangement, without shrinking font or weakening assertions.

## Bounded real Provider

`tests/mw024/运行真实场外指导验证.ps1`: **one** production Narrative adapter network attempt, Kimi `k3-256k`, completed in **9047 ms**. No real d20/World/Curator/Recommender calls. Evidence `real-ooc.json` includes only the fixed isolated request and visible response, no credentials or reasoning.

The response directly acknowledged the pacing guidance and described intended future response style without narrating a new event/protagonist action. This was a manual semantic inspection, not Program classification. No retry/fallback or optional second call. Subsequent real action adherence remains for combined Package 2 UAT; deterministic context propagation is covered.

## Import/export

- Godot **4.7.2 stable official** final import: exit0; no script/parse error (`evidence/final-import.txt`).
- Fresh Windows export via `run-game.ps1 -ValidateExportOnly`: exit0, newly rebuilt, no script/parse/export error (`evidence/final-export.txt`). Exported game never launched.
- Post-implementation-commit validation confirmed the same product input hash; no rebuild needed for the identical content.
- Product input SHA256: `ee1c358e6a9b42fb449ae6a57faefde358674b13ffdf29e876222dd811b496c6`.
- Built at UTC: `2026-09-08T10:12:26.9303975Z`.
- PCK: `build/windows/my-world.pck`, 2510732 bytes, SHA256 `8ecb666846caa9b3aca4f6156a88a6d426c20f8c42f77c8df10dffcba21fa9ab`.
- EXE, PCK and SQLite DLL hashes/times: `evidence/export-artifacts.json`; source freshness: `evidence/my-world.freshness.json`.

## Preservation and residual risks

Owner canonical checkout was not updated or installed. Its local `.gitignore` and ten unknown screenshot/import sidecars remain present. All fixture databases and builds were task-owned. Only task-import-generated sidecars were removed after creation-time and unchanged-hash verification; the cleanup manifest is retained. No reset/clean/force was used.

Residual risks: two reproduced G3 baseline Context assertions and existing exit warnings remain; one real OOC sample does not establish long-session semantic adherence. Owner Product UAT is deferred to the combined Package 2 flow after MW-025, per packet. No claim of Engineering PASS or Product PASS is made.
