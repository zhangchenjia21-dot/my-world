# godot-sqlite provenance

- Upstream: https://github.com/2shady4u/godot-sqlite
- Release: `v4.9`
- Tag commit: `9cbdb225823ee111342ce32fe451e066eb92cc6e`
- Release page: https://github.com/2shady4u/godot-sqlite/releases/tag/v4.9
- Published: 2026-08-09
- Upstream build baseline: Godot `4.7.1-stable`, SQLite `3.51.0`
- License: MIT，见同目录 `LICENSE.md`
- Official `addons.zip` SHA-256: `95E91B72FE32984A84EDAF6357A78753661F37A170CB362F5B948E0EDE7C2CB0`

本仓库只保留当前 Foundation 所需的 Windows x86_64 debug/release GDExtension 二进制和最小 descriptor；未引入其它平台二进制、EditorPlugin 或 demo。

G3-06 已在 Godot 4.7.2 Standard / Windows x64 对 vendored v4.9 二进制实测：保持 WAL source connection 打开时，`SQLite.backup_to(path)` 与在独立 staging connection 上调用的 `SQLite.restore_from(path)` 均返回 `bool true`，且 restored database 通过 `PRAGMA quick_check` 并保留 exact committed truth。production recovery 不普通复制 open WAL database。

| 文件 | SHA-256 |
|---|---|
| `bin/libgdsqlite.windows.template_debug.x86_64.dll` | `E3AE3B46B59EADCD513F8D7D6E7C0C15E173696E145594094D7F4F3CC96C7FE7` |
| `bin/libgdsqlite.windows.template_release.x86_64.dll` | `BA79B9BBF916C4ED2EB22AC719051C4A4258E460C4A354590B071BEB9A87FEDB` |
