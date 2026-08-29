extends SceneTree

const Library := preload("res://src/游戏库/L3_外交层/游戏库公开接口.gd")
const Fixture := preload("res://tests/g4_04/游戏库测试夹具.gd")

var _failures := 0
var _fixture := Fixture.new()


func _initialize() -> void:
	var root_path := _argument("--root=")
	if root_path.find("g4_04") < 0:
		_fail("必须提供 task-owned --root，且路径包含 g4_04")
		_finish()
		return
	_fixture.reset_directory(root_path)
	var library_root := root_path.path_join("library")
	var games_root := root_path.path_join("games")
	var legacy_path := root_path.path_join("legacy/current-game.sqlite")
	var library := Library.new(library_root, games_root, legacy_path)
	var path_a: String = library.managed_database_path("game-a").path
	var path_b: String = library.managed_database_path("game-b").path
	_check(_fixture.seed_game(path_a, "game-a", {"owner": "A"}, "A行动", "A回应").success, "fixture Game A 创建为独立 SQLite")
	_check(_fixture.seed_game(path_b, "game-b", {"owner": "B"}, "B行动", "B回应").success, "fixture Game B 创建为独立 SQLite")

	var record_fault := library.register_verified_managed_game("game-a", "游戏 A", "game-a", Library.FAULT_BEFORE_RECORD_PUBLISH)
	_check(not record_fault.success and String(record_fault.code) == "injected_record_publish_failure", "record publish failure fail-loud")
	_check(library.list_games().games.is_empty(), "record publish failure 不产生 inventory entry")
	var a := library.register_verified_managed_game("game-a", "游戏 A", "game-a")
	var b := library.register_verified_managed_game("game-b", "游戏 B", "game-b")
	_check(a.success and b.success, "两个 existing managed Game records 成功登记")
	var replay := library.register_verified_managed_game("game-a", "游戏 A", "game-a")
	_check(replay.success and replay.already_registered, "相同 record registration replay-safe")
	var mismatch := library.register_verified_managed_game("game-a", "游戏 A", "game-b")
	_check(not mismatch.success and String(mismatch.code) == "game_identity_mismatch", "verified identity mismatch 拒绝登记")

	var current_a := library.commit_current("game-a", "game-a")
	_check(current_a.success and String(current_a.record.game_id) == "game-a", "显式 current=A 原子提交")
	var interrupted := library.commit_current("game-b", "game-b", Library.FAULT_BEFORE_CURRENT_PUBLISH)
	_check(not interrupted.success and String(interrupted.code) == "injected_current_publish_failure", "current publish interruption fail-loud")
	_check(String(library.get_current_selection().record.game_id) == "game-a", "current failure 保留旧 A")
	var current_b := library.commit_current("game-b", "game-b")
	_check(current_b.success and String(current_b.record.game_id) == "game-b", "retry 安全收敛到 B")

	_fixture.write_json(library_root.path_join("records/ignored.pending"), {"partial": true})
	var restarted := Library.new(library_root, games_root, legacy_path)
	var inventory := restarted.list_games()
	var selection := restarted.get_current_selection()
	_check(inventory.success and inventory.games.size() == 2, "fresh instance 仅从完整 record JSON 恢复两条 inventory")
	_check(selection.success and String(selection.record.game_id) == "game-b", "fresh instance 恢复显式 current B")
	_check(String(inventory.games[0].database_path) != String(inventory.games[1].database_path), "每个 record 解析为独立 SQLite path")

	var missing_root := root_path.path_join("invalid-current-library")
	_fixture.write_json(missing_root.path_join("current.json"), {"schema_version": "game_library_current.v0.1", "game_id": "missing-record"})
	var invalid_current := Library.new(missing_root, games_root, legacy_path).get_current_selection()
	_check(not invalid_current.success and String(invalid_current.code) == "current_selection_invalid", "current 指向 missing record 时 fail-loud")
	_finish()


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("G4-04 METADATA PASS | %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("G4-04 METADATA FAIL | %s" % label)


func _finish() -> void:
	print("G4-04 METADATA | done failures=%d" % _failures)
	quit(0 if _failures == 0 else 1)
