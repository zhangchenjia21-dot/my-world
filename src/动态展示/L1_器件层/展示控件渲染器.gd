extends VBoxContainer
const Contract := preload("res://src/动态展示/L0_公理层/展示定义契约.gd")

signal visibility_requested(surface: String, key: String, hidden: bool)
var accepted_definition := false
var surface_id := ""
var visible_cards: Array[Control] = []
var hidden_cards: Array[Control] = []
var hidden_drawer: VBoxContainer
var hidden_toggle: Button

## 只接收已安全的定义与不透明偏好键；没有 Runtime、文件、模型或任意回调权限。
func render(definition: Variant, hidden_keys: Array = []) -> bool:
	for child: Node in get_children(): remove_child(child); child.queue_free()
	visible_cards.clear(); hidden_cards.clear(); hidden_drawer=null; hidden_toggle=null
	accepted_definition=Contract.valid(definition)
	add_theme_constant_override("separation",12)
	if not accepted_definition:
		_label(self,"当前信息暂时无法显示。","muted")
		return false
	surface_id=definition.surface
	var hidden: Array=[]
	for node: Dictionary in definition.children:
		if node.kind=="card" and not node.visibility_key.is_empty() and node.visibility_key in hidden_keys:
			hidden.append(node)
		else:
			var control:=_materialize(self,node,false)
			if node.kind=="card": visible_cards.append(control)
	if not hidden.is_empty():
		hidden_toggle=_button(self,"已隐藏 (%d)" % hidden.size())
		hidden_toggle.toggle_mode=true
		hidden_drawer=VBoxContainer.new(); hidden_drawer.visible=false; add_child(hidden_drawer)
		hidden_toggle.toggled.connect(func(pressed: bool): hidden_drawer.visible=pressed)
		for node: Dictionary in hidden: hidden_cards.append(_materialize(hidden_drawer,node,true))
	return true

func _label(parent: Control, content: String, role: String = "body") -> Label:
	var label:=Label.new(); label.text=content; label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",22 if role=="heading" else 20)
	if role=="muted": label.theme_type_variation=&"LabelMuted"
	parent.add_child(label); return label

func _button(parent: Control, content: String) -> Button:
	var button:=Button.new(); button.text=content; button.add_theme_font_size_override("font_size",20)
	button.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(button); return button

func _materialize(parent: Control, node: Dictionary, hidden: bool) -> Control:
	if node.kind=="text": return _label(parent,node.text,node.role)
	var container: Control
	var column:=VBoxContainer.new(); column.add_theme_constant_override("separation",8)
	if node.kind=="card" and node.collapsible:
		container=PanelContainer.new(); parent.add_child(container)
		var margin:=MarginContainer.new()
		for side: String in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,10)
		container.add_child(margin); margin.add_child(column)
	else: container=column; parent.add_child(column)
	container.set_meta("component_id",node.component_id)
	var body:=column
	if node.kind=="card":
		if node.collapsible:
			var toggle:=_button(column,"▸ "+node.title); toggle.toggle_mode=true; toggle.alignment=HORIZONTAL_ALIGNMENT_LEFT
			if not node.subtitle.is_empty(): _label(column,node.subtitle,"muted")
			body=VBoxContainer.new(); body.visible=false; column.add_child(body)
			container.set_meta("collapse_toggle",toggle); container.set_meta("expanded_body",body)
			toggle.toggled.connect(func(pressed: bool): body.visible=pressed; toggle.text=("▾ " if pressed else "▸ ")+node.title)
		else:
			if not node.title.is_empty(): _label(column,node.title,"heading")
			if not node.subtitle.is_empty(): _label(column,node.subtitle,"muted")
		if not node.visibility_key.is_empty():
			var button:=_button(column,"恢复显示" if hidden else "隐藏")
			container.set_meta("visibility_button",button)
			# 固定第一方信号；definition 不能提供动作名称或目标方法。
			button.pressed.connect(func(): visibility_requested.emit(surface_id,node.visibility_key,not hidden))
	elif not node.title.is_empty(): _label(column,node.title,"heading")
	match node.kind:
		"card","section":
			for child: Dictionary in node.children: _materialize(body,child,hidden)
		"fact_list":
			for item: String in node.items: _label(body,"• "+item)
		"field_list":
			for field: Dictionary in node.fields: _label(body,field.label+"："+field.value)
	return container
