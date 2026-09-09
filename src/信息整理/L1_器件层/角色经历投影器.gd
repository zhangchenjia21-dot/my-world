extends RefCounted

const Contract := preload("res://src/信息整理/L0_公理层/信息整理契约.gd")

# 外交层传入已验证的 frozen profile；初始摘要保持可用，任意 authored 组不由程序重新
# 分类成 Character（其中可能含起始携带物）。完整组只供模型整理，不直出本 seam。
static func project(world: Dictionary, entries: Array, profile: Dictionary, presentation_game: String = "") -> Dictionary:
	var character := {"headline": profile.get("headline", ""), "summary": profile.get("summary", ""), "groups": []}
	var initial := Contract.current_initial(world, profile)
	if not initial.is_empty():
		character = initial.result.character.duplicate(true)
	var experiences: Array = []
	for record: Dictionary in Contract.current_records(world, entries):
		var result: Dictionary = record.result
		if result.character != null:
			character = result.character.duplicate(true)
		for ordinal: int in result.experiences.size():
			var event: Dictionary = result.experiences[ordinal]
			# 当前没有独立权威 game-world calendar label；不以机器时间/回合号伪造日期。
			var item := {"title": event.title, "description": event.description, "time_label": ""}
			if not presentation_game.is_empty():
				item["presentation_key"] = JSON.stringify(["experience",presentation_game,record.id,ordinal]).sha256_text()
			experiences.append(item)
	return {"character": character, "important_experiences": experiences}
