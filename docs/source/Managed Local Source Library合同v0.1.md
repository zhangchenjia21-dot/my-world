# Managed Local Source Library 合同 v0.1

Status: G4-03 production contract
Scope: World Pack + Character Card installed Source truth

## 1. Owner boundary

Managed Source Library 拥有 installed Source inventory、immutable exact generations 与每个 stable identity 的显式 current generation。它不拥有 Game、active session、Save/Timeline、Game-local World/Character reality、选择组合或 Final Create。

```text
mutable external package
→ G4-02 Source合同公开接口 validation
→ managed same-volume staging
→ G4-02 staged revalidation
→ append-only exact generation
→ atomic current metadata
```

成功发布后，external path 不再是 installed authority，也不写入 current metadata。移动、删除或编辑 external package 不改变 managed generation。

## 2. Identity and storage

Exact generation identity：

```text
asset_type + asset_id + version + generation_fingerprint
```

物理布局：

```text
<root>/generations/<asset_type>/<asset_id>/<generation_fingerprint>/...
<root>/current/<asset_type>/<asset_id>.json
<root>/staging/<operation-id>/...
```

generation 目录只包含 `source.json` 与 G4-02 public projection 声明的 contract-owned files。不同 fingerprint append-only retained；同 fingerprint 重复安装 replay-safe。`version`、目录枚举和 mtime 都不能推断 current。

Production 默认根是 `user://my-world/source-library`。自动化测试必须注入 task-owned root，不得读取、清理或修改 production root。

## 3. Public seam

`Source库公开接口.gd` 提供：

- explicit `install_world_pack` / `install_character_card`；
- `list_current_sources`；
- typed `get_current_world` / `get_current_character`；
- `get_exact_world` / `get_exact_character`。

成功结果的 `ManagedSourceGenerationProjection` 暴露 player-safe identity、display name、managed path 与已验证的 G4-02 Source projection。它不暴露 external installed authority 或 Game state。

## 4. Failure semantics

- external validation、copy 或 staged fingerprint 失败：不发布 final，不改变 current；
- final 已存在：先重跑 G4-02 validation，损坏时 fail-loud，绝不从 external 静默覆盖；
- current metadata commit 失败：已存在 current 保持有效，published final 可由相同 intent 重试收敛；
- reload/current/exact lookup：每次重新验证 managed bytes 与 fingerprint；missing/tampered generation fail-loud；
- current 损坏时不 fallback 到历史 generation，不按目录/版本/mtime 猜测；
- stale staging 不属于 inventory。

本合同不提供 uninstall/pruning、watcher、semver resolver、Game pin、Expansion、chooser、Creator 或 Runtime Asset Resolution。
