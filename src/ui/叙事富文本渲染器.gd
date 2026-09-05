class_name NarrativeRichTextRenderer
extends RefCounted

## MW-008 Safe Markdown-Lite v0.1 —— Narrative UI 专用的展示投影（disposable）。
##
## 安全边界（packet §5）：原始模型文本永远先做 BBCode 转义（[ → [lb]，] → [rb]），
## 因此任何 [color] / [url] / [img] / [font] 等 BBCode 语义都不可能被 RichTextLabel
## 解释为样式或资源；Markdown-lite 转换只发生在转义后的纯文本上，本 renderer
## 自身只产出 [b] [/b] [i] [/i] [hr] 五种安全标签。原始 Narrative bytes 不经本
## renderer 回写 Domain / persistence / context——它只是 UI 边界的一次性投影。
##
## v0.1 只支持：**粗体**、*斜体*、trim 后整行为 --- 的主题分隔线。
## 未闭合/空内容/交叠歧义一律 fail-soft 保持可读原文；不是通用 Markdown 引擎，
## 不做嵌套优先级、标题、链接、表格、代码块或 HTML。

const SEPARATOR_LINE := "---"
## 防御性上限：异常超长文本跳过 markdown-lite 转换，仅转义后原样展示（不截断内容）。
const MAX_RENDER_CHARS := 200000


## raw（模型 authored Narrative）→ 安全 BBCode。确定性：同一 raw 恒产出同一结果，
## 因此流式分段拼接后的最终渲染 == 一次性渲染整体 raw。
static func render(raw: String) -> String:
	var escaped := _escape_bbcode(raw)
	if escaped.length() > MAX_RENDER_CHARS:
		return escaped
	var lines := escaped.split("\n")
	for index: int in lines.size():
		lines[index] = _render_line(lines[index])
	return "\n".join(lines)


## 先转义再解析：模型文本中的方括号永远变成字面量，BBCode 注入不可能。
## 必须单遍逐字符转义：顺序 replace 会把上一步插入的 [lb] 中的 ] 再次替换。
static func _escape_bbcode(text: String) -> String:
	var escaped := ""
	for character: String in text:
		if character == "[":
			escaped += "[lb]"
		elif character == "]":
			escaped += "[rb]"
		else:
			escaped += character
	return escaped


static func _render_line(line: String) -> String:
	if line.strip_edges() == SEPARATOR_LINE:
		return "[hr]"
	return _render_emphasis(_render_emphasis(line, "**", "b"), "*", "i")


## 单一 delimiter 的成对扫描：最近闭合配对；未闭合/空内容/交叠歧义整段保持原样。
## 先粗体后斜体：***x*** 类交叠按 fail-soft 处理，不发明 Markdown 优先级。
static func _render_emphasis(line: String, delimiter: String, tag: String) -> String:
	var open_tag := "[%s]" % tag
	var close_tag := "[/%s]" % tag
	var search_from := 0
	while true:
		var start := line.find(delimiter, search_from)
		if start < 0:
			return line
		var close := line.find(delimiter, start + delimiter.length())
		if close < 0:
			return line
		var inner := line.substr(start + delimiter.length(), close - start - delimiter.length())
		if inner.is_empty() or inner.contains(delimiter):
			return line
		line = line.substr(0, start) + open_tag + inner + close_tag + line.substr(close + delimiter.length())
		search_from = start + open_tag.length() + inner.length() + close_tag.length()
	return line
