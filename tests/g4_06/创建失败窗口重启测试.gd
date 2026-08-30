extends SceneTree

const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const GameLibrary := preload("res://src/游戏库/L3_外交层/游戏库公开接口.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")

var _failures := 0
var _fixture := Fixture.new()


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var root_path := _argument("--root=")
	if root_path.find("g4_06") < 0:
		_fail("必须提供 task-owned --root")
		return _finish()
	_fixture.reset_directory(root_path)
	var installed := _fixture.install_real_assets(root_path.path_join("source-library"))
	_check(installed.success, "restart suite Source installed")
	if not installed.success:
		push_error("G4-06 restart Source install detail: %s" % JSON.stringify(installed))
		return _finish()
	var library: RefCounted = installed.library
	var generations: Array = installed.installed
	var composition := _composition(library, generations)
	var fault_points := [
		FinalCreate.FAULT_AFTER_INTENT,
		FinalCreate.FAULT_AFTER_DATABASE,
		FinalCreate.FAULT_AFTER_LIBRARY_RECORD,
		FinalCreate.FAULT_AFTER_CURRENT,
	]
	for point: String in fault_points:
		var case_root := root_path.path_join(point)
		var first: Dictionary = _creator(library, case_root).create_or_resume("creation-%s" % point, composition, point)
		_check(not first.success and String(first.code) == "injected_creation_interruption", "%s is directly observable" % point)
		var resumed: Dictionary = _creator(library, case_root).create_or_resume("creation-%s" % point, composition)
		_check(resumed.success and String(resumed.game_id) == String(first.game_id), "%s fresh-object retry converges to fixed Game" % point)
		var replay: Dictionary = _creator(library, case_root).create_or_resume("creation-%s" % point, composition)
		_check(replay.success and String(replay.game_id) == String(resumed.game_id) and String(replay.local_player_id) == String(resumed.local_player_id), "%s exact replay preserves Game/local identity" % point)
		var game_library := GameLibrary.new(case_root.path_join("library"), case_root.path_join("games"))
		var inventory := game_library.list_games()
		var current := game_library.get_current_selection()
		_check(_count_sqlite(case_root.path_join("games")) == 1 and inventory.success and inventory.games.size() == 1 and current.success and String(current.record.game_id) == String(resumed.game_id), "%s ends with exactly one DB/record/current" % point)
	_finish()


func _composition(library: RefCounted, generations: Array) -> Dictionary:
	var creation := Creation.new(library)
	creation.select_world(_fixture.find_generation(generations, "world.ashtervia.afterglow"))
	creation.select_entry("t0-1287-border-route")
	creation.confirm_expansion_none()
	creation.select_player(_fixture.find_generation(generations, "character.ashtervia.adrian_wilk"))
	creation.set_guaranteed_npc(_fixture.find_generation(generations, "character.ashtervia.duen_stonescar"), true)
	creation.set_settings("中断恢复", "Light", "")
	return creation.composition_snapshot()


func _creator(library: RefCounted, case_root: String) -> RefCounted:
	return FinalCreate.new(library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games"))


func _count_sqlite(root_path: String) -> int:
	if not DirAccess.dir_exists_absolute(root_path):
		return 0
	var count := 0
	for game_directory: String in DirAccess.get_directories_at(root_path):
		if FileAccess.file_exists(root_path.path_join(game_directory).path_join("game.sqlite")):
			count += 1
	return count


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-06 RESTART PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-06 RESTART FAIL | %s" % label)


func _finish() -> void:
	print("G4-06 RESTART | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
