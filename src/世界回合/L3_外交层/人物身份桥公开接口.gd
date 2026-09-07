extends RefCounted

const Receipt := preload("res://src/世界回合/L0_公理层/人物身份回执规则.gd")

## 内部 backend 查询：只读验证当前 Game / 完整 accepted 前缀 / actor origin。
## 返回回执副本或 {}；不会发模型请求，不返回 actor material，不是 leaf UI 接口。
static func current_receipt(runtime: Variant, index: int) -> Dictionary:
	return Receipt.current(runtime.world_state, String(runtime.game_id), runtime.conversation.get_durable_accepted_entries(), index)

## 给 lived curator 的请求材料与私有映射分开返回。调用者只能把 evidence 送进模型，
## bindings 映射留在 Program；叶 UI 不接收此 envelope。cue 仅由回执指定的 accepted Player/GM 原文切片。
static func request_evidence(runtime: Variant, index: int) -> Dictionary:
	var receipt := current_receipt(runtime, index)
	if receipt.is_empty():
		return {}
	var entry: Dictionary = runtime.conversation.get_durable_accepted_entries()[index]
	var salt := Crypto.new().generate_random_bytes(12).hex_encode()
	var refs := {}
	var evidence: Array = []
	for binding: Dictionary in receipt.bindings:
		var ref := "person-" + salt + "-" + str(evidence.size())
		refs[ref] = binding.local_character_id
		if receipt.schema == Receipt.SCHEMA:
			evidence.append({"actor_ref": ref, "gm_span": binding.gm_span.duplicate(true),
				"quote": String(entry.gm_text).substr(int(binding.gm_span.start), int(binding.gm_span.length))})
		else:
			var source := String(entry.get("player_text" if binding.source_role == "player" else "gm_text", ""))
			evidence.append({"actor_ref": ref, "source_role": binding.source_role, "source_span": binding.source_span.duplicate(true),
				"quote": source.substr(int(binding.source_span.start), int(binding.source_span.length))})
	return {"receipt_id": receipt.id, "prefix": receipt.prefix, "bindings": refs, "evidence": evidence}

## 内部历史投影查询：只返回有效身份回执/ID 集，不返回 NPC 真相内容。
## entries 必须来自当前会话 accepted 历史或其前缀；不会恢复 displaced future。
static func receipt_for_history(world: Dictionary, game: String, entries: Array, index: int) -> Dictionary:
	return Receipt.current(world, game, entries, index)

static func applicable_npc_ids(world: Dictionary, entries: Array) -> Dictionary:
	return Receipt.npc_ids(world, entries, entries.size() - 1)
