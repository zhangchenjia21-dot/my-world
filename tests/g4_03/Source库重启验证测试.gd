extends SceneTree

const Library := preload("res://src/source/L3_外交层/Source库公开接口.gd")

var _failures := 0


func _initialize() -> void:
	var work_root := _argument("--work-root=")
	if work_root.find("g4_03") < 0:
		_fail("必须提供 task-owned --work-root，且路径包含 g4_03")
		_finish()
		return
	var expectation_text := FileAccess.get_file_as_string(work_root.path_join("restart-expectation.json"))
	var expectation: Variant = JSON.parse_string(expectation_text)
	if not expectation is Dictionary:
		_fail("必须先由 reality process 写入 restart expectation")
		_finish()
		return
	var library := Library.new(work_root.path_join("library"))
	var inventory := library.list_current_sources()
	_check(inventory.success and inventory.sources.size() == 2, "新 Godot process 恢复相同 current inventory")
	var current := library.get_current_world("world.border_lords")
	var retained := library.get_exact_world("world.border_lords", String(expectation.old_world))
	var character := library.get_exact_character("character.shen_yan", String(expectation.character))
	_check(current.success and String(current.generation.identity.generation_fingerprint) == String(expectation.current_world), "restart current 来自显式 metadata")
	_check(retained.success, "restart 后旧 World generation 仍可 exact lookup")
	_check(character.success, "restart 后 Character generation 仍可 exact lookup")
	_finish()


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-03 RESTART PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-03 RESTART FAIL | %s" % label)


func _finish() -> void:
	print("G4-03 RESTART | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
