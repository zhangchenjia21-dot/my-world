class_name SourceLibraryPublicInterface
extends RefCounted

const Rules := preload("res://src/source/L0_公理层/Source库规则.gd")
const Contract := preload("res://src/source/L3_外交层/Source合同公开接口.gd")
const PublicationProcess := preload("res://src/source/L2_流程层/Source库发布流程.gd")
const GenerationProjection := preload("res://src/source/L3_外交层/Source库代次公开类型.gd")

var library_root: String
var _contract := Contract.new()
var _process: RefCounted


## 默认根只用于产品；测试必须显式传入 task-owned root，避免接触 Owner 的真实 Source Library。
func _init(root: String = Rules.PRODUCTION_ROOT) -> void:
	library_root = root
	_process = PublicationProcess.new(root)


## 安装调用方明确指定的 World package；外部目录在成功发布后不再是 installed authority。
func install_world_pack(package_path: String, task_fault: String = "") -> Dictionary:
	return _project_one(_process.install(package_path, _contract.load_world_pack, task_fault))


## 安装调用方明确指定的 Character package；不会扫描目录或创建 Game-local Character。
func install_character_card(package_path: String, task_fault: String = "") -> Dictionary:
	return _project_one(_process.install(package_path, _contract.load_character_card, task_fault))


## 仅在完整合同校验、exact fingerprint 与 managed publish 成功后更新 Expansion current；失败不发布部分代次。
func install_expansion_pack(package_path: String, task_fault: String = "") -> Dictionary:
	return _project_one(_process.install(package_path, _contract.load_expansion_pack, task_fault))


## 返回显式 current metadata 指向且已重新验证的 World/Character inventory；任一损坏时整体 fail-loud。
func list_current_sources() -> Dictionary:
	var result: Dictionary = _process.list_current(_loader_for_type)
	if not result.success:
		return result
	var projections: Array[RefCounted] = []
	for record: Dictionary in result.sources:
		projections.append(_projection(record))
	return Rules.success({"sources": projections})


func get_current_world(asset_id: String) -> Dictionary:
	return _project_one(_process.get_current(Rules.WORLD_TYPE, asset_id, _contract.load_world_pack))


func get_current_character(asset_id: String) -> Dictionary:
	return _project_one(_process.get_current(Rules.CHARACTER_TYPE, asset_id, _contract.load_character_card))


## current lookup 每次重新验证 managed bytes，不信任 current metadata 自身。
func get_current_expansion(asset_id: String) -> Dictionary:
	return _project_one(_process.get_current(Rules.EXPANSION_TYPE, asset_id, _contract.load_expansion_pack))


## exact lookup 始终读取并验证 managed bytes，不信任 fingerprint 目录名。
func get_exact_world(asset_id: String, fingerprint: String) -> Dictionary:
	return _project_one(_process.get_exact(Rules.WORLD_TYPE, asset_id, fingerprint, _contract.load_world_pack))


func get_exact_character(asset_id: String, fingerprint: String) -> Dictionary:
	return _project_one(_process.get_exact(Rules.CHARACTER_TYPE, asset_id, fingerprint, _contract.load_character_card))


## exact lookup 只按显式 generation fingerprint 读取并复核；不会 fallback 到 current。
func get_exact_expansion(asset_id: String, fingerprint: String) -> Dictionary:
	return _project_one(_process.get_exact(Rules.EXPANSION_TYPE, asset_id, fingerprint, _contract.load_expansion_pack))


func _loader_for_type(asset_type: String) -> Callable:
	if asset_type == Rules.WORLD_TYPE:
		return _contract.load_world_pack
	if asset_type == Rules.CHARACTER_TYPE:
		return _contract.load_character_card
	return _contract.load_expansion_pack


func _project_one(result: Dictionary) -> Dictionary:
	if not result.success:
		return result
	return Rules.success({
		"generation": _projection(result.record),
		"already_installed": bool(result.get("already_installed", false)),
	})


func _projection(record: Dictionary) -> RefCounted:
	return GenerationProjection.new(record.metadata, String(record.path), record.source)
