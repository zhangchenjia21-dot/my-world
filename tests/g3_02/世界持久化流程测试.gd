extends SceneTree

const Persistence := preload("res://src/persistence/L3_外交层/世界持久化公开接口.gd")
const GAME_ID := "game-g3-02"
const H0 := "head-0"
const H1 := "head-1"
const H2 := "head-2"
const W0 := {"clock": 0, "nested": {"weather": "clear"}}
const W1 := {"clock": 1, "nested": {"weather": "rain"}}
const W2 := {"clock": 2, "nested": {"weather": "wind"}}

var _root_path := ""


func _initialize() -> void:
	_root_path = _argument_value("--root=")
	if _root_path.is_empty():
		_fail("missing --root")
		return
	DirAccess.make_dir_recursive_absolute(_root_path)
	if not _test_complete_path(): return
	if not _test_late_failure_rollback(): return
	if not _test_invalid_input(): return
	print("G3-02 PASS | deterministic production durable mutation suite")
	quit(0)


func _test_complete_path() -> bool:
	var path := _root_path.path_join("production.sqlite")
	var api := Persistence.new()
	if not _expect(api.open_database(path), "ready", "open/schema"): return false
	var created := api.create_initial_game(GAME_ID, H0, W0, "2026-08-27T00:00:00Z")
	if not _expect(created, "committed", "initial create"): return false
	if not _expect(api.create_initial_game(GAME_ID, "other-root", {}, "2026-08-27T00:00:00Z"), "already_exists", "duplicate Game"): return false
	var m1 := api.commit_world_mutation(GAME_ID, "mutation-1", H0, H1, W1, "2026-08-27T00:00:01Z")
	if not _expect(m1, "committed", "M1 commit"): return false
	var replay_reordered := api.commit_world_mutation(GAME_ID, "mutation-1", H0, H1, {"nested": {"weather": "rain"}, "clock": 1}, "2026-08-27T00:00:09Z")
	# created_at 不是 durable intent effect；调用时间变化不应把 lost-ACK retry 判为冲突。
	if not _expect(replay_reordered, "replay_success", "exact replay/canonical keys"): return false
	if not _expect(api.commit_world_mutation(GAME_ID, "mutation-1", H0, H1, {"clock": 999}, "2026-08-27T00:00:01Z"), "mutation_conflict", "conflicting reuse"): return false
	if not _expect(api.commit_world_mutation(GAME_ID, "mutation-stale", H0, "stale-node", W2, "2026-08-27T00:00:02Z"), "stale_head", "stale writer"): return false
	if not _expect(api.commit_world_mutation(GAME_ID, "mutation-2", H1, H2, W2, "2026-08-27T00:00:02Z"), "committed", "M2 commit"): return false
	if not _assert_state(api, H2, W2, 3, "after H2"): return false
	if not _assert_node(api, H0, W0, 0): return false
	if not _assert_node(api, H1, W1, 1): return false
	if not _assert_node(api, H2, W2, 2): return false
	api.close_database()

	var reopened := Persistence.new()
	if not _expect(reopened.open_database(path), "ready", "reopen"): return false
	if not _assert_state(reopened, H2, W2, 3, "reopen exact"): return false
	reopened.close_database()
	print("G3-02 PASS | create/reopen + M1/M2 + replay/conflict/stale + immutable anchors")
	return true


func _test_late_failure_rollback() -> bool:
	var path := _root_path.path_join("late-failure.sqlite")
	var api := Persistence.new()
	if not _expect(api.open_database(path), "ready", "late open"): return false
	if not _expect(api.create_initial_game(GAME_ID, H0, W0, "2026-08-27T00:00:00Z"), "committed", "late seed"): return false
	api.close_database()
	var db := SQLite.new()
	db.path = path
	db.default_extension = ""
	db.foreign_keys = true
	if not db.open_db(): return _fail("late trigger DB open")
	if not db.query("CREATE TRIGGER abort_head_update BEFORE UPDATE OF active_head_id ON games BEGIN SELECT RAISE(ABORT, 'intentional late head failure'); END;"):
		return _fail("install test-only late trigger: %s" % db.error_message)
	db.close_db()
	var mutation_api := Persistence.new()
	if not _expect(mutation_api.open_database(path), "ready", "late reopen"): return false
	if not _expect(mutation_api.commit_world_mutation(GAME_ID, "late-mutation", H0, H1, W1, "2026-08-27T00:00:01Z"), "storage_failure", "late rollback result"): return false
	if not _assert_state(mutation_api, H0, W0, 1, "late rollback visibility"): return false
	if not _expect(mutation_api.get_timeline_node(GAME_ID, H1), "not_found", "late node absent"): return false
	mutation_api.close_database()
	print("G3-02 PASS | final head SQL abort rolls back node + World + head")
	return true


func _test_invalid_input() -> bool:
	var api := Persistence.new()
	if not _expect(api.open_database(_root_path.path_join("invalid.sqlite")), "ready", "invalid open"): return false
	var invalid := {"forbidden": RefCounted.new()}
	if not _expect(api.create_initial_game("invalid-game", "invalid-root", invalid, "2026-08-27T00:00:00Z"), "invalid_input", "non-serializable input"): return false
	if FileAccess.file_exists(_root_path.path_join("invalid.sqlite-wal")):
		pass
	api.close_database()
	print("G3-02 PASS | non-serializable World rejected before durable mutation")
	return true


func _assert_state(api: Variant, expected_head: String, expected_world: Dictionary, expected_count: int, label: String) -> bool:
	var current: Dictionary = api.get_current_game(GAME_ID)
	var count: Dictionary = api.timeline_node_count(GAME_ID)
	if current.status != "found" or current.head_id != expected_head or current.world_state != _json_round_trip(expected_world) or count.status != "found" or count.node_count != expected_count:
		return _fail("%s | current=%s count=%s" % [label, current, count])
	return true


func _assert_node(api: Variant, node_id: String, expected_world: Dictionary, expected_sequence: int) -> bool:
	var node: Dictionary = api.get_timeline_node(GAME_ID, node_id)
	if node.status != "found" or node.world_state != _json_round_trip(expected_world) or node.sequence != expected_sequence:
		return _fail("historical anchor %s | %s" % [node_id, node])
	return true


func _expect(result: Dictionary, status: String, label: String) -> bool:
	if result.get("status") != status:
		return _fail("%s expected %s, got %s" % [label, status, result])
	return true


func _json_round_trip(value: Variant) -> Variant:
	return JSON.parse_string(JSON.stringify(value))


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix): return argument.trim_prefix(prefix)
	return ""


func _fail(message: String) -> bool:
	push_error("G3-02 FAIL | %s" % message)
	quit(1)
	return false
