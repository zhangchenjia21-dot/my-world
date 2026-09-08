extends RefCounted

## Accepted Conversation 的模式与版本材料公开契约。纯计算、无 I/O；旧 action/opening
## 保留历史 hash 材料，只有显式 OOC 增加 discriminator，禁止通过文本推断模式。
static func mode(entry: Dictionary) -> String:
	return String(entry.get("input_mode", "opening" if String(entry.get("player_text", "")).is_empty() else "action"))

## 校验仅允许两种玩家模式；opening 只用于已有 GM-only 空槽。
static func valid(entry: Dictionary) -> bool:
	var value: Variant = entry.get("input_mode", null)
	return not entry.has("input_mode") or (value is String and (value in ["action", "ooc"] or (value == "opening" and String(entry.get("player_text", "")).is_empty())))

## 只投影既有 authoritative 字段；不改变 Player/GM 原文。
static func normalize(entry: Dictionary, index: int) -> Dictionary:
	return {"turn_index": index, "player_text": entry.player_text, "gm_text": entry.gm_text, "input_mode": mode(entry)}

## 共享历史前缀算法：legacy/action/opening 的旧 [parent,Player,GM] 字节保持不变。
static func prefix_hashes(entries: Array) -> Array:
	var hashes: Array = []
	var previous := ""
	for entry: Dictionary in entries:
		var material: Array = [previous, entry.get("player_text", ""), entry.get("gm_text", "")]
		if mode(entry) == "ooc": material.append("input_mode=ooc")
		previous = JSON.stringify(material).sha256_text()
		hashes.append(previous)
	return hashes

## World 旧 GM hash 仍有效；OOC 不提供任何 World/actor/Knowledge 的 current source。
static func world_hashes(entries: Array) -> Dictionary:
	var hashes := {}
	for value: Variant in entries:
		if not value is Dictionary: continue
		var entry: Dictionary = value
		var index := int(entry.get("turn_index", -1))
		if index >= 0 and entry.get("gm_text") is String and mode(entry) != "ooc":
			hashes[index] = String(entry.gm_text).sha256_text()
	return hashes

## Recommender 的旧完整 projection hash 保留；mode 仅在 OOC 时进入序列化材料。
static func version_entries(entries: Array) -> Array:
	var result: Array = []
	for entry: Dictionary in entries:
		var item := {"turn_index": entry.turn_index, "player_text": entry.player_text, "gm_text": entry.gm_text}
		if mode(entry) == "ooc": item["input_mode"] = "ooc"
		result.append(item)
	return result
