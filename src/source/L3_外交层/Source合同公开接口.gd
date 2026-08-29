class_name SourceContractPublicInterface
extends RefCounted

const WorldProcess := preload("res://src/source/L2_流程层/世界包加载流程.gd")
const CharacterProcess := preload("res://src/source/L2_流程层/角色卡加载流程.gd")
const WorldProjection := preload("res://src/source/L3_外交层/世界包公开类型.gd")
const CharacterProjection := preload("res://src/source/L3_外交层/角色卡公开类型.gd")


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
