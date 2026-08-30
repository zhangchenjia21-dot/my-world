class_name SourceContractPublicInterface
extends RefCounted

const WorldProcess := preload("res://src/source/L2_流程层/世界包加载流程.gd")
const CharacterProcess := preload("res://src/source/L2_流程层/角色卡加载流程.gd")
const WorldProjection := preload("res://src/source/L3_外交层/世界包公开类型.gd")
const CharacterProjection := preload("res://src/source/L3_外交层/角色卡公开类型.gd")
const SelectedProjectionProcess := preload("res://src/source/L2_流程层/Source选定投影流程.gd")

var _selected_projection := SelectedProjectionProcess.new()


## 读取一个调用方明确指定的 World package。
## 成功返回 typed `WorldPackSourceProjection`；失败返回 code/message，且无安装、发布或写入副作用。
func load_world_pack(package_path: String) -> Dictionary:
	var result := WorldProcess.new().load(package_path)
	if not result.success:
		return result
	return {"success": true, "source": WorldProjection.new(result.projection)}


## 读取一个调用方明确指定的 Character package。
## 成功返回 typed `CharacterCardSourceProjection`；调用不会扫描 Library，也不会 materialize Game entity。
func load_character_card(package_path: String) -> Dictionary:
	var result := CharacterProcess.new().load(package_path)
	if not result.success:
		return result
	return {"success": true, "source": CharacterProjection.new(result.projection)}


## 返回 top-level always-safe + exact Entry sections；不返回其它 Entry 的 content。
func project_world_entry(source: RefCounted, entry_id: String) -> Dictionary:
	return _selected_projection.project_world_entry(source, entry_id)


## 返回 exact/no-world-coverage/temporal-incompatible 三态与对应 Character Source projection。
func project_character_t0(source: RefCounted, world_asset_id: String, entry_id: String) -> Dictionary:
	return _selected_projection.project_character_t0(source, world_asset_id, entry_id)
