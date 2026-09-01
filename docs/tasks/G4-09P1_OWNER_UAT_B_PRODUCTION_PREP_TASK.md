# G4-09P1 — Owner UAT B Production Preparation

Status: **ACTIVE — CODEX**  
Parent: **G4-09 First Playable B: Add Real Expansion**  
Primary owner: **Codex**  
Reviewer: **GPT**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Formal Code Base:

`08287d28a9cacfc7795c7c7a35ef4739ff9faf2c`

Accepted UI review:

`docs/g4_08b/G4-08BC01_INDEPENDENT_REVIEW.md`

## 1. Purpose

Prepare the Owner's real local product environment for First Playable B without asking the Owner to manipulate the managed Source Library manually.

G4-09 product target:

```text
accepted World + Character route
+ exact real Public d20 Expansion
→ New Game
→ exact binding
→ real DeepSeek play
→ observable Public d20 effect
→ Save / Main Menu / Continue
→ Owner UAT B
```

This task is preparation only. Codex does not declare Product PASS.

## 2. Required production Source state

Owner production Source Library is the existing default managed root:

```text
user://my-world/source-library
```

Use only the existing `SourceLibrary` public install API. Do not copy files directly into managed generations/current pointers.

Install/verify the frozen real Expansion package:

```text
Display Name  判定与检定：公开 d20
asset_id      exp.check_core.public_d20
asset_type    expansion_pack
schema        expansion_pack.v0.1
capability    action_check.public_d20.v1
slot          action_resolution
```

Current repository package authority for this first real Expansion is the exact validated package already used by G4-08M1/G4-08B evidence:

`res://tests/fixtures/g4_08m1/判定与检定_公开d20`

If the production library already contains the exact same immutable generation, verify/reuse it; do not create destructive duplicates and do not delete prior generations.

Do not change existing Owner World/Character current generations merely to satisfy this task.

## 3. Safe bootstrap requirement

The Owner must not be instructed to browse to `%APPDATA%` and manually copy package files.

Use or add the smallest explicit local preparation utility needed to invoke:

```gdscript
SourceLibrary.install_expansion_pack(package_path)
```

against the default production root.

A narrow task/owner-prep script is acceptable. It must:

- be explicit and opt-in;
- use the public Managed Library API;
- be idempotent for an already installed exact generation;
- never delete or rewrite existing Owner games;
- never expose secrets;
- never scan arbitrary folders;
- not become a generic Source import UI or G8 feature.

## 4. Production inventory evidence

After preparation, verify through the public Source Library API that the Owner production inventory includes:

- existing usable World generations;
- existing usable Character generations;
- Public d20 as an Expansion current/exact generation.

Record exact Public d20 identity/version/fingerprint in task evidence.

Do not claim exact World/Character counts unless the current production library actually reports them. This task must not destroy or normalize Owner content just to match historical test counts.

## 5. Owner launch freshness

Run the existing canonical Owner launch freshness path in validation mode:

```powershell
.\run-game.ps1 -ValidateExportOnly
```

Requirements:

- current checkout product inputs produce/validate the Windows export;
- stale export cannot be launched;
- `.env.local` secret values are never printed;
- current export includes the accepted G4-08B/BC01 UI code.

Do not replace the canonical launcher with another Owner launch path.

## 6. Pre-UAT smoke

Using task-owned data, keep the accepted automated/real vertical evidence green enough to prove the prepared checkout still supports:

```text
Public d20 selected
→ CHECK_REQUIRED observable card
→ Program-owned result
→ GM continuation
→ ordinary NO_CHECK action has no dice card
```

A new real DeepSeek call is not required if no Provider-facing semantics changed after the accepted G4-08B evidence. Explain whether it was rerun.

## 7. Owner UAT packet preparation

Create/update a concise Owner UAT B instruction record under `docs/g4_09/` that tells the Owner only the product actions to perform, not internal implementation steps.

Required UAT route:

1. launch through `run-game.cmd`;
2. choose New Game;
3. use the accepted Han baseline, preferably:
   - World: `汉末三国：天下未定`;
   - Entry: `208 / 赤壁前夕`;
   - Player: `刘备`;
   - optional guaranteed NPC: `孙权`;
   - Expansion: `判定与检定：公开 d20`;
4. verify Review visibly lists the Expansion;
5. create the Game and complete the real DeepSeek Opening;
6. perform at least one genuinely risky action where uncertainty + meaningful failure stakes exist;
7. observe a public d20 mechanic card and confirm the GM continuation respects its outcome;
8. perform at least one ordinary/no-risk action and confirm no dice card appears merely because the Expansion is enabled;
9. Save → Main Menu → Continue and confirm the same Game/history/mechanic result remains;
10. return a Product verdict focused on whether the Expansion **adds worthwhile gameplay**, not merely whether it functions technically.

Owner verdict format should be minimal:

```text
PASS
```

or:

```text
FAIL
<what felt wrong / what broke>
```

## 8. Protected boundaries

Do not redesign or expand:

- Public d20 rules;
- Source schema;
- Composition semantics;
- Final Create;
- persistence schema;
- Provider protocol;
- Wizard/Narrative product design already accepted in G4-08B;
- arbitrary Source import UI;
- G5/G6 systems.

If production prep exposes a concrete defect, stop and report the exact seam instead of hiding it with manual filesystem surgery.

## 9. Required evidence

Return after pushing any required prep utility/UAT docs and completing local preparation:

```text
START_HEAD
IMPLEMENTATION_HEAD / EVIDENCE_HEAD
changed paths
production Source bootstrap method
Public d20 exact installed identity/version/fingerprint
production inventory verification result
Owner games modified: no
run-game freshness validation result
real Provider rerun: yes/no and why
Owner UAT B instruction path
```

Return ceiling:

> **READY FOR INDEPENDENT REVIEW**

Do not declare G4-09 PASS, G4-08 Product PASS, or Owner UAT PASS.
