# G4-11P1 Independent Review

Status: **PASS / CLOSED**  
Reviewer / semantic owner: **GPT**  
Reviewed: 2026-09-03  
Parent: **G4-11 Two Primary Asset Families Reality Test**

## 1. Reviewed heads

```text
START_HEAD
f1e9c2429ba0f2582532e3215254453eaed9caec

TEST / HARNESS HEAD
522a49dd18f372943db0f70e325675c2eae7b493

EVIDENCE / FINAL HEAD
8a8426b17906f06582ea6503aa7854eaa0ed04de

Governance main reviewed
0a724515d4e588c9d01c125f4403f3063cdd9645
```

Comparison from START_HEAD to FINAL_HEAD contains only:

- `tests/g4_11p1/双族现实准备验证.gd`
- `tests/g4_11p1/双族现实准备验证.gd.uid`
- `tests/g4_11p1/运行双族真实Provider验证.ps1`
- `docs/g4_11/G4-11P1_TWO_FAMILY_REALITY_PREP_EVIDENCE.md`

No production code changed.

## 2. Independent findings

### PASS — production path, not a parallel mini-RPG

The harness instantiates current `src/main.tscn` and drives the existing New Game Wizard, exact Composition, Atomic Final Create, Game Session, Opening/Conversation, Save and Game Library reopen seams.

Only the explicit offline preflight substitutes Provider transport. The required real vertical runs through the current selected-provider path.

### PASS — same selected model profile

The real vertical used the same effective profile for both families:

```text
profile   kimi_k3
provider  kimi
model     k3-256k
context   256k
reasoning high
```

The harness snapshots the runtime model profile before/between/after the two family runs and does not write persisted Runtime Model Settings. No cross-provider fallback is introduced.

### PASS — two independent durable Games

Real Family A and B use distinct Game IDs and distinct SQLite paths. Both completed:

```text
exact Source selection
→ Final Create
→ real Provider Opening accepted durable
→ continuation 1 accepted durable
→ continuation 2 accepted durable
→ named Save
→ close to Main Menu
→ exact Game Library reopen / Continue
→ continuation 3 accepted durable
```

The same Host additionally exercised:

```text
A → B → A → B → A
```

without Session/Game identity crossover.

### PASS — exact Source ancestry and Source-current isolation

The harness records exact World/Character generation fingerprints at creation. It then publishes bounded task-owned newer generations of the same stable Source identities.

Existing Games continue to expose their original World/Character provenance and selected Entry. New-current marker text is excluded from those Games' assembled requests.

This independently confirms that existing Game truth does not follow Source current.

### PASS — cross-family Context isolation

For every Opening and continuation request, the harness checks selected-family identity/T0 markers are present and opposite-family identity/content markers are absent.

This is a Context/source-isolation assertion only. It does **not** require the model response to contain genre keywords or a mandatory prose pattern.

### PASS — Model Freedom First preserved

No production behavior changed and no response-side differentiation gate was added.

The harness does **not** reject a model response for lacking terms such as `赤壁`, `魔法`, `奥维斯塔`, historical vocabulary, fantasy vocabulary, or any prescribed structure. Family-specific checks apply to assembled Source/Context identity, not to free-form narrative acceptance.

Therefore G4-11P1 does not reintroduce:

- genre keyword validators;
- output classifiers;
- mandatory prose formats;
- scripted story beats;
- model-format blocking gates.

### PASS — Owner production safety

The real-provider wrapper fingerprints Owner production Runtime Settings, Source Library, Games, Game Library and legacy current DB before/after execution. The recorded normalized snapshots are equal. Mutable validation state is rooted under task-owned `build/g411/`.

Credential values are neither printed nor committed.

### PASS — visual deferral / no premature G5

No portrait/scene/map resolver, image pipeline, visual acceptance condition, NPC agency engine, faction simulation, event system, relationship state machine, knowledge graph or travel system was added.

G4-10 remains deferred to G6.

## 3. Evidence note — `git diff --check`

The task packet required a final `git diff --check` result. The first blocked evidence draft explicitly planned to record it, but the final evidence update omitted that line.

Independent review treats this as a **non-blocking evidence documentation omission**, not a reason to rerun the expensive real Provider vertical, because:

- the reviewed START→FINAL comparison is only newly added tests/docs;
- no production file changed;
- no reviewed patch exposed a functional or semantic whitespace issue;
- all required runtime/product integrity seams are independently inspectable from committed code and evidence.

Future evidence packets should record the requested command result explicitly.

## 4. Real selected-provider evidence summary

```text
Family A — 汉末三国 / 刘备 / 208 赤壁前夕
Opening             accepted durable
continuations       3 accepted durable
Save/reopen         PASS
exact ancestry      PASS

Family B — 埃瑟维亚 / 莉维娅 / 1287 奥维斯塔
Opening             accepted durable
continuations       3 accepted durable
Save/reopen         PASS
exact ancestry      PASS

A/B isolation       PASS
A→B→A→B→A switch   PASS
opposite Context    absent
Owner mutation      none observed
failures            0
```

## 5. Verdict

```text
G4-11P1 Two-Family Reality Prep / Engineering Proof
PASS / CLOSED
```

This verdict proves engineering reality and isolation only.

It does **not** prove:

```text
TWO WORLDS FEEL MATERIALLY DIFFERENT
G4-11 PRODUCT PASS
G4-GATE PASS
```

Those remain with the Owner.

## 6. Next gate

Activate:

```text
G4-11UAT Owner Two-Family Reality Test
ACTIVE — OWNER
```

Owner product question:

> Do the actual Han / 刘备 and Afterglow / 莉维娅 play experiences clearly feel like two different RPG worlds rather than one generic AI chat with swapped names?

Visual polish is not part of this gate.
