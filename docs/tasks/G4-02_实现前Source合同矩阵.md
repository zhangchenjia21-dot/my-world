---
title: my world｜G4-02 实现前 Source 合同矩阵
status: task-scoped-engineering-evidence
task_id: G4-02
created: 2026-08-29
updated: 2026-08-29
---

# G4-02｜实现前 Source 合同矩阵

## 1. 合同边界

本增量只定义并验证显式 package path 下的两类 authored Source：

```text
World Pack v0.1
Character Card v0.1
```

Program 从 manifest 与声明文件的真实 bytes 派生 exact generation。Source package 在创作期间可以修改；一旦由后续 Library 发布为某一 generation，内容不可变。本任务不实现发布、安装、inventory 或 generation retention。

## 2. Shared identity seam

| Fact / field | 来源 | 基数 | 验证规则 | Canonical owner | 创作时可变 | Game-local Runtime state | Fingerprint |
|---|---|---:|---|---|---|---|---|
| `schema_version` | authored | 1 | 仅接受对应 `*.v0.1` 常量 | 对应 Source contract | YES | NO；只用于 Source 合同解释 | YES |
| `asset_id` | authored | 1 | 非空、稳定 ASCII `a-z0-9._-`，最长 128 | Source author / contract | YES | NO；后续只 pin provenance | YES |
| `asset_type` | authored | 1 | 精确为 `world_pack` 或 `character_card` | Source contract | YES | NO | YES |
| `version` | authored | 1 | 非空作者版本，最长 64；不充当 generation | Source author | YES | NO；后续可记录 provenance | YES |
| `generation_fingerprint` | program-derived | 1 | SHA-256 lowercase hex；作者不得提供同名 authority | Program | NO | NO；后续 Game 可 pin exact generation | 派生结果 |

共享层不得出现 World lore、Entry、Character profile 或 eligibility 字段。

## 3. World Pack v0.1

| Fact / field | 来源 | 基数 | 验证规则 | Canonical owner | 创作时可变 | Game-local Runtime state | Fingerprint |
|---|---|---:|---|---|---|---|---|
| `display_name` | authored | 1 | 非空，最长 120 | World Source | YES | NO；后续可复制为 provenance/display | YES |
| `world_instructions` | authored | 1 | 非空文本 | World Source | YES | NO；是 T0 前参考材料 | YES |
| `gm_instructions` | authored | 1 | 非空文本 | World Source | YES | NO；不等于当前 Context | YES |
| `source_lore[]` | authored ordered | 1..N | 每项 `lore_id/title/content` 非空；`lore_id` 唯一 | World Source | YES | NO；顺序属于 authored meaning | YES，含顺序 |
| `entries[]` | authored ordered | 0..N | 每项 `entry_id/display_name/opening_seed` 非空；`entry_id` 唯一 | World Source | YES | NO；只是 lightweight T0 seed | YES，含顺序 |
| `authored_assets[]` | authored | 0..N | 每项 `asset_id/kind/path`；ID/path 唯一；kind 仅 `portrait/scene/map/document` | World Source | YES | NO；本任务不做 runtime resolution | YES，声明与 bytes |
| `source_material` | authored object | 1 | 非空 plain JSON object；只表达 pre-game source material | World Source | YES | NO；不得成为 live World truth | YES |

World 顶层采用 allowlist。`current_timeline_head`、`save_state`、`current_conversation`、`runtime_history` 等字段因此 fail-loud；不建立 Beat graph、Quest DSL 或事件引擎。

## 4. Entry / T0

Entry 只提供命名 opening seed。它没有条件、跳转、beat、脚本、执行器或 runtime state；后续 Composition 最多选择一个 Entry，由后续 Final Create 决定如何 materialize。

## 5. Character Card v0.1

| Fact / field | 来源 | 基数 | 验证规则 | Canonical owner | 创作时可变 | Game-local Runtime state | Fingerprint |
|---|---|---:|---|---|---|---|---|
| `display_name` | authored | 1 | 非空，最长 120 | Character Source | YES | NO；后续可复制为 initial definition | YES |
| `public_profile` | authored | 1 | `summary` 非空；`traits` 为 0..N 非空字符串 | Character Source | YES | NO；不是 player-known flag | YES |
| `gm_private_profile` | authored | 1 | `background` 非空；`drives` 为 0..N 非空字符串 | Character Source | YES | NO；不自动进入玩家投影 | YES |
| `portrait` | authored file ref | 1 | `path` 安全、存在且为允许的 image extension；`alt_text` 非空 | Character Source | YES | NO；本任务不解析/缓存图片 | YES，声明与 bytes |
| `player_character_supported` | authored | 1 | 必须是 bool | Character Source | YES | NO；只表达未来建局 eligibility | YES |

Character 顶层采用 allowlist，所以 `current_location/current_relationship/current_injury/current_condition/current_knowledge/current_inventory/player_known/opening_appearance/current_context_membership` 均被拒绝。有效 Character 不需要这些字段，也不携带旧 `bound_only/opening_character/player_character` role taxonomy。

## 6. Path / file validation

| 情形 | 决策 |
|---|---|
| package root | 由调用方显式给出；loader 不扫描 Library 或默认目录 |
| manifest | package root 下固定 `source.json`，UTF-8 JSON object |
| relative path | 只接受 `/` 分隔、非空、非 absolute、无 drive/URI、无 `.`/`..` segment |
| containment | lexical normalize 后必须仍位于 package root；缺失或目录引用 fail-loud |
| executable/script | 只允许图片 `.png/.jpg/.jpeg/.webp/.svg` 与 document `.txt/.md/.json`；其它 extension fail-loud |
| undeclared file | 不参与 contract，也不参与 generation；本任务不做目录 discovery |
| duplicate reference | 同一路径或同一 asset ID fail-loud，避免含义歧义 |

## 7. Exact generation fingerprint

```text
SHA-256(
  canonical manifest JSON
  + each declared file ordered by normalized relative path
  + framed path / byte length / exact file bytes
)
```

- canonical JSON 递归按 object key 排序；array 顺序保留；
- 声明文件按规范 relative path 排序，不依赖 OS directory iteration；
- path、length 与 bytes 使用明确 framing，避免拼接歧义；
- 作者不能提交并覆盖 `generation_fingerprint`；
- 未声明文件不影响 generation，后续 G4-03 也不得把可变外部目录当已发布 generation。

## 8. Failure behavior

所有失败返回结构化 `success=false/code/message`，不修改 package，不生成 identity，不 fallback 到其它 asset type：

- `manifest_missing / manifest_read_failed / malformed_json`；
- `unsupported_schema / unsupported_asset_type`；
- `missing_or_invalid_field / invalid_cardinality / duplicate_id`；
- `unsafe_reference / missing_reference / unsupported_reference_type`；
- `forbidden_source_field`；
- `fingerprint_failed`。

## 9. 分层与 scope 结论

```text
source/L0_公理层  合同常量、字段规则与失败结果
source/L1_器件层  package 文件读取、路径校验、canonical hashing
source/L2_流程层  World 与 Character 各自的完整 load/validate 流程
source/L3_外交层  显式 package path 公开入口与只读 projection
tests/fixtures     真实 compact packages；不属于四层
```

不存在跨现有 Game/Persistence 模块调用，也不需要 SQLite schema、Managed Library topology、New Game UI 或 Expansion 决策。可以进入最小实现。
