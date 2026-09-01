extends SceneTree

const SourceLibrary := preload("res://src/source/L3_外交层/Source库公开接口.gd")

const PACKAGE_PATH := "res://tests/fixtures/g4_08m1/判定与检定_公开d20"
const ASSET_ID := "exp.check_core.public_d20"
const ASSET_TYPE := "expansion_pack"
const VERSION := "0.1.0"
const DISPLAY_NAME := "判定与检定：公开 d20"
const CAPABILITY_ID := "action_check.public_d20.v1"
const CAPABILITY_SLOT := "action_resolution"
const CONFIRMATION := "--confirm-owner-production-source-prep"


func _initialize() -> void:
	call_deferred("_run")


## 本入口只在 Owner 明确 opt-in 后触碰默认 production Source Library；它不接受
## package/root 参数，避免演化成任意目录扫描器或绕过 SourceLibrary 公开安装契约。
func _run() -> void:
	if not CONFIRMATION in OS.get_cmdline_user_args():
		return _finish_failure("confirmation_required", "缺少明确的 Owner production preparation 确认参数。")

	var library := SourceLibrary.new()
	var installed: Dictionary = library.install_expansion_pack(PACKAGE_PATH)
	if not installed.success:
		return _finish_failure("install_failed", String(installed.get("message", installed.get("code", "unknown"))))
	var generation: RefCounted = installed.generation
	var identity_error := _validate_generation(generation)
	if not identity_error.is_empty():
		return _finish_failure("installed_identity_mismatch", identity_error)

	var current: Dictionary = library.get_current_expansion(ASSET_ID)
	if not current.success:
		return _finish_failure("current_lookup_failed", String(current.get("message", current.get("code", "unknown"))))
	var fingerprint := String(generation.identity.generation_fingerprint)
	var exact: Dictionary = library.get_exact_expansion(ASSET_ID, fingerprint)
	if not exact.success:
		return _finish_failure("exact_lookup_failed", String(exact.get("message", exact.get("code", "unknown"))))
	if String(current.generation.identity.generation_fingerprint) != fingerprint or String(exact.generation.identity.generation_fingerprint) != fingerprint:
		return _finish_failure("generation_lookup_mismatch", "current/exact lookup 未收敛到本次验证的 immutable generation。")

	var inventory: Dictionary = library.list_current_sources()
	if not inventory.success:
		return _finish_failure("inventory_failed", String(inventory.get("message", inventory.get("code", "unknown"))))
	var summary := _inventory_summary(inventory.sources)
	if int(summary.world_count) < 1 or int(summary.character_count) < 1:
		return _finish_failure("baseline_source_missing", "production inventory 缺少可用 World 或 Character current generation。")
	if not bool(summary.public_d20_present):
		return _finish_failure("public_d20_missing", "production inventory 未返回 Public d20 current generation。")

	var result := {
		"success": true,
		"status": "already_installed" if bool(installed.already_installed) else "installed",
		"production_library_root": ProjectSettings.globalize_path(library.library_root).simplify_path(),
		"package_path": PACKAGE_PATH,
		"owner_games_modified": false,
		"expansion": {
			"asset_id": ASSET_ID,
			"asset_type": ASSET_TYPE,
			"version": VERSION,
			"display_name": DISPLAY_NAME,
			"generation_fingerprint": fingerprint,
			"capability_id": CAPABILITY_ID,
			"capability_slot": CAPABILITY_SLOT,
		},
		"inventory": summary,
	}
	var evidence_error := _write_optional_evidence(result)
	if not evidence_error.is_empty():
		return _finish_failure("evidence_write_failed", evidence_error)
	print("G4-09P1 OWNER SOURCE PREP OK | " + JSON.stringify(result))
	quit(0)


func _validate_generation(generation: RefCounted) -> String:
	var expected := {
		"asset_id": ASSET_ID,
		"asset_type": ASSET_TYPE,
		"version": VERSION,
	}
	for field: String in expected:
		if String(generation.identity.get(field, "")) != String(expected[field]):
			return "Expansion identity 字段不匹配：%s" % field
	if generation.display_name != DISPLAY_NAME:
		return "Expansion display_name 不匹配。"
	if String(generation.source.capability_binding.get("capability_id", "")) != CAPABILITY_ID:
		return "Expansion capability_id 不匹配。"
	if String(generation.source.capability_binding.get("capability_slot", "")) != CAPABILITY_SLOT:
		return "Expansion capability_slot 不匹配。"
	return ""


func _inventory_summary(sources: Array) -> Dictionary:
	var summary := {
		"world_count": 0,
		"character_count": 0,
		"expansion_count": 0,
		"worlds": [],
		"characters": [],
		"expansions": [],
		"public_d20_present": false,
	}
	for generation: RefCounted in sources:
		var item := {
			"asset_id": String(generation.identity.asset_id),
			"version": String(generation.identity.version),
			"generation_fingerprint": String(generation.identity.generation_fingerprint),
			"display_name": generation.display_name,
		}
		match String(generation.identity.asset_type):
			"world_pack":
				summary.world_count += 1
				summary.worlds.append(item)
			"character_card":
				summary.character_count += 1
				summary.characters.append(item)
			"expansion_pack":
				summary.expansion_count += 1
				summary.expansions.append(item)
				if String(generation.identity.asset_id) == ASSET_ID:
					summary.public_d20_present = true
	return summary


## Evidence 仅允许写入 gitignored build/g4_09p1；不写 Owner AppData、Game 或 secret。
func _write_optional_evidence(result: Dictionary) -> String:
	var evidence_path := _argument("--evidence=")
	if evidence_path.is_empty():
		return ""
	var absolute := ProjectSettings.globalize_path(evidence_path).simplify_path()
	var allowed_root := ProjectSettings.globalize_path("res://build/g4_09p1").simplify_path()
	if not absolute.begins_with(allowed_root + "/"):
		return "evidence path 必须位于 res://build/g4_09p1。"
	DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
	var file := FileAccess.open(absolute, FileAccess.WRITE)
	if file == null:
		return "无法写入 task-owned evidence。"
	file.store_string(JSON.stringify(result, "  "))
	file.close()
	return ""


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _finish_failure(code: String, message: String) -> void:
	push_error("G4-09P1 OWNER SOURCE PREP FAIL | %s | %s" % [code, message])
	quit(1)
