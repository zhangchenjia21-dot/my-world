class_name ModelRuntimeSettingsPublicInterface
extends RefCounted

const Rules := preload("res://src/运行时设置/L0_公理层/模型运行时设置规则.gd")
const Process := preload("res://src/运行时设置/L2_流程层/模型运行时设置流程.gd")

var _process: RefCounted


func _init(path_override: String = "") -> void:
	_process = Process.new(path_override)


## 返回冻结且已校验的应用默认值防御性副本；不读取或写入设置、credential、Game、Source 或 SQLite。
func validated_default_settings() -> Dictionary:
	return Rules.validated_default()


## 返回当前 validated application-local preference；缺文件使用冻结默认，非法记录 fail loud。
func load_settings() -> Dictionary:
	return _process.load_settings()


## 只持久化 closed catalog 的非秘密选项；不会写 Game、Source、SQLite 或 credential value。
func save_settings(settings: Variant) -> Dictionary:
	return _process.save_settings(settings)


## 验证并投影未保存候选；不写设置，只返回 UI 所需的非秘密能力与有效值。
func inspect_candidate(settings: Variant) -> Dictionary:
	return _process.inspect_candidate(settings)


## 每次调用生成一份独立 request profile；Provider 在 start 后持有该快照直到唯一终态。
func request_snapshot() -> Dictionary:
	return _process.request_snapshot()


func credential_availability() -> Dictionary:
	return _process.credential_availability()


func context_budget_metadata() -> Dictionary:
	return _process.context_budget_metadata()


func catalog() -> Dictionary:
	return Rules.catalog()


func validate(settings: Variant) -> Dictionary:
	return Rules.validate(settings)
