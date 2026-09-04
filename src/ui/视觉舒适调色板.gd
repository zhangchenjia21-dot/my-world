extends RefCounted

## MW-003 Visual Comfort Theme Pass —— 核心 palette 的唯一权威定义与 Theme 装配。
## 目标体验：低眩光、清晰层级、可读叙事、平静表面、克制 semantic 色。
## 相对层级是权威（允许小幅调值，不允许颠倒层级）：
##   canvas < surface/base < surface/input < surface/raised；
##   text/muted < text/secondary < text/primary；semantic 色只作克制 accent，不作焦点。
## 明确非范围：light mode / 主题切换 / 用户 accent 偏好 / 布局重构 / 字体重构。
## 用法：Application Shell 在 _ready 调 apply_theme() 装配根 Theme；runtime 创建的
## 控件一律引用这里的语义常量，不再散落硬编码颜色字面量。

const CANVAS := Color("1B1E24")
const SURFACE_BASE := Color("22262D")
const SURFACE_RAISED := Color("292E36")
const SURFACE_INPUT := Color("252A31")
const BORDER_SUBTLE := Color("343A44")
const TEXT_PRIMARY := Color("D8DCE3")
const TEXT_SECONDARY := Color("A7AFBA")
const TEXT_MUTED := Color("7F8996")
const ACCENT := Color("8FA9C4")
const SUCCESS := Color("88AD96")
const WARNING := Color("C0A06B")
const DANGER := Color("C57D78")


## 装配既有根 Theme（保留其字体与字号，字体系/层级不属于本 pass）：
## 语义色默认值 + 主要控件表面/边框/hover/focus/pressed/disabled 状态 +
## Label 层级 type variation（LabelSecondary/LabelMuted/LabelAccent/LabelSuccess/LabelDanger）
## 与 runtime 卡片的 PanelCard variation。
static func apply_theme(theme: Theme) -> void:
	if theme == null:
		return
	# 文本层级默认值。
	theme.set_color("font_color", "Label", TEXT_PRIMARY)
	theme.set_color("default_color", "RichTextLabel", TEXT_PRIMARY)
	theme.set_color("selection_color", "RichTextLabel", _selection())
	# Label 层级 variation：tscn 以 theme_type_variation 引用，不再复制颜色字面量。
	_register_label_role(theme, "LabelSecondary", TEXT_SECONDARY)
	_register_label_role(theme, "LabelMuted", TEXT_MUTED)
	_register_label_role(theme, "LabelAccent", ACCENT)
	_register_label_role(theme, "LabelSuccess", SUCCESS)
	_register_label_role(theme, "LabelDanger", DANGER)
	# runtime 叙事卡片：raised 表面，与底层 panel 分层。
	theme.set_type_variation("PanelCard", "PanelContainer")
	theme.set_stylebox("panel", "PanelCard", _flat(SURFACE_RAISED, BORDER_SUBTLE, 1, 6, 10))
	# 面板与弹窗表面。
	theme.set_stylebox("panel", "PanelContainer", _flat(SURFACE_BASE, BORDER_SUBTLE, 1, 6, 8))
	theme.set_stylebox("panel", "Panel", _flat(SURFACE_BASE, BORDER_SUBTLE, 1, 6, 8))
	theme.set_stylebox("panel", "AcceptDialog", _flat(SURFACE_BASE, BORDER_SUBTLE, 1, 8, 12))
	theme.set_stylebox("panel", "TooltipPanel", _flat(SURFACE_RAISED, BORDER_SUBTLE, 1, 4, 8))
	theme.set_color("font_color", "TooltipLabel", TEXT_PRIMARY)
	# 按钮全状态。
	var button_types := ["Button", "OptionButton", "CheckButton", "MenuButton"]
	for button_type: String in button_types:
		theme.set_stylebox("normal", button_type, _flat(SURFACE_RAISED, BORDER_SUBTLE, 1, 6, 8))
		theme.set_stylebox("hover", button_type, _flat(SURFACE_RAISED.lightened(0.08), BORDER_SUBTLE.lightened(0.15), 1, 6, 8))
		theme.set_stylebox("pressed", button_type, _flat(SURFACE_BASE, BORDER_SUBTLE, 1, 6, 8))
		theme.set_stylebox("disabled", button_type, _flat(SURFACE_BASE, BORDER_SUBTLE.darkened(0.25), 1, 6, 8))
		theme.set_stylebox("focus", button_type, _focus_ring())
		theme.set_color("font_color", button_type, TEXT_PRIMARY)
		theme.set_color("font_hover_color", button_type, TEXT_PRIMARY)
		theme.set_color("font_pressed_color", button_type, TEXT_SECONDARY)
		theme.set_color("font_focus_color", button_type, TEXT_PRIMARY)
		theme.set_color("font_disabled_color", button_type, TEXT_MUTED)
	# 输入框：专用 input 表面，focus 以 accent 描边提示。
	for input_type: String in ["LineEdit", "TextEdit"]:
		theme.set_stylebox("normal", input_type, _flat(SURFACE_INPUT, BORDER_SUBTLE, 1, 6, 8))
		theme.set_stylebox("focus", input_type, _flat(SURFACE_INPUT, ACCENT, 1, 6, 8))
		theme.set_stylebox("read_only", input_type, _flat(SURFACE_BASE, BORDER_SUBTLE.darkened(0.25), 1, 6, 8))
		theme.set_color("font_color", input_type, TEXT_PRIMARY)
		theme.set_color("font_placeholder_color", input_type, TEXT_MUTED)
		theme.set_color("caret_color", input_type, ACCENT)
		theme.set_color("selection_color", input_type, _selection())
	# OptionButton 弹出菜单。
	theme.set_stylebox("panel", "PopupMenu", _flat(SURFACE_RAISED, BORDER_SUBTLE, 1, 6, 6))
	theme.set_stylebox("hover", "PopupMenu", _flat(SURFACE_RAISED.lightened(0.12), SURFACE_RAISED.lightened(0.12), 0, 3, 6))
	theme.set_color("font_color", "PopupMenu", TEXT_PRIMARY)
	theme.set_color("font_hover_color", "PopupMenu", TEXT_PRIMARY)
	theme.set_color("font_disabled_color", "PopupMenu", TEXT_MUTED)
	theme.set_color("font_separator_color", "PopupMenu", TEXT_MUTED)
	theme.set_stylebox("separator", "PopupMenu", _flat(SURFACE_RAISED, SURFACE_RAISED, 0, 0, 0))
	# 分隔线与滚动条：弱存在感。
	theme.set_color("separator", "HSeparator", BORDER_SUBTLE)
	theme.set_color("separator", "VSeparator", BORDER_SUBTLE)
	for bar_type: String in ["HScrollBar", "VScrollBar"]:
		theme.set_stylebox("scroll", bar_type, _flat(SURFACE_BASE, SURFACE_BASE, 0, 4, 0))
		theme.set_stylebox("grabber", bar_type, _flat(BORDER_SUBTLE, BORDER_SUBTLE, 0, 4, 0))
		theme.set_stylebox("grabber_highlight", bar_type, _flat(TEXT_MUTED, TEXT_MUTED, 0, 4, 0))
		theme.set_stylebox("grabber_pressed", bar_type, _flat(TEXT_SECONDARY, TEXT_SECONDARY, 0, 4, 0))


static func _register_label_role(theme: Theme, role: String, color: Color) -> void:
	theme.set_type_variation(role, "Label")
	theme.set_color("font_color", role, color)


static func _selection() -> Color:
	return Color(ACCENT, 0.32)


static func _focus_ring() -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.draw_center = false
	stylebox.border_color = ACCENT
	stylebox.set_border_width_all(1)
	stylebox.set_corner_radius_all(6)
	return stylebox


static func _flat(fill: Color, border: Color, border_width: int, radius: int, content_margin: float) -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = fill
	stylebox.border_color = border
	stylebox.set_border_width_all(border_width)
	stylebox.set_corner_radius_all(radius)
	if content_margin > 0.0:
		stylebox.set_content_margin_all(content_margin)
	return stylebox
