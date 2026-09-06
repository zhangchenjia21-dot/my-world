# MW-015 — Character + Important Experiences Surfaces v0.1 Evidence

Status: READY FOR INDEPENDENT REVIEW
Work Item: MW-015 / Revision 1 / Review-Round 0
Implementer: KimiCode / Reviewer: GPT
Branch: `mw-015-character-important-experiences-ui-v01`
Implementation base: my-world `fdf901bc64c6b182bbaefa566b675480f74bb301`
Governance base: Vibe-Coding `d4a2966e448e5173ef1311c852d31e9ba7f70e26`
Task Packet: `docs/tasks/MW-015_CHARACTER_AND_IMPORTANT_EXPERIENCES_UI_V0_1_TASK.md`

## 1. Scope delivered

Bounded fixed Godot UI consumer only:

- 右侧 World Information Host 导航由 `概览 | 存档` 扩为 **`概览 | 角色 | 重要经历 | 存档`**：
  四个互斥 toggle tab，默认概览，一次只显示一个 Surface，切换是纯可见性操作（零 Runtime mutation）。
- 右侧 chrome `世界` → `信息`（`WorldHeader` 与 narrow 模式 `WorldToggle` 同步改名；节点名未动）。
- 右栏 Surface 内容区包入 `WorldSurfaceScroll`（ScrollContainer）→ `WorldSurfaceColumn`，长内容可滚动；
  `SaveSurface` 与全部 `%Save*`/`%Recover*` 控件及其 G3 owner 完全未动。
- 新 Character / Important Experiences Surface 只消费 MW-014 已审核 player-safe L3 投影 seam
  `src/信息整理/L3_外交层/角色经历投影公开接口.gd` 的 `static project_session(runtime)`。
- 左 Player Status Host 删除 MW-011 过渡 biography/profile/world/recent-actions/turn-count 渲染；
  当前无真实 portrait/mechanics contribution → Host collapse/hide（节点与 `PlayerPanelScroll` 保留），
  narrow 模式下无用的 `PlayerToggle` 不再显示。未造假 HP/属性/立绘。

## 2. Consumed seam（未新增 Runtime authority）

```text
角色经历投影公开接口.project_session(runtime)
→ {"character": {headline, summary, groups[]}, "important_experiences": [{title, description, time_label}]}
```

- 无 ID/出处/hash/内部元数据渲染；`time_label` 仅非空时显示（当前 seam 恒为空，无权威 calendar，不伪造日期）。
- 渲染不触发任何 Provider 调用；投影 fail-closed。
- 未触碰 Runtime / persistence / semantic authority；未实现 Program 语义分类器、Narrative keyword parser、
  importance score、事件规则树或人物语义 special case。
- 未实现 MW-013 Declarative UI Host / Inventory / People / 事务 / 地图 / 系统 / portrait resolver。

## 3. Refresh lifecycle

```text
激活/reopen、semantic lane terminal、Restore/进度切换
→ _refresh_player_safe_panels() → 概览 + Character + Experiences 全量重投影（+ 左 Host 空态判定）

information_curator.finished(result)（MW-015 新增唯一连接）
→ 仅重渲染 Character / Experiences 两个 Surface
→ result 只含 {success, status}；失败/无变化同样安全（投影自动反映 current durable records），不白屏、不 gate 前台
```

## 4. 左 Host 迁移行为

- `_render_player_host()` 清空动态 body、置 `_player_status_has_content = false`（v0.1 恒 false，留扩展点）；
  `_apply_player_host_visibility()` 统一决定 wide/narrow 可见性。
- wide：空 Host 不再强制显示（原 `_update_responsive_layout` 强制 visible=true 已移除）。
- narrow：`_player_status_has_content == false` 时 `PlayerToggle` 隐藏；`WorldToggle`（现名“信息”）行为不变。
- 概览保留 world/entry/主角所知；概览中原有的 `已进行 N 个玩家回合` 行按 packet §8 刻意**删除**——
  recent actions / turn count 不是 v0.1 长期 RPG 信息 Surface，不随左栏清理搬进概览。

## 5. Changed files

```text
src/main.tscn                                      四 tab 导航 + WorldSurfaceScroll/Column + 信息 chrome + 清理重复 layout_mode 行
src/应用壳.gd                                       四态 surface、_surface_body、curator finished 刷新、左 Host collapse、responsive
tests/mw015/角色与重要经历界面测试.gd（新）           focused proof（47 checks）
tests/mw015/运行角色经历界面验证.ps1（新）            focused-first 串行 runner + Windows export
tests/mw009/玩家安全侧栏投影测试.gd                  左栏身份断言按 MW-015 迁移更新；文本收集递归化（隐私断言未动）
tests/mw010/生界一体现实矩阵测试.gd                  仅 _panel_text 文本收集递归化（无任何断言改动）
tests/mw011/G6主机视图模型基线测试.gd                左栏 recent-actions/turn-count 断言按 MW-015 迁移更新；递归化
tests/mw011r2/玩家档案表面测试.gd                    档案渲染断言迁至 Character Surface；随身物品断言改为不出现；递归化
```

无 Runtime/persistence/semantic/Source/SQLite/Public d20/Agency/World Evolution/G5 文件改动。
历史测试更新均在 packet §12「更新历史视觉期望」权限内；隐私（hidden truth / 内部 ID）与
Save/Restore currentness 断言全部保留未弱化。

## 6. Focused proof（`tests/mw015/角色与重要经历界面测试.gd`，47 checks / 0 FAIL）

真实 FinalCreate Game（汉末三国/刘备/孙权 fixtures）+ real main.tscn Shell + real SQLite；Provider 全桩：

1. 导航恰好 `概览|角色|重要经历|存档` 四个互斥 toggle，默认概览；chrome `信息`；Surface 在滚动容器内。
2. 概览保留 world/entry/主角所知；无 `已进行`/`最近行动`。
3. 左 Host 无 biography/profile/recent-actions/turn-count；wide 下 collapse；`_player_status_has_content == false`。
4. Character 初始 = seam 的 frozen profile（本 fixture 无 player_profile → 安静空态文案）；authored groups 不回填。
5. Important Experiences 初始安静空态。
6. 四 tab 轮切后 `world_state`/`active_head_id` 逐字节不变（零 mutation）。
7. accepted turn → curator 请求真实发起 → `finished` 后 Character（`善抚士卒`）/ Experiences（`首巡粮仓`）同回合可见；无伪造日期/回合标签。
8. curator 失败：表面保持 current 投影、不白屏；前台 `begin_turn` 不被 gate。
9. production Restore 到整理前快照 → restored-away Character 材料/经历立即从表面消失。
10. Restore 后重新整理恢复显示；Regenerate 替换 accepted 版本 → 旧 prefix 整理结果 seam 级立即失效、Surface 同步消失。
11. narrow 900px：`信息` toggle 可见、无用的 Player toggle 隐藏、左 Host 保持折叠；toggle 展开右栏；wide 恢复后左 Host 仍折叠。
12. 三个 Surface 文本不含 `local_character_id`/`character.han_end`/`prefix`/`hash`/`schema`/`mutation`/`game_id`/`information_curation`。

## 7. Test commands / results

Runner：`tests/mw015/运行角色经历界面验证.ps1`（串行；`--root` 均在 task-owned `build/mw015/` 下；
进程内清空 DEEPSEEK/KIMI key；real Provider calls = 0）。

```text
focused               exit=0 script_errors=0
mw014                 exit=0 script_errors=0
g304                  exit=0 script_errors=0
g501-materialization  exit=0 script_errors=0
g501-timeline         exit=0 script_errors=0
mw009                 exit=0 script_errors=0
mw011                 exit=0 script_errors=0
mw011r2               exit=0 script_errors=0
mw012                 exit=0 script_errors=0
windows-export        exit=0 errors=0
```

单独验证（GUI 痕迹类，不在严格 runner 的 exit 泄漏门禁内）：

```text
mw010                 failures=0（分支与 base fdf901b 完全一致）
g407b-integration     failures=0（分支与 base 一致）
g407b-layout          failures=0（分支与 base 一致，两侧均干净退出）
```

Exit 时 ObjectDB 泄漏计数与 base 完全一致（pre-existing，非本次引入）：

```text
mw010:            base 4 instances / 1 resource  ==  分支 4 instances / 1 resource
g407b-integration: base 3 instances / 1 resource ==  分支 3 instances / 1 resource
```

mw011r2 在最终注释清理后单独复跑：`done failures=0`。

`git diff --check`：clean。

## 8. Windows export

Runner 内含 `--export-release 'Windows Desktop'`：`exit=0 errors=0`
（产物 `build/mw015/verify-*/windows/my-world.exe`）。

## 9. Remaining risks / notes

- `tests/g2_03_gui驱动测试.gd` 是真实窗口 GUI 测试（不在 headless 回归内）：其断言宽窗口左 Host 可见/最小宽度，
  MW-015 空 Host collapse 后需要未来持有者按新语义更新；且其左栏节点路径在 MW-011R2 引入 `PlayerPanelScroll` 后已陈旧。
  本次未动（属已知视觉期望迁移面）。
- Character Surface 对无 frozen `player_profile` 的老 Game 显示安静空态——与 MW-014 seam 的 fail-closed 语义一致，非回归。
- 左 Host 何时重新出现取决于未来真实 portrait/mechanics consumer；扩展点为 `_player_status_has_content`。
- real Provider calls = 0。
