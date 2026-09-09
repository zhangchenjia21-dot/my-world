extends RefCounted
const Contract := preload("res://src/动态展示/L0_公理层/展示定义契约.gd")
const SCHEMA := "ui_visibility.v0.1"
const DEFAULT_ROOT := "user://my-world/presentation-preferences"
const MAX_KEYS := 4096
const MAX_BYTES := 600000
var path := ""
var hidden_by_surface := {"people":[],"important_experiences":[]}

## 仅加载展示 sidecar；不存在/损坏时可见默认值，不创建目录、不写回、不触碰 Game。
func _init(game_id: String, root: String = DEFAULT_ROOT) -> void:
	if game_id.is_empty(): return
	path=root.path_join(("visibility|"+game_id).sha256_text()+".json")
	if not FileAccess.file_exists(path): return
	var file:=FileAccess.open(path,FileAccess.READ)
	if file==null or file.get_length()>MAX_BYTES: return
	var parser:=JSON.new()
	if parser.parse(file.get_as_text())!=OK: return
	var value: Variant=parser.data
	if valid(value): hidden_by_surface=value.hidden_by_surface.duplicate(true)

static func valid(value: Variant) -> bool:
	if not Contract.exact(value,["schema","hidden_by_surface"]) or value.schema!=SCHEMA: return false
	if not Contract.exact(value.hidden_by_surface,Contract.HIDEABLE): return false
	for surface: String in Contract.HIDEABLE:
		var keys: Variant=value.hidden_by_surface[surface]
		if not keys is Array or keys.size()>MAX_KEYS: return false
		var seen: Dictionary={}
		for key: Variant in keys:
			if not Contract.opaque(key) or seen.has(key): return false
			seen[key]=true
	return true

func keys_for(surface: String) -> Array:
	return hidden_by_surface.get(surface,[]).duplicate()

## 唯一写入口是显式隐藏/恢复；临时文件 flush/close 后同目录原子替换，失败保留旧偏好。
func set_hidden(surface: String, key: String, hidden: bool) -> bool:
	if path.is_empty() or surface not in Contract.HIDEABLE or not Contract.opaque(key): return false
	var next: Dictionary=hidden_by_surface.duplicate(true)
	if hidden:
		if key in next[surface]: return true
		if next[surface].size()>=MAX_KEYS: return false
		next[surface].append(key)
	else:
		if key not in next[surface]: return true
		next[surface].erase(key)
	if DirAccess.make_dir_recursive_absolute(path.get_base_dir())!=OK: return false
	var temporary:=path+".tmp"
	var file:=FileAccess.open(temporary,FileAccess.WRITE)
	if file==null: return false
	file.store_string(JSON.stringify({"schema":SCHEMA,"hidden_by_surface":next}))
	file.flush(); var error:=file.get_error(); file.close()
	if error!=OK: return false
	if DirAccess.rename_absolute(temporary,path)!=OK: return false
	hidden_by_surface=next
	return true
