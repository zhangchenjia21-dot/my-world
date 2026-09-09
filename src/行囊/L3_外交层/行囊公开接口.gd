extends RefCounted
const Accepted := preload("res://src/domain/L3_外交层/已接受输入公开契约.gd")
const Contract := preload("res://src/行囊/L0_公理层/行囊事件契约.gd")
const Device := preload("res://src/行囊/L1_器件层/行囊事件折叠器.gd")

static func _versions(entries: Array) -> Array:
	var hashes := Accepted.prefix_hashes(entries)
	var versions: Array = []
	for index: int in entries.size():
		var entry: Dictionary = entries[index]
		versions.append({"valid":Accepted.valid(entry) and Accepted.mode(entry) == "action" and not String(entry.player_text).is_empty(),"prefix":hashes[index],"gm_hash":String(entry.gm_text).sha256_text()})
	return versions

## 纯 player-safe projection，仅 name/summary 的深复制，禁止把内部事件/refs 交给叶 UI。
static func project(world: Dictionary, entries: Array) -> Array:
	return Device.fold(world,_versions(entries)).values().duplicate(true)

static func project_session(runtime: Variant) -> Array:
	if runtime == null or not runtime.is_ready() or runtime.conversation == null: return []
	return project(runtime.world_state,runtime.conversation.get_durable_accepted_entries())

## 所有 foreground 消费者共用同一 bounded factual block；World-only 不调用此接口。
static func project_context(runtime: Variant) -> String:
	return "Current Player Inventory — 当前已记录的随身物品（不是全部环境物件）\n" + JSON.stringify(project_session(runtime))

## World semantic 专用边界：rows 给模型，refs 仅由本次请求持有，不进持久层或 UI。
static func request(world: Dictionary, entries: Array, index: int) -> Dictionary:
	return Device.request(Device.fold(world,_versions(entries).slice(0,index)))

static func parse_updates(value: Variant) -> Dictionary:
	return Contract.parse(value)

## 不执行写入：产出同一 semantic candidate，调用方保持既有一次原子 World commit。
static func candidate(world: Dictionary, entries: Array, index: int, parsed: Dictionary, refs: Dictionary) -> Dictionary:
	var versions := _versions(entries)
	if index < 0 or index >= versions.size() or not versions[index].valid:
		return {"world":world.duplicate(true),"counts":{},"status":"invalid_inventory"}
	return Device.candidate(world,versions,index,parsed,refs)
