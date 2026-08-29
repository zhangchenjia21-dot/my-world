# G4-05 建局 Composition 与真实资产转换矩阵

Status: implementation input
Task: G4-05 Asset-only New Game Wizard v0.1

## A. Wizard / Composition matrix

Composition 是 Application lifetime 内的建局意图，不是 Game truth；关闭向导回主菜单即丢弃。所有 Source 选择在玩家点击具体条目时复制 exact identity：`asset_type + asset_id + version + generation_fingerprint`。列表可见、键盘焦点和第一行高亮均不写入 Composition。

| Step / intent | visible choices | authoritative selection / validation | upstream clear | Review projection | durable side effect | back / cancel |
|---|---|---|---|---|---|---|
| World | Managed Source Library 当前 World inventory | 明确点击后保存 exact generation；离开步骤要求 exactly 1 | 重选 World 清除 Entry；不改 Character | 名称、version、fingerprint | NONE | Back 保留；Cancel 清空全部 |
| Entry / T0 | 所选 exact World 的 `entries` + 明确“不指定” | `0..1`；entry_id 必须属于所选 exact World | World 变化即清空 | Entry 名称与 opening seed；或 none | NONE | Back 保留仍有效 Entry |
| Expansion | 当前 vertical 只有“无拓展” | 固定 explicit `[]`，不读取/伪造 Expansion inventory | 不适用 | “未选择拓展（当前阶段）” | NONE | Back 保留空集 |
| Player Character | current Character inventory 中 `player_character_supported=true` | 明确点击 exactly 1 exact generation | 新 Player 与 NPC 重叠时移除对应 NPC | 名称、version、fingerprint | NONE | Back 保留 |
| Guaranteed NPC | current Character inventory 多选 | `0..N` exact generations；不得与 Player exact generation 相同 | Player 重选后只移除重叠 exact generation | 每个 NPC exact identity；不推导开场/关系/knowledge | NONE | Back 保留 |
| Minimal settings | display name、Full/Light/Narrative、opening supplement | 名称 trim 后非空；mode 默认 Light；supplement optional | 无 | 显示完整设置与 supplement presence/content | NONE | Back 保留 |
| Compatibility Review | Composition 的确定性只读投影 | 对每个 selected identity 调 G4-03 exact lookup；missing/tamper/identity mismatch fail-loud；不 fallback current | 无 | G4-06 将收到的 exact intent | NONE | Back 可编辑；按钮明确“下一阶段接入”且 disabled |
| Source X→Y current drift | Chooser 后续可显示 Y，但 Composition 仍保存 X | 未再次点击不得改为 Y；Review exact lookup X | 仅显式 reselection 改变 | 仍显示 X 的 version/fingerprint | NONE | Back 不触发重解析为 current |

### Navigation invariants

- New Game 入口才初始化/读取 Source Library；Application boot 不扫描 Source。
- Next 只由当前步骤验证结果启用；焦点或列表顺序不构成选择。
- Back 保留仍合法的上游意图；World reselection 只清除依赖它的 Entry。
- Cancel 返回 `MENU_READY / Session ABSENT`，释放 UI draft；不创建 SQLite、不写 Game Library、不写 Source Library。
- Review 失败留在 Review 并显示精确失败；玩家回退重选后可重试。

## B. Historical real-asset conversion matrix

Historical repository: `zhangchenjia21-dot/sillytavern-assets`
Pinned snapshot: `4a5364a042e41f4c8a69621fc4467956a78703c0`

转换包根：`tests/fixtures/g4_05/历史真实资产转换/`。旧 Markdown 仅作为语义证据；新包均重新表达为 G4-02 `source.json`，没有 production legacy parser。

| legacy path / blob SHA | family / current package | preserved material and v0.1 mapping | omitted / current-only decision | visual provenance | expected validation/install |
|---|---|---|---|---|---|
| `世界包/汉末三国_天下未定_World_Pack_v0.2.3.md` / `9d05fb2dadad8ea140d611e9f3bab49c0d8f2677` | 汉末三国 / `汉末三国/天下未定` | T0 前冻结/未来开放、历史惯性而非剧本、正史/争议/推断分层、时代尺度与 184/200/208/229 Entry 映射为 instructions/lore/entries/source_material | 旧 frontmatter、扩展建议及旧 Markdown 结构不成为 schema；current-only safe identity added | snapshot 未提供或引用视觉；World v0.1 允许无 authored visual | G4-02 PASS；G4-03 exact managed generation |
| `人物卡/汉末三国/CC-BATCH-01/刘备__Character_Card__v0.1.2.md` / `20c1ff5d01797bdd619644dba37f5eb7dbc2fa8d` | 汉末三国 / `刘备` | 身份、关系信用/政治主体性/韧性、决策条件与知识边界映射到 public/private profiles | 动态官职/所在地不迁入 Source；`player_character_supported=true` 是 current conversion decision，不冒充历史字段 | 历史无视觉；中性 SVG 明示“合同占位，非历史立绘” | G4-02 PASS；G4-03 install PASS |
| `人物卡/汉末三国/CC-BATCH-01/曹操__Character_Card__v0.1.2.md` / `c11f0f75cde326b99e0b1bc6f9ca7940085ff385` | 汉末三国 / `曹操` | 现实组织能力、秩序/人才/风险矛盾、合作/强制处理与情报边界 | 动态控制范围不迁入；eligibility current-only `true` | 同上 | PASS / PASS |
| `人物卡/汉末三国/CC-BATCH-01/孙权__Character_Card__v0.1.2.md` / `285599304931cb422f69a5507558c235214e56ad` | 汉末三国 / `孙权` | 多中心协调、授权/决断、自主外交与知识边界 | 动态继承/外交不迁入；eligibility current-only `true` | 同上 | PASS / PASS |
| `世界包/埃瑟维亚_诸界余辉_World_Pack_v0.1.3.md` / `42924b5c8b18afc7622b8f3c04afc393a69f72e8` | 诸界余辉 / `诸界余辉` | 大断裂后的多国/多族世界、魔法文明与知识边界、断界历 1287、奥维斯塔/边境 Entry 映射 | 旧扩展协议与 Markdown schema 不迁入；current safe identity added | snapshot 未提供或引用视觉；World authored assets empty | PASS / PASS |
| `人物卡/诸界余辉/CC-01_莉维娅·塞兰_Character_Card_v0.2.md` / `78a190e70c6ce7a1ca8f0327734b3eda677632b1` | 诸界余辉 / `莉维娅·塞兰` | 学院法师/教学研究者、理论与现场证据矛盾、事故责任及知识边界 | current-only eligibility `true` | 历史无视觉；中性明确占位 SVG | PASS / PASS |
| `人物卡/诸界余辉/CC-02_阿德里安·维尔克_Character_Card_v0.3.md` / `5ac0daf75ec770555c32c0ca6a48eab31a858489` | 诸界余辉 / `阿德里安·维尔克` | 旁系魔剑士、荣誉/自我掌握/护卫责任、家族情感债与知识边界 | current-only eligibility `true` | 同上 | PASS / PASS |
| `人物卡/诸界余辉/CC-03_杜恩·石痕_Character_Card_v0.3.md` / `57407d5e1714a42e11dee418da9ff54ba553b0c9` | 诸界余辉 / `杜恩·石痕` | 自由猎手/危险路线向导、保护欲与自由矛盾、旧债与边境知识边界 | `player_character_supported=false`：本 vertical 以 NPC 角色证明 eligibility negative path | 同上 | PASS / PASS |

### Contract pressure finding

当前 v0.1 能以 `world_instructions / gm_instructions / source_lore / entries / source_material` 和 public/private Character profiles 承载这两套资料的主要语义压力；不需要修改 G4-02 schema。旧资料里的完整能力表、关系钩子、扩展包建议不能全部结构化，但可作为 profile/source_material 的语义内容保留。建立通用 legacy importer 或 catch-all 顶层字段会引入 schema debt，因此明确不做。

### Conversion verification fields

实现测试会把每个 package 的实际 G4-02 validation result、G4-03 managed fingerprint 与 exact lookup 记录到运行日志。Matrix 中的 expected PASS 只有在真实命令通过后才可在 Final Report 作为完成证据引用。
