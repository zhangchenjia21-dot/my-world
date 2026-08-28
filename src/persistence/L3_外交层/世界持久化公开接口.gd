extends RefCounted

const Flow := preload("res://src/persistence/L2_流程层/世界持久化流程.gd")

var _flow: Variant = Flow.new()


## 打开调用方明确指定的数据库并验证/迁移 production schema。
## 不扫描 user://、不选择最近 Game，也不暴露 SQLite connection/row。
func open_database(database_path: String) -> Dictionary:
	return _flow.open(database_path)


func close_database() -> Dictionary:
	return _flow.close()


## 原子创建 Game、root Timeline Node recovery anchor 与唯一 writable current World。
## 重复 game_id 不覆盖；所有 identity 与 opaque World document 都由上层提供。
func create_initial_game(game_id: String, root_node_id: String, initial_world_state: Variant, created_at: String) -> Dictionary:
	return _flow.create_initial_game(game_id, root_node_id, initial_world_state, created_at)


## 枚举当前 DB 中的 Game identities，供 one-current-Game runtime 判断 0/1/ambiguous。
## 本接口不选择最近 Game，也不泄露 games row。
func list_game_identities() -> Dictionary:
	return _flow.list_game_identities()


## 读取 current accepted Conversation materialization；只返回 accepted pairs 与 revision。
## 正常 absence 是 not_found，query/corruption failure 是 storage_failure。
func get_current_conversation(game_id: String) -> Dictionary:
	return _flow.get_current_conversation(game_id)


## 原子替换 current accepted Conversation。调用方必须传入 Conversation Domain 产生的
## prospective projection；COMMIT 前不得在 Domain/UI 宣布 accepted success。
func write_current_conversation(game_id: String, accepted_entries: Variant, updated_at: String) -> Dictionary:
	return _flow.write_current_conversation(game_id, accepted_entries, updated_at)


## 在一个 transaction 内从 durable current head + accepted Conversation 创建 immutable
## Save Point。display_name 只用于玩家展示，stable save_id 才是 identity。
func create_save_point(game_id: String, save_id: String, display_name: String, created_at: String) -> Dictionary:
	return _flow.create_save_point(game_id, save_id, display_name, created_at)


## 返回 player-facing Save read model；不返回 accepted snapshot 或 SQLite row。
func list_save_points(game_id: String) -> Dictionary:
	return _flow.list_save_points(game_id)


## 返回单个 Save 的恢复候选，供 Conversation Domain 在 durable mutation 前 non-mutating validate。
func get_save_point(game_id: String, save_id: String) -> Dictionary:
	return _flow.get_save_point(game_id, save_id)


## 原子恢复 current World/head/accepted Conversation。validated_accepted_entries 必须来自
## Conversation Domain validation，且必须 exact 匹配 immutable Save recovery material。
func restore_save_point(game_id: String, save_id: String, validated_accepted_entries: Variant, updated_at: String, recovery_id: String = "") -> Dictionary:
	return _flow.restore_save_point(game_id, save_id, validated_accepted_entries, updated_at, recovery_id)


## 返回 latest Recovery candidate，供 Conversation Domain 在 Recover transaction 前验证。
## durable sequence 只在模块内部排序，不作为公开 identity 或 UI 调试信息。
func get_latest_recovery(game_id: String) -> Dictionary:
	return _flow.get_latest_recovery(game_id)


## 原子捕获 current reciprocal Recovery 并切换到 exact latest Recovery target。
func recover_previous_progress(game_id: String, target_recovery_id: String, validated_accepted_entries: Variant, reciprocal_recovery_id: String, updated_at: String) -> Dictionary:
	return _flow.recover_previous_progress(game_id, target_recovery_id, validated_accepted_entries, reciprocal_recovery_id, updated_at)


## 测试与治理验证用稳定计数；不返回 SQLite rows 或 Recovery history。
func recovery_checkpoint_count(game_id: String) -> Dictionary:
	return _flow.recovery_checkpoint_count(game_id)


## 在一个 transaction 中提交 immutable node snapshot、current World 与 active head。
## expected_head 防 stale writer；同 mutation_id 的 exact replay 恢复既有成功，冲突复用不写入。
## 仅 COMMIT 成功后返回 committed；任一失败都不得留下 partial durable truth。
func commit_world_mutation(game_id: String, mutation_id: String, expected_head_id: String, node_id: String, next_world_state: Variant, created_at: String) -> Dictionary:
	return _flow.commit_world_mutation(game_id, mutation_id, expected_head_id, node_id, next_world_state, created_at)


## 读取唯一 current World 投影；成功零行返回 not_found，底层 SELECT 失败返回 storage_failure。
## current World 是 authoritative materialization，不是 historical snapshot。
func get_current_game(game_id: String) -> Dictionary:
	return _flow.get_current_game(game_id)


## 读取 immutable historical recovery anchor；成功零行与底层 SELECT failure 保持可观察区分。
## 此接口没有历史修改能力。
func get_timeline_node(game_id: String, node_id: String) -> Dictionary:
	return _flow.get_timeline_node(game_id, node_id)


## 返回稳定计数结果；底层 query failure 返回 storage_failure，不以空 rows 或 runtime error 代替。
func timeline_node_count(game_id: String) -> Dictionary:
	return _flow.timeline_node_count(game_id)
