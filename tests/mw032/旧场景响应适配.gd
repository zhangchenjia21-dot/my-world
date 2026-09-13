extends RefCounted

## 旧场景测试明确保留其语义意图，转成新请求协议；仅测试器使用，生产解析器不兼容旧响应。
## 对已有 actor/Thread 只用请求私有精确映射或旧测试既定 ordinal，不按姓名/标题猜。
static func convert(result: Dictionary, context: Dictionary, bindings: Dictionary) -> Dictionary:
	if context.is_empty(): return result
	var next := result.duplicate(true)
	if not next.has("character") or not next.has("experiences"): return next
	var updates: Array=[]
	for item: Variant in next.get("people_updates",[]):
		if not item is Dictionary or item.has("person_ref"):
			updates.append(item);continue
		if not item.has("actor_ref") or not item.has("snapshot"):
			updates.append(item);continue
		var actor: String=bindings.get(item.actor_ref, "")
		var person_ref: Variant=null
		for ref: String in context.persons:
			if context.people[context.persons[ref]].actor_id==actor and not actor.is_empty(): person_ref=ref
		var role: Variant=null
		var span: Variant=null
		if person_ref==null:
			role="gm"
			span={"start":0,"length":1}
		var converted: Dictionary={"person_ref":person_ref,"actor_ref":item.actor_ref,"source_role":role,"source_span":span,"snapshot":item.snapshot}
		for key: String in item:
			if key not in ["actor_ref","snapshot"]: converted[key]=item[key]
		updates.append(converted)
	next["people_updates"]=updates
	var threads: Variant=next.get("open_threads")
	if threads==null:
		next["open_threads"]=context.thread_rows.duplicate(true)
	elif threads is Array:
		for index: int in threads.size():
			if threads[index] is Dictionary and not threads[index].has("thread_ref"):
				threads[index]["thread_ref"]=context.thread_rows[index].thread_ref if index<context.thread_rows.size() else null
	return next
