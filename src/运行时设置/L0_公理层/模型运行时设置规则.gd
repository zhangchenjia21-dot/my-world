class_name ModelRuntimeSettingsRules
extends RefCounted

const SETTINGS_SCHEMA := "my-world.provider-runtime.v1"
const DEFAULT_SETTINGS := {
	"profile_id": "deepseek_v4_pro",
	"context_limit": "256k",
	"reasoning_request": "high",
}

const PROFILE_CATALOG := {
	"deepseek_v4_pro": {
		"display_name": "DeepSeek V4 Pro",
		"provider_id": "deepseek",
		"endpoint": "https://api.deepseek.com/chat/completions",
		"host": "api.deepseek.com",
		"request_path": "/chat/completions",
		"credential_env": "DEEPSEEK_API_KEY",
		"models": {"256k": "deepseek-v4-pro", "1m": "deepseek-v4-pro"},
		"context_limits": ["256k", "1m"],
		"graded_reasoning": true,
	},
	"deepseek_v4_flash": {
		"display_name": "DeepSeek V4 Flash",
		"provider_id": "deepseek",
		"endpoint": "https://api.deepseek.com/chat/completions",
		"host": "api.deepseek.com",
		"request_path": "/chat/completions",
		"credential_env": "DEEPSEEK_API_KEY",
		"models": {"256k": "deepseek-v4-flash", "1m": "deepseek-v4-flash"},
		"context_limits": ["256k", "1m"],
		"graded_reasoning": true,
	},
	"kimi_k3": {
		"display_name": "Kimi K3",
		"provider_id": "kimi",
		"endpoint": "https://api.kimi.com/coding/v1/chat/completions",
		"host": "api.kimi.com",
		"request_path": "/coding/v1/chat/completions",
		"credential_env": "KIMI_API_KEY",
		"models": {"256k": "k3-256k", "1m": "k3"},
		"context_limits": ["256k", "1m"],
		"graded_reasoning": true,
	},
	"kimi_k27": {
		"display_name": "Kimi K2.7",
		"provider_id": "kimi",
		"endpoint": "https://api.kimi.com/coding/v1/chat/completions",
		"host": "api.kimi.com",
		"request_path": "/coding/v1/chat/completions",
		"credential_env": "KIMI_API_KEY",
		"models": {"256k": "kimi-for-coding"},
		"context_limits": ["256k"],
		"graded_reasoning": false,
	},
}

const REASONING_REQUESTS := ["low", "medium", "high", "max"]
const CONTEXT_TOKEN_CEILINGS := {"256k": 262144, "1m": 1048576}


static func validated_default() -> Dictionary:
	return DEFAULT_SETTINGS.duplicate(true)


static func catalog() -> Dictionary:
	return PROFILE_CATALOG.duplicate(true)


static func validate(settings: Variant) -> Dictionary:
	if typeof(settings) != TYPE_DICTIONARY:
		return failure("invalid_settings", "模型运行时设置必须是对象。")
	var value := settings as Dictionary
	var profile_id := String(value.get("profile_id", ""))
	var context_limit := String(value.get("context_limit", ""))
	var reasoning_request := String(value.get("reasoning_request", ""))
	if not PROFILE_CATALOG.has(profile_id):
		return failure("unknown_profile", "未知模型 profile_id。")
	if not CONTEXT_TOKEN_CEILINGS.has(context_limit):
		return failure("unknown_context_limit", "未知上下文上限。")
	if not REASONING_REQUESTS.has(reasoning_request):
		return failure("unknown_reasoning_request", "未知思考强度。")
	var profile := PROFILE_CATALOG[profile_id] as Dictionary
	if not (profile.context_limits as Array).has(context_limit):
		return failure("incompatible_context_limit", "%s 不支持 %s 上下文上限。" % [String(profile.display_name), context_limit])
	return success({"settings": {
		"profile_id": profile_id,
		"context_limit": context_limit,
		"reasoning_request": reasoning_request,
	}})


static func derive_request_profile(settings: Variant) -> Dictionary:
	var validation := validate(settings)
	if not validation.success:
		return validation
	var exact := validation.settings as Dictionary
	var profile := PROFILE_CATALOG[String(exact.profile_id)] as Dictionary
	var graded := bool(profile.graded_reasoning)
	var requested := String(exact.reasoning_request)
	var effective: Variant = null
	if graded:
		effective = "high" if requested == "medium" else requested
	return success({"request_profile": {
		"profile_id": String(exact.profile_id),
		"display_name": String(profile.display_name),
		"provider_id": String(profile.provider_id),
		"endpoint": String(profile.endpoint),
		"host": String(profile.host),
		"port": 443,
		"request_path": String(profile.request_path),
		"credential_env": String(profile.credential_env),
		"model_id": String((profile.models as Dictionary)[String(exact.context_limit)]),
		"context_limit": String(exact.context_limit),
		"context_token_ceiling": int(CONTEXT_TOKEN_CEILINGS[String(exact.context_limit)]),
		"reasoning_requested": requested,
		"reasoning_effective": effective,
		"graded_reasoning": graded,
		"fixed_thinking": not graded,
	}})


static func success(fields: Dictionary = {}) -> Dictionary:
	var result := {"success": true, "status": "ok", "message": ""}
	for key: Variant in fields:
		result[key] = fields[key]
	return result


static func failure(status: String, message: String) -> Dictionary:
	return {"success": false, "status": status, "message": message}
