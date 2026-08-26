extends RefCounted

const Fixture := preload("res://tests/g3_01/持久化夹具.gd")


func run(database_path: String) -> bool:
	if database_path.is_empty():
		return _fail("missing exported database path")
	var database := Fixture.open_database(database_path)
	if database == null or not Fixture.create_schema_v1(database) or not Fixture.seed_initial_game(database):
		return _fail("exported EXE create/write")
	database.close_db()
	var reopened := Fixture.open_database(database_path)
	if reopened == null:
		return _fail("exported EXE reopen")
	var game_id: Variant = Fixture.scalar(reopened, "SELECT game_id FROM g3_fixture_games LIMIT 1;", [], "game_id")
	var head: Variant = Fixture.scalar(reopened, "SELECT active_head_id FROM g3_fixture_games WHERE game_id = ?;", [Fixture.GAME_ID], "active_head_id")
	reopened.close_db()
	if game_id != Fixture.GAME_ID or head != Fixture.INITIAL_HEAD_ID:
		return _fail("exported EXE exact read")
	print("G3-01 PASS | exported Windows EXE open/write/close/reopen/read")
	return true


func _fail(message: String) -> bool:
	push_error("G3-01 FAIL | %s" % message)
	return false
