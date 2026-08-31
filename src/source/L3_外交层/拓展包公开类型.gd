class_name ExpansionPackSourceProjection
extends RefCounted

## 公开 projection 只携带 authored semantics 与声明式 capability binding；它不允许携带可执行行为。
var identity: Dictionary
var display_name: String
var catalog_summary: String
var capability_binding: Dictionary
var semantic_sections: Array


func _init(data: Dictionary) -> void:
	identity = data.identity.duplicate(true)
	display_name = String(data.display_name)
	catalog_summary = String(data.catalog_summary)
	capability_binding = data.capability_binding.duplicate(true)
	semantic_sections = data.semantic_sections.duplicate(true)
