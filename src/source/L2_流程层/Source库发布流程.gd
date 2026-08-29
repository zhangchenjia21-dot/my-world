class_name SourceLibraryPublicationProcess
extends RefCounted

const Rules := preload("res://src/source/L0_公理层/Source库规则.gd")
const Store := preload("res://src/source/L1_器件层/Source库文件存储.gd")

const FAULT_BEFORE_CURRENT_PUBLISH := "before_current_publish"

var _store: RefCounted


func _init(library_root: String) -> void:
	_store = Store.new(library_root)


## loader 是 L3 注入的 G4-02 production contract callable，使本流程不向上依赖其实现层。
## fault 只服务 task-owned deterministic failure test；产品调用必须保留空字符串。
func install(package_path: String, loader: Callable, fault: String = "") -> Dictionary:
	var initialized: Dictionary = _store.initialize()
	if not initialized.success:
		return initialized
	var external := loader.call(package_path) as Dictionary
	if not external.success:
		return external
	var source := external.source as RefCounted
	var identity_result := Rules.validate_generation_identity(source.identity)
	if not identity_result.success:
		return identity_result

	var stage_result: Dictionary = _store.create_stage()
	if not stage_result.success:
		return stage_result
	var stage := String(stage_result.path)
	var copied: Dictionary = _store.copy_contract_files(package_path, stage, Rules.contract_owned_paths(source))
	if not copied.success:
		_store.remove_tree(stage)
		return copied
	var staged := loader.call(stage) as Dictionary
	if not staged.success:
		_store.remove_tree(stage)
		return Rules.failure("staged_generation_invalid", "staged Source 未通过 G4-02 contract：%s" % String(staged.get("message", staged.get("code", "unknown"))))
	if String(staged.source.identity.generation_fingerprint) != String(source.identity.generation_fingerprint):
		_store.remove_tree(stage)
		return Rules.failure("staged_fingerprint_mismatch", "复制期间 Source exact generation 已改变，拒绝发布。")

	var final_path: String = _store.generation_path(
		String(source.identity.asset_type),
		String(source.identity.asset_id),
		String(source.identity.generation_fingerprint)
	)
	var generation_existed := DirAccess.dir_exists_absolute(final_path)
	if generation_existed:
		_store.remove_tree(stage)
		var existing := _load_exact(final_path, source.identity, loader)
		if not existing.success:
			return existing
	else:
		var published: Dictionary = _store.publish_stage(stage, final_path)
		if not published.success:
			_store.remove_tree(stage)
			return published

	var metadata := Rules.current_metadata(source)
	var current_path: String = _store.current_path(String(metadata.asset_type), String(metadata.asset_id))
	if FileAccess.file_exists(current_path):
		var current := _load_current_path(current_path, loader)
		if not current.success:
			return current
		if String(current.record.metadata.generation_fingerprint) == String(metadata.generation_fingerprint):
			return Rules.success({"record": current.record, "already_installed": true})
	if fault == FAULT_BEFORE_CURRENT_PUBLISH:
		return Rules.failure("injected_current_publish_failure", "task-only fault：current publish 前中断。")
	if not fault.is_empty():
		return Rules.failure("invalid_fault", "未知的 task-only fault。")
	var committed: Dictionary = _store.publish_current(metadata)
	if not committed.success:
		return committed
	var loaded := _load_current_path(current_path, loader)
	if not loaded.success:
		return loaded
	return Rules.success({"record": loaded.record, "already_installed": generation_existed})


func list_current(loader_for_type: Callable) -> Dictionary:
	var initialized: Dictionary = _store.initialize()
	if not initialized.success:
		return initialized
	var inventory: Array[Dictionary] = []
	for asset_type: String in Rules.SUPPORTED_TYPES:
		var listed: Dictionary = _store.list_current_metadata_paths(asset_type)
		if not listed.success:
			return listed
		var loader: Callable = loader_for_type.call(asset_type)
		for path: String in listed.paths:
			var loaded := _load_current_path(path, loader)
			if not loaded.success:
				return loaded
			inventory.append(loaded.record)
	return Rules.success({"sources": inventory})


func get_current(asset_type: String, asset_id: String, loader: Callable) -> Dictionary:
	var identity_guard := Rules.validate_generation_identity({
		"asset_type": asset_type,
		"asset_id": asset_id,
		"version": "lookup",
		"generation_fingerprint": "0000000000000000000000000000000000000000000000000000000000000000",
	})
	if not identity_guard.success:
		return identity_guard
	var initialized: Dictionary = _store.initialize()
	if not initialized.success:
		return initialized
	return _load_current_path(_store.current_path(asset_type, asset_id), loader)


func get_exact(asset_type: String, asset_id: String, fingerprint: String, loader: Callable) -> Dictionary:
	var identity_guard := Rules.validate_generation_identity({
		"asset_type": asset_type,
		"asset_id": asset_id,
		"version": "lookup",
		"generation_fingerprint": fingerprint,
	})
	if not identity_guard.success:
		return identity_guard
	var initialized: Dictionary = _store.initialize()
	if not initialized.success:
		return initialized
	var path: String = _store.generation_path(asset_type, asset_id, fingerprint)
	return _load_exact(path, {"asset_type": asset_type, "asset_id": asset_id, "generation_fingerprint": fingerprint}, loader)


func _load_current_path(path: String, loader: Callable) -> Dictionary:
	var read: Dictionary = _store.read_json(path)
	if not read.success:
		return Rules.failure("current_inventory_invalid", "current metadata 无法恢复：%s" % String(read.message))
	var metadata: Dictionary = read.metadata
	var validation := Rules.validate_current_metadata(metadata)
	if not validation.success:
		return validation
	var expected_file := "%s.json" % String(metadata.asset_id)
	var expected_parent := String(metadata.asset_type)
	if path.get_file() != expected_file or path.get_base_dir().get_file() != expected_parent:
		return Rules.failure("current_inventory_invalid", "current metadata 的物理位置与 stable identity 不一致。")
	var final_path: String = _store.generation_path(
		String(metadata.asset_type), String(metadata.asset_id), String(metadata.generation_fingerprint)
	)
	var exact := _load_exact(final_path, metadata, loader)
	if not exact.success:
		return exact
	if String(exact.record.metadata.display_name) != String(metadata.display_name) or String(exact.record.metadata.version) != String(metadata.version):
		return Rules.failure("current_inventory_invalid", "current metadata 与 managed generation projection 不一致。")
	return exact


func _load_exact(path: String, expected: Dictionary, loader: Callable) -> Dictionary:
	if not DirAccess.dir_exists_absolute(path):
		return Rules.failure("managed_generation_missing", "Managed Source generation 目录不存在。")
	var loaded := loader.call(path) as Dictionary
	if not loaded.success:
		return Rules.failure("managed_generation_invalid", "Managed Source generation 未通过 G4-02 contract：%s" % String(loaded.get("message", loaded.get("code", "unknown"))))
	var source := loaded.source as RefCounted
	for field: String in ["asset_type", "asset_id", "generation_fingerprint"]:
		if String(source.identity[field]) != String(expected[field]):
			return Rules.failure("managed_generation_invalid", "Managed Source generation %s 与 authority metadata 不一致。" % field)
	var metadata := Rules.current_metadata(source)
	return Rules.success({"record": {"metadata": metadata, "path": path, "source": source}})
