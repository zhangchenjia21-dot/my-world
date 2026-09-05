extends SceneTree

## MW-005 三国文风 Primer 生产 Source 发布——复用 G4-09P1 的 Owner opt-in 模式：
## 只在明确确认参数下触碰默认 production Source Library；不扫描目录、不接受任意路径。
## 通过现有 Source库公开接口.install_world_pack 发布新的 immutable exact generation
## 并推进 current；绝不原地修改既有 generation。

const SourceLibrary := preload("res://src/source/L3_外交层/Source库公开接口.gd")

const PACKAGE_PATH := "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定"
const ASSET_ID := "world.han_end.unsettled_realm"
const ASSET_TYPE := "world_pack"
const VERSION := "0.2.3-converted.2-full-fidelity-candidate"
const DISPLAY_NAME := "汉末三国：天下未定"
## MW-005 之前的 production current generation（docs/g4_09p1 发布证据）。
const EXPECTED_PREVIOUS_FINGERPRINT := "acea0b2afbaf5305f40456cb93b60c94d536066cee794d75bf5e4b44eebe8a47"
const CONFIRMATION := "--confirm-mw005-production-publish"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not CONFIRMATION in OS.get_cmdline_user_args():
		return _finish_failure("confirmation_required", "缺少明确的 MW-005 Owner production publish 确认参数。")

	var library := SourceLibrary.new()
	var previous: Dictionary = library.get_current_world(ASSET_ID)
	if not previous.success:
		return _finish_failure("previous_current_lookup_failed", String(previous.get("message", previous.get("code", "unknown"))))
	var previous_fingerprint := String(previous.generation.identity.generation_fingerprint)

	var installed: Dictionary = library.install_world_pack(PACKAGE_PATH)
	if not installed.success:
		return _finish_failure("install_failed", String(installed.get("message", installed.get("code", "unknown"))))
	var generation: RefCounted = installed.generation
	var identity_error := _validate_generation(generation)
	if not identity_error.is_empty():
		return _finish_failure("installed_identity_mismatch", identity_error)
	var fingerprint := String(generation.identity.generation_fingerprint)
	## 幂等重跑：current 已经是 Primer generation 时视为 already_published，
	## 记录的 previous 仍以 immutable 旧 generation 的 exact lookup 为准。
	var already_published := previous_fingerprint == fingerprint
	if not already_published:
		if fingerprint == previous_fingerprint:
			return _finish_failure("fingerprint_unchanged", "Primer generation fingerprint 必须与旧 generation 不同。")
		if previous_fingerprint != EXPECTED_PREVIOUS_FINGERPRINT:
			return _finish_failure("previous_fingerprint_mismatch", "production current 不是预期的 MW-005 之前 generation：%s" % previous_fingerprint)
	if already_published:
		previous_fingerprint = EXPECTED_PREVIOUS_FINGERPRINT

	var current: Dictionary = library.get_current_world(ASSET_ID)
	if not current.success or String(current.generation.identity.generation_fingerprint) != fingerprint:
		return _finish_failure("current_lookup_failed", "current 未指向新 Primer generation。")
	var exact: Dictionary = library.get_exact_world(ASSET_ID, fingerprint)
	if not exact.success:
		return _finish_failure("exact_lookup_failed", String(exact.get("message", exact.get("code", "unknown"))))
	var old_exact: Dictionary = library.get_exact_world(ASSET_ID, previous_fingerprint)
	if not old_exact.success:
		return _finish_failure("old_exact_lost", "旧 generation 必须保持 immutable exact 可取。")

	var result := {
		"success": true,
		"status": "already_published" if already_published else ("already_installed" if bool(installed.already_installed) else "installed"),
		"production_library_root": ProjectSettings.globalize_path(library.library_root).simplify_path(),
		"package_path": PACKAGE_PATH,
		"owner_games_modified": false,
		"world": {
			"asset_id": ASSET_ID,
			"asset_type": ASSET_TYPE,
			"version": VERSION,
			"display_name": DISPLAY_NAME,
			"previous_generation_fingerprint": previous_fingerprint,
			"generation_fingerprint": fingerprint,
			"style_section_type": "literary_style_reference",
			"style_section_disclosure": "gm_reference",
		},
	}
	var evidence_error := _write_optional_evidence(result)
	if not evidence_error.is_empty():
		return _finish_failure("evidence_write_failed", evidence_error)
	print("MW-005 PRODUCTION PUBLISH OK | " + JSON.stringify(result))
	quit(0)


func _validate_generation(generation: RefCounted) -> String:
	if String(generation.identity.asset_id) != ASSET_ID or String(generation.identity.asset_type) != ASSET_TYPE:
		return "World identity 字段不匹配。"
	if String(generation.identity.version) != VERSION or generation.display_name != DISPLAY_NAME:
		return "World version/display_name 不匹配。"
	var found := false
	for section: Dictionary in generation.source.semantic_sections:
		if String(section.get("section_type", "")) == "literary_style_reference":
			found = true
			if String(section.get("disclosure", "")) != "gm_reference":
				return "style section disclosure 不是 gm_reference。"
			if String(section.get("content", "")).is_empty():
				return "style section 缺少已物化全文。"
	if not found:
		return "新 generation 缺少 literary_style_reference section。"
	return ""


## Evidence 仅允许写入 gitignored build/mw005；不写 Owner AppData、Game 或 secret。
func _write_optional_evidence(result: Dictionary) -> String:
	var evidence_path := _argument("--evidence=")
	if evidence_path.is_empty():
		return ""
	var absolute := ProjectSettings.globalize_path(evidence_path).simplify_path()
	var allowed_root := ProjectSettings.globalize_path("res://build/mw005").simplify_path()
	if not absolute.begins_with(allowed_root + "/"):
		return "evidence path 必须位于 res://build/mw005。"
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
	push_error("MW-005 PRODUCTION PUBLISH FAIL | %s | %s" % [code, message])
	quit(1)
