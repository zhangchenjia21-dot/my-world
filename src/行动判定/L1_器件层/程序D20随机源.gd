class_name ProgramD20RandomSource
extends RefCounted

var invocation_count := 0
var _random := RandomNumberGenerator.new()


func _init() -> void:
	_random.randomize()


## 生产骰面只来自 Godot 的 Program RNG；测试可注入实现同一 roll_d20 seam 的确定性对象。
func roll_d20() -> int:
	invocation_count += 1
	return _random.randi_range(1, 20)
