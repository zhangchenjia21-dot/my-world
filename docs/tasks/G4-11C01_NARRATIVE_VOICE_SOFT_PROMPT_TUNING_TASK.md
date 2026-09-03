# TASK｜G4-11C01｜Narrative Voice Soft Prompt Tuning

Type: **micro correction / prompt-only**  
Owner: **CODEX**  
Reviewer / semantic owner: **GPT**  
Parent: **G4-11 Two Primary Asset Families Reality Test**  
Prerequisite: **G4-11UAT PASS / CLOSED**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Make one minimal shared-GM-prompt adjustment so the model is explicitly encouraged to let each current World / Character / scene produce its own narrative texture instead of converging toward one generic RPG prose voice.

This is a **soft creative instruction**, not a validation rule.

No standalone Owner UAT is required for this micro-fix. Product effect will be observed in the next suitable UAT.

## 2. Owner finding

Owner accepted that the two G4-11 worlds are materially different, but observed that their narrative prose style is too similar.

Formal result:

```text
World differentiation                    PASS
Cross-world narrative voice convergence  NON-BLOCKING FINDING
```

Do not reinterpret this task as a failure of the two-family product gate.

## 3. Production scope

Expected production change is limited to:

`src/context/上下文组装器.gd`

Specifically, adjust the shared `GM_INSTRUCTIONS` creative guidance. Focused tests/evidence may be added or updated.

If a production change outside this file appears necessary, STOP and return the boundary finding to GPT.

## 4. Frozen soft-prompt intent

The shared instruction should communicate this meaning naturally:

> 让叙述的语言质感自然服从当前 World、Character 与场景：不要把不同世界统一成同一种通用 RPG / 网文旁白；优先让词汇域、句法节奏、观察重点、人物称谓、对话礼法、制度语言与比喻来源从当前 Game Context 自然长出，同时保持清晰、长期可读。不要为了显得不同而机械堆砌古语、奇幻形容词、固定标签或固定模板。

Codex may make small wording edits for clarity, but must preserve the semantics above.

The instruction must remain generic. Do **not** hardcode `汉末三国`、`埃瑟维亚`、`刘备`、`莉维娅` or other family-specific names into the production prompt.

## 5. Protected invariants

### INV-C01-01 — Model Freedom First

The new wording is advisory creative context only.

Do not add:

- required output format;
- required vocabulary;
- genre keyword gates;
- prose-style score/threshold;
- output classifier;
- regex/parser over narrative prose;
- rejection/regeneration because style is judged insufficient;
- automatic retry for style;
- second-model style review.

Any normal free-form narrative remains acceptable under the existing lifecycle.

### INV-C01-02 — No Source mutation

Do not change:

- World Pack / Character Card fixtures;
- `gm_instructions` inside Source packages;
- Source schema/version;
- Source generation/fingerprint behavior;
- existing Game exact Source ancestry.

The purpose of using the Host-level shared instruction is specifically to avoid turning this light narrative-quality change into Source migration/versioning work.

### INV-C01-03 — No runtime/protocol change

Do not change:

- Provider selection or Runtime Model Settings;
- Public d20 protocol/mechanics;
- Conversation acceptance/failure semantics;
- streaming/finalize barrier;
- retry/cancel/fallback policy;
- persistence or SQLite;
- Context turn-retention policy;
- G5 world semantics.

### INV-C01-04 — Opening and continuation stay aligned

Because both ordinary continuation and Opening use `_compose_system_content(...)`, verify that the shared soft instruction reaches both paths without duplication or special-case branching.

### INV-C01-05 — No artificial world-style assertions

Tests may assert the **prompt text/projection**, not the model's prose style.

Do not create tests such as:

```text
Han response must contain X
Fantasy response must contain Y
response must contain ancient words
response must contain magical words
style similarity must be below threshold
```

## 6. Acceptance criteria

### AC-01 Minimal production diff

Production diff is only the shared GM instruction in `src/context/上下文组装器.gd`, unless an existing focused test requires a non-production adjustment.

### AC-02 Prompt projection

Focused tests prove that both:

- `assemble_messages(...)` ordinary continuation path; and
- `assemble_first_opening_messages(...)` Opening path

contain the new soft narrative-voice guidance in the system message.

### AC-03 Existing behavior preserved

Focused Context/Opening/Conversation tests remain green. No output-side style validation or lifecycle behavior is introduced.

### AC-04 No Source / Provider / persistence change

Changed-path review confirms no Source package/schema, Provider, Runtime Model Settings, d20, persistence or G5 production files changed.

### AC-05 Hygiene

Run and record:

```text
git diff --check
```

No real Provider call is required for this micro-fix.

## 7. Evidence

Create a concise evidence document under:

`docs/g4_11/`

Record:

- START_HEAD;
- IMPLEMENTATION_HEAD / FINAL_HEAD;
- exact changed paths;
- focused tests and results;
- `git diff --check` result;
- explicit confirmation that no style gate/classifier/retry was introduced;
- explicit confirmation that no real Provider call or Owner UAT was required.

## 8. Completion boundary

Return only:

```text
READY FOR INDEPENDENT REVIEW
```

Do not declare G4-11 closed, G4-GATE PASS, G4 closed, or G5 started. GPT owns those transitions after review.
