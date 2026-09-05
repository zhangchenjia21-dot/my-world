# MW-005 Revision 2 — Public d20 Control Lane Style Exclusion Evidence

Status: READY FOR INDEPENDENT REVIEW  
Work Item: MW-005 — Three Kingdoms Literary Style Primer v0.1  
Revision: 2 / Review target: IR#2  
Triggered-By: MW-005 IR#1 F01  
Owner: Kimi / Reviewer: GPT

```text
Revision-1 reviewed main: f7e347ed3b97bed8a036ad9c225aaa28f7e249fe
Implementation SHA:     583dde4d4dc9e4b6f2b82dd5f0cae0960dcc62cc (rebased onto origin/main@2d4ca78; pre-rebase 7a6ae68)
Evidence SHA:           <this document's own commit; see git log>
Real Provider calls:    0
```

## 1. Correction scope (IR#1 F01 only)

Literary Style Reference 可影响 GM Narrative prose，不得进入 Public d20
control / control_recovery mechanics adjudication。Primer bytes、Source
generation、Revision 1 的普通 GM projection、old/new freeze 语义全部保留；
未重新 publish Source generation。

## 2. Implementation（最小 projector/request seam，无 context-policy 平台）

```text
src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd
  project(setup_value, include_style: bool = true) —— 参数透传到 _append_world；
  默认 true，全部既有调用方行为不变
src/首次开场/L3_外交层/游戏本地上下文公开接口.gd
  project(world_state, include_style: bool = true) —— L3 wrapper 同步透传
src/行动判定/L2_流程层/公开D20行动判定流程.gd
  _control_messages() 改以 project(world_state, false) 投影——control 与
  control_recovery 共用此函数，因此两条 mechanics lane 同时排除；
  保留全部 Game/World/Player/Character 事实材料与 Expansion rules text
tests/mw005/公开D20控制文风排除测试.gd（新，focused）
```

未改：decision schema / DC / modifier / RNG / retry / no-reroll / MW-006
grounding / G5-04 / MW-004 / SQLite / Source schema / Narrative output protocol。
未使用 project_world_only() 替代 control context。

## 3. Focused proof — request_assembled(stage, messages) 实际捕获

```text
命令: godot --headless --path <repo> --script res://tests/mw005/公开D20控制文风排除测试.gd \
        -- --root=<repo>/build/mw005_r2_control
结果: MW-005 R2 CONTROL | done failures=0（51 PASS）
```

在冻结的 Primer 三国 Game（Public d20 Expansion 启用）上驱动三条真实 lane：

- **control exclusion**：control request 无 Primer marker（`听弦歌也略知雅意`）、
  无 `literary_style_reference` token、无 `## Literary Style Reference` 边界头；
  同时仍含事实 World section（`world-identity-ownership`）与 Player Character 材料（`刘备`）。
- **control_recovery exclusion**：control 输出不可解析 → 恰好一次 control_recovery，
  同样完全排除三项且保留事实材料。
- **narrative inclusion**：紧随的 `no_check_narrative`、`resolution_narrative`、
  `degraded_narrative`（recovery 耗尽降级路径）各自包含 Primer 恰好一次，
  且 marker 位于非事实文学参考边界头之下。
- **d20 语义不变**：CHECK_REQUIRED 只触发 Program RNG 一次；degraded 路径零 RNG；
  三个行动各 accepted 一次，无 reroll / 无重复。
- **Source fingerprint unchanged**：task-owned 库安装同一 fixture 仍得
  `58966f73dfade50b0aa7536aad38a8840e614016975e8beba0735f7dd14ab443`（测试内断言）；
  Primer bytes 未改（`sections/11_literary_style_reference.md` 不在本 revision diff 中）。

## 4. Consumer matrix 最终状态

```text
first opening                      INCLUDE   (Revision 1, tests/mw005 主测试保持绿)
ordinary continuation GM narrative INCLUDE   (Revision 1, 同上)
Public d20 resolution narrative    INCLUDE   (R2 focused)
Public d20 NO_CHECK narrative      INCLUDE   (R2 focused)
Public d20 degraded narrative      INCLUDE   (R2 focused)
Public d20 control                 EXCLUDE   (R2 focused)
Public d20 control_recovery        EXCLUDE   (R2 focused)
G5-04 project_world_only()         EXCLUDE   (Revision 1, mw005 主测试 + g5_04 回归绿)
```

## 5. Regressions（串行、stubbed、0 real Provider calls）

```text
tests/mw005/三国文风Primer接线测试.gd     --root=build/mw005_primer    done failures=0 (41 PASS)
tests/g4_08m1/公开D20机制测试.gd         --root=build/g4_08m1_recheck  done failures=0（retry/no-reroll/durable）
tests/g4_08b/公开D20界面整合测试.gd       --root=build/g4_08b_recheck    done failures=0
tests/mw006/机制锚定世界后果垂直测试.gd    --root=build/mw006_recheck    done failures=0（MW-006 grounding）
tests/g5_04/选择性世界演化评估测试.gd      --root=build/g5_04_recheck    done failures=0
tests/g4_07a/首次开场运行时聚焦测试.gd     --root=build/g4_07a_recheck   done failures=0
```

## 6. Export / hygiene

```text
run-game.ps1 -ValidateExportOnly → Windows export rebuilt and verified against the current checkout（未启动游戏）
git diff --check → clean
```

## 7. Remaining risks

- control 排除依赖 section_type 分类而非 disclosure；character card 若未来出现
  literary_style_reference section，control 的 Character 材料仍会渲染它（当前三国
  Character 包无此 section；`_append_character` 走默认 include_style=true）。
  如有需要可在后续 revision 同样过滤 character lane。
- 文风产品效果仍待 Owner 在 IR#2 通过后做 A/B UAT。
