extends SceneTree

const Settings := preload("res://src/运行时设置/L3_外交层/模型运行时设置公开接口.gd")
const Adapter := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")

var _results: Array = []
var _failures := 0


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var task_root := _argument("--root=")
	var evidence_path := _argument("--evidence=")
	if task_root.find("g4_09r1") < 0 or evidence_path.is_empty():
		printerr("G4-09R1M1 REAL FAIL | task-owned root/evidence required")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(task_root))
	for profile: Dictionary in [
		{"profile_id": "deepseek_v4_pro", "context_limit": "256k", "reasoning_request": "high"},
		{"profile_id": "deepseek_v4_flash", "context_limit": "1m", "reasoning_request": "medium"},
		{"profile_id": "kimi_k3", "context_limit": "256k", "reasoning_request": "low"},
		{"profile_id": "kimi_k27", "context_limit": "256k", "reasoning_request": "max"},
	]:
		await _run_profile(task_root, profile)
	var evidence := {
		"schema": "g4-09r1m1.real-provider-evidence.v1",
		"generated_at_utc": Time.get_datetime_string_from_system(true),
		"results": _results,
	}
	var file := FileAccess.open(evidence_path, FileAccess.WRITE)
	if file == null:
		printerr("G4-09R1M1 REAL FAIL | cannot write evidence")
		quit(1)
		return
	file.store_string(JSON.stringify(evidence, "\t") + "\n")
	file.close()
	print("G4-09R1M1 REAL | done configured_failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)


func _run_profile(task_root: String, selected: Dictionary) -> void:
	var settings_path := task_root.path_join("%s-provider-runtime.json" % String(selected.profile_id))
	var settings := Settings.new(settings_path)
	var saved: Dictionary = settings.save_settings(selected)
	if not saved.success:
		_record(selected, {}, "settings_failure", 0, String(saved.status), true)
		return
	var snapshot: Dictionary = settings.request_snapshot()
	var request_profile := snapshot.request_profile as Dictionary
	var credential_configured := not OS.get_environment(String(request_profile.credential_env)).strip_edges().is_empty()
	if not credential_configured:
		_record(selected, request_profile, "credential_unavailable", 0, "missing_key", false)
		return
	var adapter: Node = Adapter.new(settings)
	root.add_child(adapter)
	var terminal := {"kind": "", "code": ""}
	adapter.completed.connect(func() -> void: terminal.kind = "completed")
	adapter.cancelled.connect(func() -> void: terminal.kind = "cancelled")
	adapter.failed.connect(func(code: String, _message: String) -> void:
		terminal.kind = "failed"
		terminal.code = code
	)
	var started: Error = adapter.start_stream([
		{"role": "system", "content": "你是 my world 的 Provider 连通性测试。不要解释过程。"},
		{"role": "user", "content": "只输出：运行时验证成功"},
	])
	var deadline := Time.get_ticks_msec() + 120000
	while terminal.kind == "" and Time.get_ticks_msec() < deadline:
		await process_frame
	if terminal.kind == "":
		adapter.cancel()
		terminal.kind = "timeout"
		terminal.code = "timeout"
	var success: bool = started == OK and String(terminal.kind) == "completed" and adapter.output_chars > 0
	_record(selected, request_profile, String(terminal.kind), adapter.output_chars, String(terminal.code), not success)
	adapter.queue_free()
	await process_frame


func _record(selected: Dictionary, profile: Dictionary, status: String, chars: int, code: String, count_failure: bool) -> void:
	if count_failure:
		_failures += 1
	var result := {
		"profile_id": String(selected.profile_id),
		"context_limit": String(selected.context_limit),
		"provider_id": String(profile.get("provider_id", "")),
		"endpoint": String(profile.get("endpoint", "")),
		"model_id": String(profile.get("model_id", "")),
		"reasoning_effective": profile.get("reasoning_effective", null),
		"fixed_thinking": bool(profile.get("fixed_thinking", false)),
		"status": status,
		"error_code": code,
		"output_chars": chars,
	}
	_results.append(result)
	print("G4-09R1M1 REAL | profile=%s model=%s status=%s chars=%d" % [result.profile_id, result.model_id, status, chars])


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
