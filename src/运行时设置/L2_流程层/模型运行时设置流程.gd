class_name ModelRuntimeSettingsProcess
extends RefCounted

const Rules := preload("res://src/运行时设置/L0_公理层/模型运行时设置规则.gd")
const Store := preload("res://src/运行时设置/L1_器件层/模型运行时设置存储.gd")

var _store: RefCounted


func _init(path_override: String = "") -> void:
	_store = Store.new(path_override)


func load_settings() -> Dictionary:
	var loaded: Dictionary = _store.read_record()
	if not loaded.success:
		return loaded
	if String(loaded.status) == "missing":
		return Rules.success({"status": "default", "settings": Rules.validated_default(), "path": _store.settings_path})
	var record := loaded.record as Dictionary
	if String(record.get("schema", "")) != Rules.SETTINGS_SCHEMA:
		return Rules.failure("invalid_persisted_settings", "模型运行时设置 schema 无效；请在设置中重新保存。")
	var validation := Rules.validate(record.get("settings", null))
	if not validation.success:
		return Rules.failure("invalid_persisted_settings", "模型运行时设置内容无效：%s" % String(validation.message))
	return Rules.success({"status": "loaded", "settings": validation.settings, "path": _store.settings_path})


func save_settings(settings: Variant) -> Dictionary:
	var validation := Rules.validate(settings)
	if not validation.success:
		return validation
	var record := {"schema": Rules.SETTINGS_SCHEMA, "settings": validation.settings}
	var saved: Dictionary = _store.write_record(record)
	if not saved.success:
		return saved
	return Rules.success({"status": "saved", "settings": validation.settings, "path": _store.settings_path})


## 投影未保存候选的 UI 安全事实；只读环境中的 credential 是否存在，不暴露传输配置或秘密值。
func inspect_candidate(settings: Variant) -> Dictionary:
	var projected := Rules.project_candidate_capabilities(settings)
	if not projected.has("candidate"):
		return projected
	var candidate := projected.candidate as Dictionary
	var availability := credential_availability()
	candidate["credential_configured"] = bool((availability[String(candidate.provider_id)] as Dictionary).configured)
	return projected


func request_snapshot() -> Dictionary:
	var loaded := load_settings()
	if not loaded.success:
		return loaded
	return Rules.derive_request_profile(loaded.settings)


func credential_availability() -> Dictionary:
	return {
		"deepseek": {"configured": not OS.get_environment("DEEPSEEK_API_KEY").strip_edges().is_empty()},
		"kimi": {"configured": not OS.get_environment("KIMI_API_KEY").strip_edges().is_empty()},
	}


func context_budget_metadata() -> Dictionary:
	var snapshot := request_snapshot()
	if not snapshot.success:
		return snapshot
	var profile := snapshot.request_profile as Dictionary
	return Rules.success({"context_budget": {
		"profile_id": String(profile.profile_id),
		"context_limit": String(profile.context_limit),
		"token_ceiling": int(profile.context_token_ceiling),
	}})
