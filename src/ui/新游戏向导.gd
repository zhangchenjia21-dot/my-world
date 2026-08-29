class_name NewGameWizard
extends MarginContainer

signal cancelled

const Composition := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const STEPS := ["世界", "入口", "拓展", "主角", "保证登场角色", "设置", "兼容性审查"]

@onready var step_label: Label = %WizardStepLabel
@onready var title_label: Label = %WizardTitleLabel
@onready var hint_label: Label = %WizardHintLabel
@onready var result_label: Label = %WizardResultLabel
@onready var choices: VBoxContainer = %WizardChoices
@onready var settings: VBoxContainer = %WizardSettings
@onready var display_name_input: LineEdit = %GameDisplayNameInput
@onready var control_mode: OptionButton = %ControlModeOption
@onready var supplement_input: TextEdit = %OpeningSupplementInput
@onready var review_text: RichTextLabel = %WizardReviewText
@onready var back_button: Button = %WizardBackButton
@onready var next_button: Button = %WizardNextButton
@onready var cancel_button: Button = %NewGameBackButton
@onready var create_placeholder_button: Button = %CreatePlaceholderButton

var composition: RefCounted = null
var worlds: Array[RefCounted] = []
var characters: Array[RefCounted] = []
var step := 0
var choice_buttons: Array[Button] = []


func _ready() -> void:
	back_button.pressed.connect(_go_back)
	next_button.pressed.connect(_go_next)
	cancel_button.pressed.connect(func() -> void: cancelled.emit())
	for mode: String in ["Full", "Light", "Narrative"]:
		control_mode.add_item(mode)
	control_mode.select(1)
	display_name_input.text_changed.connect(func(_value: String) -> void: _update_navigation())


## 每次显式进入 New Game 都创建全新内存 Composition，并在此刻才读取 Source inventory。
func begin(source_library: RefCounted) -> Dictionary:
	composition = Composition.new(source_library)
	composition.reset()
	step = 0
	display_name_input.text = ""
	control_mode.select(1)
	supplement_input.text = ""
	var inventory: Dictionary = composition.load_current_inventory()
	if not inventory.success:
		worlds.clear()
		characters.clear()
		_show_inventory_failure(inventory)
		return inventory
	worlds = inventory.worlds
	characters = inventory.characters
	_refresh_step()
	return {"success": true, "world_count": worlds.size(), "character_count": characters.size()}


func discard() -> void:
	if composition != null:
		composition.reset()
	composition = null
	worlds.clear()
	characters.clear()
	_clear_choices()


func _refresh_step() -> void:
	step_label.text = "步骤 %d / %d" % [step + 1, STEPS.size()]
	result_label.text = ""
	settings.visible = step == 5
	review_text.visible = step == 6
	create_placeholder_button.visible = step == 6
	_clear_choices()
	match step:
		0: _render_worlds()
		1: _render_entries()
		2: _render_expansion_none()
		3: _render_player_characters()
		4: _render_guaranteed_npcs()
		5: _render_settings()
		6: _render_review()
	_update_navigation()


func _render_worlds() -> void:
	title_label.text = "选择世界"
	hint_label.text = "只显示 Managed Source Library 的当前安装代次。必须点击具体世界；列表出现不会自动选择第一项。"
	for generation: RefCounted in worlds:
		_add_choice_button(generation, false, _select_world.bind(generation))
	if worlds.is_empty():
		_add_message("当前 Source Library 没有可用 World Pack。")


func _render_entries() -> void:
	title_label.text = "选择入口 / T0"
	hint_label.text = "入口可选；它必须来自刚才选择的 exact World。更换世界会清除入口。"
	var none := Button.new()
	none.name = "entry_none"
	none.custom_minimum_size.y = 48
	none.text = "不指定入口，由后续 Opening 结合世界资料开始"
	none.pressed.connect(func() -> void:
		_show_result(composition.select_entry(""))
	)
	choices.add_child(none)
	choice_buttons.append(none)
	var snapshot: Dictionary = composition.composition_snapshot()
	for entry: Dictionary in snapshot.world.get("source_entries", []):
		var button := Button.new()
		button.name = "entry_%s" % String(entry.entry_id)
		button.custom_minimum_size.y = 52
		button.text = "%s\n%s" % [String(entry.display_name), String(entry.opening_seed)]
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.pressed.connect(func() -> void:
			_show_result(composition.select_entry(String(entry.entry_id)))
		)
		choices.add_child(button)
		choice_buttons.append(button)


func _render_expansion_none() -> void:
	title_label.text = "拓展"
	hint_label.text = "当前 vertical 尚未接入 Expansion Pack。这里明确记录空集合，不会伪造拓展能力。"
	var button := Button.new()
	button.name = "expansion_none"
	button.custom_minimum_size.y = 52
	button.text = "确认：本局不使用拓展"
	button.pressed.connect(func() -> void:
		_show_result(composition.confirm_expansion_none(), "已确认 selected expansions = []。")
		_update_navigation()
	)
	choices.add_child(button)
	choice_buttons.append(button)


func _render_player_characters() -> void:
	title_label.text = "选择主角"
	hint_label.text = "必须点击一张支持 Player Character 的 exact Character Card。"
	for generation: RefCounted in characters:
		var ineligible := not bool(generation.source.player_character_supported)
		var button := _add_choice_button(generation, ineligible, _select_player.bind(generation))
		if ineligible:
			button.text += "（仅 NPC）"


func _render_guaranteed_npcs() -> void:
	title_label.text = "保证登场角色"
	hint_label.text = "可选 0..N。这里只保证该 Source 会在 G4-06 被 materialize；不代表开场同场、已认识或自动进入 Context。"
	var snapshot: Dictionary = composition.composition_snapshot()
	for generation: RefCounted in characters:
		var overlap: bool = not snapshot.player_character.is_empty() \
			and _same_identity(snapshot.player_character.identity, generation.identity)
		var toggle := CheckButton.new()
		toggle.name = "npc_%s" % String(generation.identity.asset_id)
		toggle.custom_minimum_size.y = 48
		toggle.text = "%s · %s%s" % [generation.display_name, generation.identity.version, "（已作为主角）" if overlap else ""]
		toggle.disabled = overlap
		toggle.button_pressed = _contains_npc(snapshot.guaranteed_npcs, generation.identity)
		toggle.toggled.connect(func(selected: bool) -> void:
			_show_result(composition.set_guaranteed_npc(generation, selected))
		)
		choices.add_child(toggle)
		choice_buttons.append(toggle)


func _render_settings() -> void:
	title_label.text = "最小设置"
	hint_label.text = "游戏名称必填；主角控制模式默认 Light；开场补充可留空。"
	display_name_input.grab_focus.call_deferred()


func _render_review() -> void:
	title_label.text = "兼容性审查"
	hint_label.text = "以下是 G4-06 将接收的 exact Composition。本阶段不会创建 Game。"
	var result: Dictionary = composition.build_compatibility_review()
	if not result.success:
		review_text.text = "[color=#E68576]审查失败：%s[/color]" % String(result.message)
		result_label.text = String(result.message)
		return
	var review: Dictionary = result.review
	var world: Dictionary = review.world
	var player: Dictionary = review.player_character
	var entry_text := "无"
	if not review.entry.is_empty():
		entry_text = "%s · %s" % [String(review.entry.display_name), String(review.entry.entry_id)]
	var npc_lines: Array[String] = []
	for npc: Dictionary in review.guaranteed_npcs:
		npc_lines.append("• %s · %s · %s" % [npc.display_name, npc.identity.version, _short_fingerprint(npc.identity.generation_fingerprint)])
	if npc_lines.is_empty():
		npc_lines.append("无")
	review_text.text = "[b]%s[/b]\n\n[b]World[/b]\n%s · %s · %s\n\n[b]Entry / T0[/b]\n%s\n\n[b]Expansion[/b]\n无（当前阶段）\n\n[b]Player Character[/b]\n%s · %s · %s\n\n[b]Guaranteed NPC[/b]\n%s\n\n[b]主角控制[/b]\n%s\n\n[b]开场补充[/b]\n%s" % [
		review.display_name,
		world.display_name, world.identity.version, _short_fingerprint(world.identity.generation_fingerprint),
		entry_text,
		player.display_name, player.identity.version, _short_fingerprint(player.identity.generation_fingerprint),
		"\n".join(npc_lines),
		review.control_mode,
		review.opening_supplement if not String(review.opening_supplement).is_empty() else "无",
	]
	result_label.text = "exact generations 已通过 Managed Source Library 复核。"


func _go_next() -> void:
	if step == 5:
		var setting_result: Dictionary = composition.set_settings(display_name_input.text, control_mode.get_item_text(control_mode.selected), supplement_input.text)
		if not setting_result.success:
			_show_result(setting_result)
			return
	if step >= STEPS.size() - 1 or not _step_complete():
		return
	step += 1
	_refresh_step()


func _go_back() -> void:
	if step <= 0:
		cancelled.emit()
		return
	step -= 1
	_refresh_step()


func _select_world(generation: RefCounted) -> void:
	_show_result(composition.select_world(generation), "已选择 exact World：%s。" % generation.display_name)
	_update_navigation()


func _select_player(generation: RefCounted) -> void:
	_show_result(composition.select_player(generation), "已选择 exact Player Character：%s。" % generation.display_name)
	_update_navigation()


func _step_complete() -> bool:
	if composition == null:
		return false
	var snapshot: Dictionary = composition.composition_snapshot()
	match step:
		0: return not snapshot.world.is_empty()
		1: return not snapshot.world.is_empty()
		2: return bool(snapshot.expansion_none_confirmed)
		3: return not snapshot.player_character.is_empty()
		4: return true
		5: return not display_name_input.text.strip_edges().is_empty()
	return false


func _update_navigation() -> void:
	back_button.visible = step > 0
	back_button.text = "上一步"
	back_button.disabled = false
	next_button.visible = step < STEPS.size() - 1
	next_button.disabled = not _step_complete()


func _add_choice_button(generation: RefCounted, disabled: bool, callback: Callable) -> Button:
	var button := Button.new()
	button.name = "%s_%s" % [String(generation.identity.asset_type), String(generation.identity.asset_id)]
	button.custom_minimum_size.y = 52
	button.text = "%s · %s\n%s" % [generation.display_name, generation.identity.version, _short_fingerprint(generation.identity.generation_fingerprint)]
	button.disabled = disabled
	button.pressed.connect(callback)
	choices.add_child(button)
	choice_buttons.append(button)
	return button


func _show_inventory_failure(result: Dictionary) -> void:
	step_label.text = "无法开始"
	title_label.text = "Source Library 不可用"
	hint_label.text = String(result.get("message", result.get("code", "unknown")))
	result_label.text = "未创建 Game，也未改变 Source/Game Library。"
	settings.visible = false
	review_text.visible = false
	create_placeholder_button.visible = false
	next_button.visible = false
	back_button.text = "返回主菜单"


func _show_result(result: Dictionary, success_message: String = "选择已更新。") -> void:
	result_label.text = success_message if result.success else String(result.get("message", result.get("code", "操作失败")))
	result_label.add_theme_color_override("font_color", Color(0.58, 0.78, 0.62) if result.success else Color(0.90, 0.52, 0.46))


func _clear_choices() -> void:
	choice_buttons.clear()
	for child: Node in choices.get_children():
		child.queue_free()


func _add_message(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	choices.add_child(label)


func _contains_npc(npcs: Array, identity: Dictionary) -> bool:
	for npc: Dictionary in npcs:
		if _same_identity(npc.identity, identity):
			return true
	return false


func _same_identity(left: Dictionary, right: Dictionary) -> bool:
	return String(left.get("asset_type", "")) == String(right.get("asset_type", "")) \
		and String(left.get("asset_id", "")) == String(right.get("asset_id", "")) \
		and String(left.get("version", "")) == String(right.get("version", "")) \
		and String(left.get("generation_fingerprint", "")) == String(right.get("generation_fingerprint", ""))


func _short_fingerprint(value: String) -> String:
	return "sha256:%s…" % value.left(10)
