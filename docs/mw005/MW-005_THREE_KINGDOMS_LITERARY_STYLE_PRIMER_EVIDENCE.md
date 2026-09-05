# MW-005 — Three Kingdoms Literary Style Primer v0.1 Evidence

Status: READY FOR INDEPENDENT REVIEW  
Work Item: MW-005 — Three Kingdoms Literary Style Primer v0.1  
Capability-Anchor: G4 Primary Source Assets & Local Game  
Owner: Kimi / Reviewer: GPT

```text
Implementation Base:  63262dfe52d9200115544bb0a1f2507795039e33
Implementation SHA:   772fcb7 (rebased onto origin/main@378ac43; pre-rebase 807b01390b24e00d3e33f3aae6f58ddeee369a95)
Evidence SHA:         <this document's own commit; see git log>
Real Provider calls:  0
```

## 1. Identity / fingerprints

```text
asset_id:                      world.han_end.unsettled_realm
asset_type / schema:           world_pack / world_pack.v0.2（未升 v0.3）
version:                       0.2.3-converted.2-full-fidelity-candidate
previous generation:           acea0b2afbaf5305f40456cb93b60c94d536066cee794d75bf5e4b44eebe8a47
new generation:                58966f73dfade50b0aa7536aad38a8840e614016975e8beba0735f7dd14ab443
production library root:       C:/Users/MRVHREVO/AppData/Roaming/Godot/app_userdata/my world/my-world/source-library
authoring package path:        tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定
publish evidence JSON:         build/mw005/production-publish.json (gitignored)
```

## 2. Two-pass audit (packet §6.1)

### Pass 1 — authoring package / asset_id / current generation

- 生产 current metadata 指向 `acea0b2a…`（version `0.2.3-converted.2-full-fidelity-candidate`）。
- `diff -rq` 证明该 managed generation 与仓库内
  `tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定` **字节一致**——该 fixture 即当前已安装
  三国 World Pack 的 authoring package（仓库内唯一候选；g4_05 的简化 fixture 不含 sections/entries/history，不匹配）。
- 发布脚本运行前再次以 `get_current_world` revalidate 确认 previous fingerprint。

### Pass 2 — World semantic_sections / frozen source_projection consumers

审计 src/ 全部消费者（grep semantic_sections / source_projection / section_type）：

| Consumer | 结论 |
|---|---|
| `游戏本地开场上下文投影器.gd` `project()`（opening + ordinary GM Narrative） | 预期消费者；此前所有 section 以同一事实框架渲染 → 本次在此加非事实边界分离 |
| 同文件 `project_world_only()`（G5-04 evaluator baseline） | 此前无 section_type 过滤 → 本次显式整类排除 |
| `世界回合上下文投影器.gd` | 只读 `living_world.*` durable records，不碰 source_projection → 不受影响 |
| G5-01 语义物化 / G5-02 Knowledge / G5-03 Agency cycle+scheduler | 只读 accepted 文本 / roster / character-card sections → World section 永不进入 |
| `公开D20行动判定流程.gd` | 经同一 `project()` 取 GM context（GM 叙事路径，可接受）；rules 文本只读 Expansion sections |
| `原子最终建局流程.gd` / `建局公开接口.gd` | 冻结/校验 exact generation；不解释 section 内容为事实 |
| `Source合同规则.gd` | section_type 为开放 safe token，无白名单；disclosure 白名单 `[gm_reference, gm_private]` 均合法；fingerprint = canonical manifest JSON + 全部 contract-owned 文件字节 |

结论：唯一需要修改的 seam 是 `游戏本地开场上下文投影器.gd`；不需要 schema v0.3 / 平台 / 其它消费者改动。

## 3. Implementation

- Package：`semantic_sections` 追加
  `{section_id: literary-style-reference, section_type: literary_style_reference,
   disclosure: gm_reference, content_path: sections/11_literary_style_reference.md}`；
  内容文件为 `docs/tasks/inputs/MW-005_THREE_KINGDOMS_STYLE_PRIMER_V0_1.txt` 的**逐字节副本**。
- `游戏本地开场上下文投影器.gd`：
  - `_append_sections(..., include_style=true)`：style sections 不再与事实性 World sections 混排，
    归入独立边界块（`## Literary Style Reference | 文学风格参考（非世界事实）` + 显式声明
    “不构成当前 Game 的世界事实或既定未来 / 不是 Knowledge / 不是因果推演依据”）；
  - `project_world_only()` 以 `include_style=false` 调用，整类排除；
  - 无 parser / classifier / output gate / retry 协议改动。
- 发布：`scripts/MW-005_三国文风Primer生产Source发布.gd`（G4-09P1 同款 Owner 确认参数守卫），
  经 `Source库公开接口.install_world_pack` 发布新 immutable exact generation 并推进 current；
  旧 generation `acea0b2a…` 保持 immutable exact 可取（脚本内断言）。
  透明记录：首次带确认运行时 evidence 路径写法导致收尾失败，但 install 已原子完成；
  修正后以幂等 `already_published` 分支重跑补齐 evidence，最终状态一致。

## 4. Changed files

```text
src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd        (改：边界投影 + world-only 排除)
tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定/source.json   (改：+1 section 声明)
tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定/sections/11_literary_style_reference.md  (新)
scripts/MW-005_三国文风Primer生产Source发布.gd            (新，confirmation-guarded)
tests/mw005/三国文风Primer接线测试.gd                     (新，focused)
```

## 5. Focused proof（tests/mw005，41 PASS / 0 FAIL）

```text
命令: godot --headless --path <repo> --script res://tests/mw005/三国文风Primer接线测试.gd -- --root=<repo>/build/mw005_primer
结果: MW-005 PRIMER | done failures=0  (41 PASS)
```

覆盖 packet §9 全部要求：

1. world_pack.v0.2 接受/保留 literary_style_reference；内容 == 批准输入逐字节；fingerprint 变化；
   且**去掉该 section 后精确还原旧 production generation**（stripped fingerprint == `acea0b2a…`）。
2. new Game 冻结含 Primer 的 generation（provenance == `58966f73…`），不查询 Source current。
3. ordinary GM context：边界头存在、显式否认事实/未来权威、Primer marker 恰好一次、位于边界之后、
   事实 sections 仍在边界之前。
4. first opening 走真实 `首次开场公开接口` + stub Provider，Provider-visible messages 含边界与 Primer 一次。
5. `project_world_only()`：无 Primer 内容、无 `literary_style_reference` token、无边界头；事实 sections 仍在。
6. old Game（冻结旧 generation）：Source current 前进到 Primer generation 后 provenance 不变、
   投影无 Primer、无静默注入；同库之后创建的 new Game 才冻结新 generation。
7. 未新增 Narrative 输出协议/gate——changed files 仅上述 5 项，无任何输出解析/拒绝路径。

## 6. Minimal regressions（全部串行、stubbed、0 real Provider calls）

```text
g4_02r1 Source_v0_2_r2_机制现实测试     --work-root=build/g4_02r1_recheck      done failures=0 (73 PASS)
g4_02r1 Source_v0_2_r2_负向测试         --work-root=build/g4_02r1_neg_recheck  done failures=0
g4_02r1 Source可选时态范围证据测试       (无参)                                done failures=0
g4_03  Source库现实测试                 --work-root=build/g4_03_recheck        done failures=0
g4_05  应用新游戏向导现实测试            --root=build/g4_05_recheck             done failures=0
g4_06  原子最终建局现实测试              --root=build/g4_06_recheck             done failures=0
g4_07a 首次开场运行时聚焦测试            --root=build/g4_07a_recheck            done failures=0
g4_07b 可玩界面整合测试                 --root=build/g4_07b_recheck            done failures=0
g5_04  选择性世界演化评估测试            --root=build/g5_04_recheck             done failures=0
g2_05  上下文组装离线测试               (无参)                                failures=2 — PRE-EXISTING
```

`g2_05` 的 M1/M7 两项失败在未含本任务的 clean HEAD（git stash 验证）上完全相同，
为 baseline 既有失败，与 MW-005 无关。

## 7. Export / hygiene

```text
run-game.ps1 -ValidateExportOnly → Windows export rebuilt and verified against the current checkout（未启动游戏）
git diff --check → clean
```

## 8. Old/new Game freeze 证明（生产语义）

- new Game：final-create 后 durable setup 的 `world.provenance.generation_fingerprint == 58966f73…`，
  frozen `source_projection.semantic_sections` 含 style section 全文；之后把 current 推进到旧
  generation，重读 DB 冻结 setup 仍含 Primer、provenance 不变。
- old Game：在旧 generation（stripped == `acea0b2a…`）上建局，Source current 前进到 Primer
  generation 后，重开投影无 Primer、无边界头、provenance 仍为旧 fingerprint。

## 9. Remaining risks / notes

- Primer 对文风的产品效果只能由 Owner A/B UAT 判断；自动化只证明接线与 authority separation。
- `公开D20行动判定流程` 的 GM context 同样经 `project()`，会带着边界头看到 Primer——
  属 GM 叙事路径的预期消费者；control 阶段的机制文本不受影响。
- g2_05 两项 baseline 失败建议另行立项排查（不属本任务范围）。
- MW-005 不关 G5-04（Owner UAT 仍 paused）、不推进 G6、不授权 G5-05。
