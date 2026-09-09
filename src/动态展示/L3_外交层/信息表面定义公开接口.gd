extends RefCounted

## 仅把调用方已取得的 domain-safe DTO 转成临时展示树；不访问 Runtime、Source 或偏好。
static func build(surface: String, value: Variant) -> Dictionary:
	var nodes: Array=[]
	match surface:
		"character":
			if not value.headline.is_empty(): nodes.append(_text(value.headline))
			if not value.summary.is_empty(): nodes.append(_text(value.summary))
			for group: Dictionary in value.groups: nodes.append(_facts(group.items,group.title))
			if nodes.is_empty(): nodes.append(_text("角色信息将随游戏进展整理显示。","muted"))
			elif value.groups.is_empty(): nodes.append(_text("暂无更多角色信息。","muted"))
		"important_experiences":
			for item: Dictionary in value: nodes.append(_card(item.title,[_text(item.description)],false,"",item.presentation_key))
			if nodes.is_empty(): nodes.append(_text("尚无需要长期记录的重要经历。","muted"))
		"people":
			for person: Dictionary in value:
				var body: Array=[]
				for field: String in ["summary","relationship"]:
					if not person[field].is_empty(): body.append(_text(person[field]))
				body.append(_facts(person.details))
				nodes.append(_card(person.display_name,body,true,person.headline,person.presentation_key))
			if nodes.is_empty(): nodes.append(_text("人物信息将随你结识和了解他们而整理。","muted"))
		"threads":
			for item: Dictionary in value: nodes.append(_card(item.title,[_text(item.summary),_facts(item.details)]))
			if nodes.is_empty(): nodes.append(_text("目前没有需要持续跟进的事务。"))
		"inventory":
			nodes.append(_text("当前行囊","heading"))
			for item: Dictionary in value: nodes.append(_card(item.name,[_text(item.summary)]))
			if value.is_empty(): nodes.append(_text("当前没有已记录的随身物品。"))
		"system":
			nodes.append(_text("近期公开判定","heading"))
			for record: Dictionary in value:
				var fields: Array=[
					{"label":"结果","value":{"success":"成功","failure":"失败"}.get(record.outcome,record.outcome)},
					{"label":"d20","value":"%s → %d + %d = %d vs DC %d" % [str(record.get("raw_rolls",[])),record.selected_roll,record.modifier,record.total,record.dc]},
					{"label":"形势","value":"%s · %s" % [{"normal":"正常","advantage":"优势","disadvantage":"劣势"}.get(record.stance,record.stance),record.get("situation_reason","")]},
					{"label":"修正","value":String(record.get("modifier_reason",""))},
					{"label":"成功意味着","value":record.success_intent},
					{"label":"失败风险","value":record.failure_stakes}]
				nodes.append(_card("第 %d 回合 · %s" % [record.accepted_turn,record.intent],[{"kind":"field_list","title":"","fields":fields}]))
			if value.is_empty(): nodes.append(_text("暂无公开判定记录。"))
	_ids(nodes,"surface")
	return {"surface":surface,"children":nodes}

static func _text(text: String, role: String = "body") -> Dictionary:
	return {"kind":"text","text":text,"role":role}

static func _facts(items: Array, title: String = "") -> Dictionary:
	return {"kind":"section","title":title,"children":[{"kind":"fact_list","title":"","items":items.duplicate()}]}

static func _card(title: String, children: Array, collapsible: bool = false, subtitle: String = "", key: String = "") -> Dictionary:
	return {"kind":"card","title":title,"subtitle":subtitle,"children":children,"collapsible":collapsible,"visibility_key":key}

# component_id 只用于一棵临时树的唯一性，位置从不承担可见偏好身份。
static func _ids(nodes: Array, prefix: String) -> void:
	for index: int in nodes.size():
		var node: Dictionary=nodes[index]; node["component_id"]=prefix+"_"+str(index)
		if node.has("children"): _ids(node.children,node.component_id)
