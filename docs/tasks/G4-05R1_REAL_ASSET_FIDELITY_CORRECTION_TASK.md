---
title: my world｜G4-05R1 Historical Real-Asset Fidelity Correction
status: current-correction-task-packet
task_id: G4-05R1
type: implementation-correction
owner: Codex
created: 2026-08-29
updated: 2026-08-29
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: 145c3e1192b443f6284da7f36aee74619adad5bf
parent_task: G4-05
parent_task_packet: docs/tasks/G4-05_ASSET_ONLY_NEW_GAME_WIZARD_TASK.md
legacy_real_asset_reference_repo: zhangchenjia21-dot/sillytavern-assets
legacy_real_asset_reference_sha: 4a5364a042e41f4c8a69621fc4467956a78703c0
highest_implementation_status: READY FOR INDEPENDENT REVIEW
owner_uat_required: false
---

# TASK｜G4-05R1｜Historical Real-Asset Fidelity Correction

Type: `implementation-correction`  
Owner: **Codex**  
Base: `zhangchenjia21-dot/my-world/main @ 145c3e1192b443f6284da7f36aee74619adad5bf`

> G4-05 Independent Review 结论：**REWORK**。Wizard / exact Composition / Review 主实现未发现 P0/P1；本 correction 只修复“历史真实资产被高度摘要化，未真正承担 real-content/complexity pressure”这一 P1。不得开始 G4-06。

## 1. Independent Review Finding

原 G4-05 Task Packet 要求：

- historical assets 是 **primary Reality pressure**；
- `Migrate real content/complexity, not legacy schema debt.`；
- **不得为了转换方便把历史 lore 改写成 synthetic summary**；
- 若重要真实内容无法在 current v0.1 中合理表达，应报告 contract pressure，而不是用摘要规避。

当前 `145c3e1` 的 Wizard/Composition 工程路径基本成立，但 converted packages 把大型真实 World / Character 文档压缩成少量概述。例如：

- `汉末三国_天下未定_World_Pack_v0.2.3.md` 的世界定位、社会/制度/历史资料、T0、地理、物质文化、GM 使用边界等复杂内容被压缩为少数 instructions/lore 条目；
- 刘备等 Character 原卡中的能力与局限、决策行为、关系与自主性、语言表现、知识边界、历史/T0 使用边界等被压缩成一个 summary/background 与少量 traits/drives。

这可以证明“一个根据真实资产写出来的 compact fixture 能通过 contract”，但不能证明 **current Source contract + Managed Library + Wizard 真能承载真实资产复杂性**。

因此 G4-05 尚未关闭，G4-06 继续 HOLD。

## 2. Outcome

修正后：

```text
historical real asset snapshot
→ section-level semantic mapping
→ content-faithful current v0.1 Source package
→ G4-02 production validation
→ G4-03 managed install / exact lookup
→ G4-05 Wizard / exact Composition / Review
```

必须让两套历史资产族的**真实 GM-useful 内容复杂性**进入 current packages，而不是只留下 Agent-written summaries。

## 3. Authority / Read First

按顺序读取：

1. `AGENTS.md`
2. `docs/tasks/G4-05_ASSET_ONLY_NEW_GAME_WIZARD_TASK.md`
3. 本 correction packet
4. `docs/tasks/G4-05_建局Composition与真实资产转换矩阵.md`
5. current G4-02 World/Character contract + loader
6. current G4-03 Source Library seam/tests
7. `tests/g4_05/历史真实资产转换现实测试.gd`
8. historical source snapshot `zhangchenjia21-dot/sillytavern-assets@4a5364a042e41f4c8a69621fc4467956a78703c0`

至少重新读取：

- `世界包/汉末三国_天下未定_World_Pack_v0.2.3.md`
- `世界包/埃瑟维亚_诸界余辉_World_Pack_v0.1.3.md`
- 已转换的 6 张 Character 原卡。

Historical repo 仍为 read-only evidence，不得修改，也不得建立 production legacy importer。

## 4. Narrow Scope

### Required

1. **重做 2 World + 6 Character converted packages 的内容映射**，保留真实资产的 substantive GM-useful semantics / complexity。
2. 把 conversion matrix 从“主题摘要”升级为 **section-level mapping / omission audit**。
3. 增加 fidelity evidence，证明不是只凭 package 数量和 load/install PASS。
4. 保持现有 Wizard / Composition / Review 语义与 G4-01..04 regression。

### Prohibited

- G4-06 Final Create / Game DB creation / Source pin / materialization；
- Provider；
- Expansion；
- Runtime Asset Resolution；
- generic legacy importer / migration framework；
- 为旧 Markdown 建 production parser；
- 为了“看起来更完整”引入 live Game state；
- 推倒当前已通过审查的 Wizard/Composition 主结构。

## 5. Fidelity Rules

### 5.1 World Pack

对每个历史 World，matrix 必须列出原文主要 GM-useful section，并逐项标记：

```text
legacy section
→ current owner field
→ preserved / intentionally omitted
→ omission reason
→ representative content anchor
```

要求：

- 不能只保留 4–5 个概括主题；
- 世界定位、运行原则/T0、社会/制度/历史/地理/物质文化/知识边界/GM 使用边界等**只要属于 current World Source owner，就应实质保留**；
- 可以去掉 frontmatter、Revision Notes、旧宿主/旧扩展协议机械说明、明显重复文本，以及明确属于 Expansion/Runtime live truth 的内容；
- `source_material` 可以承载 contract-owned 的丰富结构化 pre-game material，不要把它只当 provenance metadata；
- 不要求逐字复制整个旧 Markdown，但不得通过高度总结丢失真实使用深度。

### 5.2 Character Card

对每张 Character，至少审计并实质保留原卡中属于 reusable Character Source 的：

- identity / public positioning；
- personality core / contradictions；
- abilities + limitations（语义，不是 live stats）；
- decision / behavior logic；
- relationship style / autonomy；
- language / expression guidance；
- knowledge / information boundary；
- T0 / historical-use boundary；
- 其它稳定、非 live 的 GM-useful authored material。

Current v0.1 只有 public/private profile + traits/drives，这些字段允许长文本/字符串数组；**先用现有 contract 忠实承载**。不要因为结构较薄就把内容压缩成一句摘要。

动态官职、当前位置、当前关系、当前伤病、当前知识、当前 inventory 等仍不得进入 Source。

### 5.3 Contract pressure

如果完整、合理映射后仍出现一个重要稳定 Character/World Source 概念无法表达：

- 先记录 exact source section + current contract gap；
- 不得塞入 live-state 或 generic catch-all 顶层字段；
- 若确实需要修改 G4-02 contract，停止扩大 correction，返回 `BLOCKED` 并给出最小 contract decision；
- 不自行建设兼容层森林。

## 6. Fidelity Evidence

更新/新增测试，使 evidence 不再只有：

```text
2 World + 6 Character
+ contract load PASS
+ library install PASS
```

至少增加一个 task-owned fidelity audit，要求：

- 每个 converted asset 有固定 legacy path + blob SHA；
- matrix 中列出的 required semantic sections 均有 current mapping；
- 为每个 World / Character 维护若干 **source-derived content anchors / section expectations**，测试验证这些内容真实存在于 current package，而不是只验证 asset_id；
- 两套 World 必须证明多个不同类别的真实材料被保留；
- Character 必须覆盖上面列出的 personality / ability-limitation / behavior / relationship-autonomy / language / knowledge / T0 等类别；
- 仍走 G4-02 production loader → G4-03 production install/exact lookup；
- 不用纯长度阈值冒充 fidelity；Independent Review 会抽查原文与 converted package。

可以把 fidelity expectations 放在 task-owned test data/docs；它不是 production schema。

## 7. Acceptance Criteria

全部满足才可返回 `READY FOR INDEPENDENT REVIEW`：

- **AC-R1** 2 个 World 不再是主题摘要型 compact fixture；属于 World Source owner 的主要历史材料有 section-level mapping 与实质内容保留。
- **AC-R2** 6 个 Character 不再只剩 summary/background；稳定 GM-useful Character semantics 按上述类别实质保留。
- **AC-R3** omission audit 明确区分：legacy schema debt / Expansion-owned / live-state / duplicate / truly omitted，并给 reason。
- **AC-R4** current G4-02 contract 能承载则不改 schema；若不能，返回 BLOCKED 而不是绕过。
- **AC-R5** fidelity test/evidence 检查真实 source-derived content anchors/categories，不是只数 package 或验证 load/install。
- **AC-R6** 8 packages 继续通过 G4-02 validation、G4-03 install/exact lookup。
- **AC-R7** Wizard exact selection、X→Y drift、tamper fail-loud、Review、Cancel、no Game DB/Provider regression 全 PASS。
- **AC-R8** G4-01..04 relevant regression PASS；不开始 G4-06。

## 8. Git / Return

开始前 fetch/revalidate `main`。Expected base 是本 correction packet / AGENTS projection 之上的最新 main；audit `145c3e1 → START_HEAD`，只允许已知 correction docs 增量。

完成后 commit + push，并返回：

```text
READY FOR INDEPENDENT REVIEW
Base / Freshness
Fidelity correction summary
World section mapping summary
Character semantic-category mapping summary
Fidelity evidence
G4-02/G4-03/Wizard regressions
Contract pressure findings (NONE or BLOCKED detail)
Scope check
Commit / Final HEAD
```

最高状态：`READY FOR INDEPENDENT REVIEW`。不得声明 G4-05 CLOSED，不得开始 G4-06。
