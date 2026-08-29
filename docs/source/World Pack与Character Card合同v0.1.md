# World Pack 与 Character Card Source 合同 v0.1

Status: implementation contract for G4-02
Manifest: package root 下的 UTF-8 `source.json`

本合同定义 authored pre-game Source，不定义 Managed Source Library、Game-local Reality 或 Runtime State。调用入口是：

`src/source/L3_外交层/Source合同公开接口.gd`

## Shared identity

两类 manifest 都必须提供：

```json
{
  "schema_version": "world_pack.v0.1 | character_card.v0.1",
  "asset_id": "stable.ascii.identity",
  "asset_type": "world_pack | character_card",
  "version": "author-version"
}
```

`generation_fingerprint` 不由作者填写。Program 对 canonical manifest 与全部声明文件 bytes 计算 SHA-256；stable identity/version 相同但内容不同，generation 也不同。

## World Pack

World manifest 另外必须提供：

- `display_name`；
- `world_instructions` 与 `gm_instructions`；
- ordered `source_lore`，至少一项，每项含唯一 `lore_id`、`title`、`content`；
- ordered `entries`，允许空，每项含唯一 `entry_id`、`display_name`、`opening_seed`；
- `authored_assets`，允许空，每项含唯一 `asset_id`、`kind`、package-local `path`；
- 非空 `source_material` object，用于 T0 前参考材料。

`kind` 只接受 `portrait | scene | map | document`。Entry 是 opening seed，不是 beat graph、quest script 或 branching DSL。

## Character Card

Character manifest 另外必须提供：

- `display_name`；
- `public_profile.summary` 与 `public_profile.traits[]`；
- `gm_private_profile.background` 与 `gm_private_profile.drives[]`；
- `portrait.path` 与 `portrait.alt_text`；
- boolean `player_character_supported`。

Character Card 是 reusable Character Source。eligibility 只说明它能否被后续建局选为 Player Character；合同不会把 Character 固定为 player-only，也不承诺 opening appearance。

## File references

- 只能使用 `/` 分隔的 package-local relative path；
- 禁止 absolute path、drive/URI、空路径段、`.`、`..` 与符号链接；
- 声明文件必须存在；
- image：`.png/.jpg/.jpeg/.webp/.svg`；document：`.txt/.md/.json`；
- executable、script、archive 不属于 v0.1 Source content；
- 未声明文件不参与 generation，也不会被 loader 扫描。

## Source / Game boundary

以下事实不属于任何 v0.1 Source，并在任意结构层级 fail-loud：

```text
current Timeline / Save / Conversation / runtime history
current location / relationship / injury / condition
current knowledge / inventory / player-known state
opening appearance guarantee / current Context membership
```

Loader 只读取调用方明确给出的 package path；不安装、不发布、不维护 inventory，不创建 Game，也不调用 Provider。
