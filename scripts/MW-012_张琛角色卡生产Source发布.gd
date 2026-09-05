extends SceneTree

## MW-012：张琛 Player Character Card 的 Owner production Source 发布入口。
## 沿用 G4-09P1 先例：只在 Owner 明确 opt-in 后触碰默认 production Source Library；
## 不接受 package/root 参数，不演化成任意目录扫描器，不绕过 SourceLibrary 公开安装契约。

const SourceLibrary := preload("res://src/source/L3_外交层/Source库公开接口.gd")

const PACKAGE_PATH := "res://tests/fixtures/mw012/汉末三国/张琛"
const ASSET_ID := "character.han_end.zhang_chen"
const ASSET_TYPE := "character_card"
const VERSION := "0.1.0"
const DISPLAY_NAME := "张琛"
const CONFIRMATION := "--confirm-owner-production-source-prep"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not CONFIRMATION in OS.get_cmdline_user_args():
		return _finish_failure("confirmation_required", "缺少明确的 Owner production Source 发布确认参数。")

	var library := SourceLibrary.new()
	var installed: Dictionary = library.install_character_card(PACKAGE_PATH)
	if not installed.success:
		return _finish_failure("install_failed", String(installed.get("message", installed.get("code", "unknown"))))
	var generation: RefCounted = installed.generation
	var identity_error := _validate_generation(generation)
	if not identity_error.is_empty():
		return _finish_failure("installed_identity_mismatch", identity_error)

	var current: Dictionary = library.get_current_character(ASSET_ID)
	if not current.success:
		return _finish_failure("current_lookup_failed", String(current.get("message", current.get("code", "unknown"))))
	var fingerprint := String(generation.identity.generation_fingerprint)
	var exact: Dictionary = library.get_exact_character(ASSET_ID, fingerprint)
	if not exact.success:
		return _finish_failure("exact_lookup_failed", String(exact.get("message", exact.get("code", "unknown"))))
	if String(current.generation.identity.generation_fingerprint) != fingerprint or String(exact.generation.identity.generation_fingerprint) != fingerprint:
		return _finish_failure("generation_lookup_mismatch", "current/exact lookup 未收敛到本次验证的 immutable generation。")

	var inventory: Dictionary = library.list_current_sources()
	if not inventory.success:
		return _finish_failure("inventory_failed", String(inventory.get("message", inventory.get("code", "unknown"))))
	var summary := _inventory_summary(inventory.sources)
	if int(summary.character_count) < 1:
		return _finish_failure("character_inventory_missing", "production inventory 未返回任何 Character current generation。")
	if not bool(summary.zhang_chen_present):
		return _finish_failure("zhang_chen_missing", "production inventory 未发现张琛 current generation。")

	var result := {
		"success": true,
		"status": "already_installed" if bool(installed.already_installed) else "installed",
		"production_library_root": ProjectSettings.globalize_path(library.library_root).simplify_path(),
		"package_path": PACKAGE_PATH,
		"owner_games_modified": false,
		"character": {
			"asset_id": ASSET_ID,
			"asset_type": ASSET_TYPE,
			"version": VERSION,
			"display_name": DISPLAY_NAME,
			"generation_fingerprint": fingerprint,
			"player_character_supported": true,
		},
		"inventory": summary,
	}
	print("MW-012 PRODUCTION SOURCE | %s" % JSON.stringify(result, "", true, true))
	quit(0)


func _validate_generation(generation: RefCounted) -> String:
	var identity: Dictionary = generation.identity
	if String(identity.get("asset_id", "")) != ASSET_ID:
		return "asset_id mismatch"
	if String(identity.get("asset_type", "")) != ASSET_TYPE:
		return "asset_type mismatch"
	if String(identity.get("version", "")) != VERSION:
		return "version mismatch"
	if String(generation.display_name) != DISPLAY_NAME:
		return "display_name mismatch"
	if String(identity.get("generation_fingerprint", "")).is_empty():
		return "missing generation fingerprint"
	return ""


func _inventory_summary(sources: Array) -> Dictionary:
	var world_count := 0
	var character_count := 0
	var zhang_chen_present := false
	for generation: RefCounted in sources:
		var identity: Dictionary = generation.identity
		if String(identity.get("asset_type", "")) == "world_pack":
			world_count += 1
		elif String(identity.get("asset_type", "")) == "character_card":
			character_count += 1
			if String(identity.get("asset_id", "")) == ASSET_ID:
				zhang_chen_present = true
	return {"world_count": world_count, "character_count": character_count, "zhang_chen_present": zhang_chen_present}


func _finish_failure(code: String, message: String) -> void:
	push_error("MW-012 PRODUCTION SOURCE FAIL | %s | %s" % [code, message])
	quit(1)
