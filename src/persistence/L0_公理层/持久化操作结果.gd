extends RefCounted

## Persistence 模块公开结果的稳定状态集合。
##
## 状态只描述 durable identity / transaction / storage outcome，不判断 Narrative 或 World
## 业务内容是否合理。L2/L3 只能返回这些可观察状态，禁止用空 Dictionary 隐藏失败。

const READY := "ready"
const FOUND := "found"
const COMMITTED := "committed"
const REPLAY_SUCCESS := "replay_success"
const ALREADY_EXISTS := "already_exists"
const STALE_HEAD := "stale_head"
const MUTATION_CONFLICT := "mutation_conflict"
const NOT_FOUND := "not_found"
const INVALID_INPUT := "invalid_input"
const STORAGE_FAILURE := "storage_failure"
const SCHEMA_MISMATCH := "schema_mismatch"
const NOT_OPEN := "not_open"


static func make(status: String, message: String = "", details: Dictionary = {}) -> Dictionary:
	var result := {
		"status": status,
		"success": status in [READY, FOUND, COMMITTED, REPLAY_SUCCESS],
		"committed": status == COMMITTED,
		"replayed": status == REPLAY_SUCCESS,
		"message": message,
	}
	for key: Variant in details:
		result[key] = details[key]
	return result
