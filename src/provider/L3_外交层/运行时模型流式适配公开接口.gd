class_name RuntimeModelStreamingAdapterPublicInterface
extends "res://src/provider/L2_流程层/OpenAI兼容流式请求流程.gd"

const SettingsInterface := preload("res://src/运行时设置/L3_外交层/模型运行时设置公开接口.gd")

var runtime_settings: RefCounted
var request_profile_override: Dictionary = {}


func _init(settings_override: RefCounted = null) -> void:
	runtime_settings = settings_override if settings_override != null else SettingsInterface.new()


## 冻结当前 validated profile，再且只读取该 profile 指定的 credential；失败不尝试另一 Provider。
func start_stream(messages: Array) -> Error:
	if is_busy():
		return ERR_BUSY
	var snapshot_result: Dictionary
	if request_profile_override.is_empty():
		snapshot_result = runtime_settings.request_snapshot()
	else:
		snapshot_result = {"success": true, "request_profile": request_profile_override.duplicate(true)}
	if not snapshot_result.success:
		_terminated = false
		_finish_failed(String(snapshot_result.status), String(snapshot_result.message))
		return ERR_INVALID_DATA
	var profile := snapshot_result.request_profile as Dictionary
	var credential_name := String(profile.credential_env)
	var api_key := OS.get_environment(credential_name).strip_edges()
	if api_key.is_empty():
		_terminated = false
		_finish_failed("missing_key", "%s 未设置；未发起任何网络请求。" % credential_name)
		return ERR_UNAUTHORIZED
	return start_stream_with_profile(messages, profile, api_key)
