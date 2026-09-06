# MW-015 Independent Review — IR#1

Work Item: MW-015 / Revision 1 / Review Round 1  
Reviewer: GPT  
Implementation candidate reviewed: `3387cba213a2680b08f78b07a63ee0ecee5417ce`  
Task base: `fdf901bc64c6b182bbaefa566b675480f74bb301`  
Implementation main observed during review: `11084a9026c507269ba21c4479e501aa0e2fb95f`  
Latest governance main observed during review: `8d6635c2b6e4049f4817a214e914487320b27732`  
Verdict: **ENGINEERING PASS**

## 1. Review basis

Independent Review inspected the pushed branch, exact candidate diff, production Godot scene/shell code, task-owned focused tests, adapted historical regression tests, and committed evidence. The implementer summary alone was not treated as proof.

Primary authorities:

- `docs/tasks/MW-015_CHARACTER_AND_IMPORTANT_EXPERIENCES_UI_V0_1_TASK.md`
- `Vibe-Coding/my world/architecture/ui/G6_SESSION_SHELL_INFORMATION_OWNERSHIP_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_CHARACTER_AND_IMPORTANT_EXPERIENCES_V1_0_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`
- `docs/mw014/MW-014_INDEPENDENT_REVIEW_IR1.md`
- current project status / repository AGENTS.

The implementation branch is one product commit ahead of the MW-015 task base. Current `main` additionally contains only the later routing/governance commit that makes Codex the default implementation agent after MW-015, so the histories are sibling branches and require a merge rather than destructive fast-forward replacement.

## 2. Product / IA compliance

PASS.

The candidate implements exactly the grounded right-side set:

```text
概览 | 角色 | 重要经历 | 存档
```

Default remains `概览`; the four tabs are mutually exclusive presentation state. No ungrounded `人物 / 事务 / 行囊 / 系统 / 地图` tabs or fake RPG state were added.

The right Host chrome is renamed from `世界` to `信息`, matching the frozen World Information Host responsibility.

The left Player Status Host no longer renders identity/profile/world/recent-actions/turn-count filler. Because there is still no legitimate portrait/mechanic contribution, the stable Host node remains in the shell but collapses/hides, and narrow mode suppresses its useless toggle. This matches the frozen IA rather than preserving the MW-011 transitional layout.

## 3. Data-boundary / semantic-authority review

PASS.

Character and Important Experiences consume only the reviewed MW-014 L3 projection:

`src/信息整理/L3_外交层/角色经历投影公开接口.gd`

The UI does not inspect raw `world_state`, parse Narrative, read curation prefix/hash/schema, call Source-current, or invoke Provider during rendering. It does not add a keyword router, importance score, event-type rule tree, Character semantic remapper, or Zhang Chen/Cao Cao/Liu Bei special case.

Therefore the frozen rule remains intact:

> **Model owns semantic interpretation and curation; Program owns normalized storage, temporal integrity and presentation.**

Character renders `headline / summary / groups` in projection order. Important Experiences renders the ordered milestone projection, and displays `time_label` only when the safe seam provides a non-empty value. No calendar precision is fabricated.

## 4. Lifecycle / currentness review

PASS.

The existing full side-panel refresh now rebuilds Overview + Character + Important Experiences at activation/reopen and Restore/current-history changes. MW-015 also subscribes to the existing curator `finished` lifecycle signal and reprojects only Character/Experiences on curator terminal.

This remains presentation-only: curator failure does not clear accepted Narrative, does not gate the next Player action, and leaves the last durable current projection visible.

Regenerate/Player-history replacement and Restore currentness remain owned by MW-014/Runtime; the UI simply reprojects the resulting current seam. No second state store was introduced.

## 5. Responsive / layout review

PASS for Engineering Gate; final visual judgment remains Owner UAT.

The right information surfaces are placed in a dedicated `ScrollContainer` and wrap through existing label helpers. With the empty left Host collapsed, wide layout becomes effectively Narrative + World Information while preserving the architectural Player Status Host for future real consumers. Narrow layout keeps the information toggle and suppresses the useless Player toggle.

The candidate does not redesign the shell into a permanently two-column architecture.

One old standalone GUI test still contains pre-MW-015 expectations that the wide left Host is visible; the implementer correctly did not treat that stale visual expectation as current product authority. This does not block the task because the new focused real-shell test covers the superseding IA and Owner UAT is the final visual gate.

## 6. Test / evidence review

PASS with no GitHub CI status attached; committed local evidence is the executable evidence source.

Recorded evidence reports:

- MW-015 focused real-shell/SQLite suite: **47 checks / 0 failures**;
- MW-014 backend curation regression: PASS;
- G3 Save/Restore regression: PASS;
- G5 semantic materialization/timeline regressions: PASS;
- MW-009 safe projection: PASS;
- MW-011 / MW-011R2 profile and ViewModel regressions: PASS under the intentionally superseded layout expectations;
- MW-012 Zhang Chen integration: PASS;
- additional MW-010 / G4-07B integration/layout checks: no new failures versus base;
- Windows Desktop release export: PASS;
- `git diff --check`: clean;
- render-test Provider calls: 0;
- no SQLite schema/table change.

The adapted MW-011R2 test specifically verifies a real Zhang Chen Game: the frozen headline/summary move to the right Character Surface, authored profile groups are not Program-reclassified, and starting possessions do not leak into Character.

## 7. Non-blocking observations

- Final spacing, information density, tab ergonomics and the subjective quality of the collapsed-left two-column moment cannot be settled by headless assertions; these belong to Owner UAT.
- Character semantic quality remains whatever MW-014/model curation currently projects. UI correctly does not patch semantic imperfections locally.
- The current `main` routing commit occurred while MW-015 was already in flight. Integration must preserve both that routing change and this reviewed UI commit.

## 8. Verdict

**ENGINEERING PASS.**

MW-015 satisfies the requested fixed Godot UI consumer and may be integrated. This is not Product PASS. After integration, the next gate is Owner UAT in the real application.
