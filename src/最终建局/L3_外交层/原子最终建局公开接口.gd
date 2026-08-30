class_name AtomicFinalCreationPublicInterface
extends RefCounted

const Rules := preload("res://src/最终建局/L0_公理层/最终建局规则.gd")
const Process := preload("res://src/最终建局/L2_流程层/原子最终建局流程.gd")

const FAULT_AFTER_INTENT := "after_intent_publish"
const FAULT_AFTER_DATABASE := "after_database_commit"
const FAULT_AFTER_LIBRARY_RECORD := "after_library_record_publish"
const FAULT_AFTER_CURRENT := "after_current_publish"
const FAULT_BEFORE_LIBRARY_RECORD := "before_library_record_publish"
const FAULT_BEFORE_CURRENT := "before_current_publish"

var _process: RefCounted


## source_library 必须是调用方明确选择的 managed Source Library L3；测试应注入三个 task-owned roots。
func _init(
	source_library: RefCounted,
	creation_root: String = Rules.PRODUCTION_ROOT,
	library_root: String = "user://my-world/game-library",
	games_root: String = "user://my-world/games"
) -> void:
	_process = Process.new(source_library, creation_root, library_root, games_root)


## creation_id 由调用方生成一次并在 UI/retry 生命周期内保留；本接口把同一 identity 精确重放到同一 Game。
func create_or_resume(creation_id: String, frozen_composition: Dictionary, task_fault: String = "") -> Dictionary:
	return _process.create_or_resume(creation_id, frozen_composition, task_fault)


func generate_creation_id() -> String:
	return "creation-%s" % Crypto.new().generate_random_bytes(16).hex_encode()
