---
title: G4-02R1｜T0-scoped Source Contract Addendum
status: current-semantic-contract-addendum
owner: GPT
created: 2026-08-29
updated: 2026-08-29
base_contract: docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md
revision: v0.2-r2
pressure_audit: docs/source/G4-02R1_SUN_QUAN_HAN_WORLD_T0_PRESSURE_AUDIT.md
supersedes_when_conflicting:
  - base freeze revision 1 §3.4 Entry/T0 behavior
  - base freeze revision 1 §4.5 Character T0/history boundary
  - base freeze revision 1 §7 Context eligibility
---

# G4-02R1｜T0-scoped Source Contract Addendum

本文件与 `World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md` 共同构成当前 **v0.2 revision 2** Source semantic contract。

发生冲突时，本 Addendum 对 T0 / temporal scope / post-T0 context eligibility 拥有更高权威。

Canonical governance decision：

`Vibe-Coding/my world/architecture/source/G4_T0_SCOPED_SOURCE_AND_POST_T0_CANON_QUARANTINE_DECISION.md`

---

## 1. Core invariant

> **Do not show the model a post-T0 answer and then ask it to forget that answer.**

某一 Source package 可以包含多个开局时点的 authored material；但某一局选择 Entry/T0 后，ordinary Runtime 只能使用该 T0 合法的 Source projection。

```text
Source Package Total Content
!= Selected T0 Projection
!= Game-local Reality
!= Runtime Relevant Set
!= Model-visible Working Set
```

---

## 2. Model freedom / narrative quality guardrail

T0 scope 是 Context eligibility / authority contract，不是模型输出 contract。

禁止借本修正增加：

- fixed narrative format/length；
- anti-history state machine；
- “must diverge” rule；
- historical divergence score；
- canon / slight-change / radical-change probability quota；
- personality transition table that replaces model judgment。

T0 projection 必须足够丰富，至少允许保留：

- 当时已经形成的人格、矛盾与压力反应；
- pre-T0 lived experience；
- abilities/limitations；
- existing relationship history/hooks；
- knowledge provenance/boundary；
- social/institutional/geographic pressures；
- open goals, fears, obligations, deliberate blanks。

> **Quarantine future answers; preserve present depth.**

---

## 3. World v0.2-r2 temporal shape

World top-level `semantic_sections` 只承载对该 World 支持范围内各 Entry 都安全的 **always-safe material**。

例如：

- core world ontology/causality；
- source/game boundary；
- truly stable cultural/geographic/institutional foundations；
- general knowledge-source rules；
- non-future GM operating principles。

每个 `entries[]` 除原有：

```json
{
  "entry_id": "...",
  "display_name": "...",
  "opening_seed": "..."
}
```

v0.2-r2 允许增加：

```json
{
  "semantic_sections": [
    {
      "section_id": "...",
      "section_type": "history | society | institution | geography | other",
      "title": "...",
      "disclosure": "gm_reference | gm_private",
      "content_path": "entries/<entry_id>/...md"
    }
  ]
}
```

语义：

```text
World Runtime Source Projection
= top-level always-safe semantic_sections
+ selected Entry.semantic_sections
```

其它 Entry 的 `semantic_sections` 仍属于 immutable Source generation，但对当前 Game ordinary Runtime **not eligible**。

### World hard rule

selected T0 之后的原历史/原作 future outcome 不得藏进 top-level always-safe section。

如果一段 World 内容只在 later Entry 才成为事实，它必须属于 later Entry scope 或 authoring/reference-only material，不得通过 broad `history` section 绕过 quarantine。

### Entry temporal sufficiency｜pressure clarification

`entry_id` / year label 本身不自动证明 T0 足够精确。

如果一个高影响事件会改变当前人物的存在、身份、权力、关系、知识或世界政权状态，而 Entry 没有明确该事件在 T0 时属于：

```text
already-past
vs
still-open-future
```

则：

- Character profile 不得根据年份、display name 或模型常识自行猜测；
- migration 必须优先把既有 Entry 的 T0 cut 澄清到足以形成 deterministic starting snapshot；
- 澄清应使用 event-relative boundary，不要求伪造无可靠依据的精确公历时间；
- 若无法可靠澄清，则不得绑定依赖该事件结果的 Character profile，并必须在 fidelity/compatibility evidence 中显式暴露缺口。

真实压力例：旧 `200｜官渡前夕` 若要绑定“已经接掌江东的孙权”，必须先明确孙策身亡/孙权继承属于该 Entry 的 already-past，而不能只因为 `year=200` 推断。

### Shared past-segment reuse

为了保留长历史材料而不把 later canon 暴露给 early Entry，同一 package-local content file 可以被多个 Entry 重复引用，只要该 material 对所有引用它的 Entry 都已经成为 past。

这允许：

```text
184-to-189 past segment
→ 189 / 196 / 200 / later Entries reuse
```

但一个从 184 已经开始运行的 Game 不会在年份前进时自动获得这些 later Source segments。它们只服务**新建 later-T0 Game**。

---

## 4. Character v0.2-r2 temporal shape

Character top-level `semantic_sections` 只承载对所有可用 T0 都安全的 **always-safe character material**。

对于跨时间变化明显的人物，允许甚至推荐 top-level 只保留很薄的连续性信息；完整人格/能力/关系/知识可以放到 T0 profile。

新增 optional：

```json
{
  "t0_profiles": [
    {
      "profile_id": "han-191",
      "display_name": "191｜初平二年",
      "bindings": [
        {
          "world_asset_id": "world.han_end.unsettled_realm",
          "entry_id": "t0-191-example"
        }
      ],
      "semantic_sections": [
        {
          "section_id": "personality-191",
          "section_type": "personality",
          "title": "191 人格与判断基线",
          "disclosure": "gm_reference",
          "content_path": "t0/han-191/02_personality.md"
        }
      ]
    }
  ]
}
```

`bindings` 是 explicit authored compatibility，不是同-family 推断。

语义：

```text
Character Runtime Source Projection
= top-level always-safe semantic_sections
+ exact matching T0 profile.semantic_sections (if present)
```

### No fallback to future

永远禁止：

- latest profile fallback；
- nearest-year profile fallback；
- later profile fallback；
- complete-life biography fallback；
- display-name / pretrained-history guess。

### Per-World Temporal Profile Coverage Closure｜pressure clarification

真实孙权压力证明：`no matching profile` 不能永远只解释为“资料少一点”，因为 later Entry 可能位于人物死亡之后。

因此采用最小闭包规则，不新增 birth/death lifecycle enum：

```text
若 Character.t0_profiles
存在任意 binding 指向 World W

则在 World W 内：
exact matching Entry binding = authored temporal compatibility
missing Entry binding        = temporally incompatible
```

语义后果：

- 同一 Character 可以显式支持 World W 的部分 Entries；
- 对 World W 未绑定的 Entry，Compatibility Review 必须视为 hard incompatibility，不能只用 always-safe material继续 materialize；
- 这不是 same-family hard restriction，而是该 Character 自己对该 World 声明的 closed temporal coverage；
- 如果 Character 对另一个 World **完全没有任何** profile binding，则仍走 cross-world always-safe-only / Compatibility Review policy，本 Addendum 不因此恢复 family restriction。

这样可以表达：

```text
孙权在汉末三国若支持 184..249
但不绑定 263/280
→ 263/280 对该 Character hard incompatible
```

而无需提前建立 universal `alive/dead/not_born` ontology。

---

## 5. What a T0 profile owns

T0 profile 表达：

> **这个人物在该开局时点已经成为谁。**

可以包含：

- identity/status as of T0；
- personality core and contradictions already formed by T0；
- abilities/limitations already earned by T0；
- behavior/decision tendencies as of T0；
- pre-T0 relationship hooks/history；
- expression style as of T0；
- knowledge/information boundary as of T0；
- private pre-T0 experiences and secrets；
- player-takeover boundary；
- deliberate blanks / open future。

不得包含：

- later personality because “history says he becomes this way”；
- later relationship/status/office；
- later injury/trauma not yet experienced；
- later skill/knowledge not yet earned；
- later historical outcome or death；
- future event as probability target。

---

## 6. Same person across T0 profiles

不同 T0 profile 不是不同 Character identity。

```text
same asset_id
+ same exact Source generation
+ different selected T0 profile
```

仍然是同一个 reusable Character Source 的不同 starting projection。

Stable identity 不得因为 `184 刘备` / `208 刘备` 而复制成多个 logical Character asset。

Profile 只是 temporal starting material，不拥有独立 cross-game identity。

---

## 7. Post-T0 canon quarantine

普通 Runtime 不得检索/注入：

- unselected later World Entry content；
- unselected later Character T0 profile；
- complete-life later biography；
- post-T0 historical outcome/reference as world truth；
- post-T0 authored personality as character truth。

如果 package 未来保留 authoring/reference corpus，该 corpus 必须拥有独立 `reference-only` authority，并且不在 ordinary Runtime section inventory 中。

v0.2-r2 当前不要求 Creator/reference-corpus UI。

---

## 8. Pretrained canon authority

即使 Source 不提供未来，Provider 自身可能知道三国历史或著名作品 canon。

普通 GM Context 保留最短必要 invariant：

> **Post-T0 pretrained/external canon has no authority as current Game fact, character motive or future prediction. Current Game-local Reality and current causality decide the future.**

不要通过列举大量未来事件来实现该规则。

该规则不限制模型的语言表达能力；它只规定 evidence/authority。

---

## 9. No convergence / no divergence target

v0.2-r2 不保存：

```text
probability_of_following_canon
historical_divergence_score
fate_convergence_strength
replacement_event_required
```

当前因果如果自然重现原历史，允许。

当前因果改变后，原历史没有特殊收敛权。

随机性作用于现实中的不确定因素，不直接抽签选择“按不按原历史”。

---

## 10. Exact generation

Generation fingerprint 仍覆盖整个 declared Source package：

- canonical manifest；
- all top-level semantic section files；
- all Entry-scoped section files；
- all Character T0 profile section files；
- authored assets / portrait when present。

**Fingerprint coverage != Runtime visibility.**

一个 Game pin exact generation，是为了可重复得到同一套可选 T0 profiles；不意味着该 Game Context 可以看到 generation 中全部 profile。

---

## 11. Validation requirements for later Codex implementation

Validator/loader 必须可证明：

- safe paths / unique IDs 适用于 nested Entry/profile sections；
- Character `profile_id` package-local unique；
- each binding has nonempty `world_asset_id + entry_id`；
- duplicate exact binding within same Character fails；
- selected T0 projection deterministically excludes unselected profile markers；
- no-match never aliases to current/latest/later profile；
- for a World with declared Character profile coverage, missing selected Entry binding surfaces temporal incompatibility；
- exact fingerprint remains content-sensitive to all declared profile files。

Validator 不负责判断某个 T0 人格写得“像不像孙权”，也不负责从自然语言推断出生/死亡；这是 authored compatibility + content fidelity / Owner UAT。

---

## 12. Real-asset pressure order

在继续批量迁移前：

1. **孙权**：先证明 early/late personality 不倒灌；
2. **汉末三国 World**：先证明不同 Entry 只得到截至该 T0 的 World truth；
3. 再重审刘备、曹操；
4. 再继续诸界余辉固定 1287 Character；
5. 再完成其余 World/Character。

已经落库的 pre-r2 fixtures 是 design evidence，不自动视为最终 v0.2-r2 package；若含 post-T0 future leakage，必须 repair forward。

Pressure audit：

`docs/source/G4-02R1_SUN_QUAN_HAN_WORLD_T0_PRESSURE_AUDIT.md`

---

## 13. UAT consequence

G4-07 First Playable A 必须增加 anti-convergence Product UAT：

- early T0；
- change a historically decisive premise；
- continue multiple high-impact developments；
- verify no canon convergence privilege；
- verify Character growth follows lived history；
- simultaneously verify Narrative/personality richness did not degrade because future canon was quarantined。
