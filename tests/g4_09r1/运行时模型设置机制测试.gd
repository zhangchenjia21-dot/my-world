extends SceneTree

const Rules := preload("res://src/运行时设置/L0_公理层/模型运行时设置规则.gd")
const Settings := preload("res://src/运行时设置/L3_外交层/模型运行时设置公开接口.gd")
const Adapter := preload("res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd")
const Parser := preload("res://src/provider/L1_器件层/OpenAI兼容流增量解析器.gd")

var _failures := 0
var _original_deepseek := ""
var _original_kimi := ""


func _init() -> void:
	_run.call_deferred()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("[g4-09r1m1] PASS: ", label)
	else:
		_failures += 1
		printerr("[g4-09r1m1] FAIL: ", label)


func _run() -> void:
	_original_deepseek = OS.get_environment("DEEPSEEK_API_KEY")
	_original_kimi = OS.get_environment("KIMI_API_KEY")
	var root_path := "res://build/g4_09r1/settings-%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(root_path))
	var settings_path := root_path + "/provider-runtime.json"
	var game_sentinel_path := root_path + "/existing-game.sqlite"
	var source_sentinel_path := root_path + "/existing-source.json"
	var sentinel := FileAccess.open(game_sentinel_path, FileAccess.WRITE)
	sentinel.store_buffer(PackedByteArray([83, 81, 76, 105, 116, 101, 45, 118, 52]))
	sentinel.close()
	var source_sentinel := FileAccess.open(source_sentinel_path, FileAccess.WRITE)
	source_sentinel.store_string("{\"source\":\"unchanged\"}")
	source_sentinel.close()
	var sentinel_before := FileAccess.get_sha256(game_sentinel_path)
	var source_before := FileAccess.get_sha256(source_sentinel_path)

	_test_settings(settings_path)
	_test_candidate_projection(root_path, game_sentinel_path, source_sentinel_path)
	_test_catalog_and_payloads()
	_test_credentials()
	_test_parsing_and_lifecycle()
	_test_product_routes()
	_check(FileAccess.get_sha256(game_sentinel_path) == sentinel_before, "settings change does not mutate existing Game/SQLite sentinel")
	_check(FileAccess.get_sha256(source_sentinel_path) == source_before, "settings change does not mutate existing Source sentinel")

	OS.set_environment("DEEPSEEK_API_KEY", _original_deepseek)
	OS.set_environment("KIMI_API_KEY", _original_kimi)
	print("[g4-09r1m1] done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)


func _test_settings(path: String) -> void:
	var api := Settings.new(path)
	var missing: Dictionary = api.load_settings()
	_check(missing.success and String(missing.status) == "default" and missing.settings == Rules.validated_default(), "A missing file -> exact validated default")
	var exact := {"profile_id": "kimi_k3", "context_limit": "1m", "reasoning_request": "medium"}
	var saved: Dictionary = api.save_settings(exact)
	var reopened: Dictionary = Settings.new(path).load_settings()
	_check(saved.success and reopened.success and reopened.settings == exact, "A save/reopen persists exact settings")
	var budget: Dictionary = api.context_budget_metadata()
	_check(budget.success and String(budget.context_budget.context_limit) == "1m" and int(budget.context_budget.token_ceiling) == 1048576, "A selected context ceiling reaches request/context planning metadata")
	var absolute_path := ProjectSettings.globalize_path(path)
	DirAccess.rename_absolute(absolute_path, absolute_path + ".previous")
	var recovered: Dictionary = Settings.new(path).load_settings()
	_check(recovered.success and recovered.settings == exact and FileAccess.file_exists(path), "A interrupted publish recovers previous valid settings")
	OS.set_environment("DEEPSEEK_API_KEY", "availability-secret-a")
	OS.set_environment("KIMI_API_KEY", "")
	var availability: Dictionary = api.credential_availability()
	_check(availability.deepseek == {"configured": true} and availability.kimi == {"configured": false} and not JSON.stringify(availability).contains("availability-secret-a"), "A credential availability exposes bool only")
	var invalid_combo: Dictionary = api.save_settings({"profile_id": "kimi_k27", "context_limit": "1m", "reasoning_request": "high"})
	_check(not invalid_combo.success and String(invalid_combo.status) == "incompatible_context_limit", "A K2.7 + 1M rejected")
	var malformed := FileAccess.open(path, FileAccess.WRITE)
	malformed.store_string("{ malformed")
	malformed.close()
	var malformed_result: Dictionary = Settings.new(path).load_settings()
	_check(not malformed_result.success and String(malformed_result.status) == "settings_malformed", "A malformed persisted record fails visibly")
	var unknown := FileAccess.open(path, FileAccess.WRITE)
	unknown.store_string(JSON.stringify({"schema": Rules.SETTINGS_SCHEMA, "settings": {"profile_id": "free-form", "context_limit": "256k", "reasoning_request": "low"}}))
	unknown.close()
	var unknown_result: Dictionary = Settings.new(path).load_settings()
	_check(not unknown_result.success and String(unknown_result.status) == "invalid_persisted_settings", "A unknown persisted profile never reaches Provider")
	var active_path := path.get_base_dir().path_join("active-snapshot.json")
	var active_settings := Settings.new(active_path)
	active_settings.save_settings(Rules.validated_default())
	OS.set_environment("DEEPSEEK_API_KEY", "snapshot-dummy")
	var active_adapter: Node = Adapter.new(active_settings)
	root.add_child(active_adapter)
	active_adapter.test_host_override = "g4-09r1-snapshot.invalid"
	active_adapter.start_stream([{"role": "user", "content": "snapshot"}])
	var frozen: Dictionary = active_adapter.last_request_snapshot.duplicate(true)
	active_settings.save_settings(exact)
	_check(String(frozen.profile_id) == "deepseek_v4_pro" and active_adapter.last_request_snapshot == frozen, "A active request profile remains immutable after settings change")
	active_adapter.cancel()
	active_adapter.queue_free()


func _test_candidate_projection(root_path: String, game_sentinel_path: String, source_sentinel_path: String) -> void:
	var candidate_path := root_path.path_join("candidate-must-not-write.json")
	var game_before := FileAccess.get_sha256(game_sentinel_path)
	var source_before := FileAccess.get_sha256(source_sentinel_path)
	OS.set_environment("DEEPSEEK_API_KEY", "projection-secret-deepseek")
	OS.set_environment("KIMI_API_KEY", "projection-secret-kimi")
	var api := Settings.new(candidate_path)
	var editable_default := api.validated_default_settings()
	_check(editable_default == {"profile_id": "deepseek_v4_pro", "context_limit": "256k", "reasoning_request": "high"}, "A2 L3 exposes exact validated editable default")
	editable_default.profile_id = "caller-mutated"
	_check(String(api.validated_default_settings().profile_id) == "deepseek_v4_pro", "A2 L3 default is a defensive copy")
	var invalid: Dictionary = api.inspect_candidate({"profile_id": "kimi_k27", "context_limit": "1m", "reasoning_request": "high"})
	_check(not invalid.success and String(invalid.status) == "incompatible_context_limit", "A2 unsaved K2.7 + 1M candidate rejected")
	_check(String(invalid.candidate.profile_id) == "kimi_k27" and String(invalid.candidate.display_name) == "Kimi K2.7" and String(invalid.candidate.provider_id) == "kimi", "A2 incompatible candidate preserves known profile identity")
	_check(String(invalid.candidate.context_limit) == "1m" and invalid.candidate.allowed_context_limits == ["256k"], "A2 incompatible candidate preserves requested and allowed context truth")
	_check(String(invalid.candidate.reasoning_requested) == "high" and invalid.candidate.reasoning_effective == null and not bool(invalid.candidate.graded_reasoning) and bool(invalid.candidate.fixed_thinking), "A2 incompatible K2.7 preserves fixed-thinking truth")
	_check(bool(invalid.candidate.credential_configured), "A2 incompatible candidate exposes selected-provider credential bool")
	var deepseek: Dictionary = api.inspect_candidate({"profile_id": "deepseek_v4_flash", "context_limit": "1m", "reasoning_request": "medium"})
	var kimi_k3: Dictionary = api.inspect_candidate({"profile_id": "kimi_k3", "context_limit": "256k", "reasoning_request": "medium"})
	var kimi_k27: Dictionary = api.inspect_candidate({"profile_id": "kimi_k27", "context_limit": "256k", "reasoning_request": "max"})
	_check(deepseek.success and String(deepseek.candidate.reasoning_effective) == "high" and kimi_k3.success and String(kimi_k3.candidate.reasoning_effective) == "high", "A2 DeepSeek/K3 Medium projects effective High")
	_check(kimi_k27.success and bool(kimi_k27.candidate.fixed_thinking) and not bool(kimi_k27.candidate.graded_reasoning) and kimi_k27.candidate.reasoning_effective == null, "A2 K2.7 projects fixed thinking with null effective effort")
	_check(kimi_k27.candidate.allowed_context_limits == ["256k"] and bool(kimi_k27.candidate.credential_configured), "A2 projection owns context capability and selected credential bool")
	var unknown: Dictionary = api.inspect_candidate({"profile_id": "unknown", "context_limit": "1m", "reasoning_request": "high"})
	var malformed: Dictionary = api.inspect_candidate("not-a-settings-object")
	_check(not unknown.success and not unknown.has("candidate") and not malformed.success and not malformed.has("candidate"), "A2 unknown/malformed settings expose no unsafe partial identity")
	var serialized := JSON.stringify([invalid, deepseek, kimi_k3, kimi_k27, api.validated_default_settings()])
	_check(not serialized.contains("projection-secret") and not serialized.contains("endpoint") and not serialized.contains("model_id") and not serialized.contains("request_path"), "A2 projection exposes no secret or transport payload fields")
	_check(not FileAccess.file_exists(candidate_path) and FileAccess.get_sha256(game_sentinel_path) == game_before and FileAccess.get_sha256(source_sentinel_path) == source_before, "A2 default/candidate inspection writes no settings and mutates no Game/Source/SQLite sentinel")


func _test_catalog_and_payloads() -> void:
	var combinations := [
		["deepseek_v4_pro", "256k", "deepseek-v4-pro", "https://api.deepseek.com/chat/completions"],
		["deepseek_v4_pro", "1m", "deepseek-v4-pro", "https://api.deepseek.com/chat/completions"],
		["deepseek_v4_flash", "256k", "deepseek-v4-flash", "https://api.deepseek.com/chat/completions"],
		["deepseek_v4_flash", "1m", "deepseek-v4-flash", "https://api.deepseek.com/chat/completions"],
		["kimi_k3", "256k", "k3-256k", "https://api.kimi.com/coding/v1/chat/completions"],
		["kimi_k3", "1m", "k3", "https://api.kimi.com/coding/v1/chat/completions"],
		["kimi_k27", "256k", "kimi-for-coding", "https://api.kimi.com/coding/v1/chat/completions"],
	]
	for row: Array in combinations:
		var settings := {"profile_id": row[0], "context_limit": row[1], "reasoning_request": "medium"}
		var derived: Dictionary = Rules.derive_request_profile(settings)
		_check(derived.success and String(derived.request_profile.model_id) == row[2] and String(derived.request_profile.endpoint) == row[3], "B exact endpoint/model %s/%s" % [row[0], row[1]])
		var adapter: Node = Adapter.new()
		root.add_child(adapter)
		adapter.request_profile_override = derived.request_profile
		adapter.test_host_override = "g4-09r1-payload.invalid"
		OS.set_environment(String(derived.request_profile.credential_env), "task-owned-dummy")
		adapter.start_stream([{"role": "user", "content": "payload probe"}])
		if bool(derived.request_profile.graded_reasoning):
			_check(String(derived.request_profile.reasoning_effective) == "high" and String(adapter.last_request_payload.get("reasoning_effort", "")) == "high", "C medium -> high for %s" % row[0])
		else:
			_check(bool(derived.request_profile.fixed_thinking) and not adapter.last_request_payload.has("reasoning_effort"), "C K2.7 fixed thinking, no graded field")
		if String(row[0]) == "kimi_k3":
			_check(String(adapter.last_request_payload.model) == String(row[2]) and String(adapter.last_request_payload.reasoning_effort) == "high" and adapter.last_request_payload.reasoning_effort != "none" and not adapter.last_request_payload.has("thinking"), "C K3 exact wire keeps Thinking ON through graded reasoning_effort")
		elif String(row[0]) == "kimi_k27":
			_check(String(adapter.last_request_payload.model) == "kimi-for-coding" and not adapter.last_request_payload.has("reasoning_effort") and not adapter.last_request_payload.has("thinking"), "C K2.7 exact wire uses fixed Thinking ON default without fake graded field")
		adapter.cancel()
		adapter.queue_free()
	for request: String in ["low", "high", "max"]:
		var deepseek: Dictionary = Rules.derive_request_profile({"profile_id": "deepseek_v4_pro", "context_limit": "256k", "reasoning_request": request})
		var kimi: Dictionary = Rules.derive_request_profile({"profile_id": "kimi_k3", "context_limit": "256k", "reasoning_request": request})
		_check(String(deepseek.request_profile.reasoning_effective) == request and String(kimi.request_profile.reasoning_effective) == request, "C exact reasoning mapping %s" % request)


func _test_credentials() -> void:
	OS.set_environment("DEEPSEEK_API_KEY", "")
	OS.set_environment("KIMI_API_KEY", "wrong-provider-secret")
	var deepseek_profile: Dictionary = Rules.derive_request_profile(Rules.validated_default()).request_profile
	var deepseek: Node = Adapter.new()
	root.add_child(deepseek)
	deepseek.request_profile_override = deepseek_profile
	var deepseek_failures: Array = []
	deepseek.failed.connect(func(code: String, message: String) -> void: deepseek_failures.append([code, message]))
	var ds_error: Error = deepseek.start_stream([])
	_check(ds_error == ERR_UNAUTHORIZED and deepseek.network_attempt_count == 0 and String(deepseek_failures[0][0]) == "missing_key", "D DeepSeek missing selected key -> zero network, no Kimi fallback")
	_check(not String(deepseek_failures[0][1]).contains("wrong-provider-secret"), "D secret absent from DeepSeek error")
	deepseek.queue_free()

	OS.set_environment("DEEPSEEK_API_KEY", "wrong-provider-secret-2")
	OS.set_environment("KIMI_API_KEY", "")
	var kimi_profile: Dictionary = Rules.derive_request_profile({"profile_id": "kimi_k3", "context_limit": "256k", "reasoning_request": "high"}).request_profile
	var kimi: Node = Adapter.new()
	root.add_child(kimi)
	kimi.request_profile_override = kimi_profile
	var kimi_failures: Array = []
	kimi.failed.connect(func(code: String, message: String) -> void: kimi_failures.append([code, message]))
	var kimi_error: Error = kimi.start_stream([])
	_check(kimi_error == ERR_UNAUTHORIZED and kimi.network_attempt_count == 0 and String(kimi_failures[0][0]) == "missing_key", "D Kimi missing selected key -> zero network, no DeepSeek fallback")
	_check(not String(kimi_failures[0][1]).contains("wrong-provider-secret-2"), "D secret absent from Kimi error")
	kimi.queue_free()


func _test_parsing_and_lifecycle() -> void:
	var parser := Parser.new()
	var reasoning_only: Dictionary = parser.parse_data_payload(JSON.stringify({"choices": [{"delta": {"reasoning_content": "private chain"}}]}))
	var content: Dictionary = parser.parse_data_payload(JSON.stringify({"choices": [{"delta": {"content": "玩家可见"}}]}))
	_check(reasoning_only.success and String(reasoning_only.kind) == "ignored" and content.success and String(content.content) == "玩家可见", "E reasoning-only delta hidden; content delta preserved")
	for provider_id: String in ["deepseek_v4_pro", "kimi_k3"]:
		var derived: Dictionary = Rules.derive_request_profile({"profile_id": provider_id, "context_limit": "256k", "reasoning_request": "low"})
		OS.set_environment(String(derived.request_profile.credential_env), "lifecycle-dummy")
		var adapter: Node = Adapter.new()
		root.add_child(adapter)
		adapter.request_profile_override = derived.request_profile
		adapter.test_host_override = "g4-09r1-lifecycle.invalid"
		var terminals := {"completed": 0, "cancelled": 0, "failed": 0}
		adapter.completed.connect(func() -> void: terminals.completed += 1)
		adapter.cancelled.connect(func() -> void: terminals.cancelled += 1)
		adapter.failed.connect(func(_code: String, _message: String) -> void: terminals.failed += 1)
		var first_error: Error = adapter.start_stream([{"role": "user", "content": "first"}])
		var snapshot_before: Dictionary = adapter.last_request_snapshot.duplicate(true)
		var second_error: Error = adapter.start_stream([{"role": "user", "content": "second"}])
		_check(first_error == OK and second_error == ERR_BUSY and adapter.last_request_snapshot == snapshot_before, "E busy guard preserves active snapshot %s" % provider_id)
		adapter._handle_sse_line("data: {broken")
		adapter.cancel()
		_check(terminals.failed == 1 and terminals.completed == 0 and terminals.cancelled == 0 and not adapter.is_busy(), "E malformed stream exactly-one terminal %s" % provider_id)
		adapter.queue_free()


func _test_product_routes() -> void:
	var route_path := "res://src/provider/L3_外交层/运行时模型流式适配公开接口.gd"
	var product_files := [
		"res://src/首次开场/L2_流程层/首次开场运行流程.gd",
		"res://src/ui/叙事对话视图.gd",
		"res://src/行动判定/L2_流程层/公开D20行动判定流程.gd",
	]
	for path: String in product_files:
		var file := FileAccess.open(path, FileAccess.READ)
		var text := file.get_as_text() if file != null else ""
		_check(text.contains(route_path), "F product call site routes through shared runtime profile seam: %s" % path.get_file())
	var adjudication := FileAccess.open(product_files[2], FileAccess.READ).get_as_text()
	_check(
		adjudication.contains('"control"')
		and adjudication.contains('"no_check_narrative"')
		and adjudication.contains('"resolution_narrative"'),
		"F d20 isolated control and both narrative branches share one selected-provider adapter seam"
	)
	var launcher := FileAccess.open("res://run-game.ps1", FileAccess.READ).get_as_text()
	_check(launcher.contains("'DEEPSEEK_API_KEY'") and launcher.contains("'KIMI_API_KEY'") and not launcher.contains("$requiredVariables") and not launcher.contains("MY_WORLD_DEEPSEEK_MODEL"), "F launcher permits either/both/no key and has no arbitrary model override")
