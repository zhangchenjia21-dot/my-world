extends SceneTree

## MW-008 Safe Markdown-Lite Narrative Rendering focused proof。
## 走真实 main.tscn + NarrativeConversationView + Domain Conversation（隔离模式），
## 捕获 RichTextLabel 实际渲染结果（get_parsed_text）与 view-only raw 缓冲；
## renderer 输出（安全 BBCode）作为最小 test-only projection seam 断言。
## raw Conversation truth 不变性、chunk-boundary 等价、注入安全、reopen 等价全覆盖。
## Provider 全部走桩；real Provider calls = 0。

const STUB := preload("res://tests/g2_03_桩适配器.gd")
const Renderer := preload("res://src/ui/叙事富文本渲染器.gd")

var _failures := 0


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load("res://src/main.tscn")
	var inst: Node = packed.instantiate()
	inst.enable_isolated_narrative_test_mode()
	root.add_child(inst)
	await process_frame
	await process_frame

	var view: Node = inst.get_node("%NarrativeHost")
	var conversation: RefCounted = view.conversation
	_test_renderer_unit()

	# 用桩适配器替换真实 adapter（G2-03 T4 模式），专注视图投影。
	var stub: Node = STUB.new()
	var real_adapter: Node = view.adapter
	real_adapter.text_delta.disconnect(view._on_text_delta)
	real_adapter.completed.disconnect(view._on_completed)
	real_adapter.cancelled.disconnect(view._on_cancelled)
	real_adapter.failed.disconnect(view._on_failed)
	view.adapter = stub
	view.add_child(stub)
	stub.text_delta.connect(view._on_text_delta)
	stub.completed.connect(view._on_completed)
	stub.cancelled.connect(view._on_cancelled)
	stub.failed.connect(view._on_failed)

	await _test_bold_stream(view, conversation, stub)
	await _test_split_chunk_bold(view, conversation, stub)
	await _test_italic_and_separator(view, conversation, stub)
	await _test_unmatched_fail_soft(view, conversation, stub)
	await _test_bbcode_injection_safe(view, conversation, stub)
	await _test_redraw_and_reopen_equivalence(view, inst)
	await _test_retry_regen_resets_buffer(view, conversation, stub)
	await _test_opening_same_renderer(view, conversation, stub)
	_test_player_input_untouched(view, stub)
	print("MW-008 FOCUSED | done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)


func _test_renderer_unit() -> void:
	_check(Renderer.render("**张飞**按剑而立。") == "[b]张飞[/b]按剑而立。", "renderer: **x** → [b]x[/b]")
	_check(Renderer.render("*低声道*：不可声张。") == "[i]低声道[/i]：不可声张。", "renderer: *x* → [i]x[/i]")
	_check(Renderer.render("上\n---\n下") == "上\n[hr]\n下", "renderer: standalone --- line → [hr]")
	_check(Renderer.render("普通文本没有标记。") == "普通文本没有标记。", "renderer: plain text unchanged")
	_check(Renderer.render("他说：**此事未完") == "他说：**此事未完", "renderer: unmatched ** stays literal, no loss")
	_check(Renderer.render("他说：*此事未完") == "他说：*此事未完", "renderer: unmatched * stays literal")
	_check(Renderer.render("****") == "****", "renderer: empty emphasis stays literal")
	_check(Renderer.render("[color=red]红字[/color]") == "[lb]color=red[rb]红字[lb]/color[rb]", "renderer: BBCode brackets escaped before markdown pass")
	_check(Renderer.render("[url=https://evil.example]点我[/url]") == "[lb]url=https://evil.example[rb]点我[lb]/url[rb]", "renderer: url tag cannot become a link")
	_check(Renderer.render("[img]https://x/y.png[/img]") == "[lb]img[rb]https://x/y.png[lb]/img[rb]", "renderer: img tag cannot load a resource")
	_check(Renderer.render("甲 **加粗** 乙 *斜体* 丙") == "甲 [b]加粗[/b] 乙 [i]斜体[/i] 丙", "renderer: bold and italic coexist")
	_check(Renderer.render("质量：**92**／超额完成") == "质量：[b]92[/b]／超额完成", "renderer: CJK punctuation adjacent to markers renders naturally")


func _test_bold_stream(view: Node, conversation: RefCounted, stub: Node) -> void:
	var raw := "**张飞**按剑而立。"
	view.player_input.text = "我拔剑。"
	view.get_node("%SendButton").pressed.emit()
	stub.text_delta.emit(raw)
	await process_frame
	var parsed := String(view._current_gm_content.get_parsed_text())
	_check(parsed == "张飞按剑而立。", "live single-delta bold renders without literal **")
	_check(String(view._current_gm_raw) == raw, "view-only raw buffer mirrors the exact model bytes")
	stub.simulate_completed()
	await process_frame
	var accepted: Array = conversation.get_accepted_entries()
	_check(accepted.size() == 1 and String(accepted[0].gm_text) == raw, "accepted gm_text preserves raw Markdown bytes exactly")
	_check(String(view._current_gm_raw) == raw, "raw buffer survives acceptance unchanged")


func _test_split_chunk_bold(view: Node, conversation: RefCounted, stub: Node) -> void:
	var chunks: Array = ["**糜", "芳、孙", "乾**拱手。"]
	var raw := "**糜芳、孙乾**拱手。"
	view.player_input.text = "我看向他们。"
	view.get_node("%SendButton").pressed.emit()
	stub.text_delta.emit(chunks[0])
	await process_frame
	_check(String(view._current_gm_content.get_parsed_text()) == "**糜", "transient unpaired delimiter stays readable literal during streaming")
	stub.text_delta.emit(chunks[1])
	stub.text_delta.emit(chunks[2])
	await process_frame
	var parsed := String(view._current_gm_content.get_parsed_text())
	_check(parsed == "糜芳、孙乾拱手。", "split-delimiter bold final render has no literal **")
	_check(String(view._current_gm_raw) == raw, "split-chunk raw buffer equals concatenated raw")
	_check(String(Renderer.render(raw)) == String(Renderer.render("".join(PackedStringArray(chunks)))), "split-chunk rendering equals one-shot rendering (renderer determinism)")
	stub.simulate_completed()
	await process_frame
	_check(String((conversation.get_accepted_entries() as Array)[-1].gm_text) == raw, "split-chunk accepted bytes unchanged")


func _test_italic_and_separator(view: Node, conversation: RefCounted, stub: Node) -> void:
	view.player_input.text = "我侧耳倾听。"
	view.get_node("%SendButton").pressed.emit()
	stub.text_delta.emit("*低")
	stub.text_delta.emit("声*道：不可声张。")
	await process_frame
	var parsed := String(view._current_gm_content.get_parsed_text())
	_check(parsed == "低声道：不可声张。", "italic renders across chunk boundary without literal *")
	_check(String(view._current_gm_raw) == "*低声*道：不可声张。", "italic raw buffer exact")
	stub.simulate_completed()
	await process_frame

	view.player_input.text = "我展开军报。"
	view.get_node("%SendButton").pressed.emit()
	var sep_chunks: Array = ["前情提要。\n", "---\n", "后继有变。"]
	for chunk: String in sep_chunks:
		stub.text_delta.emit(chunk)
	await process_frame
	var sep_parsed := String(view._current_gm_content.get_parsed_text())
	_check(String(Renderer.render("前情提要。\n---\n后继有变。")).contains("[hr]"), "separator line maps to [hr] tag")
	_check(not sep_parsed.contains("---"), "standalone --- no longer displays as literal markup")
	_check(sep_parsed.contains("前情提要。") and sep_parsed.contains("后继有变。"), "separator keeps surrounding content")
	stub.simulate_completed()
	await process_frame


func _test_unmatched_fail_soft(view: Node, conversation: RefCounted, stub: Node) -> void:
	view.player_input.text = "我追问下文。"
	view.get_node("%SendButton").pressed.emit()
	stub.text_delta.emit("他说：**此事未完")
	await process_frame
	var parsed := String(view._current_gm_content.get_parsed_text())
	_check(parsed == "他说：**此事未完", "malformed emphasis remains readable with ** and trailing text preserved")
	stub.simulate_completed()
	await process_frame
	_check(String((conversation.get_accepted_entries() as Array)[-1].gm_text) == "他说：**此事未完", "malformed case accepted bytes unchanged")


func _test_bbcode_injection_safe(view: Node, conversation: RefCounted, stub: Node) -> void:
	view.player_input.text = "守卫出示了什么？"
	view.get_node("%SendButton").pressed.emit()
	var raw := "守卫出示 [color=red]红字[/color]，递来 [url=https://evil.example]链接[/url]。"
	stub.text_delta.emit(raw)
	await process_frame
	var parsed := String(view._current_gm_content.get_parsed_text())
	_check(parsed.contains("[color=red]红字[/color]") and parsed.contains("[url=https://evil.example]链接[/url]"),
		"BBCode-like model text stays literal in rendered view")
	_check(String(Renderer.render(raw)).contains("[lb]color=red[rb]"), "brackets escaped before any markdown-lite pass")
	stub.simulate_completed()
	await process_frame
	_check(String((conversation.get_accepted_entries() as Array)[-1].gm_text) == raw, "injection probe raw bytes unchanged")


func _test_redraw_and_reopen_equivalence(view: Node, inst: Node) -> void:
	var live_parsed := String(view._current_gm_content.get_parsed_text())
	var live_raw := String(view._current_gm_raw)
	view.redraw_from_conversation()
	await process_frame
	_check(String(view._current_gm_raw) == live_raw, "redraw rebuilds the same view-only raw buffer from durable truth")
	_check(String(view._current_gm_content.get_parsed_text()) == live_parsed, "redraw rendering equals live streaming final frame")

	# reopen 投影：fresh Conversation + restore_accepted_entries → 与 production reopen
	# 相同的 _render_restored_entries 路径。
	var packed: PackedScene = load("res://src/main.tscn")
	var inst2: Node = packed.instantiate()
	inst2.enable_isolated_narrative_test_mode()
	root.add_child(inst2)
	await process_frame
	var view2: Node = inst2.get_node("%NarrativeHost")
	var restored: Array = []
	for entry_value: Variant in view.conversation.get_accepted_entries():
		restored.append((entry_value as Dictionary).duplicate(true))
	var restore_result: Dictionary = view2.conversation.restore_accepted_entries(restored)
	view2.redraw_from_conversation()
	await process_frame
	_check(restore_result.ok, "reopen fixture restores accepted entries")
	_check(String(view2._current_gm_content.get_parsed_text()) == live_parsed,
		"reopen projection rendering equals live streaming final frame with raw bytes intact")
	inst2.queue_free()


func _test_retry_regen_resets_buffer(view: Node, conversation: RefCounted, stub: Node) -> void:
	view.get_node("%RegenerateButton").pressed.emit()
	_check(String(view._current_gm_raw).is_empty(), "regenerate clears the view-only raw buffer")
	stub.text_delta.emit("重写后的**新结局**。")
	await process_frame
	var parsed := String(view._current_gm_content.get_parsed_text())
	_check(parsed == "重写后的新结局。", "regenerated block renders fresh without concatenating old draft markup")
	_check(not parsed.contains("张飞按剑而立"), "regenerated block does not keep previous turn content")
	stub.simulate_completed()
	await process_frame
	_check(String((conversation.get_accepted_entries() as Array)[-1].gm_text) == "重写后的**新结局**。", "regenerated accepted bytes raw")


func _test_opening_same_renderer(view: Node, conversation: RefCounted, stub: Node) -> void:
	var conv: RefCounted = conversation
	_check(conv.begin_gm_opening() != null, "GM-only opening attempt starts")
	stub.text_delta.emit("第一幕：**主角**登场。\n---\n暮色四合。")
	await process_frame
	var parsed := String(view._current_gm_content.get_parsed_text())
	_check(parsed.contains("主角登场") and not parsed.contains("**"), "opening uses the same safe renderer (bold)")
	_check(not parsed.contains("---"), "opening separator renders as visual rule, not literal markup")
	stub.simulate_completed()
	await process_frame


func _test_player_input_untouched(view: Node, stub: Node) -> void:
	view.player_input.text = "**玩家**输入 *不* 解释"
	view.get_node("%SendButton").pressed.emit()
	await process_frame
	var first_entry: VBoxContainer = view.entries.get_child(0) as VBoxContainer
	var player_rtl: RichTextLabel = first_entry.get_child(1) as RichTextLabel
	var parsed := String(player_rtl.get_parsed_text())
	_check(parsed == "**玩家**输入 *不* 解释", "player entry rendering unchanged: no Markdown interpretation")
	view.conversation.cancel_generation()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("MW-008 PASS | %s" % label)
	else:
		_failures += 1
		push_error("MW-008 FAIL | %s" % label)
