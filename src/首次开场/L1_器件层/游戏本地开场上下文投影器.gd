class_name GameLocalOpeningContextProjector
extends RefCounted

const Rules := preload("res://src/首次开场/L0_公理层/首次开场规则.gd")

## 这不是 G7 retrieval/summarization 平台。上限只拒绝异常大的 durable setup；
## 上限以内的已选 section 按稳定顺序全文进入请求，不做逐节截断或一句话摘要。
const MAX_CONTEXT_CHARS := 180000

## MW-005：文学风格参考是唯一非事实 section_type——仅供 GM 吸收措辞/句法/称谓/叙事距离，
## 不构成世界事实、未来 canon、NPC 命运、Knowledge 或 World Evolution 因果输入。
const STYLE_SECTION_TYPE := "literary_style_reference"
const STYLE_BOUNDARY_HEADER := "## Literary Style Reference | 文学风格参考（非世界事实）\n以下范例仅用于表达参考：措辞、句法节奏、称谓礼法、对白方式与叙事距离。其中人物、事件、地点与结局不构成当前 Game 的世界事实或既定未来，不是 Player/actor Knowledge，也不是任何因果推演依据。"

## MW-005 R3：narrative-only 的正向表达 cue。它是 style anchor 的组成部分，
## 只引导表达取向，不构成输出协议、门禁、评分或任何 authority；不随 section 增长。
const STYLE_NARRATIVE_ANCHOR_CUE := "表达锚点：当存在以上 Literary Style Reference 时，它是本局中文 GM 叙事的默认声音锚点。让句法节奏、称谓礼法、对白方式、信息传递方式与叙事距离自然向它靠拢；军事、政治与政务信息优先作为场景、信使/塘报、问答或文书等当时之人自然获知的方式进入叙事，而不是现代战略简报式的罗列。保持清晰可读，不机械堆砌章回套语或古语标签。"


## MW-005 R3：project() 返回分离的两份材料——
##   context_text          = 纯事实 Game/World/Player/Character 材料；
##   style_reference_text  = 派生的 request-only style anchor（边界 + Primer + 正向 cue），
##     由 narrative consumer 自行决定追加在 narrative context 末尾，保持 salience；
##     control/control_recovery（include_style=false）与 project_world_only() 恒为空串。
func project(setup_value: Variant, include_style: bool = true) -> Dictionary:
	var validation := Rules.validate_setup(setup_value)
	if not validation.success:
		return validation
	var setup := (setup_value as Dictionary).duplicate(true)
	var blocks: Array[String] = []
	var style_parts: Array[String] = []
	var stats := {
		"world_sections": 0,
		"player_sections": 0,
		"npc_sections": 0,
		"npc_count": 0,
		"selected_entry": setup.get("selected_entry_id"),
		"context_chars": 0,
		"style_chars": 0,
	}

	_append_runtime_contract(blocks, setup)
	_append_game(blocks, setup.game as Dictionary, setup.get("selected_entry_id"))
	var world_result := _append_world(blocks, style_parts, setup.world as Dictionary, include_style)
	if not world_result.success:
		return world_result
	stats.world_sections = int(world_result.section_count)
	var player_result := _append_character(blocks, style_parts, "Player Character", setup.player_character as Dictionary)
	if not player_result.success:
		return player_result
	stats.player_sections = int(player_result.section_count)

	var npcs := setup.guaranteed_npcs as Array
	stats.npc_count = npcs.size()
	if not npcs.is_empty():
		blocks.append("## Canonical Cast\nThese characters belong to this Game's canonical cast. Membership alone does NOT mean opening presence, same location, player familiarity, an existing relationship, or mandatory dialogue.")
	for npc_value: Variant in npcs:
		if typeof(npc_value) != TYPE_DICTIONARY:
			return Rules.failure("invalid_game_setup", "Guaranteed NPC definition 无效。")
		var npc_result := _append_character(blocks, style_parts, "Guaranteed NPC", npc_value as Dictionary)
		if not npc_result.success:
			return npc_result
		stats.npc_sections += int(npc_result.section_count)

	var style_reference_text := ""
	if include_style and not style_parts.is_empty():
		style_reference_text = "%s\n\n%s\n\n%s" % [STYLE_BOUNDARY_HEADER, "\n\n".join(style_parts), STYLE_NARRATIVE_ANCHOR_CUE]
	var text := "\n\n".join(blocks)
	stats.context_chars = text.length()
	stats.style_chars = style_reference_text.length()
	if text.length() + style_reference_text.length() > MAX_CONTEXT_CHARS:
		return Rules.failure("context_too_large", "Game-local Opening Context 超出安全上限；没有截断或摘要后继续发送。", stats)
	return Rules.success({"context_text": text, "style_reference_text": style_reference_text, "stats": stats})


## MW-002：World-only T0 baseline——只投影 durable setup 的 World 部分（World identity /
## instructions / selected Entry / World semantic sections），不含 Player/Character 私有材料。
## R2 F03：不得复用 _append_game——Game settings（control_mode / opening_supplement /
## display_name 等）不属于 World-only authority；只用最小中性 Game-local header。
## MW-005：literary_style_reference 整类排除——风格参考绝不进入 World Evolution 因果输入。
## 超限/无效 fail-soft；不截断、不摘要、不查询 mutable Source current。
func project_world_only(setup_value: Variant) -> Dictionary:
	var validation := Rules.validate_setup(setup_value)
	if not validation.success:
		return validation
	var setup := (setup_value as Dictionary).duplicate(true)
	var blocks: Array[String] = []
	_append_runtime_contract(blocks, setup)
	_append_world_only_game_header(blocks, setup.game as Dictionary, setup.get("selected_entry_id"))
	var world_result := _append_world(blocks, [], setup.world as Dictionary, false)
	if not world_result.success:
		return world_result
	var text := "\n\n".join(blocks)
	var stats := {"world_sections": int(world_result.section_count), "context_chars": text.length()}
	if text.length() > MAX_CONTEXT_CHARS:
		return Rules.failure("context_too_large", "Game-local World-only baseline 超出安全上限；World Evolution 本次 fail-soft 为 hold。", stats)
	return Rules.success({"context_text": text, "stats": stats})


## MW-002 R2 F03：World-only baseline 的最小中性 Game-local authority header——
## 只含 Game ID 与 Selected Entry；排除 control_mode / opening_supplement 等 Game settings。
func _append_world_only_game_header(blocks: Array[String], game: Dictionary, selected_entry: Variant) -> void:
	blocks.append("## Game-local World Authority\nGame ID: %s\nSelected Entry: %s" % [
		String(game.get("game_id", "")),
		"none" if selected_entry == null else String(selected_entry),
	])


func _append_runtime_contract(blocks: Array[String], setup: Dictionary) -> void:
	var no_entry := setup.get("selected_entry_id") == null
	var entry_rule := "No Entry was selected. Do not infer a default Entry, profile, year, or historical cut." if no_entry else "Only the exact durable selected Entry/profile material below is authoritative."
	blocks.append("# Durable Game-local Opening Truth\nThis text was read from the opened Game's durable current/root setup. Do not reconstruct it from Source current or external canon.\n%s\nLater or unselected external canon is not this Game's future. Continue only from current Game-local causality." % entry_rule)


func _append_game(blocks: Array[String], game: Dictionary, selected_entry: Variant) -> void:
	blocks.append("## Game Setup\nGame ID: %s\nDisplay name: %s\nControl mode: %s\nSelected Entry: %s\nOpening supplement: %s" % [
		String(game.get("game_id", "")),
		String(game.get("display_name", "")),
		String(game.get("control_mode", "")),
		"none" if selected_entry == null else String(selected_entry),
		String(game.get("opening_supplement", "")),
	])


func _append_world(blocks: Array[String], style_parts: Array[String], world: Dictionary, include_style: bool = true) -> Dictionary:
	var projection_value: Variant = world.get("source_projection")
	if typeof(projection_value) != TYPE_DICTIONARY:
		return Rules.failure("invalid_game_setup", "World selected projection 无效。")
	var projection := projection_value as Dictionary
	var identity := projection.get("identity", {}) as Dictionary
	var provenance := world.get("provenance", {}) as Dictionary
	blocks.append("## World\nLocal World ID: %s\nName: %s\nSource provenance: %s @ %s\nWorld instructions: %s\nGM instructions: %s" % [
		String(world.get("local_world_id", "")), String(projection.get("display_name", "")),
		String(provenance.get("asset_id", identity.get("asset_id", ""))), String(provenance.get("generation_fingerprint", "")),
		String(projection.get("world_instructions", "")), String(projection.get("gm_instructions", "")),
	])
	var selected_entry := projection.get("selected_entry", {}) as Dictionary
	if not selected_entry.is_empty():
		blocks.append("### Exact Selected World Entry\nEntry ID: %s\nName: %s\nOpening seed: %s" % [String(selected_entry.get("entry_id", "")), String(selected_entry.get("display_name", "")), String(selected_entry.get("opening_seed", ""))])
	return _append_sections(blocks, style_parts, projection.get("semantic_sections"), "World", include_style)


func _append_character(blocks: Array[String], style_parts: Array[String], heading: String, character: Dictionary) -> Dictionary:
	var projection_value: Variant = character.get("source_projection")
	if typeof(projection_value) != TYPE_DICTIONARY:
		return Rules.failure("invalid_game_setup", "%s selected projection 无效。" % heading)
	var projection := projection_value as Dictionary
	var provenance := character.get("provenance", {}) as Dictionary
	var selected_profile := projection.get("selected_profile", {}) as Dictionary
	blocks.append("## %s\nLocal Character ID: %s\nName: %s\nSource provenance: %s @ %s\nExact selected profile: %s" % [
		heading, String(character.get("local_character_id", "")), String(projection.get("display_name", "")),
		String(provenance.get("asset_id", "")), String(provenance.get("generation_fingerprint", "")),
		"none" if selected_profile.is_empty() else String(selected_profile.get("profile_id", "")),
	])
	return _append_sections(blocks, style_parts, projection.get("semantic_sections"), heading)


## MW-005：include_style=false 时（control lane / World-only baseline）literary_style_reference
## 整类排除；include_style=true 时 style section 收集进派生 style_parts（R3：不再混入事实 blocks）。
func _append_sections(blocks: Array[String], style_parts: Array[String], sections_value: Variant, owner: String, include_style: bool = true) -> Dictionary:
	if typeof(sections_value) != TYPE_ARRAY:
		return Rules.failure("invalid_game_setup", "%s semantic_sections 无效。" % owner)
	var sections := sections_value as Array
	for section_value: Variant in sections:
		if typeof(section_value) != TYPE_DICTIONARY:
			return Rules.failure("invalid_game_setup", "%s semantic section 无效。" % owner)
		var section := section_value as Dictionary
		if typeof(section.get("content")) != TYPE_STRING or String(section.content).strip_edges().is_empty():
			return Rules.failure("invalid_game_setup", "%s semantic section 缺少已物化全文。" % owner)
		var line := "### %s | %s | %s | %s\n%s" % [String(section.get("section_id", "")), String(section.get("title", "")), String(section.get("section_type", "")), String(section.get("disclosure", "")), String(section.content)]
		if String(section.get("section_type", "")) == STYLE_SECTION_TYPE:
			if include_style:
				style_parts.append(line)
		else:
			blocks.append(line)
	return Rules.success({"section_count": sections.size()})
