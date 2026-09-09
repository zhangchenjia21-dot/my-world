extends SceneTree

const Conversation := preload("res://src/domain/会话.gd")
const Accepted := preload("res://src/domain/L3_外交层/已接受输入公开契约.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Context := preload("res://src/context/L3_外交层/上下文组装公开接口.gd")
const Receipt := preload("res://src/世界回合/L0_公理层/人物身份回执规则.gd")
const Curation := preload("res://src/信息整理/L0_公理层/信息整理契约.gd")
const Recommendations := preload("res://src/行动推荐/L1_器件层/推荐材料构建器.gd")
const WorldRules := preload("res://src/世界回合/L0_公理层/世界回合规则.gd")
const WorldProjection := preload("res://src/世界回合/L1_器件层/世界回合上下文投影器.gd")
var checks := 0
var failures := 0
var directory := ""

func _init() -> void: _run.call_deferred()
func check(ok: bool, label: String) -> void:
	checks += 1
	if ok: print("MW-024 PASS " + label)
	else:
		failures += 1
		push_error("MW-024 FAIL " + label)

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="): directory = arg.trim_prefix("--root=")
	if not directory.contains("mw024"): quit(2); return
	DirAccess.make_dir_recursive_absolute(directory)
	var legacy := [{"turn_index": 0, "player_text": "", "gm_text": "开场"}, {"turn_index": 1, "player_text": "陈安是谁？", "gm_text": "陈安在河边等你。"}]
	var c := Conversation.new()
	check(c.restore_accepted_entries(legacy).ok, "legacy rehydration")
	var normalized: Array = c.get_durable_accepted_entries()
	check(normalized[0].input_mode == "opening" and normalized[1].input_mode == "action", "legacy normalized modes")
	var old := ""
	for i: int in range(legacy.size()):
		old = JSON.stringify([old, legacy[i].player_text, legacy[i].gm_text]).sha256_text()
		check(Accepted.prefix_hashes(normalized)[i] == old and Receipt.prefix_at(normalized, i) == old and Curation.prefix_hashes(normalized)[i] == old, "legacy chain byte identity " + str(i))
	check(Recommendations.prefix(normalized) == JSON.stringify(legacy).sha256_text(), "legacy recommendation identity")
	check(Accepted.world_hashes(normalized)[1] == WorldRules.gm_sha256(legacy[1].gm_text), "legacy World identity")
	var world := {"living_world": {"schema_version": "living_world.v0.1"}}
	world["stable_npcs"] = [{"local_character_id": "npc-a", "role": "stable_npc", "origin": {"kind": "creation_authored"}, "game_local_material": {"display_name": "陈安", "profile_text": "已存在演员"}}]
	var receipt := Receipt.build("legacy", 1, old, [{"local_character_id": "npc-a", "gm_span": {"start": 0, "length": 2}}])
	world = Receipt.with_receipt(world, receipt)
	world = WorldRules.build_world_candidate(world, WorldRules.build_record("legacy", 1, legacy[1].gm_text, ["旧世界后果"], "2026-09-08"))
	check(WorldProjection.new().project(world, normalized).context_text.contains("旧世界后果"), "pre-upgrade World record remains current")
	var result := {"character": null, "experiences": [{"title": "启程", "description": "选择水上生活。"}]}
	world["information_curation"] = {"schema": Curation.SCHEMA, "turns": {"1": {"prefix": old, "parent": "", "id": Curation.record_id(old, "", result), "result": result}}}
	check(Receipt.current(world, "legacy", normalized, 1) == receipt, "pre-upgrade People receipt remains current")
	check(Curation.current_records(world, normalized).size() == 1, "pre-upgrade Curator record remains current")
	var ooc := normalized.duplicate(true)
	ooc[1].input_mode = "ooc"
	check(Accepted.prefix_hashes(ooc)[1] != old and Recommendations.prefix(ooc) != Recommendations.prefix(normalized), "same prose action/ooc distinct versions")
	check(not WorldProjection.new().project(world, ooc).context_text.contains("旧世界后果"), "same prose OOC hides old World record")
	check(not Accepted.world_hashes(ooc).has(1), "mode replacement invalidates World/actor/Knowledge source")
	check(Receipt.current(world, "legacy", ooc, 1).is_empty() and Curation.current_records(world, ooc).is_empty(), "mode replacement invalidates old People/Curator")
	check(not c.validate_accepted_entries([{"player_text": "x", "gm_text": "y", "input_mode": "unknown"}]).ok, "unknown mode rejected")
	check(c.begin_turn("/ooc 我走到门口") != null and c.latest_turn().pending_input_mode == "action", "text never selects mode")
	c.cancel_generation()
	check(c.begin_turn(" 请放慢节奏。 ", "ooc") != null, "explicit OOC starts")
	c.append_delta(" 好的，我会放慢节奏。 ")
	check(c.get_completion_candidate().accepted_entries[-1].input_mode == "ooc", "completion candidate typed")
	c.complete_generation()
	check(c.get_durable_accepted_entries()[-1].player_text == " 请放慢节奏。 ", "raw Player bytes preserved")
	c.retry_or_regenerate_latest()
	check(c.latest_turn().pending_input_mode == "ooc", "regenerate retains mode")
	c.cancel_generation()
	c.correct_latest("请多些对话")
	check(c.latest_turn().pending_input_mode == "ooc", "correction retains mode")
	c.fail_generation("controlled")
	check(c.latest_turn().input_mode == "ooc", "failure preserves accepted mode")
	c.correct_latest(" 请放慢节奏。 ", "action")
	check(c.latest_turn().input_mode == "ooc" and c.get_completion_candidate().ok == false, "mode replacement remains pending")
	c.append_delta(" 好的，我会放慢节奏。 ")
	c.complete_generation()
	check(c.latest_turn().input_mode == "action", "mode replacement atomically accepts")
	var r := Runtime.new()
	check(r.open_current_game(directory.path_join("legacy.sqlite")).success, "isolated SQLite")
	check(r.persistence.write_current_conversation(r.game_id, legacy, "2026-09-08T00:00:00Z").success, "actual no-mode durable JSON")
	r.close()
	r = Runtime.new()
	check(r.open_existing_game(directory.path_join("legacy.sqlite")).success, "legacy Game reopens without migration")
	check(r.conversation.get_durable_accepted_entries() == normalized, "reopened normalized legacy matches")
	var legacy_save: Dictionary = r.create_save_point("legacy no-mode save")
	check(legacy_save.success, "Save preserves original missing-mode JSON")
	r.conversation.begin_turn("请放慢节奏。", "ooc")
	var messages: Array = Context.new().assemble_messages(r.conversation.get_context_projection())
	check(messages[0].content.contains("当前对话：OOC / GM 指导") and messages[-1].content.contains("OOC / GM 指导"), "active OOC request structural marker")
	r.conversation.append_delta("好的，我们放慢节奏。")
	check(r.complete_active_generation_durably().success, "OOC durable completion")
	var saved: Dictionary = r.create_save_point("mixed")
	check(saved.success, "mixed action/OOC Save")
	var expected: Array = r.conversation.get_durable_accepted_entries()
	r.conversation.begin_turn("我继续走。")
	messages = Context.new().assemble_messages(r.conversation.get_context_projection())
	check(JSON.stringify(messages).contains("OOC / GM 指导") and not messages[0].content.contains("当前对话：OOC / GM 指导") and messages[-1].content == "我继续走。", "subsequent action sees recent OOC as guidance")
	r.conversation.append_delta("你继续前行。")
	check(r.complete_active_generation_durably().success, "subsequent action accepted")
	check(r.restore_save_point(saved.save_id).success and r.conversation.get_durable_accepted_entries() == expected, "Restore exact mixed modes")
	r.close()
	r = Runtime.new()
	check(r.open_existing_game(directory.path_join("legacy.sqlite")).success and r.conversation.get_durable_accepted_entries() == expected, "mixed durable reopen")
	check(r.restore_save_point(legacy_save.save_id).success and r.conversation.get_durable_accepted_entries() == normalized, "pre-upgrade immutable Save restores without migration")
	r.close()
	print("MW-024 CONTRACT checks=%d failures=%d" % [checks, failures])
	quit(0 if failures == 0 else 1)
