class_name NewGameWizard
extends MarginContainer

signal cancelled
## 玩家提交 frozen Review payload；create attempt 身份由本向导在生命周期内固定。
signal final_create_requested(creation_id, composition)

const Composition := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const STEPS := ["世界", "开局", "拓展", "主角", "保证加入的角色", "设置", "兼容性审查"]

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
@onready var final_create_button: Button = %FinalCreateButton

var composition: RefCounted = null
var worlds: Array[RefCounted] = []
var characters: Array[RefCounted] = []
var expansions: Array[RefCounted] = []
var step := 0
var choice_buttons: Array[Button] = []

## create attempt 身份：一次 frozen Review 提交固定一个 creation_id；双击/重试复用。
## payload key 只用于检测“返回修改后再提交”，不作为 Game 唯一性来源。
var _creation_id := ""
var _creation_payload_key := ""
var _create_in_progress := false
var _create_completed := false


func _ready() -> void:
	back_button.pressed.connect(_go_back)
	next_button.pressed.connect(_go_next)
	cancel_button.pressed.connect(func() -> void: cancelled.emit())
	final_create_button.pressed.connect(_on_final_create_pressed)
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
	_reset_create_attempt()
	var inventory: Dictionary = composition.load_current_inventory()
	if not inventory.success:
		worlds.clear()
		characters.clear()
		expansions.clear()
		_show_inventory_failure(inventory)
		return inventory
	worlds = inventory.worlds
	characters = inventory.characters
	expansions = inventory.get("expansions", []) as Array[RefCounted]
	_refresh_step()
	return {"success": true, "world_count": worlds.size(), "character_count": characters.size(), "expansion_count": expansions.size()}


func discard() -> void:
	if composition != null:
		composition.reset()
	composition = null
	worlds.clear()
	characters.clear()
	expansions.clear()
	_clear_choices()
	_reset_create_attempt()


func _refresh_step() -> void:
	step_label.text = "步骤 %d / %d" % [step + 1, STEPS.size()]
	result_label.text = ""
	settings.visible = step == 5
	review_text.visible = step == 6
	final_create_button.visible = step == 6
	_clear_choices()
	match step:
		0: _render_worlds()
		1: _render_entries()
		2: _render_expansions()
		3: _render_player_characters()
		4: _render_guaranteed_npcs()
		5: _render_settings()
		6: _render_review()
	_update_navigation()


func _render_worlds() -> void:
	title_label.text = "选择世界"
	hint_label.text = "下面列出本机已安装的世界及其简介。必须点击一个世界才会选中；列表出现不会自动选择第一项。"
	for generation: RefCounted in worlds:
		_add_choice_button(generation, false, _select_world.bind(generation))
	if worlds.is_empty():
		_add_message("当前 Source Library 没有可用 World Pack。")


func _render_entries() -> void:
	title_label.text = "选择开局"
	hint_label.text = "开局可选；候选来自刚才选择的世界。更换世界会清除已选开局。"
	var none := Button.new()
	none.name = "entry_none"
	none.custom_minimum_size.y = 48
	none.text = "不指定开局；开场由世界资料与后续设置自然开始"
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


## 拓展步是真实库存投影：0..N exact generations，无 auto-select；
## 选择/冲突拒绝的权威都在 Composition 后端，UI 只投影并回滚被拒绝的 toggle。
func _render_expansions() -> void:
	title_label.text = "选择拓展"
	hint_label.text = "可选 0..N。拓展为本局加入已安装的规则能力；不选择时请点击「本局不使用拓展」。列表出现不会自动选择任何拓展。"
	var snapshot: Dictionary = composition.composition_snapshot()
	for generation: RefCounted in expansions:
		var toggle := CheckButton.new()
		toggle.name = "expansion_%s" % String(generation.identity.asset_id)
		toggle.custom_minimum_size.y = 52
		toggle.text = "%s（%s）\n%s" % [generation.display_name, generation.identity.version, String(generation.source.catalog_summary)]
		toggle.alignment = HORIZONTAL_ALIGNMENT_LEFT
		toggle.button_pressed = _contains_expansion(snapshot.expansions, generation.identity)
		toggle.toggled.connect(func(selected: bool) -> void: _toggle_expansion(toggle, generation, selected))
		choices.add_child(toggle)
		choice_buttons.append(toggle)
	if expansions.is_empty():
		_add_message("当前 Source Library 没有可用拓展。")
	var none := Button.new()
	none.name = "expansion_none"
	none.custom_minimum_size.y = 48
	none.text = "本局不使用拓展"
	none.pressed.connect(func() -> void:
		_show_result(composition.confirm_expansion_none(), "已确认：本局不使用拓展。")
		_update_navigation()
	)
	choices.add_child(none)
	choice_buttons.append(none)


## 后端拒绝（如 capability slot 冲突）时必须回滚 toggle，UI 不得留下双选假象。
func _toggle_expansion(toggle: CheckButton, generation: RefCounted, selected: bool) -> void:
	var result: Dictionary = composition.set_expansion(generation, selected)
	if result.success:
		_show_result(result, "已选择拓展：%s。" % generation.display_name if selected else "已取消拓展：%s。" % generation.display_name)
		_update_navigation()
		return
	toggle.set_pressed_no_signal(not selected)
	result_label.text = _player_facing_expansion_failure(result)
	result_label.add_theme_color_override("font_color", Color(0.90, 0.52, 0.46))


func _player_facing_expansion_failure(result: Dictionary) -> String:
	var code := String(result.get("code", ""))
	if code == "capability_slot_conflict":
		return "无法同时选择：两个拓展占用同一判定位置。请先取消已选拓展，再选择这个。"
	if code == "duplicate_expansion":
		return "该拓展已经选中。"
	return String(result.get("message", code))


func _render_player_characters() -> void:
	title_label.text = "选择主角"
	hint_label.text = "必须明确点击一位角色作为主角；只有支持主角的角色才可选择。"
	for generation: RefCounted in characters:
		var ineligible := not bool(generation.source.player_character_supported)
		var button := _add_choice_button(generation, ineligible, _select_player.bind(generation))
		if ineligible:
			button.text += "\n（仅可作为 NPC）"


func _render_guaranteed_npcs() -> void:
	title_label.text = "保证加入本局的 NPC"
	hint_label.text = "可选 0..N。表示要求该角色在创建后属于本局阵容；不代表开场就出现、同场或已经认识主角。"
	var snapshot: Dictionary = composition.composition_snapshot()
	for generation: RefCounted in characters:
		var overlap: bool = not snapshot.player_character.is_empty() \
			and _same_identity(snapshot.player_character.identity, generation.identity)
		var toggle := CheckButton.new()
		toggle.name = "npc_%s" % String(generation.identity.asset_id)
		toggle.custom_minimum_size.y = 48
		toggle.text = "%s（%s）%s\n%s" % [generation.display_name, generation.identity.version, "（已作为主角）" if overlap else "", String(generation.source.catalog_summary)]
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
	hint_label.text = "以下是将要创建本局游戏的完整选择与设置；通过检查后才可创建。"
	var result: Dictionary = composition.build_compatibility_review()
	if not result.success:
		var message := _player_facing_review_failure(result)
		review_text.text = "[color=#E68576]%s[/color]" % message
		result_label.text = message
		result_label.add_theme_color_override("font_color", Color(0.90, 0.52, 0.46))
		final_create_button.disabled = true
		final_create_button.text = "创建游戏"
		return
	var review: Dictionary = result.review
	var world: Dictionary = review.world
	var player: Dictionary = review.player_character
	var entry_text := "不指定开局"
	if not review.entry.is_empty():
		entry_text = String(review.entry.display_name)
	var npc_lines: Array[String] = []
	for npc: Dictionary in review.guaranteed_npcs:
		npc_lines.append("• %s（%s）" % [npc.display_name, npc.identity.version])
	if npc_lines.is_empty():
		npc_lines.append("无")
	var expansion_lines: Array[String] = []
	for expansion: Dictionary in review.get("expansions", []):
		expansion_lines.append("• %s（%s）" % [String(expansion.display_name), String(expansion.identity.version)])
	if expansion_lines.is_empty():
		expansion_lines.append("无")
	review_text.text = "[b]%s[/b]\n\n[b]世界[/b]\n%s（%s）\n\n[b]开局[/b]\n%s\n\n[b]拓展[/b]\n%s\n\n[b]主角[/b]\n%s（%s）\n\n[b]保证加入本局的 NPC[/b]\n%s\n\n[b]主角控制[/b]\n%s\n\n[b]开场补充[/b]\n%s" % [
		review.display_name,
		world.display_name, world.identity.version,
		entry_text,
		"\n".join(expansion_lines),
		player.display_name, player.identity.version,
		"\n".join(npc_lines),
		review.control_mode,
		review.opening_supplement if not String(review.opening_supplement).is_empty() else "无",
	]
	result_label.text = "兼容性检查通过；所选内容均已按安装版本复核。"
	result_label.add_theme_color_override("font_color", Color(0.58, 0.78, 0.62))
	if not _create_completed and not _create_in_progress:
		final_create_button.disabled = false
		final_create_button.text = "创建游戏"


## 玩家提交 frozen Review payload。一次 attempt 固定一个 creation_id：
## 双击/失败重试复用同一 id（幂等收敛到同一局）；返回修改后 payload 变化才换新 attempt。
func _on_final_create_pressed() -> void:
	if composition == null or step != STEPS.size() - 1 or _create_in_progress or _create_completed:
		return
	var frozen: Dictionary = composition.composition_snapshot()
	var payload_key := JSON.stringify(frozen)
	if _creation_id.is_empty() or payload_key != _creation_payload_key:
		_creation_id = "creation-%s" % Crypto.new().generate_random_bytes(16).hex_encode()
		_creation_payload_key = payload_key
	_create_in_progress = true
	final_create_button.disabled = true
	final_create_button.text = "正在创建…"
	result_label.text = "正在创建游戏…"
	result_label.add_theme_color_override("font_color", Color(0.72, 0.74, 0.82))
	final_create_requested.emit(_creation_id, frozen)


## create 终态由 Application Shell 回填；成功后本屏锁定，不得再创建第二局。
func create_succeeded() -> void:
	_create_in_progress = false
	_create_completed = true
	final_create_button.disabled = true
	final_create_button.text = "已创建"
	result_label.text = "创建成功，正在进入游戏…"
	result_label.add_theme_color_override("font_color", Color(0.58, 0.78, 0.62))


func create_failed(message: String) -> void:
	_create_in_progress = false
	final_create_button.disabled = false
	final_create_button.text = "重试创建"
	result_label.text = message
	result_label.add_theme_color_override("font_color", Color(0.90, 0.52, 0.46))


func _reset_create_attempt() -> void:
	_creation_id = ""
	_creation_payload_key = ""
	_create_in_progress = false
	_create_completed = false
	if final_create_button != null:
		final_create_button.disabled = true
		final_create_button.text = "创建游戏"


## 后端仍是兼容性权威；这里只把已知失败码翻译成玩家可直接行动的说明，不引入任何替代或回退。
func _player_facing_review_failure(result: Dictionary) -> String:
	var code := String(result.get("code", ""))
	if code == "character_temporal_incompatible":
		var snapshot: Dictionary = composition.composition_snapshot()
		var entry_name := String(snapshot.entry.get("display_name", "所选开局"))
		return "无法继续创建：阵容中有角色没有适用于开局「%s」的起始资料（该角色的资料未覆盖这个时间点或场景）。可返回更换开局，或调整主角与保证加入的角色。" % entry_name
	return "审查未通过：%s" % String(result.get("message", code))


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
	_show_result(composition.select_world(generation), "已选择世界：%s。" % generation.display_name)
	_update_navigation()


func _select_player(generation: RefCounted) -> void:
	_show_result(composition.select_player(generation), "已选择主角：%s。" % generation.display_name)
	_update_navigation()


func _step_complete() -> bool:
	if composition == null:
		return false
	var snapshot: Dictionary = composition.composition_snapshot()
	match step:
		0: return not snapshot.world.is_empty()
		1: return not snapshot.world.is_empty()
		2: return not snapshot.expansions.is_empty() or bool(snapshot.expansion_none_confirmed)
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
	button.text = "%s（%s）\n%s" % [generation.display_name, generation.identity.version, String(generation.source.catalog_summary)]
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.disabled = disabled
	button.pressed.connect(callback)
	choices.add_child(button)
	choice_buttons.append(button)
	return button


func _show_inventory_failure(result: Dictionary) -> void:
	step_label.text = "无法开始"
	title_label.text = "世界资料库不可用"
	hint_label.text = String(result.get("message", result.get("code", "unknown")))
	result_label.text = "未创建游戏，也没有改动任何本机数据。"
	settings.visible = false
	review_text.visible = false
	final_create_button.visible = false
	next_button.visible = false
	back_button.text = "返回主菜单"


func _show_result(result: Dictionary, success_message: String = "选择已更新。") -> void:
	result_label.text = success_message if result.success else String(result.get("message", result.get("code", "操作失败")))
	result_label.add_theme_color_override("font_color", Color(0.58, 0.78, 0.62) if result.success else Color(0.90, 0.52, 0.46))


func _clear_choices() -> void:
	choice_buttons.clear()
	for child: Node in choices.get_children():
		# 先 detach 再 queue_free：同帧重建（如再次进入 Wizard）时旧节点名不得占用新按钮名。
		choices.remove_child(child)
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


func _contains_expansion(selected: Array, identity: Dictionary) -> bool:
	for expansion: Dictionary in selected:
		if _same_identity(expansion.identity, identity):
			return true
	return false


func _same_identity(left: Dictionary, right: Dictionary) -> bool:
	return String(left.get("asset_type", "")) == String(right.get("asset_type", "")) \
		and String(left.get("asset_id", "")) == String(right.get("asset_id", "")) \
		and String(left.get("version", "")) == String(right.get("version", "")) \
		and String(left.get("generation_fingerprint", "")) == String(right.get("generation_fingerprint", ""))
