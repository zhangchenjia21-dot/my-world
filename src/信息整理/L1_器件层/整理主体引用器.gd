extends RefCounted

const Contract := preload("res://src/信息整理/L0_公理层/信息整理契约.gd")

## 每请求随机 refs 只暴露安全快照；映射与 durable identity 始终留在 Program。
static func request(people: Dictionary, threads: Array, game: String, prefix: String, entry: Dictionary, actors: Dictionary) -> Dictionary:
	var nonce := Crypto.new().generate_random_bytes(12).hex_encode()
	var persons := {}
	var person_rows: Array = []
	for id: String in people:
		var ref := "subject-" + nonce + "-" + str(persons.size())
		persons[ref] = id
		person_rows.append({"person_ref": ref, "snapshot": people[id].snapshot.duplicate(true)})
	var thread_refs := {}
	var thread_rows: Array = []
	for item: Dictionary in threads:
		var ref := "thread-" + nonce + "-" + str(thread_refs.size())
		thread_refs[ref] = item.thread_id
		thread_rows.append({"thread_ref": ref, "title": item.title, "summary": item.summary, "details": item.details.duplicate()})
	return {"people": people, "persons": persons, "thread_refs": thread_refs, "actors": actors,
		"game": game, "prefix": prefix, "entry": entry, "person_rows": person_rows, "thread_rows": thread_rows}

static func resolve_threads(value: Variant, context: Dictionary) -> Variant:
	if not value is Array or value.size() > 12: return null
	var result: Array = []
	var seen := {}
	for index: int in value.size():
		var item: Variant = value[index]
		if not Contract.keys_exact(item, ["thread_ref", "title", "summary", "details"]): return null
		var snapshot := {"title": item.title, "summary": item.summary, "details": item.details}
		if not Contract.threads_valid([snapshot]): return null
		var id := ""
		if item.thread_ref == null:
			id = JSON.stringify(["thread", context.game, context.prefix, index]).sha256_text()
		elif item.thread_ref is String and context.thread_refs.has(item.thread_ref):
			id = context.thread_refs[item.thread_ref]
		else: return null
		if seen.has(id): return null
		seen[id] = true
		snapshot["thread_id"] = id
		result.append(snapshot)
	return result

## 精确坐标只验证来源，不判断语义价值；歧义身份/关联独立 fail-soft。
static func resolve_people(value: Variant, context: Dictionary) -> Array:
	if not value is Array or value.size() > 8: return []
	var proposals: Array = []
	for index: int in value.size():
		var item: Variant = value[index]
		if not Contract.keys_exact(item, ["person_ref", "actor_ref", "source_role", "source_span", "snapshot"]): continue
		var id := ""
		var actor := ""
		if item.person_ref == null:
			if item.snapshot == null or item.source_role not in ["player", "gm"]: continue
			var source: String = context.entry.get("player_text" if item.source_role == "player" else "gm_text", "")
			var span: Variant = item.source_span
			if not Contract.keys_exact(span, ["start", "length"]): continue
			if not (span.start is int or span.start is float) or not (span.length is int or span.length is float): continue
			if span.start != int(span.start) or span.length != int(span.length): continue
			if span.start < 0 or span.length < 1 or span.length > 600 or span.start + span.length > source.length(): continue
			id = JSON.stringify(["subject", context.game, context.prefix, item.source_role, span, index], "", true).sha256_text()
		elif item.person_ref is String and context.persons.has(item.person_ref):
			id = context.persons[item.person_ref]
			actor = context.people[id].actor_id
		else: continue
		if item.actor_ref != null:
			if not item.actor_ref is String or not context.actors.has(item.actor_ref): continue
			var linked: String = context.actors[item.actor_ref]
			if not actor.is_empty() and actor != linked: continue
			actor = linked
			if item.person_ref == null:
				if context.people.has(linked): continue
				id = linked
		var snapshot: Variant = null if item.snapshot == null else Contract.normalize_person(item.snapshot)
		if snapshot != null and snapshot.is_empty(): continue
		proposals.append({"subject_id": id, "actor_id": actor, "snapshot": snapshot})
	var counts := {}
	var actor_subjects := {}
	for id: String in context.people:
		var actor: String = context.people[id].actor_id
		if not actor.is_empty():
			if not actor_subjects.has(actor): actor_subjects[actor] = {}
			actor_subjects[actor][id] = true
	for item: Dictionary in proposals:
		counts[item.subject_id] = int(counts.get(item.subject_id, 0)) + 1
		if not item.actor_id.is_empty():
			if not actor_subjects.has(item.actor_id): actor_subjects[item.actor_id] = {}
			actor_subjects[item.actor_id][item.subject_id] = true
	var result: Array = []
	for item: Dictionary in proposals:
		if counts[item.subject_id] != 1: continue
		if not item.actor_id.is_empty() and actor_subjects[item.actor_id].size() != 1: continue
		result.append(item)
	return result
