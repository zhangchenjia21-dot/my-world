extends RefCounted

# 仅定义机器结构边界；组的归属、是否改变和经历的重要性由模型决定。
const SCHEMA := "information_curation.v0.1"
const MAX_RESPONSE_BYTES := 65536
const GROUPS := ["基本资料", "出身 / 来历", "当前身份 / 社会角色", "性格 / 价值观 / 原则", "能力 / 专长说明", "局限 / 长期特征", "长期目标 / 自我方向"]

static func keys_exact(value: Variant, keys: Array) -> bool:
	if not value is Dictionary or value.size() != keys.size():
		return false
	for key: Variant in keys:
		if not value.has(key):
			return false
	return true

static func text_valid(value: Variant, maximum: int, empty: bool = false) -> bool:
	return value is String and value.length() <= maximum and (empty or not value.strip_edges().is_empty())

static func normalize(value: Variant) -> Dictionary:
	if not keys_exact(value, ["character", "experiences"]):
		return {}
	var character: Variant = value.character
	if character != null:
		if not keys_exact(character, ["headline", "summary", "groups"]):
			return {}
		if not text_valid(character.headline, 160, true) or not text_valid(character.summary, 1600, true):
			return {}
		if not character.groups is Array or character.groups.size() > 7:
			return {}
		var seen: Array = []
		for group: Variant in character.groups:
			if not keys_exact(group, ["title", "items"]) or not group.title in GROUPS or group.title in seen:
				return {}
			seen.append(group.title)
			if not group.items is Array or group.items.size() > 12:
				return {}
			for item: Variant in group.items:
				if not text_valid(item, 600):
					return {}
	if not value.experiences is Array or value.experiences.size() > 4:
		return {}
	for event: Variant in value.experiences:
		if not keys_exact(event, ["title", "description"]):
			return {}
		if not text_valid(event.title, 160) or not text_valid(event.description, 1200):
			return {}
	return value.duplicate(true)

# 前缀包含 Player 与 GM 原文；前序版本替换使所有依赖该历史的整理结果失效。
static func prefix_hashes(entries: Array) -> Array:
	var hashes: Array = []
	var previous := ""
	for entry: Dictionary in entries:
		previous = JSON.stringify([previous, entry.get("player_text", ""), entry.get("gm_text", "")]).sha256_text()
		hashes.append(previous)
	return hashes

static func record_id(prefix: String, parent: String, result: Dictionary) -> String:
	return JSON.stringify([prefix, parent, result], "", true).sha256_text()

static func current_records(world: Dictionary, entries: Array) -> Array:
	var owner: Variant = world.get("information_curation", {})
	if not owner_valid(owner):
		return []
	var prefixes := prefix_hashes(entries)
	var records: Array = []
	var parent := ""
	for index: int in range(entries.size()):
		var record: Variant = owner.turns.get(str(index), {})
		if not keys_exact(record, ["prefix", "parent", "id", "result"]):
			continue
		var result := normalize(record.result)
		if result.is_empty() or record.prefix != prefixes[index] or record.parent != parent:
			continue
		if record.id != record_id(prefixes[index], parent, result):
			continue
		records.append({"index": index, "id": record.id, "result": result})
		parent = record.id
	return records

# 可选 initial 不进入历史回合父链；旧 owner 无需迁移。
static func owner_valid(owner: Variant) -> bool:
	return (keys_exact(owner, ["schema", "turns"]) or keys_exact(owner, ["schema", "initial", "turns"])) and owner.schema == SCHEMA and owner.turns is Dictionary

# 输入已由 Profile L3 验证。仅规范结构，不按 authored 标题或内容筛选。
static func initial_input(profile: Dictionary) -> Dictionary:
	if not profile.get("success", false):
		return {}
	return {"headline": profile.headline, "summary": profile.summary, "groups": profile.groups.duplicate(true)}

static func initial_binding(profile: Dictionary) -> String:
	var material := initial_input(profile)
	return "" if material.is_empty() else JSON.stringify(material, "", true).sha256_text()

# 节点在当前 Game 的 SQLite 命名空间内稳定定位；Restore 后可只读找回同一 T0 结果。
static func initial_node_id(binding: String) -> String:
	return "initial-character-" + binding

static func current_initial(world: Dictionary, profile: Dictionary) -> Dictionary:
	var owner: Variant = world.get("information_curation", {})
	if not owner_valid(owner):
		return {}
	var record: Variant = owner.get("initial", {})
	if not keys_exact(record, ["binding", "id", "result"]):
		return {}
	var binding := initial_binding(profile)
	var result := normalize(record.result)
	if binding.is_empty() or record.binding != binding or result.is_empty():
		return {}
	# T0 没有 accepted lived event；不是按事件语义判断重要性。
	if result.character == null or not result.experiences.is_empty():
		return {}
	if record.id != record_id("initial", binding, result):
		return {}
	return record.duplicate(true)
