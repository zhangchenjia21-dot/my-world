extends SceneTree

const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Safety := preload("res://src/persistence/L3_外交层/数据库安全公开接口.gd")


func _initialize() -> void:
	var path := _argument("--db=")
	var mode := _argument("--mode=")
	if path.find("g3_06") < 0:
		_fail("task-owned --db is required")
		return
	match mode:
		"seed_backup":
			var runtime := Runtime.new()
			if not runtime.open_current_game(path).success or not runtime.create_save_point("崩溃验证存档").success:
				_fail("backup seed failed"); return
			runtime.close()
			_pass("backup seed")
		"seed_corrupt":
			var runtime := Runtime.new()
			if not runtime.open_current_game(path).success or not runtime.create_save_point("灾难恢复目标").success:
				_fail("recovery seed failed"); return
			runtime.close()
			var file := FileAccess.open(path, FileAccess.WRITE)
			file.store_string("intentional G3-06 crash recovery corruption")
			file.close()
			_pass("corrupt seed")
		"verify_backup":
			var safety := Safety.new()
			if not safety.acquire_writer(path).success:
				_fail("backup verify ownership"); return
			var inspection: Dictionary = safety.inspect_startup()
			var backup: Dictionary = safety.backup_availability()
			safety.release_writer()
			if not inspection.success or not backup.success:
				_fail("interrupted backup lost current/recovery copy: %s / %s" % [inspection, backup]); return
			_pass("interrupted backup remains recoverable")
		"verify_retry":
			var damaged := Runtime.new()
			var classified: Dictionary = damaged.open_current_game(path)
			if String(classified.status) not in ["physical_corruption", "interrupted_recovery"] or not bool(classified.get("recovery_available", false)):
				_fail("interrupted recovery was not retryable: %s" % classified); return
			if damaged.recover_damaged_database().status != "reopen_required":
				_fail("retry publication failed"); return
			var reopened := Runtime.new()
			if not reopened.open_current_game(path).success:
				_fail("retry recovered current did not reopen"); return
			reopened.close()
			_pass("quarantine interruption retry")
		"verify_published":
			var reopened := Runtime.new()
			if not reopened.open_current_game(path).success:
				_fail("published replacement did not reopen"); return
			reopened.close()
			_pass("post-publication reopen")
		_:
			_fail("unknown fixture mode")


func _pass(label: String) -> void:
	print("G3-06 CRASH VERIFY PASS | %s" % label)
	quit(0)


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix): return value.trim_prefix(prefix)
	return ""


func _fail(message: String) -> void:
	push_error("G3-06 CRASH VERIFY FAIL | %s" % message)
	quit(1)
