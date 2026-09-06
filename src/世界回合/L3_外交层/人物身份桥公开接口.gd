extends RefCounted

const Receipt := preload("res://src/世界回合/L0_公理层/人物身份回执规则.gd")

## 内部 backend 查询：只读验证当前 Game / 完整 accepted 前缀 / actor origin。
## 返回回执副本或 {}；不会发模型请求，不返回 actor material，不是 leaf UI 接口。
static func current_receipt(runtime: Variant, index: int) -> Dictionary:
	return Receipt.current(runtime.world_state, String(runtime.game_id), runtime.conversation.get_durable_accepted_entries(), index)

## 给未来 curator 的请求材料与私有映射分开返回。调用者只能把 evidence 送进模型，
## bindings 映射留在 Program；叶 UI 不接收此 envelope。cue 仅由 accepted GM 原文切片。
static func request_evidence(runtime: Variant, index: int) -> Dictionary:
	var receipt := current_receipt(runtime, index)
	if receipt.is_empty():
		return {}
	var gm := String(runtime.conversation.get_durable_accepted_entries()[index].gm_text)
	var salt := Crypto.new().generate_random_bytes(12).hex_encode()
	var refs := {}
	var evidence: Array = []
	for binding: Dictionary in receipt.bindings:
		var ref := "person-" + salt + "-" + str(evidence.size())
		refs[ref] = binding.local_character_id
		evidence.append({"actor_ref": ref, "gm_span": binding.gm_span.duplicate(true),
			"quote": gm.substr(int(binding.gm_span.start), int(binding.gm_span.length))})
	return {"receipt_id": receipt.id, "prefix": receipt.prefix, "bindings": refs, "evidence": evidence}
